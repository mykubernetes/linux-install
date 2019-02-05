ELK
====
官网：https://www.elastic.co/cn/  
一、安装jdk  
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
network.host: node001       #监听的ip地址，如果是0.0.0.0，则表示监听全部ip
discovery.zen.ping.unicast.hosts: ["node001","node002","node003"]
```  

3、所有的机子/etc/sysconfig/elasticsearch文件添加java环境  
```
vim /etc/sysconfig/elasticsearch
JAVA_HOME=/opt/modules/jdk1.8.0_121
```  
4、启动elasticsearch  
``` systemctl daemon-reload ```  
``` systemctl start elasticsearch.service ```

5、curl访问方法  
1)查看单记得点的工作状态  
``` curl -X GET 'http://node001:9200/?preey' ```  
2)查看cat支持的操作  
``` curl -X GET 'http://node001:9200/_cat' ```  
3)查看集群有几个节点  
``` curl -X GET 'http://node001:9200/_cat/nodes' ```  
``` curl -X GET 'http://node001:9200/_cat/nodes?v' ```  
4)查看集群健康状态  
``` curl -X GET 'https://node:9200/_cluster/health?pretty' ```  
5）查看集群详细信息  
``` curl 'node001:9200/_cluster/state?pretty' ```

三、安装kibana  
1、下载安装包  
```
curl -O https://artifacts.elastic.co/downloads/kibana/kibana-6.4.0-x86_64.rpm
rpm -ivh kibana-6.4.0-x86_64.rpm
```  
2、修改配置文件  
```
# vim /etc/kibana/kibana.yml
  server.port: 5601
  server.host: "192.168.0.1"
  elasticsearch.url: "http://node001:9200"
  logging.dest: /var/log/kibana.log
```  
3、创建日志目录  
``` touch /var/log/kibana.log && chmod 777 /var/log/kibana.log ```  
4、启动kibana  
``` systemctl start kibana ```  
``` http://node001:5601 ```  


四、logstash安装  
1、下载安装包  
``` curl -O https://artifacts.elastic.co/downloads/logstash/logstash-6.4.0.rpm
rpm -ivh logstash-6.4.0.rpm
```  
2、配置环境变量
```
vim /usr/share/logstash/bin/logstash.lib.sh
JAVA_HOME=/usr/local/jdk1.8
```  
3、配置logstash收集syslog日志  
```
vim /etc/logstash/conf.d/syslog.conf
input {
   syslog { 
      type => "system-syslog"
      port => 10514
   }
}
output {
   stdout {
      codec => rubydebug
   }
｝
```  
