1.异常：

我启动kafka消息提供客户端命令，随便发消息都出现下面的错误警告提示
```
#./kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic
>1
[2019-04-09 13:58:47,702] WARN Error while fetching metadata with correlation id 1 : {testTopic=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)
```

2.原因：

2.1可能是你的topic不存在，导致的。让它自动创建。

kafka集群的配置文件，是否设置了`auto.create.topics.enable=false`。如果有，就设置为`ture`。



2.2或者你也可以手动创建
```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partitions 4 --topic test
```
