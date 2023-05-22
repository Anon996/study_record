# Ubuntu

## 一. root登陆

设置root密码

```
sudo passwd root
```

切换到root用户

```
sudo -s
```

想要在登录界面使用root身份登录，可编辑/etc/lightdm/目录下的lightdm.conf文件，如没有此文件，直接创建，然后重启

```
sudo vim /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf

[SeatDefaults]
autologin-user=root 
user-session=ubuntu 
greeter-show-manual-login=true
```

## 二. vim

1.下载

```
sudo apt-get install vim
```

配置文件在/etc/vim/vimrc

2.vim函数颜色,

VIM默认情况下，函数名是不会高亮的，将下面这段代码添加到/usr/share/vim/vim74/syntax/c.vim文件的末尾即可：

```
"highlight Functions
syn match cFunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
syn match cFunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
hi cFunctions gui=NONE cterm=bold  ctermfg=darkyellow
```

ctermfg表示函数名的颜色，可以自行更换。

或者创建~/.vim/after/syntax/c/highlight_functions.vim, 加入以上代码(All files in `~/.vim/after/syntax/[filetype]/` will be sourced when vim opens a file of type `[filetype]`.)

3.gtags安装

​    [https://www.gnu.org/software/global/download.html下](https://www.gnu.org/software/global/download.html%C3%A4%C2%B8%E2%80%B9)载源码

```
sudo apt-get install libncurses5-dev
./configure
make
sudo make install 安装
cp gtags.vim ~/.vim/plugin
```

4.gtags支持python

```
pip install Pygments
git clone https://github.com/yoshizow/global-pygments-plugin
./reconf.sh
./configure
make
sudo make install
cp sample.globalrc ~/.globalrc
```

5.系统剪贴板

```
sudo apt-get install vim-gnome
```

6.vim中生效vimrc：

```
:vs ~/.vimrc
```





## 三.安装交叉编译链

```
sudo apt-get install build-essential
sudo apt-get install u-boot-tools
```



## 四.安装wps

1.官网下载wps

2.安装配置环境：

```
sudo apt-get update

sudo apt-get install libc6-i386

sudo apt-get install lib32ncurses5 lib32z1
```

3.开始安装

`sudo dpkg -i wps-office_10.1.0.5444~a20_amd64.deb`

4.安装缺失字体

下载相应自体放到/usr/share/fonts

```
sudo cp mtextra.ttf  symbol.ttf  WEBDINGS.TTF  wingding.ttf WINGDNG2.ttf WINGDNG3.ttf  /usr/share/fonts  
```

```
sudo apt-get install ttf-wqy-microhei #文泉驿-微米黑
sudo apt-get install ttf-wqy-zenhei #文泉驿-正黑
sudo apt-get install xfonts-wqy #文泉驿-点阵宋体
```



5.输入法：

```
sudo vi /usr/bin/wps
```

开头加上

```
export XMODIFIERS="@im=ibus"
export QT_IM_MODULE="ibus"
```

ppt、excel部分
和word一样的方法添加环境变量，只是编辑的文件各不同：
$ vi /usr/bin/wpp
$ vi /usr/bin/et



6.卸载自带office

```
sudo apt-get remove --purge libreoffice*
```





## 五、查看文件夹大小：

`du -sh *`

## 六、minicom颜色

在~/.bashrc中加入MINICOM='-c on' 

export MINICOM 



## 七、删除各子目录下某些文件

`find . -name "文件名" -exec chmod 755 {} \;`



## 八、错误日志

​     ubuntu错误日志在/var/crash下，如果不想每次开机都提示错误就把里面的文件删了



## 九、便签软件

```
sudo add-apt-repository ppa:umang/indicator-stickynotes
sudo apt-get update
sudo apt-get install indicator-stickynotes

卸载命令：

sudo apt-get remove indicator-stickynote
```



## 十、 交叉编译器不识别

运行gdb提示arm-none-eabi-gdb: No such file or directory，原因是电脑是32位系统，交叉编译器都是32位的，要安装

```
sudo apt-get install lib32ncurses5 lib32z1
```



## 十一、youcompleteme安装

```
sudo apt-get install build-essential cmake python-dev python3-dev
cd $HOME/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
```

配置文件.ycm_extra_conf.py

这个文件决定了YCM在进行c系语言(c,c++,etc.) 语法补全时的行为。默认的样板配置文件在

`$HOME/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py`

对于YCM来说，当打开一个代码文件时，插件将顺着文件所在的路径一直向上查找，如果搜索到第一个配置文件将立刻读入。如果一直搜索到根目录依旧无法找到配置文件，语法补全将不被启用。由此可知，文件所在目录的配置文件优先级最高，根目录的优先级最低。一种比较好的使用方法是在每个项目中创建一个配置文件，或者将项目根据语言进行分类，在每个语言文件夹下建立一个配置文件。默认配置文件是支持c++的，但是需要修改一处地方。可以将该文件拷贝出来并编辑：

```
cp $HOME/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py ~
vim ~/.ycm_extra_conf.py
```

找到以下内容

```
# NOTE: This is just for YouCompleteMe; it's highly likely that your project
     # does NOT need to remove the stdlib flag. DO NOT USE THIS IN YOUR
     # ycm_extra_conf IF YOU'RE NOT 100% YOU NEED IT.
     try:
       final_flags.remove( '-stdlib=libc++' )
     except ValueError:
       pass
```

将之删除后YCM才会补全c++标准库的内容。这样，一个最小能用的配置文件就出炉了。



## 十二、vmware启用3D加速

解决No 3D support is available from the host

thinkpad T440s，只有集成显卡，没有独立显卡。

通过

`glxinfo`

可以看出，显卡驱动是成功装上了的。

但在vmware启动时显示如下信息：

` No 3D support is available from the host. The 3D features of the virtual machine will be disabled.`

最后在网上查到，在相应的虚拟机的vmx文件中增加如下配置：

` mks.gl.allowBlacklistedDrivers = "TRUE"`

经过验证，确实可行。 目前在虚拟XP中用dxdiag命令可以看出3D加速已经启用了。



## 十三、vmware 换内核后的编译问题

```
REPL:

after kernel 4.4 (VMWare Workstation 12) need some changes in c code:
/usr/lib/vmware/modules/source
1) vmmon.tar
  - untar
  - change ./vmmon-only/linux/hostif.c
  - replace all:
  "get_user_pages" to "get_user_pages_remote"
  misc_deregister has no return value 
  - tar and replace original

2) vmnet.tar
  - untar
  - change ./vmnet-only/userif.c
  - replace all:
  "get_user_pages" to "get_user_pages_remote"
  
  change ./vmnet-only/bridge.c
  - atomic_inc(&clone->users); --- > atomic_inc((atomic_t*)&clone->users);
  - tar and replace original

```

问题:

```
 Unable to load libvmwareui.so from /usr/lib/vmware/lib/libvmwareui.so/libvmwareui.so: /usr/lib/vmware/lib/libvmwareui.so/libvmwareui.so: undefined symbol: _ZN4Glib10spawn_syncERKSsRKNS_11ArrayHandleISsNS_17Container_Helpers10TypeTraitsISsEEEENS_10SpawnFlagsERKN4sigc4slotIvNSA_3nilESC_SC_SC_SC_SC_SC_EEPSsSG_Pi
```

解决

```
export VMWARE_USE_SHIPPED_LIBS=yes 
```

问题:

```
Gtk-Message: Failed to load module "canberra-gtk-module": libcanberra-gtk-module.so: cannot open shared object file: No such file or directory
```

解决

```
sudo ln -s /usr/lib/x86_64-linux-gnu/gtk-2.0/modules/libcanberra-gtk-module.so /usr/lib/libcanberra-gtk-module.so
```

问题:

```
Failed to find /lib/modules/4.6.2-040602-generic/build/include/linux/version.h
```

解决:

```
cd /lib/modules/4.6.2-040602-generic/build/include/linux/
ln -s /usr/include/linux/version.h version.h
```



## 十四、将程序添加到开始菜单

理论上程序装完都会出现在bash菜单中,但是64位的vivado全家桶没有出现,所以到/usr/share/applications/目录下建立相应.desktop文件,以vivado主程序为例:

```
[Desktop Entry]
Encoding=UTF-8
Name=Vivado 2014.2
Exec=/home/Xilinx/Vivado/2014.2/bin/vivado
Terminal=false
Type=Application
StartupNotify=true
Categories=System;
```

完成后注销重新登陆即可

## 十五、ssh安装&记住密码

```
sudo apt-get install openssh-server
sudo /etc/init.d/ssh start
```



[http://7056824.blog.51cto.com/69854/403669](http://7056824.blog.51cto.com/69854/403669)

1.提示输入文件名直接回车即可，然后输入两次私有密码，然后会生成公钥

```
ssh-keygen -b 1024 -t rsa
```

2.拷贝公钥到被管理的服务器上

3.登陆被管理的服务器，进入需要远程登陆的用户目录，把公钥放到用户目录的 .ssh 这个目录下（如果目录不存在，需要创建~/.ssh目录，并把目录权限设置为700），把公钥改名为authorized_keys2，并且把它的用户权限设成600。

## 十六、ssh挂载自动输入密码

```
sudo sshfs -o ssh_command='sshpass -p 123 ssh' -o allow_other hebin@192.168.0.20:/home/hebin /home/steven/Steven/Develop/server/
```

.bashrc中加入一下代码，可以自动挂载

```
if [ $(ls ~/Steven/Develop/server|wc -l) == 0 ]; then#判断是否已经挂载
     echo "19901124" | sudo -S sshfs -o ssh_command='sshpass -p 123 ssh' -o allow_other hebin@192.168.0.20:/home/hebin /home/steven/Steven/Develop/server/
 fi
```



## 十七 beyond compare 永久试用方法

到期以后就删除rm ~/.config/bcompare/registry.dat

## 十八 tftp服务器搭建

安装相关软件包 

```
sudo apt-get install tftpd （服务端）
sudo apt-get install tftp （客户端） 
sudo apt-get install xinetd 
```

建立配置文件

```
sudo vim /etc/xinetd.d/tftp
```

输入

```
service tftp
{
socket_type = dgram
protocol = udp
wait = yes
user = root
server = /usr/sbin/in.tftpd
server_args = -s /tftpboot
disable = no
per_source = 11
cps = 100 2
flags = IPv4
}
```

建立tftp服务文件目录

```
sudo mkdir /tftpboot
sudo chmod 755 /tftpboot
```

重新启动服务

```
/etc/init.d/xinetd restart
```

## 十九 内核降级

先查看可用内核版本

```
 sudo vim /boot/grub/grub.cfg
```

修改默认内核版本

```
sudo vim /etc/default/grub

GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 4.6.2-040602-generic"
```



以上方法不行：

原因：修改default只是修改grub第一个页面的默认选项，可以用来默认启动别的盘安装的系统，但是不能默认选中高级选项中的内核，

解决：直接修改grub.cfg文件：

```
sudo vim /boot/grub/grub.cfg
```



找到如下这段：

menuentry 'Ubuntu' --class ubuntu --class gnu-linux --class gnu --class 
os $menuentry_id_option 
'gnulinux-simple-d0ee4cbf-d4f2-43ca-8c19-7baefda202f0' {

​        recordfail

​        load_video

​        gfxmode $linux_gfx_mode

​        insmod gzio

​        if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi

​        insmod part_msdos

​        insmod ext2

​        set root='hd0,msdos8'

​        if [ x$feature_platform_search_hint = xy ]; then

​          search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos8
 --hint-efi=hd0,msdos8 
--hint-baremetal=ahci0,msdos8  d0ee4cbf-d4f2-43ca-8c19-7baefda202f0

​        else

​          search --no-floppy --fs-uuid --set=root d0ee4cbf-d4f2-43ca-8c19-7baefda202f0

​        fi

​        linux        /boot/**vmlinuz-4.4.0-28-generic** root=UUID=d0ee4cbf-d4f2-43ca-8c19-7baefda202f0 ro  quiet splash $vt_handoff

​        initrd        /boot/**initrd.img-4.4.0-28-generic**

}

submenu 'Advanced options for Ubuntu' $menuentry_id_option 'gnulinux-advanced-d0ee4cbf-d4f2-43ca-8c19-7baefda202f0' {

将粗体部分修改为想要的内核（/boot 可查看），强制保存退出(:wq!)，然后重启就行了



## 二十 sd卡无法分区

彻底重置:

```
sudo dd if=/dev/zero of=/dev/sdX bs=4M
```

## 二十一  FAT-fs (mmcblk0p1): Volume was not properly unmounted.

```
root@linaro-ubuntu-desktop:~# fsck -V /dev/mmcblk0p1 
fsck from util-linux 2.20.1
[/sbin/fsck.vfat (1) -- /boot] fsck.vfat /dev/mmcblk0p1 
dosfsck 3.0.12, 29 Oct 2011, FAT32, LFN
0x41: Dirty bit is set. Fs was not properly unmounted and some data may be corrupt.
1) Remove dirty bit
2) No action
? 1
Leaving file system unchanged.
/dev/mmcblk0p1: 5 files, 26212/403266 clusters
root@linaro-ubuntu-desktop:~# fsck -a /dev/mmcblk0p1  //很关键
fsck from util-linux 2.20.1
dosfsck 3.0.12, 29 Oct 2011, FAT32, LFN
0x41: Dirty bit is set. Fs was not properly unmounted and some data may be corrupt.
 Automaticaly removing dirty bit.
Performing changes.
/dev/mmcblk0p1: 5 files, 26212/403266 clusters
root@linaro-ubuntu-desktop:~# mount /boot
```

## 二十二 fcitx设置每次重启都被覆盖

```
sudo chown root:root ~/.config/fcitx/config
```

## 二十三 rm数据回复

cd到删除数据的文件夹, 查看其inode号

```
ls -id
```

用extundelete查看被删除文件的inode号:

```

extundelete --inode [删除数据的文件夹inode号] /dev/硬盘设备节点

teven@steven-XPS-13-9350:~/Steven/Develop/refactoring/phenix-lite-slave-refac/src/app/f103$ sudo extundelete --inode 3646225 /dev/nvme0n1p2
[sudo] password for steven: 
NOTICE: Extended attributes are not restored.
WARNING: EXT3_FEATURE_INCOMPAT_RECOVER is set.
The partition should be unmounted to undelete any files without further data loss.
If the partition is not currently mounted, this message indicates 
it was improperly unmounted, and you should run fsck before continuing.
If you decide to continue, extundelete may overwrite some of the deleted
files and make recovering those files impossible.  You should unmount the
file system and check it with fsck before using extundelete.
Would you like to continue? (y/n) 
y
Loading filesystem metadata ... 1841 groups loaded.
Group: 445
Contents of inode 3646225:
0000 | fd 41 e8 03 00 10 00 00 7c 4d 2f 5a 3f 4d 2f 5a | .A......|M/Z?M/Z
0010 | 3f 4d 2f 5a 00 00 00 00 e8 03 03 00 08 00 00 00 | ?M/Z............
0020 | 00 00 08 00 20 04 00 00 0a f3 01 00 04 00 00 00 | .... ...........
0030 | 00 00 00 00 00 00 00 00 01 00 00 00 b2 c8 d9 00 | ................
0040 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
0050 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
0060 | 00 00 00 00 3f 1c cc 66 00 00 00 00 00 00 00 00 | ....?..f........
0070 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
0080 | 20 00 00 00 34 d4 88 0b 34 d4 88 0b 68 d7 88 9f |  ...4...4...h...
0090 | 08 e4 ee 59 70 8b 00 b1 00 00 00 00 00 00 00 00 | ...Yp...........
00a0 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
00b0 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
00c0 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
00d0 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
00e0 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
00f0 | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................

Inode is Allocated
File mode: 16893
Low 16 bits of Owner Uid: 1000
Size in bytes: 4096
Access time: 1513049468
Creation time: 1513049407
Modification time: 1513049407
Deletion Time: 0
Low 16 bits of Group Id: 1000
Links count: 3
Blocks count: 8
File flags: 524288
File version (for NFS): 1724652607
File ACL: 0
Directory ACL: 0
Fragment address: 0
Direct blocks: 127754, 4, 0, 0, 1, 14272690, 0, 0, 0, 0, 0, 0
Indirect block: 0
Double indirect block: 0
Triple indirect block: 0

File name                                       | Inode number | Deleted status
.                                                 3646225
..                                                3343390
linkscript.ld                                     3282930
m8q.c                                             3282946
m8q.h                                             3282966
main.c                                            3282393
radio_4g.c                                        3282950
radio_4g.h                                        3282968
target.mk                                         3282949        Deleted	要恢复的文件
.m8q.c.swp                                        3579070
.target.mk.swp                                    3579074        Deleted
target.mk~                                        3579078        Deleted
.radio_4g.c.swp                                   3579073
.dev_manager.h.swx                                3579078        Deleted
.linkscript.ld.swp                                3579075
.main.c.swp                                       3578799
dev_manager-bak.c                                 3579077        Deleted
dev_manager                                       3851072


```

恢复文件:

```
sudo extundelete --restore-inode 3282949 /dev/nvme0n1p2
```



##二十四 Indicator-Multiload

```
sudo add-apt-repository ppa:indicator-multiload/stable-daily

sudo apt-get update

sudo apt-get install indicator-multiload

Ubuntu安装系统状态监视器Indicator-Multiload
```



## 二十五 exfat

```
sudo apt-get install exfat-fuse exfat-utils
```



## 二十六 GParted

| Linux Distribution      [*](https://gparted.sourceforge.io/download.php#distribution-note) | Package                                  | Command Prompt Install         |
| ---------------------------------------- | ---------------------------------------- | ------------------------------ |
| Debian                                   | [gparted](https://packages.debian.org/search?keywords=gparted) | `sudo apt-get install gparted` |
| Fedora                                   | [gparted](https://koji.fedoraproject.org/koji/packageinfo?packageID=1950) | `su -c "yum install gparted"`  |
| OpenSUSE                                 | [gparted](https://software.opensuse.org/package/gparted) | `sudo zypper install gparted`  |
| Ubuntu                                   | [gparted](https://packages.ubuntu.com/search?keywords=gparted) | `sudo apt-get install gparted` |

## 二十七 美化

```
sudo apt-get install unity-tweak-tool

sudo add-apt-repository ppa:noobslab/themes

sudo apt-get update  

sudo apt-get install flatabulous-theme

sudo add-apt-repository ppa:noobslab/icons

sudo apt-get update  

sudo apt-get install ultra-flat-icons
```



## 二十八 火狐中国版

访问Firefox中国官网，下载最新版Firefox：<http://www.firefox.com.cn/download/>

解压：`tar jcf Firefox-latest-x86_64.tar.bz2`

将系统预装的Firefox备份：`sudo mv /usr/lib/firefox /usr/lib/firefox_ubuntu`

用中国版替换：`sudo mv firefox /usr/lib/firefox`

系统预装的Firefox是通过脚本启动，而中国版没有，因此要将该脚本复制过来：`sudo cp /usr/lib/firefox_ubuntu/firefox.sh /usr/lib/firefox/firefox.sh`



## 二十九 写入U盘镜像

```
sudo dd if=...iso of=/dev/sda
```



## 三十 java安装

oracle官网下载压缩包，解压

```
vim ~/.bashrc

export JAVA_HOME=/opt/jdk1.8.0_121
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

```



## 三十一 astah乱码

```
sudo apt-get install fonts-arphic-uming*  
```



## 三十二 libpython**2.6.so.1**.0 doesn't exist

Ugly, but working solution is to create symlink `libpython**2.6.so.1**.0` pointing to `libpython2.7.so`

```
sudo ln -s /usr/lib/x86_64-linux-gnu/libpython2.7.so \
/usr/lib/x86_64-linux-gnu/libpython2.6.so.1.0
```



## 三十三 arm-linux安装

GDB:

1.下载：

http://www.gnu.org/software/gdb/download/

2.解压

```
tar -zxvf gdb-7.5.tar.gz
```

3.编译

cd gdb-7.5

```
./configure --target=arm-linux --prefix=/usr/local/arm-gdb -v
```

   target指明编译生成的GDB用于调试ARM-LINUX程序,prefix指明安装目录

  ```
make
sudo make install
vim /etc/environment --把arm-linux-gdb加入环境变量 (:/usr/local/arm-gdb/bin)
source /etc/environment  //更新环境变量
  ```

  这样就可以在/usr/local/arm-gdb/bin目录下看到如下三个可执行文件

  arm-linux-gdb arm-linux-gdbtui arm-linux-run

GCC:

```
sudo apt install gcc-arm-linux-gnueabihf
```



G++

```
sudo apt install g++-arm-linux-gnueabihf
```





## 三十四 挂载IMG

有时候直接挂载会出错：

```
$sudo mount -o loop OSMC_TGT_rbp2_20180207.img tmp/
NTFS signature is missing.
Failed to mount '/dev/loop0': Invalid argument
The device '/dev/loop0' doesn't seem to have a valid NTFS.
Maybe the wrong device is used? Or the whole disk instead of a
partition (e.g. /dev/sda, not /dev/sda1)? Or the other way around?

```

此时需要计算offset：

```
$sudo fdisk -lu OSMC_TGT_rbp2_20180207.img
Disk OSMC_TGT_rbp2_20180207.img: 256 MiB, 268435456 bytes, 524288 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x3891f920

Device                      Boot Start    End Sectors  Size Id Type
OSMC_TGT_rbp2_20180207.img1       2048 499711  497664  243M  c W95 FAT32 (LBA)
```

可以看到start=2048，以及`Units = sectors of 1 * 512 = 512 bytes`

所以offset = 2048*512=1048576，命令改为：

```
sudo mount -o loop,offset=1048576 OSMC_TGT_rbp2_20180207.img tmp/
```



## 三十五 卸载自带office

```
sudo apt-get remove --purge libreoffice*
```



## 三十六 iPad作为副屏

下载VirtScreen：

```
https://github.com/kbumsik/VirtScreen
```

virtscreen依赖于x11vnc，但是ubuntu下apt安装的版本过低，不支持muliptr参数，导致副屏鼠标不显示，下载最新版x11vnc:

```
git clone git@github.com:LibVNC/x11vnc.git
```

安装依赖

```
sudo apt-get build-dep x11vnc
```

编译和安装:

```
autoreconf -fiv
./configure
make
make install
```

安装virtscreen

```
sudo dpkg -i virtscreen.deb

```

添加x11 inter显卡相关配置

```

```

输入

```
Section "Device"
    Identifier "intelgpu0"
    Driver "intel"
    Option "VirtualHeads" "1"
EndSection
```

保存后重启

运行以后设定分辨率为1440*1080，ipad端下载vnc客户端，连接电脑ip即可