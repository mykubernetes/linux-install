# extractnumbers过滤器

- extractnumbers过滤器：从字符串中提取数字
- 注意默认情况下此过滤器为捆绑需要执行`bin/logstash-plugin install logstash-filter-extractnumbers`操作安装插件

**可配置的参数**

| 参数 | 作用 | 参数类型 |
|------|------|---------|
| source | 要进行操作的字段 | string |

1、配置
```
input {
	redis {
		key => "logstash-extractnumbers"
		host => "localhost"
		password => "dailearn"
		port => 6379
		db => "0"
		data_type => "list"
		type  => "extractnumbers"
	}
}


filter {
		extractnumbers {
			source => "message"
			target => "message2"
		}
}


output {
	stdout { codec => rubydebug }
}

```

2、测试数据
```
zhangSan5,age16 + 0.5 456 789
```

3、控制台输出
```
{
        "float1" => 0.5,
          "int2" => 789,
          "int1" => 456,
    "@timestamp" => 2020-05-17T03:51:23.695Z,
      "@version" => "1",
          "type" => "extractnumbers",
       "message" => "zhangSan5,age16 + 0.5 456 789",
          "tags" => [
        [0] "_jsonparsefailure"
    ]
}

虽然文档中介绍，此过滤器会尝试提取出字符串中所有的字段，但是实际中部分和字母结合的字符串结构并没有被提取出来，而那些被字母和其他符号被包裹起来的数字没有被完整的提取出来，比如之前测试的时候使用的zhangSan5,age16 + 0.5,456[789],888这样的数据就没有任何内容被提取出来。
