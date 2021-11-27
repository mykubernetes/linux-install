# 关于Kafka的日志

日志的英语是“log”，但Kafka的数据文件也被称为log，所以很多时候会造成一定的歧义。在Kafka中，日志分为两种：
- 数据日志
- 操作日志

数据日志是指Kafka的topic中存储的数据，这种日志的路径是在`$KAFKA_HOME/config/server.properties`文件中配置，配置项为log.dirs。如果此项没有被配置，默认会使用配置项 log.dir（请仔细观察，两个配置项最后差了一个s）。log.dir的默认路径为/tmp/kafka-logs，大家知道，/tmp路径下的文件在计算机重启的时候是会被删除的，因此，强烈推荐将文件目录设置在其他可以永久保存的路径。另一种日志是操作日志，类似于我们在自己开发的程序中输出的log日志（log4j），这种日志的路径是在启动Kafka的路径下。比如一般我们在KAFKA_HOME路径下启动Kafka服务，那么操作日志的路径为KAFKA_HOME/logs。

# 数据日志清理

数据日志有两种类型的清理方式，一种是按照日志被发布的时间来删除，另一种是按照日志文件的size来删除。有专门的配置项可以配置这个删除策略：

# 按时间删除：

Kafka提供了配置项让我们可以按照日志被发布的时间来删除。它们分别是：
- log.retention.ms
- log.retention.minutes
- log.retention.hours

根据配置项的名称很容易理解它们的含义。log.retention.ms表示日志会被保留多少毫秒，如果为null，则Kafka会使用使用log.retention.minutes配置项。log.retention.minutes表示日志会保留多少分钟，如果为null，则Kafka会使用log.retention.hours选项。默认情况下，log.retention.ms和log.retention.minutes均为null，log.retention.hours为168，即Kafka的数据日志默认会被保留7天。如果想修改Kafka中数据日志被保留的时间长度，可以通过修改这三个选项来实现。

# 按size删除

Kafka除了提供了按时间删除的配置项外，也提供了按照日志文件的size来删除的配置项：
- log.retention.bytes

即日志文件到达多少byte后再删除日志文件。默认为-1，即无限制。需要注意的是，这个选项的值如果小于segment文件大小的话是不起作用的。segment文件的大小取决于log.segment.bytes配置项，默认为1G。 另外，Kafka的日志删除策略并不是非常严格的（比如如果log.retention.bytes设置了10G的话，并不是超过10G的部分就会立刻删除，只是被标记为待删除，Kafka会在恰当的时候再真正删除），所以请预留足够的磁盘空间。当磁盘空间剩余量为0时，Kafka服务会被kill掉。

# 操作日志清理

目前Kafka的操作日志暂时不提供自动清理的机制，需要运维人员手动干预，比如使用shell和crontab命令进行定时备份、清理等。

链接：https://www.jianshu.com/p/d4c19fed4742

# 实际操作

查看某个topic的保留时长：
```
./kafka-topics.sh --bootstrap-server 10.3.1.173:9092 --describe --topic diamond-ds-207-binlog-sale-repl
Topic:diamond-ds-207-binlog-sale-repl	PartitionCount:8	ReplicationFactor:2	Configs:compression.type=snappy,flush.ms=10000,segment.bytes=1073741824,retention.ms=1296000000,flush.messages=20000,max.message.bytes=30000000,index.interval.bytes=4096,segment.index.bytes=10485760
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 0	Leader: 25	Replicas: 25,24	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 1	Leader: 24	Replicas: 24,25	Isr: 25,24
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 2	Leader: 25	Replicas: 25,24	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 3	Leader: 24	Replicas: 24,25	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 4	Leader: 25	Replicas: 25,24	Isr: 25,24
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 5	Leader: 24	Replicas: 24,25	Isr: 25,24
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 6	Leader: 25	Replicas: 25,24	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 7	Leader: 24	Replicas: 24,25	Isr: 24,25
```
- 其中的 retention.ms=1296000000换算一下就是15天。

其他参数讲解：
- Topic：对应topic名字
- PartitionCount：分区数
- ReplicationFactor：副本数
- compression.type：压缩类型，压缩的速度上lz4=snappy<gzip。还可以设置'uncompressed',就是不压缩；设置为'producer'这意味着保留生产者设置的原始压缩编解码。
- flush.ms：此设置允许我们强制fsync写入日志的数据的时间间隔。例如，如果这设置为1000，那么在1000ms过去之后，我们将fsync。 一般，我们建议不要设置它，并使用复制来保持持久性，并允许操作系统的后台刷新功能，因为它更有效率
- segment.bytes：此配置控制日志的段文件大小。一次保留和清理一个文件，因此较大的段大小意味着较少的文件，但对保留率的粒度控制较少。
- retention.ms：如果我们使用“删除”保留策略，则此配置控制我们将保留日志的最长时间，然后我们将丢弃旧的日志段以释放空间。这代表SLA消费者必须读取数据的时间长度。
- flush.messages：此设置允许指定我们强制fsync写入日志的数据的间隔。例如，如果这被设置为1，我们将在每个消息之后fsync; 如果是5，我们将在每五个消息之后fsync。一般，我们建议不要设置它，使用复制特性来保持持久性，并允许操作系统的后台刷新功能更高效。可以在每个topic的基础上覆盖此设置。
- max.message.bytes：kafka允许的最大的消息批次大小。如果增加此值，并且消费者的版本比0.10.2老，那么消费者的提取的大小也必须增加，以便他们可以获取大的消息批次。 在最新的消息格式版本中，消息总是分组批量来提高效率。在之前的消息格式版本中，未压缩的记录不会分组批量，并且此限制仅适用于该情况下的单个消息。
- index.interval.bytes：此设置控制Kafka向其offset索引添加索引条目的频率。默认设置确保我们大致每4096个字节索引消息。 更多的索引允许读取更接近日志中的确切位置，但使索引更大。你不需要改变这个值。
- segment.index.bytes：此配置控制offset映射到文件位置的索引的大小。我们预先分配此索引文件，并在日志滚动后收缩它。通常不需要更改此设置。

上边是生产的环境，下边到一个测试环境来进行一波操作。

最开始的初始情况如下：
```
$./kafka-topics.sh  --zookeeper localhost:2181 --describe --topic liql-test1
Topic:liql-test1	PartitionCount:5	ReplicationFactor:1	Configs:
	Topic: liql-test1	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 1	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 2	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 3	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 4	Leader: 0	Replicas: 0	Isr: 0
```

同时也可以用如下命令查看是否又进行过单独配置：
```
./kafka-configs.sh --describe --zookeeper localhost:2181 --entity-type topics  --entity-name liql-test1
Configs for topic 'liql-test1' are
```
- 返回如上信息说明此topic使用的是默认配置，并没有进行任何配置。

现在来配置一下这个topic保留时长，现在不能使用 ./kafka-topics.sh命令来调整了，否则会报错如下：
```
$./kafka-topics.sh  --zookeeper localhost:2181  --topic liql-test1 --alert --config retention.ms=2678400000
Exception in thread "main" joptsimple.UnrecognizedOptionException: alert is not a recognized option
	at joptsimple.OptionException.unrecognizedOption(OptionException.java:108)
	at joptsimple.OptionParser.handleLongOptionToken(OptionParser.java:510)
	at joptsimple.OptionParserState$2.handleArgument(OptionParserState.java:56)
	at joptsimple.OptionParser.parse(OptionParser.java:396)
	at kafka.admin.TopicCommand$TopicCommandOptions.<init>(TopicCommand.scala:358)
	at kafka.admin.TopicCommand$.main(TopicCommand.scala:44)
	at kafka.admin.TopicCommand.main(TopicCommand.scala)
```

而应该使用如下命令：
```
$./kafka-configs.sh --zookeeper localhost:2181 --alter --entity-name liql-test1 --entity-type topics --add-config retention.ms=1296000000
Completed Updating config for entity: topic 'liql-test1'.
```

再查看一下相关信息：
```
$./kafka-topics.sh  --zookeeper localhost:2181 --describe --topic liql-test1
Topic:liql-test1	PartitionCount:5	ReplicationFactor:1	Configs:retention.ms=1296000000
	Topic: liql-test1	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 1	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 2	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 3	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 4	Leader: 0	Replicas: 0	Isr: 0
```

如果需要调整，则可以进行如下操作：
```
$./kafka-configs.sh --zookeeper localhost:2181 --alter --entity-name liql-test1 --entity-type topics --add-config retention.ms=432000000
Completed Updating config for entity: topic 'liql-test1'.
```

然后就把保留时间更改为5天了：
```
$./kafka-topics.sh  --zookeeper localhost:2181 --describe --topic liql-test1
Topic:liql-test1	PartitionCount:5	ReplicationFactor:1	Configs:retention.ms=432000000
	Topic: liql-test1	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 1	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 2	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 3	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 4	Leader: 0	Replicas: 0	Isr: 0
```
