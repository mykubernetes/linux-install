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
- Producer： 消息生产者，就是向 kafka broker 发消息的客户端；
- Consumer： 消息消费者，向 kafka broker 取消息的客户端；
- Consumer Group（CG ）： 消费者组，由多个 consumer 组成。 消费者组内每个消费者负责消费不同分区的数据，一个分区只能由一个 组内 消费者消费；消费者组之间互不影响。所有的消费者都属于某个消费者组，即 消费者组是逻辑上的一个订阅者。
- Broker： 一台 kafka 服务器就是一个 broker。一个集群由多个 broker 组成。一个 broker可以容纳多个 topic。
- Topic： 可以理解为一个队列， 生产者和消费者面向的都是一个 topic；
- Partition： 为了实现扩展性，一个非常大的 topic 可以分布到多个 broker（即服务器）上，一个 topic 可以分为多个 partition，每个 partition 是一个有序的队列，一个partition只能属于一个topic；消息1和消息2都发送到主题1，它们可能进入同一个分区也可能进入不同的分区（所以同一个主题下的不同分区包含的消息是不同的），之后便会发送到分区对应的Broker节点上。
- Replica： 副本，为保证集群中的某个节点发生故障时，该节点上的 partition 数据不丢失，且 kafka 仍然能够继续工作，kafka 提供了副本机制，一个 topic 的每个分区都有若干个副本，一个 leader 和若干个 follower。
- Offset： 分区可以看作是一个只进不出的队列（Kafka只保证一个分区内的消息是有序的），消息会往这个队列的尾部追加，每个消息进入分区后都会有一个偏移量，标识该消息在该分区中的位置，消费者要消费该消息就是通过偏移量来识别。
  - kafka0.8 版本之前offset保存在zookeeper上。
  - kafka0.8 版本之后offset保存在kafka集群上。
- leader： 每个分区多个副本的“主”，生产者发送数据的对象，以及消费者消费数据的对象都是 leader。
- follower： 每个分区多个副本中的“从”，实时从 leader 中同步数据，保持和 leader 数据的同步。leader 发生故障时，某个 follower 会成为新的 follower。
- controller： 就是Kafka集群中某个broker宕机之后，是谁负责感知到他的宕机，以及负责进行Leader Partition的选举？如果你在Kafka集群里新加入了一些机器，此时谁来负责把集群里的数据进行负载均衡的迁移？包括你的Kafka集群的各种元数据，比如说每台机器上有哪些partition，谁是leader，谁是follower，是谁来管理的？如果你要删除一个topic，那么背后的各种partition如何删除，是谁来控制？还有就是比如Kafka集群扩容加入一个新的broker，是谁负责监听这个broker的加入？如果某个broker崩溃了，是谁负责监听这个broker崩溃？这里就需要一个Kafka集群的总控组件，Controller。他负责管理整个Kafka集群范围内的各种东西。
- zookeeper： Kafka 通过 zookeeper 来存储集群的meta元数据信息。一旦controller所在broker宕机了，此时临时节点消失，集群里其他broker会一直监听这个临时节点，发现临时节点消失了，就争抢再次创建临时节点，保证有一台新的broker会成为controller角色。

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

2、bin目录文件
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

3、修改配置文件
| 参数 | 说明 |
|------|-----|
| broker.id =0 | 全局唯一当IP改变时，broker.id没有变化，不会影响consumers的消息情况 |
| listeners=PLAINTEXT://:9092 | 配置kafka监听地址 |
| advertised.listeners=PLAINTEXT://ip:9092 | producer、consumer连接地址，如未设置使用 listeners |
| num.network.threads=3 | broker处理消息的最大线程数，一般情况下数量为cpu核数 |
| num.io.threads=8 | broker处理磁盘IO的线程数，数值为cpu核数2倍 |
| socket.send.buffer.bytes=102400 | socket的发送缓冲区，socket的调优参数SO_SNDBUFF |
| socket.receive.buffer.bytes=102400 | socket的接受缓冲区，socket的调优参数SO_RCVBUFF |
| socket.request.max.bytes=104857600 | 向kafka请求消息或者向kafka发送消息的请请求的最大数，这个值不能超过java的堆栈大小 |
| log.dirs=/tmp/kafka-logs | kafka数据的存放地址，多个地址的话用逗号分割,多个目录分布在不同磁盘上可以提高读写性能 /data/kafka-logs-1，/data/kafka-logs-2 |
| num.partitions=1 | 每个topic的分区个数，在创建topic时没有指定使用 |
| num.recovery.threads.per.data.dir=1 | 在启动时用于日志恢复的线程个数 |
| offsets.topic.replication.factor=1 | 用于配置offset记录的topic的partition的副本个数 |
| transaction.state.log.replication.factor=1 |  |
| transaction.state.log.min.isr=1 |  |
| log.retention.hours=168 | 默认消息的最大持久化时间，168小时，7天 |
| log.segment.bytes=1073741824 | topic分区以一堆segment文件存储，控制每个segment的大小，会被topic创建时的指定参数覆盖 |
| log.retention.check.interval.ms=300000 | 每隔300000毫秒去检查上面配置的log失效时间（log.retention.hours=168 ） |
| zookeeper.connect=localhost:2181 | zookeeper集群的地址 |
| zookeeper.connection.timeout.ms=6000 | ZooKeeper的连接超时时间 |
| group.initial.rebalance.delay.ms=0 |  |	

```
$ cd config/
$ vim server.properties
broker.id=0                              #broker的全局唯一编号，不能重复
listeners=PLAINTEXT://:9092              #监听所有地址
port=9092                                #用来监听链接的端口，producer或consumer将在此端口建立连接
delete.topic.enable=true                 #删除topic功能使能
num.network.threads=8                    #处理网络请求的线程数量,设置为CPU核心数
num.io.threads=16                        #用来处理磁盘IO的现成数量,设置为CPU核心数的两倍
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
group.initial.rebalance.delay.ms=0
```  

4、启动kafka服务
```
# kafka-server-start.sh /usr/local/kafka/config/server.properties
# kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
# kafka-server-stop.sh stop
```

五、Kafka命令行操作
---

1、创建topic  
```
# ./kafka-topics.sh --zookeeper node001:2181 --create --topic test --partitions 20 --replication-factor 3 --config max.message.bytes=1048576 --config segment.bytes=10485760
```
- --zookeeper 指定zookeeper的地址，如果zookeeper是集群，可以指定多个zookeeper，也可以只指定一个可用的zookeeper服务地址
- --create 创建命令
- --topic 指定topic的名称 
- --replication-factor  设置消息保存在几个broker上，一般情况下和brocker数量相同
- --partitions  定义分区数
- --config x=y 创建时指定配置

2、查看当前服务器中的所有topic  
```
# bin/kafka-topics.sh --list --zookeeper node001:2181
test
```

3、往topic发送消息
```
$ bin/kafka-console-producer.sh --broker-list node001:9092 --topic test
>hello world
>kafka  kafka
```

4、从topic消费消息
```
# 老版本
# bin/kafka-console-consumer.sh --zookeeper node001:2181 --topic test
# bin/kafka-console-consumer.sh --zookeeper node001:2181 --from-beginning --topic test

#新版本
# bin/kafka-console-consumer.sh --bootstrap-server node001:9092 --from-beginning --topic test

# 创建hncscwc消费者组, 并从2号分区 偏移量为1的位置开始消费 2条消息
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --group hncscwc --partition 2 --offset 1 --max-messages 2
```
- --from-beginning 读取主题中所有的数据
-  --partition 从指定的分区消费消息
- --offset 从指定的偏移位置消费消息
- --group 以指定消费者组的形式消费消息
- --max-messages 指定消费消息的最大个数
- --zookeeper已经被弃用 改为 --bootstrap-server参数

在创建consumer时指定消费组
```
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning --consumer-property group.id=test-group1
```

查询consumer消费信息
```
在kafka 0.9版本之后，kafka的consumer group和offset信息就不保存在zookeeper中了。因此我们要查看所有消费组，我们得先区分kafka版本：

#0.9版本之前kafka查看所有消费组
# ./kafka-consumer-groups.sh --zookeeper localhost:2181 --list

# 0.9及之后版本kakfa查看所有消费组
# kafka-consumer-groups.sh --new-consumer --bootstrap-server localhost:9092 --list 

# 2.4.0版本已经不支持--new-consumer选项
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
console-consumer-54559
console-consumer-97891
test-group2
test-group1
console-consumer-81258
```

```
# 0.9版本之前kafka查看consumer的消费情况
# bin/kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --zookeeper localhost:2181 --group logstash-new

# 0.9及之后版本kakfa查看consumer消费情况
# bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server localhost:9092 --describe --group console-consumer-99512

# 说明2.4.0版本已经不支持--new-consumer选项
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group test-group1
Consumer group 'test-group1' has no active members.
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
test-group1     test-ken-io     0          10              10              0               -               -            
```

5、修改topics
```
# kafka-topics.sh --zookeeper node001:2181 --alter --topic test --partitions 40
WARNING: If partitions are increased for a topic that has a key, the partition logic or ordering of the messages will be affected
Adding partitions succeeded!
```
- partitions的一个使用场景就是对数据进行分区，添加分区数并不会改变已有数据的分区，因此这可能会影响到一些依赖于分区的consumer。因为通常使用hash(key)%number_of_partitions算法来决定数据存放到哪个分区，但是kafka并不会尝试对已存在的数据重新做分区映射。

1）添加configs
```
# bin/kafka-configs.sh --zookeeper node001:2181 --entity-type topics --entity-name my_topic_name --alter --add-config x=y
# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my_topic_name --alter --add-config x=y
```

2) 移除config
```
# bin/kafka-configs.sh --zookeeper node001:2181 --entity-type topics --entity-name my_topic_name --alter --delete-config x
# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my_topic_name --alter --delete-config x
```

3) 修改topic
```
# kafka-topics.sh --zookeeper localhost:2181 --create --topic test --partitions 2 --replication-factor 1
# kafka-topics.sh --zookeeper localhost:2181 --alter --topic test --config max.message.bytes=1048576
# kafka-topics.sh --zookeeper localhost:2181 --describe --topic test
# kafka-topics.sh --zookeeper localhost:2181 --alter --topic test --config segment.bytes=10485760
# kafka-topics.sh --zookeeper localhost:2181 --alter --delete-config max.message.bytes --topic test
```

4）删除topic
```
# kafka-topics.sh --zookeeper node001:2181 --delete --topic test
Topic test is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.
```  
- 需要server.properties中设置delete.topic.enable=true否则只是标记删除或者直接重启。


分区副本的分配
- 见官方文档：http://kafka.apache.org/documentation/#topicconfigs
```
Configurations pertinent to topics have both a server default as well an
optional per-topic override. If no per-topic configuration is given the server
default is used. The override can be set at topic creation time by giving one or
more --config options. This example creates a topic named my-topic with a custom
max message size and flush rate:

> bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my-topic --partitions 1 --replication-factor 1 --config max.message.bytes=64000 --config flush.messages=1
Overrides can also be changed or set later using the alter configs command. This
example updates the max message size for my-topic:

> bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name my-topic --alter --add-config max.message.bytes=128000
To check overrides set on the topic you can do

> bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name my-topic --describe
To remove an override you can do

> bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name my-topic --alter --delete-config max.message.bytes
The following are the topic-level configurations. The server's default
configuration for this property is given under the Server Default Property
heading. A given server default config value only applies to a topic if it does
not have an explicit topic config override.
```

7、查看topic的分区及副本
```
kafka-topics.sh --zookeeper node001:2181 --describe --topic test
Topic:test  PartitionCount:20  ReplicationFactor:3  Configs:
Topic: test  Partition: 0      Leader: 3            Replicas: 3,0,2   Isr: 3,0,2
Topic: test  Partition: 1      Leader: 0            Replicas: 0,2,3   Isr: 0,2,3
Topic: test  Partition: 2      Leader: 2            Replicas: 2,3,0   Isr: 2,3,0
Topic: test  Partition: 3      Leader: 3            Replicas: 3,2,0   Isr: 3,2,0
Topic: test  Partition: 4      Leader: 0            Replicas: 0,3,2   Isr: 0,3,2
Topic: test  Partition: 5      Leader: 2            Replicas: 2,0,3   Isr: 2,0,3
Topic: test  Partition: 6      Leader: 3            Replicas: 3,0,2   Isr: 3,0,2
Topic: test  Partition: 7      Leader: 0            Replicas: 0,2,3   Isr: 0,2,3
Topic: test  Partition: 8      Leader: 2            Replicas: 2,3,0   Isr: 2,3,0
Topic: test  Partition: 9      Leader: 3            Replicas: 3,2,0   Isr: 3,2,0
Topic: test  Partition: 10     Leader: 0            Replicas: 0,3,2   Isr: 0,3,2
Topic: test  Partition: 11     Leader: 2            Replicas: 2,0,3   Isr: 2,0,3
Topic: test  Partition: 12     Leader: 3            Replicas: 3,0,2   Isr: 3,0,2
Topic: test  Partition: 13     Leader: 0            Replicas: 0,2,3   Isr: 0,2,3
Topic: test  Partition: 14     Leader: 2            Replicas: 2,3,0   Isr: 2,3,0
Topic: test  Partition: 15     Leader: 3            Replicas: 3,2,0   Isr: 3,2,0
Topic: test  Partition: 16     Leader: 0            Replicas: 0,3,2   Isr: 0,3,2
Topic: test  Partition: 17     Leader: 2            Replicas: 2,0,3   Isr: 2,0,3
Topic: test  Partition: 18     Leader: 3            Replicas: 3,0,2   Isr: 3,0,2
Topic: test  Partition: 19     Leader: 0            Replicas: 0,2,3   Isr: 0,2,3
```
- 第一行，列出了topic的名称，分区数(PartitionCount),副本数(ReplicationFactor)以及其他的配置(Configs) 
- Leader:1 表示为做为读写的broker的编号
- Replicas:表示该topic的每个分区在那些borker中保存
- Isr:表示当前有效的broker, Isr是Replicas的子集


8、查看topic消费到的offset
```
# kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list node001:9092 --topic test0 --time -1
test0:17:0
test0:8:0
test0:11:0
test0:2:0
test0:5:0
test0:14:0
test0:13:0
test0:4:0
test0:16:0
test0:7:0
test0:10:0
test0:1:0
test0:19:0
test0:18:0
test0:9:0
test0:3:0
test0:12:0
test0:15:0
test0:6:0
test0:0:

# 注1 结果格式为： topic名称:partition分区号:分区的offset
# 注2 --time 为 -1时用来请求分区最新的offset
#     --time 为 -2时用来请求分区最早有效的offset
```

9、显示所有消费者
```
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
# 结果如下
Note: This will not show information about old Zookeeper-based consumers.
 
console-consumer-22568
hncscwc
```

10、检查 consumer  位置
```
# 这将仅显示使⽤Java consumer API（基于⾮ZooKeeper的 consumer）的 consumer 的信息。
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group
  
TOPIC       PARTITION CURRENT-OFFSET LOG-END-OFFSET LAG       CONSUMER-ID                                      HOST
my-topic    0         2              4              2         consumer-1-029af89c-873c-4751-a720-cefd41a669d6  /127.0.0.1
my-topic    1         2              3              1         consumer-1-029af89c-873c-4751-a720-cefd41a669d6  /127.0.0.1
my-topic    2         2              3              1         consumer-2-42c1abd4-e3b2-425d-a8bb-e1ea49b29bb2  /127.0.0.1


# 这只会显示关于使⽤ZooKeeper的 consumer 的信息（不是那些使⽤Java consumer API的消费者）。
> bin/kafka-consumer-groups.sh --zookeeper localhost:2181 --describe --group my-group
TOPIC       PARTITION CURRENT-OFFSET LOG-END-OFFSET LAG       CONSUMER-ID
my-topic    0         2              4              2         my-group_consumer-1
my-topic    1         2              3              1         my-group_consumer-1
my-topic    2         2              3              1         my-group_consumer-2
```
- CURRENT-OFFSET 表示当前消费的offset
- LOG-END-OFFSET 表示最新的offset，也就是生产者最新的offset,总共的offset
- LAG 表示堆积


11、查看topic消费进度
- 显示出consumer group的offset情况， 必须参数为--group， 不指定--topic，默认为所有topic
```
# bin/kafka-run-class.sh kafka.tools.ConsumerOffsetChecker
required argument: [group] 
Option Description 
------ ----------- 
--broker-info Print broker info 
--group Consumer group. 
--help Print this message. 
--topic Comma-separated list of consumer 
   topics (all topics if absent). 
--zkconnect ZooKeeper connect string. (default: localhost:2181)
Example,

# bin/kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --group pv

Group           Topic              Pid Offset   logSize    Lag    Owner 
pv              page_visits        0   21       21         0      none 
pv              page_visits        1   19       19         0      none 
pv              page_visits        2   20       20         0      none
```
- topic：创建时topic名称
- pid：分区编号
- offset：表示该parition已经消费了多少条message
- logSize：表示该partition已经写了多少条message
- Lag：表示有多少条message没有被消费。
- Owner：表示消费者


12、常用创建topic参数
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



六、kafka manager安装配置
---
常用的kafka管理工具
- kafka manager
- Kafka Web Conslole
- KafkaOffsetMonitor

1、下载
```
# git clone https://github.com/yahoo/kafka-manager
Cloning into 'kafka-manager'...
remote: Counting objects: 4555, done.
remote: Total 4555 (delta 0), reused 0 (delta 0), pack-reused 4555
Receiving objects: 100% (4555/4555), 2.81 MiB | 1.05 MiB/s, done.
Resolving deltas: 100% (2914/2914), done.
```

2、编译打包
```
# cd kafka-manager/
# ./sbt clean dist
```

3、解压安装
```
# unzip kafka-manager-1.3.3.16.zip
# mv kafka-manager-1.3.3.16 /usr/local/kafka-manager
```

4、配置kafka-manager
```
vim /usr/local/kafka-manager/conf/application.conf
#修改kafka-manager.zkhosts配置项为zookeeper地址即可
```

5、启动kafka-manager
```
./bin/kafka-manager -Dconfig.flie=/usr/local/kafka-manager/conf/application.conf -Dhttp.port=8011
```
- -Dhttp.port 默认kafka-manager使用的是9000端口

启动后可以通过ip:8011访问kafka-manager页面



七、Kafka使用密码认证
---
Kafka 目前支持SSL、SASL/Kerberos、SASL/PLAIN三种认证机制。可以支持 客户端与brokers之间的认证，可以支持brokers与zookeeper之间的认证。因为SASL/PLAIN认证的用户名密码均是明文传书，所以可以使用SSL加密传输，而ACL基于用户对topic的读写权限进行控制。

在客户端与brokers、brokers与zookeeper之间的认证可以只做客户端与brokers，这并不影响brokers与zookeeper的之间的通讯，当然为了安全我们可以做brokers与zookeeper的认证。

Kafka 的安全机制主要分为两个部分
- 身份认证（Authentication）：对client 与服务器的连接进行身份认证。
- 权限控制（Authorization）：实现对于TOPIC的权限控制

一）SASL/PLAIN认证

1、修改server.properties配置文件
```
#之前配置listeners=PLAINTEXT://192.168.101.66:9092以PLAINTEXT协议监听，需要修改为如下配置
listeners=SASL_PLAINTEXT://192.168.101.66:9092     #修改监听协议为SASL_PLAINTEXT

security.inter.broker.protocol=SASL_PLAINTEXT     #配置安全协议为SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=PLAIN        #使用PLAIN做broker之间通信的协议
sasl.enabled.mechanisms=PLAIN                     #启用SASL机制
authorizer.class.name = kafka.security.auth.SimpleAclAuthorizer   #配置java认证类
super.users=User:admin                            #设置超级用户为：admin
allow.everyone.if.no.acl.found=true               #如果topic找不到acl配置是否运行操作，true为允许
```
- super.users配置了一个超级用户，这个超级用户不受ACL的限制可以自由访问任何的TOPIC，通常不对外使用，仅仅做管理使用，一般而言和JAAS配置的username一致。 allow.everyone.if.no.acl.found 配置了在TOPIC上没有找到ACL如何授权，配置true允许操作，配置false不允许操作，此配默认值为false，如果为false，TOPIC必须指定ACL，并且客户端使用指定的用户名才能访问成功。

2、jaas文件配置
```
# vim kafka_server_jaas.conf
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin@2017"
    user_alice="alice@2017";
};
```
- username和password是broker用于初始化连接到其他的broker
- admin用户为broker间的通讯
- user_UserName 定义了所有连接到 broker和 broker验证的所有的客户端连接包括其他 broker的用户密码，user_userName必须配置admin用户，否则报错。

3、添加kafka_server_jaas.conf到jvm的环境变量  
kafka启动时，会运行 bin/kafka-run-class.sh,将变量传给JVM。修改kafka-run-class.sh，将kafka_server_jaas.conf传递给JVM
```
# vim kafka-run-class.sh
#1、配置的第一行添加KAFKA_SASL_OPTS='-Djava.security.auth.login.config=/usr/local/kafka/config/kafka_server_jaas.conf'
KAFKA_SASL_OPTS='-Djava.security.auth.login.config=/usr/local/kafka/config/kafka_server_jaas.conf'
if [ $# -lt 1 ];
then
  echo "USAGE: $0 [-daemon] [-name servicename] [-loggc] classname [opts]"
  exit 1
fi
.
.
#2、配置文件最后一段的Launch mode中，添加 $KAFKA_SASL_OPTS即可
# Launch mode
if [ "x$DAEMON_MODE" = "xtrue" ]; then
  nohup $JAVA $KAFKA_HEAP_OPTS $KAFKA_JVM_PERFORMANCE_OPTS $KAFKA_GC_LOG_OPTS $KAFKA_SASL_OPTS $KAFKA_JMX_OPTS $KAFKA_LOG4J_OPTS -cp $CLASSPATH $KAFKA_OPTS "$@" > "$CONSOLE_OUTPUT_FILE" 2>&1 < /dev/null &
else
  exec $JAVA $KAFKA_HEAP_OPTS $KAFKA_JVM_PERFORMANCE_OPTS $KAFKA_GC_LOG_OPTS $KAFKA_SASL_OPTS $KAFKA_JMX_OPTS $KAFKA_LOG4J_OPTS -cp $CLASSPATH $KAFKA_OPTS "$@"
fi
```


4、重启kafka
```
# kafka-server-stop.sh stop
# kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties

[2018-05-09 10:58:09,225] WARN SASL configuration failed: javax.security.auth.login.LoginException: No JAAS configuration section named 'Client' was found in specified JAAS configuration file: '/usr/local/kafka/config/kafka_server_jaas.conf'. Will continue connection to Zookeeper server without SASL authentication, if Zookeeper server allows it. (org.apache.zookeeper.ClientCnxn)
```
- brokers和Zookeeper通信没有启用SASL，如果Zookeeper服务器允许的话，将继续连接到Zookeeper服务器

生产者和消费者配置  
1、配置server端配置
```
# vim kafka_server_jaas.conf
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin@2017"
    user_alice="alice@2017";
};
```

2、配置client配置
```
# vim kafka_cilent_jaas.conf
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin@2017"
    user_alice="alice@2017";
};
```
- username和password是客户端用来配置客户端连接broker的用户，在上面配置中，客户端使用admin用户连接到broker

3、修改consumer.properties和producer.properties，分别增加如下配置：
```
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
```

4、修改生产者和消费者启动文件参数
```
# vim kafka-console-consumer.sh
export KAFKA_OPTS=" -Djava.security.auth.login.config=/usr/local/kafka/config/kafka_client_jaas.conf"

# vim kafka-console-producer.sh
export KAFKA_OPTS=" -Djava.security.auth.login.config=/usr/local/kafka/config/kafka_client_jaas.conf"
```


6、启动生产者：
```
bin/kafka-console-producer.sh --broker-list 10.100.17.79:9092 --topic test --producer.config config/producer.properties
```

7、启动消费者
```
bin/kafka-console-consumer.sh --bootstrap-server 10.100.17.79:9092 --topic test --from-beginning --consumer.config config/consumer.properties
```

验证kafka用户密码
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


二）ACL的使用

1. kafka提供了一个ACL的功能用来控制TOPIC的权限

| 权限 | 说明 |
|------|------|
| READ | 读取topic |
| WRITE | 写入topic |
| DELETE | 删除topic |
| CREATE | 创建topic |
| ALTER | 修改topic |
| DESCRIBE | 获取topic的信息 |
| ClusterAction |  |
| ALL | 所有权限 |

- 访问控制列表ACL存储在zk上，路径为/kafka-acl

2. kafka提供了一个bin/kafka-acls.sh脚本来设置权限

| Option | Description | Default | Option type |
|--------|-------------|---------|-------------|
| –add | Indicates to the script that user is trying to add an acl.  |  | Action |
| –remove | Indicates to the script that user is trying to remove an acl. | | Action
| –list | Indicates to the script that user is trying to list acts.  | | Action
| –authorizer | Fully qualified class name of the authorizer. | kafka.security.auth.SimpleAclAuthorizer| Configuration |
| –authorizer-properties | key=val pairs that will be passed to authorizer for initialization. For the default authorizer the example values are: zookeeper.connect=localhost:2181 	| | Configuration |
| –cluster | Specifies cluster as resource. | | Resource |
| –topic [topic-name] | Specifies the topic as resource. | | Resource |
| –group [group-name] | Specifies the consumer-group as resource.| | Resource |
| –allow-principal | Principal is in PrincipalType:name format that will be added to ACL with Allow permission. You can specify multiple –allow-principal in a single command. 	| | Principal |
| –deny-principal | Principal is in PrincipalType:name format that will be added to ACL with Deny permission. You can specify multiple –deny-principal in a single command. 		| | Principal |
| –allow-host | IP address from which principals listed in –allow-principal will have access. | if –allow-principal is specified defaults to * which translates to “all hosts” 	     | Host |
| –deny-host | IP address from which principals listed in –deny-principal will be denied access. | if –deny-principal is specified defaults to * which translates to “all hosts” 	| Host |
| –operation | Operation that will be allowed or denied. Valid values are : Read, Write, Create, Delete, Alter, Describe, ClusterAction, All | All | Operation |
| –producer | Convenience option to add/remove acls for producer role. This will generate acls that allows WRITE, DESCRIBE on topic and CREATE on cluster.| | Convenience |
| –consumer | Convenience option to add/remove acls for consumer role. This will generate acls that allows READ, DESCRIBE on topic and READ on consumer-group.| | Convenience |

3. 权限设置

add 操作
```
# 为用户 alice 在 test（topic）上添加读写的权限
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=zk1:2181/kafka_test10 --add --allow-principal User:alice --operation Read --operation Write --topic test

# 对于 topic 为 test 的消息队列，拒绝来自 ip 为198.51.100.3账户为 BadBob  进行 read 操作，其他用户都允许
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=zk1:2181/kafka_test10 --add --allow-principal User:* --allow-host * --deny-principal User:BadBob --deny-host 198.51.100.3 --operation Read --topic test

# 为bob 和 alice 添加all，以允许来自 ip 为198.51.100.0或者198.51.100.1的读写请求
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=zk1:2181/kafka_test10 --add --allow-principal User:bob --allow-principal User:alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic test
```

list 操作
```
# 列出 topic 为 test 的所有权限账户
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=zk1:2181/kafka_test10 --list --topic test
```
输出信息为：
```
Current ACLs for resource `Topic:test`:
    User:alice has Allow permission for operations: Describe from hosts: *
    User:alice has Allow permission for operations: Read from hosts: *
    User:alice has Allow permission for operations: Write from hosts: *
```

remove 操作
```
# 移除 acl
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=zk1:2181/kafka_test10 --remove --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic test
```

producer 和 consumer 的操作
```
# producer
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=zk1:2181/kafka_test10 --add --allow-principal User:alice --producer --topic test
#consumer
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=zk1:2181/kafka_test10 --add 
```



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

显示 consumer  群体中所有 consumer 的位置，以及所在⽇志的结尾。
```
仅显示使⽤Java consumer API（基于⾮ZooKeeper的 consumer）的 consumer 的信息
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group

显示关于使⽤ZooKeeper的 consumer 的信息（不是那些使⽤Java consumer API的消费者)
# bin/kafka-consumer-groups.sh --zookeeper localhost:2181 --describe --group my-group
```

管理 Consumer Group 
```
# 列出所有 topic
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
test-consumer-group

# 查看偏移量
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group test-consumer-group
TOPIC                         PARTITION CURRENT-OFFSET LOG-END-OFFSET LAG       CONSUMER-ID                                      HOST
test-foo                      0         1              3              2         consumer-1-a5d61779-4d04-4c50-a6d6-fb35d942642d  /127.0.0.1

# 使⽤⽼的⾼级 consumer 并在 ZooKeeper 中存储组元数据
> bin/kafka-consumer-groups.sh --zookeeper localhost:2181 --list
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
