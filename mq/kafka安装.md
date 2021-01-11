Kafka集群部署
============
一、 集群规划
---
```
node001                 node002                 node003
zk                      zk                      zk
kafka                   kafka                   kafka
```
jar包下载 http://kafka.apache.org/downloads.html   

Kafka工作流程分析
---
![image](https://github.com/mykubernetes/hadoop/blob/master/image/kafka.png)
- Producer  ：消息生产者，就是向 kafka broker 发消息的客户端；
- Consumer  ：消息消费者，向 kafka broker 取消息的客户端；
- Consumer Group  （CG ）：消费者组，由多个 consumer 组成。 消费者组内每个消费者负责消费不同分区的数据，一个分区只能由一个 组内 消费者消费；消费者组之间互不影响。所有的消费者都属于某个消费者组，即 消费者组是逻辑上的一个订阅者。
- Broker  ：一台 kafka 服务器就是一个 broker。一个集群由多个 broker 组成。一个 broker可以容纳多个 topic。
- Topic  ：可以理解为一个队列， 生产者和消费者面向的都是一个 topic；
- Partition ：为了实现扩展性，一个非常大的 topic 可以分布到多个 broker（即服务器）上，一个 topic  可以分为多个 partition，每个 partition 是一个有序的队列；
- Replica： ：副本，为保证集群中的某个节点发生故障时，该节点上的 partition 数据不丢失，且 kafka 仍然能够继续工作，kafka 提供了副本机制，一个 topic 的每个分区都有若干个副本，一个 leader 和若干个 follower。
- leader ：每个分区多个副本的“主”，生产者发送数据的对象，以及消费者消费数据的对象都是 leader。
- follower ：每个分区多个副本中的“从”，实时从 leader 中同步数据，保持和 leader 数据的同步。leader 发生故障时，某个 follower 会成为新的 follower。

zookpeer存储结构
---
![image](https://github.com/mykubernetes/hadoop/blob/master/image/kafka_zk.png)

二、安装jdk
---
1、卸载现有jdk  
（1）查询是否安装java软件：  
``` $ rpm -qa|grep java ```  
（2）如果安装的版本低于1.7，卸载该jdk：  
``` $ rpm -e 软件包 ```  
2、在linux系统下的opt目录中查看软件包是否导入成功。  
``` $ jdk-7u79-linux-x64.gz  hadoop-2.7.2.tar.gz ```  
3、解压jdk到/opt/module目录下  
``` $ tar -zxf jdk-7u79-linux-x64.gz -C /opt/module/ ```  
4、配置jdk环境变量  
（1）先获取jdk路径：  
``` $ pwd ```  
``` /opt/module/jdk1.7.0_79 ```  
（2）打开/etc/profile文件：  
```
$ vi /etc/profile
在profie文件末尾添加jdk路径：
##JAVA_HOME
export JAVA_HOME=/opt/module/jdk1.7.0_79
export PATH=$PATH:$JAVA_HOME/bin
```  
（3）让修改后的文件生效：  
``` $ source  /etc/profile ```   
（4）测试jdk安装成功  
```
$ java -version
$ java version "1.7.0_79"
```  

三、安装Zookeeper
---
1）解压安装  
（1）解压zookeeper安装包到/opt/module/目录下  
``` $ tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/ ```  
（2）在/opt/module/zookeeper-3.4.10/这个目录下创建zkData  
``` $ mkdir -p zkData ```  
（3）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg  
``` $ mv zoo_sample.cfg zoo.cfg ```  

2）配置zoo.cfg文件
```
dataDir=/opt/module/zookeeper-3.4.10/zkData
增加如下配置
#######################cluster##########################
server.1=node001:2888:3888
server.2=node002:2888:3888
server.3=node003:2888:3888
集群模式下配置一个文件myid，这个文件在dataDir目录下
```  

3）集群操作  
（1）在/opt/module/zookeeper-3.4.10/zkData目录下创建一个myid的文件  
``` $ echo 1 > myid ```  
（2）拷贝配置好的zookeeper到其他机器上  
```
$ scp -r zookeeper-3.4.10/ root@node002:/opt/app/
$ scp -r zookeeper-3.4.10/ root@node003:/opt/app/
并分别修改myid文件中内容为2、3
```  
（3）分别启动zookeeper  
``` $ bin/zkServer.sh start ```  
       
（4）查看状态  
```
[root@node001 zookeeper-3.4.10]# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
	
[root@node002 zookeeper-3.4.10]# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: leader
	
[root@node003 zookeeper-3.4.5]# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
```  


四、Kafka集群部署
---
1）解压安装包  
``` $ tar -zxvf kafka_2.11-0.11.0.0.tgz -C /opt/module/ ```
  
2）修改解压后的文件名称  
``` $ mv kafka_2.11-0.11.0.0/ kafka ```  
  
3）在/opt/module/kafka目录下创建logs文件夹  
``` $ mkdir logs ```  
  
4）修改配置文件  
 ```
$ cd config/
$ vim server.properties
broker.id=0                              #broker的全局唯一编号，不能重复
port=9092                                #用来监听链接的端口，producer或consumer将在此端口建立连接
delete.topic.enable=true                 #删除topic功能使能
num.network.threads=3                    #处理网络请求的线程数量
num.io.threads=8                         #用来处理磁盘IO的现成数量
socket.send.buffer.bytes=102400          #发送套接字的缓冲区大小
socket.receive.buffer.bytes=102400       #接收套接字的缓冲区大小
socket.request.max.bytes=104857600       #请求套接字的缓冲区大小
log.dirs=/opt/module/kafka/logs          #kafka运行日志存放的路径
log.cleaner.enable=true                  #日志清理是否打开
num.partitions=1                         #topic在当前broker上的分区个数
num.recovery.threads.per.data.dir=1      #用来恢复和清理data下数据的线程数量
log.retention.hours=168                  #segment文件保留的最长时间，超时将被删除
log.roll.hours=168                       #滚动生成新的segment文件的最大时间
log.segment.bytes=1073741824             #日志文件中每个segment的大小，默认为1G
log.flush.interval.messages=10000        #partion buffer中，消息的条数达到阈值，将触发flush到磁盘
log.flush.interval.ms=3000               #消息buffer的时间，达到阈值，将触发flush到磁盘
zookeeper.connect=node001:2181,node002:2181,node003:2181       #配置连接Zookeeper集群地址
zookeeper.connection.timeout.ms=6000     #zookeeper链接超时时间
```  

5）配置环境变量  
```
$ cat /etc/profile
   #KAFKA_HOME
   export KAFKA_HOME=/opt/module/kafka
   export PATH=$PATH:$KAFKA_HOME/bin
$ source /etc/profile
```  

6）分发安装包  
``` $ scp -rp /opt/module/kafka node002:/opt/module/ ```  
``` $ scp -rp /opt/module/kafka node003:/opt/module/ ```  

7）分别在node002和node003上修改配置文件/opt/module/kafka/config/server.properties中的broker.id=1、broker.id=2  
注：broker.id不得重复  
  
8）启动集群  
依次在node001、node002、node003节点上启动kafka  
``` $ bin/kafka-server-start.sh -daemon config/server.properties ```   
 
9)关闭集群
``` $ bin/kafka-server-stop.sh stop ```
      
五、Kafka命令行操作
---


1）创建topic  
```
$ bin/kafka-topics.sh --create --zookeeper node001:2181 --replication-factor 3 --partitions 1 --topic first
```
- --topic 定义topic名  
- --replication-factor  定义副本数  
- --partitions  定义分区数

2）查看当前服务器中的所有topic  
``` $ bin/kafka-topics.sh --list --zookeeper node001:2181 ```


3）删除topic
```
$ bin/kafka-topics.sh --delete --zookeeper node001:2181 --topic first
```  
- 需要server.properties中设置delete.topic.enable=true否则只是标记删除或者直接重启。

4）发送消息
```
$ bin/kafka-console-producer.sh --broker-list node001:9092 --topic first
>hello world
>kafka  kafka
```

5）消费消息    
```
老版本
$ bin/kafka-console-consumer.sh --zookeeper node001:2181 --topic first
$ bin/kafka-console-consumer.sh --zookeeper node001:2181 --from-beginning --topic first
新版本
$ bin/kafka-console-consumer.sh --bootstrap-server node001:9092 --from-beginning --topic first
$ bin/kafka-console-consumer.sh --bootstrap-server node001:9092 --from-beginning --topic first
```
- --from-beginning 读取主题中所有的数据  
注意： --zookeeper已经被弃用 改为 --bootstrap-server参数  

6）查看某个Topic的详情  
```
$ bin/kafka-topics.sh --topic first --describe --zookeeper node001:2181
```

7)修改分区数
```
$  bin/kafka-topics.sh  --zookeeper hadoop102:2181 --alter --topic first --partitions 6
```

8)增加⼀个配置项
```
$ bin/kafka-configs.sh --zookeeper zk_host:port/chroot --entity-type topics --entity-name my_topic_name --alter --add-config x=y
```

9)
```
$ bin/kafka-configs.sh --zookeeper zk_host:port/chroot --entity-type topics --entity-name my_topic_name --alter --delete-config x
```

常用创建topic参数
```
bin/kafka-topics.sh --create \
--zookeeper $zookeeper_address \
--topic $topic \
--replication-factor 1 \
--partitons 32 \
--config retention.ms=86400000 \
--config retention.bytes=1073741824 \
--if-not-exists
```
- --config retention.ms=86400000 #topic过期时间，86400000 为一天，单位是毫秒
- --config retention.bytes=1073741824 # 日志数据存储的最大字节数。超过这个时间会根据policy处理数据。

六、Kafka使用密码认证
---
在Kafka0.9版本之前，Kafka集群时没有安全机制的。Kafka Client应用可以通过连接Zookeeper地址，例如zk1:2181:zk2:2181,zk3:2181等。来获取存储在Zookeeper中的Kafka元数据信息。拿到Kafka Broker地址后，连接到Kafka集群，就可以操作集群上的所有主题了。由于没有权限控制，集群核心的业务主题时存在风险的。

Kafka开启使用 SASL_PLAINTEXT认证

1、配置server端配置
```
# vim kafka_server_jaas.conf
KafkaServer {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="admin"
  user_admin="admin"
  user_alice="alice";
　};
```
- username和password是broker用于初始化连接到其他的broker
- admin用户为broker间的通讯
- user_UserName 定义了所有连接到 broker和 broker验证的所有的客户端连接包括其他 broker的用户密码，user_userName必须配置admin用户，否则报错。

2、配置client配置
```
# vim kafka_cilent_jaas.conf
KafkaClient {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="admin";
　};
```
- username和password是客户端用来配置客户端连接broker的用户，在上面配置中，客户端使用admin用户连接到broker

3、配置文件
```
# vim server.properties
listeners=SASL_PLAINTEXT://IP:9092                     # 使用的认证协议 
security.inter.broker.protocol=SASL_PLAINTEXT          # SASL机制 
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN             # 完成身份验证的类
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer     # 如果没有找到ACL（访问控制列表）配置，则允许任何操作
super.users=User:admin
```

4、修改consumer.properties和producer.properties，分别增加如下配置：
```
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
```

5、修改启动文件参数
```
# vim kafka-server-start.sh
export KAFKA_OPTS=" -Djava.security.auth.login.config=/data/kafka/kafka_2.11-1.1.0/config/kafka_server_jaas.conf"
```

```
# vim kafka-console-consumer.sh
export KAFKA_OPTS=" -Djava.security.auth.login.config=/data/kafka/kafka_2.11-1.1.0/config/kafka_client_jaas.conf"

# vim kafka-console-producer.sh
export KAFKA_OPTS=" -Djava.security.auth.login.config=/data/kafka/kafka_2.11-1.1.0/config/kafka_client_jaas.conf"
```

6、启动zookeeper和kafka
```
bin/kafka-server-start.sh config/server.properties &
```

7、启动生产者：
```
bin/kafka-console-producer.sh --broker-list 10.100.17.79:9092 --topic test --producer.config config/producer.properties
```

8、启动消费者
```
bin/kafka-console-consumer.sh --bootstrap-server 10.100.17.79:9092 --topic test --from-beginning --consumer.config config/consumer.properties
```

七、验证kafka用户密码
---
1. 创建 2 个文件
```
# cd /home/kafka

# vi  kafka_client_jaas.conf
注意替换用户名密码

KafkaClient {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="root"
  password="kafka";
};

# vi client-sasl.properties

security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
```

2. 创建一个测试 topic，名字为  aaabbb
```
kafka-topics.sh --create \
        --zookeeper zookeeper-default:2181/kafka \
        --topic aaabbb \
        --replication-factor 2 \
        --partitions 32 \
        --if-not-exists
```

3. 开始测试 producer，注意替换 broker-list 为 控制节点的 ip

```
# KAFKA_OPTS="-Djava.security.auth.login.config=/home/kafka/kafka_client_jaas.conf" \
    kafka-console-producer.sh \
    --broker-list 172.20.26.102:9092 \
    --topic aaabbb \
    --producer.config=/home/kafka/client-sasl.properties
```


4. 打开另外一个窗口，登陆到 kafka pod 里，测试消费，注意 bootstrap-server 的 ip 为 控制接点 ip，跟上面一样就行。
```
# KAFKA_OPTS="-Djava.security.auth.login.config=/home/kafka/kafka_client_jaas.conf" 、
    kafka-console-consumer.sh \
    --bootstrap-server 172.20.26.102:9092 \
    --topic aaabbb  \
    --consumer.config /home/kafka/client-sasl.properties \
    --from-beginning
```

5. 在 producer 那边输入一些消息，看 consumer 有没有

八、消费者组案例
---
测试同一个消费者组中的消费者，同一时刻只能有一个消费者消费。
```
在node001、node002上修改kafka/config/consumer.properties配置文件中的group.id属性为任意组名。
# vi consumer.properties
group.id=test001

在node001、node002上分别启动消费者
# bin/kafka-console-consumer.sh --zookeeper node001:2181 --topic first --consumer.config config/consumer.properties
# bin/kafka-console-consumer.sh --zookeeper node001:2181 --topic first --consumer.config config/consumer.properties

在node003上启动生产者
# bin/kafka-console-producer.sh --broker-list node001:9092 --topic first
>hello world

查看node001和node002的接收者。
同一时刻只有一个消费者接收到消息。
```


Kafka  监控
===
Kafka Eagle
---

1、修改 kafka-server-start.sh 命令中
```
if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
fi
为
if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
export KAFKA_HEAP_OPTS="-server -Xms2G -Xmx2G -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70"
export JMX_PORT="9999"
#export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
fi
```

2、部署
```
$  tar  -zxvf  kafka-eagle-bin-1.3.7.tar.gz
进入刚才解压的目录
$ tar -zxvf kafka-eagle-web-1.3.7-bin.tar.gz -C /opt/module/
$ mv kafka-eagle-web-1.3.7/ eagle
给启动文件执行权限
$ cd bin/ && chmod 777 ke.sh
```

3、修改配置文件
```
######################################
# multi zookeeper&kafka cluster list
######################################
kafka.eagle.zk.cluster.alias=cluster1
cluster1.zk.list=hadoop102:2181,hadoop103:2181,hadoop104:2181
######################################
# kafka offset storage
######################################
cluster1.kafka.eagle.offset.storage=kafka
######################################
# enable kafka metrics
######################################
kafka.eagle.metrics.charts=true
kafka.eagle.sql.fix.error=false
######################################
# kafka jdbc driver address
######################################
kafka.eagle.driver=com.mysql.jdbc.Driver
kafka.eagle.url=jdbc:mysql://hadoop102:3306/ke?useUnicode=true&ch
aracterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
kafka.eagle.username=root
kafka.eagle.password=000000
```

4、添加环境变量
```
export KE_HOME=/opt/module/eagle
export PATH=$PATH:$KE_HOME/bin
```

5、启动
```
$ bin/ke.sh start
```

6、登录页面展示
http://IP:8048/ke
