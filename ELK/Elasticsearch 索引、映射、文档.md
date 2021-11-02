# 索引
- 索引(index)就像是传统关系数据库中的数据库。

# 创建索引
- 创建索引时可以通过设置number_of_shards和number_of_replicas来指定主分片和每个主分片对应副本分片的数量。

注意：主分片数一旦设置，后期不能修改。
```
PUT user_info
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  }
}
```

# 查看索引
```
GET user_info

GET user_info/_settings
GET user_info/_mapping
GET user_info/_alias
```

# 修改索引
```
#增加副本数
PUT user_info/_settings
{
  "number_of_replicas": 5
}
```

# 索引是否存在
```
#存在返回200 不存在返回404
HEAD user_info
```

# 打开关闭索引
```
#关闭索引
#注意:被关闭的索引，不能读写数据，只能读写元数据。
POST user_info/_close

#打开索引
POST user_info/_open
```

# 删除索引
```
DELETE user_info
```

# 拷贝索引
```
# 这里将索引user_info中的数据拷贝至索引user_info5
# 注意：索引user_info5不必提前创建。
POST _reindex
{
  "source": {"index": "user_info"},
  "dest": {"index": "user_info5"}
}

#结果
#took：从开始到结束整个过程的毫秒数
#updated：已成功更新的文档数
#created：已成功创建的文档数
#version_conflicts：版本冲突的数量

{
  "took": 499,
  "timed_out": false,
  "total": 3,
  "updated": 0,
  "created": 3,
  "deleted": 0,
  "batches": 1,
  "version_conflicts": 0,
  "noops": 0,
  "retries": {
    "bulk": 0,
    "search": 0
  },
  "throttled_millis": 0,
  "requests_per_second": -1,
  "throttled_until_millis": 0,
  "failures": []
}
```

# 索引统计
- 统计某个索引的文档数、大小、translog等。
```
GET user_info/_stats
```

# 查看索引主分片和副本分片位置信息
```
#默认显示red和yellow状态的分片
GET user_info/_shard_stores

#查看是yellow状态的分片
GET user_info/_shard_stores?status=yellow
```

# 查看正在恢复的索引分片
```
GET user_info/_recovery?pretty&human

#id：shard id
#type：恢复类型，如快照、存储
#stage：恢复状态
#primary：是否是主分片
#start_time/start_time_in_millis：开始时间
#stop_time/stop_time_in_millis：结束时间
#total_time/total_time_in_millis：总耗时
#source：恢复源，如快照等
#target：目标节点
#index：恢复索引的统计数据
#translog：translog统计数据
...

 {
        "id": 0,
        "type": "EXISTING_STORE",
        "stage": "DONE",
        "primary": true,
        "start_time": "2018-08-25T14:00:02.194Z",
        "start_time_in_millis": 1535205602194,
        "stop_time": "2018-08-25T14:00:02.263Z",
        "stop_time_in_millis": 1535205602263,
        "total_time": "69ms",
        "total_time_in_millis": 69,
        "source": {},
        "target": {
          "id": "ud0sXQP2THqu-Jv68JEZyA",
          "host": "node2",
          "transport_address": "192.168.113.102:9300",
          "ip": "192.168.113.102",
          "name": "data-1"
        },
        "index": {
          "size": {
            "total": "230b",
            "total_in_bytes": 230,
            "reused": "230b",
            "reused_in_bytes": 230,
            "recovered": "0b",
            "recovered_in_bytes": 0,
            "percent": "100.0%"
          },
          "files": {
            "total": 1,
            "reused": 1,
            "recovered": 0,
            "percent": "100.0%"
          },
          "total_time": "0s",
          "total_time_in_millis": 0,
          "source_throttle_time": "-1",
          "source_throttle_time_in_millis": 0,
          "target_throttle_time": "-1",
          "target_throttle_time_in_millis": 0
        },
        "translog": {
          "recovered": 0,
          "total": 0,
          "percent": "100.0%",
          "total_on_start": 0,
          "total_time": "52ms",
          "total_time_in_millis": 52
        },
        "verify_index": {
          "check_index_time": "0s",
          "check_index_time_in_millis": 0,
          "total_time": "0s",
          "total_time_in_millis": 0
        }
      }

...
```

# 查看索引分段segment
```
GET user_info/_segments

#_0：segment名。
#num_docs：segment中没被删除的文档数
#deleted_docs：已被标记为删除的文档数
#size_in_bytes：占用的磁盘空间
#committed：该segment是否已持久化到磁盘
#search：该segment是否可以被搜索了
#version：操作这个segment的Lucene版本

...

 "_0": {
                "generation": 0,
                "num_docs": 1,
                "deleted_docs": 0,
                "size_in_bytes": 3244,
                "memory_in_bytes": 1249,
                "committed": true,
                "search": true,
                "version": "7.2.1",
                "compound": true,
                "attributes": {
                  "Lucene50StoredFieldsFormat.mode": "BEST_SPEED"
                }

...
```

# 清除索引缓存
```
#清楚所有缓存
POST user_info/_cache/clear

#清楚特定缓存
POST user_info/_cache/clear?request=true

POST user_info/_cache/clear?query=true

POST user_info/_cache/clear?field_data=true
```

# 手动刷新索引

- 刷新索引，使之前最后一次刷新之后的所有操作被执行。

默认，ES内部会自动触发。
```
POST user_info/_refresh
```

# 手动flush冲洗索引

- flush冲洗索引会将数据持久化到磁盘并且清除translog日志，释放内存缓存buffer。

默认，ES内部会自动触发。
```
POST user_info/_flush
```

# 手动合并索引

- 手动合并索引，减少segment数量。

注意：合并的过程中，请求会被阻塞，直到合并完成。
```
#max_num_segments：用于合并的分片数量。为了充分合并，设置为1。
#flush：合并完成后是否执行冲洗。默认true。

POST user_info/_forcemerge
{
  "max_num_segments":1,
  "flush": true
}
```

# 索引别名

- 别名类似于数据库中的视图。

### 增加索引别名

- 一个别名指向一个索引
```
#这里，为索引user_info增加一个别名
#查询的数据为年龄在[15,20]之间的用户
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "user_info",
        "alias": "alias_user_info",
        "filter": {
          "range": {
            "age": {
              "gte": 15,
              "lte": 20
            }
          }
        }
      }
    }
  ]
}
```

- 一个别名指向多个索引
```
#一个别名指向多个索引
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "user_info",
        "alias": "alias1"
      }
    },
    {
      "add": {
        "index": "user_info2",
        "alias": "alias1"
      }
    }
  ]
}

或

POST _aliases
{
  "actions": [
    {
      "add": {
        "indices": [
          "user_info",
          "user_info2"
        ],
        "alias": "alias2"
      }
    }
  ]
}
```
- 用通配符，一个别名指向多个索引

注意：通配符指定的索引只对当前存在的索引生效，后期添加的不会被自动添加到别名上。
```
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "user_info*",
        "alias": "alias3"
      }
    }
  ]
}
```

### 删除索引别名
```
#删除索引别名
POST _aliases
{
  "actions": [
    {
      "remove": {
        "index": "user_info",
        "alias": "alias1"
      }
    }
  ]
}

或

DELETE user_info/_alias/alias1
```

### 修改索引别名

- 注意：索引别名没有修改语法，若要修改，可以先删除别名，再增加别名

```
#修改索引别名：先删除，再增加
POST _aliases
{
  "actions": [
    {
      "remove": {
        "index": "user_info",
        "alias": "alias3"
      }
    },
    {
      "add": {
        "index": "user_info",
        "alias": "alias4"
      }
    }
  ]
}
```

### 查询索引别名
```
GET user_info*/_alias
```

### 判断索引别名是否存在
```
#存在返回200 不存在返回404
HEAD user_info/_alias/alias*
HEAD user_info/_alias/alias_user_info
```

# 索引模板

- 索引模板：定义好了一类索引的setting和mapping。

- 如Logstash、filebeat把数据按天入ES并按天建索引，就可以指定索引的模板。

### 创建索引模板

- 创建索引模板，就是要定义好这个模板适用的索引(index_patterns)、setting和mapping。
```
PUT _template/template_user_info
{
  "index_patterns": [
    "user_info*"
  ],
  "settings": {
    "number_of_shards": 3
  },
  "mappings": {
    "user": {
      "properties": {
        "name": {
          "type": "keyword"
        },
        "updated_at": {
          "type": "date",
          "format": "epoch_millis"
        }
      }
    }
  }
}
```

### 查看索引模板
```
GET _template/template_user_info
```

### 删除索引模板
```
DELETE _template/template_user_info
```

### 判断索引模板是否存在
```
#存在返回200 不存在返回404
HEAD _template/template_user_info
```

### 多索引模板匹配问题

- 如果一个索引同时匹配到了多个模板。配置不同，则合并；配置相同，则按模板中指定的order顺序，order大的会覆盖小的。

- 在用Logstash、filebeat向ES中，如果指定了模板，则要注意这个问题。

# 映射

- 映射(mapping)定义了每个字段的数据类型，字段使用的分词器等。

- 动态映射：字段数据类型不需要事先定义，ES内部自动映射默认字段类型。

### 创建映射
```
#给已知索引user_info增加映射
#字符串类型：同一个字段可以同时有text和keyword两种类型。text类型用于全文检索，keyword类型用于不分词查询、聚合排序。如下:nick_name字段。
#日期类型：同一字段可指定多种日期格式。如下:updated_at字段。
#JSON数组类型：ES中没有专门数组类型。在插入数据时直接使用即可。
#JSON对象类型：如下:name字段。

PUT user_info/_mapping/user
{
  "properties": {
    "name": {
      "properties": {
        "first_name": {
          "type": "text"
        },
        "last_name": {
          "type": "text"
        }
      }
    },
    "nick_name": {
      "type": "text",
      "fields": {
        "keyword": {
          "type": "keyword"
        }
      }
    },
    "age": {
      "type": "integer"
    },
    "gender": {
      "type": "integer"
    },
    "updated_at": {
      "type": "date",
      "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
    }
  }
}
```

### 查看映射
```
GET user_info/_mapping
```

### 修改映射
```
#增加字段
PUT user_info/_mapping/user
{
  "properties": {
    "address":{
      "type": "text"
    }
  }
}
```

### 映射是否存在
```
#存在返回200 不存在返回404
HEAD user_info/_mapping/user
```

# 文档

- 文档(document)就像是传统关系数据库中的一条记录。

### 增加文档

- 增加文档时，如果索引不存在，则会自动创建索引。自动创建的索引会被ES自动映射每个字段类型。

- 增加文档有两种方式：强制创建、尝试创建

### 强制创建
```
#增加文档，不存在则创建，存在则替换
PUT user_info_test/user/1
{
  "name":"name1",
  "age":20
}
```

### 尝试创建
```
#增加文档，不存在则创建，存在则创建失败。
#创建失败返回状态码 409。
PUT user_info_test/user/1/_create
{
  "name":"name1",
  "age":20
}
```

### 更新文档

- 更新文档有两种方式：全量更新和部分更新。

- 二者原理都类似，都是先把原文档标记为删除，然后再创建新文档。但全量更新需要把每个字段都带上，增加了网络传输。

### 全量更新
```
#只想更新age字段时，需要把所有字段都带上。
PUT user_info_test/user/1
{
  "name":"name1",
  "age":30
}
```

### 部分更新
```
#只想更新age字段时，只需要带上age字段即可。
POST user_info_test/user/1/_update
{
  "doc": {
    "age":40
  }
}
```

### 删除文档
```
DELETE user_info_test/user/1
```

### 查询文档
```
#返回所有字段
GET user_info_test/user/1

#不返回_source
GET user_info_test/user/1?_source=false

#只返回_source,不返回文档元数据字段如_index、_type、_id、_version
GET user_info_test/user/1/_source

#只返回_source中指定字段
GET user_info_test/user/1?_source_includes=age
GET user_info_test/user/1?_source_excludes=age
```
