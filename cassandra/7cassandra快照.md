Cassandra管理之备份与恢复

1、全量备份
```
# nodetool snapshot
Requested creating snapshot(s) for [all keyspaces] with snapshot name [1570691336948] and options {skipFlush=false}
Snapshot directory: 1570691336948
```

```
nodetool -h 服务器ip -p 端口号 snapshots -t 快照名称 -kt 数据库名.表名 #某个表快照
nodetool -h 服务器ip -p 端口号 snapshots 数据库名 #全库快照

# nodetool -h localhost -p 7199 snapshot -t xn_dolphin_1-20181010  xn_dolphin_1
Requested creating snapshot(s) for [xn_dolphin_1] with snapshot name [xn_dolphin_1-20181010] and options {skipFlush=false}
Snapshot directory: xn_dolphin_1-20181010

# nodetool -h localhost -p 7199 snapshot   xn_dolphin_1
Requested creating snapshot(s) for [xn_dolphin_1] with snapshot name [1539180816386] and options {skipFlush=false}
Snapshot directory: 1539180816386

# nodetool listsnapshots
Snapshot Details:
Snapshot name         Keyspace name Column family name               True size Size on disk
1539180816386         xn_dolphin_1  dolphin_conversation_result      5.1 MiB   5.1 MiB
1539180816386         xn_dolphin_1  dolphin_conversation_member      0 bytes   1.02 KiB
1539180816386         xn_dolphin_1  dolphin_wchat_openid             0 bytes   895 bytes
1539180816386         xn_dolphin_1  zoogate_login_info               0 bytes   1.02 KiB
1539180816386         xn_dolphin_1  dolphin_conversation_list        0 bytes   946 bytes
1539180816386         xn_dolphin_1  dolphin_leaving_msg              0 bytes   1.27 KiB
1539180816386         xn_dolphin_1  dolphin_conversation             0 bytes   1.1 KiB
1539180816386         xn_dolphin_1  dolphin_member_inout             0 bytes   1.05 KiB
1539180816386         xn_dolphin_1  dolphin_conversation_message     0 bytes   1.18 KiB
1539180816386         xn_dolphin_1  zoogate_blacklist                0 bytes   1.01 KiB
1539180816386         xn_dolphin_1  dolphin_conversation_visitorinfo 0 bytes   1.2 KiB
1539180816386         xn_dolphin_1  dolphin_conversation_statistics  0 bytes   1 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_conversation_result      5.1 MiB   5.1 MiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_conversation_member      0 bytes   1.02 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_wchat_openid             0 bytes   895 bytes
xn_dolphin_1-20181010 xn_dolphin_1  zoogate_login_info               0 bytes   1.02 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_conversation_list        0 bytes   946 bytes
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_leaving_msg              0 bytes   1.27 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_conversation             0 bytes   1.1 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_member_inout             0 bytes   1.05 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_conversation_message     0 bytes   1.18 KiB
xn_dolphin_1-20181010 xn_dolphin_1  zoogate_blacklist                0 bytes   1.01 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_conversation_visitorinfo 0 bytes   1.2 KiB
xn_dolphin_1-20181010 xn_dolphin_1  dolphin_conversation_statistics  0 bytes   1 KiB
```


2、查看快照列表
```
nodetool listsnapshots 
```

3、增量备份
```
# 1、默认情况下，它的增量备份是禁用的
# nodetool statusbackup
not running

# 2、启用增量备份
# nodetool enablebackup 
# nodetool statusbackup 
running

# 3、启动增量备份
# nodetool snapshot
Requested creating snapshot(s) for [all keyspaces] with snapshot name [1570695931097] and options {skipFlush=false} Snapshot directory: 1570695931097
```

4、恢复数据
```
这里将snapshot目录的数据拷贝到数据目录，然后执行refresh

# 1、还原snapshot目录的数据
# pwd
/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc
# cp -ra snapshots/1570695931097/* .

如果有索引数据也要进行拷贝操作
# cp -ra snapshots/1570695931097/.rhnchecksum_idx/* .rhnchecksum_idx/

# 2、当把快照文件复制到对应表的目录下后，运行refresh命令加载新的SSTables 不需要重启机器节点。

# nodetool refresh spacewalk rhnchecksum

完成后，cassandra的日志会出现下面的提示:
# tail -f /var/log/cassandra/system.log 
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:41:22,513 ColumnFamilyStore.java:734 - Loading new SSTables for spacewalk/rhnchecksum...
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:41:22,517 ColumnFamilyStore.java:782 - Renaming new SSTable /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-47-big to /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-50-big
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:41:22,548 ColumnFamilyStore.java:782 - Renaming new SSTable /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-49-big to /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-51-big
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:41:22,567 ColumnFamilyStore.java:782 - Renaming new SSTable /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-48-big to /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-52-big
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:41:22,589 ColumnFamilyStore.java:782 - Renaming new SSTable /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-46-big to /var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-53-big
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:41:22,610 ColumnFamilyStore.java:817 - Loading new SSTables and building secondary indexes for spacewalk/rhnchecksum: [BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-52-big-Data.db'), BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-51-big-Data.db'), BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-53-big-Data.db'), BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-50-big-Data.db')]
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:41:22,614 SecondaryIndexManager.java:366 - Submitting index build of rhnchecksum_idx for data in BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-52-big-Data.db'),BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-51-big-Data.db'),BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-53-big-Data.db'),BigTableReader(path='/var/lib/cassandra/data/spacewalk/rhnchecksum-dbbb8330dde111e99dfb45c418aaa2bc/md-50-big-Data.db')
INFO  [Service Thread] 2019-10-10 16:41:34,134 GCInspector.java:284 - ConcurrentMarkSweep GC in 467ms.  CMS Old Gen: 1227906720 -> 508200320; Code Cache: 35251328 -> 35276800; Metaspace: 45251080 -> 45251832; Par Eden Space: 6575264 -> 139631912; Par Survivor Space: 41943040 -> 14759936
INFO  [Service Thread] 2019-10-10 16:41:43,679 GCInspector.java:284 - ParNew GC in 236ms.  CMS Old Gen: 844136912 -> 967814552; Par Eden Space: 335544320 -> 0; Par Survivor Space: 35314704 -> 41943040
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:47:00,987 SecondaryIndexManager.java:386 - Index build of rhnchecksum_idx complete   #出现rhnchecksum
INFO  [RMI TCP Connection(68)-127.0.0.1] 2019-10-10 16:47:00,987 ColumnFamilyStore.java:825 - Done loading
```
