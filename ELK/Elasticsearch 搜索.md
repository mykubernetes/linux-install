# 测试数据

### 下载测试数据
```
wget -O accounts.json https://github.com/elastic/elasticsearch/blob/6.4/docs/src/test/resources/accounts.json?raw=true
```

### 查看测试数据
```
head -n 4 accounts.json
{"index":{"_id":"1"}}
{"account_number":1,"balance":39225,"firstname":"Amber","lastname":"Duke","age":32,"gender":"M","address":"880 Holmes Lane","employer":"Pyrami","email":"amberduke@pyrami.com","city":"Brogan","state":"IL"}
{"index":{"_id":"6"}}
{"account_number":6,"balance":5686,"firstname":"Hattie","lastname":"Bond","age":36,"gender":"M","address":"671 Bristol Street","employer":"Netagy","email":"hattiebond@netagy.com","city":"Dante","state":"TN"}
```

### 数据load到ES
```
curl -u elastic:123456 -H 'Content-Type: application/x-ndjson' -XPOST 'node4:9200/bank/account/_bulk?pretty' --data-binary @accounts.json
```

### 查看ES中索引
```
GET _cat/indices/bank?v&format=json

[
  {
    "health": "green",
    "status": "open",
    "index": "bank",
    "uuid": "keZHd3v8QB2z43t7nhNLYw",
    "pri": "5",
    "rep": "1",
    "docs.count": "1000",
    "docs.deleted": "0",
    "store.size": "949.4kb",
    "pri.store.size": "474.7kb"
  }
]
```

### 查看ES中Mapping

注意:ES中默认的分词器是标准分词器(Standard Tokenizer)。
```
GET bank/_mapping

{
  "bank": {
    "mappings": {
      "account": {
        "properties": {
          "account_number": {
            "type": "long"
          },
          "address": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "age": {
            "type": "long"
          },
          "balance": {
            "type": "long"
          },
          "city": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "email": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "employer": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "firstname": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "gender": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "lastname": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "state": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          }
        }
      }
    }
  }
}
```

# URL参数搜索
```
用_search关键字，将查询语句传递给参数q。

# 查询name=name1的文档
GET user_info_test/_search?q=name:name1

# 查询name=name1 且 age=30的文档
# AND 注意:AND应大写。
GET user_info_test/_search?q=name:name1 AND age:30

# 查询name=name1 或 name=name3的文档
# OR 
GET user_info_test/_search?q=name:name1 OR name:name3
```

# URL请求体搜索

## 分页
```
#from 从第几行开始
#size查询多少条文档
#from默认是0，size默认是10
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "from": 0, 
  "size": 5
}
```

## 排序
```
#按age和balance排序
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "age": {
        "order": "desc"
      },
      "balance": {
        "order": "asc"
      }
    }
  ]
}
```

## 只显示部分字段
```
#不显示_source
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "_source": false
}

#只显示部分字段
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "_source": ["address","firstname","age"]
}

#排除某些列
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "_source": {
    "includes": ["address","firstname"],
    "excludes": "age"
  }
}
```

## 脚本支持
```
#给每个文档中balance加10000
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "script_fields": {
    "add_balance": {
      "script": "doc['balance'].value+10000"
    }
  }
}
```

## Score值解释
```
#解释Score值是如何被计算出来的
GET bank/_search
{
  "explain": true, 
  "query": {
    "match_all": {}
  }
}
```

## 查看请求访问到的节点、索引和Shard
```
GET bank/_search_shards
{
  "query": {
    "match_all": {}
  }
}
```

## 查看匹配到的文档总数
```
GET bank/_count
{
  "query": {
    "match_all": {}
  }
}
```

## 查看查询是否有结果
```
#达到数量terminate_after则终止查询
#验证是否有查询结果存在
GET bank/_search
{
  "query": {
    "term": {
      "age": {
        "value": 40
      }
    }
  },
  "size":0,
  "terminate_after": 1
}

#有查询结果存在
{
  "took": 4,
  "timed_out": false,
  "terminated_early": true,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 5,
    "max_score": 0,
    "hits": []
  }
}
```

## 验证查询语法是否有效
```
GET bank/_validate/query
{
  "query": {
    "term": {
      "age": {
        "value": 40
      }
    }
  }
}

{
  "valid": true,
  "_shards": {
    "total": 1,
    "successful": 1,
    "failed": 0
  }
}
```

## 匹配所有文档(Match All Query)
```
#_score 默认1.0
GET bank/_search
{
  "query": {
    "match_all": {}
  }
}
```

### 全文检索(Full text Query)

- 全文检索查询：先应用分词器，再查询。

- 注意：要确保查询分词器和索引分词器一致。

### 单词查询(Match Query)
```
#查询原理:
#1)分词 "Putnam Avenue" => Putnam和Avenue
#2)转小写 Putnam和Avenue => putnam和avenue
#2)查询 address中包含putnam或avenue的文档

# 默认operator:or
# address中包含单词Putnam或Avenue的文档
GET bank/_search
{
    "query": {
        "match" : {
            "address" : "Putnam Avenue"
        }
    }
}

# operator:and
# address中同时包含单词Putnam和Avenue的文档
GET bank/_search
{
    "query": {
        "match" : {
            "address" : {
              "query": "Putnam Avenue",
              "operator": "and"
            }

        }
    }
}
```

### 短语查询(Match Phrase Query)
```
GET bank/_search
{
  "query": {
    "match_phrase": {
      "address": "171 Putnam Avenue"
    }
  }
}
```

### 短语前缀查询(Match Phrase Prefix Query)
```
GET bank/_search
{
  "query": {
    "match_phrase_prefix": {
      "address": "171 Putnam"
    }
  }
}
```

### 多字段查询(Multi Match Query)
```
# or
GET bank/_search
{
  "query": {
    "multi_match": {
      "query": "Virginia Ayala",
      "fields": ["firstname","lastname","address"]
    }
  }
}

#and
GET bank/_search
{
  "query": {
    "multi_match": {
      "query": "Virginia Ayala",
      "fields": ["firstname","lastname"],
      "operator":   "and"
    }
  }
}
```

### Lucene语法查询(Query String Query)
```
GET bank/_search
{
  "query": {
    "query_string": {
      "default_field": "address",
      "query": "Putnam AND Avenue "
    }
  }
}

GET bank/_search
{
  "query": {
    "query_string": {
      "default_field": "address",
      "query": "(Putnam AND Avenue) OR (Baycliff AND Terrace)"
    }
  }
}
```

### 简化查询(Simple Query String Query)
```
GET bank/_search
{
  "query": {
    "simple_query_string": {
      "query": "\"Putnam  Avenue\" | \"Baycliff Terrace\"",
      "fields": ["address"],
      "default_operator": "AND"
    }
  }
}
```

## 字段查询(Term level queries)

- Term Query：不应用分词器，去倒排索引中找完全匹配(包括大小写)的Term。

### 单个词查询(Term Query)
```
#在倒排索引中查找address字段包含baycliff的文档
GET bank/_search
{
  "query": {
    "term": {
      "address": "baycliff"
    }
  }
}
```

### 多个词查询(Terms Query)
```
#在倒排索引中查找address字段包含baycliff或terrace的文档
GET bank/_search
{
  "query": {
    "terms": {
      "address": [
        "baycliff",
        "terrace"
      ]
    }
  }
}
```

### 范围查询(Range Query)

- 数字范围
```
GET bank/_search
{
  "query": {
    "range": {
      "age": {
        "gte": 20,
        "lte": 26
      }
    }
  }
}
```

- 日期范围
```
GET bank/_search
{
    "query": {
        "range" : {
            "born" : {
                "gte": "01/01/2012",
                "lte": "08/01/2012",
                "format": "dd/MM/yyyy"
            }
        }
    }
}
```

### 是否存在查询(Exists Query)

- 查找指定字段包含非空值得文档
```
#返回gender字段至少包含一个非空值的文档
GET bank/_search
{
  "query": {
    "exists" : { "field" : "gender" }
  }
}
```

- 缺失值查询
```
#返回gender字段缺失的文档
GET bank/_search
{
  "query": {
    "bool": {
      "must_not": [
        {
          "exists":{
            "field":"gender"
          }
        }
      ]
    }
  }
}
```

### 前缀查询(Prefix Query)
```
#返回倒排索引中firstname以au为前缀开始的文档
GET bank/_search
{
  "query": {
    "prefix": {
      "firstname": {
        "value": "au"
      }
    }

  }
}
```

### 通配符查询(Wildcard Query)
```
#不分析查询
#返回倒排索引中firstname以au开始mn结尾的文档
GET bank/_search
{
  "query": {
    "wildcard": {
      "firstname": {
        "value": "au*mn"
      }
    }
  }
}
```

### 正则查询(Regexp Query)
```
#不分析查询
#返回倒排索引中firstname以au开始mn结尾的文档
GET bank/_search
{
  "query": {
    "regexp":{
      "firstname":"au.*mn"
    }
  }
}
```

### 模糊查询(Fuzzy Query)
```
#此模糊查询时基于最大编辑距离的查询
#编辑距离是相似度算法的一种
GET bank/_search
{
  "query": {
    "fuzzy":{
      "firstname":"Aurelia"
    }
  }
}
```

## 复合查询(Compound queries)

### Bool Query

- must:必须出现在文档中，会影响最终得分。
- must_not:必须不出现在文档中。
- filter:必须匹配，不会影响最终得分。
- should:应该出现在文档中，在布尔查询中如果没有must或filter，则必须包含一个或多个should。应该匹配的should的最小数量可以通过minimum_should_match来设置。

```
POST bank/_search
{
  "query": {
    "bool": {
      "must": {
        "term": {
          "firstname": "aurelia"
        }
      },
      "must_not": {
        "range": {
          "age": {
            "gte": 10,
            "lte": 20
          }
        }
      },
      "should": [
        {
          "term": {
            "lastname": "harding"
          }
        },
        {
          "term": {
            "address": "baycliff"
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}
```

## 连接查询(Joining queries)

### 嵌套查询(Nested Query)
```
#创建如下索引,定义user类型为嵌套类型
PUT my_index
{
  "mappings": {
    "_doc": {
      "properties": {
        "user": {
          "type": "nested" 
        }
      }
    }
  }
}

#插入数据
PUT my_index/_doc/1
{
  "group" : "fans",
  "user" : [ 
    {
      "first" : "John",
      "last" :  "Smith"
    },
    {
      "first" : "Alice",
      "last" :  "White"
    }
  ]
}

#嵌套查询
GET my_index/_search
{
  "query": {
    "nested": {
      "path": "user",
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "user.first": "Alice"
              }
            }
          ]
        }
      }
    }
  }
}
```
