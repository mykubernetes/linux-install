# 一、mutate插件介绍

## 1.描述

muatet过滤器允许用户对字段进行改变，可以重命名、替换和修改事件中的字段。

# 2.操作顺序
- coerce
- rename
- update
- replace
- convert
- gsub
- uppercase
- capitalize
- lowercase
- strip
- split
- join
- merge
- copy

# 二、convert

- 功能：类型转换
- 介绍：将目标字段转换为目标类型
- 类型介绍：
  - integer：将字段转换为整数,逗号分隔符和点小数 1,000=1000 1.000=1
  - integer_eu：将字段转换为整数,点分隔符和逗号小数 1,000=1 1.000=1000
  - float：将字段转换为浮点数,逗号分隔符和点小数
  - float_eu：将字段转换为浮点数,点分隔符和逗号小数
  - string：将字段转换为字符串
  - boolean：将字段转换为布尔值
    - true:1、1.0、“true”、“t”、“yes”、“y”、“1”、“1.0”
    - false:0、0.0、“false”、“f”、“no”、“n”、“0”、“0.0”、“”
    - 所有其他值直接通过而不进行转换并记录警告消息

```
filter{
    mutate{
        convert => {
            "message" => "integer"
            "[log][syslog][facility][code]" => "boolean"
        }
    }
}
```

```
{
    "log": {
        "syslog": {
            "facility": {
                "code": false,
                "name": "kernel"
            },
            "priority": 0,
            "severity": {
                "code": 0,
                "name": "Emergency"
            }
        }
    },
    "message": 173
}
```

# 三、copy

- 功能：复制
- 介绍：将现有字段复制到另一个字段，现有的目标字段将会被覆盖

```
filter{
    mutate{
    	# 将message的值复制给type
        copy => {
            "message" => "type"
        }
    }
}
```

# 四、gsub

- 功能：正则替换
- 介绍：将正则表达式与字段匹配，将匹配字符串替换为替换字符串

```
filter{
    mutate{
        gsub => [
        	# 将message字段中的所有a都替换成b
           # "message","a","b"
           # 支持正则替换
           "message","a+","b"
        ]
    }
}
```

# 五、join

- 功能：数组连接
- 介绍：使用分隔符连接数组，如果目标不是数组则不执行操作

```
filter{
    mutate{
    	# 将message字段按照空格拆分成数组
        split => {
            "message" => " "
        }
       # 将message数组按照,连接
        join => {
            "message" => ","
        }
    }
}
```

```
  {
         "event" => {
        "original" => "姚明 刘翔"
    },
       "message" => "姚明,刘翔",
}
```

# 六、lowercase

- 功能：小写转换
- 介绍：将字符串中的字母全部变为小写

```
filter {
    mutate {
    	# 将message字段变为小写
        lowercase => ["message"]
    }
}
```

```
{
      "event" => {
        "original" => "Python"
    },
    "message" => "python"
}
```


# 七、merge

- 功能：合并
- 介绍：将两个字段合并为一个数组

```
filter {
    mutate {
    	# 将@timestamp字段与message字段合并为数组
        merge => {
            "message" => "@timestamp"
        }
    }
}
```

```
{
    "@timestamp" => 2022-04-25T09:28:20.531150Z,
         "event" => {
        "original" => "Python"
    },
       "message" => [
        [0] "Python",
        [1] 2022-04-25T09:28:20.531150Z
    ]
}
```

# 八、coerce

- 功能：字段默认值
- 介绍：如果目标字段为空，则为该字段赋默认值

```
filter {
    mutate {
    	# 如果field1字段为空则设置为0
        coerce => {
            "field1" => 0
        }
    }
}
```

# 九、rename

- 功能：重命名
- 介绍：将目标字段重命名为新的名称，如果新的字段名原本就存在，则覆盖原来的字段

```
filter {
    mutate {
    	# 将@timestamp字段重命名为time
        rename => {
            "@timestamp" => "time"
        }
    }
}
```

```
{
       "time" => 2022-04-25T09:35:23.718005Z,
    "message" => "123"
}
```

```
filter {
    mutate {
    	# 将message字段覆盖为@timestamp的值
        rename => {
            "@timestamp" => "message"
        }
    }
}
```

```
{
      "event" => {
        "original" => "123"
    },
    "message" => 2022-04-25T09:36:55.760534Z
}
```

# 十、replace

- 功能：替换
- 介绍：将目标字段的值替换为新的值，如果该字段不存在，则添加该字段，新值中可以包含变量

```
filter{
      mutate {
      # 将message字段替换为新的值
        replace => {
            "message" => "这是被替换后的消息"
        }
      }
}
```

```
filter{
      mutate {
      # 将message字段替换为host.ip的值
        replace => {
            "message" => "%{[host][ip]}"
        }
      }
}
```

# 十一、split

- 功能：分隔
- 介绍：使用指定分隔符将字符串拆分为数组

```
filter {
    mutate {
        # 将message字段按照message分隔
        split => {
            "message" => " "
        }
        # 取出message分隔后的数组第一个元素
        add_field => {"姓名"=>"%{[message][0]}"}
        # 取出message分隔后的数组第二个元素
        add_field => {"性别"=>"%{[message][1]}"}
        # 取出message分隔后的数组第三个元素
        add_field => {"年龄"=>"%{[message][2]}"}
    }
}
```

# 十二、strip
-
-  功能：去除空格
- 介绍：去掉指定字段首尾的空格

```
filter {
    mutate {
        strip => ["message"]
    }
}
```

```
{
      "event" => {
        "original" => "  123   "
    },
    "message" => "123"
}
```

# 十三、update

- 功能：更新字段信息
- 介绍：更新指定字段的内容，如果字段不存在，则不执行任何操作

```
filter {
    mutate {
        update => {
            "message" => "新的字段信息"
        }
    }
}
```

```
{
      "event" => {
        "original" => "原本的字段信息"
    },
    "message" => "新的字段信息"
}
```

# 十四、uppercase

- 功能：字段内容大写
- 介绍：将指定字段的字母变为大写

```
filter {
    mutate {
        uppercase => ["message"]
    }
}
```

```
{
      "event" => {
        "original" => "Python"
    },
    "message" => "PYTHON"
}
```

```
十五、capitalize

- 功能：首字母大写
- 介绍：将字段内容的首字母变为大写

```
filter {
    mutate {
        uppercase => ["message"]
    }
}
```

```
{
      "event" => {
        "original" => "python"
    },
    "message" => "Python"
}
```
