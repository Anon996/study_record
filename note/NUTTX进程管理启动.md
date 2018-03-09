# NUTTX进程管理启动

标签（空格分隔）： 未分类

---

                    os_start(本身就是idle进程)
                        |
        创建idle进程的tcb,其task函数为os_start
                        |
                dq_addfirst加入readytorun链表
                        |
                fs_initialize初始化文件系统
                        |
        group_setupidlefiles设置idle进程的filelist
                        |
                os_bringup启动init进程
                        |
                    idle死循环


