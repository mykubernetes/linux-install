Burrow简介
===
Burrow是LinkedIn开源的一款专门监控consumer lag的框架。

Burrow的特点如下
- 使用Burrow监控kafka, 不需要预先设置lag的阈值, 他完全是基于消费过程的动态评估
- Burrow支持读取kafka topic和,zookeeper两种方式的offset，对于新老版本kafka都可以很好支持
- Burrow支持http, email类型的报警
- Burrow默认只提供HTTP接口(HTTP endpoint)，数据为json格式，没有web UI

https://github.com/ignatev/burrow-kafka-dashboard

https://github.com/danielqsj/kafka_exporter

https://blog.csdn.net/weixin_39553352/article/details/111262485

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

3、二进制包的方式
```
# wget https://github.com/linkedin/Burrow/releases/download/v1.1.0/Burrow_1.1.0_linux_amd64.tar.gz 
# mkdir burrow
# tar -xf Burrow_1.1.0_linux_amd64.tar.gz -C burrow
# cp burrow/burrow /usr/bin/
# mkdir /etc/burrow
# cp burrow/config/* /etc/burrow/

# chkconfig --add burrow
# /etc/init.d/burrow start
```


4、编辑配置
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
root-path="/burrow"                   #znode地址，必填项，一个znode的全路径

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

运行
```
$GOPATH/bin/Burrow --config-dir /data/goconfig
```


5、常用配置，简洁配置
```
[general]
pidfile="/var/run/burrow.pid"
stdout-logfile="/var/log/burrow.log"
access-control-allow-origin="mysite.example.com"

[logging]
filename="/var/log/burrow.log"
level="info"
maxsize=512
maxbackups=30
maxage=10
use-localtime=true
use-compression=true

[zookeeper]
servers=[ "test1.localhost:2181","test2.localhost:2181" ]
timeout=6
root-path="/burrow"

[client-profile.prod]
client-id="burrow-lagchecker"
kafka-version="0.10.0"

[cluster.production]
class-name="kafka"
servers=[ "test1.localhost:9092","test2.localhost:9092" ]
client-profile="prod"
topic-refresh=180
offset-refresh=30

[consumer.production_kafka]
class-name="kafka"
cluster="production"
servers=[ "test1.localhost:9092","test2.localhost:9092" ]
client-profile="prod"
start-latest=false
group-blacklist="^(console-consumer-|python-kafka-consumer-|quick-|test).*$"
group-whitelist=""

[consumer.production_consumer_zk]
class-name="kafka_zk"
cluster="production"
servers=[ "test1.localhost:2181","test2.localhost:2181" ]
#zookeeper-path="/"
# If specified, this is the root of the Kafka cluster metadata in the Zookeeper ensemble. If not specified, the root path is used.
zookeeper-timeout=30
group-blacklist="^(console-consumer-|python-kafka-consumer-|quick-|test).*$"
group-whitelist=""

[httpserver.default]
address=":8000"

[storage.default]
class-name="inmemory"
workers=20
intervals=15
expire-group=604800
min-distance=1
```

6、k8s配置
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


7、接口说明
| Request	| Method | URL Format |
|---------|--------|------------|
| Healthcheck |	GET |	/burrow/admin |
| List Clusters | GET |	/v3/kafka |
| Kafka Cluster Detail | GET |	/v3/kafka/(cluster) |
| List Consumers | GET | /v3/kafka/(cluster)/consumer |
| List Cluster Topics |	GET |	/v3/kafka/(cluster)/topic |
| Get Consumer Detail |	GET |	/v3/kafka/(cluster)/consumer/(group) |
| Consumer Group Status |	GET |	/v3/kafka/(cluster)/consumer/(group)/status /v3/kafka/(cluster)/consumer/(group)/lag |
| Remove Consumer Group |	DELETE | /v3/kafka/(cluster)/consumer/(group) |
| Get Topic Detail |	GET |	/v3/kafka/(cluster)/topic/(topic) |
| Get General Config | GET | /v3/config |
| List Cluster Modules | GET | /v3/config/cluster |
| Get Cluster Module Config |	GET |	/v3/config/cluster/(name) |
| List Consumer Modules |	GET |	/v3/config/consumer |
| Get Consumer Module Config | GET | /v3/config/consumer/(name) |
| List Notifier Modules |	GET |	/v3/config/notifier |
| Get Notifier Module Config | GET | /v3/config/notifier/(name) |
| List Evaluator Modules | GET | /v3/config/evaluator |
| Get Evaluator Module Config |	GET | /v3/config/evaluator/(name) |
| List Storage Modules | GET | /v3/config/storage |
| Get Storage Module Config |	GET |	/v3/config/storage/(name) |
| Get Log Level |	GET |	/v3/admin/loglevel |
| Set Log Level |	POST | /v3/admin/loglevel |

8、接口使用
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

9常用接口
```
GET /v3/kafka/(cluster)/consumer                       #获取所有消费者列表
GET /v3/kafka/(cluster)/consumer/(group)/status        #获取指定消费者状态
GET /v3/kafka/(cluster)/consumer/(group)/lag           #获取指定延迟
GET /v3/kafka/(cluster)/topic                          #获取topic列表
GET /v3/kafka/(cluster)/topic/(topic)                  #获取topic offsets信息
```

```
消费组健康状态的接口含义如下：

NOTFOUND – 消费组未找到
OK   – 消费组状态正常
WARN   – 消费组处在WARN状态，例如offset在移动但是Lag不停增长。 the offsets are moving but lag is increasing
ERR   – 消费组处在ERR状态。例如，offset停止变动，但Lag非零。 the offsets have stopped for one or more partitions but lag is non-zero
STOP   – 消费组处在ERR状态。例如offset长时间未提交。the offsets have not been committed in a log period of time
STALL   – 消费组处在STALL状态。例如offset已提交但是没有变化，Lag非零。the offsets are being committed, but they are not changing and the lag is non-zero
```

```
健康检查：/burrow/admin
列出kafka集群：/v3/kafka
列出zk集群：/v3/zookeeper
列出单个kafka集群的详情：/v3/kafka/(cluster)
列出单个kafka集群的消费者：/v3/kafka/(cluster)/consumer
删除某个kafka集群的消费者group：/v3/kafka/(cluster)/consumer/(group)
列出单个kafka集群某个消费者group的topic：/v3/kafka/(cluster)/consumer/(group)/topic
列出单个kafka集群某个消费者group的topic详情：/v3/kafka/(cluster)/consumer/(group)/topic/(topic)
返回仅包含处于不良状态的分区的对象：/v2/kafka/(cluster)/consumer/(group)/status 
返回包含消费者的所有分区的对象，而不管分区的评估状态如何：/v3/kafka/(cluster)/consumer/(group)/lag
列出单个kafka集群的topic：/v3/kafka/(cluster)/topic
列出单个kafka集群的单个topic详情：/v2/kafka/(cluster)/topic/(topic)
```

10、配置systemd
```
[Unit]
Description=Burrow - Kafka consumer LAG Monitor
After=network.target


[Service]
Type=simple
RestartSec=20s
ExecStart=/usr/bin/burrow --config-dir /etc/burrow
PIDFile=/var/run/burrow/burrow.pid
User=burrow
Group=burrow
Restart=on-abnormal


[Install]
WantedBy=multi-user.target
```


11、启动burrow-exporter
```
nohup ./burrow-exporter --burrow-addr="http://10.10.0.18:8000" --metrics-addr="0.0.0.0:9254" --interval="15" --api-version="3" &
```

12、配置prometheus
```
scrape_configs:
  - job_name: kafka
    static_configs:
      - targets: ["192.168.112.129:9254"]
```


https://github.com/ignatev/burrow-kafka-dashboard

https://www.jianshu.com/p/92ae7e5992e2?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation

https://blog.csdn.net/weixin_33877885/article/details/91593934
