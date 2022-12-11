->->[grok在线测试网站](https://www.5axxw.com/tools/v2/grok.html)-<-<

->->[grok官方匹配模式](https://github.com/elastic/logstash/tree/v1.4.2/patterns)-<-<

->->[正则表达式官方语法](https://github.com/kkos/oniguruma/blob/master/doc/RE)-<-<

# 一、grok介绍

- 描述任意文本并对其进行结构化
- 将非结构化日志数据解析为结构化和可查询的数据
- 语法：%{SYNTAX:SEMANTIC}
  - SYNTAX：要匹配的模式名称
  - SEMANTIC：为匹配的文本提供的标识符

# Grok默认表达式

- Logstash 内置了120种默认表达式，可以查看patterns，里面对表达式做了分组，每个文件为一组，文件内部有对应的表达式模式。下面只是部分常用的。

**常用表达式**

| 表达式标识 | 名称 | 详情 | 匹配例子 |
|-----------|------|-----|-----------|
| USERNAME 或 USER | 用户名 | 由数字、大小写及特殊字符`(._-)`组成的字符串 | 1234、Bob、Alex.Wong |
| EMAILLOCALPART | 用户名 | 首位由大小写字母组成，其他位由数字、大小写及特殊字符`(_.+-=:)`组成的字符串。注意，国内的QQ纯数字邮箱账号是无法匹配的，需要修改正则 | windcoder、windcoder_com、abc-123 |
| EMAILADDRESS | 电子邮件 |  | windcoder@abc.com、windcoder_com@gmail.com、abc-123@163.com |
| HTTPDUSER | Apache服务器的用户 | 可以是EMAILADDRESS或USERNAME |  |
| INT | 整数 | 包括0和正负整数 | 0、-123、43987 |
| BASE10NUM 或 NUMBER | 十进制数字 | 包括整数和小数 | 0、18、5.23 |
| BASE16NUM | 十六进制数字 | 整数 | 0x0045fa2d、-0x3F8709 |
| WORD | 字符串 | 包括数字和大小写字母 | String、3529345、ILoveYou |
| NOTSPACE | 不带任何空格的字符串 |  |  |
| SPACE | 空格字符串 |  |  |
| QUOTEDSTRING 或 QS | 带引号的字符串 |  | “This is an apple”、’What is your name?’ |
| UUID | 标准UUID |  | 550E8400-E29B-11D4-A716-446655440000 |
| MAC | MAC地址 | 可以是Cisco设备里的MAC地址，也可以是通用或者Windows系统的MAC地址 |  |
| IP | IP地址 | IPv4或IPv6地址 | 127.0.0.1、FE80:0000:0000:0000:AAAA:0000:00C2:0002 |
| HOSTNAME | IP或者主机名称 |  |  |
| HOSTPORT | 主机名(IP)+端口 |  | 127.0.0.1:3306、api.windcoder.com:8000 |
| PATH | 路径 | Unix系统或者Windows系统里的路径格式 | /usr/local/nginx/sbin/nginx、c:\windows\system32\clr.exe |
| URIPROTO | URI协议 | | http、ftp |
| URIHOST | URI主机 | | windcoder.com、10.0.0.1:22 |
| URIPATH | URI路径 | | //windcoder.com/abc/、/api.php |
| URIPARAM | URI里的GET参数 |  | ?a=1&b=2&c=3 |
| URIPATHPARAM | URI路径+GET参数 | /windcoder.com/abc/api.php?a=1&b=2&c=3 |  |
| URI | 完整的URI |  | https://windcoder.com/abc/api.php?a=1&b=2&c=3 |
| LOGLEVEL | Log表达式 | Log表达式 | Alert、alert、ALERT、Error |
| GREEDYDATA | 内容 | 匹配任意或多个除换行符。 | .* |

**日期时间表达式**

| 表达式标识 | 名称 | 匹配例子 |
|-----------|------|----------|
| MONTH | 月份名称 | Jan、January |
| MONTHNUM | 月份数字 | 03、9、12 |
| MONTHDAY | 日期数字 | 03、9、31 |
| DAY | 星期几名称 | Mon、Monday |
| YEAR | 年份数字 |  |
| HOUR | 小时数字 |  |
| MINUTE | 分钟数字 |  |
| SECOND | 秒数字 |  |
| TIME | 时间 | 00:01:23 |
| DATE_US | 美国时间 | 10-01-1892、10/01/1892/ |
| DATE_EU | 欧洲日期格式 | 01-10-1892、01/10/1882、01.10.1892 |
| ISO8601_TIMEZONE | ISO8601时间格式 | +10:23、-1023 |
| TIMESTAMP_ISO8601 | ISO8601时间戳格式 | 2016-07-03T00:34:06+08:00 |
| DATE | 日期 | 美国日期%{DATE_US}或者欧洲日期%{DATE_EU} |
| DATESTAMP | 完整日期+时间 | 07-03-2016 00:34:06 |
| HTTPDATE | http默认日期格式 | 03/Jul/2016:00:36:53 +0800 |


使用*GROK*模式解析*Nginx*正确访问日志，只需要*COMBINEDAPACHELOG*模式即可。

| 模式 | 规则 | 说明 |
|------|------|------|
| COMMONAPACHELOG | %{IPORHOST:clientip} %{HTTPDUSER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})" %{NUMBER:response} (?:%{NUMBER:bytes}|-) | 解析出clientip、ident、auth、timestamp、verb、request、httpversion、response、bytes信息。 |
| COMBINEDAPACHELOG | %{COMMONAPACHELOG} %{QS:referrer} %{QS:agent} | 解析出上一行中所有字段，另外还解析出referrer、agent字段。 |


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

# grok调试案例

## 实例一：
```
日志记录
55.3.244.1 GET /index.html 15824 0.043
 
grok表达式
%{IP:ip}\s*%{WORD:method}\s*%{URIPATHPARAM:url}\s*%{NUMBER:data}\s*%{NUMBER:duration}
```

日志的切分规则：ip地址 、method，请求路径、位数，消耗时间五部分
```
IP ===>55.3.244.1
WORD===>GET
URIPATHPARAM====>/index.html
NUMBER===>15824
NUMBER===>0.043
```

输出完整结果
```
{
  "ip": [
    [
      "55.3.244.1"
    ]
  ],
  "method": [
    [
      "GET"
    ]
  ],
  "url": [
    [
      "/index.html"
    ]
  ],
  "data": [
    [
      "15824"
    ]
  ],
  "duration": [
    [
      "0.043"
    ]
  ]
}
```

## 实例二：

```
日志记录
[2020-08-22 12:25:51.441] [TSC_IHU] [ERROR] [c.e.c.t.i.t.s.IhuTsaUplinkServiceImpl] Activation/Bind uplink, query UserSession by Token failure!
 
 
grok 表达式
\[%{TIMESTAMP_ISO8601:time}\]\s*%{DATA:thread}\s*\[%{LOGLEVEL:level}\]\s*%{GREEDYDATA:data}
```
日志切分规则：
- 日期（2020-08-22 12:25:51.441）
- 线程名称（TSC_IHU）
- 日志等级（ERROR）
- 内容（[c.e.c.t.i.t.s.IhuTsaUplinkServiceImpl] Activation/Bind uplink, query UserSession by Token failure!）

```
TIMESTAMP_ISO8601===》匹配日期（到毫秒的）
 
DATA===》TSC_IHU
 
LOGLEVEL===》匹配日志等级ERROR
 
GREEDYDATA===》匹配内容
```

输出完整结果
```
{
  "time": [
    [
      "2020-08-22 12:25:51.441"
    ]
  ],
  "thread": [
    [
      "[TSC_IHU]"
    ]
  ],
  "level": [
    [
      "ERROR"
    ]
  ],
  "data": [
    [
      "[c.e.c.t.i.t.s.IhuTsaUplinkServiceImpl] Activation/Bind uplink, query UserSession by Token failure!"
    ]
  ]
}
```

## 实例三

```
测试日志
2020-09-12 14:16:36.320+08:00 INFO 930856f7-c78f-4f12-a0f1-83a2610b2dfc DispatcherConnector ip-192-168-114-244 [Mqtt-Device-1883-worker-18-1] com.ericsson.sep.dispatcher.api.transformer.v1.MessageTransformer {"TraceID":"930856f7-c78f-4f12-a0f1-83a2610b2dfc","clientId":"5120916600003466K4GA1059","username":"LB37622Z3KX609880"}

grok表达式
%{TIMESTAMP_ISO8601:access_time}\s*%{LOGLEVEL:level}\s*%{UUID:uuid}\s*%{WORD:word}\s*%{HOSTNAME:hostname}\s*\[%{DATA:work}\]\s*(?<api>([\S+]*))\s*(?<TraceID>([\S+]*))\s*%{GREEDYDATA:message_data}
```

日志切分规则：
- 日期（2020-09-12 14:16:36.320+08:00）
- 日志等级（INFO）
- UUID（930856f7-c78f-4f12-a0f1-83a2610b2dfc）
- 字符串（DispatcherConnector ）
- 主机名称（ip-192-168-114-244）
- 线程（[Mqtt-Device-1883-worker-18-1）
- 请求api(com.ericsson.sep.dispatcher.api.transformer.v1.MessageTransformer)
- 内容（{"TraceID":"930856f7-c78f-4f12-a0f1-83a2610b2dfc","clientId":"5120916600003466K4GA1059","username":"LB37622Z3KX609880"}
）

```
TIMESTAMP_ISO8601===》匹配日期（到毫秒的）
LOGLEVEL===》匹配日志等级ERROR
UUID ===》匹配随机ID
WORD===>匹配任意字符串
HOSTNAME===》匹配主机名
DATA===》匹配线程
GREEDYDATA===》匹配内容
 
其中
(?<api>([\S+]*)) ====>匹配com.ericsson.sep.dispatcher.api.transformer.v1.MessageTransformer
(?<TraceID>([\S+]*))===》匹配{"TraceID":"930856f7-c78f-4f12-a0f1-83a2610b2dfc","clientId":"5120916600003466K4GA1059","username":"LB37622Z3KX609880"}
```

输出完整结果
```
{
  "access_time": [
    [
      "2020-09-12 14:16:36.320+08:00"
    ]
  ],
  "level": [
    [
      "INFO"
    ]
  ],
  "uuid": [
    [
      "930856f7-c78f-4f12-a0f1-83a2610b2dfc"
    ]
  ],
  "word": [
    [
      "DispatcherConnector"
    ]
  ],
  "hostname": [
    [
      "ip-192-168-114-244"
    ]
  ],
  "work": [
    [
      "Mqtt-Device-1883-worker-18-1"
    ]
  ],
  "api": [
    [
      "com.ericsson.sep.dispatcher.api.transformer.v1.MessageTransformer"
    ]
  ],
  "TraceID": [
    [
      "{"TraceID":"930856f7-c78f-4f12-a0f1-83a2610b2dfc","clientId":"5120916600003466K4GA1059","username":"LB37622Z3KX609880"}"
    ]
  ],
  "message_data": [
    [
      ""
    ]
  ]
}
```

## 实例四：

```
[12/Sep/2020:14:10:58 +0800] "GET /backend/services/ticketRemind/query?cid=&msgType=1&pageSize=100&pageIndex=1&langCode=zh HTTP/1.1" 200 91
 
 
grok表达式
\[%{HTTPDATE:access_time}\]\s*%{DATA:b}%{WORD:method}\s*%{URIPATH:url}%{URIPARAM:param}\s*%{URIPROTO:uri}%{DATA:c}%{NUMBER:treaty}%{DATA:d}\s*%{NUMBER:status}\s*%{NUMBER:latency_millis}
```

输出完整结果
```
{
  "access_time": [
    [
      "12/Sep/2020:14:10:58 +0800"
    ]
  ],
  "b": [
    [
      """
    ]
  ],
  "method": [
    [
      "GET"
    ]
  ],
  "url": [
    [
      "/backend/services/ticketRemind/query"
    ]
  ],
  "param": [
    [
      "?cid=&msgType=1&pageSize=100&pageIndex=1&langCode=zh"
    ]
  ],
  "uri": [
    [
      "HTTP"
    ]
  ],
  "c": [
    [
      "/"
    ]
  ],
  "treaty": [
    [
      "1.1"
    ]
  ],
  "d": [
    [
      """
    ]
  ],
  "status": [
    [
      "200"
    ]
  ],
  "latency_millis": [
    [
      "91"
    ]
  ]
}
```

## 实例五：

```
测试日志
192.168.125.138 - - [12/Sep/2020:14:10:58 +0800] "GET /backend/services/ticketRemind/query?cid=&msgType=1&pageSize=100&pageIndex=1&langCode=zh HTTP/1.1" 200 91
 
 
grok表达式
\s*%{IP:ip}\s*%{DATA:a}\s*\[%{HTTPDATE:access_time}\]\s*%{DATA:b}%{WORD:method}\s*%{URIPATH:url}%{URIPARAM:param}\s*%{URIPROTO:uri}%{DATA:c}%{NUMBER:treaty}%{DATA:d}\s*%{NUMBER:status}\s*%{NUMBER:latency_millis}
```

输出完整结果
```
{
  "ip": [
    [
      "192.168.125.138"
    ]
  ],
  "a": [
    [
      "- -"
    ]
  ],
  "access_time": [
    [
      "12/Sep/2020:14:10:58 +0800"
    ]
  ],
  "b": [
    [
      """
    ]
  ],
  "method": [
    [
      "GET"
    ]
  ],
  "url": [
    [
      "/backend/services/ticketRemind/query"
    ]
  ],
  "param": [
    [
      "?cid=&msgType=1&pageSize=100&pageIndex=1&langCode=zh"
    ]
  ],
  "uri": [
    [
      "HTTP"
    ]
  ],
  "c": [
    [
      "/"
    ]
  ],
  "treaty": [
    [
      "1.1"
    ]
  ],
  "d": [
    [
      """
    ]
  ],
  "status": [
    [
      "200"
    ]
  ],
  "latency_millis": [
    [
      "91"
    ]
  ]
}
```

**总结**：
1.首先要清楚日志的切分规则，然后根据每一个切分点套用grok提供的匹配表达式即可。



参考：
- https://blog.csdn.net/qq_38423256/article/details/117947020
- https://blog.csdn.net/feizuiku0116/article/details/124432215
