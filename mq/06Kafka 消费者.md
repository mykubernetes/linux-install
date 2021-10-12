# 一、确保消费者消费的消息是顺序的，需要把消息存放在同一个topic的同一个分区下：

如：生产者需要按顺序写入数据 1 2 3 4 5 6 ，消费者需要消费顺序也必须为 1 2 3 4 5 6

## 1、创建话题：
```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test 
```
-  partitions 指定分区为1个

## 2、生产者：
```
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
 
>1
>2
>3
>4
>5
>6
```

## 3、消费者：
```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```
这样能确保消息的按顺序消费的。

 

# 二、队列与发布订阅下消息的顺序性

## 1）队列：消费者A、消费者B属于同一个消费者组a

创建话题（指定2个分区）：
```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 2 --topic test 
```
- partitions 指定分区为2个

生产者不变

消费者A，B：
```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning --group a
```
-  group指定为同一个消费者组

则最后A输出1 3 5，B输出2 4 6。因为消息是平均写入到两个分区的。在同一个消费者组下，A和B各获得一个不同的分区（属于同一个topic）

 

## 2）发布订阅：消费者A属于消费者组a、消费者B属于同一个消费者组b

消费者A：
```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning --group a

消费者B：
```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning --group b
```

则最后A、B都输出1 3 2 5 4 6。因为是不同的消费者组，所以消息都全部被A与B订阅，所以1-6的6个数字都被两个消费者消费到。但是由于A或B本身获取到两个该topic的分区，读取的顺序是随机的，所以不能确保1-6这6个数字的顺序性。
