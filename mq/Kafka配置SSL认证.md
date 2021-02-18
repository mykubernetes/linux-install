1、修改kafka配置
```
# vim server.properties

############################# Server Basics #############################
# SSL认证配置
# 如果配置了SSL认证，那么原来的port和advertised.listeners可以注释掉了
listeners=SSL://kafka-single:9095
advertised.listeners=SSL://kafka-single:9095
ssl.keystore.location=/usr/ca/server/server.keystore.jks
ssl.keystore.password=ds1994
ssl.key.password=ds1994
ssl.truststore.location=/usr/ca/trust/server.truststore.jks
ssl.truststore.password=ds1994
ssl.client.auth=required
ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
ssl.keystore.type=JKS 
ssl.truststore.type=JKS 
# kafka2.0.x开始，将ssl.endpoint.identification.algorithm设置为了HTTPS，即:需要验证主机名
# 如果不需要验证主机名，那么可以这么设置 ssl.endpoint.identification.algorithm=即可
ssl.endpoint.identification.algorithm=HTTPS
# 设置内部访问也用SSL，默认值为security.inter.broker.protocol=PLAINTEXT
security.inter.broker.protocol=SSL
broker.id=0
############################# Socket Server Settings #############################
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
############################# Log Basics #############################
log.dirs=/usr/data/kafka
num.partitions=1
num.recovery.threads.per.data.dir=1
############################# Internal Topic Settings  #############################
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
############################# Log Retention Policy #############################
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
############################# Zookeeper #############################
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=6000
############################# Group Coordinator Settings #############################
group.initial.rebalance.delay.ms=0
```

2、重启kafka
```
# 后台启动zookeeper
./zkServer.sh start 
# 前台启动kafak
./kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
```

3、先创建一个主题
```
# 创建主题
./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic topicOne
# 查看所有主题
./kafka-topics.sh --list --zookeeper localhost:2181
```

4、消费者配置
```
security.protocol=SSL
group.id=test-group
ssl.truststore.location=/usr/ca/trust/server.truststore.jks
ssl.truststore.password=ds1994
ssl.keystore.password=ds1994
ssl.keystore.location=/usr/ca/server/server.keystore.jks
```

```
./kafka-console-consumer.sh --bootstrap-server kafka-single:9095 --topic topicOne --from-beginning --consumer.config ../config/c.properties
```

5、生产者配置,消费测试
```
bootstrap.servers=kafka-single:9095
security.protocol=SSL
ssl.truststore.location=/usr/ca/trust/server.truststore.jks
ssl.truststore.password=ds1994   
ssl.keystore.password=ds1994
ssl.keystore.location=/usr/ca/server/server.keystore.jks
```

```
./kafka-console-producer.sh --broker-list kafka-single:9095 --topic topicOne --producer.config ../config/p.properties
```


