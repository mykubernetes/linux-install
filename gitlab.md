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
gitlab-rake              # 数据备份恢复等数据操作

gitlab-ctl start         # 启动所有 gitlab 组件
gitlab-ctl stop          # 停止所有 gitlab 组件
gitlab-ctl restart       # 重启所有 gitlab 组件
gitlab-ctl status        # 查看服务状态

gitlab-ctl reconfigure   # 启动服务
gitlab-ctl show-config   # 验证配置文件

gitlab-ctl tail          # 查看日志
gitlab-ctl tail nginx    # 查看nginx日志

gitlab-rake gitlab:check SANITIZE=true --trace    # 检查gitlab
```

## 数据备份恢复

### 备份

1、设置数据保存路径及保存时间
```
# vim /etc/gitlab/gitlab.rb
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"      # 备份保存的位置，这里是默认位置，可修改成指定的位置
gitlab_rails['backup_archive_permissions'] = 0644		       # 备份文件的默认权限
gitlab_rails['backup_keep_time'] = 604800                    # 设置备份保存的时间，超过此时间的日志将会被新覆盖,默认保存7天

# 特别注意：
#     如果自定义了备份保存位置，则要修改备份目录的权限，比如：
#     chown -R git.git /data/backup/gitlab
```

配置完成后要重启以使配置生效
```
# 重读配置文件
# gitlab-ctl reconfigure  
......
......
......
Running handlers:
Running handlers complete
Chef Client finished, 9/730 resources updated in 46 seconds
gitlab Reconfigured!

# 重启gitlab
gitlab-ctl restart
```

2、停止gitlab 数据服务
```
# 停止数据写入服务
# gitlab-ctl stop unicorn
ok: down: unicorn: ls, normally up

# gitlab-ctl stop sidekiq
ok: down: sidekiq: 0s, normally up
```

3、手动备份数据
```
# gitlab-rake gitlab:backup:create    #在任意目录即可备份当前gitlab数据
# gitlab-ctl start                    #备份完成后启动gitlab
```

```
# ll /var/opt/gitlab/backups/                        # 查看备份目录
total 0

# gitlab-rake gitlab:backup:create                   # 备份数据
2019-11-27 16:12:08 +0800 -- Dumping database ... 
Dumping PostgreSQL database gitlabhq_production ... [DONE]
2019-11-27 16:12:10 +0800 -- done
2019-11-27 16:12:10 +0800 -- Dumping repositories ...
2019-11-27 16:12:10 +0800 -- done
2019-11-27 16:12:10 +0800 -- Dumping uploads ... 
2019-11-27 16:12:10 +0800 -- done
2019-11-27 16:12:10 +0800 -- Dumping builds ... 
2019-11-27 16:12:10 +0800 -- done
2019-11-27 16:12:10 +0800 -- Dumping artifacts ... 
2019-11-27 16:12:10 +0800 -- done
2019-11-27 16:12:10 +0800 -- Dumping pages ... 
2019-11-27 16:12:10 +0800 -- done
2019-11-27 16:12:10 +0800 -- Dumping lfs objects ... 
2019-11-27 16:12:10 +0800 -- done
2019-11-27 16:12:10 +0800 -- Dumping container registry images ... 
2019-11-27 16:12:10 +0800 -- [DISABLED]
Creating backup archive: 1574842330_2019_11_27_12.5.0_gitlab_backup.tar ... done
Uploading backup archive to remote storage  ... skipped
Deleting tmp directories ... done
done
done
done
done
done
done
done
Deleting old backups ... done. (0 removed)
Warning: Your gitlab.rb and gitlab-secrets.json files contain sensitive data 
and are not included in this backup. You will need these files to restore a backup.
Please back them up manually.
Backup task is done.

# ll /var/opt/gitlab/backups/                           # 查看备份目录
total 172
-rw-r--r-- 1 git git 174080 Nov 27 16:12 1574842330_2019_11_27_12.5.0_gitlab_backup.tar
```

4、备份时间的识别
```
# 备份后的文件类似这样的形式：1574842330_2019_11_27_12.5.0_gitlab_backup.tar，可以根据前面的时间戳确认备份生成的时间
data  -d  @1574842330
```

5、查看恢复的文件
```
/var/opt/gitlab/backups/          #gitlab数据备份目录，需要使用命令备份
/var/opt/gitlab/nginx/conf        #nginx配置文件
/etc/gitlab/gitlab.rb             #gitlab配置文件
/etc/gitlab/gitlab-secrets.json   #key文件
```

6、备份到云存储
```
涉及的配置项如下：
   393  # gitlab_rails['backup_upload_connection'] = {
   394  #   'provider' => 'AWS',
   395  #   'region' => 'eu-west-1',
   396  #   'aws_access_key_id' => 'AKIAKIAKI',
   397  #   'aws_secret_access_key' => 'secret123'
   398  # }
   399  # gitlab_rails['backup_upload_remote_directory'] = 'my.s3.bucket'
   400  # gitlab_rails['backup_multipart_chunk_size'] = 104857600
```

7、设置定时任务
```
# 每天凌晨2点定时创建备份
# 将一下内容写入到定时任务中 crontab -e
0 2 * * * /usr/bin/gitlab-rake gitlab:backup:create

# 备份策略建议：
#     本地保留3到7天，在异地备份永久保存
```



### 还原

1、查看备份文件
```
# cat /etc/gitlab/gitlab.rb |grep "backup_path" |grep -Ev "^$"         # 确认备份目录
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"

# ll /var/opt/gitlab/backups/                                          # 确认备份文件
total 172
-rw-r--r-- 1 git git 174080 Nov 27 16:12 1574842330_2019_11_27_12.5.0_gitlab_backup.tar
```
特别注意：
- 备份目录和gitlab.rb中定义的备份目录必须一致
- GitLab的版本和备份文件中的版本必须一致，否则还原时会报错。

2、停止gitlab 数据服务
```
# 停止数据写入服务
# gitlab-ctl stop unicorn
ok: down: unicorn: ls, normally up

# gitlab-ctl stop sidekiq
ok: down: sidekiq: 0s, normally up

# gitlab-rake gitlab:backup:restore BACKUP=备份文件名
```

3、开始恢复
```
# gitlab-rake gitlab:backup:restore BACKUP=1574842330_2019_11_27_12.5.0       # 还原
Unpacking backup ... done
Before restoring the database, we will remove all existing
tables to avoid future upgrade problems. Be aware that if you have
custom tables in the GitLab database these tables and all data will be
removed.

Do you want to continue (yes/no)? yes
Removing all tables. Press `Ctrl-C` within 5 seconds to abort
2019-11-27 16:40:03 +0800 -- Cleaning the database ... 
2019-11-27 16:40:05 +0800 -- done
2019-11-27 16:40:05 +0800 -- Restoring database ... 
......
......
......
[DONE]
2019-11-27 16:40:19 +0800 -- done
2019-11-27 16:40:19 +0800 -- Restoring repositories ...
2019-11-27 16:40:19 +0800 -- done
2019-11-27 16:40:19 +0800 -- Restoring uploads ... 
2019-11-27 16:40:19 +0800 -- done
2019-11-27 16:40:19 +0800 -- Restoring builds ... 
2019-11-27 16:40:19 +0800 -- done
2019-11-27 16:40:19 +0800 -- Restoring artifacts ... 
2019-11-27 16:40:19 +0800 -- done
2019-11-27 16:40:19 +0800 -- Restoring pages ... 
2019-11-27 16:40:19 +0800 -- done
2019-11-27 16:40:19 +0800 -- Restoring lfs objects ... 
2019-11-27 16:40:19 +0800 -- done
This task will now rebuild the authorized_keys file.
You will lose any data stored in the authorized_keys file.
Do you want to continue (yes/no)? yes

Deleting tmp directories ... done
done
done
done
done
done
done
done
Warning: Your gitlab.rb and gitlab-secrets.json files contain sensitive data 
and are not included in this backup. You will need to restore these files manually.
Restore task is done.


# gitlab-ctl restart                                          # 重启服务
ok: run: alertmanager: (pid 26150) 1s
ok: run: gitaly: (pid 26163) 0s
ok: run: gitlab-exporter: (pid 26182) 1s
ok: run: gitlab-workhorse: (pid 26184) 0s
ok: run: grafana: (pid 26204) 1s
ok: run: logrotate: (pid 26216) 0s
ok: run: nginx: (pid 26223) 1s
ok: run: node-exporter: (pid 26229) 0s
ok: run: postgres-exporter: (pid 26235) 0s
ok: run: postgresql: (pid 26321) 1s
ok: run: prometheus: (pid 26330) 0s
ok: run: redis: (pid 26341) 1s
ok: run: redis-exporter: (pid 26345) 0s
ok: run: sidekiq: (pid 26353) 0s
ok: run: unicorn: (pid 26364) 0s




# gitlab-rake gitlab:check SANITZE=true  # 检查GitLab所有组件是否运行正常
Checking GitLab subtasks ...

Checking GitLab Shell ...

GitLab Shell: ... GitLab Shell version >= 10.2.0 ? ... OK (10.2.0)
Running /opt/gitlab/embedded/service/gitlab-shell/bin/check
Internal API available: OK
Redis available via internal API: OK
gitlab-shell self-check successful

Checking GitLab Shell ... Finished

Checking Gitaly ...

Gitaly: ... default ... OK

Checking Gitaly ... Finished

Checking Sidekiq ...

Sidekiq: ... Running? ... yes
Number of Sidekiq processes ... 1

Checking Sidekiq ... Finished

Checking Incoming Email ...

Incoming Email: ... Reply by email is disabled in config/gitlab.yml

Checking Incoming Email ... Finished

Checking LDAP ...

LDAP: ... LDAP is disabled in config/gitlab.yml

Checking LDAP ... Finished

Checking GitLab App ...

Git configured correctly? ... yes
Database config exists? ... yes
All migrations up? ... yes
Database contains orphaned GroupMembers? ... no
GitLab config exists? ... yes
GitLab config up to date? ... yes
Log directory writable? ... yes
Tmp directory writable? ... yes
Uploads directory exists? ... yes
Uploads directory has correct permissions? ... yes
Uploads directory tmp has correct permissions? ... yes
Init script exists? ... skipped (omnibus-gitlab has no init script)
Init script up-to-date? ... skipped (omnibus-gitlab has no init script)
Projects have namespace: ... can't check, you have no projects
Redis version >= 2.8.0? ... yes
Ruby version >= 2.5.3 ? ... yes (2.6.3)
Git version >= 2.22.0 ? ... yes (2.22.0)
Git user has default SSH configuration? ... yes
Active users: ... 3
Is authorized keys file accessible? ... yes

Checking GitLab App ... Finished


Checking GitLab subtasks ... Finished
```









参考：
- https://www.cnblogs.com/hgzero/p/14088215.html
