# 一、对事件中的数据进行处理

很多时候我们传入logstash的原始数据并不是我们所需要传输的最终数据，这个时候需要我们队数据进行处理。而filter用来进行数据处理的插件主要是下面几个
- alter：主要根据元素中的值，对其进行重新赋值
- mutate：主要对元素中的值，进行值的修改
- translate：一种字典操作，将元素中的值，替换为字典中的内容
- truncate：对超长字符串进行截短工作

# 二、alter

> 默认情况下未捆绑,需要使用`bin/logstash-plugin install logstash-filter-alter`进行安装

alter过滤器使您可以对时间中字段进行常规更改。

**可配置参数**

| 参数 | 作用 |
|------|------|
| coalesce | 给定一组参数，第一个元素为目标字段，它的值将被设置为后续多个参数中第一个非空的表达式 |
| condrewrite | 给定一组参数，第一个元素为目标字段，假如它的值等于后一位参数的值，则它的值被设置为第三位的参数 |
| condrewriteother | 给定一组参数分别是：目标字段、预设值、修改的字段、修改的值。目标字段的内容等于预期的值，则将该字段的内容更改为指定的值。 |

参数介绍

使用的例子

配置
```
    filter {
		json {
			source => "message"
		}	
		alter {
			coalesce => [
				"alter_field","%{desc}","%{name}"
			]
			condrewrite => [
				"name","test","condrewrite test"
			]
			condrewriteother => [
				"name","condrewriteother test","age",999    
			]
		}

    }

```

测试数据
- coalesce

coalesce会将指定参数赋值为第一个不为空的参数的值。所以在使用下面参数请求logstash的时候因为不存在desc的内容，此时alter_field会被赋值为那么的结果
```
{"name":"coalesce test"}
```

最终控制台结果
```
{
     "@timestamp" => 2020-05-17T05:15:28.509Z,
       "@version" => "1",
           "name" => "coalesce test",
    "alter_field" => "coalesce test",
           "type" => "alter"
}
```

- condrewrite

condrewrite类似一种参数转换，当目标字段等于某个值就被转换成另外一个内容。
```
{
          "name" => "test",
           "age" => 10
}
```

使用上面的数据， 在经过logstash的时候，因为name参数的匹配会使得其内容发生变化,最终可以得到下面的结果
```
{
    "@timestamp" => 2020-05-17T05:36:04.872Z,
      "@version" => "1",
          "name" => "condrewrite test",
          "type" => "alter2",
           "age" => 10
}
```

- condrewriteother

condrewriteother和condrewrite不同之处在于，condrewrite只是修改进行参数判断的元素，而condrewriteother是当目标参数符合判断时，其可以修改另外一个参数的值

比如使用下面参数
```
{"age":5,"name":"condrewriteother test"}
```

此参数最终会被转换为下面的结果
```
{
    "@timestamp" => 2020-05-17T05:41:19.012Z,
      "@version" => "1",
          "name" => "condrewriteother test",
          "type" => "alter3",
           "age" => "999"
}
```

ps.需要注意的是这里age被设置成了字符串格式。

# 二、mutate

允许对字段执行一般的修改。您可以在事件中重命名、删除、替换和修改字段。

**可配置参数**

| 参数 | 作用 |
|------|-----|
| convert | 将字段的值转换为其他类型，例如将字符串转换为整数 |
| copy | 将现有字段复制到另一个字段。 |
| gsub | 将正则表达式与字段值匹配，然后将所有匹配项替换为替换字符串。 |
| join | 用分隔符连接数组。对非数组字段不执行任何操作。 |
| lowercase | 将字符串转换为其小写形式 |
| merge | 合并两个数组或哈希字段。字符串字段将自动转换为数组 |
| coerce | 设置存在但为空的字段的默认值 |
| rename | 重命名一个或多个字段 |
| replace | 用新值替换字段的值。 |
| split | 使用分隔符将字段拆分为数组。 |
| strip | 从字段中删除空格。仅适用于前后空白字段。 |
| update | 用新值更新现有字段。如果该字段不存在，则不会采取任何措施。 |
| uppercase | 将字符串转换为对应的大写字母 |
| capitalize | 将字符串转换为它的大写等价物 |

使用的例子

配置
```
filter {
	mutate {
		split => {"split_field"=> "."}
		join => { "join_field" => "," }
		uppercase => [ "uppercase_field"]
		capitalize => [ "capitalize_field"]
	}
}
```

测试数据

现在结合上面的配置使用下面的测试数据
```
{
    "split_field": "abc.def.123.456",
    "uppercase": "sendMutate",
    "join_field": [
        "ab",
        "cd",
        "ef"
    ],
    "capitalize": "sendMutate"
}

```

最终可以得到下面的结果
```
{
         "split_field" => [
        [0] "abc",
        [1] "def",
        [2] "123",
        [3] "456"
    ],
     "uppercase_field" => "SENDMUTATE",
    "capitalize_field" => "Sendmutate",
          "@timestamp" => 2020-05-17T06:00:55.280Z,
            "@version" => "1",
                "type" => "mutate",
          "join_field" => "ab,cd,ef"
}
```

ps. 这里需要注意一下，在官方的文档中关于split提供了两个demo分别是下面内容，而实际使用中两个格式都是可以使用的
```
    filter {
      mutate {
         split => { "fieldname" => "," }
      }
    }
```

```
    mutate {
        split => ["hostname", "."]
    }
```

# 三、translate

使用已配置的散列和/或文件来确定替换值的工具。将事件中的特殊key替换为字典中的对应内容

**可配置参数**

| 参数 | 作用 |
|------|-----|
| destination | 转换结果存放的字段 |
| dictionary | 进行数据转换的字典 |
| dictionary_path | 外部词典文件的完整路径 |
| exact |  |
| fallback | 如果事件中的key没有匹配成功，则使用此字段的值作为默认值 |
| field |  |
| iterate_on | 当您需要对处理的值是可变大小的数组时，此设置中指定字段名称。此设置引入两种模式，1）当值是字符串数组时，2）当值是对象数组时 |
| override | 如果指定的字段已存在，此参数设置是否跳过还是只想覆盖操作 |
| refresh_interval | 配置logstash以多久的间隔去刷新配置内容 |
| regex | 字典使用正则表达式匹配 |
| refresh_behaviour | 指定字段刷新策略，1.新旧字典合并；2.旧字段完全覆盖新字典 |

使用的例子

配置
```
    filter {
		translate {
			iterate_on => "area_list"
			field      => "area"
			destination => "area_des"
		    dictionary => {
    			  "CN" => "China"
    			  "FR" => "France"
    			  "US" => "America"
    			  "RU" => "Russia"
    			  "GB" => "britain"
			}
			fallback => "Unknown"
		}

    }
```

测试数据

使用下面的格式对字典库中匹配和不匹配的参数都尝试发出请求。
```
{ "area" => "GB",}
```

结果

最终可以得到下面的结果，此时根据area中的内容在area_description字段中填充字典中的值。
```
{
                "area" => "GB",
          "@timestamp" => 2020-05-17T04:53:39.511Z,
            "@version" => "1",
    "area_description" => "britain",
                "type" => "translate1"
}
{
                "area" => "RU",
          "@timestamp" => 2020-05-17T04:53:39.512Z,
            "@version" => "1",
    "area_description" => "Russia",
                "type" => "translate1"
}
{
                "area" => "US",
          "@timestamp" => 2020-05-17T04:53:39.512Z,
            "@version" => "1",
    "area_description" => "America",
                "type" => "translate1"
}
{
                "area" => "FR",
          "@timestamp" => 2020-05-17T04:53:39.513Z,
            "@version" => "1",
    "area_description" => "France",
                "type" => "translate1"
}
{
                "area" => "CN",
          "@timestamp" => 2020-05-17T04:53:39.513Z,
            "@version" => "1",
    "area_description" => "China",
                "type" => "translate1"
}
{
                "area" => "UK",
          "@timestamp" => 2020-05-17T04:53:39.481Z,
            "@version" => "1",
    "area_description" => "nuknow",
                "type" => "translate1"
}

```

**数组数据的字典库匹配**

对于一些数组格式的数据比如下面这种
```
{"area_list":["CN","FR","US","RU","GB","UK"]}
```

可以使用下面的配置进行数据格式的数据进行字典匹配
```
		translate {
			iterate_on => "area_list"
			field      => "area_list"
			destination => "area_name_list"
            dictionary => {
    			  "CN" => "China"
    			  "FR" => "France"
    			  "US" => "America"
    			  "RU" => "Russia"
    			  "GB" => "britain"
			}

			fallback => "Unknown"
		}

```

输出的结果同样是个数组格式
```
{
          "@version" => "1",
    "area_name_list" => [
        [0] "China",
        [1] "France",
        [2] "America",
        [3] "Russia",
        [4] "britain",
        [5] "Unknown"
    ],
         "area_list" => [
        [0] "CN",
        [1] "FR",
        [2] "US",
        [3] "RU",
        [4] "GB",
        [5] "UK"
    ],
              "type" => "translate2"
}
```

**嵌套数据的字典库匹配**

而对于嵌套的对象数组格式
```
{
    "area_list": [
        {
            "area": "CN"
        },
        {
            "area": "FR"
        },
        {
            "area": "US"
        },
        {
            "area": "RU"
        },
        {
            "area": "GB"
        },
        {
            "area": "UK"
        }
    ]
}
```

可以使用下面配置
```
		translate {
			iterate_on => "area_list"
			field      => "area"
			destination => "area_des"
		    dictionary => {
    			  "CN" => "China"
    			  "FR" => "France"
    			  "US" => "America"
    			  "RU" => "Russia"
    			  "GB" => "britain"
			}

			fallback => "Unknown"
		}

```

可以得到下面的结果
```
{
      "@version" => "1",
     "area_list" => [
        [0] {
                "area" => "CN",
            "area_des" => "China"
        },
        [1] {
                "area" => "FR",
            "area_des" => "France"
        },
        [2] {
                "area" => "US",
            "area_des" => "America"
        },
        [3] {
                "area" => "RU",
            "area_des" => "Russia"
        },
        [4] {
                "area" => "GB",
            "area_des" => "britain"
        },
        [5] {
                "area" => "UK",
            "area_des" => "Unknown"
        }
    ],
          "type" => "translate3"
}
```

# 四、truncate
用来截取超过一定长度的字符串，**这将截断字节值，而不是字符数**。

可配置参数

| 参数 | 作用 |
|------|-----|
| fields | 需要截断的字段 |
| length_bytes | 超过此长度的字段将被截断为该长度 |

使用的例子

配置
```
filter {
  truncate {
	fields => "message"
	length_bytes => 10
  }
}
```

测试数据

使用下面的数据经过logstash其长度会被截取掉，
```
abcdefghijabcdefghijaaaa
```

最终我们只能的到这样的结果。
```
{
    "@timestamp" => 2020-05-17T06:08:34.899Z,
      "@version" => "1",
       "message" => "abcdefghij",
          "type" => "truncate",
          "tags" => [
        [0] "_jsonparsefailure"
    ]
}

需要注意官方文档中冶专门强调
```
This truncates on bytes values, not character count. In practice, this should mean that the truncated length is somewhere between length_bytes and length_bytes - 6
```
