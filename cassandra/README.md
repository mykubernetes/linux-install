# Cassandra的介绍

| 描述 | 网址 |
|------|------|
| 博客 | https://blog.csdn.net/zwq00451?type=blog |
| 博客 | https://blog.51cto.com/michaelkang/p_2 |
| 博客 | http://zqhxuyuan.github.io/2015/10/15/Cassandra-Daily/#%E6%96%87%E4%BB%B6%E6%93%8D%E4%BD%9C |

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

# Cassandra使用场景

1、特征
- 数据写入操作密集
- 数据修改操作很少
- 通过主键查询
- 需要对数据进行分区存储

2、场景举例
- 存储日志型数据
- 类似物联网的海量数据
- 对数据进行跟踪

# 数据读写

node接收write请求，将数据写入memtable，同时记录到commit log。commit log 记录node接收到的每一次write请求，这样，即使发生断电等故障，也不会丢失数据。

memtable是一个cache，按顺序存储write的数据，当memtable 的内容大小达到配置的阈值或者commit log的存储空间大于阈值，memtable里的数据被flush到磁盘，保存为SSTables。当memtable中的数据flush到磁盘后，commit log被删除。

在内部实现上，memtable 和 SSTable按table进行划分，不同的table可以共享一个commit log。SSTable本质上是磁盘文件，不可更改，因此，一个partition 包含了多个SSTables。

best practice: 重启node前先使用nodetool flush memtable，这样可以减少commit log重放。



# Cassandra 3.9下载

> 打开官网，选择下载频道https://cassandra.apache.org/download/


# nodetool常用命令

- https://docs.datastax.com/en/archived/cassandra/2.2/cassandra/tools/toolsNodetool.html

| 命令参数 | 描述|
|---------|-----|
| assassinate | 强制的将某个节点remove掉，但是不会把节点上的数据进行摆放到移除节点后的新环的数据节点上 |
| bootstrap |  |
| cleanup | 会触发马上的清理操作，清理的目标主要是不属于这个节点的数据 |
| clearsnapshot | 清楚本机上的snapshot，如果没有提供keyspace等信息，就清理本机全部的snapshot |
| compact | 触发major compaction |
| compactionhistory | 打印compaction的历史 |
| compactionstats | 打印compaction的状态 |
| decommission | decommission连接的node, 把节点从环中移除 |
| describecluster |打印cluster的信息，包括clustername， snitch信息，partitionr信息，schema信息等 |
| describering | 给出一个keyspace以及对应的token环信息 |
| disableautocompaction | 关闭minor compaction |
| disablebackup | 关闭备份 |
| disablebinary | disable native transport(默认的9042端口服务) |
| disablegossip | 关闭gossip |
| disablehandoff | 关闭hinthandoff |
| disablehintsfordc | 关闭为某dc的hint |
| disablethrift |关闭thrift服务，默认(9160端口) |
| drain | drain 掉node，暂停很多操作，比如数据节点的写，counter，view写等操作，flush 表以及disable minor compaction |
| enableautocompaction | 开启minor compaction |
| enablebackup | 开启自动incremental backup |
| enablebinary | 开启native transport |
| enablegossip | 开启gossip |
| enablehandoff | 开启hinthandoff |
| enablehintsfordc | 开启for dc的hint handoff |
| enablethrift | 开启thrift |
| failuredetector | 集群的failure 探测的信息 |
| flush | 强制执行flush操作 |
| garbagecollect | 清除表中删除的数据 |
| gcstats | 打印gc信息 |
| getcompactionthreshold | 获取compact的阈值 |
| getcompactionthroughput | 获取compact吞吐 |
| getconcurrentcompactors | 获取系统中的并发compact的数目 |
| getendpoints | 获取拥有partition key（hash计算前）的节点 |
| getinterdcstreamthroughput | 集群内部dc stream阈值 |
| getlogginglevels | log的level |
| getsstables | 打印key属于的sstable |
| getstreamthroughput | 系统内部stream阈值 |
| gettimeout | 超时时间 |
| gettraceprobability | trace的可能值 |
| gossipinfo | gossip的信息 |
| help | 帮助 |
| info | 集群的信息 |
| invalidatecountercache | 让counter cache无效 |
| invalidatekeycache | 让keycache无效 |
| invalidaterowcache | 让rowcache无效 |
| join | join 环 |
| listsnapshots | 列出snapshot |
| move | 把这个token对应的节点换成别的token相应会移动数据 |
| netstats | 打印网络信息 |
| pausehandoff | 暂停hint的传递进程 |
| proxyhistograms | 打印网络直方图 |
| rangekeysample | 所有keyspace的抽样key信息 |
| rebuild | 从别的节点托数据 |
| rebuild_index | rebuild 本地二级索引 |
| refresh | 无需重启，直接把本地的sstable进行加载 |
| refreshsizeestimates | 重建system.size_estimates表，主要是对应节点多少数据 |
| reloadlocalschema | 从本地重新load schema表 |
| reloadtriggers | reload trigger 类 |
| relocatesstables | 搬迁sstable |
| removenode | 展示当前remove node的状态;force完成阻塞的remove操作；remove 提供的token |
| repair | 执行副本间数据修复的repair操作 |
| replaybatchlog | 开始batch log replay以及等待完成 |
| resetlocalschema | 重置本地的schema |
| resumehandoff | 恢复hinthandof的传递程序 |
| ring | 打印集群的ring信息 |
| scrub | 清理本节点无效的数据 |
| setcachecapacity | 设置cache的容量 |
| setcachekeystosave | 设置每个cache的保留容量 |
| setcompactionthreshold |这只compaction阈值 |
| setcompactionthroughput | 设置compaction吞吐 |
| setconcurrentcompactors | 设置compact的并发数 |
| sethintedhandoffthrottlekb | 设置hint的阈值 |
| setinterdcstreamthroughput | 设置dc stream的吞吐 |
| setlogginglevel |设置log的level |
| setstreamthroughput | 设置stream的阈值 |
| settimeout | 设置超时 |
| settraceprobability | 设置执行trace的概率值 |
| snapshot | 打快照 |
| status | 集群的状态 |
| statusbackup | 备份的状态 |
| statusbinary | native transport的状态 |
| statusgossip | gossip的状态 |
| statushandoff | hinthandoff的状态 |
| statusthrift  | thrift的状态 |
| stop | 停止compaction |
| stopdaemon | 停止cassandra deamon |
| tablehistograms | 表直方图 |
| tablestats | 表状态 |
| toppartitions | 抽样并给出某个表的活跃partition |
| tpstats |打出thread pool的状态 |
| truncatehints | 给出节点的所有hint 放弃掉 |
| upgradesstables | 对应的表的sstable执行upgrade(实际上就是读出来，写入新sstable) |
| verify|验证表的数据checksum |
| version | cassandra version |
| viewbuildstatus | viewbuild的状态 |

1、列出nodetool所有可用的命令
```
nodetool help 
```

2、列出指定command 的帮助内容
```
nodetool help command-name
```

显示当前Cassandra的版本信息
```
nodetool version
ReleaseVersion: 3.11.11
```

变比cassandra服务
```
nodetool stopdaemon
```

3、显示集群的基本信息，包括：集群的名字(cassandra.yaml里面配置的)、Snitch类型、是否开启dynamicendpointsnitch、集群partitioner、schmema version，因为我们是通过gossip进行信息同步，可能会存在某些节点一时间与另外节点schema version不一致，可以通过这个命令判断。
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
- UN 运行中
- DN 宕机
- UL 离线中

5、展示集群的token ring环信息，由于我这里的vnode用了默认的256，所以只列部分数据
```
nodetool -u cassandra -pw cassandra ring
Datacenter: datacenter1
==========
Address        Rack        Status State   Load            Owns                Token
                                                                              9171192753316195244
192.168.0.245  rack1       Up     Normal  266.49 KiB      64.99%              -9183757132875531958
192.168.0.250  rack1       Up     Normal  242.16 KiB      70.75%              -9159199665119898622
192.168.0.250  rack1       Up     Normal  242.16 KiB      70.75%              -9135911702874518408
192.168.0.250  rack1       Up     Normal  242.16 KiB      70.75%              -9120077450536389482
192.168.0.246  rack1       Up     Normal  238.16 KiB      64.26%              -9106101311114100850
192.168.0.246  rack1       Up     Normal  238.16 KiB      64.26%              -9069141338515824351
```
- Datacenter ： 对应的datacenter的名字，这里使用的是默认的；
- Address、Rack：表示的是对应节点以及从属的rack信息；
- Status 、State ：对应的节点的状态：Up、Down;Normal、leaving等等；
- Load：集群的对应节点的load信息，参考上面的gossip info的输出信息；
- Owns：这个ip负责的tokens的范围占整个数据范围的占比多少
- Token：对应负责的token是哪些

6、打印出给定的keyspace以及与其相关的token ring信息，此处我的token_number设置为2，方便展示信息，如果我们希望想要知道某个keyspace与其相关的token信息，可以通过这个命令获取。
```
nodetool describering <keyspace>
Schema Version:ea63e099-37c5-3d7b-9ace-32f4c833653d
TokenRange:
    TokenRange(start_token:-7410294471124200252, end_token:2438009623152110684, endpoints:[127.0.0.1], rpc_endpoints:[127.0.0.1], endpoint_details:[EndpointDetails(host:127.0.0.1, datacenter:datacenter1, rack:rack1)])
    TokenRange(start_token:2438009623152110684, end_token:-7410294471124200252, endpoints:[127.0.0.1], rpc_endpoints:[127.0.0.1], endpoint_details:[EndpointDetails(host:127.0.0.1, datacenter:datacenter1, rack:rack1)])
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

11、查看表的一些信息，包括读的次数，写的次数，sstable的数量，memtable信息，压缩信息，bloomfilter信息；
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

14、显示集群的gossip信息，下面显示的是一个三节点的集群中，各个节点相关的gossip信息输出：
```
nodetool gossipinfo
/192.168.0.250
  generation:1578559963
  heartbeat:289
  STATUS:18:NORMAL,-1000610182680759021
  LOAD:273:111238.0
  SCHEMA:20:ea63e099-37c5-3d7b-9ace-32f4c833653d
  DC:6:datacenter1
  RACK:8:rack1
  RELEASE_VERSION:4:3.11.4
  RPC_ADDRESS:3:127.0.0.1
  NET_VERSION:1:11
  HOST_ID:2:012ed1eb-0dac-4562-9812-415a7b58e6d6
  RPC_READY:32:true
  TOKENS:17:<hidden>
/192.168.0.245
  generation:1578560055
  heartbeat:196
  STATUS:58:NORMAL,-112189776392027338
  LOAD:153:115665.0
  SCHEMA:20:ea63e099-37c5-3d7b-9ace-32f4c833653d
  DC:6:datacenter1
  RACK:8:rack1
  RELEASE_VERSION:4:3.11.4
  RPC_ADDRESS:3:127.0.0.1
  NET_VERSION:1:11
  HOST_ID:2:0dbd4aca-7dd4-4833-b3db-c7d9dda0aef9
  RPC_READY:68:true
  TOKENS:57:<hidden>
/192.168.0.246
  generation:1578559991
  heartbeat:260
  STATUS:56:NORMAL,-1045048566066926798
  LOAD:213:91038.0
  SCHEMA:18:ea63e099-37c5-3d7b-9ace-32f4c833653d
  DC:6:datacenter1
  RACK:8:rack1
  RELEASE_VERSION:4:3.11.4
  RPC_ADDRESS:3:127.0.0.1
  NET_VERSION:1:11
  HOST_ID:2:3ca695aa-edd2-435c-b9ee-89e143648351
  RPC_READY:66:true
  TOKENS:55:<hidden>
```
上述信息表示了集群种三个节点对应的相关gossip信息，就第一个节点解释下相关的信息意义:
- 第一行的ip 192.168.0.250表示的是对应节点进行gossip交互ip信息；
- generation 表示的每个节点的相关的generation信息，节点的generation是交互信息的一部分，最初是当前时间的秒数（从1970年UTC时间开始到现在）;
- heartbeat 表示在当前这个generation下面执行了多少次gossip交互，默认的情况下，每隔1s会主动进行一次gossip交互任务，这里看来是经过289秒；
- 余下都是集群的状态相关的信息：在Cassandra里面都是applicationstate里的VersionedValue，可以参考下面这个图：

我们可以看到的是接下来的模块都是string0:number0:string1,其中string0 的格式就是STATUS、LOAD、SCHEMA等等这些需要的状态字符串，number0是这些状态每个一次变更就加1的version版本号，我们主要介绍是string1的具体意义；但是不是说string0 和number0 不重要。
- STATUS：表示的是对应的ip节点的状态，有9种状态（3.11.4版本代码），BOOT、BOOT_REPLACE、NORMAL、shutdown、removing、removed、LEAVING、LEFT、MOVING;
- LOAD: 表示对应节点的节点的磁盘存储容量，单位是byte；
- SCHEMA: 对应节点上面schema keyspace下面的所有table 按照顺序计算出来的一个md5值转换为的一个UUID；
- DC: 对应节从属的datacenter；
- RACK:对应节点从属的rack；
- RELEASE_VERSION:节点机器的release 软件包的版本号；
- RPC_ADDRESS: RPC的地址
- NET_VERSION:这里主要是我们的网络版本号，如果是force使用3.0 的协议版本就是10，否则是11；
- HOST_ID:节点的hostid，基于对应节点的ip等计算
- RPC_READY: 如果9042的端口或者9142（ssl）的rpc端口已经准备初始化完成，可以接收响应就是true；
- TOKENS:本来是对应节点负责的tokens，但是在这里显示的时候是hindden表示。



15、把memtable中的数据刷新到sstable，并且当前节点会终止与其他节点的联系。
> 执行完这条命令需要重启这个节点。一般在Cassandra版本升级的时候才使用这个命令。
> 如果单纯想把memtable中数据刷新到sstable，可以使用nodetool flush命令。
```
nodetool -u cassandra -pw cassandra drain
```

16、把memtable中的数据刷新到sstable，不需要重启节点。
```
nodetool -u cassandra -pw cassandra flush
```

17、清理节点上的旧数据，集群扩容后立即清理多余数据，扩容后新节点承担了原理的数据所以旧节点上的数据以及不归该节点管辖
```
nodetool -u cassandra -pw cassandra cleanup
```

18、修复当前集群的一致性，全量修复，修改大量数据时，失败的概率很大，3.x版本的BUG
```
nodetool -u cassandra -pw cassandra repair --full --trace
```

19、扩容时候可能会使⽤用write survey模式启动节点。之后再用该命令将write survey模式下节点加入集群。
```
nodetool join
```

20、单节点修复
```
nodetool -u cassandra -pw cassandra repair -pr
```
- 在删除数据的时候，Casssandra并非真实的删除，而是重新插入一条的数据，记录了删除的记录的信息和时间，叫做tombstone墓碑。使用nodetool repair，可以删除tombstone数据。频繁修改的数据节点可以使用这个命令节省空间、提高读速度。

21、当有新的数据中心加入，运行这个命令复制数据到数据中心
```
nodetool rebuild
```

22、重建索引
```
nodetool -u cassandra -pw cassandra rebuild_index
```

23、移动节点到指定的token,只能用在单个token的节点上，通俗讲就是换一个区间给该节点管理，会移动数据，一般是根据业务，自己设计了分区策略，自己计算token的时候可能会用到，默认每个节点随机256个token出来，用不到这个命令
```
nodetool -u cassandra -pw cassandra move <new token>
```

24、resetlocalschema 解决节点表Schema不一致问题
```
nodetool resetlocalschema
```

25、重启节点上cassandra
```
nodetool -u cassandra -pw cassandra disablegossip       #禁用gossip通讯，该节点停止与其他节点的gossip通讯，忽略从其他节点发来的请求
nodetool -u cassandra -pw cassandra disablebinary       #禁止本地传输（二进制协议）binary CQL protocol
nodetool -u cassandra -pw cassandra disablethirft       #禁用thrift server,即禁用该节点会充当coordinator,早期版本的cassandra使用thrift协议
nodetool -u cassandra -pw cassandra flush               #会把memtable中的数据刷新导sstable
nodetool -u cassandra -pw cassandra drain               #会把memtable中的数据刷新导sstable,单曲节点会终止其他系欸但的联系，执行完该命令后，需要stopdaemon重启
nodetool -u cassandra -pw cassandra stopdaemon          #停止cassandra进程，k8s会重启pod,这样pod ip 不会改变，对服务器影响比较小
nodetool -u cassandra -pw cassandra status -r           #查看集群所有节点状态
```

26、日志相关操作
```
nodetool -u cassandra -pw cassandra getlogginglevels               #查看日志级别
nodetool -u cassandra -pw cassandra setlogginglevel ROOT DEBUG     #设置日志级别为DEBUG
```

27、压缩相关操作
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

#6、停止正在执行的压缩，避免备份数据时sstable compaction 变化
nodetool -u cassandra -pw cassandra stop COMPACTION

#7、启动自动压缩
nodetool -u cassandra -pw cassandra enableautocompaction

#8、获取compact吞吐
nodetool -u cassandra -pw cassandra getcompactionthroughput            #打印compaction throughput
Current compaction throughput: 16 MB/s

#9、设置compact吞吐
nodetool -u cassandra -pw cassandra setcompactionthroughput 100        #设置compaction throughput，默认100Mb/s
```

集群迁移速度
```
限制集群所有节点数据迁移流量，集群扩容使用
nodetool -u cassandra -pw cassandra setstreamthroughput 200           #设置streaming throughput 默认200Mb/s
nodetool getstreamthroughput
```

28、移除节点
```
# 需要在删除的机器上执行，缩容数据会迁移到其他节点，执行后命令会一直开着，节点处于LEAVING状态，直到结束。可以提前中断因为实际过程server端异步执行
nodetool -u cassandra -pw cassandra decommission                                         #退服节点

# 需要在删除的机器上执行，无法使用decommission时候才会用到此命令，功能类似decommission。比如要下线的目标节点down了，无法恢复
nodetool -u cassandra -pw cassandra removenode 88e16e35-50dd-4ee3-aa1a-f10a8c61a3eb      #节点下线

nodetool -u cassandra -pw cassandra assassinate node_ip                                  #强制删除节点
```

29、快照备份
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

30、合并sstable文件。
```
nodetool compact
```
- 省略表，压缩keyspace下面的所有表
- 省略keyspace，压缩所有keyspace下的所有表


# 性能诊断工具

cassandra专项监控

| 命令 | 描述 |
|------|-----|
| nodetool status | 集群基本信息  |
| nodetool netstats | 网络链接操作的统计 |
| nodetool tablestats | 表上的统计信息 |
| nodetool proxyhistograms | 网络耗时直方图 |
| nodetool tpstats | 线程统计 |
| nodetool compactionstats | 压缩情况 |
| nodetool tablehistograms | 表直方图 |

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

5、查看key分布在哪一个节点上上，分析热点或者过大的partition时，进一步定位受影响的节点，可以用来预测业务数据均衡情况
```
nodetool getendpoints <keyspace> <table> <key>
```

6、查看key分布在哪一个SSTable上
```
nodetool getsstables <keyspace> <table> <key>
```

7、查看所有线程池的运行情况，可以观察某些任务是否有阻塞现象
```
nodetool tpstats
```

8、查看某个节点负载，内存使用情况
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

# cqlsh命令

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



