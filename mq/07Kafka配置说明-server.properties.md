# 以下是kafka_2.10-0.8.2.0的server.properties文件

```
############################# Server Basics #############################

# The id of the broker. This must be set to a unique integer for each broker.
broker.id=0
#每一个broker在集群中的唯一表示，要求是正数。当该服务器的IP地址发生改变时，broker.id没有变化，则不会影响consumers的消息情况

# Switch to enable topic deletion or not, default value is false
#delete.topic.enable=true
#能够删除topic（0.10.1.0新增内容）

############################# Socket Server Settings #############################

# The port the socket server listens on
port=9092
#broker server服务端口

# Hostname the broker will bind to. If not set, the server will bind to all interfaces
#host.name=localhost
#broker的主机地址，若是设置了，那么会绑定到这个地址上，若是没有，会绑定到所有的接口上，并将其中之一发送到ZK，一般不设置

# Hostname the broker will advertise to producers and consumers. If not set, it uses the
# value for "host.name" if configured.  Otherwise, it will use the value returned from
# java.net.InetAddress.getCanonicalHostName().
#advertised.host.name=<hostname routable by clients>
#配置返回的host.name值，把这个参数配置为外网IP地址即可。这个参数默认没有启用，默认是返回的java.net.InetAddress.getCanonicalHostName的值。

# The port to publish to ZooKeeper for clients to use. If this is not set,
# it will publish the same port that the broker binds to.
#advertised.port=<port accessible by clients>

注：如果advertised.host.name没有设，会用host.name的值注册到zookeeper，如果host.name也没有设，则会使用JVM拿到的本机hostname注册到zk。

这里有两个坑要注意：
1.如果advertised.host.name没有设，host.name不能设为0.0.0.0，否则client通过zk拿到的broker地址就是0.0.0.0。
如果指定要bind到所有interface，host.name不设就可以。

2.如果host.name和advertised.host.name都不设，client通过zk拿到的就是JVM返回的本机hostname，如果这个hostname是client无法访问到的，client就会连不上broker。
所以如果要bind到所有interface，client又能访问，解决的办法是host.name不设或设置0.0.0.0，advertised.host.name一定要设置为一个client可以访问的地址，如直接设IP地址。


如果不需要bind到所有interface，也可以只在host.name设置IP地址。

简单的检查broker是否可以被client访问到的办法，就是在zookeeper中看broker信息，上面显示的hostname是否是client可以访问到的地址。
在zkCli中执行get /brokers/<id>

扩展：为何producer是配置broker地址而consumer中是配置zookeeper地址？
答：区别的原因是consumer要把consumer group和consumer的信息（主要是分配了哪些topic/partition）注册到zookeeper中，被各个consumer watch，以实现consumer之间的自动均衡。
至于consumer的offset虽然也可能保存在zookeeper上，但不是区别的原因。因为在0.9版本以上，offset也是可以保存到Kafka本身的。

注意：上面这四个配置在0.10.1.0中被下面这两个所替代

# The address the socket server listens on. It will get the value returned from 
# java.net.InetAddress.getCanonicalHostName() if not configured.
#   FORMAT:
#     listeners = security_protocol://host_name:port
#   EXAMPLE:
#     listeners = PLAINTEXT://your.host.name:9092
#listeners=PLAINTEXT://:9092

# Hostname and port the broker will advertise to producers and consumers. If not set, 
# it uses the value for "listeners" if configured.  Otherwise, it will use the value
# returned from java.net.InetAddress.getCanonicalHostName().
#advertised.listeners=PLAINTEXT://your.host.name:9092

# The number of threads handling network requests
num.network.threads=3
#broker处理消息的最大线程数，一般情况下不需要去修改
 
# The number of threads doing disk I/O
num.io.threads=8
#broker处理磁盘IO的线程数，数值应该大于你的硬盘数

# The send buffer (SO_SNDBUF) used by the socket server
socket.send.buffer.bytes=102400
#socket server的发送缓冲区，socket的调优参数SO_SNDBUFF

# The receive buffer (SO_RCVBUF) used by the socket server
socket.receive.buffer.bytes=102400
#socket server的接受缓冲区，socket的调优参数SO_RCVBUFF

# The maximum size of a request that the socket server will accept (protection against OOM)
socket.request.max.bytes=104857600
#socket请求的最大数值，防止serverOOM，message.max.bytes必然要小于socket.request.max.bytes，会被topic创建时的指定参数覆盖

############################# Log Basics #############################

# A comma seperated list of directories under which to store log files
log.dirs=/tmp/kafka-logs
#kafka数据的存放地址，多个地址的话用逗号分割 /data/kafka-logs-1，/data/kafka-logs-2

# The default number of log partitions per topic. More partitions allow greater
# parallelism for consumption, but this will also result in more files across
# the brokers.
num.partitions=1
#每个topic的分区个数，若是在topic创建时候没有指定的话会被topic创建时的指定参数覆盖

# The number of threads per data directory to be used for log recovery at startup and flushing at shutdown.
# This value is recommended to be increased for installations with data dirs located in RAID array.
num.recovery.threads.per.data.dir=1
#每个数据目录用来日志恢复的线程数目

############################# Log Flush Policy #############################

# Messages are immediately written to the filesystem but by default we only fsync() to sync
# the OS cache lazily. The following configurations control the flush of data to disk. 
# There are a few important trade-offs here:
#    1. Durability: Unflushed data may be lost if you are not using replication.
#    2. Latency: Very large flush intervals may lead to latency spikes when the flush does occur as there will be a lot of data to flush.
#    3. Throughput: The flush is generally the most expensive operation, and a small flush interval may lead to exceessive seeks. 
# The settings below allow one to configure the flush policy to flush data after a period of time or
# every N messages (or both). This can be done globally and overridden on a per-topic basis

# The number of messages to accept before forcing a flush of data to disk
#log.flush.interval.messages=10000
#log文件”sync”到磁盘之前累积的消息条数,因为磁盘IO操作是一个慢操作,但又是一个”数据可靠性"的必要手段,所以此参数的设置,需要在"数据可靠性"与"性能"之间做必要的权衡.如果此值过大,将会导致每次"fsync"的时间较长(IO阻塞),如果此值过小,将会导致"fsync"的次数较多,这也意味着整体的client请求有一定的延迟.物理server故障,将会导致没有fsync的消息丢失.

# The maximum amount of time a message can sit in a log before we force a flush
#log.flush.interval.ms=1000
#仅仅通过interval来控制消息的磁盘写入时机,是不足的.此参数用于控制"fsync"的时间间隔,如果消息量始终没有达到阀值,但是离上一次磁盘同步的时间间隔达到阀值,也将触发.

############################# Log Retention Policy #############################

# The following configurations control the disposal of log segments. The policy can
# be set to delete segments after a period of time, or after a given size has accumulated.
# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens
# from the end of the log.

# The minimum age of a log file to be eligible for deletion
log.retention.hours=168（7 days）
#每个日志文件删除之前保存的时间。默认数据保存时间对所有topic都一样。log.retention.minutes和log.retention.bytes都是用来设置删除日志文件的，无论哪个属性已经溢出。这个属性设置可以在topic基本设置时进行覆盖。

# A size-based retention policy for logs. Segments are pruned from the log as long as the remaining
# segments don't drop below log.retention.bytes.
#log.retention.bytes=1073741824
#每个topic下每个partition保存数据的总量；注意，这是每个partitions的上限，因此这个数值乘以partitions的个数就是每个topic保存的数据总量。同时注意：如果log.retention.hours和log.retention.bytes都设置了，则超过了任何一个限制都会造成删除一个段文件。这项设置可以由每个topic设置时进行覆盖。

# The maximum size of a log segment file. When this size is reached a new log segment will be created.
log.segment.bytes=1073741824（1024*1024*1024）
#topic  partition的日志存放在某个目录下诸多文件中，这些文件将partition的日志切分成一段一段的；这个属性就是每个文件的最大尺寸；当尺寸达到这个数值时，就会创建新文件。此设置可以由每个topic基础设置时进行覆盖。

# The interval at which log segments are checked to see if they can be deleted according 
# to the retention policies
log.retention.check.interval.ms=300000（5 minutes）
#检查日志分段文件的间隔时间，以确定是否文件属性是否到达删除要求。

# By default the log cleaner is disabled and the log retention policy will default to just delete segments after their retention expires.
# If log.cleaner.enable=true is set the cleaner will be enabled and individual logs can then be marked for log compaction.
log.cleaner.enable=false
#当这个属性设置为false时，一旦日志的保存时间或者大小达到上限时，就会被删除；如果设置为true，则当保存属性达到上限时，就会进行log compaction。

############################# Zookeeper #############################

# Zookeeper connection string (see zookeeper docs for details).
# This is a comma separated host:port pairs, each corresponding to a zk
# server. e.g. "127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002".
# You can also append an optional chroot string to the urls to specify the
# root directory for all kafka znodes.
zookeeper.connect=localhost:2181
#指定zookeeper的连接的字符串，格式是hostname：port，此处host和port都是zookeeper server的host和port，为避免某个zookeeper 机器宕机之后失联，你可以指定多个hostname：port，使用逗号作为分隔：hostname1：port1，hostname2：port2，hostname3：port3
#可以在zookeeper连接字符串中加入zookeeper的chroot路径，此路径用于存放他自己的数据，方式：hostname1：port1，hostname2：port2，hostname3：port3/chroot/path

# Timeout in ms for connecting to zookeeper
zookeeper.connection.timeout.ms=6000
#客户端在建立通zookeeper连接中的最大等待时间


补充：在这个配置文件中并没有列出却可以配置的项（后来越整越多，头都大了，感觉有好多根本就没必要知道啊。。。）

bootstrap.servers=master:9092,slave1:9092,slave2:9092
#用于建立与kafka集群连接的host/port组。数据将会在所有servers上均衡加载，不管哪些server是指定用于bootstrapping。这个列表仅仅影响初始化的hosts（用于发现全部的servers）。这个列表格式：host1:port1,host2:port2,…因为这些server仅仅是用于初始化的连接，以发现集群所有成员关系（可能会动态的变化），这个列表不需要包含所有的servers（你可能想要不止一个server，尽管这样，可能某个server宕机了）。如果没有server在这个列表出现，则发送数据会一直失败，直到列表可用。

acks=-1
#producer需要server接收到数据之后发出的确认接收的信号，此项配置就是指procuder需要多少个这样的确认信号。此配置实际上代表了数据备份的可用性。以下设置为常用选项：（1）acks=0：设置为0表示producer不需要等待任何确认收到的信息。副本将立即加到socket buffer并认为已经发送。没有任何保障可以保证此种情况下server已经成功接收数据，同时重试配置不会发生作用（因为客户端不知道是否失败）回馈的offset会总是设置为-1；（2）acks=1：这意味着至少要等待leader已经成功将数据写入本地log，但是并没有等待所有follower是否成功写入。这种情况下，如果follower没有成功备份数据，而此时leader又挂掉，则消息会丢失。（3）acks=all：这意味着leader需要等待所有备份都成功写入日志，这种策略会保证只要有一个备份存活就不会丢失数据。这是最强的保证。

retries=0
#设置大于0的值将使客户端重新发送任何数据，一旦这些数据发送失败。注意，这些重试与客户端接收到发送错误时的重试没有什么不同。允许重试将潜在的改变数据的顺序，如果这两个消息记录都是发送到同一个partition，则第一个消息失败第二个发送成功，则第二条消息会比第一条消息出现要早。

batch.size=16384
#producer将试图批处理消息记录，以减少请求次数。这将改善client与server之间的性能。这项配置控制默认的批量处理消息字节数。不会试图处理大于这个字节数的消息字节数。发送到brokers的请求将包含多个批量处理，其中会包含对每个partition的一个请求。较小的批量处理数值比较少用，并且可能降低吞吐量（0则会仅用批量处理）。较大的批量处理数值将会浪费更多内存空间，这样就需要分配特定批量处理数值的内存大小。

compression.type=none
#producer用于压缩数据的压缩类型。默认是无压缩。正确的选项值是none、gzip、snappy。压缩最好用于批量处理，批量处理消息越多，压缩性能越好

buffer.memory=33554432
#producer可以用来缓存数据的内存大小。如果数据产生速度大于向broker发送的速度，producer会阻塞或者抛出异常，以“block.on.buffer.full”来表明。这项设置将和producer能够使用的总内存相关，但并不是一个硬性的限制，因为不是producer使用的所有内存都是用于缓存。一些额外的内存会用于压缩（如果引入压缩机制），同样还有一些用于维护请求。

key.serializer
#key的序列化方式，若是没有设置，同serializer.class。实现Serializer接口的class

value.serializer
#value序列化类方式。实现Serializer接口的class

max.block.ms=60000
#控制block的时长,当buffer空间不够或者metadata丢失时产生block

max.request.size=1048576
#请求的最大字节数。这也是对最大记录尺寸的有效覆盖。注意：server具有自己对消息记录尺寸的覆盖，这些尺寸和这个设置不同。此项设置将会限制producer每次批量发送请求的数目，以防发出巨量的请求。

receive.buffer.bytes=32768
#socket的接收缓存空间大小,当阅读数据时使用
send.buffer.bytes=131072
#发送数据时的缓存空间大小
注：不知道和上面的socket.receive.buffer.bytes和socket.send.buffer.bytes参数是否是一回事，有待以后进行考证（我感觉是一回事，有可能不同版本写法不同吧）

max.in.flight.requests.per.connection=5
#kafka可以在一个connection中发送多个请求，叫作一个flight,这样可以减少开销，但是如果产生错误，可能会造成数据的发送顺序改变,默认是5

metadata.fetch.timeout.ms=60000
#是指我们所获取的一些元素据的第一个时间数据。元素据包含：topic，host，partitions。此项配置是指当等待元素据fetch成功完成所需要的时间，否则会跑出异常给客户端

metadata.max.age.ms=300000
#以微秒为单位的时间，是在我们强制更新metadata的时间间隔。即使我们没有看到任何partition leadership改变。

metric.reporters=none
#类的列表，用于衡量指标。实现MetricReporter接口，将允许增加一些类，这些类在新的衡量指标产生时就会改变。JmxReporter总会包含用于注册JMX统计

metrics.num.samples=2
#用于维护metrics的样本数

metrics.sample.window.ms=30000
#metrics系统维护可配置的样本数量，在一个可修正的window size。这项配置配置了窗口大小，例如。我们可能在30s的期间维护两个样本。当一个窗口推出后，我们会擦除并重写最老的窗口

reconnect.backoff.ms=10
#连接失败时，当我们重新连接时的等待时间。这避免了客户端反复重连

retry.backoff.ms=100
#在试图重试失败的produce请求之前的等待时间。避免陷入发送-失败的死循环中


message.max.bytes=1000000
#server可以接收的消息最大尺寸。重要的是，consumer和producer有关这个属性的设置必须同步，否则producer发布的消息对consumer来说太大。

max.connections.per.ip=Int.MaxValue
#每个ip地址上每个broker可以被连接的最大数目

max.connections.per.ip.overrides=
#每个ip或者hostname默认的连接的最大覆盖

background.threads=4
#一些后台任务处理的线程数，例如过期消息文件的删除等，一般情况下不需要去做修改

queued.max.requests=500
#在网络线程停止读取新请求之前，可以排队等待I/O线程处理的最大请求个数。

linger.ms=0
#producer组将会汇总任何在请求与发送之间到达的消息记录一个单独批量的请求。通常来说，这只有在记录产生速度大于发送速度的时候才能发生。然而，在某些条件下，客户端将希望降低请求的数量，甚至降低到中等负载一下。这项设置将通过增加小的延迟来完成–即，不是立即发送一条记录，producer将会等待给定的延迟时间以允许其他消息记录发送，这些消息记录可以批量处理。这可以认为是TCP种Nagle的算法类似。这项设置设定了批量处理的更高的延迟边界：一旦我们获得某个partition的batch.size，他将会立即发送而不顾这项设置，然而如果我们获得消息字节数比这项设置要小的多，我们需要“linger”特定的时间以获取更多的消息。 这个设置默认为0，即没有延迟。设定linger.ms=5，例如，将会减少请求数目，但是同时会增加5ms的延迟。

log.roll.hours=24*7
#即使文件没有到达log.segment.bytes，只要文件创建时间到达此属性，就会创建新文件。这个设置也可以有topic层面的设置进行覆盖；

log.roll.jitter.{ms,hours}=0
#从logRollTimeMillis抽离的jitter最大数目

log.cleanup.policy=delete
#日志清理策略选择有：delete和compact主要针对过期数据的处理，或是日志文件达到限制的额度，会被topic创建时的指定参数覆盖

log.cleaner.threads=1
#进行日志压缩的线程数

log.cleaner.io.max.bytes.per.second=None
#日志压缩时候处理的最大大小

log.cleaner.dedupe.buffer.size=500*1024*1024
#日志压缩去重时候的缓存空间，在空间允许的情况下，越大越好

log.cleaner.io.buffer.size=512*1024
#日志清理时候用到的IO块大小，一般不需要修改

log.cleaner.io.buffer.load.factor =0.9
#日志清理中hash表的扩大因子，一般不需要修改

log.cleaner.backoff.ms=15000
#检查是否处罚日志清理的间隔

log.cleaner.min.cleanable.ratio=0.5
#日志清理的频率控制，越大意味着更高效的清理，同时会存在一些空间上的浪费，会被topic创建时的指定参数覆盖

log.cleaner.delete.retention.ms=1day
#对于压缩的日志保留的最长时间，也是客户端消费消息的最长时间，同log.retention.minutes的区别在于一个控制未压缩数据，一个控制压缩后的数据。会被topic创建时的指定参数覆盖

log.index.size.max.bytes=10*1024*1024
#对于segment日志的索引文件大小限制，会被topic创建时的指定参数覆盖

log.index.interval.bytes=4096
#当执行一个fetch操作后，需要一定的空间来扫描最近的offset大小，设置越大，代表扫描速度越快，但是也更废内存，一般情况下不需要搭理这个参数

log.flush.scheduler.interval.ms=3000
#检查是否需要固化到硬盘的时间间隔

log.delete.delay.ms=60000
#文件在索引中清除后保留的时间一般不需要去修改

log.flush.offset.checkpoint.interval.ms=60000
#控制上次固化硬盘的时间点，以便于数据恢复一般不需要去修改

auto.create.topics.enable=true
#是否允许自动创建topic，若是false，就需要通过命令创建topic

auto.leader.rebalance.enable=true
#如果这是true，控制者将会自动平衡brokers对于partitions的leadership

auto.commit.enable=true
#如果为真，consumer所fetch的消息的offset将会自动的同步到zookeeper。这项提交的offset将在进程挂掉时，由新的consumer使用

auto.commit.interval.ms=60*1000
#consumer向zookeeper提交offset的频率，单位是秒

auto.offset.reset=largest
#zookeeper中没有初始化的offset时，如果offset是以下值的回应：
#smallest：自动复位offset为smallest的offset
#largest：自动复位offset为largest的offset
#anything  else：向consumer抛出异常

queued.max.message.chunks=2
#用于缓存消息的最大数目，以供consumption。每个chunk必须和fetch.message.max.bytes相同

rebalance.max.retries=4
#当新的consumer加入到consumer  group时，consumers集合试图重新平衡分配到每个consumer的partitions数目。如果consumers集合改变了，当分配正在执行时，这个重新平衡会失败并重入

default.replication.factor=1
#副本的个数

rebalance.backoff.ms=2000
#在重试reblance之前backoff时间

refresh.leader.backoff.ms=200
#在试图确定某个partition的leader是否失去他的leader地位之前，需要等待的backoff时间

replica.lag.time.max.ms=10000
#replicas响应partition leader的最长等待时间，若是超过这个时间，就将replicas列入ISR(in-sync replicas)，并认为它是死的，不会再加入管理中

replica.lag.max.messages=4000
#如果follower落后与leader太多,将会认为此follower[或者说partition relicas]已经失效
#通常,在follower与leader通讯时,因为网络延迟或者链接断开,总会导致replicas中消息同步滞后
#如果消息之后太多,leader将认为此follower网络延迟较大或者消息吞吐能力有限,将会把此replicas迁移到其他follower中.
#在broker数量较少,或者网络不足的环境中,建议提高此值.

replica.socket.timeout.ms=30*1000
#follower与leader之间的socket超时时间

replica.socket.receive.buffer.bytes=64*1024
#leader复制时候的socket缓存大小

replica.fetch.max.bytes=1024*1024
#replicas每次获取数据的最大大小

replica.fetch.wait.max.ms=500
#replicas同leader之间通信的最大等待时间，失败了会重试

replica.fetch.min.bytes=1
#fetch的最小数据尺寸,如果leader中尚未同步的数据不足此值,将会阻塞,直到满足条件

num.replica.fetchers=1
#leader进行复制的线程数，增大这个数值会增加follower的IO

replica.high.watermark.checkpoint.interval.ms=5000
#每个replica检查是否将最高水位进行固化的频率

fetch.purgatory.purge.interval.requests=1000
#fetch请求清除时的清除间隔

producer.purgatory.purge.interval.requests=1000
#producer请求清除时的清除间隔

controller.socket.timeout.ms=30000
#partition leader与replicas之间通讯时,socket的超时时间

controller.message.queue.size=10
#partition leader与replicas数据同步时,消息的队列尺寸

controlled.shutdown.enable=false
#是否允许控制器关闭broker,若是设置为true,会关闭所有在这个broker上的leader，并转移到其他broker

controlled.shutdown.max.retries=3
#控制器关闭的尝试次数

controlled.shutdown.retry.backoff.ms=5000
#每次关闭尝试的时间间隔

connections.max.idle.ms=600000
#空连接的超时限制

consumer.timeout.ms=-1
#如果没有消息可用，即使等待特定的时间之后也没有，则抛出超时异常

consumer.id
#不需要设置，一般自动产生

exclude.internal.topics=true
#是否将内部topics的消息暴露给consumer

paritition.assignment.strategy=range
#选择向consumer 流分配partitions的策略，可选值：range，roundrobin

leader.imbalance.per.broker.percentage=10
#leader的不平衡比例，若是超过这个数值，会对分区进行重新的平衡

leader.imbalance.check.interval.seconds=300
#检查leader是否不平衡的时间间隔

offset.metadata.max.bytes=4096
#允许客户端保存他们offsets的最大个数

offsets.topic.num.partitions=50
#The number of partitions for the offset commit topic. Since changing this after deployment is currently unsupported, we recommend using a higher setting for production (e.g., 100-200).

offsets.topic.retention.minutes=1440
#存在时间超过这个时间限制的offsets都将被标记为待删除

offsets.retention.check.interval.ms=600000
#offset管理器检查陈旧offsets的频率

offsets.topic.replication.factor=3
#topic的offset的备份份数。建议设置更高的数字保证更高的可用性

offset.topic.segment.bytes=104857600
#offsets topic的segment尺寸。

offsets.load.buffer.size=5242880
#这项设置与批量尺寸相关，当从offsets segment中读取时使用。

offsets.commit.required.acks=-1
#在offset  commit可以接受之前，需要设置确认的数目，一般不需要更改

offset.channel.backoff.ms=1000
#重新连接offsets channel或者是重试失败的offset的fetch/commit请求的backoff时间

offsets.channel.socket.timeout.ms=10000
#当读取offset的fetch/commit请求回应的socket超时限制。此超时限制是被consumerMetadata请求用来请求offset管理

offsets.commit.max.retries=5
#在offset commit可以接受之前，需要设置确认的数目，一般不需要更改

offsets.storage=zookeeper
#用于存放offsets的地点：zookeeper或者kafka

dual.commit.enabled=true
#如果使用“kafka”作为offsets.storage，你可以二次提交offset到zookeeper(还有一次是提交到kafka）。在zookeeper-based的offset storage到kafka-based的offset storage迁移时，这是必须的。对任意给定的consumer group来说，比较安全的建议是当完成迁移之后就关闭这个选项

unclean.leader.election.enable=true
#指明了是否能够使不在ISR中replicas设置用来作为leader

zookeeper.session.timeout.ms=6000
#ZooKeeper的最大超时时间，就是心跳的间隔，若是没有反映，那么认为已经死了，不易过大

zookeeper.sync.time.ms=2000
#ZK follower可以落后ZK leader的最大时间

partition.assignment.strategy=range
#在“range”和“roundrobin”策略之间选择一种作为分配partitions给consumer 数据流的策略； 循环的partition分配器分配所有可用的partitions以及所有可用consumer  线程。它会将partition循环的分配到consumer线程上。如果所有consumer实例的订阅都是确定的，则partitions的划分是确定的分布。循环分配策略只有在以下条件满足时才可以：（1）每个topic在每个consumer实力上都有同样数量的数据流。（2）订阅的topic的集合对于consumer  group中每个consumer实例来说都是确定的。

group.id
#用来唯一标识consumer进程所在组的字符串，如果设置同样的group  id，表示这些processes都是属于同一个consumer  group

client.id=group id value
#是用户特定的字符串，用来在每次请求中帮助跟踪调用。它应该可以逻辑上确认产生这个请求的应用

fetch.message.max.bytes=1024*1024
#每次fetch请求中，针对每次fetch消息的最大字节数。这些字节将会督导用于每个partition的内存中，因此，此设置将会控制consumer所使用的memory大小。这个fetch请求尺寸必须至少和server允许的最大消息尺寸相等，否则，producer可能发送的消息尺寸大于consumer所能消耗的尺寸。

num.consumer.fetchers=1
用于fetch数据的fetcher线程数

metadata.broker.list
#服务于bootstrapping。producer仅用来获取metadata（topics，partitions，replicas）。发送实际数据的socket连接将基于返回的metadata数据信息而建立。格式是：host1：port1，host2：port2
#这个列表可以是brokers的子列表或者是一个指向brokers的VIP

request.required.acks=0
#此配置是表明当一次produce请求被认为完成时的确认值。特别是，多少个其他brokers必须已经提交了数据到他们的log并且向他们的leader确认了这些信息。典型的值包括：
#0： 表示producer从来不等待来自broker的确认信息（和0.7一样的行为）。这个选择提供了最小的时延但同时风险最大（因为当server宕机时，数据将会丢失）。
#1：表示获得leader replica已经接收了数据的确认信息。这个选择时延较小同时确保了server确认接收成功。
#-1：producer会获得所有同步replicas都收到数据的确认。同时时延最大，然而，这种方式并没有完全消除丢失消息的风险，因为同步replicas的数量可能是1.如果你想确保某些replicas接收到数据，那么你应该在topic-level设置中选项min.insync.replicas设置一下。请阅读一下设计文档，可以获得更深入的讨论。

request.timeout.ms=10000
#broker尽力实现request.required.acks需求时的等待时间，否则会发送错误到客户端

producer.type=sync
#此选项置顶了消息是否在后台线程中异步发送。正确的值：
#（1）  async： 异步发送
#（2）  sync： 同步发送
#通过将producer设置为异步，我们可以批量处理请求（有利于提高吞吐率）但是这也就造成了客户端机器丢掉未发送数据的可能性

serializer.class=kafka.serializer.DefaultEncoder
#消息的序列化类别。默认编码器输入一个字节byte[]，然后返回相同的字节byte[]

key.serializer.class
#关键字的序列化类。如果没给与这项，默认情况是和消息一致

partitioner.class=kafka.producer.DefaultPartitioner
#partitioner 类，用于在subtopics之间划分消息。默认partitioner基于key的hash表

compression.codec=none
#此项参数可以设置压缩数据的codec，可选codec为：“none”， “gzip”， “snappy”

compressed.topics=null
#此项参数可以设置某些特定的topics是否进行压缩。如果压缩codec是NoCompressCodec之外的codec，则对指定的topics数据应用这些codec。如果压缩topics列表是空，则将特定的压缩codec应用于所有topics。如果压缩的codec是NoCompressionCodec，压缩对所有topics军不可用。

message.send.max.retries=3
#此项参数将使producer自动重试失败的发送请求。此项参数将置顶重试的次数。注意：设定非0值将导致重复某些网络错误：引起一条发送并引起确认丢失

topic.metadata.refresh.interval.ms=600*1000
#producer一般会在某些失败的情况下（partition missing，leader不可用等）更新topic的metadata。他将会规律的循环。如果你设置为负值，metadata只有在失败的情况下才更新。如果设置为0，metadata会在每次消息发送后就会更新（不建议这种选择，系统消耗太大）。重要提示： 更新是有在消息发送后才会发生，因此，如果producer从来不发送消息，则metadata从来也不会更新。

queue.buffering.max.ms=5000
#当应用async模式时，用户缓存数据的最大时间间隔。例如，设置为100时，将会批量处理100ms之内消息。这将改善吞吐率，但是会增加由于缓存产生的延迟。

queue.buffering.max.messages=10000
#当使用async模式时，在在producer必须被阻塞或者数据必须丢失之前，可以缓存到队列中的未发送的最大消息条数

batch.num.messages=200
#使用async模式时，可以批量处理消息的最大条数。或者消息数目已到达这个上线或者是queue.buffer.max.ms到达，producer才会处理
```

参考：
- http://www.cnblogs.com/rilley/p/5391268.html
- http://blog.csdn.net/hanjibing1990/article/details/50070815
- http://www.cnblogs.com/liangyours/p/4971656.html
