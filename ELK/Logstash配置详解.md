
文件路径 logstash/config/logstash.yml
```
# ---------- Node identity ----------

# 节点名称，默认主机名
node.name: test


# ---------- Data path ----------

# 数据存储路径，默认LOGSTASH_HOME/data
path.data:


# ---------- Pipeline Settings ----------

# pipeline ID，默认main
pileline.id: main

# 输出通道的工作workers数据量，默认cpu核心数
pipeline.workers:

# 单个工作线程尝试执行其过滤器和输出之前将从输入手机的最大事件数量，默认125
pipeline.batch.size: 125

# 将较小的批处理分派给管道之前，等待的毫秒数，默认50ms
pipeline.batch.delay: 50

# 此值为true时，即使内存中仍然有运行中事件，也会强制Logstash在关机期间退出
pipeline.unsafe_shutdown: false

# 管道事件排序
# 可选项: auto,true,false,默认auto
pipeline.ordered: auto


# ---------- Pipeline Configuration Settings ----------

# 配置文件路径
path.config:

# 主管道的管道配置字符串
config.string:

# 该值为true时，检查配置是否有效，然后退出，默认false
config.test_and_exit: false

# 该值为true时，会定期检查配置是否已更改，并在更改后重新加载配置，默认false
config.reload.automatic: false

# 检查配置文件更改的时间间隔，默认3s
config.reload.interval: 3s

# 该值为true时，将完整编译的配置显示为调试日志消息，默认为false
config.debug: false

# 该值为true时，开启转移
config.support_escapes: false


# ---------- HTTP API Settings ----------

# 是否开启htp访问，默认true
http.enabled: true

# 绑定主机地址，可以是ip，主机名，默认127.0.0.1
http.host: 127.0.0.1

# 服务监听端口，可以是单个端口，也可以是范围端口，默认9600-9700
http.port: 9600-9700


# ---------- Module Settings ----------

# 模块定义，必须为数组
# 模块变量名格式必须为var.PLUGIN_TYPE.PLUGIN_NAME.KEY
modules:
    - name: MODULE_NAME
        var.PLUGINTYPE1.PLUGINNAME1.KEY1: VALUE
        var.PLUGINTYPE1.PLUGINNAME1.KEY2: VALUE
        var.PLUGINTYPE2.PLUGINNAME1.KEY1: VALUE
        var.PLUGINTYPE3.PLUGINNAME3.KEY1: VALUE


# ---------- Queuing Settings ----------

# 事件缓冲的内部排队模型，可选项：memory，persisted，默认memory
queue.type: memory

# 启用持久队列(queue.type: persisted)后将在其中存储数据文件的目录路径
# 默认path.data/queue
path.queue:

# 启用持久队列(queue.type: persisted)后，队列中未读事件的最大数量
# 默认0
queue.max_events: 0

# 启用持久队列(queue.type: persisted)后，队列的总容量，单位字节，默认1024mb
queue.max_bytes: 1024mb

# 启用持久队列(queue.type: persisted)后，在强制检查点之前的最大ACKed事件数，默认1024
queue.checkpoint.acks: 1024

# 启用持久队列(queue.type: persisted)后，在强制检查点之前的最大书面时间数，默认1024
queue.checkpoint.writes: 1024

# 启用持久队列(queue.type: persisted)后，执行检查点的时间间隔，单位ms，默认1000ms
queue.checkpoint.interval: 1000


# ---------- Dead-Letter Queue Settings ----------

# 是否启用插件支持的DLQ功能的标志，默认false
dead_letter_queue.enable: false

# dead_letter_queue.enable为true时，每个死信队列的最大大小
# 若死信队列的大小超出该值，则被删除，默认1024mb
dead_letter_queue.max_bytes: 1024mb

# 死信队列存储路径，默认path.data/dead_letter_queue
path.dead_letter_queue:


# ---------- Debugging Settings ----------

# 日志输出级别，选项：fatal，error，warn，info，debug，trace，默认info
log.level: info

# 日志格式，选项：json，plain，默认plain
log.format:

# 日志路径，默认LOGSTASH_HOME/logs
path.logs:


# ---------- Other Settings ----------

# 插件存储路径
path.plugins: []

# 是否启用每个管道在不同日志文件中的日志分隔
# 默认false
pipeline.separate_logs: false

————————————————
版权声明：本文为CSDN博主「飞Link」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/feizuiku0116/article/details/125597421
```
