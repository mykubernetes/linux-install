查询mysql进程，因为数据库的sleep连接很多（一般都会在几千个左右），不建议直接show processlist或者show full Processlist

# Mysql 链接数过大或经常链接超时的排错方法

1、允许的最大连接数
```
mysql> show variables like "%max_connections%";
±----------------±--------+
| Variable_name  | Value  |
±----------------±--------+
| max_connections|  10000 |
±----------------±--------+
1 row in set (0.00 sec)
```

2、当前连接数
```
show global status like 'Threads_connected';
±------------------±-------+
| Variable_name    | Value |
±------------------±-------+
| Threads_connected|  9045 |
±------------------±-------+
1 row in set (0.00 sec)
```

3、获得最大一次的连接数
```
mysql> show global status like 'Max_used_connections';
+----------------------+-------+
| Variable_name        | Value |
+----------------------+-------+
| Max_used_connections | 11    |
+----------------------+-------+
1 row in set (0.00 sec)
```

4、修改最大链接数，重启后失效
```
mysql> set global max_connections = 1000;
```

5、要查出那个ip或那个微服务占用太多资源，用mysql客户端进入information_schema数据库查看
```
select SUBSTRING_INDEX(host,':',1) as ip , count(*) from information_schema.processlist group by ip;
```

6、依照服务名查看使用状况
```
select count(*),db from information_schema.processlist group by db
```

查看当前连接数
```
show status like 'Threads%'
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| Threads_cached    | 2     |
+-------------------+-------+
| Threads_connected | 9049  |
+-------------------+-------+
| Threads_created   | 59376 |
+-------------------+-------+
| Threads_running   | 3     |
+-------------------+-------+
1 row in set (0.00 sec)
```
- Thread_cached:被缓存的线程的个数
- Thread_running：处于激活状态的线程的个数
- Thread_connected：当前连接的线程的个数
- Thread_created：总共被创建的线程的个数

```
mysql> show processlist;
+----+------+-----------+-------+---------+------+-------+------------------+
| Id | User | Host      | db    | Command | Time | State | Info             |
+----+------+-----------+-------+---------+------+-------+------------------+
|  2 | root | localhost | mysql | Sleep   |    4 |       | NULL             |
|  3 | root | localhost | test  | Query   |    0 | init  | show processlist |
+----+------+-----------+-------+---------+------+-------+------------------+
rows in set (0.00 sec)


mysql> show full processlist
```

尽量去用select查询

正在running的线程
```
select count(*) from information_schema.processlist where info is not null;
```

Mysql的全部线程
```
select count(*) from information_schema.processlist;
```

查询当前running sql执行时间最长的10条
```
select * frominformation_schema.processlist where info is not null order by time desc limit10 ;
```

查询执行sql的ip 的连接数量
```
select left(host,instr(host,‘:‘)-1) asip,count(*) as num from information_schema.processlist group by ip order by num desc;
```

查询执行sql的user的连接数量
```
select user,count(*) as num from  information_schema.processlist group by userorder by num desc;
```

查询执行sql语句的数量
```
select count(*) as num,info from  information_schema.processlist where info isnot null group by info order by num;
```

查询mysql服务器最大连接数、当前数据库连接数和running数show global variables like 'max_connections';
```
show global status like 'Threads%';
```

查询用户最大连接数
```
show grants for 'mysql_bi';
```

参考：
- https://www.codercto.com/a/108302.html
- https://blog.csdn.net/qq_36652619/article/details/88289668
- https://blog.csdn.net/zhougubei/article/details/120745840
- https://blog.csdn.net/magic_kid_2010/article/details/109670647
