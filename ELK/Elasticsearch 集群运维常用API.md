# 一、调整节点磁盘水位线

https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-cluster.html#disk-based-shard-allocation

## 1、ES默认会根据data节点磁盘使用空间情况分配新shards，或将节点上已有shards迁移到其它节点上；

- cluster.routing.allocation.disk.watermark.low：意味着ES不会为磁盘使用率超过此值的节点分配新shards，支持动态调整，默认85%或；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.disk.watermark.low":"85%"}}'
```

- cluster.routing.allocation.disk.watermark.high：意味着ES会为磁盘使用率超过此值的节点迁出shards或重分配shards，支持动态调整，默认90%；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.disk.watermark.high":"90%"}}'
```

- cluster.routing.allocation.disk.watermark.flood_stage：意味着ES会对磁盘使用率超过此值的节点上的所有索引设置只读（index.blocks.read_only_allow_delete），拒绝新数据写入，支持动态调整，默认95%。
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.disk.watermark.flood_stage":"95%"}}'
```

## 2、以上3个控制节点磁盘使用率的参数也支持将百分比值修改成磁盘空间剩余的绝对值，API如下
```
PUT _cluster/settings 
{ 
"transient": { 
  "cluster.routing.allocation.disk.watermark.low": "100gb",
  "cluster.routing.allocation.disk.watermark.high": "50gb",
  "cluster.routing.allocation.disk.watermark.flood_stage": "10gb"
} 
}
```

# 二、集群中Shards分配与恢复

https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-cluster.html#cluster-shard-allocation-settings

## 1、cluster.routing.allocation.enable：控制shards分配规则，默认all，需要快速重启data节点的情况下建议将值设置为none；

- all：允许分配集群中所有的分片；
- none：不允许分片集群中所有的分片；
- primaries：只允许分配集群中索引的新分片；
- new_primaries：只允许分配集群中新索引的主分片；

```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.enable":"all"}}'
```

## 2、分片恢复

- cluster.routing.allocation.node_concurrent_incoming_recoveries：分片恢复过程中单节点允许多少并发分片传入数，默认2；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.node_concurrent_incoming_recoveries":"2"}}'
```

- cluster.routing.allocation.node_concurrent_outgoing_recoveries：分片恢复过程中单节点允许多少并发分片传出数，默认2；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.node_concurrent_outgoing_recoveries":"2"}}'
```

- cluster.routing.allocation.node_concurrent_recoveries：同时设置分片传入与传出的并发数；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.node_concurrent_recoveries":"4"}}'
```

- indices.recovery.max_bytes_per_sec：设置恢复过程中节点间每秒传输速率，默认40mb，如果主机网卡及磁盘IO配置高，可以适当调高此值，以提高分片恢复速率；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"indices.recovery.max_bytes_per_sec":"40mb"}}'
```

- cluster.routing.allocation.node_initial_primaries_recoveries: ES7.9 设置分片恢复速率；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.node_initial_primaries_recoveries":"10"}}'
```

## 3、控制分片分配到单个data节点的数量

- index.routing.allocation.total_shards_per_node：控制indices的分片分配到单个节点的分片数；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/indices_test/_settings -d '{"index.routing.allocation.total_shards_per_node":"3"}'
```

- cluster.routing.allocation.total_shards_per_node：控制集群中所有分片分配到单个节点的分片数，不常用。
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.max_shards_per_node":2000
  }
}
```

- cluster.max_shards_per_node：控制集群中每个data节点上的分片数量，默认1000
```
PUT _cluster/settings 
{ 
    "transient" : { 
        "cluster.routing.allocation.exclude._ip" : "10.0.0.1"     } 
}
```

- action.search.shard_count.limit：控制一次查询覆盖的shards数量
```
{
    "persistent" : {
        "action.search.shard_count.limit" : "800"
    }
}
```
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.exclude._ip":"127.0.0.1"}}'
```

## 4、手动执行集群分片重平衡
```
POST /_cluster/reroute?retry_failed=true
```
添加参数
- explain：如果使用?explain查询参数，则返回结果会包含一个为什么可以执行或者为什么不能执行的解释信息；
- retry_failed：如果使用?retry_failed查询参数，则将尝试对之前分配失败的分片重试一次分配；
- timeout：等待响应的超时时间，如果超时则请求失败并返回错误，默认30s。

手动迁移分片API
```
POST /_cluster/reroute
{
 "commands" : [
  {
   "move" : {
    "index" : "apm-7.4.0-prod-3-2021.04.14", 
    "shard" : 1,
    "from_node" : "es-cn-n6w24rnm500dh5ljz-74a4d33e-0002", 
    "to_node" : "es-cn-n6w24rnm500dh5ljz-74a4d33e-0001"
   }
  }
 ]
}
```

## 5、查看shard未分配原因
```
GET _cluster/allocation/explain?pretty
```

# 三、集群中Shards rebalance

https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-cluster.html#cluster-shard-allocation-filtering

## 1、cluster.routing.rebalance.enable：控制集群shards rebalance参数，默认all，需要快速重启节点的情况下建议将值设置为none；
- all：允许集群中所有shards进行rebalance；
- none：不允许集群中所有indices的shards进行rebalance；
- primaries：只允许集群中主shards进行rebalance；
- replicas：只允许集群中副本shards进行rebalance；

```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.rebalance.enable":"all"}}'
```

## 2、cluster.routing.allocation.cluster_concurrent_rebalance：允许集群中分片rebalance的并发数量，默认是2，集群扩容新data节点后通过调大此参数值让分片更快迁移到新节点上，快速达到集群分片Rebalance；
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.cluster_concurrent_rebalance":"2"}}'
```

## 3、调整分片分配策略
- cluster.routing.allocation.balance.index：倾向indices内分片平衡分配到各数据节点，默认0.55f
- cluster.routing.allocation.balance.shard：倾向集群所有分片平衡分配到各数据节点，默认0.45f
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.balance.index":"0.8f"}}'
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/_cluster/settings -d '{"transient" : {"cluster.routing.allocation.balance.shard":"0.2f"}}'
```

# 四、索引settings

## 1、调整索引分片数
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/indices_test/_settings -d '{"index":{"number_of_replicas" : 1}}'
```

## 2、调整索引refresh频率
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/indices_test/_settings -d '{"index":{"refresh_interval" : "30s"}}'
```

## 3、调整索引translog flush策略
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/indices_test/_settings -d '{"index":{"translog.durability" : "async","translog.flush_threshold_size":"1gb"}}'
```

## 4、设置每个节点上每个索引的分片（主+副本）数量，
```
curl -H 'Content-Type:application/json' -XPUT   http://127.0.0.1:9200/indices_test/_settings -d '{"index.routing.allocation.total_shards_per_node":5}'
```

# 五、reindex

## 1、集群内部reindex源索引到目标索引
```
POST _reindex?wait_for_completion=false
{
  "source": {
    "index": "indices_sour",
    "query": {"match_all": {}},
    "size": 2000
  },
  "dest": {
    "index": "indices_dest"
  }
}
```
## 2、从其它集群中reindex索引到本集群中
```
POST _reindex?wait_for_completion=false
{
  "source": {
    "remote": {
      "host": "",
      "username": "elastic",
      "password": "xxxxxx"
    }, 
    "index": "indices_sour",
    "query": {"match_all": {}},
    "size": 2000
  },
  "dest": {
    "index": "indices_dest"
  }
}
POST _reindex?wait_for_completion=false
{
  "source": {
    "index": "apm-7.4.0-prod-2021.04.14",
    "query": {
      "bool": {
      "must": [],
      "filter": [
        {
          "match_all": {}
        },
        {
          "range": {
            "@timestamp": {
              "gte": "2021-04-14T08:00:00.000Z",
              "lte": "2021-04-14T14:00:00.000Z",
              "format": "strict_date_optional_time"
            }
          }
        }
      ],
      "should": [],
      "must_not": []
      }
    },
    "size": 10000
  },
  "dest": {
    "index": "apm-7.4.0-prod-3-2021.04.14"
  }
}
```

## 3、查看reindex任务的进度
```
GET _tasks/reindex_id
```

# 六、template

## 1、创建index template
```
PUT _template/us_data 
{ 
    "order": 5,
    "index_patterns": ["*"], 
    "settings": { 
        "index": {
            "refresh_interval": "60s",
            "number_of_replicas": "1", 
            "translog": {
                "flush_threshold_size": "2gb", 
                "sync_interval": "120s",
                "durability": "async"
            }
        }
    }, 
    "mappings": {}, 
    "aliases": {} 
}
```

# 七、日志级别设置
```
PUT /_cluster/settings
{
  "transient":{
    "logger._root":"INFO"
  }
}
```

# 八、Snapshot

## 1、从已备份的快照中恢复indices
```
POST _snapshot/oss_bucket_name/snapshot_name/_restore?wait_for_completion=false
{
  "indices":"indices_name",
  "ignore_unavailable":"true",
  "index_settings": {
    "index.number_of_replicas": 0,
    "index.routing.allocation.total_shards_per_node":"10"
  },
  "include_global_state":false
}
```

## 2、注册快照仓库（NAS）
```
# ES配置文件elasticsearch.yml
path.repo: ["/esbackup/repo"]
curl -H 'Content-Type: application/json' -u 'elastic:123456' -XPUT http://127.0.0.1:9200/_snapshot/backup_repository -d '{"type": "fs","settings": {"location": "/esbackup/repo","compress": true}}'
```

## 3、注册快照仓库（S3或OSS）
```
1.安装插件
sudo bin/elasticsearch-plugin install repository-s3
wget https://artifacts.elastic.co/downloads/elasticsearch-plugins/repository-s3/repository-s3-7.8.0.zip
sudo bin/elasticsearch-plugin install file:///path/to/repository-s3-7.8.0.zip
2.在每个ES节点执行命令，添加AK、SK到ES中
bin/elasticsearch-keystore add s3.client.default.access_key
bin/elasticsearch-keystore add s3.client.default.secret_key
3. 重启ES生效以上配置
4. 创建快照仓库
curl -H 'Content-Type: application/json' -u 'elastic:123456' -XPUT 'http://127.0.0.1:9200/_snapshot/es_backup_oss_test' -d '{"type": "s3", "settings": { "bucket": "es-backup", "endpoint": "abc.aliyuncs.com"}}'
```

## 4、创建索引快照
```
curl -H 'Content-Type: application/json' -u 'elastic:123456' -XPUT 'http://127.0.0.1:9200/_snapshot/es_backup/snapshot-test' -d '{"indices":"indices_test_backup","ignore_unavailable": true,"include_global_state": false}'
```

# 九、discover（7之前版本）

## 1、更改ES集群minimum_master_nodes节点数量
```
PUT _cluster/settings
{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 1
    }
}
```

# 十、调整集群最大bucket数量

- ES 6版本时search.max_buckets参数默认无限制
- ES 7.0-7.8，search.max_buckets参数默认是10000
- ES 7.9 以后，search.max_buckets参数默认是65536

```
PUT _cluster/settings 
{ 
  "persistent": { 
    "search.max_buckets": "65536"
  } 
}
```

# 十一、打开自动创建索引
```
PUT _cluster/settings
{
  "persistent": {
    "action.auto_create_index":"true"
  }
}
```

# 十二、ES模板中索引别名设置
```
{
  "mldb": {}
}
```

# 十三、索引别名设置API
```
POST /_aliases
{
  "actions": [
    {"remove": {"index": "l1", "alias": "a1"}},
    {"add": {"index": "l1", "alias": "a2"}}
  ]
}
POST /_aliases
{
  "actions": [
    {"add": {"index": "l1", "alias": "a1"}},
    {"add": {"index": "l2", "alias": "a1"}},
    {"add": {"index": "l3", "alias": "a1"}}
  ]
}
```
```
POST /_aliases
{
  "actions": [
    {"add": {"indices": ["l1", "l2", "l3"], "alias": "a2"}}
  ]
}
```
```
POST /_aliases
{
  "actions": [
    {"add": {"index": "l1", "aliases": ["a1", "a2", "a3"]}}
  ]
}
```
```
POST /_aliases
{
  "actions": [
    {"add": {"index": "l*", "alias": "f1"}}
  ]
}
```

# 十四、设置聚合查询最大bucket数量
```
PUT _cluster/settings
{
  "transient": {
    "search.max_buckets": 20000
  }
}

curl -XPUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'{"persistent" : {"search.max_buckets": 20000}}'
```

# 十五、设置集群专有协调节点
```
node.master: false 
node.data: false 
node.ingest: false 
search.remote.connect: false 
```

# 十六、设置ES日志级别

```
# 设置根日志级别为DEBUG
PUT /_cluster/settings
{
  "transient":{
    "logger._root":"DEBUG"
  }
}

# 设置discover模块的日志级别是DEBUG
PUT _cluster/settings
{
  "transient": {
    "logger.discovery" : "DEBUG"  
  }
}

# 设置全局慢查询日志打印级别
PUT /_cluster/settings
{
    "transient" : {
        "logger.index.search.slowlog" : "DEBUG", 
        "logger.index.indexing.slowlog" : "WARN" 
    }
}

# 设置索引慢查询阈值
PUT /my_index/_settings
{
    "index.search.slowlog.threshold.query.warn" : "10s", 
    "index.search.slowlog.threshold.fetch.debug": "500ms", 
    "index.indexing.slowlog.threshold.index.info": "5s" 
}
```
