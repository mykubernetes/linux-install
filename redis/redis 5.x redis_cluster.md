官方文档：https://redis.io/topics/cluster-tutorial

# redis cluster 相关命令

范例: 查看 --cluster 选项帮助
```
[root@centos8 ~]#redis-cli --cluster help
Cluster Manager Commands:
 create         host1:port1 ... hostN:portN
                 --cluster-replicas <arg>
 check          host:port
                 --cluster-search-multiple-owners
 info           host:port
 fix            host:port
                 --cluster-search-multiple-owners
 reshard        host:port
                 --cluster-from <arg>
                 --cluster-to <arg>
                 --cluster-slots <arg>
                 --cluster-yes
                 --cluster-timeout <arg>
                 --cluster-pipeline <arg>
                 --cluster-replace
 rebalance      host:port
                 --cluster-weight <node1=w1...nodeN=wN>
                 --cluster-use-empty-masters
                 --cluster-timeout <arg>
                 --cluster-simulate
                 --cluster-pipeline <arg>
                 --cluster-threshold <arg>
                 --cluster-replace
 add-node       new_host:new_port existing_host:existing_port
                 --cluster-slave
                 --cluster-master-id <arg>
 del-node       host:port node_id
 call           host:port command arg arg .. arg
 set-timeout    host:port milliseconds
 import         host:port
                 --cluster-from <arg>
                 --cluster-copy
                 --cluster-replace
 help           For check, fix, reshard, del-node, set-timeout you can specify the host and port of any working node in the cluster.
```

范例: 查看CLUSTER 指令的帮助
```
[root@centos8 ~]#redis-cli CLUSTER HELP
1) CLUSTER <subcommand> arg arg ... arg. Subcommands are:
2) ADDSLOTS <slot> [slot ...] -- Assign slots to current node.
3) BUMPEPOCH -- Advance the cluster config epoch.
4) COUNT-failure-reports <node-id> -- Return number of failure reports for<node-id>.
5) COUNTKEYSINSLOT <slot> - Return the number of keys in <slot>.
6) DELSLOTS <slot> [slot ...] -- Delete slots information from current node.
7) FAILOVER [force|takeover] -- Promote current replica node to being a master.
8) FORGET <node-id> -- Remove a node from the cluster.
9) GETKEYSINSLOT <slot> <count> -- Return key names stored by current node in a slot.
10) FLUSHSLOTS -- Delete current node own slots information.
11) INFO - Return onformation about the cluster.
12) KEYSLOT <key> -- Return the hash slot for <key>.
13) MEET <ip> <port> [bus-port] -- Connect nodes into a working cluster.
14) MYID -- Return the node id.
15) NODES -- Return cluster configuration seen by node. Output format:
16) <id> <ip:port> <flags> <master> <pings> <pongs> <epoch> <link> <slot> ... <slot>
17) REPLICATE <node-id> -- Configure current node as replica to <node-id>.
18) RESET [hard|soft] -- Reset current node (default: soft).
19) SET-config-epoch <epoch> - Set config epoch of current node.
20) SETSLOT <slot> (importing|migrating|stable|node <node-id>) -- Set slot state.
21) REPLICAS <node-id> -- Return <node-id> replicas.
22) SLOTS -- Return information about slots range mappings. Each range is made of:
23) start, end, master and replicas IP addresses, ports and ids
```

# 创建 redis cluster集群的环境准备
- 1. 每个redis 节点采用相同的硬件配置、相同的密码、相同的redis版本
- 2. 所有redis服务器必须没有任何数据
- 3. 准备六台主机，地址如下：
```
10.0.0.8
10.0.0.18
10.0.0.28
10.0.0.38
10.0.0.48
10.0.0.58
```

# 启用 redis cluster 配置

1、所有6台主机都执行以下配置
```
[root@centos8 ~]#dnf -y install redis
```

2、每个节点修改redis配置，必须开启cluster功能的参数
```
#手动修改配置文件
[root@redis-node1 ~]vim /etc/redis.conf
bind 0.0.0.0
masterauth 123456                          #建议配置，否则后期的master和slave主从复制无法成功，还需再配置
requirepass 123456
cluster-enabled yes                        #取消此行注释,必须开启集群，开启后redis 进程会有cluster显示
cluster-config-file nodes-6379.conf        #取消此行注释,此为集群状态文件,记录主从关系及slot范围信息,由redis cluster 集群自动创建和维护
cluster-require-full-coverage no           #默认值为yes,设为no可以防止一个节点不可用导致整个cluster不可能

#或者执行下面命令,批量修改
[root@redis-node1 ~]#sed -i.bak -e 's/bind 127.0.0.1/bind 0.0.0.0/' \
                       -e '/masterauth/a masterauth 123456' -e '/# requirepass/a requirepass 123456' \
                       -e '/# cluster-enabled yes/a cluster-enabled yes' \
                       -e '/# cluster-config-file nodes-6379.conf/a cluster-config-file nodes-6379.conf' \
                       -e '/cluster-require-full-coverage yes/c cluster-require-full-coverage no' /etc/redis.conf
[root@redis-node1 ~]#systemctl enable --now redis
```

验证当前Redis服务状态：
```
#开启了16379的cluster的端口,实际的端口=redis port + 10000
[root@centos8 ~]#ss -ntl
State       Recv-Q       Send-Q Local  Address:Port     Peer Address:Port 
LISTEN       0             128           0.0.0.0:22            0.0.0.0:*     
LISTEN       0             100         127.0.0.1:25            0.0.0.0:*     
LISTEN       0             128        0.0.0.0:16379            0.0.0.0:*     
LISTEN       0             128         0.0.0.0:6379            0.0.0.0:*     
LISTEN       0             128              [::]:22               [::]:*     
LISTEN       0             100             [::1]:25               [::]:*     
      
#注意进程有[cluster]状态
[root@centos8 ~]#ps -ef|grep redis
redis   1939    1  0 10:54 ?    00:00:00 /usr/bin/redis-server 0.0.0.0:6379 [cluster]
root    1955   1335  0 10:57 pts/0    00:00:00 grep --color=auto redis
```

# 创建集群
```
# redis-cli --cluster-replicas 1 表示每个master对应一个slave节点
[root@redis-node1 ~]#redis-cli -a 123456 --cluster create 10.0.0.8:6379 10.0.0.18:6379 10.0.0.28:6379 10.0.0.38:6379 10.0.0.48:6379 10.0.0.58:6379 --cluster-replicas 1 
Warning: Using a password with '-a' or '-u' option on the command line interface 
may not be safe.
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 10.0.0.38:6379 to 10.0.0.8:6379
Adding replica 10.0.0.48:6379 to 10.0.0.18:6379
Adding replica 10.0.0.58:6379 to 10.0.0.28:6379
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379          #带M的为master
   slots:[0-5460] (5461 slots) master                              #当前master的槽位起始和结束位
M: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots:[5461-10922] (5462 slots) master
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[10923-16383] (5461 slots) master
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379         #带S的slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7      
S: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   replicates 99720241248ff0e4c6fa65c2385e92468b3b5993
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
Can I set the above configuration? (type 'yes' to accept): yes     #输入yes自动创建集群
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
....
>>> Performing Cluster Check (using node 10.0.0.8:6379)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[0-5460] (5461 slots) master                              #已经分配的槽位
   1 additional replica(s)                                         #分配了一个slave
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave                                          #slave没有分配槽位
   replicates d34da8666a6f587283a1c2fca5d13691407f9462             #对应的master的10.0.0.28的ID
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7             #对应的master的10.0.0.8的ID
S: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots: (0 slots) slave
   replicates 99720241248ff0e4c6fa65c2385e92468b3b5993             #对应的master的10.0.0.18的ID
M: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.                    #所有节点槽位分配完成
>>> Check for open slots...                                        #检查打开的槽位
>>> Check slots coverage...                                        #检查插槽覆盖范围
[OK] All 16384 slots covered.                                      #所有槽位(16384个)分配完成


#观察以上结果，可以看到3组master/slave
master:10.0.0.8---slave:10.0.0.38
master:10.0.0.18---slave:10.0.0.48
master:10.0.0.28---slave:10.0.0.58
```

#  查看主从状态
```
[root@redis-node1 ~]#redis-cli -a 123456 -c INFO replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.38,port=6379,state=online,offset=896,lag=1
master_replid:3a388865080d779180ff240cb75766e7e57877da
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:896
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:896

[root@redis-node2 ~]#redis-cli -a 123456 INFO replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.48,port=6379,state=online,offset=980,lag=1
master_replid:b9066d3cbf0c5fecc7f4d1d5cb2433999783fa3f
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:980
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:980

[root@redis-node3 ~]#redis-cli -a 123456 INFO replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.58,port=6379,state=online,offset=980,lag=0
master_replid:53208e0ed9305d721e2fb4b3180f75c689217902
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:980
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:980

[root@redis-node4 ~]#redis-cli -a 123456 INFO replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:slave
master_host:10.0.0.8
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:1036
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:3a388865080d779180ff240cb75766e7e57877da
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:1036
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:1036

[root@redis-node5 ~]#redis-cli -a 123456 INFO replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:slave
master_host:10.0.0.18
master_port:6379
master_link_status:up
master_last_io_seconds_ago:2
master_sync_in_progress:0
slave_repl_offset:1064
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:b9066d3cbf0c5fecc7f4d1d5cb2433999783fa3f
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:1064
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:1064

[root@redis-node6 ~]#redis-cli -a 123456 INFO replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:slave
master_host:10.0.0.28
master_port:6379
master_link_status:up
master_last_io_seconds_ago:7
master_sync_in_progress:0
slave_repl_offset:1078
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:53208e0ed9305d721e2fb4b3180f75c689217902
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:1078
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:1078
```

# 范例: 查看指定master节点的slave节点信息
```
[root@centos8 ~]#redis-cli cluster nodes 
4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379@16379 master - 01602571565772 12 connected 10923-16383
779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379@16379 slave 97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 0 1602571565000 11 connected
97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379@16379 master - 01602571564000 11 connected 5462-10922
07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379@16379 slave 4f146b1ac51549469036a272c60ea97f065ef832 0 1602571565000 12 connected
a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379@16379 myself,master - 01602571566000 10 connected 0-5461
cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 slave a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 0 1602571566780 10 connected

#以下命令查看指定master节点的slave节点信息,其中#a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 为master节点的ID
[root@centos8 ~]#redis-cli cluster slaves a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab
1) "cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 slave a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 0 1602571574844 10 connected"
```

# 验证集群状态
```
[root@redis-node1 ~]#redis-cli -a 123456 CLUSTER INFO
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6                 #节点数
cluster_size:3                        #三个集群
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:837
cluster_stats_messages_pong_sent:811
cluster_stats_messages_sent:1648
cluster_stats_messages_ping_received:806
cluster_stats_messages_pong_received:837
cluster_stats_messages_meet_received:5
cluster_stats_messages_received:1648

#查看任意节点的集群状态
[root@redis-node1 ~]#redis-cli -a 123456 --cluster info 10.0.0.38:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.18:6379 (99720241...) -> 0 keys | 5462 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 0 keys | 5461 slots | 1 slaves.
10.0.0.8:6379 (cb028b83...) -> 0 keys | 5461 slots | 1 slaves.
[OK] 0 keys in 3 masters.
0.00 keys per slot on average.
```

# 查看集群node对应关系
```
[root@redis-node1 ~]#redis-cli -a 123456 CLUSTER NODES
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379@16379 slave d34da8666a6f587283a1c2fca5d13691407f9462 0 1582344815790 6 connected
f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379@16379 slave cb028b83f9dc463d732f6e76ca6bbcd469d948a7 0 1582344811000 4 connected
d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379@16379 slave 99720241248ff0e4c6fa65c2385e92468b3b5993 0 1582344815000 5 connected
99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379@16379 master - 01582344813000 2 connected 5461-10922
d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379@16379 master - 01582344814780 3 connected 10923-16383
cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379@16379 myself,master - 01582344813000 1 connected 0-5460

[root@redis-node1 ~]#redis-cli -a 123456 --cluster check 10.0.0.38:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.18:6379 (99720241...) -> 0 keys | 5462 slots | 1 slaves.
10.0.0.28:6379 (d34da866...) -> 0 keys | 5461 slots | 1 slaves.
10.0.0.8:6379 (cb028b83...) -> 0 keys | 5461 slots | 1 slaves.
[OK] 0 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 10.0.0.38:6379)
S: f9adcfb8f5a037b257af35fa548a26ffbadc852d 10.0.0.38:6379
   slots: (0 slots) slave
   replicates cb028b83f9dc463d732f6e76ca6bbcd469d948a7
S: d04e524daec4d8e22bdada7f21a9487c2d3e1057 10.0.0.48:6379
   slots: (0 slots) slave
   replicates 99720241248ff0e4c6fa65c2385e92468b3b5993
M: 99720241248ff0e4c6fa65c2385e92468b3b5993 10.0.0.18:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 9875b50925b4e4f29598e6072e5937f90df9fc71 10.0.0.58:6379
   slots: (0 slots) slave
   replicates d34da8666a6f587283a1c2fca5d13691407f9462
M: d34da8666a6f587283a1c2fca5d13691407f9462 10.0.0.28:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: cb028b83f9dc463d732f6e76ca6bbcd469d948a7 10.0.0.8:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

# 验证集群写入key

1 redis cluster 写入key
```
#经过算法计算，当前key的槽位需要写入指定的node
[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.8 SET key1 values1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(error) MOVED 9189 10.0.0.18:6379                 #槽位不在当前node所以无法写入

[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.18 SET key1 values1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
OK

#指定node可写入
[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.18 GET key1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
"values1"

#对应的slave节点可以KEYS *,但GET key1失败,可以到master上执行GET key1
[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.48 KEYS "*"
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
1) "key1"

[root@redis-node1 ~]#redis-cli -a 123456 -h 10.0.0.48 GET key1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(error) MOVED 9189 10.0.0.18:6379
```

2 redis cluster 计算key所属的slot
```
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster nodes
4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379@16379 master - 01602561649000 12 connected 10923-16383
779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379@16379 slave 97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 0 1602561648000 11 connected
97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379@16379 master - 01602561650000 11 connected 5462-10922
07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379@16379 slave 4f146b1ac51549469036a272c60ea97f065ef832 0 1602561650229 12 connected
a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379@16379 myself,master - 01602561650000 10 connected 0-5461
cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 slave a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 0 1602561651238 10 connected

#计算得到hello对应的slot
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster keyslot hello
(integer) 866

[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning set hello magedu
OK

[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster keyslot name 
(integer) 5798

[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning set name wang
(error) MOVED 5798 10.0.0.18:6379

[root@centos8 ~]#redis-cli -h 10.0.0.18 -a 123456 --no-auth-warning set name wang
OK

[root@centos8 ~]#redis-cli -h 10.0.0.18 -a 123456 --no-auth-warning get name
"wang"

#使用选项-c 以集群模式连接
[root@centos8 ~]#redis-cli -c -h 10.0.0.8 -a 123456 --no-auth-warning 
10.0.0.8:6379> cluster keyslot linux
(integer) 12299
10.0.0.8:6379> set linux love
-> Redirected to slot [12299] located at 10.0.0.28:6379
OK
10.0.0.28:6379> get linux 
"love"
10.0.0.28:6379> exit

[root@centos8 ~]#redis-cli -h 10.0.0.28 -a 123456 --no-auth-warning get linux
"love"
```
