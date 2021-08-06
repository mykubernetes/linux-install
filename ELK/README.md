
Promtail + Loki + Grafana 构建日志监控告警系统
- promtail： 日志收集的代理，安装部署在需要收集和分析日志的服务器，promtail会将日志发给Loki服务。
- Loki： 主服务器，负责存储日志和处理查询。
- Grafana：提供web管理界面，数据展示功能。 

https://blog.csdn.net/m0_38075425/article/details/108386005

https://www.freesion.com/article/41801004511/

https://blog.csdn.net/yangbosos/article/details/88903846

http://www.jwsblog.com/archives/59.html


使用curl命令操作elasticsearch
=============================

https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html

https://github.com/chenryn/ELKstack-guide-cn/blob/master/SUMMARY.md

ES  内置的REST 接口
---
| URL | 说明 |
|-----|------|
| /index/_search | 搜索指定索引下的数据 |
| /_aliases | 获取或者操作索引下的别名 |
| /index/ | 查看指定索引下的详细信息 |
| /index/type/ | 创建或者操作类型 |
| /index/mapping | 创建或者操作mapping |
| /index/settings | 创建或者操作settings |
| /index/_open | 打开指定索引 |
| /index/_close | 关闭指定索引 |
| /index/_refresh | 刷新索引（使新增加内容对搜索可见，不保证数据被写入磁盘） |
| /index/_flush | 刷新索引（会触发Lucene提交数据） |

一、使用_cat系列
---
_cat系列提供了一系列查询elasticsearch集群状态的接口。  
```
curl -XGET localhost:9200/_cat
获取所有_cat系列的操作
=^.^=
/_cat/allocation              #查看节点分配情况
/_cat/shards                  #查看分片情况
/_cat/shards/{index}
/_cat/master                  #查看主节点信息
/_cat/nodes                   #查看所有节点
/_cat/indices                 #查看所有索引 类似于数据库的show databases;
/_cat/indices/{index}
/_cat/segments                #查看索引的分片信息
/_cat/segments/{index}
/_cat/count                   #查看文档个数
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health                  #查看集群健康情况
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
```  

后面加一个v，让输出内容表格显示表头  
```
curl localhost:9200/_cat/indices?v
name       component        version type url
Prometheus analysis-mmseg   NA      j
Prometheus analysis-pinyin  NA      j
Prometheus analysis-ik      NA      j
Prometheus analysis-ik      NA      j
Prometheus analysis-smartcn 2.1.0   j
Prometheus segmentspy       NA      s    /_plugin/segmentspy/
Prometheus head             NA      s    /_plugin/head/
Prometheus bigdesk          NA      s    /_plugin/bigdesk/
Xandu      analysis-ik      NA      j
Xandu      analysis-pinyin  NA      j
Xandu      analysis-mmseg   NA      j
Xandu      analysis-smartcn 2.1.0   j
Xandu      head             NA      s    /_plugin/head/
Xandu      bigdesk          NA      s    /_plugin/bigdesk/
Onyxx      analysis-ik      NA      j
Onyxx      analysis-mmseg   NA      j
Onyxx      analysis-smartcn 2.1.0   j
Onyxx      analysis-pinyin  NA      j
Onyxx      head             NA      s    /_plugin/head/
Onyxx      bigdesk          NA      s    /_plugin/bigdesk/
```

二、使用_cluster系列  
---

1、集群健康检测
```
http://172.0.0.1:9200/_cat/health?v
     
epoch      timestamp cluster    status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1498119164 16:12:44  es-cluster yellow          1         1     20  20    0    0       20             0                  -                 50.0%
```

2、查询设置集群状态  
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

3、集群的详细信息。包括节点、分片等。  
```
curl -XGET localhost:9200/_cluster/state?pretty=true
```  

4、获取集群堆积的任务  
```
curl -XGET localhost:9200/_cluster/pending_tasks?pretty=true
```  

5、修改集群配置
```
curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}'
```  
transient 表示临时的，persistent表示永久的  

6、对shard的手动控制  
```
curl -XPOST 'localhost:9200/_cluster/reroute' -d 'xxxxxx'
```

7、关闭节点

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

8、查看snspshots
```
# curl -XGET http://127.0.0.1:9200/_cat/snapshots/{repository}
```

三、使用_nodes系列
---

1、查询节点的状态  
```
curl -XGET 'http://localhost:9200/_nodes/stats?pretty=true'
curl -XGET 'http://localhost:9200/_nodes/process'            
curl -XGET 'http://localhost:9200/_nodes/process/stats'                            #统计信息（内存、cpu）
curl -XGET 'http://localhost:9200/_nodes/jvm'                                      #获取各节点的虚拟机统计和配置信息
curl -XGET 'http://localhost:9200/_nodes/jvm/stats'                                #更详细的虚拟机信息
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



2、集群节点列表api
```
curl -XGET http://172.0.0.1:9200/_cat/nodes?v
 
ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.0.128           19          72  58                          mdi       *      master

#显示更详细的节点信息
curl -XGET http://172.0.0.1:9200/_nodes/process?pretty
```
-  heap.percent 查看内存是否爆表


四、使用索引操作
---
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
# curl -XGET http://127.0.0.1:9200/index/_search          #搜索
# curl -XGET http://127.0.0.1:9200/_aliases               #获取或操作索引的别名
# curl -XGET http://127.0.0.1:9200/index/                 #查看当前索引
# curl -XGET http://127.0.0.1:9200/index/type/            #创建或操作类型
# curl -XGET http://127.0.0.1:9200/index/_mapping         #创建或操作mapping
# curl -XGET http://127.0.0.1:9200/index/_settings        #创建或操作设置（number_of_shards是不可更改的）
# curl -XGET http://127.0.0.1:9200/index/_open            #打开被关闭的索引
# curl -XGET http://127.0.0.1:9200/index/_close           #关闭索引
# curl -XGET http://127.0.0.1:9200/index/_refresh         #刷新索引（使新加内容对搜索课件）
# curl -XGET http://127.0.0.1:9200/index/_flush           #刷新索引（将变动提交到ucene索引文件中，并清空elasticsearch的transaction log）
# curl -XGET http://127.0.0.1:9200/index/_optimize        #优化segement
# curl -XGET http://127.0.0.1:9200/index/_status          #获取索引的状态信息
# curl -XGET http://127.0.0.1:9200/index/_segments        #获取索引的segments的状态信息
# curl -XGET http://127.0.0.1:9200/index/_explain         #不执行实际搜索，而返回解释信息
# curl -XGET http://127.0.0.1:9200/index/_analyze         #不执行实际搜索，根据输入的参数进行文本分析
# curl -XGET http://127.0.0.1:9200/index/type/id          #操作指定文档
# curl -XPUT http://127.0.0.1:9200/index/type/id/_create  #创建一个文档，如果该文档已存在，则返回失败
# curl -XPUT http://127.0.0.1:9200/index/type/id/update   #更新一个文档，如果该文档不已存在，则返回失败
```

五、日常巡检
---

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

