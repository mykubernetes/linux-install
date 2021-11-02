# 一、Fluentd
Fluentd是一个完全免费且开源的日志收集系统，性能敏感的部分用C语言编写，插件部分用Ruby编写，500多种插件，只需很少的系统资源即可轻松实现”Log Everything”。一般叫Fluentd为td-agent。

Fluentd与td-agent关系：td-agent是Fluentd的稳定发行包。

Fluentd与Flume关系:是两个类似工具，都可用于数据采集。Fluentd的Input／Buffer／Output类似于Flume的Source／Channel／Sink。

# 二、Fluentd主要组成部分


Fluentd 主要由Input输出、Buffer缓冲、Output输出三大部分组成。这三大部分都是以插件的形式存在。当然还有其他辅助插件如Filter、Formatter等用于数据处理或格式化。

# 三、快速部署

Fluentd官网下载对应版本并安装。
```
curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh
```

启动Fluentd
```
service td-agent start
```

默认情况下，/etc/td-agent/td-agent.conf配置文件给了一个测试配置。可接收HTTP Post数据，并将其路由并写入到/var/log/td-agent/td-agent.log日志文件中。
```
curl -X POST -d 'json={"json":"Hello Fluentd"}' http://localhost:8888/debug

/var/log/td-agent/td-agent.log收到的内容
debug: {"json":"Hello Fluentd"}
```

# 四、Fluentd插件

Fluentd有七种类型的插件：输入(Input)，分析器(Parser)，过滤器(Filter)，输出(Output)，格式化(Formatter)，存储(Storage)，缓冲(Buffer)。
- Input: 输入插件。内置的有tail、http、tcp、udp等。
- Parser: 解析器。可自定义解析规则，如解析nginx日志。
- Filter: Filter插件，可过滤掉事件，或增加字段，删除字段。
- Output: 输出插件。内置的有file、hdfs、s3、kafka、elasticsearch、mongoDB、stdout等。
- Formatter: Formatter插件。可自定义输出格式如json、csv等。
- Storage: Storage插件可将各状态保存在文件或其他存储中，如Redis、MongoDB等。
- Buffer: Buffer缓冲插件。缓冲插件由输出插件使用。在输出之前先缓冲，然后以如Kafka Producer Client的方式批量提交。有file、memory两种类型。flush_interval参数决定了提交的间隔，默认60秒刷新一次。

# 五、同一 Fluentd Agent同步不同类型日志到对应Kaka Topic

1、在/etc/td-agent目录创建配置文件browseFile_browseTopic.conf,内容如下：
```
##### input file #####
<source>
  #input类型tail 类似于tail -F 命令
  @type tail
  #日志文件路径
  path /data/log/browse-*.log
  #偏移量路径 记录上一次读取的位置 td-agent用户需要写权限
  pos_file /data/td-agent-data/pos/browse.pos
  #tag: match tag 把Event路由到不同output
  tag browse

  <parse>
    #以json格式解析
    @type json
  </parse>
</source>

##### output kafka #####
#匹配tag
<match browse>
   #输出到kafka
   @type kafka
   #kafka brokers
   brokers node1:6667,node2:6667,node3:6667
   #kafka topic
   default_topic browse_log
   #kafka data type
   output_data_type json
   #kafka ack
   required_acks -1
   #kafka flush 间隔
   flush_interval 5s

   #缓冲
   #缓冲类型 file
   buffer_type file
   #缓存的文件路径
   buffer_path /data/td-agent-data/buffer/browse_buffer
</match>
```

2、在/etc/td-agent目录创建配置文件clickFile_clickTopic.conf,内容如下：
```
##### input file #####
<source>
  #input类型tail 类似于tail -F 命令
  @type tail
  #日志文件路径
  path /data/log/click-*.log
  #偏移量路径 记录上一次读取的位置 td-agent用户需要写权限
  pos_file /data/td-agent-data/pos/click.pos
  #tag: match tag 把Event路由到不同output
  tag click

  <parse>
    #以json格式解析
    @type json
  </parse>
</source>

##### output kafka #####
#匹配tag
<match click>
   #输出到kafka
   @type kafka
   #kafka brokers
   brokers node1:6667,node2:6667,node3:6667
   #kafka topic
   default_topic click_log
   #kafka data type
   output_data_type json
   #kafka ack
   required_acks -1
   #kafka flush 间隔
   flush_interval 5s

   #缓冲
   #缓冲类型 file
   buffer_type file
   #缓存的文件路径
   buffer_path /data/td-agent-data/buffer/click_buffer
</match>
```

3、在/etc/td-agent目录创建配置文件td-agent1.conf,内容如下：
```
#用户浏览日志
@include /etc/td-agent/browseFile_browseTopic.conf

#用户点击日志
@include /etc/td-agent/clickFile_clickTopic.conf
```

4、启动td-agent
```
td-agent -c /etc/td-agent/td-agent1.conf -o /var/log/td-agent/td-agent1.log
```

5、向用户浏览日志日志文件追加数据
```
for i in `seq 1 1000`;
do
  aa=`date "+%Y-%m-%d %H:%M:%S"`
  browse='{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"'"${aa}"'"}'
  echo ${browse} >> browse-1534527000.log
  echo ${browse} >> browse-1534528000.log
  sleep 1
done
```

6、向用户点击日志日志文件追加数据
```
click='{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}'
for i in `seq 1 1000`;do echo ${click} >> click-1534525200.log;sleep 1;done
```

结果: kafka topic browse_log 收到的日志
```
bin/kafka-console-consumer.sh --bootstrap-server node1:9200,node2:9200,node3:9200 --topic browselog
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:46"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:48"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:49"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:46"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:47"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:48"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:49"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"browse_log","now_date":"2018-08-19 19:32:50"}
```


结果：kafka topic click_log 收到的日志
```
bin/kafka-console-consumer.sh --bootstrap-server node1:9200,node2:9200,node3:9200 --topic clich_log
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
{"userID":1,"productID":1,"event_time":12333,"log_type":"click_log"}
```


# 五、同一 Fluentd Agent同步同一输入到不同输出

1、在/etc/td-agent目录创建配置文件 td-agent2.conf，内容如下：
```
#####配置input#####
<source>
  #配置input 为tail
  @type tail
  #日志文件路径
  path /data/log/test-*.log
  #偏移量路径
  pos_file /data/td-agent-data/pos/test.pos
  #tag
  tag test
  <parse>
    #原样输出
    @type none
  </parse>
</source>


#####配置output 多个输出#####
<match test>
    #copy output plugin 将event拷贝到多个output
    @type copy
    <store>
       #输出到文件
       @type file
       path /data/log/testBackup.log
    </store>
    <store>
       #输出到控制台
       @type stdout
    </store>
    <store>
       #输出到kafka
       @type kafka
       brokers node1:6667,node2:6667,node3:6667
       default_topic testTopic3
    </store>
</match>
```

2、启动td-agent
```
td-agent -c /etc/td-agent/td-agent2.conf -o /var/log/td-agent/td-agent2.log
```

3、向test-1.log追加日志
```
for i in `seq 1 1000`;do echo "Fluent is logging ....">> test-1.log;sleep 1;done
```

结果:本地目录
```
tail -f 7844ac885a0bc28buffer.b573c8b906ec16e6fc.log
2018-08-19T20:14:01+08:00            test      {"message":"Fluent is logging ...."}
2018-08-19T20:14:02+08:00            test      {"message":"Fluent is logging ...."}
2018-08-19T20:14:03+08:00            test      {"message":"Fluent is logging ...."}
2018-08-19T20:14:04+08:00            test      {"message":"Fluent is logging ...."}
2018-08-19T20:14:05+08:00            test      {"message":"Fluent is logging ...."}
2018-08-19T20:14:06+08:00            test      {"message":"Fluent is logging ...."}
2018-08-19T20:14:07+08:00            test      {"message":"Fluent is logging ...."}
2018-08-19T20:14:08+08:00            test      {"message":"Fluent is logging ...."}
```

结果:标准输出
```
tail -f /var/log/td-agent/td-agent2.log
2018-08-19 20:14:46.592940261 +0800 test: {"message":"Fluent is logging ...."}
2018-08-19 20:14:47.607707956 +0800 test: {"message":"Fluent is logging ...."}
2018-08-19 20:14:48.617084709 +0800 test: {"message":"Fluent is logging ...."}
2018-08-19 20:14:49.638059276 +0800 test: {"message":"Fluent is logging ...."}
2018-08-19 20:14:50.662753952 +0800 test: {"message":"Fluent is logging ...."}
2018-08-19 20:14:51.667721588 +0800 test: {"message":"Fluent is logging ...."}
2018-08-19 20:14:52.673620531 +0800 test: {"message":"Fluent is logging ...."}
2018-08-19 20:14:53.678351009 +0800 test: {"message":"Fluent is logging ...."}
```


结果:kafka
```
bin/kafka-console-consumer.sh --bootstrap-server node1:9200,node2:9200,node3:9200 --topic testTopic3
{"message":"Fluent is logging ...."}
{"message":"Fluent is logging ...."}
{"message":"Fluent is logging ...."}
{"message":"Fluent is logging ...."}
{"message":"Fluent is logging ...."}
{"message":"Fluent is logging ...."}
{"message":"Fluent is logging ...."}
{"message":"Fluent is logging ...."}
```


# 六、监控

## 进程监控

一个td-agent有两个进程:父进程、子进程。确保这两个进程存在。
```
ps w -C ruby -C td-agent --no-heading

81565 ?        Sl     0:00 /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config
81570 ?        Sl     0:02 /opt/td-agent/embedded/bin/ruby -Eascii-8bit:ascii-8bit /usr/sbin/td-agent --log /var/log/td-agent/td-ag
```

## 指标监控

在td-agent1.conf配置文件增加如下配置:
```
#监控
<source>
  type monitor_agent
  bind 0.0.0.0
  port 24220
</source>
```

## 通过HTTP访问 http://node3:24220/api/plugins.json
```
{
    "plugins":[
        {
            "plugin_id":"object:d72aa8",
            "plugin_category":"input",
            "type":"tail",
            "config":{
                "@type":"tail",
                "path":"/data/log/browse-*.log",
                "pos_file":"/data/td-agent-data/pos/browse.pos",
                "tag":"browse"
            },
            "output_plugin":false,
            "retry_count":null
        },
        {
            "plugin_id":"object:10351c8",
            "plugin_category":"input",
            "type":"tail",
            "config":{
                "@type":"tail",
                "path":"/data/log/click-*.log",
                "pos_file":"/data/td-agent-data/pos/click.pos",
                "tag":"click"
            },
            "output_plugin":false,
            "retry_count":null
        },
        {
            "plugin_id":"object:d6c4b4",
            "plugin_category":"input",
            "type":"monitor_agent",
            "config":{
                "type":"monitor_agent",
                "bind":"0.0.0.0",
                "port":"24220"
            },
            "output_plugin":false,
            "retry_count":null
        },
        {
            "plugin_id":"object:f94124",
            "plugin_category":"output",
            "type":"kafka",
            "config":{
                "@type":"kafka",
                "brokers":"node1:6667,node2:6667,node3:6667",
                "default_topic":"browse_log",
                "output_data_type":"json",
                "required_acks":"-1",
                "flush_interval":"5s",
                "buffer_type":"file",
                "buffer_path":"/data/td-agent-data/buffer/browse_buffer"
            },
            "output_plugin":true,
            "retry_count":0,
            "retry":{

            }
        },
        {
            "plugin_id":"object:ff62e8",
            "plugin_category":"output",
            "type":"kafka",
            "config":{
                "@type":"kafka",
                "brokers":"node1:6667,node2:6667,node3:6667",
                "default_topic":"click_log",
                "output_data_type":"json",
                "required_acks":"-1",
                "flush_interval":"5s",
                "buffer_type":"file",
                "buffer_path":"/data/td-agent-data/buffer/click_buffer"
            },
            "output_plugin":true,
            "retry_count":0,
            "retry":{

            }
        }
    ]
}
```

参考：
- https://cloud.tencent.com/developer/column/87531
- https://docs.fluentd.org/input/tail
- https://www.jianshu.com/p/e7c5f51f290b
