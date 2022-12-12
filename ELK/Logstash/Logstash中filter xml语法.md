# 对XML格式的数据进行的处理

- XML过滤器。主要是可以将获取包含XML的字段并将其展开为实际的数据结构。

| 参数 | 作用 |
|------|------|
| force_array | 默认情况下，过滤器将强制单个元素为数组。将其设置为false将防止在数组中存储单个元素。 |
| force_content | 默认情况下，过滤器将展开与标签内部内容不同的属性。使用此选项，您可以强制文本内容和属性始终解析为哈希值。 |
| namespaces | 默认情况下，仅考虑根元素上的名称空间声明。这允许配置所有名称空间声明以解析XML文档。 |
| remove_namespaces | 从文档中的所有节点中删除所有名称空间。当然，如果文档具有名称相同但名称空间不同的节点，则它们现在将是模糊的。 |
| store_xml | 默认情况下，过滤器将如上所述将整个解析的XML存储在目标字段中。将此设置为false可以防止这种情况。 |
| suppress_empty | 默认情况下，如果元素为空，则不输出任何内容。如果设置为false，则Empty元素将导致一个空对象。 |

# 例子

- 实际中XML过滤器使用起来也比较简单，下面配置中只配置了要解析的字段和目标字段

1、配置
```
input {
	redis {
		key => "logstash-xml"
		host => "localhost"
		password => "dailearn"
		port => 6379
		db => "0"
		data_type => "list"
		type  => "xml"
	}
}


filter {
	xml {
		source => "message"
		target => "messageXml"
	}	
}


output {
	stdout { codec => rubydebug }
}
```

2、插入数据

现在向Redis对应键中插入一条数据
```
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <name>张三</name>
  <age>10</age>
</user>
```

3、控制台输出
```
{
          "type" => "xml",
    "messageXml" => {
         "age" => [
            [0] "10"
        ],
        "name" => [
            [0] "张三"
        ]
    },
       "message" => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>\n<name>张三</name>\n<age>10</age>\n</user>",
    "@timestamp" => 2020-05-07T13:06:07.810Z,
      "@version" => "1",
          "tags" => [
        [0] "_jsonparsefailure"
    ]
}
```
