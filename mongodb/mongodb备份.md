https://www.cnblogs.com/xiaotengyi/p/6393972.html


mongodb数据库的备份，备份所有库  
```
mongodump -h 127.0.0.1:27017 -o /data/mongodbbackup/
```  

mongodb数据库的恢复  
```
mongorestore -h 127.0.0.1:27018 /data/mongodbbackup/
```  
