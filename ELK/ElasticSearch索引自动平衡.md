### 以下动态设置可用于控制分片和恢复： `cluster.routing.allocation.enable` 启用或禁用特定种类的分片的分配：
- all - （默认值）允许为所有类型的分片分配分片。
- primaries - 仅允许分配主分片的分片。
- new_primaries - 仅允许为新索引的主分片分配分片。
- none - 任何索引都不允许任何类型的分片。

### cluster.routing.rebalance.enable 为特定类型的分片启用或禁用重新平衡：
- all - （默认值）允许各种分片的分片平衡。
- primaries - 仅允许主分片的分片平衡。
- replicas - 仅允许对副本分片进行分片平衡。
- none - 任何索引都不允许任何类型的分片平衡。

### cluster.routing.allocation.allow_rebalance

当分片再平衡时允许的操作
- 始终 - 始终允许重新平衡。
- indices_primaries_active - 仅在所有主分片激活时。
- indices_all_active - （默认）仅当所有分片都激活时。

### 当节点出于任何原因（有意或无故）离开集群时，主服务器会做出以下反应：
- 将副本分片提升为主分片，以代替所有之前在该节点上的主分片。
- 分配副本分片以替换丢失的副本（假设有足够的节点）。
- 在其余节点之间平均分配碎片。

可以使用 index.unassigned.node_left.delayed_timeout 动态设置（默认值为 1m ）来延迟由于节点离开而变成未分配的副本分片的分配。

可以在实时索引（或所有索引）上更新此设置：
```
PUT _all/_settings
{
  "settings": {
    "index.unassigned.node_left.delayed_timeout": "5m"
  }
}
```

# 关闭自动分配
```
curl -XPUT "http://127.0.0.1:9200/_cluster/settings" -H 'Content-Type: application/json' -d' 
{
    "transient":{
        "cluster.routing.allocation.enable":"none"
    }
}'
```

# 开启
```
curl -XPUT "http://127.0.0.1:9200/_cluster/settings" -H 'Content-Type: application/json' -d' 
{
    "transient":{
        "cluster.routing.allocation.enable":"all"
    }
}'
```

# 调整自动平衡速度 默认为2
```
curl -XPUT "http://127.0.0.1:9200/_cluster/settings" -H 'Content-Type: application/json' -d' 
{
    "transient":{
        "cluster.routing.allocation.cluster_concurrent_rebalance":"2"
    }
}'
```

# 调整未分配恢复速度 默认为2 最大为50  处理完及时还原配置
```
curl -XPUT "http://127.0.0.1:9200/_cluster/settings" -H 'Content-Type: application/json' -d' 
{
    "transient":{
        "cluster.routing.allocation.node_concurrent_recoveries":"2"
    }
}'
```

# 如果希望 Elasticsearch 立即分配丢失的分片，只需将超时更新为零：
```
PUT _all/_settings
{
  "settings": {
    "index.unassigned.node_left.delayed_timeout": "0"
  }
}
```
您可以在丢失的分片开始恢复后立即重置超时。

参考：
https://www.jianshu.com/p/a81ca31bb316
