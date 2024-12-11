# 1. 简介

OpenVX是一个图像和视觉处理库，它是由Khronos Group维护的标准API。OpenVX的目的是提供高性能的硬件加速计算机视觉功能。它提供了一种用于构建和处理图像和视频流的标准界面，使开发人员可以更加容易地利用硬件加速功能。

# 2.对象

## 2.1 框架对象（Framework Object）

- vx_reference：所有的对象都是继承自vx_reference，因此所有的对象都能强转成vx_reference

- vx_context：openvx中最基础的对象，所有数据对象以及所有框架对象都存在于此对象中，此对象必须最先创建

- vx_graph：图对象，一组以有向（仅单向）非循环（不回环）方式连接的节点（vx_node）。图中可能有一组节点与同一图中的其他节点集不相连，图的状态机见[The OpenVX Specification: Object: Graph](https://registry.khronos.org/OpenVX/specs/1.2/html/d9/d7f/group__group__graph.html)

- vx_kernel：内核对象，计算机视觉功能的抽象表示

- vx_node：节点是内核的一个实例，它将与一组特定的引用（参数）配对。节点仅从单个图创建并与其关联。

- vx__parameter：参数对象，传递给计算机视觉函数的抽象输入、输出或双向数据对象。此对象包含来自内核描述的该参数用法的签名，这些信息包括：
  
  - Signature Index - 签名中参数的编号索引
  
  - Object Type - e.g., VX_TYPE_IMAGE or VX_TYPE_ARRAY or some other object type from vx_type_e.
  
  - Usage Model - e.g., VX_INPUT, VX_OUTPUT, or VX_BIDIRECTIONAL.
  
  - Presence State - e.g., VX_PARAMETER_STATE_REQUIRED or VX_PARAMETER_STATE_OPTIONAL.

## 2.2 数据对象（Data Object）

- vx_array：数组对象，存储相同类型的元素，如整数、浮点数等

- vx_object_array：对象数组对象，存储一组OpenVX中的数据对象，如vx_image、vx_matrix等

- vx_image：图片对象

- vx_convolution：卷积对象，用户定义的 MxM 个元素的卷积核

- vx_distribution：分布对象，包含频率分布，如直方图

- vx_lut：查找表对象，查找表是一个数组，它通过用更简单的数组索引操作替换计算来简化运行时计算

- vx_matrix：矩阵对象。某种单位类型的 MxN 矩阵。

- vx_pyramid：金字塔对象，包含一组多级缩放的vx_image

- vx_remap：重映射表对象。重映射表包含输出像素到输入像素的逐像素映射

- vx_scalar：标量对象，包含单一原始数据

- vx_threshold：阈值对象，包含所需阈值的类型和限值

- **vx_user_data_object**：用户数据对象，属于扩展功能，TI用此对象来定制多路相机采集的功能，主要用于配置采集参数（[The OpenVX&#8482; User Data Object Extension](https://registry.khronos.org/OpenVX/extensions/vx_khr_user_data_object/1.0/vx_khr_user_data_object_1_0.html#_vx_user_data_object)）

# 3. Graph

![graph.png](E:\study_record\note\openvx\graph.png)

# 4. 4路相机采集流程

## 4.1 初始化

1. vxCreateContext 创建context对象

2. tivxHwaLoadKernels 加载HWA（Hardware Accelerator）内核到context

3. tivxImagingLoadKernels 加载成像内核到context

4. vxCreateGraph 创建图对象

5. vxCreateImage 按相机宽高和颜色格式创建一个临时image对象

6. vxCreateObjectArray 按临时image对象，创建image对象的数组，一路相机对应一个数组成员，也就是说一个数组有4个image，每路相机3块buffer，因此创建3个数组

7. vxReleaseImage 释放临时image对象

8. tivx_capture_params_init 初始化采集参数，配置好采集参数结构体tivx_capture_params_t 

9. vxCreateUserDataObject 创建采集参数对象，临时使用

10. tivxCaptureNode 利用采集参数对象创建TI的采集节点

11. vxReleaseUserDataObject 释放采集参数对象

12. vxSetNodeTarget 设置运行采集节点的目标硬件，这里是"CAPTURE1"

13. vxGetParameterByIndex 获取采集节点的参数对象，临时使用

14. vxAddParameterToGraph 把节点的参数对象设置给图

15. vxReleaseParameter 释放参数对象

16. tivxSetGraphPipelineDepth 设置流水线深度，流水线概念参考
    
    - [The OpenVX&#8482; Graph Pipelining, Streaming, and Batch Processing Extension to OpenVX 1.1 and 1.2](https://registry.khronos.org/OpenVX/extensions/vx_khr_pipelining/1.0.1/vx_khr_pipelining_1_0_1.html)
    
    - [TIOVX 学习笔记其二：TIVOX_tivxsetnodeparameternumbufbyindex-CSDN博客](https://blog.csdn.net/qq_28087491/article/details/116045115)

17. vxSetGraphScheduleConfig 设置图调度方式（因为启用了流水线）[OpenVX Graph Pipelining Extension: Pipelining and Batch Processing](https://registry.khronos.org/OpenVX/extensions/vx_khr_pipelining/1.0/html/d7/d94/group__group__pipelining.html#ga4a050fb0e974eaf1532e0cef243a7731)

18. vxVerifyGraph 确认图

19. vxGraphParameterEnqueueReadyRef 将image数组对象所有权交给框架，可以理解为入执行队列

## 4.2 采集线程

1. vxGraphParameterDequeueDoneRef 阻塞等待一组帧数据采集完毕，graph处理以image数组为单位，一个image对应一路相机，也就是4路相机都采完才会返回

2. release_rb中获取可用缓存

3. 通过udma把帧数据拷贝到缓存中，详见AppCamera::udma_copy_yuyv

4. vxGraphParameterEnqueueReadyRef 重新入执行队列

官方demo：

```
ti-processor-sdk-rtos-j721s2-evm-10_00_00_05/vision_apps/apps/srv_demos/app_srv_camera/app_srv_camera.c
ti-processor-sdk-rtos-j721s2-evm-10_00_00_05/vision_apps/apps/basic_demos/app_multi_cam/main_linux_arm.c
```

参考：

[TIOVX User Guide: Resources](https://software-dl.ti.com/jacinto7/esd/processor-sdk-rtos-jacinto7/latest/exports/docs/tiovx/docs/user_guide/RESOURCES.html#autotoc_md2)

[GitHub - TexasInstruments/tiovx: TI&#39;s implementation of the OpenVX standard.](https://github.com/TexasInstruments/tiovx?tab=readme-ov-file)

[The OpenVX Specification: Object: Context](https://registry.khronos.org/OpenVX/specs/1.2/html/d1/dc3/group__group__context.html)

[2016 Embedded Vision Summit - The Khronos Group Inc](https://www.khronos.org/events/2016-embedded-vision-summit)
