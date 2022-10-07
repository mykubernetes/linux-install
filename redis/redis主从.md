# 一、主从的概念

- 主Redis写入数据时，从Redis会通过Redis Sync机制，同步数据，确保数据一致。并且Redis有哨兵(Sentinel)机制，Redis主挂掉会自动帮我们提升从为主，不过哨兵我发现只适用一主多从，不太适合级联模式。
- ⼀个master可以拥有多个slave，⼀个slave⼜可以拥有多个slave，如此下去，形成了强大的多级服务器集群架构
- master用来写数据，slave用来读数据，经统计：网站的读写比率是10:1
- 通过主从配置可以实现读写分离
- master和slave都是一个redis实例(redis服务)

# 二、主从的配置

## 配置主服务器 master

1、查看master ip
```
[root@10-23-117-188 ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1452 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:fe:c2:c8 brd ff:ff:ff:ff:ff:ff
    inet 11.23.119.188/16 brd 10.23.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fefe:c2c8/64 scope link 
       valid_lft forever preferred_lft forever
```

2、设置redis.conf文件
```
[root@10-23-117-188 ~]# cd /usr/local/redis-6.0.8/bin/
[root@10-23-117-188 bin]# ls
backup.db  dump.rdb  redis-benchmark  redis-check-aof  redis-check-rdb  redis-cli  redis.conf  redis-sentinel  redis-server
[root@10-23-117-188 bin]# 
```

3、修改redis.conf配置
```
vim redis.conf

修改配置
bind 11.23.119.188 127.0.0.1    #绑定redis服务器网卡IP，默认为127.0.0.1,即本地回环地址。
protected-mode no               #保护模式，默认是开启状态，只允许本地客户端连接
daemonize yes                   #默认情况下redis不是作为守护进程运行的。当redis作为守护进程运行的时候，它会写一个 pid 到 /var/run/redis.pid 文件里面。
appendonly yes                  #默认redis使用的是rdb方式持久化。
requirepass 123456              #redis连接密码

重启redis服务器（先杀死进程，在加载配置文件启动）
[root@10-23-117-188 bin]# ps -aux |grep redis
root       7048  0.1  0.5 173316  9688 ?        Ssl  14:35   0:09 ./redis-server 10.23.117.188:6379
root      11323  0.0  0.1 112828  2296 pts/0    R+   16:25   0:00 grep --color=auto redis
[root@10-23-117-188 bin]# kill -9 7048      
[root@10-23-117-188 bin]# ./redis-server ./redis.conf 
You have new mail in /var/spool/mail/root
```

## 配置从服务器slave

1、查看slave ip
```
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:24:9c:4e brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.111/24 brd 192.168.0.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::7e0f:4e94:3afd:ae55/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

2、设置redis.conf文件
```
[root@localhost ~]# cd /usr/local/redis-5.0.4/bin/
[root@localhost bin]# ls
dump.rdb  redis-benchmark  redis-check-aof  redis-check-rdb  redis-cli  redis.conf  redis-sentinel  redis-server
```

打开redis.conf文件
```
[root@localhost bin]# vim redis.conf

修改配置
bind 192.168.0.111 127.0.0.1
slaveof 106.75.226.106 6379                # 主节点的ip和端口
port 6379
masterauth 123456                          # 验证master的密码，此密码为master的密码
requirepass 123456                         # 给slave设置密码
重启redis服务器（先杀死进程，在加载配置文件启动）
```

# 查看主从关系

1、在master下 输入 redis-cli -h 11.23.119.188 info replication -a 123456(主master密码)
```
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:master
connected_slaves:1
slave0:ip=111.19.42.76,port=6379,state=online,offset=3458,lag=0
master_replid:22dc694b36c6634f14ef9f1718fd0c8f0b81e1a1
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:3458
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:3458
You have new mail in /var/spool/mail/root
```

2、在slave下输入 redis-cli -h 192.168.0.111（slave绑定的ip） -a 123456(从slave密码)
```
[root@localhost bin]# ./redis-cli -h 192.168.0.111 -p 6379 -a 123456 info replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:slave
master_host:106.75.226.106
master_port:6379
master_link_status:up
master_last_io_seconds_ago:3
master_sync_in_progress:0
slave_repl_offset:4494
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:22dc694b36c6634f14ef9f1718fd0c8f0b81e1a1
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:4494
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:4494
```

# 验证主从读写功能master（读写）slave（只读）

- masert端
```
[root@10-23-117-188 bin]# redis
127.0.0.1:6379> set name laowang
(error) NOAUTH Authentication required.
127.0.0.1:6379> 
```

提示没有验证，输入密码即可 auth 123456
```
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> set name laowang
OK
127.0.0.1:6379> get name
"laowang"
127.0.0.1:6379> 
```

- slave端
```
[root@localhost bin]# redis
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> get name
"laowang"
127.0.0.1:6379> set age 18
(error) READONLY You can't write against a read only replica.
127.0.0.1:6379> 
```
由上验证了slave端只能读不能写，master端可读可写。


# 配置哨兵

启动哨兵进程首先需要创建哨兵配置文件
```
vim sentinel.conf
输入内容：
sentinel monitor taotaoMaster 127.0.0.1 6379 1
```
- taotaoMaster：监控主数据的名称，自定义即可，可以使用大小写字母和“.-_”符号
- 127.0.0.1：监控的主数据库的IP
- 6379：监控的主数据库的端口
- 1：最低通过票数

启动哨兵进程：
```
redis-sentinel ./sentinel.conf
```

