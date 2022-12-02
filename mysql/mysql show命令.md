 - 1.show databases; 查看数据库名
 - 2.show tables; 查看表名(前提要进入一个库中)
 - 3.show create database xx; 查看建库语句
 - 4.show create table xx; 查看建表语句
 - 5.show processlist; 查看所有用户连接情况
 - 6.show charset; 查看支持的字符集
 - 7.show collation; 查看所有支持的校对规则
 - 8.show grants for xx; 查看用户的权限信息
 - 9.show variables like '%xx%' 查看参数信息(查看变量)(like为模糊查询)
 - 10.show engines; 看所有支持的存储引擎类型（就像linux的文件系统一样）
 - 11.show index from xxx 查看表的索引信息（首先先创建一个索引测试）
 - 12.show engine innodb status\G 查看innoDB引擎详细状态信息（\G将查询到的横向表格纵向输出，方便阅读）
 - 13.show binary logs 查看二进制日志的列表信息(首先要开启二进制日志功能,在my.cnf中加入log-bin=mysql-bin然后重启服务)
 - 14.show binlog events in '二进制日志文件' 查看二进制日志的事件信息
 - 15.show master status ; 查看mysql当前使用二进制日志信息
 - 16.show slave status\G 查看从库状态信息(用在主从复制那一块)
 - 17.show relaylog events in '中继日志文件' 查看中继日志的事件信息

1.show databases; 查看数据库名
```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
| world              |
+--------------------+
5 rows in set (0.01 sec)

mysql> 
```

2.show tables; 查看表名(前提要进入一个库中)
```
mysql>show tables;;
+---------------------------+
| Tables_in_mysql           |
+---------------------------+
| columns_priv              |
| db                        |
| event                     |
| func                      |
| general_log               |
| help_category             |
| help_keyword              |
| help_relation             |
| help_topic                |
| host                      |
| ndb_binlog_index          |
| plugin                    |
| proc                      |
| procs_priv                |
| proxies_priv              |
| servers                   |
| slow_log                  |
| tables_priv               |
| time_zone                 |
| time_zone_leap_second     |
| time_zone_name            |
| time_zone_transition      |
| time_zone_transition_type |
| user                      |
+---------------------------+
24 rows in set (0.04 sec)

mysql> 
```

3.show create database xx; 查看建库语句
```
mysql> create database abc;
Query OK, 1 row affected (0.03 sec)

mysql> show create database abc;
\+----------+----------------------------------------------------------------+
| Database | Create Database                                                |
+----------+----------------------------------------------------------------+
| abc      | CREATE DATABASE `abc` /*!40100 DEFAULT CHARACTER SET latin1 */ |
+----------+----------------------------------------------------------------+
1 row in set (0.01 sec)

mysql> 
```

4.show create table xx; 查看建表语句
```
abc> create table abc(id int,name char(20));
Query OK, 0 rows affected (0.02 sec)

abc> show create table abc;
+-------+-------------------------------------------------------------------------------------------------------------------------+
| Table | Create Table                                                                                                            |
+-------+-------------------------------------------------------------------------------------------------------------------------+
| abc   | CREATE TABLE `abc` (
  `id` int(11) DEFAULT NULL,
  `name` char(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
+-------+-------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

abc> 
```

5.show processlist; 查看所有用户连接情况
```
abc> show processlist;
+-----+------+-----------+------+---------+------+-------+------------------+----------+
| Id  | User | Host      | db   | Command | Time | State | Info             | Progress |
+-----+------+-----------+------+---------+------+-------+------------------+----------+
| 514 | root | localhost | abc  | Query   |    0 | NULL  | show processlist |    0.000 |
+-----+------+-----------+------+---------+------+-------+------------------+----------+
1 row in set (0.01 sec)

abc> 
```

6.show charset; 查看支持的字符集
```
abc> show charset;
+----------+-----------------------------+---------------------+--------+
| Charset  | Description                 | Default collation   | Maxlen |
+----------+-----------------------------+---------------------+--------+
| big5     | Big5 Traditional Chinese    | big5_chinese_ci     |      2 |
| dec8     | DEC West European           | dec8_swedish_ci     |      1 |
| cp850    | DOS West European           | cp850_general_ci    |      1 |
| hp8      | HP West European            | hp8_english_ci      |      1 |
| koi8r    | KOI8-R Relcom Russian       | koi8r_general_ci    |      1 |
| latin1   | cp1252 West European        | latin1_swedish_ci   |      1 |
| latin2   | ISO 8859-2 Central European | latin2_general_ci   |      1 |
| swe7     | 7bit Swedish                | swe7_swedish_ci     |      1 |
| ascii    | US ASCII                    | ascii_general_ci    |      1 |
| ujis     | EUC-JP Japanese             | ujis_japanese_ci    |      3 |
| sjis     | Shift-JIS Japanese          | sjis_japanese_ci    |      2 |
| hebrew   | ISO 8859-8 Hebrew           | hebrew_general_ci   |      1 |
| tis620   | TIS620 Thai                 | tis620_thai_ci      |      1 |
| euckr    | EUC-KR Korean               | euckr_korean_ci     |      2 |
| koi8u    | KOI8-U Ukrainian            | koi8u_general_ci    |      1 |
| gb2312   | GB2312 Simplified Chinese   | gb2312_chinese_ci   |      2 |
| greek    | ISO 8859-7 Greek            | greek_general_ci    |      1 |
| cp1250   | Windows Central European    | cp1250_general_ci   |      1 |
| gbk      | GBK Simplified Chinese      | gbk_chinese_ci      |      2 |
| latin5   | ISO 8859-9 Turkish          | latin5_turkish_ci   |      1 |
| armscii8 | ARMSCII-8 Armenian          | armscii8_general_ci |      1 |
| utf8     | UTF-8 Unicode               | utf8_general_ci     |      3 |
| ucs2     | UCS-2 Unicode               | ucs2_general_ci     |      2 |
| cp866    | DOS Russian                 | cp866_general_ci    |      1 |
| keybcs2  | DOS Kamenicky Czech-Slovak  | keybcs2_general_ci  |      1 |
| macce    | Mac Central European        | macce_general_ci    |      1 |
| macroman | Mac West European           | macroman_general_ci |      1 |
| cp852    | DOS Central European        | cp852_general_ci    |      1 |
| latin7   | ISO 8859-13 Baltic          | latin7_general_ci   |      1 |
| utf8mb4  | UTF-8 Unicode               | utf8mb4_general_ci  |      4 |
| cp1251   | Windows Cyrillic            | cp1251_general_ci   |      1 |
| utf16    | UTF-16 Unicode              | utf16_general_ci    |      4 |
| cp1256   | Windows Arabic              | cp1256_general_ci   |      1 |
| cp1257   | Windows Baltic              | cp1257_general_ci   |      1 |
| utf32    | UTF-32 Unicode              | utf32_general_ci    |      4 |
| binary   | Binary pseudo charset       | binary              |      1 |
| geostd8  | GEOSTD8 Georgian            | geostd8_general_ci  |      1 |
| cp932    | SJIS for Windows Japanese   | cp932_japanese_ci   |      2 |
| eucjpms  | UJIS for Windows Japanese   | eucjpms_japanese_ci |      3 |
+----------+-----------------------------+---------------------+--------+
39 rows in set (0.01 sec)

abc> 
```

7.show collation; 查看所有支持的校对规则
```
abc> show collation;
+--------------------------+----------+-----+---------+----------+---------+
| Collation                | Charset  | Id  | Default | Compiled | Sortlen |
+--------------------------+----------+-----+---------+----------+---------+
| big5_chinese_ci          | big5     |   1 | Yes     | Yes      |       1 |
| big5_bin                 | big5     |  84 |         | Yes      |       1 |
| dec8_swedish_ci          | dec8     |   3 | Yes     | Yes      |       1 |
| dec8_bin                 | dec8     |  69 |         | Yes      |       1 |
| cp850_general_ci         | cp850    |   4 | Yes     | Yes      |       1 |
.............
..............
...........................
+--------------------------+----------+-----+---------+----------+---------+
202 rows in set (0.00 sec)

abc> 
```

8.show grants for xx; 查看用户的权限信息
```
abc> grant all on *.* to lisi@'%' identified by '123456';Query OK, 0 rows affected (0.01 sec)

abc> show grants for lisi;
+--------------------------------------------------------------------------------------------------------------+
| Grants for lisi@%                                                                                            |
+--------------------------------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'lisi'@'%' IDENTIFIED BY PASSWORD '*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9' |
+--------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

abc> 
```

9.show variables like ‘%xx%’ 查看参数信息(查看变量)(like为模糊查询)
```
abc> show variables like '%ab%';
+----------------------------------------+-------------------+
| Variable_name                          | Value             |
+----------------------------------------+-------------------+
| aria_used_for_temp_tables              | ON                |
| big_tables                             | OFF               |
| character_set_database                 | latin1            |
| collation_database                     | latin1_swedish_ci |
| innodb_corrupt_table_action            | assert            |
| innodb_file_per_table                  | OFF               |
| innodb_import_table_from_xtrabackup    | 0                 |
| innodb_lazy_drop_table                 | 0                 |
| innodb_table_locks                     | ON                |
| innodb_use_sys_stats_table             | OFF               |
| lower_case_table_names                 | 0                 |
| max_heap_table_size                    | 16777216          |
| max_tmp_tables                         | 32                |
| old_alter_table                        | OFF               |
| performance_schema_max_table_handles   | 100000            |
| performance_schema_max_table_instances | 50000             |
| replicate_do_table                     |                   |
| replicate_ignore_table                 |                   |
| replicate_wild_do_table                |                   |
| replicate_wild_ignore_table            |                   |
| skip_show_database                     | OFF               |
| sql_big_tables                         | OFF               |
| table_definition_cache                 | 400               |
| table_open_cache                       | 400               |
| tmp_table_size                         | 16777216          |
| updatable_views_with_limit             | YES               |
+----------------------------------------+-------------------+
26 rows in set (0.01 sec)

abc> 
```

10.show engines; 看所有支持的存储引擎类型（就像linux的文件系统一样）
```
abc> show engines;
+--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                          | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, and foreign keys       | YES          | YES  | YES        |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                                            | NO           | NO   | NO         |
| MyISAM             | YES     | Non-transactional engine with good performance and small data footprint          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears)                   | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                               | NO           | NO   | NO         |
| CSV                | YES     | Stores tables as CSV files                                                       | NO           | NO   | NO         |
| ARCHIVE            | YES     | gzip-compresses tables for a low storage footprint                               | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                        | NO           | NO   | NO         |
| FEDERATED          | YES     | Allows to access tables on other MariaDB servers, supports transactions and more | YES          | NO   | YES        |
| Aria               | YES     | Crash-safe tables with MyISAM heritage                                           | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
10 rows in set (0.00 sec)

abc> 
```

11.show index from xxx 查看表的索引信息（首先先创建一个索引测试）
```
abc> alter table abc add index inx_name(name);
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

abc> show index from abc;
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| abc   |          1 | inx_name |            1 | name        | A         |           0 |     NULL | NULL   | YES  | BTREE      |         |               |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
1 row in set (0.00 sec)

abc> 
```

12.show engine innodb status\G 查看innoDB引擎详细状态信息（\G将查询到的横向表格纵向输出，方便阅读）
```
abc> show engine innodb status\G;
*************************** 1. row ***************************
  Type: InnoDB
  Name: 
Status: 
=====================================
210405 10:17:46 INNODB MONITOR OUTPUT
=====================================
Per second averages calculated from the last 50 seconds
-----------------
BACKGROUND THREAD
-----------------
srv_master_thread loops: 714 1_second, 714 sleeps, 64 10_second, 82 background, 82 flush
srv_master_thread log flush and writes: 690
----------
SEMAPHORES
----------
OS WAIT ARRAY INFO: reservation count 25659, signal count 3757
Mutex spin waits 52134, rounds 1581819, OS waits 25550
RW-shared spins 128, rounds 3840, OS waits 87
RW-excl spins 0, rounds 660, OS waits 22
Spin rounds per wait: 30.34 mutex, 30.00 RW-shared, 660.00 RW-excl
--------
FILE I/O
--------
I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
I/O thread 1 state: waiting for completed aio requests (log thread)
I/O thread 2 state: waiting for completed aio requests (read thread)
I/O thread 3 state: waiting for completed aio requests (read thread)
I/O thread 4 state: waiting for completed aio requests (read thread)
I/O thread 5 state: waiting for completed aio requests (read thread)
I/O thread 6 state: waiting for completed aio requests (write thread)
I/O thread 7 state: waiting for completed aio requests (write thread)
I/O thread 8 state: waiting for completed aio requests (write thread)
I/O thread 9 state: waiting for completed aio requests (write thread)
Pending normal aio reads: 0 [0, 0, 0, 0] , aio writes: 0 [0, 0, 0, 0] ,
 ibuf aio reads: 0, log i/o's: 0, sync i/o's: 0
Pending flushes (fsync) log: 0; buffer pool: 0
135 OS file reads, 7138 OS file writes, 524 OS fsyncs
0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s
-------------------------------------
INSERT BUFFER AND ADAPTIVE HASH INDEX
-------------------------------------
Ibuf: size 1, free list len 0, seg size 2, 0 merges
merged operations:
 insert 0, delete mark 0, delete 0
discarded operations:
 insert 0, delete mark 0, delete 0
Hash table size 276671, node heap has 139 buffer(s)
0.00 hash searches/s, 0.00 non-hash searches/s
---
LOG
---
Log sequence number 121716959
Log flushed up to   121716959
Last checkpoint at  121716959
Max checkpoint age    7782360
Checkpoint age target 7539162
Modified age          0
Checkpoint age        0
0 pending log writes, 0 pending chkp writes
332 log i/o's done, 0.00 log i/o's/second
----------------------
BUFFER POOL AND MEMORY
----------------------
Total memory allocated 137756672; in additional pool allocated 0
Total memory allocated by read views 104
Internal hash tables (constant factor + variable factor)
    Adaptive hash index 4494960 	(2213368 + 2281592)
    Page hash           139112 (buffer pool 0 only)
    Dictionary cache    633343 	(554768 + 78575)
    File system         83536 	(82672 + 864)
    Lock system         333248 	(332872 + 376)
    Recovery system     0 	(0 + 0)
Dictionary memory allocated 78575
Buffer pool size        8191
Buffer pool size, bytes 134201344
Free buffers            3427
Database pages          4625
Old database pages      1687
Modified db pages       0
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 15, not young 0
0.00 youngs/s, 0.00 non-youngs/s
Pages read 0, created 4625, written 6431
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 4625, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
--------------
ROW OPERATIONS
--------------
0 queries inside InnoDB, 0 queries in queue
1 read views open inside InnoDB
0 transactions active inside InnoDB
0 out of 1000 descriptors used
---OLDEST VIEW---
Normal read view
Read view low limit trx n:o 2313
Read view up limit trx id 2313
Read view low limit trx id 2313
Read view individually stored trx ids:
-----------------
Main thread process no. 19175, id 140517702547200, state: waiting for server activity
Number of rows inserted 3116732, updated 0, deleted 0, read 4225538500
0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
------------
TRANSACTIONS
------------
Trx id counter 2314
Purge done for trx's n:o < 2313 undo n:o < 0
History list length 11
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 2313, not started
MySQL thread id 515, OS thread handle 0x7fccd0888700, query id 14057 localhost root
show engine innodb status
----------------------------
END OF INNODB MONITOR OUTPUT
============================

1 row in set (0.01 sec)
abc>
```

13.show binary logs 查看二进制日志的列表信息(首先要开启二进制日志功能,在my.cnf中加入log-bin=mysql-bin然后重启服务)
```
abc> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |       245 |
+------------------+-----------+
1 row in set (0.00 sec)

abc> 
```

14.show binlog events in ‘二进制日志文件’ 查看二进制日志的事件信息
```
abc> show binlog events in 'mysql-bin.000001';
+------------------+-----+-------------+-----------+-------------+-------------------------------------------+
| Log_name         | Pos | Event_type  | Server_id | End_log_pos | Info                                      |
+------------------+-----+-------------+-----------+-------------+-------------------------------------------+
| mysql-bin.000001 |   4 | Format_desc |         1 |         245 | Server ver: 5.5.68-MariaDB, Binlog ver: 4 |
+------------------+-----+-------------+-----------+-------------+-------------------------------------------+
1 row in set (0.00 sec)

abc>
```

15.show master status ; 查看mysql当前使用二进制日志信息
```
abc> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000001 |      245 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)

abc> 
```

16.show slave status\G 查看从库状态信息(用在主从复制那一块)

17.show relaylog events in ‘中继日志文件’ 查看中继日志的事件信息
