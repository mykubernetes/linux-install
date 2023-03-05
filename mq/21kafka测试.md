https://kafka.apache.org/32/documentation.html#uses

# 测试Kafka集群

## 1、创建topic
```
[root@data-vm1 kafka_2.12-3.3.1]# bin/kafka-topics.sh \
--create \
--topic quickstart-events \
--bootstrap-server data-vm4:9092
 
Created topic quickstart-events.
[root@data-vm1 kafka_2.12-3.3.1]#
 
# 
[root@data-vm1 kafka_2.12-3.3.1]# bin/kafka-topics.sh \
--create \
--topic quickstart-events \
--bootstrap-server data-vm1:9092,data-vm2:9092,data-vm3:9092
```

## 2、查看topic列表
```
bin/kafka-topics.sh \
--list \
--bootstrap-server data-vm4:9092
 
# 
bin/kafka-topics.sh \
--list \
--bootstrap-server data-vm1:9092,data-vm2:9092,data-vm3:9092,data-vm4:9092
```

## 3、查看消息详情
```
[root@data-vm1 kafka_2.12-3.3.1]# bin/kafka-topics.sh \
--describe \
--topic quickstart-events \
--bootstrap-server data-vm3:9092
 
Topic: quickstart-events        TopicId: zSOJC6wNRRGQ4MudfHLGvQ PartitionCount: 1       ReplicationFactor: 1    Configs: segment.bytes=1073741824
        Topic: quickstart-events        Partition: 0    Leader: 1       Replicas: 1     Isr: 1
 
[root@data-vm1 kafka_2.12-3.3.1]#
```

## 4、生产消息
```
[root@data-vm1 kafka_2.12-3.3.1]# bin/kafka-console-producer.sh \
--topic quickstart-events \
--bootstrap-server data-vm1:9092
 
# 参考: 创建并配置topic
bin/kafka-topics.sh \
--bootstrap-server localhost:9092 \
--create \
--topic my-topic \
--partitions 1 \
--replication-factor 1 \
--config max.message.bytes=64000 \
--config flush.messages=1
 
# ------------------------- 参考 ------------------------ #
# 1: 修改已创建topic配置
# (Overrides can also be changed or set later using the alter configs command.)
bin/kafka-configs.sh \
--bootstrap-server localhost:9092 \
--entity-type topics \
--entity-name my-topic \
--alter \
--add-config max.message.bytes=128000
 
# 2: 检查已修改的topic配置是否生效
# (To check overrides set on the topic you can do)
bin/kafka-configs.sh \
--bootstrap-server localhost:9092 \
--entity-type topics \
--entity-name my-topic \
--describe
 
# 3. 恢复到原来的配置
# (To remove an override you can do)
bin/kafka-configs.sh \
--bootstrap-server localhost:9092 \
--entity-type topics \
--entity-name my-topic \
--alter \
--delete-config max.message.bytes
 
# 4. 增加分区数
# (To add partitions you can do)
bin/kafka-topics.sh \
--bootstrap-server broker_host:port \
--alter \
--topic my_topic_name \
--partitions 40
 
# 5. 添加配置
# (To add configs:)
bin/kafka-configs.sh \
--bootstrap-server broker_host:port \
--entity-type topics \
--entity-name my_topic_name \
--alter \
--add-config x=y
 
# 6. 移除配置
# (To remove a config:)
bin/kafka-configs.sh \
--bootstrap-server broker_host:port \
--entity-type topics \
--entity-name my_topic_name \
--alter \
--delete-config x
 
# 7. 删除topic
# (And finally deleting a topic:)
bin/kafka-topics.sh \
--bootstrap-server broker_host:port \
--delete \
--topic my_topic_name
```

5、消费消息
```
bin/kafka-console-consumer.sh \
--topic quickstart-events \
--from-beginning \
--bootstrap-server data-vm4:9092
```

## 6、查看消费者组
```
# 检查消费者postition
# Checking consumer position
bin/kafka-consumer-groups.sh \
--bootstrap-server localhost:9092 \
--describe \
--group my-group
 
  TOPIC                          PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG        CONSUMER-ID                                       HOST                           CLIENT-ID
  my-topic                       0          2               4               2          consumer-1-029af89c-873c-4751-a720-cefd41a669d6   /127.0.0.1                     consumer-1
  my-topic                       1          2               3               1          consumer-1-029af89c-873c-4751-a720-cefd41a669d6   /127.0.0.1                     consumer-1
  my-topic                       2          2               3               1          consumer-2-42c1abd4-e3b2-425d-a8bb-e1ea49b29bb2   /127.0.0.1                     consumer-2
```

## 7、查看消费者组列表
```
# list all consumer groups across all topics
bin/kafka-consumer-groups.sh \
--bootstrap-server localhost:9092 \
--list
 
  test-consumer-group
 
 
# To view offsets, as mentioned earlier, 
# we "describe" the consumer group like this:
bin/kafka-consumer-groups.sh \
--bootstrap-server localhost:9092 \
--describe \
--group my-group
 
  TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                    HOST            CLIENT-ID
  topic3          0          241019          395308          154289          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
  topic2          1          520678          803288          282610          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
  topic3          1          241018          398817          157799          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
  topic1          0          854144          855809          1665            consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1
  topic2          0          460537          803290          342753          consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1
  topic3          2          243655          398812          155157          consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1      consumer4
 
# 更多配置参考:
# https://kafka.apache.org/32/documentation.html#uses
```
