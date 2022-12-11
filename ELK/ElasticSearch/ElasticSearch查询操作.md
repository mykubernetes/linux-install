ElasticSearch~查询操作
- 简单查询
- 批量查询
- 匹配查询
- 模糊查询
- 精确查询
- 范围查询
- 通配符查询
- must查询
- should查询
- 过滤查询


# 一、简单查询

## 1、查询所有结果
```
GET /student_info/_search
{
  "query": {"match_all": {}}
}
```

## 2、根据条件查询
```
GET /student_info/_search
{
  "query":{
    "match":{
      "name":"张三"
    }
  }
}
```

## 3、排序
```
GET /student_info/_search
{
  "query":{
    "match":{
      "name":"张三"
    }
  },
  "sort":[{
    "age":"desc"
  }]
}
```

## 4、指定查询返回结果字段
```
GET /student_info/_search
{
  "query":{"match_all": {}},
  "_source": ["name","age"]
}
```

# 二、批量查询

## 1、多ID查询
```
GET /student_info/_search
{
  "query":{
    "ids":{
      "values":[11001,11002,11003]
    }
  }
}
```

## 2、单索引批量查询
```
POST /student_info/_mget
{
  "ids":["11001","11002","11003"]
}
```

## 3、跨索引批量查询
```
GET /_mget
{
  "docs":[
      {
        "_index":"student_info",
        "_id":"11001"
      },
      {
        "_index":"teacher",
        "_id":"1001"
      }
    ]
}
```

# 4、跨索引批量查询
```
GET /_msearch
{"index":"student_info"}
{"query":{"match_all":{}},"from":0,"size":4}
{"index":"teacher"}
{"query":{"match_all":{}}}
```

# 三、匹配查询

## 1、关键词分词查询

先对match里面的字段值进行分词，然后进行查询

“profession”: “计算机技术” ：分词结果为 “计算机”、 “技术”，查询profession包含 "计算机"和 "技术"的记录
```
GET /student_info/_search
{
  "query":{
    "match":{
      "profession":"计算机技术"
    }
  }
}
```

```
GET /student_info/_search
{
  "query":{
    "match":{
      "profession":"计算机酒店"
    }
  }
}
```

## 2、关联查询
“profession”: “计算机技术” ：分词结果为 “计算机”、 “技术”，查询条件"operator": “and”，必须满足全部分词结果。
```
GET /student_info/_search
{
  "query":{
    "match":{
      "profession": {
        "query":"计算机技术",
        "operator": "and"
      }
    }
  }
}
```

“profession”: “计算机技术” ：分词结果为 “计算机”、 “技术”，查询条件"operator": “or”，任意满足其一。
```
GET /student_info/_search
{
  "query": {
    "match":{
      "profession": {
        "query": "计算机酒店",
        "operator": "or"
      }
    }
  }
}
```

## 3、多字段查询
检索内容"我计算机技术" , 会拆词为“我”，“计算机”，“技术”匹配字段profession或desc字段中包含拆出来的词语的结果
```
GET /student_info/_search
{
  "query":{
    "multi_match": {
      "query": "我计算机技术",
      "fields": ["profession","desc"]
    }
  }
}
```

## 4、短语查询
match_phrase短语搜索，要求所有的分词必须同时出现在文档中，同时位置必须紧邻一致。
```
GET /student_info/_search
{
  "query": {
    "match_phrase": {
      "profession": "计算机科"
    }
  }
}
```

## 5、高亮搜索

- highlight 高亮查找
- pre_tags 标签前缀
- post_tags 标签后缀
- fields 规定的字段，支持多个
- 注意：如果不声明前缀和后缀，那边默认使用 <em></em>

```
GET /student_info/_search
{
  "query":{
    "match":{
      "name":"张三"
    }
  },
  "highlight": {
    "pre_tags":"<p class = \"text_high_light\">",
    "post_tags": "</p>",
    "fields": {
      "name":{}
    }
  }
}
```

## 6、前缀匹配
```
GET /student_info/_search
{
  "query": {
    "match_phrase_prefix": {
      "name":"小小"
    }
  }
}
```

# 四、模糊查询

```
GET /student_info/_search
{
  "query":{
    "fuzzy":{
      "name":"张"
    }
  }
}
```

# 五、精确查询

term是关键词查询，参数类型type 一般都是是keyword , 精确查询，对查询的值不分词,直接进倒排索引去匹配。
- term 精确查找（单个）
- terms 精确查找（多个）

```
GET /student_info/_search
{
  "query":{
    "term":{
      "name.keyword": "张三"
    }
  }
}
```

terms表示多条件并列，用大括号 [ ] 涵盖所查内容，类似于MySql中in方法
```
GET /student_info/_search
{
  "query": {
    "terms":{
      "age":[19,20,21,22]
    }
  }
}
```

# 六、范围查询

## 1、range
大于-gt，小于-lt，大于等于-gte，小于等于-lte

- 数字范围
```
GET /student_info/_search
{
  "query": {
    "range":{
      "age":{
        "gte":19,
        "lte":21
      }
    }
  }
}
```

- 时间范围
```
GET /student_info/_search
{
  "query": {
    "range":{
      "birthday": {
        "gte": "2001-06-15",
        "lte": "2001-09-20"
      }
    }
  }
}
```

## 2、from…to

- 范围查询包含边界
```
GET /student_info/_search
{
  "query":{
    "range":{
      "age":{
        "from":19,
        "to":21
      }
    }
  }
}
```

- 范围查询不包含边界
```
GET /student_info/_search
{
  "query": {
    "range":{
      "age":{
        "from":19,
        "to":21,
        "include_lower":false,
        "include_upper":false
      }
    }
  }
}
```

# 七、通配符查询
注：?用来匹配任意字符，*用来匹配零个或者多个字符，主要用于-英文检索
```
GET /student_info/_search
{
  "query":{
    "wildcard":{
      "english_name": "xiaoxiao*"
    }
  }
}
```

```
GET /student_info/_search
{
  "query":{
    "wildcard": {
      "english_name": "li?i"
    }
  }
}
```

# 八、must查询

- must的多条件都必须满足
- must相当于MySQL条件中的AND

```
GET /student_info/_search
{
  "query":{
    "bool":{
      "must":[{
        "match":{
          "name":"小小"
        }
      },
      {
        "range":{
          "age":{
            "gt":19,
            "lte":22
          }
        }
      }
      ]
    }
  }
}
```

# 九、should查询

- should的条件，至少满足一个就可以
- should相当于MySQL条件中的OR

```
GET /student_info/_search
{
  "query":{
    "bool":{
      "should":[{
        "match":{
          "name":"小小"
        }
      },
      {
        "range":{
          "age":{
            "gt":19,
            "lte":22
          }
        }
      }]
    }
  }
}

```

# 十、过滤查询
```
GET /student_info/_search
{
  "query":{
    "bool":{
      "should":[
        {
          "match":{
            "name":"小小"
          }
        }],
        "filter":{
          "range":{
            "age":{
              "gt":21,
              "lte":22
            }
          }
        }
    }
  }
}
```
