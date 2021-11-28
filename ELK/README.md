| 资料 | 地址 |
|-----|------|
| 官网 | https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html |
| github | https://github.com/chenryn/ELKstack-guide-cn/blob/master/SUMMARY.md |
| 博客 | https://haicoder.net/elasticsearch/elasticsearch-tutorial.html |
| 博客 | https://wiki.eryajf.net/pages/2351.html |

# 使用curl命令操作elasticsearch

ES  内置的REST 接口
---
| URL | 说明 |
|-----|------|
| `/index/_search` | 搜索指定索引下的数据 |
| `/_aliases` | 获取或者操作索引下的别名 |
| `/index/` | 查看指定索引下的详细信息 |
| `/index/type/` | 创建或者操作类型 |
| `/index/mapping` | 创建或者操作mapping |
| `/index/settings` | 创建或者操作settings |
| `/index/_open` | 打开指定索引 |
| `/index/_close` | 关闭指定索引 |
| `/index/_refresh` | 刷新索引（使新增加内容对搜索可见，不保证数据被写入磁盘） |
| `/index/_flush` | 刷新索引（会触发Lucene提交数据） |

一、使用_cat系列
---
_cat系列提供了一系列查询elasticsearch集群状态的接口。  
```
curl -XGET localhost:9200/_cat
获取所有_cat系列的操作
=^.^=
/_cat/allocation              #查看资源信息
/_cat/shards                  #查看分片情况
/_cat/shards/{index}          #查看具体索引的分片信息
/_cat/master                  #查看主节点信息
/_cat/nodes                   #查看节点状态
/_cat/nodeattrs               #查看节点的自定义属性
/_cat/indices                 #查看所有索引 类似于数据库的show databases;
/_cat/indices/{index}         #查看具体索引信息
/_cat/segments                #查看索引的分片信息
/_cat/segments/{index}        #查看具体索引的存储片段信息
/_cat/snapshots/{repository}  #查看快照库
/_cat/count                   #查看文档总数
/_cat/count/{index}           #查看具体索引的文档总数
/_cat/recovery                #查看数据恢复状态
/_cat/recovery/{index}        #查看数据恢复状态
/_cat/repositories            #查看存储库
/_cat/health                  #查看集群健康情况
/_cat/pending_tasks           #查看待处理任务
/_cat/aliases                 #查看别名信息
/_cat/aliases/{alias}         #指定别名查看信息
/_cat/thread_pool             #查看线程池信息
/_cat/thread_pool/{thread_pools}/_cat/plugins            #查看线程池下插件
/_cat/tasks                   #查看任务
/_cat/templates               #查看模板
/_cat/plugins                 #查看插件信息
/_cat/fielddata               #查看fielddata占用内存情况(查询时es会把fielddata信息load进内存)
/_cat/fielddata/{fields}      #针对某一字段进行查看
```  
- ?v 打印出表头信息
- ?pretty 美化输出

查看es是否正常启动
```
curl -XGET 'http://localhost:9200/?pretty'
{
  "name" : "node01",
  "cluster_name" : "es-cluster",
  "cluster_uuid" : "53LLexx8RSW16nE4lsJMQQ",
  "version" : {
    "number" : "6.8.2",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "159a78a",
    "build_date" : "2021-11-06T20:11:28.826501Z",
    "build_snapshot" : false,
    "lucene_version" : "7.5.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

查看所有index
```
curl -XGET http://localhost:9200/_cat/indices?v
```

查看所有doc数量
```
curl -XGET http://localhost:9200/_cat/count?v
```

查看所有node存储空间转台
```
curl -XGET http://localhost:9200/_cat/allocation?v
```

查看所有node文件系统状态
```
curl -XGET http://localhost:9200/_nodes/stats/fs?pretty
```

查看所有node可用磁盘大小
```
curl -XGET http://localhost:9200/_cat/nodes?h=h,diskAvail
```

集群健康检测
```
curl -XGET http://localhost:9200/_cat/health?v

epoch      timestamp cluster    status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1498119164 16:12:44  es-cluster yellow          1         1     20  20    0    0       20             0                  -                 50.0%
```

# 二、使用_cluster系列  

查看集群概要信息：
```
curl -XGET 'http://127.0.0.1:9200/_cluster/stats?pretty'
```
查看集群健康状态信息：
```
curl -XGET 'http://127.0.0.1:9200/_cluster/health?pretty'
```

查看集群堆积的任务
```
curl -u es-user:es-password -H "Content-Type: application/json" -XPUT 'http://127.0.0.1:9200/_cluster/pending_tasks?pretty=true  
```

查看集群设置信息：
```
curl -XGET 'http://127.0.0.1:9200/_cluster/settings?pretty'
```

允许集群生成新的分片：
```	
curl -XPUT http://127.0.0.1:9200/_cluster/settings?pretty=1 -d '{
"persistent":{
"cluster.routing.allocation.enable": "all"
}
}'
```
- transient 表示临时的
- persistent 表示永久的

禁止集群生成新的分片：
```
curl -XPUT http://127.0.0.1:9200/_cluster/settings?pretty=1 -d '{
"persistent":{
"cluster.routing.allocation.enable": "none"
}
}'
```

允许集群中所有分片自动均衡：
```
curl -XPUT http://127.0.0.1:9200/_cluster/settings?pretty=1 -d '{
"persistent":{
"cluster.routing.rebalance.enable": "all"
}
}'
```

只允许集群中的副本分片自动均衡：
```
curl -XPUT http://127.0.0.1:9200/_cluster/settings?pretty=1 -d '{
"persistent":{
"cluster.routing.rebalance.enable": "replicas"
}
}'
```

禁止集群中的分片自动均衡：
```
curl -XPUT http://127.0.0.1:9200/_cluster/settings?pretty=1 -d '{
"persistent":{
"cluster.routing.rebalance.enable": "none"
}
}'
```

设置集群自动均衡最低剩余存储容量(es7)：
```
curl -u es-user:es-password -H "Content-Type: application/json" -XPUT 'http://127.0.0.1:9200/_cluster/settings?pretty=true' -d '{
"persistent":{
"cluster.routing.allocation.disk.watermark.low": "90%"
}
}'
```

设置集群自动均衡最高使用存储容量(es7)：
```
curl -u es-user:es-password -H "Content-Type: application/json" -XPUT 'http://127.0.0.1:9200/_cluster/settings?pretty=true' -d '{
"persistent":{
"cluster.routing.allocation.disk.watermark.low": "95%"
}
}'
```

设置集群信息更新时间(es7):
```
curl -u es-user:es-password -H "Content-Type: application/json" -XPUT 'http://127.0.0.1:9200/_cluster/settings?pretty=true' -d '{
"persistent":{
"cluster.info.update.interval": "1m"
}
}'
```

查询设置集群状态  
```
curl -XGET localhost:9200/_cluster/health?pretty=true
{
  "cluster_name" : "jiankunking-log",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,                        #集群内的总节点数
  "number_of_data_nodes" : 3,                   #集群内的总数据节点数
  "active_primary_shards" : 2722,               #集群内所有索引的主分片总数
  "active_shards" : 5444,                       #集群内所有索引的分片总数
  "relocating_shards" : 0,                      #正在迁移中的分片数
  "initializing_shards" : 0,                    #正在初始化的分片数
  "unassigned_shards" : 0,                      #未分配到具体节点上的分片数      重要
  "delayed_unassigned_shards" : 0,              #延时待分配到具体节点上的分片数
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0     #分片比例正常是100%，处在恢复阶段比例在增加直到100
}

curl -XGET localhost:9200/_cluster/health?pretty=true         #表示格式化输出
curl -XGET localhost:9200/_cluster/health?level=indices       #表示显示索引状态
curl -XGET localhost:9200/_cluster/health?level=shards        #表示显示分片信息
```
- green 绿灯，所有分片都正确运行，集群非常健康。
- yellow 黄灯，所有主分片都正确运行，但是有副本分片缺失。
- red 红灯，有主分片缺失。这部分数据完全不可用。


修改集群配置
```
curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}'
```  

关闭指定192.168.1.1节点  
```
curl -XPOST 'http://192.168.1.1:9200/_cluster/nodes/_local/_shutdown'
curl -XPOST 'http://localhost:9200/_cluster/nodes/192.168.1.1/_shutdown'
```

关闭主节点  
```
curl -XPOST http://localhost:9200/_cluster/nodes/_master/_shutdown'
```

关闭整个集群  
```
$ curl -XPOST 'http://localhost:9200/_shutdown?delay=10s'
$ curl -XPOST 'http://localhost:9200/_cluster/nodes/_shutdown'
$ curl -XPOST 'http://localhost:9200/_cluster/nodes/_all/_shutdown'
delay=10s表示延迟10秒关闭
```

查看snspshots
```
# curl -XGET http://127.0.0.1:9200/_cat/snapshots/{repository}
```


# 三、使用_nodes系列


查看节点信息：
```
curl -XGET 'http://127.0.0.1:9200/_cat/nodes?v'
ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.0.128           19          72  58                          mdi       *      master
```

查看所有节点信息：
```
curl -XGET 'http://127.0.0.1:9200/_nodes?pretty=true'
```

查看指定节点(node-es-03)的信息：
```
curl -XGET 'http://127.0.0.1:9200/_nodes/node-es-03?pretty=true'
```

#显示更详细的节点信息
```
curl -XGET http://172.0.0.1:9200/_nodes/process?pretty
```
- heap.percent 查看内存是否爆表


查询节点的状态  
```
curl -XGET 'http://localhost:9200/_nodes/stats?pretty=true'
curl -XGET 'http://localhost:9200/_nodes/process'
curl -XGET 'http://localhost:9200/_nodes/_all
curl -XGET 'http://localhost:9200/_nodes/_all/process
curl -XGET 'http://localhost:9200/_nodes/process/stats'                            #统计信息（内存、cpu）
curl -XGET 'http://localhost:9200/_nodes/jvm'                                      #获取各节点的虚拟机统计和配置信息
curl -XGET 'http://localhost:9200/_nodes/jvm,process'  
curl -XGET 'http://localhost:9200/_nodes/jvm/stats'                                #更详细的虚拟机信息
curl -XGET 'http://localhost:9200/_nodes/info/jvm,process'
curl -XGET 'http://localhost:9200/_nodes/http'                                     #获取各个节点的http信息（如ip地址）
curl -XGET 'http://localhost:9200/_nodes/http/stats'                               #获取各个节点处理http请求的统计情况
curl -XGET 'http://localhost:9200/_nodes/hot_threads/stats'
curl -XGET 'http://localhost:9200/_nodes/thread_pool                               #获取各种类型的线程池
curl -XGET 'http://localhost:9200/_nodes/thread_pool/stats'                        #获取各种类型线程池的统计信息
```
以上操作可以通过以下形式针对指定节点操作
```
curl -XGET 'http://localhost:9200/_node/${nodeid}/jvm/stats
curl -XGET 'http://localhost:9200/_node/${nodeip}/jvm/stats
curl -XGET 'http://localhost:9200/_node/${nodeattribute}/jvm/stats
```

# 四、使用索引操作

1、列出集群中所有的索引
```
curl -XGET http://172.0.0.1:9200/_cat/indices?v
     
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   ttl   mPSsvTX3TbSsSQKUcJqtbA   5   1          0            0       795b           795b
yellow open   java  3IfBdV_-T8SuvNSK72jBqQ   5   1          0            0       650b           650b
yellow open   book  -rZ8v4AfTDyPPTm3oZ_qLQ   5   1         16            0     64.7kb         64.7kb
yellow open   index 4BAj2ycsSGyosLYPmTQEZw   5   1          0            0       795b           795b
```
上面health都为yellow是因为只有一个node,es默认创建一个副本,等待其他的节点加入
- pri 索引的分配个数
- rep 索引的副本个数
- docs.count 所有文档的总数
- docs.deleted 删除文档的总数
- store.size 总存储空间，包含副本的空间
- pri.store.size 主分片存储的空间

查看分片状态
```
# curl -XGET http://127.0.0.1:9200/_cat/shards?v
index                             shard prirep state            docs    store ip        node
logstash-mweibo-h5view-2015.06.10 20    p      STARTED       4690968  679.2mb 127.0.0.1 10.19.0.108
logstash-mweibo-h5view-2015.06.10 20    r      STARTED       4690968  679.4mb 127.0.0.1 10.19.0.39
logstash-mweibo-h5view-2015.06.10 2     p      STARTED       4725961  684.3mb 127.0.0.1 10.19.0.53
logstash-mweibo-h5view-2015.06.10 2     r      STARTED       4725961  684.3mb 127.0.0.1 10.19.0.102
```
- prirep
  - p 主分片
  - r 复副本


```
# curl -XGET http://127.0.0.1:9200/${index}/_search          #搜索
# curl -XGET http://127.0.0.1:9200/_aliases                  #获取或操作索引的别名
# curl -XGET http://127.0.0.1:9200/${index}/                 #查看当前索引
# curl -XGET http://127.0.0.1:9200/${index}?pretty           #查看指定索引的结构
# curl -XGET http://127.0.0.1:9200/${index}/_stats?prtty     #查看指定索引的状态
# curl -XGET http://127.0.0.1:9200/${index}/type/            #创建或操作类型
# curl -XGET http://127.0.0.1:9200/${index}/_mapping         #创建或操作索引的映射机构
# curl -XGET http://127.0.0.1:9200/${index}/_settings        #创建或操作设置（number_of_shards是不可更改的）
# curl -XGET http://127.0.0.1:9200/${index}/_open            #打开被关闭的索引
# curl -XGET http://127.0.0.1:9200/${index}/_close           #关闭索引
# curl -XGET http://127.0.0.1:9200/${index}/_refresh         #刷新索引（使新加内容对搜索课件）
# curl -XGET http://127.0.0.1:9200/${index}/_flush           #刷新索引（将变动提交到ucene索引文件中，并清空elasticsearch的transaction log）
# curl -XGET http://127.0.0.1:9200/${index}/_optimize        #优化segement
# curl -XGET http://127.0.0.1:9200/${index}/_status          #获取索引的状态信息
# curl -XGET http://127.0.0.1:9200/${index}/_segments        #获取索引的segments的状态信息
# curl -XGET http://127.0.0.1:9200/${index}/_explain         #不执行实际搜索，而返回解释信息
# curl -XGET http://127.0.0.1:9200/${index}/_analyze         #不执行实际搜索，根据输入的参数进行文本分析
# curl -XGET http://127.0.0.1:9200/${index}/type/id          #操作指定文档
# curl -XPUT http://127.0.0.1:9200/${index}/type/id/_create  #创建一个文档，如果该文档已存在，则返回失败
# curl -XPUT http://127.0.0.1:9200/${index}/type/id/update   #更新一个文档，如果该文档不已存在，则返回失败
```

创建新的索引：
```
curl -XPUT "http://127.0.0.1:9200/logstash-bbl?pretty" -d '
{
"settings" : {
"index" : {
"refresh_interval" : "5s",
"number_of_shards" : "1",
"number_of_replicas" : "1"
}
}
}'
```

删除指定的索引:
```
curl -XDELETE 'http://127.0.0.1:9200/logstash-bbl'
```

删除指定索引的副本分片(es5)：
```
curl -XPUT "http://127.0.0.1:9200/logstash-bbl/_settings?pretty=1" -d '{
"index" :{
"number_of_replicas" : 1
}
}'　
```

删除指定索引的副本分片(es7)：
```
curl -u es-user:es-password -H "Content-Type: application/json" -XPUT 'http://127.0.0.1:9210/user-access-2000.01.01/_settings?pretty=true' -d '{
"index" :{
"number_of_replicas" : 0
}
}'
```

# 五、分片(Shards)相关

查各节点中分片的分布情况：
```
curl -XGET 'http://127.0.0.1:9200/_cat/allocation?v'
```

查看集群中所有分片信息：
```
curl -XGET 'http://127.0.0.1:9200/_cat/shards?v'
```

查看指定分片信息：
```
curl -XGET 'http://127.0.0.1:9200/_cat/shards/statistics?v' 
```

迁移分片(es5)：node-es-04 --> storage.track(0) --> node-es-01
```
curl -XPOST 'http://127.0.0.1:9200/_cluster/reroute' -d '{
"commands":[{
"move":{
"index":"storage.track",
"shard":0,
"from_node":"node-es-04",
"to_node":"node-es-01"
}}]}'
```

迁移分片(es7)：node-es-04 --> storage.track(0) --> node-es-01
```
curl -u es-user:es-password -H "Content-Type: application/json" -XPOST 'http://127.0.0.1:9210/_cluster/reroute' -d '{
"commands":[{
"move":{
"index":"storage.track",
"shard":0,
"from_node":"node-es-04",
"to_node":"node-es-01"
}}]}'
```


# 六、CURD
```
1.查询数据
curl -XGET 'http://localhost:9200/{index}/{type}/{id}'

2.索引(插入)数据
curl -XPOST 'http://localhost:9200/{index}/{type}/{id}’ -d'{“key”:”value”,“key”:”value”}'

3.批量导入数据(在a.json文件所在当前文件下)
curl -XPOST 'localhost:9200/{index}/{type}/_bulk' --data-binary "@a.json"

4.删除数据
curl -XDELETE 'http://localhost:9200/{index}/{type}/{id}'

5.按照查询结果删除数据
curl -XPOST 'localhost:9200/{index}/{type}/_delete_by_query?pretty' -d'
{"query": {"query_string": {"message": "some message"}}}'
```

# 七、settings
```
1.修改分片数
curl -XPUT 'http://localhost:9200/_all/_settings?preserve_existing=true' -d '{
"index.number_of_shards" : “3”}'

2.修改副本数
curl  -XPUT 'http://115.28.157.41:9222/_all/_settings' -d ' {
"index.number_of_replicas":"0"}'
```
- 分片数在有数据之后不能再改动，副本数可以随时修改。

# 八、日常巡检

1、查看集群状态
```
curl -XGET http://172.0.0.1:9200/_cluster/health?pretty
```

2、显示集群系统信息，包括CPU JVM等等  
```
curl -XGET http://172.0.0.1:9200/_cluster/stats?pretty=true
```

3、查看集群JVM内存大小，如果超过80%，则集群写入会不正常
```
curl -XGET "http://172.0.0.1:9200/_nodes/stats/jvm?pretty" | grep heap_used_percent
```

4、集群空间检查
```
curl http://172.0.0.1:9200/_cat/allocation?v
```

5、检查磁盘空间
```
df -h
```


六、集群常见故障处理
---
ES集群出现Unassigned shards问题 

1、对集群进行巡检，进行检查集群状态，检查jvm使用情况，检查集群空间，磁盘空间

2、查看unassigned shards有哪些
```
# curl -XGET http://127.0.0.1:9200/_cat/shards?h=index,shard,prirep,state,unassigned,reason |grep UNASSIGNED
```

3、查看出现unassigned shards的原因
```
# curl -XGET http://127.0.0.1:9200/_cluster/allocation/explain?pretty
```

4、查看状态不为green的index
```
# curl -XGET http://127.0.0.1:9200/_cat/indices?v |grep -v green
```

通过查看日志，出现unassigned shards的情况有很多，需要具体问题具体分析，下面列出几种情况
---
1、node节点出现卡死，通过kill es进程重启卡死的es节点即可

2、shard分配超过最大次数，尝试手动分配shard
```
# curl -XPOST 'http://127.0.0.1:9200/_cluster/reroute?retry_failed=true'
```

3、副本数据损坏，需要把相应副本先设为0，再设为1，重新分配
```
# curl -XPUT 'http://127.0.0.1:9200/${index}/_settings?pretty -H 'Content-Type: application/json' -d'
{
  "index": {
    "number_of_repolicas": 0
  }
}
```

4、对于数据可丢失的情况，可以直接delete出现问题的indices,恢复集群正常（慎用）
```
# curl -XDELETE 'http://127.0.0.1:9200/index_name
```


# Promtail + Loki + Grafana 构建日志监控告警系统
- promtail： 日志收集的代理，安装部署在需要收集和分析日志的服务器，promtail会将日志发给Loki服务。
- Loki： 主服务器，负责存储日志和处理查询。
- Grafana：提供web管理界面，数据展示功能。 

参考：
- https://blog.csdn.net/m0_38075425/article/details/108386005
- https://www.freesion.com/article/41801004511/
- https://blog.csdn.net/yangbosos/article/details/88903846
- http://www.jwsblog.com/archives/59.html
