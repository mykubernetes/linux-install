
跨版本备份，支持json和csv两种格式
---
mongoexport 
- -h 指明数据库宿主机的IP 
- -u 指明数据库的用户名
- -p 指明数据库的密码
- -d 指明数据库的名字
- -c 指明collection的名字
- -f 指明要导出哪些列
- -o 指明要导出的文件名
- -q 指明导出数据库的过滤条件
- --authenticationatabase admin

备份
```
备份json格式
mongoexport -uroot -p12456 -c log --authenticationatabase admin -o /mongob/bakup/log.json

备份csv格式
mongoexport -uroot -p12456 -c log --type=csv -f uid,name,date --authenticationatabase admin -o /mongob/bakup/log.csv
```

mongoimport

- -h 指明数据库宿主机的IP 
- -u 指明数据库的用户名
- -p 指明数据库的密码
- -d 指明数据库的名字
- -c 指明collection的名字
- -f 指明要导出哪些列
- -j, --numInsertionWorker=<number> number of insert operation to run concurrently (default to 1) 并发导入

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
select * from t100w into outfile "/opt.t100w.csv" fields terminated by ',';

mongoimport -uroot -p12456 -d mysqltest -c test --type -f id,num,k1,k2,dt --authenticationatabase admin /opt.t100w.csv
```



mongob备份支持bson格式
---
mongodb数据库的备份，备份所有库 

mongodump
- -h 指明数据库宿主机的IP 
- -u 指明数据库的用户名
- -p 指明数据库的密码
- -d 指明数据库的名字
- -c 指明collection的名字
- -o 指明要导出的文件名
- -q 指明导出的数据库过滤条件
- -j 并发
--oplog 备份的同时备份oplog

```
备份所有库
mongodump -uroot -p123456 --port 27017--authenticationDatabase admin -o /monggodb/backup/

备份单个库
mongodump -uroot -p123456 --port 27017  --authenticationDatabase admin -d DB_NAME -o /monggodb/backup/

备份单个表
mongodump -uroot -p123456 --port 27017 --authenticationDatabase admin -d DB_NAME -c TABLE_NAME -o /monggodb/backup/mongo_201507021701.bak


```  

mongodb数据库的恢复  
```
恢复所有库：
mongorestore -uroot -p 123456 --port 27017 --authenticationDatabase admin /monggodb/backup/

恢复单个库：
mongorestore -uroot -p 123456 --port 27017 --authenticationDatabase admin -d DB_NAME /monggodb/backup/

恢复单表
mongorestore -uroot -p 123456 --authenticationDatabase admin -d DB_NAME -c TABLE_NAME /monggodb/backup/myTest_d_bak_201507021701.bak/myTest/d.bson
```  

```
备份所有库推荐使用添加--oplog参数的命令，这样的备份是基于某一时间点的快照，只能用于备份全部库时才可用，单库和单表不适用：
mongodump -h 127.0.0.1 --port 27017   --oplog -o  /root/bak 

同时，恢复时也要加上--oplogReplay参数，具体命令如下(下面是恢复单库的命令)：
mongorestore  -d swrd --oplogReplay  /home/mongo/swrdbak/swrd/
```
