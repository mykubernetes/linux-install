
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

ES  内置的REST 接口
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
_cat系列提供了一系列查询elasticsearch集群状态的接口。  
```
curl -XGET localhost:9200/_cat
获取所有_cat系列的操作
=^.^=
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master                  #查看住节点信息
/_cat/nodes                   #查看所有节点
/_cat/indices                 #查看所有索引 类似于数据库的show databases;
/_cat/indices/{index}
/_cat/segments
/_cat/segments/{index}
/_cat/count
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health                  #查看es健康状况
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
```  
你也可以后面加一个v，让输出内容表格显示表头  
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
1、查询设置集群状态  
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
  "unassigned_shards" : 0,                      #未分配到具体节点上的分片数
  "delayed_unassigned_shards" : 0,              #延时待分配到具体节点上的分片数
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

curl -XGET localhost:9200/_cluster/health?pretty=true         #表示格式化输出
curl -XGET localhost:9200/_cluster/health?level=indices       #表示显示索引状态
curl -XGET localhost:9200/_cluster/health?level=shards        #表示显示分片信息
```
- green 绿灯，所有分片都正确运行，集群非常健康。
- yellow 黄灯，所有主分片都正确运行，但是有副本分片缺失。
- red 红灯，有主分片缺失。这部分数据完全不可用。



2、显示集群系统信息，包括CPU JVM等等  
```
curl -XGET localhost:9200/_cluster/stats?pretty=true
```

3、集群的详细信息。包括节点、分片等。  
```
curl -XGET localhost:9200/_cluster/state?pretty=true
```  

4、获取集群堆积的任务  
```
curl -XGET localhost:9200/_cluster/pending_tasks?pretty=true
```  

5、修改集群配置
举例：
```
curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}'
```  
transient 表示临时的，persistent表示永久的  

6、对shard的手动控制  
``` curl -XPOST 'localhost:9200/_cluster/reroute' -d 'xxxxxx' ```

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

三、使用_nodes系列

1、查询节点的状态  
```
curl -XGET 'http://localhost:9200/_nodes/stats?pretty=true'
curl -XGET 'http://localhost:9200/_nodes/192.168.1.2/stats?pretty=true'
curl -XGET 'http://localhost:9200/_nodes/process'
curl -XGET 'http://localhost:9200/_nodes/_all/process'
curl -XGET 'http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/jvm,process'
curl -XGET 'http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/info/jvm,process'
curl -XGET 'http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/_all'
curl -XGET 'http://localhost:9200/_nodes/hot_threads'
```

四、使用索引操作

1、集群健康检测api
```
http://192.168.0.128:9200/_cat/health?v
     
epoch      timestamp cluster    status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1498119164 16:12:44  es-cluster yellow          1         1     20  20    0    0       20             0                  -                 50.0%
     
说明:集群的状态描述:
green:一切都准备好了,集群功能全部可用;
yellow:数据准备好了,但是副本还没有分配好,集群功能全部可用;
red:有些数据不可用,但是集群部分功能可用;
```

2、集群节点列表api
```
http://192.168.0.128:9200/_cat/nodes?v
 
ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.0.128           19          72  58                          mdi       *      master
```

3、列出集群中所有的索引
```
curl -XGET http://192.168.0.128:9200/_cat/indices?v
     
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   ttl   mPSsvTX3TbSsSQKUcJqtbA   5   1          0            0       795b           795b
yellow open   java  3IfBdV_-T8SuvNSK72jBqQ   5   1          0            0       650b           650b
yellow open   book  -rZ8v4AfTDyPPTm3oZ_qLQ   5   1         16            0     64.7kb         64.7kb
yellow open   index 4BAj2ycsSGyosLYPmTQEZw   5   1          0            0       795b           795b
```
上面health都为yellow是因为只有一个node,es默认创建一个副本,等待其他的节点加入

4、创建一个customer的index
```
curl -XPUT http://192.168.0.128:9200/customer?pretty

response:
{
  "acknowledged": true,
  "shards_acknowledged": true
}
```

5、创建文档索引和查询文档
```
curl -XPUT http://192.168.0.128:9200/customer/person/1?pretty -d '{"name":"张三","age":34,"sex":"男"}'
 
response:
{
  "_index": "customer",
  "_type": "person",
  "_id": "1",
  "_version": 1,
  "result": "created",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  },
  "created": true
}
 
----------------------------------------------------------
curl -XPOST http://192.168.0.128:9200/customer/person?pretty -d '{"name":"张三","age":34,"sex":"男"}'

 response:
 {
   "_index": "customer",
   "_type": "person",
   "_id": "AVzTAOlNiSjTxTQlMxWw",
   "_version": 1,
   "result": "created",
   "_shards": {
     "total": 2,
     "successful": 1,
     "failed": 0
   },
   "created": true
 }
 
-----------------------------------------------------------
     
curl -XPOST http://192.168.0.128:9200/customer/person/AVzTAOlNiSjTxTQlMxWw/_update?pretty -d
'{
	"doc":{"name":"李四","age":44,"sex":"男"}
}'
 
response:
{
  "_index": "customer",
  "_type": "person",
  "_id": "AVzTAOlNiSjTxTQlMxWw",
  "_version": 2,
  "result": "updated",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  }
}
     
ps:AVzTAOlNiSjTxTQlMxWw是文档id
     
---------------------------------------------------------------
     
使用脚本更新,ctx._source指向当前source文档
curl -XPOST http://192.168.0.128:9200/customer/person/AVzTAOlNiSjTxTQlMxWw/_update?pretty
'{
	"script" : "ctx._source.age += 5"
}'
     
response:
{
  "_index": "customer",
  "_type": "person",
  "_id": "AVzTAOlNiSjTxTQlMxWw",
  "_version": 3,
  "result": "updated",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  }
}
     
---------------------------------------------------------------
     
curl -XGET http://192.168.0.128:9200/customer/person/1?pretty
     
response:
{
  "_index": "customer",
  "_type": "person",
  "_id": "1",
  "_version": 1,
  "found": true,
  "_source": {
    "name": "张三",
    "age": 34,
    "sex": "男"
  }
}
```

6、删除索引
```
curl -XDELETE http://192.168.0.128:9200/customer
 
response:
{
  "acknowledged": true
}
```

7、根据文档id,删除文档
```
curl -XDELETE http://192.168.0.128:9200/customer/person/AVzTAOlNiSjTxTQlMxWw?pretty
 
response:
{
  "found": true,
  "_index": "customer",
  "_type": "person",
  "_id": "AVzTAOlNiSjTxTQlMxWw",
  "_version": 4,
  "result": "deleted",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  }
}
```

8、批处理_bulk API,可以同时处理index,update,delete操作.批处理减少网络请求.批处理时,如果某个动作失败了,不会影响其他的动作;批处理返回结果按执行的顺序返回动作执行状态,可以检测是否失败.
```
批量添加两个index
curl -XPOST http://192.168.0.128:9200/customer/person/_bulk?pretty
{"index" : {"_id" : 2}}
{"name" : "赵六","age" : 23}
{"index" : {"_id" : 3}}
{"name" : "王五","age" : 53}
 
response:
{
  "took" : 1541,
  "errors" : false,
  "items" : [
    {
      "index" : {
        "_index" : "customer",
        "_type" : "person",
        "_id" : "2",
        "_version" : 1,
        "result" : "created",
        "_shards" : {
          "total" : 2,
          "successful" : 1,
          "failed" : 0
        },
        "created" : true,
        "status" : 201
      }
    },
    {
      "index" : {
        "_index" : "customer",
        "_type" : "person",
        "_id" : "3",
        "_version" : 1,
        "result" : "created",
        "_shards" : {
          "total" : 2,
          "successful" : 1,
          "failed" : 0
        },
        "created" : true,
        "status" : 201
      }
    }
  ]
}
 
------------------------------------------------------
 
 
更新文档2,删除文档3
curl -XPOST http://192.168.0.128:9200/customer/person/_bulk?pretty
{"update" : {"_id" : 2}}
{"doc" : {"age" : 33}}
{"delete" : {"_id" : 3}}
 
response:
{
  "took": 941,
  "errors": false,
  "items": [
    {
      "update": {
        "_index": "customer",
        "_type": "person",
        "_id": "2",
        "_version": 2,
        "result": "updated",
        "_shards": {
          "total": 2,
          "successful": 1,
          "failed": 0
        },
        "status": 200
      }
    },
    {
      "delete": {
        "found": true,
        "_index": "customer",
        "_type": "person",
        "_id": "3",
        "_version": 2,
        "result": "deleted",
        "_shards": {
          "total": 2,
          "successful": 1,
          "failed": 0
        },
        "status": 200
      }
    }
  ]
}
```

9、使用REST API搜索文档
```
搜索所有文档,结果按account_number升序排序
curl -XGET http://192.168.0.128:9200/bank/_search?q=*&sort=account_number:asc&pretty

等价的写法:
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ],
  "from" : 5, //从第5条开始,默认是0
  "size" : 1 //返回1条,默认是10条
}'
 
response:
{
  "took": 32, //搜索时间,单位:毫秒
  "timed_out": false, //搜索是否超时
  "_shards": { //搜索分片数量,以及成功和失败的数量
    "total": 5,
    "successful": 5,
    "failed": 0
  },
  "hits": { //搜索结果
    "total": 1000, //满足搜索条件的文档数量
    "max_score": null,
    "hits": [ //真实搜索结果数组,默认显示10条
      {
        "_index": "bank",
        "_type": "account",
        "_id": "0",
        "_score": null,
        "_source": {
          "account_number": 0,
          "balance": 16623,
          "firstname": "Bradshaw",
          "lastname": "Mckenzie",
          "age": 29,
          "gender": "F",
          "address": "244 Columbus Place",
          "employer": "Euron",
          "email": "bradshawmckenzie@euron.com",
          "city": "Hobucken",
          "state": "CO"
        },
        "sort": [ //排序的结果
          0
        ]
      }
    ]
  }
}
 
------------------------------------------
搜索所有的文档,返回前2条,并显示指定的fields
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
  "query": { "match_all": {} },
  "_source" : ["account_number","balance","email"], //返回指定的字段
  "size" : 2
}'
 
response:
{
  "took": 17,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "failed": 0
  },
  "hits": {
    "total": 1000,
    "max_score": 1,
    "hits": [
      {
        "_index": "bank",
        "_type": "account",
        "_id": "25",
        "_score": 1,
        "_source": {
          "account_number": 25,
          "balance": 40540,
          "email": "virginiaayala@filodyne.com"
        }
      },
      {
        "_index": "bank",
        "_type": "account",
        "_id": "44",
        "_score": 1,
        "_source": {
          "account_number": 44,
          "balance": 34487,
          "email": "aureliaharding@orbalix.com"
        }
      }
    ]
  }
}
 
------------------------------------
搜索account_number为20的文档
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
  "query": { "match": {"account_number" : 20} }
}'
 
------------------------------
搜索address中含有mill的所有文档
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
 "query": { "match": {"address" : "mill"} }
}'
 
---------------------------------
使用match_phrase匹配address中含有"mill lane"短语的文档
http://192.168.0.128:9200/bank/_search
method: POST
params:
{
  "query": { "match_phrase": {"address" : "mill lane"} }
}
 
---------------------------------
 
使用bool query匹配address中同时含有"mill "和"lane"短语的文档,must:and
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
  "query": {
    "bool": {
      "must": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}'
 
与之类似的:
should:or关系
must_not:即不含"mill",也不含"lane"的文档
bool query可以同时包含must,should,must_not组成复杂的查询
```

10 文档score:根据搜索条件估算一个文档匹配程度的相对的数值.得分越高,文档越有价值;反之,价值越低.有些情况不需要score(比如"filter""),es会检测自动优化查询,不计算得分.
```
curl -XPOST http://192.168.0.128:9200/bank/_search  -d
'{
  "query": {
    "bool": {
      "must": { "match_all": {} }, //查询所有的文档
      "filter": { //过滤,不计算得分,从结果可以查出所有的score都为1,是个常量
        "range": { //范围查询,适用于numeric或deta 类型
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}'
```

11 执行聚合:es提供了分组和统计的能力,这就是聚合.可以认为就是sql中的group by和aggregate 功能.es在聚合时同时返回搜索的文档和聚合两部分.
```
按state分组聚合,不返回搜索的文档
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
  "size": 0,//不返回搜索的文档
  "aggs": {//聚合
    "group_by_state": {
      "terms": {
        "field": "state.keyword" //按state分组,降序排序
      }
    }
  }
}'
 
response:
{
  "took": 58,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "failed": 0
  },
  "hits": {
    "total": 1000,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "group_by_state": {
      "doc_count_error_upper_bound": 20,
      "sum_other_doc_count": 770,
      "buckets": [
        {
          "key": "ID",
          "doc_count": 27
        },
        ...,
        {
          "key": "MO",
          "doc_count": 20
        }
      ]
    }
  }
}
 
--------------------------------------------------
 
按state分组,统计每个state的平均工资,并降序排序
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword",
        "order": {
          "average_balance": "desc"
        }
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}'
 
-------------------------------------------------
按年龄段分组,然后按性别分组,统计每个年龄段中不同性别的平均工资
curl -XPOST http://192.168.0.128:9200/bank/_search -d
'{
 "size": 0,
 "aggs": {
   "group_by_age": {
     "range": {
       "field": "age",
       "ranges": [
         {
           "from": 20,
           "to": 30
         },
         {
           "from": 30,
           "to": 40
         },
         {
           "from": 40,
           "to": 50
         }
       ]
     },
     "aggs": {
       "group_by_gender": {
         "terms": {
           "field": "gender.keyword"
         },
         "aggs": {
           "average_balance": {
             "avg": {
               "field": "balance"
             }
           }
         }
    
     }
   }
 }
}'
```
