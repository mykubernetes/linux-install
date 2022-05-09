# 一、基于Redis 4 的 redis cluster 部署

## 1、准备redis Cluster 基本配置
- 1. 每个redis 节点采用相同的硬件配置、相同的密码、相同的redis版本
- 2. 所有redis服务器必须没有任何数据
- 3. 准备三台CentOS 7 主机，已编译安装好redis，各启动两个redis实例，分别使用6379和6380端口，从而模拟实现6台redis实例

```
10.0.0.7:6379|6380
10.0.0.17:6379|6380
10.0.0.27:6379|6380
```

范例: 6个物理节点环境的基于脚本安装后批量修改配置
```
[root@centos7 ~]#sed -i -e '/^# masterauth/a masterauth 123456' \
                 -e '/# cluster-enabled yes/a cluster-enabled yes' \
                 -e '/# cluster-config-file nodes-6379.conf/a cluster-config-file nodes-6379.conf' \
                 -e '/cluster-require-full-coverage yes/c cluster-require-full-coverage no' /apps/redis/etc/redis.conf

[root@centos7 ~]#grep '^[^#]' /apps/redis/etc/redis.conf
bind 0.0.0.0
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /apps/redis/run/redis_6379.pid
loglevel notice
logfile /apps/redis/log/redis-6379.log
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /apps/redis/data/
masterauth 123456
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
requirepass 123456
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no
lua-time-limit 5000
cluster-enabled yes
cluster-config-file nodes-6379.conf
cluster-require-full-coverage no
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
```

准备6个实例：在三个主机上重复下面的操作

范例: 3个节点
```
#在三台主机上都编译安装redis
[root@redis-node1 ~]#yum -y install gcc jemalloc-devel 
[root@redis-node1 ~]#cd /usr/local/src
[root@redis-node1 src]#wget http://download.redis.io/releases/redis-4.0.14.tar.gz
[root@redis-node1 src]#tar xf redis-4.0.14.tar.gz
[root@redis-node1 src]#cd redis-4.0.14
[root@redis-node1 redis-4.0.14]#make PREFIX=/apps/redis install 

#准备相关文件和目录
[root@redis-node1 redis-4.0.14]#ln -s /apps/redis/bin/redis-* /usr/bin/
[root@redis-node1 redis-4.0.14]#mkdir -p /apps/redis/{etc,log,data,run}
[root@redis-node1 redis-4.0.14]#cp redis.conf /apps/redis/etc/

#准备用户
[root@redis-node1 ~]#useradd -r -s /sbin/nologin redis

#配置权限和相关优化配置
[root@redis-node1 ~]#chown -R redis.redis /apps/redis
[root@redis-node1 ~]#cat >> /etc/sysctl.conf <<EOF
net.core.somaxconn = 1024
vm.overcommit_memory = 1
EOF

[root@redis-node1 ~]#sysctl -p 
[root@redis-node1 ~]#echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local
[root@redis-node1 ~]#chmod +x /etc/rc.d/rc.local
[root@redis-node1 ~]#/etc/rc.d/rc.local

#准备service文件
[root@redis-node1 ~]#cat > /usr/lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis persistent key-value database
After=network.target
[Service]
ExecStart=/apps/redis/bin/redis-server /apps/redis/etc/redis.conf --supervised systemd
ExecStop=/bin/kill -s QUIT \$MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
[Install]
WantedBy=multi-user.target
EOF

[root@redis-node1 ~]#systemctl daemon-reload
[root@redis-node1 ~]#systemctl enable --now redis

#准备6379的实例配置文件
[root@redis-node1 ~]#systemctl stop redis
[root@redis-node1 ~]#cd /apps/redis/etc/
[root@redis-node1 etc]#sed -i -e 's/bind 127.0.0.1/bind 0.0.0.0/' \
                       -e '/^# masterauth/a masterauth 123456' \
                       -e '/# requirepass/a requirepass 123456' \
                       -e '/# cluster-enabled yes/a cluster-enabled yes' \
                       -e '/# cluster-config-file nodes-6379.conf/a cluster-config-file nodes-6379.conf' \
                       -e 's/^dir .*/dir \/apps\/redis\/data/' \
                       -e '/appendonly no/c appendonly yes' \
                       -e '/logfile ""/c logfile "/apps/redis/log/redis-6379.log"' \
                       -e '/^pidfile .*/c pidfile /apps/redis/run/redis_6379.pid' /apps/redis/etc/redis.conf

#准备6380端口的实例的配置文件
[root@redis-node1 etc]#cp -p redis.conf redis6380.conf 
[root@redis-node1 etc]#sed -i -e 's/6379/6380/' \
                      -e 's/dbfilename dump\.rdb/dbfilename dump6380.rdb/' \
                      -e 's/appendfilename "appendonly\.aof"/appendfilename "appendonly6380.aof"/' /apps/redis/etc/redis6380.conf

#准备服务文件
[root@redis-node1 ~]#cp /lib/systemd/system/redis.service /lib/systemd/system/redis6380.service
[root@redis-node1 ~]#sed -i 's/redis.conf/redis6380.conf/' /lib/systemd/system/redis6380.service

#启动服务，查看到端口都打开
[root@redis-node1 ~]#systemctl daemon-reload 
[root@redis-node1 ~]#systemctl enable --now redis redis6380
[root@redis-node1 ~]#ss -ntl

State       Recv-Q Send-Q   Local Address:Port     Peer Address:Port             
LISTEN      0      100            127.0.0.1:25                   *:*               
LISTEN      0      128                 *:16379                   *:*               
LISTEN      0      128                 *:16380                   *:*               
LISTEN      0      128                  *:6379                   *:*               
LISTEN      0      128                  *:6380                   *:*               
LISTEN      0      128                    *:22                   *:*               
LISTEN      0      100                [::1]:25                [::]:*               
LISTEN      0      128                 [::]:22                [::]:*               
    
[root@redis-node1 ~]#ps -ef|grep redis
redis 71539   1  0 22:13 ?   00:00:00 /apps/redis/bin/redis-server 0.0.0.0:6379 
[cluster]
redis 71543   1  0 22:13 ?   00:00:00 /apps/redis/bin/redis-server 0.0.0.0:6380 
[cluster]
root  71553  31781  0 22:15 pts/0 00:00:00 grep --color=auto redis
[root@redis-node1 ~]#tree /apps/redis/
/apps/redis
├── bin
│   ├── redis-benchmark
│   ├── redis-check-aof
│   ├── redis-check-rdb
│   ├── redis-cli
│   ├── redis-sentinel -> redis-server
│   └── redis-server
├── data
│   ├── appendonly6380.aof
│   ├── appendonly.aof
│   ├── nodes-6379.conf
│   └── nodes-6380.conf
├── etc
│   ├── redis6380.conf
│   └── redis.conf
├── log
│   ├── redis-6379.log
│   └── redis-6380.log
└── run
   ├── redis_6379.pid
   └── redis_6380.pid
5 directories, 16 files
```

## 2、准备redis-trib.rb工具
Redis 3和 4版本需要使用到集群管理工具redis-trib.rb，这个工具是redis官方推出的管理redis集群的工具，集成在redis的源码src目录下，是基于redis提供的集群命令封装成简单、便捷、实用的操作工具，redis-trib.rb是redis作者用ruby开发完成的，centos 7 系统yum安装的ruby存在版本较低问题，如下：
```
[root@redis-node1 ~]#find / -name redis-trib.rb
/usr/local/src/redis-4.0.14/src/redis-trib.rb

[root@redis-node1 ~]#cp /usr/local/src/redis-4.0.14/src/redis-trib.rb /usr/bin/

[root@redis-node1 ~]#redis-trib.rb                         #缺少ruby环境无法运行rb脚本
/usr/bin/env: ruby: No such file or directory

#CentOS 7带的ruby版本过低,无法运行上面ruby脚本,需要安装2.3以上版本,安装rubygems依赖ruby自动安装
[root@redis-node1 ~]#yum install rubygems -y  
[root@redis-node1 ~]#gem install redis #gem相当于python里pip和linux的yum
Fetching: redis-4.1.3.gem (100%)
ERROR: Error installing redis:
 redis requires Ruby version >= 2.3.0.
```

1、解决ruby版本较低问题：
```
[root@redis-node1 ~]#yum -y install gcc openssl-devel zlib-devel
[root@redis-node1 ~]#wget https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.5.tar.gz
[root@redis-node1 ~]#tar xf ruby-2.5.5.tar.gz
[root@redis-node1 ~]#cd ruby-2.5.5
[root@redis-node1 ruby-2.5.5]#./configure
[root@redis-node1 ruby-2.5.5]#make -j 2 && make install
[root@redis-node1 ruby-2.5.5]#which ruby
/usr/local/bin/ruby

[root@redis-node1 ruby-2.5.5]# ruby -v
ruby 2.5.5p157 (2019-03-15 revision 67260) [x86_64-linux]
[root@redis-node1 ruby-2.5.5]#exit                  #注意需要重新登录
```

2、redis-trib.rb 仍无法运行错误
```
[root@redis-node1 ~]#redis-trib.rb -h
Traceback (most recent call last):
   2: from /usr/bin/redis-trib.rb:25:in `<main>'
   1: from /usr/local/lib/ruby/2.5.0/rubygems/core_ext/kernel_require.rb:59:in `require'
/usr/local/lib/ruby/2.5.0/rubygems/core_ext/kernel_require.rb:59:in `require': cannot load such file -- redis (LoadError)
```

解决上述错误：
```
[root@redis-node1 ~]#gem install redis -v 4.1.3           #注意需要重新登录再执行,否则无法识别到新ruby版本
Fetching: redis-4.1.3.gem (100%)
Successfully installed redis-4.1.3
Parsing documentation for redis-4.1.3
Installing ri documentation for redis-4.1.3
Done installing documentation for redis after 1 seconds
1 gem installed

#gem uninstall redis 可以卸载已安装好redis模块
```

如果无法在线安装，可以下载redis模块安装包离线安装
```
#https://rubygems.org/gems/redis #先下载redis模块安装包
[root@redis-node1 ~]#gem install -l redis-4.1.3.gem #安装redis模块
```

## 3、redis-trib.rb 命令用法
```
[root@redis-node1 ~]#redis-trib.rb
Usage: redis-trib <command> <options> <arguments ...>
create        host1:port1 ... hostN:portN   #创建集群
              --replicas <arg>              #指定每个master的副本数量,即对应slave数量,一般为1 
check         host:port                     #检查集群信息
info          host:port                     #查看集群主机信息
fix           host:port                     #修复集群
              --timeout <arg>
reshard host:port                           #在线热迁移集群指定主机的slots数据
              --from <arg>
              --to <arg>
              --slots <arg>
              --yes
              --timeout <arg>
              --pipeline <arg>
rebalance host:port                        #平衡集群中各主机的slot数量
              --weight <arg>
              --auto-weights
              --use-empty-masters
              --timeout <arg>
              --simulate
              --pipeline <arg>
              --threshold <arg>
add-node new_host:new_port existing_host:existing_port      #添加主机到集群
              --slave
              --master-id <arg>
del-node host:port node_id                 #删除主机
set-timeout host:port milliseconds         #设置节点的超时时间
call host:port command arg arg .. arg      #在集群上的所有节点上执行命令
import host:port                           #导入外部redis服务器的数据到当前集群
              --from <arg>
              --copy
              --replace
help          (show this help)
```

## 4、修改密码 redis 登录密码
```
#修改redis-trib.rb连接redis的密码
[root@redis ~]#vim /usr/local/lib/ruby/gems/2.5.0/gems/redis-4.1.3/lib/redis/client.rb
        DEFAULTS = {
          : url => lambda { ENV["REDIS_URL"] },
          : scheme => "redus",
          : host => "127.0.0.1",
          : port => 6379,
          : path => nil,
          : timeout => 5.0,
          : password => 123456,                 #数据库密码
          : db => 0,
          : dirver => nil,
          : id => nil,
          : tcp_keepalive => 0,
          : reconnect_attempts => 1,
          : reconnect_delay => 0,
          : reconnect_delay_max => 0.5,
          : inherit_socket => false
        }
```

## 5、创建redis cluster集群
```
#确保三台主机6个实例都启动状态
[root@redis-node1 ~]#systemctl is-active redis redis6380
active
active

[root@redis-node2 ~]#systemctl is-active redis redis6380
active
active

[root@redis-node3 ~]#systemctl is-active redis redis6380
active
active

#在第一个主机上执行下面操作
#--replicas 1 表示每个 master 分配一个 slave 节点,前三个节点自动划分为master,后面都为slave节点
[root@redis-node1 ~]#redis-trib.rb create --replicas 1 10.0.0.7:6379 10.0.0.17:6379 10.0.0.27:6379 10.0.0.7:6380 10.0.0.17:6380 10.0.0.27:6380 
>>> Creating cluster
>>> Performing hash slots allocation on 6 nodes...
Using 3 masters:
10.0.0.7:6379
10.0.0.17:6379
10.0.0.27:6379
Adding replica 10.0.0.17:6380 to 10.0.0.7:6379
Adding replica 10.0.0.27:6380 to 10.0.0.17:6379
Adding replica 10.0.0.7:6380 to 10.0.0.27:6379
M: 739cb4c9895592131de418b8bc65990f81b75f3a 10.0.0.7:6379
   slots:0-5460 (5461 slots) master
S: 0e0beba04cc98da02ebdb5225a11b84aa8062e10 10.0.0.7:6380
   replicates a01fd3d81922d6752f7c960f1a75b6e8f28d911b
M: dddabb4e19235ec02ae96ab2ce67e295ce0274d7 10.0.0.17:6379
   slots:5461-10922 (5462 slots) master
S: 34708909088ba562decbc1525a9606e088bdddf1 10.0.0.17:6380
   replicates 739cb4c9895592131de418b8bc65990f81b75f3a
M: a01fd3d81922d6752f7c960f1a75b6e8f28d911b 10.0.0.27:6379
   slots:10923-16383 (5461 slots) master
S: aefc6203958859024b8383b2fdb87b9e09411ccd 10.0.0.27:6380
   replicates dddabb4e19235ec02ae96ab2ce67e295ce0274d7
Can I set the above configuration? (type 'yes' to accept): yes      #输入yes 
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join....
>>> Performing Cluster Check (using node 10.0.0.7:6379)
M: 739cb4c9895592131de418b8bc65990f81b75f3a 10.0.0.7:6379
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
S: 0e0beba04cc98da02ebdb5225a11b84aa8062e10 10.0.0.7:6380
   slots: (0 slots) slave
   replicates a01fd3d81922d6752f7c960f1a75b6e8f28d911b
S: 34708909088ba562decbc1525a9606e088bdddf1 10.0.0.17:6380
   slots: (0 slots) slave
   replicates 739cb4c9895592131de418b8bc65990f81b75f3a
S: aefc6203958859024b8383b2fdb87b9e09411ccd 10.0.0.27:6380
   slots: (0 slots) slave
   replicates dddabb4e19235ec02ae96ab2ce67e295ce0274d7
M: a01fd3d81922d6752f7c960f1a75b6e8f28d911b 10.0.0.27:6379
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
M: dddabb4e19235ec02ae96ab2ce67e295ce0274d7 10.0.0.17:6379
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

如果有之前的操作导致Redis集群创建报错，则执行清空数据和集群命令：
```
127.0.0.1:6379> FLUSHALL
OK
127.0.0.1:6379> cluster reset
OK
```

## 6、查看 redis cluster 集群状态

- 自动生成配置文件记录master/slave对应关系
```
[root@redis-node1 ~]#cat /apps/redis/data/nodes-6379.conf 
0e0beba04cc98da02ebdb5225a11b84aa8062e10 10.0.0.7:6380@16380 slave a01fd3d81922d6752f7c960f1a75b6e8f28d911b 0 1582383256000 5 connected
34708909088ba562decbc1525a9606e088bdddf1 10.0.0.17:6380@16380 slave 739cb4c9895592131de418b8bc65990f81b75f3a 0 1582383256216 4 connected
aefc6203958859024b8383b2fdb87b9e09411ccd 10.0.0.27:6380@16380 slave dddabb4e19235ec02ae96ab2ce67e295ce0274d7 0 1582383257000 6 connected
739cb4c9895592131de418b8bc65990f81b75f3a 10.0.0.7:6379@16379 myself,master - 01582383256000 1 connected 0-5460
a01fd3d81922d6752f7c960f1a75b6e8f28d911b 10.0.0.27:6379@16379 master - 01582383258230 5 connected 10923-16383
dddabb4e19235ec02ae96ab2ce67e295ce0274d7 10.0.0.17:6379@16379 master - 01582383257223 3 connected 5461-10922vars currentEpoch 6 lastVoteEpoch 0
[root@redis-node1 ~]#
```

查看状态
```
[root@redis-node1 ~]#redis-trib.rb info 10.0.0.7:6379
10.0.0.7:6379 (739cb4c9...) -> 0 keys | 5461 slots | 1 slaves.
10.0.0.27:6379 (a01fd3d8...) -> 0 keys | 5461 slots | 1 slaves.
10.0.0.17:6379 (dddabb4e...) -> 0 keys | 5462 slots | 1 slaves.
[OK] 0 keys in 3 masters.
0.00 keys per slot on average.

[root@redis-node1 ~]#redis-trib.rb check 10.0.0.7:6379
>>> Performing Cluster Check (using node 10.0.0.7:6379)
M: 739cb4c9895592131de418b8bc65990f81b75f3a 10.0.0.7:6379
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
S: 0e0beba04cc98da02ebdb5225a11b84aa8062e10 10.0.0.7:6380
   slots: (0 slots) slave
   replicates a01fd3d81922d6752f7c960f1a75b6e8f28d911b
S: 34708909088ba562decbc1525a9606e088bdddf1 10.0.0.17:6380
   slots: (0 slots) slave
   replicates 739cb4c9895592131de418b8bc65990f81b75f3a
S: aefc6203958859024b8383b2fdb87b9e09411ccd 10.0.0.27:6380
   slots: (0 slots) slave
   replicates dddabb4e19235ec02ae96ab2ce67e295ce0274d7
M: a01fd3d81922d6752f7c960f1a75b6e8f28d911b 10.0.0.27:6379
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
M: dddabb4e19235ec02ae96ab2ce67e295ce0274d7 10.0.0.17:6379
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

[root@redis-node1 ~]#redis-cli -a 123456
Warning: Using a password with '-a' option on the command line interface may not be safe.
127.0.0.1:6379> CLUSTER INFO
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:252
cluster_stats_messages_pong_sent:277
cluster_stats_messages_sent:529
cluster_stats_messages_ping_received:272
cluster_stats_messages_pong_received:252
cluster_stats_messages_meet_received:5
cluster_stats_messages_received:529
127.0.0.1:6379> 

[root@redis-node1 ~]#redis-cli -a 123456 -p 6379 CLUSTER NODES
Warning: Using a password with '-a' option on the command line interface may not be safe.
29a83275db60f1c8f9f6d39b66cbc6c3d5cf20f1 10.0.0.7:6379@16379 myself,master - 01601985995000 1 connected 0-5460
3e607de412a8a240e8214c2d7a663cf1523412eb 10.0.0.17:6380@16380 slave 29a83275db60f1c8f9f6d39b66cbc6c3d5cf20f1 0 1601985997092 4 connected
17d0b29d2f50ea9c89d4e6e0cf3ee3ee4f7c4179 10.0.0.7:6380@16380 slave 90b206131d89b0812c626677343df9a11ff1d211 0 1601985995075 5 connected
90b206131d89b0812c626677343df9a11ff1d211 10.0.0.27:6379@16379 master - 01601985996084 5 connected 10923-16383
fb34c3a704aefb1e1ef2317b20598d6e1e51c010 10.0.0.17:6379@16379 master - 01601985995000 3 connected 5461-10922
c9ea6113a1992695fb86f5368fe6320349b0f8a6 10.0.0.27:6380@16380 slave fb34c3a704aefb1e1ef2317b20598d6e1e51c010 0 1601985996000 6 connected

[root@redis-node1 ~]#redis-cli -a 123456 -p 6379 INFO replication
Warning: Using a password with '-a' option on the command line interface may not be safe.
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.17,port=6380,state=online,offset=196,lag=0
master_replid:4ee36f9374c796ca4c65a0f0cb2c39304bb2e9c9
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:196
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:196

[root@redis-node1 ~]#redis-cli -a 123456 -p 6380 INFO replication
Warning: Using a password with '-a' option on the command line interface may not be safe.
# Replication
role:slave
master_host:10.0.0.27
master_port:6379
master_link_status:up
master_last_io_seconds_ago:2
master_sync_in_progress:0
slave_repl_offset:224
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:dba41cb31c14de7569e597a3d8debc1f0f114c1e
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:224
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:224
```

## 7、python脚本实现RedisCluster集群写入
```
[root@redis-node1 ~]#yum -y install python3
[root@redis-node1 ~]#pip3 install redis-py-cluster
[root@redis-node1 ~]#vim redis_cluster_test.py
[root@redis-node1 ~]#cat ./redis_cluster_test.py
#!/usr/bin/env python3
from rediscluster import RedisCluster
startup_nodes = [
   {"host":"10.0.0.7", "port":6379},
   {"host":"10.0.0.7", "port":6380},
   {"host":"10.0.0.17", "port":6379},
   {"host":"10.0.0.17", "port":6380},
   {"host":"10.0.0.27", "port":6379},
   {"host":"10.0.0.27", "port":6380}
]
redis_conn= RedisCluster(startup_nodes=startup_nodes,password='123456',decode_responses=True)
for i in range(0, 10000):
   redis_conn.set('key'+str(i),'value'+str(i))
   print('key'+str(i)+':',redis_conn.get('key'+str(i)))

[root@redis-node1 ~]#chmod +x redis_cluster_test.py
[root@redis-node1 ~]#./redis_cluster_test.py
......
key9998: value9998
key9999: value9999
```

验证脚本写入的状态
```
[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.7 DBSIZE
Warning: Using a password with '-a' option on the command line interface may not be safe.
(integer) 3331

[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.17 DBSIZE
Warning: Using a password with '-a' option on the command line interface may not be safe.
(integer) 3340

[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.27 DBSIZE
Warning: Using a password with '-a' option on the command line interface may not be safe.
(integer) 3329

[root@redis-node1 ~]#redis-cli -a 123456 GET key1
Warning: Using a password with '-a' option on the command line interface may not be safe.
(error) MOVED 9189 10.0.0.17:6379

[root@redis-node1 ~]#redis-cli -a 123456 GET key2
Warning: Using a password with '-a' option on the command line interface may not be safe.
"value2"

[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.17 GET key1
Warning: Using a password with '-a' option on the command line interface may not be safe.
"value1"

[root@redis-node1 ~]#redis-trib.rb info 10.0.0.7:6379
10.0.0.7:6379 (739cb4c9...) -> 3331 keys | 5461 slots | 1 slaves.
10.0.0.27:6379 (a01fd3d8...) -> 3329 keys | 5461 slots | 1 slaves.
10.0.0.17:6379 (dddabb4e...) -> 3340 keys | 5462 slots | 1 slaves.
[OK] 10000 keys in 3 masters.
0.61 keys per slot on average.
[root@redis-node1 ~]#
```

## 8、模拟 master 故障，对应的slave节点自动提升为新master
```
[root@redis-node1 ~]#systemctl stop redis

#不会立即提升,需要稍等一会儿再观察下面结果
[root@redis-node1 ~]#redis-trib.rb check 10.0.0.27:6379
>>> Performing Cluster Check (using node 10.0.0.27:6379)
M: a01fd3d81922d6752f7c960f1a75b6e8f28d911b 10.0.0.27:6379
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
S: aefc6203958859024b8383b2fdb87b9e09411ccd 10.0.0.27:6380
   slots: (0 slots) slave
   replicates dddabb4e19235ec02ae96ab2ce67e295ce0274d7
S: 0e0beba04cc98da02ebdb5225a11b84aa8062e10 10.0.0.7:6380
   slots: (0 slots) slave
   replicates a01fd3d81922d6752f7c960f1a75b6e8f28d911b
M: 34708909088ba562decbc1525a9606e088bdddf1 10.0.0.17:6380
   slots:0-5460 (5461 slots) master
   0 additional replica(s)
M: dddabb4e19235ec02ae96ab2ce67e295ce0274d7 10.0.0.17:6379
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

[root@redis-node1 ~]#tail /var/log/messages
Feb 22 23:23:13 centos7 redis-server: 71887:M 22 Feb 23:23:13.656 * Saving the final RDB snapshot before exiting.
Feb 22 23:23:13 centos7 systemd: Stopped Redis persistent key-value database.
Feb 22 23:23:13 centos7 redis-server: 71887:M 22 Feb 23:23:13.660 * DB saved on disk
Feb 22 23:23:13 centos7 redis-server: 71887:M 22 Feb 23:23:13.660 * Removing the pid file.
Feb 22 23:23:13 centos7 redis-server: 71887:M 22 Feb 23:23:13.660 # Redis is now ready to exit, bye bye...
Feb 22 23:23:13 centos7 systemd: Unit redis.service entered failed state.
Feb 22 23:23:13 centos7 systemd: redis.service failed.
Feb 22 23:23:30 centos7 redis-server: 72046:S 22 Feb 23:23:30.077 * FAIL message received from dddabb4e19235ec02ae96ab2ce67e295ce0274d7 about 739cb4c9895592131de418b8bc65990f81b75f3a
Feb 22 23:23:30 centos7 redis-server: 72046:S 22 Feb 23:23:30.077 # Cluster state changed: fail
Feb 22 23:23:30 centos7 redis-server: 72046:S 22 Feb 23:23:30.701 # Cluster state changed: ok

[root@redis-node1 ~]#redis-trib.rb info 10.0.0.27:6379
10.0.0.27:6379 (a01fd3d8...) -> 3329 keys | 5461 slots | 1 slaves.
10.0.0.17:6380 (34708909...) -> 3331 keys | 5461 slots | 0 slaves.
10.0.0.17:6379 (dddabb4e...) -> 3340 keys | 5462 slots | 1 slaves.
[OK] 10000 keys in 3 masters.
0.61 keys per slot on average.
```

将故障的master恢复后，该节点自动加入集群成为新的slave
```
[root@redis-node1 ~]#systemctl start redis
[root@redis-node1 ~]#redis-trib.rb check 10.0.0.27:6379
>>> Performing Cluster Check (using node 10.0.0.27:6379)
M: a01fd3d81922d6752f7c960f1a75b6e8f28d911b 10.0.0.27:6379
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
S: aefc6203958859024b8383b2fdb87b9e09411ccd 10.0.0.27:6380
   slots: (0 slots) slave
   replicates dddabb4e19235ec02ae96ab2ce67e295ce0274d7
S: 739cb4c9895592131de418b8bc65990f81b75f3a 10.0.0.7:6379
   slots: (0 slots) slave
   replicates 34708909088ba562decbc1525a9606e088bdddf1
S: 0e0beba04cc98da02ebdb5225a11b84aa8062e10 10.0.0.7:6380
   slots: (0 slots) slave
   replicates a01fd3d81922d6752f7c960f1a75b6e8f28d911b
M: 34708909088ba562decbc1525a9606e088bdddf1 10.0.0.17:6380
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
M: dddabb4e19235ec02ae96ab2ce67e295ce0274d7 10.0.0.17:6379
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

# 二、Redis cluster集群节点维护

redis 集群运行之后，难免由于硬件故障、网络规划、业务增长等原因对已有集群进行相应的调整， 比如: 增加Redis node节点、减少节点、节点迁移、更换服务器等。增加节点和删除节点会涉及到已有的槽位重新分配及数据迁移。

## 1、集群维护之动态扩容

实战案例：

因公司业务发展迅猛，现有的三主三从的redis cluster架构可能无法满足现有业务的并发写入需求，因此公司紧急采购两台服务器10.0.0.68，10.0.0.78，需要将其动态添加到集群当中，但不能影响业务使用和数据丢失。

注意: 生产环境一般建议master节点为奇数个,比如:3,5,7,以防止脑裂现象

### 1)添加节点准备

增加Redis node节点，需要与之前的Redis node版本相同、配置一致，然后分别再启动两台Redis node，应为一主一从。
```
#配置node7节点
[root@redis-node7 ~]#dnf -y install redis
[root@redis-node7 ~]#sed -i.bak -e 's/bind 127.0.0.1/bind 0.0.0.0/' \
                    -e '/masterauth/a masterauth 123456' \
                    -e '/# requirepass/a requirepass 123456' \
                    -e '/# cluster-enabled yes/a cluster-enabled yes' \
                    -e '/# cluster-config-file nodes-6379.conf/a cluster-config-file nodes-6379.conf' \
                    -e '/cluster-require-full-coverage yes/c cluster-require-full-coverage no' /etc/redis.conf
[root@redis-node7 ~]#systemctl enable --now redis

#配置node8节点
[root@redis-node8 ~]#dnf -y install redis
[root@redis-node8 ~]#sed -i.bak -e 's/bind 127.0.0.1/bind 0.0.0.0/' \
                     -e '/masterauth/a masterauth 123456' \
                     -e '/# requirepass/a requirepass 123456' \
                     -e '/# cluster-enabled yes/a cluster-enabled yes' \
                     -e '/# cluster-config-file nodes-6379.conf/a cluster-config-file nodes-6379.conf' \
                     -e '/cluster-require-full-coverage yes/c cluster-require-full-coverage no' /etc/redis.conf
[root@redis-node8 ~]#systemctl enable --now redis
```

### 2)添加新的master节点到集群

使用以下命令添加新节点，要添加的新redis节点IP和端口添加到的已有的集群中任意节点的IP:端口
```
add-node new_host:new_port existing_host:existing_port [--slave --master-id <arg>]

#说明：
new_host:new_port                   #为新添加的主机的IP和端口
existing_host:existing_port         #为已有的集群中任意节点的IP和端口
```

#### Redis 3/4 添加方式：
```
#把新的Redis 节点10.0.0.37添加到当前Redis集群当中。
[root@redis-node1 ~]#redis-trib.rb add-node 10.0.0.37:6379 10.0.0.7:6379

[root@redis-node1 ~]#redis-trib.rb info 10.0.0.7:6379
10.0.0.7:6379 (29a83275...) -> 3331 keys | 5461 slots | 1 slaves.
10.0.0.37:6379 (12ca273a...) -> 0 keys | 0 slots | 0 slaves.
10.0.0.27:6379 (90b20613...) -> 3329 keys | 5461 slots | 1 slaves.
10.0.0.17:6379 (fb34c3a7...) -> 3340 keys | 5462 slots | 1 slaves.
[OK] 10000 keys in 4 masters.
0.61 keys per slot on average.
```

#### Redis 5 添加方式：
```
#将一台新的主机10.0.0.68加入集群,以下示例中10.0.0.58可以是任意存在的集群节点
[root@redis-node1 ~]#redis-cli -a 123456 --cluster add-node 10.0.0.68:6379 <当前任意集群节点>:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Adding node 10.0.0.68:6379 to cluster 10.0.0.58:6379
>>> Performing Cluster Check (using node 10.0.0.58:6379)
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 10.0.0.68:6379 to make it join the cluster.
[OK] New node added correctly.
#观察到该节点已经加入成功，但此节点上没有slot位,也无从节点，而且新的节点是master

[root@redis-node1 ~]#redis-cli -a 123456 --cluster info 10.0.0.8:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.8:6379 (cb028b83...) -> 6672 keys | 5461 slots | 1 slaves.
10.0.0.68:6379 (d6e2eca6...) -> 0 keys | 0 slots | 0 slaves.
10.0.0.48:6379 (d04e524d...) -> 6679 keys | 5462 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 6649 keys | 5461 slots | 1 slaves.
[OK] 20000 keys in 5 masters.
1.22 keys per slot on average.
[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.8:6379
Warning: Using a password with '-a' or '-u' option on the command line interface 
may not be safe.
10.0.0.8:6379 (cb028b83...) -> 6672 keys | 5461 slots | 1 slaves.
10.0.0.68:6379 (d6e2eca6...) -> 0 keys | 0 slots | 0 slaves.
10.0.0.48:6379 (d04e524d...) -> 6679 keys | 5462 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 6649 keys | 5461 slots | 1 slaves.
[OK] 20000 keys in 5 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots: (0 slots) master
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

[root@redis-node1 ~]#cat /var/lib/redis/nodes-6379.conf 
d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379@16379 master - 01582356107260 8 connected
9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379@16379 slave d34da8666a6f587283a1c2fca5d13691407f9462 0 1582356110286 6 connected
f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379@16379 slave cb028b83f9dc463d732f6e76ca6bbcd469d948a7 0 1582356108268 4 connected
d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379@16379 master - 01582356105000 7 connected 5461-10922
99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379@16379 slave d04e524daec4d8e22bdada7f21a9487c2d3e1057 0 1582356108000 7 connected
d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379@16379 master - 01582356107000 3 connected 10923-16383
cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379@16379 myself,master - 01582356106000 1 connected 0-5460
vars currentEpoch 8 lastVoteEpoch 7

#和上面显示结果一样
[root@redis-node1 ~]#redis-cli -a 123456 CLUSTER NODES
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379@16379 master - 01582356313200 8 connected
9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379@16379 slave d34da8666a6f587283a1c2fca5d13691407f9462 0 1582356311000 6 connected
f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379@16379 slave cb028b83f9dc463d732f6e76ca6bbcd469d948a7 0 1582356314208 4 connected
d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379@16379 master - 01582356311182 7 connected 5461-10922
99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379@16379 slave d04e524daec4d8e22bdada7f21a9487c2d3e1057 0 1582356312000 7 connected
d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379@16379 master - 01582356312190 3 connected 10923-16383
cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379@16379 myself,master - 01582356310000 1 connected 0-5460

#查看集群状态
[root@redis-node1 ~]#redis-cli -a 123456 CLUSTER INFO
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:7
cluster_size:3
cluster_current_epoch:8
cluster_my_epoch:1
cluster_stats_messages_ping_sent:17442
cluster_stats_messages_pong_sent:13318
cluster_stats_messages_fail_sent:4
cluster_stats_messages_auth-ack_sent:1
cluster_stats_messages_sent:30765
cluster_stats_messages_ping_received:13311
cluster_stats_messages_pong_received:13367
cluster_stats_messages_meet_received:7
cluster_stats_messages_fail_received:1
cluster_stats_messages_auth-req_received:1
cluster_stats_messages_received:26687
[root@redis-node1 ~]#
```

### 3)在新的master上重新分配槽位

新的node节点加到集群之后,默认是master节点，但是没有slots，需要重新分配添加主机之后需要对添加至集群种的新主机重新分片,否则其没有分片也就无法写入数据。

注意: 重新分配槽位需要清空数据,所以需要先备份数据,扩展后再恢复数据

#### Redis 3/4:
```
[root@redis-node1 ~]# redis-trib.rb check 10.0.0.67:6379 #当前状态
[root@redis-node1 ~]# redis-trib.rb reshard <任意节点>:6379 #重新分片
[root@redis-node1 ~]# redis-trib.rb fix 10.0.0.67:6379 #如果迁移失败使用此命令修复集群
```

#### Redis 5：
```
[root@redis-node1 ~]#redis-cli -a 123456 --cluster reshard <当前任意集群节点>:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing Cluster Check (using node 10.0.0.68:6379)
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots: (0 slots) master
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
M: f67f1c02c742cd48d3f48d8c362f9f1b9aa31549 10.0.0.78:6379
   slots: (0 slots) master
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)?4096                 #新分配多少个槽位=16384/master个数
What is the receiving node ID? d6e2eca6b338b717923f64866bd31d42e52edc98   #新的master的ID
Please enter all the source node IDs.
 Type 'all' to use all the nodes as source nodes for the hash slots.
 Type 'done' once you entered all the source nodes IDs.
Source node #1: all                                                       #将哪些源主机的槽位分配给新的节点，all是自动在所有的redis node选择划分，如果是从redis cluster删除某个主机可以使用此方式将指定主机上的槽位全部移动到别的redis主机
......
Do you want to proceed with the proposed reshard plan (yes/no)?  yes       #确认分配
......
Moving slot 12280 from 10.0.0.28:6379 to 10.0.0.68:6379: .
Moving slot 12281 from 10.0.0.28:6379 to 10.0.0.68:6379: .
Moving slot 12282 from 10.0.0.28:6379 to 10.0.0.68:6379: 
Moving slot 12283 from 10.0.0.28:6379 to 10.0.0.68:6379: ..
Moving slot 12284 from 10.0.0.28:6379 to 10.0.0.68:6379: 
Moving slot 12285 from 10.0.0.28:6379 to 10.0.0.68:6379: .
Moving slot 12286 from 10.0.0.28:6379 to 10.0.0.68:6379: 
Moving slot 12287 from 10.0.0.28:6379 to 10.0.0.68:6379: ..
[root@redis-node1 ~]#

#确定slot分配成功
[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.8:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.8:6379 (cb028b83...) -> 5019 keys | 4096 slots | 1 slaves.
10.0.0.68:6379 (d6e2eca6...) -> 4948 keys | 4096 slots | 0 slaves.
10.0.0.48:6379 (d04e524d...) -> 5033 keys | 4096 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 5000 keys | 4096 slots | 1 slaves.
[OK] 20000 keys in 5 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master           #可看到4096个slots
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

### 4)为新的master添加新的slave节点

需要再向当前的Redis集群中添加一个Redis单机服务器10.0.0.78，用于解决当前10.0.0.68单机的潜在宕机问题，即实现响应的高可用功能，有两种式：

#### 方法1：在新加节点到集群时，直接将之设置为slave

##### Redis 3/4 添加方式：
```
redis-trib.rb   add-node --slave --master-id 750cab050bc81f2655ed53900fd43d2e64423333 10.0.0.77:6379 <任意集群节点>:6379
```

##### Redis 5 添加方式：
```
redis-cli -a 123456 --cluster add-node 10.0.0.78:6379 <任意集群节点>:6379 --cluster-slave --cluster-master-id d6e2eca6b338b717923f64866bd31d42e52edc98
```

范例: 
```
#查看当前状态
[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.8:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.8:6379 (cb028b83...) -> 5019 keys | 4096 slots | 1 slaves.
10.0.0.68:6379 (d6e2eca6...) -> 4948 keys | 4096 slots | 0 slaves.
10.0.0.48:6379 (d04e524d...) -> 5033 keys | 4096 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 5000 keys | 4096 slots | 1 slaves.
[OK] 20000 keys in 4 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

#直接加为slave节点
[root@redis-node1 ~]#redis-cli -a 123456 --cluster add-node 10.0.0.78:6379 10.0.0.8:6379 --cluster-slave --cluster-master-id d6e2eca6b338b717923f64866bd31d42e52edc98

#验证是否成功
[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.8:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.8:6379 (cb028b83...) -> 5019 keys | 4096 slots | 1 slaves.
10.0.0.68:6379 (d6e2eca6...) -> 4948 keys | 4096 slots | 1 slaves.
10.0.0.48:6379 (d04e524d...) -> 5033 keys | 4096 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 5000 keys | 4096 slots | 1 slaves.
[OK] 20000 keys in 4 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
   1 additional replica(s)
S: 36840d7eea5835ba540d9b64ec018aa3f8de6747 10.0.0.78:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

[root@centos8 ~]#redis-cli -a 123456 -h 10.0.0.8 --no-auth-warning cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8                              #8个节点
cluster_size:4                                     #4组主从
cluster_current_epoch:11
cluster_my_epoch:10
cluster_stats_messages_ping_sent:1810
cluster_stats_messages_pong_sent:1423
cluster_stats_messages_auth-req_sent:5
cluster_stats_messages_update_sent:14
cluster_stats_messages_sent:3252
cluster_stats_messages_ping_received:1417
cluster_stats_messages_pong_received:1368
cluster_stats_messages_meet_received:2
cluster_stats_messages_fail_received:2
cluster_stats_messages_auth-ack_received:2
cluster_stats_messages_update_received:4
cluster_stats_messages_received:2795
```

#### 方法2：先将新节点加入集群，再修改为slave

##### 为新的master添加slave节点

###### Redis 3/4 版本：
```
[root@redis-node1 ~]#redis-trib.rb add-node 10.0.0.78:6379 10.0.0.8:6379
```

###### Redis 5 版本：
```
#把10.0.0.78:6379添加到集群中：
[root@redis-node1 ~]#redis-cli -a 123456 --cluster add-node 10.0.0.78:6379 10.0.0.8:6379
```

##### 更改新节点更改状态为slave：
需要手动将其指定为某个master的slave，否则其默认角色为master。
```
[root@redis-node1 ~]#redis-cli -h 10.0.0.78 -p 6379 -a 123456                  #登录到新添加节点
10.0.0.78:6380> CLUSTER NODES                                                  #查看当前集群节点，找到目标master 的ID
10.0.0.78:6380> CLUSTER REPLICATE 886338acd50c3015be68a760502b239f4509881c     #将其设置slave，命令格式为cluster replicate MASTERID
10.0.0.78:6380> CLUSTER NODES                                                  #再次查看集群节点状态，验证节点是否已经更改为指定master 的slave
```

## 2、集群维护之动态缩容

实战案例：

由于10.0.0.8服务器使用年限已经超过三年，已经超过厂商质保期而且硬盘出现异常报警，经运维部架构师提交方案并同开发同事开会商议，决定将现有Redis集群的8台主服务器中的master 10.0.0.8和对应的slave 10.0.0.38 临时下线，三台服务器的并发写入性能足够支出未来1-2年的业务需求

删除节点过程：

添加节点的时候是先添加node节点到集群，然后分配槽位，删除节点的操作与添加节点的操作正好相反，是先将被删除的Redis node上的槽位迁移到集群中的其他Redis node节点上，然后再将其删除，如果一个Redis node节点上的槽位没有被完全迁移，删除该node的时候会提示有数据且无法删除。


### 1）迁移master 的槽位至其他master

注意: 被迁移Redis master源服务器必须保证没有数据，否则迁移报错并会被强制中断。

#### Redis 3/4 版本
```
[root@redis-node1 ~]# redis-trib.rb reshard 10.0.0.8:6379
[root@redis-node1 ~]# redis-trib.rb fix 10.0.0.8:6379           #如果迁移失败使用此命令修复集群
```

#### Redis 5版本
```
#查看当前状态
[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.8:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.8:6379 (cb028b83...) -> 5019 keys | 4096 slots | 1 slaves.
10.0.0.68:6379 (d6e2eca6...) -> 4948 keys | 4096 slots | 1 slaves.
10.0.0.48:6379 (d04e524d...) -> 5033 keys | 4096 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 5000 keys | 4096 slots | 1 slaves.
[OK] 20000 keys in 4 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
   1 additional replica(s)
S: 36840d7eea5835ba540d9b64ec018aa3f8de6747 10.0.0.78:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

#连接到任意集群节点，#最后1365个slot从10.0.0.8移动到第一个master节点10.0.0.28上
[root@redis-node1 ~]#redis-cli -a 123456 --cluster reshard 10.0.0.18:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing Cluster Check (using node 10.0.0.18:6379)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
S: 36840d7eea5835ba540d9b64ec018aa3f8de6747 10.0.0.78:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
   1 additional replica(s)
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 1356                #共4096/3分别给其它三个master节点
What is the receiving node ID? d34da8666a6f587283a1c2fca5d13691407f9462   #master 10.0.0.28
Please enter all the source node IDs.
 Type 'all' to use all the nodes as source nodes for the hash slots.
 Type 'done' once you entered all the source nodes IDs.
Source node #1: cb028b83f9dc463d732f6e76ca6bbcd469d948a7                  #输入要删除10.0.0.8节点ID
Source node #2: done
Ready to move 1356 slots.
 Source nodes:
   M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
       slots:[1365-5460] (4096 slots) master
       1 additional replica(s)
 Destination node:
   M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
       slots:[12288-16383] (4096 slots) master
       1 additional replica(s)
 Resharding plan:
   Moving slot 1365 from cb028b83f9dc463d732f6e76ca6bbcd469d948a7
......
 Moving slot 2719 from cb028b83f9dc463d732f6e76ca6bbcd469d948a7
   Moving slot 2720 from cb028b83f9dc463d732f6e76ca6bbcd469d948a7
Do you want to proceed with the proposed reshard plan (yes/no)? yes       #确定
......
Moving slot 2718 from 10.0.0.8:6379 to 10.0.0.28:6379: ..
Moving slot 2719 from 10.0.0.8:6379 to 10.0.0.28:6379: .
Moving slot 2720 from 10.0.0.8:6379 to 10.0.0.28:6379: ..

#非交互式方式
#再将1365个slot从10.0.0.8移动到第二个master节点10.0.0.48上
[root@redis-node1 ~]#redis-cli -a 123456 --cluster reshard 10.0.0.18:6379 --cluster-slots 1365 --cluster-from cb028b83f9dc463d732f6e76ca6bbcd469d948a7 --cluster-to d04e524daec4d8e22bdada7f21a9487c2d3e1057 --cluster-yes

#最后的slot从10.0.0.8移动到第三个master节点10.0.0.68上
[root@redis-node1 ~]#redis-cli -a 123456 --cluster reshard 10.0.0.18:6379 --cluster-slots 1375 --cluster-from cb028b83f9dc463d732f6e76ca6bbcd469d948a7 --cluster-to d6e2eca6b338b717923f64866bd31d42e52edc98 --cluster-yes

#确认10.0.0.8的所有slot都移走了，上面的slave也自动删除，成为其它master的slave 
[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.8:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.8:6379 (cb028b83...) -> 0 keys | 0 slots | 0 slaves.
10.0.0.68:6379 (d6e2eca6...) -> 6631 keys | 5471 slots | 2 slaves.
10.0.0.48:6379 (d04e524d...) -> 6694 keys | 5461 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 6675 keys | 5452 slots | 1 slaves.
[OK] 20000 keys in 4 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots: (0 slots) master
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[4086-6826],[10923-12287] (5471 slots) master
   2 additional replica(s)
S: 36840d7eea5835ba540d9b64ec018aa3f8de6747 10.0.0.78:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[2721-4085],[6827-10922] (5461 slots) master
   1 additional replica(s)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[1365-2720],[12288-16383] (5452 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

#原有的10.0.0.38自动成为10.0.0.68的slave
[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.68 INFO replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:master
connected_slaves:2
slave0:ip=10.0.0.78,port=6379,state=online,offset=129390,lag=0
slave1:ip=10.0.0.38,port=6379,state=online,offset=129390,lag=0
master_replid:43e3e107a0acb1fd5a97240fc4b2bd8fc85b113f
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:129404
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:129404

[root@centos8 ~]#redis-cli -a 123456 -h 10.0.0.8 --no-auth-warning cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8          #集群中8个节点
cluster_size:3                 #少了一个主从的slot
cluster_current_epoch:16
cluster_my_epoch:13
cluster_stats_messages_ping_sent:3165
cluster_stats_messages_pong_sent:2489
cluster_stats_messages_fail_sent:6
cluster_stats_messages_auth-req_sent:5
cluster_stats_messages_auth-ack_sent:1
cluster_stats_messages_update_sent:27
cluster_stats_messages_sent:5693
cluster_stats_messages_ping_received:2483
cluster_stats_messages_pong_received:2400
cluster_stats_messages_meet_received:2
cluster_stats_messages_fail_received:2
cluster_stats_messages_auth-req_received:1
cluster_stats_messages_auth-ack_received:2
cluster_stats_messages_update_received:4
cluster_stats_messages_received:4894
```

### 2）从集群删除服务器

虽然槽位已经迁移完成，但是服务器IP信息还在集群当中，因此还需要将IP信息从集群删除

注意: 删除服务器前,必须清除主机上面的槽位,否则会删除主机失败

#### Redis 3/4：
```
[root@s~]#redis-trib.rb del-node 10.0.0.8:6379 dfffc371085859f2858730e1f350e9167e287073
>>> Removing node dfffc371085859f2858730e1f350e9167e287073 from cluster 192.168.7.102:6379
>>> Sending CLUSTER FORGET messages to the cluster...
>>> SHUTDOWN the node.
```

#### Redis 5：
```
[root@s~]#redis-trib.rb del-node 10.0.0.8:6379 dfffc371085859f2858730e1f350e9167e287073
>>> Removing node dfffc371085859f2858730e1f350e9167e287073 from cluster 192.168.7.102:6379
>>> Sending CLUSTER FORGET messages to the cluster...
>>> SHUTDOWN the node.
```

#### 删除多余的slave节点验证结果
```
#验证删除成功
[root@redis-node1 ~]#ss -ntl
State       Recv-Q       Send-Q   Local Address:Port     Peer Address:Port
LISTEN       0             128            0.0.0.0:22             0.0.0.0:*
LISTEN       0             128               [::]:22                [::]:*

[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.18:6379 
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.68:6379 (d6e2eca6...) -> 6631 keys | 5471 slots | 2 slaves.
10.0.0.48:6379 (d04e524d...) -> 6694 keys | 5461 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 6675 keys | 5452 slots | 1 slaves.
[OK] 20000 keys in 3 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.18:6379)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
S: 36840d7eea5835ba540d9b64ec018aa3f8de6747 10.0.0.78:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[4086-6826],[10923-12287] (5471 slots) master
   2 additional replica(s)
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[2721-4085],[6827-10922] (5461 slots) master
   1 additional replica(s)
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[1365-2720],[12288-16383] (5452 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

#删除多余的slave从节点
[root@redis-node1 ~]#redis-cli -a 123456 --cluster del-node 10.0.0.18:6379 f9adcfb8f5a037b257af35fa548a26ffbadc852d
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Removing node f9adcfb8f5a037b257af35fa548a26ffbadc852d from cluster 10.0.0.18:6379
>>> Sending CLUSTER FORGET messages to the cluster...
>>> SHUTDOWN the node.

#删除集群文件
[root@redis-node4 ~]#rm -f /var/lib/redis/nodes-6379.conf 
[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.18:6379 
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.68:6379 (d6e2eca6...) -> 6631 keys | 5471 slots | 1 slaves.
10.0.0.48:6379 (d04e524d...) -> 6694 keys | 5461 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 6675 keys | 5452 slots | 1 slaves.
[OK] 20000 keys in 3 masters.
1.22 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.18:6379)
S: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots: (0 slots) slave
   replicates d04e524daec4d8e22bdada7f21a9487c2d3e1057
S: 36840d7eea5835ba540d9b64ec018aa3f8de6747 10.0.0.78:6379
   slots: (0 slots) slave
   replicates d6e2eca6b338b717923f64866bd31d42e52edc98
M: d6e2eca6b338b717923f64866bd31d42e52edc98 10.0.0.68:6379
   slots:[0-1364],[4086-6826],[10923-12287] (5471 slots) master
   1 additional replica(s)
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
M: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots:[2721-4085],[6827-10922] (5461 slots) master
   1 additional replica(s)
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[1365-2720],[12288-16383] (5452 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

[root@redis-node1 ~]#redis-cli -a 123456 --cluster info 10.0.0.18:6379 
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.68:6379 (d6e2eca6...) -> 6631 keys | 5471 slots | 1 slaves.
10.0.0.48:6379 (d04e524d...) -> 6694 keys | 5461 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 6675 keys | 5452 slots | 1 slaves.
[OK] 20000 keys in 3 masters.
1.22 keys per slot on average.

#查看集群信息
[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.18 CLUSTER INFO
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6                      #只有6个节点
cluster_size:3
cluster_current_epoch:11
cluster_my_epoch:10
cluster_stats_messages_ping_sent:12147
cluster_stats_messages_pong_sent:12274
cluster_stats_messages_update_sent:14
cluster_stats_messages_sent:24435
cluster_stats_messages_ping_received:12271
cluster_stats_messages_pong_received:12147
cluster_stats_messages_meet_received:3
cluster_stats_messages_update_received:28
cluster_stats_messages_received:24449
```

## 3、集群维护之导入现有Redis数据至集群

官方提供了离线迁移数据到集群的工具,有些公司开发了离线迁移工具
- 官方工具: redis-cli --cluster import
- 第三方在线迁移工具: 模拟slave 节点实现, 比如: 唯品会 redis-migrate-tool , 豌豆荚 redis-port

实战案例：
公司将redis cluster部署完成之后，需要将之前的数据导入之Redis cluster集群，但是由于Redis cluster使用的分片保存key的机制，因此使用传统的AOF文件或RDB快照无法满足需求，因此需要使用集群数据导入命令完成。

注意: 导入数据需要redis cluster不能与被导入的数据有重复的key名称，否则导入不成功或中断。

### 1)基础环境准备

导入数据之前需要关闭各redis 服务器的密码，包括集群中的各node和源Redis server，避免认证带来的环境不一致从而无法导入，可以加参数--cluster-replace 强制替换Redis cluster已有的key。
```
#在所有节点包括master和slave节点上关闭各Redis密码认证
[root@redis ~]# redis-cli -h 10.0.0.18 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""
OK
```

### 2)执行数据导入

将源Redis server的数据直接导入之 redis cluster,此方式慎用!

Redis 3/4：
```
[root@redis ~]# redis-trib.rb import --from <外部Redis node-IP:PORT> --replace <集群服务器IP:PORT>
```

Redis 5：
```
[root@redis ~]#redis-cli --cluster import <集群服务器IP:PORT> --cluster-from <外部Redis node-IP:PORT> --cluster-copy --cluster-replace

#只使用cluster-copy，则要导入集群中的key不能存在
#如果集群中已有同样的key，如果需要替换，可以cluster-copy和cluster-replace联用，这样集群中的key就会被替换为外部数据
```

范例：将非集群节点的数据导入redis cluster 
```
#在非集群节点10.0.0.78生成数据
[root@centos8 ~]#hostname -I
10.0.0.78 

[root@centos8 ~]#cat redis_test.sh 
#!/bin/bash
#
#********************************************************************
#Author: wangxiaochun
#QQ: 29308620
#Date: 2020-02-03
#FileName： redis.sh
#URL: http://www.wangxiaochun.com
#Description： The test script
#Copyright (C): 2020 All rights reserved
#********************************************************************
NUM=10
PASS=123456
for i in `seq $NUM`;do
   redis-cli -h 127.0.0.1 -a "$PASS"  --no-auth-warning  set testkey${i} testvalue${i}
   echo "testkey${i} testvalue${i} 写入完成"
done
echo "$NUM个key写入到Redis完成"  

[root@centos8 ~]#bash redis_test.sh
OK
testkey1 testvalue1 写入完成
OK
testkey2 testvalue2 写入完成
OK
testkey3 testvalue3 写入完成
OK
testkey4 testvalue4 写入完成
OK
testkey5 testvalue5 写入完成
OK
testkey6 testvalue6 写入完成
OK
testkey7 testvalue7 写入完成
OK
testkey8 testvalue8 写入完成
OK
testkey9 testvalue9 写入完成
OK
testkey10 testvalue10 写入完成
10个key写入到Redis完成

#取消需要导入的主机的密码
[root@centos8 ~]#redis-cli -h 10.0.0.78 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""

#取消所有集群服务器的密码
[root@centos8 ~]#redis-cli -h 10.0.0.8 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""
[root@centos8 ~]#redis-cli -h 10.0.0.18 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""
[root@centos8 ~]#redis-cli -h 10.0.0.28 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""
[root@centos8 ~]#redis-cli -h 10.0.0.38 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""
[root@centos8 ~]#redis-cli -h 10.0.0.48 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""
[root@centos8 ~]#redis-cli -h 10.0.0.58 -p 6379 -a 123456 --no-auth-warning CONFIG SET requirepass ""

#导入数据至集群
[root@centos8 ~]#redis-cli --cluster import 10.0.0.8:6379 --cluster-from 10.0.0.78:6379 --cluster-copy --cluster-replace
>>> Importing data from 10.0.0.78:6379 to cluster 10.0.0.8:6379
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379
   slots:[0-5461] (5462 slots) master
   1 additional replica(s)
M: 4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379
   slots: (0 slots) slave
   replicates 97c5dcc3f33c2fc75c7fdded25d05d2930a312c0
M: 97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379
   slots:[5462-10922] (5461 slots) master
   1 additional replica(s)
S: 07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379
   slots: (0 slots) slave
   replicates 4f146b1ac51549469036a272c60ea97f065ef832
S: cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379
   slots: (0 slots) slave
   replicates a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
*** Importing 10 keys from DB 0
Migrating testkey4 to 10.0.0.18:6379: OK
Migrating testkey8 to 10.0.0.18:6379: OK
Migrating testkey6 to 10.0.0.28:6379: OK
Migrating testkey1 to 10.0.0.8:6379: OK
Migrating testkey5 to 10.0.0.8:6379: OK
Migrating testkey10 to 10.0.0.28:6379: OK
Migrating testkey7 to 10.0.0.18:6379: OK
Migrating testkey9 to 10.0.0.8:6379: OK
Migrating testkey2 to 10.0.0.28:6379: OK
Migrating testkey3 to 10.0.0.18:6379: OK

#验证数据
[root@centos8 ~]#redis-cli -h 10.0.0.8 keys '*'
1) "testkey5"
2) "testkey1"
3) "testkey9"
[root@centos8 ~]#redis-cli -h 10.0.0.18 keys '*'
1) "testkey8"
2) "testkey4"
3) "testkey3"
4) "testkey7"
[root@centos8 ~]#redis-cli -h 10.0.0.28 keys '*'
1) "testkey6"
2) "testkey10"
3) "testkey2"
```

### 4)集群偏斜

redis cluster 多个节点运行一段时间后,可能会出现倾斜现象,某个节点数据偏多,内存消耗更大,或者接受用户请求访问更多

发生倾斜的原因可能如下:
- 节点和槽分配不均
- 不同槽对应键值数量差异较大
- 包含bigkey,建议少用
- 内存相关配置不一致
- 热点数据不均衡 : 一致性不高时,可以使用本缓存和MQ

获取指定槽位中对应键key值的个数
```
#redis-cli cluster countkeysinslot {slot的值}
```

范例: 获取指定slot对应的key个数
```
[root@centos8 ~]#redis-cli -a 123456 cluster countkeysinslot 1
(integer) 0
[root@centos8 ~]#redis-cli -a 123456 cluster countkeysinslot 2
(integer) 0
[root@centos8 ~]#redis-cli -a 123456 cluster countkeysinslot 3
(integer) 1
```

执行自动的槽位重新平衡分布,但会影响客户端的访问,此方法慎用
```
#redis-cli --cluster rebalance <集群节点IP:PORT>
```

范例: 执行自动的槽位重新平衡分布
```
[root@centos8 ~]#redis-cli -a 123456 --cluster rebalance 10.0.0.8:6379
>>> Performing Cluster Check (using node 10.0.0.8:6379)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
*** No rebalancing needed! All nodes are within the 2.00% threshold.
```

获取bigkey ,建议在slave节点执行
```
#redis-cli --bigkeys
```

范例: 查找 bigkey
```
[root@centos8 ~]#redis-cli -a 123456 --bigkeys
# Scanning the entire keyspace to find biggest keys as well as
# average sizes per key type. You can use -i 0.1 to sleep 0.1 sec
# per 100 SCAN commands (not usually needed).
[00.00%] Biggest string found so far 'key8811' with 9 bytes
[26.42%] Biggest string found so far 'testkey1' with 10 bytes
-------- summary -------

Sampled 3335 keys in the keyspace!
Total key length in bytes is 22979 (avg len 6.89)

Biggest string found 'testkey1' has 10 bytes

3335 strings with 29649 bytes (100.00% of keys, avg size 8.89)
0 lists with 0 items (00.00% of keys, avg size 0.00)
0 sets with 0 members (00.00% of keys, avg size 0.00)
0 hashs with 0 fields (00.00% of keys, avg size 0.00)
0 zsets with 0 members (00.00% of keys, avg size 0.00)
0 streams with 0 entries (00.00% of keys, avg size 0.00)
```

#  redis cluster 的局限性
- 大多数时客户端性能会”降低”
- 命令无法跨节点使用:mget、keys、scan、flush、sinter等
- 客户端维护更复杂:SDK和应用本身消耗(例如更多的连接池)
- 不支持多个数据库︰集群模式下只有一个db 0
- 复制只支持一层∶不支持树形复制结构,不支持级联复制
- Key事务和Lua支持有限∶操作的key必须在一个节点,Lua和事务无法跨节点使用

范例: 跨slot的局限性
```
[root@centos8 ~]#redis-cli -a 123456 mget key1 key2 key3
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(error) CROSSSLOT Keys in request don't hash to the same slot
```
