
1、修改/etc/hosts文件，自定义一个hosts名
```
vim /etc/hosts
192.168.0.1    kafka-single
```

2、修改kafka配置
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

3、重启kafka
```
# 后台启动zookeeper
./zkServer.sh start 
# 前台启动kafak
./kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
```

4、先创建一个主题
```
# 创建主题
./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic topicOne
# 查看所有主题
./kafka-topics.sh --list --zookeeper localhost:2181
```

5、消费者配置
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

6、生产者配置,消费测试
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

证书配置方法
---

一、服务器端SSL证书签发

1、创建目录来保存证书
```
mkdir -p /usr/ca/{root,server,client,trust}
```

2、生成server.keystore.jks文件(即：生成服务端的keystore文件)
```
keytool -keystore /usr/ca/server/server.keystore.jks -alias ds-kafka-single -validity 365 -genkey -keypass ds1994 -keyalg RSA -dname "CN=kafka-single,OU=aspire,O=aspire,L=beijing,S=beijing,C=cn" -storepass ds1994 -ext SAN=DNS:kafka-single
```
-alias #别名
-keystore #指定密钥库的名称(就像数据库一样的证书库，可以有很多个证书，cacerts这个文件是jre自带的， 也可以使用其它文件名字，如果没有这个文件名字，它会创建这样一个)
-storepass #指定密钥库的密码
-keypass #指定别名条目的密码
-list #显示密钥库中的证书信息
-v #显示密钥库中的证书详细信息
-export #将别名指定的证书导出到文件
-file #参数指定导出到文件的文件名
-delete #删除密钥库中某条目
-import #将已签名数字证书导入密钥库
-keypasswd #修改密钥库中指定条目口令
-dname #指定证书拥有者信息。其中，CN=名字与姓氏/域名,OU=组织单位名称,O=组织名称,L=城市或区域名称,ST=州或省份名称,C=单位的两字母国家代码
-keyalg #指定密钥的算法
-validity #指定创建的证书有效期多少天
-keysize #指定密钥长度

3、生成CA认证证书(为了保证整个证书的安全性，需要使用CA进行证书的签名保证)
```
openssl req -new -x509 -keyout /usr/ca/root/ca-key -out /usr/ca/root/ca-cert -days 365 -passout pass:ds1994 -subj "/C=cn/ST=beijing/L=beijing/O=aspire/OU=aspire/CN=kafka-single"
```

4、通过CA证书创建一个客户端信任证书
```
keytool -keystore /usr/ca/trust/client.truststore.jks -alias CARoot -import -file /usr/ca/root/ca-cert -storepass ds1994
```

5、通过CA证书创建一个服务端器端信任证书
```
keytool -keystore /usr/ca/trust/server.truststore.jks -alias CARoot -import -file /usr/ca/root/ca-cert -storepass ds1994
```

6、服务器证书的签名处理
```
# 1、导出服务器端证书server.cert-file
keytool -keystore /usr/ca/server/server.keystore.jks -alias ds-kafka-single -certreq -file /usr/ca/server/server.cert-file -storepass ds1994

# 2、用CA给服务器端证书进行签名处理
openssl x509 -req -CA /usr/ca/root/ca-cert -CAkey /usr/ca/root/ca-key -in /usr/ca/server/server.cert-file -out /usr/ca/server/server.cert-signed -days 365 -CAcreateserial -passin pass:ds1994

# 3、将CA证书导入到服务器端keystore
keytool -keystore /usr/ca/server/server.keystore.jks -alias CARoot -import -file /usr/ca/root/ca-cert -storepass ds1994

# 4、将已签名的服务器证书导入到服务器keystore
keytool -keystore /usr/ca/server/server.keystore.jks -alias ds-kafka-single -import -file /usr/ca/server/server.cert-signed -storepass ds1994
```

二、客户端SSL证书签发

1、导出客户端证书
```
keytool -keystore /usr/ca/client/client.keystore.jks -alias ds-kafka-single -validity 365 -genkey -keypass ds1994 -dname "CN=kafka-single,OU=aspire,O=aspire,L=beijing,S=beijing,C=cn" -ext SAN=DNS:kafka-single -storepass ds1994
```

2、将证书文件导入到客户端keystore
```
keytool -keystore /usr/ca/server/server.keystore.jks -alias ds-kafka-single -validity 365 -genkey -keypass ds1994 -keyalg RSA -dname "CN=kafka-single,OU=aspire,O=aspire,L=beijing,S=beijing,C=cn" -storepass ds1994 -ext SAN=DNS:kafka-single
```

3、用CA给客户端证书进行签名处理
```
openssl x509 -req -CA /usr/ca/root/ca-cert -CAkey /usr/ca/root/ca-key -in /usr/ca/client/client.cert-file -out /usr/ca/client/client.cert-signed -days 365 -CAcreateserial -passin pass:ds1994
```

4、将CA证书导入到客户端keystore
```
keytool -keystore /usr/ca/client/client.keystore.jks -alias CARoot -import -file /usr/ca/root/ca-cert -storepass ds1994
```

5、将已签名的证书导入到客户端keystore
```
keytool -keystore /usr/ca/client/client.keystore.jks -alias ds-kafka-single -import -file /usr/ca/client/client.cert-signed -storepass ds1994
```
