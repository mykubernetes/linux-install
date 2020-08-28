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

5、mongodb的基础概念
- database  #数据库
- collection  #集合，类似于mysql中的表
- filed   #类似于mysql中字段
- document #每行的记录

6、mongo客户端提供一个正确关闭mongodb服务器的方法
```
> use admin
> db.shutdownServer()
```

7、mongo常用命令
```
> help
> db.help()
> rs.help()
> sh.help() 
> db.collection.find().help()
```

```
> show dbs      列出所有DB
> show databases 列出所有DB
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

8、mongo shell 除了支持交互式的调用方式，执行完后自动退出
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


# echo 'db.serverStatus().opcounters' | mongo 
MongoDB shell version v4.0.20
connecting to: mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("83bebff7-1f28-42f8-a504-a9cfad2f3189") }
MongoDB server version: 4.0.20
{
	"insert" : 0,
	"query" : 10,
	"update" : 0,
	"delete" : 2,
	"getmore" : 0,
	"command" : 209
}
bye

```

使用
```
#插入一个表
> db.studens.insert({name:"tom",age:"23"})
WriteResult({ "nInserted" : 1 })

#查看表
> show collections                                   
studens

#查看数据库
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
test    0.000GB

#查看连接信息
db.studens.stats()
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

#获取所有的表
> db.getCollectionNames()
[ "studens" ]

#插入数据
> db.studens.insert({name:"jerry",age:"40",gender:"M"})
WriteResult({ "nInserted" : 1 })

#查看数据
> db.studens.find()
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }

#查看数据个数
> db.studens.count()
2

#查看所有表数据
> db.studens.find()
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

#查找年龄大于30的
> db.studens.find({age:{$gt: "30"}})
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

#查找年龄小于30的
> db.studens.find({age:{$lt: "30"}})
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
 
#查找年龄是23或40的
> db.studens.find({age:{$in: ["23","40"]}})
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibzhang" }

#查找年龄不是23或40的
> db.studens.find({age:{$nin: ["23","40"]}})
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }

#或关系
> db.studens.find({$or: [{age: {$nin: ["23","40"]}},{age: {$in: ["23","40"]}}]})  
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

#表中的字段是否存在
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


```
> db.studens.find()
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : "23" }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

#更新
> db.studens.update({name: "tom"},{$set: {age: 21}})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

> db.studens.find()
{ "_id" : ObjectId("5f4274d6925a6e6d33fe2872"), "name" : "tom", "age" : 21 }
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }


#删除
> db.studens.remove({age:21})
WriteResult({ "nRemoved" : 1 })

> db.studens.find()
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

```
更新操作  
db.mycoll.update()
- $set: 修改字段的值为新指定的值，语法格式（{filed: value},{$set: {filed: new_value}})
- $unset: 删除指定字段，语法格式（{field: value},{$unset: {field1,filed2,...}}）
- $rename: 更改字段名，语法格式（{$rename: {oldname: newname}}）
- $inc

删除操作
```
有条件删除数据
db.myuser.remove({ name: 'xiaoming' })
db.mycoll.remove({},1)   #数值代码删除符合添加的个数
db.mycoll.remove({})

#删除collection  
db.mycoll.drop()

#删除database
db.dropDatabase()
```

```
> db.studens.find({age: {$in: ["20","40"]}})
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }
> db.studens.find({age: {$in: ["20","40"]}}).count()
3
> db.studens.find({age: {$in: ["20","40"]}}).limit(1)
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
> db.studens.find({age: {$in: ["20","40"]}}).skip(1)
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

> db.studens.find({age: {$gt: "10"}})
{ "_id" : ObjectId("5f427690925a6e6d33fe2873"), "name" : "jerry", "age" : "40", "gender" : "M" }
{ "_id" : ObjectId("5f4277a3925a6e6d33fe2874"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f4277bf925a6e6d33fe2875"), "name" : "Yang Guo", "age" : "20", "Coures" : "Meinv Quan" }
{ "_id" : ObjectId("5f4277c2925a6e6d33fe2876"), "name" : "Ou Yangfeng", "age" : "90", "Coures" : "HaMogong" }
{ "_id" : ObjectId("5f427819925a6e6d33fe2877"), "name" : "Gou Jing", "age" : "40", "Coures" : "Xianglong Shibazhang" }

> db.studens.findOne({age: {$gt: "10"}})
{
	"_id" : ObjectId("5f427690925a6e6d33fe2873"),
	"name" : "jerry",
	"age" : "40",
	"gender" : "M"
}

> db.studens.drop()
true

> show collections

> db.stats()
{
	"db" : "test",
	"collections" : 0,
	"views" : 0,
	"objects" : 0,
	"avgObjSize" : 0,
	"dataSize" : 0,
	"storageSize" : 0,
	"numExtents" : 0,
	"indexes" : 0,
	"indexSize" : 0,
	"fsUsedSize" : 1782595584,
	"fsTotalSize" : 18238930944,
	"ok" : 1
}

> db.dropDatabase()
{ "dropped" : "test", "ok" : 1 }

> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
```
