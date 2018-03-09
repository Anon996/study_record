## 1. 安装matplotlib

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

## 2. 常用类

### 2.1 Figure, Subplot和AxesSubplot

matplotlib的图像全部位于Figure类中, 一个Figure可以包含多个Subplot类, Subplot代表一块图像, 一个Subplot包含一个AxesSubplot类, AxesSubplot代表坐标轴

创建一个Figure:

```
import matplotlib.pyplot as plt
fig=plt.figure()
```

向Figure添加一个Subplot

```
ax=fig.add_subplot(2,2,1)	#添加一个2*2大小的图像, 编号为1, 返回AxesSubplot实例
```

也可以默认参数快速创建:

```
fig, ax = plt.subplots()	#创建一个Figure,并添加一个Subplot, 返回Figure和AxesSubplot的实例
```

subplots函数原型:

```
subplots(nrows=1, ncols=1, sharex=False, sharey=False, squeeze=True, subplot_kw=None, gridspec_kw=None, **fig_kw)

nrows,ncols: 整型, 默认为1, 创建nrows*ncols个subplot
sharex, sharey: bool型或者{'none', 'all', 'row', 'col'}, 控制x,y轴是否在各个subplot中共享,如果x共享,只					有最后一行subplot的x轴会显示,y轴共享,只有第一列的y轴会显示
				- True 或 'all': x或y轴在所有subplot中共享
				- False 或 'none': 不共享
				- 'row': 每行的subplot共享一个x或y轴
				- 'col': 每列的subplot共享一个x或y
squeeze: bool型,
		 -True: 如果只有一个subplot创建,则只返回一个
		 		如果有N*1或1*M个创建, 返回AxesSubplot的一维numpy数组
		 		如果N*M个, 返回AxesSubplot的二维numpy数组
		 -False: 所有情况都返回AxesSubplot的二维numpy数组
subplot_kw: 字典, 传给fig.add_subplot方法的参数
gridspec_kw: 字典, 传给matplotlib.gridspec.GridSpec的构造函数
**fig_kw: 传给plt.figure函数的关键字参数
```

## 3. 绘图

### 3.1 绘图函数

创建好Figure和Subplot后, 调用顶层函数

```
plt.plot(x, y, '-') 	#x, y可以是numpy的数组, '-'是线的类型
```

即可对**最后一个用过的**subplot上绘制

如果要对特定的Subplot绘制, 则用add_subplot或subplots返回的AxesSubplot实例中的plot方法, 参数和顶层的plot方法一样

### 3.2. 刻度

```
ticks = ax.set_xticks([0, 250, 500, 750, 1000])
labels = ax.set_xticklabels(['one', 'two', 'three', 'four', 5])
```

set_xticks只接收数字序列(本质是浮点), 同时改变x轴的画图范围, 例如ax.set_xlim(0, 10), 再调用ax.set_xticks([0, 250, 500, 750, 1000]), 最终画的图有1000个点而不是10个

set_xticklabels可接收字符串和数字, 只改变x轴刻度的字符串, 不改变范围

y轴一样, 把方法名中的x改为y即可

### 3.3 标题, 轴标签

```
ax.set_title('HB')		#标题, 位置在最上方居中
ax.set_xlabel('xlabel')	#x轴标题, 位置在x轴下方居中
```

### 3.4 图例

要添加图例, 在调用plot时, 必须要指定label参数的值, 不然不会出现图例

```
line1 = ax.plot(np.random.sample(1000), label='one')
ax.legend(loc='best')
```

loc参数指定图例的位置:

```
            ===============   =============
            Location String   Location Code
            ===============   =============
            'best'            0
            'upper right'     1
            'upper left'      2
            'lower left'      3
            'lower right'     4
            'right'           5
            'center left'     6
            'center right'    7
            'lower center'    8
            'upper center'    9
            'center'          10
            ===============   =============
best会自动放在最不碍事的位置
```

