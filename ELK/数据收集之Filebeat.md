# 简介：

Filebeat采用Go语言开发，也可用于日志收集，相较于的Logstash，更轻量，资源占用更少。一般部署在日志收集的最前端。

本文基于Filebeat 6.3.2总结。

# 设计要点

### 主要组件
- Filebeat主要由两大组件组成：Harvester、Input。Output实际上是Beats公共库libbeat一部分。

### Harvester
- 每个文件启动一个Harvester，即对应一个Go routine。Harvester负责打开和关闭这个文件。Harvester监控并按行读取文件，并将内容发送到输出。

### Input
- Input负责管理Harvester，找到要读取的每个文件，并为每个文件启动Harvester。

### 状态机制
- Filebeat记录每个文件的状态并且刷新此状态到registry_file注册表文件中。注册表文件里的offset记录了成功发送最后一行的偏移量。
- Filebeat重启或Output重新可用时，Filebeat根据注册表文件中记录的位置，继续读取文件。

注意:注册表文件被删除，重启filebeat可实现从头开始重新读取内容。

### At-Least-Once机制
- Filebeat确保事件至少一次被发送到配置的Output。Filebeat能够实现At-Least-Once发送，因为它将每个事件的发送状态存储在注册表文件中。
- 若输出不可达或不能确认输出是否已收到事件，Filebeat会继续尝试发送事件，直到Filebeat确认输出已收到。
- 若Filebeat在发送事件的过程中关闭，重启后，将再次尝试发送到输出。这样，在Filebeat关闭过程中未被确认到达的事件至少会被发送一次，可以通过设置shutdown_timeout参数将Filebeat配置为在关闭之前等待特定时间，减少重复发送事件的次数，从而减少输出中事件的重复。

### 工作原理
- 启动Filebeat时，它会根据配置启动一个或多个Input。对于Input找到的每个日志文件，都启动一个Harvester。每个Harvester监控并读取每行数据，并将内容发送到libbeat，libbeat把事件汇聚成batch，并以client的方式发送给特定Output，如Kafka、Elasticsearch。

# 快速部署

ELK官网下载对应系统的Filebeat，安装即可。
```
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.2-x86_64.rpm
rpm -ivh filebeat-6.3.2-x86_64.rpm
```

# 同一Filebeat Agent同步不同类型日志到对应Kaka Topic

Filebeat一般部署在业务服务器上。

Filebeat可以实现类似于tail -F 监控业务日志文件，并同步Kafka(很多公司的大数据平台都以Kafka为数据中心)。

一个Filebeat Instance(也可叫Filebeat Agent)可对应一个或多个Input，但只能有一个Output(6.x版本的新变化)。

在/etc/filebeat目录下创建配置文件file_kafka.yml配置文件内容如下：
```
#cpu
max_procs: 1

#memory
queue.mem:
  events: 2048
  flush.min_events: 1024
  flush.timeout: 5s

#配置输入
#=========================== Filebeat inputs =============================
filebeat.inputs:
# 指定需要监控的文件或者目录
- type: log
  # 为true 表示启用此配置
  enabled: true
  # 指定需要监控的文件或者目录
  paths:
    - /data/log/browse-*.log
  # 排除行
  #exclude_lines: ['^DBG']
  # 只包含的行
  #include_lines: ['^ERR', '^WARN']
  #需要排除的文件 这里排除以appError开头的日志文件
  exclude_files: ['appError.*']
  #额外添加字段，如
  fields:
    #用户浏览日志，用户浏览时上报。应发往kafka topic:browse_log
    log_topic: browse_log

- type: log
  enabled: true
  paths:
    - /data/log/pay-*.log
  fields:
    #用户下单日志，用户下单时上报。应发往kafka topic:pay_log
    log_topic: pay_log
  scan_frequency: 30s

- type: log
  enabled: true
  paths:
    - /data/log/click-*.log
  fields:
    #用户点击日志，用户点击时上报。应发往kafka topic:click_log
    log_topic: click_log
  scan_frequency: 120s

#配置输出
#6.x的filebeat,一个filebeat instace只能有一个输出
#================================ Outputs =====================================
#输出到控制台
#output.console:
#  enabled: true
#  pretty: true
#  codec.format.string: '%{[message]}'


#输出到kafka
output.kafka:
  #启用此输出
  enabled: true
  #只输出Event Body
  codec.format:
    string: '%{[message]}'
  #kafka broker list
  hosts: ['node1:6667','node2:6667','node3:6667']
  #kafka topic
  topic: '%{[fields.log_topic]}'
  #kafka partition 分区策略 random/round_robin/hash
  partition.hash:
    #是否只发往可达分区
    reachable_only: false
  #kafka ack级别
  required_acks: -1
  #Event最大字节数。默认1000000。应小于等于kafka broker message.max.bytes值
  max_message_bytes: 1000000
  #kafka output的最大并发数
  worker: 1
  #kafka 版本
  version: 0.10.1
  #单次发往kafka的最大事件数
  bulk_max_size: 2048
```

# 启动filebeat
```
path.home:filebeat 安装目录
path.config:filebeat配置文件目录
path.data:持久化数据的文件目录如registry(注册表文件)
path.logs:filebeat系统日志文件目录
e:日志不再输入到path.logs，直接输出到控制台，用于debug
c:配置文件，配置了input output等

/usr/share/filebeat/bin/filebeat \
  -path.home /usr/share/filebeat \
  -path.config /etc/filebeat \
  -path.data /var/lib/filebeat \
  -path.logs /var/log/filebeat \
  -e \
  -c file_kafka.yml
```

同时向browse-1534527000.log、click-1534525200.log、pay-1534525200.log中追加数据，查看kafka-console-consumer中变化。

可以看到，三个topic分别收到各自的消息。
