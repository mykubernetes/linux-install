ELK
====
官网：https://www.elastic.co/cn/  
一、安装jdk  最低要求jdk 8版本
```
$ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
# source /etc/profile
```

二、安装elasticsearch  
1下载elasticsearch  
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.0.tar.gz
tar -xvf elasticsearch-6.6.0.tar.gz -C /opt/module/
```  
2、创建普通用户用于启动elasticsearch默认不支持root启动  
```
# useradd elasticsearch
# chown -R elasticsearch:elasticsearch opt/module/elasticsearch-6.6.0/
```  

3、修改配置文件
```
# vim /opt/module/elasticsearch-6.6.0/config/elasticsearch.yml
cluster.name: my-elk           #集群的名称
node.name: my-test01           #节点的名称
node.master: true              #是否为master（主节点），true：是，false：不是
node.data: true                #是否是数据节点，false：不是，true：是
index.number_of_shards: 5      #每个索引的shard数量（分片数量）
index.number_of_replicas: 2    #每个shard的复本数量
bootstrap.memory_lock: true    #锁定物理内存，开启后只使用物理内存，不会使用swap,建议开启
http.port: 9200                #es端口
transport.tcp.port: 9300       #集群选举通信端口
path.data: /opt/module/elk/data                    #数据路径
path.logs: /opt/module/elasticsearch-6.6.0/logs    #日志路径
network.host: node001         #监听的ip地址，如果是0.0.0.0，则表示监听全部ip
discovery.zen.minimum_master_nodes: 1              #master最小节点数，小于次节点数，es启动不了
discovery.zen.ping.timeout: 3s           #超时时间
discovery.zen.ping.multicast.enabled: false    #通过多播的方法发现es，建议关闭
discovery.zen.ping.unicast.hosts: ["node001","node002","node003"]   #默认使用9300，如果修改可node001:9300
```  
4、优化内核限制文件数和打开的进程数  
```
cat  /etc/security/limits.conf  |grep "^*"
    * soft    nofile    924511
    * hard    nofile    924511
    * soft    nproc     924511
    * hard    nproc     924511
    * soft    memlock   unlimited    #内存锁，不限制
    * hard    memlock   unlimited
```  

centos7系统的nproc修改位置  
```
cat /etc/security/limits.d/20-nproc.conf
     * soft   nproc     20480
```  
5、修改内核参数
```  
# vim /etc/sysctl.conf
  fs.file-max=655360         #最大打开文件数
  vm.max_map_count=262144    #最大线程数，用于限制一个进程可以拥有的VMA(虚拟内存区域)的大小
# sysctl -p
```  

6、JVM调优  
```
# vim /opt/module/elasticsearch-6.6.0/config/jvm.options
-Xms2g
-Xmx2g
```  
- 可根据服务器内存大小，修改为合适的值。一般设置为服务器物理内存的一半最佳。  

7、启动elasticsearch  
```
# su - elasticsearch
$ cd /opt/module/elasticsearch-6.6.0/bin/
./elasticsearch -d
```  
-d 参数的意思是将elasticsearch放到后台运行。  
不能使用root身份运行  

8、curl访问方法  
1)查看单记得点的工作状态  
``` curl -X GET 'http://node001:9200/?pretty' ```  
2)查看cat支持的操作  
``` curl -X GET 'http://node001:9200/_cat' ```  
3)查看集群有几个节点  
``` curl -X GET 'http://node001:9200/_cat/nodes' ```  
``` curl -X GET 'http://node001:9200/_cat/nodes?v' ```  
4)查看集群健康状态  
``` curl -X GET 'http://node001:9200/_cluster/health?pretty' ```  
5）查看集群详细信息  
``` curl 'node001:9200/_cluster/state?pretty' ```

三、安装Kibana  
1、下载安装包  
```
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.6.0-linux-x86_64.tar.gz
tar -xvf kibana-6.6.0-linux-x86_64.tar.gz -C /opt/module/
```  
2、修改配置文件  
```
# vim /opt/module/kibana-6.6.0/kibana/kibana.yml
  server.port: 5601
  server.host: "0.0.0.0"
  elasticsearch.hosts: "http://node001:9200"
  logging.dest: /var/log/kibana.log
```  

4、启动kibana  
``` nohup ./kibana & ```  
``` http://node001:5601 ```  

5、配置nginx反向代理kibana认证  
```
# htpasswd -bc /usr/local/nginx/htpass.txt kibana 123456
#chown nginx.nginx /usr/local/nginx/ -R

server字段添加
auth_basic "Restricted Access";
auth_basic_user_file /usr/local/nginx/htpass.txt;
```  

四、安装Logstash  
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

五、安装Filebeat  
官网配置文档https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html  
1、下载安装包  
``` 
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.6.1-x86_64.rpm
yum install -y filebeat-6.6.1-x86_64.rpm
```  
2、修改配置文件
```
# grep -v "#"  /etc/filebeat/filebeat.yml | grep -v "^$"
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/messages
    - /var/log/*.log
  exclude_lines: ["^DBG","^$"]              #不收集的行                       
  document_type: system-log-node01          #和elasticsearch一样打标签
output.redis:
  hosts: ["192.168.56.12:6379"]
  key: "system-log-5612"  
  db: 1
  timeout: 5
  password: 123456
output.logstash:
  hosts: ["192.168.56.11:5044"]             #logstash 服务器地址，可以是多个
  enabled: true                             #是否开启输出至logstash，默认即为true
  worker: 1                                 #工作线程数
  compression_level: 3                      #压缩级别
  #loadbalance: true                        #多个输出的时候开启负载
```  
3、启动filebeat  
``` systemctl  restart filebeat ```  
4、收集tomcat日志  
```
#  grep -v "#"  /etc/filebeat/filebeat.yml | grep -v "^$"
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/messages
    - /var/log/*.log
  exclude_lines: ["^DBG","^$"]
  document_type: system-log-node01
- input_type: log
  paths:
    - /usr/local/tomcat/logs/tomcat_access_log.*.log
  document_type: tomcat-accesslog-node01
output.logstash:
  hosts: ["192.168.56.11:5044","192.168.56.11:5045"] #多个logstash服务器
  enabled: true
  worker: 1
  compression_level: 3
  loadbalance: true
```  
5、发送到kafka  
```
filebeat.inputs:
- type: log
  enabled: true
  paths:
   - /var/log/messages
   - /var/log/secure
  fields:
    log_topic: osmessages
name: "172.16.213.157"
output.kafka:
  enabled: true
  hosts: ["172.16.213.51:9092", "172.16.213.75:9092", "172.16.213.109:9092"]
  version: "0.10"
  topic: '%{[fields][log_topic]}'
  partition.round_robin:
    reachable_only: true
  worker: 2
  required_acks: 1
  compression: gzip
  max_message_bytes: 10000000
logging.level: debug
```  
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
