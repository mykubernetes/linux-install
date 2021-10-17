# kafka自带压力测试

使用perf命令来测试topic的性能，50W条消息，每条1000字节，batch大小1000，topic为test，4个线程：
```
bin/kafka-topics.sh --create --zookeeper h153:2181 --replication-factor 1 --partitions 2 --topic test
```

```
# 生产者测试：
# bin/kafka-producer-perf-test.sh --messages 500000 --message-size 1000  --batch-size 1000 --topics test --threads 4 --broker-list h153:9092
start.time, end.time, compression, message.size, batch.size, total.data.sent.in.MB, MB.sec, total.data.sent.in.nMsg, nMsg.sec
2017-09-27 01:33:54:610, 2017-09-27 01:34:10:381, 0, 1000, 1000, 476.84, 30.2351, 500000, 31703.7601

# 消费者：
#bin/kafka-consumer-perf-test.sh --zookeeper h153 --messages 500000 --topic test --threads 4
start.time, end.time, fetch.size, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, nMsg.sec
2017-09-27 01:36:41:066, 2017-09-27 01:36:46:068, 1048576, 0.0000, 0.0000, 0, 0.0000
```

新版本运行命令和输出结果都有所变化（参考Kafka-2.11-1.1.0版本）
```
./kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=localhost:9092
# 输出：
records sent, 1202.4 records/sec (1.15 MB/sec), 1678.8 ms avg latency, 2080.0 max latency.
records sent, 2771.8 records/sec (2.64 MB/sec), 1300.4 ms avg latency, 2344.0 max latency.
records sent, 2061.6 records/sec (1.97 MB/sec), 17.1 ms avg latency, 188.0 max latency.
records sent, 1976.6 records/sec (1.89 MB/sec), 10.0 ms avg latency, 177.0 max latency.
records sent, 2025.2 records/sec (1.93 MB/sec), 15.4 ms avg latency, 253.0 max latency.
records sent, 2000.8 records/sec (1.91 MB/sec), 6.1 ms avg latency, 163.0 max latency.
records sent, 1929.7 records/sec (1.84 MB/sec), 3.7 ms avg latency, 128.0 max latency.
records sent, 2072.0 records/sec (1.98 MB/sec), 14.1 ms avg latency, 163.0 max latency.
records sent, 2001.6 records/sec (1.91 MB/sec), 4.5 ms avg latency, 116.0 max latency.
records sent, 1997.602877 records/sec (1.91 MB/sec), 290.41 ms avg latency, 2344.00 ms max latency, 2 ms 50th, 1992 ms 95th, 2177 ms 99th, 2292 ms 99.9th.
 
./kafka-consumer-perf-test.sh --broker-list localhost:9092 --topic test_perf --fetch-size 1048576 --messages 100000 --threads 1
# 输出：
start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, nMsg.sec, rebalance.time.ms, fetch.time.ms, fetch.MB.sec, fetch.nMsg.sec
2018-12-06 05:50:41:276, 2018-12-06 05:50:45:281, 95.3674, 23.8121, 100000, 24968.7890, 78, 3927, 24.2851, 254
```

参考：
- https://blog.csdn.net/laofashi2015/article/details/81111466
- https://www.cnblogs.com/xiao987334176/p/10075659.html
