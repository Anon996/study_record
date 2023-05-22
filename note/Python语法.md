# Python语法

## 1. 基本元素

### 1.1 数据类型

- 布尔型(True/False)
- 整形(整数:42, 1000) - 用int()函数可将其他类型的数据转成整型(带小数点的以及非纯数字字符串除外)
- 浮点型(小数, 3.14或者**科学计数法**表示的数字,1.0e8 - 100000000.0) - float()函数可转换浮点
- 字符串型(python字符串不可变,只能复制,""或者''都可以表示, 引号见没有内容就是**空串**) - str()函数可转换字符

所有数据类型都是以对象形式存在(包括数据结构,函数,程序), 所以一个变量的数据类型是无法修改的

对象可以比作盒子,对象类型决定盒子里的是数据是允许修改的**变量**还是不允许修改的**常量**, 可变对象可以修改里面的是数据但无法改变对象类型

**Note:**

python处理超大数不会有溢出问题, python3中int可以存储任意大小的数字:

```
>>> a=10**1000
>>> a
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
```



### 1.2 变量

python的变量就是为了方便引用内存中的值而取的**名称**(仅仅是个名字,赋值操作不会复制值,而是取个名字), 相当于是贴在盒子上的标签. 如果想知道变量的类型可以用函数

```
type(thing)
```

```
>>> a = 10
>>> type(a)
<class 'int'>
>>> a = 1.1
>>> type(a)
<class 'float'>
```

变量名称只能包含以下字符:

- 小写字母
- 大写字母
- 下划线(下划线开头的名字有特殊含义,不可随便用)
- 数字(不可以数字开头!)

和C一样ptyhon的**关键字**也不可以用作变量名

### 1.3 运算符

- +
- -
- *
- /       浮点除法
- //      整数除法
- %      取余
- **      幂

如果除0会出现异常:

```
>>> 5/0
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ZeroDivisionError: division by zero
```

**Note**:

divmod()可以同时得到余数和商

```
>>> divmod(10,3)
(3, 1)
```

### 1.4 进制

​	不加前缀默认为十进制

- 二进制: 0b/0B
- 八进制: 0o/0O
- 十六进制: 0x/0X

python解释器打印十进制:

```
>>> 0x15
21
```

### 1.5 数学函数

首先导入数学库

```
import math
```

#### 1.5.1 绝对值

```
>>> math.fabs(-98.6)
98.6
```

#### 1.5.2 向下取整数

```
>>> math.floor(98.6)
98
```

#### 1.5.3 向上取整数

```
>>> math.ceil(98.1)
99
```

#### 1.5.4 阶乘

```
>>> math.factorial(10)
3628800
```

#### 1.5.5 对数

```
>>> math.log(1.0)
0.0
>>> math.log(math.e)
1.0
>>> math.e
2.718281828459045
```

#### 1.5.6 指数

指数用**也可计算,但是底数指数都为整数,算出来的值不会转成浮点数,用pow()算出来的都是浮点

```
>>> math.pow(2,3)
8.0
>>> 2**3
8
>>> 2.0**3
8.0
```

#### 1.5.7 平方根

```
>>> math.sqrt(100)
10.0
```

#### 1.5.8 三角函数

```
>>> math.sin(30)
-0.9880316240928618
```

为何结果好像不对? 因为sin是以弧度为参数,传角度用radians()方法

```
>>> math.sin(math.radians(30))
0.49999999999999994
```

其他三角函数还有: cos, tan, asin, acos, atan, atan2

#### 1.5.9 勾股定理

```
>>> math.hypot(3,4)
5.0
```

#### 1.5.10 弧度角度转换

弧度:

```
>>> math.radians(180)
3.141592653589793
```

角度:

```
>>> math.degrees(3.1415926)
179.99999692953102
```

### 1.6 字符串操作

python字符串不可变,只能复制,""或者''都可以表示, 引号见没有内容就是**空串**

所有字符串都是对象, 想知道有哪些方法可以调用, 在交互解释器中输入str_name.加tab即可显示所有方法

```
>>> a.
a.__add__(           a.__rmod__(          a.istitle(
a.__class__(         a.__rmul__(          a.isupper(
a.__contains__(      a.__setattr__(       a.join(
a.__delattr__(       a.__sizeof__(        a.ljust(
a.__dir__(           a.__str__(           a.lower(
a.__doc__            a.__subclasshook__(  a.lstrip(
a.__eq__(            a.capitalize(        a.maketrans(
a.__format__(        a.casefold(          a.partition(
a.__ge__(            a.center(            a.replace(
a.__getattribute__(  a.count(             a.rfind(
a.__getitem__(       a.encode(            a.rindex(
a.__getnewargs__(    a.endswith(          a.rjust(
a.__gt__(            a.expandtabs(        a.rpartition(
a.__hash__(          a.find(              a.rsplit(
a.__init__(          a.format(            a.rstrip(
a.__iter__(          a.format_map(        a.split(
a.__le__(            a.index(             a.splitlines(
a.__len__(           a.isalnum(           a.startswith(
a.__lt__(            a.isalpha(           a.strip(
a.__mod__(           a.isdecimal(         a.swapcase(
a.__mul__(           a.isdigit(           a.title(
a.__ne__(            a.isidentifier(      a.translate(
a.__new__(           a.islower(           a.upper(
a.__reduce__(        a.isnumeric(         a.zfill(
a.__reduce_ex__(     a.isprintable(       
a.__repr__(          a.isspace(     
```



#### 1.6.1字符串用两种引号的好处

可以在字符串中包含引号而不需要转义字符:

```
>>> "'HB', hhhhhh"
"'HB', hhhhhh"
```

#### 1.6.2三元引号

三元引号创建多行字符串:

```
>>> a='''HB
... sljefi
... hhh'''
>>> print(a)
HB
sljefi
hhh
>>> 
```

#### 1.6.3 空串

```
>>> bottles=99
>>> base=''
>>> base+='hhhhh'
>>> base+=str(bottles)
>>> base
'hhhhh99'
```

#### 1.6.4 字符串复制:

```
>>> a='hb'*4
>>> a
'hbhbhbhb'
```

#### 1.6.5 字符串拼接

用+可以进行简单的字符串合并

```
>>> a= "HB" + "HHH"
>>> a
'HBHHH'
```

用join()方法可以利用粘合字符合并

```
>>> list = ['aaa', 'bbb', 'ccc']
>>> '/'.join(list)
'aaa/bbb/ccc'
>>> ''.join(list)
'aaabbbccc'
>>> ' '.join(list)
'aaa bbb ccc'
```

#### 1.6.6 提取字符串

用[]可以提取字符串:

```
>>> a = "abcdefghijklmnopqrstuvwxyz"
>>> a[0]
'a'
>>> a[-1]
'z'
>>> a[-2]
'y'
>>> a[10]
'k'
```

分片操作:

- [:]从头到尾
- [start:]从start到尾
- [:end]从头到end-1
- [start:end]从start到end-1
- [start:end :step]从start到end-1每step个字符提取一个,step为负数时从右往左提取

分片操作如果偏移量超出范围就按开头和结尾算

```
>>> a[10:15]
'klmno'
>>> a[:]
'abcdefghijklmnopqrstuvwxyz'
>>> a[20:]
'uvwxyz'
>>> a[:10]
'abcdefghij'
>>> a[-3:]
'xyz'
>>> a[18:-3]
'stuvw'
>>> a[::7]
'ahov'
>>> a[::-1]
'zyxwvutsrqponmlkjihgfedcba'
>>> a[::-1]
'zyxwvutsrqponmlkjihgfedcba'
>>> a[20::-1]
'utsrqponmlkjihgfedcba'
>>> a[:20:-1]
'zyxwv'
>>> a[-50:50]
'abcdefghijklmnopqrstuvwxyz'
```

#### 1.6.7 字符串长度

```
>>> len(a)
26
>>> empty=""
>>> len(empty)
0
```

#### 1.6.8 字符串内容替换

```
>>> name="HeBin"
>>> name.replace('H', 'h')
'heBin'
```

#### 1.6.9 字符串分割

str对象的split方法可以基于**分割符**将字符串分成各个子字符串存入**列表(list)**,如果没有传入分割符,则默认用空白字符--换行/空格/制表

```
>>> a="aaa bbb, ccc ddd, eee fff"
>>> a.split(',')
['aaa bbb', ' ccc ddd', ' eee fff']
>>> a.split()
['aaa', 'bbb,', 'ccc', 'ddd,', 'eee', 'fff']
```

#### 1.6.10 字符串位置

第一次出现

```
>>> a='aaa bbb, ccc ddd, eee fff'
>>> a.find('a')
0
>>> a.find('b')
4
```

最后一次出现

```
>>> a.rfind('b')
6
>>> a.rfind('a')
2
```

#### 1.6.11 字符串出现次数

```
>>> a.count("aa")
1
>>> a.count("a")
3
```

#### 1.6.12 所有字符都是字母或数字?

```
>>> a.isalnum()
False
```

#### 1.6.13 首字母换成大写

用capitalize()方法

## 2. Python容器

### 2.1 列表

可以包含0个或多个不同种类的类型对象

#### 2.1.1 创建列表

用[]或list()创建列表

```
>>> empty_list  = []
>>> list = ['sefesf', 'sefser']
>>> list
['sefesf', 'sefser']
>>> empty_list
[]
>>> empty_list1 = list()
>>> empty_list1
[]
>>> 
```

#### 2.1.2 列表转换

list()也可以将其他数据类型转成列表

```
>>> list('cat')
['c', 'a', 't']
```

#### 2.1.3 用[offset]获取,修改元素

获取包括分片操作和1.6.6中操作一样

```
>>> list1=["123","234","555"]
>>> list1[3]="abc"
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
IndexError: list assignment index out of range
>>> list1[2]="abc"
>>> list1
['123', '234', 'abc']
```

**Note**:

如果列表中的元素是字符串, 则无法修改字符串中的某个字符,因为字符串不可变

#### 2.1.4 包含列表的列表

```
>>> list1=["123","456","789"]
>>> list2=["hhh","bbbb"]
>>> list_all=[list1, list2]
>>> list_all
[['123', '456', '789'], ['hhh', 'bbbb']]
>>> list_all[0]
['123', '456', '789']
>>> list_all[1]
['hhh', 'bbbb']
>>> list_all[1][1]
'bbbb'
```

#### 2.1.5添加至尾部

```
>>> list1.append('ggg')
>>> list1
['123', '234', 'abc', 'ggg']
```

#### 2.1.6 合并

extend方法或者+=都可以

```
>>> list2=['fff','sss']
>>> list1.extend(list2)
>>> list1
['123', '234', 'abc', 'ggg', 'fff', 'sss']
>>> list1+=list2
>>> list1
['123', '234', 'abc', 'ggg', 'fff', 'sss', 'fff', 'sss']
>>> 
```

#### 2.1.7 指定位置插入

```
>>> list1.insert(2,'666')
>>> list1
['123', '234', '666', 'abc', 'ggg', 'fff', 'sss', 'fff', 'sss']
```

#### 2.1.8 指定位置删除

```
>>> del list1[2]
>>> list1
['123', '234', 'abc', 'ggg', 'fff', 'sss', 'fff', 'sss']
```

del是python语句,不是方法!!相当与=的逆过程,将对象与名字分离,如果无其他名字,空间也会清除

#### 2.1.9 删除指定值

```
>>> list1.remove('ggg')
>>> list1
['123', '234', 'abc', 'fff', 'sss', 'fff', 'sss']
```

#### 2.1.10 pop()获取并删除指定位置

```
>>> list1.pop(0)
'123'
>>> list1.pop(-1) #list1.pop()也有同样效果
'sss'
>>> list1
['234', 'abc', 'fff', 'sss', 'fff']
```

**Note:**pop和apend结合可以实现栈和fifo,pop(0)就是fifo, pop(-1)或pop()就是栈

#### 2.1.11 查询元素位置

```
>>> list1
['234', 'abc', 'fff', 'sss', 'fff']
>>> list1.index('sss')
3
```

#### 2.1.12 元素是否存在

```
>>> 'abc' in list1
True
>>> 'abcc' in list1
False
```

用count方法可以记录出现的次数,和字符串的是一样的

#### 2.1.13 排序

排序有两种方法

1.sort()方法  -- 改变原列表内容

2.sorted()通用函数 -- 不改变列表内容,返回一个排好序的副本

```
>>> sorted(list1)
['234', 'abc', 'fff', 'fff', 'sss']
>>> list1
['234', 'abc', 'fff', 'sss', 'fff']
>>> list1.sort(reverse=True)
>>> list1
['sss', 'fff', 'fff', 'abc', '234']
```

如果列表有字符串和数字类型则无法排序:

```
>>> list1.append(4.0)
>>> list1.sort(reverse=True)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: unorderable types: str() < float()
```

如果列表都是数字,浮点整型混合也可以排序

#### 2.1.14 =赋值和copy复制

一个列表赋值给多个变量(也就是取多个名字,C中理解为指针), 改变任何一处,其他变量对应的值都会改, 一下几种都是新对象,而不是赋值:

- 列表的copy()方法
- list()转换函数
- 列表分片

### 2.2 元组

与列表的区别就是值无法改变,没有添加,删除,修改等操作

#### 2.2.1 创建

```
>>> empty_tuple=()
>>> empty_tuple
()
>>> tuple1='sfe',
>>> tuple1
('sfe',)
```

元组创建可以省略括号,但是**只有一个元素时,逗号不能省**

tuple()函数可以用其他数据类型来创建元组

```
>>> tuple(list1)
('sss', 'fff', 'fff', 'abc', '234', 4.0)
```

#### 2.2.2 多变量同时赋值

```
>>> tuple1='sfe','ret'
>>> a,b=tuple1
>>> a
'sfe'
>>> b
'ret'
```

称为**元组解包**,利用这种方法可以不需要临时变量来交换数据

```
>>> a1=123
>>> a2=345
>>> a1,a2=a2,a1
>>> a1
345
>>> a2
123
```

#### 2.2.3 元组优势

- 占用空间小
- 不会意外修改内容
- 可作为字典的key
- 命名元组可以作为对象的替代
- 函数的参数以元组形式传递

### 2.3 字典

和列表类似,但是顺序无关紧要,每个值会对应一个key, key通常是字符串,也可以是任何其他不可变的数据类型

#### 2.3.1 创建

用{}创建

```
>>> dict1={"a":"hlfjsei", "b":"jfeio"}
>>> dict1
{'b': 'jfeio', 'a': 'hlfjsei'}
```

dict可以将包含双值子序列的列表或者元组转成字典:

```
>>> list2=[['a', 'b'],['c', 'd'],['e', 'f'],]
>>> dict(list2)
{'c': 'd', 'a': 'b', 'e': 'f'}
>>> 
>>> tuple2=(['a', 'b'],['c', 'd'],['e', 'f'])
>>> dict(tuple2)
{'c': 'd', 'a': 'b', 'e': 'f'}
>>>
>>> list2=["ab","cd"]
>>> dict(list2)
{'c': 'd', 'a': 'b'}
>>>
>>> tuple2=("ab","cd")
>>> dict(tuple2)
{'c': 'd', 'a': 'b'}
```

字典的键必须是不可变对象,所以列表,字典,集合都不能作为键,但是元组可以, 例如GPS坐标可以放入元组作为键

### 2.4 集合

集合就是舍弃了值,只剩键的字典一样, 内容不可重复, 无序

#### 2.4.1 创建

用set()或者大括号创建

```
>>> empty_set = set()
>>> empty_set
set()
>>> 
>>> even = {0, 1, 2, 3}
>>> even
{0, 1, 2, 3}
>>> even = {0, 1, 2, 2}
>>> even
{0, 1, 2}
```

**Note:**用[]可以创建空列表,但是{}只能创建空字典而不是空集合

#### 2.4.2 转换

用set()也可以把其他类型转为集合

```
>>> set("letter")		#字符串
{'e', 'l', 't', 'r'}
>>> set(['d','fg'])		#列表
{'fg', 'd'}
>>> set(('d','fg'))		#元组
{'fg', 'd'}
```

#### 2.4.3 update合并集合

字典也有一样的操作

```
>>> even
{0, 1, 2}
>>> even1 = {'f'}
>>> even.update(even1)
>>> even
{0, 1, 2, 'f'}
```

#### 2.4.4 复制集合

字典也有一样的操作

```
>>> hb=even.copy()
>>> hb
{0, 1, 2, 'f'}
```

#### 2.4.5 交集运算

可以用& 或者 intersection()方法

```
>>> even
{0, 1, 2, 'f'}
>>> even1
{'f'}
>>> even & even1
{'f'}
>>> even.intersection(even1)
{'f'}
```

#### 2.4.6 并集运算

可以用| 或者union()方法

```
>>> even1 = {4, 5}
>>> even
{0, 1, 2, 'f'}
>>> even | even1
{0, 1, 2, 'f', 4, 5}
>>> even.union(even1)
{0, 1, 2, 'f', 4, 5}
```

#### 2.4.7 差集运算(出现在第一个集合不出现在第二个集合)

可以用- 或者difference()方法

```
>>> even
{0, 1, 2, 'f'}
>>> even1
{4, 5}
>>> even-even1
{0, 1, 2, 'f'}
>>> even.difference(even1)
{0, 1, 2, 'f'}
```

#### 2.4.8异或(两个集合中出现一次)

可以用^或者symmetric_difference()方法

```
>>> even
{0, 1, 2, 'f'}
>>> even1
{4, 5}
>>> even^even1
{0, 1, 2, 4, 5, 'f'}
>>> even.symmetric_difference(even1)
{0, 1, 2, 4, 5, 'f'}
```

#### 2.4.9 子集

可以用<= 或者issubset()方法

```
>>> even
{0, 1, 2, 'f'}
>>> even1
{4, 5}
>>> even<=even1
False
>>> even.issubset(even1)
False
>>> even.issubset(even)
True
>>> even<even1  #真子集
False
>>> even<even	#真子集
False
```

#### 2.4.10 超集

和子集相反,>= 或者issuperset()方法, 真超级也一样,去掉=即可

## 3.语句

### 3.1 条件判断

```
if 条件:
	...
elif 条件:
	...
else:
	...
```

比较操作符和C语言一样,多了一个

```
in... #属于
```

同时进行多个比较, 使用布尔操作符and, or, not

```
>>> x =1
>>> 1<x and x<10
False
>>> 1<x or x<10
True
>>> 1<x or not x<10
False
>>> 0<x<5
True
```

如果if中表达式返回类型不是布尔型, 除以下情况外都认为是True:

| null类型 | None  |
| ------ | ----- |
| 整型     | 0     |
| 浮点     | 0.0   |
| 空字符串   | ''    |
| 空列表    | []    |
| 空元组    | ()    |
| 空字典    | {}    |
| 空集合    | set() |

可以用来判断容器中是否有值, 只要有值就返回True, 类似C语言, 非0值都是True

### 3.2 循环

```
>>> i=1
>>> while i <= 5:
...     print(i)
...     i += 1
... 
1
2
3
4
5

a = None
if a is None:

pass

else:

pass



```

和C语言一样, 循环中都有break和continue

和C语言的while不一样的是, python的while可以用else, **如果while中没有用break跳出, 就会执行else部分的代码**

### 3.3 for迭代

```
>>> hb
['123', 'sdf', 'fff']
>>> for i in hb:	#遍历列表
...     print(i)
... 
123
sdf
fff

>>> s="jslfjeojf"
>>> for i in s:		#遍历字符串
...     print(i)
... 
j
s
l
f
j
e
o
j
f

#遍历字典
>>> d = {"f":"ff", 'b':'bb', 'a':'bb'}
>>> for i in d:			#遍历键
...     print(i)
... 
a
f
b
>>> for i in d.keys():	#遍历键
...     print(i)
... 
a
f
b
>>> for i in d.values():	#遍历值
...     print(i)
... 
bb
ff
bb
>>> for i in d.items():		#遍历键值对,返回元组
...     print(i)
... 
('a', 'bb')
('f', 'ff')
('b', 'bb')
>>> for i,j in d.items():	#遍历键值对
...     print(i,j)
... 
a bb
f ff
b bb
```

和while一样, for也有break, continue, else

### 3.4 zip并行迭代

```
>>> a='1','2','3'
>>> b='1.1', '2.1'
>>> zip(a,b)
<zip object at 0x7fbd0e37afc8>
>>> 
>>> for i,j in zip(a,b):
...     print(i, '-', j)
... 
1 - 1.1
2 - 2.1
```

在最短的序列"用完"以后就会停止迭代

利用zip也可以把两个序列中相同位移的项目创建成字典或者列表

```
>>> dict(zip(a,b))
{'2': '2.1', '1': '1.1'}
>>> list(zip(a,b))
[('1', '1.1'), ('2', '2.1')]
```

### 3.5 range()生成自然数序列

用法类似切片:range(start, end, step)

```
>>> for i in range(1,6,2):
...     print(i)
... 
1
3
5
>>> list(range(1,6))
[1, 2, 3, 4, 5]
>>> list(range(2,-1,-1))
[2, 1, 0]
>>> list(range(2,6,-1))
[]
>>> list(range(6,2,-1))
[6, 5, 4, 3]
>>> list(range(6,2,1))
[]
```

### 3.6 推导式

#### 3.6.1 列表推导

基本形式

```
[表达式 for i in 序列]
```

例:

```
>>> [i for i in range(1,6)]
[1, 2, 3, 4, 5]
>>> [i-1 for i in range(1,6,2)]
[0, 2, 4]
```

增加条件判断

```
[表达式 for i in 序列 if 条件]
```

例:

```
>>> [i-1 for i in range(1,6) if i>1]
[1, 2, 3, 4]
>>> [i for i in range(1,6) if i>1]
[2, 3, 4, 5]

>>> rows=range(1,6)
>>> cols=range(1,5)
>>> [(i,j) for i in rows for j in cols]
[(1, 1), (1, 2), (1, 3), (1, 4), (2, 1), (2, 2), (2, 3), (2, 4), (3, 1), (3, 2), (3, 3), (3, 4), (4, 1), (4, 2), (4, 3), (4, 4), (5, 1), (5, 2), (5, 3), (5, 4)]
>>> [(i,j) for i in rows for j in cols if i==j]
[(1, 1), (2, 2), (3, 3), (4, 4)]

```

#### 3.6.2 字典推导

基本形式

```
{键:值 for i in 序列}
```

例:

```
#统计字符串中各个字符的出现次数
>>> {c:hb.count(c) for c in hb}
{'e': 1, 'l': 1, 'f': 2, 'k': 1, 'j': 1, 's': 2}
>>> {c:hb.count(c) for c in hb if c=='f'}
{'f': 2}
>>> {c:hb.count(c) for c in hb if hb.count(c)==2}
{'f': 2, 's': 2}
```

#### 3.6.3 集合推导

上个例子中f出现两次, 也迭代了两次, 浪费时间, 利用集合可以减少调用次数

```
>>> {c:hb.count(c) for c in set(hb)}
{'e': 1, 'l': 1, 'f': 2, 'k': 1, 'j': 1, 's': 2}
>>> {c:hb.count(c) for c in set(hb) if hb.count(c)==2}
{'f': 2, 's': 2}
>>> {c:hb.count(c) for c in set(hb) if c=='f'}
{'f': 2}
```

#### 3.6.4 生成器推导式

元组没有推导式, 把列表推导式换成圆括号返回的不是元组,是生成器对象

```
>>> ((i,j) for i in rows for j in cols if i==j)
<generator object <genexpr> at 0x7fbd10163518>
```

生成器只运行一次, 之后就会被擦除

```
>>> cc = ((i,j) for i in rows for j in cols if i==j)
>>> list(cc)
[(1, 1), (2, 2), (3, 3), (4, 4)]
>>> list(cc)
[]
```

## 4. 函数

### 4.1 参数

#### 4.1.1 定义

基本形式

```
def 函数名(参数):
	...
```

#### 4.1.2 参数

**位置参数:** 和C语言的一样

```
>>> def func(arg1, arg2):
...     return [arg1, arg2]
... 
>>> func(1, '3')
[1, '3']
```

**关键字参数: **调用时指定参数名字

```
>>> func(arg2=1, arg1='3')
['3', 1]
>>> func(1, arg2=1) 	# 可以和位置参数混合使用
[1, 1]
```

**指定默认参数**

```
>>> def func(arg1, arg2='hb'):
...     return [arg1, arg2]
... 
>>> func(1)
[1, 'hb']
```

**Note:**默认参数在函数定义时就已经计算出来, 不是在程序运行时, 可变数据类型一般不用做默认值, 如果以列表为默认值会出现以下情况

```
>>> def func(arg1, arg2=[]):
...     arg2.append(arg1)
...     print(arg2)
... 
>>> func('a')
['a']
>>> func('b')
['a', 'b']

#可以改为
>>> def func(arg1, arg2=None):
...     if arg2 is None:
...             arg2=[]
...             print("arg2 is none")\
... 
...     arg2.append(arg1)
...     print(arg2)
... 
>>> func('a')
arg2 is none
['a']
>>> func('b')
arg2 is none
['b']
>>> 
```

**用\*收集位置参数**:*并不是指针, *可以将一组可变数量的参数变成元组传入函数(感觉就是指针....)

```
>>> def func(*arg):
...     print('arg:', arg)
... 
>>> func(12,34,'fse')
arg: (12, 34, 'fse')
>>> func()
arg: ()
```

**用\*\*收集关键字参数**: 参数名字是字典的键, 参数值是字典的值

```
>>> func(a=1, b=2, c=33)
arg: {'a': 1, 'b': 2, 'c': 33}
>>> func()
arg: {}
```

#### 4.1.3 文档字符串

在函数体开头部分加入说明字符串, 然后用help(函数名)即可查看函数用法

```
>>> def func():
...     'just test'
... 
>>> help(func)
Help on function func in module __main__:

func()
    just test
    
#只打印字符串
>>> func.__doc__
'just test'
```

#### 4.1.4 内部函数

一个函数如果很长,可以用内部函数拆分, 内部函数可以直接使用外部函数的参数, 相当于外部函数的参数是全局变量,无需传参(闭包:可以由另一个函数动态生成的函数,并且可以改变和存储 函数外创建的变量的值)

基本形式:

```
def outer(a,b):
	def inner(c,d):
		return c+d
	return inner(a,b)
```

```
>>> def outer(str):
...     def inner():
...             return "str=%s" % str
...     return inner
... 
>>> a = outer('wer')
>>> type(a)
<class 'function'>
```

案例1返回的是int型数据, 案例2返回的是函数,也就是闭包, 相当于C的函数指针

#### 4.1.5 匿名函数lambda()

用语句表达的匿名函数,可以用来代替小函数

```
>>> def edit_story(str, func):
...     for word in str:
...             print(func(word))
... 
>>> s=['ff','aa','bb','dd']
>>> edit_story(s, lambda word:word.capitalize() + '!')
Ff!
Aa!
Bb!
Dd!
>>> 
```

以上代码表示lambda函数接收一个word参数, 冒号后面为函数定义

#### 4.1.6 生成器

用来创建python序列的一个对象, 可以用它迭代庞大的序列而不需要在内存中创建和存储整个序列, 3.5中的range就是一个ie生成器.如果用生成器推导代码很长, 可以写一个**生成器函数**

```
#模仿range
>>> def my_range(first=0, last=0, step=1):
...     number=first
...     while number < last:
...             yield number	#生成器函数用yield返回
...             number += step
... 
>>> ranger = my_range(1,5)
>>> ranger
<generator object my_range at 0x7f880ea273b8>
>>> for x in ranger:
...     print(x)
... 
1
2
3
4
```

#### 4.1.7 装饰器

本质是一个函数, 把函数作为输入,并返回另一个函数, 打印函数传参经常用:

```
>>> def doc_it(func):
...     def new_func(*args, **kwargs):
...             print('running func:', func.__name__)
...             print('args:', args)
...             print('kwargs:', kwargs)
...             ret = func(*args, **kwargs)
...             print('result:', ret)
...             return ret
...     return new_func

>>> debug_add = doc_it(add_ints)	#人工对装饰器赋值
>>> debug_add(1,5)
running func: add_ints
args: (1, 5)
kwargs: {}
result: 6
6

#自动赋值
>>> @doc_it
... def add_ints(a,b):
...     return a+b
... 
>>> add_ints(1,5)
running func: add_ints
args: (1, 5)
kwargs: {}
result: 6
6
```

同一个函数可以有多个装饰器, 自动赋值的情况下, 最靠近def的最先执行, 其返回的函数再作为参数传入第二个装饰器, 一次类推

### 4.2 命名空间和作用域

函数外定义的变量在函数内可以读取, 但是如果要读取并改变它的值, 必须要用global声明, 否则函数内部出现和外部一样名字的变量会报错, 因为改变值以为着新定义了一个变量, 这个变量是函数内部的, 

```
#只读取
>>> a='hb'
>>> def func():
...     print(a)
... 
>>> func()
hb

#试图改变, 实际上全局变量并没有改变
>>> def func():
...     a = 'hh'
...     print(a)
... 
>>> func()
hh
>>> 
>>> a
'hb'
>>> 

#加上global即可改变
>>> def func():
...     global a
...     a = 'hh'
...     print(a)
... 
>>> func()
hh
>>> a
'hh'

#试图读取并改变
>>> a='hb'
>>> def func():
...     print(a)
...     a = 'hh'
...     print(a)
... 
>>> func()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 2, in func
UnboundLocalError: local variable 'a' referenced before assignment

```

函数locals()和globals()可以获取局部和全局命名空间中内容的字典

### 4.3 __用法

双下划线开头和结束的变量都是保留用法, 开发者不能用

### 4.4 try和except处理错误

基本形式:

```
try:
	执行语句
except:
	异常处理
```

如果执行语句出错就会执行except的代码

也可以获取异常对象,根据不同异常做不同处理

```
try:
	执行语句
except 异常类型1 as 变量名1
	异常处理1
except 异常类型2 as 变量名2
	异常处理2
...
```

IndexError是由索引一个序列的非法位置抛出的异常, 标准库中还有些其他的定义好的类型

### 4.5 定义自己的异常

异常是一个类, 是Exception的子类, 只需定一个子类, 并用raise关键字触发

```
class my_exception(Exception):
	pass
....
raise my_exception(问题变量) 
```

## 5. 类

### 5.1 定义

基本形式

```
class 类名(父类):
	def __init__(self, ...)
		super.__inif__(...)
		...
	def method(self)	#所有方法必须用self作为第一个参数
		...
```



## 附录

### 1. pip安装

python3.5:

```
sudo apt install python3-pip

pip3 install numpy  
```

### 2. 安装matplotlib

```
git clone https://github.com/matplotlib/matplotlib
cd matplotlib
python3 setup.py build
sudo python3 setup.py install
```

配置:

import matplotlib.pyplot as plt出现错误The Gtk3Agg backend is known to not work on Python 3.x with pycairo, 不解决这个问题图形界面出不来

先在python中执行

```
import matplotlib
matplotlib.matplotlib_fname()
```

显示配置文件matplotlibrc的位置

编辑这个文件 
**把其中的backend : Gtk3Agg改成backend:TkAgg** 
**当然这个前提 是你在机器上装过Tk的库**

或者 
**把其中的backend : Gtk3Agg改成backend:qt5agg** 
这个也是要装点东西的..

qt的界面好看一点