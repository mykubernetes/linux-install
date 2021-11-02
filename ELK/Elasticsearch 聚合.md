总结Elasticsearch三种聚合 Metrics Aggregations、Bucket Aggregations、Pipeline Aggregations中的常用聚合。

- Metrics Aggregations 度量聚合
  - 如Count、Sum、Min、Max、Avg、Count(Distinct)就是度量。
- Bucket Aggregations 分桶聚合
  - 如 Group by country,每个country就是一个桶，也可以叫做一个分组。可对每个分组内的数据进行聚合。
- Pipeline Aggregations 管道聚合
  - 管道聚合，基于现有的聚合结果，再进行聚合。

# 数据准备
```
创建索引
PUT user_logs
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  },
  "mappings": {
    "recharge_log": {
      "properties": {
        "uid": {
          "type": "keyword"
        },
        "name": {
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
        "country": {
          "type": "keyword"
        },
        "payTime": {
          "type": "date",
          "format": "yyyy-MM-dd HH:mm:ss"
        },
        "payWay": {
          "type": "integer"
        },
        "money": {
          "type": "integer"
        }
      }
    }
  }
}
```

# 插入数据
```
POST /user_logs/recharge_log/_bulk
{"index": {}}
{"uid": "1", "country": "US", "age": 26, "payWay": 2, "money": 30, "payTime": "2016-08-25 08:05:16", "name": "Rose petal"}
{"index": {}}
{"uid": "1", "country": "US", "age": 26, "payWay": 1, "money": 20, "payTime": "2016-08-26 08:05:16", "name": "Rose petal"}
{"index": {}}
{"uid": "1", "country": "US", "age": 26, "payWay": 1, "money": 30, "payTime": "2016-08-27 10:05:16", "name": "Rose petal"}
{"index": {}}
{"uid": "2", "country": "CN", "age": 23, "payWay": 2, "money": 20, "payTime": "2016-08-25 08:05:16", "name": "Belen Rose"}
{"index": {}}
{"uid": "2", "country": "CN", "age": 23, "payWay": 2, "money": 20, "payTime": "2016-08-26 08:05:16", "name": "Belen Rose"}
{"index": {}}
{"uid": "2", "country": "CN", "age": 23, "payWay": 1, "money": 20, "payTime": "2016-08-27 10:05:16", "name": "Belen Rose"}
{"index": {}}
{"uid": "3", "country": "CN", "age": 29, "payWay": 2, "money": 20, "payTime": "2016-08-25 08:05:16", "name": "Rose petal"}
{"index": {}}
{"uid": "3", "country": "CN", "age": 29, "payWay": 2, "money": 20, "payTime": "2016-08-26 08:05:16", "name": "Rose petal"}
{"index": {}}
{"uid": "3", "country": "CN", "age": 29, "payWay": 1, "money": 10, "payTime": "2016-08-27 10:05:16", "name": "Rose petal"}
```

# 只返回聚合结果
- 设置size=0,只返回聚合结果，不返回搜索结果。
```
#查询
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "avg_money": {
      "avg": {
        "field": "money"
      }
    }
  }
}

#返回
{
  "took": 5,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "avg_money": {
      "value": 21.11111111111111
    }
  }
}
```

# 同时返回聚合类型

- 添加typed_keys参数，在返回聚合结果时，可同时返回聚合类型。

如下avg#avg_money，在聚合名称(avg_money)前添加聚合类型(avg)前缀，并一并返回。
```
#查询
GET user_logs/recharge_log/_search?size=0&typed_keys
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "avg_money": {
      "avg": {
        "field": "money"
      }
    }
  }
}

#返回
{
  "took": 3,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "avg#avg_money": {
      "value": 21.11111111111111
    }
  }
}
```

# 度量聚合(Metric Agg)

## 值计数聚合(Value Count Aggregation)

计算查询结果中某字段值的数量。
```
#查询：文档总数
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "value_count_docs": {
      "value_count": {
        "field": "_id"
      }
    }
  }
}

#返回
{
  "took": 246,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "value_count_docs": {
      "value": 9
    }
  }
}
```

## 均值聚合(Avg Aggregation)

- 计算查询结果中某字段的均值。
```
#查询：平均充值金额=总充值金额/充值订单数
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "avg_money":{
      "avg": {
        "field": "money"
      }
    }
  }
}

#返回
{
  "took": 2,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "avg_money": {
      "value": 21.11111111111111
    }
  }
}
```

## 最小值聚合(Min Aggregation)

- 计算查询结果中某字段的最小值。
```
#查询：最小充值金额
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "min_money":{
      "min": {
        "field": "money"
      }
    }
  }
}

#返回
{
  "took": 11,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "min_money": {
      "value": 10
    }
  }
}
```

## 最大值聚合(Max Aggregation)

- 计算查询结果中某字段的最大值。
```
#查询：单笔充值最高值
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "max_money":{
      "max": {
        "field": "money"
      }
    }
  }
}

#返回
{
  "took": 3,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "max_money": {
      "value": 30
    }
  }
}
```

## 和聚合(Sum Aggregation)

- 计算查询结果中某字段值的总和。
```
#查询：总充值金额
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "sum_money":{
      "sum": {
        "field": "money"
      }
    }
  }
}

#返回
{
  "took": 12,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "sum_money": {
      "value": 190
    }
  }
}
```

## 去重计数聚合(Cardinality Aggregation)

计算查询结果中某字段值的去重计数。

去重计数聚合基于HyperLogLog++ 算法，这个算法基于散列值，可通过precision_threshold控制精度。

precision_threshold默认值3000，最大值40000。
```
#查询：充值uv
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "recharge_uv":{
      "cardinality": {
        "field": "uid",
        "precision_threshold": 40000
      }
    }
  }
}

#返回
{
  "took": 9,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "recharge_uv": {
      "value": 3
    }
  }
}
```

## 统计信息聚合(Stats Aggregation)

- 计算查询结果中某字段的统计数据。
```
#查询：充值金额统计
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "stats_money":{
      "stats": {
        "field": "money"
      }
    }
  }
}

#返回
{
  "took": 9,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "stats_money": {
      "count": 9,
      "min": 10,
      "max": 30,
      "avg": 21.11111111111111,
      "sum": 190
    }
  }
}
```

## 百分位数聚合(Percentiles Aggregation)

计算查询结果中某字段的百分位数。可用来评估字段值分布。

如用来评估请求SLA延迟是否达标。每条请求日志都包含请求延时字段，可以查看请求延时99百分位数，如果99百分位数的值在100ms以内则说明请求在100ms内响应的占比99%，SLA达标，否则SLA不达标。

如下，返回结果50.0:20，意味着，单笔充值金额在20以内的占比50%。

默认百分位数1,5,25,50,75,95,99。

注意：
- 百分位数也可通过numpy取得。如 print numpy.percentile(numpy.array([5,10,18]),99)
- 常用平均值度量，但平均值容易受异常最大最小值影响，

```
#查询：
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "percentiles_money":{
      "percentiles": {
        "field": "money",
        "percents": [
          50, 
          99
        ]
      }
    }
  }
}

#返回
{
  "took": 15,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "percentiles_money": {
      "values": {
        "50.0": 20, //单笔充值金额在20以内的占比50%
        "99.0": 30 //单笔充值金额在30以内的占比99%
      }
    }
  }
}
```

## 百分位数排名聚合(Percentile Ranks Aggregation)

- 计算查询结果中某字段值小于某个数的百分位数。

符：百分位数排名释义。
```
#查询
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "percentiles_rank_money":{
      "percentile_ranks": {
        "field": "money",
        "values": [
          20,
          30
        ]
      }
    }
  }
}

#返回
{
  "took": 21,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "percentiles_rank_money": {
      "values": {
        "20.0": 66.66666666666666, //单笔充值在20以内的占比66.66666666666666
        "30.0": 100 //单笔充值在30以内的占比100%
      }
    }
  }
}
```

## TopN聚合(Top Hits Aggregation)

- 计算查询结果中某字段值的TopN。
```
#查询：取充值最高的三条记录
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "top3_money": {
      "top_hits": {
        "size": 3, //取top3
        "sort": [
          {
            "money": { //按充值金额降序排序
              "order": "desc"
            }
          }
        ],
        "_source": {
          "includes": [ //指定返回字段
            "uid",
            "money"
          ]
        }
      }
    }
  }
}

#返回
{
  "took": 263,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "top3_money": {
      "hits": {
        "total": 9,
        "max_score": null,
        "hits": [
          {
            "_index": "user_logs",
            "_type": "recharge_log",
            "_id": "sMjgkmUBc0eBrlTlqYGw",
            "_score": null,
            "_source": {
              "uid": "1",
              "money": 30
            },
            "sort": [
              30
            ]
          },
          {
            "_index": "user_logs",
            "_type": "recharge_log",
            "_id": "ssjgkmUBc0eBrlTlqYGw",
            "_score": null,
            "_source": {
              "uid": "1",
              "money": 30
            },
            "sort": [
              30
            ]
          },
          {
            "_index": "user_logs",
            "_type": "recharge_log",
            "_id": "tsjgkmUBc0eBrlTlqYGx",
            "_score": null,
            "_source": {
              "uid": "3",
              "money": 20
            },
            "sort": [
              20
            ]
          }
        ]
      }
    }
  }
}
```

## 分桶聚合(Bucket Aggregations)

### 直方图聚合(Histogram Aggregation)

基于查询结果中某字段值的动态分桶,对每个桶进行聚合。是多Bucket聚合。

分桶规则
```
#value:字段值
#interval:间隔
#rem:取余
#举例:
#如 interval=10
#当 value=10 时，rem=0,则bucket_key=10
rem = value % interval
if (rem < 0) {
    rem += interval
}
bucket_key = value - rem
```

```
#查询：每个充值区间的订单数
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "money_histogram": {
      "histogram": {
        "field": "money",
        "interval": 10 //充值区间间隔
      }
    }
  }
}

#返回
{
  "took": 15,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "money_histogram": {
      "buckets": [
        {
          "key": 10,
          "doc_count": 1
        },
        {
          "key": 20,
          "doc_count": 6
        },
        {
          "key": 30,
          "doc_count": 2
        }
      ]
    }
  }
}
```

### 日期直方图聚合(Date Histogram Aggregation)

日期直方图和直方图作用一样，只不过可以用日期间隔来分桶,对每个桶进行聚合。是多Bucket聚合。

注意：
- 数据默认是以UTC时间存储在ES中。默认情况下，所有时间分组都是以UTC来完成的。可以指定time_zone参数以指定时区分组。
- interval 时间间隔可以为:year,month,day,hour,quarter,minute,second。

```
#查询:每个小时充值订单数
#min_doc_count:当某个bucket中没有文档时不返回此bucket
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "payTime_date_Histogram": {
      "date_histogram": {
        "field": "payTime",
        "interval": "hour",
        "format": "yyyy-MM-dd HH:mm:ss",
        "min_doc_count": 1, 
        "time_zone": "+08:00"
      }
    }
  }
}

#返回
{
  "took": 13,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "payTime_date_Histogram": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 16:00:00",
          "key": 1472112000000,
          "doc_count": 3
        },
        {
          "key_as_string": "2016-08-26 16:00:00",
          "key": 1472198400000,
          "doc_count": 3
        },
        {
          "key_as_string": "2016-08-27 18:00:00",
          "key": 1472292000000,
          "doc_count": 3
        }
      ]
    }
  }
}
```

## 范围聚合(Range Aggregation)

- 自定义一系列范围，每个范围代表一个分桶。是多Bucket聚合。
```
#查询
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "range": {
      "age": {
        "gte": 20,
        "lte": 36
      }
    }
  },
  "aggs": {
    "age_range_agg": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "to": 30
          },
          {
            "from": 30,
            "to": 36
          }
        ]
      }
    }
  }
}

#返回
{
  "took": 15,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "age_range_agg": {
      "buckets": [
        {
          "key": "*-30.0", //第一个范围 age<30
          "to": 30,
          "doc_count": 9
        },
        {
          "key": "30.0-36.0", //第二个范围 age>= 30 and age <36
          "from": 30,
          "to": 36,
          "doc_count": 0
        }
      ]
    }
  }
}
```

## 日期范围聚合

对日期字段按日期范围聚合。是多Bucket聚合。

同范围聚合(Range Aggregation)相比，日期范围聚合可用ES 内置日期格式或JodaDate日期表达式来表示日期范围。

format指定输入和输出日期格式。

### ES内置时间格式
```
查询:每个指定时间段内充值订单数。

GET /user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "date_range_payTime": {
      "date_range": {
        "field": "payTime",
        "format": "epoch_second", 
        "ranges": [
          {
            "from": 1472083200,
            "to": 1472169600
          },
          {
            "from": 1472169600,
            "to": 1472256000
          }
        ]
      }
    }
  }
}

返回
{
  "took": 12,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_range_payTime": {
      "buckets": [
        {
          "key": "1472083200-1472169600",
          "from": 1472083200000,
          "from_as_string": "1472083200",
          "to": 1472169600000,
          "to_as_string": "1472169600",
          "doc_count": 3
        },
        {
          "key": "1472169600-1472256000",
          "from": 1472169600000,
          "from_as_string": "1472169600",
          "to": 1472256000000,
          "to_as_string": "1472256000",
          "doc_count": 3
        }
      ]
    }
  }
}
```

### JodaDate日期表达式
```
查询:每个指定时间段内充值订单数。
GET /user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "date_range_payTime": {
      "date_range": {
        "field": "payTime",
        "format": "yyyy-MM-dd HH:mm:ss", 
        "ranges": [
          {
            "from": "now-25M/M", //25个月之前的那个月初
            "to": "now-24M/M" //24个月之前的那个月初
          }
        ]
      }
    }
  }
}

#返回
{
  "took": 9,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_range_payTime": {
      "buckets": [
        {
          "key": "2016-08-01 00:00:00-2016-09-01 00:00:00",
          "from": 1470009600000,
          "from_as_string": "2016-08-01 00:00:00",
          "to": 1472688000000,
          "to_as_string": "2016-09-01 00:00:00",
          "doc_count": 9
        }
      ]
    }
  }
}
```

## 单过滤聚合(Filter Aggregation)

- 对Quey结果单次Filter后形成的新的Bucket进行聚合。是单Bucket聚合。
```
#充值方式payWay=2的总充值金额
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "payWay2_agg":{
      "filter": {"term": {"payWay": 2}},
      "aggs": {"sum_money_payWay2": {"sum": {"field":"money"}}}
    }
  }
}

#返回结果
{
  "took": 107,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "payWay2_agg": {
      "doc_count": 5,
      "sum_money_payWay2": {
        "value": 110
      }
    }
  }
}
```

## 多过滤聚合(Filters Aggregation)

- 对Quey结果多次Filter后形成的多个Bucket分别聚合。是多Bucket聚合。
```
#充值方式payWay=1和payWay=2，每种充值方式对应的充值总额
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "flters_agg": {
     "filters": {
       "filters": {
         "payWay2": {"term": {"payWay": 2}},
         "payWay1":{"term": {"payWay": 1}}
       }
     },
     "aggs": {
       "sum_money": {
         "sum": {
           "field": "money"
         }
       }
     }
    }
  }
}

#返回结果
{
  "took": 480,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "flters_agg": {
      "buckets": {
        "payWay1": { //payWay=1的总充值金额
          "doc_count": 4,
          "sum_money": {
            "value": 80
          }
        },
        "payWay2": { //payWay=2的总充值金额
          "doc_count": 5,
          "sum_money": {
            "value": 110
          }
        }
      }
    }
  }
}
```

## 全局聚合(Global Aggregation)

- 全局聚合不受Query的影响。是单Bucket聚合。
```
#全部年龄充值总金额和query年龄段充值总金额。
GET user_logs/recharge_log/_search?size=0
{
  "query": {"range": {"age": {"gte": 10,"lte": 25}}},
  "aggs": {
    "all_age_sum_money": {
      "global": {}, 
      "aggs": {
        "sum_money": {
          "sum": {
            "field": "money"
          }
        }
      }
    },
    "this_age_sum_money":{
      "sum": {
        "field": "money"
      }
    }  
  }
}

#返回结果
{
  "took": 4,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 3,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "all_age_sum_money": { //全局聚合结果-不受Query影响
      "doc_count": 9,
      "sum_money": {
        "value": 190
      }
    },
    "this_age_sum_money": { //Query聚合结果
      "value": 60
    }
  }
}
```

## 缺失值聚合(Missing Aggregation)

- 对Query结果中某缺失字段统计。是单Bucket聚合。
```
#统计没有payWay字段或payWay字段为NULL的文档数。
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "missing_payWay": {
      "missing": {
        "field": "payWay"
      }
    }
  }
}

#返回结果
{
  "took": 23,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "missing_payWay": {
      "doc_count": 0
    }
  }
}
```

## 唯一值聚合(Terms Aggregation)

- 根据某个字段的每个唯一值聚合。是多Bucket聚合。
```
#每种充值方式对应的充值总额
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "terms_payWay": {
     "terms": {
       "field": "payWay"
     }
    }
  }
}

#返回结果
{
  "took": 5,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "terms_payWay": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 0,
      "buckets": [
        {
          "key": 2,
          "doc_count": 5
        },
        {
          "key": 1,
          "doc_count": 4
        }
      ]
    }
  }
}
```

## 其他分桶聚合

- IP范围聚合(IP Range Aggregation)
  - 对IP数据类型字段，进行IP范围聚合。是多Bucket聚合。

- 嵌套聚合(Nested Aggregation)和反向嵌套聚合(Reverse Nested Aggregation)
  - 对嵌套数据类型字段，进行嵌套聚合。是单Bucket聚合。

## 管道聚合

管道聚合分为两类：
- Sibling
  - 基于同级聚合结果再进行聚合。
- Parent
  - 基于父级聚合结果再进行聚合。

## 桶均值聚合(Avg Bucket Aggregation)

- 同级管道聚合,计算同级聚合中所有桶指定度量的均值。
```
#每天充值金额与平均每天充值金额
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "date_agg": {  //每天充值金额
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
    "aggs": {
      "day_sum_money": { 
        "sum": {
          "field": "money"
        }
      }
    }
    },
    "pipeline_avg_money":{ //平均每天充值金额
      "avg_bucket": {
        "buckets_path": "date_agg>day_sum_money"
      }
    }
  }
}

#返回结果
{
  "took": 182,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 70
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00",
          "key": 1472169600000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        }
      ]
    },
    "pipeline_avg_money": {
      "value": 63.333333333333336
    }
  }
}
```

## 桶总和聚合

- 同级管道聚合,计算同级聚合中所有桶指定度量的总和。
```
#每天充值金额和总充值金额
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "date_agg": { //每天充值金额
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
    "aggs": {
      "day_sum_money": {
        "sum": {
          "field": "money"
        }
      }
    }
    },
    "pipeline_sum_money":{ //总充值金额
      "sum_bucket": {
        "buckets_path": "date_agg>day_sum_money"
      }
    }
  }
}

#返回结果
{
  "took": 8,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 70
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00",
          "key": 1472169600000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        }
      ]
    },
    "pipeline_sum_money": {
      "value": 190
    }
  }
}
```

## 桶最大值聚合(Max Bucket Aggregation)

- 同级管道聚合,计算同级聚合中所有桶指定度量的最大值。
```
#每天平均充值金额和平均充值金额最大的那一天
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
    "aggs": {
      "day_avg_money": {
        "avg": {
          "field": "money"
        }
      }
    }
    },
    "pipeline_max_money":{
      "max_bucket": {
        "buckets_path": "date_agg>day_avg_money"
      }
    }
  }
}

#返回结果
{
  "took": 130,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00", //每天平均充值金额
          "key": 1472083200000,
          "doc_count": 3,
          "day_avg_money": {
            "value": 23.333333333333332
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00", //每天平均充值金额
          "key": 1472169600000,
          "doc_count": 3,
          "day_avg_money": {
            "value": 20
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00", //每天平均充值金额
          "key": 1472256000000,
          "doc_count": 3,
          "day_avg_money": {
            "value": 20
          }
        }
      ]
    },
    "pipeline_max_money": { //平均充值金额最大的那一天
      "value": 23.333333333333332,
      "keys": [
        "2016-08-25 00:00:00"
      ]
    }
  }
}
```

## 桶最小值聚合(Min Bucket Aggregation)

- 同级管道聚合,计算同级聚合中所有桶指定度量的最小值。
```
#每天平均充值金额和平均充值金额最小的那一天
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
    "aggs": {
      "day_avg_money": {
        "avg": {
          "field": "money"
        }
      }
    }
    },
    "pipeline_min_money":{
      "min_bucket": {
        "buckets_path": "date_agg>day_avg_money"
      }
    }
  }
}

#返回结果
{
  "took": 20,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "day_avg_money": {
            "value": 23.333333333333332
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00",
          "key": 1472169600000,
          "doc_count": 3,
          "day_avg_money": {
            "value": 20
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "day_avg_money": {
            "value": 20
          }
        }
      ]
    },
    "pipeline_min_money": { //平均充值金额最小的那一天。这里26号和27号同时最小，返回两天
      "value": 20,
      "keys": [
        "2016-08-26 00:00:00",
        "2016-08-27 00:00:00"
      ]
    }
  }
}
```


## 桶统计信息聚合(Stats Bucket Aggregation)

- 同级管道聚合,计算同级聚合中所有桶指定度量的统计信息。
```
#每天充值总额与每天充值总额对应的统计信息
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
    "aggs": {
      "day_sum_money": {
        "sum": {
          "field": "money"
        }
      }
    }
    },
    "pipeline_stats_money":{
      "stats_bucket": {
        "buckets_path": "date_agg>day_sum_money"
      }
    }
  }
}

#返回结果
{
  "took": 8,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 70
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00",
          "key": 1472169600000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        }
      ]
    },
    "pipeline_stats_money": {
      "count": 3,
      "min": 60,
      "max": 70,
      "avg": 63.333333333333336,
      "sum": 190
    }
  }
}
```

## 桶百分比聚合(Percentiles Bucket Aggregation)

- 同级管道聚合,计算同级聚合中所有桶指定度量的百分位数。
```
#每天充值金额的百分位数
GET user_logs/recharge_log/_search?size=0
{
  "query": {"match_all": {}},
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
    "aggs": {
      "day_sum_money": {
        "sum": {
          "field": "money"
        }
      }
    }
    },
    "pipeline_stats_money":{
      "percentiles_bucket": {
        "buckets_path": "date_agg>day_sum_money"
      }
    }
  }
}

#返回结果
{
  "took": 49,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 70
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00",
          "key": 1472169600000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "day_sum_money": {
            "value": 60
          }
        }
      ]
    },
    "pipeline_stats_money": {
      "values": {
        "1.0": 60,
        "5.0": 60,
        "25.0": 60,
        "50.0": 60,
        "75.0": 70,
        "95.0": 70,
        "99.0": 70
      }
    }
  }
}
```

## 桶累计和聚合

- 父级管道聚合，计算父级直方图（或日期直方图）聚合中指定度量的累积和。
```
#每天充值金额和每天累计充值金额
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
      "aggs": {
        "day_sum_money": {
          "sum": {
            "field": "money"
          }
        },
        "pipeline_stats_money": {
          "cumulative_sum": {
            "buckets_path": "day_sum_money"
          }
        }
      }
    }
  }
}

#返回结果
{
  "took": 33,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "day_sum_money": { //2016-08-25日充值金额
            "value": 70
          },
          "pipeline_stats_money": {//截止到2016-08-25日的累计充值金额
            "value": 70
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00",
          "key": 1472169600000,
          "doc_count": 3,
          "day_sum_money": { //2016-08-26日充值金额
            "value": 60
          },
          "pipeline_stats_money": { //截止到2016-08-26日的累计充值金额
            "value": 130
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "day_sum_money": { //2016-08-27日充值金额
            "value": 60
          },
          "pipeline_stats_money": { //截止到2016-08-27日的累计充值金额
            "value": 190
          }
        }
      ]
    }
  }
}
```

## 桶脚本聚合(Bucket Script Aggregation)

- 父级管道聚合，执行一个脚本，得到父级聚合中多个指定度量经过脚本计算的结果。

脚本可以是 inline script，也可以是 file script。
```
#每天payWay=2的充值方式的充值总额占每天所有充值方式充值总额的百分比
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
      "aggs": {
        "day_sum_money": {
          "sum": {
            "field": "money"
          }
        },
        "day_payWay_sum_money": {
          "filter": {
            "term": {
              "payWay": 2
            }
          },
          "aggs": {
            "day_payWay2_sum_money": {
              "sum": {
                "field": "money"
              }
            }
          }
        },
        "payWay2_percent": {
          "bucket_script": {
            "buckets_path": {
              "day_payWay2_total": "day_payWay_sum_money > day_payWay2_sum_money",
              "day_total": "day_sum_money"
            },
            "script": "(params.day_payWay2_total / params.day_total) * 100 "
          }
        }
      }
    }
  }
}

#返回结果
{
  "took": 8,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "day_payWay_sum_money": {
            "doc_count": 3,
            "day_payWay2_sum_money": { //充值方式payWay=2的充值总额
              "value": 70
            }
          },
          "day_sum_money": { //所有充值方式的充值总额
            "value": 70
          },
          "payWay2_percent": { //占比
            "value": 100
          }
        },
        {
          "key_as_string": "2016-08-26 00:00:00",
          "key": 1472169600000,
          "doc_count": 3,
          "day_payWay_sum_money": {
            "doc_count": 2,
            "day_payWay2_sum_money": {
              "value": 40
            }
          },
          "day_sum_money": {
            "value": 60
          },
          "payWay2_percent": {
            "value": 66.66666666666666
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "day_payWay_sum_money": {
            "doc_count": 0,
            "day_payWay2_sum_money": {
              "value": 0
            }
          },
          "day_sum_money": {
            "value": 60
          },
          "payWay2_percent": {
            "value": 0
          }
        }
      ]
    }
  }
}
```

## 桶选择器聚合(Bucket Selector Aggregation)

- 父级管道聚合，执行一个脚本,选择父级聚合中需要保留的桶。
```
#保留每天充值金额大于60的桶
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
      "aggs": {
        "sum_money": {
          "sum": {
            "field": "money"
          }
        },
        "money_bucket_selector": {
          "bucket_selector": {
            "buckets_path": {
              "sum_money": "sum_money"
            },
            "script": "params.sum_money>60"
          }
        }
      }
    }
  }
}

#返回结果
{
  "took": 15,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "sum_money": {
            "value": 70
          }
        }
      ]
    }
  }
}
```

## 桶排序聚合(Bucket Sort Aggregation)

- 父级管道聚合,对父级聚合中的桶按指定度量排序，并保留n个。
```
#充值金额最多的2天
GET user_logs/recharge_log/_search?size=0
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "date_agg": {
      "date_histogram": {
        "field": "payTime",
        "interval": "day"
      },
      "aggs": {
        "sum_money": {
          "sum": {
            "field": "money"
          }
        },
        "money_bucker": {
          "bucket_sort": {
            "sort": [
              {
                "sum_money": {
                  "order": "desc"
                }
              }
            ],
            "size": 2
          }
        }
      }
    }
  }
}

#返回结果
{
  "took": 12,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 9,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "date_agg": {
      "buckets": [
        {
          "key_as_string": "2016-08-25 00:00:00",
          "key": 1472083200000,
          "doc_count": 3,
          "sum_money": {
            "value": 70
          }
        },
        {
          "key_as_string": "2016-08-27 00:00:00",
          "key": 1472256000000,
          "doc_count": 3,
          "sum_money": {
            "value": 60
          }
        }
      ]
    }
  }
}
```
