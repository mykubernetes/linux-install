五、安装Filebeat  
官网配置文档

https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html  

https://www.elastic.co/guide/en/beats/filebeat/current/configuring-output.html  
1、下载安装包  
``` 
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.6.1-x86_64.rpm
yum install -y filebeat-6.6.1-x86_64.rpm
```  
2、修改配置文件
```
# grep -v "#"  /etc/filebeat/filebeat.yml | grep -v "^$"
# 收集系统日志
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/messages
    - /var/log/*.log
  exclude_lines: ["^DBG","^$"]              #不收集的行                       
  document_type: system-log-node01          #和elasticsearch一样打标签

# 收集tomat日志
- input_type: log
  paths:
    - /usr/local/tomcat/logs/tomcat_access_log.*.log
  document_type: tomcat-accesslog-node01

# 发送熬reddis
output.redis:
  hosts: ["192.168.56.12:6379"]
  key: "system-log-5612"                    #redis的key名
  db: 1                                     #库
  timeout: 5
  password: 123456                          #redis密码

# 发送到logstash
output.logstash:
  hosts: ["192.168.56.11:5044"]             #logstash 服务器地址，可以是多个
  enabled: true                             #是否开启输出至logstash，默认即为true
  worker: 1                                 #工作线程数
  compression_level: 3                      #压缩级别
  loadbalance: true                         #多个输出的时候开启负载

# 输出熬kafka
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

3、启动filebeat  
``` 
systemctl  restart filebeat 
nohup ./filebeat -c filebeat_console.yml >/dev/null 2>&1 &
```  


