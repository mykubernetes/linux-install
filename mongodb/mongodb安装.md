官方文档
https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/

安装方式rpm包
===
1.添加 yum 源
```
# vim /etc/yum.repos.d/mongodb-org-3.4.repo
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
```
2.安装
```
# yum install -y mongodb-org

mongodb-org                    x86_64             3.4.22-1.el7             mongodb-org-3.4             5.8 k
mongodb-org-mongos             x86_64             3.4.22-1.el7             mongodb-org-3.4              12 M
mongodb-org-server             x86_64             3.4.22-1.el7             mongodb-org-3.4              20 M
mongodb-org-shell              x86_64             3.4.22-1.el7             mongodb-org-3.4              11 M
mongodb-org-tools              x86_64             3.4.22-1.el7             mongodb-org-3.4              69 M
```  

- mongodb-org #一个名称，将自动安装以下列出的四个组件包
- mongodb-org-mongos #数据分片
- mongodb-org-server #服务端包
- mongodb-org-shell #客户端包
- mongodb-org-tools #备份导入导出包


Mongodb 二进制包安装
===
官网下载地址：https://www.mongodb.com/download-center?jmp=nav#production  

1、下载安装  
```
# wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.4.6.tgz
# tar -zxvf mongodb-linux-x86_64-rhel70-3.4.6.tgz -C /home/mdb/
# mv mongodb-linux-x86_64-rhel70-3.4.6 mongodb
# cd mongodb
# mkdir conf data logs pid
```  

2、配置环境变量  
```
# vim /etc/profile
PATH=$PATH:/opt/mongodb/bin

# source /etc/profile
```  

3、配置mondodb  
```
# vim mongodb/conf/mongodb.conf
systemLog:
  destination: file                # Mongodb 日志输出的目的地，指定一个 file 或者 syslog，如果指定 file，必须指定 systemlog.path
  logAppend: true                  #当实例重启时，不创建新的日志文件，在老的日志文件末尾继续添加
  path: /opt/mongodb/logs/mongodb.log    #日志路径

storage:
  dbPath: /opt/mongodb/data        #数据存储目录
  journal:                         #回滚日志
    enabled: true
  directoryPerDB: true             #默认 false，不适用 inmemory engine
  wiredTiger:
     engineConfig:
        cacheSizeGB: 1             #将用于所有数据缓存的最大小
        directoryForIndexes: true  #默认false 索引集合storage.dbPath存储在数据单独子目录

processManagement:                 #使用处理系统守护进程的控制处理
  fork: true                       # fork and run in background  后台运行
  pidFilePath: /opt/mongodb/pid/mongod.pid     # location of pidfile 创建 pid 文件

net:
  port: 27017                      #监听端口
  bindIp: 127.0.0.1,192.168.101.70     #绑定 ip
#replication:
#   oplogSizeMB: 1024              #复制操作日志的大小
#   replSetName: goumin            #副本集名称，同一个副本集的所有主机必须设置相同的名称
```  

所有配置选项  https://docs.mongodb.com/manual/reference/configuration-options/  

4、启动mongodb  
```
# mongod -f /opt/mongodb/conf/mongodb.conf 
about to fork child process, waiting until server is ready for connections.
forked process: 12951
child process started successfully, parent exiting
```  

5、启动mongodb发现有四个WARNING  
```
# mongo 192.168.101.70:27017
MongoDB shell version v3.4.6
connecting to: 192.168.101.70:27017
MongoDB server version: 3.4.6
Server has startup warnings: 
2019-08-03T01:08:26.745-0400 I CONTROL  [initandlisten] 
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] ** WARNING: Access control is not enabled for the database.
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] **          Read and write access to data and configuration is unrestricted.
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] ** WARNING: You are running this process as the root user, which is not recommended.
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] 
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] 
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] ** WARNING: /sys/kernel/mm/transparent_hugepage/enabled is 'always'.
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] **        We suggest setting it to 'never'
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] 
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] ** WARNING: /sys/kernel/mm/transparent_hugepage/defrag is 'always'.
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] **        We suggest setting it to 'never'
2019-08-03T01:08:26.746-0400 I CONTROL  [initandlisten] 
> 
```  

解决办法
```
下面两个WARNING告警解决办法
WARNING: /sys/kernel/mm/transparent_hugepage/enabled is 'always'.
WARNING: /sys/kernel/mm/transparent_hugepage/defrag is 'always'.

# cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never
# cat /sys/kernel/mm/transparent_hugepage/defrag
[always] madvise never


1、运行以下命令即时禁用THP
# echo never > /sys/kernel/mm/transparent_hugepage/enabled
# echo never > /sys/kernel/mm/transparent_hugepage/defrag

2、编辑rc.local 文件：
# chmod +x /etc/rc.d/rc.local
# vim /etc/rc.d/rc.local
# echo never > /sys/kernel/mm/transparent_hugepage/enabled
# echo never > /sys/kernel/mm/transparent_hugepage/defrag


3、使用127.0.0.1身份登录mongodb关闭服务器并重启
# mongo 127.0.0.1:27017
> use admin
switched to db admin
> db.shutdownServer()

4、重新启动
# mongod -f /opt/mongodb/conf/mongodb.conf
```  


```
WARNING告警解决办法
WARNING: Access control is not enabled for the database.

1、连接mongodb数据库
# mongo 192.168.101.70:27017

2、创建用户权限
> db.createUser({user: "admin",pwd: "123456",roles:[ { role: "root", db:"admin"}]})

3、查看用户权限
> db.getUsers()

4、重启mongodb数据库
# mongo 127.0.0.1:27017
> use admin
switched to db admin
> db.shutdownServer()

5、启动mongodb数据库
# mongo 127.0.0.1:27017 -u admin -p
```  

```
这个告警需要使用普遍用户启动数据库
WARNING: You are running this process as the root user, which is not
# useradd mongodb
# chown mongodb.mongodb /opt/mongodb -R
# su - mongodb 
$ mongod -f /opt/mongodb/conf/mongodb.conf
```  
