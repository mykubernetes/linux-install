# 分片分配感知

- 分片感知分配：通过自定义节点属性来实现，比如定义一个属性rack_id，通过该属性来判断是否属于同一个机架，比如当有2个机架时，就会分别在另一个机架中分配自己的副分片，这样就能保证另一台机架宕机后，仍工作的机架上也有之前的机架的副分片，从而保证了数据的完整性。
- 设置启用分片分配感知后，分片仅分配给已为指定感知属性设置值的节点。如果使用了多个感知属性，那么es在分配分片时会分别考虑每个属性
- 总的来说，分片分配感知会将任意一个机架上的索引的副分片复制到每个机架中，这样就能确保即使某一个机架宕机了，其他机架上也有自己的备份，从而保证数据的完整性

# 一、设置机架感知的方法

## 1、在配置文件中设置，自定义属性
```
node.attr.{attribute}: {value}
```

## 2、在创建索引的时候配置

### 2.1 在创建索引配置
```
PUT <index_name>
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1,
    "index.routing.allocation.include.{attribute}": "{value}"
  }
}
```
除了使用自定义的属性来实现外，还可以使用节点自带的属性:
- `_name`：匹配节点名称
- `_host_ip`: 匹配节点主机IP地址
- `_publish_ip`：匹配节点发布IP地址
- `_ip`：匹配host_ip或者publish_ip
- `_host`：匹配主机名hostname
- `_id`：匹配节点ID
- `_tier`：匹配节点的数据层角色
- 
### 2.2 在索引创建之后执行
```
PUT <index_name>/_settings
{
  index.routing.allocation.include.{attribute}": "{value}"
}
```
- index.routing.allocation.include.{attribute}" #表示索引可以分配在包含多个值中的其中一个节点上。
- index.routing.allocation.require.{attribute}" #表示索引要分配在包含索引指定的系欸但是（通常一般设置一个值）。
- index.routing.allocation.exclude.{attribute}" #表示索引只能分配在不包含所有指定节点上。

## 3、在集群级别设置分配感知，对所有的索引生效

- **persistent**: 永久性修改，persistent相关的修改保持在`"/{path.data}/{cluster.name}/nodes/0/_state/global-n.st"`,如果想删除设置，删除此文件即可。
- **transient**: 集群重启后失效。

集群设置的有限顺序为：
- 1、transient cluster settings
- 2、persistent cluster settings
- 3、settings in theelasticsearch.yml configuratin file

```
PUT _cluster/settings
{
  "persistent": {
     "cluster.routing.allocation.awareness.attributes": {attribute}
  }
}
```
除了使用自定义的属性来实现外，还可以使用节点自带的属性:
- `_name`：匹配节点名称
- `_host_ip`: 匹配节点主机IP地址
- `_publish_ip`：匹配节点发布IP地址
- `_ip`：匹配host_ip或者publish_ip
- `_host`：匹配主机名hostname
- `_id`：匹配节点ID
- `_tier`：匹配节点的数据层角色

### 3.1、机架1中添加配置
```
node.attr.rack_id: rack_1
```
### 3.2、机架2中添加配置
```
node.attr.rack_id: rack_2
```
### 3.3、开启分片分配感知
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.awareness.attributes": "rack_id"
  }
}
```



## 4、强制感知策略是避免意外断电导致服务器过载

- 默认情况下，如果一个位置失败，es会将所有丢失的副本分片分配给其他位置。尽管你可能在所有位置上都有足够的资源来承载你的主副分片，但单个位置可能无法承载所有分片,为了防止发生故障时单个位置过载，可以设置cluster.routing.allocaltion.awareness.force，可以使在其他位置的节点可用之前，不分片任何副本。

```
"cluster.routing.allocation.awareness.attributes": {attribute}
"cluster.routing.allocation.awareness.force.my_rack_id.values": {value1,value2}
```

```
PUT _cluster/settings
{
  "transient": {
    "cluster.routing.allocation.awareness.attributes": "my_rack_id",
    "cluster.routing.allocation.awareness.force.my_rack_id.values": "rack1,rack2"
  }
}
```

冷热集群参考：
- https://blog.csdn.net/laoyang360/article/details/102539888
