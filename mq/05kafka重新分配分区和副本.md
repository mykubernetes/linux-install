# 一、分区重新分配

## 1、条件准备
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

## 2、扩容前准备

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

## 3、重新分配Partition

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

# 二、修改副本因子


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

# 三、kafka对topic leader 进行自动负载均衡


## 1、指定Topic指定分区用重新PREFERRED：优先副本策略 进行Leader重选举
```
# bin/kafka-leader-election.sh --bootstrap-server localhost:9092 --topic test_create_topic4 --election-type PREFERRED --partition 0
```

## 2、所有Topic所有分区用重新PREFERRED：优先副本策略 进行Leader重选举
```
# bin/kafka-leader-election.sh --bootstrap-server localhost:9092 --election-type preferred  --all
```

##  3、设置配置文件批量指定topic和分区进行Leader重选举

在创建一个topic时，kafka尽量将partition均分在所有的brokers上，并且将replicas也j均分在不同的broker上。

每个partitiion的所有replicas叫做”assigned replicas”，”assigned replicas”中的第一个replicas叫”preferred replica”，刚创建的topic一般”preferred replica”是leader。leader replica负责所有的读写。

但随着时间推移，broker可能会停机，会导致leader迁移，导致机群的负载不均衡。我们期望对topic的leader进行重新负载均衡，让partition选择”preferred replica”做为leader。

kafka通过三个参数来控制leader partition的负载均衡
- auto.leader.rebalance.enable 是否开启 默认开启
- leader.imbalance.per.broker.percentage 允许不平衡比例 默认10%
- leader.imbalance.check.interval.seconds 检查leader负载均衡时间间隔 默认300s

1、查看topic详情
```
./kafka-topics.sh --bootstrap-server localhost:9092 --describe  --topic logdata-es

Topic:logdata-es        PartitionCount:6        ReplicationFactor:2     Configs:
        Topic: logdata-es       Partition: 0    Leader: 2       Replicas: 3,2   Isr: 2,3
        Topic: logdata-es       Partition: 1    Leader: 2       Replicas: 5,2   Isr: 2,5
        Topic: logdata-es       Partition: 2    Leader: 1       Replicas: 4,1   Isr: 1,4
        Topic: logdata-es       Partition: 3    Leader: 2       Replicas: 5,2   Isr: 2,5
        Topic: logdata-es       Partition: 4    Leader: 1       Replicas: 1,3   Isr: 1,3
        Topic: logdata-es       Partition: 5    Leader: 2       Replicas: 2,5   Isr: 2,5
```

2、编辑相应topic的json文件
```
vim logdata-es-autu.json
{
 "partitions":
  [
    {"topic": "logdata-es", "partition": 0},
    {"topic": "logdata-es", "partition": 1},
    {"topic": "logdata-es", "partition": 2},
    {"topic": "logdata-es", "partition": 3},
    {"topic": "logdata-es", "partition": 4},
    {"topic": "logdata-es", "partition": 5}
  ]
}
```

3、执行
```
./kafka-preferred-replica-election.sh --bootstrap-server localhost:9092 --path-to-json-file logdata-es-autu.json 

Successfully started preferred replica election for partitions Set([logdata-es,3], [logdata-es,2], [logdata-es,1], [logdata-es,5], [logdata-es,0], [logdata-es,4])
```

4、之后在查看
```
Topic:logdata-es        PartitionCount:6        ReplicationFactor:2     Configs:
        Topic: logdata-es       Partition: 0    Leader: 3       Replicas: 3,2   Isr: 2,3
        Topic: logdata-es       Partition: 1    Leader: 5       Replicas: 5,2   Isr: 2,5
        Topic: logdata-es       Partition: 2    Leader: 4       Replicas: 4,1   Isr: 1,4
        Topic: logdata-es       Partition: 3    Leader: 5       Replicas: 5,2   Isr: 2,5
        Topic: logdata-es       Partition: 4    Leader: 1       Replicas: 1,3   Isr: 1,3
        Topic: logdata-es       Partition: 5    Leader: 2       Replicas: 2,5   Isr: 2,5
```
