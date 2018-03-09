# ardupilot

## 1.罗盘校验数据存储

```
Compass::accept_calibration->set_and_save_offsets->Compass::save_offsets
```

save_offsets中实际是调用了bool AP_Param::save(bool force_save)，具体怎么调过来的要研究一下C++的模板

```
save->eeprom_write_check 写入FRAM

    ->send_parameter 发mavlink
```

## 2.从存储器加载参数

```
load_parameters->StorageAccess::read_block->PX4Storage::read_block
PX4Storage::read_block中先调用了
PX4Storage::storage_open，这个里面会把读出来的数据都放在buffer，然后返回
再将_buffer中的数据memcpy到read_block中传入的buffer
```

## 3.看上去略坑的 param系统

 param实际上是px4的参数管理系统，对于ardupilot来讲并没有用，证据在ardupilot/modules/PX4Firmware/src/modules/systemlib/module.mk：

```
ifneq ($(ARDUPILOT_BUILD),1)
# ArduPilot uses its own parameter system
SRCS += param/param.c \
system_params.c \
circuit_breaker_params.c
endif
```

实际上hal层中实现了几个px4的param系统的空函数：px4_param.cpp

## 4.spi死锁风险

​       nuttx内核中的spi驱动接口是有锁保护的，但问题是ardupilot中的spi接口都是在hrt的中断回调函数中调用，如果spi接口在其他非中断的地方调用，并在拿到锁后恰好被hrt中断打断，那hrt中断就会死等这把锁，中断永远出不来了，所以必须要注意的是，飞控系统中，spi接口只能在hrt中断中调用，并且还要时刻注意中断嵌套，对于zynq来说只有两级中断嵌套，firq可以打断irq，只要别再firq中调用spi就不会有问题     

## 5.uORB

uORB是一个命名空间

**main:**

uORB::DeviceMaster -> init ->CDev::init -> Device::init (实例化DeviceMaster的时候没有传中断，也就是说这个模块没用到中断，所以这个调用基本没用)

  -> register_driver:_devname=/obj/_obj_ name=obj_master

**orb_advertise_multi:**

  调用get_instance获取uORB::Manager,第一次调用的时候会new一个Manager类

  然后调用Manager::orb_advertise_multi -> Manager::node_open -> Utils::node_mkpath 根据instance计数生成总路径名，放入path变量，实际上instance就是路径的数字后缀，这样可以支持多个主题发布者

  -> open 尝试打开刚才的path，没创建过所以肯定是失败

  -> Manager::node_advertise 之前打开path失败就调这个接口创建节点，实际上就是通过CDev的register_driver来创建节点的,里面调用ioctl命令ORBIOCADVERTISE

  命令中new了一个DeviceNode类，它继承了CDev,orb_advertise_multi返回值就是它

  -> Manager::orb_publish 发布初始消息

**orb_advertise:**

  和有multi的比起来少了两个参数，一个用于计个数的instance，一个优先级，实际调的都是Manager::orb_advertise_multi, 没有的两个参数传空和默认优先级

**orb_publish:**

  orb_advertise_multi会返回一个orb_advert_t的数据作为handle传入Manager::orb_publish -> DeviceNode::publish -> DeviceNode::write 申请内存_data，将要发布的数据拷贝到_data,调用poll_notify通知等待的人

**orb_subscribe:**

  订阅主题调到最后实际就是open了相应的设备节点，返回节点的fd

**orb_copy:**

  实际上就是设备节点的read操作

**orb_check:**

  调用Mana::orb_check -> ioctl ORBIOCUPDATED -> apprears_updated 对比_generation，这个值在publish后会++，如果不一样代表有新数据，如果上层有设置intervel，则调用hrt_call_after，在intervel时间过后再通知有新数据



## 6.Mavlink传数据

​          以发送心跳包为例：

​          Copter::gcs_send_heartbeat                                        =>GCS_Mavlink.cpp

​                              |

   Copter::gcs_send_message(MSG_HEARTBEAT)               =>GCS_Mavlink.cpp

​                              |

GCS_MAVLINK::send_message(MSG_HEARTBEAT)             =>GCS_Common.cpp

​                              |

GCS_MAVLINK::try_send_message(MSG_HEARTBEAT)       =>GCS_Mavlink.cpp

​                              |

 Copter::send_heartbeat(mavlink_channel_t chan)               =>GCS_Mavlink.cpp

​                              |

​          mavlink_msg_heartbeat_send                                      =>mavlink_msg_heartbeat.h由python生成，直接拷过来用即可

​                              |

​     _mav_finalize_message_chan_send                                  =>mavlink_helpers.h

​                              |

​               _mavlink_send_uart                                                   =>mavlink_helpers.h

​                              |

​                   comm_send_ch                                                     =>GCS_MAVLink.h

​                              |

​        mavlink_comm_port[chan]->write(ch)                           =>GCS_MAVLink.h

mavlink_comm_port的设置：

​                    Copter::setup

​                               |

​               Copter::init_ardupilot         setup_uart调4次，分别对应usb串口、两个数传，最后调的那个数传是不存在的，不用管

​                               |

​            GCS_MAVLINK::setup_uart       调用hal层uart的begin接口初始化串口

​                              |

​               GCS_MAVLINK::init                将UARTDriver的实例赋值给mavlink_comm_port

```
GDB栈跟踪：

#0  mavlink_msg_raw_imu_send (chan=MAVLINK_COMM_0, time_usec=254088178, xacc=11, yacc=1, zacc=-991, xgyro=14, ygyro=-7, zgyro=-18, xmag=0, ymag=0, zmag=0)
    at ../include/GCS_MAVLink/include/mavlink/v1.0/ardupilotmega/../common/./mavlink_msg_raw_imu.h:229
#1  0x1a1614d8 in GCS_MAVLINK::send_raw_imu (this=0x1a3133bc <copter+5384>, ins=..., compass=...) at ../src/libraries/GCS_MAVLink/GCS_Common.cpp:995
#2  0x1a18fbdc in GCS_MAVLINK::try_send_message (this=0x1a3133bc <copter+5384>, id=MSG_RAW_IMU1) at ../src/copter/GCS_Mavlink.cpp:600
#3  0x1a160624 in GCS_MAVLINK::send_message (this=0x1a3133bc <copter+5384>, id=MSG_RAW_IMU1) at ../src/libraries/GCS_MAVLink/GCS_Common.cpp:785
#4  0x1a190730 in GCS_MAVLINK::data_stream_send (this=0x1a3133bc <copter+5384>) at ../src/copter/GCS_Mavlink.cpp:898
#5  0x1a193944 in Copter::gcs_data_stream_send (this=0x1a311eb4 <copter>) at ../src/copter/GCS_Mavlink.cpp:2056
#6  0x1a1f9ba4 in Functor<void>::method_wrapper<Copter, &Copter::gcs_data_stream_send> (obj=0x1a311eb4 <copter>) at ../src/libraries/AP_HAL/utility/functor.h:85
#7  0x1a1de1b4 in Functor<void>::operator() (this=0x1a228148 <Copter::scheduler_tasks+480>) at ../src/libraries/AP_HAL/utility/functor.h:55
#8  0x1a0655cc in AP_Scheduler::run (this=0x1a312284 <copter+976>, time_available=2258) at ../src/libraries/AP_Scheduler/AP_Scheduler.cpp:133
#9  0x1a1948c8 in Copter::loop (this=0x1a311eb4 <copter>) at ../src/copter/ArduCopter.cpp:251
#10 0x1a047bbc in main_loop (pvParameters=0x0) at ../src/libraries/AP_HAL_ZYNQ/HAL_PX4_Class.cpp:156        
```

## 7.加速度计校验

```
Copter::accel_cal_update
AP_InertialSensor::acal_update
AP_AccelCal::update
mat_inverse
```

## 8.AP_Param

​          先实例化一个StorageAccess类：StorageAccess AP_Param::_storage(StorageManager::StorageParam); 

​          StorageParam代表是专门存储参数的区域，一共有12个区域，分为四种，详见StorageManager.cpp，每种类型的存储区域有3块内存，

一块满了存下一块，都满了就从头开始覆盖

```
AP_Param::setup_sketch_defaults
AP_Param::setup
AP_Param::erase_all
eeprom_write_check
StorageAccess::write_block         
```

   ## 9.

```
Copter::pre_arm_gps_checks
AP_AHRS_NavEKF::healthy
```

## 10.Arm: gyros still settling

​	iltErrFilt这个值貌似根据不同板子要调过的，NavEKF2_core::checkAttitudeAlignmentStatus函数中通过一下公式计算			tiltErrFilt
 = alpha*temp + (1.0f-alpha)*tiltErrFilt;

​      alpha值在NavEKF2_core::readIMUData() 函数中赋值，貌似代表前后数据才采集的时间间隔，应该是越小越好

​      temp代表向量误差，应该也是越小越好

​     数据对比详见附件，可以看到，stm32的alph和temp值都较大，说明误差和时间间隔都较大，所以tiltErrFilt很快可以减到0.005，但是zynq都较小，所以要很久，目前就把tiltErrFilt的初始值改小

## 11.飞控代码下载重启流程

```
(gdb) bt

#0 px4systemreset (to_bootloader=false) at /home/steven/Steven/Develop/ardupilot/ardupilot/modules/PX4Firmware/src/platforms/nuttx/px4layer/px4_nuttx_tasks.c:64

#1 0x0806f00a in PX4::PX4Scheduler::reboot (this=<optimized out>, hold_in_bootloader=<optimized out>) at /home/steven/Steven/Develop/ardupilot/ardupilot/libraries/AP_HAL_PX4/Scheduler.cpp:225

#2 0x0800a5e0 in GCS_MAVLINK::handleMessage (this=this@entry=0x200023cc <copter+5384>, msg=msg@entry=0x1000c720) at /home/steven/Steven/Develop/ardupilot/ardupilot/ArduCopter/GCS_Mavlink.cpp:1472

#3 0x0801a0f0 in GCS_MAVLINK::update (this=this@entry=0x200023cc <copter+5384>, run_cli=...) at /home/steven/Steven/Develop/ardupilot/ardupilot/libraries/GCS_MAVLink/GCS_Common.cpp:840

#4 0x08008e74 in Copter::gcs_check_input (this=this@entry=0x20000ec4 <copter>) at /home/steven/Steven/Develop/ardupilot/ardupilot/ArduCopter/GCS_Mavlink.cpp:2074

#5 0x08008ed4 in Copter::mavlink_delay_cb (this=0x20000ec4 <copter>) at /home/steven/Steven/Develop/ardupilot/ardupilot/ArduCopter/GCS_Mavlink.cpp:2015

#6 0x0806f2d0 in PX4::PX4Scheduler::delay (this=0x20003e18 <schedulerInstance>, ms=<optimized out>) at /home/steven/Steven/Develop/ardupilot/ardupilot/libraries/AP_HAL_PX4/Scheduler.cpp:155

#7 0x0800a5be in GCS_MAVLINK::handleMessage (this=this@entry=0x200023cc <copter+5384>, msg=msg@entry=0x1000c968) at /home/steven/Steven/Develop/ardupilot/ardupilot/ArduCopter/GCS_Mavlink.cpp:1470

#8 0x0801a0f0 in GCS_MAVLINK::update (this=this@entry=0x200023cc <copter+5384>, run_cli=...) at /home/steven/Steven/Develop/ardupilot/ardupilot/libraries/GCS_MAVLink/GCS_Common.cpp:840

#9 0x08008e74 in Copter::gcs_check_input (this=0x20000ec4 <copter>) at /home/steven/Steven/Develop/ardupilot/ardupilot/ArduCopter/GCS_Mavlink.cpp:2074

#10 0x0806b268 in Functor<void>::operator() (this=<optimized out>) at /home/steven/Steven/Develop/ardupilot/ardupilot/libraries/AP_HAL/utility/functor.h:55

#11 AP_Scheduler::run (this=0x20001294 <copter+976>, time_available=2179) at /home/steven/Steven/Develop/ardupilot/ardupilot/libraries/AP_Scheduler/AP_Scheduler.cpp:128

#12 0x080710a6 in main_loop (argc=<optimized out>, argv=<optimized out>) at /home/steven/Steven/Develop/ardupilot/ardupilot/libraries/AP_HAL_PX4/HAL_PX4_Class.cpp:176

#13 0x080a823e in task_start () at task_start.c:138

#14 0x00000000 in ?? ()
```

## 12.4轴6轴

BOARD_PWM_COUNT_DEFAULT

## 13.死机问题定位

CAN 项目中imu板子数据发的太快飞控这端就会死机：

```
Assertion failed at file:armv7-m/up_hardfault.c line: 184 task: Idle Task
sp: 2000ed58
IRQ stack:
  base: 2000ed9c
  size: 000002e8
2000ed40: 080d9498 000000b8 080d93d2 2000ed58 2000f434 080ab20b 080d9498 000000b8
2000ed60: 080a4e15 00000010 2000d24c 00000003 2000f33c 080ab4a9 080ab495 080b5971
2000ed80: 00000010 00000000 2000ed68 2000f33c 0011fe00 080ab419 2000eccc 00000000
sp: 080d934c
User stack:
  base: 2000f434
  size: 000003e8
R0: 080d93d2 2000ed4c 40007800 080ab231 2000cec4 2000ed9c 080a782f 080b3c35
R8: 00000007 00000000 00000000 00000000 080d93ed 080d934c 080d93d2 2000ed4c
xPSR: 00000000 BASEPRI: 080d8192 CONTROL: 00000000
EXC_RETURN: 080d9447
```

挂上gdb提示段错误，但是地址很诡异 ：

```
(gdb) bt

#0 0x3e50000c in ?? ()

#1 0x080848a6 in robcan_recv_frame (desc=desc@entry=0x200000f8 <g_can2desc>, frame=frame@entry=0x2000ed68 <up_interruptstack+696>)
  at /home/steven/Steven/Develop/ardupilot/ardupilot/modules/PX4Firmware/src/drivers/robcan/stm32_can_drv.cpp:755

#2 0x08084934 in robcan_rx0interrupt (irq=<optimized out>, context=<optimized out>) at /home/steven/Steven/Develop/ardupilot/ardupilot/modules/PX4Firmware/src/drivers/robcan/stm32_can_drv.cpp:498

#3 0x080b5970 in up_doirq (irq=80, regs=0x2000f33c) at armv7-m/up_doirq.c:102

#4 0x080ab418 in exception_common () at armv7-m/up_exception.S:141

#5 0x080ab418 in exception_common () at armv7-m/up_exception.S:141

#6 0x080ab418 in exception_common () at armv7-m/up_exception.S:141

Backtrace stopped: previous frame inner to this frame (corrupt stack?)
```

查看cpu寄存器：

```
r0 0x20011fe0 536944608

r1 0x0 0

r2 0x2000ed6f 536931695

r3 0x1 1

r4 0x0 0

r5 0x2000ed68 536931688

r6 0x2000f33c 536933180

r7 0x11fe00 1179136

r8 0x0 0

r9 0x0 0

r10 0x0 0

r11 0x0 0

r12 0x3e4fca69 1045416553

sp 0x2000ed58 0x2000ed58 <up_interruptstack+680>

lr 0x80848a7 0x80848a7 <robcan_recv_frame(can_describe*, can_frame*)+30>

pc 0x3e50000c 0x3e50000c

xpsr 0x1000003 16777219
```

lr值为

```
<robcan_recv_frame(can_describe*, can_frame*)+30>
```

说明pc是从这里跳到0x3e50000c这个地址的

查看跳转代码语句：

```
l *(robcan_recv_frame+30)

0x80848a6 is in robcan_recv_frame(can_describe, can_frame) (/home/steven/Steven/Develop/ardupilot/ardupilot/modules/PX4Firmware/Build/px4fmu-rob_APM.build/nuttx-export/include/arch/armv7-m/irq.h:232).
```

提示是从irq.h:232行也就是memory这句（memory强制gcc编译器假设RAM所有内存单元均被汇编指令修改，这样cpu中的registers和cache中已缓存的内存单元中的数据将作废。cpu将不得不在需要的时候重新读取内存中的数据。这就阻止了cpu又将registers，cache中的数据用于去优化指令，而避免去访问内存。）

查看代码是个inline函数setbasepri，在函数irqrestore中调用，在函数

int32_t robcan_recv_frame(struct can_describe *desc, struct can_frame *frame)                                                                                    中注释掉就不会死了

再看反汇编

```
80848a2: f7fd fcdc bl 808225e <_ZN14RobCan_Manager6can_rxEP9can_frame>
80848a6: b2e4 uxtb r4, r4                                                                        80848a8: f384 8811 msr BASEPRI, r4
80848ac: 2000 movs r0, #0  
```

就是msr BASEPRI, r4导致死机，r4的值是0

BASEPRI是一个9位寄存器。它定义了屏蔽优先级。 当它置位时, 所有同级的或低级的中断被忽略

## 14.LED闪烁代码

​     继承关系: ToshibaLED_PX4 -> ToshibaLED -> RGBLed

​                   SCHED_TASK(update_notify,         50,     90)

​                                                               |

​                                               Copter::update_notify

​                                                                |

​                                                 RGBLed::update()
​                                                                |

​                                          RGBLed::update_colours(void)

​                                                                 |

​                                                   RGBLed::set_rgb

​                                                                  |

​                                           ToshibaLED_PX4::hw_set_rgb  <---(union rgb_value)---    ToshibaLED_PX4::update_timer

## 15.自稳姿态控制

Copter::fast_loop

​		|

AC_AttitudeControl_Multi::rate_controller_run

​		|

AC_AttitudeControl::rate_target_to_motor_roll (传入_rate_target_ang_vel)





Copter::fast_loop

​			|

Copter::stabilize_run

​			|

AC_AttitudeControl::input_euler_angle_roll_pitch_euler_rate_yaw

​			|

AC_AttitudeControl::attitude_controller_run_quat (计算出_rate_target_ang_vel )



## 16.写log

Log_Write_Compass
mavlink_raw_imu_t
mavlink_msg_raw_imu_pack
mavlink_msg_raw_imu_encode

sd卡log数据大约15KB/s, 15bytes/ms 2k的buff可存135ms的数据

Breakpoint 1, DataFlash_File::start_new_log (this=0x1a26f108 <ucHeap+174048>) at ../src/libraries/DataFlash/DataFlash_File.cpp:830
830	    _write_fd = ::open(fname, O_WRONLY|O_CREAT|O_TRUNC, 0666);
(gdb) s
open (path=0x1a3165f0 "/fs/microsd/APM/LOGS/14.BIN", oflags=38) at ../src/FreeRTOS/robsense_custom/fs/fs_open.c:91
91	  FAR const char      *relpath = NULL;
(gdb) n
93	  mode_t               mode = 0666;
(gdb) 
100	  list = sched_getfiles();
(gdb) 
101	  if (!list)
(gdb) 
125	  inode = inode_find(path, &relpath);
(gdb) 
126	  if (!inode)
(gdb) p relpath 
$1 = 0x1a3165fc "APM/LOGS/14.BIN"

## 17.自动生成的buildin_command.c

每个传感器驱动代码的文件夹下有一个module.mk, 里面给MODULE_COMMAND赋值, 这个值不能有重复,然后在module.mk中, 根据MODULE_COMMAND在编译目录下生成相关名称的空文件, 最后在firmware.mk中生成builtin_commands.c

  ## 18. 已用ioctl基数

- 0x0100 - terminal
- 0x0200 - watch dog driver
- 0x0300 - file system
- 0x0400 - character driver
- 0x0500 - block driver
- 0x0600 - MTD driver
- 0x0700 - socket
- 0x0800 - arp
- 0x0900 - touchsreen
- 0x0a00 - sensor
- 0x0b00 - adc/dac
- 0x0c00 - pwm
- 0x0d00 - cdc/acm
- 0x0e00 - battery
- 0x0f00 - Quadrature encoder
- 0x1000 - audio
- 0x1100 - segment lcd, wireless
- 0x2700 - px4 gpio
- 0x2800 - px4 gps, io expander
- 0x2b00 - px4 rc input
- 0x2c00 - px4 sbus
- 0x2d00 - oreoled
- 0x2e00 - px4 smbus
- 0x4000 - px4 uavcan
- 0x7700 - px4flow
- 0x7900 - px4 range finder
- 0xff00  - px4io



各个传感器典型值

```
accel
level:
  accel x: -0.42114 m/s^2
  accel y: 0.00000 m/s^2
  accel z: -9.80100 m/s^2
  accel x: 0 raw
  accel y: -176 raw
  accel z: -4096 raw
left:
  accel x: -1.07198 m/s^2 
  accel y: 10.26042 m/s^2 
  accel z: 0.45942 m/s^2 
  accel x: -4288 raw 
  accel y: -448 raw 
  accel z: 192 raw
right:
  accel x: 0.61256 m/s^2 
  accel y: -9.68615 m/s^2 
  accel z: -0.26800 m/s^2 
  accel x: 4048 raw 
  accel y: 256 raw 
  accel z: -112 raw
up:
  accel x: 9.15015 m/s^2 
  accel y: 1.79940 m/s^2 
  accel z: -0.49771 m/s^2 
  accel x: -752 raw 
  accel y: 3824 raw 
  accel z: -208 raw
down:
  accel x: -9.03530 m/s^2 
  accel y: -0.80399 m/s^2 
  accel z: -0.19143 m/s^2 
  accel x: 336 raw 
  accel y: -3776 raw 
  accel z: -80 raw
back:
  accel x: 0.15314 m/s^2 
  accel y: 0.68913 m/s^2 
  accel z: 9.72443 m/s^2 
  accel x: -288 raw 
  accel y: 64 raw 
  accel z: 4064 raw
gyro:
left:
  gyro x: -1.29259 rad/s 
  gyro y: -0.63286 rad/s 
  gyro z: 0.04154 rad/s 
  temp: 0 C 
  gyro x: 518 raw 
  gyro y: -1058 raw 
  gyro z: 34 raw 
  temp: 0 raw 
  gyro range: 34.9066 rad/s (2000 deg/s)
rigth:
  gyro x: 1.76540 rad/s 
  gyro y: 0.16738 rad/s 
  gyro z: -0.11240 rad/s 
  temp: 0 C 
  gyro x: -137 raw 
  gyro y: 1445 raw 
  gyro z: -92 raw 
  temp: 0 raw 
  gyro range: 34.9066 rad/s (2000 deg/s)
up:
  gyro x: -0.12584 rad/s 
  gyro y: 2.73545 rad/s 
  gyro z: -0.28466 rad/s 
  temp: 0 C 
  gyro x: -2239 raw 
  gyro y: -103 raw 
  gyro z: -233 raw 
  temp: 0 raw 
  gyro range: 34.9066 rad/s (2000 deg/s)
down:
  gyro x: 0.18204 rad/s 
  gyro y: -2.20522 rad/s 
  gyro z: -0.04520 rad/s 
  temp: 0 C 
  gyro x: 1805 raw 
  gyro y: 149 raw 
  gyro z: -37 raw 
  temp: 0 raw 
  gyro range: 34.9066 rad/s (2000 deg/s)
x朝南：
  lsm303d: mag device active: onboard
  lsm303d: mag x: -0.35104 ga
  lsm303d: mag y: 0.06544 ga
  lsm303d: mag z: -2.62144 ga
  lsm303d: mag x: -4388 raw
  lsm303d: mag y: 818 raw
  lsm303d: mag z: -32768 raw
  lsm303d: mag range: 2.0000 ga
x朝北：
  lsm303d: mag x: 0.36544 ga
  lsm303d: mag y: 0.04656 ga
  lsm303d: mag z: 0.54120 ga
  lsm303d: mag x: 4568 raw
  lsm303d: mag y: 582 raw
  lsm303d: mag z: 6765 raw
  lsm303d: mag range: 2.0000 ga
x朝东：
  lsm303d: mag device active: onboard
  lsm303d: mag x: -0.06728 ga
  lsm303d: mag y: -0.29040 ga
  lsm303d: mag z: 0.54568 ga
  lsm303d: mag x: -841 raw
  lsm303d: mag y: -3630 raw
  lsm303d: mag z: 6821 raw
  lsm303d: mag range: 2.0000 ga
x朝西：
  lsm303d: mag device active: onboard
  lsm303d: mag x: 0.13568 ga
  lsm303d: mag y: 0.41456 ga
  lsm303d: mag z: 2.62136 ga
  lsm303d: mag x: 1696 raw
  lsm303d: mag y: 5182 raw
  lsm303d: mag z: 32767 raw
  lsm303d: mag range: 2.0000 ga
```



