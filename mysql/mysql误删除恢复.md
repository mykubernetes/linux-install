
1、查看是否开启二进制日志
```
mysql> show variables like '%log_bin%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| log_bin                         | OFF   |
| log_bin_basename                |       |
| log_bin_index                   |       |
| log_bin_trust_function_creators | OFF   |
| log_bin_use_v1_row_events       | OFF   |
| sql_log_bin                     | ON    |
+---------------------------------+-------+
6 rows in set (0.01 sec)
```

2、开启binlog
```
# vim /etc/my.cnf
log_bin=mysql-bin  
server-id = 1
```

3、再次查看是否开启二进制日志
```
mysql> show variables like '%log_bin%';
+---------------------------------+--------------------------------+
| Variable_name                   | Value                          |
+---------------------------------+--------------------------------+
| log_bin                         | ON                             |
| log_bin_basename                | /var/lib/mysql/myslq-bin       |
| log_bin_index                   | /var/lib/mysql/myslq-bin.index |
| log_bin_trust_function_creators | OFF                            |
| log_bin_use_v1_row_events       | OFF                            |
| sql_log_bin                     | ON                             |
+---------------------------------+--------------------------------+
6 rows in set (0.00 sec)
```

4、创建数据库和表
```
mysql> create database ops;
Query OK, 1 row affected (0.00 sec)

mysql> use ops;
Database changed

mysql>  create table customers(  id int not null auto_increment,  name char(20) not null,  age int not null,  primary key(id) )engine=InnoDB;
Query OK, 0 rows affected (0.01 sec)

mysql> show tables;
+---------------+
| Tables_in_ops |
+---------------+
| customers     |
+---------------+
1 row in set (0.00 sec)
```

5、插入数据
```
mysql> desc customers;
+-------+----------+------+-----+---------+----------------+
| Field | Type     | Null | Key | Default | Extra          |
+-------+----------+------+-----+---------+----------------+
| id    | int(11)  | NO   | PRI | NULL    | auto_increment |
| name  | char(20) | NO   |     | NULL    |                |
| age   | int(11)  | NO   |     | NULL    |                |
+-------+----------+------+-----+---------+----------------+
3 rows in set (0.01 sec)

mysql> insert into customers values(1,"wangbo","24");
Query OK, 1 row affected (0.00 sec)

mysql> insert into customers values(2,"guohui","22");
Query OK, 1 row affected (0.01 sec)

mysql> insert into customers values(3,"zhangheng","27");
Query OK, 1 row affected (0.00 sec)

mysql> select * from customers;
+----+-----------+-----+
| id | name      | age |
+----+-----------+-----+
|  1 | wangbo    |  24 |
|  2 | guohui    |  22 |
|  3 | zhangheng |  27 |
+----+-----------+-----+
3 rows in set (0.00 sec)
```

6、进行全量备份
```
# mysqldump -uroot -p -B -F -R -x --master-data=2 ops|gzip >/opt/backup/ops_$(date +%F).sql.gz
Enter password: 

# ls /opt/backup/
ops_2021-10-26.sql.gz
```
- -B：指定数据库
- -F：刷新日志
- -R：备份存储过程等
- -x：锁表
- --master-data：在备份语句里添加CHANGE MASTER语句以及binlog文件及位置点信息

6、再次插入数据
```
mysql> insert into customers values(4,"liupeng","21");
Query OK, 1 row affected (0.00 sec)

mysql>  insert into customers values(5,"xiaoda","31");
Query OK, 1 row affected (0.00 sec)

mysql> insert into customers values(6,"fuaiai","26");
Query OK, 1 row affected (0.00 sec)

mysql> select * from customers;
+----+-----------+-----+
| id | name      | age |
+----+-----------+-----+
|  1 | wangbo    |  24 |
|  2 | guohui    |  22 |
|  3 | zhangheng |  27 |
|  4 | liupeng   |  21 |
|  5 | xiaoda    |  31 |
|  6 | fuaiai    |  26 |
+----+-----------+-----+
6 rows in set (0.00 sec)
```

7、此时误操作，删除了test数据库
```
mysql> drop database ops;
Query OK, 1 row affected (0.01 sec)
```

8、查看全备之后新增的binlog文件
```
[root@localhost ~]# cd /opt/backup/

[root@localhost backup]# ls
ops_2021-10-26.sql.gz

[root@localhost backup]# gzip -d ops_2021-10-26.sql.gz

[root@localhost backup]# ls
ops_2021-10-26.sql

[root@localhost backup]# grep CHANGE ops_2021-10-26.sql 
-- CHANGE MASTER TO MASTER_LOG_FILE='myslq-bin.000003', MASTER_LOG_POS=154;
```
- 这是全备时刻的binlog文件位置,即mysql-bin.000003的154行，因此在该文件之前的binlog文件中的数据都已经包含在这个全备的sql文件中了

9、移动binlog文件，并导出为sql文件，剔除其中的drop语句
```
# cd /var/lib/mysql

# ls |grep  myslq-bin
myslq-bin.000001
myslq-bin.000002
myslq-bin.000003
myslq-bin.index

# cp myslq-bin.000003 /opt/backup/

# 将binlog文件导出sql文件，并vim编辑它删除其中的drop语句
# cd /opt/backup/

# ls
myslq-bin.000003  ops_2021-10-26.sql

# mysqlbinlog myslq-bin.000003 > 003bin.sql              # 即将binlog日志转化为可正常导入的sql文件

# ls
003bin.sql  myslq-bin.000003  ops_2021-10-26.sql

# vim 003bin.sql                                         # 删除里面的drop语句
```

10、恢复
```
# mysql -uroot -p < ops_2021-10-26.sql 
Enter password: 

# 登录验证
# mysql -uroot -p 
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 6
Server version: 5.7.35-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| csdn               |
| mysql              |
| ops                |
| performance_schema |
| sqltest            |
| sys                |
| wordpress          |
+--------------------+
8 rows in set (0.00 sec)


mysql> use ops;

mysql>  select * from customers;
+----+-----------+-----+
| id | name      | age |
+----+-----------+-----+
|  1 | wangbo    |  24 |
|  2 | guohui    |  22 |
|  3 | zhangheng |  27 |
+----+-----------+-----+
3 rows in set (0.00 sec)
```
- 此时恢复了全备时刻的数据


11、接着，使用002bin.sql文件恢复全备时刻到删除数据库之间，新增的数据

```
# mysql -uroot -p < 003bin.sql 
Enter password: 
ERROR 1790 (HY000) at line 93: @@SESSION.GTID_NEXT cannot be changed by a client that owns a GTID. The client owns ANONYMOUS. Ownership is released on COMMIT or ROLLBACK.

# 登录验证
# mysql -uroot -p 
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 5.7.35-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| csdn               |
| mysql              |
| ops                |
| performance_schema |
| sqltest            |
| sys                |
| wordpress          |
+--------------------+
8 rows in set (0.00 sec)

mysql> use ops 
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql>  select * from customers;
+----+-----------+-----+
| id | name      | age |
+----+-----------+-----+
|  1 | wangbo    |  24 |
|  2 | guohui    |  22 |
|  3 | zhangheng |  27 |
|  4 | liupeng   |  21 |
|  5 | xiaoda    |  31 |
|  6 | fuaiai    |  26 |
+----+-----------+-----+
6 rows in set (0.00 sec)
```
- 以上就是mysql数据库增量数据恢复的实例过程！

## 最后，总结几点：
- 1）本案例适用于人为SQL语句造成的误操作或者没有主从复制等的热备情况宕机时的修复
- 2）恢复条件为mysql要开启binlog日志功能，并且要全备和增量的所有数据
- 3）恢复时建议对外停止更新，即禁止更新数据库
- 4）先恢复全量，然后把全备时刻点以后的增量日志，按顺序恢复成SQL文件，然后把文件中有问题的SQL语句删除（也可通过时间和位置点），再恢复到数据库。














