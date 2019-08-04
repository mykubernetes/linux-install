
集群规划  
```
主机名       服务        IP地址
node01    mongodb    192.168.101.69
node02    mongodb    192.168.101.70
node03    mongodb    192.168.101.71
```  

所有节点分别执行此操作
---

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
  bindIp: 127.0.0.1,192.168.101.69     #绑定 ip   IP需要更改
replication:
   oplogSizeMB: 1024              #复制操作日志的大小
   replSetName: goumin            #副本集名称，同一个副本集的所有主机必须设置相同的名称   此名称需要一致
```  

分别启动每台服务器的mongodb  
---
```
[root@node01 ~]# mongod -f /opt/mongodb/conf/mongodb.conf
[root@node02 ~]# mongod -f /opt/mongodb/conf/mongodb.conf
[root@node03 ~]# mongod -f /opt/mongodb/conf/mongodb.conf

分别查看进程是否启动
# ps -ef |grep mongodb
root       3061      1  1 04:33 ?        00:00:02 mongod -f /opt/mongodb/conf/mongodb.conf

连接测试
# mongo 192.168.101.69:27017
# mongo 192.168.101.70:27017
# mongo 192.168.101.71:27017
```  

将mongodb服务器加入集群  
```
1、登录任意节点执行命令写入配置
config = {
_id : "goumin",
members : [
{_id : 0, host : "192.168.101.69:27017"},
{_id : 1, host : "192.168.101.70:27017"},
{_id : 2, host : "192.168.101.71:27017"},
] }

输出结果为执行成功
> config = {
... _id : "goumin",
... members : [
... {_id : 0, host : "192.168.101.69:27017"},
... {_id : 1, host : "192.168.101.70:27017"},
... {_id : 2, host : "192.168.101.71:27017"},
... ] }
{
	"_id" : "goumin",
	"members" : [
		{
			"_id" : 0,
			"host" : "192.168.101.69:27017"
		},
		{
			"_id" : 1,
			"host" : "192.168.101.70:27017"
		},
		{
			"_id" : 2,
			"host" : "192.168.101.71:27017"
		}
	]
}

2、成功后执行初始化配置
rs.initiate(config)

执行后结果
> rs.initiate(config)
{ "ok" : 1 }
goumin:OTHER> 
goumin:SECONDARY>
```  

查看状态  
```
goumin:PRIMARY> rs.status()
{
	"set" : "goumin",
	"date" : ISODate("2019-08-03T09:11:26.908Z"),
	"myState" : 1,
	"term" : NumberLong(1),
	"heartbeatIntervalMillis" : NumberLong(2000),
	"optimes" : {
		"lastCommittedOpTime" : {
			"ts" : Timestamp(1564823485, 1),
			"t" : NumberLong(1)
		},
		"appliedOpTime" : {
			"ts" : Timestamp(1564823485, 1),
			"t" : NumberLong(1)
		},
		"durableOpTime" : {
			"ts" : Timestamp(1564823485, 1),
			"t" : NumberLong(1)
		}
	},
	"members" : [
		{
			"_id" : 0,
			"name" : "192.168.101.69:27017",
			"health" : 1,
			"state" : 1,
			"stateStr" : "PRIMARY",
			"uptime" : 281,
			"optime" : {
				"ts" : Timestamp(1564823485, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2019-08-03T09:11:25Z"),
			"electionTime" : Timestamp(1564823364, 1),
			"electionDate" : ISODate("2019-08-03T09:09:24Z"),
			"configVersion" : 1,
			"self" : true
		},
		{
			"_id" : 1,
			"name" : "192.168.101.70:27017",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 133,
			"optime" : {
				"ts" : Timestamp(1564823485, 1),
				"t" : NumberLong(1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1564823485, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2019-08-03T09:11:25Z"),
			"optimeDurableDate" : ISODate("2019-08-03T09:11:25Z"),
			"lastHeartbeat" : ISODate("2019-08-03T09:11:26.813Z"),
			"lastHeartbeatRecv" : ISODate("2019-08-03T09:11:26.575Z"),
			"pingMs" : NumberLong(0),
			"syncingTo" : "192.168.101.69:27017",
			"configVersion" : 1
		},
		{
			"_id" : 2,
			"name" : "192.168.101.71:27017",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 133,
			"optime" : {
				"ts" : Timestamp(1564823485, 1),
				"t" : NumberLong(1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1564823485, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2019-08-03T09:11:25Z"),
			"optimeDurableDate" : ISODate("2019-08-03T09:11:25Z"),
			"lastHeartbeat" : ISODate("2019-08-03T09:11:26.816Z"),
			"lastHeartbeatRecv" : ISODate("2019-08-03T09:11:26.712Z"),
			"pingMs" : NumberLong(0),
			"syncingTo" : "192.168.101.69:27017",
			"configVersion" : 1
		}
	],
	"ok" : 1
}
```  

在主节点测试，从节点不支持写入查询  
```
1、写入命令
db.inventory.insertMany( [
    { "item": "journal", "qty": 25, "size": { "h": 14, "w": 21, "uom": "cm" }, "status": "A" },
    { "item": "notebook", "qty": 50, "size": { "h": 8.5, "w": 11, "uom": "in" }, "status": "A" },
    { "item": "paper", "qty": 100, "size": { "h": 8.5, "w": 11, "uom": "in" }, "status": "D" },
    { "item": "planner", "qty": 75, "size": { "h": 22.85, "w": 30, "uom": "cm" }, "status": "D" },
    { "item": "postcard", "qty": 45, "size": { "h": 10, "w": 15.25, "uom": "cm" }, "status": "A" }
]);

执行结果
goumin:PRIMARY> db.inventory.insertMany( [
... { "item": "journal", "qty": 25, "size": { "h": 14, "w": 21, "uom": "cm" }, "status": "A" },
... { "item": "notebook", "qty": 50, "size": { "h": 8.5, "w": 11, "uom": "in" }, "status": "A" },
... { "item": "paper", "qty": 100, "size": { "h": 8.5, "w": 11, "uom": "in" }, "status": "D" },
... { "item": "planner", "qty": 75, "size": { "h": 22.85, "w": 30, "uom": "cm" }, "status": "D" },
... { "item": "postcard", "qty": 45, "size": { "h": 10, "w": 15.25, "uom": "cm" }, "status": "A" }
... ]);
{
	"acknowledged" : true,
	"insertedIds" : [
		ObjectId("5d4550b20f9d40fb6fb14750"),
		ObjectId("5d4550b20f9d40fb6fb14751"),
		ObjectId("5d4550b20f9d40fb6fb14752"),
		ObjectId("5d4550b20f9d40fb6fb14753"),
		ObjectId("5d4550b20f9d40fb6fb14754")
	]
}


2、查询表
goumin:PRIMARY> show tables
inventory


3、查询
goumin:PRIMARY> db.inventory.find()
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14750"), "item" : "journal", "qty" : 25, "size" : { "h" : 14, "w" : 21, "uom" : "cm" }, "status" : "A" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14751"), "item" : "notebook", "qty" : 50, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "A" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14752"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "D" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14753"), "item" : "planner", "qty" : 75, "size" : { "h" : 22.85, "w" : 30, "uom" : "cm" }, "status" : "D" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14754"), "item" : "postcard", "qty" : 45, "size" : { "h" : 10, "w" : 15.25, "uom" : "cm" }, "status" : "A" }

4、在从节点设置可读，才可查询，查询只对当前有效，退出无效
goumin:SECONDARY> rs.slaveOk();
goumin:SECONDARY> db.inventory.find()
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14754"), "item" : "postcard", "qty" : 45, "size" : { "h" : 10, "w" : 15.25, "uom" : "cm" }, "status" : "A" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14752"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "D" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14750"), "item" : "journal", "qty" : 25, "size" : { "h" : 14, "w" : 21, "uom" : "cm" }, "status" : "A" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14751"), "item" : "notebook", "qty" : 50, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "A" }
{ "_id" : ObjectId("5d4550b20f9d40fb6fb14753"), "item" : "planner", "qty" : 75, "size" : { "h" : 22.85, "w" : 30, "uom" : "cm" }, "status" : "D" }
```  

获取配置  
```
goumin:PRIMARY> rs.config()
{
	"_id" : "goumin",
	"version" : 1,
	"protocolVersion" : NumberLong(1),
	"members" : [
		{
			"_id" : 0,
			"host" : "192.168.101.69:27017",
			"arbiterOnly" : false,
			"buildIndexes" : true,
			"hidden" : false,
			"priority" : 1,
			"tags" : {
				
			},
			"slaveDelay" : NumberLong(0),
			"votes" : 1
		},
		{
			"_id" : 1,
			"host" : "192.168.101.70:27017",
			"arbiterOnly" : false,
			"buildIndexes" : true,
			"hidden" : false,
			"priority" : 1,
			"tags" : {
				
			},
			"slaveDelay" : NumberLong(0),
			"votes" : 1
		},
		{
			"_id" : 2,
			"host" : "192.168.101.71:27017",
			"arbiterOnly" : false,
			"buildIndexes" : true,
			"hidden" : false,
			"priority" : 1,
			"tags" : {
				
			},
			"slaveDelay" : NumberLong(0),
			"votes" : 1
		}
	],
	"settings" : {
		"chainingAllowed" : true,
		"heartbeatIntervalMillis" : 2000,
		"heartbeatTimeoutSecs" : 10,
		"electionTimeoutMillis" : 10000,
		"catchUpTimeoutMillis" : 60000,
		"getLastErrorModes" : {
			
		},
		"getLastErrorDefaults" : {
			"w" : 1,
			"wtimeout" : 0
		},
		"replicaSetId" : ObjectId("5d454f39d421fc2cd51418ce")
	}
}
```  

查看slave的延时情况  
```
rs.printSlaveReplicationInfo()
```  

调整权重  
```
goumin:PRIMARY> config.members[0].priority=90
90
goumin:PRIMARY> rs.reconfig(config)
{ "ok" : 1 }
```  

主节点主动降级  
```
goumin:PRIMARY> rs.stepDown()
```  
 
增加新节点  
首先部署新节点，和上边安装一样  
```
goumin:PRIMARY> use admin
goumin:PRIMARY> rs.add("192.168.101.72:27017")
```  
 
删除旧节点  
```
goumin:PRIMARY> rs.remove("192.168.101.72:27017")
{ "ok" : 1 }

角色状态为OTHER时可以关闭
goumin:OTHER>

# mongo localhost:7017
goumin:OTHER> use admin
switched to db admin
goumin:OTHER> db.shutdownServer()

mongo localhost:28010
```  

增加仲裁节点  
Arbiter 节点只参与投票，不能被选为 Primary，并且不从 Primary 同步数据。  
```  
rs.addArb("192.168.101.72:27017")

查看集群状态
goumin:PRIMARY> rs.status()
```  
