https://www.cnblogs.com/xiaotengyi/p/6393972.html


mongob备份支持bson格式

mongodb数据库的备份，备份所有库  
```
mongodump -h 127.0.0.1:27017 -o /data/mongodbbackup/
```  

mongodb数据库的恢复  
```
mongorestore -h 127.0.0.1:27018 /data/mongodbbackup/
```  

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

