# 1、问题
- 由于早前elasticsearch集群数据存储路径只配置了一个，所以某天磁盘突然爆满，集群差点当机。需重新配置多路径存储路径，因为在生产环境，得保证集群不死掉，只能一台一台配置重启。

# 2、修改配置文件

修改elasticsearch.yml中path.data属性，添加多路径以逗号分隔
```
path.data : /opt/data1,/opt/data2
```

# 3、查看集群状态
```
curl -XGET "http://xxxx:9200/_cat/indices"
curl -XGET "http://xxxx:9200/_cat/nodes"
curl -XGET "http://xxxx:9200/_cat/health"
```

4、关闭索引自动平衡
```
curl -XPUT "http://xxxx:9200/_cluster/settings" -d'
{
  "transient" : { 
      "cluster.routing.allocation.enable" : "none" 
  } 
}'
```

5、重启节点

6、开启自动平衡
```
curl -XPUT "http://xxxx.52:9200/_cluster/settings" -d'
{
  "transient": {
    "cluster.routing.allocation.enable": "all"
  }
}'
```

7、重复4-6步骤

8、遇到的问题

有一个索引的某个分片一直处理UNASSIGNED状态，需进行手动分配。
```
curl -XGET 'http://xxxx:9200/_cat/shards' | grep UNASSIGNED    #查看未分配的索引分片
curl -XGET "http://xxxx:9200/_cat/shards/index?v" #查看索引分片
```

使用reroute接口进行分配。reroute 接口支持五种指令：
- allocate_replica
- allocate_stale_primary
- allocate_empty_primary
- move
- cancel。

常用的一般是 allocate 和 move，allocate_* 指令。

因为负载过高等原因，有时候个别分片可能长期处于 UNASSIGNED 状态，我们就可以手动分配分片到指定节点上。默认情况下只允许手动分配副本分片(即使用 allocate_replica)，所以如果要分配主分片，需要单独加一个 accept_data_loss 选项

分配主分片
```
curl -XPOST "http://xxxx:9200/_cluster/reroute" -d  '{
  "commands" : [ {
        "allocate_stale_primary" :
            {
              "index" : "index",
              "shard" : 4,
              "node" : "node56",
              "accept_data_loss" : true
            }
        }
  ]
}'
```

分配副分片
```
curl -XPOST "http://xxxx:9200/_cluster/reroute" -d  '{
  "commands" : [ {
        "allocate_replica" :
            {
              "index" : "index",
              "shard" : 4, 
              "node" : "node56"
            }
        }
  ]
}'
```

9、kibana进和查询命令
```
fuser -n tcp 5601
```
