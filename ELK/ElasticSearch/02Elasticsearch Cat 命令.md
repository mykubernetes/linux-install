# Cat 命令公共参数

- Help 查看帮助
```
GET _cat/master?help

id   |   | node id    
host | h | host name  
ip   |   | ip address 
node | n | node name   
```

- Verbose 显示列名
```
GET _cat/master?v

id                     host  ip              node
AhlyPtZYTta1AVH_7mUSbQ node1 192.168.113.101 master-1
```

- Headers 只显示特定列
```
GET _cat/master?v&h=host,ip,node

host  ip              node
node1 192.168.113.101 master-1
```

- 数字格式化
```
bytes=kb store.size以kb输出

GET _cat/indices?v&h=index,docs.count,store.size&bytes=kb

index                           docs.count store.size
.monitoring-es-6-2018.08.25            441        721
.monitoring-kibana-6-2018.08.25         18        205
.kibana                                  1          7
.security-6                              3         19
```

- Format 输出格式
```
#支持的输出格式有json,test,yaml等
#默认以text格式输出
#以json格式输出 format=json&pretty

GET _cat/indices?v&h=index,docs.count,store.size&bytes=kb&format=json&pretty

[
  {
    "index": ".monitoring-es-6-2018.08.25",
    "docs.count": "476",
    "store.size": "1114"
  },
  {
    "index": ".monitoring-kibana-6-2018.08.25",
    "docs.count": "21",
    "store.size": "72"
  },
  {
    "index": ".kibana",
    "docs.count": "1",
    "store.size": "7"
  },
  {
    "index": ".security-6",
    "docs.count": "3",
    "store.size": "19"
  }
]

#以yaml格式输出 format=yaml&pretty
GET _cat/indices?v&h=index,docs.count,store.size&bytes=kb&format=yaml&pretty

---
- index: ".monitoring-es-6-2018.08.25"
  docs.count: "509"
  store.size: "979"
- index: ".monitoring-kibana-6-2018.08.25"
  docs.count: "24"
  store.size: "142"
- index: ".kibana"
  docs.count: "1"
  store.size: "7"
- index: ".security-6"
  docs.count: "3"
  store.size: "19"
```

- Sort 排序
```
#按index升序，docs.count降序
GET _cat/indices?v&h=index,docs.count,store.size&bytes=kb&format=json&pretty&s=index,docs.count:desc

[
  {
    "index": ".kibana",
    "docs.count": "1",
    "store.size": "7"
  },
  {
    "index": ".monitoring-es-6-2018.08.25",
    "docs.count": "608",
    "store.size": "1068"
  },
  {
    "index": ".monitoring-kibana-6-2018.08.25",
    "docs.count": "33",
    "store.size": "163"
  },
  {
    "index": ".security-6",
    "docs.count": "3",
    "store.size": "19"
  }
]
```

## 查看集群健康状态
```
GET _cat/health?v&h=cluster,status

cluster status
my-elk  green
```

## 查看集群节点和磁盘剩余
```
#集群节点
GET _cat/nodes?v

ip              heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.113.103           60          93   5    0.54    0.53     0.55 di        -      data-2
192.168.113.104           12          87   7    0.72    0.77     0.94 -         -      client-1
192.168.113.101           13          90   4    0.35    0.32     0.37 m         *      master-1
192.168.113.102           46          91 100    2.81    2.84     3.44 di        -      data-1

#磁盘剩余
GET _cat/nodes?v&h=ip,node.role,name,disk.avail

ip              node.role name     disk.avail
192.168.113.102 di        data-1        2.4gb
192.168.113.103 di        data-2        6.5gb
192.168.113.104 -         client-1        5gb
192.168.113.101 m         master-1      6.5gb
```

## 查看集群master节点
```
GET _cat/master?v

id                     host  ip              node
AhlyPtZYTta1AVH_7mUSbQ node1 192.168.113.101 master-1
```

## 查看分配
```
#查看每个数据节点上的分片数(shards)，以及每个数据节点磁盘剩余
GET _cat/allocation?v

shards disk.indices disk.used disk.avail disk.total disk.percent host  ip              node
     4        8.2mb      14gb      3.2gb     17.2gb           81 node2 192.168.113.102 data-1
     4        5.7mb     9.9gb      7.3gb     17.2gb           57 node3 192.168.113.103 data-2
```

## 查看被挂起任务
```
GET _cat/pending_tasks?v

insertOrder timeInQueue priority source
```

## 查看每个节点正在运行的插件
```
GET _cat/plugins?v

name     component          version
data-2   x-pack-core        6.2.4
data-2   x-pack-deprecation 6.2.4
data-2   x-pack-graph       6.2.4
data-2   x-pack-logstash    6.2.4
data-2   x-pack-ml          6.2.4
data-2   x-pack-monitoring  6.2.4
data-2   x-pack-security    6.2.4
data-2   x-pack-upgrade     6.2.4
data-2   x-pack-watcher     6.2.4
client-1 x-pack-core        6.2.4
client-1 x-pack-deprecation 6.2.4
client-1 x-pack-graph       6.2.4
client-1 x-pack-logstash    6.2.4
client-1 x-pack-ml          6.2.4
client-1 x-pack-monitoring  6.2.4
client-1 x-pack-security    6.2.4
client-1 x-pack-upgrade     6.2.4
client-1 x-pack-watcher     6.2.4
master-1 x-pack-core        6.2.4
master-1 x-pack-deprecation 6.2.4
master-1 x-pack-graph       6.2.4
master-1 x-pack-logstash    6.2.4
master-1 x-pack-ml          6.2.4
master-1 x-pack-monitoring  6.2.4
master-1 x-pack-security    6.2.4
master-1 x-pack-upgrade     6.2.4
master-1 x-pack-watcher     6.2.4
data-1   x-pack-core        6.2.4
data-1   x-pack-deprecation 6.2.4
data-1   x-pack-graph       6.2.4
data-1   x-pack-logstash    6.2.4
data-1   x-pack-ml          6.2.4
data-1   x-pack-monitoring  6.2.4
data-1   x-pack-security    6.2.4
data-1   x-pack-upgrade     6.2.4
data-1   x-pack-watcher     6.2.4
```

## 查看每个节点的自定义属性
```
GET /_cat/nodeattrs?v

node     host  ip              attr              value
data-2   node3 192.168.113.103 ml.machine_memory 1028517888
data-2   node3 192.168.113.103 ml.max_open_jobs  20
data-2   node3 192.168.113.103 ml.enabled        true
client-1 node4 192.168.113.104 ml.machine_memory 1856888832
client-1 node4 192.168.113.104 ml.max_open_jobs  20
client-1 node4 192.168.113.104 ml.enabled        true
master-1 node1 192.168.113.101 ml.machine_memory 1028517888
master-1 node1 192.168.113.101 ml.max_open_jobs  20
master-1 node1 192.168.113.101 ml.enabled        true
data-1   node2 192.168.113.102 ml.machine_memory 1028517888
data-1   node2 192.168.113.102 ml.max_open_jobs  20
data-1   node2 192.168.113.102 ml.enabled        true
```

## 查看索引分片的恢复视图
```
#索引分片的恢复视图,包括正在进行和先前已完成的恢复
#只要索引分片移动到群集中的其他节点，就会发生恢复事件
GET _cat/recovery/.kibana?v&format=json&pretty

[
  {
    "index": ".kibana",
    "shard": "0",
    "time": "446ms",
    "type": "empty_store",
    "stage": "done",
    "source_host": "n/a",
    "source_node": "n/a",
    "target_host": "node2",
    "target_node": "data-1",
    "repository": "n/a",
    "snapshot": "n/a",
    "files": "0",
    "files_recovered": "0",
    "files_percent": "0.0%",
    "files_total": "0",
    "bytes": "0",
    "bytes_recovered": "0",
    "bytes_percent": "0.0%",
    "bytes_total": "0",
    "translog_ops": "0",
    "translog_ops_recovered": "0",
    "translog_ops_percent": "100.0%"
  },
  {
    "index": ".kibana",
    "shard": "0",
    "time": "2s",
    "type": "peer",
    "stage": "done",
    "source_host": "node2",
    "source_node": "data-1",
    "target_host": "node3",
    "target_node": "data-2",
    "repository": "n/a",
    "snapshot": "n/a",
    "files": "1",
    "files_recovered": "1",
    "files_percent": "100.0%",
    "files_total": "1",
    "bytes": "230",
    "bytes_recovered": "230",
    "bytes_percent": "100.0%",
    "bytes_total": "230",
    "translog_ops": "0",
    "translog_ops_recovered": "0",
    "translog_ops_percent": "100.0%"
  }
]
```

## 查看每个数据节点上fielddata当前占用的堆内存

全文检索用倒排索引非常合适;但过滤、分组聚合、排序这些操作，正排索引更合适。

ES中引入了fielddata的数据结构用来做正排索引。如果需要对某一个字段排序、分组聚合、过滤，则可将字段设置成fielddata。

默认情况下:
- text类型的字段是不能分组及排序的，如需要则需要开启该字段的fielddata=true,但是这样耗费大量的内存，不建议这么使用。
- keyword类型默认可分组及排序。

fielddata默认是采用懒加载的机制加载到堆内存中。当某个字段基数特别大，可能会出现OOM。
```
GET _cat/fielddata?v&h=node,field,size

node   field                      size
data-1 kibana_stats.kibana.uuid     0b
data-1 kibana_stats.kibana.status   0b
data-2 kibana_stats.kibana.uuid     0b
data-2 kibana_stats.kibana.status   0b

#对某一字段进行查看
GET _cat/fielddata?v&h=node,field,size&fields=kibana_stats.kibana.uuid

node   field                    size
data-2 kibana_stats.kibana.uuid   0b
data-1 kibana_stats.kibana.uuid   0b
```

## 查看注册的快照仓库
```
GET _cat/repositories?v

id type
```

## 查看快照仓库下的快照
```
#可将ES中的一个或多个索引定期备份到如HDFS、S3等更可靠的文件系统，以应对灾难性的故障
#第一次快照是一个完整拷贝，所有后续快照则保留的是已存快照和新数据之间的差异
#当出现灾难性故障时，可基于快照恢复

GET _cat/snapshots/repo1?v
```

## 查看每个节点线程池的统计信息
```
#查看每个节点bulk线程池的统计信息
# actinve（活跃的），queue（队列中的）和 reject（拒绝的）
GET _cat/thread_pool/bulk?v&format=json&pretty

[
  {
    "node_name": "data-2",
    "name": "bulk",
    "active": "0",
    "queue": "0",
    "rejected": "0"
  },
  {
    "node_name": "client-1",
    "name": "bulk",
    "active": "0",
    "queue": "0",
    "rejected": "0"
  },
  {
    "node_name": "master-1",
    "name": "bulk",
    "active": "0",
    "queue": "0",
    "rejected": "0"
  },
  {
    "node_name": "data-1",
    "name": "bulk",
    "active": "0",
    "queue": "0",
    "rejected": "0"
  }
]
```

## 查看索引
```
GET _cat/indices/.monitoring*?v&h=index,health

index                           health
.monitoring-es-6-2018.08.25     green
.monitoring-kibana-6-2018.08.25 green
```

## 查看别名
```
GET _cat/aliases?v&h=alias,index

alias     index
.security .security-6
```

## 查看索引模板
```
GET _cat/templates?v&format=json&pretty

[
  {
    "name": "logstash-index-template",
    "index_patterns": "[.logstash]",
    "order": "0",
    "version": null
  },
  {
    "name": "security_audit_log",
    "index_patterns": "[.security_audit_log*]",
    "order": "2147483647",
    "version": null
  },
  {
    "name": ".monitoring-kibana",
    "index_patterns": "[.monitoring-kibana-6-*]",
    "order": "0",
    "version": "6020099"
  },
  {
    "name": ".watches",
    "index_patterns": "[.watches*]",
    "order": "2147483647",
    "version": null
  },
  {
    "name": ".monitoring-beats",
    "index_patterns": "[.monitoring-beats-6-*]",
    "order": "0",
    "version": "6020099"
  },
  {
    "name": ".ml-notifications",
    "index_patterns": "[.ml-notifications]",
    "order": "0",
    "version": "6020499"
  },
  {
    "name": ".ml-anomalies-",
    "index_patterns": "[.ml-anomalies-*]",
    "order": "0",
    "version": "6020499"
  },
  {
    "name": ".ml-state",
    "index_patterns": "[.ml-state]",
    "order": "0",
    "version": "6020499"
  },
  {
    "name": "security-index-template",
    "index_patterns": "[.security-*]",
    "order": "1000",
    "version": null
  },
  {
    "name": ".watch-history-7",
    "index_patterns": "[.watcher-history-7*]",
    "order": "2147483647",
    "version": null
  },
  {
    "name": ".ml-meta",
    "index_patterns": "[.ml-meta]",
    "order": "0",
    "version": "6020499"
  },
  {
    "name": ".monitoring-alerts",
    "index_patterns": "[.monitoring-alerts-6]",
    "order": "0",
    "version": "6020099"
  },
  {
    "name": ".monitoring-logstash",
    "index_patterns": "[.monitoring-logstash-6-*]",
    "order": "0",
    "version": "6020099"
  },
  {
    "name": ".triggered_watches",
    "index_patterns": "[.triggered_watches*]",
    "order": "2147483647",
    "version": null
  },
  {
    "name": ".monitoring-es",
    "index_patterns": "[.monitoring-es-6-*]",
    "order": "0",
    "version": "6020099"
  },
  {
    "name": "kibana_index_template:.kibana",
    "index_patterns": "[.kibana]",
    "order": "0",
    "version": null
  }
]
```

## 查看单个或某类或整个集群文档数
```
#整个集群文档数
GET _cat/count?v
epoch      timestamp count
1535185950 16:32:30  3008

#某类索引文档数
GET _cat/count/.monitoring*?v
epoch      timestamp count
1535186185 16:36:25  2162
```
注意:只包含实际文档数，不包括尚未清除的已删除文档。

## 查看每个索引的分片
```
GET _cat/shards?v&format=json&pretty&s=index
[
  {
    "index": ".kibana",
    "shard": "0",
    "prirep": "p",
    "state": "STARTED",
    "docs": "1",
    "store": "4kb",
    "ip": "192.168.113.102",
    "node": "data-1"
  },
  {
    "index": ".kibana",
    "shard": "0",
    "prirep": "r",
    "state": "STARTED",
    "docs": "1",
    "store": "4kb",
    "ip": "192.168.113.103",
    "node": "data-2"
  },
  {
    "index": ".monitoring-es-6-2018.08.25",
    "shard": "0",
    "prirep": "p",
    "state": "STARTED",
    "docs": "2557",
    "store": "1.6mb",
    "ip": "192.168.113.102",
    "node": "data-1"
  },
  {
    "index": ".monitoring-es-6-2018.08.25",
    "shard": "0",
    "prirep": "r",
    "state": "STARTED",
    "docs": "2557",
    "store": "1.5mb",
    "ip": "192.168.113.103",
    "node": "data-2"
  },
  {
    "index": ".monitoring-kibana-6-2018.08.25",
    "shard": "0",
    "prirep": "p",
    "state": "STARTED",
    "docs": "211",
    "store": "110.1kb",
    "ip": "192.168.113.102",
    "node": "data-1"
  },
  {
    "index": ".monitoring-kibana-6-2018.08.25",
    "shard": "0",
    "prirep": "r",
    "state": "STARTED",
    "docs": "211",
    "store": "110.1kb",
    "ip": "192.168.113.103",
    "node": "data-2"
  },
  {
    "index": ".security-6",
    "shard": "0",
    "prirep": "p",
    "state": "STARTED",
    "docs": "3",
    "store": "9.8kb",
    "ip": "192.168.113.102",
    "node": "data-1"
  },
  {
    "index": ".security-6",
    "shard": "0",
    "prirep": "r",
    "state": "STARTED",
    "docs": "3",
    "store": "9.8kb",
    "ip": "192.168.113.103",
    "node": "data-2"
  }
]
```

## 查看每个索引的segment
```
GET _cat/segments/.kibana?v&format=json&pretty

[
  {
    "index": ".kibana",
    "shard": "0",
    "prirep": "p",
    "ip": "192.168.113.102",
    "segment": "_2",
    "generation": "2",
    "docs.count": "1",
    "docs.deleted": "0",
    "size": "3.7kb",
    "size.memory": "1346",
    "committed": "true",
    "searchable": "true",
    "version": "7.2.1",
    "compound": "true"
  },
  {
    "index": ".kibana",
    "shard": "0",
    "prirep": "r",
    "ip": "192.168.113.103",
    "segment": "_2",
    "generation": "2",
    "docs.count": "1",
    "docs.deleted": "0",
    "size": "3.7kb",
    "size.memory": "1346",
    "committed": "true",
    "searchable": "true",
    "version": "7.2.1",
    "compound": "true"
  }
]
```

参考：
- https://wangpei.blog.csdn.net/article/details/82287444
