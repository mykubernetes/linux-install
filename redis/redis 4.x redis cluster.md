# 一、部署方式介绍

redis cluster 有多种部署方法:
- 原生命令安装
  - 理解Redis Cluster架构
  - 生产环境不使用
- 官方工具安装
  - 高效、准确
  - 生产环境可以使用
- 自主研发
  - 可以实现可视化的自动化部署

# 二、原生命令手动部署

1、原生命令手动部署过程
- 在所有节点安装redis,并配置开启cluster功能
- 各个节点执行meet,实现所有节点的相互通信
- 为各个master 节点指派槽位范围
- 指定各个节点的主从关系

2、利用原生命令手动部署redis cluster

2.1 在所有节点安装redis并启动cluster功能
```
#在所有6个节点上都执行下面相同操作
[root@centos8 ~]#dnf -y install redis
[root@centos8 ~]#sed -i.bak -e 's/bind 127.0.0.1/bind 0.0.0.0/' -e '/masterauth/a masterauth 123456' \
                   -e '/# requirepass/a requirepass 123456' \
                   -e '/# cluster-enabled yes/a cluster-enabled yes' \
                   -e '/# cluster-config-file nodes-6379.conf/a cluster-config-file nodes-6379.conf' \
                   -e '/cluster-require-full-coverage yes/c cluster-require-full-coverage no' /etc/redis.conf
[root@centos8 ~]#systemctl enable --now redis
```

2.2执行meet 操作实现相互通信
```
#在任一节点上和其它所有节点进行meet通信
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster meet 10.0.0.18 6379
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster meet 10.0.0.28 6379
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster meet 10.0.0.38 6379
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster meet 10.0.0.48 6379
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster meet 10.0.0.58 6379

#可以看到所有节点之间可以相互连接通信
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster nodes
a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379@16379 myself,master - 01602515365000 3 connected
97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379@16379 master - 01602515367093 1 connected
cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 master - 01602515365057 0 connected
779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379@16379 master - 01602515365000 4 connected
07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379@16379 master - 01602515365000 5 connected
4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379@16379 master - 01602515366074 2 connected

#由于没有槽位无法创建key
[root@centos8 ~]#redis-cli -a 123456 --no-auth-warning set name wang
(error) CLUSTERDOWN Hash slot not served

#查看当前状态
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster info
cluster_state:fail
cluster_slots_assigned:0
cluster_slots_ok:0
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:0
cluster_current_epoch:5
cluster_my_epoch:3
cluster_stats_messages_ping_sent:584
cluster_stats_messages_pong_sent:145
cluster_stats_messages_meet_sent:8
cluster_stats_messages_sent:737
cluster_stats_messages_ping_received:145
cluster_stats_messages_pong_received:151
cluster_stats_messages_received:296
```

2.3 为各个master 节点指派槽位范围
```
#创建添加槽位的脚本
[root@centos8 ~]#cat addslot.sh
#!/bin/bash
#
#********************************************************************
#Author: wangxiaochun
#QQ: 29308620
#Date: 2020-03-12
#FileName： addslot.sh
#URL: http://www.wangxiaochun.com
#Description： The test script
#Copyright (C): 2020 All rights reserved
#********************************************************************
host=$1
port=$2
start=$3
end=$4
pass=123456
for slot in `seq ${start} ${end}`;do
    echo slot:$slot
   redis-cli -h ${host} -p $port -a ${pass} --no-auth-warning cluster addslots 
${slot}
done

#为三个master分配槽位,共16364/3=5,461.333333333333,平均每个master分配5,461个槽位
[root@centos8 ~]#bash addslot.sh 10.0.0.8 6379 0 5461
[root@centos8 ~]#bash addslot.sh 10.0.0.18 6379 5462 10922
[root@centos8 ~]#bash addslot.sh 10.0.0.28 6379 10923 16383

#当第一个master分配完槽位后,可以看到下面信息
[root@centos8 ~]#redis-cli -a 123456 --no-auth-warning cluster info
cluster_state:ok
cluster_slots_assigned:5462
cluster_slots_ok:5462
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:1
cluster_current_epoch:5
cluster_my_epoch:3
cluster_stats_messages_ping_sent:1234
cluster_stats_messages_pong_sent:782
cluster_stats_messages_meet_sent:8
cluster_stats_messages_sent:2024
cluster_stats_messages_ping_received:782
cluster_stats_messages_pong_received:801
cluster_stats_messages_received:1583

#当第一个master分配完槽位后,可以看到下面信息
[root@centos8 ~]#redis-cli -a 123456 --no-auth-warning cluster nodes
a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379@16379 myself,master - 01602516039000 3 connected 0-5461
97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379@16379 master - 01602516044606 1 connected
cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 master - 01602516042000 0 connected
779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379@16379 master - 01602516041575 4 connected
07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379@16379 master - 01602516042585 5 connected
4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379@16379 master - 01602516043595 2 connected

#分配槽位后可以创建key
[root@centos8 ~]#redis-cli -a 123456 --no-auth-warning set name wang 
(error) MOVED 5798 10.0.0.18:6379

[root@centos8 ~]#redis-cli -h 10.0.0.18 -a 123456 --no-auth-warning set name mage 
OK

[root@centos8 ~]#redis-cli -h 10.0.0.18 -a 123456 --no-auth-warning get name
"mage"

#当所有的三个master分配完槽位后,可以看到下面信息
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster 
nodes
a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379@16379 myself,master - 01602516633000 3 connected 0-5461
97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379@16379 master - 01602516635862 1 connected 5462-10922
cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 master - 01602516635000 0 connected
779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379@16379 master - 01602516635000 4 connected
07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379@16379 master - 01602516634852 5 connected
4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379@16379 master - 01602516636872 2 connected 10923-16383

#当所有的三个master分配完槽位后,可以看到下面信息
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3                #三个成员
cluster_current_epoch:5
cluster_my_epoch:3
cluster_stats_messages_ping_sent:1832
cluster_stats_messages_pong_sent:1375
cluster_stats_messages_meet_sent:8
cluster_stats_messages_sent:3215
cluster_stats_messages_ping_received:1375
cluster_stats_messages_pong_received:1399
cluster_stats_messages_received:2774
```

2.4 指定各个节点的主从关系
```
#通过上面cluster nodes 查看master的ID信息,执行下面操作,将对应的slave 指定相应的master节点,实现三对主从节点
[root@centos8 ~]#redis-cli -h 10.0.0.38 -a 123456 --no-auth-warning cluster replicate a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab
OK
[root@centos8 ~]#redis-cli -h 10.0.0.48 -a 123456 --no-auth-warning cluster replicate 97c5dcc3f33c2fc75c7fdded25d05d2930a312c0
OK
[root@centos8 ~]#redis-cli -h 10.0.0.58 -a 123456 --no-auth-warning cluster replicate 4f146b1ac51549469036a272c60ea97f065ef832
OK

#在第一组主从节点创建成功后,可以看到下面信息
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster nodes
a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379@16379 myself,master - 01602517124000 3 connected 0-5461
97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379@16379 master - 01602517123000 1 connected 5462-10922
cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 slave a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 0 1602517125709 3 connected
779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379@16379 master - 01602517124689 4 connected
07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379@16379 master - 01602517123676 5 connected
4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379@16379 master - 01602517123000 2 connected 10923-16383

#在第一组主从节点创建成功后,可以看到下面信息
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning info replication
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.38,port=6379,state=online,offset=322,lag=1
master_replid:7af8303230e2939cc22943e991f06c6409356c6e
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:322
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:322

[root@centos8 ~]#redis-cli -h 10.0.0.38 -a 123456 --no-auth-warning info replication
# Replication
role:slave
master_host:10.0.0.8
master_port:6379
master_link_status:up
master_last_io_seconds_ago:10
master_sync_in_progress:0
slave_repl_offset:336
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:7af8303230e2939cc22943e991f06c6409356c6e
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:336
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:336

#所有三组主从节点创建成功后,可以看到最终结果
[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster nodes
a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 10.0.0.8:6379@16379 myself,master - 01602517611000 3 connected 0-5461
97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 10.0.0.18:6379@16379 master - 01602517614000 1 connected 5462-10922
cb20d58870fe05de8462787cf9947239f4bc5629 10.0.0.38:6379@16379 slave a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab 0 1602517615000 3 connected
779a24884dbe1ceb848a685c669ec5326e6c8944 10.0.0.48:6379@16379 slave 97c5dcc3f33c2fc75c7fdded25d05d2930a312c0 0 1602517616011 4 connected
07231a50043d010426c83f3b0788e6b92e62050f 10.0.0.58:6379@16379 slave 4f146b1ac51549469036a272c60ea97f065ef832 0 1602517613966 5 connected
4f146b1ac51549469036a272c60ea97f065ef832 10.0.0.28:6379@16379 master - 01602517617034 2 connected 10923-16383

[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:5
cluster_my_epoch:3
cluster_stats_messages_ping_sent:2813
cluster_stats_messages_pong_sent:2346
cluster_stats_messages_meet_sent:8
cluster_stats_messages_sent:5167
cluster_stats_messages_ping_received:2346
cluster_stats_messages_pong_received:2380
cluster_stats_messages_received:4726

[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning info replication
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.38,port=6379,state=online,offset=1022,lag=1
master_replid:7af8303230e2939cc22943e991f06c6409356c6e
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:1022
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:1022

[root@centos8 ~]#redis-cli -h 10.0.0.18 -a 123456 --no-auth-warning info replication
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.48,port=6379,state=online,offset=182,lag=1
master_replid:e4a8394213bd865a800c9326224584f8cb52f169
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:182
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:182

[root@centos8 ~]#redis-cli -h 10.0.0.28 -a 123456 --no-auth-warning info replication
# Replication
role:master
connected_slaves:1
slave0:ip=10.0.0.58,port=6379,state=online,offset=252,lag=0
master_replid:6d5e8f898e9023cfa0b7fe006ce42142175895e7
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:252
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:252

#查看主从节关系及槽位信息
[root@centos8 ~]#redis-cli -h 10.0.0.28 -a 123456 --no-auth-warning cluster slots
1) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "10.0.0.28"
      2) (integer) 6379
      3) "4f146b1ac51549469036a272c60ea97f065ef832"
   4) 1) "10.0.0.58"
      2) (integer) 6379
      3) "07231a50043d010426c83f3b0788e6b92e62050f"
2) 1) (integer) 0
   2) (integer) 5461
   3) 1) "10.0.0.8"
      2) (integer) 6379
      3) "a177c5cbc2407ebb6230ea7e2a7de914bf8c2dab"
   4) 1) "10.0.0.38"
      2) (integer) 6379
      3) "cb20d58870fe05de8462787cf9947239f4bc5629"
3) 1) (integer) 5462
   2) (integer) 10922
   3) 1) "10.0.0.18"
      2) (integer) 6379
      3) "97c5dcc3f33c2fc75c7fdded25d05d2930a312c0"
   4) 1) "10.0.0.48"
      2) (integer) 6379
      3) "779a24884dbe1ceb848a685c669ec5326e6c8944"
```

2.5 验证 redis cluster 访问
```
#-c 表示以集群方式连接
[root@centos8 ~]#redis-cli -c -h 10.0.0.8 -a 123456 --no-auth-warning set name wang
OK

[root@centos8 ~]#redis-cli -c -h 10.0.0.8 -a 123456 --no-auth-warning get name
"wang"

[root@centos8 ~]#redis-cli -h 10.0.0.8 -a 123456 --no-auth-warning get name
(error) MOVED 5798 10.0.0.18:6379

[root@centos8 ~]#redis-cli -h 10.0.0.18 -a 123456 --no-auth-warning get name
"wang"

[root@centos8 ~]#redis-cli -h 10.0.0.28 -a 123456 --no-auth-warning get name
(error) MOVED 5798 10.0.0.18:6379
```






