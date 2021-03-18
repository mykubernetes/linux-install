 Analysis
---
```
analysis(只是一个概念)，文本分析是将全文本转换为一系列单词的过程，也叫分词。analysis是通 过analyzer(分词器)来实现的，可以使用Elasticsearch内置的分词器，也可以自己去定制一些分词 器。 除了在数据写入的时候进行分词处理，那么在查询的时候也可以使用分析器对查询语句进行分词。

anaylzer是由三部分组成，例如有
Hello a World, the world is beautifu
1. Character Filter: 将文本中html标签剔除掉。
2. Tokenizer: 按照规则进行分词，在英文中按照空格分词。
3. Token Filter: 去掉stop world(停顿词，a, an, the, is, are等)，然后转换小写
```

内置分词器
| 分词器名称 | 处理过程 |
|-----------|----------|
| Standard Analyzer | 默认的分词器，按词切分，小写处理 |
| Simple Analyzer | 按照非字母切分(符号被过滤)，小写处理 |
| Stop Analyzer | 小写处理，停用词过滤(the, a, this) |
| Whitespace Analyzer | 按照空格切分，不转小写 |
| Keyword Analyzer | 不分词，直接将输入当做输出 |
| Pattern Analyzer | 正则表达式，默认是\W+(非字符串分隔) |

Standard Analyzer
```
curl -H "Content-Type: application/json" -XGET 'http://master:9200/_analyze?pretty=true' -d '{  "analyzer": "standard",  "text": "2 Running quick brown-foxes leap over lazy dog in the summer evening" }'
```

Simple Analyzer
```
curl -H "Content-Type: application/json" -XGET 'http://master:9200/_analyze?pretty=true' -d '{  "analyzer": "simple",  "text": "2 Running quick brown-foxes leap over lazy dog in the summer evening" }'
```

Stop Analyzer 
```
curl -H "Content-Type: application/json" -XGET 'http://master:9200/_analyze?pretty=true' -d '{  "analyzer": "stop",  "text": "2 Running quick brown-foxes leap over lazy dog in the summer evening" }'
```

Whitespace Analyzer 
```
curl -H "Content-Type: application/json" -XGET 'http://master:9200/_analyze?pretty=true' -d '{  "analyzer": "whitespace",  "text": "2 Running quick brown-foxes leap over lazy dog in the summer evening" }'
```

Keyword Analyzer 
```
curl -H "Content-Type: application/json" -XGET 'http://master:9200/_analyze?pretty=true' -d '{  "analyzer": "keyword",  "text": "2 Running quick brown-foxes leap over lazy dog in the summer evening" }'
```

Pattern Analyzer 
```
curl -H "Content-Type: application/json" -XGET 'http://master:9200/_analyze?pretty=true' -d '{  "analyzer": "pattern",  "text": "2 Running quick brown-foxes leap over lazy dog in the summer evening" }'
```
