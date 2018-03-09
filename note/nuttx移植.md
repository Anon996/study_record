# nuttx移植

## 1.下载代码

```
两个文件夹放在同级目录
git clone https://bitbucket.org/nuttx/nuttx.git nuttx
git clone https://bitbucket.org/nuttx/apps.git apps
```

## 2.配置

configs目录下创建phenix-dev文件夹, 从stm32_tiny目录下拷贝一下文件夹:

```
cd configs
mkdir phenix-dev
cd stm32_tiny
cp include  nsh  scripts  src ../phenix-dev/ -r
```

修改nsh中的defconfig:

注意:

- 必须要修改CONFIG_ARCH_BOARD, 否则编译的时候找不到头文件.
- 如果console的串口大于2, 必须要加CONFIG_STM32_HAVE_USART3=y这类宏,不然console出不来

执行config脚本

```
cd nuttx/tools/
./configure.sh phenix_dev/nsh/
```

## 3. gdb

在defconfig中打开**CONFIG_DEBUG_SYMBOLS**, makefile在编译时会自动加上-g参数

## 4. 编译

```
make CROSSDEV=arm-none-eabi-
```

或者menuconfig, 配置编译器:

```
System Type  --->
	Toolchain Selection--->
		CodeSourcery GNU toolchain under Linux
```



## 5.menuconfig

去http://ymorin.is-a-geek.org/projects/kconfig-frontends下载kconfig-frontends工具, 然后编译安装:

```
./configure		#configure有可能失败,注意看打印信息,装上依赖库即可
make
sudo make install
sudo cp libs/parser/.libs/libkconfig-parser-4.11.0.so /usr/lib/
```

修改configs/Kconfig:

在相应位置增加

```
config ARCH_BOARD_PHENIX_DEV
	bool "Phenix-Dev board"
	depends on ARCH_CHIP_STM32F103RC
	---help---
		A configuration for the Robsense Phenix Device Manager board. This board is based on a
		STM32F103RCT6 micro-controller chip

default "phenix_dev"               if ARCH_BOARD_PHENIX_DEV

if ARCH_BOARD_PHENIX_DEV
source "configs/phenix_dev/Kconfig"
endif

```

## 6. 应用程序入口nsh_main

menuconfig中可设置

```
RTOS Features  --->
	Tasks and Scheduling  --->
		Application entry point
```



## 7. 支持C++

menuconfig中可设置

```
Library Routines  --->
	Have C++ compiler
	Have C++ initialization
```

## 8.romfs

menuconfig配置:

```
File Systems  --->
	ROMFS file system

Application Configuration  --->
	NSH Library  --->
		Scripting Support  --->
			Support ROMFS start-up script
			ROMFS header location   --->	(Architecture-specific ROMFS path)
```

生成romfs:

```
mkdir romfs
mkdir romfs/init.d
echo "script start up" > romfs/init.d/rcS
genromfs -f romfs.img -d romfs -v -V "romfs"
```

Nuttx系统中注册romfs文件系统，需要romfs文件系统头指针，以便将文件系统编译链接进可执行文件。所以，需要将romfs映像文件生成一个头文件:

```
xxd -i romfs.img nsh_romfsimg.h
cp nsh_romfsimg.h nuttx/configs/phenix_dev/include/
```

代码中注册romfs的位置:

```
nsh_initialize -> nsh_romfsetc
```

## 9. ram大小修改

menuconfig:

```
System Type  --->
	Boot Memory Configuration  --->
		Primary RAM size
```

## 10. build-in command not found

gdb跟踪发现是线程在alloc stack的时候失败, 没内存了

## 11. ardupilot用export编译整个工程

- makefile.make中以[..].export为目标, 用make export把nuttx编译成nuttx-export.zip, 拷贝成.export的形式
- nuttx.mk中解压export, 添加里面的libapp和libnuttx
- 在firmware.mk中生成builtin_commands.c, 里面包含了要编译进nuttx的用户自定义命令
- 由于nuttx在buildin_list.c中定义了g_builtins和g_builtin_count, 但是似乎主程序定义的全局变量可以替换库中的

**PS:**  如果用到C++, 必须在自己的makefile中增加-DCONFIG_WCHAR_BUILTIN 