扩容
---
```
1、 准备一个新节点

2、 关闭所有节点压缩(可选)
# 关闭所有节点的压缩
nodetool disableautocompaction

# 停止正在执行的压缩
nodetool stop COMPACTION
注：根据我们的经验，以上关闭压缩的步骤多余，反而会因为未及时压缩产生大量SSTABLE而影响性能。
             
3、评估扩容时间：
生产数据扩容，一般都是T级别的数据迁移，耗时数小时，一般都需要选择晚上或周末，具体视迁移的数据量多少、CPU性能等决定。 若数据量少或机器性能强劲，基本任何时候都可扩容，否则选择晚上或周末。

4、限制集群所有节点数据迁移流量
nodetool setstreamthroughput 32 (注：32Mb/s = 4MB/s)
nodetool getstreamthroughput 
一般，若集群性能好，出流可以设置为8MB/s, 入流可设置70MB/s,  生产迁移过程中可从小到大调整，观察对性能是否有影响，没影响就适当调大。

5、session超时设置,根据同步数据量计算需要大概多少时间能迁移完成。如：60G,传输速率4MB/s，大约需要4.26小时完成。
# vim cassandra.ymal
streaming_socket_timeout_in_ms: 172800000     # 默认3600000（1H，生产环境明显不够），改成172800000（48H），保证有足够时间完成数据迁移

6、启动引导程序节点（新加入节点执行）
systemctl start cassandra 

7、使用nodetool status来验证节点是否已完全引导，并且所有其他节点都处于运行状态（UN）而不处于任何其他状态。

8、监控迁移情况
nodetool netstats               # 数据迁移情况
nodetool compactionstats -H     # SSTABLE压缩情况
nodetool status                 # 集群情况，UJ：未完成，UN：已完成

9、现在重新开启所有节点自动压缩
# nodetool enableautocompaction

10、关闭所有节点数据迁移流量
# nodetool setstreamthroughput 0

11、数据迁移完成后清理数据,手动清理每一台老节点磁盘空间,一个完成后再清理下一个。
nodetool cleanup
注：清理数据会大量消耗集群性能，对twcs，不必删除，经过一段时间后冗余数据会自动清理；
```

正常缩容
---
```
1、选择一个要下线的节点实例
2、选择下线时间，见扩容。
3、限制集群所有节点数据迁移流量
nodetool setstreamthroughput 32 (注：32Mb/s = 4MB/s)
nodetool getstreamthroughput 
一般，若集群性能好，出流可以设置为70MB/s, 入流可设置8MB/s,  生产迁移过程中可从小到大调整，观察对性能是否有影响，没影响就适当调大。

4、需要删除的机器上执行下线命令
nodetool decommission

5、监控迁移情况
nodetool netstats                   # 数据迁移情况
nodetool compactionstats -H         # SSTABLE压缩情况
nodetool status                     # 删除节点状态为UL
```

强制删除节点
---
强制删除节点一般用在节点宕机的情况下使用
```
nodetool removenode hostid    (force)
如：nodetool removenode 8b6dbd89-a4ed-479c-9fc2-9f92712bf48a  force;
```
