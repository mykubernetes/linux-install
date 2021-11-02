# 安装Logstash

https://github.com/logstash-plugins  


| 命令 | 详解 |
|----------------------|------------------|
| -f, --path.config CONFIG_PATH | 指定配置文件。使用文件，目录，或者通配符加载配置信息，如果指定目录或者通配符，按字符顺序加载。 |
| -e, --config.string CONFIG_STRING | 指定字符串输入 |
| -w, --pipeline.workers COUNT | 指定管道数量，默认3 |
| --log.level LEVEL | 指定Logstash日志级别,fatal/error/warn/info/debug/trace |
| -r，--config.reload.automatic | 配置文件自动重新加载。默认每3s检查一次配置文件更改。--config.reload.interval `<interval>` 修改时间间隔。如果没有启用自动加载，也可以向Logstash进程发送SIGHUP（信号挂起）信号重启管道，例如：kill -1 14175 |
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

2、自检-接收标准输入并输出到控制台
```
# bin/logstash -e 'input { stdin { } } output { stdout {} }'
输入 Hello
输出
    {
          "@version" => "1",
           "message" => "Hello",
        "@timestamp" => 2018-08-11T11:49:31.059Z,
              "host" => "localhost.local"
    }
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

# Mysql增量同步至 Kafka/Hdfs/Elasticsearch

## Mysql 测试库表

- 生产中一个库同一类数据一般会有多张分表如16张分表,256张分表。
```
#建库 user_logs
create database user_logs;

#建表-用户浏览日志表: user_browse_0_logs,user_browse_1_logs 如
CREATE TABLE `user_browse_0_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `event_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uid` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `event_time` (`event_time`) USING BTREE,
  KEY `uid_event_time` (`uid`,`event_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='用户浏览日志表';
```

## Logstash 配置

基础配置
```
#配置目录
[wangpei@localhost ~/software/logstash-6.3.2]$ mkdir db_test

#拷贝默认配置
[wangpei@localhost ~/software/logstash-6.3.2]$ cp config/* db_test/

#db_test/jvm.options
#jvm配置 
-Xms1g
-Xmx1g

#db_test/logstash.yml
#持久化目录 
#logstash和plugin任何需要持久化的数据都会放在这个目录
path.data: /Users/wangpei/software/logstash-6.3.2/data/user_browse_logs/data

#queue  
#默认memory,logstash进程重启会丢数据
queue.type: persisted

#并发度
pipeline.workers: 2

#每个线程从输入收集的最大数量
pipeline.batch.size: 125
```

## Input-Filter-Output配置
```
[wangpei@localhost ~/software/logstash-6.3.2]$ vim db_test/user_browse_logs.conf
#输入配置 jdbc插件
input {
  jdbc {
    #jdbc驱动
    jdbc_driver_library => "/Users/wangpei/software/logstash-6.3.2/mysql-connector-java-5.1.38.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    #jdbc连接
    jdbc_connection_string => "jdbc:mysql://node2:3306/user_logs"
    jdbc_user => "root"
    jdbc_password => "111"
    #任务调度
    schedule => "* * * * *"
    #上次运行的sql_last_value保存路径
    #启动前需要确保该文件已存在
    last_run_metadata_path => "/Users/wangpei/software/logstash-6.3.2/data/test/metadata/user_browse_0_logs"
    #sql语句
    #按主键自增id 增量同步
    #input在拿到字段为日期类型的数据时,一定会减8小时并带上时区信息
    #如原始mysql event_time字段为日期类型(这里是timestamp类型)的数据2018-08-12 14:38:24 =>经过input后=> 2018-08-12T14:38:24.000Z
    #不想让input修改原始数据,这里直接把event_time转成成字符串类型。
    statement => "SELECT id,product_id,DATE_FORMAT(event_time, '%Y-%m-%d %H:%i:%s') as event_time,uid FROM user_browse_0_logs WHERE id > :sql_last_value"
    #设置成true 用tracking_column列的值去更新上次记录的sql_last_value值
    use_column_value => true
    #追踪的列
    tracking_column => "id"
    #追踪的列的数据类型 支持["numeric", "timestamp"]
    tracking_column_type => "numeric"
    #插件id 便于监控
    id => "user_browse_logs_input_jdbc"
    #添加字段 表名 便于后期DQC 如mysql 每个分表的数据和HDFS每个分区数据count、sum验证
    add_field => {"table_name" => "user_browse_0_logs"}
    #input event输出格式 每个event转换成json+换行符格式
    codec => json_lines {charset => "UTF-8"}
  }
}

#Filter配置
filter {
  #默认会对每条数据加上@timestamp
  #不指定@timestamp字段来源,默认会以logstash服务器收到数据时间为准
  date {
        #匹配到这种格式就会替换成目标字段,目标字段默认是@timestamp
        #貌似不管怎么设置,Logstash中 @timestamp永远是0时区
        #@timestamp 0时区,数据写入ES，@timestamp 在Kibana上显示时会根据浏览器市区自动调整 如自动+8
        match => ["event_time" , "yyyy-MM-dd HH:mm:ss"]
        #timezone => "Asia/Shanghai"
    #target => "@timestamp"
    }
  #增加dt字段,该字段来源于event_time,用于hdfs按天分区、ES按天索引
  #总结:
  #假设源数据是北京时间
  #1)数据同步到ES:(需要兼顾kibana各种作图、Java/Python API查询)
  #   A、按北京时间建索引如下dt
  #   B、kibana可视化,时间选择用@timestamp时间字段,避免用event_time时间字段做不了Date Histogram问题。
  #   C、ES API查询,时间选择用event_time时间字段更方便。
  #2)数据同步到HDFS: 按北京时间分区 如下dt即可
  ruby {code => "event.set('dt', event.get('event_time')[0,10].gsub('-',''));"}
}

#输出配置
output {
  #输出到控制台
  stdout { codec => rubydebug}
  #输出到kafka
  kafka {
    #kafka brokers
    bootstrap_servers => "localhost:9092"
    #topic
    topic_id => "testTopic3"
    #ack
    acks => "1"
    #输出格式
    codec => json
    #id
    id => "user_browse_logs_ouput_kafka"
  }
  #输出到HDFS
  #需要开启HDFS 的webhdfs
  webhdfs {
    codec => json_lines {charset => "UTF-8"}
    #namenode
    host => 'node1'
    port => 50070
    #standby namenode
    standby_host => 'node4'
    standby_port => 50070
    #user
    user => 'root'
    #user需要对path有读写权限
    path => '/data/user_logs/user_browse_logs/%{dt}/%{table_name}.log'
    #攒到多少条event时向hdfs写一次数据
    flush_size => 3
    #间隔多久向hdfs写一次数据 单位:秒
    idle_flush_time => 2
  }
  #输出到elasticsearch
  elasticsearch {
         #es节点列表
         hosts => ["localhost:9200"]
         #索引使用的模板
         #模板中定义了mapping(日期Format,某个字段使用的分词器)和setting
     template_name => "template.user_browse_logs"
         #index
         #数据是北京时间,这个按北京时间建索引
         index => "user_browse_logs.%{dt}"
     #type
         document_type =>"browse_logs"
         #权限
         user => "logstash_input"
         password => "logstash_input"
         codec => json {charset => "UTF-8"}
    }
}
```

## 启动方式
```
#直接启动===> 一个input-filter-output配置独享一个logstash进程
[wangpei@localhost ~/software/logstash-6.3.2]$ bin/logstash --path.settings db_test/  -f db_test/user_browse_logs.conf --config.reload.automatic

#pipeline方式启动===> 多个input-filter-output配置共享一个logstash进程
[wangpei@localhost ~/software/logstash-6.3.2]$ bin/logstash --path.settings db_test/  --config.reload.automatic
需配置db_test/pipelines.yml
配置多个pipeline。每个pipeline可对应一个表(input-filter-output)。
- pipeline.id: user_logs.user_browse_logs
  queue.type: persisted
  pipeline.workers: 1
  queue.max_bytes: 32mb
  path.config: "/Users/wangpei/software/logstash-6.3.2/db_test/user_browse_logs.conf"

- pipeline.id: user_logs.user_pay_logs
  queue.type: persisted
  pipeline.workers: 1
  queue.max_bytes: 32mb
  path.config: "/Users/wangpei/software/logstash-6.3.2/db_test/user_pay_logs.conf"
  ...
```

## 结果

- mysql插入数据
```
insert into user_browse_0_logs(product_id,uid) values(1,"0");
insert into user_browse_0_logs(product_id,uid) values(2,"0");
insert into user_browse_0_logs(product_id,uid) values(3,"0");

mysql> select * from user_browse_0_logs;
+----+------------+---------------------+-----+
| id | product_id | event_time          | uid |
+----+------------+---------------------+-----+
|  1 |          1 | 2018-08-12 20:18:31 | 0   |
|  2 |          2 | 2018-08-12 20:18:31 | 0   |
|  3 |          3 | 2018-08-12 20:18:32 | 0   |
+----+------------+---------------------+-----+
```

kafka收到的数据
```
[wangpei@localhost ~/software/logstash-6.2.4]$ kafka-console-consumer --bootstrap-server localhost:9092 --topic testTopic3

{"@version":"1","dt":"20180812","product_id":3,"uid":"0","id":3,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:32","@timestamp":"2018-08-12T12:18:32.000Z"}
{"@version":"1","dt":"20180812","product_id":1,"uid":"0","id":1,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
{"@version":"1","dt":"20180812","product_id":2,"uid":"0","id":2,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
```

hdfs收到的数据
```
#分区:20180812
#分区下的文件:user_browse_0_logs.log user_browse_0_logs是表名
#该路径来自:output webhdfs path参数 path => '/data/user_logs/user_browse_logs/%{dt}/%{table_name}.log'

[root@node2 /root]# hdfs dfs -cat /data/user_logs/user_browse_logs/20180812/user_browse_0_logs.log
{"@version":"1","dt":"20180812","product_id":1,"uid":"0","id":1,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
{"@version":"1","dt":"20180812","product_id":2,"uid":"0","id":2,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
{"@version":"1","dt":"20180812","product_id":3,"uid":"0","id":3,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:32","@timestamp":"2018-08-12T12:18:32.000Z"}
```


查看jdbc偏移量记录文件
```
#该路径来自input jdbc插件 last_run_metadata_path参数
last_run_metadata_path => "/Users/wangpei/software/logstash-6.3.2/data/test/metadata/user_browse_0_logs"

#此时id的偏移量是3,下次取id>3的数据。这样就实现了增量同步
[wangpei@localhost ~/software/logstash-6.3.2]$ cat /Users/wangpei/software/logstash-6.3.2/data/test/metadata/user_browse_0_logs
--- 3
```

查看logstash持久化的数据
```
#持久化目录下包含2个目录,一个文件
#该目录来自于logstash.yml中 path.data: /Users/wangpei/software/logstash-6.3.2/data/user_browse_logs/data

[wangpei@localhost ~/software/logstash-6.3.2]$ ls -l /Users/wangpei/software/logstash-6.3.2/data/user_browse_logs/data
total 8
drwxr-xr-x  2 wangpei  staff   68  8 12 19:38 dead_letter_queue
drwxr-xr-x  4 wangpei  staff  136  8 12 19:57 queue
-rw-r--r--  1 wangpei  staff   36  8 12 19:38 uuid

#uuid:logstash agent uuid
#queue:input → queue → filter + output。queue配置为persisted时,input会把数据先写入此持久化目录,然后再由filter + output处理。
#dead_letter_queue:DLQ队列。死信队列储存响应代码为400或404的情况，两者都表示无法重试的事件。
如数据input=>filter=>output(es)，
一条数据出现mapping error，此时如果在logstash.yml中配置了dead_letter_queue.enable: true,
就会将这条数据放在DLQ对应的持久化目录中。然后可以通过DLQ(Dead Letter Queues) Input => Filter(再处理)=>Output ES。
```

## 附:Kafka Input
```
input{
    kafka{
        codec => json {charset => "UTF-8"}
        #消费者组
        group_id => "test_topic_consumer1"
        #从最新开始消费
        auto_offset_reset => "latest"
        #消费的topics
        topics => ["test_topic"]
        #bootstrap server
        bootstrap_servers => "localhost:9092"
        #注意:线程数最好与partition数目一样多,超过partition数量的线程会闲置。
        #kafka topic 一个partition同一时刻只能有一个线程去消费。
        consumer_threads =>3
    }
}
```


# 过滤器插件（Filter）

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
