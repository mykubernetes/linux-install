mysqldump
---
```
导出一个数据库：
# mysqldump -u root -p -P 3306 --databases course>backup.sql
导出多个数据库：
# mysqldump -u root -p -P 3306 --databases course test>course.sql
#或则
# mysqldump -u root -p -P 3306 -B course test>course.sql
 
导出所有数据库：
# mysqldump -u root -p -P 3306 --all-databases>course.sql
 
导出一个数据库的某几个表：
# mysqldump -u root -p -P 3306 course students students_myisam>course.sql
 
仅导出course数据库的数据而不包含表结构：
# mysqldump -u root -p -P 3306 --no-create-info course>course.sql
 
仅导出course数据库中的students和students_myisam两个表的数据：
# mysqldump -u root -p -P 3306 --no-create-info course students students_myisam>course.sq
 
仅导出course数据库的表结构：
# mysqldump -u root -p -P 3306 --no-data course>course.sql
 
导出course数据库中除了teacher和score两个表的其他表结构和数据：
# mysqldump -u root -p -P 3306 --ignore-table=course.teacher --ignoretable=course.score course>course.sql
 
导出course数据库的表和存储过程和触发器：
# mysqldump -u root -p -P 3306 --routine --trigger course>course.sql
 
导出course数据库中符合where条件的数据：
# mysqldump -u root -p -P 3306 --where="sid in (1,2)" course students
students_myisam>course.sql
 
远程导出course数据库，导出文件在发起导出命令的服务器上：
# mysqldump -u root -p -P 3306 -h 10.0.0.201 course > course.sql
```

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


二进制文件恢复
---
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
mysqlbinlog --start-position="436" --stop-position="521" /var/lib/mysql/binlog.000001 | mysql -u root -p123
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


mysql主从错误修复
---
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

自定义脚本定时备份  
检测所有用户定义的数据库，定时备份所有的数据库，并上传到备份服务器
```
#!/bin/sh
####################################
##Function: mysql_dump
##Version: 1.1
# #####################################
MYUSER=system
PORT=5001
DB_DATE=$(date +%F)
DB_NAME=$(uname -n)
MYPASS=********
MYLOGIN=" /data/application/mysql/bin/mysql -u$MYUSER -p$MYPASS -P$PORT "
MYDUMP=" /data/application/mysql/bin/mysqldump -u$MYUSER -p$MYPASS -P$PORT -B "
DATABASE=" $($MYLOGIN -e "show databases;" |egrep -vi "information_schema|database|performance_schema|mysql") "
for dbname in $DATABASE do
MYDIR=/server/backup/$dbname
[ ! -d $MYDIR ] && mkdir -p $MYDIR
$MYDUMP $dbname --ignore-table=opsys.user_action|gzip > $MYDIR/${dbname}_${DB_NAME}_${DB_DATE}_sql.gz
Done
find /server/backup/ -type f -name "*.gz" -mtime +3|xargs rm –rf
find /server/backup/* -type d -name "*" -exec rsync -avz {} data_backup:/data/backup/ \;
```
