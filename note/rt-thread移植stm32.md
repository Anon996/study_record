# rt-thread移植

## 1. 下载代码

```
git clone https://github.com/RT-Thread/rt-thread
```

## 2. 内核配置

bsp目录下有各个支持的CPU相关的包, 编译也是在那里编译, 以stm32f103rct6为例, 使用HAL库(标准库编出来太大, 有90多k)

```
cd bsp/stm32f10x-HAL/
```

修改编译器:

```
vim rtconfig.py

CROSS_TOOL设为'gcc'
EXEC_PATH设为交叉编译器bin文件夹路径
```

menuconfig:

```
scons --menuconfig
```

选好console, 需要的驱动, cpu型号等

修改启动文件:

```
vim bsp/stm32f10x-HAL/Libraries/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_stm32f103xe.s
```

在LoopFillZerobss函数中注释掉__libc_init_array, 会导致死机, 原因暂不明, 标准库里似乎也没有这句, 不知为何HAL库有

```
bl main 改为 bl entry
```

编译:

```
scons
```

