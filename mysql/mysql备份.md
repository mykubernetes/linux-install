1、备份所有数据库  
```
mysqldump -u root -p123456 --all-databases > /opt/mysqlbak/20190804.sql
```  
- --all-databases可以使用-A

2、备份指定数据库  
```
mysqldump --databases 数据库名 > /opt/mysqlbak/20190804.sql
```  

3、备份指定表  
```
mysqldump -uroot -p123456 数据库名  表名 > /opt/mysqlbak/20190804.sql
```  

4、恢复  
```
mysql < /opt/mysqlbak/20190804.sql
或者
source /opt/mysqlbak/20190804.sql
```  
