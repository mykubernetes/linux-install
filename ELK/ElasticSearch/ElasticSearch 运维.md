## 查看节点详细信息 参数说明：v 显示表头 h 需要显示的字段（支持通配符） s 排序字段
```
curl 'http://localhost:9200/_cat/nodes?v&h=name,ip,version,jdk,disk.total,disk.used,disk.avail,disk.used_percent,heap.current,heap.percent,heap.max,ram.current,ram.percent,ram.max,master'
curl 'http://localhost:9200/_cat/nodes?v&h=name,ip,jdk,disk.total,disk.used,disk.used_percent,heap.current,heap.percent,heap.max,ram.current,ram.percent,ram.max,master,cpu,load_*'
curl -s 'http://localhost:9200/_cat/nodes?v&h=name,ip,jdk,cpu,disk*,heap*,ram*,load_*&s=name'
```

# 缓存查询
```
curl -s 'localhost:9200/_cat/nodes?v&h=http,*memory_size'
```

# 查询节点 uptime 
```
curl -s 'http://localhost:9200/_cat/nodes?v&h=name,ip,cpu,disk*,load*,uptime'
name     ip              cpu  disk.total disk.used disk.avail disk.used_percent load_1m load_5m load_15m uptime
node01   192.168.101.66  0    984.1gb    59.8gb    924gb      6.08              0.00    0.01    0.05     58d
node02   192.168.101.66  0    984.1gb    59.8gb    924gb      6.08              0.11    0.04    0.05     58d
node03   192.168.101.66  0    984.1gb    59.8gb    924gb      6.08              0.00    0.01    0.05     58d
```

# 手动设置当前副本数设定
```
curl -s -XPUT 'http://localhost:9200/_settings' -H 'Content-Type: application/json' --data '{"number_of_replicas" : 0}'
```

# 手动设置指定索引的副本数设定
```
curl -s -XPUT localhost:9200/test/_settings?pretty -H 'Content-Type: application/json' --data '{"index" : {"number_of_replicas" : 0}}'
```

# 查看分片信息
```
curl -XGET 'http://localhost:9200/_cat/shards?v'
curl -s 'localhost:9200/_cat/shards' | grep UNASSIGNED
```

# 查看分片未分配原因
```
curl --location --request GET http://localhost:9200/_cluster/allocation/explain?pretty
```

# 查看指定分片未分配原因
```
curl -XGET 'http://localhost:9200/_cluster/allocation/explain?pretty' \
-u rio:ee06167bsdrtx177f60766dsdiosdisk \
-H 'Content-Type: application/json' \
-d '{"index": "log-2020.11.28","shard":0,"primary":false}'
```

# 触发未分配分片重新分配
```
curl -XPOST localhost:9200/_cluster/reroute?retry_failed=true
```

# 查看 pipeline信息
```
pipeline_id=sgaccess
curl --location --request GET http://rio.tencent.com:9200/_ingest/pipeline/${sgaccess}
```

# 索引缓存清理
```
默认60%已经很大了,就是说一次请求的数据量不能太大，要么增大内存要么清理缓存。可以先清理下cache:
https://www.elastic.co/guide/e ... .html

清理fileddata cache方式为： 
curl -XPOST 'http://localhost:9200/${index_name}/_cache/clear?fielddata=true'

另外可以调用UPDATE _cluster/settings设置indices.fielddata.cache.size参数限制fileddata缓存不能太大
```

# 动态修改最小master节点数
```
curl -XPUT -u root:changeme "http://172.16.16.5:9201/_cluster/settings?pretty" -d' 
{
    "persistent":{
        "discovery.zen.minimum_master_nodes":"4"
    }
}'
```

# 查看集群当前应用的配置信息（包含默认配置值）
```
curl -XGET -s 'http://localhost:9200/_cluster/settings?include_defaults&pretty' | grep include_relocations

## 该示例默认是true，意味着es在计算一个node的磁盘使用率的时候，会考虑正在分配给这个node的shard
```

# 查看白名单列表
```
curl -u root:changeme -XGET http://127.0.0.1:9201/_auth/hosts?pretty
```

# 添加白名单
```
curl -XPUT <ctsdb-ip>:9201/_auth/host/<ip>
```
