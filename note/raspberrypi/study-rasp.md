# 树莓派学习记录

## 1. 启动过程

树莓派的启动过程和一般的开发板不同，因为它有一个GPU，最先启动的是GPU而不是ARM：

- GPU先启动，关闭ARM
- GPU运行SOC ROM中的firt stage bootloader启动代码
- GPU的启动代码从SD卡加载GPU的second stage bootloader：`bootcode.bin`
- bootcode.bin从SD卡加载并运行start.elf (原先老版本的bootcode无法运行elf文件，还需要加载一个loader.bin，现在已经支持，所以已经没有loader.bin)
- start.elf初始化ddr等初始化操作，读取 `config.txt`, `cmdline.txt`, `dtb` , 然后加载`kernel.img`
- 和正常的嵌入式linux内核一样，kernel.img从地址0x8000开始



## 2. 无线网络配置

扫描SSID：

```
sudo iwlist wlan0 scan
```

可以在结果中看到公司的wifi：lmeng3，然后修改配置：

```
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

在最后添加：

```
network={
    ssid="lmeng3"
    psk="hellolmeng"
}
```

使配置生效：

```
wpa_cli -i wlan0 reconfigure
```

如果无法apt update：

```
sudo sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf' 
```



**PS: **wpa_supplicant.conf中保存明文密码并不安全，可以使用`wpa_passphrase`工具生成加密的PSK密码：

```
pi@raspberrypi:~$ wpa_passphrase "lmeng3" "hellolmeng"
network={
        ssid="lmeng3"
        #psk="hellolmeng"
        psk=907d729f0226c9a3d101e5d9e71f0882a72096a13acc46d2a87ce4bac7291b3a
}
```

把hellolmeng这行，删掉，然后写入wpa_supplicant.conf