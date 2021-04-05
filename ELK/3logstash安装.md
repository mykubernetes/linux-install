四、安装Logstash  
https://github.com/logstash-plugins  


| 命令 | 详解 |
|----------------------|------------------|
| -f, --path.config CONFIG_PATH | 指定配置文件。使用文件，目录，或者通配符加载配置信息，如果指定目录或者通配符，按字符顺序加载。 |
| -e, --config.string CONFIG_STRING | 指定字符串输入 |
| -w, --pipeline.workers COUNT | 指定管道数量，默认3 |
| --log.level LEVEL | 指定Logstash日志级别,fatal/error/warn/info/debug/trace |
| -r，--config.reload.automatic | 配置文件自动重新加载。默认每3s检查一次配置文件更改。--config.reload.interval <interval> 修改时间间隔。如果没有启用自动加载，也可以向Logstash进程发送SIGHUP（信号挂起）信号重启管道，例如：kill -1 14175 |
| -t, --config.test_and_exit | 检查配置文件是否正确 |


条件判断
- 使用条件来决定filter和output处理特定的事件

比较操作
|语法|说明|
|----|-----|
| == | 等于 |
| != | 不等于 |
| < | 小于 |
| > | 大于 |
| <= | 小于等于 |
| >= | 大于等于 |
| =~ | 匹配正则 |
| !~ | 不匹配正则 |
| in | 包含 |
| not in | 不包含 |

布尔操作
| 语法 | 说明 |
|-----|----|
| and | 与 |
| or | 或 |
| nand | 非与 |
| xor | 非或 |

一元运算符
| 语法 | 说明 |
|-----|----|
| ! | 取反 |
| () | 复合表达式 |
| !() | 对复合表达式结果取反 |


条件if判断、多分支，嵌套
```
if EXPRESSION {
  ...
} else if EXPRESSION {
  ...
} else {
  ...
}
```

1、下载安装包  
``` 
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.6.1.rpm
yum install -y logstash-6.6.1.rpm
```  

2、测试logstash是否可用
```
/usr/share/logstash/bin/logstash -e 'input { stdin{} } output { stdout { codec => rubydebug}}'
```

示例
```
# 1、Stdin
input {
  stdin {

  }
}
filter {

}
output {
  stdout{codec => rubydebug }
}

# 2、file
# https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html
input {
  file {
     path =>"/var/log/messages"
     tags =>"nginx"
     tags =>"access"
     type =>"syslog"
  }
}
filter {

}
output {
  stdout{codec => rubydebug }
}

# 3、TCP
# 通过TCP套接字读取事件。与标准输入和文件输入一样，每个事件都被定位一行文本。
input {
  tcp {
     port =>12345
     type =>"nc"
  }
}
filter {

}
output {
  stdout{codec => rubydebug }
}

# nc 192.168.1.196 12345

# 4、Beats
# 从Elastic Beats框架接收事件
input {
  beats {
    port => 5044
  }
}
 
filter {
 
}

output {
  stdout { codec => rubydebug }
}
```

3、基本配置说明
```
# cat /etc/logstash/conf.d/system-log.conf 
input {
  file {
    path => "var/log/messages"                    #收集日志文件
    start_position => "beginning"                 #第一次启动是否读取以前文件内容"beginning"为读取以前内容
    type => "systemlog-node01"                    #打一个标签
    stat_interval => "2"                          #读取文件时间间隔
  }
}

output {
  elasticsearch {                                            #发生给elasticsearch
    hosts => ["192.168.1.70:9200"]                           #日志发送的主机
    index => "logstash-system-log-node01-%{+YYYY.MM.dd}"     #定义日志格式
  }
}
```  

4、配置logstash收集syslog日志  
```
vim /opt/module/logstash/config/logstash.conf
input {
   beats {
      port => 5044
   }
}

output {
   if "nginx" in [tags] {
      elasticsearch {
         hosts => "localhost:9200"
         index => "nginx-access-%{+YYYY.MM.dd}"
      }
    }
    
    if "tomcat" in [tags] {
      elasticsearch {
         hosts => "localhost:9200"
         index => "tomcat-catalina-%{+YYYY.MM.dd}"
       }
     }
}     
```  
参考https://www.elastic.co/guide/en/logstash/current/index.html  

5、启动logstash  
```
systemctl start logstash
```

json/json_lines
---
该解码器可用于解码（Input）和编码（Output）JSON消息。如果发送的数据是JSON数组，则会创建多个事件（每个元素一个）如果传输JSON消息以\n分割，就需要使用json_lines。
```
input {
  stdin {
     codec =>json {
        charset => ["UTF-8"]
     }
  }
}
filter {

}
output {
  stdout{codec => rubydebug }
}
```

multline匹配多行
---
| Setting | Input type | Required | Default | Description |
|---------|------------|----------|---------|-------------|
| auto_flush_interval | number | No | | |
| charset | string | No | UTF-8	| 输入使用的字符编码 |
| max_bytes | bytes	| No | 10M | 如果事件边界未明确定义，则事件的的积累可能会导致logstash退出，并出现内存不足。与max_lines组合使用 |
| max_lines | number | No | 500	| 如果事件边界未明确定义，则事件的的积累可能会导致logstash退出，并出现内存不足。与max_bytes组合使用 |
| multiline_tag | string | No	| multiline	| 给定标签标记多行事件 |
| negate | boolean | No | false | 正则表达式模式，设置正向匹配还是反向匹配。默认正向 |
| pattern | string | Yes | | 正则表达式匹配 |
| patterns_dir | array | No | [] | 默认带的一堆模式 |
| what | string, one of ["previous", "next"] | Yes | 无 | 设置未匹配的内容是向前合并还是向后合并 |

```
input {
  stdin {
    codec => multiline {
      pattern => "pattern, a regexp"
      negate => "true" or "false"
      what => "previous" or "next"
    }
  }
}
```

将JAVA堆栈跟踪是多行的，通常从最左边开始，每个后续行都缩进
```
input {
  stdin {
    codec => multiline {
      pattern => "^\s"
      what => "previous"
    }
  }
}
```

```
input {
  stdin {
    codec => multiline {
      pattern => "^\["
      negate => true
      what => "previous"
    }
  }
}
```

```
input {
  stdin {
    codec => multiline {
      # Grok pattern names are valid! :)
      pattern => "^%{TIMESTAMP_ISO8601} "
      negate => true
      what => "previous"
    }
  }
}
```

nginx日志转换成json格式
---
```
# vim  conf/nginx.conf
log_format access_json '{"@timestamp":"$time_iso8601",'
        '"host":"$server_addr",'
        '"clientip":"$remote_addr",'
        '"size":$body_bytes_sent,'
        '"responsetime":$request_time,'
        '"upstreamtime":"$upstream_response_time",'
        '"upstreamhost":"$upstream_addr",'
        '"http_host":"$host",'
        '"url":"$uri",'
        '"domain":"$host",'
        '"xff":"$http_x_forwarded_for",'
        '"referer":"$http_referer",'
        '"status":"$status"}';
    access_log  /var/log/nginx/access.log  access_json;
```  
配置logstash收集nginx日志
```
# vim nginx.conf 
input {
  file {
    path => "/var/log/nginx/access.log"
    start_position => "end"
    type => "nginx-accesslog"
    codec => json
  }
}


output {
  if [type] == "nginx-accesslog" {
    elasticsearch {
      hosts => ["192.168.56.11:9200"]
      index => "logstash-nginx-accesslog-node01-%{+YYYY.MM.dd}"
  }}
}
```  

tomcat日志转换成json格式
---
1、把tomcat日志格式转换成json
```
vim conf/server.xml
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="tomcat_access_log" suffix=".log"
               pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;ClientUser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;AccessTime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;SendBytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;AgentVersion&quot;:&quot;%{User-Agent}i&quot;}"/> 
```  

2、配置logstash收集tomcat日志  
```
# cat /etc/logstash/conf.d/tomcat.conf 
input {
  file {
    path => "/usr/local/tomcat/logs/localhost_access_log.*.txt"
    start_position => "end"
    type => "tomct-access-log"
  }
}

output {
  if [type] == "tomct-access-log" {
    elasticsearch {
      hosts => ["192.168.56.11:9200"]
      index => "logstash-tomcat-node01-access-%{+YYYY.MM.dd}"
      codec => "json"
    }
  }
}
```  

验证日志是否json格式
---
http://www.kjson.com/


配置logstash服务并收集beats日志
---
```
# cat beats-node01.conf 
input {
        beats {
        port => 5044          #重新开启一个端口
        codec => "json"
        }
}

output {
  if [type] == "system-log-node01" {
  redis {
    host => "192.168.56.12"
    port => "6379"
    db => "1"
    key => "system-log-5612"
    data_type => "list"
    password => "123456"
 }}
  if [type] == "tomcat-accesslog-node01" {
  redis {
    host => "192.168.56.12"
    port => "6379"
    db => "0"
    key => "tomcat-accesslog-node01"
    data_type => "list"
    password => "123456"
 }} 
}

```  

配置logstash收集redis并发生到elasticsearch
---
```
# cat  redis-es.conf
input {
  redis {
    host => "192.168.56.12"
    port => "6379"
    db => "1"
    key => "system-log-node01"
    data_type => "list"
    password => "123456"
 }
  redis {
    host => "192.168.56.12"
    port => "6379"
    db => "0"
    key => "tomcat-accesslog-node01"
    data_type => "list"
    password => "123456"
    codec  => "json" #对于json格式的日志定义编码格式
 } 
}

output {
  if [type] == "system-log-node01" {
    elasticsearch {
      hosts => ["192.168.56.12:9200"]
      index => "logstash-system-log-node01-%{+YYYY.MM.dd}"
}}
  if [type] == "tomcat-accesslog-node01" {
    elasticsearch {
      hosts => ["192.168.56.12:9200"]
      index => "logstash-tomcat-accesslog-node01-%{+YYYY.MM.dd}"
}}
}
```

将日志写入kafka，并取出写入elasticsearch
---
```
input {
  file {
    path => "/var/log/nginx/access.log"
    type => "nginx-access-log-node01"
    start_position => "beginning"
    stat_interval => "2"
    codec => "json"
  }
  file {
    path => "/var/log/messages"
    type => "systme-log-node01"
    start_position => "beginning"
    stat_interval => "2"
  }
}

output {
  if [type] == "nginx-access-log-node01" {
    kafka {
      bootstrap_servers => "192.168.101.66:9092"
      topic_id => "nginx-accesslog-node01"
      codec => "json"
        }
  }
  if [type] == "system-log-node01" {
    kafka {
      otstrap_servers => "192.168.101.66:9092"
      topic_id => "system-log-node01"
      codec => "json"
    }
  }
}
```  

```
input {
  kafka {
    bootstrap_servers => "192.168.101.66:9092"
    topics => "nginx-accesslog-node01"
    group_id => "nginx-access-log"
    codec => "json"
    consumer_threads => 1
    decorate_events => true
  }
   kafka {
    bootstrap_servers => "192.168.101.66:9092"
    topics => "system-log-node01"
    group_id => "systemlog-log"
    codec => "json"
    consumer_threads => 1
    decorate_events => true
  }
}

output {
  if [type] == "nginx-access-log-node01" {
  elasticsearch {
    hosts => ["192.168.101.66:9200"]
    index => "logstash-nginx-access-log-node01-%{+YYYY.MM.dd}"
    }
  }
  if [type] == "system-log-node01" {
  elasticsearch {
    hosts => ["192.168.101.66:9200"]
    index => "systemlog-log-node01-%{+YYYY.MM}"
    }
  }
}
```  

过滤器插件（Filter）
---
- Filter：过滤，将日志格式化。有丰富的过滤插件：Grok正则捕获、date时间处理、JSON编解码、数据修改Mutate等。

所有的过滤器插件都支持以下配置选项
| Setting	| Input type | Required	| Default	| Description |
|---------|-------------|---------|---------|--------------|
| add_field | hash | No | {} | 如果过滤成功，添加任何field到这个事件。例如：add_field => [ "foo_%{somefield}", "Hello world, from %{host}" ]，如果这个事件有一个字段somefiled，它的值是hello，那么我们会增加一个字段foo_hello，字段值则用%{host}代替。 |
| add_tag | array | No | [] | 过滤成功会增加一个任意的标签到事件例如：add_tag => [ "foo_%{somefield}" ] |
| enable_metric | boolean | No | true | |
| id | string | No | | |	
| periodic_flush | boolean | No | false | 定期调用过滤器刷新方法 |
| remove_field | array | No | [] | 过滤成功从该事件中移除任意filed。例：remove_field => [ "foo_%{somefield}" ] |
| remove_tag | array | No | [] | 过滤成功从该事件中移除任意标签，例如：remove_tag => [ "foo_%{somefield}" ] |

1、json
- JSON解析过滤器，接收一个JSON的字段，将其展开为Logstash事件中的实际数据结构。当事件解析失败时，这个插件有一个后备方案，那么事件将不会触发，而是标记为_jsonparsefailure，可以使用条件来清楚数据。也可以使用tag_on_failure

```
input {
  stdin {
  }
}

filter {
  json {
    source => "message"
    target => "content"
  }
}
output {
  stdout{codec => rubydebug }
}
```

2、kv
- 自动解析key=value。也可以任意字符串分割数据。field_split  一串字符，指定分隔符分析键值对

```
filter {
  kv {
     field_split => "&?"             #根据&和?分隔
  }
}
```

3、grok
- grok是将非结构化数据解析为结构化。这个工具非常适于系统日志，mysql日志，其他Web服务器日志以及通常人类无法编写任何日志的格式。

```
filter {
  grok {
    match => { 
       "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}" 
    }
  }
}
```
