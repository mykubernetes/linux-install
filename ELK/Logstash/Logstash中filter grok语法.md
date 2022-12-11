->->[grok在线测试网站](https://www.5axxw.com/tools/v2/grok.html)-<-<

->->[grok官方匹配模式](https://github.com/elastic/logstash/tree/v1.4.2/patterns)-<-<

->->[正则表达式官方语法](https://github.com/kkos/oniguruma/blob/master/doc/RE)-<-<

# 一、grok介绍

- 描述任意文本并对其进行结构化
- 将非结构化日志数据解析为结构化和可查询的数据
- 语法：%{SYNTAX:SEMANTIC}
  - SYNTAX：要匹配的模式名称
  - SEMANTIC：为匹配的文本提供的标识符

# 二、match：匹配

## 1.常规匹配

按照`%{SYNTAX:SEMANTIC}`语法进行匹配，将SYNTAX匹配到的内容保存到SEMANTIC字段中
```
filter{
    grok{
        match => { "message" => "%{IP:ip} %{NUMBER:number} %{WORD:word} %{URIPATHPARAM:uripathparam}"}
	}
}
```

```
{
    "message": "192.168.10.100 185 grok /index.html",
    "word": "grok",
    "number": "185",
    "ip": "192.168.10.100",
    "uripathparam": "/index.html"
}
```

## 2.转换数据类型

- 正常情况下匹配到的数据都是字符类型
- 目前支持转换int类型和float类型
- 格式：`%{NUMBER:num:int}`

```
filter{
    grok{
    	# 将转换的结果转换为整形
        match => {"message" , "%{NUMBER:number:int}"}
	}
}
```

```
{
    "message": "185.76",
    "number": 185
}
```

## 3.多项匹配
```
filter{
    grok{
    	# 如果第一个匹配不成功则匹配下一个
        match => [
            "message" , "%{IP:ip} %{NUMBER:number} %{WORD:word} %{URIPATHPARAM:uripathparam}",
            "message" , "%{IP:ip} %{WORD:word}"
		]
	}
}
```

```
{
    "message": "192.168.10.100 185 Jack /index.html",
    "word": "Jack",
    "number": "185",
    "ip": "192.168.10.100",
    "uripathparam": "/index.html"
}
```

```
{
    "word": "Jack",
    "message": "192.168.10.100 Jack",
    "ip": "192.168.10.100"
}
```

# 三 、配置项

## 1. patterns_dir

- 功能：自定义正则匹配模式
- 介绍：可以使用正则表达式自定义匹配的模式，通过路径引用

```
# ./patterns/extra
TEST_RE [0-9 A-F]{10,11}
```

```
filter{
    grok{
    	# 自定义正则表达式路径
        patterns_dir => ["./patterns"]
        match => { "message" => "%{TEST_RE:test_re}"}
	}
}
```

## 2. break_on_match

- 功能：匹配到一次之后直接退出
- 介绍：默认为true，match成功后不会继续下面的match，如果需要多次match，则需要关闭这个选项

```
filter{
    grok{
        break_on_match => "false"
        match => {
            "message" => "%{NUMBER:number1} %{WORD:name1}"
        }
        match => {
            "message" => "%{INT:int2} %{WORD:name2}"
        }
	}
}
```

```
{   
    "message": "173 Jack",
    "int2": "173",
    "number1": "173",
    "name1": "Jack",
    "name2": "Jack"
}
```

## 3. overwrite

- 功能：覆盖其他字段
- 介绍：overwrite指定的字段可以被其他同名字段覆盖

```
filter{
    grok{
        match => {
            "message" => "%{NUMBER:message} %{WORD:name}"
        }
        overwrite => ["message"]
	}
}
```

```
{
    "message": "173",
    "name": "Jack",
    "event": {
        "original": "173 Jack"
    }
}
```

# 4.target

- 功能：将匹配到的内容保存到指定字段中
- 介绍：正常匹配到的内容是在最外层的，使用这个配置项之后就可以将匹配到的内容封装到指定的字段中

```
filter{
    grok{
        match => {
            "message" => "%{NUMBER:number} %{WORD:name}"
        }
        target => "result"
	}
}
```

```
{
    "result": {
        "number": "173",
        "name": "Jack"
    },
    "message": "173 Jack"
}
```

参考：
- https://blog.csdn.net/feizuiku0116/article/details/124432215
