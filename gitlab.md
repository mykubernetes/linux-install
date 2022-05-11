# Gitlab的安装及使用

## 1. Gitlab概述

### 1.1 GitLab介绍
GitLab是利用Ruby on Rails一个开源的版本管理系统，实现一个自托管的Git项目仓库，可通过Web界面进行访问公开的或者私人项目。

GitLab能够浏览源代码，管理缺陷和注释。可以管理团队对仓库的访问，它非常易于浏览提交过的版本并提供一个文件历史库。团队成员可以利用内置的简单聊天程序(Wall)进行交流。

它还提供一个代码片段收集功能可以轻松实现代码复用，便于日后有需要的时候进行查找

### 1.2 Gitlab服务构成
- Nginx：静态web服务器。
- gitlab-shell：用于处理Git命令和修改authorized keys列表。
- gitlab-workhorse: 轻量级的反向代理服务器。
- logrotate：日志文件管理工具。
- postgresql：数据库。
- redis：缓存数据库。
- sidekiq：用于在后台执行队列任务（异步执行）。
- unicorn：An HTTP server for Rack applications，GitLab Rails应用是托管在这个服务器上面的。


## 2. Gitlab的安装部署

Gitlab要求服务器内存2G以上

### 2.1 方式一:下载gitlab-ce的rpm包

- 安装包下载地址：https://packages.gitlab.com/gitlab/gitlab-ce
- rpm 包国内下载地址： https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/
- ubuntu 国内下载地址： https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu/pool/

将对应版本的gitlab-ce下载到本地后，直接yum安装即可
```
# 要先将这个rpm包下载到本地
yum install -y gitlab-ce-13.6.1-ce.0.el7.x86_64.rpm
```

### 2.2 方式二:配置yum源

```
# 1、在 /etc/yum.repos.d/ 下新建 gitlab-ce.repo，写入如下内容：
[gitlab-ce]
name=gitlab-ce
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/
Repo_gpgcheck=0
Enabled=1
Gpgkey=https://packages.gitlab.com/gpg.key

# 2、然后创建cache，再直接安装gitlab-ce

# 这一步会创建大量的数据
yum makecache  

# 直接安装最新版
yum install -y gitlab-ce                

# 如果要安装指定的版本，在后面填上版本号即可
yum install -y  gitlab-ce-13.6.1

# 如果安装时出现gpgkey验证错误，只需在安装时明确指明不进行gpgkey验证
yum install gitlab-ce -y --nogpgcheck
```

### 2.3 gitlab的配置

配置文件位置  /etc/gitlab/gitlab.rb
```
[root@centos7 test]# vim /etc/gitlab/gitlab.rb
[root@centos7 test]# grep "^[a-Z]" /etc/gitlab/gitlab.rb
external_url 'http://10.0.0.51'                            # 这里一定要加上http://
```

# 配置邮件服务
```
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.qq.com"
gitlab_rails['smtp_port'] = 25
gitlab_rails['smtp_user_name'] = "hgzerowzh@qq.com"        # 自己的qq邮箱账号
gitlab_rails['smtp_password'] = "xxx"                      # 开通smtp时返回的授权码
gitlab_rails['smtp_domain'] = "qq.com"
gitlab_rails['smtp_authentication'] = "login"   
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['gitlab_email_from'] = "hgzerowzh@qq.com"     # 指定发送邮件的邮箱地址
user["git_user_email"] = "shit@qq.com"                     # 指定接收邮件的邮箱地址
```

修改好配置文件后，要使用 gitlab-ctl reconfigure 命令重载一下配置文件，否则不生效。
```
gitlab-ctl reconfigure # 重载配置文件
```

### 2.4 gitlab相关的目录
```
/etc/gitlab       # 配置文件目录
/run/gitlab       # 运行pid目录
/opt/gitlab       # 安装目录
/var/opt/gitlab   # 数据目录，存储gitlab数据目录
/var/log/gitlab    # 日志目录
```


### 2.5 Gitlab常用命令
```
gitlab-ctl start         # 启动所有 gitlab 组件
gitlab-ctl stop          # 停止所有 gitlab 组件
gitlab-ctl restart       # 重启所有 gitlab 组件
gitlab-ctl status        # 查看服务状态

gitlab-ctl reconfigure   # 启动服务
gitlab-ctl show-config   # 验证配置文件

gitlab-ctl tail          # 查看日志

gitlab-rake gitlab:check SANITIZE=true --trace    # 检查gitlab
```







参考：
- https://www.cnblogs.com/hgzero/p/14088215.html
