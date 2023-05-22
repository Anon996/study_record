```
root@steven-XPS-13-9350:/# apt update
Err:1 http://ports.ubuntu.com/ubuntu-ports xenial InRelease
  Temporary failure resolving 'ports.ubuntu.com'
Err:2 http://ports.ubuntu.com/ubuntu-ports xenial-updates InRelease
  Temporary failure resolving 'ports.ubuntu.com'
Err:3 http://ports.ubuntu.com/ubuntu-ports xenial-security InRelease
  Temporary failure resolving 'ports.ubuntu.com'
Reading package lists... Done
```

原因:

temporary due to your Internet Service Provider not correctly forwarding internet naming (DNS) to either its or external DNS servers

解决:

```
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null  127.0.1.1是不是也行?不行
```

```
apt-get install -y sudo
apt-get install net-tools //获取ifconfig

apt-get install language-pack-en-base sudo ssh net-tools ethtool wireless-tools iputils-ping rsyslog bash-completion python-gobject-2 python-gtk2 lsb-release
```



```
adduser robsense && addgroup robsense adm && addgroup robsense sudo && addgroup robsense audio
```



自动登录:

Create the folder: */etc/systemd/system/getty@tty1.service.d*

Create the file: */etc/systemd/system/getty@tty1.service.d/override.conf*

Open the file with your favorite editor and add this:

```
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noissue --autologin myusername %I $TERM
Type=idle
```



```
sudo vim /etc/apt/sources.list
每行最后增加universe multiverse ros必须要加
```





sudo tar -xpf ubuntu-core-16.04-robsense.tar.bz2 -C /media/steven/rootfs

sudo tar jcpf ubuntu-core-16.04-robsense.tar.bz2 .





[ TIME ] Timed out waiting for device dev-ttyPS0.device.
[DEPEND] Dependency failed for Serial Getty on ttyPS0.

解决:

systemctl enable getty@ttyPS0.service







http://cdimage.ubuntu.com/ubuntu-base/releases/16.04/release/



open /dev/mem 需要sudo