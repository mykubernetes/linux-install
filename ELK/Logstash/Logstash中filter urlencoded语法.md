# 对URL参数的数据进行的处理

- urlencoded过滤器主要是解码urlencoded的字段。有的时候我们传递的数据可能是被UrlEncode编码的此时就需要使用此过滤器

| 参数 | 作用 |
|------|------|
| all_fields | 是否解码所有字段 |
| field | 需要解码的目标字段 |
| charset | 解码的时候需要使用的字符编码 |

charset支持的参数(主要的一些)
- ASCII-8BIT
- UTF-8
- GB2312
- GBK
- ISO-8859系列 （ISO-8859-1 至 ISO-8859-16）
- UTF-16
- UTF-32
- ASCII等

# 例子

- 使用下面的配置就可以使用urlencoded过滤器

1、配置
```
input {
	redis {
		key => "logstash-urldecode"
		host => "localhost"
		password => "dailearn"
		port => 6379
		db => "0"
		data_type => "list"
		type  => "urldecode"
	}
}


filter {
	urldecode {
		all_fields => true
	}	
}


output {
	stdout { codec => rubydebug }
}

```

2、插入数据
```
%e5%a7%93%e5%90%8d%e6%98%af%e5%bc%a0%e4%b8%89%e5%b9%b4%e9%be%84%e6%98%af10
```

3、控制台输出
```
{
          "type" => "urldecode",
       "message" => "姓名是张三年龄是10",
    "@timestamp" => 2020-05-07T13:06:59.888Z,
      "@version" => "1",
          "tags" => [
        [0] "_jsonparsefailure"
    ]
}
```
