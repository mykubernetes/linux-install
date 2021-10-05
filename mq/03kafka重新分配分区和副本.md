# 分区重新分配

## 一、条件准备
1、创建一个有三个节点的集群
```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic heima-par --partitions 3 --replication-factor 3
Created topic heima-par.
```

2、详情查看
```
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic heima-par
Topic:heima-par PartitionCount:3    ReplicationFactor:3   Configs:
Topic: heima-par    Partition: 0  Leader: 2    Replicas: 2,1,0 Isr: 2,1,0
Topic: heima-par    Partition: 1  Leader: 0    Replicas: 0,2,1 Isr: 0,2,1
Topic: heima-par    Partition: 2  Leader: 1    Replicas: 1,0,2 Isr: 1,0,2
```
- 从上面的输出可以看出heima-par这个主题一共有三个分区，有三个副本

## 二、扩容前准备

1、主题heima-par再添加一个分区
```
# bin/kafka-topics.sh --alter --zookeeper localhost:2181 --topic heima-par --partitions 4
WARNING: If partitions are increased for a topic that has a key, the partition logic or ordering of the messages will be affected
Adding partitions succeeded!
```

2、查看详情已经变成4个分区
```
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic heima-par
Topic:heima-par PartitionCount:4    ReplicationFactor:3   Configs:
Topic: heima-par    Partition: 0  Leader: 2    Replicas: 2,1,0 Isr: 2,1,0
Topic: heima-par    Partition: 1  Leader: 0    Replicas: 0,2,1 Isr: 0,2,1
Topic: heima-par    Partition: 2  Leader: 1    Replicas: 1,0,2 Isr: 1,0,2
Topic: heima-par    Partition: 3  Leader: 2    Replicas: 2,1,0 Isr: 2,1,0
```
- 这样会导致 broker2维护更多的分区

3、再添加一个 broker节点
```
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic heima-par
Topic:heima-par PartitionCount:4    ReplicationFactor:3   Configs:
Topic: heima-par    Partition: 0  Leader: 2    Replicas: 2,1,0 Isr: 2,1,0
Topic: heima-par    Partition: 1  Leader: 0    Replicas: 0,2,1 Isr: 0,2,1
Topic: heima-par    Partition: 2  Leader: 1    Replicas: 1,0,2 Isr: 1,0,2
Topic: heima-par    Partition: 3  Leader: 2    Replicas: 2,1,0 Isr: 2,1,0
```
- 从上面输出信息可以看出新添加的节点并没有分配之前主题的分区

## 三、重新分配Partition

1) 将原先分布在broker 1-3节点上的分区重新分布到broker 1-4节点上
```
# cat reassign.json
{"topics":[{"topic":"heima-par"}],
"version":1
}
```

2) 使用 kafka -reassign-partitions.sh 工具生成reassign plan
```
# kafka-reassign-partitions.sh --zookeeper localhost:2181 --topics-to-move-json-file reassign.json --broker-list "0,1,2,3" --generate
Current partition replica assignment
{"version":1,"partitions":[{"topic":"heima-par","partition":2,"replicas":[1,0,2],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":1,"replicas":[0,2,1],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":0,"replicas":[2,1,0],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":3,"replicas":[2,1,0],"log_dirs":["any","any","any"]}]}

Proposed partition reassignment configuration
{"version":1,"partitions":[{"topic":"heima-par","partition":0,"replicas":[1,2,3],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":2,"replicas":[3,0,1],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":1,"replicas":[2,3,0],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":3,"replicas":[0,1,2],"log_dirs":["any","any","any"]}]}
```
- --generate 表示指定类型参数
- --topics-to-move-json-file 指定分区重分配对应的主题清单路径

> 命令输入两个Json字符串，第一个JSON内容为当前的分区副本分配情况，第二个为重新分配的候选方案，注意这里只是生成一份可行性的方案，并没有真正执行重分配的动作。

3) 将第二个JSON内容保存到名为result.json文件里面（文件名不重要，文件格式也不一定要以json为结尾，只要保证内容是json即可），然后执行这些reassign plan：
```
# cat result.json
{
 "version": 1,
 "partitions": [
   {
     "topic": "heima-par",
     "partition": 0,
     "replicas": [
       1,
       2,
       3
     ],
     "log_dirs": [
       "any",
       "any",
       "any"
     ]
   },
   {
     "topic": "heima-par",
     "partition": 2,
     "replicas": [
       3,
       0,
     "log_dirs": [
       "any",
       "any",
       "any"
     ]
   },
   {
     "topic": "heima-par",
     "partition": 1,
     "replicas": [
       2,
       3,
       0
     ],
     "log_dirs": [
       "any",
       "any",
       "any"
     ]
   },
   {
     "topic": "heima-par",
     "partition": 3,
     "replicas": [
       0,
       1,
       2
     ],
     "log_dirs": [
       "any",
       "any",
       "any"
     ]
   }
 ]
}
```

4) 执行副本搬迁
```
# kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file result.json --execute
Current partition replica assignment
{"version":1,"partitions":[{"topic":"heima-par","partition":2,"replicas":[1,0,2],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":1,"replicas":[0,2,1],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":0,"replicas":[2,1,0],"log_dirs":["any","any","any"]},{"topic":"heima-par","partition":3,"replicas":[2,1,0],"log_dirs":["any","any","any"]}]}
Save this to use as the --reassignment-json-file option during rollback
Successfully started reassignment of partitions
```

5) 查看分区重新分配的进度
```
# kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file result.json --verify
Status of partition reassignment:
Reassignment of partition heima-par-3 completed successfully
Reassignment of partition heima-par-0 is still in progress
Reassignment of partition heima-par-2 is still in progress
Reassignment of partition heima-par-1 is still in progress

# kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file result.json --verify
Status of partition reassignment:
Reassignment of partition heima-par-3 completed successfully
Reassignment of partition heima-par-0 completed successfully
Reassignment of partition heima-par-2 completed successfully
Reassignment of partition heima-par-1 completed successfully
```
- 可以看出，分区正在Reassignment的状态是still in progress；如果分区Reassignment完成则completed successfully

kafka-reassign-partitions.sh工具来重新分布分区。该工具有三种使用模式：
- generate模式，给定需要重新分配的Topic，自动生成reassign plan（并不执行）
- execute模式，根据指定的reassign plan重新分配Partition
- verify模式，验证重新分配Partition是否成功

修改副本因子
===

1、配置topic的副本，保存为json文件
```
# cat replication-factor.json
{
"version":1,
"partitions":[
    {"topic":"heima","partition":0,"replicas":[0,1,2]},
    {"topic":"heima","partition":1,"replicas":[0,1,2]},
    {"topic":"heima","partition":2,"replicas":[0,1,2]}
]
}
```

2、执行脚本
```
# kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file replication-factor.json --execute
Current partition replica assignment
{"version":1,"partitions":[{"topic":"topic0703","partition":1,"replicas":[1,0],"log_dirs":["any","any"]},{"topic":"topic0703","partition":0,"replicas":[0,1],"log_dirs":["any","any"]},{"topic":"topic0703","partition":2,"replicas":[2,0],"log_dirs":["any","any"]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started reassignment of partitions.
```

3、验证
```
# kafka-topics.sh --describe --zookeeper localhost:2181 --topic topic0703
Topic:topic0703 PartitionCount:3    ReplicationFactor:3   Configs:
Topic: topic0703    Partition: 0  Leader: 0    Replicas: 0,1,2 Isr: 0,1
Topic: topic0703    Partition: 1  Leader: 1    Replicas: 0,1,2 Isr: 1,0
Topic: topic0703    Partition: 2  Leader: 2    Replicas: 0,1,2 Isr: 2,0
```
