---
  整体目录结构

  rkaiq/
  ├── aiq_core/           # 核心 AIQ 引擎 (C++)
  ├── aiq_core_c/         # AIQ 核心的 C 语言封装
  ├── algos/              # 62+ 个独立算法实现
  ├── algos_camgroup/     # 多摄像头组算法
  ├── hwi_c/              # 硬件接口层 (C)
  │   └── isp39/          # ★ ISP39 (RK3576) 专用实现
  ├── include/            # 公共头文件
  ├── uAPI2/              # 用户 API v2 (当前版本)
  ├── uAPI2_c/            # uAPI2 的 C 封装
  ├── xcore/              # 框架工具 (C++)
  ├── iq_parser_v2/       # 标定文件解析器 (JSON格式)
  ├── ipc/                # 进程间通信
  └── dumpcam_server/     # 诊断服务

---
  核心模块架构

  1. 层次架构图

  ┌─────────────────────────────────────┐
  │        Application (用户程序)         │
  ├─────────────────────────────────────┤
  │   uAPI2 / uAPI2_c (公共用户接口)     │
  ├─────────────────────────────────────┤
  │        RkAiqManager                 │  ← 生命周期管理入口
  │        ├─ RkAiqCore                 │  ← 算法协调引擎
  │        │   ├─ RkAiqHandle (x63)    │  ← 各算法处理器
  │        │   └─ AnalyzeGroupManager  │  ← 并行分组调度
  │        └─ CamHwBase / ISP39        │  ← 硬件抽象层
  ├─────────────────────────────────────┤
  │   aiq_ispParamsCvt (参数转换)        │
  ├─────────────────────────────────────┤
  │   ISP39 硬件 (V4L2 / Kernel)        │
  └─────────────────────────────────────┘

---
  2. 关键模块说明

  RkAiqManager — 主入口

  - 文件：RkAiqManager.h/cpp
  - 职责：初始化、prepare、start/stop、标定DB加载、ISP模式切换（HDR/Normal/Raw）

  RkAiqCore — 算法调度核心

  - 文件：aiq_core/RkAiqCore.h/cpp
  - 职责：统计数据解析 → 驱动全部算法执行 → 输出 RkAiqFullParams

  RkAiqHandle — 算法处理器基类

  prepare() → preProcess() → processing() → postProcess() → genIspResult()
  每个算法（AE/AWB/AF/NR/Sharpness...）都对应一个派生的 Handle。

  RkAiqAnalyzeGroupManager — 分组并行执行

  - 将相关算法分组，各组在独立线程中并行运行
  - 帧级批处理和依赖管理

  ISP39 硬件接口 (hwi_c/isp39/)

  - 文件：aiq_CamHwIsp39.c/h
  - 管理 ISP39 参数更新，支持以下硬件模块：
    - RAWAE0/3 — AE测量
    - RAWHIST0/3 — 直方图
    - RAWAWB — AWB测量
    - RAWAF — AF测量
    - BLS — 黑电平
    - AWB_GAIN — WB增益

---
  3. 数据流（每帧）

  ISP39 硬件产生统计数据
         ↓
  V4L2 stats 设备
         ↓
  RkAiqCore::pushStats()
         ↓
  RkAiqResourceTranslatorV39   ← ★ ISP39专用统计解析
    ├─ translateAecStats()      → AE25 格式
    ├─ translateAwbStats()      → AWB39 格式
    ├─ translateAfStats()       → AF33 格式
    └─ translateBay3dStats()
         ↓
  各算法 Handle 并行执行
         ↓
  RkAiqFullParamsProxy (结果容器)
         ↓
  aiq_ispParamsCvt (算法结果 → isp39_isp_params_cfg)
         ↓
  V4L2 写入 ISP_PARAMS_DEV → 下一帧生效

---
  4. 62+ 算法分类（algos/）

  ┌───────────┬─────────────────────────────────────────┐
  │   类别    │                  算法                   │
  ├───────────┼─────────────────────────────────────────┤
  │ 3A        │ AE, AWB, AF                             │
  ├───────────┼─────────────────────────────────────────┤
  │ Raw域降噪 │ abayertnr v2/v23/v30, abayer2dnr v2/v23 │
  ├───────────┼─────────────────────────────────────────┤
  │ YUV域降噪 │ aynr v1-v24, acnr v1/v2/v30/v31         │
  ├───────────┼─────────────────────────────────────────┤
  │ 锐化      │ asharp v1/v3/v4/v33/v34                 │
  ├───────────┼─────────────────────────────────────────┤
  │ HDR       │ amerge v22/v23, adrc, atmo              │
  ├───────────┼─────────────────────────────────────────┤
  │ 色彩      │ accm, alsc, a3dlut, acac                │
  ├───────────┼─────────────────────────────────────────┤
  │ 去雾      │ adehaze v22/v23/v14                     │
  ├───────────┼─────────────────────────────────────────┤
  │ Gamma     │ agamma, adegamma                        │
  ├───────────┼─────────────────────────────────────────┤
  │ 缺陷矫正  │ adpcc, agic                             │
  ├───────────┼─────────────────────────────────────────┤
  │ 畸变矫正  │ aldc, aldch                             │
  ├───────────┼─────────────────────────────────────────┤
  │ 特殊      │ amd, afd, aeis, aorb, aiisp             │
  └───────────┴─────────────────────────────────────────┘

---
  5. 线程模型

  RkAiqMngCmdThread        — 模式切换命令
  RkAiqCoreThread          — 主分析循环（统计解析 + 算法触发）
  AnalyzeGroupMsgHdlThread — 各算法组独立线程（并行执行）
  RkAiqRstApplyThread      — 结果异步写入硬件

---
  6. ISP39 (RK3576) 关键定位

  ┌───────────────┬───────────────────────────────────────┐
  │    关注点     │               文件路径                │
  ├───────────────┼───────────────────────────────────────┤
  │ ISP39 HW控制  │ hwi_c/isp39/aiq_CamHwIsp39.c          │
  ├───────────────┼───────────────────────────────────────┤
  │ ISP39统计解析 │ aiq_core/RkAiqResourceTranslatorV39.h │
  ├───────────────┼───────────────────────────────────────┤
  │ ISP39参数结构 │ include/common/rk_aiq_types_v39.h     │
  ├───────────────┼───────────────────────────────────────┤
  │ ISP39统计结构 │ include/isp/rk_aiq_isp_stats_v39.h    │
  ├───────────────┼───────────────────────────────────────┤
  │ 参数格式转换  │ hwi_c/aiq_ispParamsCvt.c/h            │
  └───────────────┴───────────────────────────────────────┘

---
  整体架构的核心设计思路：硬件抽象 + 插件化算法 + 分组并行调度 + 双缓冲参数同步，通过 RkAiqHandle 统一的5步执行接口，将62+个算法与ISP硬件解耦，支持多个ISP版本（ISP20/32/33/35/39）共用同一套上层框架。