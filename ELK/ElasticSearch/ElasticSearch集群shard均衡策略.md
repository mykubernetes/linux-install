ES集群的rebalance和allocation功能，可以自动均衡集群内部数据、分配分片，保证各个节点间尽量均衡。但是，在高访问量或者节点宕机的情况下，大范围的rebalance会影响到集群性能。所以，调整好集群相关参数，是重中之重。

# 1 - shard分配策略

集群分片分配是指将索引的shard分配到其他节点的过程，会在如下情况下触发：
- 集群内有节点宕机，需要故障恢复；
- 增加副本；
- 索引的动态均衡，包括集群内部节点数量调整、删除索引副本、删除索引等情况；

上述策略开关，可以动态调整，由参数`cluster.routing.allocation.enable`控制，启用或者禁用特定分片的分配。该参数的可选参数有：
- all - 默认值，允许为所有类型分片分配分片；
- primaries - 仅允许分配主分片的分片；
- new_primaries - 仅允许为新索引的主分片分配分片；
- none - 任何索引都不允许任何类型的分片；

重新启动节点时，此设置不会影响本地主分片的恢复。如果重新启动的节点具有未分配的主分片的副本，会立即恢复该主分片。
```
PUT _cluster/settings
{ 
  "persistent" :
  { 
     "cluster.routing.rebalance.enable": "none",
       ##允许在一个节点上发生多少并发传入分片恢复。 默认为2。
       ##多数为副本
      "cluster.routing.allocation.node_concurrent_incoming_recoveries":2，
      ##允许在一个节点上发生多少并发传出分片恢复，默认为2.
       ## 多数为主分片
      "cluster.routing.allocation.node_concurrent_outgoing_recoveries":2,
       ##为上面两个的统一简写
      "cluster.routing.allocation.node_concurrent_recoveries":2,
      ##在通过网络恢复副本时，节点重新启动后未分配的主节点的恢复使用来自本地  磁盘的数据。 
      ##这些应该很快，因此更多初始主要恢复可以在同一节点上并行发生。 默认为4。
      "cluster.routing.allocation.node_initial_primaries_recoveries":4,
      ##允许执行检查以防止基于主机名和主机地址在单个主机上分配同一分片的多个实例。 
      ##默认为false，表示默认情况下不执行检查。 此设置仅适用于在同一台计算机上启动多个节点的情况。这个我的理解是如果设置为false，
      ##则同一个节点上多个实例可以存储同一个shard的多个副本没有容灾作用了
      "cluster.routing.allocation.same_shard.host":true
    }
}
```

# 2 - rebalance策略

`cluster.routing.rebalance.enable`为特定类型的分片启用或禁用重新平衡：
- all - （默认值）允许各种分片的分片平衡；
- primaries - 仅允许主分片的分片平衡；
- replicas - 仅允许对副本分片进行分片平衡；
- none - 任何索引都不允许任何类型的分片平衡；

`cluster.routing.allocation.allow_rebalance`用来控制rebalance触发条件：
- always - 始终允许重新平衡；
- indices_primaries_active - 仅在所有主分片可用时；
- indices_all_active - （默认）仅当所有分片都激活时；

`cluster.routing.allocation.cluster_concurrent_rebalance`用来控制均衡力度，允许集群内并发分片的rebalance数量，默认为2。

`cluster.routing.allocation.node_concurrent_recoveries`，每个node上允许rebalance的片数量。

# 3 - ElasticSearch集群什么时候会进行rebalance？

`rebalance`策略的触发条件，主要由下面几个参数控制：
```
## 每个节点上的从shard数量，-1代表不限制
cluster.routing.allocation.total_shards_per_node: -1

## 定义分配在该节点的分片数的因子 阈值=因子*（当前节点的分片数-集群的总分片数/节点数，即每个节点的平均分片数）
cluster.routing.allocation.balance.shard: 0.45f

## 定义分配在该节点某个索引的分片数的因子，阈值=因子*（保存当前节点的某个索引的分片数-索引的总分片数/节点数，即每个节点某个索引的平均分片数）
cluster.routing.allocation.balance.index: 0.55f

## 超出这个阈值就会重新分配分片
cluster.routing.allocation.balance.threshold: 1.0f

## 磁盘参数
## 启用基于磁盘的分发策略
cluster.routing.allocation.disk.threshold_enabled: true
## 硬盘使用率高于这个值的节点，则不会分配分片
cluster.routing.allocation.disk.watermark.low: "85%"
## 如果硬盘使用率高于这个值，则会重新分片该节点的分片到别的节点
cluster.routing.allocation.disk.watermark.high: "90%"
## 当前硬盘使用率的查询频率
cluster.info.update.interval: "30s"
## 计算硬盘使用率时，是否加上正在重新分配给其他节点的分片的大小
cluster.routing.allocation.disk.include_relocations: true
```

elasticsearch内部计算公式是：
```
weightindex(node, index) = indexBalance * (node.numShards(index) – avgShardsPerNode(index))
weightnode(node, index) = shardBalance * (node.numShards() – avgShardsPerNode)
weightprimary(node, index) = primaryBalance * (node.numPrimaries() – avgPrimariesPerNode)
weight(node, index) = weightindex(node, index) + weightnode(node, index) + weightprimary(node, index)
```
如果计算最后的weight(node, index)大于threshold， 就会发生shard迁移。

# 4 - 自定义规则

可以通过设置分片的分布规则来人为地影响分片的分布，示例如下：

假设有几个机架，可以在每个节点设置机架的属性：
```
node.attr.rack_id: r1
```

现在添加一条策略，设置rack_id作为分片规则的一个属性
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.awareness.attributes":"r1"
  }
}
```
上面设置意味着rack_id会用来作为分片分布的依据。例如：我们启动两个node.attr.rack_id设置r1的节点，然后建立一个5个分片，一个副本的索引。这个索引就会完全分布在这两个节点上。如果再启动另外两个节点，node.attr.rack_id设置成r2，分片会重新分布，但是一个分片和它的副本不会分配到同样rack_id值的节点上。

可以为分片分布规则设置多个属性，例如：
```
cluster.routing.allocation.awareness.attributes: rack_id,zone
```
注意：当设置了分片分布属性时，如果集群中的节点没有设置其中任何一个属性，那么分片就不会分布到这个节点中。

**强制分布规则**

更多的时候，我们不想更多的副本被分布到相同分布规则属性值的一群节点上，那么，我们可以强制分片规则为一个指定的值。

例如，我们有一个分片规则属性叫zone，并且我们知道有两个zone，zone1和zone2。下面是设置：
```
cluster.routing.allocation.awareness.force.zone.values: zone1,zone2  
cluster.routing.allocation.awareness.attributes: zone
```
现在我们启动两个node.zone设置成zone1的节点，然后创建一个5个分片，一个副本的索引。索引建立完成后只有5个分片（没有副本），只有当我们启动node.zone设置成zone2的节点时，副本才会分配到那节点上。

**分片分布过滤**
允许通过`include/exclude`过滤器来控制分片的分布。这些过滤器可以设置在索引级别上或集群级别上。下面是个索引级别上的例子:

假如我们有四个节点，每个节点都有一个叫tag（可以是任何名字）的属性。每个节点都指定一个tag的值。如：节点一设置成node.tag: value1，节点二设置成node.tag: value2，如此类推。我们可以创建一个索引然后只把它分布到tag值为value1和value2的节点中，可以通过设置index.routing.allocation.include.tag为value1,value2达到这样的效果，如：
```
PUT /test/_settings 
{ 
     "index.routing.allocation.include.tag" : "value1,value2" 
}
```
与此相反，通过设置index.routing.allocation.exclude.tag为value3，我们也可以创建一个索引让其分布在除了tag设置为value3的所有节点中，如：
```
PUT /test/_settings 
{ 
     "index.routing.allocation.include.tag" : "value3" 
}
```
include或exclude过滤器的值都会使用通配符来匹配，如value*。一个特别的属性名是_ip，它可以用来匹配节点的ip地址。

显然，一个节点可能拥有多个属性值，所有属性的名字和值都在配置文件中配置。如，下面是多个节点的配置：
```
node.group1: group1_value1   
node.group2: group2_value4
```
同样的方法，include和exclude也可以设置多个值，如：
```
PUT /test/_settings 
{ 
     "index.routing.allocation.include.group1" : "xxx" ,
     "index.routing.allocation.include.group1" : "yyy",
     "index.routing.allocation. exclude.group1" : "zzz"  
}
```
上面的设置可以通过索引更新的api实时更新到索引上，允许实时移动索引分片。
