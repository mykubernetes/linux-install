# 消费者组管理 kafka-consumer-groups.sh

## 1. 查看消费者列表`--list`
```
sh bin/kafka-consumer-groups.sh --bootstrap-server xxxx:9092 --list
```

## 2. 查看消费者组详情`--describe`

- 查看消费组详情--group 或 --all-groups

查看指定消费组详情--group
```
sh bin/kafka-consumer-groups.sh --bootstrap-server xxxxx:9092 --describe --group test2_consumer_group
```

查看所有消费组详情`--all-groups`
```
sh bin/kafka-consumer-groups.sh --bootstrap-server xxxxx:9092 --describe --all-groups
```
查看该消费组 消费的所有Topic、及所在分区、最新消费offset、Log最新数据offset、Lag还未消费数量、消费者ID等等信息


查询消费者成员信息`--members`

所有消费组成员信息
```
sh bin/kafka-consumer-groups.sh --describe --all-groups --members --bootstrap-server xxx:9092
```

指定消费组成员信息
```
sh bin/kafka-consumer-groups.sh --describe --members --group test2_consumer_group --bootstrap-server xxxx:9092
```


查询消费者状态信息--state

所有消费组状态信息
```
sh bin/kafka-consumer-groups.sh --describe --all-groups --state --bootstrap-server xxxx:9090
```

指定消费组状态信息
```
sh bin/kafka-consumer-groups.sh --describe --state --group test2_consumer_group --bootstrap-server xxxxx:9090
```

## 3. 删除消费者组--delete

删除消费组`–delete`

删除指定消费组`--group`
```
sh bin/kafka-consumer-groups.sh --delete --group test2_consumer_group --bootstrap-server xxxx:9090
```

删除所有消费组--all-groups
```
sh bin/kafka-consumer-groups.sh --delete --all-groups --bootstrap-server xxxx:9090
```

PS: 想要删除消费组前提是这个消费组的所有客户端都停止消费/不在线才能够成功删除;否则会报下面异常
```
Error: Deletion of some consumer groups failed:
* Group 'test2_consumer_group' could not be deleted due to: java.util.concurrent.ExecutionException: org.apache.kafka.common.errors.GroupNotEmptyException: The group is not empty.
```

## 4. 重置消费组的偏移量 --reset-offsets

能够执行成功的一个前提是 消费组这会是不可用状态;

下面的示例使用的参数是: --dry-run ;这个参数表示预执行,会打印出来将要处理的结果;
等你想真正执行的时候请换成参数--excute ;

下面示例 重置模式都是 --to-earliest 重置到最早的;

请根据需要参考下面 相关重置Offset的模式 换成其他模式;

重置指定消费组的偏移量 --group

重置指定消费组的所有Topic的偏移量--all-topic
```
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --group test2_consumer_group --bootstrap-server xxxx:9090 --dry-run --all-topic
```

重置指定消费组的指定Topic的偏移量--topic
```
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --group test2_consumer_group --bootstrap-server xxxx:9090 --dry-run --topic test2
```

重置所有消费组的偏移量 --all-group

重置所有消费组的所有Topic的偏移量--all-topic
```
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --all-group --bootstrap-server xxxx:9090 --dry-run --all-topic
```

重置所有消费组中指定Topic的偏移量--topic
```
sh bin/kafka-consumer-groups.sh --reset-offsets --to-earliest --all-group --bootstrap-server xxxx:9090 --dry-run --topic test2
```

--reset-offsets 后面需要接重置的模式

# 相关重置Offset的模式

| 参数 | 描述 | 例子 |
|------|-----|------|
| --to-earliest | 重置offset到最开始的那条offset(找到还未被删除最早的那个offset) |
| --to-current | 直接重置offset到当前的offset，也就是LOE |
| --to-latest | 置到最后一个offset |
| --to-datetime | 重置到指定时间的offset;格式为:`YYYY-MM-DDTHH:mm:SS.sss` | `--to-datetime "2021-6-26T00:00:00.000"` |
| --to-offset | `重置到指定的offset,但是通常情况下,匹配到多个分区,这里是将匹配到的所有分区都重置到这一个值; 如果 1.目标最大offset<--to-offset, 这个时候重置为目标最大offset；2.目标最小offset>--to-offset ，则重置为最小; 3.否则的话才会重置为--to-offset的目标值; 一般不用这个` | `--to-offset 3465` |
| --shift-by | 按照偏移量增加或者减少多少个offset；正的为往前增加;负的往后退；当然这里也是匹配所有的 | `--shift-by 100` 、`--shift-by -100` |
| --from-file | 根据CVS文档来重置; 这里下面单独讲解 |

- --from-file: 上面其他的一些模式重置的都是匹配到的所有分区; 不能够每个分区重置到不同的offset；不过**--from-file** 可以让我们更灵活一点;

先配置cvs文档

格式为: Topic:分区号: 重置目标偏移量
```
cvs test2,0,100 test2,1,200 test2,2,300
```
2. 执行命令
```
>sh bin/kafka-consumer-groups.sh --reset-offsets --group test2_consumer_group --bootstrap-server xxxx:9090 --dry-run --from-file config/reset-offset.csv
```

5. 删除偏移量delete-offsets
能够执行成功的一个前提是 消费组这会是不可用状态;

偏移量被删除了之后,Consumer Group下次启动的时候,会从头消费;
```
sh bin/kafka-consumer-groups.sh --delete-offsets --group test2_consumer_group2 --bootstrap-server XXXX:9090 --topic test2
```

# 相关可选参数

| 参数 | 描述 | 例子 |
|---|------|----|
| --bootstrap-server | 指定连接到的kafka服务 | –bootstrap-server localhost:9092 |
| --list | 列出所有消费组名称 | --list |
| --describe | 查询消费者描述信息 | --describe |
| --group | 指定消费组 | |
| --all-groups | 指定所有消费组 | |
| --members | 查询消费组的成员信息 | |
| --state | 查询消费者的状态信息 | |
| --offsets | 在查询消费组描述信息的时候,这个参数会列出消息的偏移量信息; 默认就会有这个参数的 | |
| dry-run | 重置偏移量的时候,使用这个参数可以让你预先看到重置情况，这个时候还没有真正的执行,真正执行换成--excute;默认为dry-run | |
| --excute | 真正的执行重置偏移量的操作 | |
| --to-earliest | 将offset重置到最早 | |
| to-latest | 将offset重置到最近 | |


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
