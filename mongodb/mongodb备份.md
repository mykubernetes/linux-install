mongoexport和mongoimport
===

跨版本备份，支持json和csv两种格式
---
mongoexport 
| 参数 | 参数说明 |
|------|---------|
| -h | 指明数据库宿主机的IP |
| -u | 指明数据库的用户名 |
| -p | 指明数据库的密码 |
| -d | 指明数据库的名字 |
| -c | 指明collection的名字 |
| -f | 指明要导出那些列 |
| -o | 指明到要导出的文件名 |
| -q | 指明导出数据的过滤条件 |
| --type  指定文件类型 |
| --authenticationDatabase | 验证数据的名称 |

备份
```
备份json格式
mongoexport -uroot -p12456 -c log --authenticationatabase admin -o /mongob/bakup/log.json

备份csv格式
mongoexport -uroot -p12456 -c log --type=csv -f uid,name,date --authenticationatabase admin -o /mongob/bakup/log.csv
```

mongoimport
| 参数 | 参数说明 |
|------|------------|
| -h | 指明数据库宿主机的IP |
| -u | 指明数据库的用户名 |
| -p | 指明数据库的密码 |
| -d | 指明数据库的名字 |
| -c | 指明collection的名字 |
| -f | 指明要导出那些列 |
| -o | 指明到要导出的文件名 |
| -q | 指明导出数据的过滤条件 |
| --drop | 插入之前先删除原有的 |
| --headerline | 指明第一行是列名，不需要导入。 |
| -j, --numInsertionWorker=<number> | 同时运行的插入操作数（默认为1），并行 |
| --authenticationDatabase | 验证数据的名称


还原
```
导入json格式
mongoimport -uroot -p12456 -c test --authenticationatabase admin /mongob/bakup/log.json

导入csv格式，跳过头一行 --headerline
mongoimport -uroot -p12456 -c test --type --headerline --authenticationatabase admin /mongob/bakup/log.csv

导入csv格式，自定义表面
mongoimport -uroot -p12456 -c test --type -f uid,name,age,date --authenticationatabase admin /mongob/bakup/log.csv
```


把mysql数据导入到mongodb

备份mysql数据为csv格式,默认空格为分隔符，改为指定逗号分隔
```
select user,host,password from mysql.user
into outfile '/tmp/user.csv'                 # 导出文件位置
fields terminated by ','                     # 字段间以,号分隔
optionally enclosed by '"'                   # 字段用"号括起
escaped by '"'                               # 字段中使用的转义符为"
lines terminated by '\r\n';                  # 行以\r\n结束


mongoimport -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin -d app -c user -f user,host,password  --type=csv --file /tmp/user.csv
```



mongob备份bson格式
---
mongodump数据库的备份，备份所有库 

mongodump的参数与mongoexport的参数基本一致
| 参数 | 参数说明 |
|-----|----------|
| -h | 指明数据库宿主机的IP |
| -u | 指明数据库的用户名 |
| -p | 指明数据库的密码 |
| -d | 指明数据库的名字 |
| -c | 指明collection的名字 |
| -o | 指明到要导出的文件名 |
| -q | 指明导出数据的过滤条件 |
| -j | 并发 |
| --authenticationDatabase | 验证数据的名称 |
| --gzip | 备份时压缩 |
| --oplog | 备份的同时备份oplog |


1、全库备份
```
mongodump -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin  -o /home/mongod/backup/full
```

2、备份test库
```
mongodump -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin  -d test -o /home/mongod/backup/
```

3、备份test库下的vast集合
```
mongodump -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin  -d test -c vast -o /home/mongod/backup/
```

4、压缩备份库
```
mongodump -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin  -d test -o /home/mongod/backup/ --gzip
```

5、压缩备份单表
```
mongodump -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin  -d test -c vast -o /home/mongod/backup/ --gzip
```


mongorestore数据库的恢复

mongorestore与mongoimport参数类似 

| 参数 | 参数说明 |
|------|---------|
| -h | 指明数据库宿主机的IP |
| -u | 指明数据库的用户名 |
| -p | 指明数据库的密码 |
| -d | 指明数据库的名字 |
| -c | 指明collection的名字 |
| -o | 指明到要导出的文件名 |
| -q | 指明导出数据的过滤条件 |
| --authenticationDatabase | 验证数据的名称 |
| --gzip | --gzip格式备份的还原也需要加此参数 |
| --oplog | use oplog for taking a point-in-time snapshot |
| --drop | 恢复的时候把之前的集合drop掉（慎用） |

1、全库备份中恢复单库（基于之前的全库备份）
```
mongorestore -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin -d test --drop  /home/mongod/backup/full/test/
```

2、恢复test库
```
mongorestore -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin -d test /home/mongod/backup/test/
```

3、恢复test库下的vast集合
```
mongorestore -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin -d test -c vast /home/mongod/backup/test/vast.bson
```

4、--drop参数实践恢复
```
# 恢复单库
mongorestore -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin -d test --drop /home/mongod/backup/test/
# 恢复单表
mongorestore -h 10.0.0.152:27017 -uroot -proot --authenticationDatabase admin -d test -c vast --drop /home/mongod/backup/test/vast.bson
```


全量恢复加oplog恢复
---
- MongoDB 的Replication是通过一个日志来存储写操作的，这个日志就叫做oplog。
- 在默认情况下,oplog分配的是5%的空闲磁盘空间。通常而言,这是一种合理的设置。可以通过mongod --oplogSize来改变oplog的日志大小。

oplog相关的参数

| 参数| 参数说明 |
|-----|---------|
| --oplogReplay | 重放oplog.bson中的操作内容 |
| --oplogLimit | 与--oplogReplay一起使用时，可以限制重放到的时间点 |

```
1、全量备份,然后删除库
mongodump --port27017 --oplog -o /monggodb/backup/

2、查看删除数据库操作时间戳
use local
db.oplog.rs.find("op":"d").pretty()

2、备份oplog日志
mongodump --port 27017 -d local -c oplog.rs -o /monggodb/backup/

3、把日志拷贝到之前全备份库中,并重命名
cp /monggodb/backup/oplog.rs.bson ../oplog.bson

4、删除local库
cd ..
rm -rf local/

5、恢复
mongorestore --port 27017 --oplogReplay --oplogLimit "1563957100:3" --drop /monggodb/backup/DB_NAME/
```


模拟一个不断有插入操作的集合foo，
```
use clsn
for(var i = 0; i < 10000; i++) {
    db.clsn.insert({a: i});
}
```

【模拟】mongodump使用
---
1、然后在插入过程中模拟一次mongodump并指定--oplog。
```
$ mongodump -h 10.0.0.152 --port 28021  --oplog  -o /home/mongod/backup/oplog
```
注意：--oplog选项只对全库导出有效，所以不能指定-d选项。因为整个实例的变更操作都会集中在local库中的oplog.rs集合中。

从dump开始的时间系统将记录所有的oplog到oplog.bson中，所以得到这些文件：
```
$ ll /home/mongod/backup/oplog 
total 8
drwxrwxr-x 2 mongod mongod   4096 Jan  8 16:49 admin
drwxrwxr-x 2 mongod mongod   4096 Jan  8 16:49 clsn
-rw-rw-r-- 1 mongod mongod  77256 Jan  8 16:49 oplog.bson
```

2、查看oplog.bson中第一条和最后一条内容
```
$ bsondump oplog.bson  >/tmp/oplog.bson.tmp

$ head -1 /tmp/oplog.bson.tmp 
{"ts":{"$timestamp":{"t":1515401553,"i":666}},"t":{"$numberLong":"5"},"h":{"$numberLong":"5737315465472464503"},"v":2,"op":"i","ns":"clsn.clsn1","o":{"_id":{"$oid":"5a533151cc075bd0aa461327"},"a":3153.0}}

$ tail -1 /tmp/oplog.bson.tmp 
{"ts":{"$timestamp":{"t":1515401556,"i":34}},"t":{"$numberLong":"5"},"h":{"$numberLong":"-7438621314956315593"},"v":2,"op":"i","ns":"clsn.clsn1","o":{"_id":{"$oid":"5a533154cc075bd0aa4615de"},"a":3848.0}}
```
最终dump出的数据既不是最开始的状态，也不是最后的状态，而是中间某个随机状态。这正是因为集合不断变化造成的。

3、使用mongorestore来恢复
```
[mongod@MongoDB oplog]$ mongorestore -h 10.0.0.152 --port 28021  --oplogReplay  --drop   /home/mongod/backup/oplog
2018-01-08T16:59:18.053+0800    building a list of dbs and collections to restore from /home/mongod/backup/oplog dir
2018-01-08T16:59:18.066+0800    reading metadata for clsn.clsn from /home/mongod/backup/oplog/clsn/clsn.metadata.json
2018-01-08T16:59:18.157+0800    restoring clsn.clsn from /home/mongod/backup/oplog/clsn/clsn.bson
2018-01-08T16:59:18.178+0800    reading metadata for clsn.clsn1 from /home/mongod/backup/oplog/clsn/clsn1.metadata.json
2018-01-08T16:59:18.216+0800    restoring clsn.clsn1 from /home/mongod/backup/oplog/clsn/clsn1.bson
2018-01-08T16:59:18.669+0800    restoring indexes for collection clsn.clsn1 from metadata
2018-01-08T16:59:18.679+0800    finished restoring clsn.clsn1 (3165 documents)               # clsn.clsn1集合中恢复了3165个文档
2018-01-08T16:59:19.850+0800    restoring indexes for collection clsn.clsn from metadata     # 重放了oplog中的所有操作
2018-01-08T16:59:19.851+0800    finished restoring clsn.clsn (10000 documents)
2018-01-08T16:59:19.851+0800    replaying oplog
2018-01-08T16:59:19.919+0800    done
```
从日志可以看出clsn.clsn1集合中恢复了3165个文档，重放了oplog中的所有操作。所以理论上clsn1应该有16857个文档（3165个来自clsn.bson，剩下的来自oplog.bson）。验证一下：
```
sh1:PRIMARY> db.clsn1.count()
3849
```
这就是带oplog的mongodump的真正作用。

模拟生产环境
---

1、模拟一个不断有插入操作
```
for(i=0;i<300000;i++){ db.oplog.insert({"id":i,"name":"shenzheng","age":70,"date":new Date()}); }
```

2、插入数据的同时备份
```
mongodump -h 10.0.0.152 --port 28021  --oplog  -o /home/mongod/backup/config
```

3、备份完成后进行次错误的操作
```
db.oplog.remove({});
```

4、备份oplog.rs文件
```
mongodump -h 10.0.0.152 --port 28021 -d local -c oplog.rs -o  /home/mongod/backup/config/oplog
```

5、恢复之前备份的数据
```
mongorestore -h 10.0.0.152 --port 28021--oplogReplay /home/mongod/backup/config
```

6、截取oplog，找到发生误删除的时间点
```
bsondump oplog.rs.bson |egrep "\"op\":\"d\"\,\"ns\":\"test\.oplog\"" |head -1 
"t":1515379110,"i":1
```

7、复制oplog到备份目录
```
cp  /home/mongod/backup/config/oplog/oplog.rs.bson   /home/mongod/backup/config/oplog.bson
```

8、进行恢复，添加之前找到的误删除的点（limt）
```
mongorestore -h 10.0.0.152 --port 28021 --oplogReplay --oplogLimit "1515379110:1"  /home/mongod/backup/
```


备份恢复--oplog
```
备份所有库推荐使用添加--oplog参数的命令，这样的备份是基于某一时间点的快照，只能用于备份全部库时才可用，单库和单表不适用：
mongodump -h 127.0.0.1 --port 27017 --oplog -o /root/bak 

同时，恢复时也要加上--oplogReplay参数，具体命令如下(下面是恢复单库的命令)：
mongorestore -d swrd --oplogReplay /home/mongo/swrdbak/swrd/
```
