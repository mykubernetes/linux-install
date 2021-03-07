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

3、查看集群信息
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

4、查看集群节点状态
UN=UP&Normal  load表示每个节点维护的数据的字节数，owns列表示一个节点拥有的令牌的区间的有效百分比
```
nodetool -u cassandra -pw cassandra status
Datacenter: dc1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load       Tokens Owns (effective)  Host ID                               Rack
UN  172.20.101.164  173.72 KiB  256    34.2%       dcbbad83-fe7c-4580-ade7-aa763b8d2c40  rack1
UN  172.20.101.165  50.4 KiB    256    35.0%       cefe8a3b-918f-463b-8c7d-faab0b9351f9  rack1
UN  172.20.101.166  95.5 KiB    256    34.1%       88e16e35-50dd-4ee3-aa1a-f10a8c61a3eb  rack1
UN  172.20.101.167  50.4 KiB    256    32.3%       8808aaf7-690c-4f0c-be9b-ce655c1464d4  rack1
UN  172.20.101.160  194.83 KiB  256    31.5%       57cc39fc-e47b-4c96-b9b0-b004f2b79242  rack1
UN  172.20.101.157  176.67 KiB  256    33.0%       091ff0dc-415b-48a7-b4ce-e70c84bbfafc  rack1
```

5、ring 确定环中节点（包括虚拟节点）状态
```
nodetool -u cassandra -pw cassandra ring
```

6、info 获取指定节点信息
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
Key Cache              : entries 119, size 11.7 KiB, capacity 100 MiB, 435 hits, 596 requests, 0.730 recent hit rate, 14400 save period in seconds
Row Cache              : entries 0, size 0 bytes, capacity 0 bytes, 0 hits, 0 requests, NaN recent hit rate, 0 save period in seconds
Counter Cache          : entries 0, size 0 bytes, capacity 50 MiB, 0 hits, 0 requests, NaN recent hit rate, 7200 save period in seconds
Chunk Cache            : entries 11, size 704 KiB, capacity 480 MiB, 1388 misses, 2253 requests, 0.384 recent hit rate, NaN microseconds miss latency
Percent Repaired       : 100.0%
Token                  : (invoke with -T/--tokens to see all 256 tokens)w
```

7、tpstats Cassandra维护的线程池信息，上半部分表示cassandra线程池中任务的相关数据，下半部分给出了节点丢弃的消息数

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

8、nodetool cfstats 显示了每个表和keyspace的统计数据；
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

9、nodetool cfhistograms 显示表的统计数据，包括读写延迟，行大小，列的数量和SSTable的数量；
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

10、查看keyspace和table的统计信息
```
nodetool -u cassandra -pw cassandra tablestats {KEYSPACE_NAME}
```

11、获取节点的网络连接信息，查看节点间网络传输
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

nodetool compactionstats 显示当前正在压缩的任务进度
```
pending tasks: 0
```

12、刷新输出
```
nodetool -u cassandra -pw cassandra flush
```

13、清理节点上的旧数据
```
nodetool -u cassandra -pw cassandra cleanup
```

14、修复当前集群的一致性，全量修复，修改大量数据时，失败的概率很大，3.x版本的BUG
```
nodetool -u cassandra -pw cassandra repair --full --trace
```

15、单节点修复
```
nodetool -u cassandra -pw cassandra repair -pr
```

16、重建索引
```
nodetool -u cassandra -pw cassandra rebuild_index
```

17、移动token
```
nodetool -u cassandra -pw cassandra move token_value
```

18、重启节点上cassandra
```
nodetool -u cassandra -pw cassandra disablegossip       #禁用gossip通讯，该节点停止与其他节点的gossip通讯，忽略从其他节点发来的请求
nodetool -u cassandra -pw cassandra disablebinary       #禁止本地传输（二进制协议）binary CQL protocol
nodetool -u cassandra -pw cassandra disablethirft       #禁用thrift server,即禁用该节点会充当coordinator,早期版本的cassandra使用thrift协议
nodetool -u cassandra -pw cassandra flush               #会把memtable中的数据刷新导sstable
nodetool -u cassandra -pw cassandra drain               #会把memtable中的数据刷新导sstable,单曲节点会终止其他系欸但的联系，执行完该命令后，需要stopdaemon重启
nodetool -u cassandra -pw cassandra stopdaemon          #停止cassandra进程，k8s会重启pod,这样pod ip 不会改变，对服务器影响比较小
nodetool -u cassandra -pw cassandra status -r           #查看集群所有节点状态
```

19、日志相关操作
```
nodetool -u cassandra -pw cassandra getlogginglevels               #查看日志级别
nodetool -u cassandra -pw cassandra setlogginglevel ROOT DEBUG     #设置日志级别为DEBUG
```

20、压缩相关操作
```
nodetool -u cassandra -pw cassandra disableautocompaction             #禁用自动压缩
nodetool -u cassandra -pw cassandra enableautocompaction              #启动自动压缩
nodetool -u cassandra -pw cassandra compactionstats                   #压缩状态查看
nodetool -u cassandra -pw cassandra compact --user-defined mc-103-big-Date.db       手动指定文件压缩
nodetool -u cassandra -pw cassandra setstreamthroughput 200           #设置streaming throughput 默认200Mb/s
nodetool -u cassandra -pw cassandra getcompactionthroughput           #打印compaction throughput
nodetool -u cassandra -pw cassandra setcompactionhroughput 100        #设置compaction throughput，默认100Mb/s
nodetool -u cassandra -pw cassandra stop --COMPACTION                 #停止压缩，避免备份数据时sstable compaction 变化
nodetool -u cassandra -pw cassandra compactionhistory                 #显示压缩操作历史
```

21、移除节点
```
需要在删除的机器上执行
nodetool -u cassandra -pw cassandra decommission             #退服节点
nodetool -u cassandra -pw cassandra removenode               #节点下线

nodetool -u cassandra -pw cassandra assassinate node_ip      #强制删除节点
```

22、快照备份
```
nodetool -u cassandra -pw cassandra snapshot              #创建快照
nodetool -u cassandra -pw cassandra listsnapshots         #查看快照列表
nodetool -u cassandra -pw cassandra enbalebackup          #启动增量备份
nodetool -u cassandra -pw cassandra clearsnapshot         #清空所有旧快照
```


cqlsh命令
---

```
#连接到cassandra
cqlsh -u cassandra -p cassandra

#查看所有的keyspaces
DESCRIBE KEYSPACES

#查看集群信息
DESCRIBE CLUSTER

#连接到指定keyspace
USE sps_proxy

#查看所有table
DESCRIBE TABLES

#查看keyspace信息
DESCRIBE KEYSPACE_NAME

#查看table描述
DESCRIBE TABLE TABLE_NAME

#查看所有用户自定义数据类型（当前为空）
DESCRIBE TYPES

#查看用户自定义数据类型描述
DESCRIBE TYPE xxx

#扩展输出，使用此命令前必须打开expand 命令
EXPAND ON

#显示当前cqlsh 会话信息
SHOW HOST

#从文件执行命令
source filename
```

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


Cqlsh命令
```
HELP         #显示所有cqlsh命令的帮助主题。
CAPTURE      #捕获命令的输出并将其添加到文件。
CONSISTENCY  #显示当前一致性级别，或设置新的一致性级别。
COPY         #将数据复制到Cassandra并从Cassandra复制数据。
DESCRIBE     #描述Cassandra及其对象的当前集群。
EXPAND       #纵向扩展查询的输出。
EXIT         #使用此命令，可以终止cqlsh。
PAGING       #启用或禁用查询分页。
SHOW         #显示当前cqlsh会话的详细信息，如Cassandra版本，主机或数据类型假设。
SOURCE       #执行包含CQL语句的文件。
TRACING      #启用或禁用请求跟踪。
```

CQL数据定义命令
```
CREATE KEYSPACE  #在Cassandra中创建KeySpace。
USE              #连接到已创建的KeySpace。
ALTER KEYSPACE   #更改KeySpace的属性。
DROP KEYSPACE    #删除KeySpace。
CREATE TABLE     #在KeySpace中创建表。
ALTER TABLE      #修改表的列属性。
DROP TABLE       #删除表。
TRUNCATE         #从表中删除所有数据。
CREATE INDEX     #在表的单个列上定义新索引。
DROP INDEX       #删除命名索引。
```

CQL数据操作指令
```
INSERT           #在表中添加行的列。
UPDATE           #更新行的列。
DELETE           #从表中删除数据。
BATCH            #一次执行多个DML语句。
```

CQL字句
```
SELECT           #此子句从表中读取数据
WHERE            #where子句与select一起使用以读取特定数据。
ORDERBY          #orderby子句与select一起使用，以特定顺序读取特定数据。
```
