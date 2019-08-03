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

2、配置mondodb  
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
  bindIp: 127.0.0.1,10.0.0.201     #绑定 ip
#replication:
#   oplogSizeMB: 1024              #复制操作日志的大小
#   replSetName: goumin            #副本集名称，同一个副本集的所有主机必须设置相同的名称
```  
