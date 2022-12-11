# 一、介绍
用来解析json格式数据的过滤器，默认会解析置顶字段的json数据并将其放置在Logstash事件的最顶级中，可以配置target配置项选择存放结果位置
如果解析的数据包含一个@timestamp字段，会将解析的数据放在顶级的@timestamp中，如果解析失败，该字段将被重命名为_@timestamp

# 二、source

- 功能：选择解析字段的位置
- 介绍：没有位置，必须要配置

```
filter{
    json {
    	# 将message作为解析json的字段
        source => "message"
    }
}
```

```
{
    "message" => "{\"name\":\"卡兹克\",\"age\":\"67\"}",
       "name" => "卡兹克",
        "age" => "67"
}
```

# 三、target

- 功能：目标字段
- 介绍：默认情况写解析出来的结果会存放在logstash信息的最上层，可以配置target将其保存在指定的字段下

```
filter{
    json {
        source => "message"
       # 将匹配的结果保存在test字段中
        target => "test"
    }
}
```

```
{
       "test" => {
        "name" => "卡兹克",
         "age" => "67"
    },
    "message" => "{\"name\":\"卡兹克\",\"age\":\"67\"}"
}
```
