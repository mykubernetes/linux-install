# 分析器(Analyzer)

Elasticsearch 无论是内置分析器还是自定义分析器，都由三部分组成：字符过滤器(Character Filters)、分词器(Tokenizer)、词元过滤器(Token Filters)。

### 分析器Analyzer工作流程：

Input Text => Character Filters(如果有多个，按顺序应用) => Tokenizer => Token Filters(如果有多个，按顺序应用) => Output Token

## 字符过滤器(Character Filters)
字符过滤器：对原始文本预处理，如去除HTML标签，”&”转成”and”等。

注意：一个分析器同时有多个字符过滤器时，按顺序应用。

## 分词器(Tokenizer)
分词器：将字符串分解成一系列的词元Token。如根据空格将英文单词分开。

## 词元过滤器(Token Filters)
词元过滤器：对分词器分出来的词元Token做进一步处理，如转换大小写、移除停用词、单复数转换、同义词转换等。

注意：一个分析器同时有多个词元过滤器时，按顺序应用。


# 分析器analyze API的使用

分析器analyze API可验证分析器的分析效果并解释分析过程。
```
# text: 待分析文本
# explain:解释分析过程
# char_filter:字符过滤器
# tokenizer:分词器
# filter:词元过滤器

GET _analyze 
{
  "char_filter" : ["html_strip"],
  "tokenizer": "standard",
  "filter":  [ "lowercase"],
  "text": "<p><em>No <b>dreams</b>, why bother <b>Beijing</b> !</em></p>",
  "explain" : true
}
```

## 自定义多个分析器

### 创建索引并自定义多个分析器

这里对一个索引同时定义了多个分析器。
```
PUT my_index
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1, 
    "analysis": { 
      "char_filter": { //自定义多个字符过滤器
        "my_charfilter1": {
          "type": "mapping",
          "mappings": ["& => and"]
        },
        "my_charfilter2": {
          "type": "pattern_replace",
          "pattern": "(\\d+)-(?=\\d)",
          "replacement": "$1_"
        }
      },
      "tokenizer":{  //自定义多个分词器
          "my_tokenizer1": {
              "pattern":"\\s+",
              "type":"pattern"
            },
          "my_tokenizer2":{
                "pattern":"_",
                "type":"pattern"
            }
      },
      "filter": {  //自定义多个词元过滤器
        "my_tokenfilter1": {
          "type": "stop",
          "stopwords": ["the", "a","an"]
        },
        "my_tokenfilter2": {
          "type": "stop",
          "stopwords": ["info", "debug"]
        }
      },
      "analyzer": { //自定义多个分析器
         "my_analyzer1":{  //分析器my_analyzer1 
           "char_filter": ["html_strip", "my_charfilter1","my_charfilter2"],
           "tokenizer":"my_tokenizer1",
           "filter": ["lowercase", "my_tokenfilter1"]
         },
         "my_analyzer2":{  //分析器my_analyzer2
           "char_filter": ["html_strip"],
           "tokenizer":"my_tokenizer2",
           "filter": ["my_tokenfilter2"]
         }
      }
    }
  }
}
```

## 验证索引my_index的多个分析器

### 验证分析器my_analyzer1分析效果
```
GET /my_index/_analyze
{
  "text": "<b>Tom </b> & <b>jerry</b> in the room number 1-1-1",
  "analyzer": "my_analyzer1"//,
  //"explain": true
}

#返回结果
{
  "tokens": [
    {
      "token": "tom",
      "start_offset": 3,
      "end_offset": 6,
      "type": "word",
      "position": 0
    },
    {
      "token": "and",
      "start_offset": 12,
      "end_offset": 13,
      "type": "word",
      "position": 1
    },
    {
      "token": "jerry",
      "start_offset": 17,
      "end_offset": 26,
      "type": "word",
      "position": 2
    },
    {
      "token": "in",
      "start_offset": 27,
      "end_offset": 29,
      "type": "word",
      "position": 3
    },
    {
      "token": "room",
      "start_offset": 34,
      "end_offset": 38,
      "type": "word",
      "position": 5
    },
    {
      "token": "number",
      "start_offset": 39,
      "end_offset": 45,
      "type": "word",
      "position": 6
    },
    {
      "token": "1_1_1",
      "start_offset": 46,
      "end_offset": 51,
      "type": "word",
      "position": 7
    }
  ]
}
```

### 验证分析器my_analyzer2分析效果
```
GET /my_index/_analyze
{
  "text": "<b>debug_192.168.113.1_971213863506812928</b>",
  "analyzer": "my_analyzer2"//,
  //"explain": true
}


#返回结果
{
  "tokens": [
    {
      "token": "192.168.113.1",
      "start_offset": 9,
      "end_offset": 22,
      "type": "word",
      "position": 1
    },
    {
      "token": "971213863506812928",
      "start_offset": 23,
      "end_offset": 45,
      "type": "word",
      "position": 2
    }
  ]
}
```

## 添加Mapping并为不同字段设置不同分析器
```
PUT my_index/_mapping/my_type
{
      "properties": {
      "my_field1": {
        "type": "text",
        "analyzer": "my_analyzer1",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "my_field2": {
        "type": "text",
        "analyzer": "my_analyzer2",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      }
    }
}
```

## 创建文档
```
PUT my_index/my_type/1
{
  "my_field1":"<b>Tom </b> & <b>jerry</b> in the room number 1-1-1",
  "my_field2":"<b>debug_192.168.113.1_971213863506812928</b>"
}
```

## Query-Mathch全文检索

- 查询时，ES会根据字段使用的分析器进行分析，然后检索。
```
#查询my_field2字段包含IP:192.168.113.1的文档
GET my_index/_search
{
  "query": {
    "match": {
      "my_field2": "192.168.113.1"
    }
  }
}

#返回结果
{
  "took": 22,
  "timed_out": false,
  "_shards": {
    "total": 3,
    "successful": 3,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 1,
    "max_score": 0.2876821,
    "hits": [
      {
        "_index": "my_index",
        "_type": "my_type",
        "_id": "1",
        "_score": 0.2876821,
        "_source": {
          "my_field1": "<b>Tom </b> & <b>jerry</b> in the room number 1-1-1",
          "my_field2": "<b>debug_192.168.113.1_971213863506812928</b>"
        }
      }
    ]
  }
}
```
