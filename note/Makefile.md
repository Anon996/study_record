# Makefile

## 1.gcc常见编译错误

-  linker input file unused because linking not done

​              链接时加了-c参数,-c是只生成目标文件不链接, 只有在编译.o的时候加, 链接时不加

/home/steven/Steven/Develop/ardupilot/toolchain/gcc-arm-none-eabi-5_4-2016q3/bin/../lib/gcc/arm-none-eabi/5.4.1/../../../../arm-none-eabi/bin/ld: section .ARM.exidx loaded at [08010538,0801053f] overlaps section .data loaded at [08010538,08011747]

在link脚本中加入.ARM.exidx字段,

```
       . = ORIGIN(ram);
       .data : AT(_etext) {
                _data = .;
                *(.data*)       /* Read-write initialized data */
                . = ALIGN(4);
                _edata = .;
        } >ram
```

改为

```
    .ARM.exidx : {
        __exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        __exidx_end = .;
    } >rom
    

        . = ORIGIN(ram);


        .data : AT(__exidx_end) {
                _data = .;
                *(.data*)       /* Read-write initialized data */
                . = ALIGN(4);
                _edata = .;
        } >ram
```



## 2.gcc参数

- -ffunction-sections, -fdata-sections

​              使compiler为每个function和data item分配独立的section

- --gc-sections

​              使ld删除没有被使用的section, 链接操作以section作为最小的处理单元，只要一个section中有某个符号被引用，该section就会被放入output中, 加上这个参数可以减小输出文件的大小。

- -T

​         给链接器指定链接脚本

- -c 
  只激活预处理,编译,和汇编,也就是他只把程序做成obj文件 
  　　例子用法: 
  　　gcc -c hello.c 
  　　他将生成.o的obj文件 
- O0,O1,O2,O3,Os

​              编译器的优化选项的4个级别，-O0表示没有优化,-O1为缺省值，-O3优化级别最高,Os介于2和3之间

- -Wl.option

​         此选项传递option给连接程序;如果option中间有逗号,就将option分成多个选项,然 后传递给会连接程序. 

- -Ldir

​         制定编译的时候，搜索库的路径。比如你自己的库，可以用它制定目录，不然编译器将只在标准库的目录找。这个dir就是目录的名称。

- -M 

​         生成文件关联的信息。包含目标文件所依赖的所有源代码你可以用gcc -M hello.c来测试一下，很简单。 

- -MM 

​         和上面的那个一样，但是它将忽略由#include<file>造成的依赖关系。

- -MD 

​         和-M相同，但是输出将导入到.d的文件里面 

- -MMD 

​         和-MM相同，但是输出将导入到.d的文件里面 

- -Idir 

​         在你是用#include"file"的时候,gcc/g++会先在当前目录查找你所制定的头文件,如 果没有找到,他回到缺省的头文件目录找,如果使用-I制定了目录,他会先在你所制定的目录查找,然后再按常规的顺序去找. 对于#include<file>,gcc/g++会到-I制定的目录查找,查找不到,然后将到系统的缺省的头文件目录查找 

- -static

​         此选项将禁止使用动态库，所以，编译出来的东西，一般都很大，也不需要什么动态连接库，就可以运行. 

- -share

​         此选项将尽量使用动态库，所以生成文件比较小，但是需要系统由动态库. 

- -fpack-struct=1

​          所有结构体按1字节对齐, 不设定表示用默认值,默认32位程序按4字节对齐, 64位程序按8字节对齐

## 3. makefile常用变量

- $@   目标文件
- $^    所有依赖文件
- $<    第一个依赖文件
- @D  "$@"的目录部分（不以斜杠作为结尾）

## 4. makefile的include

​     类似C语言的include,直接在makefile中插入include文件中的字符串

## 5.自动生成依赖

利用gcc的-MM参数可以自动推导出头文件依赖,它将输出xx.o:xx.c
xx.h的形式,把它重定向到.d文件然后include之即可成为makefile中的规则,而且无须自己写%.o%.c的命令,makefile自动会执行命令,如果有参数要加就定义CFLAG变量,
 从而实现改动头文件无须make clean的功能

第一种做法:

main: $(OBJS)        $(CC) -o main $(OBJS).depend: $(SRCS)         @$(CC) -MM $(SRCS) > $@sinclude .depend这种做法出来的depend中包含了所有目标的文件依赖,并且目标是不带路径的, 如果.o在其他文件夹就没用了,而且官方手册声明这种方法过时,因为如果头文件中新include其他头文件,.depend并不会更新

第二种做法:

```
%.d: %.c        
	@set -e; rm -f @; /
    (CC) -MM  < > @.$$$$; /
    sed 's,/($*/)/.o[ :]*,/1.o $@ : ,g' < $@.$$$$ > $@; /
    rm -f $@.$$$$
sinclude $(SOURCES:.c=.d)
main:$(OBJS)
    	$(CC) -o main $(OBJS)
```

这种方法是每个.c对应生成一个.d,里面只包含该.c文件的依赖关系
 sed 's,/($*/)/.o[ :]*,/1.o $@ : ,g' < $@.$$$$ > $@; /这句会把MM的输出变成xx.o xx.d: xx.c xx.h的形式,这样头文件有改动也会重新.d,也就是头文件中新include一个头文件.d文件也会更新,但是目标还是不带路径\

第三种做法:

```
(ELF):(OBJS) $(LINKER_FILE) 
    @echo 'Building target: $@'
    @echo 'Invoking:$(CC)'
    (CC) (CFLAGS) (LDFLAGS) -o @ (OBJS) (LIBS)
    @echo 'Finished building target: $@'
    @echo ' '
%.o:%.c
    @echo 'Building C file: $<'
    @echo 'Invoking:$(CC)'
    (CC) (CFLAGS) -c -MMD -o @ < 
    @echo 'Finished building: $<'
    @echo ' '
sinclude $(SRCS:.c=.d)
```

这种做法是参考赛灵思的sdk自动生成的makefile, 通过MMD直接在编译.o的时候把依赖关系导入.d文件,而且这种方法出来的目标是带路径的:

```
../common/can_drv.o: ../common/can_drv.c ../common/hw_config.h 
```

同时也可以解决方法一中.d文件不更新的问题.

## 6.gcc 引用math.h头文件，编译出现undefined reference to `pow‘等错

使用`math.h`中声明的库函数还有一点特殊之处，`gcc`命令行必须加`-lm`选项，因为数学函数位于`libm.so`库文件中（这些库文件通常位于`/usr/lib`目录下），`-lm`选项告诉编译器，我们程序中用到的数学函数要到这个库文件里找

## 7.Makefile函数定义

```
# (BUILTIN_DEF,<cmdspec>,<outputfile>)
define BUILTIN_DEF
	$(ECHO) '    {"$(word 1,$1)", $(word 2,$1), $(word 3,$1), $(word 4,$1)},' >> $2;
endef
```

\$1和\$2分别代表函数的两个参数, 用call来调用这个函数:

```
$(call BUILTIN_PROTO,param1,param2)
```



## 8.Makefile常用函数

函数调用

\$(函数名 参数)

或者

\${函数名 参数}

### 8.1 subst

定义:

```
$(subst <from>,<to>,<text>)
```

功能：把字串<text>中的<from>字符串替换成<to>

返回：函数返回被替换过后的字符串

### 8.2 patsubst

定义:

```
$(patsubst <pattern>,<replacement>,<text>)
```

功能：查找<text>中的单词（单词以“空格”、“Tab”或“回车”“换行”分隔）是否符合模式<pattern>，如果匹配的话，则以<replacement>替换。这里，<pattern>可以包括通配符“%”，表示任意长度的字串。如果<replacement>中也包含“%”，那么，<replacement>中的这个“%”将是<pattern>中的那个“%”所代表的字串。（可以用“\” 来转义，以“\%”来表示真实含义的“%”字符） 

返回：函数返回被替换过后的字符串

示例:

```
$(patsubst %.c,%.o,x.c.cbar.c)
#把字串“x.c.cbar.c”符合模式[%.c]的单词替换成[%.o]，返回结果是“x.c.obar.o”
```

### 8.3 strip

定义:

```
$(strip <string>)
```

功能：去掉<string>字串中开头和结尾的空字符

返回：返回被去掉空格的字符串值

### 8.4  findstring

定义:

```
$(findstring <find>,<in>)
```

功能：在字串<in>中查找<find>字串

返回：如果找到，那么返回<find>，否则返回空字符串

示例：

```
$(findstring a,a b c) 
$(findstring a,b c)
#第一个函数返回“a”字符串，第二个返回“”字符串（空字符串）
```

### 8.5 filter

定义:

```
$(filter <pattern...>,<text>)
```

功能：以<pattern>模式过滤<text>字符串中的单词，保留符合模式<pattern>的单词。可以有多个模式

 返回：返回符合模式<pattern>的字串

示例：

```
sources := foo.c bar.c baz.s ugh.h 
foo: $(sources) 
cc $(filter %.c %.s,$(sources)) -o foo
#返回的值是“foo.c bar.c baz.s”
```

### 8.6 filter-out

用法和filter一样, 只不过返回的是不符合pattern的字符串

### 8.7 word

定义:

```
$(word <n>,<text>)
```

功能：取字符串<text>中第<n>个单词（从1开始, 以空格为单词判断依据）

返回：返回字符串<text>中第<n>个单词。如果<n>比<text>中的单词数要大，那么返回空字符串

### 8.8 wordlist

定义:

```
$(wordlist <s>,<e>,<text>)
```

功能：从字符串<text>中取从<s>开始到<e>的单词串。<s>和<e>是一个数字

返回：返回字符串<text>中从<s>到<e>的单词字串。如果<s>比<text>中的单词数要大，那么返回空字符串。如果<e>大于<text>的单词数，那么返回从<s>开始，到<text>结束

### 8.9 words

定义:

```
$(words <text>)
```

功能：统计<text>中字符串中的单词个数

返回：返回<text>中的单词数

**note:**如果我们要取<text>中最后的一个单词，我们可以这样

```
$(word $(words <text>),<text>)
```

### 8.10 dir

定义:

```
$(dir <names...>)
```

功能：从文件名序列<names>中取出目录部分。目录部分是指最后一个斜杠（"/"）之前的部分。如果没有斜杠，那么返回"./"。

返回：返回文件名序列<names>的目录部分

### 8.11 notdir

和dir一样, 只不过返回的是非目录部分, 也就是文件名

### 8.12 suffix

定义:

```
$(suffix <names...>)
```

功能：从文件名序列<names>中取出**各个**文件名的后缀(以. 为分割依据)

返回：返回文件名序列<names>的后缀序列，如果文件没有后缀，则返回空字串

### 8.13 basename

定义:

```
$(basename <names...>)
```

功能：从文件名序列<names>中取出**各个**文件名的前缀部分

返回：返回文件名序列<names>的前缀序列，如果文件没有前缀，则返回空字串

### 8.14 addsuffix

定义:

```
$(addsuffix <suffix>,<names...>)
```

功能：把后缀<suffix>加到<names>中的**每个**单词后面

返回：返回加过后缀的文件名序列

### 8.15 addprefix

加前缀, 用法和addsuffix一样

### 8.16 shell 

参数就是Shell 的命令:

```
contents := $(shell cat foo)
```

### 8.17 call

定义:

```
$(call <expression>,<parm1>,<parm2>,<parm3>...)
```

功能：可以写一个非常复杂的表达式，这个表达式中，可以定义许多参数，然后用call函数来向这个表达式传递参数

示例:

```
reverse = $(1) $(2)
foo = $(call reverse,a,b)
#foo的值就是“ab”
```

### 8.18 foreach

定义:

```
$(foreach <var>,<list>,<text>)
```

功能：把参数<list>中的单词逐一取出放到参数<var>所指定的变量中，然后再执行<text>所包含的表达式。每一次<text>会返回一个字符串，循环过程中，<text>的所返回的每个字符串会以空格分隔，最后当整个循环结束时，<text>所返回的每个字符串所组成的整个字符串（以空格分隔）将会是foreach函数的返回值

## 9. arm-linux-gnueabi和arm-linux-gnueabihf

### 9.1 abi

二进制应用程序接口(Application Binary Interface (ABI) for the ARM Architecture), 在计算机中，应用二进制接口描述了应用程序（或者其他类型）和操作系统之间或其他应用程序的低级接口.ABI涵盖了各种细节，如：
​	数据类型的大小、布局和对齐;
​	调用约定（控制着函数的参数如何传送以及如何接受返回值），例如，是所有的参数都通过栈传递，还是部分参数通过寄存器传递；哪个寄存器用于哪个函数参数；通过栈传递的第一个函数参数是最先push到栈上还是最后；
​	系统调用的编码和一个应用如何向操作系统进行系统调用；
​	以及在一个完整的操作系统ABI中，目标文件的二进制格式、程序库等等.

一个完整的ABI，像Intel二进制兼容标准 (iBCS) ，允许支持它的操作系统上的程序不经修改在其他支持此ABI的操作体统上运行。ABI不同于应用程序接口（API），API定义了源代码和库之间的接口，因此同样的代码可以在支持这个API的任何系统中编译，ABI允许编译好的目标代码在使用兼容ABI的系统中无需改动就能运行。

### 9.2 eabi

嵌入式ABI, 与关于通用计算机的ABI的主要区别是应用程序代码中允许使用特权指令，不需要动态链接（有时是禁止的），和更紧凑的堆栈帧组织用来节省内存。广泛使用EABI的有Power PC和ARM.

### 9.3  gnueabi相关的两个交叉编译器: gnueabi和gnueabihf

gcc-arm-linux-gnueabi – The GNU C compiler for armel architecture
gcc-arm-linux-gnueabihf – The GNU C compiler for armhf architecture

这两个交叉编译器只不过是gcc的选项-mfloat-abi的默认值不同. gcc的选项-mfloat-abi有三种值soft,softfp,hard(其中后两者都要求arm里有fpu浮点运算单元,soft与后两者是兼容的，但softfp和hard两种模式互不兼容)：
​	soft   : 不用fpu进行浮点计算，即使有fpu浮点运算单元也不用,而是使用软件模式。
​	softfp : armel架构(对应的编译器为gcc-arm-linux-gnueabi)采用的默认值，用fpu计算，但是传参数用普通寄存器传，这样中断的时候，只需要保存普通寄存器，中断负荷小，但是参数需要转换成浮点的再计算。
​	hard   : armhf架构(对应的编译器gcc-arm-linux-gnueabihf)采用的默认值，用fpu计算，传参数也用fpu中的浮点寄存器传，省去了转换, 性能最好，但是中断负荷高。

操作系统运行的是armhf还是armel是看文件系统中/lib路径下动态库是ld-linux-armhf.so.3还是ld-linux.so.3, 执行二进制文件时会去动态链接这个库, 如果架构不匹配, 会提示**file not found**

如果要在armel的文件系统中运行armhf的程序, 在编译时加上-static参数即可, 作用是静态链接ld库和C库, 规避运行不了的问题, 副作用是编译出来的程序会大很多, 比如ocm_master, 不加static只有108K, 加上以后有2.8M

## 10. 调试

Makefile只能打印调试:

```
$(info, "here add the debug info")			不能打印出.mk的行号
$(warning, "here add the debug info")
$(error "error: this will stop the compile") 可以停止当前makefile的编译
```



## 11. 查看gcc/g++预定义宏 

```
gcc -dM -E - < /dev/null
```

