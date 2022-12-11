# 一、add_field

- 功能：添加字段
- 介绍：在filter过滤成功之后，可以添加字段，可以添加多个字段，必须写在filter组件内部，可以动态添加字段

```
filter{
    grok{
        match => {
            "message" => "%{NUMBER:number} %{WORD:name}"
        }
	    add_field => {
	        "f1" => "field1"
	        "f2" => "field2"
	    }
	}
}
```

```
{
    "message": "173 Jack",
    "number": "173",
    "name": "Jack",
    "f1": "field1",
    "f2": "field2"
}
```

```
filter {
    mutate {
    	# 可以添加多条字段
        add_field => {
        	# 添加动态字段
            "To %{[host][ip]}" => "%{@timestamp}"
           # 添加静态字段
            "newField" => "newValue"
        }
    }
}
```

# 二、remove_field

- 功能：删除字段
- 介绍：在filter组件过滤成功之后可以删除字段，可以删除多个字段，必须写在filter组件内部

```
filter{
    grok{
        match => {
            "message" => "%{WORD:name} %{NUMBER:age}"
        }
        # 可以在filter阶段删除字段，必须写在过滤组件内部
        remove_field => ["message","event"]
    }
}
```

# 三、add_tag

- 功能：添加标志
- 介绍：在filter组件过滤成功之后可以在tag字段中添加一段自定义的内容，当tag字段中超过一个内容的时候会变成数组，支持动态添加其他字段，必须写在filter组件内部

```
filter {
    mutate {
    	# 添加多个字段
        add_tag => [
        	# 可以添加字符串
            "123",
           # 也可以添加其他字段(添加的字段不能被移除)
            "%{@timestamp}"
        ]
    }
}
```

```
{
          "tags" => [
        [0] "_grokparsefailure_sysloginput",
        [1] "123",
        [2] "2022-04-26T03:07:25.974998Z"
    ],
       "message" => "python",
    "@timestamp" => 2022-04-26T03:07:25.974998Z,
         "event" => {
        "original" => "python"
    }
}
```

# 四、id

- 功能：为插件配置唯一标识
- 介绍：在使用监控API监控logstash时有用，平常貌似是用不到

```
filter {
    mutate {
        id => "ABC"
    }
}
```
