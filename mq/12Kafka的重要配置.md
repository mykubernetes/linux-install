# broker配置

- 官网查看地址：http://kafka.apache.org/082/documentation.html#brokerconfigs

| 配置项 | 说明 |
|-------|------|
| broker.id | Kafka服务器的编号，同一个集群不同节点的编号应该唯一 |
| zookeeper.connect | 连接ZooKeeper的地址，不同Kafka集群如果连接到同一个ZooKeeper，应该使用不同的chroot路径 |
| auto.create.topics.enable | 自动创建主题，默认为true |
| auto.leader.rebalance.enable | 开启主副本自动平衡，当节点宕机后，会影响这个节点上的主副本转移到其他节点，宕机的节点重启后只能作为备份副本，如果开启平衡，则会将主副本转移到原节点 |
| delete.topic.enable | 自动删除主题，默认为false，通过delete命令删除主题，并不会物理删除，只有开启该选项才会真正删除主题的日志文件 |
| log.dirs | 日志文件的目录，可以指定多个目录。默认是/tmp/kafka-logs |
| log.flush.interval.messages | 在消息集刷写到磁盘之前需要收集的消息数量，默认值为Long.MAX |
| log.flush.scheduler.interval.ms | 日志刷新线程过久，检查一次是否有日志文件需要刷写到磁盘，默认值为Long.MAX。 |
| log.retention.bytes | 日志文件超过最大大小时删除旧数据，默认值为-1，即永不会删除 |
| log.retention.hours | 日志文件保留的时间，默认为168小时，即7天 |
| log.segment.bytes | 单个日志文件片段的最大值，默认为1 GB，日志超过1 GB后会刷写到磁盘 |
| message.max.bytes | 服务端接收的消息最大值，默认为1 MB，即一批消息最大不能超过1 MB |
| min.insync.replicas | 当生产者的应答策略设置为all时，写操作的数量必须满足该值才算成功。默认值为1，表示只要写到一个节点就算成功 |
| offsets.commit.required.acks | 消费者提交偏移量和生产者写消息的行为类似，用应答来表示写操作是否成功，默认值为-1 |
| offsets.commit.timeout.ms | 类似于生产者的请求超时时间，写请求会被延迟，默认5秒 |
| offsets.topic.num.partitions | 消费者提交偏移量内部主题的分区数量，默认为50个 |
| offsets.topic.replication.factor | 消费者提交偏移量内部主题的副本数量，默认为3个 |
| replica.fetch.min.bytes | 每个拉取请求最少要拉取的字节数量，默认为1byte。 |
| replica.fetch.wait.max.ms | 每个拉取请求的最大等待时间，默认为500毫秒 |
| replica.lag.time.max.ms | 备份副本在指定时间内都没有发送拉取请求，或者在这个时间内仍然没有赶上主副本，它将会被从ISR中移除，默认10秒 |
| request.timeout.ms | 客户端从发送请求到接收响应的超时时间，默认30秒 |
| zookeeper.session.timeout.ms | ZooKeeper会话的超时时间，默认6秒 |
| default.replication.factor | 自动创建的主题的副本数，默认为1个 |
| log.cleaner.delete.retention.ms | 被删除的记录保存的时间，默认为1天 |
| log.cleaner.enable | 是否开启日志清理线程，当清理策略为compact时，建议开启 |
| log.index.interval.bytes | 添加1条索引到日志文件的间隔，默认为4096条 |
| log.index.size.max.bytes | 索引文件的最大大小，默认为10 MB |
| num.partitions | 每个主题的分区数量，默认为1个 |
| replica.fetch.max.bytes | 拉取请求中每个分区的消息最大值，默认为1 MB |
| replica.fetch.response.max.bytes | 整个拉取请求的消息最大值，默认为10 MB |

```
broker.id 0                           #非负整数，用于唯一标识broker
log.dirs /tmp/kafka-logs              #kafka持久化数据存储的路径，可以指定多个，以逗号分隔
port 9092                             #broker接收连接请求的端口
zookeeper.connect                     #指定zk连接字符串，[hostname:port]以逗号分隔
message.max.bytes 1000000             #单条消息最大大小控制，消费端的最大拉取大小需要略大于该值
num.network.threads 3                 #接收网络请求的线程数
num.io.threads 8                      #用于执行请求的I/O线程数
background.threads 10                 #用于各种后台处理任务（如文件删除）的线程数
queued.max.requests 500               #待处理请求最大可缓冲的队列大小
host.name                             #配置该机器的IP地址
num.partitions  1                     #默认分区个数，配置n，表示可以划分log的数量，进行多线程的读取，挺高效率
log.segment.bytes 1024 * 1024 * 1024  #分段文件大小，超过后会轮转
log.roll.{ms,hours}   168             #日志没达到大小，如果达到这个时间也会轮转
log.retention.{ms,minutes,hours}      #日志保留时间
auto.create.topics.enable true        #不存在topic的时候是否自动创建
default.replication.factor 1          #partition默认的备份因子
replica.lag.time.max.ms   10000       #如果这个时间内follower没有发起fetch请求，被认为dead，从ISR移除
replica.lag.max.messages  4000        #如果follower相比leader落后这么多以上消息条数，会被从ISR移除
replica.fetch.max.bytes 1024 * 1024   #从leader可以拉取的消息最大大小
num.replica.fetchers 1                #从leader拉取消息的fetch线程数
zookeeper.session.timeout.ms  6000    #zk会话超时时间
zookeeper.connection.timeout.ms       #zk连接所用时间
zookeeper.sync.time.ms 2000           #zk follower落后leader的时间
delete.topic.enable false             #是否开启topic可以被删除的方式
```

# producer配置

- 官方查看地址：http://kafka.apache.org/082/documentation.html#producerconfigs

| 配置项 | 说明 |
|-------|------|
| bootstrap.servers | 生产者客户端连接Kafka集群的地址和端口，多个节点用逗号分隔 |
| acks | 生产者请求要求主副本收到的应答数量满足后，写请求才算成功。0表示记录添加到网络缓冲区后就认为已经发送，生产者不会等待服务端的任何应答；1表示主副本会将记录到本地日志文件，但不会等待任何备份副本的应答；-1或all表示主副本必须等待ISR中所有副本都返回应答给它 |
| retries | 发送时出现短暂的错误或者收到错误码，客户端会重新发送记录。如果max.in.flight.requests.per.connection没有设置为1，在异常重试时，服务端收到的记录可能是乱序的 |
| buffer.memory | 生产者发送记录给服务端在客户端的缓冲区，默认为32 MB |
| batch.size | 当多条记录发送到同一个分区，生产者会尝试将一批记录分成更少的请求，来提高客户端和服务端的性能，默认每一个Batch的大小为16 KB。如果一条记录就超过了16 KB，则这条记录不会和其他记录组成Batch。Batch太小会减小吞吐量，Batch太大会占用太多的内存 |
| max.request.size | 一个请求的最大值，实际上也是记录的最大值。注意服务端关于记录的最大值（Broker的message.max.bytes，或者Topic的max.message.bytes）可能和它不同（实际上默认值都是1 MB）。这个配置项会限制生产者一个请求中Batch的记录数，防止发送过大的请求 |
| partitioner.class | 消息的分区语义，对消息进行路由到指定的分区，实现分区接口 |
| request.timeout.ms | 客户端等待一个请求的响应的最长时间，超时后客户端会重新发送或失败 |
| timeout.ms | 服务端等待备份的应答来达到生产者设置的ack的最长时间，超时后不满足失败 |

```
request.required.acks 0                                   #参与消息确认的broker数量控制，0代表不需要任何确认 1代表需要leader replica确认 -1代表需要ISR中所有进行确认
request.timeout.ms  10000                                 #从发送请求到收到ACK确认等待的最长时间（超时时间）
producer.type sync                                        #设置消息发送模式，默认是同步方式， async异步模式下允许消息累计到一定量或一段时间又另外线程批量发送，吞吐量好但丢失数据风险增大
serializer.class kafka.serializer.DefaultEncoder          #消息序列化类实现方式，默认是byte[]数组形式
partitioner.class kafka.producer.DefaultPartitioner       #kafka消息分区策略实现方式，默认是对key进行hash
compression.codec none                                    #对发送的消息采取的压缩编码方式，有none|gzip|snappy
compressed.topics  null                                   #指定哪些topic的message需要压缩
message.send.max.retries 3                                #消息发送失败的情况下，重试发送的次数 存在消息发送是成功的，只是由于网络导致ACK没收到的重试，会出现消息被重复发送的情况
retry.backoff.ms 100                                      #在开始重新发起metadata更新操作需要等待的时间
topic.metadata.refresh.interval.ms 600 * 1000             #metadata刷新间隔时间，如果负值则失败的时候才会刷新，如果0则每次发送后都刷新，正值则是一种周期行为
queue.buffering.max.ms 5000                               #异步发送模式下，缓存数据的最长时间，之后便会被发送到broker
queue.buffering.max.messages 10000                        #producer端异步模式下最多缓存的消息条数
queue.enqueue.timeout.ms -1                               #0代表队列没满的时候直接入队，满了立即扔弃，-1代表无条件阻塞且不丢弃
batch.num.messages 200                                    #一次批量发送需要达到的消息条数，当然如果queue.buffering.max.ms达到的时候也会被发送
```

# consumer配置

- 官网查看地址:http://kafka.apache.org/082/documentation.html#consumerconfigs

| 配置项 | 说明 |
|-------|------|
| fetch.min.bytes | 拉取请求要求服务端返回的数据最小值，如果服务端的数据量还不够，客户端的请求会一直等待，直到服务端收集到足够的数据才会返回响应给客户端。默认值为1个字节，表示服务端处理的拉取请求数据量只要达到1个字节就立即收到响应，或者因为在等待数据的到达一直没有满足最小值时而超时后，拉取请求也会结束。将该值设置大一点，可以牺牲一些延迟来获取服务端更高的吞吐量 |
| fetch.max.bytes | 服务端对一个拉取请求返回数据的最大值，默认值为50 MB |
| fetch.max.wait.ms | 在没有收集到满足fetch.min.bytes大小的数据之前，服务端对拉取请求的响应会阻塞直到超时，默认500毫秒 |
| group.id | 消费者所述的唯一消费组名称，在使用基于Kafka的偏移量管理策略，或者使用消费组管理协议的订阅方法时，必须指定消费组名称 |
| heartbeat.interval.ms | 使用消费组管理协议时消费者和协调者的心跳间隔，心跳用来确保消费者的会话保持活动的状态，以及当有新消费者加入或消费者离开时可以更容易地进行平衡，该选项必须比session.timeout.ms小，通常设置为不大于它的1/3。默认值为3秒，我们可以将心跳值设置得更低，来更好地控制平衡：需要平衡时，心跳间隔越短就能越快地感知到 |
| max.partition.fetch.bytes | 服务端返回的数据中每个分区的最大值，默认值为1 MB |
| session.timeout.ms | 使用消费组管理协议检测到消费者失败的最大时间，消费者定时地向Broker发送心跳表示处于存活状态。服务端的Broker会记录消费者的心跳时间，如果在指定的会话时间内都没有收到消费者的心跳，Broker会将其从消费组中移除并启动一次平衡 |
| auto.offset.reset | Kafka中没有分区的初始偏移量，消费者任何定位分区位置。earliest表示重置到最旧的位置；latest表示重置到最新的位置，默认值为latest |
| enable.auto.commit | 消费者的偏移量是否会在后台定时地提交，默认值为true |
| auto.commit.interval.ms | 消费者自动提交偏移量的时间间隔，默认值为5秒 |
| max.poll.interval.ms | 使用消费组管理协议时，在调用poll()之间的最大延迟，它设置了消费者在下一次拉取更多记录之前允许的最长停顿时间。如果超时后消费者仍然没有调用poll()，那么消费者就会被认为失败了，就会启动消费组的平衡，默认值为5秒 |
| max.poll.records | 在一次poll()调用中允许返回的最大记录数，默认值为500条 |
| partition.assignment.strategy | 使用消费者管理协议时，消费者实例之间用来进行分区分配的策略，默认值为RangeAssignor |

```
group.id                                              #指明当前消费进程所属的消费组，一个partition只能被同一个消费组的一个消费者消费
fetch.message.max.bytes  1024 * 1024                  #针对一个partition的fetch request所能拉取的最大消息字节数，必须大于等于Kafka运行的最大消息
auto.commit.enable true                               #是否自动周期性提交已经拉取到消费端的消息offset
auto.commit.interval.ms  60 * 1000                    #自动提交offset到zookeeper的时间间隔
rebalance.max.retries  4                              #消费均衡的重试次数
rebalance.backoff.ms 2000                             #消费均衡两次重试之间的时间间隔
refresh.leader.backoff.ms   200                       #当重新去获取partition的leader前需要等待的时间
auto.offset.reset largest                             #如果zookeeper上没有offset合理的初始值情况下获取第一条消息开始的策略smallest|largeset
zookeeper.session.timeout.ms  6000                    #如果其超时，将会可能触发rebalance并认为已经死去
zookeeper.connection.timeout.ms 6000                  #确认zookeeper连接建立操作客户端能等待的最长时间
```

参考：
- https://blog.csdn.net/leegh1992/article/details/70142452
