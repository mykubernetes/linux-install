Burrow简介
===
Burrow是LinkedIn开源的一款专门监控consumer lag的框架。

Burrow的特点如下
- 使用Burrow监控kafka, 不需要预先设置lag的阈值, 他完全是基于消费过程的动态评估
- Burrow支持读取kafka topic和,zookeeper两种方式的offset，对于新老版本kafka都可以很好支持
- Burrow支持http, email类型的报警
- Burrow默认只提供HTTP接口(HTTP endpoint)，数据为json格式，没有web UI


1、安装go，将go安装到/opt/soft下：
```
# cd /opt/soft
# wget https://dl.google.com/go/go1.10.4.linux-amd64.tar.gz
# tar -zxvf go1.8.linux-amd64.tar.gz


mkdir -p /data/{go,src,pkg}  


# vim /etc/profile
export GOROOT=/opt/soft/go
export GOPATH=/data/go
export PATH=$PATH:$GOROOT/bin

# seorce /etc/profile
```


2、安装burrow
```
$ go get github.com/linkedin/Burrow
$ cd $GOPATH/src/github.com/linkedin/Burrow
$ go install
```

3、配置
```
# vim /data/goconfig/burrow.toml

#基础选项
[general]
pidfile="burrow.pid"
stdout-logfile="logs/burrow.out"
access-control-allow-origin="mysite.example.com"

#日志选项
[logging]
filename="logs/burrow.log"
level="info"
maxsize=100
maxbackups=30
maxage=10
use-localtime=false
use-compression=true

#zookeeper选项，这个zookeeper使用burrow自己用的
[zookeeper]
servers=["10.128.0.2:2181", ]
timeout=6
root-path="/burrow"

#burrow作为客户端的配置
[client-profile.burrowclient]
client-id="burrowclient"
kafka-version="0.10.0"

#HTTP监听配置，可以使用HTTPS
[httpserver.default]
address=":8000"

#存储选项
[storage.default]
class-name="inmemory"
workers=20
intervals=15
expire-group=604800
min-distance=1

#报警选项
[notifier.default]
class-name="email"
interval=30
threshold=2
group-whitelist="^important-group-prefix.*$"
group-blacklist="^not-this-group$"
template-open="config/default-email.tmpl"
server="127.0.0.1"
port=25
from="root@localhost.com"
to="hello@ipcpu.com"
#
# kafka cluster config here

#接下来是Kafka相关的内容
#
[cluster.bu-agent-kafka]
class-name="kafka"
servers=[ "10.128.0.65:9092", "10.128.0.66:9092", "10.128.0.67:9092" ]
client-profile="burrowclient"
topic-refresh=300
offset-refresh=60
[consumer.bu-agent-kafka]
class-name="kafka"
cluster="bill-kafka"
servers=[ "10.128.0.65:9092", "10.128.0.66:9092", "10.128.0.67:9092" ]
client-profile="burrowclient"
offsets-topic="__consumer_offsets"
start-latest=true
group-whitelist=".*"
group-blacklist="^not-this-group$"
#@注意这里使用了cluster.kafkaname和consumer.kafkaname两个配置组，
#@第一个用来获取topic和最新offset信息，
#@第二个用来获取消费组和消费组offset及Lag。
```

```
[zookeeper]
servers=["zookeeper-default:2181"]
timeout=6
root-path="/burrow"

[client-profile.client]
client-id="burrow-client"
kafka-version="0.10.0"
sasl="saslprofile"

[sasl.saslprofile]
username="KAFKA_USERNAME"
password="KAFKA_PASSWORD"
handshake-first=true

[cluster.kafka-default]
class-name="kafka"
servers=[ "kafka-default:9092"]
topic-refresh=60
offset-refresh=30
client-profile="client"

[consumer.kafka-default]
class-name="kafka"
cluster="kafka-default"
servers=[ "kafka-default:9092"]
group-blacklist=""
group-whitelist=""
client-profile="client"

[consumer.kafka-default-zk]
class-name="kafka_zk"
cluster="kafka-default"
servers=["zookeeper-default:2181"]
zookeeper-path="/tracking_kafka"
zookeeper-timeout=30
group-blacklist=""
group-whitelist=""
[httpserver.default]
address=":8000"
Events:  <none>
```


4、运行
```
$GOPATH/bin/Burrow --config-dir /data/goconfig
```


5、简单使用
| Request	| Method | URL Format |
|---------|--------|------------|
| List Clusters	| GET	| /v3/kafka |
| Kafka Cluster	|  Detail	| GET	| /v3/kafka/(cluster) |
| List Consumers	| GET	| /v3/kafka/(cluster)/consumer |
| List Cluster Topics	| GET	| /v3/kafka/(cluster)/topic |
| Get Consumer Detail	| GET	| /v3/kafka/(cluster)/consumer/(group) |
| Consumer Group Status	| GET	| /v3/kafka/(cluster)/consumer/(group)/status |
| Consumer Group Lag	| GET	| /v3/kafka/(cluster)/consumer/(group)/lag |

```
#@列出所有监控的Kafka集群
# curl -s http://10.128.0.2:8000/v3/kafka |jq
{
  "error": false,
  "message": "cluster list returned",
  "clusters": [
    "nginxlog",
    "bill-kafka"
  ],
  "request": {
    "url": "/v3/kafka",
    "host": "zabbix"
  }
}

#@列出所有消费组
[root@mt ~]# curl -s http://10.128.0.2:8000/v3/kafka/bill-kafka/consumer |jq
{
  "error": false,
  "message": "consumer list returned",
  "consumers": [
    "group1",
    "group_bill",
    "report_gid"
  ],
  "request": {
    "url": "/v3/kafka/bill-kafka/consumer",
    "host": "zabbix"
  }
}
 
 #@查看消费组健康状态
# curl -s http://10.128.0.2:8000/v3/kafka/bill-kafka/consumer/group1/status |jq
{
  "error": false,
  "message": "consumer status returned",
  "status": {
    "cluster": "bill-kafka",
    "group": "group1",
    "status": "OK",
    "complete": 1,
    "partitions": [],
    "partition_count": 18,
    "maxlag": {
      "topic": "shellActivity",
      "partition": 0,
      "owner": "",
      "status": "OK",
      "start": {
        "offset": 101333573,
        "timestamp": 1526997873289,
        "lag": 0
      },
      "end": {
        "offset": 101333604,
        "timestamp": 1526997891689,
        "lag": 0
      },
      "current_lag": 0,
      "complete": 1
    },
    "totallag": 0
  },
  "request": {
    "url": "/v3/kafka/bill-kafka/consumer/group1/status",
    "host": "zabbix"
  }
}
```


https://github.com/panubo/docker-burrow-exporter


https://github.com/ignatev/burrow-kafka-dashboard

https://www.jianshu.com/p/92ae7e5992e2?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation
