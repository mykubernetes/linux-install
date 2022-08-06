# 一、Kafka常用命令之kafka-topics.sh

kafka-topics.sh 脚本主要负责 topic 相关的操作。它的具体实现是通过 kafka-run-class 来调用 TopicCommand 类，并根据参数执行指定的功能。

| 属性名 | 值类型 | 默认值 | 有效值 | 服务器默认属性 | 描述 |
|--------|-------|--------|--------|----------------|------|
| cleanup.policy | list | delete | delete、compact | log.cleanup.policy | 过期或达到上限日志的清理策略。delete：删除，compact：压缩 |
| compression.type | string | producer | uncompressed、snappy、lz4、gzip、producer | compression.type | 指定给该topic最终的压缩类型 |
| delete.retention.ms | long | 86400000 | [0,…] | log.cleaner.delete.retention.ms | 压缩的日志保留的最长时间，也是客户端消费消息的最长时间。与 log.retention.minutes 的区别在于：一个控制未压缩的数据，一个控制压缩后的数据。 |
| file.delete.delay.ms | long | 60000 | [0,…] | log.segment.delete.delay.ms | 从文件系统中删除前所等待的时间 |
| flush.messages | long | 9223372036854775807 | [0,…] | log.flush.interval.messages | 在消息刷到磁盘之前，日志分区收集的消息数 |
| flush.ms | long | 9223372036854775807 | [0,…] | log.flush.interval.ms | 消息在刷到磁盘之前，保存在内存中的最长时间，单位是ms |
| index.interval.bytes | int | 4096 | [0,…] | log.index.interval.bytes | 执行 fetch 操作后，扫描最近的 offset 运行空间的大小。设置越大，代表扫描速度越快，但是也更耗内存。（一般情况下不需要设置此参数） |
| message.max.bytes | int | 1000012 | [0,…] | message.max.bytes | log中能够容纳消息的最大字节数 |
| min.cleanable.dirty.ratio | double | 0.5 | [0,…,1] | log.cleaner.min.cleanable.ratio | 日志清理的频率控制，占该log的百分比。越大意味着更高效的清理，同时会存在空间浪费问题 |
| retention.bytes | long | -1 | | log.retention.bytes | topic每个分区的最大文件大小。一个 topic 的大小限制 = 分区数 * log.retention.bytes。-1 表示没有大小限制。 |
| retention.ms | int | 604800000 | [-1,…] | log.retention.minutes | 日志文件保留的分钟数。数据存储的最大时间超过这个时间会根据 log.cleanup.policy 设置的策略处理数据 |
| segment.bytes | int | 1073741824 | [14,…] | log.segment.bytes | 每个 segment 的大小 (默认为1G) |
| segment.index.bytes | int | 10485760 | [0,…] | log.index.size.max.bytes | 对于segment日志的索引文件大小限制(默认为10M) |

## 1、创建 Topic

TopicCommand.createTopic() 方法负责创建 Topic，其核心逻辑是确定新建 Topic 中有多少个分区及每个分区中的副本如何分配，既支持使用 replica-assignment 参数手动分配，也支持使用 partitions 参数和 replication-factor 参数指定分区个数和副本个数进行自动分配。之后该方法会将副本分配结果写入到 ZooKeeper 中。

- 形式一

使用`replica-assignment`参数手动指定 Topic Partition Replica 与 Kafka Broker 之间的存储映射关系。
```
bin/kafka-topics.sh --create --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName --replica-assignment 0:1,1:2,2:0
```
注意：0:1,1:2,2:0 中的数字均为 broker.id；3个分区(逗号分隔)；每个分区有两个副本(副本所在的 broker 以冒号分割)。

> 此形式在最新的 2.3 版本中会报 Aborted due to timeout 异常，建议使用形式二。

- 形式二

使用`partitions`和`replication-factor`参数自动分配存储映射关系。
```
bin/kafka-topics.sh --create --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName --partitions 3 --replication-factor 2
```
表示：创建一个 名为 topicName 的 Topic。其中指定分区个数为3，副本个数为2。

> 注意：Topic 名称中一定不要同时出现下划线 (’_’) 和小数点 (’.’)。WARNING: Due to limitations in metric names, topics with a period (’.’) or underscore(’_’) could collide. To avoid issues ot os best to use either, but not both.

- 创建 Topic 时也可指定参数：
```
bin/kafka-topics.sh --create --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName --partitions 3 --replication-factor 2 --config cleanup.policy=compact --config retention.ms=500
```

创建topic过程的问题，replication-factor个数不能超过 broker 的个数，否则有如下错误信息：
```
ERROR org.apache.kafka.common.errors.InvalidReplicationFactorException: Replication factor: 3 larger than available brokers: 1.
```

## 2、查看 Topic

- 查看 Topic 列表
```
bin/kafka-topics.sh --list --bootstrap-server node1:9092,node2:9092,node3:9092
```
查询出来的结果仅有 Topic 的名称信息。

- 查看指定 Topic 明细
```
bin/kafka-topics.sh --describe --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName
Topic: topicName PartitionCount:3 ReplicationFactor:2 Configs:
Topic: topicName Partition: 0 Leader: 0 Replicas: 0,1 Isr: 0,1
Topic: topicName Partition: 1 Leader: 1 Replicas: 1,2 Isr: 1,2
Topic: topicName Partition: 2 Leader: 2 Replicas: 2,0 Isr: 2,0
```
- **PartitionCount**：partition 个数。
- **ReplicationFactor**：副本个数。
- **Partition**：partition 编号，从 0 开始递增。
- **Leader**：当前 partition 起作用的 breaker.id。
- **Replicas**: 当前副本数据所在的 breaker.id，是一个列表，排在最前面的其作用。
- **Isr**：当前 kakfa 集群中可用的 breaker.id 列表。

## 3、删除 Topic

```
bin/kafka-topics.sh --delete --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName
```
- 若 delete.topic.enable=true
  - 直接彻底删除该 Topic。
- 若 delete.topic.enable=false
  - 如果当前 Topic 没有使用过即没有传输过信息：可以彻底删除。
  - 如果当前 Topic 有使用过即有过传输过信息：并没有真正删除 Topic 只是把这个 Topic 标记为删除(marked for deletion)，重启 Kafka Server 后删除。

**注**：delete.topic.enable=true 配置信息位于配置文件 config/server.properties 中(较新的版本中无显式配置，默认为 true)。

## 4、修改 Topic

- 增加分区数
```
bin/kafka-topics.sh --alter --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName --partitions 3
```

修改分区数时，仅能增加分区个数。若是用其减少 partition 个数，则会报如下错误信息：
```
org.apache.kafka.common.errors.InvalidPartitionsException: The number of partitions for a topic can only be increased. Topic hadoop currently has 3 partitions, 2 would not be an increase.
```
不能用来修改副本个数。(请使用 kafka-reassign-partitions.sh 脚本增加副本数)

- 增加配置
```
bin/kafka-topics.sh --alter --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName --config flush.messages=1
```

- 删除配置
```
bin/kafka-topics.sh --alter --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName --delete-config flush.messages
```



# 二、Kafka常用命令之kafka-console-producer.sh

kafka-console-producer.sh 脚本通过调用 kafka.tools.ConsoleProducer 类加载命令行参数的方式，在控制台生产消息的脚本。

| 参数 | 值类型 | 说明 | 有效值 |
|------|--------|------|--------|
| --bootstrap-server | String | 要连接的服务器,必需(除非指定--broker-list) | 形如：host1:prot1,host2:prot2 |
| --topic | String | (必需)接收消息的主题名称 | |
| --broker-list | String | 已过时要连接的服务器 | 形如：host1:prot1,host2:prot2 |
| --batch-size | Integer | 单个批处理中发送的消息数| 200(默认值) |
| --compression-codec | String | 压缩编解码器 | none、gzip(默认值)、snappy、lz4、zstd |
| --max-block-ms | Long | 在发送请求期间，生产者将阻止的最长时间 | 60000(默认值) |
| --max-memory-bytes | Long | 生产者用来缓冲等待发送到服务器的总内存 | 33554432(默认值) |
| --max-partition-memory-bytes | Long | 为分区分配的缓冲区大小 | 16384 |
| --message-send-max-retries | Integer | 最大的重试发送次数 | 3 |
| --metadata-expiry-ms | Long | 强制更新元数据的时间阈值(ms) | 300000 |
| --producer-property | String | 将自定义属性传递给生成器的机制 | 形如：key=value |
| --producer.config | String | 生产者配置属性文件[--producer-property]优先于此配置 | 配置文件完整路径 |
| --property | String | 自定义消息读取器 | parse.key=true false,key.separator=`<key.separator>`,ignore.error=true false |
| --request-required-acks | String | 生产者请求的确认方式 | 0、1(默认值)、all |
| --request-timeout-ms | Integer | 生产者请求的确认超时时间 | 1500(默认值) |
| --retry-backoff-ms | Integer | 生产者重试前，刷新元数据的等待时间阈值 | 100(默认值) |
| --socket-buffer-size | Integer | TCP接收缓冲大小 | 102400(默认值) |
| --timeout | Integer | 消息排队异步等待处理的时间阈值 | 1000(默认值) |
| --sync | | 同步发送消息 | |
| --version | | 显示 Kafka 版本,不配合其他参数时，显示为本地Kafka版本 | |
| --help | | 打印帮助信息 | |

## 1、无key型消息

默认情况下，所生产的消息是没有 key 的，命令如下：
```
bin/kafka-console-producer.sh --bootstrap-server localhsot:9092 --topic topicName
```

执行上述命令后，就会在控制台等待键入消息体，直接输入消息值(value)即可，每行（以换行符分隔）表示一条消息，如下所示。
```
>Hello Kafka!
>你好 kafka!
```
正常情况，每次回车表示触发“发送”操作，回车后可直接使用“Ctrl + c”退出生产者控制台，再使用 kafka-console-consumer.sh 脚本验证本次的生产情况。

## 2、有key型消息

当需要为消息指定 key 时，可使用如下命令：
```
bin/kafka-console-producer.sh --bootstrap-server localhsot:9092 --topic topicName --property parse.key=true
```

默认消息键与消息值间使用“Tab键”进行分隔，切勿使用转义字符(\t)，如下所示：
```
>Lei Li    Hello Kafka!
>Meimei Han    你好 kafka!
```
键入如上信息表示所生产的消息“Lei Li”为消息键，“Hello Kafka”为消息值。



# 三、Kafka常用命令之kafka-console-consumer.sh

kafka-console-consumer.sh 脚本是一个简易的消费者控制台。该 shell 脚本的功能通过调用 kafka.tools 包下的 ConsoleConsumer 类，并将提供的命令行参数全部传给该类实现。

| 参数 | 值类型 | 说明 | 有效值 |
|------|--------|------|--------|
| --topic | string |被消费的topic | |
| --whitelist | string |正则表达式，指定要包含以供使用的主题的白名单 | |
| --partition | integer |指定分区除非指定’–offset’，否则从分区结束(latest)开始消费 | |
| --offset | string | 执行消费的起始offset位置，默认值:latest | latest、earliest、`<offset>` |
| --consumer-property | string | 将用户定义的属性以key=value的形式传递给使用者 | |	
| --consumer.config | string | 消费者配置属性文件请注意，[consumer-property]优先于此配置 | |
| --formatter | string | 用于格式化kafka消息以供显示的类的名称,默认值:kafka.tools.DefaultMessageFormatter | kafka.tools.DefaultMessageFormatter kafka.tools.LoggingMessageFormatter kafka.tools.NoOpMessageFormatter kafka.tools.ChecksumMessageFormatter |
| --property | string | 初始化消息格式化程序的属性 | print.timestamp=true false，print.key=true false、print.value=true false、key.separator=`<key.separator>`、line.separator=`<line.separator>`、key.deserializer=`<key.deserializer>`、value.deserializer=`<value.deserializer>` |
| --from-beginning | | 从存在的最早消息开始，而不是从最新消息开始 |
| --max-messages | integer | 消费的最大数据量，若不指定，则持续消费下去 | |
| --timeout-ms | integer | 在指定时间间隔内没有消息可用时退出 | |
| --skip-message-on-error | | 如果处理消息时出错，请跳过它而不是暂停	
| --bootstrap-server | string | 必需(除非使用旧版本的消费者)，要连接的服务器 | |
| --key-deserializer | string | | |
| --value-deserializer | string | | |
| --enable-systest-events | | 除记录消费的消息外，还记录消费者的生命周期(用于系统测试) | |
| --isolation-level | string | 设置为read_committed以过滤掉未提交的事务性消息,设置为read_uncommitted以读取所有消息,默认值:read_uncommitted | |
| --group | string | 指定消费者所属组的ID | |
| --blacklist | string | 要从消费中排除的主题黑名单 | |
| --csv-reporter-enabled | | 如果设置，将启用csv metrics报告器 | |
| --delete-consumer-offsets | | 如果指定，则启动时删除zookeeper中的消费者信息 | |
| --metrics-dir | string | 输出csv度量值,需与[csv-reporter-enable]配合使用 | |
| --zookeeper | string | 必需(仅当使用旧的使用者时)连接zookeeper的字符串。可以给出多个URL以允许故障转移 | |

- 消息消费
```
bin/kafka-console-consumer.sh --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName
```
表示从 latest 位移位置开始消费该主题的所有分区消息，即仅消费正在写入的消息。

从开始位置消费
```
bin/kafka-console-consumer.sh --bootstrap-server node1:9092,node2:9092,node3:9092 --from-beginning --topic topicName
```
表示从指定主题中有效的起始位移位置开始消费所有分区的消息。

显示key消费
```
bin/kafka-console-consumer.sh --bootstrap-server node1:9092,node2:9092,node3:9092 --property print.key=true --topic topicName
```
 消费出的消息结果将打印出消息体的 key 和 value。


  
  
  
  
  
  
  
  
  
  
