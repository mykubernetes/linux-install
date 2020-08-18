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


查看二进制命令
```
mysqlbinlog binlog.0000001
```

1，通过时间节点还原
```
mysqlbinlog --start-date="2016-09-30 18:19:30" --stop-date="2016-10-1 12:30:30" /var/lib/mysql/binlog.000001 | mysql -u root -p123
```

2按位置号还原
```
mysqlbinlog --start-position="436" --stop-position="521" /var/lib/mysql/binlog.000001 mysql -u root -p123
```

3、记录日志方式 还原日志
```
mysqldump mysqlbinlog.000001 > /tmp/caozuo.sql
mysql -u root -p123 < /tmp/caozuo.sql
```

4、可查看日志内容
```
# mysqlbinlog --start-date="2016-09-30 18:19:30" --stop-date="2016-10-1 12:30:30" /var/lib/mysql/binlog.000001 > /tmp/a.sql
```




I/O错误修复方法
```
show slave status\G
show master status\G

>slave stop;
>change master to
>master_host='10.1.1.3',
>master_user='sko',
>master_password='123',
>master_log_file='binlog.000005',
>master_log_pos=106;

slave stop
slave start
```
