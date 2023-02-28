
正常情况下，死锁发生时，权重最小的连接将被kill并回滚。但http://www.cppcns.com是为了找出语句来优化，启用可启用死锁将死锁信息记录下来。

#step 1：窗口一
```
mysql> start transaction;
mysql> update aa set name='aaa' where id = 1;
```

#step 2：窗口二
```
mysql> start transaction;
mysql> update bb set name='bbb' where id = 1;
```

#step 3：窗口一
```
mysql> update bb set name='bbb';
```

#step 4：窗口三

#是否自动提交
```
mysql> show variables like 'autocommit';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+
```

#查看当前连接
```
mysql> show processlist;
mysql> show full processlist;
mysql> SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST;
+----+------+-----------+------+---------+------+-------+------------------+
| Id | User | Host      | db   | Command | Time | State | Info             |
+----+------+-----------+------+---------+------+-------+------------------+
| 4  | root | localhost | test | Sleep   | 244  |       | NULL             |
| 5  | root | localhost | test | Sleep   | 111  |       | NULL             |
| 6  | root | localhost | NULL | Query   | 0    | init  | show processlist |
+----+------+-----------+------+---------+------+-------+------------------+
```
 
#查看当前正在被锁的事务（锁请求超时后则查不到）
```
mysql> SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;
+------------------+-------------+-----------+-----------+-------------+-----------------+------------+-----------+----------+----------------+
| lock_id          | lock_trx_id | lock_mode | lock_type | lock_table  | lock_index      | lock_space | lock_page | lock_rec | lock_data      |
+------------------+-------------+-----------+-----------+-------------+-----------------+------------+-----------+----------+----------------+
| 130718495:65:3:4 | 130718495   | X         | RECORD    | `test`.`bb` | GEN_CLUST_INDEX |   65       |   3       |  4       | 0x000000000300 |
| 130718496:65:3:4 | 130718496   | X         | RECORD    | `test`.`bb` | GEN_CLUST_INDEX |   65       |   3       |  4       | 0x000000000300 |
+------------------+-------------+-----------+-----------+-------------+-----------------+------------+-----------+----------+----------------+
```

#查看当前等待锁的事务（锁请求超时后则查不到）
```
mysql> SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS; 
+-------------------+-------------------+-----------------+------------------+
| requesting_trx_id | requested_lock_id | blocking_trx_id | blocking_lock_id |
+-------------------+-------------------+-----------------+------------------+
| 130718499         | 130718499:65:3:4  | 130718500       | 130718500:65:3:4 |
+-------------------+-------------------+-----------------+------------------+
```
 
#查看当前未提交的事务（如果死锁等待超时,事务可能还没有关闭）
```
mysql> SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;
+--------------------------------------------------------------------------------------------------------+
| trx_id    | trx_state | trx_started         | trx_requested_lock_id | trx_wait_started    | trx_weight |
+-----------+-----------+---------------------+-----------------------+---------------------+------------+
| 130718500 | RUNNING   | 2018-03-12 09:28:10 | NULL                  | NULL                |   3        |
| 130718499 | LOCK WAIT | 2018-03-12 09:27:59 | 130718499:65:3:4      | 2018-03-12 09:32:48 |   5        |
==========================================================================================================
| trx_mysql_thread_id | trx_query                             | trx_operation_state | trx_tables_in_use |
+---------------------+---------------------------------------+---------------------+-------------------+
|     4               | NULL                                  | NULL                |     0             |
|     5               | update bb set name='bbb'              | starting index read |     1             |
=========================================================================================================
| trx_tables_locked | trx_lock_structs | trx_lock_memory_bytes | trx_rows_locked | trx_rows_modified |
+-------------------+------------------+-----------------------+-----------------+-------------------+
|     0             |    2             |     360               |    3            |     1             |
|     1             |    4             |     1184              |    4            |     1             |
===========================================================================================================================
| trx_concurrency_tickets | trx_isolation_level | trx_unique_checks | trx_foreign_key_checks | trx_last_foreign_key_error |
+-------------------------+---------------------+-------------------+------------------------+----------------------------+
|      0                  | REPEATABLE READ     |     1             |      1                 | NULL                       |
|      0                  | REPEATABLE READ     |     1             |      1                 | NULL                       |
===========================================================================================================================
| trx_adaptive_hash_latched | trx_adaptive_hash_timeout | trx_is_read_only | trx_autocommit_non_locking |
+---------------------------+---------------------------+------------------+----------------------------+
|       0                   |      10000                |    0             |       0                    |
|       0                   |      10000                |    0             |       0                    |
+---------------------------+---------------------------+------------------+----------------------------+
```
 
#查看正在被访问的表
```
mysql> show OPEN TABLES where In_use > 0;
+----------+-------+--------+-------------+
| Database | Table | In_use | Name_locked |
+----------+-------+--------+-------------+
| test     | bb    |  1     |   0         |
+----------+-------+--------+-------------+
```

#step 3：窗口一 （若第三步中锁请求太久，则出现锁超时而终止执行）
```
mysql> update bb set name='bbb';
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
``` 
 
#"窗口一" 锁请求超时前，执行第五步，使死锁产生，则该连接 "窗口二" 执行终止，"窗口一" 顺利执行

#step 5：窗口二
```
mysql> update aa set name='aa';
ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
```

#查看最近一个死锁情况
```
mysql> SHOW ENGINE INNODB STATUSG ;
...............
------------------------
LATEST DETECTED DEADLOCK
------------------------
2018-03-12 11:01:06 7ffb4993a700          #发生时间
*** (1) TRANSACTION:                      #事务1
TRANSACTION 130718515, ACTIVE 19 sec starting index read
mysql tables in use 1, locked 1           #正被访问的表
LOCK WAIT 4 lock struct(s), heap size 1184, 4 row lock(s), undo log entries 1             #影响行数
MySQL thread id 5, OS thread handle 0x7ffb498f8700, query id 205 localhost root updating   #线程/连接host/用户
update bb set name='bb'                   #请求语句
*** (1) WAITING FOR THIS LOCK TO BE GRANTED:       #等待以下资源 （锁定位置及锁模式）
RECORD LOCKS space id 65 page no 3 n bits 72 index `GEN_CLUST_INDEX` of table `test`.`bb` trx id 130718515 lock_mode X waiting
Record lock, heap no 5 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 6; hex 000000000300; asc  ;;
 1: len 6; hex 000007ca9b34; asc  4;;
 2: len 7; hex 1f000002092075; asc  u;;
 3: len 4; hex 80000001; asc  ;;
 4: len 2; hex 6262; asc bb;;
 
*** (2) TRANSACTION:                     #事务2
TRANSACTION 130718516, ACTIVE 14 sec starting index read
mysql tables in use 1, locked 1
4 lock struct(s), heap size 1184, 4 row lock(s), undo log entries 1
MySQL thread id 4, OS thread handle 0x7ffb4993a700, query id 206 localhost root updating
update aa set name='aa'                  #请求语句
*** (2) HOLDS THE LOCK(S):               #持有锁资源
RECORD LOCKS space id 65 page no 3 n bits 72 index `GEN_CLUST_INDEX` of table `test`.`bb` trx id 130718516 lock_mode X
Record lock, heap no 1 PHYSICAL RECORD: n_fields 1; compact format; info bits 0
 0: len 8; hex 73757072656d756d; asc supremum;;
 
Record lock, heap no 3 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 6; hex 000000000301; asc  ;;
 1: len 6; hex 000007ca9b17; asc  ;;
 2: len 7; hex 9000000144011e; asc  D ;;
 3: len 4; hex 80000002; asc  ;;
 4: len 2; hex 6262; asc bb;;
 
Record lock, heap no 5 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 6; hex 000000000300; asc  ;;
 1: len 6; hex 000007ca9b34; asc  4;;
 2: len 7; hex 1f000002092075; asc  u;;
 3: len 4; hex 80000001; asc  ;;
 4: len 2; hex 6262; asc bb;;
 
*** (2) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 64 page no 3 n bits 80 index `GEN_CLUST_INDEX` of table `test`.`aa` trx id 130718516 lock_mode X waiting
Record lock, heap no 7 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 6; hex 000000000200; asc  ;;
 1: len 6; hex 000007ca9b33; asc  3;;
 2: len 7; hex 1e000001d53057; asc  0W;;
 3: len 4; hex 80000001; asc  ;;
 4: len 2; hex 6161; asc aa;;
 
*** WE ROLL BACK TRANSACTION (2)
...............
```

#死锁记录只记录最近一个死锁信息，若要将每个死锁信息都保存到错误日志，启用以下参数：
```
mysql> show variables like 'innodb_print_all_deadlocks';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| innodb_print_all_deadlocks | OFF   |
+----------------------------+-------+
```
 
#上面 【step 3：窗口一】若一直请求不到资源，默认50秒则出现锁等待超时。
```
mysql> show variables like 'innodb_lock_wait_timeout'; 
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_lock_wait_timeout | 50    |
+--------------------------+-------+
 
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
```
 
#设置全局变量 锁等待超时为60秒（新的连接生效）
```
#mysql> set session innodb_lock_wait_timeout=50; 
mysql> set global innodb_lock_wait_timeout=60; 
```
 
#上面测试中，当事务中的某个语句超时只回滚该语句，事务的完整性属于被破坏了。为了回滚这个事务，启用以下参数：
```
mysql> show variables like 'innodb_rollback_on_timeout';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| innodb_rollback_on_timeout | OFF   |
+----------------------------+-------+
```

最终参数设置如下：(重启服务重新连接测试)
```
[mysqld]
log-error =/var/log/mysqld3306.log
innodb_lock_wait_timeout=60  #锁请求超时时间(秒)
innodb_rollback_on_timeout = 1 #事务中某个语句锁请求超时将回滚真个事务
innodb_print_all_deadlocks = 1 #死锁都保存到错误日志
```

#若手动删除堵塞会话，删除 Command='Sleep' 、无State、无Info、trx_weight 权重最小的。
```
show processlist;
SELECT trx_mysql_thread_id,trx_state,trx_started,trx_weight FROM INFORMATION_SCHEMA.INNODB_TRX;
```

总结:

到此这篇关于MySQL死锁检查处理的文章就介绍到这了,更多相关MySQL死锁检查处理内容请搜索我们以前的文章或继续浏览下面的相关文章希望大家以后多多支持我们！
