1、配置yum源
```
# cd /etc/yum.repos.d
# vim mongodb-org-4.0.repo
[mngodb-org]
name=MongoDB Repository
baseurl=http://mirrors.aliyun.com/mongodb/yum/redhat/7Server/mongodb-org/4.0/x86_64/
gpgcheck=0
enabled=1
```

2、安装
```
# yum -y install mongodb-org
```

3、配置
```
# vim /etc/mongod.conf
bindIp: 172.0.0.1  改为 bindIp: 0.0.0.0
```

4、启动
```
systemctl start mongod.service
systemctl enable mongod.service
```

```
> help
> db.help()
> rs.help()
> sh.help() 
> db.collection.find().help()
```

```
> show dbs      列出所有DB
> use dbname    切换当前DB
> show tables   或 show collections  列出当前DB的所有表/集合
> show users    列出当前DB的所有用户
> show profile  列出当前DB的所有慢查询
> show logs     列出运行日志
```

```
> db.serverStatus()                                查看mongod运行状态信息
> db.stats()                                       查看db元数据
> db.mycoll.help()                                 对数据库进行管理和操作的基本命令
> db.collection.stats()                            查看集合元数据
> db.collection.insert() / update / remove / find  对集合增删改查
> db.collection.createIndex()                      创建索引
> db.collection.dropIndex()                        删除索引
> db.dropDatabase()                                删除DB
> db.printReplicationInfo() 
> db.printSlaveReplicationInfo()                   查看复制集同步信息
> rs.status()                                      查看复制集当前状态
> rs.conf()                                        查看复制集配置
> rs.initiate()                                    初始化复制集
> rs.reconfig()                                    重新配置复制集
> rs.add() / rs.remove()                           增加/删除复制集节点  
> sh.enableSharding()                              对DB启用分片
> sh.shardCollection()                             对集合进行分片
> sh.status()                                      查看sharding状态信息
```

mongo shell 除了支持交互式的调用方式，执行完后自动退出
```
# mongo --host localhost:27017 --eval "printjson( db.serverStatus().opcounters )"
MongoDB shell version v4.0.20
connecting to: mongodb://localhost:27017/?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("8dbaa24e-1749-4b71-a227-b6499f6b3897") }
MongoDB server version: 4.0.20
{
	"insert" : 0,
	"query" : 2,
	"update" : 0,
	"delete" : 0,
	"getmore" : 0,
	"command" : 36
}
```

使用
```
> db.studens.insert({name:"tom",age:"23"})           #插入一个表
WriteResult({ "nInserted" : 1 })
> show collections                                   #查看连接
studens
> show dbs                                           #查看数据库
admin   0.000GB
config  0.000GB
local   0.000GB
test    0.000GB
db.studens.stats()                                   #查看连接信息
{
	"ns" : "test.studens",
	"size" : 48,
	"count" : 1,
	"avgObjSize" : 48,
	"storageSize" : 16384,
	"capped" : false,
	"wiredTiger" : {
		"metadata" : {
			"formatVersion" : 1
		},
......

> db.getCollectionNames()
[ "studens" ]

> db.studens.insert({name:"jerry",age:"40",gender:"M"})
WriteResult({ "nInserted" : 1 })

> db.studens.find()                     #查看数据
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }

> db.studens.count()                    #查看数据个数
2


> db.studens.find()
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }


> db.studens.find({age:{$gt: "30"}})
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }
> db.studens.find({age:{$lt: "30"}})
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
> 

> db.studens.find({age:{$in: ["23","40"]}})
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibzhang" }

> db.studens.find({age:{$nin: ["23","40"]}})
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }

> db.studens.find({$or: [{age: {$nin: ["23","40"]}},{age: {$in: ["23","40"]}}]})  
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

> db.studens.find({gender: {$exists: true}})
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }

> db.studens.find({gender: {$exists: false}})
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

```
比较查询
- $gt 大于 语法格式{filed: {$gt: VALUE}}
- $gte 大于等于
- $lt 小于
- $lte 小于等于
- $ne 不等于
- $in 语法格式{filed: {$in: [<value>]}}
- $nin 语法格式{filed: {$nin: [<value>]}}
组合运算符
- $or 或运算，语法格式{$or: [{expression1>},......]}
- $and 与运算
- $not 非运算
- $nor 反运算，返回不符合指定条件的所有文档
元素查询：根据文档中是否存在指定的字段进行查询
- $exists: 语法格式 {$filed: {$exists: <boolean>}}
- $mod:
- $type: 返回指定字段的值的类型为指定类型的文档，语法格式{field: {$type: <BSON type>}}
	double,string,object,array,binary data,undefined,boolean,data,null,regular expression,javascript,timestamp
