# 一、kv介绍

用于解析key=value类型的消息，可以配置任意字符串来拆分数据，不一定非要用=符号，kv对的间隔也不一定非要用空格

# 二、allow_duplicate_values

- 功能：允许重复键值对
- 介绍：默认为true，两个相同的键值对都会被放到数组中，如果设置为false，则相同的键值对只会显示一个
```
filter{
    kv {
        source => "message"
        # 允许重复键值对
        allow_duplicate => "true"
    }
}
```

```
{
    "age": [
        "20",
        "20"
    ],
    "message": "name=瑞文 age=20 name=瑞文 age=20",
    "name": [
        "瑞文",
        "瑞文"
    ]
}
```

```
filter{
    kv {
        source => "message"
        # 不允许重复键值对
        allow_duplicate => "false"
    }
}
```

```
{
    "age": "20",
    "message": "name=瑞文 age=20 name=瑞文 age=20",
    "name": "瑞文",
}
```

# 三、allow_empty_values

- 功能：允许空值
- 介绍：默认为false，不允许空值，如果配置为true，则可以匹配name=这样的字符
```
filter{
    kv {
        source => "message"
        # 允许空字段
        allow_empty_values => "true"
    }
}
```

```
{
    "message": "name=",
    "name": "",
}
```

```
filter{
    kv {
        source => "message"
        # 不允许空字段
        allow_empty_values => "false"
    }
}
```

```
{
    "message": "name="
}
```


# 四、default_keys

- 功能：添加默认的key
- 介绍：如果匹配的内容中不含有指定的key，就将key添加到字段中，指定的数组内元素数量必须为双数，单数下标的元素是value，双数下标的元素是key（0基）
```
filter{
    kv {
        source => "message"
        # 添加默认键值对
        default_keys => ["from","123@com"]
    }
}
```

```
{
    "from": "123@com",
    "message": "name=奥拉夫",
    "name": "奥拉夫"
}
```

```
filter{
    kv {
        source => "message"
    }
}
```

```
{
    "message": "name=奥拉夫",
    "name": "奥拉夫"
}
```

# 五、recursive

- 功能：递归解析字段
- 介绍：默认为false，如果设置为true，字段中只要还有=符号就一直解析，放到子字段中

```
filter{
    kv {
        source => "message"
        # 递归解析字段
        recursive => "true"
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=type1=type2=战士",
       "name" => "泰达米尔",
        "age" => "20",
       "type" => {
        "type1" => {
            "type2" => "战士"
        }
    }
}
```

```
filter{
    kv {
        source => "message"
        remove_field => [
            "log","@timestamp","@version","tags","service","host","event"
        ]
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=type1=type2=战士",
       "name" => "泰达米尔",
        "age" => "20",
       "type" => "type1=type2=战士"
}
```


# 六、field_split

- 功能：字段拆分字符
- 介绍：默认为" "，可以更改拆分键值对的间隔字符，用正则表示，可以指定多个字符，多个字符是或的关系

```
filter{
    kv {
        source => "message"
        # 将键值对的分隔符修改为&
        field_split => "&"
    }
}
```

```
{
    "sex": "男",
    "message": "name=泰隆&age=19&sex=男",
    "name": "泰隆",
    "age": "19"
}
```

```
filter{
    kv {
        source => "message"
    }
}
```

```
{
    "message": "name=泰隆&age=19&sex=男",
    "name": "泰隆&age=19&sex=男"
}
```

```
filter{
    kv {
        source => "message"
        # 使用&或者?作为分隔字符
        field_split => "&?"
    }
}
```

```
{
    "sex": "男",
    "message": "name=泰隆&age=19&sex=男?type=刺客",
    "name": "泰隆",
    "age": "19",
    "type": "刺客"
}
```

# 七、field_split_pattern

- 功能：字段分隔正则匹配模式
- 介绍：优先级高于field_split，可以自定义需要正则模式匹配键值对间隔

```
filter{
    kv {
        source => "message"
        # 匹配一个或多个:
        field_split_pattern => ":+"
    }
}
```

```
{
    "sex": "男",
    "message": "name=泰隆:age=19::sex=男::::::type=刺客",
    "name": "泰隆",
    "age": "19",
    "type": "刺客"
}
```

```
filter{
    kv {
        source => "message"
        # 匹配两个+
        field_split_pattern => "\+\+"
    }
}
```

```
{
         "k4" => "v4",
    "message" => "k1=v1++k2=v2++k3=v3++k4=v4",
         "k3" => "v3",
         "k2" => "v2",
         "k1" => "v1"
}
```

# 八、include_brackets

- 功能：排除括号
- 介绍：默认为true，会将(123)这种value识别为123，忽略两遍的括号

```
filter{
    kv {
        source => "message"
        # 排除字段中的括号
        include_brackets => "true"
    }
}
```

```
{
        "age" => "20",
    "message" => "name=(泰达米尔) age=(20)",
       "name" => "泰达米尔"
}
```

```
filter{
    kv {
        source => "message"
        # 不排除字段中的括号
        include_brackets => "false"
    }
}
```

```
{
        "age" => "(20)",
    "message" => "name=(泰达米尔) age=(20)",
       "name" => "(泰达米尔)"
}
```

# 九、exclude_keys

- 功能：排除字段
- 介绍：在匹配到的键值对中，把指定key的键值对排除掉

```
filter{
    kv {
        source => "message"
        # 排除age字段
        exclude_keys => ["age"]
    }
}
```

```
{
    "sex": "男",
    "message": "name=泰隆 age=19 sex=男",
    "name": "泰隆"
}
```

```
filter{
    kv {
        source => "message"
    }
}
```

```
{
    "sex": "男",
    "age": "19",
    "message": "name=泰隆 age=19 sex=男",
    "name": "泰隆"
}
```

# 十、include_keys

- 功能：添加字段
- 介绍：默认为匹配到的全体数组，如果设置了这一项，则只显示这一项配置的匹配到的字段

```
filter{
    kv {
        source => "message"
        # 只显示匹配到的name和age字段
        include_keys => ["name","age"]
    }
}
```

```
{
        "age" => "20",
    "message" => "name=泰达米尔 age=20 type=战士",
       "name" => "泰达米尔"
}
```

```
filter{
    kv {
        source => "message"
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=战士",
       "name" => "泰达米尔",
        "age" => "20",
       "type" => "战士"
}
```

# 十一、prefix

- 功能：添加字段前缀
- 介绍：设置一个字符串，可以添加到所有匹配到的key中

```
filter{
    kv {
        source => "message"
        # 在匹配到的key中添加test_前缀
        prefix => "test_"
    }
}
```

```
{
      "message" => "name=泰达米尔 age=20 type=战士",
     "test_age" => "20",
    "test_type" => "战士",
    "test_name" => "泰达米尔"
}
```

```
filter{
    kv {
        source => "message"
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=战士",
       "name" => "泰达米尔",
        "age" => "20",
       "type" => "战士"
}
```

# 十二、remove_char_key

- 功能：移除key中的字符串
- 介绍：指定符号，删除key中的这些符号，支持正则表达式

```
filter{
    kv {
        source => "message"
       # 删除key中包含的指定字符
        remove_char_key => "+-"
    }
}
```

```
{
     "type" => "战士",
    "message" => "+name=泰达米尔 a-ge=20 ty+-pe=战士",
      "name" => "泰达米尔",
       "age" => "20"
}
```

# 十三、remove_char_value

- 功能：移除value中的字符串
- 介绍：指定符号，删除value中的这些符号，支持正则表达式
```
filter{
    kv {
        source => "message"
       # 删除value中包含的指定符号
        remove_char_value => "<>"
    }
}
```

```
{
    "message" => "name=泰达<米尔 age=2>0 type=战<>士",
       "name" => "泰达米尔",
       "type" => "战士",
        "age" => "20"
}
```

# 十四、source

- 功能：指定要执行key=value的字段
- 介绍：指定一个字段按照key=value进行解析，默认解析message字段，也可以指定其他字段

```
input{
    syslog{
        port => "514"
       # 添加一个字段
        add_field => {"test" => "testKey=testValue"}
    }

}
filter{
    kv {
    	# 将解析字段变为test
        source => "test"
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=战士",
       "test" => "testKey=testValue",
    "testKey" => "testValue"
}
```

# 十五、target

- 功能：目标字段
- 介绍：将key=value解析出来的结果放到指定的字段下，默认键值对在最外层

```
filter{
    kv {
        source => "message"
       # 将解析出来的结果保存到test字段下
        target => "test"
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=战士",
       "test" => {
        "name" => "泰达米尔",
         "age" => "20",
        "type" => "战士"
    }
}
```

# 十六、transform_key

- 功能：改变key
- 介绍：可选值：lowercase、uppercase、capitalize，将key转换为选择的模式

```
filter{
    kv {
        source => "message"
       # 将key中的字母变为小写
        transform_key => "uppercase"
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=战士",
        "AGE" => "20",
       "NAME" => "泰达米尔",
       "TYPE" => "战士"
}
```

# 十七、transform_value

- 功能：改变value
- 介绍：可选值：lowercase、uppercase、capitalize，将value转换为选择的模式

```
filter{
    kv {
        source => "message"
       # 将value中的字母变为大写
        transform_value => "uppercase"
    }
}
```

```
{
    "message" => "name=泰达米尔 age=20 type=战士 sex=m",
       "name" => "泰达米尔",
       "type" => "战士",
        "sex" => "M",
        "age" => "20"
}
```

# 十八、trim_key

- 功能：修建key字段
- 介绍：类似于strip，可以自定义字符，支持正则，将key前后包含的指定字符删除

```
filter{
    kv {
        source => "message"
       # 将key中的指定字符删除
        trim_key => "<>"
    }
}
```

```
{
    "message" => "<name=泰达米尔 <age>=20 type=战士",
       "name" => "泰达米尔",
       "type" => "战士",
        "age" => "20"
}
```
  
```
filter{
    kv {
        source => "message"
    }
}
```
  
```
{
    "message" => "<name=泰达米尔 <age>=20 type=战士",
      "<name" => "泰达米尔",
       "type" => "战士",
      "<age>" => "20"
}
```

# 十九、trim_value

- 功能：修剪value字段
- 介绍：类似于strip，可以自定义字符，支持正则，将value前后包含的指定字符删除

```
filter{
    kv {
        source => "message"
       # 将value中的指定字符删除
        trim_value => "<>"
    }
}
```

```
{
    "message" => "name=泰达米尔<> age=<20> type=<><战士",
       "name" => "泰达米尔",
       "type" => "战士",
        "age" => "20"
}
```

```
filter{
    kv {
        source => "message"
    }
}
```

```
{
    "message" => "name=泰达米尔<> age=<20> type=<><战士",
       "name" => "泰达米尔<>",
       "type" => "<><战士",
        "age" => "20"
}
```
# 二十、value_split

- 功能：键值对分隔符
- 介绍：默认按照=符号拆分，可以更改拆分的符号，支持正则

```
filter{
    kv {
        source => "message"
       # 将key、value按照:分隔
        value_split => ":"
    }
}
```

```
{
    "message" => "name:泰达米尔 age:20 type:战士",
       "name" => "泰达米尔",
       "type" => "战士",
        "age" => "20"
}
```

# 二十二、value_split_pattern

- 功能：设置多字符键值对分隔符
- 介绍：value_split的升级版，可以支持多个字符作为分隔符，优先级高鱼value_split

```
filter{
    kv {
        source => "message"
       # 将键值对按照多个:进行匹配
        value_split_pattern => ":+"
    }
}
```

```
{
    "message" => "name::::泰达米尔 age:::20 type:战士",
       "name" => "泰达米尔",
       "type" => "战士",
        "age" => "20"
}
```

# 二十三、whitespace

- 功能：设置键值对匹配的空格模式
- 介绍：可选值为：lenient、strict，默认是lenient，等号两边有空格也可以匹配，如果改为strict，等号两边有空格就匹配不上了

```
filter{
    kv {
        source => "message"
       # 宽松模式匹配空格
        whitespace => "lenient"
    }
}
```

```
{
    "message" => "name= 泰达米尔  age=  20    type=战士",
       "name" => "泰达米尔",
       "type" => "战士",
        "age" => "20"
}
```

```
filter{
    kv {
        source => "message"
       # 严格模式匹配空格
        whitespace => "strict"
    }
}
```

```
{
    "message" => "name= 泰达米尔  age=  20    type=战士",
       "type" => "战士"
}
```

参考：
- https://blog.csdn.net/feizuiku0116/article/details/124480801
