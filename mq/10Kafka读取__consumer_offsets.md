# Kafka读取__consumer_offsets

注意：该实验受限于kafka版本，我在kafka_2.11-0.9.0.1和kafka_2.10-0.10.1.0中都成功了，而在较旧的kafka_2.10-0.8.2.0（根本就不会产生__consumer_offsets）和最新的kafka_2.11-0.11.0.0（在第6步的时候报错Exception in thread “main” java.lang.ClassNotFoundException: kafka.coordinator.GroupMetadataManager$OffsetsMessageFormatter）中却无法完成。

由于Zookeeper并不适合大批量的频繁写入操作，新版Kafka（0.8版本之后）已推荐将consumer的位移信息保存在Kafka内部的topic中，即__consumer_offsets topic，并且默认提供了kafka_consumer_groups.sh脚本供用户查看consumer信息。

不过依然有很多用户希望了解__consumer_offsets topic内部到底保存了什么信息，特别是想查询某些consumer group的位移是如何在该topic中保存的。针对这些问题，本文将结合一个实例探讨如何使用kafka-simple-consumer-shell脚本来查询该内部topic。

## 1.创建topic “test”：
```
# bin/kafka-topics.sh --create --zookeeper h153:2181 --replication-factor 1 --partitions 2 --topic test
```

## 2.使用kafka-console-producer.sh脚本生产消息：

本例中生产了4条消息
```
# bin/kafka-console-producer.sh --broker-list h153:9092 --topic test
```


## 3.验证消息生产成功：
```
# bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list h153:9092 --topic test --time -1
test:1:2
test:0:2
```
参数解释：
- --time -1 表示从最新的时间的offset中得到数据条数
- 输出结果每个字段分别表示topic、partition、untilOffset
- 上面的输出结果表明总共生产了4条消息

## 4.创建一个console consumer group：
```
# bin/kafka-console-consumer.sh --bootstrap-server h153:9092 --topic test --from-beginning --new-consumer
```

在kafka启动窗口你会看见输出这些信息：
```
[2017-09-26 21:49:54,454] INFO [Group Metadata Manager on Broker 0]: Loading offsets and group metadata from [__consumer_offsets,32] (kafka.coordinator.GroupMetadataManager)
[2017-09-26 21:49:54,457] INFO [Group Metadata Manager on Broker 0]: Finished loading offsets from [__consumer_offsets,32] in 3 milliseconds. (kafka.coordinator.GroupMetadataManager)
[2017-09-26 21:49:54,457] INFO [Group Metadata Manager on Broker 0]: Loading offsets and group metadata from [__consumer_offsets,35] (kafka.coordinator.GroupMetadataManager)
注：默认情况下__consumer_offsets有50个分区
```
使用bin/kafka-topics.sh --list --zookeeper h153:2181你会看到__consumer_offsets生成

## 5.获取该consumer group的group id：

后面需要根据该id查询它的位移信息
```
# bin/kafka-consumer-groups.sh --bootstrap-server h153:9092 --list --new-consumer
输出：console-consumer-88985  (记住这个id！)
```

## 6.查询__consumer_offsets topic所有内容：

注意：运行下面命令前先要在consumer.properties中设置exclude.internal.topics=false否则该运行该命令后卡住不动，按Ctrl+C也无法结束。
```
# bin/kafka-console-consumer.sh --topic __consumer_offsets --zookeeper h153:2181 --formatter "kafka.coordinator.GroupMetadataManager\$OffsetsMessageFormatter" --consumer.config config/consumer.properties --from-beginning
[console-consumer-88985,test,1]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800225,ExpirationTime 1506520200225]
[console-consumer-88985,test,0]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800225,ExpirationTime 1506520200225]
[console-consumer-88985,test,1]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800326,ExpirationTime 1506520200326]
[console-consumer-88985,test,0]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800326,ExpirationTime 1506520200326]
注：第二次运行这个命令的时候得加--delete-consumer-offsets
```

```
# 0.11.0.0之前版本
bin/kafka-console-consumer.sh --topic __consumer_offsets --zookeeper localhost:2181 --formatter "kafka.coordinator.GroupMetadataManager\$OffsetsMessageFormatter" --consumer.config config/consumer.properties --from-beginning

# 0.11.0.0之后版本(含)
bin/kafka-console-consumer.sh --topic __consumer_offsets --zookeeper localhost:2181 --formatter "kafka.coordinator.group.GroupMetadataManager\$OffsetsMessageFormatter" --consumer.config config/consumer.properties --from-beginning
```

## 7.计算指定consumer group在__consumer_offsets topic中分区信息：

这时候就用到了第5步获取的group.id(本例中是console-consumer-88985)。Kafka会使用下面公式计算该group位移保存在__consumer_offsets的哪个分区上：
```  
Math.abs(groupID.hashCode()) % numPartitions
```

所以在本例中，对应的分区=Math.abs("console-consumer-88985".hashCode()) % 50 = 39，即__consumer_offsets的分区39保存了这个consumer group的位移信息，下面让我们验证一下。（你可以写个Java小程序直接输出System.out.println(Math.abs(“console-consumer-88985”.hashCode()) % 50);即可知道结果）

## 8.获取指定consumer group的位移信息：
```
# bin/kafka-simple-consumer-shell.sh --topic __consumer_offsets --partition 39 --broker-list h153:9092 --formatter "kafka.coordinator.GroupMetadataManager\$OffsetsMessageFormatter"
[console-consumer-88985,test,1]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800225,ExpirationTime 1506520200225]
[console-consumer-88985,test,0]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800225,ExpirationTime 1506520200225]
[console-consumer-88985,test,1]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800326,ExpirationTime 1506520200326]
[console-consumer-88985,test,0]::[OffsetMetadata[2,NO_METADATA],CommitTime 1506433800326,ExpirationTime 1506520200326]
注：如果将39换为其他数字则不会有上面的内容输出
```

```
# 0.11.0.0版本之前
bin/kafka-simple-consumer-shell.sh --topic __consumer_offsets --partition 11 --broker-list h153:9092 --formatter "kafka.coordinator.GroupMetadataManager\$OffsetsMessageFormatter"

0.11.0.0版本以后(含)
bin/kafka-simple-consumer-shell.sh --topic __consumer_offsets --partition 11 --broker-list h153:9092 --formatter "kafka.coordinator.group.GroupMetadataManager\$OffsetsMessageFormatter"
```
