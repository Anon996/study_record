# Kodi17.6

## 1. 编译PC版

clone代码

```
git clone -b Jarvis git://github.com/xbmc/xbmc.git
```

安装依赖

```
sudo apt-get install python-software-properties software-properties-common
sudo add-apt-repository ppa:team-xbmc/unstable
sudo add-apt-repository ppa:team-xbmc/xbmc-ppa-build-depends
sudo add-apt-repository ppa:team-xbmc/xbmc-nightly
sudo apt-get updat
sudo apt-get build-dep xbmc
sudo apt-get install libcrossguid-dev uuid-dev
```

安装其他依赖库

```
cd xbmc/tools/depends/
./bootstrap
./configre --prefix=/opt/xbmc-depends
sudo make -C tools/depends/target/libdcadec PREFIX=/usr/local
```

如果configure出现奇怪的错误，清空所有，再试一次：

```
git clean -xfd
```

编译:

```
./bootstrap
sudo ./configure
sudo make -j8
```

**错误：**

```
g++: error: unrecognized command line option ‘-ffmpeg’
```

查看~/Develop/kodi/xbmc/tools/depends/target/ffmpeg，执行autobuild.sh，打印如下错误：

```
Creating config.mak, config.h, and doc/config.texi...
awk: fatal: cannot open file `./libavcodec/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libavdevice/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libavfilter/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libavformat/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libavresample/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libavutil/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libpostproc/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libswresample/version.h' for reading (No such file or directory)
awk: fatal: cannot open file `./libswscale/version.h' for reading (No such file or directory)
```

去github查看

```
https://github.com/xbmc/FFmpeg/
```

发现这几个文件夹下面都是有源码的，但是下载下来的压缩包，解压后没有。查看autobuild.sh，发现下载压缩包语句：

```
[ -f ${ARCHIVE} ] || curl -Ls --create-dirs -f -o ${ARCHIVE} ${BASE_URL}/${VERSION}.tar.gz
```

-f是下载失败了也不显示，所以怀疑是网络问题，包没下完，删除现有压缩包，手动执行autobuild.sh，然后回到工程根目录，重新执行configure和make



## 2. 编译树莓派版

### 2.1 PC端配置

删除系统中通过apt安装的交叉编译器

```
sudo apt-get remove --purge gcc-arm-linux-gnueabihf
sudo apt-get remove --purge g++-arm-linux-gnueabihf
```

安装依赖：

```
sudo apt-get install git autoconf curl g++ zlib1g-dev libcurl4-openssl-dev gawk gperf libtool autopoint swig default-jre
```

下载并安装树莓派官方交叉工具链

```
git clone https://github.com/raspberrypi/tools
```

下载树莓派官方固件

```
git clone https://github.com/raspberrypi/firmware
```

下载kodi源码

```
git clone git://github.com/xbmc/xbmc.git
```

切换到17.6稳定版

```
git checkout a9a7a20
```

配置工作目录

```
sudo mkdir -p /opt/bcm-rootfs/opt
sudo cp -r firmware/opt/vc /opt/bcm-rootfs/opt
sudo mkdir -p /opt/xbmc-bcm
sudo chmod 777 /opt/xbmc-bcm
```



### 2.2 编译树莓派依赖

```
RPI_DEV=/home/robin/Develop/raspberrypi
cd xbmc/tools/depends
mkdir kodi-bcm
./bootstrap
$ ./configure --host=arm-linux-gnueabihf \
   --prefix=/home/robin/Develop/kodi/kodi-bcm/ \
   --with-toolchain=$RPI_DEV/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf \
   --with-firmware=$RPI_DEV/firmware \
   --with-platform=raspberry-pi2 \
   --build=i686-linux \
   --disable-debug

make
```

**注意，天朝网络差，make不要加-j参数，不然打印很混乱，出错了也不知道是哪个库出问题了，一般编译错误都是网络不好，导致源码没下完整导致。**



###2.3 编译源码

```
make -C tools/depends/target/cmakebuildsys
cd build
make
make install
```

完成之后PC的/opt/xbmc-bcm/xbmc-dbg/arm-linux-gnueabihf目录下会有所有执行kodi所需要的东西



### 2.4 树莓派配置

```
sudo raspi-config
```

配置显存

```
"Advanced Options" -> "Memory Split" -> 250
```

使能相机，使kodi支持VP6, VP8, MJPEG, Theora等编码格式

```
"Interfacing Options" -> "Camera" -> Enable
```

确保关闭了opneGL驱动：

```
"Advanced Options" -> GL Driver -> "Original non-GL desktop driver"
```

重启后，再断电，拿出sd卡，插到PC，拷贝vc库到树莓派sd卡

``` 
sudo cp -r firmware/hardfp/opt/vc /media/robin/rootfs/opt/
```

拷贝kodi编译输出文件到树莓派sd卡

```
sudo cp -r /opt/xbmc-bcm/ /media/robin/rootfs/opt/
```

SD卡放回树莓派，启动后执行ldconfig，使新的动态库生效

```
sudo ldconfig -v
```

安装其他依赖库

```
sudo apt update
sudo apt install upower smbclient
```

拷贝kodi到

```
cd cd /opt/xbmc-bcm/xbmc-dbg/arm-linux-gnueabihf
sudo cp lib/* /usr/lib/ -rf
sudo cp etc/* /etc/ -rf
sudo cp share/* /usr/share/ -rf
sudo ln -fs /usr/lib/python2.7/plat-arm-linux-gnueabihf/_sysconfigdata_nd.py /usr/lib/python2.7/

```

运行kodi

```‘
cd bin/
./kodi
```



### 2.5 SD备份与恢复

创建SD卡镜像：

```
sudo dd bs=4M if=/dev/sdc | gzip > raspbian.img.gz
```

烧写：

```
gunzip --stdout raspbian.img.gz | sudo dd bs=4M of=/dev/sdc
```



