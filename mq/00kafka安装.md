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
# cd config/
# vim server.properties
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

# 五、Kafka命令行操作

## topic的常用操作

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

2、常用创建topic参数
```
bin/kafka-topics.sh --create \
--zookeeper $zookeeper_address \
--topic $topic \
--replication-factor 3 \
--partitons 3 \
--config retention.ms=86400000 \        # topic过期时间，86400000 为一天，单位是毫秒
--config retention.bytes=1073741824 \   #topic过期时间，86400000 为一天，单位是毫秒
--if-not-exists
```

3、查看当前服务器中的所有topic  
```
# bin/kafka-topics.sh --list --zookeeper node001:2181
test
```

4、往topic发送消息
```
# bin/kafka-console-producer.sh --broker-list node001:9092 --topic test
>hello world
>kafka  kafka
```

5、从topic消费消息
```
# 实时消费
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test

# 从头开始消费
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic test

# 从尾部开始消费
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --offset latest

# 指定分区消费
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --offset latest --partition 1

# 指定分区消费--partition 指定起始偏移量消费--offset 
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --partition 0 --offset 100

# 指定消费消息的个数
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --offset latest --partition 1 --max-messages 30

# 创建hncscwc消费者组, 并从2号分区 偏移量为999的位置开始消费 2条消息
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --group hncscwc --partition 2 --offset 999 --max-messages 2
```
- --from-beginning 读取主题中所有的数据，从头开始消费
- --partition 从指定的分区消费消息
- --offset 执行消费的起始offset位置 
- --group 以指定消费者组的形式消费消息
- --max-messages 指定消费消息的最大个数
- --zookeeper 0.9之前的版本使用
- --bootstrap-server 0.9之后的版本使用

6、修改topics
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

2）移除config
```
# bin/kafka-configs.sh --zookeeper node001:2181 --entity-type topics --entity-name my_topic_name --alter --delete-config x
# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my_topic_name --alter --delete-config x
```

3）查询config
```
# bin/kafka-configs.sh --describe --bootstrap-server localhost:9092 --topic my_topic_name
或者
# bin/kafka-configs.sh --describe --bootstrap-server localhost:9092 --entity-type topics --entity-name my_topic_name
```

4）查询kafka版本信息
```
# bin/kafka-configs.sh --describe --bootstrap-server localhost:9092 --version
```


5）修改topic
```
# kafka-topics.sh --zookeeper localhost:2181 --create --topic test --partitions 2 --replication-factor 1
# kafka-topics.sh --zookeeper localhost:2181 --alter --topic test --config max.message.bytes=1048576
# kafka-topics.sh --zookeeper localhost:2181 --describe --topic test
# kafka-topics.sh --zookeeper localhost:2181 --alter --topic test --config segment.bytes=10485760
# kafka-topics.sh --zookeeper localhost:2181 --alter --delete-config max.message.bytes --topic test
```

7、删除topic
```
# kafka-topics.sh --zookeeper node001:2181 --delete --topic test
Topic test is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.
```  
- 需要server.properties中设置delete.topic.enable=true否则只是标记删除或者直接重启。

8、查看topic的分区及副本
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

9、查看topic消费到的offset
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

# 管理consumer group

- `consumer group`命令行可以list、describe或者delete消费组。`consumer group`可以手工删除，或者是根据日志留存策略在过期后被自动删除。如果要手动删除，那就必须要保证该group当前已经没有活跃的成员(active members)了。

1、在创建consumer时指定消费组
```
# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning --consumer-property group.id=test-group1
```

2、查询consumer消费信息

- 在kafka 0.9版本之后，kafka的consumer group和offset信息就不保存在zookeeper中了。

```
# 0.9版本之前kafka查看所有消费组
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

3、列出所有topic的消费组
```
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
test-consumer-group
```

4、查看消费偏移，可以describe消费组
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group
TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                    HOST            CLIENT-ID
topic3          0          241019          395308          154289          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
topic2          1          520678          803288          282610          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
topic3          1          241018          398817          157799          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
topic1          0          854144          855809          1665            consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1
topic2          0          460537          803290          342753          consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1
topic3          2          243655          398812          155157          consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1      consumer4
```
- CURRENT-OFFSET 表示当前消费的offset
- LOG-END-OFFSET 表示最新的offset，也就是生产者最新的offset,总共的offset
- LAG 表示堆积

4.1、`--members`选项，获取一个`consumer group`中所有的active members。
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group --members
CONSUMER-ID                                    HOST            CLIENT-ID       #PARTITIONS
consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1       2
consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1      consumer4       1
consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2       3
consumer3-ecea43e4-1f01-479f-8349-f9130b75d8ee /127.0.0.1      consumer3       0
```
- 上面显示consumer1当前正在消费两个分区，consumer4正在消费1个分区。

4.2、`--members` `--verbose`选项,在--members选项的基础上，本选项用于列出consumer正在消费哪些分区。
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group --members --verbose

CONSUMER-ID                                    HOST            CLIENT-ID       #PARTITIONS     ASSIGNMENT
consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1       2               topic1(0), topic2(0)
consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1      consumer4       1               topic3(2)
consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2       3               topic2(1), topic3(0,1)
consumer3-ecea43e4-1f01-479f-8349-f9130b75d8ee /127.0.0.1      consumer3       0               -
```

4.3、`--offsets`选项，这是默认的describe选项，提供的输出与--describe相同。

4.4、`--state`选项，提供一些有用的group级别的信息。
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group --state
COORDINATOR (ID)          ASSIGNMENT-STRATEGY       STATE                #MEMBERS
localhost:9092 (0)        range                     Stable               4
```

4.5、`--delete`选项，手动的删除一个或多个consumer group(s)。
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --delete --group my-group --group my-other-group
Deletion of requested consumer groups ('my-group', 'my-other-group') was successful.
```

4.6、如果想要重置一个consumer group的offsets，可以使用`--reset-offsets`选项。本选项只支持一次重置一个consumer group，在重置offsets时还需要指定作用域：`--all-topics`或`--topic`。另外，还需要确保在重置是consumer处于Inactive状态。

执行offsets重置时，有3个执行选项：
- (default): 显示哪些offsets会被重置
- --execute: 用于执行--reset-offsets进程
- --export: 将结果导出为CSV格式

--reset-offsets可以通过如下方式来指定要重置到哪个位置：
```
--to-datetime <String: datetime>: 将offsets重置指定的日期。日期格式为'YYYY-MM-DDTHH:mm:SS.sss'
--to-earliest : 重置offsets到earliest
--to-latest: 重置offsets到latest
--shift-by <Long: number-of-offsets>: 将offsets重置为当前值+'n'，这里'n'可以可以是正数也可以是负数
--from-file : 将offsets重置到CSV文件中指定的位置
--to-current: 将offsets重置到当前位置
--to-offset: 将offsets重置到一个指定的偏移值
```
- 如果要重置的offsets已经超出了当前可用的offset，那么就只会被重置为当前可用offset的结尾处。例如，假如offset end是10，我们使用offset shift请求来设置偏移到15，那么最后offset仍只能被重置为10。

将偏移量设置为最早的
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --group consumergroup1 --to-earliest --topic topic1
```

将偏移量设置为最新的
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --group consumergroup1 --to-latest --topic topic1
TOPIC                          PARTITION  NEW-OFFSET
topic1                         0          0
```

分别将指定主题的指定分区的偏移量向前移动10个消息
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --group consumergroup1 --topic topic1 --shift-by -10
```

5、删除group
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group consumergroup1 --delete
```

# 检查consumer的消费偏移

要查看consumer的消费偏移信息。
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group
 
TOPIC                          PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG        CONSUMER-ID                                       HOST                           CLIENT-ID
my-topic                       0          2               4               2          consumer-1-029af89c-873c-4751-a720-cefd41a669d6   /127.0.0.1                     consumer-1
my-topic                       1          2               3               1          consumer-1-029af89c-873c-4751-a720-cefd41a669d6   /127.0.0.1                     consumer-1
my-topic                       2          2               3               1          consumer-2-42c1abd4-e3b2-425d-a8bb-e1ea49b29bb2   /127.0.0.1                     consumer-2
```
- TOPIC：该group里消费的topic名称
- PARTITION：分区编号
- CURRENT-OFFSET：该分区当前消费到的offset
- LOG-END-OFFSET：该分区当前latest offset
- LAG：消费滞后区间，为LOG-END-OFFSET-CURRENT-OFFSET，具体大小需要看应用消费速度和生产者速度，一般过大则可能出现消费跟不上，需要引起应用注意
- CONSUMER-ID：server端给该分区分配的consumer编号
- HOST：消费者所在主机
- CLIENT-ID：消费者id，一般由应用指定


如果想控制当前offset，需要注意的是这里面的消息消费过后可能超出了kafka日志留存策略，所以你只能控制到近期仍保留的日志偏移。
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group your_consumer_group_name --topic your_topic_name --execute --reset-offsets --to-offset 80
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group your_consumper_group_name
```

# 查看kafka topic的消息offset范围

1、查看各个patition消息的最大Offset
```
# bin/kafka-run-class.sh kafka.tools.GetOffsetShell \
--topic topic_name \
--time -1 \
--broker-list host1:9092,host2:9092,host3:9092
```

2、查看各个partition消息的最小Offset
```
# bin/kafka-run-class.sh kafka.tools.GetOffsetShell \
--topic topic_name \
--time -2 \
--broker-list host1:9092,host2:9092,host3:9092
```

3、计算可消费的消息个数
```
# max=`sh kafka-run-class.sh kafka.tools.GetOffsetShell --topic topic_name --time -1 --broker-list host1:9092,host2:9092,host3:9092|awk -F':' '{print $3}'| awk ' { SUM += $1 } END { print SUM }'`

# min=`sh kafka-run-class.sh kafka.tools.GetOffsetShell --topic topic_name --time -2 --broker-list host1:9092,host2:9092,host3:9092|awk -F':' '{print $3}'| awk ' { SUM += $1 } END { print SUM }'`

# echo $(($max-$min))
```

# 优雅的关闭

kafka集群会自动的侦测任何broker的关闭或者是失效，然后为相应的分区重新选举出新的leader。这在broker因故障失效，或者人为的主动关闭(如进行系统维护），或者配置修改均会触发相应的Leader选举动作。对于后面的一些场景（系统维护、配置修改），kafka支持一种更加优雅的机制来进行关闭，而不是直接将其kill掉。当kafka是被优雅的关闭时，其主要是做了如下两方面的优化：
- 主动的将日志数据同步到硬盘，以避免在进行重启时需要进行日志恢复（校验日志文件尾部的若干消息的checksum)，从而可以提高系统的启动速度
- 在broker关闭之前，会迁移Leader是该broker的分区。这可以加快后续相应分区Leader的选举的速度，并降低相应分区处于不可用状态的时间。

无论broker是被优雅的关闭，还是直接kill，都会触发日志的同步。但是受控的Leadership迁移需要如下特殊设置：
```
controlled.shutdown.enable=true
```
值得注意的是，受控的关闭只在该broker有replicas(即副本数大于等于1，并且至少要有一个副本处于alive状态)的情况下才有效。

# 平衡leadership

无论什么时候一个broker关闭或者崩溃，如果某些partitions的leadership在该broker上，那么将会进行leadship转移。这就意味着在默认情况下，当broker重启，该broker只会成为相应分区的follower，从而不会在该broker上进行任何的读写操作。

为了避免这样导致的不平衡，kafka有一个首选副本的概念。假如某一个分区的副本列表是1、5、9，则node1会更被倾向于成为leader，因为node1排在整个副本列表的首位。你可以运行如下命令，尝试让kafka集群恢复leadership到原来的broker上：
```
# bin/kafka-preferred-replica-election.sh --zookeeper zk_host:port/chroot
```
由于每次运行此命名可能会十分繁琐，因此我们可以通过如下配置来让kafka自动的来完成：
```
auto.leader.rebalance.enable=true
```

# 跨rack平衡replicas

kafka的rack感知特性(rack awareness feature)分区的副本放到不同的rack上。此扩展保证了kafka能够应对因rack故障导致的broker失效问题，从而降低了数据丢失的风险。

你可以通过broker的配置参数指定broker是属于哪一个特定的rack：
```
broker.rack=my-rack-id
```
当创建、修改topic，或者replicas redistributed时，此rack参数的限制就会起作用，确保副本之间尽量分布到不同的rack上面。

kafka中为broker分配replicas的算法会确保每个broker的leader都会是一个常量，而不管broker的跨rack情况如何。这从整体上保证了集群的平衡。

然而，假如rack之间brokers数量是不相等的，则副本的指定将会是不平衡的。那些brokers数量更少的rack会有更多的replicas，这就意味着会在这些brokers上面存储更多的数据。因此，我们最好保证每个rack上都有相等的broker数量。

# 集群之间镜像(mirror)数据

为区分单个kafka集群broker节点之间的数据复制，这里我们将集群之间复制(replicate)数据的过程称为mirroring。kafka提供了一个相应的工具来在集群之间进行数据镜像，该工具会从source cluster消费数据，然后发布到destination cluster。这种数据镜像(mirror)的常见使用场景是：在其他的数据中保存一个副本。

我们可以运行多个镜像(mirror)进程来增加吞吐率和容错性（假如一个进程失效，则其他的进程将会接管相应的负载）。

kafka-mirror-maker.sh会从source cluster相应的topic中读取数据，然后将其写到destination cluster相同名称的topic中。实际上mirror maker相当于把consumer以及producer相应功能组合到了一起。

source及destination cluster是两个完全独立的entry: 两个集群可以有不同的partitions数量，offsets也会不同。 由于这样的原因，镜像(mirror)一个cluster其实并不能作为一个很好的容错机制，我们还是建议采用使用单个集群内的副本复制。mirror maker进程会使用相同的message key来映射分区，因此消息之间的整体排列还是不会被打乱。

如下我们给出一个示例展示如何mirror一个topic:
```
#  bin/kafka-mirror-maker.sh --consumer.config consumer.properties --producer.config producer.properties --whitelist my-topic
```
上面我们注意到使用了`--whitelist`选项来指定topic列表，该选项允许使用任何java风格的正则表达式。因此你可以使用`--whitelist 'A|B'`来mirror topic A以及topic B。或者你也可以使用`--whitelist '*'`来mirror所有的topic。请使用单引号(`''`)把正则表达式括起来，以免shell将其解释为文件路径。此外，为了使用方便我们允许使用,'来代替|用于指定多个topic。之后再配合使用`auto.create.topics.enable=true`，使得在Mirror数据时自动的进行topic数据创建.


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
