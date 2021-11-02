# 简单部署 

```
#下载解压
[wangpei@localhost ~/software]$ wget https://artifacts.elastic.co/downloads/logstash/logstash-6.3.2.tar.gz

[wangpei@localhost ~/software]$ tar -zxvf logstash-6.3.2.tar.gz

#自检-接收标准输入并输出到控制台
[wangpei@localhost ~/software/logstash-6.3.2]$ bin/logstash -e 'input { stdin { } } output { stdout {} }'
输入 Hello
输出
    {
          "@version" => "1",
           "message" => "Hello",
        "@timestamp" => 2018-08-11T11:49:31.059Z,
              "host" => "localhost.local"
    }
```


# Mysql增量同步至 Kafka/Hdfs/Elasticsearch

## Mysql 测试库表

- 生产中一个库同一类数据一般会有多张分表如16张分表,256张分表。
```
#建库 user_logs
create database user_logs;

#建表-用户浏览日志表: user_browse_0_logs,user_browse_1_logs 如
CREATE TABLE `user_browse_0_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `event_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uid` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `event_time` (`event_time`) USING BTREE,
  KEY `uid_event_time` (`uid`,`event_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='用户浏览日志表';
```

## Logstash 配置

基础配置
```
#配置目录
[wangpei@localhost ~/software/logstash-6.3.2]$ mkdir db_test

#拷贝默认配置
[wangpei@localhost ~/software/logstash-6.3.2]$ cp config/* db_test/

#db_test/jvm.options
#jvm配置 
-Xms1g
-Xmx1g

#db_test/logstash.yml
#持久化目录 
#logstash和plugin任何需要持久化的数据都会放在这个目录
path.data: /Users/wangpei/software/logstash-6.3.2/data/user_browse_logs/data

#queue  
#默认memory,logstash进程重启会丢数据
queue.type: persisted

#并发度
pipeline.workers: 2

#每个线程从输入收集的最大数量
pipeline.batch.size: 125
```

## Input-Filter-Output配置
```
[wangpei@localhost ~/software/logstash-6.3.2]$ vim db_test/user_browse_logs.conf
#输入配置 jdbc插件
input {
  jdbc {
    #jdbc驱动
    jdbc_driver_library => "/Users/wangpei/software/logstash-6.3.2/mysql-connector-java-5.1.38.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    #jdbc连接
    jdbc_connection_string => "jdbc:mysql://node2:3306/user_logs"
    jdbc_user => "root"
    jdbc_password => "111"
    #任务调度
    schedule => "* * * * *"
    #上次运行的sql_last_value保存路径
    #启动前需要确保该文件已存在
    last_run_metadata_path => "/Users/wangpei/software/logstash-6.3.2/data/test/metadata/user_browse_0_logs"
    #sql语句
    #按主键自增id 增量同步
    #input在拿到字段为日期类型的数据时,一定会减8小时并带上时区信息
    #如原始mysql event_time字段为日期类型(这里是timestamp类型)的数据2018-08-12 14:38:24 =>经过input后=> 2018-08-12T14:38:24.000Z
    #不想让input修改原始数据,这里直接把event_time转成成字符串类型。
    statement => "SELECT id,product_id,DATE_FORMAT(event_time, '%Y-%m-%d %H:%i:%s') as event_time,uid FROM user_browse_0_logs WHERE id > :sql_last_value"
    #设置成true 用tracking_column列的值去更新上次记录的sql_last_value值
    use_column_value => true
    #追踪的列
    tracking_column => "id"
    #追踪的列的数据类型 支持["numeric", "timestamp"]
    tracking_column_type => "numeric"
    #插件id 便于监控
    id => "user_browse_logs_input_jdbc"
    #添加字段 表名 便于后期DQC 如mysql 每个分表的数据和HDFS每个分区数据count、sum验证
    add_field => {"table_name" => "user_browse_0_logs"}
    #input event输出格式 每个event转换成json+换行符格式
    codec => json_lines {charset => "UTF-8"}
  }
}

#Filter配置
filter {
  #默认会对每条数据加上@timestamp
  #不指定@timestamp字段来源,默认会以logstash服务器收到数据时间为准
  date {
        #匹配到这种格式就会替换成目标字段,目标字段默认是@timestamp
        #貌似不管怎么设置,Logstash中 @timestamp永远是0时区
        #@timestamp 0时区,数据写入ES，@timestamp 在Kibana上显示时会根据浏览器市区自动调整 如自动+8
        match => ["event_time" , "yyyy-MM-dd HH:mm:ss"]
        #timezone => "Asia/Shanghai"
    #target => "@timestamp"
    }
  #增加dt字段,该字段来源于event_time,用于hdfs按天分区、ES按天索引
  #总结:
  #假设源数据是北京时间
  #1)数据同步到ES:(需要兼顾kibana各种作图、Java/Python API查询)
  #   A、按北京时间建索引如下dt
  #   B、kibana可视化,时间选择用@timestamp时间字段,避免用event_time时间字段做不了Date Histogram问题。
  #   C、ES API查询,时间选择用event_time时间字段更方便。
  #2)数据同步到HDFS: 按北京时间分区 如下dt即可
  ruby {code => "event.set('dt', event.get('event_time')[0,10].gsub('-',''));"}
}

#输出配置
output {
  #输出到控制台
  stdout { codec => rubydebug}
  #输出到kafka
  kafka {
    #kafka brokers
    bootstrap_servers => "localhost:9092"
    #topic
    topic_id => "testTopic3"
    #ack
    acks => "1"
    #输出格式
    codec => json
    #id
    id => "user_browse_logs_ouput_kafka"
  }
  #输出到HDFS
  #需要开启HDFS 的webhdfs
  webhdfs {
    codec => json_lines {charset => "UTF-8"}
    #namenode
    host => 'node1'
    port => 50070
    #standby namenode
    standby_host => 'node4'
    standby_port => 50070
    #user
    user => 'root'
    #user需要对path有读写权限
    path => '/data/user_logs/user_browse_logs/%{dt}/%{table_name}.log'
    #攒到多少条event时向hdfs写一次数据
    flush_size => 3
    #间隔多久向hdfs写一次数据 单位:秒
    idle_flush_time => 2
  }
  #输出到elasticsearch
  elasticsearch {
         #es节点列表
         hosts => ["localhost:9200"]
         #索引使用的模板
         #模板中定义了mapping(日期Format,某个字段使用的分词器)和setting
     template_name => "template.user_browse_logs"
         #index
         #数据是北京时间,这个按北京时间建索引
         index => "user_browse_logs.%{dt}"
     #type
         document_type =>"browse_logs"
         #权限
         user => "logstash_input"
         password => "logstash_input"
         codec => json {charset => "UTF-8"}
    }
}
```

## 启动方式
```
#直接启动===> 一个input-filter-output配置独享一个logstash进程
[wangpei@localhost ~/software/logstash-6.3.2]$ bin/logstash --path.settings db_test/  -f db_test/user_browse_logs.conf --config.reload.automatic

#pipeline方式启动===> 多个input-filter-output配置共享一个logstash进程
[wangpei@localhost ~/software/logstash-6.3.2]$ bin/logstash --path.settings db_test/  --config.reload.automatic
需配置db_test/pipelines.yml
配置多个pipeline。每个pipeline可对应一个表(input-filter-output)。
- pipeline.id: user_logs.user_browse_logs
  queue.type: persisted
  pipeline.workers: 1
  queue.max_bytes: 32mb
  path.config: "/Users/wangpei/software/logstash-6.3.2/db_test/user_browse_logs.conf"

- pipeline.id: user_logs.user_pay_logs
  queue.type: persisted
  pipeline.workers: 1
  queue.max_bytes: 32mb
  path.config: "/Users/wangpei/software/logstash-6.3.2/db_test/user_pay_logs.conf"
  ...
```

## 结果

- mysql插入数据
```
insert into user_browse_0_logs(product_id,uid) values(1,"0");
insert into user_browse_0_logs(product_id,uid) values(2,"0");
insert into user_browse_0_logs(product_id,uid) values(3,"0");

mysql> select * from user_browse_0_logs;
+----+------------+---------------------+-----+
| id | product_id | event_time          | uid |
+----+------------+---------------------+-----+
|  1 |          1 | 2018-08-12 20:18:31 | 0   |
|  2 |          2 | 2018-08-12 20:18:31 | 0   |
|  3 |          3 | 2018-08-12 20:18:32 | 0   |
+----+------------+---------------------+-----+
```

kafka收到的数据
```
[wangpei@localhost ~/software/logstash-6.2.4]$ kafka-console-consumer --bootstrap-server localhost:9092 --topic testTopic3

{"@version":"1","dt":"20180812","product_id":3,"uid":"0","id":3,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:32","@timestamp":"2018-08-12T12:18:32.000Z"}
{"@version":"1","dt":"20180812","product_id":1,"uid":"0","id":1,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
{"@version":"1","dt":"20180812","product_id":2,"uid":"0","id":2,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
```

hdfs收到的数据
```
#分区:20180812
#分区下的文件:user_browse_0_logs.log user_browse_0_logs是表名
#该路径来自:output webhdfs path参数 path => '/data/user_logs/user_browse_logs/%{dt}/%{table_name}.log'

[root@node2 /root]# hdfs dfs -cat /data/user_logs/user_browse_logs/20180812/user_browse_0_logs.log
{"@version":"1","dt":"20180812","product_id":1,"uid":"0","id":1,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
{"@version":"1","dt":"20180812","product_id":2,"uid":"0","id":2,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:31","@timestamp":"2018-08-12T12:18:31.000Z"}
{"@version":"1","dt":"20180812","product_id":3,"uid":"0","id":3,"table_name":"user_browse_0_logs","event_time":"2018-08-12 20:18:32","@timestamp":"2018-08-12T12:18:32.000Z"}
```


查看jdbc偏移量记录文件
```
#该路径来自input jdbc插件 last_run_metadata_path参数
last_run_metadata_path => "/Users/wangpei/software/logstash-6.3.2/data/test/metadata/user_browse_0_logs"

#此时id的偏移量是3,下次取id>3的数据。这样就实现了增量同步
[wangpei@localhost ~/software/logstash-6.3.2]$ cat /Users/wangpei/software/logstash-6.3.2/data/test/metadata/user_browse_0_logs
--- 3
```

查看logstash持久化的数据
```
#持久化目录下包含2个目录,一个文件
#该目录来自于logstash.yml中 path.data: /Users/wangpei/software/logstash-6.3.2/data/user_browse_logs/data

[wangpei@localhost ~/software/logstash-6.3.2]$ ls -l /Users/wangpei/software/logstash-6.3.2/data/user_browse_logs/data
total 8
drwxr-xr-x  2 wangpei  staff   68  8 12 19:38 dead_letter_queue
drwxr-xr-x  4 wangpei  staff  136  8 12 19:57 queue
-rw-r--r--  1 wangpei  staff   36  8 12 19:38 uuid

#uuid:logstash agent uuid
#queue:input → queue → filter + output。queue配置为persisted时,input会把数据先写入此持久化目录,然后再由filter + output处理。
#dead_letter_queue:DLQ队列。死信队列储存响应代码为400或404的情况，两者都表示无法重试的事件。
如数据input=>filter=>output(es)，
一条数据出现mapping error，此时如果在logstash.yml中配置了dead_letter_queue.enable: true,
就会将这条数据放在DLQ对应的持久化目录中。然后可以通过DLQ(Dead Letter Queues) Input => Filter(再处理)=>Output ES。
```

## 附:Kafka Input
```
input{
    kafka{
        codec => json {charset => "UTF-8"}
        #消费者组
        group_id => "test_topic_consumer1"
        #从最新开始消费
        auto_offset_reset => "latest"
        #消费的topics
        topics => ["test_topic"]
        #bootstrap server
        bootstrap_servers => "localhost:9092"
        #注意:线程数最好与partition数目一样多,超过partition数量的线程会闲置。
        #kafka topic 一个partition同一时刻只能有一个线程去消费。
        consumer_threads =>3
    }
}
```

## Logstash监控

可通过X-Pack以UI的方式查看监控信息，也可通过监控API查看。

监控API主要有四类:节点信息、插件信息、节点状态统计、热线程统计。

- 节点信息
```
接口返回os、jvm、pipelines配置信息 如jvm最大最小堆、pipelines worker数。
http://localhost:9600/_node/<os/pipelines/jvm>?pretty 
```

- 插件信息
```
列出所有可用插件。
http://localhost:9600/_node/plugins?pretty
```

- 节点状态统计
```
http://localhost:9600/_node/stats/<type>?pretty
type=jvm 获取jvm统计信息。如jvm当前线程数、线程峰值、内存各区(young、old、survivor)内存使用情况、gc次数、gc时间
type=process 获取进程统计信息。如内存消耗和CPU使用情况
type=events 获取event相关统计信息。如输入、filter、输出中的event数目
type=pipelines 获取每个pipeline统计信息、
```

- 热线程统计
```
获取当前热线程。热线程是一个Java线程，具有较高的CPU使用率并且执行时间超过正常时间。
http://localhost:9600/_node/hot_threads?pretty
```
