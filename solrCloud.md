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


3、部署三台tomcat  
--- 
```
1、部署tomcat
# wget http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.92/bin/apache-tomcat-7.0.92.tar.gz
# tar -zxvf  apache-tomcat-7.0.92.tar.gz

2、如果一台机器需要修改端口号，不同机器不用修改
# cd taomcat
# vim conf/server.xml

3、启动
# bin/startup.sh
```

4、部署solr
---
```
1、解压solr-4.10.3.tar.gz压缩包。复制solr.war到tomcat
# tar xvf solr-4.10.3.tar.gz

2、解压war包
# cd solr-4.10.3/dist
# jar xvf solr-4.10.3.war

3、分别拷贝solr到tomcat中
# cp solr -r tomcat/webapps/

4、拷贝solrhome，修改每个web.xml指定solrhome的位置。
# cp -r solrhome/ tomcat/webapps/solrcloud/solrhome
# vim tomcat/webapps/solr/WEB-INF/web.xml
 solrcloud/solrhome

#组成集群

5、把solrhome中的配置文件上传到zookeeper集群。使用zookeeper的客户端上传。
# cd /root/solr-4.10.3/example/scripts/cloud-scripts
# ./zkcli.sh -zkhost 192.168.101.66:2181,192.168.101.67:2181,192.168.101.68:2181 -cmd upconfig -confdir /usr/local/solrcloud/solrhome/collection1/conf -confname myconf

6、修改solrhome下的solr.xml文件，指定当前实例运行的ip地址及端口号。
vim /usr/local/solrcloud/solrhome1/solr.xml
<solr>
  <solrcloud>
    <str name="host">${host:192.168.101.66}</str>             #ip地址
    <int name="hostPort">${jetty.port:8083}</int>             #端口号
    <str name="hostContext">${hostContext:solr}</str>
    <int name="zkclientTimeout">${zkclientTimeout:30000}</int>
    <bool name="genericCoreNodeNames">${genericCoreNodeNames:true}</bool>
  </solrcloud>
  
7、修改每一台solr的tomcat 的 bin目录下catalina.sh文件中加入DzkHost指定zookeeper服务器地址
# vim tomcat/bin/catalina.sh
JAVA_OPTS="-DzkHost=192.168.101.66:2181,192.168.101.67:2182,192.168.101.68:2183"

8、重启tomcat
# zookeeper/bin/zkServer.sh stop
# zookeeper/bin/zkServer.sh start
# tomcat/bin/shutdown.sh
# tomcat/bin/startup.sh
```
可以通过web界面访问http://192.168.101.66:8080/solr/#/~cloud  


4、创建collection、Shard和replication
---
创建3个分片1个副本  
```
curl 'http://192.168.101.66:8080/solr/admin/collections?action=CREATE&name=userinfo&numShards=3&replicationFactor=1'
```  

创建5个分片3个副本  
```
curl 'http://192.168.101.66:8080/solr/admin/collections?action=CREATE&name=userinfo&numShards=5&replicationFactor=3&maxShardsPerNode=3'
```  
- name 待创建Collection的名称  
- numShards 分片的数量  
- replicationFactor 复制副本的数量  


修改collection的配置信息：  
```
curl 'http://192.168.101.66:8080/solr/admin/collections?action=RELOAD&name=collection1'  
```

删除collection,数据目录下只保留了目录，数据已经删除了。
```
curl 'http://192.168.101.66:8080/solr/admin/collections?action=DELETE&name=test'  
```


zk中的该collection的信息没有被删除。
```
curl 'http://192.168.101.66:8080/solr/admin/collections?action=SPLITSHARD&collection=name&shard=shardID'  

curl 'http://192.168.101.66:8080/solr/admin/collections?action=DELETESHARD&shard1=shardID&collection=name'  
```

给分片创建副本
```
curl 'http://10.0.0.1:8080/solr/admin/collections?action=ADDREPLICA&collection=collection&shard=shard&node=solr_node_name'  

curl 'http://10.0.0.1:8080/solr/admin/collections?action=ADDREPLICA&collection=test_shard&shard=shard1_0&node=10.0.0.2:8080_solr'  
```

删除副本
```
curl 'http://10.0.0.1:8080/solr/admin/collections?action=DELETEREPLICA&collection=collection&shard=shard&replica=replica'

curl 'http://10.0.0.1:8080/solr/admin/collections?action=DELETEREPLICA&collection=test_shard&shard=shard1_0&replica=core_node5'  
```
