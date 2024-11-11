### 1.镜像构建
#### 1.1 预下载路径(服务器10.0.11.100)
```
/mnt/public/sdk/yocto1.4.3
```
解压后层级如下：
```
data
├── yocto-downloads  #三方仓库的共享目录
├── yocto_p1         #工程1
```

#### 1.2 编译
```
#进入构建目录
cd yocto_p1

#配置环境变量，执行后会进入zhihe-build/p1-fm目录
source openembedded-core/oe-init-build-env zhihe-build/p1-fm

#构建基础镜像：新老版本命令有不同，后续命令都以新版本为准，老版本参考下面命令修改
MACHINE=p1-evb bitbake image-linux
MACHINE=p1-evb bitbake image-xfce

#查看所有包名
bitbake -s
```

#### 1.3 各种路径
总镜像
```
~/data/yocto_p1/zhihe-build/p1-fm/deploy-tools/tarball/prebuild_p1-evb.tar.gz
```
内核驱动源码
```
~/data/yocto_p1/zhihe-build/p1-fm/tmp-glibc/work/p1_evb-oe-linux
```
应用层软件包源码
```
~/data/yocto_p1/zhihe-build/p1-fm/tmp-glibc/work/riscv64-oe-linux
```
所有包和驱动都可以单独编译，bitbake后面跟源码文件夹名称即可

omxil库：
```
~data/yocto_p1/zhihe-build/p1-fm/tmp-glibc/work/riscv64-oe-linux/p1-bsp-prebuild/1.0-r0/git/vpu-omxil/usr/lib/omxil/
```
ffmpeg
```
~/data/yocto_p1/zhihe-build/p1-fm/tmp-glibc/work/riscv64-oe-linux/ffmpeg/5.1.3-r2
~/data/yocto_p1/zhihe-build/p1-fm/tmp-glibc/work/riscv64-oe-linux/ffmpeg/6.1.1-r2
```


#### 1.4 单独编译内核
```
MACHINE=p1-evb bitbake linux-kernel -c menuconfig
MACHINE=p1-evb bitbake linux-kernel -C compile
```

#### 1.5 软件包修改源码后编译
yocto支持修改后直接编译，调试阶段不需要生成patch以及修改.bbappend文件，否则效率太低了
以ffmpeg为例

```
bitbake ffmpeg -c compile -f;
```
编译后deb文件路径
```
~/data/yocto_p1/zhihe-build/p1-fm/tmp-glibc/work/riscv64-oe-linux/ffmpeg/6.1.1-r2/deploy-debs/riscv64
```

#### 1.6 编译编解码驱动
```
MACHINE=p1-evb bitbake vpu-vc8000e-kmd vpu-vc8000d-kmd buffer-video -C compile
```
编译完后deb和ko文件分别在源码上层目录的deploy-debs和image目录中

#### 1.7 查找包的bb文件位置

```
bitbake -e libx11 | grep ^FILE=
```

#### 1.8 导出源码

```
bitbake libdrm -c patch
```



### 2. 软件包升级版本

以ffmpeg为例

新增recipes配置：
```
cd ~/data/yocto_p1/meta-zhihe/recipes-multimedia/ffmpeg/
cp ffmpeg_5.1.3.bb ffmpeg_6.1.1.bb
```
修改bb文件，主要修改以下变量：
```
PV = "6.1.1"
PR = "r2"
SRC_URI[sha256sum] = "8684f4b00f94b85461884c3719382f1261f0d9eb3d59640a1f4ac0873616f968"
```
如果不确定sha256的值，可以先随便填一个，构建的时候等yocto下载完源码会由于sha256校验不过报错，并打印出正确的sha256的值，然后填入即可

修改~/data/yocto_p1/zhihe-build/p1-fm/conf中的auto.conf，把ffmpeg的版本改为6.6.1
```
PREFERRED_VERSION_ffmpeg ?= "6.1.1"
```

为了方便调试，以下语句加到bb文件，可在构建时打印一些调试信息：
```
bbwarn "Hello, this is a debug message from ${USER}"
```

### 3.修改源码
以ffmpeg为例
```
devtool modify ffmpeg
```
以上命令会把源码放到一个工作目录用于修改，会有以下输出
```
NOTE: Starting bitbake server...
NOTE: Reconnecting to bitbake server...
NOTE: Retrying server connection (#1)...
Loading cache: 100% |######################################################################################################| Time: 0:00:00
Loaded 4645 entries from dependency cache.
Parsing recipes: 100% |####################################################################################################| Time: 0:00:00
Parsing of 3099 .bb files complete (3059 cached, 40 parsed). 4690 targets, 174 skipped, 0 masked, 0 errors.
NOTE: Resolving any missing task queue dependencies

Build Configuration:
BB_VERSION           = "2.2.0"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "universal"
TARGET_SYS           = "riscv64-oe-linux"
MACHINE              = "p1-evb"
DISTRO               = "distro-info"
DISTRO_VERSION       = "24.1"
TUNE_FEATURES        = "riscv64"
EXTERNAL_TOOLCHAIN   = "/mnt/home/heb/data/yocto_p1/zhihe-build/p1-fm/../../riscv-toolchain"
EXTERNAL_TARGET_SYS  = "riscv64-linux"
GCC_VERSION          = "10.2.0"
meta
meta-oe
meta-python
meta-perl
meta-multimedia
meta-networking
meta-external-toolchain
meta-riscv
meta-zhihe
meta-p1
meta-gnome
meta-filesystems
meta-webserver
meta-qt5
meta-xfce
workspace            = "master:9086300d55ae1b15c2687635e3a8a44a3d8d77eb"

Initialising tasks: 100% |#################################################################################################| Time: 0:00:03
Sstate summary: Wanted 0 Local 0 Mirrors 0 Missed 0 Current 22 (0% match, 100% complete)
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 102 tasks of which 99 didn't need to be rerun and all succeeded.
NOTE: Writing buildhistory
NOTE: Writing buildhistory took: 4 seconds
INFO: Source tree extracted to /mnt/home/heb/data/yocto_p1/zhihe-build/p1-fm/workspace/sources/ffmpeg
INFO: Recipe ffmpeg now set up to build from /mnt/home/heb/data/yocto_p1/zhihe-build/p1-fm/workspace/sources/ffmpeg
```
最后一行提示了待修改源码的位置，即便源码不是从git下载的，工作目录下的源码也会变成git工程，因此可以用git命令

修改完以后一定要执行一次

```
bitbake ffmpeg -c configure
```

否则只会按默认配置来编译

用以下命令编译
```
devtool build ffmpeg
```
也可以直接

```\
bitbake ffmpeg
```

这样同时会更新deploy中的deb文件

完成修改后添加到layer中

```
git add . -A;git commit -m “XXX” 提交代码
devtool finish ffmpeg meta-zhihe  改动添加到layer
```
会有以下输出
```
NOTE: Starting bitbake server...
Loading cache: 100% |######################################################################################################| Time: 0:00:00
Loaded 4645 entries from dependency cache.
Parsing recipes: 100% |####################################################################################################| Time: 0:00:01
Parsing of 3099 .bb files complete (3058 cached, 41 parsed). 4690 targets, 174 skipped, 0 masked, 0 errors.
INFO: Adding new patch 0001-.patch
INFO: Updating recipe ffmpeg_6.1.1.bb
INFO: Cleaning sysroot for recipe ffmpeg...
INFO: Preserving source tree in /mnt/home/heb/data/yocto_p1/zhihe-build/p1-fm/workspace/attic/sources/ffmpeg.20240906120250
If you no longer need it then please delete it manually.
It is also possible to reuse it via devtool source tree argument.
```
生产了新的patch 0001-.patch，path默认会加在bb文件中，也可以挪出来放到bbappend文件中

取消strip：bb文件中加INHIBIT_PACKAGE_STRIP = "1"



开启asan

bb文件中增加

CFLAGS:append = " -fsanitize=address"
LDFLAGS:append = " -fsanitize=address"

DEPENDS += gcc-sanitizers-external
