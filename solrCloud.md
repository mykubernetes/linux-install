SolrCloud 分布式集群
======

软件下载地址  
http://archive.apache.org/dist/  
https://www.apache.org/dist/lucene/  
搭建solrcloud集群  

1、安装java
---
```
1、解压缩jdk

# tar xvf jdk-8u141-linux-x64.tar.gz

2、配置环境变量
# vim /etc/profile
export JAVA_HOME=/data/software/java8
export JRE_HOME=/data/software/java8/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib 
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

# source /etc/profile
```
2、安装zookeeper
---
```
1、下载zookeeper
# wget http://archive.apache.org/dist/zookeeper/zookeeper-3.5.7/apache-zookeeper-3.5.7-bin.tar.gz

2解压
# tar -zxvf zookeeper-3.4.9.tar.gz

服务器1：
#mv zookeeper-3.4.9 zookeeper
服务器2：
#mv zookeeper-3.4.9 zookeeper
服务器3：
#mv zookeeper-3.4.9 zookeeper

3、在zookeeper的各个节点下 创建数据和日志目录
# cd zookeeper
# mkdir data
# mkdir logs

4、重命名配置文件
# cd conf
# cp zoo_sample.cfg zoo.cfg

5、修改配置文件
clientPort=2181
dataDir=/data/software/zookeeper/data
dataLogDir=/data/software/zookeeper/logs

server.1=node01:2881:3881
server.2=node02:2881:3881
server.3=node03:2881:3881

6、创建myid文件
# cd /data/software/zookeeper/data
服务器1：
# echo 1 > myid
服务器2：
# echo 2 > myid
服务器3：
# echo 3 > myid

7、启动测试zookeeper
进入/bin目录下执行：
服务器1：
# /zkServer.sh start
服务器2：
# /zkServer.sh start
服务器3：
# /zkServer.sh start

8、jps命令查看进程
# jps

9、查看状态
# /zkServer.sh status
```


3、安装tomcat  
--- 
```
5、安装tomcat
# wget http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.92/bin/apache-tomcat-7.0.92.tar.gz
# tar -zxvf  apache-tomcat-7.0.92.tar.gz  
```  










1.	启动10.0.0.1上的tomcat，这时候，SolrCloud集群中只有一个活跃的节点，而且默认生成了一个collection1实例，可以通过web界面访问http://10.0.0.1:8080/solr  
2.	启动其余4台服务器的tomcat，会在zookeeper集群中查看到当前所有的集群状态：   
```
[zk: solr-cloud-001:2181(CONNECTED) 1] ls /live_nodes
[10.0.0.1:8080_solr, 10.0.0.2:8080_solr, 10.0.0.3:8080_solr, 10.0.0.4:8080_solr, 10.0.0.5:8080_solr]
```  
这时，已经存在5个active的节点了，但是SolrCloud集群并没有更多信息;  


创建collection、Shard和replication  
创建3个分片1个副本  
```
curl 'http://10.0.0.2:8080/solr/admin/collections?action=CREATE&name=userinfo&numShards=3&replicationFactor=1'
```  
创建5个分片3个副本  
```
curl 'http://10.0.0.2:8080/solr/admin/collections?action=CREATE&name=userinfo&numShards=5&replicationFactor=3&maxShardsPerNode=3'
```  
- name 待创建Collection的名称  
- numShards 分片的数量  
- replicationFactor 复制副本的数量  

通过Web管理页面查看SolrCloud集群的分片信息  
访问http://10.0.0.1:8080/solr/#/~cloud  




solrCloud 管理
----
创建collection：  
./zkcli.sh -cmd upconfig -zkhost 10.0.0.1:2181/solrcloud -confdir /apps/conf/solr/config-files-confname test_date  
curl 'http://10.0.0.1:8080/solr/admin/collections?action=CREATE&name=test_date&numShards=1&replicationFactor=3'  
修改collection的配置信息：  
写入ZK：  
1. sh zkcli.sh -zkhost 10.0.0.1:2181/solrcloud -cmd upconfig -confdir /apps/conf/solr/config-files -confname collection1  
2. reload conf： curl 'http://10.0.0.1:8080/solr/admin/collections?action=RELOAD&name=collection1'  
删除collection  
curl 'http://10.0.0.1:8080/solr/admin/collections?action=DELETE&name=test'  
数据目录下只保留了目录，数据已经删除了。
zk中的该collection的信息没有被删除。
split shard  
curl 'http://10.0.0.1:8080/solr/admin/collections?action=SPLITSHARD&collection=name&shard=shardID'  
delete inactive shard  
curl 'http://10.0.0.1:8080/solr/admin/collections?action=DELETESHARD&shard1=shardID&collection=name'  
给分片创建副本：  
curl 'http://10.0.0.1:8080/solr/admin/collections?action=ADDREPLICA&collection=collection&shard=shard&node=solr_node_name'  
例如：curl 'http://10.0.0.1:8080/solr/admin/collections?action=ADDREPLICA&collection=test_shard&shard=shard1_0&node=10.0.0.2:8080_solr'  
删除副本：  
curl 'http://10.0.0.1:8080/solr/admin/collections?action=DELETEREPLICA&collection=collection&shard=shard&replica=replica'
例如：curl 'http://10.0.0.1:8080/solr/admin/collections?action=DELETEREPLICA&collection=test_shard&shard=shard1_0&replica=core_node5'  
Zookeeper维护的集群状态数据是存放在solr/data目录下的。  

