官网介绍：https://dev.mysql.com/doc/refman/8.0/en/show-processlist.html

1、通过 `SHOW FULL PROCESSLIST`命令查看info信息，会提示锁的语句

| 序号 | 字段 | 含义 |
|------|-----|------|
| 1 | Id | 链接mysql 服务器线程的唯一标识，可以通过kill来终止此线程的链接。 |
| 2 | User | 当前线程链接数据库的用户 |
| 3 | Host | 显示这个语句是从哪个ip 的哪个端口上发出的。可用来追踪出问题语句的用户 |
| 4 | db | 线程链接的数据库，如果没有则为null |
| 5 | Command | 显示当前连接的执行的命令，一般就是休眠或空闲（sleep），查询（query），连接（connect） |
| 6 | Time | 线程处在当前状态的时间，单位是秒 |
| 7 | State | 显示使用当前连接的sql语句的状态，很重要的列，后续会有所有的状态的描述，请注意，state只是语句执行中的某一个状态，一个 sql语句，已查询为例，可能需要经过copying to tmp table，Sorting result，Sending data等状态才可以完成 |
| 8 | Info | 显示执行的 SQL 语句 |

State 列的状态

| State状态 | 描述 |
|----------|------|
| Checking table | 检查表 | 
| Closing tables | 将表中修改的数据刷新（Flush）到磁盘中，同时关闭已经用完的表 | 
| Copying to tmp table on disk | 内存存储转换为硬盘存储 | 
| Creating tmp table | 创建临时表 | 
| deleting from main table | 多表删除中的第一步 | 
| deleting from reference tables | 多表删除中的第二步 | 
| Flushing tables | FLUSH TABLES，等待其他线程关闭数据 | 
| Locked | 查询有锁 | 
| Sending data | 正在执行 SELECT 查询，然后把结果发送给客户端 | 
| Sorting for group | 正在为分组排序 | 
| Sorting for order | 正在排 | 

```
mysql> SHOW FULL PROCESSLIST;
+----+------+-----------+------+---------+------+-------+------------------+
| Id | User | Host      | db   | Command | Time | State | Info             |
+----+------+-----------+------+---------+------+-------+------------------+
| 4  | root | localhost | test | Sleep   | 244  |       | NULL             |
| 5  | root | localhost | test | Sleep   | 111  |       | NULL             |
| 6  | root | localhost | NULL | Query   | 0    | init  | show processlist |
+----+------+-----------+------+---------+------+-------+------------------+
```

show processlist 显示的查询结果来自 information_schema 中的 processlist 表，可以用下述查询代替：
```
mysql> select * from information_schema.processlist
```


2、通过`kill` 命令杀死的死锁的线程
```
kill 2454;
```


3、可以通过如下命令批量删除死锁线程
```
mysql> select concat('KILL ',id,';') from information_schema.processlist where user='root' and time > 200 into outfile '/tmp/a.txt'

mysql> source /tmp/a.txt;
```

