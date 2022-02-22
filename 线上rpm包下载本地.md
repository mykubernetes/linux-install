# 一、简介

通常生产环境由于安全原因都无法访问互联网。此时就需要进行离线安装，主要有两种方式：源码编译、rpm包安装。源码编译耗费时间长且缺乏编译环境，所以一般都选择使用离线 rpm 包安装。

# 二、工具准备

**安装yum-utils**

这个软件包中有许多关于rpm包的工具
- repotrack(全量下载一个软件的依赖包)
- yumdownloader（下载软件的依赖包，如果本机已经安装不下载）
- reposync（下载一个yum仓库中所有包）

```
yum -y install yum-utils
```

**安装createrepo**

- 这个软件可以利用目录中的rpm包生成一个repodata目录

# 三、实现步骤
```
[11:14:13 root@centos7 ~]#mkdir ansible
[11:14:43 root@centos7 ~]#cd ansible
#下载ansible所有依赖包
[11:14:25 root@centos7 ansible]#repotrack ansible
#查看
[11:15:26 root@centos7 ansible]#ls | wc -l
88
#生成repodata元数据信息目录
[11:15:35 root@centos7 ansible]#createrepo .
[11:16:01 root@centos7 ansible]#ls repodata/
110b7aac253936a5b971189db5441cd4dbec6c720d6fd5410f72b094fc680fb3-filelists.xml.gz
6e538dbaa7a5995aca8d49de2223ed6222b2fef2759d30d409310f18e4d54c24-primary.sqlite.bz2
8ccec094ea873d8278961c73500765402a460b7f4b5854b9c2994c79c16ecd6c-filelists.sqlite.bz2
ca3d224dcaa4b08f02977d374527d62f27ced4807ec248634438c45af2ff981f-other.sqlite.bz2
e49d0aa81391cbe4dd2ca7397731e3fff50e216a9ce5a7132212e7155fcfb7cc-other.xml.gz
f5e3d782d30ba1618959b775d481deea2ec3bde0dea66758e00ecb218f3b5073-primary.xml.gz
repomd.xml

#在yum配置中配置新的仓库
[11:17:47 root@centos7 ansible]#cat /etc/yum.repos.d/ansible.repo
[ansible]
name=ansible
baseurl=file:///root/ansible
gpgcheck=0
#验证
[11:17:56 root@centos7 ansible]#yum repolist

#安装软件
[11:20:44 root@centos7 yum.repos.d]#yum install ansible
```
