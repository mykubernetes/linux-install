官方文档  
https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/  

1、下载文件  
```
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-server-4.0.5-1.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-shell-4.0.5-1.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-tools-4.0.5-1.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-mongos-4.0.5-1.el7.x86_64.rpm
```  
- mongodb-org-4.0.5-1.el7.x86_64.rpm
- mongodb-org-mongos-4.0.5-1.el7.x86_64.rpm #数据分片
- mongodb-org-server-4.0.5-1.el7.x86_64.rpm #服务端包
- mongodb-org-shell-4.0.5-1.el7.x86_64.rpm #客户端包
- mongodb-org-tools-4.0.5-1.el7.x86_64.rpm #备份导入导出包

2、安装  
```
yum install -y mongodb-org-server-4.0.5-1.el7.x86_64.rpm mongodb-org-shell-4.0.5-1.el7.x86_64.rpm mongodb-org-tools-4.0.5-1.el7.x86_64.rpm
```  

3、修改配置文件  
```
vim /etc/mongod.conf
systemLog:
  destination: file                  #Mongodb 日志输出的目的地，指定一个 file 或者 syslog，如果指定 file，必须指定 systemlog.path
  logAppend: true                    #当实例重启时，不创建新的日志文件，在老的日志文件末尾继续添加
  path: /opt/mongodb/logs/mongodb.log    #日志路径

storage:
  dbPath: /data/mongodb              #数据存储目录
  journal:                           #回滚日志
    enabled: true
  directoryPerDB: true               #默认 false，不适用 inmemory engine
  wiredTiger:
     engineConfig:
        cacheSizeGB: 1               #将用于所有数据缓存的最大小
        directoryForIndexes: true    #默认false 索引集合storage.dbPath存储在数据单独子目录

processManagement:                   # 使用处理系统守护进程的控制处理
  fork: true                         # fork and run in background  后台运行
  pidFilePath: /opt/mongodb/pid/mongod.pid     # location of pidfile 创建 pid 文件

net:
  port: 27017                        #监听端口
  bindIp: 127.0.0.1,10.0.0.201       #绑定 ip
#replication:
#   oplogSizeMB: 1024                #复制操作日志的大小
#   replSetName: goumin              #副本集名称，同一个副本集的所有主机必须设置相同的名称
```  

4、连接数据库及常用命令  
```
mongo --host 192.168.101.69
> show dbs     # 查看数据库
admin   0.000GB
config  0.000GB
local   0.000GB
> use testdb   #无需创建直接使用，延时创建
> db.help()
> db.stats()  数据库状态 
> db.serverStatus() 数据库服务状态
> show collection 查看库的集合
> db.getCollectionNames()
```  
