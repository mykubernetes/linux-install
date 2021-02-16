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
```
# rpm -qa|grep java
# rpm -e 软件包
```

2、解压二进制包，移动到指定的目录
```
# tar -zxvf jdk-8u151-linux-x64.tar.gz
# mv jdk1.8.0_151/ /usr/local/jdk
```

3、配置环境变量 
```
# vi /etc/profile
JAVA_HOME=/usr/local/jdk
JRE_HOME=/usr/local/jdk/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

# source /etc/profile
```  

4、检查是否安装成功
```
# java -version
java version "1.8.0_151"
Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode)
```  

三、安装Zookeeper
---
1、解压zookeeper二进制包，移动到指定目录
```
# tar -zxvf zookeeper-3.4.10.tar.gz
# mv zookeeper-3.4.10 /usr/local/zookeeper
```  

2、修改配置文件
```
# 1、进入配置文件目录
# cd /usr/local/zookeeper/conf
# ls
configuration.xsl  log4j.properties  zoo_sample.cfg

# 2、zookeeper提供了一个示例配置文件 zoo_sample.cfg 复制一份
# cp zoo_sample.cfg zoo.cfg

# 3、编辑配置文件
# vim zoo.cfg
# The number of milliseconds of each tick
tickTime=2000
#zookeeper中的一个时间单元，zookeeper中所有的时间都是以这个时间单元为准，进行整倍数的调整，默认是2S

# The number of ticks that the initial 
# synchronization phase can take
initLimit=10
#Follower在启动过程中，会从Leader同步所有最新的数据，确定自己能够对外服务的起始状态。
#当Follower在initLimit个tickTime还没有完成数据同步时，则Leader仍为Follower连接失败。

# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
syncLimit=5
#Leader于Follower之间通信请求和应答的时间长度。
#若Leader在syncLimit个tickTime还没有收到Follower应答，则认为该Lwader已经下线。

# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
#dataDir=/tmp/zookeeper
dataDir=/data/zookeeper
#存储快照文件的目录，默认情况下事务日志也会存储在该目录上。
#由于事务日志的写性能直接影响zookeeper性能，因此建议同时配置dataLogDir
#在生产环境中，一般我们要修改此目录，我们将修改为dataDir=/tmp/zookeeper

dataLogDir=/data/zookeeper
#事务日志输入目录
# the port at which the clients will connect
clientPort=2181
#zookeeper的对外服务端口

# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

server.1=zk1.linuxops.org:2888:3888
server.2=zk2.linuxops.org:2888:3888
server.3=zk3.linuxops.org:2888:3888
#以上配置zookeeper集群的服务地址，需要手动添加。
#其中server.1为第1台服务器，zk1.linuxops.org为第一台服务器解析的域名
#2888为该服务器于集群中Leader交换信息的端口，3888为选举时服务器通信端口。
```  

3、设置myid
准备目录，配置myid
```
# mkdir -p /data/zookeeper/log
# echo '1' > /data/zookeeper/myid
# cat /data/zookeeper/myid          # 不同zookeeper的myid不允许相同
1
```

4、修改zkEnv.sh文件
```
# 1、设置环境变量ZOO_LOG_DIR为zookeeper的日志存放目录
# vim /usr/local/zookeeper/bin/zkEnv.sh
# 2、在有效配置范围为的第一行增加如下配置：
export ZOO_LOG_DIR=/data/zookeeper/log
```
- 将日志文件zookeeper.out输出到/data/zookeeper/log目录下。默认输出到启动zookeeper时候所在的目录。

5、修改环境变量
```
vim /etc/profile
# 在文件末尾添加
export PATH=$PATH:/usr/local/zookeeper/bin
# source /etc/profile
```

6、启动、停止和状态管理
```
启动zookeeper
# zkServer.sh start 
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Starting zookeeper ... already running as process 4115.

停止zookeeper
# zkServer.sh stop
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Stopping zookeeper ... STOPPED
```
       
7、查看状态  
```
ZK1状态：
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: follower

ZK2状态：
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: follower

ZK3状态：
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: leader
```  
- 启动zookeeper之后，可以通过/data/zookeeper/log/zookeeper.out 查看到zookeeper日志。

四、Kafka集群部署
---
1）kafka安装
```
# wget http://mirrors.shu.edu.cn/apache/kafka/1.0.0/kafka_2.11-1.0.0.tgz 
# tar -zxvf kafka_2.11-1.0.0.tgz 
# mv kafka_2.11-1.0.0 /usr/local/kafka

# vim /etc/profile
#在文件末尾添加"
export PATH=$PATH:/usr/local/kafka/bin/"

# source /etc/profile
```  

2、
```
# cd /usr/local/kafka/bin/ && ls
connect-distributed.sh        kafka-console-consumer.sh    kafka-log-dirs.sh                    kafka-replay-log-producer.sh   kafka-simple-consumer-shell.sh      trogdor.sh     zookeeper-shell.sh
connect-standalone.sh         kafka-console-producer.sh    kafka-mirror-maker.sh                kafka-replica-verification.sh  kafka-streams-application-reset.sh  windows
kafka-acls.sh                 kafka-consumer-groups.sh     kafka-preferred-replica-election.sh  kafka-run-class.sh             kafka-topics.sh                     zookeeper-security-migration.sh
kafka-broker-api-versions.sh  kafka-consumer-perf-test.sh  kafka-producer-perf-test.sh          kafka-server-start.sh          kafka-verifiable-consumer.sh        zookeeper-server-start.sh
kafka-configs.sh              kafka-delete-records.sh      kafka-reassign-partitions.sh         kafka-server-stop.sh           kafka-verifiable-producer.sh        zookeeper-server-stop.sh
```
- kafka-console-consumer.sh ：官方控制台消费者
- kafka-console-producer.sh ： 官方控制台生产者
- kafka-server-start.sh ：kafka启动脚本
- kafka-server-stop.sh：kafka停止脚本
- kafka-topics.sh ： topics管理脚本
- zookeeper-server-start.sh ：zookeeper启动脚本
- zookeeper-server-stop.sh ：zookeeper停止脚本

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

$ bin/kafka-topics.sh --zookeeper zk_host:port/chroot --create --topic my_topic_name --partitions 20 --replication-factor 3 --config x=y
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

列出所有 topic  中的所有consumer  组
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
```

显示 consumer  群体中所有 consumer  的位置，以及所在⽇志的结尾。
```
仅显示使⽤Java consumer API（基于⾮ZooKeeper的 consumer）的 consumer 的信息
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group

显示关于使⽤ZooKeeper的 consumer 的信息（不是那些使⽤Java consumer API的消费者)
# bin/kafka-consumer-groups.sh --zookeeper localhost:2181 --describe --group my-group
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
