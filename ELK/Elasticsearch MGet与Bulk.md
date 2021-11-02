MGet(Multi Get)与Bulk 都是ES里的批量操作。可降低多次请求的网络开销，提升性能。

**MGet:** 一次请求查询多个文档。

**Bulk:** 一次请求执行多次index、create、update、delete操作。

# MGet

注意:
- mget API 需要一个docs数组。
- 数组的每一项包含_index、_type、_id。同一Index下，_index可以省略;同一Index，同一Type下，_index、_type都可省略。
- _source参数:指定只需要返回的字段。
- 一次mget请求，一次响应，响应返回一个docs数组，响应docs数组中的顺序与请求docs数组中的顺序相同，找到文档标记为found:true，没有找到found:false。

## MGet-不同Index
```
GET _mget
{
  "docs":[
      {
        "_index": "bank",
        "_type": "account",
        "_id": "25",
        "_source":["account_number","balance"]
      },
      {
        "_index": "user_logs",
        "_type": "recharge_log",
        "_id": "sMjgkmUBc0eBrlTlqYGw",
        "_source": ["uid","country","money"]
      },
      {
        "_index": "my_index",
        "_type": "my_type",
        "_id": "1"
      },
      {
        "_index": "my_index",
        "_type": "my_type",
        "_id": "10"
      }
   ]
}
```

## MGet-同一Index 不同Type
```
GET user_logs/_mget
{
  "docs":[
      {
        "_type": "recharge_log",
        "_id": "sMjgkmUBc0eBrlTlqYGw",
        "_source": ["uid","country","money"]
      },
      {
        "_type": "browse_log",
        "_id": "1",
        "_source": ["uid","page"]
      }
   ]
}
```

## MGet-同一Index 同一Type
```
GET user_logs/recharge_log/_mget?_source=uid,country,money
{
  "docs":[
   {"_id":"sMjgkmUBc0eBrlTlqYGw"},
   {"_id":"ssjgkmUBc0eBrlTlqYGw"},
   {"_id":"tsjgkmUBc0eBrlTlqYGx"}
   ]
}

#简化版
GET user_logs/recharge_log/_mget?_source=uid,country,money
{
  "ids":["sMjgkmUBc0eBrlTlqYGw","ssjgkmUBc0eBrlTlqYGw","tsjgkmUBc0eBrlTlqYGx"]
}
```

# Bulk

## Bulk可以执行的操作:
- index: 相当于PUT index/type/id，id不存在则创建，id存在则全量替换。
- create: 相当于PUT index/type/id/_create，id不存在则创建，id存在则创建失败。
- update: 相当于POST index/type/id/_update，id不存在则更新失败，id存在则部分更新。
- delete: 相当于DELETE index/type/id。

## Bulk语法
Bulk API对语法有严格要求，每行一条json，行与行之间必须有一个换行。

每个操作由两行json组成:一行action+元数据，另一行数据。注意:delete操作，只有action+元数据一行。

bulk操作中，任意一个操作失败，是不会影响其他操作的，但是在返回结果里，会告诉你异常日志。
```
#index
{"index": {"metadata"}} 
{"data"} 
{"index": {"metadata"}} 
{"data"}
#create
{"create": {"metadata"}} 
{"data"}
{"create": {"metadata"}} 
{"data"}
#update
{"update": {"metadata"}} 
{"data"}
...
#delete
{"delete": {"metadata"}} 
{"delete": {"metadata"}}
```

## Bulk 一次请求 多次操作
```
POST _bulk
{ "index" : { "_index" : "test_index", "_type" : "test_type", "_id" : "1" } }
{ "uid":1,"age":21}
{ "index" : { "_index" : "test_index", "_type" : "test_type", "_id" : "2" } }
{ "uid":2,"age":22}
{ "create" : { "_index" : "test_index", "_type" : "test_type", "_id" : "3" } }
{ "uid":3,"age":23}
{ "create" : { "_index" : "test_index", "_type" : "test_type", "_id" : "3" } }
{ "uid":3,"age":23}
{ "update" : {"_index" : "test_index", "_type" : "test_type", "_id" : "3"} }
{ "doc" : {"age" : 33} }
{ "delete" : { "_index" : "test_index", "_type" : "test_type", "_id" : "1" }}
{ "delete" : { "_index" : "test_index", "_type" : "test_type", "_id" : "5" }}

#返回结果
{
  "took": 2611,
  "errors": true,
  "items": [
    {
      "index": {
        "_index": "test_index",
        "_type": "test_type",
        "_id": "1",
        "_version": 1,
        "result": "created",
        "_shards": {
          "total": 2,
          "successful": 1,
          "failed": 0
        },
        "_seq_no": 0,
        "_primary_term": 1,
        "status": 201
      }
    },
    {
      "index": {
        "_index": "test_index",
        "_type": "test_type",
        "_id": "2",
        "_version": 1,
        "result": "created",
        "_shards": {
          "total": 2,
          "successful": 2,
          "failed": 0
        },
        "_seq_no": 0,
        "_primary_term": 1,
        "status": 201
      }
    },
    {
      "create": {
        "_index": "test_index",
        "_type": "test_type",
        "_id": "3",
        "_version": 1,
        "result": "created",
        "_shards": {
          "total": 2,
          "successful": 1,
          "failed": 0
        },
        "_seq_no": 0,
        "_primary_term": 1,
        "status": 201
      }
    },
    {
      "create": {
        "_index": "test_index",
        "_type": "test_type",
        "_id": "3",
        "status": 409,
        "error": {
          "type": "version_conflict_engine_exception",
          "reason": "[test_type][3]: version conflict, document already exists (current version [1])",
          "index_uuid": "6rtZl28FQDiK0WezcPgXZA",
          "shard": "4",
          "index": "test_index"
        }
      }
    },
    {
      "update": {
        "_index": "test_index",
        "_type": "test_type",
        "_id": "3",
        "_version": 2,
        "result": "updated",
        "_shards": {
          "total": 2,
          "successful": 1,
          "failed": 0
        },
        "_seq_no": 1,
        "_primary_term": 1,
        "status": 200
      }
    },
    {
      "delete": {
        "_index": "test_index",
        "_type": "test_type",
        "_id": "1",
        "_version": 2,
        "result": "deleted",
        "_shards": {
          "total": 2,
          "successful": 1,
          "failed": 0
        },
        "_seq_no": 1,
        "_primary_term": 1,
        "status": 200
      }
    },
    {
      "delete": {
        "_index": "test_index",
        "_type": "test_type",
        "_id": "5",
        "_version": 1,
        "result": "not_found",
        "_shards": {
          "total": 2,
          "successful": 1,
          "failed": 0
        },
        "_seq_no": 0,
        "_primary_term": 1,
        "status": 404
      }
    }
  ]
}
```
