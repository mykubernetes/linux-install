1、查看消费组
```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
group.demo
```

2、查看消费组详情
```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group group.demo
TOPIC      PARTITION CURRENT-OFFSET LOG-END-OFFSET LAG      CONSUMER-ID                                      HOST        CLIENT-ID
heima      0         0              0              0        consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1
heima      1         0              0              0        consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1
heima      2         0              0              0        consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1
```

3、列出还在消费者分组中还存活的成员
```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group group.demo --members
CONSUMER-ID                                      HOST        CLIENT-ID        #PARTITIONS
consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1       2
consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1       1
consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1       0
```

4、列出每个分区上面对应的topic信息
```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group group.demo --members --verbose
CONSUMER-ID                                      HOST        CLIENT-ID        #PARTITIONS     ASSIGNMENT
consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1       2               topic1(0), topic2(0)
consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1       1               topic3(0)
consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1       0               topic2(2), topic3(0,1)
```

5、查看消费组当前的状态
```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group group.demo --state
COORDINATOR (ID)                    ASSIGNMENT-STRATEGY     STATE        #MEMBERS
Server-node.localdomain:9092 (0)    range                   Stable       1
```

6、消费组内成员信息
```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group group.demo --members
CONSUMER-ID                                     HOST         CLIENT-ID   #PARTITIONS
consumer-1-38efa901-4917-4660-ab66-3e5b989cbac3 /127.0.0.1   consumer-1  3
```

7、删除消费组，如果有消费者在使用则会失败
```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --delete --group group.demo
Error: Deletion of some consumer groups failed:
* Group 'group.demo' could not be deleted due to:
java.util.concurrent.ExecutionException:
org.apache.kafka.common.errors.GroupNotEmptyException: The group is not empty.
```

8、消费位移管理

重置消费位移，前提是没有消费者在消费，提示信息如下
```
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group group.demo --all-topics --reset-offsets --to-earliest --execute
Error: Assignments can only be reset if the group 'group.demo' is inactive, but the current state is Stable.
TOPIC             PARTITION NEW-OFFSET
```
- --all-topics指定了所有主题，可以修改为--topics，指定单个主题。
