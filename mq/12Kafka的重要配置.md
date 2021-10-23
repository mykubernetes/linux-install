# broker配置

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

producer配置
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
