# 简介

- Maxwell是由Java语言编写,Zendesk开源的binlog解析同步工具。可通过简单配置，将binlog解析并以json的格式同步到如file,kafka,redis,RabbitMQ等系统中。也可自定义输出。相比Canal,Maxwell相当于Canal Server+Canal Client。

# 安装

## 配置MySQL

MySQL 开启Binlog
```
#开启binlog
#修改my.cnf配置文件 增加如下内容
[root@node2 /root]# vim /etc/my.cnf

[mysqld]
#binlog文件保存目录及binlog文件名前缀
#binlog文件保存目录: /var/lib/mysql/
#binlog文件名前缀: mysql-binlog
#mysql向文件名前缀添加数字后缀来按顺序创建二进制日志文件 如mysql-binlog.000006 mysql-binlog.000007
log-bin=/var/lib/mysql/mysql-binlog
#选择基于行的日志记录方式
binlog-format=ROW
#服务器 id
#binlog数据中包含server_id,标识该数据是由那个server同步过来的
server_id=1
```

## MySQL 配置权限
```
CREATE USER 'maxwell_sync'@'%' IDENTIFIED BY 'maxwell_sync_1';
-- Maxwell需要在待同步的库上建立schema_database库,将状态存储在`schema_database`选项指定的数据库中(默认为`maxwell`)
GRANT ALL on maxwell.* to 'maxwell_sync'@'%';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'maxwell_sync'@'%';
FLUSH PRIVILEGES;
```

## MySQL 建库建表
```
create database test_maxwell;
use test_maxwell;
create table if not exists `user_info`(
   `userid` int,
   `name` varchar(100),
   `age` int
)engine=innodb default charset=utf8;
```

## 配置Maxwell
```
下载解压
[root@node2 /data/software]# wget https://github.com/zendesk/maxwell/releases/download/v1.17.1/maxwell-1.17.1.tar.gz

[root@node2 /data/software]# tar -zxvf maxwell-1.17.1.tar.gz
```

## 解析binlog并同步至kafka并配置监控

### 启动maxwell
```
#输入来源于mysql binlog 
#输出到kafka
#配置说明
#1)kafka_topic 
#可配置成如 namespace_%{database}_%{table} %{database} 和 %{table}会被替换成真正的值
#2)kafka_version 
#注意和kafka版本匹配。
#3)额外配置 
#kafka.acks、kafka.compression.type、kafka.retries
#4)filter
#可排除库、表、过滤掉某些行。也可用一段js灵活处理数据 
#如 exclude: test_maxwell.user_info.userid = 1 排除test_maxwell库user_info表userid值为1的行
#5)monitor
#可配置的监控方式jmx、http等
#http_bind_address 监控绑定的IP
#http_port 监控绑定的Port
#http_path_prefix http请求前缀

[root@node2 /data/software/maxwell-1.17.1]# bin/maxwell \
--host='localhost' \
--port=3306 \
--user='maxwell_sync' \
--password='maxwell_sync_1' \
--filter='exclude: *.*,include:test_maxwell.user_info,exclude: test_maxwell.user_info.userid = 1' \
--producer=kafka \
--kafka_version='0.11.0.1' \
--kafka.bootstrap.servers='node1:6667,node2:6667,node3:6667' \
--kafka_topic=qaTopic \
--metrics_type=http \
--metrics_jvm=true \
--http_bind_address=node2 \
--http_port=8090 \
--http_path_prefix=db_test_maxwell

#输出到控制台用如下配置

[root@node2 /data/software/maxwell-1.17.1]# bin/maxwell \
--host='localhost' \
--port=3306 \
--user='maxwell_sync' \
--password='maxwell_sync_1' \
--producer=stdout
```

### kafka消费者客户端
```
[root@node1 /usr/hdp/2.6.4.0-91/kafka]# bin/kafka-console-consumer.sh --bootstrap-server 192.168.113.101:6667 --topic qaTopic


### 解析Insert
```
#sql insert 3条数据
mysql> insert into user_info(userid,name,age) values (1,'name1',10),(2,'name2',20),(3,'name3',30);

#kafka-console-consumer结果
#userid=1的数据被过滤掉了
{"database":"test_maxwell","table":"user_info","type":"insert","ts":1533857131,"xid":10571,"xoffset":0,"data":{"userid":2,"name":"name2","age":20}}
{"database":"test_maxwell","table":"user_info","type":"insert","ts":1533857131,"xid":10571,"commit":true,"data":{"userid":3,"name":"name3","age":30}}
```

### 解析Delete
```
#sql delete
mysql> delete from user_info where userid=2;

#kafka-console-consumer结果
{"database":"test_maxwell","table":"user_info","type":"delete","ts":1533857183,"xid":10585,"commit":true,"data":{"userid":2,"name":"name2","age":20}}
```

### 解析Update
```
#sql update
mysql> update user_info set name='name3',age=23 where userid=3;

#maxwell解析结果
{"database":"test_maxwell","table":"user_info","type":"update","ts":1533857219,"xid":10595,"commit":true,"data":{"userid":3,"name":"name3","age":23},"old":{"age":30}}
```

## 查看监控

### 消息处理速度与JVM
```
成功发送到Kafka的消息数、发送失败的消息数
已从binlog处理的行数、消费binlog速度、jvm状态
http://node2:8090/db_test_maxwell/metrics

返回:
counters: {
MaxwellMetrics.messages.failed: {
count: 0
},
MaxwellMetrics.messages.succeeded: {
count: 0
},
MaxwellMetrics.row.count: {
count: 84
}
}
......
```

### maxwell健康状态
```
http://node2:8090/db_test_maxwell/healthcheck

返回:
{
MaxwellHealth: {
healthy: true
}
}
```

### ping
```
http://node2:8090/db_test_maxwell/ping

能ping通返回字符串pong
```

## Maxwell优缺点

优点
- (1) 相比较canal,配置简单,开箱即用。
- (2) 可自定义发送目的地(java 继承类,实现方法),数据处理灵活(js)。
- (3) 自带多种监控。

缺点
- (1) 需要在待同步的业务库上建schema_database库(默认maxwell),用于存放元数据,如binlog消费偏移量。但按maxwell的意思,这并不是缺点。
- (2) 不支持HA。而canal可通过zookeeper实现canal server和canal client的HA,实现failover。
