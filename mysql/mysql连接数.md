查询mysql进程，因为数据库的sleep连接很多（一般都会在几千个左右），不建议直接show processlist或者show full Processlist

查看当前级别最大连接数
```
show variables like 'max_connections';
```

查看当前最大连接数
```
show global status like 'Threads_connected';
```

查看当前连接数
```
show status like 'Threads%'
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

查询mysql服务器最大连接数、当前数据库连接数和running数show global variables like ‘max_connections‘;
```
show global status like ‘Threads%‘;
```

查询用户最大连接数
```
show grants for ‘mysql_bi‘;
```



杀掉慢查询进程，可以针对用户，执行时间去操作
```
select concat(‘KILL ‘,id,‘;‘) frominformation_schema.processlist where user=‘用户名称‘ and time>100into outfile ‘/tmp/aa.txt‘;
source/tmp/aa.txt 
```
