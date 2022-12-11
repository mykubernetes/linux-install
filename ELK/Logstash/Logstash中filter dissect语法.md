# dissect插件
基于分隔符原理解析数据，解决grok解析时消耗过多cpu资源的问题。

同样的日志信息，dissect可以这样来写：
```
83.149.9.216 [17/May/2015:10:05:03 +0000] "GET /presentations/logstash-monitorama-2013/images/kibana-search.png HTTP/1.1" 200 203023 "http://semicomplete.com/presentations/logstash-monitorama-2013/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"
```

dissect配置：
```
%{clientip} [%{timestamp}] "%{request}" %{response} %{bytes} "%{referrer}" "%{agent}"
```

但是，正因为dissect语法简单，因此它能处理的场景比较有限。它只能处理格式相似，且有分隔符的字符串。它的语法如下：
- %{}里面是字段
- 两个%{}之间是分隔符。

## 例子1： 有以下日志：
```
Apr 26 12:20:02 localhost systemd[1]: Starting system activity accounting tool
```

我想要把前面的日期和时间解析到同一个字段中，那么就可以这样来做：
```
filter {
    dissect {
        mapping => {
        	"message" => "%{ts} %{+ts} %{+ts} %{src} %{prog}[%{pid}]: %{msg}"
        }
    }
}
```

## 例子2： 如果有以下日志：
```
name=hushukang&age=28
```

我想要把它解析成：
```
{
	"name": "hushukang",
	"age": 28
}
```

那么，可以这样来写dissect:
```
filter {
    dissect {
        mapping => {
            "message" => "%{?key1}=%{&key1}&%{?key2}=%{&key2}"
        }
        convert_datatype => {
            age => "int"
        }
    }
}
```
- `%{?}`代表忽略匹配值，但是赋予字段名，用于后续匹配用。
- `%{&}`代表将匹配值赋到指定字段中。
- convert_datatype 可以将指定字符串转为int或者float类型。

