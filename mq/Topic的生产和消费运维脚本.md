# 1.Topic的发送kafka-console-producer.sh

## 1.1 生产无key消息
```
## 生产者
bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test --producer.config config/producer.properties
```

## 1.2 生产有key消息
加上属性--property parse.key=true
```
## 生产者
bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test --producer.config config/producer.properties  --property parse.key=true
```
**默认消息key与消息value间使用“Tab键”进行分隔，所以消息key以及value中切勿使用转义字符(\t)**

可选参数

| 参数 | 值类型 | 说明 | 有效值 |
|------|-------|------|--------|
| –bootstrap-server | String | 要连接的服务器必需(除非指定–broker-list) | 如：host1:prot1,host2:prot2 |
| –topic | String | (必需)接收消息的主题名称 | |
| –batch-size | Integer | 单个批处理中发送的消息数 | 200(默认值) |
| –compression-codec | String | 压缩编解码器 | none、gzip(默认值)snappy、lz4、zstd |
| –max-block-ms | Long | 在发送请求期间，生产者将阻止的最长时间 | 60000(默认值) |
| –max-memory-bytes | Long | 生产者用来缓冲等待发送到服务器的总内存 | 33554432(默认值) |
| –max-partition-memory-bytes | Long | 为分区分配的缓冲区大小 | 16384 |
| –message-send-max-retries | Integer | 最大的重试发送次数 | 3 |
| –metadata-expiry-ms	Long | 强制更新元数据的时间阈值(ms) | 300000 |
| –producer-property | String | 将自定义属性传递给生成器的机制 | 如：key=value |
| –producer.config | String | 生产者配置属性文件[–producer-property]优先于此配置 配置文件完整路径 | |
| –property | String | 自定义消息读取器 | parse.key=true/false key.separator=<key.separator>ignore.error=true/false |
| –request-required-acks | String | 生产者请求的确认方式 | 0、1(默认值)、all |
| –request-timeout-ms | Integer | 生产者请求的确认超时时间 | 1500(默认值) |
| –retry-backoff-ms | Integer	生产者重试前，刷新元数据的等待时间阈值 | 100(默认值) |
| –socket-buffer-size | Integer | TCP接收缓冲大小 | 102400(默认值) |
| –timeout | Integer | 消息排队异步等待处理的时间阈值 | 1000(默认值) |
| –sync | 同步发送消息 | |
| –version | 显示 Kafka 版本 | 不配合其他参数时，显示为本地Kafka版本 |
| –help | 打印帮助信息 |  |

# 2. Topic的消费kafka-console-consumer.sh

## 1. 新客户端从头消费--from-beginning (注意这里是新客户端,如果之前已经消费过了是不会从头消费的)
下面没有指定客户端名称,所以每次执行都是新客户端都会从头消费
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

## 2. 正则表达式匹配topic进行消费--whitelist
消费所有的topic
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --whitelist ‘.*’
```

消费所有的topic，并且还从头消费
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --whitelist ‘.*’ --from-beginning
```

## 3.显示key进行消费--property print.key=true
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --property print.key=true
```

## 4. 指定分区消费--partition 指定起始偏移量消费--offset
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --partition 0 --offset 100
```

## 5. 给客户端命名--group

注意给客户端命名之后,如果之前有过消费，那么--from-beginning 就不会再从头消费了
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --group test-group
```

## 6. 添加客户端属性--consumer-property

这个参数也可以给客户端添加属性,但是注意 不能多个地方配置同一个属性,他们是互斥的;比如在下面的基础上还加上属性--group test-group 那肯定不行
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --consumer-property group.id=test-consumer-group
```

## 7. 添加客户端属性--consumer.config

跟--consumer-property 一样的性质,都是添加客户端的属性,不过这里是指定一个文件,把属性写在文件里面, --consumer-property 的优先级大于 --consumer.config
```
sh bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --consumer.config config/consumer.properties
```

| 参数 | 描述 | 例子 |
|------|-----|------|
| --group | 指定消费者所属组的ID |  |
| --topic | 被消费的topic |  |
| --partition | 指定分区 ；除非指定–offset，否则从分区结束(latest)开始消费 | --partition 0 |
| --offset | 执行消费的起始offset位置 ;默认值: latest; /latest /earliest /偏移量 | --offset 10 |
| --whitelist | 正则表达式匹配topic；--topic就不用指定了; 匹配到的所有topic都会消费; 当然用了这个参数,--partition --offset等就不能使用了 | |
| --consumer-property | 将用户定义的属性以key=value的形式传递给使用者 | --consumer-property group.id=test-consumer-group |
| --consumer.config | 消费者配置属性文件请注意，[consumer-property]优先于此配置 | --consumer.config config/consumer.properties |
| --property | 初始化消息格式化程序的属性 | print.timestamp=true,false 、print.key=true,false 、print.value=true,false 、key.separator=`<key.separator>`、line.separator=`<line.separator>`、key.deserializer=`<key.deserializer>`、value.deserializer=`<value.deserializer>` |
| --from-beginning | 从存在的最早消息开始，而不是从最新消息开始,注意如果配置了客户端名称并且之前消费过，那就不会从头消费了 |  |
| --max-messages | 消费的最大数据量，若不指定，则持续消费下去 | --max-messages 100 |
| --skip-message-on-error | 如果处理消息时出错，请跳过它而不是暂停 |
| --isolation-level | 设置为read_committed以过滤掉未提交的事务性消息,设置为read_uncommitted以读取所有消息,默认值:read_uncommitted |
| --formatter | kafka.tools.DefaultMessageFormatter、kafka.tools.LoggingMessageFormatter、kafka.tools.NoOpMessageFormatter、kafka.tools.ChecksumMessageFormatter |

# 3. 持续批量推送消息kafka-verifiable-producer.sh

单次发送100条消息--max-messages 100

一共要推送多少条，默认为-1，-1表示一直推送到进程关闭位置
```
sh bin/kafka-verifiable-producer.sh --topic test_create_topic4 --bootstrap-server localhost:9092 --max-messages 100
```

每秒发送最大吞吐量不超过消息 --throughput 100

推送消息时的吞吐量，单位messages/sec。默认为-1，表示没有限制
```
sh bin/kafka-verifiable-producer.sh --topic test_create_topic4 --bootstrap-server localhost:9092 --throughput 100
```

发送的消息体带前缀--value-prefix
```
sh bin/kafka-verifiable-producer.sh --topic test_create_topic4 --bootstrap-server localhost:9092 --value-prefix 666
```
注意 --value-prefix 666必须是整数,发送的消息体的格式是加上一个 点号. 例如： 666.

其他参数：
- --producer.config CONFIG_FILE 指定producer的配置文件
- --acks ACKS 每次推送消息的ack值，默认是-1

# 4. 持续批量拉取消息kafka-verifiable-consumer

持续消费
```
sh bin/kafka-verifiable-consumer.sh --group-id test_consumer --bootstrap-server localhost:9092 --topic test_create_topic4
```

单次最大消费10条消息--max-messages 10
```
sh bin/kafka-verifiable-consumer.sh --group-id test_consumer --bootstrap-server localhost:9092 --topic test_create_topic4 --max-messages 10
```

相关可选参数

| 参数 | 描述 | 例子 |
|------|-----|------|
| --bootstrap-server | 指定kafka服务	指定连接到的kafka服务; | –bootstrap-server localhost:9092 |
| --topic | 指定消费的topic |  |
| --group-id | 消费者id；不指定的话每次都是新的组id |  |
| --group-instance-id | 消费组实例ID,唯一值 |  |
| --max-messages | 单次最大消费的消息数量 |  |
| --enable-autocommit | 是否开启offset自动提交；默认为false |  |
| --reset-policy | 当以前没有消费记录时，选择要拉取offset的策略，可以是earliest, latest,none。默认是earliest | |
| --assignment-strategy | consumer分配分区策略，默认是org.apache.kafka.clients.consumer.RangeAssignor | |
| --consumer.config | 指定consumer的配置文件 | |

[【kafka运维】Kafka全网最全最详细运维命令合集(精品强烈建议收藏!!!)_石臻臻的杂货铺-CSDN博客](https://blog.csdn.net/u010634066/article/details/118215928?spm=1001.2014.3001.5501)

[【kafka实战】分区重分配可能出现的问题和排查问题思路(生产环境实战,干货!!!非常干!!!建议收藏)](https://blog.csdn.net/u010634066/article/details/118631272?spm=1001.2014.3001.5501)

[【kafka异常】kafka 常见异常处理方案(持续更新! 建议收藏)](https://blog.csdn.net/u010634066/article/details/118105676?spm=1001.2014.3001.5501)

[【kafka运维】分区从分配、数据迁移、副本扩缩容 (附教学视频)](https://blog.csdn.net/u010634066/article/details/118028403?spm=1001.2014.3001.5501)

[【kafka源码】ReassignPartitionsCommand源码分析(副本扩缩、数据迁移、副本重分配、副本跨路径迁移](https://blog.csdn.net/u010634066/article/details/118051963)

[【kafka】点击更多…](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=Mzg4ODY1NTcxNg==&action=getalbum&album_id=1966026980307304450#wechat_redirect)

参考：
- https://blog.csdn.net/u010634066/article/details/119327126
