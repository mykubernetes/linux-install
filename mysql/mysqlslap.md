mysqlslap是mysql自带的基准测试工具,可以模拟多个客户端同时并发的向服务器发出查询更新,给出了性能测试数据而且提供了多种引擎的性能比较。mysqlslap为mysql性能优化前后提供了直观的验证依据.

1、更改其默认的最大连接数  
在对MySQL进行压力测试之前，需要更改其默认的最大连接数
```
# vim /etc/my.cnf 
................
[mysqld]
max_connections=1024
[root@mysql ~]# systemctl restart mysqld
```

2、登录MySQL查看最大连接数是否生效
```
#查看最大连接数
mysql> show variables like 'max_connections';       
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 1024  |
+-----------------+-------+
1 row in set (0.00 sec)
```


3、进行压力测试
```
# mysqlslap --defaults-file=/etc/my.cnf --concurrency=100,200 --iterations=1 --number-int-cols=20 --number-char-cols=30 --auto-generate-sql --auto-generate-sql-add-autoincrement --auto-generate-sql-load-type=mixed --engine=myisam,innodb --number-of-queries=2000 -uroot -p123 --verbose
```

模拟测试两次读写并发，第一次100，第二次200，自动生成SQL脚本，测试表包含20个init字段，30 个char字段，每次执行2000查询请求。测试引擎分别是myisam，innodb。（上述选项中有很多都是默认值，可以省略，如果想要了解各个选项的解释，可以使用mysqlslap --help进行查询）
