Burrow简介
===
Burrow是LinkedIn开源的一款专门监控consumer lag的框架。

Burrow的特点如下
- 使用Burrow监控kafka, 不需要预先设置lag的阈值, 他完全是基于消费过程的动态评估
- Burrow支持读取kafka topic和,zookeeper两种方式的offset，对于新老版本kafka都可以很好支持
- Burrow支持http, email类型的报警
- Burrow默认只提供HTTP接口(HTTP endpoint)，数据为json格式，没有web UI

https://github.com/ignatev/burrow-kafka-dashboard

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

二进制包的方式
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

3、配置说明

burrow配置文件主要由多个配置段组成
- 1、[general]配置中包含了日志文件的位置和PID文件，以及一些kafka集群的共享配置。
- 2、[zookeeper]配置指定一个Zookeeper集合，以便在多个Burrow副本之间提供锁定，这允许您随时运行多个Burrow副本，只允许一个副本执行通知程序。
- 3、[kafka]配置指定了burrow连接和监控的单个kafka集群，子标题"local"是用于在HTTP请求和响应中标识的Kafka集群的名称，可以指定多个[kafka]子标题，以便为一个Burrow实例监视许多Kafka群集
- 4、[storm]配置指定一个单一的Storm集群，用于通过Zookeeper偏移量进行监视。子标题"local"是此Storm集群映射到的Kafka集群的名称，用于在HTTP请求和通知中标识它。 可以指定多个子标题来提供一个Burrow实例来监视许多Storm群集。
- 5、[notify]设置关于通知中心的配置
- 6、[tickers]设置关于执行某些操作的频率的配置。
- 7、[lagcheck]配置设置关于内部滞后检查算法的配置。
- 8、[httpserver]配置burrow的HTTP endpoint
- 9、[Notifiers]用于在消费者组处于不良状态时将电子邮件发送到指定的地址。可以为单个电子邮件地址配置多个组，并且可以根据每个电子邮件地址配置检查状态的时间间隔。可以在burrow配置文件中配置多个email通知，每个通知有自己的配置段，必须将enable=true通知器才能执行，必须在子标题部分指定发送email通知的地址

```
[general]
logdir=log                              #日志目录，非必填项，包含了日志文件和PID文件
logconfig=config/logging.cfg            #日志配置文件，非必填项，指定了记录日志的格式
pidfile=burrow.pid                      #PID文件名称，非必填项，里面包含了进程PID
client-id=burrow-lagchecker             #kafka client ID，非必填项，当消费kafka消息时，提供给kakfa集群的消费者ID，这遵循与topic名称相同的规则
group-blacklist=^(console-consumer-|python-kafka-consumer-).*$         #正则表达式，非必填项，如果消费者group匹配这个正则，则忽略

[zookeeper]
#zookeeper地址，必填项，多个主机条目可以提供更好的冗余， hostname OR hostname:port
hostname=zkhost01.example.com
hostname=zkhost02.example.com
hostname=zkhost03.example.com
port=2181                               #zookeeper的端口，非必填项，默认2181
timeout=6                               #超时时间，非必填项，连接zookeeper的超时时间
lock-path=/burrow/notifier              #znode地址，非必填项，一个znode的全路径，用于在多个burrow实例之间进行锁定，如果不存在会自动创建

[kafka "local"]

#broker地址，必填项，多个主机条目可以提供更好的冗余，hostname OR hostname:port
broker=kafka01.example.com
broker=kafka02.example.com
broker=kafka03.example.com
broker-port=10251                       #broker端口，非必填项，默认9092

#zookeeper地址，必填项，多个主机条目可以提供更好的冗余，hostname OR hostname:port
zookeeper=zkhost01.example.com
zookeeper=zkhost02.example.com
zookeeper=zkhost03.example.com
zookeeper-port=2181                     #zookeeper端口，非必填项，默认2181
zookeeper-path=/kafka-cluster           #znode地址，必填项，一个znode的全路径。
zookeeper-offsets=true                  #zookeeper偏移量收集是否开启，非必填项，默认false
offsets-topic=__consumer_offsets        #offsets的topic，非必填项，默认__consumer_offsets

[storm "local"]
#zookeeper地址，必填项，多个主机条目可以提供更好的冗余，hostname OR hostname:port
zookeeper=zkhost01.example.com
zookeeper=zkhost02.example.com
zookeeper=zkhost03.example.com
zookeeper-port=2181                     #zookeeper端口，非必填项，默认2181
zookeeper-path=/storm-cluster

[notify]
interval=10                             #检查consumergroup状态的时间间隔

[tickers]
broker-offsets=60                       #多久刷新一次broker HEAD在所有partitions的偏移量，秒

[lagcheck]
intervals=10                            #多少个consumer的偏移量存储在partition，这决定了评估消费者滞后的窗口
expire-group=604800                     #在消费者停止提交偏移量以从Burrow的监视中删除之后，等待几秒钟。
min-distance=1                          #消费者偏移提交之间允许的最小间隔(秒)，在此间隔内的提交将被忽略。
zookeeper-interval=60                   #如果配置了zk保存cluster的offsets，则多久扫描一次Zookeeper来检查偏移量
zk-group-refresh=300                    #刷新Zookeeper里面的消费者列表的频率。

[httpserver]
server=on                               #是否开启HTTP server，默认false
port=8000                               #HTTPS server监听的端口
; Alternately, use listen
; listen=host:port
; listen=host2:port2

[smtp]
server=mailserver.example.com           #邮件服务器地址
port=25                                 #邮件服务器端口
auth-type=plain                         #认证类型，如果没auth则是空，plain这是明文的用户和密码
username=emailuser
password=s3cur3!
from=burrow-noreply@example.com         #发邮件的地址
template=config/default-email.tmpl      #邮件模板

[emailnotifier "bofh@example.com"]
#两个逗号分隔的字符串，第一个字符串表示kafka集群名称(上文定义的)，第二个字符串表示监控那个consumer group
group=local,critical-consumer-group
group=local,other-consumer-group
interval=60                              #检查consumer group的时间间隔
enable=true                              #是否开启email通知
```

4、配置
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

运行
```
$GOPATH/bin/Burrow --config-dir /data/goconfig
```


5、k8s配置
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





5、简单使用
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

常用
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


启动burrow-exporter
```
nohup ./burrow-exporter --burrow-addr="http://10.10.0.18:8000" --metrics-addr="0.0.0.0:9254" --interval="15" --api-version="3" &
```

配置prometheus
```
scrape_configs:
  - job_name: kafka
    static_configs:
      - targets: ["192.168.112.129:9254"]
```



https://github.com/panubo/docker-burrow-exporter


https://github.com/ignatev/burrow-kafka-dashboard

https://www.jianshu.com/p/92ae7e5992e2?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation

https://blog.csdn.net/weixin_33877885/article/details/91593934
