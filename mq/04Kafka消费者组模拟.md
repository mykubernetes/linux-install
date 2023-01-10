# 一、什么是消费者组（Consumer Group）

消费者组（Consumer Group）是逻辑上的概念，是Kafka中实现单播和广播两种消息模型的手段。

对于同一个topic的数据，会广播给不同的group；同一个group中的worker，只有一个worker能拿到这个数据。换句话说，对于同一个topic，每个group都可以拿到同样的所有数据，但是数据进入group后只能被其中的一个worker消费。group内的worker可以使用多线程或多进程来实现，也可以将进程分散在多台机器上，worker的数量通常不超过partition的数量，且二者最好保持整数倍关系，因为Kafka在设计时假定了一个partition只能被一个worker消费（同一group内）。

消费者组consumer group是kafka提供的可扩展且具有容错性的消费者机制。既然是一个组，那么组内必然可以有多个消费者或消费者实例(consumer instance)，它们共享一个公共的ID，即group ID。组内的所有消费者协调在一起来消费订阅主题(subscribed topics)的所有分区(partition)。当然，每个分区只能由同一个消费组内的一个consumer来消费。

总结消费者组（consumer group）有以下三个特点：
- 1）每个消费者组下面可以有一个或多个消费者实例，而消费者实例可以是一个进程，也可以是一个线程；
- 2）每个消费者组都具有一个用来唯一标识的字符串形式的ID，即group.id ；
- 3）每个消费者组订阅的topic下的每个partition分区只能分配给该消费者组下的一个消费者实例(当然该分区也还可以被分配给其它的消费者组)




## 1、创建一个topic
```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test 
```

## 2、生产者
```
# bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
>1
>2
>3
>4
>5
>6
```

## 3、消费者
```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
1
2
3
4
5
6
```
- 这样能确保消息的按顺序消费的。



# 二、多情形消费者案例测试

## 1、单个消费者组（group1）——消费者数量多于分区数

1）创建一个用于测试的具有3个分区的topic：test
```
# bin/kafka-topics.sh --create --zookeeper node001:2181,node002:2181,node003:2181 --replication-factor 1 --partitions 3 --topic test
```

2）启动1个生产者和4个消费者，查看消费结果。

生产者
```
# bin/kafka-console-producer.sh --broker-list node001:9092,node002:9092,node003:9092 --topic test
>1
>2
>3
>4
>5
>6
>7
>8
>9
>10
>11
>12
>
```

消费者1
```
# bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
2
5
8
11
```

消费者2
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
3
6
9
12
```

消费者3
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
1
4
7
10
```

消费者4
```
# bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
```
- 通过添加 --group = group1 选项来指定消费组为group1

3) 查看消费者组（group1）中各消费者对应的分区情况：
```
# bin/kafka-consumer-groups.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --describe --group group1

TOPIC       PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG         CONSUMER-ID                                     HOST          CLIENT-ID
test        0          4               4               0           consumer-1-281faa83-995c-4b1c-993a-a1303444e260 /127.0.0.1    consumer1
test        1          4               4               0           consumer-1-435cbd8a-d6d9-48ac-a8a8-bbfb584cabb9 /127.0.0.1    consumer1
test        2          4               4               0           consumer-1-7d96ffc4-f694-4d46-a102-137ce04938f7 /127.0.0.1    consumer1
```
- 可见，有一个消费者是没有对应的partition的，所以它就拉取不到消息。因此，我们在建立topic的时候，可以多建一些分区，保证多个消费者都能对应到分区，避免有消费者被浪费。当然，在创建完topic后，利用命令kafka-reassign-partitions.sh是可以进行增加分区的。

**结论：同一个分区内的消息只能被同一个组中的一个消费者消费，当消费者数量多于分区数量时，多于的消费者空闲（不能消费数据）。**


## 2、单个消费者组（group1）——消费者数量少于和等于分区数

1）启动1个生产者和2个消费者,查看消费结果

生产者
```
# bin/kafka-console-producer.sh --broker-list node001:9092,node002:9092,node003:9092 --topic test
>1
>2
>3
>4
>5
>6
>7
>8
>9
>10
>
```

消费者1
```
# bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
2
5
8
```

消费者2
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
1
3
4
6
7
9
10
```
- 可见，当使用2个消费者的时候，发现消费数据的没有被平均分配，而是一个是7条，一个是3条。原因在于有一个消费者对应2个分区，而另一个消费者对应一个分区，而消息的消费是根据分区进行平均消费的。


2）查看消费者组（group1）中各消费者对应的分区情况
```
# bin/kafka-consumer-groups.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --describe --group group1

TOPIC       PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG         CONSUMER-ID                                     HOST          CLIENT-ID
test        0          13               13               0         consumer-1-281faa83-995c-4b1c-993a-a1303444e260 /127.0.0.1    consumer1
test        1          11               11               0         consumer-1-281faa83-995c-4b1c-993a-a1303444e260 /127.0.0.1    consumer1
test        2          12               12               0         consumer-1-7d96ffc4-f694-4d46-a102-137ce04938f7 /127.0.0.1    consumer1
```

## 3、测试启动1个生产者和3个消费者查看消费结果

生产者
```
# bin/kafka-console-producer.sh --broker-list node001:9092,node002:9092,node003:9092 --topic test
>1
>2
>3
>4
>5
>6
>7
>8
>9
>10
>
```

消费者1
```
# bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
1
4
7
```

消费者2
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
2
5
8
```

消费者3
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
3
6
9
```

查看消费者组（group1）中各消费者对应的分区情况
```
# bin/kafka-consumer-groups.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --describe --group group1

TOPIC       PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG         CONSUMER-ID                                     HOST          CLIENT-ID
test        2          15               15               0         consumer-1-281faa83-995c-4b1c-993a-a1303444e260 /127.0.0.1    consumer1
test        0          16               16               0         consumer-1-435cbd8a-d6d9-48ac-a8a8-bbfb584cabb9 /127.0.0.1    consumer1
test        1          14               14               0         consumer-1-7d96ffc4-f694-4d46-a102-137ce04938f7 /127.0.0.1    consumer1
```
- 可见，三个消费者各自对应一个分区，非常理想地将9条消息平均消费，每个消费者消费三条消息，组合起来就是所有的消息，保证了数据的完整性。

**结论：当分区数多于消费者数的时候，有的消费者对应多个分区。当分区数等于消费者数的时候，每个消费者对应一个分区**


## 4、多个消费者组（group1、group2）

1）启动1个生产者

生产者
```
# bin/kafka-console-producer.sh --broker-list node001:9092,node002:9092,node003:9092 --topic test
>1
>2
>3
>4
>5
>6
>7
>8
>9
>10
>
```

2）消费者组（group1）启动3个消费者

消费者1
```
# bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
1
4
7
```

消费者2
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
2
5
8
```

消费者3
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group1
3
6
9
```

3）消费者组（group2）启动1个消费者

消费者1
```
bin/kafka-console-consumer.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --topic test --group=group2
1
2
3
4
5
6
7
8
9
```


4）查看消费结果
```
# bin/kafka-consumer-groups.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --describe --group group1

TOPIC       PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG         CONSUMER-ID                                     HOST          CLIENT-ID
test        1          15               15               0         consumer-1-281faa83-995c-4b1c-993a-a1303444e260 /127.0.0.1    consumer1
test        0          16               16               0         consumer-1-435cbd8a-d6d9-48ac-a8a8-bbfb584cabb9 /127.0.0.1    consumer1
test        2          14               14               0         consumer-1-7d96ffc4-f694-4d46-a102-137ce04938f7 /127.0.0.1    consumer1



# bin/kafka-consumer-groups.sh --bootstrap-server node001:9092,node002:9092,node003:9092 --describe --group group2

TOPIC       PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG         CONSUMER-ID                                     HOST          CLIENT-ID
test        0          19               19               0         consumer-1-3aecd259-e164-4a40-b4f7-64dfadcdfadf /127.0.0.1    consumer1
test        1          17               17               0         consumer-1-3aecd259-e164-4a40-b4f7-64dfadcdfadf /127.0.0.1    consumer1
test        2          18               18               0         consumer-1-3aecd259-e164-4a40-b4f7-64dfadcdfadf /127.0.0.1    consumer1
```
**结论：对于同一个topic，每个消费者组group都可以拿到同样的所有数据，但是数据进入group后只能被该组中的一个消费者所消费。**



# 三、将消费者组id配置到配置文件中

1、在node001、node002上修改kafka/config/consumer.properties配置文件中的group.id属性为任意组名。
```
# vi consumer.properties
group.id=test001
```

2、在node001、node002上分别启动消费者
```
# bin/kafka-console-consumer.sh --zookeeper node001:2181 --topic first --consumer.config config/consumer.properties
# bin/kafka-console-consumer.sh --zookeeper node001:2181 --topic first --consumer.config config/consumer.properties
```

3、在node003上启动生产者
```
# bin/kafka-console-producer.sh --broker-list node001:9092 --topic first
>hello world
```
查看node001和node002的接收者,同一时刻只有一个消费者接收到消息。
