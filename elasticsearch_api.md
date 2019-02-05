使用curl命令操作elasticsearch
=============================
一、使用_cat系列  
_cat系列提供了一系列查询elasticsearch集群状态的接口。  
```
curl -XGET localhost:9200/_cat
获取所有_cat系列的操作
=^.^=
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
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
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
```  
你也可以后面加一个v，让输出内容表格显示表头  
```
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
pretty=true表示格式化输出
level=indices 表示显示索引状态
level=shards 表示显示分片信息
```  
2、显示集群系统信息，包括CPU JVM等等  
``` curl -XGET localhost:9200/_cluster/stats?pretty=true ```

3、集群的详细信息。包括节点、分片等。  
``` curl -XGET localhost:9200/_cluster/state?pretty=true ```  

4、获取集群堆积的任务  
``` curl -XGET localhost:9200/_cluster/pending_tasks?pretty=true ```  

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
``` curl -XPOST ‘localhost:9200/_cluster/reroute’ -d ‘xxxxxx’ ```

7、关闭节点  
关闭指定192.168.1.1节点  
```
curl -XPOST ‘http://192.168.1.1:9200/_cluster/nodes/_local/_shutdown’
curl -XPOST ‘http://localhost:9200/_cluster/nodes/192.168.1.1/_shutdown’
```  
关闭主节点  
```  curl -XPOST ‘http://localhost:9200/_cluster/nodes/_master/_shutdown’ ```  
关闭整个集群  
```
$ curl -XPOST ‘http://localhost:9200/_shutdown?delay=10s’
$ curl -XPOST ‘http://localhost:9200/_cluster/nodes/_shutdown’
$ curl -XPOST ‘http://localhost:9200/_cluster/nodes/_all/_shutdown’
delay=10s表示延迟10秒关闭
```  
三、使用_nodes系列  
1、查询节点的状态  
```
curl -XGET ‘http://localhost:9200/_nodes/stats?pretty=true’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2/stats?pretty=true’
curl -XGET ‘http://localhost:9200/_nodes/process’
curl -XGET ‘http://localhost:9200/_nodes/_all/process’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/jvm,process’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/info/jvm,process’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/_all
curl -XGET ‘http://localhost:9200/_nodes/hot_threads
```  
四、使用索引操作  
1、获取索引  
``` curl -XGET ‘http://localhost:9200/{index}/{type}/{id}’ ```  
2、索引数据  
``` curl -XPOST ‘http://localhost:9200/{index}/{type}/{id}’ -d'{“a”:”avalue”,”b”:”bvalue”}’ ```  
3、删除索引  
``` curl -XDELETE ‘http://localhost:9200/{index}/{type}/{id}’ ```  
4、设置mapping  
```
curl -XPUT http://localhost:9200/{index}/{type}/_mapping -d '{
  "{type}" : {
	"properties" : {
	  "date" : {
		"type" : "long"
	  },
	  "name" : {
		"type" : "string",
		"index" : "not_analyzed"
	  },
	  "status" : {
		"type" : "integer"
	  },
	  "type" : {
		"type" : "integer"
	  }
	}
  }
}'
```  
5、获取mapping  
``` curl -XGET http://localhost:9200/{index}/{type}/_mapping ```  
6、搜索  
```
curl -XGET 'http://localhost:9200/{index}/{type}/_search' -d '{
    "query" : {
        "term" : { "user" : "kimchy" } //查所有 "match_all": {}
    },
	"sort" : [{ "age" : {"order" : "asc"}},{ "name" : "desc" } ],
	"from":0,
	"size":100
}
curl -XGET 'http://localhost:9200/{index}/{type}/_search' -d '{
    "filter": {"and":{"filters":[{"term":{"age":"123"}},{"term":{"name":"张三"}}]},
	"sort" : [{ "age" : {"order" : "asc"}},{ "name" : "desc" } ],
	"from":0,
	"size":100
}
```  
