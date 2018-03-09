# LINUX

## 1. printf在终端输出时改变颜色

终端的字符颜色是用转义序列控制的，是文本模式下的系统显示功能，和具体的语言无关。

转义序列是以 ESC 开头,可以用 \033 完成相同的工作（ESC 的 ASCII 码用十进制表示就是 27， = 用八进制表示的 33）。

\033[显示方式;前景色;背景色m

显示方式:0（默认值）、1（高亮）、22（非粗体）、4（下划线）、24（非下划线）、5（闪烁）、25（非闪烁）、7（反显）、27（非反显）

前景色:30（黑色）、31（红色）、32（绿色）、 33（黄色）、34（蓝色）、35（洋红）、36（青色）、37（白色）

背景色:40（黑色）、41（红色）、42（绿色）、 43（黄色）、44（蓝色）、45（洋红）、46（青色）、47（白色）

\033[0m 默认

\033[1;32;40m 绿色

033[1;31;40m 红色

printf( "\033[1;31;40m 输出红色字符 \033[0m" )



## 2.static inline

GCC的static inline定义很容易理解：你可以把它认为是一个static的函数，加上了inline的属性。这个函数大部分表现和普通的static函数一样，只不过在调用这种函数的时候，gcc会在其调用处将其汇编码展开编译而不为这个函数生成独立的汇编码。除了以下几种情况外：

函数的地址被使用的时候。如通过函数指针对函数进行了间接调用。这种情况下就不得不为static inline函数生成独立的汇编码，否则它没有自己的地址。

其他一些无法展开的情况，比如函数本身有递归调用自身的行为等。

static inline函数和static函数一样，其定义的范围是local的，即可以在程序内有多个同名的定义（只要不位于同一个文件内即可）。



## 3.二维数组和指向指针的指针

```
include<stdio.h>

void main()
{
    char **p,a[6][8];
    p = a;
    printf（"\n"）;
}
```

编译，然后就会发现通不过，报错：错误 1 error C2440: “=”: 无法从“char [6][8]”转换为“char **” 

于是乎，我看了下《C专家编程》里10.5节—使用指针向函数传递一个多维数组。

方法一，函数是 void fun(int arr[2][3]); 这种方法只能处理2行3列的int型数组。

方法二，可以省略第一维的长度。函数是 void fun(int arr[][3]);这种方式虽然限制宽松了一些，但是还是只能处理每行是3个整数长度的数组。

　　　　或者写成这种形式 void fun(int (*arr)[3]);这是一个数组指针或者叫行指针，arr和*先结合使得arr成为一个指针，这个指针指向具有3个

　　　　int类型数据的数组。

方法三，创建一个一维数组，数组中的元素是指向其他东西的指针，也即二级指针。函数是 int fun(int **arr);这种方法可以动态处理各行各列不一样长度的数据。

注意：只有把二维数组改成一个指向向量的指针数组的前提下才可以这么做！比如下面的程序可以正常输出abc：

```
#include <iostream> 
using namespace std; 
void test(char **ptr) 
{ 
    cout << *ptr << endl; 
} 
 
int main() 
{ 
    char *p[3] = {"abc", "def", "ghi"}; 
    test(p); 
    return 0; 
}
```



## 4.文件操作

1.open（打开文件）
相关函数 read，write，fcntl，close，link，stat，umask，unlink，fopen 
表头文件 

```
include<sys/types.h>

include<sys/stat.h>

include<fcntl.h>

定义函数 
int open( const char * pathname, int flags);

int open( const char * pathname,int flags, mode_t mode);
```

函数说明 参数pathname 指向欲打开的文件路径字符串。下列是参数flags 所能使用的旗标:

```
O_RDONLY 以只读方式打开文件
O_WRONLY 以只写方式打开文件
O_RDWR 以可读写方式打开文件。上述三种旗标是互斥的，也就是不可同时使用，但可与下列的旗标利用OR(|)运算符组合。
O_CREAT 若欲打开的文件不存在则自动建立该文件。
O_EXCL 如果O_CREAT 也被设置，此指令会去检查文件是否存在。文件若不存在则建立该文件，否则将导致打开文件错误。此外，若O_CREAT与O_EXCL同时设置，并且欲打开的文件为符号连接，则会打开文件失败。
O_NOCTTY 如果欲打开的文件为终端机设备时，则不会将该终端机当成进程控制终端机。
O_TRUNC 若文件存在并且以可写的方式打开时，此旗标会令文件长度清为0，而原来存于该文件的资料也会消失。
O_APPEND 当读写文件时会从文件尾开始移动，也就是所写入的数据会以附加的方式加入到文件后面。
O_NONBLOCK 以不可阻断的方式打开文件，也就是无论有无数据读取或等待，都会立即返回进程之中。
O_NDELAY 同O_NONBLOCK。
O_SYNC 以同步的方式打开文件。
O_NOFOLLOW 如果参数pathname 所指的文件为一符号连接，则会令打开文件失败。
O_DIRECTORY 如果参数pathname 所指的文件并非为一目录，则会令打开文件失败。
此为Linux2.2以后特有的旗标，以避免一些系统安全问题。参数mode 则有下列数种组合，只有在建立新文件时才会生效，此外真正建文件时的权限会受到umask值所影响，因此该文件权限应该为（mode-umaks）。
S_IRWXU00700 权限，代表该文件所有者具有可读、可写及可执行的权限。
S_IRUSR 或S_IREAD，00400权限，代表该文件所有者具有可读取的权限。
S_IWUSR 或S_IWRITE，00200 权限，代表该文件所有者具有可写入的权限。
S_IXUSR 或S_IEXEC，00100 权限，代表该文件所有者具有可执行的权限。
S_IRWXG 00070权限，代表该文件用户组具有可读、可写及可执行的权限。
S_IRGRP 00040 权限，代表该文件用户组具有可读的权限。
S_IWGRP 00020权限，代表该文件用户组具有可写入的权限。
S_IXGRP 00010 权限，代表该文件用户组具有可执行的权限。
S_IRWXO 00007权限，代表其他用户具有可读、可写及可执行的权限。
S_IROTH 00004 权限，代表其他用户具有可读的权限
S_IWOTH 00002权限，代表其他用户具有可写入的权限。
S_IXOTH 00001 权限，代表其他用户具有可执行的权限。
```

返回值 若所有欲核查的权限都通过了检查则返回0 值，表示成功，只要有一个权限被禁止则返回-1。

2.read（由已打开的文件读取数据）

相关函数 readdir，write，fcntl，close，lseek，readlink，fread 
表头文件

```
include<unistd.h>

定义函数 ssize_t read(int fd,void * buf ,size_t count); 
```

函数说明
read()会把参数fd 
所指的文件传送count个字节到buf指针所指的内存中。若参数count为0，则read()不会有作用并返回0。返回值为实际读取到的字节数，如果返回0，表示已到达文件尾或是无可读取的数据，此外文件读写位置会随读取到的字节移动。**如果打开时没有指定O_NONBLOCK， 函数就是阻塞的**

附加说明
 如果顺利read()会返回实际读到的字节数，最好能将返回值与参数count 
作比较，若返回的字节数比要求读取的字节数少，则有可能读到了文件尾、从管道(pipe)或终端机读取，或者是read()被信号中断了读取动作。当有错误发生时则返回-1，错误代码存入errno中，而文件读写位置则无法预期。

错误代码 EINTR 此调用被信号所中断。
EAGAIN 当使用不可阻断I/O 时（O_NONBLOCK），若无数据可读取则返回此值。
EBADF 参数fd 非有效的文件描述词，或该文件已关闭。

范例 参考open（）。

3.**sync（将缓冲区数据写回磁盘）** 
相关函数 fsync 
表头文件 #include<unistd.h> 
定义函数 int sync(void) 
函数说明 sync()负责将系统缓冲区数据写回磁盘，以确保数据同步。 
返回值 返回0。

4.**write（将数据写入已打开的文件内）** 
相关函数 open，read，fcntl，close，lseek，sync，fsync，fwrite
表头文件 #include<unistd.h> 
定义函数 ssize_t write (int fd,const void * buf,size_t count); 
函数说明 write()会把参数buf所指的内存写入count个字节到参数fd所指的文件内。当然，文件读写位置也会随之移动。 
返回值 如果顺利write()会返回实际写入的字节数。当有错误发生时则返回-1，错误代码存入errno中。 
错误代码 EINTR 此调用被信号所中断。
EAGAIN 当使用不可阻断I/O 时（O_NONBLOCK），若无数据可读取则返回此值。
EADF 参数fd非有效的文件描述词，或该文件已关闭。 
范例 请参考open（）。

5.**lseek用于文件位置定位**

```
函数原形：off_t lseek(int fildes, off_t offset, int whence);

int fd = open(file_name,O_RDONLY);
if (fd<0) return -1;
long fsize = lseek(fd,0L,SEEK_END);
close(fd);
```

fildes,表示打开的文件描述符offset,表示操作需要移动的相对量whence,标示文件移动的方向其取值有如下三种情况：lseek(int fildes, off_t offset, SEEK_SET);返回值即为文件开头起始之后的offset位置，seek的起始位置为文件头lseek(int fildes, off_t offset, SEEK_CUR);返回值即为文件当前偏移量+offset的值，seek的起始位置为当前位置lseek(int fildes, off_t offset, SEEK_END);返回值即为文件大小+offset，seed的起始位置为文件末尾[offset 可正可负，表示相对位置的前后关系]偏移量offset已字节为单元。在成功调用情况下的返回值表示相对于文件头的文件读取偏移量在调用失败情况下，将返回-1lseek将当前的文件偏移量记录在内核之中, 而并不会引起任何实际的I/O操作,之后的文件读/写操作将在该偏移量上执行.对与文件偏移量大于文件当前长度情况下, 对该文件的写操作将导致在文件中形成一段空洞,即那段没有写过字节的位移段被读为0.



## 5.devicetree如何和platform驱动对应起来

devicetree中每个节点有一个compatible,里面是字符串,最长31个字符 

platform驱动中定义一个struct platform_driver结构体,例如

```
 static struct platform_driver armv7_pmu_driver = {
        .driver        = {
        .name    = "armv7-pmu",
        .of_match_table = armv7_pmu_of_device_ids,
         },
         .probe        = armv7_pmu_device_probe,
   };
```

里面有个of_match_table,就是一个指向struct of_device_id的指针,这个结构体也是驱动中定义的:

```
static const struct of_device_id armv7_pmu_of_device_ids[] = {
    {.compatible = "arm,cortex-a17-pmu",    .data = armv7_a17_pmu_init},
    {.compatible = "arm,cortex-a15-pmu",    .data = armv7_a15_pmu_init},
    {.compatible = "arm,cortex-a12-pmu",    .data = armv7_a12_pmu_init},
    {.compatible = "arm,cortex-a9-pmu",    .data = armv7_a9_pmu_init},
    {.compatible = "arm,cortex-a8-pmu",    .data = armv7_a8_pmu_init},
    {.compatible = "arm,cortex-a7-pmu",    .data = armv7_a7_pmu_init},
    {.compatible = "arm,cortex-a5-pmu",    .data = armv7_a5_pmu_init},
    {.compatible = "qcom,krait-pmu",    .data = krait_pmu_init},
    {.compatible = "qcom,scorpion-pmu",    .data = scorpion_pmu_init},
    {.compatible = "qcom,scorpion-mp-pmu",    .data = scorpion_mp_pmu_init},
    {},
};
```

可以看到这个结构体也有compatible,内核启动的时候就是通过这个去匹配相应的驱动的,在devicetree中没有的platform驱动如果要加载就需要在驱动中自己定义struct platform_device和struct resource,有devicetree就可已代替这两个结构体(参考http://blog.csdn.net/zqixiao_09/article/details/50889458)

## 6. 系统宏\_\_linux\_\_

系统宏定义在编译器中, 比如linux程序专用的编译器会定义宏\_\_linux\_\_, 而通用的逻辑编译器arm-none-eabi-gcc就没有

查看编译器宏的命令:

```
arm-none-eabi-gcc -dM -E - < /dev/null
```

## 7. sizeof

```
int *a;
char *b;
char c[100];

a = malloc(100);
b = malloc(100);

sizeof(*a);//4
sizeof(*b);//1
sizeof(c);//100
```

## 8. /etc/fstab文件

作用:

磁盘被手动挂载之后都必须把挂载信息写入/etc/fstab这个文件中，否则下次开机启动时仍然需要重新挂载。系统开机时会主动读取/etc/fstab这个文件中的内容，根据文件里面的配置挂载磁盘。这样我们只需要将磁盘的挂载信息写入这个文件中我们就不需要每次开机启动之后手动进行挂载了。

限制:

　	1、根目录是必须挂载的，而且一定要先于其他mount point被挂载。因为mount是所有目录的根目录

　　2、挂载点必须是已经存在的目录。

　　3、挂载点的指定可以任意，但必须遵守必要的系统目录架构原则

　　4、所有挂载点在同一时间只能被挂载一次

　　5、所有分区在同一时间只能挂在一次

　　6、若进行卸载，必须将工作目录退出挂载点（及其子目录）之外。

格式:

一般嵌入式系统的ubuntu的存储设备不会经常插拔(插拔以后设备节点名字可能会变), 所以用存储设备节点即可, 无需存储分区的uuid, 电脑上一般用uuid

电脑上的(自动生成):

```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/nvme0n1p2 during installation
UUID=0a0dfe93-048e-4540-8a95-84be6b327d24 /  ext4  errors=remount-ro 0   1
# /boot/efi was on /dev/nvme0n1p1 during installation
UUID=FEC1-F8F8  /boot/efi  vfat  umask=0077  0  1
# swap was on /dev/nvme0n1p3 during installation
UUID=c27287bb-155d-41f0-923a-114978448199 none  swap   sw  0  0
```

开发板(有时候可能需要自己编写):

```
/dev/mmcblk0p1  /boot   vfat    defaults        0 0
/dev/mmcblk0p2  /       ext4    defaults        0 0
```

各列参数意义:

第一列:

​	使用设备名和label及uuid作为标识

第二列:

​	设备的挂载点，就是你要挂载到哪个目录下

第三列:

​	磁盘文件系统的格式，包括ext2、ext3、reiserfs、nfs、vfat等

第四列:

​	文件系统的参数	

| Async/sync  | 设置是否为同步方式运行，默认为async                     |
| ----------- | ---------------------------------------- |
| auto/noauto | 当下载mount -a 的命令时，此文件系统是否被主动挂载。默认为auto    |
| rw/ro       | 是否以以只读或者读写模式挂载                           |
| exec/noexec | 限制此文件系统内是否能够进行"执行"的操作                    |
| user/nouser | 是否允许用户使用mount命令挂载                        |
| suid/nosuid | 是否允许SUID的存在                              |
| Usrquota    | 启动文件系统支持磁盘配额模式                           |
| Grpquota    | 启动文件系统对群组磁盘配额模式的支持                       |
| Defaults    | 同事具有rw,suid,dev,exec,auto,nouser,async等默认参数的设置 |

第五列:

​	能否被dump备份命令作用：dump是一个用来作为备份的命令。通常这个参数的值为0或者1

第六列:

​	是否检验扇区：开机的过程中，系统默认会以fsck检验我们系统是否为完整（clean）

| 0    | 不要检验           |
| ---- | -------------- |
| 1    | 最早检验（一般根目录会选择） |
| 2    | 1级别检验完成之后进行检验  |

## 9. taskset指定进程运行的cpu

1.先启动后指定

先用ps查看进程PID:

```
robsense@robsense:~$ sudo ps -a
[sudo] password for robsense: 
  PID TTY          TIME CMD
  920 ttyPS1   00:00:00 bash
  992 pts/0    00:00:00 bash
 1003 pts/0    00:00:00 sudo
 1009 pts/0    00:00:00 sudo
 1013 pts/0    00:00:14 arducopter
 1025 ttyPS1   00:00:00 sudo
 1034 ttyPS1   00:00:00 ps
```

查看arducopter进程运行的cpu:

```
robsense@robsense:~$taskset -p 1013
pid 1013's current affinity mask: 3
```

3也就是二进制的11, 一个1代表一个cpu, 表示该进程在两个核上跑

指定在cpu1上跑:

```
robsense@robsense:~$ sudo taskset -pc 1 1013
pid 1013's current affinity list: 0,1
pid 1013's new affinity list: 1
```

再次查看:

```
robsense@robsense:~$ taskset -p 1013        
pid 1013's current affinity mask: 2
```

变成了10, 设置成功

2.启动进程时指定

```
echo "robsense" | sudo -S sudo taskset -c 1 ./arducopter -A /dev/ttyS2 -B /dev/ttyS3 -C /dev/ttyS0 -D /dev/ttyS1
```

查看cpu:

```
robsense@robsense:~$ taskset -p 1075        
pid 1075's current affinity mask: 2
```

PS: sched_setaffinity函数可以在代码中实现进程绑定cpu

## 10. core文件

允许产生core文件

```
ulimit  -c unlimited
```

查看core文件

```
gdb ./app
core-file core
```

默认core文件生成在app的同目录下

## 11.busybox 

下载:

```
https://busybox.net/downloads/
```

配置:

```
make ARCH=arm CROSS_COMPILER=arm-linux-gnueabihf- menuconfig

Busybox Settings  --->
    Build Options  --->
        [*]Build shared libbusybox
        [ ]   Produce a binary for each applet, linked against libbusybox
        [ ]   Produce additional busybox binary linked against libbusybox
意思是运行busybox才动态链接库，busybox需要的库要我们提供
        
Busybox Settings  --->
    Installation Options ("make install" behavior)  --->
        What kind of applet links to install (as soft-links)  --->
        (./_install) BusyBox installation prefix      // 编译生成文件的存放路径,新版本似乎没了
设置busybox生成后各种命令均为指向busybox主程序的软链接        
```

编译:

```
make ARCH=arm CROSS_COMPILER=arm-linux-gnueabihf- -j4
```

安装:

```
cp busybox rootfs/bin/
```

## 12. perf

参考:https://www.ibm.com/developerworks/cn/linux/l-cn-perf1/index.html

参考:http://blog.csdn.net/zhangskd/article/details/37902159

Perf 是用来进行软件性能分析的工具。

### 12.1编译:

```
cd linux-kernel/tools/perf
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

编译后生成elf文件perf, 然后拷贝到arm板即可运行

### 12.2 perf list

Perf-list用来查看perf所支持的性能事件，有软件的也有硬件的。

 ```
List all symbolic event types.

perf list [hw | sw | cache | tracepoint | event_glob]
 ```

### 12.2 perf stat

有些程序慢是因为计算量太大，其多数时间都应该在使用 CPU 进行计算，这叫做 CPU bound 型；有些程序慢是因为过多的 IO，这种时候其 CPU 利用率应该不高，这叫做 IO bound 型

```
$perf stat ./t1 
 Performance counter stats for './t1': 
 
 CPU 利用率，该值高，说明程序的多数时间花费在CPU计算上而非IO
 262.738415 task-clock-msecs # 0.991 CPUs	
 
 进程切换次数，记录了程序运行过程中发生了多少次进程切换，频繁的进程切换是应该避免的
 2 context-switches # 0.000 M/sec 
 
 表示进程 t1 运行过程中发生了多少次CPU迁移，即被调度器从一个CPU转移到另外一个CPU上运行
 1 CPU-migrations # 0.000 M/sec
 
缺页。指当内存访问时先根据进程虚拟地址空间中的虚拟地址通过MMU查找该内存页在物理内存的映射，没有找到该映射，则发生缺页，然后通过CPU中断调用处理函数，从物理内存中读取
 81 page-faults # 0.000 M/sec 
 
 处理器时钟，一条机器指令可能需要多个 cycles
 9478851 cycles # 36.077 M/sec (scaled from 98.24%) 
 
 机器指令数目, IPC是 Instructions/Cycles的比值，该值越大越好，说明程序充分利用了处理器的特性
 6771 instructions # 0.001 IPC (scaled from 98.99%) 
 
 这段时间内发生分支预测(一般是if else语句)的次数。现代的CPU都有分支预测方面的优化
 111114049 branches # 422.908 M/sec (scaled from 99.37%) 
 
 这段时间内分支预测失败的次数，这个值越小越好
 8495 branch-misses # 0.008 % (scaled from 95.91%)
 
 cache 命中的次数
 12152161 cache-references # 46.252 M/sec (scaled from 96.16%) 
 
 cache 失效的次数
 7245338 cache-misses # 27.576 M/sec (scaled from 95.49%) 
 
  0.265238069 seconds time elapsed 
 
上面告诉我们，程序 t1 是一个 CPU bound 型，因为 task-clock-msecs 接近 1。
```

### 12.3 perf top

Perf top 用于实时显示当前系统的性能统计信息。该命令主要用来观察整个系统当前的状态，比如可以通过查看该命令的输出来查看当前系统最耗时的内核函数或某个用户进程。

### 12.4 perf record和perf report

收集采样信息，并将其记录在数据文件中。随后可以通过其它工具(perf report)对数据文件进行分析，结果类似于perf top

常用参数:

```
-e：Select the PMU event.
-a：System-wide collection from all CPUs.
-p：Record events on existing process ID (comma separated list).
-A：Append to the output file to do incremental profiling.
-f：Overwrite existing data file.
-o：Output file name.
-g：Do call-graph (stack chain/backtrace) recording.
-C：Collect samples only on the list of CPUs provided.
```

例子:

```
perf record -e cpu-clock -g ./t1 记录执行t1时的cpu占用情况
perf record -e syscalls:sys_enter ls 记录执行ls时的系统调用，可以知道哪些系统调用最频繁
```

## 13. linux 串口操作

```
1.打开串口函数open_port()中要实现的函数：
(1)open("/dev/ttys0",O_RDWR | O_NOCTTY | O_NDELAY);/*打开串口0*/
(2)fcntl(fd,F_SETFL,0)/*恢复串口为阻塞状态*/
(3)isatty(STDIN_FILENO) /*测试是否为中断设备 非0即是中断设备*/

2.配置串口参数函数set_opt()中要实现的函数:
(1)保存原先有串口配置 
struct termios oldtio;
tcgetattr(fd,&oldtio);

(2)先将新串口配置清0 
struct termios newito;
bzore(&newtio,sizeof(newito));

(3)激活选项CLOCAL和CREAD 并设置数据位大小 
newtio.c_cflag |=CLOCAL | CREAD;
newtio.c_cflag &= ~CSIZE;
newtio.c_cflag |=CS8;

(4)设置奇偶校验
奇校验:
newtio.c_cflag |= PARENB;
newtio.c_cflag |= PARODD;
newtio.c_iflag |= (INPCK | ISTRIP);
偶校验: 
newtio.c_iflag |= (INPCK | ISTRIP);
newtio.c_cflag |= PAREND;
newtio.c_cflag &= ~PARODD;
无奇偶校验：
newtio.c_cflag &= ~PARENB;

(5) 设置停止位
newtio.c_cflag &= ~CSTOPB; /*停止位为1*/
newtio.c_cflag |= CSTOPB;/*停止位为0*/

(6)设置波特率:
cfsetispeed(&newtio,B115200);
cfsetospeed(&newtio,B115200);

(7)设置等待时间和最小接受字符:
newtio.c_cc[VTIME] = 0;
newtio.c_cc[VMIN] = 0;

(8)处理为接收字符:
tcflush(fd,TCIFLUSH);

(9)激活新配置:
tcsetattr(fd,TCSANOW,&newtio);
3.读写串口
write(fd,buff,8);
read(fd,buff,8);


```

读写阻塞：

open时不制定O_NOBLOCK或O_NDELAY，write和read时阻塞的，对于普通文件，read不阻塞

 串口操作分为规范模式和非规范模式。



规范模式：所有的输入是基于行进行处理。打开串口默认阻塞的情况下，下面两种情形造成读返回：

（1）所要求的字节数已读到是时，读返回。无需读一个完整的行，如果只是读取了行缓存的一部分，也不会丢失信息，下一次将从前一次读的停止处开始。

（2）当读到一个行界定符时，读返回。其中，换行符CR和文件结束符EOF都被认为一行的终止。但是，除了EOF之外的行结束符（回车符等）与普通字符一样会被read()函数读到缓冲区中。



非规范模式：所有的输入是即时有效的，不需要用户另外输入行结束符，而且不可进行行编程。在非规范模式下，对参数MIN（c_cc[VMIN]）和TIME(c_cc[VTIME])的设置决定read(0函数的调用方式，它们的组合关系如下：

​    1、VTIME=0，VMIN=0：此时即使读取不到任何数据，函数read也会返回，返回值是0。

​    2、VTIME=0，VMIN>0：read调用一直阻塞，直到读到VMIN个字符后立即返回。

​    3、VTIME>0，VMIN=0：read调用读到数据则立即返回，否则将为每个字符最多等待 VTIME*100ms 时间。

​    4、VTIME>0，VMIN>0：read调用将保持阻塞直到读取到第一个字符，读到了第一个字符之后开始计时，此后若时间到了 VTIME*100ms 或者时间未到但已读够了VMIN个字符则会返回。若在时间未到之前又读到了一个字符(但此时读到的总数仍不够VMIN)则计时重新开始(即每个字符都有VTIME*100ms的超时时间)。



##14. errno

**头文件 /usr/include/asm-generic/errno-base.h **

**头文件/usr/include/asm-generic/erno.h**

errno0 :     Success

errno1 :     Operation not permitted

errno2 :     No such file or directory

errno3 :     No such process

errno4 :     Interrupted system call

errno5 :     Input/output error

errno6 :     No such device or address

errno7 :     Argument list too long

errno8 :     Exec format error

errno9 :     Bad file descriptor

errno10 :    No child processes

errno11 :    Resource temporarily unavailable

errno12 :    Cannot allocate memory

errno13 :    Permission denied

errno14 :    Bad address

errno15 :    Block device required

errno16 :    Device or resource busy

errno17 :    File exists

errno18 :    Invalid cross-device link

errno19 :    No such device

errno20 :    Not a directory

errno21 :    Is a directory

errno22 :    Invalid argument

errno23 :    Too many open files in system

errno24 :    Too many open files

errno25 :    Inappropriate ioctl for device

errno26 :    Text file busy

errno27 :    File too large

errno28 :    No space left on device

errno29 :    Illegal seek

errno30 :    Read-only file system

errno31 :    Too many links

errno32 :    Broken pipe

errno33 :    Numerical argument out of domain

errno34 :    Numerical result out of range

errno35 :    Resource deadlock avoided

errno36 :    File name too long

errno37 :    No locks available

errno38 :    Function not implemented

errno39 :    Directory not empty

errno40 :    Too many levels of symbolic links

errno41 :    Unknown error 41

errno42 :    No message of desired type

errno43 :    Identifier removed

errno44 :    Channel number out of range

errno45 :    Level 2 not synchronized

errno46 :    Level 3 halted

errno47 :    Level 3 reset

errno48 :    Link number out of range

errno49 :    Protocol driver not attached

errno50 :    No CSI structure available

errno51 :    Level 2 halted

errno52 :    Invalid exchange

errno53 :    Invalid request descriptor

errno54 :    Exchange full

errno55 :    No anode

errno56 :    Invalid request code

errno57 :    Invalid slot

errno58 :    Unknown error 58

errno59 :    Bad font file format

errno60 :    Device not a stream

errno61 :    No data available

errno62 :    Timer expired

errno63 :    Out of streams resources

errno64 :    Machine is not on the network

errno65 :    Package not installed

errno66 :    Object is remote

errno67 :    Link has been severed

errno68 :    Advertise error

errno69 :    Srmount error

errno70 :    Communication error on send

errno71 :    Protocol error

errno72 :    Multihop attempted

errno73 :    RFS specific error

errno74 :    Bad message

errno75 :    Value too large for defined datatype

errno76 :    Name not unique on network

errno77 :    File descriptor in bad state

errno78 :    Remote address changed

errno79 :    Can not access a needed sharedlibrary

errno80 :    Accessing a corrupted sharedlibrary

errno81 :    .lib section in a.out corrupted

errno82 :    Attempting to link in too manyshared libraries

errno83 :    Cannot exec a shared librarydirectly

errno84 :    Invalid or incomplete multibyte orwide character

errno85 :    Interrupted system call should berestarted

errno86 :    Streams pipe error

errno87 :    Too many users

errno88 :    Socket operation on non-socket

errno89 :    Destinationaddress required

errno90 :    Message too long

errno91 :    Protocol wrong type for socket

errno92 :    Protocol not available

errno93 :    Protocol not supported

errno94 :    Socket type not supported

errno95 :    Operation not supported

errno96 :    Protocol family not supported

errno97 :    Address family not supported byprotocol

errno98 :    Address already in use

errno99 :    Cannot assign requested address

errno100 :   Network is down

errno101 :   Network is unreachable

errno102 :   Network dropped connection onreset

errno103 :   Software caused connection abort

errno104 :   Connection reset by peer

errno105 :   No buffer space available

errno106 :   Transport endpoint is alreadyconnected

errno107 :   Transport endpoint is notconnected

errno108 :   Cannot send after transportendpoint shutdown

errno109 :   Too many references: cannot splice

errno110 :   Connection timed out

errno111 :   Connection refused

errno112 :   Host is down

errno113 :   No route to host

errno114 :   Operation already in progress

errno115 :   Operation now in progress

errno116 :   Stale NFS file handle

errno117 :   Structure needs cleaning

errno118 :   Not a XENIX named type file

errno119 :   No XENIX semaphores available

errno120 :   Is a named type file

errno121 :   Remote I/O error

errno122 :   Disk quota exceeded

errno123 :   No medium found

errno124 :   Wrong medium type

errno125 :   Operation canceled

errno126 :   Required key not available

errno127 :   Key has expired

errno128 :   Key has been revoked

errno129 :   Key was rejected by service

errno130 :   Owner died

errno131 :   State not recoverable

errno132 :   Operation not possible due toRF-kill

errno133 :   Unknown error 133

errno134 :   Unknown error 134

errno135 :   Unknown error 135

errno136 :   Unknown error 136

errno137 :   Unknown error 137

errno138 :   Unknown error 138

errno139 :   Unknown error 139