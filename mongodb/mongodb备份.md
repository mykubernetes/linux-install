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

备份恢复--oplog
```
备份所有库推荐使用添加--oplog参数的命令，这样的备份是基于某一时间点的快照，只能用于备份全部库时才可用，单库和单表不适用：
mongodump -h 127.0.0.1 --port 27017 --oplog -o /root/bak 

同时，恢复时也要加上--oplogReplay参数，具体命令如下(下面是恢复单库的命令)：
mongorestore -d swrd --oplogReplay /home/mongo/swrdbak/swrd/
```


全量恢复加oplog恢复
---

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








