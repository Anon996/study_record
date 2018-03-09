# Git

## 一、本地git操作

### 1.创建仓库

```
git init
```

### 2.上传内容 

```
git add .
git commit -m"log内容"
```

### 3.查看log 

```
git log
```

### 4.建立git中心仓库：

```
git clone --bare [刚才创建仓库的路径]
```

生成*.git文件，这步过后，之前的仓库文件就可以删除了,去任意路径

```
git clone .git
```

即可. 修改代码后上传，步骤和2一样，但最后一定要

```
git push
```

不然不会同步到仓库！！！

### 5.删除仓库中的文件

手动rm

```
git status 查看当前删除的文件:
git add -A 
git commit -m"..."
```

### 6.排除某些文件

在home目录下建立.gitignoreglogal文件，输入要忽略的文件如*.o等，执行

```
git config --global core.excludesfile .gitignoreglobal
```

**ps: 如果加了*.d, 又不想屏蔽init.d,加入!init.d即可**

### 7.git无法上传空目录



### 8.用beyond compare对比代码

配置：

```
git config --global diff.tool bc3
git config --global difftool.bc3 trustExitCode true
git config --global merge.tool bc3
git config --global mergetool.bc3 trustExitCode true
```

  使用：

```
git difftool -d --no-symlinks&
```

 此命令将改动的文件统一拷贝到临时目录，用bc进行文件夹对比，no-symlinks代表拷贝原文件而不是软连接

 若要bc支持软连接对比，要点Rules->Handling->Follow symbolic links,并选择also update session defaults 

### 9.git只导一个分支：

```
git clone -b master --single-branch https://github.com/Xilinx/linux-xlnx.git
```

git导uboot：

git clone git://github.com/Xilinx/u-boot-xlnx.git

### 10.合并冲突

先将本地修改存储起来

```
git stash
```

这样本地的所有修改就都被暂时存储起来 。是用git stash list可以看到保存的信息：

![Screenshot from 2017-03-13 13-20-37](/home/steven/Pictures/Screenshot from 2017-03-13 13-20-37.png)

其中stash@{0}就是刚才保存的标记。

暂存了本地修改之后，就可以pull了。

```
git pull
```

还原暂存的内容

```
git stash pop
```

系统提示如下类似的信息：

```
Auto-merging c/environ.c
CONFLICT (content): Merge conflict in c/environ.c
```

解决文件中冲突的的部分

![022cc01c-8c27-4739-b48c-9afc9067835d](/home/steven/Pictures/022cc01c-8c27-4739-b48c-9afc9067835d.png)

其中Updated upstream 和=====之间的内容就是pull下来的内容，====和stashed changes之间的内容就是本地修改的内容。碰到这种情况，git也不知道哪行内容是需要的，所以要自行确定需要的内容。

### 11.修改log

如果git commit的时候log写错了，用

```
git commit --amend
```

即可修改，前提是没有push

### 12.更新log

```
git remote update;git log origin
```

### 13.列出改动的文件

```
git log --stat 
```

### 14.对比某次提交的改动

  ```
git difftool HEAD~1 HEAD -d
  ```

### 15.查看是否有其他人push代码到服务器

同步服务器数据库

```
git fetch origin
```

然后出现如下打印:

[本地最新版本号]..[服务器最新版本号]  master     -> origin/master

```
git log [服务器最新版本号]
```

即可查看其他人上传的log

### 16.查看已经add(暂存)过的文件改动:

```
git diff --staged
```

### 17.删除文件

```
git rm
```

### 18.移动文件    

```
git mv file_from file_to
```

其实，运行 git mv 就相当于运行了下面三条命令： 

```
$ mv README.txt README
$ git rm README.txt
$ git add README
```

### 19.取消已暂存的文件

```
git reset HEAD ...
```

此命令可以恢复被删除但为提交的文件

### 20.修改最后一次提交

如果刚才提交时忘了暂存某些修改，可以先补上暂存操作，然后再运行 --amend 提交, amend会打开message让你修改：

```
$ git commit -m 'initial commit'
$ git add forgotten_file
$ git commit --amend
```

上面的三条命令最终只是产生一个提交，第二个提交命令修正了第一个的提交内容。

### 21.查看当前的远程库

```
 git remote
```

会列出每个远程库的简短名字。在克隆完某个项目后，至少可以看到一个名为 origin 的远程库，Git 默认使用这个名字来标识你所克隆的原始仓库

### 22.从远程仓库获取数据

```
git fetch  origin
```

  抓取从你上次克隆以来别人上传到此远程仓库中的所有更新（或是上次 fetch 以来别人提交的更新）

```
git log master..origin/master
```

查看别人上传的log

### 23.删除未跟踪文件

```
# 删除 untracked files
git clean -f
 
# 连 untracked 的目录也一起删掉
git clean -fd
 
# 连 gitignore 的untrack 文件/目录也一起删掉 （慎用，一般这个是用来删掉编译出来的 .o之类的文件用的）
git clean -xfd
 
# 在用上述 git clean 前，墙裂建议加上 -n 参数来先看看会删掉哪些文件，防止重要文件被误删
git clean -nxfd
git clean -nf
git clean -nfd
```

### 24. 修改远程仓库地址

```
git remote set-url origin [url]
```

或先删后加

```
git remote rm origin
git remote add origin [url]
```

或直接修改config

### 25. 现有工程变成GIT

```
cd existing_folder
git init
git remote add origin http://192.168.0.11/phenix-lite-develops/ardupilot/ardupilot-3.5.3.git
git add .
git commit -m "Initial commit"
git push -u origin master
```

### 26. subtree

以映射rstcan头文件到phenix-lite-slave工程为例

```
cd rstcan
#prefix - 要映射的头文件路径
#branch - 要创建的分支名
git subtree split --prefix=include/apis --branch=apis
```

以上命令以后git会创建一个只有头文件的分支:

```
steven@steven-XPS-13-9350:~/Steven/Develop/refactoring/can/rstcan$ git log
commit c65dedb861fdcc63484e6f11fd6a38af2bf0f587
Author: HeBin <bin.he@robsense.com>
Date:   Tue Dec 12 16:29:11 2017 +0800

    1.api相关头文件放到单独文件夹,作为branch给使用模块作为submodule
steven@steven-XPS-13-9350:~/Steven/Develop/refactoring/can/rstcan$ git branch 
* apis
  master

```

cd到phenix-lite-slave工程

```
#增加rstcan的git路径
git remote add apis http://192.168.0.11/phenix-lite-develops/rstcan-develop/rstcan.git
#prefix - 要存放头文件的路径
#第一个apis remote中add的apis的名字
#第二个apis 分支名
git subtree add --prefix=include/apis apis apis
```

在phenix-lite-slave修改头文件上传:

```
git subtree push --prefix=include/apis apis hotfix/apis   在rstcan中建立一个hotfix/apis分支,等待维护者合并
```

维护者合并头文件

```
git merge --squash -s subtree [分支名]		在apis分支
git subtree merge --prefix=include/apis/ HEAD  在master分支
```



在phenix-lite-slave更新头文件

```
git subtree pull --prefix=include/apis apis apis
```



### 27. makefile生成git_version.c用于git版本打印

```
#
# Get a version string provided by git
# This assumes that git command is available and that
# the directory holding this file also contains .git directory
#
GIT_DESC := $(shell git log -1 --pretty=format:%H)
ifneq ($(words $(GIT_DESC)),1)
    GIT_DESC := "unknown_git_version"
endif

GIT_DESC_SHORT := $(shell echo $(GIT_DESC) | cut -c1-16)

$(shell mkdir -p $(OUT_PATH))
$(shell rm -f $(OUT_PATH)git_version.*)
$(shell echo "#include <git_version.h>" > $(OUT_PATH)git_version.c)
$(shell echo "const char* rstcan_git_version = \"$(GIT_DESC)\";" >> $(OUT_PATH)git_version.c)
$(shell echo "const uint64_t rstcan_git_version_binary = 0x$(GIT_DESC_SHORT);" >> $(OUT_PATH)git_version.c)


```



### 28. 一个分支替换master

```
git checkout master // 切换到旧的分支
git reset --hard develop // 将本地的旧分支 master 重置成 develop
git push origin master --force // 再推送到远程仓库
```



## 二 Github

### 1. 大文件

github最大单个文件大小限制在100M, 超过100M要用lfs(Large File Storage)托管

下载

```
https://git-lfs.github.com/
```

解压, 安装:

```
git lfs install
```

添加文件:

```
git lfs track amp_system/linux_image/ubuntu-core-16.04-robsense.tar.bz2
```

创建attributes:

```
git add .gitattributes
```

查看:

```
steven@steven-XPS-13-9350:~/Steven/Develop/xilinx/PhenixPro_Devkit$ git status
On branch develop
Your branch is ahead of 'origin/develop' by 1 commit.
  (use "git push" to publish your local commits)
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   .gitattributes

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   amp_system/linux_image/ubuntu-core-16.04-robsense.tar.bz2
```

commit, push:

```
git add amp_system/linux_image/ubuntu-core-16.04-robsense.tar.bz2
git commit -m "manage big file with lfs"
git push
```

问题:

重复提交, 打开GIT_TRACE:

```
 GIT_TRACE=1 git push
14:38:13.584290 git.c:344               trace: built-in: git 'push'
14:38:13.585336 run-command.c:334       trace: run_command: 'ssh' 'git@github.com' 'git-receive-pack '\''/RobSenseTech/PhenixPro_Devkit'\'''
14:38:17.192869 run-command.c:334       trace: run_command: '.git/hooks/pre-push' 'origin' 'ssh://git@github.com/RobSenseTech/PhenixPro_Devkit'
14:38:17.195711 git.c:561               trace: exec: 'git-lfs' 'pre-push' 'origin' 'ssh://git@github.com/RobSenseTech/PhenixPro_Devkit'
14:38:17.195767 run-command.c:334       trace: run_command: 'git-lfs' 'pre-push' 'origin' 'ssh://git@github.com/RobSenseTech/PhenixPro_Devkit'
trace git-lfs: run_command: 'git' config -l
trace git-lfs: run_command: 'git' version
trace git-lfs: tq: running as batched queue, batch size of 100
trace git-lfs: run_command: ssh -- git@github.com git-lfs-authenticate RobSenseTech/PhenixPro_Devkit upload
trace git-lfs: HTTP: POST https://lfs.github.com/RobSenseTech/PhenixPro_Devkit/locks/verify
trace git-lfs: HTTP: 200
trace git-lfs: HTTP: {"ours":[],"theirs":[],"next_cursor":""}

trace git-lfs: pre-push: refs/heads/develop 41cada29c70a1e8971675cac8247e1f2f246d001 refs/heads/develop 521e2472943c679670e56205a5427e6fa6e7381f
trace git-lfs: run_command: git rev-list --objects 41cada29c70a1e8971675cac8247e1f2f246d001 --not --remotes=origin --
trace git-lfs: run_command: git cat-file --batch-check
trace git-lfs: run_command: git cat-file --batch
trace git-lfs: tq: sending batch of size 1
trace git-lfs: run_command: ssh -- git@github.com git-lfs-authenticate RobSenseTech/PhenixPro_Devkit upload
trace git-lfs: api: batch 1 files
trace git-lfs: HTTP: POST https://lfs.github.com/RobSenseTech/PhenixPro_Devkit/objects/batch
trace git-lfs: HTTP: 200
trace git-lfs: HTTP: {"objects":[{"oid":"cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a","size":184973517,"actions":{"upload":{"href":"https://github-cloud.s3.amazonaws.com/alambic/media/145040091/cf/00/cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a?actor_id=17840499","header":{"Authorization":"AWS4-HMAC-SHA256 Credential=AKIAIMWPLRQEC4XCWWPA/20170627/us-east-1/s3/aws4_request,SignedHeaders=host;x-amz-content-sha256;x-amz-date,Signature=1c0c33d094914c58061eaf58df6a3696b4270c670fb2d58eeeef349d
trace git-lfs: HTTP: fe35903f","x-amz-content-sha256":"cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a","x-amz-date":"20170627T063826Z"},"expires_at":"2017-06-27T06:53:26Z","expires_in":900},"verify":{"href":"https://lfs.github.com/RobSenseTech/PhenixPro_Devkit/objects/cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a/verify","header":{"Authorization":"RemoteAuth ARA5cyhbZv7uGLucouWil6W8Z0lvrHMhks5ZU07iwA==","Accept":"application/vnd.git-lfs+json"}}}}]}
trace git-lfs: tq: starting transfer adapter "basic"
Git LFS: (0 of 1 files) 0 B / 176.40 MB                                                                                                                                                                           trace git-lfs: HTTP: PUT https://github-cloud.s3.amazonaws.com/alambic/media/145040091/cf/00/cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a
Git LFS: (0 of 1 files) 176.40 MB / 176.40 MB                                                                                                                                                                     trace git-lfs: tq: retrying object cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a: LFS: Put https://github-cloud.s3.amazonaws.com/alambic/media/145040091/cf/00/cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a?actor_id=17840499: read tcp 127.0.0.1:52110->127.0.0.1:37793: i/o timeout
trace git-lfs: tq: enqueue retry #1 for "cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a" (size: 184973517)
trace git-lfs: tq: sending batch of size 1
trace git-lfs: run_command: ssh -- git@github.com git-lfs-authenticate RobSenseTech/PhenixPro_Devkit upload
trace git-lfs: api: batch 1 files
trace git-lfs: HTTP: POST https://lfs.github.com/RobSenseTech/PhenixPro_Devkit/objects/batch
trace git-lfs: HTTP: 200
trace git-lfs: HTTP: {"objects":[{"oid":"cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a","size":184973517,"actions":{"upload":{"href":"https://github-cloud.s3.amazonaws.com/alambic/media/145040091/cf/00/cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a?actor_id=17840499","header":{"Authorization":"AWS4-HMAC-SHA256 Credential=AKIAIMWPLRQEC4XCWWPA/20170627/us-east-1/s3/aws4_request,SignedHeaders=host;x-amz-content-sha256;x-amz-date,Signature=fe1b99b38da25b3e9176e72dd49624581252bda3135b0d7677665f6e
trace git-lfs: HTTP: b56f15fe","x-amz-content-sha256":"cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a","x-amz-date":"20170627T064421Z"},"expires_at":"2017-06-27T06:59:21Z","expires_in":900},"verify":{"href":"https://lfs.github.com/RobSenseTech/PhenixPro_Devkit/objects/cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a/verify","header":{"Authorization":"RemoteAuth ARA5cwrnJajnjUEV4--HswJWXB2I_UMbks5ZU1BFwA==","Accept":"application/vnd.git-lfs+json"}}}}]}
trace git-lfs: tq: starting transfer adapter "basic"
Git LFS: (0 of 1 files) 0 B / 176.40 MB                                                                                                                                                                           trace git-lfs: HTTP: PUT https://github-cloud.s3.amazonaws.com/alambic/media/145040091/cf/00/cf0097d7d4698da1fe11c77101a0104c694fd382ff1a0243ae59f0561ce0798a
Git LFS: (0 of 1 files) 123.59 MB / 176.40 MB                                                                        
```

发现:

```
read tcp 127.0.0.1:52110->127.0.0.1:37793: i/o timeout
```

换个网络....

### 2. 暂存密码

用http传github lfs的时候, 传几个文件就要输几次用户名和密码, 用一下命令暂存1小时密码, 默认是15分钟:

```
git config --global credential.helper 'cache --timeout=3600'
```

### 3. rebase

获取fork后的代码:

```
git clone https://github.com/hebin1124/ardupilot
```

链接当前仓库到上游仓库:

```
git remote add upstream https://github.com/ArduPilot/ardupilot.git
```

获取上游仓库的最新改动:

```
git fetch upstream
```

rebase当前自己仓库的改动:

```
git rebase upstream/master
```

整理提交历史:

```
git rebase -i
git rebase -i HEAD~2		rebase前2个提交, 最上面的是最早的提交，最下面的是最近一次提交。
```

push最终改动

```
git push --force
```

PS: ardupilot的Tools/gittools/目录下的git-subsystems-split可以自动生成符合要求的提交和提交log, 先把所有改动一起commit, 然后执行这个就可以按ardupilot的要求拆分commit和log

### 4. submodule版本

添加submodule参考

https://git-scm.com/book/en/v2/Git-Tools-Submodules

reset:

```
git reset master -- sub
git reset master@{upstream} -- sub
git reset HEAD -- sub
git reset MERGE_HEAD -- sub
```

或者直接到submodule的目录下,

```
git checkout 版本号
```

clone:

```
git submodule init
git submodule update --init --recursive
```



###5. Connection refused

使用Github pull 代码突然报错：

Failed to connect to 127.0.0.1 port 43421: Connection refused

使用 lsof 发现端口未被占用：lsof -i:45463



查看代理：env|grep -i proxy

```
NO_PROXY=localhost,127.0.0.0/8,::1 
http_proxy=http://127.0.0.1:45463/ 
HTTPS_PROXY=http://127.0.0.1:45463/ 
https_proxy=http://127.0.0.1:45463/ 
no_proxy=localhost,127.0.0.0/8,::1 
HTTP_PROXY=http://127.0.0.1:45463/
```

原因：使用代理导致访问失败

解决方法：(取消代理使用)

```
 export http_proxy=""
 export https_proxy=""
 export HTTP_PROXY=""
 export HTTPS_PROXY=""
```