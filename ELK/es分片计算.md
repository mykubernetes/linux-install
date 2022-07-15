```
# 新增索引的同时添加分片，不使用默认分片，分片的数量
# 一般以（节点数*1.5或3倍）来计算，比如有4个节点，分片数量一般是6个到12个，每个分片一般分配一个副本
```
PUT /testindex
 {
    "settings" : {
       "number_of_shards" : 12,
       "number_of_replicas" : 1
    }
 }
```
