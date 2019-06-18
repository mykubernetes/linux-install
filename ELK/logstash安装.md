四、安装Logstash  
https://github.com/logstash-plugins  
1、下载安装包  
``` 
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.6.1.rpm
yum install -y logstash-6.6.1.rpm
```  

2、测试logstash是否可用
```
/usr/share/logstash/bin/logstash -e 'input { stdin{} } output { stdout { codec => rubydebug}}'
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

6、nginx日志转换成json格式  
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
7、tomcat日志转换成json格式  
```
vim conf/server.xml
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="tomcat_access_log" suffix=".log"
               pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;ClientUser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;AccessTime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;SendBytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;AgentVersion&quot;:&quot;%{User-Agent}i&quot;}"/> 
```  
配置logstash收集tomcat日志  
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

8、验证日志是否json格式：
http://www.kjson.com/


6、配置logstash服务并收集beats日志  
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
7、配置logstash收集redis并发生到elasticsearch
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
