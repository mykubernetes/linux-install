SolrCloud 分布式集群
======

一、正式solrcloud集群搭建  
zookeeper 部署  

1、下载zk  
```
mkdir -p /apps/soft
cd /apps/soft
wget http://mirrors.hust.edu.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
tar zxvf zookeeper-3.4.6.tar.gz
mv /apps/soft/zookeeper-3.4.6 /apps/svr/zookeeper
```  

2、	新建zookeeper的数据存储目录和日志文件目录
```
mkdir -p /apps/dat/zookeeper
mkdir -p /apps/logs/zookeeper
```  

3、修改zk配置文件  
```
# cd /apps/svr/zookeeper/conf
# cp -av zoo_sample.cfg zoo.cfg
# vim zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/apps/dat/zookeeper
dataLogDir=/apps/logs/zookeeper
clientPort=2181
 #maxClientCnxns=60
 #minSessionTimeout=4000
 #maxSessionTimeout=40000
server.1=solr-cloud-001:4888:5888
server.2=solr-cloud-002:4888:5888
server.3=solr-cloud-003:4888:5888
server.4=solr-cloud-004:4888:5888
server.5=solr-cloud-005:4888:5888
```  

- tickTime：这个时间是作为 Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。
- initLimit：这个配置项是用来配置 Zookeeper 接受客户端（这里所说的客户端不是用户连接 Zookeeper 服务器的客户端，而是 Zookeeper服务器集群中连接到 Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 10 个心跳的时间（也就是tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是52000=10秒。
- syncLimit：这个配置项标识 Leader 与 Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个tickTime 的时间长度，总的时间长度就是22000=4秒
- dataDir：顾名思义就是 Zookeeper 保存数据的目录，默认情况下，Zookeeper 将写数据的日志文件也保存在这个目录里。
- dataLogDir： Zookeeper的日志文件位置。
- server.A=B：C：D：其中 A 是一个数字，表示这个是第几号服务器；B是这个服务器的 ip 地址；C 表示的是这个服务器与集群中的 Leader服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。
- clientPort：这个端口就是客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求。

1.	同步至其余4台服务器  
```
scp -r /apps/svr/zookeeper username@'10.0.0.2':/app/svr/
scp -r /apps/svr/zookeeper username@'10.0.0.3':/app/svr/
scp -r /apps/svr/zookeeper username@'10.0.0.4':/app/svr/
scp -r /apps/svr/zookeeper username@'10.0.0.5':/app/svr/
```  
2.	分别在每台机器上创建myid文件存储该机器的标识码  
```
echo "1" >> /apps/dat/zookeeper/myid
echo "2" >> /apps/dat/zookeeper/myid
echo "3" >> /apps/dat/zookeeper/myid
echo "4" >> /apps/dat/zookeeper/myid
echo "5" >> /apps/dat/zookeeper/myid
```  

3.	启动zookeeper  
```
cd /apps/svr/zookeeper/bin && ./zkServer.sh start
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
2.	
# vim /apps/svr/tomcat/conf/server.xml

3、配置zk
```
# vim /apps/svr/tomcat/bin/catalina.sh 注释掉JAVA_OPTS，并且添加如下：
JAVA_OPTS="$JAVA_OPTS  -Xmx8192m -Xms8192m -Xmn4g -Xss256k -XX:ParallelGCThreads=24 -DzkHost=solr-cloud-001:2181,solr-cloud-002:2181,solr-cloud-003:2181,solr-cloud-004:2181,solr-cloud-005:2181 -XX:+UseConcMarkSweepGC -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=8060 -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=10.0.0.1  -XX:PermSize=1024m -XX:MaxPermSize=1024m -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -XX:+PrintHeapAtGC -Xloggc:/apps/logs/tomcat/gc`date +%Y%m%d%H%M%S`.log -XX:ErrorFile=\"/apps/logs/tomcat/java_error.log\""
```  
1.	将tomcat的目录分发至其余服务器的相应的位置；
2.	SolrCloud是通过ZooKeeper集群来保证配置文件的变更及时同步到各个节点上，所以，需要将配置文件上传到ZooKeeper集群中：执行如下操作：
java -classpath .:/apps/conf/solr/solr-lib/* org.apache.solr.cloud.ZkCLI -cmd upconfig -zkhost 10.0.0.1:2181,10.0.0.2:2181,10.0.0.3:2181,10.0.0.4:2181,10.0.0.5:2181 -confdir /apps/conf/solr/config-files/ -confname myconf
java -classpath .:/apps/conf/solr/solr-lib/* org.apache.solr.cloud.ZkCLI -cmd linkconfig -collection collection1 -confname myconf -zkhost 10.0.0.1:2181,10.0.0.2:2181,10.0.0.3:2181,10.0.0.4:2181,10.0.0.5:2181
3.	分发完毕以后，我们可以检查一下zookeeper的存储情况：
cd /apps/svr/zookeeper/bin/
./zkCli.sh -server solr-cloud-001:2181
________________________________________
[zk: solr-cloud-001:2181(CONNECTED) 2] ls /configs/myconf
[currency.xml, mapping-FoldToASCII.txt, protwords.txt, synonyms.txt, scripts.conf, stopwords.txt, velocity, _schema_analysis_synonyms_english.json, admin-extra.html, update-script.js, _schema_analysis_stopwords_english.json, solrconfig.xml, admin-extra.menu-top.html, elevate.xml, schema.xml, clustering, spellings.txt, xslt, mapping-ISOLatin1Accent.txt, lang, admin-extra.menu-bottom.html]
________________________________________

1.	启动10.0.0.1上的tomcat，这时候，SolrCloud集群中只有一个活跃的节点，而且默认生成了一个collection1实例，可以通过web界面访问http://10.0.0.1:8080/solr
2.	启动其余4台服务器的tomcat，会在zookeeper集群中查看到当前所有的集群状态：
[zk: solr-cloud-001:2181(CONNECTED) 1] ls /live_nodes
[10.0.0.1:8080_solr, 10.0.0.2:8080_solr, 10.0.0.3:8080_solr, 10.0.0.4:8080_solr, 10.0.0.5:8080_solr]
这时，已经存在5个active的节点了，但是SolrCloud集群并没有更多信息;


1.	创建collection、Shard和replication
上面链接中的几个参数的含义，说明如下：
curl 'http://10.0.0.2:8080/solr/admin/collections?action=CREATE&name=userinfo&numShards=3&replicationFactor=1'
创建3个分片1个副本
curl 'http://10.0.0.2:8080/solr/admin/collections?action=CREATE&name=userinfo&numShards=5&replicationFactor=3&maxShardsPerNode=3'
创建5个分片3个副本
name 待创建Collection的名称
numShards 分片的数量
replicationFactor 复制副本的数量
执行上述操作如果没有异常，已经创建了一个Collection，名称为userinfo；这时，也可以查看ZooKeeper中状态：
[zk: solr-cloud-001:2181(CONNECTED) 3] ls /collections
[collection1, userinfo]
通过Web管理页面，访问http://10.0.0.1:8080/solr/#/~cloud查看SolrCloud集群的分片信息；
到此为止，我们基于5个物理节点，配置完成了SolrCloud集群多节点的配置。


扩展内容：
solrCloud 管理
更多的solrcloude管理信息，请参考http://eksliang.iteye.com/blog/2124078
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

