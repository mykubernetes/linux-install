## 查看都有哪些cat指令

```
GET _cat

=^.^=
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
/_cat/tasks
/_cat/indices
/_cat/indices/{index}
/_cat/segments
/_cat/segments/{index}
/_cat/count
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/thread_pool/{thread_pools}
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
/_cat/nodeattrs
/_cat/repositories
/_cat/snapshots/{repository}
/_cat/templates
```

## verbose显示指令的详细信息
```
GET _cat/health?v
```

## help显示指令返回参数的说明
```
GET _cat/health?help
```

## header选择要显示的列
```
GET _cat/count?h=timestamp,count
```

## format设置返回内容的格式，支持json,yaml,text,smile,cbor
```
GET _cat/master?format=json&pretty
```

## sort排序
```
GET _cat/indices?s=store.size:desc
```

## 可以多个参数一起使用，用&连接
```
GET _cat/indices?v&s=store.size:desc
```

## cat指令

## aliases

- 显示别名、过滤器、路由信息
```
GET _cat/aliases?v

alias index filter routing.index routing.search
```

| 名称 | 描述 |
|------|------|
| alias： | 别名 |
| index： | 索引别名指向 |
| filter： | 过滤规则 |
| routing.index： | 索引路由 |
| routing.search： | 搜索路由 |

## allocation

- 显示每个节点分片数量、占用空间
```
GET _cat/allocation?v

shards disk.indices disk.used disk.avail disk.total disk.percent host        ip          node
  1073        1.2tb     1.2tb    787.1gb      1.9tb           61 10.82.9.205 10.82.9.205 node01
  1072        1.2tb     1.2tb      1.2tb      2.4tb           50 10.82.9.207 10.82.9.207 node03
  1073        1.2tb     1.2tb    787.4gb      1.9tb           61 10.82.9.206 10.82.9.206 node02
```

| 名称 | 描述 |
|------|------|
| shards： | 节点承载的分片数量 |
| disk.indices： | 索引占用的空间大小 |
| disk.used： | 节点所在机器已使用的磁盘空间大小 |
| disk.avail： | 节点可用空间大小 |
| disk.total： | 节点总空间大小 |
| disk.percent： | 节点磁盘占用百分比 |
| host： | 节点的host地址 |
| ip： | 节点的ip地址 |
| node： | 节点名称 |

## count

- 显示索引文档数量
```
GET _cat/count?v

epoch      timestamp count
1558059594 10:19:54  7829577019
```

| 名称 | 描述 |
|------|------|
| epoch： | 自标准时间（1970-01-01 00:00:00）以来的秒数 |
| timestamp： | 时间 |
| count： | 文档总数 |

## health

- 查看集群健康状况
```
GET _cat/health?v

epoch      timestamp cluster   status node.total node.data shards  pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1558059496 10:18:16  ops_coffee green           7         5   5362 2681    0    0        0             0                  -                100.0%
```

| 名称 | 描述 |
|------|------|
| epoch： | 自标准时间（1970-01-01 00:00:00）以来的秒数 |
| timestamp： | 时间 |
| cluster： | 集群名称 |
| status： | 集群状态
| node.total： | 节点总数 |
| node.data： | 数据节点总数 |
| shards： | 分片总数 |
| pri： | 主分片总数 |
| repo： | 复制节点的数量 |
| init： | 初始化节点的数量 |
| unassign： | 未分配分片的数量 |
| pending_tasks： | 待定任务数 |
| max_task_wait_time： | 等待最长任务的等待时间 |
| active_shards_percent： | 活动分片百分比 |

## indices

- 查看索引信息
```
GET _cat/indices?v

health status index                                uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ops-coffee-slowlog-2019.04.08        5ARM1TgqTy-fGO8RlJC_Jg   5   1       7743            0     57.9mb         28.9mb
green  open   ops-coffee-nginx-2019.04.09          1VdeScHaQda6CF_htRZz_A   5   1   81519329            0       52gb         25.8gb
```

| 名称 | 描述 |
|------|------|
| health： | 索引的健康状态 |
| status： | 索引的开启状态 |
| index： | 索引名字 |
| uuid： | 索引的uuid |
| pri： | 索引的主分片数量 |
| rep： | 索引的复制分片数量 |
| docs.count： | 索引下的文档总数 |
| docs.deleted： | 索引下删除状态的文档数 |
| store.size： | 主分片+复制分片的大小 |
| pri.store.size： | 主分片的大小 |

## master

- 显示master节点信息
```
GET _cat/master?v

id                     host        ip          node
dkof1ouuT96BTQOR1xyDhQ 10.82.9.205 10.82.9.205 node01
```

| 名称 | 描述 |
|------|------|
| id： | 节点ID |
| host： | 主机名称 |
| ip： | 主机IP |
| node： | 节点名称 |

## nodeattrs

- 显示node节点属性
```
GET _cat/nodeattrs?v

node host ip attr value
```

| 名称 | 描述 |
|------|------|
| node： | 节点名称 |
| host： | 主机地址 |
| ip： | 主机ip |
| attr： | 属性描述 |
| value： | 属性值 |

## nodes

- 显示node节点信息
```
GET _cat/nodes?v

ip          heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.82.9.205           50          99   6    2.32    2.82     3.37 mdi       *      node01
10.82.9.206           71          99   6    3.24    4.02     4.35 mdi       -      node02
10.82.9.208           25          94   3    0.40    0.42     0.36 i         -      node04
10.82.9.132           70          99   7    1.51    2.28     2.57 di        -      node11
```

| 名称 | 描述 |
|------|------|
| ip： | node节点的IP |
| heap.percent： | 堆内存占用百分比 |
| ram.percent： | 内存占用百分比 |
| cpu： | CPU占用百分比 |
| load_1m： | 1分钟的系统负载 |
| load_5m： | 5分钟的系统负载 |
| load_15m： | 15分钟的系统负载 |
| node.rol： | node节点的角色 |
| master： | 是否是master节点 |
| name： | 节点名称 |

## pending_tasks

- 显示正在等待的任务
```
GET _cat/pending_tasks?v

insertOrder timeInQueue priority source
```

| 名称 | 描述 |
|------|------|
| insertOrder： | 任务插入顺序 |
| timeInQueue： | 任务排队了多长时间 |
| priority： | 任务优先级 |
| source： | 任务源 |

## plugins

- 显示每个运行插件节点的视图
```
GET _cat/plugins?v

name component version
```

| 名称 | 描述 |
|------|------|
| name： | 节点名称 |
| component： | 插件名称 |
| version： | 插件版本 |

## recovery

- 显示正在进行和先前完成的索引碎片恢复的视图
```
GET _cat/recovery?v

index                                shard time  type           stage source_host source_node target_host target_node repository snapshot files files_recovered files_percent files_total bytes      bytes_recovered bytes_percent bytes_total translog_ops translog_ops_recovered translog_ops_percent
filebeat-docker-pay-2019.04.18       0     209ms peer           done  10.82.9.132 node11      10.82.9.207 node03      n/a        n/a      0     0               0.0%          0           0          0               0.0%          0           0            0                      100.0%
```

| 名称 | 描述 |
|------|-----|
| index： | 索引名称 |
| shard： | 分片名称 |
| time： | 恢复时间 |
| type： | 恢复类型 |
| stage： | 恢复阶段 |
| source_host： | 源主机 |
| source_node： | 源节点名称 |
| target_host： | 目标主机 |
| target_node： | 目标节点名称 |
| repository: | 仓库 |
| snapshot: | 快照 |
| files： | 要恢复的文件数 |
| files_recovered： | 已恢复的文件数 |
| files_percent： | 恢复文件百分比 |
| files_total： | 文件总数 |
| bytes： | 要恢复的字节数 |
| bytes_recovered： | 已恢复的字节数 |
| bytes_percent： | 恢复字节百分比 |
| bytes_total： | 字节总数 |
| translog_ops： | 要恢复的translog操作数 |
| translog_ops_recovered： | 已恢复的translog操作数 |
| translog_ops_percent： | 恢复的translog操作的百分比 |

## segments

- 显示碎片中的分段信息
```
GET _cat/segments?v

index                                shard prirep ip          segment generation docs.count docs.deleted     size size.memory committed searchable version compound
filebeat-docker-pay-2019.04.18       0     r      10.82.9.207 _8cu         10830      19470            0   17.7mb       43546 true      true       7.2.1   false
```

| 名称 | 描述 |
|------|------|
| index： | 索引名称 |
| shard： | 分片名称 |
| prirep： | 主分片还是副本分片 |
| ip： | 所在节点IP |
| segment： | segments段名 |
| generation： | 分段生成 |
| docs.count： | 段中的文档树 |
| docs.deleted： | 段中删除的文档数 |
| size： | 段大小，以字节为单位 |
| size.memory： | 段内存大小，以字节为单位 |
| committed： | 段是否已提交 |
| searchable： | 段是否可搜索 |
| version： | 版本 |
| compound： | compound模式 |

## shards

```
GET _cat/shards?v

index                                shard prirep state       docs    store ip          node
mysql-slowlog-2019.03.14             4     r      STARTED     1381    4.6mb 10.82.9.205 node01
mysql-slowlog-2019.03.14             4     p      STARTED     1381    4.5mb 10.82.9.206 node02
```

| 名称 | 描述 |
|------|------|
| index： | 索引名称 |
| shard： | 分片序号 |
| prirep： | 分片类型，p表示是主分片，r表示是复制分片 |
| state： | 分片状态 |
| docs： | 该分片存放的文档数量 |
| store： | 该分片占用的存储空间大小 |
| ip： | 该分片所在的服务器ip |
| node： | 该分片所在的节点名称 |

## thread_pool

- 查看线程池信息
```
GET _cat/thread_pool?v

node_name name                active queue rejected
node10    bulk                     1     0        4
node10    fetch_shard_started      0     0        0
```

| 名称 | 描述 |
|------|------|
| node_name： | 节点名称 |
| name： | 线程池名称 |
| active： | 活跃线程数量 |
| queue： | 当前队列中的任务数 |
| rejected： | 被拒绝的任务数 |


