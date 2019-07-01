SolrCloud 分布式集群
======

软件下载地址  
https://www.apache.org/dist/  
https://www.apache.org/dist/lucene/  
搭建solrcloud集群  
zookeeper部署  

1、下载zk  
```
mkdir -p /apps/soft
cd /apps/soft
wget https://www.apache.org/dist/zookeeper/zookeeper-3.5.5/apache-zookeeper-3.5.5.tar.gz
tar zxvf apache-zookeeper-3.5.5.tar.gz
mv apache-zookeeper-3.5.5 /opt/zookeeper
```  

2、	新建zookeeper的数据存储目录和日志文件目录
```
mkdir -p /opt/zookeeper/logs
mkdir -p /opt/zookeeper/data
```  

3、修改zk配置文件  
```
# cd /opt/zookeeper/conf
# cp -av zoo_sample.cfg zoo.cfg
# vim zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/zookeeper/data
dataLogDir=/opt/zookeeper/logs
clientPort=2181
 #maxClientCnxns=60
 #minSessionTimeout=4000
 #maxSessionTimeout=40000
server.1=node01:4888:5888
server.2=node02:4888:5888
server.3=node03:4888:5888
```  


4	同步至其余4台服务器  
```
scp -r /opt/zookeeper node01:/opt
scp -r /opt/zookeeper node02:/opt
```  

5、分别在每台机器上创建myid文件存储该机器的标识码  
```
echo "1" >> /opt/zookeeper/data/myid
echo "2" >> /opt/zookeeper/data/myid
echo "3" >> /opt/zookeeper/data/myid
```  

3.	启动zookeeper  
```
cd /opt/zookeeper/bin && ./zkServer.sh start
./zkServer.sh status
mode: follower or mode: Leader
```  



二、Solrcloud分布式集群搭建  
1、部署solr  
```
cd /apps/soft
mkdir -p /apps/dat/web/working/solr/data(solr数据存储目录)
wget archive.apache.org/dist/lucene/solr/4.8.1/solr-4.8.1.zip
unzip solr-4.8.1.zip
```  

2、拷贝war包  
```
cp -av /apps/soft/solr-4.8.1/example/webapps/solr.war /apps/dat/web/working/solr/
cd /apps/dat/web/working/solr && jar -xvf solr.war
cp -av /apps/svr/solr-4.8.1/example/lib/ext/*.jar /apps/dat/web/working/solr/WEB-INF/lib/
```  

3、拷贝文件  
```
mkdir -p /apps/conf/solr/config-files
mkdir -p /apps/conf/solr/solr-lib
cp -av /apps/svr/solr-4.8.1/example/solr/collection1/conf/* /apps/conf/solr/config-files/
cp -av /apps/dat/web/working/solr/WEB-INF/lib/*.jar /apps/conf/solr/solr-lib/
```  

4、修改配置文件  
```
# vim /apps/dat/web/working/solr/WEB-INF/web.xml(添加solr数据存储目录)
<env-entry>   
  <env-entry-name>solr/home</env-entry-name>   
  <env-entry-value>/apps/dat/web/working/solr/data</env-entry-value>   
  <env-entry-type>java.lang.String</env-entry-type>
</env-entry>
```  

1、
```
cp -av /apps/svr/solr-4.8.1/example/lib/ext/*.jar /apps/svr/tomcat/lib/
cp -av /apps/svr/solr-4.8.1/example/resources/log4j.properties /apps/svr/tomcat/lib/
cp -av /apps/svr/solr-4.8.1/example/solr/solr.xml /apps/svr/solr-4.8.1/example/solr/zoo.cfg /apps/dat/web/working/solr/data
```  
2、配置  
```
# vim /apps/svr/tomcat/conf/server.xml
```  

3、配置zk
```
# vim /apps/svr/tomcat/bin/catalina.sh 注释掉JAVA_OPTS，并且添加如下：
JAVA_OPTS="$JAVA_OPTS  -Xmx8192m -Xms8192m -Xmn4g -Xss256k -XX:ParallelGCThreads=24 -DzkHost=solr-cloud-001:2181,solr-cloud-002:2181,solr-cloud-003:2181,solr-cloud-004:2181,solr-cloud-005:2181 -XX:+UseConcMarkSweepGC -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=8060 -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=10.0.0.1  -XX:PermSize=1024m -XX:MaxPermSize=1024m -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -XX:+PrintHeapAtGC -Xloggc:/apps/logs/tomcat/gc`date +%Y%m%d%H%M%S`.log -XX:ErrorFile=\"/apps/logs/tomcat/java_error.log\""
```  
1.	将tomcat的目录分发至其余服务器的相应的位置；  
2.	SolrCloud是通过ZooKeeper集群来保证配置文件的变更及时同步到各个节点上，所以，需要将配置文件上传到ZooKeeper集群中：执行如下操作：
```
java -classpath .:/apps/conf/solr/solr-lib/* org.apache.solr.cloud.ZkCLI -cmd upconfig -zkhost 10.0.0.1:2181,10.0.0.2:2181,10.0.0.3:2181,10.0.0.4:2181,10.0.0.5:2181 -confdir /apps/conf/solr/config-files/ -confname myconf
java -classpath .:/apps/conf/solr/solr-lib/* org.apache.solr.cloud.ZkCLI -cmd linkconfig -collection collection1 -confname myconf -zkhost 10.0.0.1:2181,10.0.0.2:2181,10.0.0.3:2181,10.0.0.4:2181,10.0.0.5:2181
```  

3.	分发完毕以后，我们可以检查一下zookeeper的存储情况：  
```
cd /apps/svr/zookeeper/bin/
./zkCli.sh -server solr-cloud-001:2181
________________________________________
[zk: solr-cloud-001:2181(CONNECTED) 2] ls /configs/myconf
[currency.xml, mapping-FoldToASCII.txt, protwords.txt, synonyms.txt, scripts.conf, stopwords.txt, velocity, _schema_analysis_synonyms_english.json, admin-extra.html, update-script.js, _schema_analysis_stopwords_english.json, solrconfig.xml, admin-extra.menu-top.html, elevate.xml, schema.xml, clustering, spellings.txt, xslt, mapping-ISOLatin1Accent.txt, lang, admin-extra.menu-bottom.html]
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

