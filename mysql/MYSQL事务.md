含义
---
事务：一条或多条sql语句组成一个执行单位，一组sql语句要么都执行要么都不执行

- 概念：在mysql中的数据用各种不同的技术存储在文件（或内存）中。
- 通过show engines；来查看mysql支持的存储引擎。
- 在mysql中用的最多的存储引擎有：innodb，myisam ,memory 等。其中innodb支持事务，而myisam、memory等不支持事务


特点（ACID）
---
- A 原子性：一个事务是不可再分割的整体，要么都执行要么都不执行
- C 一致性：一个事务可以使数据从一个一致状态切换到另外一个一致的状态
- I 隔离性：一个事务不受其他事务的干扰，多个事务互相隔离的
- D 持久性：一个事务一旦提交了，则永久的持久化到本地

隐式（自动）事务：没有明显的开启和结束，本身就是一条事务可以自动提交，比如insert、update、delete

显式事务：具有明显的开启和结束

执行事务步骤
---
```
1、开启事务
set autocommit=0;
start transaction;#可以省略

2、编写一组逻辑sql语句
sql语句支持的是insert、update、delete

3、结束事务
提交：commit;
回滚：rollback;
```

并发事务
---
1、事务的并发问题是如何发生的？
- 多个事务 同时 操作 同一个数据库的相同数据时

2、并发问题都有哪些？
- 脏读：一个事务读取了其他事务还没有提交的数据，读到的是其他事务“更新”的数据
- 不可重复读：一个事务多次读取，结果不一样
- 幻读：一个事务读取了其他事务还没有提交的数据，只是读到的是 其他事务“插入”的数据

3、如何解决并发问题
- 通过设置隔离级别来解决并发问题

4、隔离级别
|  	| 脏读 | 不可重复读 | 幻读 |
| :------: | :--------: | :------: | :------: |
| read uncommitted:读未提交 | × | × | × |
| read committed：读已提交 | √ | × | × |
| repeatable read：可重复读 | √ | √ | × |
| serializable：串行化 | √ | √ | √ |


```
# 查看当前隔离级别
mysql> select @@tx_isolation;
+-----------------+
| @@tx_isolation  |
+-----------------+
| REPEATABLE-READ |
+-----------------+
1 row in set, 1 warning (0.00 sec)

# 设置当前会话隔离级别
set session transaction isolation leve red uncommitted;

# 设置数据库系统的全局隔离级别
set global session transaction isolation leve red uncommitted;
```
