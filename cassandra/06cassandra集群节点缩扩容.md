# Cassandra扩容

1、 准备一个新节点

2、 关闭所有节点压缩(可选)
```
# 关闭所有节点的压缩
nodetool disableautocompaction

# 停止正在执行的压缩
nodetool stop COMPACTION
```
注：根据我们的经验，以上关闭压缩的步骤多余，反而会因为未及时压缩产生大量SSTABLE而影响性能。
             
3、评估扩容时间：
生产数据扩容，一般都是T级别的数据迁移，耗时数小时，一般都需要选择晚上或周末，具体视迁移的数据量多少、CPU性能等决定。 若数据量少或机器性能强劲，基本任何时候都可扩容，否则选择晚上或周末。

4、限制集群所有节点数据迁移流量
```
nodetool setstreamthroughput 32 (注：32Mb/s = 4MB/s)
nodetool getstreamthroughput 
```
一般，若集群性能好，出流可以设置为8MB/s, 入流可设置70MB/s,  生产迁移过程中可从小到大调整，观察对性能是否有影响，没影响就适当调大。

5、session超时设置,根据同步数据量计算需要大概多少时间能迁移完成。如：60G,传输速率4MB/s，大约需要4.26小时完成。
```
# vim cassandra.yaml
streaming_socket_timeout_in_ms: 172800000          # 默认3600000（1H，生产环境明显不够），改成172800000（48H），保证有足够时间完成数据迁移
```

6、启动引导程序节点（新加入节点执行）
```
systemctl start cassandra 
```

7、使用nodetool status来验证节点是否已完全引导，并且所有其他节点都处于运行状态（UN）而不处于任何其他状态。

8、监控迁移情况
```
nodetool netstats               # 数据迁移情况
nodetool compactionstats -H     # SSTABLE压缩情况
nodetool status                 # 集群情况，UJ：未完成，UN：已完成
```

9、现在重新开启所有节点自动压缩
```
# nodetool enableautocompaction
```

10、关闭所有节点数据迁移流量
```
# nodetool setstreamthroughput 0
```

11、数据迁移完成后清理数据,手动清理每一台老节点磁盘空间,一个完成后再清理下一个。花费时间较长，推荐后台运行
```
nodetool cleanup
```
注：清理数据会大量消耗集群性能，对twcs，不必删除，经过一段时间后冗余数据会自动清理；

# Cassandra下线节点

1、选择一个要下线的节点实例

2、选择下线时间，见扩容。

3、限制集群所有节点数据迁移流量
```
# nodetool getstreamthroughput
Current stream throughput: 200 Mb/s

# nodetool setstreamthroughput 32        # 注：32Mb/s = 4MB/s
# nodetool getstreamthroughput
Current stream throughput: 32 Mb/s
```
- 一般，若集群性能好，出流可以设置为70MB/s, 入流可设置8MB/s,  生产迁移过程中可从小到大调整，观察对性能是否有影响，没影响就适当调大。

4、需要删除的节点上执行下线命令,关闭当前节点。将数据传输到下一个节点中。
```
nodetool decommission
```

5、监控迁移情况
```
nodetool netstats                   # 数据迁移情况
nodetool compactionstats -H         # SSTABLE压缩情况
```

6、查看集群状态

- 删除节点状态为UL，删除完成后消失
```
# nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.101.69  137.38 KiB  256          100.0%            53a8aaf1-f594-4561-9e97-d11e0fd6087c  rack1
UL  192.168.101.71  244.22 KiB  256          100.0%            8bfb1ae5-99ba-4513-a2ca-8464dbd1fb5b  rack1

# nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.101.69  147.75 KiB  256          100.0%            53a8aaf1-f594-4561-9e97-d11e0fd6087c  rack1
```

7、删除节点后，通过`describeclustr`还有记录需要删除
```
# nodetool describecluster
Cluster Information:
	Name: Test Cluster
	Snitch: org.apache.cassandra.locator.SimpleSnitch
	DynamicEndPointSnitch: enabled
	Partitioner: org.apache.cassandra.dht.Murmur3Partitioner
	Schema versions:
		e84b6a60-24cf-30ca-9b58-452d92911703: [192.168.101.69]

		UNREACHABLE: [192.168.101.71]

# nodetool assassinate 192.168.101.71

# nodetool describecluster
Cluster Information:
	Name: Test Cluster
	Snitch: org.apache.cassandra.locator.SimpleSnitch
	DynamicEndPointSnitch: enabled
	Partitioner: org.apache.cassandra.dht.Murmur3Partitioner
	Schema versions:
		e84b6a60-24cf-30ca-9b58-452d92911703: [192.168.101.69]
```

# Cassandra删除宕机机器节点步骤

1、找出状态为DN的节点
```
# nodetool status
Datacenter: DC1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address        Load       Tokens  Owns (effective)  Host ID                               Rack
UN  192.168.2.101  112.82 KB  256     31.7%             420129fc-0d84-42b0-be41-ef7dd3a8ad06  RAC1
DN  192.168.2.103  91.11 KB   256     33.9%             d0844a21-3698-4883-ab66-9e2fd5150edd  RAC1
UN  192.168.2.102  124.42 KB  256     32.6%             8d5ed9f4-7764-4dbd-bad8-43fddce94b7c  RAC1
```

2、删除节点一般用在节点宕机的情况下使用
```
# nodetool removenode d0844a21-3698-4883-ab66-9e2fd5150edd
```

3、查看删除节点的操作的状态
```
# nodetool removenode status
RemovalStatus: No token removals in process.
```

4、确认节点已被删除
```
# nodetool status
Datacenter: DC1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address        Load       Tokens  Owns (effective)  Host ID                               Rack
UN  192.168.2.101  112.82 KB  256     37.7%             420129fc-0d84-42b0-be41-ef7dd3a8ad06  RAC1
UN  192.168.2.102  124.42 KB  256     38.3%             8d5ed9f4-7764-4dbd-bad8-43fddce94b7c  RAC1
```

5、如果删除不了，强制删除
```
nodetool removenode d0844a21-3698-4883-ab66-9e2fd5150edd  force
```

# Cassandra节点替换

1、查看集群状态
```
# nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.101.69  137.38 KiB  256          100.0%            53a8aaf1-f594-4561-9e97-d11e0fd6087c  rack1
DN  192.168.101.71  244.22 KiB  256          100.0%            8bfb1ae5-99ba-4513-a2ca-8464dbd1fb5b  rack1
```

2、修改配置文件

- 如果要替换已死亡的节点，请在其位置重新启动指定死节点地址的新节点。 新节点的数据目录中不得包含任何数据.
```
vi /etc/cassandra/conf/jvm.options  
47行
#-Dcassandra.replace_address=listen_address or broadcast_address of dead node

修改配置文件：
-Dcassandra.replace_address=192.168.101.71
```

3、清理无用数据、启动服务
```
# grep -A2 '^data_file_directories' /etc/cassandra/conf/cassandra.yaml
data_file_directories:
    - /var/lib/cassandra/data


# grep -E '^commitlog_directory|^saved_caches_directory' /etc/cassandra/conf/cassandra.yaml
commitlog_directory: /var/lib/cassandra/commitlog
saved_caches_directory: /var/lib/cassandra/saved_caches


执行前删除下列文件夹及内容：
- data/
- commitlog/
- saved_caches/


rm -rf /var/lib/cassandra/data/*
rm -rf /var/lib/cassandra/commitlog/*
rm -rf /var/lib/cassandra/saved_caches/*
```

4、启动
```
systemctl start cassandra 
```

5、等待集群数据恢复完成，验证集群状态
```
# nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.101.69  251.83 KiB  256          100.0%            53a8aaf1-f594-4561-9e97-d11e0fd6087c  rack1
UN  192.168.101.71  114.69 KiB  256          100.0%            de0445b8-d6aa-47d0-bd74-95b1326741a4  rack1
```

其他步骤和扩容一样
