# 一、开启ES集群慢查询

三种方式https://www.elastic.co/guide/...

## 方式1、在elasticsearch.yml文件中添加相关配置（需重启节点生效）
```
**#查询慢日志**
index.search.slowlog.threshold.query.warn: 10s
index.search.slowlog.threshold.query.info: 5s
index.search.slowlog.threshold.query.debug: 2s
index.search.slowlog.threshold.query.trace: 500ms
index.search.slowlog.threshold.fetch.warn: 1s
index.search.slowlog.threshold.fetch.info: 800ms
index.search.slowlog.threshold.fetch.debug: 500ms
index.search.slowlog.threshold.fetch.trace: 200ms
index.search.slowlog.level: info
**#写过程慢日志**
index.indexing.slowlog.threshold.index.warn: 10s
index.indexing.slowlog.threshold.index.info: 5s
index.indexing.slowlog.threshold.index.debug: 2s
index.indexing.slowlog.threshold.index.trace: 500ms
index.indexing.slowlog.level: info
index.indexing.slowlog.source: 1000
```

## 方式2、执行API动态修改某些索引的慢查询日志
```
PUT /my-index-000001/_settings 
{ 
 "index.search.slowlog.threshold.query.warn": "10s",
 "index.search.slowlog.threshold.query.info": "5s", 
 "index.search.slowlog.threshold.query.debug": "2s",
 "index.search.slowlog.threshold.query.trace": "500ms",
 "index.search.slowlog.threshold.fetch.warn": "1s",
 "index.search.slowlog.threshold.fetch.info": "800ms",
 "index.search.slowlog.threshold.fetch.debug": "500ms",
 "index.search.slowlog.threshold.fetch.trace": "200ms",
 "index.search.slowlog.level": "info"
 "index.indexing.slowlog.threshold.index.warn": "10s",
 "index.indexing.slowlog.threshold.index.info": "5s",
 "index.indexing.slowlog.threshold.index.debug": "2s",
 "index.indexing.slowlog.threshold.index.trace": "500ms",
 "index.indexing.slowlog.level": "info",
 "index.indexing.slowlog.source": "1000" 
}
```

## 方式3、在template的settings中设置慢查询配置
```
PUT _template/us_data 
{ 
  "order": 5,
  "index_patterns": ["*"], 
  "settings": { 
  "index": {
    "lifecycle": {
      "name": "ilm_elk"
    },
    "codec": "best_compression",
    "routing": {
      "allocation": {
        "total_shards_per_node": "1"
      }
    },
    "search": {
      "slowlog": {
        "level": "info",
        "threshold": {
          "fetch": {
            "warn": "2s",
            "debug": "800ms",
            "info": "1s"
          },
          "query": {
            "warn": "10s",
            "debug": "2s",
            "info": "5s"
          }
        }
      }
    },
    "refresh_interval": "50s",
    "indexing": {
      "slowlog": {
        "level": "info",
        "threshold": {
          "index": {
            "warn": "10s",
            "debug": "2s",
            "info": "5s"
          }
        },
        "source": "2000"
      }
    },
    "number_of_shards": "1",
    "translog": {
      "flush_threshold_size": "2gb",
      "sync_interval": "120s",
      "durability": "async"
    },
    "merge": {
      "scheduler": {
        "max_thread_count": "2"
      }
    },
    "unassigned": {
      "node_left": {
        "delayed_timeout": "30m"
      }
    },
    "number_of_replicas": "1"
  }
    }, 
  "mappings": {}, 
  "aliases": {} 
}
```

# 二、使用filebeat收集慢查询日志到ES

# 三、使用kibana可视化慢查询日志
