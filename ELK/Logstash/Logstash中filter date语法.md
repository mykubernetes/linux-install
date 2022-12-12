# date插件

- date插件是对于排序事件和回填旧数据尤其重要，它可以用来转换日志记录中的时间字段，变成LogStash::Timestamp对象，然后转存到@timestamp字段里，这在之前已经做过简单的介绍。

**Date过滤器配置选项**

| 设置 | 作用 | 输入类型 | 要求 |
|------|---------|------|------|
| locale | 指定用于日期解析的区域设置 | tring | No |
| match | 如何匹配时间格式 | array | No |
| tag_on_failure | 匹配失败后追加的内容 | array | No |
| target | 匹配成功后的内容需要设置的目标字段 | string | No |
| timezone | 指定用于日期解析的时区规范ID | string | No |

timezone: 指定用于日期解析的时区规范ID，有效的id列在[Joda.org可用时区页面](https://joda-time.sourceforge.net/timezones.html)上，这在无法从值中提取时区时非常有用，而且不是平台默认值。如果没有指定，将使用平台默认值，Canonical ID很好，因为它为你处理了夏令时，例如，America/Los_Angeles或Europe/Paris是有效的id。该字段可以是动态的，并使用%{field}语法包含事件的一部分。



**日期格式说明**

| 时间字段 | 字母 | 表示含义 |
|----------|------|---------|
| 年 | yyyy | 表示全年号码。 例如：2021 |
| 年 | yy | 表示两位数年份。 例如：2021年即为21 |
| 月 | M | 表示1位数字月份，例如：1月份为数字1，12月份为数字12 |
| 月 | MM | 表示两位数月份，例如：1月份为数字01，12月份为数字12 |
| 月 | MMM | 表示缩短的月份文本，例如：1月份为Jan，12月份为Dec |
| 月 | MMMM | 表示全月文本，例如：1月份为January，12月份为December |
| 日 | d | 表示1位数字的几号，例如8表示某月8号 |
| 日 | dd | 表示2位数字的几号，例如08表示某月8号 |
| 时 | H | 表示1位数字的小时，例如1表示凌晨1点 |
| 时 | HH | 表示2位数字的小时，例如01表示凌晨1点 |
| 分 | m | 表示1位数字的分钟，例如5表示某点5分 |
| 分 | mm | 表示2位数字的分钟，例如05表示某点5分 |
| 秒 | s | 表示1位数字的秒，例如6表示某点某分6秒 |
| 秒 | ss | 表示2位数字的秒，例如06表示某点某分6秒 |
| 时区 | Z | 表示时区偏移，结构为HHmm，例如：+0800 |
| 时区 | ZZ | 表示时区偏移，结构为HH:mm，例如：+08:00 |
| 时区 | ZZZ | 表示时区身份，例如Asia/Shanghai |


```
input{
    stdin{}
}
filter {
    grok {
        match => ["message", "%{HTTPDATE:timestamp}"]
    }
    date {
        match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"]
        timezone => ""
        target => "@timestamp"
    }
}
output{
    stdout{
        codec => "rubydebug"
    }
}
```

## 例子

1、配置
```
input {
	redis {
		key => "logstash-date"
		host => "localhost"
		password => "dailearn"
		port => 6379
		db => "0"
		data_type => "list"
		type  => "date"
	}
}


filter {
	date {
		match => [ "message", "yyyy-MM-dd HH:mm:ss" ]
		locale => "Asia/Shanghai"
		timezone => "Europe/Paris"
		target => "messageDate"
	}	
}


output {
	stdout { codec => rubydebug }
}
```

2、测试数据
```
2020-05-07 23:59:59
```

3、控制台输出
```
{
     "@timestamp" => 2020-05-12T13:47:26.094Z,
           "type" => "date",
           "tags" => [
        [0] "_jsonparsefailure"
    ],
       "@version" => "1",
        "message" => "2020-05-07 23:59:59",
    "messageDate" => 2020-05-07T21:59:59.000Z
}
```

参考：
- https://segmentfault.com/a/1190000016615152
