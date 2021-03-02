nodetool常用命令
---

https://cloud.tencent.com/developer/article/1772888?from=information.detail.Nodetool

http://www.mamicode.com/info-detail-2723557.html

1、查看集群信息
```
nodetool -u cassandra -pw cassandra describecluster
```

2、查看集群节点状态
UN=UP&Normal  load表示每个节点维护的数据的字节数，owns列表示一个节点拥有的令牌的区间的有效百分比
```
nodetool -u cassandra -pw cassandra status
```

3、ring 确定环中节点（包括虚拟节点）状态
```
nodetool -u cassandra -pw cassandra ring
```

4、info 获取指定节点信息
```
nodetool -u cassandra -pw cassandra -h 10.224.0.3 info
```

5、tpstats Cassandra维护的线程池信息，上半部分表示cassandra线程池中任务的相关数据，下半部分给出了节点丢弃的消息数
```
nodetool -u cassandra -pw cassandra
```

6、查看keyspace和table的统计信息
```
nodetool -u cassandra -pw cassandra tablestats {KEYSPACE_NAME}
```

7、获取节点的网络连接信息，查看节点间网络传输
```
nodetool -u cassandra -pw cassandra netstats
```

8、刷新输出
```
nodetool -u cassandra -pw cassandra flush
```

9、清理节点上的旧数据
```
nodetool -u cassandra -pw cassandra cleanup
```

10、修复当前集群的一致性，全量修复，修改大量数据时，失败的概率很大，3.x版本的BUG
```
nodetool -u cassandra -pw cassandra repair --full --trace
```

11、单节点修复
```
nodetool -u cassandra -pw cassandra repair -pr
```

12、重建索引
```
nodetool -u cassandra -pw cassandra rebuild_index
```

13、移动token
```
nodetool -u cassandra -pw cassandra move token_value
```

14、重启节点上cassandra
```
nodetool -u cassandra -pw cassandra disablegossip       #禁用gossip通讯，该节点停止与其他节点的gossip通讯，忽略从其他节点发来的请求
nodetool -u cassandra -pw cassandra disablebinary       #禁止本地传输（二进制协议）binary CQL protocol
nodetool -u cassandra -pw cassandra disablethirft       #禁用thrift server,即禁用该节点会充当coordinator,早期版本的cassandra使用thrift协议
nodetool -u cassandra -pw cassandra flush               #会把memtable中的数据刷新导sstable
nodetool -u cassandra -pw cassandra drain               #会把memtable中的数据刷新导sstable,单曲节点会终止其他系欸但的联系，执行完该命令后，需要stopdaemon重启
nodetool -u cassandra -pw cassandra stopdaemon          #停止cassandra进程，k8s会重启pod,这样pod ip 不会改变，对服务器影响比较小
nodetool -u cassandra -pw cassandra status -r           #查看集群所有节点状态
```

15、日志相关操作
```
nodetool -u cassandra -pw cassandra getlogginglevels               #查看日志级别
nodetool -u cassandra -pw cassandra setlogginglevel ROOT DEBUG     #设置日志级别为DEBUG
```

16、压缩相关操作
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

17、移除节点
```
nodetool -u cassandra -pw cassandra decommission             #退服节点
nodetool -u cassandra -pw cassandra removenode               #节点下线
nodetool -u cassandra -pw cassandra assassinate node_ip      #强制删除节点
```
18、快照备份
```
nodetool -u cassandra -pw cassandra listsnapshots         #查看快照列表
nodetool -u cassandra -pw cassandra clearsnapshot         #清空所有旧快照
nodetool -u cassandra -pw cassandra enbalebackup          #启动增量备份
nodetool -u cassandra -pw cassandra snapshot              #创建快照
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
