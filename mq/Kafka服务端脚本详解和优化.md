Kafka 已经给我们提供了非常丰富的脚本，用来对Kafka进行管理和优化，该文是对Kafka服务端脚本的详解和测试，并尝试通过参数调整来调优Kafka性能
 
# Kafka服务端脚本详解(1)-topics

## kafka-topics.sh

- --partitions: 创建或修改主题的分区数
- --replication-factor: 副本因子，副本数量
- --replica-assignment: 手动指定分区副本分配方案，使用该参数，不用指定--partitions 和 --replication-factor
- --topic: 主题名称
- --zookeeper: 连接kafka zk地址
- --alter: 修改分区，副本，配置
- --bootstrap-server: kafka服务器地址
- --create: 创建主题
- --delete: 删除主题

- --list: 列出所有的可用主题
```
 [root@10 kafka_2]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --list
 __consumer_offsets
 first
 test
 topic-3
 topic-4
 topic-5
 topic-6
 topic-admin
 topic-create-diff
 topic-two
```

- --describe: 列出主题的详细信息
- --exclude-internal: 使用--list --describe 命令时是否列出内部主题，默认列出内部主题

- --command-config: 以配置文件的形式修改Admin Client的配置,支持的配置见org.apache.kafka.clients.admin.AdminClientConfig
```
//me.properties
request.timeout.ms=200000

//
bin/kafka-topics.sh --bootstrap-server  10.211.55.3:9092 --topic topic-two --list  --command-config config/me.properties 
```

- --config: 在创建/修改主题的时候可以对主题默认参数进行覆盖，具体支持的参数见`http://kafka.apachecn.org/documentation.html#topicconfigs`，该参数将在以后废弃，请使用kafka-configs.sh
```
 [root@10 kafka_2.11-2.2.0]# bin/kafka-topics.sh --bootstrap-server  10.211.55.3:9092 --topic topic-two --describe
Topic:topic-two PartitionCount:1        ReplicationFactor:1     Configs:segment.bytes=1073741824,retention.bytes=1073741824
Topic: topic-two        Partition: 0    Leader: 0       Replicas: 0     Isr: 0

 [root@10 kafka_2.11-2.2.0]# bin/kafka-topics.sh --zookeeper  10.211.55.3:2181 --alter --topic topic-two --config segment.bytes=1048577
 WARNING: Altering topic configuration from this script has been deprecated and may be removed in future releases.
         Going forward, please use kafka-configs.sh for this functionality
 Updated config for topic topic-two.
 
[root@10 kafka_2.11-2.2.0]# bin/kafka-topics.sh --zookeeper  10.211.55.3:2181 --describe --topic topic-two
Topic:topic-two PartitionCount:1        ReplicationFactor:1     Configs:segment.bytes=1048577
Topic: topic-two        Partition: 0    Leader: 0       Replicas: 0     Isr: 0
```

- --delete-config: 删除一个配置项
```
[root@10 kafka_2.11-2.2.0]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --topic topic-two --alter --delete-config segment.bytes 
WARNING: Altering topic configuration from this script has been deprecated and may be removed in future releases.
         Going forward, please use kafka-configs.sh for this functionality
Updated config for topic topic-two.

[root@10 kafka_2.11-2.2.0]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --topic topic-two --describe
Topic:topic-two PartitionCount:1        ReplicationFactor:1     Configs:
        Topic: topic-two        Partition: 0    Leader: 0       Replicas: 0     Isr: 0
```

- --disable-rack-aware: 忽略机架信息

有两个broker,一个配了机架信息，另一个没配，在创建topic的时候就会报错
```
[root@10 kafka_2.11-2.2.0]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --create --topic topic-6 --replication-factor 1  --partitions 2
Error while executing topic command : Not all brokers have rack information. Add --disable-rack-aware in command line to make replica assignment without rack information.
[2018-12-27 05:22:40,834] ERROR kafka.admin.AdminOperationException: Not all brokers have rack information. Add --disable-rack-aware in command line to make replica assignment without rack information.
        at kafka.zk.AdminZkClient.getBrokerMetadatas(AdminZkClient.scala:71)
        at kafka.zk.AdminZkClient.createTopic(AdminZkClient.scala:54)
        at kafka.admin.TopicCommand$ZookeeperTopicService.createTopic(TopicCommand.scala:274)
        at kafka.admin.TopicCommand$TopicService$class.createTopic(TopicCommand.scala:134)
        at kafka.admin.TopicCommand$ZookeeperTopicService.createTopic(TopicCommand.scala:266)
        at kafka.admin.TopicCommand$.main(TopicCommand.scala:60)
        at kafka.admin.TopicCommand.main(TopicCommand.scala)
 (kafka.admin.TopicCommand$)

[root@10 kafka_2.11-2.2.0]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --create --topic topic-6 --replication-factor 1  --partitions 2 --disable-rack-aware
Created topic topic-6.
```

- --if-exists: 只有当主题存在时，相关命令才会执行，不会显示错误
```
[root@10 kafka_2]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --topic topic-7  --alter --config segment.bytes=104857 --if-exists

[root@10 kafka_2]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --topic topic-7  --alter --config segment.bytes=104857
Error while executing topic command : Topics in [] does not exist
[2018-12-27 06:01:25,638] ERROR java.lang.IllegalArgumentException: Topics in [] does not exist
        at kafka.admin.TopicCommand$.kafka$admin$TopicCommand$$ensureTopicExists(TopicCommand.scala:416)
        at kafka.admin.TopicCommand$ZookeeperTopicService.alterTopic(TopicCommand.scala:294)
        at kafka.admin.TopicCommand$.main(TopicCommand.scala:62)
        at kafka.admin.TopicCommand.main(TopicCommand.scala)
 (kafka.admin.TopicCommand$)
```

- --if-not-exists: 创建主题的时候，只有当主题不存在时，命令才执行，存在时不会报错
```
[root@10 kafka_2]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --topic topic-6  --create --partitions 1 --replication-factor 1 --if-not-exists

[root@10 kafka_2]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --topic topic-6  --create --partitions 1 --replication-factor 1 
Error while executing topic command : Topic 'topic-6' already exists.
[2018-12-27 06:07:54,185] ERROR org.apache.kafka.common.errors.TopicExistsException: Topic 'topic-6' already exists.
 (kafka.admin.TopicCommand$)
```

- --topics-with-overrides: 显示覆盖过配置的主题

- --unavailable-partitions: 查看没有leader副本的分区
```
[root@10 kafka_2]# bin/kafka-topics.sh --zookeeper 10.211.55.3:2181 --topic topic-6  --describe --unavailable-partitions
        Topic: topic-6  Partition: 0    Leader: -1      Replicas: 1     Isr: 1
```

- --under-replicated-partitions: 查看所有包含失效副本的分区

## connect-distributed.sh & connect-standalone.sh

- Kafka Connect 是一款可扩展并且可靠的在 Apache Kafka 和其他系统之间进行数据传输的工具。
```
bin/connect-standalone.sh config/connect-standalone.properties  config/connect-file-source.properties
bin/connect-distributed.sh config/connect-distributed.properties
```

# Kafka服务端脚本详解(2)一log,verifiable

| 脚本名称 | 脚本用途 |
|---------|----------|
| kafka-log-dirs.sh | 查看指定broker上日志目录使用情况 |
| kafka-verifiable-consumer.sh | 检验kafka消费者 |
| kafka-verifiable-producer.sh | 检验kafka生产者 |

## kafka-log-dirs.sh

- --bootstrap-server: kafka地址
- --broker-list: 要查询的broker地址列表，broker之间逗号隔开，不配置该命令则查询所有broker
- --topic-list: 指定查询的topic列表，逗号隔开
- --command-config: 配置Admin Client

- --describe: 显示详情
```
[root@10 kafka_2.11-2.2.0]# bin/kafka-log-dirs.sh --bootstrap-server 10.211.55.3:9092 --describe --broker-list 0 --topic-list first,topic-3
Querying brokers for log directories information
Received log directory information from brokers 0
{"version":1,"brokers":[{"broker":0,"logDirs":[{"logDir":"/tmp/kafka-logs","error":null,"partitions":[{"partition":"topic-3-0","size":474,"offsetLag":0,"isFuture":false},{"partition":"first-0","size":310,"offsetLag":0,"isFuture":false}]}]}]}
```

## kafka-verifiable-consumer.sh

- --broker-list: broker列表，HOST1:PORT1,HOST2:PORT2,…
- --topic: 要消费的topic
- --group-id: 消费组id

- --max-messages: 最大消费消息数量，默认-1，一直消费
```
#设置消费两次后，自动停止
[root@10 kafka_2.11-2.2.0]# bin/kafka-verifiable-consumer.sh --broker-list 10.211.55.3:9092 --topic first --group-id group.demo --max-messages 2
{"timestamp":1558869583036,"name":"startup_complete"}
{"timestamp":1558869583329,"name":"partitions_revoked","partitions":[]}
{"timestamp":1558869583366,"name":"partitions_assigned","partitions":[{"topic":"first","partition":0}]}
{"timestamp":1558869590352,"name":"records_consumed","count":1,"partitions":[{"topic":"first","partition":0,"count":1,"minOffset":37,"maxOffset":37}]}
{"timestamp":1558869590366,"name":"offsets_committed","offsets":[{"topic":"first","partition":0,"offset":38}],"success":true}
{"timestamp":1558869595328,"name":"records_consumed","count":1,"partitions":[{"topic":"first","partition":0,"count":1,"minOffset":38,"maxOffset":38}]}
{"timestamp":1558869595335,"name":"offsets_committed","offsets":[{"topic":"first","partition":0,"offset":39}],"success":true}
{"timestamp":1558869595355,"name":"shutdown_complete"}
```

- --session-timeout: 消费者会话超时时间，默认30000ms，服务端如果在该时间内没有接收到消费者的心跳，就会将该消费者从消费组中删除

- --enable-autocommit: 自动提交，默认false
```
#比较一下两者的差别
#没有--enable-autocommit
[root@10 kafka_2.11-2.2.0]# bin/kafka-verifiable-consumer.sh --broker-list 10.211.55.3:9092 --topic first --group-id group.demo
{"timestamp":1558875063613,"name":"startup_complete"}
{"timestamp":1558875063922,"name":"partitions_revoked","partitions":[]}
{"timestamp":1558875063952,"name":"partitions_assigned","partitions":[{"topic":"first","partition":0}]}
{"timestamp":1558875069603,"name":"records_consumed","count":1,"partitions":[{"topic":"first","partition":0,"count":1,"minOffset":47,"maxOffset":47}]}
{"timestamp":1558875069614,"name":"offsets_committed","offsets":[{"topic":"first","partition":0,"offset":48}],"success":true}

#有--enable-autocommit
[root@10 kafka_2.11-2.2.0]# bin/kafka-verifiable-consumer.sh --broker-list 10.211.55.3:9092 --topic first --group-id group.demo --enable-autocommit
{"timestamp":1558874772119,"name":"startup_complete"}
{"timestamp":1558874772408,"name":"partitions_revoked","partitions":[]}
{"timestamp":1558874772449,"name":"partitions_assigned","partitions":[{"topic":"first","partition":0}]}
{"timestamp":1558874820898,"name":"records_consumed","count":1,"partitions":[{"topic":"first","partition":0,"count":1,"minOffset":46,"maxOffset":46}]}
```

- --reset-policy: 设置消费偏移量，earliest从头开始消费，latest从最近的开始消费，none抛出异常，默认earliest
- --assignment-strategy: 消费者的分区配置策略, 默认 RangeAssignor
- --consumer.config: 配置文件

## kafka-verifiable-producer.sh

- 该脚本可以生产测试数据发送到指定topic,并将数据已json格式打印到控制台

- --topic: 主题名称
- --broker-list: broker列表， HOST1:PORT1,HOST2:PORT2,…
- --max-messages: 最大消息数量，默认-1，一直生产消息
- --throughput: 设置吞吐量，默认-1
- --acks: 指定分区中必须有多少个副本收到这条消息，才算消息发送成功，默认-1
- --producer.config: 配置文件
- --message-create-time: 设置消息创建的时间，时间戳
- --value-prefix: 设置消息前缀

- --repeating-keys: key从0开始，每次递增1，直到指定的值，然后再从0开始
```
[root@10 kafka_2.11-2.2.0]# bin/kafka-verifiable-producer.sh --broker-list 10.211.55.3:9092 --topic first --message-create-time 1527351382000 --value-prefix 1 --repeating-keys 10 --max-messages 20
{"timestamp":1558877565069,"name":"startup_complete"}
{"timestamp":1558877565231,"name":"producer_send_success","key":"0","value":"1.0","topic":"first","partition":0,"offset":1541118}
{"timestamp":1558877565238,"name":"producer_send_success","key":"1","value":"1.1","topic":"first","partition":0,"offset":1541119}
{"timestamp":1558877565238,"name":"producer_send_success","key":"2","value":"1.2","topic":"first","partition":0,"offset":1541120}
{"timestamp":1558877565238,"name":"producer_send_success","key":"3","value":"1.3","topic":"first","partition":0,"offset":1541121}
{"timestamp":1558877565238,"name":"producer_send_success","key":"4","value":"1.4","topic":"first","partition":0,"offset":1541122}
{"timestamp":1558877565239,"name":"producer_send_success","key":"5","value":"1.5","topic":"first","partition":0,"offset":1541123}
{"timestamp":1558877565239,"name":"producer_send_success","key":"6","value":"1.6","topic":"first","partition":0,"offset":1541124}
{"timestamp":1558877565239,"name":"producer_send_success","key":"7","value":"1.7","topic":"first","partition":0,"offset":1541125}
{"timestamp":1558877565239,"name":"producer_send_success","key":"8","value":"1.8","topic":"first","partition":0,"offset":1541126}
{"timestamp":1558877565239,"name":"producer_send_success","key":"9","value":"1.9","topic":"first","partition":0,"offset":1541127}
{"timestamp":1558877565239,"name":"producer_send_success","key":"0","value":"1.10","topic":"first","partition":0,"offset":1541128}
{"timestamp":1558877565239,"name":"producer_send_success","key":"1","value":"1.11","topic":"first","partition":0,"offset":1541129}
{"timestamp":1558877565239,"name":"producer_send_success","key":"2","value":"1.12","topic":"first","partition":0,"offset":1541130}
{"timestamp":1558877565240,"name":"producer_send_success","key":"3","value":"1.13","topic":"first","partition":0,"offset":1541131}
{"timestamp":1558877565240,"name":"producer_send_success","key":"4","value":"1.14","topic":"first","partition":0,"offset":1541132}
{"timestamp":1558877565241,"name":"producer_send_success","key":"5","value":"1.15","topic":"first","partition":0,"offset":1541133}
{"timestamp":1558877565244,"name":"producer_send_success","key":"6","value":"1.16","topic":"first","partition":0,"offset":1541134}
{"timestamp":1558877565244,"name":"producer_send_success","key":"7","value":"1.17","topic":"first","partition":0,"offset":1541135}
{"timestamp":1558877565244,"name":"producer_send_success","key":"8","value":"1.18","topic":"first","partition":0,"offset":1541136}
{"timestamp":1558877565244,"name":"producer_send_success","key":"9","value":"1.19","topic":"first","partition":0,"offset":1541137}
{"timestamp":1558877565262,"name":"shutdown_complete"}
{"timestamp":1558877565263,"name":"tool_data","sent":20,"acked":20,"target_throughput":-1,"avg_throughput":100.50251256281408}
```

# Kafka服务端脚本详解(3)-性能测试脚本

| 脚本名称 | 脚本用途 |
|---------|----------|
| kafka-producer-perf-test.sh | kafka 生产者性能测试脚本 |
| kafka-consumer-perf-test.sh | kafka 消费者性能测试脚本 |
| kafka-console-producer.sh | kafka 生产者控制台 |
| kafka-console-consumer.sh | kafka 消费者控制台 |

## kafka-producer-perf-test.sh

- kafka 生产者性能测试脚本

- --topic: 消息主题名称
- --num-records: 需要生产的消息数量
- --payload-delimiter: 指定 --payload-file 文件的分隔符，默认为换行符 \n
- --throughput: 设置消息吞吐量，messages/sec
- --producer-props: 发送端配置信息，配置信息优先于 --producer.config
- --producer.config: 发送端配置文件
- --print-metrics: 是否打印测试指标，默认 false
- --transactional-id: 用于测试并发事务的性能 (默认值:performance-producer-default-transactional-id)
- --transaction-duration-ms: 事务时间最大值，超过这个值就提交事务，只有 > 0 时才生效
- --record-size: 每条消息字节数
- --payload-file: 测试数据文件

测试 10w 条数据，每条数据 1000 字节，每秒发送 2000 条数据
```
[root@10 kafka_2.11-2.2.0]# bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=10.211.55.3:9092 --topic first --record-size 1000 --num-records 100000  --throughput 2000
9999 records sent, 1999.8 records/sec (1.91 MB/sec), 8.6 ms avg latency, 406.0 ms max latency.
10007 records sent, 2001.4 records/sec (1.91 MB/sec), 0.7 ms avg latency, 8.0 ms max latency.
10002 records sent, 2000.4 records/sec (1.91 MB/sec), 0.7 ms avg latency, 10.0 ms max latency.
10000 records sent, 2000.0 records/sec (1.91 MB/sec), 0.8 ms avg latency, 37.0 ms max latency.
10008 records sent, 2001.2 records/sec (1.91 MB/sec), 0.6 ms avg latency, 7.0 ms max latency.
10004 records sent, 2000.4 records/sec (1.91 MB/sec), 0.7 ms avg latency, 5.0 ms max latency.
10000 records sent, 2000.0 records/sec (1.91 MB/sec), 0.8 ms avg latency, 35.0 ms max latency.
10004 records sent, 2000.8 records/sec (1.91 MB/sec), 0.8 ms avg latency, 33.0 ms max latency.
10004 records sent, 2000.4 records/sec (1.91 MB/sec), 0.7 ms avg latency, 5.0 ms max latency.
100000 records sent, 1999.280259 records/sec (1.91 MB/sec), 1.50 ms avg latency, 406.00 ms max latency, 1 ms 50th, 2 ms 95th, 43 ms 99th, 91 ms 99.9th.
```
测试结果为：每秒发送 1.91MB 数据，平均延迟 1.5ms，最大延迟 406ms, 延迟小于 1ms 占 50%，小于 2ms 占 95%...

## kafka-consumer-perf-test.sh

- kafka 消费者性能测试脚本

- --topic: 消费的主题名称
- --broker-list: kafka 地址
- --consumer.config: 消费端配置文件
- --date-format: 格式化时间
- --fetch-size: 一次请求拉取的消息大小，默认 1048576 字节
- --from-latest: 如果消费者还没有已建立的偏移量，就从日志中的最新消息开始，而不是最早的消息
- --group: 消费者组 id，默认 perf-consumer-94851
- --hide-header: 如果设置，就跳过打印统计信息的标题
- --messages: 要获取的消息数量
- --num-fetch-threads: 获取消息的线程数量
- --print-metrics: 打印指标信息
- --reporting-interval: 打印进度信息的间隔，默认 5000ms
- --show-detailed-stats: 如果设置，将按 --reporting-interval 的间隔打印统计信息
- --socket-buffer-size: TCP 获取信息的缓存大小 默认 2097152（2M）
- --threads: 处理线程数，默认 10
- --timeout: 返回记录的超时时间

测试消费 50w 条数据
```
[root@10 kafka_2.11-2.2.0]# bin/kafka-consumer-perf-test.sh --topic first --broker-list 10.211.55.3:9092 --messages 500000  --timeout 300000
start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, nMsg.sec, rebalance.time.ms, fetch.time.ms, fetch.MB.sec, fetch.nMsg.sec
2019-05-30 01:21:27:072, 2019-05-30 01:21:30:801, 488.6162, 131.0314, 500343, 134176.1866, 25, 3704, 131.9158, 135081.8035
```
测试结果为：共消费 488.6162MB 数据，每秒消费 131.0314MB, 共消费 500343 条数据，每秒消费 134176.1866 条

# Kafka生产者端优化

```
测试环境虚拟机
CPU:2 核
RAM:2G
Kafka Topic 为 1 分区，1 副本
```

## Kafka 生产者端发送延迟优化

- batch.size: batch.size 单位为字节，为了方便这里都表示为kb,默认配置`batch.size=16kb`

- `batch.size=16kb`
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic first  --record-size 1024 --num-records 1000000  --throughput 50000
249892 records sent, 49978.4 records/sec (48.81 MB/sec), 153.6 ms avg latency, 537.0 ms max latency.
250193 records sent, 50038.6 records/sec (48.87 MB/sec), 1.4 ms avg latency, 12.0 ms max latency.
211747 records sent, 42349.4 records/sec (41.36 MB/sec), 194.3 ms avg latency, 1106.0 ms max latency.
1000000 records sent, 49972.515117 records/sec (48.80 MB/sec), 119.65 ms avg latency, 1106.00 ms max latency, 2 ms 50th, 488 ms 95th, 1043 ms 99th, 1102 ms 99.9th.
```
结果显示平均延迟有 456.94 ms，最高延迟 5308.00 ms

现在我要降低最高延迟数，batch.size 的意思是 ProducerBatch 的内存区域充满后，消息就会被立即发送，那我们把值改小看看

- `batch.size=8kb`
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic first  --record-size 1024 --num-records 1000000  --throughput 50000
148553 records sent, 29710.6 records/sec (29.01 MB/sec), 812.4 ms avg latency, 1032.0 ms max latency.
195468 records sent, 39093.6 records/sec (38.18 MB/sec), 735.9 ms avg latency, 907.0 ms max latency.
189700 records sent, 37940.0 records/sec (37.05 MB/sec), 763.4 ms avg latency, 1053.0 ms max latency.
208418 records sent, 41683.6 records/sec (40.71 MB/sec), 689.7 ms avg latency, 923.0 ms max latency.
196504 records sent, 39300.8 records/sec (38.38 MB/sec), 718.1 ms avg latency, 1056.0 ms max latency.
1000000 records sent, 37608.123355 records/sec (36.73 MB/sec), 741.56 ms avg latency, 1056.00 ms max latency, 725 ms 50th, 937 ms 95th, 1029 ms 99th, 1051 ms 99.9th.
```

但经过测试发现，延迟反而很高，连设定的 50000 吞吐量都达不到，原因应该是这样：batch.size 小了，消息很快就会充满，这样消息就会被立即发送的服务端，但这样的话发送的次数就变多了，但由于网络原因是不可控的，有时候网络发生抖动就会造成较高的延迟,那就改大看看。

- `batch.size=32kb`
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic first  --record-size 1024 --num-records 1000000  --throughput 50000
249852 records sent, 49970.4 records/sec (48.80 MB/sec), 88.8 ms avg latency, 492.0 ms max latency.
250143 records sent, 50028.6 records/sec (48.86 MB/sec), 1.2 ms avg latency, 15.0 ms max latency.
250007 records sent, 49991.4 records/sec (48.82 MB/sec), 1.2 ms avg latency, 17.0 ms max latency.
1000000 records sent, 49952.545082 records/sec (48.78 MB/sec), 31.07 ms avg latency, 492.00 ms max latency, 1 ms 50th, 305 ms 95th, 440 ms 99th, 486 ms 99.9th.
```

测试后，平均延迟，最高延迟都降下来很多，而且比默认值延迟都要小很多，那再改大延迟还会降低吗

- `batch.size=50kb`
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic first  --record-size 1024 --num-records 1000000  --throughput 50000
249902 records sent, 49970.4 records/sec (48.80 MB/sec), 27.3 ms avg latency, 219.0 ms max latency.
250200 records sent, 50030.0 records/sec (48.86 MB/sec), 1.2 ms avg latency, 8.0 ms max latency.
250098 records sent, 50019.6 records/sec (48.85 MB/sec), 18.6 ms avg latency, 288.0 ms max latency.
242327 records sent, 48407.3 records/sec (47.27 MB/sec), 121.3 ms avg latency, 920.0 ms max latency.
1000000 records sent, 49823.127896 records/sec (48.66 MB/sec), 41.98 ms avg latency, 920.00 ms max latency, 1 ms 50th, 221 ms 95th, 792 ms 99th, 910 ms 99.9th.
```
如上测试在不同的机器上结果会有不同，但总体的变化曲线是一样的，成 U 型变化



- batch.size 代码实现

Kafka 客户端有一个 RecordAccumulator 类，叫做消息记录池，内部有一个 BufferPool 内存区域
```
RecordAccumulator(LogContext logContext,
                             int batchSize,
                             CompressionType compression,
                             int lingerMs,
                             long retryBackoffMs,
                             int deliveryTimeoutMs,
                             Metrics metrics,
                             String metricGrpName,
                             Time time,
                             ApiVersions apiVersions,
                             TransactionManager transactionManager,
                             BufferPool bufferPool)
```
当该判断为 true，消息就会被发送
```
if (result.batchIsFull || result.newBatchCreated) {
   log.trace("Waking up the sender since topic {} partition {} is either full or getting a new batch", record.topic(), partition);
   this.sender.wakeup();
}
```

- max.in.flight.requests.per.connection

该参数可以在一个 connection 中发送多个请求，叫作一个 flight, 这样可以减少开销，但是如果产生错误，可能会造成数据的发送顺序改变，默认 5

在 batch.size=100kb 的基础上，增加该参数值到 10，看看效果
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic two   --record-size 1024 --num-records 1000000  --throughput 50000
249902 records sent, 49960.4 records/sec (48.79 MB/sec), 16.1 ms avg latency, 185.0 ms max latency.
250148 records sent, 50019.6 records/sec (48.85 MB/sec), 1.3 ms avg latency, 14.0 ms max latency.
239585 records sent, 47917.0 records/sec (46.79 MB/sec), 6.4 ms avg latency, 226.0 ms max latency.
1000000 records sent, 49960.031974 records/sec (48.79 MB/sec), 9.83 ms avg latency, 226.00 ms max latency, 1 ms 50th, 83 ms 95th, 182 ms 99th, 219 ms 99.9th.
```
多次测试结果延迟都比原来降低了 10 倍多，效果还是很明显的但物极必反，如果你再调大后，效果就不明显了，最终延迟反而变高，这个 batch.size 道理是一样的

- compression.type

指定消息的压缩方式，默认不压缩

在原来 batch.size=100kb,max.in.flight.requests.per.connection=10 的基础上，设置 compression.type=gzip 看看延迟是否还可以降低
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic two   --record-size 1024 --num-records 1000000  --throughput 50000
249785 records sent, 49957.0 records/sec (48.79 MB/sec), 2.5 ms avg latency, 199.0 ms max latency.
250091 records sent, 50008.2 records/sec (48.84 MB/sec), 1.9 ms avg latency, 17.0 ms max latency.
250123 records sent, 50024.6 records/sec (48.85 MB/sec), 1.5 ms avg latency, 18.0 ms max latency.
1000000 records sent, 49960.031974 records/sec (48.79 MB/sec), 1.89 ms avg latency, 199.00 ms max latency, 2 ms 50th, 4 ms 95th, 6 ms 99th, 18 ms 99.9th.
```
测试结果发现延迟又降低了，是不是感觉很强大😁

acks

指定分区中必须有多少个副本收到这条消息，才算消息发送成功，默认值 1,如果配置 acks=0 还能降低一点点延迟，就是不等待 broker 返回是否成功，发出去就完了
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic two   --record-size 1024 --num-records 1000000  --throughput 50000
249919 records sent, 49963.8 records/sec (48.79 MB/sec), 1.4 ms avg latency, 179.0 ms max latency.
250157 records sent, 50021.4 records/sec (48.85 MB/sec), 1.2 ms avg latency, 10.0 ms max latency.
250228 records sent, 50015.6 records/sec (48.84 MB/sec), 0.9 ms avg latency, 8.0 ms max latency.
1000000 records sent, 49967.521111 records/sec (48.80 MB/sec), 1.09 ms avg latency, 179.00 ms max latency, 1 ms 50th, 3 ms 95th, 4 ms 99th, 6 ms 99.9th.
```

通过测试上面几个参数，如果只配置其中一个，compression.type=gzip 效果是最好的
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic two   --record-size 1024 --num-records 1000000  --throughput 50000
249882 records sent, 49956.4 records/sec (48.79 MB/sec), 11.9 ms avg latency, 191.0 ms max latency.
248708 records sent, 49731.7 records/sec (48.57 MB/sec), 2.9 ms avg latency, 92.0 ms max latency.
251380 records sent, 50276.0 records/sec (49.10 MB/sec), 2.0 ms avg latency, 23.0 ms max latency.
249980 records sent, 49996.0 records/sec (48.82 MB/sec), 1.5 ms avg latency, 18.0 ms max latency.
1000000 records sent, 49960.031974 records/sec (48.79 MB/sec), 4.55 ms avg latency, 191.00 ms max latency, 2 ms 50th, 12 ms 95th, 88 ms 99th, 163 ms 99.9th.

在当前环境下，平均延迟能只有 4.55ms, 最大延迟 191ms

如上测试是在单机1分区，1副本的情况下的，为了能看到效果，延迟只是一个指标，但实际中并不是一味追求某个指标，还需要综合考虑，比如低延迟下，还要提高吞吐量，这就会要牺牲一部分的低延迟。不同的优化点，需要调整不同的参数，具体参数可以见 https://dwz.cn/Sl5L3zoq

另外：
 如果 Topic 是多分区，也有显著效果，如果还需要降低延迟，可以再通过如上的参数进行优化

比如在当前环境下，我现在要达到 10w 的吞吐量，默认配置下是达不到的
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic two    --record-size 1024 --num-records 1000000  --throughput 100000
1 records sent, 0.1 records/sec (0.00 MB/sec), 7194.0 ms avg latency, 7194.0 ms max latency.
91167 records sent, 3306.3 records/sec (3.23 MB/sec), 519.4 ms avg latency, 26096.0 ms max latency.
330075 records sent, 66015.0 records/sec (64.47 MB/sec), 2843.5 ms avg latency, 26106.0 ms max latency.
227535 records sent, 45507.0 records/sec (44.44 MB/sec), 556.2 ms avg latency, 2306.0 ms max latency.
236940 records sent, 38577.0 records/sec (37.67 MB/sec), 522.0 ms avg latency, 3439.0 ms max latency.
1000000 records sent, 18762.078088 records/sec (18.32 MB/sec), 1402.18 ms avg latency, 26106.00 ms max latency, 443 ms 50th, 4018 ms 95th, 26073 ms 99th, 26095 ms 99.9th.
```

通过这几个配置`batch.size=204800` `compression.type=gzip`,就近乎达到了 10w 的吞吐量
```
[root@10 kafka_2.11-2.2.0]# ./bin/kafka-producer-perf-test.sh --producer.config config/me.properties --topic tw   --record-size 1024 --num-records 2000000  --throughput 100000
397998 records sent, 79599.6 records/sec (77.73 MB/sec), 3.4 ms avg latency, 193.0 ms max latency.
489610 records sent, 97922.0 records/sec (95.63 MB/sec), 2.5 ms avg latency, 24.0 ms max latency.
522791 records sent, 104558.2 records/sec (102.11 MB/sec), 1.8 ms avg latency, 29.0 ms max latency.
485255 records sent, 96973.4 records/sec (94.70 MB/sec), 1.8 ms avg latency, 26.0 ms max latency.
2000000 records sent, 94665.593790 records/sec (92.45 MB/sec), 2.31 ms avg latency, 193.00 ms max latency, 2 ms 50th, 5 ms 95th, 12 ms 99th, 23 ms 99.9th.
```
到这里Kafka的所有配置上的性能优化到此就结束了。
