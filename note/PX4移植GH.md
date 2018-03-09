# PX4移植GH

工程路径：http://192.168.0.11/phenix-lite-develops/px4/px4-firmware



1.cmake/configs文件夹下增加nuttx_phenix-gh_default, 从nuttx_px4fmu-v4_default.cmake拷贝, 修改相应驱动目录, 所有需要编译的驱动都在这里设置

2.增加gh的传感器驱动到src/drivers/

3.drivers/boards/下增加phenix-gh文件夹

board_config.h	BOARD_BATTERY1_V_DIV是什么?
CMakeLists.txt
px4fmu_can.c*
px4fmu_init.c*
px4fmu_led.c*
px4fmu_pwm_servo.c 改为px4fmu_timer_config.c
px4fmu_spi.c*
px4fmu_usb.c*

4.nuttx-configs/文件夹下增加phenix-gh文件夹 

CONFIG_ARCH_BOARD_PX4FMU_V2

5.改启动脚本 ROMFS/init.d/

6.改根目录makfile

7.Images/目录增加phenix-gh.prototype

8.bootloader额hw_config.h增加TARGET_HW_PHENIX_GH

​	USBPRODUCTID对应deconfig中的CONFIG_CDCACM_PRODUCTID

​	BOARD_TYPE对应phenix-gh.prototype中的board_id



9.up_serialinit  串口初始化, 包括console console是ttyS0

- ttyS0	usart2	*	console



- ttyS1       usart3	*	telem


- ttyS2       uart4       *	GPS


- ttyS3       usart6     *      sbus


- ttyS4       uart7


- ttyS5       uart8



10.06-30-10:13:08ERROR [sensors] Gyro #1 fail:  STALE!

```
#0  DataValidator::confidence (this=this@entry=0x1000d700, timestamp=1609856) at /home/steven/Steven/Develop/px4/Firmware/src/lib/ecl/validation/data_validator.cpp:121
#1  0x08074f10 in DataValidatorGroup::get_best (this=this@entry=0x1000bf18, timestamp=<optimized out>, index=index@entry=0x1000d2b0)
    at /home/steven/Steven/Develop/px4/Firmware/src/lib/ecl/validation/data_validator_group.cpp:140
#2  0x0801407a in sensors::VotedSensorsUpdate::accel_poll (this=this@entry=0x1000bea8, raw=...) at /home/steven/Steven/Develop/px4/Firmware/src/modules/sensors/voted_sensors_update.cpp:608
#3  0x08014fb6 in sensors::VotedSensorsUpdate::sensors_poll (this=this@entry=0x1000bea8, raw=...) at /home/steven/Steven/Develop/px4/Firmware/src/modules/sensors/voted_sensors_update.cpp:1055
#4  0x080126f2 in Sensors::task_main (this=0x1000b6e0) at /home/steven/Steven/Develop/px4/Firmware/src/modules/sensors/sensors.cpp:585
#5  0x08012882 in Sensors::task_main_trampoline (argc=<optimized out>, argv=<optimized out>) at /home/steven/Steven/Develop/px4/Firmware/src/modules/sensors/sensors.cpp:545
#6  0x0808d134 in task_start () at task/task_start.c:131
#7  0x00000000 in ?? ()
```

​	static const constexpr unsigned VALUE_EQUAL_COUNT_DEFAULT = 100;	/**< if the sensor value is the same (accumulated also between axes) this many times, flag it */   --> ERROR_FLAG_STALE_DATA



11.WARN  [commander] MANUAL CONTROL LOST (at t=492322ms)

fmu publish input_rc --> rc_poll subscribe input_rc & publish manual_control_setpoint  			manual.timestamp = rc_input.timestamp_last_signal;  -->commander_thread_main  subscribe manual_control_setpoint

ttyS3和GPS冲突了



12.WARN  [commander][cal] Accel #0 (ID 4588042) no matching uORB devid

驱动的_checked_values数组没有初始化, 最后一个成员没有赋值,是个随机值, 导致measure在check reg的时候误认为寄存器值错误而退出



13.hil仿真飞机无法起飞

按R, 发现ROTOR的control都是0, drivers/pwm_out_sim驱动加上即可



14.gps

如果gps start时没有指定-p , mode就是NONE, mode_auto就是true, interface默认是UART

gps如果没搜到信号应该是会重新找gps

gps刚开始找到后来丢了, 因为rc里面把ttys2配成了第二个mavlink, 冲突了



15.pwm 可以把中断关掉

需要改的接口:

io_timer_init_timer



16.服务器编译出错

fatal: Not a git repository: /home/steven/Steven/Develop/px4/Firmware/.git/modules/NuttX/modules/NxWidgets
fatal: Not a git repository: /home/steven/Steven/Develop/px4/Firmware/.git/modules/NuttX/modules/NxWidgets
fatal: Not a git repository: /home/steven/Steven/Develop/px4/Firmware/.git/modules/NuttX/modules/NxWidgets
fatal: Not a git repository: /home/steven/Steven/Develop/px4/Firmware/.git/modules/NuttX/modules/NxWidgets

```
[rst008@localhost Firmware]$ git status
fatal: Not a git repository: /home/steven/Steven/Develop/px4/Firmware/.git/modules/NuttX/modules/NxWidgets
```

把NuttX/NxWidgets/.git中的绝对路径改成相对路径, 如果有其他相对路径继续git status查看,然后修改

17.指定编译器

cmake/toolchains/Toolchain-arm-none-eabi.cmake

18.编译命令

```
make phenix-gh_default upload
```
