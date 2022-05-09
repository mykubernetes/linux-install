# 1、准备redis Cluster 基本配置
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

# 2、准备redis-trib.rb工具
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

# 3、redis-trib.rb 命令用法
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

# 4、修改密码 redis 登录密码
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

# 5、创建redis cluster集群
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

# 6、查看 redis cluster 集群状态

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

# 7、python脚本实现RedisCluster集群写入
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

# 8、模拟 master 故障，对应的slave节点自动提升为新master
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




