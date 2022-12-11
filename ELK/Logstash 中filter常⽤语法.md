### 官方文档：https://blog.csdn.net/UbuntuTouch/article/details/100770828

# 一、介绍

## 1、grok插件

- grok是一个十分强大的logstash filter插件，他可以通过正则解析任意文本，将非结构化日志数据弄成结构化和方便查询的结构。他是目前logstash 中解析非结构化日志数据最好的方式。

Grok 的语法规则是：
```
%{语法: 语义}
```
- **语法**: 指的就是匹配的模式，例如使用NUMBER模式可以匹配出数字，IP模式则会匹配出127.0.0.1这样的IP地址：

### 1.1例如输入的内容为：
```
192.168.50.21 [08/Oct/2021:23:24:19 +0800] "GET / HTTP/1.1" 403 5039
```
那么，`%{IP:clientip}`匹配模式将获得的结果为：
```
clientip: 192.168.50.21
```

`%{HTTPDATE:timestamp}`匹配模式将获得的结果为：
```
timestamp: 08/Oct/2021:23:24:19 +0800
```

而`%{QS:referrer}`匹配模式将获得的结果为：
```
referrer: "GET / HTTP/1.1"
```

下面是一个组合匹配模式，它可以获取上面输入的所有内容：
```
%{IP:clientip}\ \[%{HTTPDATE:timestamp}\]\ %{QS:referrer}\ %{NUMBER:response}\ %{NUMBER:bytes}	
```

通过上面这个组合匹配模式，我们将输入的内容分成了五个部分，即五个字段，将输入内容分割为不同的数据字段，这对于日后解析和查询日志数据非常有用，这正是使用grok的目的。

Logstash默认提供了近200个匹配模式（其实就是定义好的正则表达式）让我们来使用，可以在logstash安装目录下，例如这里是/usr/local/logstash/vendor/bundle/jruby/1.9/gems/logstash-patterns-core-4.1.2/patterns目录里面查看，基本定义在grok-patterns文件中。

```
USERNAME [a-zA-Z0-9._-]+
USER %{USERNAME}
EMAILLOCALPART [a-zA-Z][a-zA-Z0-9_.+-=:]+
EMAILADDRESS %{EMAILLOCALPART}@%{HOSTNAME}
INT (?:[+-]?(?:[0-9]+))
BASE10NUM (?<![0-9.+-])(?>[+-]?(?:(?:[0-9]+(?:\.[0-9]+)?)|(?:\.[0-9]+)))
NUMBER (?:%{BASE10NUM})
BASE16NUM (?<![0-9A-Fa-f])(?:[+-]?(?:0x)?(?:[0-9A-Fa-f]+))
BASE16FLOAT \b(?<![0-9A-Fa-f.])(?:[+-]?(?:0x)?(?:(?:[0-9A-Fa-f]+(?:\.[0-9A-Fa-f]*)?)|(?:\.[0-9A-Fa-f]+)))\b
 
POSINT \b(?:[1-9][0-9]*)\b
NONNEGINT \b(?:[0-9]+)\b
WORD \b\w+\b
NOTSPACE \S+
SPACE \s*
DATA .*?
GREEDYDATA .*
QUOTEDSTRING (?>(?<!\\)(?>"(?>\\.|[^\\"]+)+"|""|(?>'(?>\\.|[^\\']+)+')|''|(?>`(?>\\.|[^\\`]+)+`)|``))
UUID [A-Fa-f0-9]{8}-(?:[A-Fa-f0-9]{4}-){3}[A-Fa-f0-9]{12}
# URN, allowing use of RFC 2141 section 2.3 reserved characters
URN urn:[0-9A-Za-z][0-9A-Za-z-]{0,31}:(?:%[0-9a-fA-F]{2}|[0-9A-Za-z()+,.:=@;$_!*'/?#-])+
# Networking
MAC (?:%{CISCOMAC}|%{WINDOWSMAC}|%{COMMONMAC})
CISCOMAC (?:(?:[A-Fa-f0-9]{4}\.){2}[A-Fa-f0-9]{4})
WINDOWSMAC (?:(?:[A-Fa-f0-9]{2}-){5}[A-Fa-f0-9]{2})
COMMONMAC (?:(?:[A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2})
IPV6 ((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?
IPV4 (?<![0-9])(?:(?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5]))(?![0-9])
IP (?:%{IPV6}|%{IPV4})
HOSTNAME \b(?:[0-9A-Za-z][0-9A-Za-z-]{0,62})(?:\.(?:[0-9A-Za-z][0-9A-Za-z-]{0,62}))*(\.?|\b)
IPORHOST (?:%{IP}|%{HOSTNAME})
HOSTPORT %{IPORHOST}:%{POSINT}
# paths
PATH (?:%{UNIXPATH}|%{WINPATH})
UNIXPATH (/([\w_%!$@:.,+~-]+|\\.)*)+
TTY (?:/dev/(pts|tty([pq])?)(\w+)?/?(?:[0-9]+))
WINPATH (?>[A-Za-z]+:|\\)(?:\\[^\\?*]*)+
URIPROTO [A-Za-z]([A-Za-z0-9+\-.]+)+
URIHOST %{IPORHOST}(?::%{POSINT:port})?
# uripath comes loosely from RFC1738, but mostly from what Firefox
# doesn't turn into %XX
URIPATH (?:/[A-Za-z0-9$.+!*'(){},~:;=@#%&_\-]*)+
#URIPARAM \?(?:[A-Za-z0-9]+(?:=(?:[^&]*))?(?:&(?:[A-Za-z0-9]+(?:=(?:[^&]*))?)?)*)?
URIPARAM \?[A-Za-z0-9$.+!*'|(){},~@#%&/=:;_?\-\[\]<>]*
URIPATHPARAM %{URIPATH}(?:%{URIPARAM})?
URI %{URIPROTO}://(?:%{USER}(?::[^@]*)?@)?(?:%{URIHOST})?(?:%{URIPATHPARAM})?
# Months: January, Feb, 3, 03, 12, December
MONTH \b(?:[Jj]an(?:uary|uar)?|[Ff]eb(?:ruary|ruar)?|[Mm](?:a|ä)?r(?:ch|z)?|[Aa]pr(?:il)?|[Mm]a(?:y|i)?|[Jj]un(?:e|i)?|[Jj]ul(?:y)?|[Aa]ug(?:ust)?|[Ss]ep(?:tember)?|[Oo](?:c|k)?t(?:ober)?|[Nn]ov(?:ember)?|[Dd]e(?:c|z)(?:ember)?)\b
MONTHNUM (?:0?[1-9]|1[0-2])
MONTHNUM2 (?:0[1-9]|1[0-2])
MONTHDAY (?:(?:0[1-9])|(?:[12][0-9])|(?:3[01])|[1-9])
# Days: Monday, Tue, Thu, etc...
DAY (?:Mon(?:day)?|Tue(?:sday)?|Wed(?:nesday)?|Thu(?:rsday)?|Fri(?:day)?|Sat(?:urday)?|Sun(?:day)?)
# Years?
YEAR (?>\d\d){1,2}
HOUR (?:2[0123]|[01]?[0-9])
MINUTE (?:[0-5][0-9])
# '60' is a leap second in most time standards and thus is valid.
SECOND (?:(?:[0-5]?[0-9]|60)(?:[:.,][0-9]+)?)
TIME (?!<[0-9])%{HOUR}:%{MINUTE}(?::%{SECOND})(?![0-9])
# datestamp is YYYY/MM/DD-HH:MM:SS.UUUU (or something like it)
DATE_US %{MONTHNUM}[/-]%{MONTHDAY}[/-]%{YEAR}
DATE_EU %{MONTHDAY}[./-]%{MONTHNUM}[./-]%{YEAR}
ISO8601_TIMEZONE (?:Z|[+-]%{HOUR}(?::?%{MINUTE}))
ISO8601_SECOND (?:%{SECOND}|60)
TIMESTAMP_ISO8601 %{YEAR}-%{MONTHNUM}-%{MONTHDAY}[T ]%{HOUR}:?%{MINUTE}(?::?%{SECOND})?%{ISO8601_TIMEZONE}?
DATE %{DATE_US}|%{DATE_EU}
DATESTAMP %{DATE}[- ]%{TIME}
TZ (?:[APMCE][SD]T|UTC)
DATESTAMP_RFC822 %{DAY} %{MONTH} %{MONTHDAY} %{YEAR} %{TIME} %{TZ}
DATESTAMP_RFC2822 %{DAY}, %{MONTHDAY} %{MONTH} %{YEAR} %{TIME} %{ISO8601_TIMEZONE}
DATESTAMP_OTHER %{DAY} %{MONTH} %{MONTHDAY} %{TIME} %{TZ} %{YEAR}
DATESTAMP_EVENTLOG %{YEAR}%{MONTHNUM2}%{MONTHDAY}%{HOUR}%{MINUTE}%{SECOND}
# Syslog Dates: Month Day HH:MM:SS
SYSLOGTIMESTAMP %{MONTH} +%{MONTHDAY} %{TIME}
PROG [\x21-\x5a\x5c\x5e-\x7e]+
SYSLOGPROG %{PROG:program}(?:\[%{POSINT:pid}\])?
SYSLOGHOST %{IPORHOST}
SYSLOGFACILITY <%{NONNEGINT:facility}.%{NONNEGINT:priority}>
HTTPDATE %{MONTHDAY}/%{MONTH}/%{YEAR}:%{TIME} %{INT}
# Shortcuts
QS %{QUOTEDSTRING}
# Log formats
SYSLOGBASE %{SYSLOGTIMESTAMP:timestamp} (?:%{SYSLOGFACILITY} )?%{SYSLOGHOST:logsource} %{SYSLOGPROG}:
# Log Levels
LOGLEVEL ([Aa]lert|ALERT|[Tt]race|TRACE|[Dd]ebug|DEBUG|[Nn]otice|NOTICE|[Ii]nfo|INFO|[Ww]arn?(?:ing)?|WARN?(?:ING)?|[Ee]rr?(?:or)?|ERR?(?:OR)?|[Cc]rit?(?:ical)?|CRIT?(?:ICAL)?|[Ff]atal|FATAL|[Ss]evere|SEVERE|EMERG(?:ENCY)?|[Ee]merg(?:ency)?)
```

参考:
- http://blog.csdn.net/liukuan73/article/details/52318243

date 过滤器配置选项

| 设置 | 输入类型 | 要求 |
| locale | string | No |
| match | array | No |
| tag_on_failure | array | No |
| target | string | No |
| timezone | string | No |

**实战**
```
input {
    stdin {
    }
}
filter{
     grok{
          match => {"message" => "\ \[%{HTTPDATE:timestamp}\]"}
     }
     date{
          match => ["timestamp","dd/MMM/yyyy:HH:mm:ss Z"]
     }
}
output {
    stdout {
    }
}
```




## 2、mutate插件

- mutate插件是用来处理数据的格式的，你可以选择处理你的时间格式，或者你想把一个字符串变为数字类型(当然需要合法)，同样的你也可以返回去做。可以设置的转换类型 包括： "integer"， "float" 和 "string"。

- add_field 增加字段
- remove_field 删除字段
- rename_field 重命名字段
- replace 修改字段的值(可以调用其他字段)
- update 修改字段的值(不可以调用其他字段)
- convert 字段类型转换
- copy 复制一个字段
- lowercase 值转小写
- uppercase 值转大写
- split 字段分割
- strip 去掉末尾空格
- gsub 正则替换，只对字符串类型有效

```
filter {
    mutate {
        #接收一个数组，其形式为value，type
        #需要注意的是，你的数据在转型的时候要合法，你总是不能把一个‘abc’的字符串转换为123的。
        convert => [
                    #把request_time的值装换为浮点型
                    "request_time", "float"，
                    #costTime的值转换为整型
                    "costTime", "integer"
                    ]
    }
}
```

## 3、ruby插件

- 官方对ruby插件的介绍是——无所不能。ruby插件可以使用任何的ruby语法，无论是逻辑判断，条件语句，循环语句，还是对字符串的操作，对EVENT对象的操作，都是极其得心应手的。
```
filter {
    ruby {
        #ruby插件有两个属性，一个init 还有一个code
        #init属性是用来初始化字段的，你可以在这里初始化一个字段，无论是什么类型的都可以，这个字段只是在ruby{}作用域里面生效。
        #这里我初始化了一个名为field的hash字段。可以在下面的coed属性里面使用。
        init => [field={}]
        #code属性使用两个冒号进行标识，你的所有ruby语法都可以在里面进行。
        #下面我对一段数据进行处理。
        #首先，我需要在把message字段里面的值拿到，并且对值进行分割按照“|”。这样分割出来的是一个数组(ruby的字符创处理)。
        #第二步，我需要循环数组判断其值是否是我需要的数据(ruby条件语法、循环结构)
        #第三步，我需要吧我需要的字段添加进入EVEVT对象。
        #第四步，选取一个值，进行MD5加密
        #什么是event对象？event就是Logstash对象，你可以在ruby插件的code属性里面操作他，可以添加属性字段，可以删除，可以修改，同样可以进行树脂运算。
        #进行MD5加密的时候，需要引入对应的包。
        #最后把冗余的message字段去除。
        code => "
            array=event。get('message').split('|')
            array.each do |value|
                if value.include? 'MD5_VALUE'
                    then 
                        require 'digest/md5'
                        md5=Digest::MD5.hexdigest(value)
                        event.set('md5',md5)
                end
                if value.include? 'DEFAULT_VALUE'
                    then
                        event.set('value',value)
                end
            end
             remove_field=>"message"
        "
    }
}
```

## 4、date插件

- date过滤器用于解析字段中的日期，然后使用该日期或时间戳作为事件的logstash时间戳。
- date插件是对于排序事件和回填旧数据尤其重要，它可以用来转换日志记录中的时间字段，变成LogStash::Timestamp对象，然后转存到@timestamp字段里，这在之前已经做过简单的介绍。

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
    }
}
output{
    stdout{
        codec => "rubydebug"
    }
}
```

## 5、json提取插件

- 这个插件也是极其好用的一个插件，现在我们的日志信息，基本都是由固定的样式组成的，我们可以使用json插件对其进行解析，并且得到每个字段对应的值。
```
filter{
    #source指定你的哪个值是json数据。
    json {
         source => "message"
    }
    #注意：如果你的json数据是多层的，那么解析出来的数据在多层结里是一个数组，你可以使用ruby语法对他进行操作，最终把所有数据都装换为平级的。
 
}
```

```
{
    "message" => "{\"name\":\"卡兹克\",\"age\":\"67\"}",
       "name" => "卡兹克",
        "age" => "67"
}
```

默认情况写解析出来的结果会存放在logstash信息的最上层，可以配置target将其保存在指定的字段下
```
filter{
    json {
        source => "message"
       # 将匹配的结果保存在test字段中
        target => "test"
    }
}
```

```
{
       "test" => {
        "name" => "卡兹克",
         "age" => "67"
    },
    "message" => "{\"name\":\"卡兹克\",\"age\":\"67\"}"
}
```

json插件还是需要注意一下使用的方法的，就是多层结构的弊端,对应的解决方案为：
```
ruby{
                code=>"
                  kv=event.get('content')[0]
                  kv.each do |k,v|
                  event.set(k,v)
                  end"
                  remove_field => ['content','value','receiptNo','channelId','status']
            }
```

Logstash filter组件的插件基本介绍到这里了，这里需要明白的是：

add_field、remove_field、add_tag、remove_tag 是所有 Logstash 插件都有。相关使用反法看字段名就可以知道。不如你也试试吧。。。。

# 二、使用

## 1、删除字段
```
filter {
    mutate {
      remove_field => [ "foo_%{somefield}" ]
    }
  }
```

## 2、添加字段
```
filter {
  mutate {
    split => { "hostname" => "." }
    add_field => { "shortHostname" => "%{[hostname][0]}" }
  }
}
```

## 3、转换字段类型
```
mutate{
    convert => {
      "ip" => "string"
    }
  }
```

## 4、重命名字段
```
# 将 'HOSTORIP' 字段重命名为 'client_ip'
  filter {
    mutate {
      rename => { "HOSTORIP" => "client_ip" }
    }
  }
```

## 5、修改字段值

- 将字段的值替换为新值，如果该字段不存在，则添加该字段。新值可以包含%{foo}字符串，以帮助您从事件的其他部分构建新值。
```
filter {
    mutate {
      replace => { "message" => "%{source_host}: My new message" }
    }
  }
```

## 6、字段取值
```
%{message}
```

## 7、条件判断语句

使用条件来决定filter和output处理特定的事件。logstash条件类似于编程语言。条件支持if、else if、else语句，可以嵌套。 比较操作有:

- 相等: `==`,`!=`,`<`,`>`,`<=`,`>=`
- 正则: `=~(匹配正则)`,`!~(不匹配正则)`
- 包含: `in`(包含),`not in`(不包含)
- 布尔操作: `and`(与),`or`(或),`nand`(非与),`xor`(非或)
- 一元运算符:
  - `!`(取反)
  - `()`(复合表达式)
  - `!()`(对复合表达式结果取反)

### 举个栗子

### 7.1在数组里检查一个会员
```
filter {
  mutate { lowercase => "account" }
  if [type] == "batch" {
    split { 
       field => actions 
       target => action 
    }
  }
 
  if { "action" =~ /special/ } {
    drop {}
  }
}
```

### 7.2根据条件删除当前消息
```
if "caoke" not in [docker]{
     drop {}
   }
   if "caoke" != [className]{
      drop {}
   }
```

### 7.3根据条件修改环境字段
```
if [http_host] {
    if  [http_host] =~ /test/ {
      mutate {
      replace => { "env" => "test" }
      }
    }else if "dev" in [http_host] {
      mutate {
      replace => { "env" => "dev" }
      }
    }
}
```
> if [foo] in "String" 在执行这样的语句是出现错误原因是没有找到叫做foo的field，无法把该字段值转化成String类型。所以最好要加field if exist判断。


### 7.4判断字段是否存在，代码如下:
```
if ["foo"] {
  mutate {
    add_field => { "bar" => "%{foo}"}
  }
}
example:
  filter{
      if "start" in [message]{
        grok{
          match => xxxxxxxxx
        }
      }else if "complete" in [message]{
        grok{
          xxxxxxxxxx
        }
      }else{
        grok{
          xxxxxxx
        }
      }
  }
```

## 8、过滤器

- Logstash具有一个有趣的功能，称为翻译过滤器 (translate filter)。 翻译过滤器用于根据字典或查找文件过滤传入数据中的特定字段。 然后，如果输入字段与字典查找文件中的条目匹配，则它将执行操作，例如，将字段添加到数据或发送电子邮件。这个和我们之前介绍的数据丰富是一样的。
```
input {
  generator {
    message => '83.149.9.216 - - [17/May/2015:10:05:50 +0000] "GET /presentations/logstash-monitorama-2013/images/kibana-dashboard.png HTTP/1.1" 200 321631 "http://semicomplete.com/presentations/logstash-monitorama-2013/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"'
    count => 1
  }
}
 
filter {
    grok {
        match => {
          "message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
        }
     }
 
    translate {
        field => "[response]"
        destination => "[http_status_description]"
        dictionary => {
            "100" => "Continue"
            "101" => "Switching Protocols"
            "200" => "OK"
            "500" => "Server Error"
        }
 
        fallback => "I'm a teapot"
    }
 
}
 
output {
    stdout {
        codec => rubydebug
    }
}
```
更多使用方法请参阅：https://elasticstack.blog.csdn.net/article/details/106888095

## 9、创建模板
```
PUT _template/temp_jiagou
{
  "order": 0,
  "index_patterns": [
    "jiagou-*"
  ],
  "settings": {
    "index": {
      "number_of_shards": "1",
      "number_of_replicas": "1",
      "refresh_interval": "5s"
    }
  },
  "mappings": {
    "_default_": {
      "properties": {
        "logTimestamp": {
          "type": "date",
          "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd HH:mm:ss.SSS||epoch_millis"
        },
        "partition": {
          "type": "integer"
        },
        "offset": {
          "type": "long"
        },
        "lineNum": {
          "type": "integer"
        }
      }
    }
  }
}
```
