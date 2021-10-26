
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
