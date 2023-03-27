
```
kafka　　　　　　　　　　　　　　                   Kafka 根目录
├─bin                                            Kafka 运行的脚本
│  ├─connect-distributed.sh                      连接 kafka 集群模式
│  ├─connect-standalone.sh                       连接 kafka 单机模式
│  ├─kafka-acls.sh                 
│  ├─kafka-broker-api-versions.sh         
│  ├─kafka-configs.sh                            配置管理脚本
│  ├─kafka-console-consumer.sh                   kafka 消费者控制台
│  ├─kafka-console-producer.sh                   kafka 生产者控制台
│  ├─kafka-consumer-groups.sh                    kafka 消费者组相关信息
│  ├─kafka-consumer-perf-test.sh                 kafka 消费者性能测试
│  ├─kafka-delegation-tokens.sh        
│  ├─kafka-delete-records.sh                    删除低水位的日志文件
│  ├─kafka-dump-log.sh                 
│  ├─kafka-log-dirs.sh                           kafka消息日志目录
│  ├─kafka-mirror-maker.sh                       不同数据中心 kafka 集群复制工具
│  ├─kafka-preferred-replica-election.sh         触发 preferred replica 选举
│  ├─kafka-producer-perf-test.sh                 kafka 生产者性能测试脚本
│  ├─kafka-reassign-partitions.sh                分区重分配脚本
│  ├─kafka-replica-verification.sh               复制进度验证脚本
│  ├─kafka-run-class.sh        
│  ├─kafka-server-start.sh                       启动 kafka 服务
│  ├─kafka-server-stop.sh                        停止 kafka 服务
│  ├─kafka-streams-application-reset.sh         
│  ├─kafka-topics.sh                             kafka主题
│  ├─kafka-verifiable-consumer.sh                可检验的 kafka 消费者
│  ├─kafka-verifiable-producer.sh                可检验的 kafka 生产者
│  └─trogdor.sh
│  ├─windows                                    在 Windows 系统下执行的脚本目录
│  │  ├─connect-distributed.bat
│  │  └─ …                                      更多 windows 下执行的脚本文件
│  ├─zookeeper-security-migration.sh            
│  ├─zookeeper-server-start.sh                   启动 zk 服务
│  ├─zookeeper-server-stop.sh                    停止 zk 服务
│  └─zookeeper-shell.sh                         zk 客户端脚本
│
├─config                                          Kafka、zookeeper 等配置文件
│  ├─connect-console-sink.properties            
│  ├─connect-console-source.properties          
│  ├─connect-distributed.properties             
│  ├─connect-file-sink.properties               
│  ├─connect-file-source.properties             
│  ├─connect-log4j.properties                   
│  ├─connect-standalone.properties              
│  ├─consumer.properties                        消费者配置
│  ├─log4j.properties                           
│  ├─producer.properties                         生产者配置
│  ├─server.properties                           kafka 服务配置
│  ├─tools-log4j.properties       
│  ├─trogdor.conf       
│  └─zookeeper.properties                       zk 服务配置
│
├─libs                                           Kafka 运行的依赖库
│  ├─activation-1.1.1.jar
│  └─...                          
│
├─site-docs/                                    Kafka 相关文档
│  ├─kafka_2.12-2.3.1-site-docs.tgz 
```

# 1.TopicCommand

## 1.1.Topic创建
```
bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 3 --partitions 3 --topic test
```

相关可选参数

| 参数 | 描述 | 例子 |
|-----|------|------|
| --bootstrap-server 指定kafka服务 | 指定连接到的kafka服务; 如果有这个参数,则--zookeeper可以不需要 | --bootstrap-server localhost:9092 |
| --zookeeper | 弃用, 通过zk的连接方式连接到kafka集群; | --zookeeper localhost:2181 或者localhost:2181/kafka |
| --replication-factor | 副本数量,注意不能大于broker数量;如果不提供,则会用集群中默认配置 | --replication-factor 3 |
| --partitions | 分区数量,当创建或者修改topic的时候,用这个来指定分区数;如果创建的时候没有提供参数,则用集群中默认值; 注意如果是修改的时候,分区比之前小会有问题 | --partitions 3 |
| --replica-assignment | 副本分区分配方式;创建topic的时候可以自己指定副本分配情况; | --replica-assignment BrokerId-0:BrokerId-1:BrokerId-2,BrokerId-1:BrokerId-2:BrokerId-0,BrokerId-2:BrokerId-1:BrokerId-0 ; 这个意思是有三个分区和三个副本,对应分配的Broker; 逗号隔开标识分区;冒号隔开表示副本 |
| --config `<String: name=value>` | 用来设置topic级别的配置以覆盖默认配置;只在–create 和–bootstrap-server 同时使用时候生效; 可以配置的参数列表请看文末附件 | 例如覆盖两个配置 --config retention.bytes=123455 --config retention.ms=600001 |
| --command-config `<String: command 文件路径>` | 用来配置客户端Admin Client启动配置,只在–bootstrap-server 同时使用时候生效; | 例如:设置请求的超时时间 --command-config config/producer.proterties; 然后在文件中配置 request.timeout.ms=300000 |

## 1.2.删除Topic
```
bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic test
```
支持正则表达式匹配Topic来进行删除,只需要将topic 用双引号包裹起来

例如: 删除以`create_topic_byhand_zk`为开头的topic;
```
bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic "create_topic_byhand_zk.*"
```
- .表示任意匹配除换行符 \n 之外的任何单字符。要匹配 . ，请使用 . 。
- ·*·：匹配前面的子表达式零次或多次。要匹配 * 字符，请使用 *。
- .* : 任意字符

删除任意Topic (慎用)
```
bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic ".*?"
```
更多的用法请[参考正则表达式](https://www.runoob.com/regexp/regexp-syntax.html)

相关配置

| 配置 | 描述 | 默认 |
|-----|------|------|
| file.delete.delay.ms | topic删除被标记为–delete文件之后延迟多长时间删除正在的Log文件 | 60000 |
| delete.topic.enable | true | 是否能够删除topic |

## 1.3.Topic分区扩容

zk方式(不推荐)
```
>bin/kafka-topics.sh --zookeeper localhost:2181 --alter --topic topic1 --partitions 2
```

**kafka版本 >= 2.2 支持下面方式（推荐）**

单个Topic扩容
```
bin/kafka-topics.sh --bootstrap-server broker_host:port --alter --topic test_create_topic1 --partitions 4
```

批量扩容 (将所有正则表达式匹配到的Topic分区扩容到4个)
```
sh bin/kafka-topics.sh --topic ".*?" --bootstrap-server 172.23.248.85:9092 --alter --partitions 4
```
- ".*?" 正则表达式的意思是匹配所有; 您可按需匹配

**PS**: 当某个Topic的分区少于指定的分区数时候,他会抛出异常;但是不会影响其他Topic正常进行;

相关可选参数

| 参数 | 描述 | 例子 |
|------|-----|------|
| --replica-assignment | 副本分区分配方式;创建topic的时候可以自己指定副本分配情况; | --replica-assignment BrokerId-0:BrokerId-1:BrokerId-2,BrokerId-1:BrokerId-2:BrokerId-0,BrokerId-2:BrokerId-1:BrokerId-0 ; 这个意思是有三个分区和三个副本,对应分配的Broker; 逗号隔开标识分区;冒号隔开表示副本 |

**PS**: 虽然这里配置的是全部的分区副本分配配置,但是正在生效的是新增的分区;

比如: 以前3分区1副本是这样的

| Broker-1 | Broker-2 | Broker-3 | Broker-4 |
|----------|----------|----------|----------|
| 0 | 1 | 2 |  |

现在新增一个分区,--replica-assignment 2,1,3,4 ; 看这个意思好像是把0，1号分区互相换个Broker

| Broker-1 | Broker-2 | Broker-3 | Broker-4 |
|----------|----------|----------|----------|
| 1 | 0 | 2 | 3 |

但是实际上不会这样做,Controller在处理的时候会把前面3个截掉; 只取新增的分区分配方式,原来的还是不会变

| Broker-1 | Broker-2 | Broker-3 | Broker-4 |
|----------|----------|----------|----------|
| 0 | 1 | 2 | 3 |

## 1.4.查询Topic描述

1.查询单个Topic
```
sh bin/kafka-topics.sh --topic test --bootstrap-server xxxx:9092 --describe --exclude-internal
```

2.批量查询Topic(正则表达式匹配,下面是查询所有Topic)
```
sh bin/kafka-topics.sh --topic ".*?" --bootstrap-server xxxx:9092 --describe --exclude-internal
```
支持正则表达式匹配Topic,只需要将topic 用双引号包裹起来

相关可选参数

| 参数 | 描述 | 例子 |
|------|------|-----|
| --bootstrap-server 指定kafka服务 | 指定连接到的kafka服务; 如果有这个参数,则 --zookeeper可以不需要 | --bootstrap-server localhost:9092 |
| --at-min-isr-partitions | 查询的时候省略一些计数和配置信息 | --at-min-isr-partitions |
| --exclude-internal | 排除kafka内部topic,比如__consumer_offsets-* | --exclude-internal |
| --topics-with-overrides | 仅显示已覆盖配置的主题,也就是单独针对Topic设置的配置覆盖默认配置；不展示分区信息 | --topics-with-overrides |

## 1.5.查询Topic列表

1.查询所有Topic列表
```
sh bin/kafka-topics.sh --bootstrap-server xxxxxx:9092 --list --exclude-internal
```

2.查询匹配Topic列表(正则表达式)

查询test_create_开头的所有Topic列表
```
sh bin/kafka-topics.sh --bootstrap-server xxxxxx:9092 --list --exclude-internal --topic "test_create_.*"
```

相关可选参数

| 参数 | 描述 | 例子 |
|-----|------|------|
| --exclude-internal | 排除kafka内部topic,比如__consumer_offsets-* | --exclude-internal |
| --topic | 可以正则表达式进行匹配,展示topic名称 | --topic |

# 2.ConfigCommand

> Config相关操作; 动态配置可以覆盖默认的静态配置;

## 2.1 查询配置

**Topic配置查询**

> 展示关于Topic的动静态配置

1.查询单个Topic配置(只列举动态配置)
```
sh bin/kafka-configs.sh --describe --bootstrap-server xxxxx:9092 --topic test_create_topic
或者
sh bin/kafka-configs.sh --describe --bootstrap-server 172.23.248.85:9092 --entity-type topics --entity-name test_create_topic
```

2.查询所有Topic配置(包括内部Topic)(只列举动态配置)
```
sh bin/kafka-configs.sh --describe --bootstrap-server 172.23.248.85:9092 --entity-type topics
```



3.查询Topic的详细配置(动态+静态)

> 只需要加上一个参数--all

**其他配置/clients/users/brokers/broker-loggers 的查询**

> 同理 ；只需要将--entity-type 改成对应的类型就行了 (topics/clients/users/brokers/broker-loggers)



查询kafka版本信息
```
sh bin/kafka-configs.sh --describe --bootstrap-server xxxx:9092 --version
```

所有可配置的动态配置 请看最后面的 附件 部分

## 2.2 增删改 配置 --alter

--alter
- **删除配置**: --delete-config k1=v1,k2=v2
- **添加/修改配置**: --add-config k1,k2
- **选择类型**: --entity-type (topics/clients/users/brokers/broker-loggers)
- **类型名称**: --entity-name

Topic添加/修改动态配置
- --add-config
```
sh bin/kafka-configs.sh --bootstrap-server xxxxx:9092 --alter --entity-type topics --entity-name test_create_topic1 --add-config file.delete.delay.ms=222222,retention.ms=999999
```

Topic删除动态配置
- --delete-config
```
sh bin/kafka-configs.sh --bootstrap-server xxxxx:9092 --alter --entity-type topics --entity-name test_create_topic1 --delete-config file.delete.delay.ms,retention.ms
```

添加/删除配置同时执行
```
sh bin/kafka-configs.sh --bootstrap-server xxxxx:9092 --alter --entity-type brokers --entity-default --add-config log.segment.bytes=788888888 --delete-config log.retention.ms
```

**其他配置同理,只需要类型改下--entity-type**

> 类型有: (topics/clients/users/brokers/broker- loggers)

哪些配置可以修改 请看最后面的附件：ConfigCommand 的一些可选配置

**默认配置**

- 配置默认 --entity-default
```
sh bin/kafka-configs.sh --bootstrap-server xxxxx:9090 --alter --entity-type brokers --entity-default --add-config log.segment.bytes=88888888
```

动态配置的默认配置是使用了节点 `<defalut>`;


该图转自https://www.cnblogs.com/lizherui/p/12271285.html

优先级 指定动态配置>默认动态配置>静态配置

# 3.副本扩缩、分区迁移、跨路径迁移 kafka-reassign-partitions

# 4.Topic的发送kafka-console-producer.sh

## 4.1 生产无key消息
```
## 生产者
bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test --producer.config config/producer.properties
```

## 4.2 生产有key消息
加上属性--property parse.key=true
```
## 生产者
bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test --producer.config config/producer.properties  --property parse.key=true
```

**默认消息key与消息value间使用“Tab键”进行分隔，所以消息key以及value中切勿使用转义字符(\t)**

可选参数

| 参数 | 值类型 | 说明 | 有效值 |
|------|-------|------|--------|
| –bootstrap-server | String | 要连接的服务器必需(除非指定–broker-list) | 如：host1:prot1,host2:prot2 |
| –topic | String | (必需)接收消息的主题名称 | |
| –batch-size | Integer | 单个批处理中发送的消息数 | 200(默认值) |
| –compression-codec | String | 压缩编解码器 | none、gzip(默认值)snappy、lz4、zstd |
| –max-block-ms | Long | 在发送请求期间，生产者将阻止的最长时间 | 60000(默认值) |
| –max-memory-bytes | Long | 生产者用来缓冲等待发送到服务器的总内存 | 33554432(默认值) |
| –max-partition-memory-bytes | Long | 为分区分配的缓冲区大小 | 16384 |
| –message-send-max-retries | Integer | 最大的重试发送次数 | 3 |
| –metadata-expiry-ms | Long | 强制更新元数据的时间阈值(ms) | 300000 |
| –producer-property | String | 将自定义属性传递给生成器的机制 | 如：key=value |
| –producer.config | String | 生产者配置属性文件[–producer-property]优先于此配置 配置文件完整路径 | |
| –property | String | 自定义消息读取器 | parse.key=true/false key.separator=<key.separator>ignore.error=true/false |
| –request-required-acks | String | 生产者请求的确认方式 | 0、1(默认值)、all |
| –request-timeout-ms | Integer | 生产者请求的确认超时时间 | 1500(默认值) |
| –retry-backoff-ms | Integer	生产者重试前，刷新元数据的等待时间阈值 | 100(默认值) |
| –socket-buffer-size | Integer | TCP接收缓冲大小 | 102400(默认值) |
| –timeout | Integer | 消息排队异步等待处理的时间阈值 | 1000(默认值) |
| –sync | 同步发送消息 | |
| –version | 显示 Kafka 版本 | 不配合其他参数时，显示为本地Kafka版本 |
| –help | 打印帮助信息 |  |

# 5. Topic的消费kafka-console-consumer.sh

## 5.1. 新客户端从头消费--from-beginning (注意这里是新客户端,如果之前已经消费过了是不会从头消费的)
下面没有指定客户端名称,所以每次执行都是新客户端都会从头消费
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

## 5.2. 正则表达式匹配topic进行消费--whitelist
消费所有的topic
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --whitelist ‘.*’
```

消费所有的topic，并且还从头消费
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --whitelist ‘.*’ --from-beginning
```

## 5.3.显示key进行消费--property print.key=true
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --property print.key=true
```

## 5.4. 指定分区消费--partition 指定起始偏移量消费--offset
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --partition 0 --offset 100
```

## 5.5. 给客户端命名--group

注意给客户端命名之后,如果之前有过消费，那么--from-beginning 就不会再从头消费了
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --group test-group
```

## 5.6. 添加客户端属性--consumer-property

这个参数也可以给客户端添加属性,但是注意 不能多个地方配置同一个属性,他们是互斥的;比如在下面的基础上还加上属性--group test-group 那肯定不行
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --consumer-property group.id=test-consumer-group
```

## 5.7. 添加客户端属性--consumer.config

跟--consumer-property 一样的性质,都是添加客户端的属性,不过这里是指定一个文件,把属性写在文件里面, --consumer-property 的优先级大于 --consumer.config
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --consumer.config config/consumer.properties
```

| 参数 | 描述 | 例子 |
|------|-----|------|
| --group | 指定消费者所属组的ID |  |
| --topic | 被消费的topic |  |
| --partition | 指定分区 ；除非指定–offset，否则从分区结束(latest)开始消费 | --partition 0 |
| --offset | 执行消费的起始offset位置 ;默认值: latest; /latest /earliest /偏移量 | --offset 10 |
| --whitelist | 正则表达式匹配topic；--topic就不用指定了; 匹配到的所有topic都会消费; 当然用了这个参数,--partition --offset等就不能使用了 | |
| --consumer-property | 将用户定义的属性以key=value的形式传递给使用者 | --consumer-property group.id=test-consumer-group |
| --consumer.config | 消费者配置属性文件请注意，[consumer-property]优先于此配置 | --consumer.config config/consumer.properties |
| --property | 初始化消息格式化程序的属性 | print.timestamp=true,false 、print.key=true,false 、print.value=true,false 、key.separator=`<key.separator>`、line.separator=`<line.separator>`、key.deserializer=`<key.deserializer>`、value.deserializer=`<value.deserializer>` |
| --from-beginning | 从存在的最早消息开始，而不是从最新消息开始,注意如果配置了客户端名称并且之前消费过，那就不会从头消费了 |  |
| --max-messages | 消费的最大数据量，若不指定，则持续消费下去 | --max-messages 100 |
| --skip-message-on-error | 如果处理消息时出错，请跳过它而不是暂停 |
| --isolation-level | 设置为read_committed以过滤掉未提交的事务性消息,设置为read_uncommitted以读取所有消息,默认值:read_uncommitted |
| --formatter | kafka.tools.DefaultMessageFormatter、kafka.tools.LoggingMessageFormatter、kafka.tools.NoOpMessageFormatter、kafka.tools.ChecksumMessageFormatter |

# 6.kafka-leader-election Leader重新选举

## 6.1 指定Topic指定分区用重新PREFERRED：优先副本策略 进行Leader重选举
```
> sh bin/kafka-leader-election.sh --bootstrap-server xxxx:9090 --topic test_create_topic4 --election-type PREFERRED --partition 0
```

## 6.2 所有Topic所有分区用重新PREFERRED：优先副本策略 进行Leader重选举
```
sh bin/kafka-leader-election.sh --bootstrap-server xxxx:9090 --election-type preferred  --all-topic-partitions
```

## 6.3 设置配置文件批量指定topic和分区进行Leader重选举

先配置leader-election.json文件
```
{
  "partitions": [
    {
      "topic": "test_create_topic4",
      "partition": 1
    },
    {
      "topic": "test_create_topic4",
      "partition": 2
    }
  ]
}
```

```
sh bin/kafka-leader-election.sh --bootstrap-server xxx:9090 --election-type preferred  --path-to-json-file config/leader-election.json
```
相关可选参数

| 参数 | 描述 | 例子 |
|------|-----|------|
| --bootstrap-server 指定kafka服务 | 指定连接到的kafka服务 | --bootstrap-server localhost:9092 |
| --topic | 指定Topic，此参数跟--all-topic-partitions和path-to-json-file 三者互斥 |  |
| --partition | 指定分区,跟--topic搭配使用 |  |
| --election-type | 两个选举策略(PREFERRED:优先副本选举,如果第一个副本不在线的话会失败;UNCLEAN: 策略) |  |
| --all-topic-partitions | 所有topic所有分区执行Leader重选举; 此参数跟--topic和path-to-json-file 三者互斥 |  |
| --path-to-json-file | 配置文件批量选举，此参数跟--topic和all-topic-partitions 三者互斥 |  |

# 7. 持续批量推送消息kafka-verifiable-producer.sh

单次发送100条消息--max-messages 100

一共要推送多少条，默认为-1，-1表示一直推送到进程关闭位置
```
sh bin/kafka-verifiable-producer.sh --topic test_create_topic4 --bootstrap-server localhost:9092 --max-messages 100
```

每秒发送最大吞吐量不超过消息 --throughput 100

推送消息时的吞吐量，单位messages/sec。默认为-1，表示没有限制
```
sh bin/kafka-verifiable-producer.sh --topic test_create_topic4 --bootstrap-server localhost:9092 --throughput 100
```

发送的消息体带前缀--value-prefix
```
sh bin/kafka-verifiable-producer.sh --topic test_create_topic4 --bootstrap-server localhost:9092 --value-prefix 666
```
注意 --value-prefix 666必须是整数,发送的消息体的格式是加上一个 点号. 例如： 666.

其他参数：
- --producer.config CONFIG_FILE 指定producer的配置文件
- --acks ACKS 每次推送消息的ack值，默认是-1

8. 持续批量拉取消息kafka-verifiable-consumer

持续消费
```
sh bin/kafka-verifiable-consumer.sh --group-id test_consumer --bootstrap-server localhost:9092 --topic test_create_topic4
```

单次最大消费10条消息--max-messages 10
```
sh bin/kafka-verifiable-consumer.sh --group-id test_consumer --bootstrap-server localhost:9092 --topic test_create_topic4 --max-messages 10
```

相关可选参数

| 参数 | 描述 | 例子 |
|------|-----|------|
| --bootstrap-server | 指定kafka服务	指定连接到的kafka服务; | –bootstrap-server localhost:9092 |
| --topic | 指定消费的topic |  |
| --group-id | 消费者id；不指定的话每次都是新的组id |  |
| --group-instance-id | 消费组实例ID,唯一值 |  |
| --max-messages | 单次最大消费的消息数量 |  |
| --enable-autocommit | 是否开启offset自动提交；默认为false |  |
| --reset-policy | 当以前没有消费记录时，选择要拉取offset的策略，可以是earliest, latest,none。默认是earliest | |
| --assignment-strategy | consumer分配分区策略，默认是org.apache.kafka.clients.consumer.RangeAssignor | |
| --consumer.config | 指定consumer的配置文件 | |

# 9.生产者压力测试kafka-producer-perf-test.sh

1. 发送1024条消息`--num-records 100`并且每条消息大小为1KB`--record-size 1024` 最大吞吐量每秒10000条`--throughput 100`
```
sh bin/kafka-producer-perf-test.sh --topic test_create_topic4 --num-records 100 --throughput 100000 --producer-props bootstrap.servers=localhost:9092 --record-size 1024
```
你可以通过LogIKM查看分区是否增加了对应的数据大小

从LogIKM 可以看到发送了1024条消息; 并且总数据量=1M; 1024条*1024byte = 1M;

2. 用指定消息文件`--payload-file`发送100条消息最大吞吐量每秒100条--throughput 100

先配置好消息文件batchmessage.txt


然后执行命令
发送的消息会从batchmessage.txt里面随机选择; 注意这里我们没有用参数--payload-delimeter指定分隔符，默认分隔符是\n换行;
```
bin/kafka-producer-perf-test.sh --topic test_create_topic4 --num-records 1024 --throughput 100 --producer-props bootstrap.servers=localhost:9090 --payload-file config/batchmessage.txt
```
验证消息，可以通过 LogIKM 查看发送的消息



相关可选参数

| 参数 | 描述 | 例子 |
|------|-----|------|
| --topic | 指定消费的topic | |
| --num-records | 发送多少条消息 | |
| --throughput | 每秒消息最大吞吐量 | |
| --producer-props | 生产者配置, k1=v1,k2=v2 | --producer-props bootstrap.servers= localhost:9092,client.id=test_client |
| --producer.config | 生产者配置文件 | --producer.config config/producer.propeties |
| --print-metrics | 在test结束的时候打印监控信息,默认false | --print-metrics true |
| --transactional-id | 指定事务 ID，测试并发事务的性能时需要，只有在 --transaction-duration-ms > 0 时生效，默认值为 performance-producer-default-transactional-id | |
| --transaction-duration-ms | 指定事务持续的最长时间，超过这段时间后就会调用 commitTransaction 来提交事务，只有指定了 > 0 的值才会开启事务，默认值为 0 | |
| --record-size | 一条消息的大小byte; 和 --payload-file 两个中必须指定一个，但不能同时指定 | |
| --payload-file | 指定消息的来源文件，只支持 UTF-8 编码的文本文件，文件的消息分隔符通过 --payload-delimeter指定,默认是用换行\nl来分割的，和 --record-size 两个中必须指定一个，但不能同时指定 ; 如果提供的消息 | |
| --payload-delimeter | 如果通过 --payload-file 指定了从文件中获取消息内容，那么这个参数的意义是指定文件的消息分隔符，默认值为 \n，即文件的每一行视为一条消息；如果未指定--payload-file则此参数不生效；发送消息的时候是随机送文件里面选择消息发送的; | |

# 10.消费者压力测试kafka-consumer-perf-test.sh

消费100条消息--messages 100
```
sh bin/kafka-consumer-perf-test.sh -topic test_create_topic4 --bootstrap-server localhost:9090 --messages 100
```

相关可选参数

| 参数 | 描述 | 例子 |
|------|-----|-------|
| --bootstrap-server |  |  |
| --consumer.config | 消费者配置文件 |
| --date-format | 结果打印出来的时间格式化 | 默认：yyyy-MM-dd HH:mm:ss:SSS |
| --fetch-size | 单次请求获取数据的大小 | 默认1048576 |
| --topic | 指定消费的topic |  |
| --from-latest |  |
| --group | 消费组ID | |
| --hide-header | 如果设置了,则不打印header信息 | |
| --messages | 需要消费的数量 | |
| --num-fetch-threads | feth 数据的线程数(废弃无效) | 默认：1 |
| --print-metrics | 结束的时候打印监控数据 | |
| --show-detailed-stats | 如果设置，则按照--report_interval配置的方式报告每个报告间隔的统计信息 |  |
| --threads | 消费线程数;(废弃无效) | 默认 10 |
| --reporting-interval | 打印进度信息的时间间隔（以毫秒为单位） |  |

# 11.删除指定分区的消息kafka-delete-records.sh

删除指定topic的某个分区的消息删除至offset为1024

先配置json文件offset-json-file.json
```
{"partitions":
[{"topic": "test1", "partition": 0,
  "offset": 1024}],
  "version":1
}
```

在执行命令
```
sh bin/kafka-delete-records.sh --bootstrap-server 172.23.250.249:9090 --offset-json-file config/offset-json-file.json
```
验证 通过 LogIKM 查看发送的消息

**从这里可以看出来,配置"offset": 1024 的意思是从最开始的地方删除消息到 1024的offset; 是从最前面开始删除的**

# 12. 查看Broker磁盘信息kafka-log-dirs.sh

查询指定topic磁盘信息--topic-list topic1,topic2
```
sh bin/kafka-log-dirs.sh --bootstrap-server xxxx:9090 --describe --topic-list test2
```

查询指定Broker磁盘信息--broker-list 0 broker1,broker2
```
sh bin/kafka-log-dirs.sh --bootstrap-server xxxxx:9090 --describe --topic-list test2 --broker-list 0
```

例如我一个3分区3副本的Topic的查出来的信息logDir Broker中配置的log.dir
```
{
	"version": 1,
	"brokers": [{
		"broker": 0,
		"logDirs": [{
			"logDir": "/Users/xxxx/work/IdeaPj/ss/kafka/kafka-logs-0",
			"error": null,
			"partitions": [{
				"partition": "test2-1",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}, {
				"partition": "test2-0",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}, {
				"partition": "test2-2",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}]
		}]
	}, {
		"broker": 1,
		"logDirs": [{
			"logDir": "/Users/xxxx/work/IdeaPj/ss/kafka/kafka-logs-1",
			"error": null,
			"partitions": [{
				"partition": "test2-1",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}, {
				"partition": "test2-0",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}, {
				"partition": "test2-2",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}]
		}]
	}, {
		"broker": 2,
		"logDirs": [{
			"logDir": "/Users/xxxx/work/IdeaPj/ss/kafka/kafka-logs-2",
			"error": null,
			"partitions": [{
				"partition": "test2-1",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}, {
				"partition": "test2-0",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}, {
				"partition": "test2-2",
				"size": 0,
				"offsetLag": 0,
				"isFuture": false
			}]
		}]
	}, {
		"broker": 3,
		"logDirs": [{
			"logDir": "/Users/xxxx/work/IdeaPj/ss/kafka/kafka-logs-3",
			"error": null,
			"partitions": []
		}]
	}]
}
```

如果你觉得通过命令查询磁盘信息比较麻烦，你也可以通过 LogIKM 查看

# 12. 消费者组管理 kafka-consumer-groups.sh

## 12.1. 查看消费者列表--list
```
sh bin/kafka-consumer-groups.sh --bootstrap-server xxxx:9090 --list
```
- 先调用MetadataRequest拿到所有在线Broker列表
- 再给每个Broker发送ListGroupsRequest请求获取 消费者组数据

## 12.2. 查看消费者组详情--describe

- DescribeGroupsRequest

查看消费组详情`--group`或`--all-groups`

查看指定消费组详情--group
```
sh bin/kafka-consumer-groups.sh --bootstrap-server xxxxx:9090 --describe --group test2_consumer_group
```

查看所有消费组详情--all-groups
```
sh bin/kafka-consumer-groups.sh --bootstrap-server xxxxx:9090 --describe --all-groups
```

查看该消费组 消费的所有Topic、及所在分区、最新消费offset、Log最新数据offset、Lag还未消费数量、消费者ID等等信息


**查询消费者成员信息--members**

所有消费组成员信息
```
sh bin/kafka-consumer-groups.sh --describe --all-groups --members --bootstrap-server xxx:9090
```

指定消费组成员信息
```
sh bin/kafka-consumer-groups.sh --describe --members --group test2_consumer_group --bootstrap-server xxxx:9090
```

**查询消费者状态信息--state**

所有消费组状态信息
```
sh bin/kafka-consumer-groups.sh --describe --all-groups --state --bootstrap-server xxxx:9090
```

指定消费组状态信息
```
sh bin/kafka-consumer-groups.sh --describe --state --group test2_consumer_group --bootstrap-server xxxxx:9090
```

## 12.3. 删除消费者组--delete
- DeleteGroupsRequest

删除消费组–delete

删除指定消费组--group
```
sh bin/kafka-consumer-groups.sh --delete --group test2_consumer_group --bootstrap-server xxxx:9090
```

删除所有消费组--all-groups
```
sh bin/kafka-consumer-groups.sh --delete --all-groups --bootstrap-server xxxx:9090
```

**PS**: 想要删除消费组前提是这个消费组的所有客户端都停止消费/不在线才能够成功删除;否则会报下面异常
```
Error: Deletion of some consumer groups failed:
* Group 'test2_consumer_group' could not be deleted due to: java.util.concurrent.ExecutionException: org.apache.kafka.common.errors.GroupNotEmptyException: The group is not empty.
```

## 12.4. 重置消费组的偏移量 --reset-offsets

能够执行成功的一个前提是 消费组这会是不可用状态;下面的示例使用的参数是:`--dry-run`;这个参数表示预执行,会打印出来将要处理的结果;等你想真正执行的时候请换成参数`--execute`;下面示例 重置模式都是`--to-earliest`重置到最早的;请根据需要参考下面 相关重置`Offset`的模式 换成其他模式;

- 重置指定消费组的偏移量 --group
```
重置指定消费组的所有Topic的偏移量--all-topic
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --group test2_consumer_group --bootstrap-server xxxx:9090 --dry-run --all-topic

重置指定消费组的指定Topic的偏移量--topic
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --group test2_consumer_group --bootstrap-server xxxx:9090 --dry-run --topic test2
```

- 重置所有消费组的偏移量 --all-group
```
重置所有消费组的所有Topic的偏移量--all-topic
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --all-group --bootstrap-server xxxx:9090 --dry-run --all-topic

重置所有消费组中指定Topic的偏移量--topic
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --all-group --bootstrap-server xxxx:9090 --dry-run --topic test2
```

- --reset-offsets 后面需要接**重置的模式**

相关重置Offset的模式

| 参数 | 描述 | 例子 |
|------|-----|------|
| --to-earliest | 重置offset到最开始的那条offset(找到还未被删除最早的那个offset) | |
| --to-current | 直接重置offset到当前的offset，也就是LOE | |
| --to-latest | 重置到最后一个offset | |
| --to-datetime | 重置到指定时间的offset;格式为:YYYY-MM-DDTHH:mm:SS.sss; | --to-datetime "2021-6-26T00:00:00.000" |
| --to-offset | 重置到指定的offset,但是通常情况下,匹配到多个分区,这里是将匹配到的所有分区都重置到这一个值; 如果 1.目标最大offset<--to-offset, 这个时候重置为目标最大offset；2.目标最小offset>--to-offset ，则重置为最小; 3.否则的话才会重置为--to-offset的目标值; 一般不用这个 | --to-offset 3465  |
| --shift-by | 按照偏移量增加或者减少多少个offset；正的为往前增加;负的往后退；当然这里也是匹配所有的; | --shift-by 100 、--shift-by -100 |
| --from-file | 根据CVS文档来重置; 这里下面单独讲解 |  |

- --from-file**着重讲解一下**

上面其他的一些模式重置的都是匹配到的所有分区; 不能够每个分区重置到不同的offset；不过 **--from-file** 可以让我们更灵活一点;

1.先配置cvs文档
格式为: Topic:分区号: 重置目标偏移量
```
test2,0,100
test2,1,200
test2,2,300
```

2.执行命令
```
sh bin/kafka-consumer-groups.sh --reset-offsets --group test2_consumer_group --bootstrap-server xxxx:9090 --dry-run --from-file config/reset-offset.csv
```

## 12.5. 删除偏移量delete-offsets

能够执行成功的一个前提是 消费组这会是不可用状态;

偏移量被删除了之后,Consumer Group下次启动的时候,会从头消费;
```
sh bin/kafka-consumer-groups.sh --delete-offsets --group test2_consumer_group2 --bootstrap-server XXXX:9090 --topic test2
```

相关可选参数

| 参数 | 描述 | 例子 |
| --bootstrap-server | 指定连接到的kafka服务; | –bootstrap-server localhost:9092 |
| --list | 列出所有消费组名称 | --list |
| --describe | 查询消费者描述信息 | --describe |
| --group | 指定消费组 |  |
| --all-groups | 指定所有消费组 |  |
| --members | 查询消费组的成员信息 |  |
| --state | 查询消费者的状态信息 |  |
| --offsets | 在查询消费组描述信息的时候,这个参数会列出消息的偏移量信息; 默认就会有这个参数的; |  |
| --dry-run | 重置偏移量的时候,使用这个参数可以让你预先看到重置情况，这个时候还没有真正的执行,真正执行换成`--excute`;默认为`dry-run` |  |
| --excute | 真正的执行重置偏移量的操作; |  |
| --to-earliest | 将offset重置到最早 |  |
| --to-latest | 将offset重置到最近 |  |

# 13.查看日志文件 kafka-dump-log.sh

| 参数 | 描述 | 例子 |
|-----|------|------|
| --deep-iteration |  |
| --files `<String: file1, file2, ...>` | 必需; 读取的日志文件 | --files 0000009000.log |
| --key-decoder-class | 如果设置，则用于反序列化键。这类应实现kafka.serializer。解码器特性。自定义jar应该是在kafka/libs目录中提供 | |
| --max-message-size | 最大的数据量,默认：5242880 | |
| --offsets-decoder | `if set, log data will be parsed as offset data from the __consumer_offsets topic.` | |
| --print-data-log | 打印内容 | |
| --transaction-log-decoder | `if set, log data will be parsed as transaction metadata from the __transaction_state topic` | |
| --value-decoder-class [String] | if set, used to deserialize the messages. This class should implement kafka. serializer.Decoder trait. Custom jar should be available in kafka/libs directory. (default: kafka.serializer. StringDecoder) | |
| --verify-index-only | if set, just verify the index log without printing its content.	 | |

查询Log文件
```
sh bin/kafka-dump-log.sh --files kafka-logs-0/test2-0/00000000000000000300.log
```

查询Log文件具体信息 --print-data-log
```
sh bin/kafka-dump-log.sh --files kafka-logs-0/test2-0/00000000000000000300.log --print-data-log
```

查询index文件具体信息
```
sh bin/kafka-dump-log.sh --files kafka-logs-0/test2-0/00000000000000000300.index
```
配置项为log.index.size.max.bytes； 来控制创建索引的大小;

查询timeindex文件
```
sh bin/kafka-dump-log.sh --files kafka-logs-0/test2-0/00000000000000000300.timeindex
```

# 附件

- ConfigCommand 的一些可选配置

## Topic相关可选配置

| key | value | 示例 |
|-----|-------|-----|
| cleanup.policy | 清理策略 | |
| compression.type | 压缩类型(通常建议在produce端控制) | |
| delete.retention.ms | 压缩日志的保留时间 | |
| file.delete.delay.ms | topic删除被标记为–delete文件之后延迟多长时间删除正在的Log文件 | 60000 |
| flush.messages | 持久化message限制 |
| flush.ms | 持久化频率 |
| follower.replication.throttled.replicas | flowwer副本限流 格式：分区号:副本follower号,分区号:副本follower号 | 0:1,1:1 |
| index.interval.bytes	 |  |
| leader.replication.throttled.replicas | leader副本限流 格式：分区号:副本Leader号 | 0:0 |
| max.compaction.lag.ms	 |  |
| max.message.bytes | 最大的batch的message大小 |
| message.downconversion.enable | message是否向下兼容 |
| message.format.version | message格式版本 |
| message.timestamp.difference.max.ms |  |
| message.timestamp.type |  |
| min.cleanable.dirty.ratio |  |
| min.compaction.lag.ms |  |
| min.insync.replicas | 最小的ISR |  |
| preallocate |  |
| retention.bytes | 日志保留大小(通常按照时间限制) |  |
| retention.ms | 日志保留时间 |  |
| segment.bytes | segment的大小限制 |  |
| segment.index.bytes |  |
| segment.jitter.ms |  |
| segment.ms | segment的切割时间 |  |
| unclean.leader.election.enable | 是否允许非同步副本选主 |

## Broker相关可选配置

| key | value | 示例 |
|-----|-------|------|
| advertised.listeners |  |
| background.threads |  |
| compression.type |  |
| follower.replication.throttled.rate |  |
| leader.replication.throttled.rate |  |
| listener.security.protocol.map |  |
| listeners |  |
| log.cleaner.backoff.ms |  |
| log.cleaner.dedupe.buffer.size |  |
| log.cleaner.delete.retention.ms |  |
| log.cleaner.io.buffer.load.factor |  |
| log.cleaner.io.buffer.size |  |
| log.cleaner.io.max.bytes.per.second |  |
| log.cleaner.max.compaction.lag.ms |  |
| log.cleaner.min.cleanable.ratio |  |
| log.cleaner.min.compaction.lag.ms |  |
| log.cleaner.threads |  |
| log.cleanup.policy |  |
| log.flush.interval.messages |  |
| log.flush.interval.ms |  |
| log.index.interval.bytes |  |
| log.index.size.max.bytes |  |
| log.message.downconversion.enable |  |
| log.message.timestamp.difference.max.ms |  |
| log.message.timestamp.type |  |
| log.preallocate |  |
| log.retention.bytes |  |
| log.retention.ms |  |
| log.roll.jitter.ms |  |
| log.roll.ms |  |
| log.segment.bytes |  |
| log.segment.delete.delay.ms |  |
| max.connections |  |
| max.connections.per.ip |  |
| max.connections.per.ip.overrides |  |
| message.max.bytes |  |
| metric.reporters |  |
| min.insync.replicas |  |
| num.io.threads |  |
| num.network.threads |  |
| num.recovery.threads.per.data.dir |  |
| num.replica.fetchers |  |
| principal.builder.class |  |
| replica.alter.log.dirs.io.max.bytes.per.second |  |
| sasl.enabled.mechanisms |  |
| sasl.jaas.config |  |
| sasl.kerberos.kinit.cmd |  |
| sasl.kerberos.min.time.before.relogin |  |
| sasl.kerberos.principal.to.local.rules |  |
| sasl.kerberos.service.name |  |
| sasl.kerberos.ticket.renew.jitter |  |
| sasl.kerberos.ticket.renew.window.factor |  |
| sasl.login.refresh.buffer.seconds |  |
| sasl.login.refresh.min.period.seconds |  |
| sasl.login.refresh.window.factor |  |
| sasl.login.refresh.window.jitter |  |
| sasl.mechanism.inter.broker.protocol |  |
| ssl.cipher.suites |  |
| ssl.client.auth |  |
| ssl.enabled.protocols |  |
| ssl.endpoint.identification.algorithm |  |
| ssl.key.password |  |
| ssl.keymanager.algorithm |  |
| ssl.keystore.location |  |
| ssl.keystore.password |  |
| ssl.keystore.type |  |
| ssl.protocol |  |
| ssl.provider |  |
| ssl.secure.random.implementation |  |
| ssl.trustmanager.algorithm |  |
| ssl.truststore.location |  |
| ssl.truststore.password |  |
| ssl.truststore.type |  |
| unclean.leader.election.enable |  |

Users相关可选配置

| key | value | 示例 |
|-----|-------|------|
| SCRAM-SHA-256 |  |
| SCRAM-SHA-512 |  |
| consumer_byte_rate | 针对消费者user进行限流 |
| producer_byte_rate | 针对生产者进行限流 |
| request_percentage | 请求百分比 |

## clients相关可选配置

| key | value | 示例 |
|-----|-------|------|
| consumer_byte_rate |  |
| producer_byte_rate |  |
| request_percentage |  |

以上大部分运维操作,都可以使用 LogI-Kafka-Manager 在平台上可视化操作;
