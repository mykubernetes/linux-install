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
1下载eelasticsearch  
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.0.tar.gz
tar -xvf elasticsearch-6.6.0.tar.gz -C /opt/module/
```  
2、修改配置文件
```
# vim /opt/module/elasticsearch-6.6.0/config/elasticsearch.yml
cluster.name: my-elk        #集群的名称
node.name: my-test01        #节点的名称
node.master: true           #是否为master（主节点），true：是，false：不是
node.data: false            #是否是数据节点，false：不是，true：是
index.number_of_shards:5    #每个索引的shard数量（分片数量）
index.number_of_replicas:   #每个shard的复本数量
transport.tcp.port: 9300    #集群选举通信端口
path.data: /opt/module/elk/data  #数据路径
path.logs: /opt/module/elasticsearch-6.6.0/logs  #日志路径
network.host: node001       #监听的ip地址，如果是0.0.0.0，则表示监听全部ip
discovery.zen.ping.unicast.hosts: ["node001","node002","node003"]
```  
3、优化内核限制文件数和打开的进程数  
```
cat  /etc/security/limits.conf  |grep "^*"
    * soft    nofile    924511
    * sift    nproc     924511
    * hard    nproc     924511
    * hard nofile 924511
```  
4、修改内核参数
```  
# vim /etc/sysctl.conf
  vm.max_map_count=262144
# sysctl -p
```  
5、启动elasticsearch  
``` ./elasticsearch -d ```  
不能使用root身份运行

6、curl访问方法  
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
1、下载安装包  
``` 
https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.6.0-linux-x86_64.tar.gz
tar -xvf filebeat-6.6.0-linux-x86_64.tar.gz
```  
2、修改配置文件
```
vim /opt/module/filebeat-6.6.0-linux-x86_64/filebeat.yml
#注释以下内容：
#enabled: false

输出位置配置：
output.elasticsearch:
 hosts: ["localhost:9200"]

#修改paths:
 paths:
    - /var/log/messages
```  
3、启动filebeat  
``` ./filebeat -c /etc/filebeat/filebeat.yml ```
