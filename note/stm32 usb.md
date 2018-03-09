# stm32 usb

```
stm32fx07_poll -> user_callback_ctr
```

user_callback_ctr是一个[8][3]数组，代表usb的8个双向端点（ep）和3类transactions模式：

Setup transaction:主机用来向设备发送控制命令

Data IN transaction:主机用来从设备读取数据

Data OUT transaction:主机用来向设备发送数据     （总是由主机发起）

在libopencm3的代码中他们分别对应枚举：

```
enum _usbd_transaction {
	USB_TRANSACTION_IN,
	USB_TRANSACTION_OUT,
	USB_TRANSACTION_SETUP,
};
```

8个端点中，ep0是必备的，在libopencm3的驱动中，0用作刚插入时的枚举，属于控制端点，其他平台应该也是这么用的

usb协议中定义了4中传输类型：

```
控制传输(Control Transfers): 非周期性,突发
      用于命令和状态的传输

 大容量数据传输(Bulk Transfers): 非周期性,突发
      大容量数据的通信,数据可以占用任意带宽,并容忍延迟

 同步传输(Isochronous Transfers): 周期性
      持续性的传输,用于传输与时效相关的信息,并且在数据中保存时间戳的信息

 中断传输(Interrupt Transfers): 周期性,低频率
      允许有限延迟的通信
```

在libopencm3的代码中他们分别对应宏：

```
#define USB_ENDPOINT_ATTR_CONTROL           0x00

#define USB_ENDPOINT_ATTR_ISOCHRONOUS       0x01

#define USB_ENDPOINT_ATTR_BULK              0x02

#define USB_ENDPOINT_ATTR_INTERRUPT         0x03
```

每种传输类型单独使用一个ep

数据传输以107驱动为例，经过初始化配置后函数指针和对应函数关系如下：

```
usbd_ep_read_packet -> stm32fx07_ep_read_packet
usbd_ep_write_packet -> stm32fx07_ep_write_packet
usbd_poll -> stm32fx07_poll
user_callback_ctr0 -> _usbd_control_in
user_callback_ctr0  -> _usbd_control_out
user_callback_ctr0 -> _usbd_control_setup
user_callback_ctr1 -> cdcacm_data_rx_cb
user_callback_ctr1  -> NULL
user_callback_ctr1 -> NULL
```

所以user_callback_ctr都会在poll或中断中调用，如果是控制指令则调用user_callback_ctr[0][1]给host发送回复