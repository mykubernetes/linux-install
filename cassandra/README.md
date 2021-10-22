Cassandra的介绍
---

| 描述 | 网址 |
|------|------|
| 博客 | https://blog.csdn.net/zwq00451?type=blog |
| 博客 | https://blog.51cto.com/michaelkang/p_2 |


1、Cassandra概述

> Cassandra是一套开源分布式NoSQL数据库系统。它最初由Facebook开发，用于储存收件箱等简单格式数据，集[Google](https://baike.baidu.com/item/Google)[BigTable](https://baike.baidu.com/item/BigTable)的数据模型与[Amazon](https://baike.baidu.com/item/Amazon) Dynamo的完全分布式的架构于一身Facebook于2008将 Cassandra 开源，此后，由于Cassandra良好的[可扩展性](https://baike.baidu.com/item/可扩展性/8669999)，被[Digg](https://baike.baidu.com/item/Digg)、[Twitter](https://baike.baidu.com/item/Twitter)等知名[Web 2.0](https://baike.baidu.com/item/Web 2.0)网站所采纳，成为了一种流行的分布式结构化数据存储方案。

2、Cassandra的官网

Cassandra在2009年成为了Apache软件基金会的Incubator项目，并在2010年2月走出孵化器，成为正式的基金会项目。

> 官网地址：https://cassandra.apache.org/

3、Cassandra特点

- **弹性可扩展性** - Cassandra是高度可扩展的; 它允许添加更多的硬件以适应更多的客户和更多的数据根据要求。
- **始终基于架构** - Cassandra没有单点故障，它可以连续用于不能承担故障的关键业务应用程序。
- **快速线性性能** - Cassandra是线性可扩展性的，即它为你增加集群中的节点数量增加你的吞吐量。因此，保持一个快速的响应时间。
- **灵活的数据存储** - Cassandra适应所有可能的数据格式，包括：结构化，半结构化和非结构化。它可以根据您的需要动态地适应变化的数据结构。
- **便捷的数据分发** - Cassandra通过在多个数据中心之间复制数据，可以灵活地在需要时分发数据。
- **事务支持** - Cassandra支持属性，如原子性，一致性，隔离和持久性（ACID）。
- **快速写入** - Cassandra被设计为在廉价的商品硬件上运行。 它执行快速写入，并可以存储数百TB的数据，而不牺牲读取效率。

Cassandra使用场景
---
1、特征
- 数据写入操作密集
- 数据修改操作很少
- 通过主键查询
- 需要对数据进行分区存储

2、场景举例
- 存储日志型数据
- 类似物联网的海量数据
- 对数据进行跟踪

数据读写
---
node接收write请求，将数据写入memtable，同时记录到commit log。commit log 记录node接收到的每一次write请求，这样，即使发生断电等故障，也不会丢失数据。

memtable是一个cache，按顺序存储write的数据，当memtable 的内容大小达到配置的阈值或者commit log的存储空间大于阈值，memtable里的数据被flush到磁盘，保存为SSTables。当memtable中的数据flush到磁盘后，commit log被删除。

在内部实现上，memtable 和 SSTable按table进行划分，不同的table可以共享一个commit log。SSTable本质上是磁盘文件，不可更改，因此，一个partition 包含了多个SSTables。

best practice: 重启node前先使用nodetool flush memtable，这样可以减少commit log重放。



Cassandra 3.9下载
---
> 打开官网，选择下载频道https://cassandra.apache.org/download/


nodetool常用命令
---

https://cloud.tencent.com/developer/article/1772888?from=information.detail.Nodetool

http://www.mamicode.com/info-detail-2723557.html

1、列出nodetool所有可用的命令
```
nodetool help 
```

2、列出指定command 的帮助内容
```
nodetool help command-name
```

3、查看集群信息，获取集群名称，检查各节点Schema是否一致
```
nodetool -u cassandra -pw cassandra describecluster
Cluster Information:
        Name: pttest
        Snitch: org.apache.cassandra.locator.GossipingPropertyFileSnitch
        DynamicEndPointSnitch: enabled
        Partitioner: org.apache.cassandra.dht.Murmur3Partitioner
        Schema versions:
                8560f200-adbb-3a18-8d5e-a1f7f7856194: [172.20.101.164, 172.20.101.165, 172.20.101.166, 172.20.101.167, 172.20.101.160, 172.20.101.157]
```

4、查看集群节点状态，查看集群整体健康节点情况，查看数据分布容量，查看节点IP,部署位置等基本信息

UN=UP&Normal  load表示每个节点维护的数据的字节数，owns列表示一个节点拥有的令牌的区间的有效百分比
```
nodetool -u cassandra -pw cassandra status
Datacenter: dc1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load        Tokens Owns (effective)  Host ID                               Rack
UN  172.20.101.164  173.72 KiB  256    34.2%             dcbbad83-fe7c-4580-ade7-aa763b8d2c40  rack1
UN  172.20.101.165  50.4 KiB    256    35.0%             cefe8a3b-918f-463b-8c7d-faab0b9351f9  rack1
UN  172.20.101.166  95.5 KiB    256    34.1%             88e16e35-50dd-4ee3-aa1a-f10a8c61a3eb  rack1
UN  172.20.101.167  50.4 KiB    256    32.3%             8808aaf7-690c-4f0c-be9b-ce655c1464d4  rack1
UN  172.20.101.160  194.83 KiB  256    31.5%             57cc39fc-e47b-4c96-b9b0-b004f2b79242  rack1
UN  172.20.101.157  176.67 KiB  256    33.0%             091ff0dc-415b-48a7-b4ce-e70c84bbfafc  rack1
```

5、ring 确定环中节点（包括虚拟节点）状态
```
nodetool -u cassandra -pw cassandra ring
```

6、describering 查看keyspace 数据分区详细信息，可以用来分析热点，知道热点数据的partition key分布后，可以进一步通过此命令知道数据会由哪些节点负责
```
nodetool describering <keyspace>
```

7、info 查看读Cache命中率，调优性能。如果名利率很低，业务可以通过提升命中率改善读延迟。如果命中率很高，可以尝试增加读cache获取更多收益
```
nodetool -u cassandra -pw cassandra -h 10.224.0.3 info
ID                     : 091ff0dc-415b-48a7-b4ce-e70c84bbfafc
Gossip active          : true
Thrift active          : false
Native Transport active: true
Load                   : 282.65 KiB
Generation No          : 1561803589
Uptime (seconds)       : 844997
Heap Memory (MB)       : 354.14 / 3970.00
Off Heap Memory (MB)   : 0.00
Data Center            : dc1
Rack                   : rack1
Exceptions             : 0
——————————————————————————和命中相关
Key Cache              : entries 119, size 11.7 KiB, capacity 100 MiB, 435 hits, 596 requests, 0.730 recent hit rate, 14400 save period in seconds
Row Cache              : entries 0, size 0 bytes, capacity 0 bytes, 0 hits, 0 requests, NaN recent hit rate, 0 save period in seconds
Counter Cache          : entries 0, size 0 bytes, capacity 50 MiB, 0 hits, 0 requests, NaN recent hit rate, 7200 save period in seconds
Chunk Cache            : entries 11, size 704 KiB, capacity 480 MiB, 1388 misses, 2253 requests, 0.384 recent hit rate, NaN microseconds miss latency
——————————————————————————
Percent Repaired       : 100.0%
Token                  : (invoke with -T/--tokens to see all 256 tokens)w
```

8、tpstats Cassandra维护的线程池信息，上半部分表示cassandra线程池中任务的相关数据，下半部分给出了节点丢弃的消息数

active、pending以及完成的任务等Cassandra操作的每个阶段的状态
```
nodetool -u cassandra -pw cassandra tpstats
Pool Name                         Active   Pending      Completed   Blocked  All time blocked
ReadStage                              0         0            140         0                 0
MiscStage                              0         0              0         0                 0
CompactionExecutor                     0         0         491131         0                 0
MutationStage                          0         0             45         0                 0
MemtableReclaimMemory                  0         0            586         0                 0
PendingRangeCalculator                 0         0             13         0                 0
GossipStage                            0         0        3150790         0                 0
.....
PerDiskMemtableFlushWriter_0           0         0            586         0                 0
ValidationExecutor                     0         0              0         0                 0
.....

Message type           Dropped
READ                         0
.........
REQUEST_RESPONSE             0
PAGED_RANGE                  0
READ_REPAIR                  0
```

9、nodetool cfstats 显示了每个表和keyspace的统计数据；
```
# 1、创建keyspace
create keyspace ptmind_test with replication = {'class':'NetworkTopologyStrategy','dc1':2} and durable_writes = true;

# 2、创建表
cassandra@cqlsh:ptmind_test> CREATE TABLE users (
               ...   user_id text PRIMARY KEY,
               ...   first_name text,
               ...   last_name text,
               ...   emails set<text>
               ... );

# 3、插入数据：
INSERT INTO users (user_id, first_name, last_name, emails) VALUES('2', 'kevin', 'kevin', {'kevin@ptmind.com', 'kevin@gmail.com'});


# 4、显示了每个表和keyspace的统计数据
nodetool cfstats ptmind_test.users
Total number of tables: 37
----------------
Keyspace : ptmind_test
        Read Count: 0
        Read Latency: NaN ms
        Write Count: 0
        Write Latency: NaN ms
        Pending Flushes: 0
                Table: users
................................
                Average live cells per slice (last five minutes): NaN
                Maximum live cells per slice (last five minutes): 0
                Average tombstones per slice (last five minutes): NaN
                Maximum tombstones per slice (last five minutes): 0
                Dropped Mutations: 0
```

10、nodetool cfhistograms 显示表的统计数据，包括读写延迟，行大小，列的数量和SSTable的数量；
```
# nodetool cfhistograms ptmind_test.users

No SSTables exists, unable to calculate 'Partition Size' and 'Cell Count' percentiles
ptmind_test/users histograms
Percentile  SSTables     Write Latency      Read Latency    Partition Size        Cell Count
                              (micros)          (micros)           (bytes)                  
50%             0.00              0.00              0.00               NaN               NaN
........
Max             0.00              0.00              0.00               NaN               NaN
```

11、查看keyspace和table的统计信息
```
nodetool -u cassandra -pw cassandra tablestats {KEYSPACE_NAME}
```

12、获取节点的网络连接信息，查看节点间网络传输,应用场景新节点扩容后，查看节点状态，数据同步速度，也能查看消息处理情况，有没有堆积等
```
nodetool -u cassandra -pw cassandra netstats --human-readable
Mode: NORMAL
Not sending any streams.
Read Repair Statistics:
Attempted: 0
Mismatch (Blocking): 0
Mismatch (Background): 0
Pool Name                    Active   Pending      Completed   Dropped
Large messages                  n/a         0              0         0
Small messages                  n/a         0            163         0
Gossip messages                 n/a         0        3150335         0
```

13、显示当前正在压缩的任务进度
```
nodetool compactionstats
pending tasks: 0
```

14、刷新输出
```
nodetool -u cassandra -pw cassandra flush
```

15、清理节点上的旧数据，集群扩容后立即清理多余数据，扩容后新节点承担了原理的数据所以旧节点上的数据以及不归该节点管辖
```
nodetool -u cassandra -pw cassandra cleanup
```

16、修复当前集群的一致性，全量修复，修改大量数据时，失败的概率很大，3.x版本的BUG
```
nodetool -u cassandra -pw cassandra repair --full --trace
```

17、扩容时候可能会使⽤用write survey模式启动节点。之后再用该命令将write survey模式下节点加入集群。
```
nodetool join
```

18、单节点修复
```
nodetool -u cassandra -pw cassandra repair -pr
```

19、重建索引
```
nodetool -u cassandra -pw cassandra rebuild_index
```

20、移动节点到指定的token,只能用在单个token的节点上，通俗讲就是换一个区间给该节点管理，会移动数据，一般是根据业务，自己设计了分区策略，自己计算token的时候可能会用到，默认每个节点随机256个token出来，用不到这个命令
```
nodetool -u cassandra -pw cassandra move <new token>
```

21、resetlocalschema 解决节点表Schema不一致问题
```
nodetool resetlocalschema
```

22、重启节点上cassandra
```
nodetool -u cassandra -pw cassandra disablegossip       #禁用gossip通讯，该节点停止与其他节点的gossip通讯，忽略从其他节点发来的请求
nodetool -u cassandra -pw cassandra disablebinary       #禁止本地传输（二进制协议）binary CQL protocol
nodetool -u cassandra -pw cassandra disablethirft       #禁用thrift server,即禁用该节点会充当coordinator,早期版本的cassandra使用thrift协议
nodetool -u cassandra -pw cassandra flush               #会把memtable中的数据刷新导sstable
nodetool -u cassandra -pw cassandra drain               #会把memtable中的数据刷新导sstable,单曲节点会终止其他系欸但的联系，执行完该命令后，需要stopdaemon重启
nodetool -u cassandra -pw cassandra stopdaemon          #停止cassandra进程，k8s会重启pod,这样pod ip 不会改变，对服务器影响比较小
nodetool -u cassandra -pw cassandra status -r           #查看集群所有节点状态
```

23、日志相关操作
```
nodetool -u cassandra -pw cassandra getlogginglevels               #查看日志级别
nodetool -u cassandra -pw cassandra setlogginglevel ROOT DEBUG     #设置日志级别为DEBUG
```

24、压缩相关操作
```
#1、手动触发Major Compaction,用以优化读性能和清理被删除的数据释放空间。
nodetool -u cassandra -pw cassandra compact --user-defined mc-103-big-Date.db

#2、查看compaction任务压缩历史，保留7天。可以观察compaction效果，释放空间多少，以及数据重复情况。
nodetool -u cassandra -pw cassandra compactionhistory

#3、查看当前compaction任务进度
nodetool -u cassandra -pw cassandra compactionstats

#4、清理已经删除的数据，用以优化性能和释放空间,与compact命令区别是所需磁盘会少很多。会通过多个compaction task完成对SSTable的操作时间更久。清理效果不如Major compaction.
nodetool garbagecollect [<keyspace> <tables>]

#5、禁用自动压缩
nodetool -u cassandra -pw cassandra disableautocompaction

#6、启动自动压缩
nodetool -u cassandra -pw cassandra enableautocompaction

#7、获取compact吞吐
nodetool -u cassandra -pw cassandra getcompactionthroughput           #打印compaction throughput

#8、设置compact吞吐
nodetool -u cassandra -pw cassandra setcompactionhroughput 100        #设置compaction throughput，默认100Mb/s

#9、停止压缩，避免备份数据时sstable compaction 变化
nodetool -u cassandra -pw cassandra stop --COMPACTION

#10、限制集群所有节点数据迁移流量，集群扩容使用
nodetool -u cassandra -pw cassandra setstreamthroughput 200           #设置streaming throughput 默认200Mb/s
nodetool getstreamthroughput
```

25、移除节点
```
# 需要在删除的机器上执行，缩容数据会迁移到其他节点，执行后命令会一直开着，节点处于LEAVING状态，直到结束。可以提前中断因为实际过程server端异步执行
nodetool -u cassandra -pw cassandra decommission                                         #退服节点

# 需要在删除的机器上执行，无法使用decommission时候才会用到此命令，功能类似decommission。比如要下线的目标节点down了，无法恢复
nodetool -u cassandra -pw cassandra removenode 88e16e35-50dd-4ee3-aa1a-f10a8c61a3eb      #节点下线

nodetool -u cassandra -pw cassandra assassinate node_ip                                  #强制删除节点
```

26、快照备份
```
#创建快照
nodetool -u cassandra -pw cassandra snapshot

#查看快照列表
nodetool -u cassandra -pw cassandra listsnapshots

#启动增量备份
nodetool -u cassandra -pw cassandra enbalebackup

清楚本机上的snapshot，如果没有提供keyspace等信息，就清理本机全部的snapshot
nodetool -u cassandra -pw cassandra clearsnapshot
```

性能诊断工具
---

1、proxyhistograms 从Coordinator视角查看最近读写延迟，可以用来诊断慢节点。Coordinator是负责接受用户请求，再并发读写其他集群内部节点的模块，类似proxy.每个节点都可以作为Coordinator
```
nodetool proxyhistograms
```

2、查看table级别延迟，统计的是本地执行，不是从Coordinator视角，也可以用来诊断Partition是否过大
```
nodetool tablehistograms <keyspace> <table> | <keyspace.table>
nodetool tablehistograms school.students
```

3、tablestats 查看table资源使用情况，磁盘空间，内存等。查看table读写请求统计。查看tombstones数据，分析读性能表现太差的原因
```
nodetool tablestats [<keyspace.table>]
nodetool tablestats school.students
```

4、toppartitions 分析热点用，通过抽样统计一段时间，得出最热的那些partition key,没请求的时候无法统计，统计不是完全精准的，是近似
```
nodetool toppartitions <keyspace> <cfname> <duration>
nodetool toppartitions school students 100
```

5、getendpoints 计算某个partition key会分布在那些节点上，分析热点或者过大的partition时，进一步定位受影响的节点，可以用来预测业务数据均衡情况
```
nodetool getendpoints <keyspace> <table> <key>
```

6、查看所有线程池的运行情况，可以观察某些任务是否有阻塞现象
```
nodetool tpstats
```

7、查看某个节点负载，内存使用情况
```
# nodetool info
ID                     : 091ff0dc-415b-48a7-b4ce-e70c84bbfafc
Gossip active          : true
Thrift active          : false
Native Transport active: true
Load                   : 282.65 KiB
Generation No          : 1561803589
Uptime (seconds)       : 844997
Heap Memory (MB)       : 354.14 / 3970.00
Off Heap Memory (MB)   : 0.00
Data Center            : dc1
Rack                   : rack1
Exceptions             : 0
Key Cache              : entries 119, size 11.7 KiB, capacity 100 MiB, 435 hits, 596 requests, 0.730 recent hit rate, 14400 save period in seconds
Row Cache              : entries 0, size 0 bytes, capacity 0 bytes, 0 hits, 0 requests, NaN recent hit rate, 0 save period in seconds
Counter Cache          : entries 0, size 0 bytes, capacity 50 MiB, 0 hits, 0 requests, NaN recent hit rate, 7200 save period in seconds
Chunk Cache            : entries 11, size 704 KiB, capacity 480 MiB, 1388 misses, 2253 requests, 0.384 recent hit rate, NaN microseconds miss latency
Percent Repaired       : 100.0%
Token                  : (invoke with -T/--tokens to see all 256 tokens)w
```

cqlsh命令
---

| 命令        | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| HELP        | 显示所有cqlsh命令的帮助主题                                  |
| CAPTURE     | 捕获命令的输出并将其添加到文件                               |
| CONSISTENCY | 显示当前一致性级别，或设置新的一致性级别                     |
| COPY        | 将数据复制到Cassandra并从Cassandra复制数据                   |
| DESCRIBE    | 描述Cassandra及其对象的当前集群                              |
| EXPAND      | 纵向扩展查询的输出                                           |
| EXIT        | 终止cqlsh                                                    |
| PAGING      | 启用或禁用查询分页                                           |
| SHOW        | 显示当前cqlsh会话的详细信息，如Cassandra版本，主机或数据类型假设 |
| SOURCE      | 执行包含CQL语句的文件                                        |
| TRACING     | 启用或禁用请求跟踪                                           |

数据定义命令

| 指令            | 描述                      |
| --------------- | ------------------------- |
| CREATE KEYSPACE | 在Cassandra中创建KeySpace |
| USE             | 连接到已创建的KeySpace    |
| ALTER KEYSPACE  | 更改KeySpace的属性        |
| DROP KEYSPACE   | 删除KeySpace              |
| CREATE TABLE    | 在KeySpace中创建表        |
| ALTER TABLE     | 修改表的列属性            |
| DROP TABLE      | 删除表                    |
| TRUNCATE        | 从表中删除所有数据        |
| CREATE INDEX    | 在表的单个列上定义新索引  |
| DROP INDEX      | 删除命名索引              |

数据操作指令

| 指令   | 描述              |
| ------ | ----------------- |
| INSERT | 在表中添加行的列  |
| UPDATE | 更新行的列        |
| DELETE | 从表中删除数据    |
| BATCH  | 一次执行多个DML语 |

查询指令

| 指令    | 描述                                                |
| ------- | --------------------------------------------------- |
| SELECT  | 从表中读取数据                                      |
| WHERE   | where子句与select一起使用以读取特定数据             |
| ORDERBY | orderby子句与select一起使用，以特定顺序读取特定数据 |

常规命令选项
```
选项     用法        介绍
cqlsh --help               # 显示有关cqlsh命令的选项的帮助主题。
cqlsh --version            # 提供您正在使用的cqlsh的版本。
cqlsh --color              # 指示shell使用彩色输出。
cqlsh --debug              # 显示更多的调试信息。
cqlsh --execute            # 指示shell接受并执行CQL命令。
cql_statement              # 指示shell接受并执行CQL命令。
cqlsh --file= "file name"  # 如果使用此选项，Cassandra将在给定文件中执行命令并退出。
cqlsh --no-color           # 指示Cassandra不使用彩色输出。
cqlsh -u "user name"       # 使用此选项，您可以验证用户。默认用户名为：cassandra。
cqlsh-p "pass word"        # 使用此选项，您可以使用密码验证用户。默认密码为：cassandra。
```
```
#1、连接到cassandra
cqlsh -u cassandra -p cassandra

#2、查看所有的keyspaces
DESCRIBE KEYSPACES

#3、查看创建语法
DESCRIBE KEYSPACE keyspace_name;

#4、显示当前级别CONSISTENCY
CONSISTENCY 
Current consistency level is ONE.

#5、查看集群信息
DESCRIBE CLUSTER

#6、连接到指定keyspace
USE sps_proxy

#7、查看所有table
DESCRIBE TABLES

#8、表的描述
DESCRIBE TABLE tables_name

#9、查看keyspace信息
DESCRIBE KEYSPACE_NAME

#10、查看table描述
DESCRIBE TABLE TABLE_NAME

#11、查看所有用户自定义数据类型（当前为空）
DESCRIBE TYPES

#12查看用户自定义数据类型描述
DESCRIBE TYPE xxx

#13、显示当前cqlsh 会话信息
SHOW HOST

#14、扩展输出，使用此命令前必须打开expand 命令
cqlsh:cqlsh> expand on;
cqlsh:cqlsh> select * from users;
cassandra@cqlsh:ptmind_test> select * from users;

@ Row 1
------------+-----------------------------------------
 user_id    | 2
 emails     | {'kevin@gmail.com', 'kevin@ptmind.com'}
 first_name | kevin
 last_name  | kevin

@ Row 2
------------+-----------------------------------------

(2 rows)

使用以下命令关闭展开选项。

cqlsh:cqlsh> expand off;
Disabled Expanded output.
##################################################


# 15、COPY 将数据从Cassandra复制到文件中
cassandra@cqlsh:ptmind_test> COPY users (user_id, first_name, last_name, emails) TO 'kevinfile';
Using 3 child processes

Starting copy of ptmind_test.users with columns [user_id, first_name, last_name, emails].
Processed: 2 rows; Rate:       1 rows/s; Avg. rate:       1 rows/s
2 rows exported to 1 files in 1.472 seconds.

验证：
[root@kubm-01 ~]# more kevinfile 

2,kevin,kevin,"{'kevin@gmail.com', 'kevin@ptmind.com'}"
frodo,Frodo,Baggins,"{'baggins@gmail.com', 'f@baggins.com'}"


##################################################

# 16、source 从文件执行命令

# more cqshell.source 
select * from users;

登陆执行；
cassandra@cqlsh:ptmind_test> SOURCE '/root/cqshell.source'

 user_id | emails                                  | first_name | last_name
---------+-----------------------------------------+------------+-----------
       2 | {'kevin@gmail.com', 'kevin@ptmind.com'} |      kevin |     kevin
   frodo |  {'baggins@gmail.com', 'f@baggins.com'} |      Frodo |   Baggins

```



