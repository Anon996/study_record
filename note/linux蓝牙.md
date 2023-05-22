# Linux蓝牙

## 1. 调试工具

###1.1 hcitool

查看当前蓝牙设备

```
robin@robin-XPS-13-9360:~$ hciconfig
hci0:	Type: BR/EDR  Bus: USB
	BD Address: 9C:B6:D0:F6:90:12  ACL MTU: 1024:8  SCO MTU: 50:8
	DOWN 
	RX bytes:6729 acl:29 sco:0 events:139 errors:0
	TX bytes:3913 acl:28 sco:0 commands:69 errors:0
```



开启关闭蓝牙设备

```
#设备打开
sudo hciconfig hci0 up
#设备关闭
sudo hciconfig hci0 down
```



在打开蓝牙设备以后，就可以使用hcitool工具集对蓝牙进行控制，工具集参数 分为两部分，一为正常的蓝牙设备调试，二为低功耗即BLE设备，命令参数如下：

| 命令        | 说明                                                         | 调用方式                                                     |
| ----------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 参数        |                                                              |                                                              |
| –help       | 进入帮助                                                     | hcitool –help                                                |
| -i          | 在host插有多个蓝牙适配器的情况下，可以通过该参数来指定某控制某一适配器 | hcitool -i \[dbaddr][command]                                |
| 命令        | 下面的命令是普通蓝牙设备，不需要sudo                         |                                                              |
| dev         | 同hciconfig一样，显示当前适配器设备，输出格式为[hciid MAC]   | hcitool dev                                                  |
| inq         | 查询可发现的远程设备，与scan不同的是，除了能查询出MAC以外，还可以查出远程设备的时钟偏移值“clock offset”与设备类型“class”，scan是不会输出相关设备的类型，这可以让我们区分设备是蓝牙耳机，或蓝牙鼠标 | hcitool inq                                                  |
|             |                                                              | hcitool inq [–length=N]设置最大查询时间                      |
|             |                                                              | hcitool inq [–numrsp=N]设置最大查询数量                      |
|             |                                                              | hcitool inq [–iac=lap]指定查询的lac码                        |
|             |                                                              | hcitool inq [–flush]清除缓存                                 |
| scan        | 查询可发现的远程设备，与inq不同的是，除了能查询出MAC以外，还可以输出设备的名字【名字写在标准的module中，若查询不到该key对应的values则会输出N/A】,可以通过设置参数来获取设备的类型，信息等 | hcitool scan                                                 |
|             |                                                              | hcitool scan[–length=N]设置最大查询时间                      |
|             |                                                              | hcitool scan[–numrsp=N]设置最大查询数量                      |
|             |                                                              | hcitool scan[–iac=lap]指定查询的lac码                        |
|             |                                                              | hcitool scan[–class]查询设备类型                             |
|             |                                                              | hcitool scan[–info]查询设备信息                              |
|             |                                                              | hcitool scan[–oui]查询设备唯一标识                           |
|             |                                                              | hcitool scan[–flush]清除缓存                                 |
| name        | 通过指定MAC地址来获取设备的名称，该命令可以补全inq查询时无法输出设备名称的问题. | hcitool name [dbaddr]                                        |
| info        | 通过指定MAC地址来获取设备的相关信息。                        | hcitool info [dbaddr]                                        |
| spinq       | 开启定期查询，使设备被发现，没有则无输出                     | hcitool spinq                                                |
| epinq       | 关闭定期查询，没有则无输出                                   | hcitool epinq                                                |
| cmd         | 向远程设备发送命令                                           | hcitool cmd < ogf > < ocf > [parameters]                     |
| con         | 显示当前连接信息                                             | hcitool con                                                  |
| cc          | 连接设备，可以设置数据类型，与主从关系                       | hcitool cc < bdaddr >                                        |
|             |                                                              | hcitool cc [–ptype=pkt_types] < bdaddr > 可以设置接收数据的类型，数据类型包括[DM1, DM3, DM5,DH1,DH3,DH5, HV1, HV2, HV3]，可以设置多个类型，类型中间以逗号分隔，默认接收所有类型数据 |
|             |                                                              | hcitool cc [–role=m/s] < bdaddr >可以设置设备的主从关系，M为master，S为slave，默认为s |
|             | Example:                                                     | hcitool cc –ptype=dm1,dh3,dh5 01:02:03:04:05:06              |
|             |                                                              | cc –role=m 01:02:03:04:05:06                                 |
| dc          | 断开远程设备连接                                             | hcitool dc < bdaddr > [reason]                               |
| sr          | 设置设备的主从关系                                           | hcitool sr < bdaddr > < role >                               |
| cpt         | 设置远程设备数据类型                                         | hcitool cpt < bdaddr > < packet_types >可以设置接收数据的类型，数据类型包括[DM1, DM3, DM5,DH1,DH3,DH5, HV1, HV2, HV3]，可以设置多个类型，类型中间以逗号分隔 |
| rssi        | 显示设备的信号强度                                           | hcitool rssi < bdaddr>                                       |
| lq          | 显示设备的链路质量                                           | hcitool lq < bdaddr>                                         |
| tpl         | 显示设备的发射功率级别                                       | hcitool tpl < bdaddr> [type]                                 |
| afh         | 显示设备的AFH（适应性跳频）的信道地图                        | hcitool afh < bdaddr>                                        |
| lp          | 设置或显示设备的链路                                         | hcitool lp < bdaddr> [link policy]                           |
| lst         | 设置或显示连接超时时间，默认情况下连接超时断开连接为20s可以设置超时时间来缩短超时断开连接的时间 | hcitool lst < bdaddr> [new value in slots]                   |
| auth        | 请求设备配对认证                                             | hcitool auth < bdaddr>                                       |
| enc         | 设置连接加密，同样可以关闭连接加密                           | hcitool enc < bdaddr> [encrypt enable]                       |
| key         | 更新与远程设备的link key                                     | hcitool key < bdaddr>                                        |
| clkoff      | 读取远程设备的时钟偏移量，不过这个变量不太靠谱               | hcitool clkoff < bdaddr>                                     |
| clock       | 读取本地时钟或远程设备的时钟                                 | hcitool clock [bdaddr] [which clock]                         |
| BLE设备命令 | 以下命令需要root权限才能执行                                 |                                                              |
| lescan      | 搜索BLE设备                                                  | hcitool lescan                                               |
|             |                                                              | hcitool lescan[–privacy]启用隐私搜索                         |
|             |                                                              | hcitool lescan [–passive]默认参数，设置被动扫描              |
|             |                                                              | hcitool lescan [–discovery=g/l] 设置搜索条件为综合设备或限制设备 |
|             |                                                              | hcitool lescan [–duplicates]过滤重复的设备                   |
| lewladd     | 将设备加入BLE白名单                                          | hcitool lewladd [–random] < bdaddr>可声明该设备的MAC地址为随机地址，有的BLE设备可以被设置为随机MAC地址以增加私密性，为以后也能连接到该MAC地址，需要声明MAC地址是随机，这样才能用旧的MAC地址连接到设备 |
| lewlrm      | 将设备移除BLE白名单                                          | hcitool lewlrm < bdaddr>                                     |
| lewlsz      | 输出白名单设备列表                                           | hcitool lewlsz                                               |
| lewlclr     | 清空白名单列表                                               | hcitool lewlclr                                              |
| lecc        | 连接BLE设备                                                  | hcitool lecc < bdaddr>                                       |
|             |                                                              | hcitool lecc [–random] < bdaddr>随机MAC地址连接              |
|             |                                                              | hcitool lecc –whitelist 连接所有白名单设备                   |
| ledc        | 断开BLE设备的连接。在通过lecc链接后，hci工具会随机分配给该设备一个handle名，断开连接时需要使用该handle，因为在蓝牙4.0以后，一个蓝牙适配器可以连接7个BLE设备 | hcitool ledc < handle> [reason]                              |
| lecup       | 更新BLE设备的连接及状态                                      | hcitool lecup [Options]                                      |
|             | Options:                                                     |                                                              |
|             |                                                              | -H, –handle < 0xXXXX>指定更新状态的BLE设备Handle，在通过lecc链接后，hci工具会随机分配给该设备一个handle名 |
|             |                                                              | -m, –min < interval> 设置设备蓝牙的休眠时间与–max联合使用，设置的区间为: 0x0006~0x0C80 |
|             |                                                              | -M, –max < interval> 设置实例【hcitool lecup –handle 71 –min 6 –max 100】 |
|             |                                                              | -l, –latency < range> 设置BLE数据传输速率，区间为： 0x0000~0x03E8 |
|             |                                                              | -t, –timeout < time> N * 10ms 设置设备超时等待时间，区间为 0x000A~0x0C80 |
|             | 备注：                                                       | min/max参数区间为7.5ms到4s，误差在1.25ms，timeout的区间为100ms到32s |



实例：

显示蓝牙设备

```
robin@robin-XPS-13-9360:~$ hcitool dev
Devices:
	hci0	9C:B6:D0:F6:90:12
```

查询远程设备：

```
robin@robin-XPS-13-9360:~$ hcitool inq
Inquiring ...
	00:15:83:3D:0A:57	clock offset: 0x4ab4	class: 0x120104
	C0:A5:3E:2A:47:FD	clock offset: 0x6134	class: 0x7a020c
	78:62:56:E3:9C:75	clock offset: 0x7df5	class: 0x5a020c

robin@robin-XPS-13-9360:~$ hcitool name C0:A5:3E:2A:47:FD
bin的 iPhone
```

```
robin@robin-XPS-13-9360:~$ hcitool scan
Scanning ...
	00:15:83:3D:0A:57	GCB-XWC
	C0:A5:3E:2A:47:FD	bin的 iPhone
	78:62:56:E3:9C:75	HUAWEI nova 2s
```

获取远程设备信息

```
robin@robin-XPS-13-9360:~$ sudo hcitool info C0:A5:3E:2A:47:FD
Requesting information ...
	BD Address:  C0:A5:3E:2A:47:FD
	Device Name: bin的 iPhone
	LMP Version:  (0x9) LMP Subversion: 0x420e
	Manufacturer: Broadcom Corporation (15)
	Features page 0: 0xbf 0xfe 0xcf 0xfe 0xdb 0xff 0x7b 0x87
		<3-slot packets> <5-slot packets> <encryption> <slot offset> 
		<timing accuracy> <role switch> <sniff mode> <RSSI> 
		<channel quality> <SCO link> <HV2 packets> <HV3 packets> 
		<u-law log> <A-law log> <CVSD> <paging scheme> <power control> 
		<transparent SCO> <broadcast encrypt> <EDR ACL 2 Mbps> 
		<EDR ACL 3 Mbps> <enhanced iscan> <interlaced iscan> 
		<interlaced pscan> <inquiry with RSSI> <extended SCO> 
		<EV4 packets> <EV5 packets> <AFH cap. slave> 
		<AFH class. slave> <LE support> <3-slot EDR ACL> 
		<5-slot EDR ACL> <sniff subrating> <pause encryption> 
		<AFH cap. master> <AFH class. master> <EDR eSCO 2 Mbps> 
		<EDR eSCO 3 Mbps> <3-slot EDR eSCO> <extended inquiry> 
		<LE and BR/EDR> <simple pairing> <encapsulated PDU> 
		<err. data report> <non-flush flag> <LSTO> <inquiry TX power> 
		<EPC> <extended features> 
	Features page 1: 0x0f 0x00 0x00 0x00 0x00 0x00 0x00 0x00
	Features page 2: 0x7f 0x0b 0x00 0x00 0x00 0x00 0x00 0x00
```





### 1.2 gatttool

使用hcitool是为了对设备的连接进行管理，那么对BLE数据进行精细化管理的话，就需要用到gattool，使用gattool对蓝牙设备发送指令的操作上要比hcitool的cmd齐全很多，关于gattool的使用分为两种，一种直接使用参数对蓝牙设备进行控制，二就是使用`-I`参数进入gattool的interactive模式对蓝牙设备进行控制。参数如下：

| 参数             | 说明                                                         | 调用方式                                                     |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| -i               | 指定适配器                                                   | gatttool -i < hciX> -b < MAC Address>                        |
| -b               | 指定远程设备，在连接多个设备的情况下需要指定控制某一设备     | gatttool -b < bdaddr>                                        |
| -t               | 指定设备的类型，是开放设备还是私密设备                       | gatttool -b < MAC Address> -t [public/random]                |
| -m               | 设置数据包长度                                               | -m MTU                                                       |
| –sec-leve        | 设置数据发送级别，默认情况下是low，需要高频发射数据的情况下需要将级别设置为high,但相应的耗电会上升 | gatttool -b < MAC Address> -l [low/medium/high]              |
| -I               | 进入interactive模式                                          | gatttool -b < MAC Address> -I                                |
|                  | 以下参数可以直接在interactive模式下使用，也可以在命令行直接使用 |                                                              |
| –primary         | 寻找BLE中可用的服务                                          | gatttool -b < MAC Address> –primary                          |
| –characteristics | 查看设备服务的特性，其中handle是特性的句柄，char properties是特性的属性值，char value handle是特性值的句柄，uuid是特性的标识。 | gatttool -b < MAC Address> –characteristics                  |
| –char-desc       | 配合查看服务特性使用，可以查看该设备所有服务特性的值，该值类型为键值对 | gatttool –b < MAC Address> –char-desc [–uuid 0x000]可以通过设置UUID来查看某一特性的值 |
| –char-write      | 更新特性的值，该更新类似于键值对，一个uuid匹配一个value      | gatttool -b  –char-write –uuid [0x000] –value [0]            |
| –char-write-req  | 读取notifications里的内容，可以设置listen来开启监听否则每次只读一次，监听读取notifications时需要向该handle写入一个1，在命令行中16进制的表示为0100，若向该handle写入0200的话则改为读取indications的内容 | gatttool -b < MAC Address> –char-write-req –handle=0xXXXX –value=0100 –listen |
|                  | 完整示例：                                                   | gatttool -i hci0 -b aa:bb:cc:dd -t random –char-write-req -a 0x0039 -n 0100 –listen |



## 2. rfcomm

rfcomm - Radio Frequency Communication protocol, 在L2CAP提供的模拟串口接口

L2CAP -  Logical Link Control and Adaptation Protocol蓝牙网络层协议，主要在linux的驱动中实现

###2.1 连接远程设备（一）

rfcomm可以把蓝牙映射成串口，这样就可以像操作串口一样操作蓝牙设备，利用rfcomm连接蓝牙设备过程如下：

查看远程设备蓝牙地址：

```
robin@robin-XPS-13-9360:~$ hcitool scan
Scanning ...
	74:AC:5F:EC:45:DB	360 N5S
	C0:A5:3E:2A:47:FD	bin的 iPhone
	78:62:56:E3:9C:75	HUAWEI nova 2s
	00:15:83:3D:0A:57	GCB-XWC

```

绑定设备节点和地址：

```
sudo rfcomm bind /dev/rfcomm0 C0:A5:3E:2A:47:FD
```

之后会在/dev目录下生成设备节点rfcomm0:

```
robin@robin-XPS-13-9360:~$ ls /dev/r
random   rfcomm0  rfkill   rtc      rtc0 
```

连接远程设备：

```
sudo rfcomm connect hci0 C0:A5:3E:2A:47:FD
sudo rfcomm release /dev/rfcomm0
sudo rfcomm connect hci0 C0:A5:3E:2A:47:FD
```

第一次connect会提示：

```
robin@robin-XPS-13-9360:~$ sudo rfcomm connect hci0 C0:A5:3E:2A:47:FD
Can't create RFCOMM TTY: Address already in use
```

release掉设备节点，再connect一次就能连接

```
robin@robin-XPS-13-9360:~$ sudo rfcomm release /dev/rfcomm0
robin@robin-XPS-13-9360:~$ sudo rfcomm connect hci0 C0:A5:3E:2A:47:FD
Connected /dev/rfcomm0 to C0:A5:3E:2A:47:FD on channel 1
Press CTRL-C for hangup

```



### 2.2 连接远程设备（二）

绑定设备节点和地址：

```
sudo rfcomm bind /dev/rfcomm0 C0:A5:3E:2A:47:FD
```

连接：

```
sudo cat >/dev/rfcomm0
```

结束以后释放设备节点

```
sudo rfcomm release /dev/rfcomm0
```

**PS:这种方法似乎更正确，因为再ubuntu系统中，这种方法连接的设备在有右上角会有显示，上一种连接方式没有，不知为何 **



