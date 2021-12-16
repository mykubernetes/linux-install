# mysqldump命令详解
```
--all-databases , -A             导出全部数据库。
--all-tablespaces , -Y           导出全部表空间。
--no-tablespaces , -y            不导出任何表空间信息。
--add-drop-database              每个数据库创建之前添加drop数据库语句。
--add-drop-table                 每个数据表创建之前添加drop数据表语句。(默认为打开状态，使用--skip-add-drop-table取消选项)
--add-locks                      在每个表导出之前增加LOCK TABLES并且之后UNLOCK TABLE。(默认为打开状态，使用--skip-add-locks取消选项)
--allow-keywords                 允许创建是关键词的列名字。这由表名前缀于每个列名做到。
--apply-slave-statements         在'CHANGE MASTER'前添加'STOP SLAVE'，并且在导出的最后添加'START SLAVE'。
--character-sets-dir             字符集文件的目录
--comments                       附加注释信息。默认为打开，可以用--skip-comments取消
--compatible                     导出的数据将和其它数据库或旧版本的MySQL 相兼容。值可以为ansi、mysql323、mysql40、postgresql、oracle、mssql、db2、maxdb、no_key_options、no_tables_options、no_field_options等，要使用几个值，用逗号将它们隔开。它并不保证能完全兼容，而是尽量兼容。
--compact                        导出更少的输出信息(用于调试)。去掉注释和头尾等结构。可以使用选项：--skip-add-drop-table --skip-add-locks --skip-comments --skip-disable-keys
--complete-insert, -c            使用完整的insert语句(包含列名称)。这么做能提高插入效率，但是可能会受到max_allowed_packet参数的影响而导致插入失败。
--compress, -C                   在客户端和服务器之间启用压缩传递所有信息
--create-options, -a             在CREATE TABLE语句中包括所有MySQL特性选项。(默认为打开状态)
--databases, -B                  导出几个数据库。参数后面所有名字参量都被看作数据库名。
--debug                          输出debug信息，用于调试。默认值为：d:t:o,/tmp/mysqldump.trace
--debug-check                    检查内存和打开文件使用说明并退出。
--debug-info                     输出调试信息并退出
--default-character-set          设置默认字符集，默认值为utf8
--delayed-insert                 采用延时插入方式（INSERT DELAYED）导出数据
--delete-master-logs             master备份后删除日志. 这个参数将自动激活--master-data。
--disable-keys                   对于每个表，用/*!40000 ALTER TABLE tbl_name DISABLE KEYS */;和/*!40000 ALTER TABLE tbl_name ENABLE KEYS */;语句引用INSERT语句。这样可以更快地导入dump出来的文件，因为它是在插入所有行后创建索引的。该选项只适合MyISAM表，默认为打开状态。
--dump-slave                     该选项将导致主的binlog位置和文件名追加到导出数据的文件中。设置为1时，将会以CHANGE MASTER命令输出到数据文件；设置为2时，在命令前增加说明信息。该选项将会打开--lock-all-tables，除非--single-transaction被指定。该选项会自动关闭--lock-tables选项。默认值为0。
--events, -E                     导出事件。
--extended-insert, -e            使用具有多个VALUES列的INSERT语法。这样使导出文件更小，并加速导入时的速度。默认为打开状态，使用--skip-extended-insert取消选项。
--fields-terminated-by           导出文件中忽略给定字段。与--tab选项一起使用，不能用于--databases和--all-databases选项
--fields-enclosed-by             输出文件中的各个字段用给定字符包裹。与--tab选项一起使用，不能用于--databases和--all-databases选项
--fields-optionally-enclosed-by      输出文件中的各个字段用给定字符选择性包裹。与--tab选项一起使用，不能用于--databases和--all-databases选项
--fields-escaped-by              输出文件中的各个字段忽略给定字符。与--tab选项一起使用，不能用于--databases和--all-databases选项
--flush-logs                    开始导出之前刷新日志。请注意：假如一次导出多个数据库(使用选项--databases或者--all-databases)，将会逐个数据库刷新日志。除使用--lock-all-tables或者--master-data外。在这种情况下，日志将会被刷新一次，相应的所以表同时被锁定。因此，如果打算同时导出和刷新日志应该使用--lock-all-tables 或者--master-data 和--flush-logs。
--flush-privileges              在导出mysql数据库之后，发出一条FLUSH PRIVILEGES 语句。为了正确恢复，该选项应该用于导出mysql数据库和依赖mysql数据库数据的任何时候。
--force                         在导出过程中忽略出现的SQL错误。
--help                          显示帮助信息并退出。
--hex-blob                      使用十六进制格式导出二进制字符串字段。如果有二进制数据就必须使用该选项。影响到的字段类型有BINARY、VARBINARY、BLOB。
--host, -h                      需要导出的主机信息
--ignore-table                  不导出指定表。指定忽略多个表时，需要重复多次，每次一个表。每个表必须同时指定数据库和表名。例如：--ignore-table=database.table1 --ignore-table=database.table2 ……
--include-master-host-port      在--dump-slave产生的'CHANGE MASTER TO..'语句中增加'MASTER_HOST=<host>，MASTER_PORT=<port>'
--insert-ignore                 在插入行时使用INSERT IGNORE语句.
--lines-terminated-by           输出文件的每行用给定字符串划分。与--tab选项一起使用，不能用于--databases和--all-databases选项。
--lock-all-tables, -x           提交请求锁定所有数据库中的所有表，以保证数据的一致性。这是一个全局读锁，并且自动关闭--single-transaction 和--lock-tables 选项。
--lock-tables, -l               开始导出前，锁定所有表。用READ LOCAL锁定表以允许MyISAM表并行插入。对于支持事务的表例如InnoDB和BDB，--single-transaction是一个更好的选择，因为它根本不需要锁定表。请注意当导出多个数据库时，--lock-tables分别为每个数据库锁定表。因此，该选项不能保证导出文件中的表在数据库之间的逻辑一致性。不同数据库表的导出状态可以完全不同。
--log-error                     附加警告和错误信息到给定文件
--master-data                   该选项将binlog的位置和文件名追加到输出文件中。如果为1，将会输出CHANGE MASTER 命令；如果为2，输出的CHANGE MASTER命令前添加注释信息。该选项将打开--lock-all-tables 选项，除非--single-transaction也被指定（在这种情况下，全局读锁在开始导出时获得很短的时间；其他内容参考下面的--single-transaction选项）。该选项自动关闭--lock-tables选项。
--max_allowed_packet            服务器发送和接受的最大包长度。
--net_buffer_length             TCP/IP和socket连接的缓存大小。
--no-autocommit                 使用autocommit/commit 语句包裹表。
--no-create-db, -n              只导出数据，而不添加CREATE DATABASE 语句。
--no-create-info, -t            只导出数据，而不添加CREATE TABLE 语句。
--no-data, -d                   不导出任何数据，只导出数据库表结构。
--no-set-names, -N              等同于--skip-set-charset
--opt                           等同于--add-drop-table, --add-locks, --create-options, --quick, --extended-insert, --lock-tables, --set-charset, --disable-keys 该选项默认开启, 可以用--skip-opt禁用.
--order-by-primary              如果存在主键，或者第一个唯一键，对每个表的记录进行排序。在导出MyISAM表到InnoDB表时有效，但会使得导出工作花费很长时间。
--password, -p                  连接数据库密码
--pipe(windows系统可用)          使用命名管道连接mysql
--port, -P                      连接数据库端口号
--protocol                      使用的连接协议，包括：tcp, socket, pipe, memory.
--quick, -q                     不缓冲查询，直接导出到标准输出。默认为打开状态，使用--skip-quick取消该选项。
--quote-names,-Q                使用（`）引起表和列名。默认为打开状态，使用--skip-quote-names取消该选项。
--replace                       使用REPLACE INTO 取代INSERT INTO.
--result-file, -r               直接输出到指定文件中。该选项应该用在使用回车换行对（\\r\\n）换行的系统上（例如：DOS，Windows）。该选项确保只有一行被使用。
--routines, -R                  导出存储过程以及自定义函数。
--set-charset                   添加'SET NAMES default_character_set'到输出文件。默认为打开状态，使用--skip-set-charset关闭选项。
--single-transaction            该选项在导出数据之前提交一个BEGIN SQL语句，BEGIN 不会阻塞任何应用程序且能保证导出时数据库的一致性状态。它只适用于多版本存储引擎，仅InnoDB。本选项和--lock-tables 选项是互斥的，因为LOCK TABLES 会使任何挂起的事务隐含提交。要想导出大表的话，应结合使用--quick 选项。
--dump-date                     将导出时间添加到输出文件中。默认为打开状态，使用--skip-dump-date关闭选项。
--skip-opt                      禁用–opt选项.
--socket,-S                     指定连接mysql的socket文件位置，默认路径/tmp/mysql.sock
--tab,-T                        为每个表在给定路径创建tab分割的文本文件。注意：仅仅用于mysqldump和mysqld服务器运行在相同机器上。
--tables                        覆盖--databases (-B)参数，指定需要导出的表名。
--triggers                      导出触发器。该选项默认启用，用--skip-triggers禁用它。
--tz-utc                        在导出顶部设置时区TIME_ZONE='+00:00' ，以保证在不同时区导出的TIMESTAMP 数据或者数据被移动其他时区时的正确性。
--user, -u                      指定连接的用户名。
--verbose, --v                  输出多种平台信息。
--version, -V                   输出mysqldump版本信息并退出
--where, -w                     只转储给定的WHERE条件选择的记录。请注意如果条件包含命令解释符专用空格或字符，一定要将条件引用起来。
--xml, -X                       导出XML格式.
--plugin_dir                    客户端插件的目录，用于兼容不同的插件版本。
--default_auth                  客户端插件默认使用权限。
```


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

附加选项：
- -c 完整sql语句
- –skip-add-locks 不锁表
- -d 导出表结构不导出数据
- -t 导出数据不导出表结构
- -R 导出存储过程及自定义函数

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
