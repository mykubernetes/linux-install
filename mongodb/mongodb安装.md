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

5、修改配置文件开启认证权限，最后两行新增认证
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
security:                          #认证
  authorization: enabled           #启用或者禁用基于角色的访问控制来管理每个用户对数据库资源和操作的访问enabled或者disables

6、启动mongodb数据库
# mongo 127.0.0.1:27017 -u admin -p


或者
# mongo 
> db.auth("admin","123456")
```  
- user: 用户名
- pwd: 密码
- roles:
   - role: 角色
   - db: 作用的对象
- role 有多种角色root,redWrite,read，dbAdmin
```
# 数据库用户角色
read：授予User只读数据的权限
readWrite：授予User读写数据的权限

# 数据库管理角色
dbAdmin：在当前dB中执行管理操作
dbOwner：在当前DB中执行任意操作
userAdmin：在当前DB中管理User

# 备份和还原角色
backup
restore

# 跨库角色
readAnyDatabase：授予在所有数据库上读取数据的权限
readWriteAnyDatabase：授予在所有数据库上读写数据的权限
userAdminAnyDatabase：授予在所有数据库上管理User的权限
dbAdminAnyDatabase：授予管理所有数据库的权限

# 集群管理角色
clusterAdmin：授予管理集群的最高权限
clusterManager：授予管理和监控集群的权限，A user with this role can access the config and local databases, which are used in sharding and replication, respectively.
clusterMonitor：授予监控集群的权限，对监控工具具有readonly的权限
hostManager：管理Server

# 超级用户角色
root 

# 内部角色
__system: 提供对数据库中的任何对象执行任何操作的权限
```

mong使用use 后对这个库设置账户即对当前库拥有权限
```
> use applcation                 # 在哪个库下创建用户就该用户就属于哪个库下
switched to db applcation

> db.createUser({user: "applcation",pwd: "123456",roles:[ { role: "readWrite", db:"applcation"}]})
Successfully added user: {
	"user" : "applcation",
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "applcation"
		}
	]
}
> 



客户端远程连接需要加上库名，才可以进入
# mongo 192.168.101.70/applcation -u applcation -p
MongoDB shell version v4.0.20
Enter password: 
connecting to: mongodb://192.168.101.70:27017/app?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("377f5810-d203-4b6e-b1fe-996a3bc3398a") }
MongoDB server version: 4.0.20
>


# 创建app数据库读写权限的用户并对test数据库有读权限
> use app
switched to db app
> db.createUser({user: "apps",pwd: "123456",roles:[ { role: "readWrite", db:"app"},{ role: "read", db: "test"}]})
Successfully added user: {
	"user" : "apps",
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "app"
		},
		{
			"role" : "read",
			"db" : "test"
		}
	]
}
```


```
这个告警需要使用普遍用户启动数据库
WARNING: You are running this process as the root user, which is not
# useradd mongodb
# chown mongodb.mongodb /opt/mongodb -R
# su - mongodb 
$ mongod -f /opt/mongodb/conf/mongodb.conf
```  


自定义角色格式
```
# 自定义角色(对config库所有表可以增删改查,对users库usersCollection表更新,插入,删除,对所有数据库有查找权限)
> use admin
switched to db admin
> db.createRole(
   {
     role: "wuhan123",       # 角色名
     privileges: [
       { resource: { db: "config", collection: "" }, actions: [ "find", "update", "insert", "remove" ] },
       { resource: { db: "users", collection: "usersCollection" }, actions: [ "update", "insert", "remove" ] },
       { resource: { db: "", collection: "" }, actions: [ "find" ] }
     ],
     roles: [
       { role: "read", db: "admin" }
     ]
   }
)
>
```

列出角色和删除角色
```
# 显示当前库所有角色
> db.getRoles()

# 显示单个角色信息(wuhan123是角色名)
> db.getRole("wuhan123")

# 删除角色
> db.dropRole("wuhan123");
true

# 删除所有角色
> db.dropAllRoles();
NumberLong(1)
```


查看用户和添加删除用户
```
# 查看当前数据库所有用户
> db.getUsers(); 

# 查看指定用户
> db.getUser("u_tong"); 

# 删除单个用户
> db.dropUser("u_tong");    
true

# 删除当前库所有用户
> db.dropAllUsers();       
NumberLong(1)
```

将角色授权给用户
```
> db.grantRolesToUser(
   "u_tong",[ "readWrite" , { role: "read", db: "tong" } ],
> )
```
