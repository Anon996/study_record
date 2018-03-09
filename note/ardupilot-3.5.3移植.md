# ardupilot-3.5.3移植

## 1. waf

Tools/ardupilotwaf/boards.py的最后增加GH相关信息:

```
class phenix_gh(px4):
    name = 'phenix-gh'
    def __init__(self):
        super(phenix_gh, self).__init__()
        self.bootloader_name = 'phenix427_bl.bin'
        self.board_name = 'phenix-gh'
        self.romfs_exclude(['oreoled.bin'])
```

复制phenix427_bl.bin到目录:

```
mk/PX4/bootloader/
```

Tools/ardupilotwaf/px4/cmake/configs/增加nuttx_phenix-gh_apm.cmake

## 2. rcs

目前ardupilot已经抛弃了原生的px4驱动, 全部移动到上层, 和linux版一样的玩法, 用**AP_BoardConfig::PX4_BOARD_PIXRACER**之类的枚举或宏加以区分, rcs里面已经没有启动驱动的脚本代码

## 3. 板子相关外设驱动

路径modules/PX4Firmware/src/drivers/boards/下创建phenix-gh文件夹, 名字必须和1中的self.board_name相同,加入

    px4fmu_can.c
    px4fmu_init.c
    px4fmu_led.c
    px4fmu_timer_config.c
    px4fmu_spi.c
    px4fmu_usb.c
跟之前有点不一样, 结合参考老版本的ardupilot和新版的px4

## 4. nuttx配置

modules/PX4Firmware/nuttx-configs/目录下增加phenix-gh文件夹

其中defconfig中的Board Selection设置为CONFIG_ARCH_BOARD_PHENIX_GH=y

## 5. 代码宏

- 搜索CONFIG_ARCH_BOARD_PX4FMU_V4, 在有V4的地方按情况增加GH的代码
- CONFIG_HAL_BOARD_SUBTYPE HAL_BOARD_SUBTYPE_PX4_V4
- USE_FLASH_STORAGE
- GPIO_SERVO_1 
- GPIO_5V_HIPOWER_OC
- enum px4_board_type RST_BOARD_PHENIX_GH=

**注意:**libraries/AP_HAL_PX4/GPIO.cpp中不可打开TONEALARM0_DEVICE_PATH, 并且在rcS中要干掉tone alarm, 不然和pwm3,4冲突!!!

## 6. HAL_PX4

- SPIDevice.cpp  PX4_SPIDEV_LIS
- HMC5883要翻转????
- AP_InertialSensor
- AP_Compass
- AP_Baro


## 7. 改6轴

地面站配置两个参数:

FRAME_CLASS --> 2

BRD_PWM_COUNT --> 6

