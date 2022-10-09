# 前言

在之前的开发工作中，需要开发使用用户名密码的方式连接 Kafka 并对 Kafka 数据进行处理，但是客户并没有提供可以测试的环境，于是就自己着手搭建了一套单节点的 Kafka 并开启 SASL 认证。

# 一、环境准备

## 1、组件版本

| 组件 | 版本 |
|------|------|
| kafka | 2.11-2.22 |
| zookeeper | 3.6.2 |

## 2、下载文件

KAFKA：[下载地址](https://link.csdn.net/?target=https%3A%2F%2Farchive.apache.org%2Fdist%2Fkafka%2F2.2.2%2Fkafka_2.11-2.2.2.tgz)

ZOOKEEPER：[下载地址](https://link.csdn.net/?target=https%3A%2F%2Farchive.apache.org%2Fdist%2Fzookeeper%2Fzookeeper-3.6.2%2Fapache-zookeeper-3.6.2-bin.tar.gz)

## 3、上传文件
```
# 将下载的 zookeeper 和 kafka 包上传到 /opt/software 目录下
mkdir -p /opt/software
# 组件的安装目录
mkdir -p /opt/module
# 组件数据存放目录
mkdir -p /opt/data
```

# 二、安装 Zookeeper（单节点）
```
# 解压zookeeper文件到/opt/modele/目录下
cd /opt/software
tar -zxvf apache-zookeeper-3.6.2-bin.tar.gz -C /opt/module/

# 进入解压后的文件
cd /opt/module/apache-zookeeper-3.6.2-bin

# ll 可以发现文件夹结构如下
ll
	drwxr-xr-x 2 root root  4096 Sep  4  2020 bin
	drwxr-xr-x 2 root root  4096 Sep  4  2020 conf
	drwxr-xr-x 5 root root  4096 Sep  4  2020 docs
	drwxr-xr-x 2 root root  4096 Jul  6 11:27 lib
	-rw-r--r-- 1 root root 11358 Sep  4  2020 LICENSE.txt
	-rw-r--r-- 1 root root   432 Sep  4  2020 NOTICE.txt
	-rw-r--r-- 1 root root  1963 Sep  4  2020 README.md
	-rw-r--r-- 1 root root  3166 Sep  4  2020 README_packaging.md

# 创建zk配置文件
cd conf/
cp zoo_sample.cfg zoo.cfg
vim zoo.cfg
	# 修改如下配置（数据存储文件，自定义都行，不修改也行）
	dataDir=/tmp/zookeeper => dataDir=/opt/data/zookeeper

# 记得创建刚才配置的地址
mkdir -p /opt/data/zookeeper

# ok 启动 zk
cd ../bin/
sh zkServer.sh start
	
# 执行启动命令后控制台打印如下日志
ZooKeeper JMX enabled by default
Using config: /opt/module/apache-zookeeper-3.6.2-bin/bin/../conf/zoo.cfg
Starting zookeeper ... FAILED TO START

# ok 很明显启动失败了 我们查看日志
less ../logs/zookeeper-root-server-zujian1.sdns.bigdata.suxr.sit.testpbcdci.out
	#可以看到如下的日志
	Problem starting AdminServer on address 0.0.0.0, port 8080 and command URL /commands
	Caused by: java.io.IOException: Failed to bind to /0.0.0.0:8080
	Caused by: java.net.BindException: Address already in use
	# 发现 8080端口已经被占用了，这是Zookeeper 3.5 之后的新特性，AdminServer 默认使用8080端口
	
# 修改 AdminServer 的默认端口
vim ../conf/zoo.cfg
	# 添加如下配置
	admin.serverPort=8081
	
# 重新启动zk
sh zkServer.sh start

# 看到如下日志表示启动成功
ZooKeeper JMX enabled by default
Using config: /opt/module/apache-zookeeper-3.6.2-bin/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

# 其他命令
sh zkServer.sh restart # 重启
sh zkServer.sh stop # 停止
sh zkServer.sh status # 查看zk运行状态
```

# 三、安装 Kafka（单节点）
```
# 解压 kafka 安装包
cd /opt/software/
tar -zxvf kafka_2.11-2.2.2.tgz -C /opt/module/

# 修改 kafka 配置文件
cd /opt/module/kafka_2.11-2.2.2/config
vim server.properties
	# broker 服务器要监听的地址及端口
	listeners=PLAINTEXT://hostname:9092
	# kafka消息存放的路径
	log.dirs=/opt/data/kafka/kafka-logs
	# zk 地址
	zookeeper.connect=localhost:2181/kafka

# 创建如上的文件夹
mkdir -p /opt/data/kafka/kafka-logs

# 启动 kafka
cd ../bin/
sh kafka-server-start.sh ../config/server.properties

# 查看日志，如果启动成功，则终止前台程序，改为守护进程启动
sh kafka-server-start.sh -daemon ../config/server.properties

# 查看启动日志
tail 200f ../logs/kafkaServer.out

# 创建 topic （这里需要使用主机名，使用IP会报错，我也不知道为什么）
./kafka-topics.sh --create --bootstrap-server hostname:9092 --replication-factor 1 --partitions 1 --topic topic-test

# 经过一番研究，上面的bug解决了，修改配置文件，详情查看博客（https://blog.csdn.net/chenfeng_sky/article/details/103124473）
vim ../config/server.properties
	advertised.host.name=ip

# 查看 topic
./kafka-topics.sh --bootstrap-server hostname:9092 --list

# 查看 topic 详细信息
./kafka-topics.sh --describe --bootstrap-server hostname:9092 --topic topic-test

# 启动生产者
./kafka-console-producer.sh --broker-list hostname:9092 --topic topic-test

# 开一个linux新窗口 启动消费者
./kafka-console-consumer.sh --bootstrap-server hostname:9092  --from-beginning --topic topic-test

# 往生产者中输入消息，可以看到在消费者中会打印消息，到这里，kafka 安装完成
```

# 四、Zookeeper 开启 SASL 认证

## 1、为啥需要开启zookeeper认证

kafka使用zookeeper来存储元数据，其中包括了ACL。默认的情况下，任何可以访问网络的人，都可以访问zookeeper，这意味着任何人可以：
- 通过修改配置ACL来升级特权
- 通过恶意修改zookeeper的元数据，来使得kafka集群收到污染，崩溃
- 开启认证后，可以阻止恶意修改，同事不妨碍正常访问zookeeper服务

## 2、修改 zoo.cfg，添加如下配置
```
# 开启认证功能，注意是 阿拉伯数字的 1，而不是英文字母 L。
authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
# 设置认证方式为sasl
requireClientAuthScheme=sasl
# 客户端开启 SASL
zookeeper.sasl.client=true
jaasLoginRenew=3600000
```

## 3、新增 zk_server_jaas.conf
```
cd ../conf

vim zk_server_jaas.conf

# 添加如下内容
Server {
	org.apache.kafka.common.security.plain.PlainLoginModule required
	username="admin"
	password="zookeeper-admin-pwd"
	user_kafka="kafka-zookeeper-pwd";
};
```
Server字段用于指定服务端登录配置。通过org.apache.org.apache.kafka.common.security.plain.PlainLoginModule 由指定采用 PLAIN 机制。

定义了两个用户，username 和paasword 是 zk集群之间的认证密码，user_kafka = “kafka"定义了一个用户"kafka”，密码是"kafka-zookeeper-pwd"， 通过“ user_ "为前缀后接用户名方式创建连接代理的用户名和密码。

## 4、将 kafka 认证的包导入 zk 中

从上面的配置可以看出，Zookeeper的认证机制是使用插件 “org.apache.kafka.common.security.plain.PlainLoginModule”，所以需要导入Kafka相关jar包，kafka-clients相关jar包，在kafka服务下的lib目录中可以找到，根据kafka不同版本，相关jar包版本会有所变化。
```
cp /opt/module/kafka_2.11-2.2.2/libs/kafka-clients-2.2.2.jar /opt/module/apache-zookeeper-3.6.2-bin/lib/
cp /opt/module/kafka_2.11-2.2.2/libs/lz4-java-1.5.0.jar /opt/module/apache-zookeeper-3.6.2-bin/lib/
```

## 5、修改 zkEnv.sh 添加环境变量
```
cd /opt/module/apache-zookeeper-3.6.2-bin/bin/
vim zkEnv.sh
# 添加如下变量
export SERVER_JVMFLAGS=" -Djava.security.auth.login.config=/opt/module/apache-zookeeper-3.6.2-bin/conf/zk_server_jaas.conf"
```

## 6、重启 zk
```
/opt/module/apache-zookeeper-3.6.2-bin/bin/zkServer.sh stop
/opt/module/apache-zookeeper-3.6.2-bin/bin/zkServer.sh start
/opt/module/apache-zookeeper-3.6.2-bin/bin/zkServer.sh status
```

# 五、Kafka 开启 SASL 认证

## 1、新增 kafka_server_jaas.conf 配置文件
```
cd /opt/module/kafka_2.11-2.2.2/config/

vim kafka_server_jaas.conf

# 添加如下内容
    KafkaServer {
       org.apache.kafka.common.security.plain.PlainLoginModule required
       username="admin"
       password="kafka-admin-pwd"
       user_admin="kafka-admin-pwd"
       user_kafka_client="kafka-server-pwd";
    };
    Client {
       org.apache.kafka.common.security.plain.PlainLoginModule required
       username="kafka"
       password="kafka-zookeeper-pwd";
    };
```
KafkaServer，使用 user_ 来定义多个用户，供客户端程序（生产者、消费者程序）认证使用，可以定义多个，后续配置还可以根据不同的用户定义ACL。username 和password 的值必须在 user_*中有配置，且用户名密码一致，否则kafka启动就会报错。

Client 配置 kafka 和 zookeeper 通信用的，从上文的Zookeeper JAAS文件中选择一个用户，填写用户名和密码即可。

## 2、修改 kafka-run-class.sh，添加环境变量
```
vim ../bin/kafka-run-class.sh

# 添加如下内容
export KAFKA_OPTS=" -Djava.security.auth.login.config=/opt/module/kafka_2.11-2.2.2/config/kafka_server_jaas.conf"
```

## 3、修改 server.properties 配置文件
```
listeners=SASL_PLAINTEXT://10.98.0.116:9092
advertised.listeners=SASL_PLAINTEXT://10.98.0.116:9092
# 用于在代理之间进行通信的安全协议。有效值为：PLAINTEXT、SSL、SASL_PLAINTEXT、SASL_SSL。
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
allow.everyone.if.no.acl.found=false
# super.users=User:*的值和kafka_server_jaas.conf中KafkaServer的username的值保持一致
super.users=User:admin
# 配置 kafka 使用 zookeeper 的 ACL
zookeeper.set.acl=true
```

## 4、重启 kafka
```
../bin/kafka-server-stop.sh
../bin/kafka-server-start.sh -daemon ../config/server.properties
```

## 5、查看 Topic
```
../bin/kafka-topics.sh --zookeeper hostname:2181 --list
../bin/kafka-topics.sh --bootstrap-server hostname:9092 --list
```

此时我们会发现，使用 --bootstrap-server 命令卡住不动了，我们可以查看一下日志
```
tail -200f /opt/module/kafka_2.11-2.2.2/logs/server.log

# 可以看到一直在打印异常信息
[2022-07-06 19:16:07,363] INFO [SocketServer brokerId=0] Failed authentication with /hostname (Unexpected Kafka request of type METADATA during SASL handshake.) (org.apache.kafka.common.network.Selector)

# 可以发现，SASL握手失败，brokerId=0 的 broker 认证失败了，这说明 SASL 认证开启成功了，我们和 broker 通信需要经过认证，而访问 zk 时，kafka 会将认证信息携带过去。所以我们在访问 broker 的时候也将认证信息传递过去可以了
vim /opt/module/kafka_2.11-2.2.2/config/sasl.properties
	# 添加如下认证信息，需要注意的是，username 和 password 就是之前 KafkaServer 中配置好的用户名密码。在这里先使用超级用户，因为别的用户都涉及到 ACL 授权的事，这个后面再说，超级用户不受ACL权限控制。
	sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="kafka-admin-pwd";
	security.protocol=SASL_PLAINTEXT
	sasl.mechanism=PLAIN

# 携带认证信息查看 Topic
./kafka-topics.sh --bootstrap-server hostname:9092 --list --command-config ../config/sasl.properties
```

## 6、启动生产者和消费者
```
# 启动生产者
./kafka-console-producer.sh --broker-list hostname:9092 --topic topic-test -producer.config ../config/sasl.properties

# 开一个linux新窗口 启动消费者
./kafka-console-consumer.sh --bootstrap-server hostname:9092  --from-beginning --topic topic-test -consumer.config ../config/sasl.properties
```

在生产中我们使用生产者和消费者，大都使用下面的方式进行配置。
```
# 在 kafka_server_jaas.conf 中添加 KafkaClient 的认证信息
vim ../config/kafka_server_jaas.conf
KafkaClient {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="admin"
   password="kafka-admin-pwd";
};

# 修改 consumer.properties 和 producer.properties 配置文件，添加如下内容
cat > ../config/consumer.properties <<EOF
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
EOF

cat > ../config/producer.properties <<EOF
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
EOF
```

配置好了之后，启动命令如下
```
# 启动生产者
./kafka-console-producer.sh --broker-list hostname:9092 --topic topic-test --producer.config ../config/producer.properties

# 开一个linux新窗口 启动消费者
./kafka-console-consumer.sh --bootstrap-server hostname:9092 --from-beginning --topic topic-test --consumer.config ../config/consumer.properties
````

# 六、配置 ACL

[ZK ACL](https://www.cnblogs.com/dalianpai/p/12748144.html)

[Apache Kafka](https://kafka.apache.org/22/documentation.html#security_authz)

## 1、配置 Zookeeper ACL

首先我们来看一下官网的这一段话
```
If you are running a version of Kafka that does not support security or simply with security disabled, and you want to make the cluster secure, then you need to execute the following steps to enable ZooKeeper authentication with minimal disruption to your operations:

Perform a rolling restart setting the JAAS login file, which enables brokers to authenticate. At the end of the rolling restart, brokers are able to manipulate znodes with strict ACLs, but they will not create znodes with those ACLs
Perform a second rolling restart of brokers, this time setting the configuration parameter zookeeper.set.acl to true, which enables the use of secure ACLs when creating znodes
Execute the ZkSecurityMigrator tool. To execute the tool, there is this script: ./bin/zookeeper-security-migration.sh with zookeeper.acl set to secure. This tool traverses the corresponding sub-trees changing the ACLs of the znodes
```
所以，我们要开启 Zookeeper 的 ACL 身份认证功能，执行一下的步骤即可

### 1、配置 jaas 文件，使得 kafka broker 需要认证操作 zk 中的节点。这个我们在之前开启 SASL 已经配置完成了。

### 2、在 kafka 配置文件（server.properties）中添加如下的配置
```
# 配置 kafka 使用 zookeeper 的 ACL
zookeeper.set.acl=true
```

### 3、执行如下脚本，将 zookeeper.acl 设置为 secure。此工具会遍历相应的子节点，更改 znode 的 ACL。
```
./zookeeper-security-migration.sh --zookeeper.acl=secure --zookeeper.connect=localhost:2181/kafka
```
在执行前，我们可以通过 zk 客户端来查看一下 kafka 节点的 ACL
```
/opt/module/apache-zookeeper-3.6.2-bin/bin/zkCli.sh
 [zk: localhost:2181(CONNECTED) 3] getAcl /kafka
 'world,'anyone
 : cdrwa
 [zk: localhost:2181(CONNECTED) 4]
 
 # 可以看到是默认的权限，然后我们执行上述脚本，再次查看发现节点ACL已经发生改变，表示经过 sasl 认证的kafka 用户具有 cdrwa 权限，其他所有用户都只有 r 权限。
 [zk: localhost:2181(CONNECTED) 5] getAcl /kafka
 'sasl,'kafka
 : cdrwa
 'world,'anyone
 : r
 [zk: localhost:2181(CONNECTED) 6]
```

经过我的测试，我发现如果在 zookeeper.set.acl=true 配置完成后，zk 中没有 kafka 的节点信息，那么启动 kafka 后，zk 中生成的节点信息，自动就修改了 ACL。

## 2、配置 Kafka ACL
在开始之前，我们简单学习下Kafka ACL的格式。根据官网的介绍，Kafka中一条ACL的格式如下：“Principal P is [Allowed/Denied] Operation O From Host H On Resource R”。它们的含义如下：

- principal：表示一个Kafka user
- operation：表示一个具体的操作类型，有效值: Read(读), Write(写), Create(创建), Delete(删除), Alter(修改),Describe(描述), ClusterAction(集群操作), All(所有)
- Host：表示连向Kafka集群的client的IP地址，如果是‘*’则表示所有IP。注意：当前Kafka不支持主机名，只能指定IP地址
- Resource：表示一种Kafka资源类型。当前共有5种类型：TOPIC、CLUSTER、GROUP、transactional-id、delegation-token

在之前的配置中，我们配置 kafkaClient 都是使用的超级用户，跳过了 ACL，现在我们将用户修改回来。
```
vim /opt/module/kafka_2.11-2.2.2/config/sasl.properties
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="kafka_client" password="kafka-server-pwd";
    
vim ../config/kafka_server_jaas.conf
KafkaClient {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="kafka_client"
   password="kafka-server-pwd";
};
```

配置好了之后，我们重启服务，再次启动生产者和消费者，此时我们会发现，我们当前没有权限操作 topic 了
```
[root@hostname bin]# ./kafka-console-consumer.sh --bootstrap-server hostname:9092 --topic topic-test -consumer.config ../config/consumer.properties
[2022-07-07 12:16:27,284] WARN [Consumer clientId=consumer-1, groupId=test-consumer-group] Error while fetching metadata with correlation id 2 : {topic-test=TOPIC_AUTHORIZATION_FAILED} (org.apache.kafka.clients.NetworkClient)
[2022-07-07 12:16:27,285] ERROR Error processing message, terminating consumer process:  (kafka.tools.ConsoleConsumer$)
org.apache.kafka.common.errors.TopicAuthorizationException: Not authorized to access topics: [topic-test]
Processed a total of 0 messages
[root@hostname bin]#
```

我们可以通过，如下命令来查看 topic 的权限信息
```
# 查看所有权限
./kafka-acls.sh --authorizer-properties zookeeper.connect=hostname:2181/kafka --list 
# 查看单个
./kafka-acls.sh --authorizer-properties zookeeper.connect=hostname:2181/kafka --list --topic topic-test
```

然后可以通过如下命令来对topic进行acl
```
# 给用户kafka_client topic topic-test 的 producer 权限
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=hostname:2181/kafka --topic "topic-test" --add --allow-principal User:kafka_client --producer
    
# 给用户kafka_client 所有消费者组的 topic topic-test 的 consumer 权限
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=hostname:2181/kafka --topic "topic-test" --add --allow-principal User:kafka_client --consumer --group "*"
```

配置好了之后，kafka_client 用户对 topic-test topic 就有了正常的生产消费权限，如下
```
[root@hostname bin]# ./kafka-acls.sh --authorizer-properties zookeeper.connect=hostname:2181/kafka --list
Current ACLs for resource `Topic:LITERAL:topic-test`:
        User:kafka_client has Allow permission for operations: Write from hosts: *
        User:kafka_client has Allow permission for operations: Describe from hosts: *
        User:kafka_client has Allow permission for operations: Create from hosts: *
        User:kafka_client has Allow permission for operations: Read from hosts: *
```
ACL 还有很多中限制，就看大家的实际需求去配置就行。

参考：
- https://blog.csdn.net/binter12138/article/details/124288445
- https://blog.csdn.net/qq_41581031/article/details/125648498
- https://blog.csdn.net/zhang5324496/article/details/111474084
