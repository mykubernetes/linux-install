# cassandra-stress 压测使用介绍

Cassandra从很早的版本就自带了cassandra-stress压力测试工具，它的使用方法在cassandra-stress后添加命令和选项。其中常用的命令一般只用到：write、read、mixed、user。其中单纯的write和read只测试读和写，mixed则测试同时读写。user是2.1之后新增的，通过自定义配置文件，在配置文件中可以指定insert和query查询语句。

命令command没有以-开头，而选项[options]有两种方式：-选项名称 选项值或者选项名称=选项值。

## 常用的选项有
```
counter_read： 多个并发读，必须首先通过counter_write测试填充群集。
counter_write：多个并发写。
legacy：传统模式的支持。
mixed：混合模式和可配置的读写比例和分布。集群必须先写测试数据填充。
read: 多个并发读取。必须首先通过写入测试填充群集。
write: 针对群集的多个并发写入。
user:  交错用户提供具有可配置比率和分布的查询。
version: 打印cassandra-stress版本。
print: 打印定义输出 
```


## 子选项

### -COL

列详细信息，例如大小和计数分布，数据生成器
```
用法：
-col names =？[slice] [super =？] [comparator =？] [timestamp =？] [size = DIST（？）]
 要么 
-col [n = DIST（？）] [slice] [super =？] [comparator =？] [timestamp =？] [size = DIST（？）]
```


### -rate

速率
```
使用以下选项设置费率：
-rate threads=N [throttle=N] [fixed=N]
配置项：
threads=N  并发运行的客户端数量。
throttle=N 所有客户端的每秒操作达到最大速率，默认值为0。
fixed=N    期望所有客户每秒的固定运行率。默认值为0。

或者
-rate [threads>=N] [threads<=N] [auto]
参数：
threads > = N ：同时运行至少这么多客户端。默认值为4。
threads <= N ：最多同时运行这么多客户端。默认值为1000。
auto 一旦吞吐量饱和，就停止增加线程。
```


### -errors

如何处理压力测试期间遇到的错误
```
用法：
-errors [retries = N] [ignore] [skip-read-validation]
retries=N 失败前尝试次数。
ignore 忽略错误。
skip-read-validation 跳过读取验证和消息输出。
```


### -graph

压力测试生成结果图表，可以将多个测试一起绘制成图表。
```
用法:
-graph file=? [revision=?] [title=?] [op=?]
```

### -log

日志设置
```
用法：
level=verbose
or
-log [level=?] [no-summary] [file=?] [hdrfile=?] [interval=?] [no-settings] [no-progress] [show-queries] [query-log-file=?]
```


### -mode

Thrift or CQL 选项
```
用法：
-mode thrift [smart] [user=?] [password=?]
  or 
-mode native [unprepared] cql3 [compression=?] [port=?] [user=?] [password=?] [auth-provider=?] [maxPending=?] [connectionsPerHost=?] [protocolVersion=?]
  or
-mode simplenative [prepared] cql3 [port=?]
```


### -node

要连接的节点
```
用法：
-node [datacenter=?] [whitelist] [file=?] []
```


### -port

指定用于连接Cassandra节点的端口。9042端口用于native协议的客户端连接。
```
-port [native=?] [thrift=?] [jmx=?]
```


### -schema

表结构设置
```
用法：
-schema [replication(?)] [keyspace=?] [compaction(?)] [compression=?]
```

### -sendto

指定要将压力命令发送到的服务器。
```
用法：
-sendto <host>
```

### -tokenrange
令牌范围设置。
```
用法：
-tokenrange [no-wrap] [split-factor =？] [savedata =？]
```

### 额外选项
```
profile=?：指定YAML配置文件，需要自己编写DML，插入，查询；(只能作为user选项的子选项)
ops(?)：   指定操作类型和数量，比如ops(inserts=1)，或者ops(queries=2)，其中queries需要用指定的查询名称代替；(只能作为user选项的子选项)
n=?：      指定操作数量，比如要写入1万条数据，n=10000； 要读取1000条数据，n=1000；
err<?：	指定均值的标准误差; 达到此值时， cassandra-stress将结束。默认值为0.02；
truncate=?: 是否需要清空表，可选项有：never(默认值),one,always；
cl=?：     一致性级别，可选项有：ONE,QUORUM,LOCAL_QUORUM,EACH_QUORUM,ALL,ANY,LOCAL_ONE(默认值)；(只能作为user选项的子选项)
no-warmup：不要预热过程，冷启动任务。
```
> 注意: 选项名称，选项值必须放在 子选项选项值前面，比如正确的用法：truncate=one -node xxx

## 简单读写压测示例
```
＃插入（写入）一百万行
cassandra-stress write n = 1000000 -rate threads = 50 -node  172.20.101.166 -port native=9042

＃读二十万行。
cassandra-stress读n = 200000 -rate threads = 50 -node 172.20.101.157 -port native=9042

＃读取行持续3分钟。

cassandra-stress read duration = 3m -rate threads = 50 -node 172.20.101.164 -port native=9042

＃混合读写持续5分钟。
cassandra-stress mixed duration = 5m -rate threads = 50 -node 172.20.101.164 -port native=9042


＃首先读取200,000行而不预热50,000行。
cassandra-stress read n = 200000 no-warmup -rate threads = 50 -node 172.20.101.160, 172.20.101.166 -port native=9042


#通过身份验证运行cassandra-stress
以下示例显示使用-mode选项提供用户名和密码：
cassandra-stress -mode native cql3 user = cassandra password = cassandra no-warmup cl = QUORUM
```

## 复杂压测示例：

100万条数据写入，一致性级别为Local_Quorum，客户端线程数=500个，2个列，副本数据=3个
```
cassandra-stress write n=1000000 cl=LOCAL_QUORUM -rate threads=500 \
    -col "size=fixed(2048)" "n=fixed(32)" -schema "replication(factor=3)" -node 172.20.101.157 -port native=9042
```


使用user profile 配置yaml
```
#
# This is an example YAML profile for cassandra-stress
#
# insert data
# cassandra-stress user profile=/home/jake/stress1.yaml ops(insert=1)
#
# read, using query simple1:
# cassandra-stress profile=/home/jake/stress1.yaml ops(simple1=1)
#
# mixed workload (90/10)
# cassandra-stress user profile=/home/jake/stress1.yaml ops(insert=1,simple1=9)


#
# Keyspace info
#
keyspace: load_test

#
# The CQL for creating a keyspace (optional if it already exists)
#
keyspace_definition: |
  CREATE KEYSPACE load_test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
#
# Table info
#
table: event2

#
# The CQL for creating a table you wish to stress (optional if it already exists)
#
table_definition: |
  CREATE TABLE event2 (
        cookie_id int,
        timestamp timestamp,
        event_name text,
        session_id uuid,
        page text,
        device text,
        PRIMARY KEY(cookie_id, timestamp, event_name, session_id)
  ) WITH CLUSTERING ORDER BY (timestamp DESC)

#
# Optional meta information on the generated columns in the above table
# The min and max only apply to text and blob types
# The distribution field represents the total unique population
# distribution of that column across rows.  Supported types are
# 
#      EXP(min..max)                        An exponential distribution over the range [min..max]
#      EXTREME(min..max,shape)              An extreme value (Weibull) distribution over the range [min..max]
#      GAUSSIAN(min..max,stdvrng)           A gaussian/normal distribution, where mean=(min+max)/2, and stdev is (mean-min)/stdvrng
#      GAUSSIAN(min..max,mean,stdev)        A gaussian/normal distribution, with explicitly defined mean and stdev
#      UNIFORM(min..max)                    A uniform distribution over the range [min, max]
#      FIXED(val)                           A fixed distribution, always returning the same value
#      Aliases: extr, gauss, normal, norm, weibull
#
#      If preceded by ~, the distribution is inverted
#
# Defaults for all columns are size: uniform(4..8), population: uniform(1..100B), cluster: fixed(1)
#
columnspec:
  - name: cookie_id
    population: uniform(1..100M)   # the range of unique values to select for the field (default is 100Billion)
  - name: timestamp
    size: fixed(13)
    population: uniform(1..100M)
  - name: event_name
    size: uniform(5..10)
    population: uniform(1..100M)
  - name: session_id
    size: fixed(32)
    population: uniform(1..100M)
  - name: page
    size: gaussian(16..64)
    population: uniform(1..100M)
  - name: device
    size: fixed(4)
    population: uniform(1..10)

insert:
  partitions: uniform(1..50)       # number of unique partitions to update in a single operation
                                  # if batchcount > 1, multiple batches will be used but all partitions will
                                  # occur in all batches (unless they finish early); only the row counts will vary
  batchtype: UNLOGGED               # type of batch to use
  select: fixed(10)/10       # uniform chance any single generated CQL row will be visited in a partition;
                                  # generated for each partition independently, each time we visit it

#
# A list of queries you wish to run against the schema
#
queries:
   simple1:
      cql: select * from event2 where cookie_id = ?
      fields: samerow             # samerow or multirow (select arguments from the same row, or randomly from all rows in the partition)
Collapse
```

### user profile 测试案例-1

不要预热过程,冷启动任务,插入1000000万条数据,读写比例3比1 ，一致性级别设置为：QUORUM
```
cassandra-stress user profile=./pttest-cassandra.yaml n=1000000 ops(insert=3,simple1=1) no-warmup cl=QUORUM -node 172.20.101.157 -port native=9042

Results:
Op rate                   :    1,562 op/s  [insert: 1,164 op/s, simple1: 398 op/s]
Partition rate            :   30,063 pk/s  [insert: 29,667 pk/s, simple1: 396 pk/s]
Row rate                  :   30,063 row/s [insert: 29,667 row/s, simple1: 396 row/s]
Latency mean              :   28.2 ms [insert: 37.0 ms, simple1: 2.7 ms]
Latency median            :    4.3 ms [insert: 6.5 ms, simple1: 1.1 ms]
Latency 95th percentile   :  126.2 ms [insert: 142.5 ms, simple1: 7.7 ms]
Latency 99th percentile   :  230.4 ms [insert: 254.1 ms, simple1: 23.8 ms]
Latency 99.9th percentile :  476.8 ms [insert: 554.2 ms, simple1: 96.6 ms]
Latency max               : 2581.6 ms [insert: 2,581.6 ms, simple1: 2,264.9 ms]
Total partitions          :    999,932 [insert: 986,756, simple1: 13,176]
Total errors              :          0 [insert: 0, simple1: 0]
Total GC count            : 43
Total GC memory           : 12.565 GiB
Total GC time             :    3.0 seconds
Avg GC time               :   69.4 ms
StdDev GC time            :   13.4 ms
Total operation time      : 00:00:33

Improvement over 181 threadCount: -7%
```


### user profile 测试案例-2

不要预热过程,冷启动任务,500并发，插入1000000万条数据,读写比例3比1 ，一致性级别设置为：QUORUM
```
cassandra-stress user profile=./pttest-cassandra.yaml n=1000000 ops(insert=3,simple1=1) no-warmup cl=QUORUM -rate threads=500 -node 172.20.101.157 -port native=9042

Results:
Op rate                   :    1,496 op/s  [insert: 1,145 op/s, simple1: 396 op/s]
Partition rate            :   28,763 pk/s  [insert: 29,221 pk/s, simple1: 394 pk/s]
Row rate                  :   28,763 row/s [insert: 29,221 row/s, simple1: 394 row/s]
Latency mean              :   49.5 ms [insert: 64.0 ms, simple1: 7.5 ms]
Latency median            :    4.9 ms [insert: 7.0 ms, simple1: 1.3 ms]
Latency 95th percentile   :  251.3 ms [insert: 286.0 ms, simple1: 29.7 ms]
Latency 99th percentile   :  513.0 ms [insert: 561.0 ms, simple1: 118.3 ms]
Latency 99.9th percentile :  909.1 ms [insert: 940.0 ms, simple1: 477.1 ms]
Latency max               : 1416.6 ms [insert: 1,416.6 ms, simple1: 820.0 ms]
Total partitions          :    999,847 [insert: 986,542, simple1: 13,305]
Total errors              :          0 [insert: 0, simple1: 0]
Total GC count            : 41
Total GC memory           : 12.277 GiB
Total GC time             :    3.0 seconds
Avg GC time               :   72.3 ms
StdDev GC time            :   25.0 ms
Total operation time      : 00:00:34
```
发现并发并没有提升效率！

### user profile 测试案例-3

连接多节点，不要预热过程,冷启动任务,插入1000000万条数据,读写比例3比1 ，一致性级别设置为：QUORUM
```
cassandra-stress user profile=./pttest-cassandra.yaml n=1000000 ops(insert=3,simple1=1) no-warmup cl=QUORUM -node 172.20.101.157,172.20.101.160,172.20.101.167 -port native=9042

Results:
Op rate                   :    1,570 op/s  [insert: 1,181 op/s, simple1: 389 op/s]
Partition rate            :   30,638 pk/s  [insert: 30,250 pk/s, simple1: 389 pk/s]
Row rate                  :   30,638 row/s [insert: 30,250 row/s, simple1: 389 row/s]
Latency mean              :   32.6 ms [insert: 42.4 ms, simple1: 2.6 ms]
Latency median            :    4.4 ms [insert: 6.6 ms, simple1: 1.3 ms]
Latency 95th percentile   :  128.6 ms [insert: 146.9 ms, simple1: 7.7 ms]
Latency 99th percentile   :  283.4 ms [insert: 336.3 ms, simple1: 21.6 ms]
Latency 99.9th percentile : 2334.1 ms [insert: 2,344.6 ms, simple1: 78.0 ms]
Latency max               : 2730.5 ms [insert: 2,730.5 ms, simple1: 414.7 ms]
Total partitions          :    999,987 [insert: 987,306, simple1: 12,681]
Total errors              :          0 [insert: 0, simple1: 0]
Total GC count            : 43
Total GC memory           : 12.817 GiB
Total GC time             :    3.1 seconds
Avg GC time               :   72.1 ms
StdDev GC time            :   14.9 ms
Total operation time      : 00:00:32
```

user profile 测试案例-4

生成测试结果图

连接多节点，不要预热过程,冷启动任务,插入1000000万条数据,读写比例3比1 ，一致性级别设置为：QUORUM
```
cassandra-stress user profile=./pttest-cassandra.yaml n=1000000 ops(insert=3,simple1=1) no-warmup cl=QUORUM -graph file=test.html title=test revision=test1 -node 172.20.101.157,172.20.101.160,172.20.101.167 -port native=9042

Results:
Op rate                   :    1,602 op/s  [insert: 1,204 op/s, simple1: 398 op/s]
Partition rate            :   30,941 pk/s  [insert: 30,543 pk/s, simple1: 398 pk/s]
Row rate                  :   30,941 row/s [insert: 30,543 row/s, simple1: 398 row/s]
Latency mean              :   15.6 ms [insert: 20.1 ms, simple1: 2.1 ms]
Latency median            :    4.1 ms [insert: 5.9 ms, simple1: 1.2 ms]
Latency 95th percentile   :   67.2 ms [insert: 74.7 ms, simple1: 5.4 ms]
Latency 99th percentile   :  111.9 ms [insert: 118.9 ms, simple1: 11.7 ms]
Latency 99.9th percentile :  274.2 ms [insert: 289.4 ms, simple1: 71.3 ms]
Latency max               : 2231.4 ms [insert: 2,231.4 ms, simple1: 271.1 ms]
Total partitions          :    999,996 [insert: 987,127, simple1: 12,869]
Total errors              :          0 [insert: 0, simple1: 0]
Total GC count            : 41
Total GC memory           : 12.276 GiB
Total GC time             :    2.7 seconds
Avg GC time               :   66.9 ms
StdDev GC time            :   15.4 ms
Total operation time      : 00:00:32

Improvement over 81 threadCount: -8%
```


参考文档：
- https://docs.datastax.com/en/dse/5.1/dse-admin/datastax_enterprise/tools/toolsCStress.html
- https://www.instaclustr.com/deep-diving-cassandra-stress-part-3-using-yaml-profiles/
- https://zqhxuyuan.github.io/2015/10/15/Cassandra-Stress/
