## 1. 服务器部署

### 1.1 配置以及安装依赖包

```
yum install curl policycoreutils openssh-server openssh-clients -y
yum install libsemanage-static libsemanage-devel
systemctl enable sshd
systemctl start sshd
yum install postfix
systemctl enable postfix
systemctl start postfix
firewall-cmd --permanent --add-service=http
systemctl reload firewalld
```

1.2 添加服务

```
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install gitlab-ce -y
```

### 1.3 安装

​	下载路径:https://packages.gitlab.com/gitlab/gitlab-ce

```
rpm -i gitlab-ce-XXX.rpm
```

### 1.4 配置并启动

```
sudo gitlab-ctl reconfigure
```

### 1.5 登录

​	浏览器输入服务器地址, 第一次登录先设置root帐号密码 rstserver-gitlab



## 2. 修改host地址

​	如果不修改host地址, 创建出来的仓库路径都是localhost

```
vim /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml
```

​	将host:后面的localhost改为服务器地址, 重启

```
gitlab-ctl restart
```

