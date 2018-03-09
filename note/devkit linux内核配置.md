# Devkit Linux 内核配置

## 1. SPI

### 1.1 BUG

原版SPI驱动有以下问题:

- SPI驱动不支持普通GPIO作为片选管脚
- GPIO驱动注册了PM, 要使用GPIO必须调用zynq_gpio_request打开slcr时钟, 然而内核的上层SPI驱动spi_set_cs并没有这么做.

对于第一个问题, google后发现有人已经做好了:

```
https://lkml.org/lkml/2017/4/25/728
```

```
From	Moritz Fischer <>
Subject	[PATCH] spi: cadence: Allow for GPIO pins to be used as chipselects
Date	Tue, 25 Apr 2017 11:30:14 -0700
share 0
share 0
This adds support for using GPIOs for chipselects as described by the
default dt-bindings.

Signed-off-by: Moritz Fischer <mdf@kernel.org>
---

Hi Mark,

I've tested this on my Zynq-7000 based system with
GPIO and non-gpio based chipselects mixed.

Thanks for your time,

Moritz

---
 drivers/spi/spi-cadence.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff --git a/drivers/spi/spi-cadence.c b/drivers/spi/spi-cadence.c
index 1c57ce6..f0b5c7b 100644
--- a/drivers/spi/spi-cadence.c
+++ b/drivers/spi/spi-cadence.c
@@ -13,6 +13,7 @@
 
 #include <linux/clk.h>
 #include <linux/delay.h>
+#include <linux/gpio.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/module.h>
@@ -127,6 +128,10 @@ struct cdns_spi {
 	u32 is_decoded_cs;
 };
 
+struct cdns_spi_device_data {
+	bool gpio_requested;
+};
+
 /* Macros for the SPI controller read/write */
 static inline u32 cdns_spi_read(struct cdns_spi *xspi, u32 offset)
 {
@@ -456,6 +461,64 @@ static int cdns_unprepare_transfer_hardware(struct spi_master *master)
 	return 0;
 }
 
+static int cdns_spi_setup(struct spi_device *spi)
+{
+
+	int ret = -EINVAL;
+	struct cdns_spi_device_data *cdns_spi_data = spi_get_ctldata(spi);
+
+	/* this is a pin managed by the controller, leave it alone */
+	if (spi->cs_gpio == -ENOENT)
+		return 0;
+
+	/* this seems to be the first time we're here */
+	if (!cdns_spi_data) {
+		cdns_spi_data = kzalloc(sizeof(*cdns_spi_data), GFP_KERNEL);
+		if (!cdns_spi_data)
+			return -ENOMEM;
+		cdns_spi_data->gpio_requested = false;
+		spi_set_ctldata(spi, cdns_spi_data);
+	}
+
+	/* if we haven't done so, grab the gpio */
+	if (!cdns_spi_data->gpio_requested && gpio_is_valid(spi->cs_gpio)) {
+		ret = gpio_request_one(spi->cs_gpio,
+				       (spi->mode & SPI_CS_HIGH) ?
+				       GPIOF_OUT_INIT_LOW : GPIOF_OUT_INIT_HIGH,
+				       dev_name(&spi->dev));
+		if (ret)
+			dev_err(&spi->dev, "can't request chipselect gpio %d\n",
+				spi->cs_gpio);
+		else
+			cdns_spi_data->gpio_requested = true;
+	} else {
+		if (gpio_is_valid(spi->cs_gpio)) {
+			int mode = ((spi->mode & SPI_CS_HIGH) ?
+				    GPIOF_OUT_INIT_LOW : GPIOF_OUT_INIT_HIGH);
+
+			ret = gpio_direction_output(spi->cs_gpio, mode);
+			if (ret)
+				dev_err(&spi->dev, "chipselect gpio %d setup failed (%d)\n",
+					spi->cs_gpio, ret);
+		}
+	}
+
+	return ret;
+}
+
+static void cdns_spi_cleanup(struct spi_device *spi)
+{
+	struct cdns_spi_device_data *cdns_spi_data = spi_get_ctldata(spi);
+
+	if (cdns_spi_data) {
+		if (cdns_spi_data->gpio_requested)
+			gpio_free(spi->cs_gpio);
+		kfree(cdns_spi_data);
+		spi_set_ctldata(spi, NULL);
+	}
+
+}
+
 /**
  * cdns_spi_probe - Probe method for the SPI driver
  * @pdev:	Pointer to the platform_device structure
@@ -555,6 +618,8 @@ static int cdns_spi_probe(struct platform_device *pdev)
 	master->transfer_one = cdns_transfer_one;
 	master->unprepare_transfer_hardware = cdns_unprepare_transfer_hardware;
 	master->set_cs = cdns_spi_chipselect;
+	master->setup = cdns_spi_setup;
+	master->cleanup = cdns_spi_cleanup;
 	master->auto_runtime_pm = true;
 	master->mode_bits = SPI_CPOL | SPI_CPHA;
 
-- 
2.7.4
```

第二个问题, 把gpio-zynq.c中所有pm相关的接口都删掉即可

### 1.2 devicetree配置

要在/dev下出现spi设备节点必须要在设备树中制定spidev, 如果是gpio作为cs, 也需要额外指定:

```
&spi0{
	u-boot,dm-pre-reloc;
	status = "okay";
    num-cs = <4>;
    is-decoded-cs = <0>;
    cs-gpios = <&gpio0 34 0>, <&gpio0 35 0>, <&gpio0 36 0>, <&gpio0 37 0>;
    spidev@0{
        compatible = "spidev";    
        spi-max-frequency = <10000000>;
        reg = <0>;
    };
    spidev@1{
        compatible = "spidev";    
        spi-max-frequency = <10000000>;
        reg = <1>;
    };
    spidev@2{
        compatible = "spidev";    
        spi-max-frequency = <10000000>;
        reg = <2>;
    };
    spidev@3{
        compatible = "spidev";    
        spi-max-frequency = <10000000>;
        reg = <3>;
    };
};
```

此外, SPI控制器中的SS0管脚是无法配成普通io口来用的, 所以spi1的节点:

```
&spi1{
	u-boot,dm-pre-reloc;
	status = "okay";
    spidev@0{
        compatible = "spidev";    
        spi-max-frequency = <10000000>;
        reg = <0>;
    };
};
```



## 2. I2C

### 2.1 BUG

之前裸机驱动中的控制器bug在linux驱动中也有(AR#61664), 即多字节接收时, 在接收完毕后,rx valid位依然为1, 按裸机驱动修改即可

### 2.2 devicetree配置

zynq-7000.dtsi中的配置即可, 只需在板子私有设备树中使能即可:

```
&i2c0 {
	u-boot,dm-pre-reloc;
	status = "okay";
};

&i2c1 {
	u-boot,dm-pre-reloc;
	status = "okay";
};
```

## 3. 串口

原先的linux只使能了uart1, 要在板子私有设备树中加入uart0使能:

```
&uart0 {
	u-boot,dm-pre-reloc;
	status = "okay";
};
```

此外在aliases 节点要修改:

```
		serial0 = &uart0;
		serial1 = &uart1;

```

在加入uart0以后, 原先uart1的设备节点从ttyPS0变成了ttyPS1, 所以console的配置也要改:

- uboot启动参数

  ```
  set bootargs 'console=ttyPS1,115200 maxcpus=2 ramdisk_size=40000000 root=/dev/ram rw earlyprintk'
  ```


- 文件系统

  ```
  vim rootfs/etc/inittab
  ```

  把里面的PS0改为PS1. 这是修改shell在哪个串口中打开, 不改的话内核启动后在uart1上不能输入shell命令

- 设备节点：
  ttyPS0 - UART0 SUBS
  ttyPS1 - UART1  Console

## 4. PL串口

设备节点：

ttyS0 - UART2 - serial1

ttyS1 - UART3 - serial2

ttyS2 - UART4 - serial3

ttyS3- UART5 - GPS

### 4.1 内核配置

xilinx没有提供专门的官方驱动, 但是linux自带的8250驱动可以直接用, 需要在menuconfig下打开:

```
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- menuconfig
```

路径:

```
Device Drivers ---> 
Character devices ---> 
Serial drivers --->
[*]8250/16550 and compatible serial support
[*]Devicetree based probing for 8250 ports
```

### 4.2 devicetree配置

中断号为手册中的中断号减去32

```
    axi_uart0: serial@43c00000{
        current-speed = <115200>;
        clock-frequency = <100000000>;
        compatible="ns16550a";
        interrupt-parent = <&intc>;
        interrupts = < 0 29 4>; //interrupt id -32
        reg = < 0x43c00000 0xffff >;
        reg-offset = <0x1000>;
        reg-shift = <2>;
        xlnx,family = "zynq";
        xlnx,has-external-rclk = <0x0>;
        xlnx,has-external-xin = <0x0>;
        xlnx,is-a-16550 = <0x1>;
        xlnx,s-axi-aclk-freq-hz = <0x5f5e100>;
        xlnx,use-modem-ports = <0x0>;
        xlnx,use-user-ports = <0x0>;
        xlnx,instance = "axi_uart16550_0";
    };

    axi_uart1: serial@43c10000{
        current-speed = <115200>;
        clock-frequency = <100000000>;
        compatible="ns16550a";
        interrupt-parent = <&intc>;
        interrupts = < 0 30 4>; //interrupt id -32
        reg = < 0x43c10000 0xffff >;
        reg-offset = <0x1000>;
        reg-shift = <2>;
        xlnx,family = "zynq";
        xlnx,has-external-rclk = <0x0>;
        xlnx,has-external-xin = <0x0>;
        xlnx,is-a-16550 = <0x1>;
        xlnx,s-axi-aclk-freq-hz = <0x5f5e100>;
        xlnx,use-modem-ports = <0x0>;
        xlnx,use-user-ports = <0x0>;
        xlnx,instance = "axi_uart16550_1";
    };

    axi_uart2: serial@43c20000{
        current-speed = <115200>;
        clock-frequency = <100000000>;
        compatible="ns16550a";
        interrupt-parent = <&intc>;
        interrupts = < 0 31 4>; //interrupt id -32
        reg = < 0x43c20000 0xffff >;
        reg-offset = <0x1000>;
        reg-shift = <2>;
        xlnx,family = "zynq";
        xlnx,has-external-rclk = <0x0>;
        xlnx,has-external-xin = <0x0>;
        xlnx,is-a-16550 = <0x1>;
        xlnx,s-axi-aclk-freq-hz = <0x5f5e100>;
        xlnx,use-modem-ports = <0x0>;
        xlnx,use-user-ports = <0x0>;
        xlnx,instance = "axi_uart16550_2";
    };

    axi_uart3: serial@43c30000{
        current-speed = <115200>;
        clock-frequency = <100000000>;
        compatible="ns16550a";
        interrupt-parent = <&intc>;
        interrupts = < 0 32 4>; //interrupt id -32
        reg = < 0x43c30000 0xffff >;
        reg-offset = <0x1000>;
        reg-shift = <2>;
        xlnx,family = "zynq";
        xlnx,has-external-rclk = <0x0>;
        xlnx,has-external-xin = <0x0>;
        xlnx,is-a-16550 = <0x1>;
        xlnx,s-axi-aclk-freq-hz = <0x5f5e100>;
        xlnx,use-modem-ports = <0x0>;
        xlnx,use-user-ports = <0x0>;
        xlnx,instance = "axi_uart16550_3";
    };
```

## 5. QSPI Flash

### 5.1 内核配置

默认内核没有打开QSPI驱动,所以文件系统中找不到mtd的设备节点

```
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- menuconfig
```

路径

```
Device Drivers  --->
            <*> Memory Technology Device (MTD) support  --->
              Self-contained MTD device drivers  ---> 
                <*> Support most SPI Flash chips (AT26DF, M25P, W25X, ...)
```

### 5.2 devicetree配置

设备树中要定好flash的分区:

```
&qspi {
	u-boot,dm-pre-reloc;
	status = "okay";
	is-dual = <0>;
	num-cs = <1>;
	flash@0 {
		compatible = "s25fl256s1";
		reg = <0x0>;
		spi-tx-bus-width = <1>;
		spi-rx-bus-width = <4>;
		spi-max-frequency = <50000000>;
		#address-cells = <1>;
		#size-cells = <1>;
		partition@qspi-fsbl-uboot {
			label = "qspi-fsbl-uboot";
			reg = <0x0 0x100000>;/*1M*/
		};
		partition@qspi-linux {
			label = "qspi-linux";
			reg = <0x100000 0x500000>;/*5M*/
		};
		partition@qspi-device-tree {
			label = "qspi-device-tree";
			reg = <0x600000 0x20000>;/*128k*/
		};
		partition@qspi-rootfs {
			label = "qspi-rootfs";
			reg = <0x620000 0x15E0000>;/*21.8M*/
		};
        /*reserve 4M*/
	};
};
```

启动后在/proc/mtd下可看到分区信息, 执行文件系统根目录下的update_qspi.sh脚本可以把SD卡中的程序烧入flash

## 6. PWM 

### 6.1 内核修改

PWM管脚接在PL上, 之前用的是公司自己人写的pwm ip核, 实际上xilinx官方有提供AXI timer(**修改好IP核以后必须重新生成一边FSBL**), 可以实现一路pwm输出, 但是linux中没有官方驱动, 谷歌后发现一个人的github上有现成写好的驱动:

```
https://github.com/btanghe/xilinx-pwm
```

按照patch改好Kconfig, Makefile等文件, 然后进menuconfig使能pwm驱动, 再编译即可

```
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- menuconfig
```

路径:

```
Device Drivers  --->
		[*]Pulse-Width Modulation (PWM) Support  --->
		<*>   Xilinx PWM support
```

### 6.2 devicetree配置

一共有8个节点, 以一个为例子, 加在根节点即可:

```
    axi_timer_0: timer@42800000 {
		clock-frequency = <100000000>;
		#pwm-cells = <2>;
		clocks = <&clkc 15>;
		compatible = "xlnx,pwm-xlnx";
		reg = <0x42800000 0x10000>;
		xlnx,count-width = <0x20>;
		xlnx,gen0-assert = <0x1>;
		xlnx,gen1-assert = <0x1>;
		xlnx,one-timer-only = <0x0>;
		xlnx,trig0-assert = <0x1>;
		xlnx,trig1-assert = <0x1>;
	} ;
```

测试:

```
echo 0 > /sys/class/pwm/pwmchip0/export	
cd /sys/class/pwm/pwmchip0/pwm0/
//period is 100us
echo 100000 > period	
//duty_cycle of 30 us
echo 30000  > duty_cycle	
echo 1 > enable
```

ps: 必须先设置周期和占空比才能enable