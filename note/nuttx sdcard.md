# Nuttx SD Card

## 初始化:

nsh_archinitialize->sdio_initialize(返回sdio_dev_s, 一个dev对应一个sdio设备)->mmcsd_slotinitialize(绑定sdio设备到实体sd插槽)



## 结构体

struct sdio_dev_s 描述一个sdio设备的通用部分,包含各种函数指针, 让mmcsd模块调用

struct zynq_dev_s 包含struct sdio_dev_s, 可以看作是struct sdio_dev_s的子类,继承所有函数指针,加上一些zynq平台特有的变量, 由于struct sdio_dev_s是第一个成员,所以实际上,sdio_dev的指针可以强转成zynq_dev, 类似多态