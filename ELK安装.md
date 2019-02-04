ELK
====
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
yum源
```
vim /etc/yum.repos.d/elk.repo
[elasticsearch]
name=Elasticsearch Repository for 6.x Package
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
enabled=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
```  
rpm下载地址：https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.rpm  
```
curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.rpm 
# rpm -ivh elasticsearch-6.4.0.rpm 
```  
修改配置文件
```
cd /etc/elasticsearch/
vim elasticsearch.yml
集群名称
cluster.name: elasticsearch
节点名称
node.name: "node001"
选举后是否可以成为主节点
node.master: true
是否可以存储数据
node.master: true
每个索引shard的数量
index.number_of_shards: 3
每个所以shard的副本数
index.number_of_replicas: 2
参与集群选举的端口端口
transport.tcp.port: 9300
工作端口
http.port: 9200
最少主节点数量
discovery.zen.minimum_master_nodes: 1
探测其他节点超时时间
discovery.zen.ping.timeout: 3s
```  
启动elasticsearch进程  
systemctl daemon-reload  
systemctl start elasticsearch  
