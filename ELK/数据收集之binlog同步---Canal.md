# 一、简介
- Canal是阿里开源的binlog同步工具。可以解析binlog，并将解析后的数据同步到任何目标存储中。

# 二、Canal工作原理
- 1、mysql master节点将改变记录保存到二进制binlog文件中。
- 2、canal 把自己伪装成mysql slave节点,向master节点发送dump binlog请求。master节点收到请求并找到对应binlog文件及binlog位置pos。
- 3、master根据pos读取binlog event，不断发往slave节点(也就是canal)。
- 4、slave节点收到binlog events并拷贝到slave的中继日志。
- 5、slave结点回放中继日志中的event并同步。
- 6、新的binlog被master不断广播到slave节点，slave节点源源不断解析同步。

# 三、Canal目录结构
```
canal-1.0.24/
├── bin
│   ├── canal.pid 
│   ├── startup.bat 启动canal server脚本
│   ├── startup.sh  启动canal server脚本
│   └── stop.sh     停止canal server脚本
├── conf
│   ├── canal.properties common属性,是全局instance配置文件,被多个instance实例共享
│   ├── canal_test  instance实例配置目录
│   │   ├── instance.properties instance实例配置文件
│   │   ├── meta.dat 记录Instance实例消费binlog position位置等信息
│   ├── example 默认instance实例
│   │   └── instance.properties 
│   ├── logback.xml 日志分割
│   └── spring instance实例可选处理模式
│       ├── default-instance.xml 
│       ├── file-instance.xml 基于文件
│       ├── group-instance.xml
│       ├── local-instance.xml
│       └── memory-instance.xml 基于内存
├── lib 
└── logs
    ├── canal canal server运行日志
    │   └── canal.log
    ├── canal_test instance实例日志
    │   ├── canal_test.log
    │   └── meta.log
    └── example 默认instance实例日志
        └── example.log
```

# 四、Canal 2种方式部署

## 1）配置Mysql
```
MySQL 开启Binlog
修改/etc/my.cnf 配置文件,增加如下配置

[root@node2 ~]# vim /etc/my.cnf

#开启binlog
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

## 2）MySQL 配置Canal Server权限
```
CREATE USER 'canal_sync'@'%' IDENTIFIED BY 'canal_sync123';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal_sync'@'%';
FLUSH PRIVILEGES;
```

## 3）MySQL 建库建表
```
create database canal_test;
use canal_test;
create table if not exists `user_info`(
   `userid` int,
   `name` varchar(100),
   `age` int
)engine=innodb default charset=utf8;
```

# 五、Canal Server单节点模式
```
1、Canal Server单节点模式,Canal Client可采用多Client多活或单Client进程的方式。但要注意存在的问题。
    存在问题:
        (1)Server端会有单点问题。
        (2)多Client多活，同时工作，并互为主备。但无法保证binlog的顺序。实际情况下一个Client进程加监控就足以满足需要。
2、单节点模式binlog postion偏移量记录的位置:每个instance配置目录下的meta.dat文件中。如canal-1.0.24/conf/canal_test/meta.dat
```

### Server端配置
```
下载解压
[root@node3 software]# pwd
/data/software

[root@node3 software]# wget https://github.com/alibaba/canal/releases/download/canal-1.0.24/canal.deployer-1.0.24.tar.gz

[root@node3 software]# mkdir canal-1.0.24

[root@node3 software]# tar -zxvf canal.deployer-1.0.24.tar.gz -C canal-1.0.24
```

### 配置Instance
```
[root@node3 conf]# pwd
/data/software/canal-1.0.24/conf

#约定以要同步的库名作为配置文件目录名
[root@node3 conf]# cp -r example/ canal_test

[root@node3 conf]# vim canal_test/instance.properties
#slaveId
#每个instance都会伪装成一个mysql slave节点
#同一个mysql实例(待同步的mysql节点),此slaveId应该唯一
#若是集群模式,则同一集群中,相同的instance,此slaveId应相同
canal.instance.mysql.slaveId = 111101

#master 库
#canal运行时首要连接库 可以为mysql 主库
#如果只能基于从库的binlog,这里用mysql从库也可
canal.instance.master.address = node2:3306
#起始binlog文件
canal.instance.master.journal.name =
#起始binlog偏移量,同步该binlog位点后的数据
canal.instance.master.position =
#起始binlog时间戳,找到该时间戳对应的binlog位点后开始同步
canal.instance.master.timestamp =

#standby 库
#canal.instance.standby.address =
#canal.instance.standby.journal.name =
#canal.instance.standby.position =
#canal.instance.standby.timestamp =

#mysql 数据库账号
canal.instance.dbUsername = canal_sync
canal.instance.dbPassword = canal_sync123
#默认数据库
canal.instance.defaultDatabaseName =
canal.instance.connectionCharset = UTF-8

#注意:
#(1)这里黑白名单可以覆盖defaultDatabaseName。
#(2)如果Client端 配置了connector.subscribe则会覆盖黑白名单配置
#表过滤--白名单 只监听库表
#如testDB\..*只监听testDB数据库,testDB\.test_1 只监听testDB库中test_1表。多个用逗号分开
canal.instance.filter.regex = .*\\..*
#表过滤--黑名单 排除库表
canal.instance.filter.black.regex =
```

### 启动
```
[root@node3 canal-1.0.24]# bin/startup.sh

查看启动日志,根据日志中的报错排查问题
[root@node3 canal-1.0.24]# tail -f logs/canal_test/canal_test.log
```

### Client端消费
```
pom依赖
<dependency>
    <groupId>com.alibaba.otter</groupId>
    <artifactId>canal.client</artifactId>
    <version>1.0.24</version>
</dependency>

import com.alibaba.otter.canal.client.CanalConnector;
import com.alibaba.otter.canal.client.CanalConnectors;
import com.alibaba.otter.canal.protocol.CanalEntry;
import com.alibaba.otter.canal.protocol.Message;

import java.net.InetSocketAddress;
import java.util.List;


public class ClientSample {
    public static void main(String args[]) {
        // 单连接
        CanalConnector connector = CanalConnectors.newSingleConnector(
                new InetSocketAddress("node3", 11111), "canal_test", "", "");
        // 集群连接
        //CanalConnector connector = CanalConnectors.newClusterConnector("192.168.113.101:2181,192.168.113.102:2181,192.168.113.103:2181/canal/cluster1", "canal_test", "", "");
        //计数器
        int emptyCount = 0;
        //一次最多拉多少条Message
        //注意:

        int batchSize = 1000;
        try {
            //和server建立连接
            connector.connect();
            //订阅表
            connector.subscribe("canal_test.user_info");
            //回滚到上次ack的位置
            connector.rollback();
            //最大空闲次数
            int maxEmptyCount = 1000;
            //死循环去拉取数据
            while (emptyCount < maxEmptyCount) {
                //尝试最多拿batchSize条记录
                //注意:getWithoutAck一次，对应一个Message。
                //一个Message有一个MessageID,还有一个List<CanalEntry.Entry>
                Message message = connector.getWithoutAck(batchSize);
                long batchId = message.getId();
                int size = message.getEntries().size();
                //没有数据---等待
                if (batchId == -1 || size == 0) {
                    emptyCount++;
//                    System.out.println("empty count : " + emptyCount);
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                } else {
                    //拿到数据---开始解析--发送到目的地如kafka/elasticsearch/redis/hbase...等
                    emptyCount = 0;
                    //这里打印内容
                    printEntry(message.getEntries());
                }

                connector.ack(batchId); // 提交确认
                //connector.rollback(batchId); // 处理失败, 回滚数据
            }

            System.out.println("empty too many times, exit");
        } finally {
            connector.disconnect();
        }
    }

    private static void printEntry(List<CanalEntry.Entry> entrys) {
        for (CanalEntry.Entry entry : entrys) {
            //该条数据的数据类型是事务开始或事务结束，不是binlog 二进制数据本身，就跳过继续处理
            //注意:这里是有bug的，当mysql开启binlog，且为Row行模式，且开启了在binlog中显示原始SQL。
            //这时就会有一种新增的类型:CanalEntry.EventType.QUERY
            // 原始
            //if (entry.getEntryType() == CanalEntry.EntryType.TRANSACTIONBEGIN || entry.getEntryType() == CanalEntry.EntryType.TRANSACTIONEND) {
            //    continue;
            //}
            // 修改为 只保留binlog部分对应的Entry并解析
            if (entry.getEntryType() == CanalEntry.EntryType.TRANSACTIONBEGIN //跳过事务开始的Entry
                    || entry.getEntryType() == CanalEntry.EntryType.TRANSACTIONEND //跳过事务结束的Entry
                    || entry.getHeader().getEventType() == CanalEntry.EventType.QUERY //跳过事务为原始SQL的Entry
                    ) {
                continue;
            }
            //得到当前行变化的数据Before、After
            CanalEntry.RowChange rowChage = null;
            try {
                rowChage = CanalEntry.RowChange.parseFrom(entry.getStoreValue());
            } catch (Exception e) {
                throw new RuntimeException("ERROR ## parser of eromanga-event has an error , data:" + entry.toString(),
                        e);
            }

            //事件类型
            CanalEntry.EventType eventType = rowChage.getEventType();
            System.out.println(String.format("================> binlog[%s:%s] , name[%s,%s] , eventType : %s",
                    entry.getHeader().getLogfileName(), //binlog文件名
                    entry.getHeader().getLogfileOffset(),//binlog offset
                    entry.getHeader().getSchemaName(),//库名
                    entry.getHeader().getTableName(),//表名
                    eventType //事件类型
            ));

            for (CanalEntry.RowData rowData : rowChage.getRowDatasList()) {
                //INSERT
                if (eventType == CanalEntry.EventType.INSERT) {
                    printColumn(rowData.getAfterColumnsList());
                //DELETE
                } else if (eventType == CanalEntry.EventType.DELETE) {
                    printColumn(rowData.getBeforeColumnsList());
                //UPDATE
                } else if (eventType == CanalEntry.EventType.UPDATE) {
                    System.out.println("-------> before");
                    printColumn(rowData.getBeforeColumnsList());
                    System.out.println("-------> after");
                    printColumn(rowData.getAfterColumnsList());
                }
            }
        }
    }

    private static void printColumn(List<CanalEntry.Column> columns) {
        for (CanalEntry.Column column : columns) {
            //列名:列值 该列是否被更新
            System.out.println(column.getName() + " : " + column.getValue() + "    update=" + column.getUpdated());
        }
    }

}
```

### Insert
```
#mysql 插入
mysql> insert into user_info(userid,name,age) values(3,'name3',3);

#canal 解析binlog结果
================> binlog[mysql-binlog.000004:1694] , name[canal_test,user_info] , eventType : INSERT
userid : 3    update=true
name : name3    update=true
age : 3    update=true
```

### Delete
```
#mysql 删除
mysql> delete from user_info where userid=3;

#canal 解析binlog结果
================> binlog[mysql-binlog.000004:1898] , name[canal_test,user_info] , eventType : DELETE
userid : 3    update=false
name : name3    update=false
age : 3    update=false
```

### Update
```
#mysql 修改
mysql> update user_info set name='name13',age=13 where userid=1;

#canal 解析binlog结果
================> binlog[mysql-binlog.000004:2528] , name[canal_test,user_info] , eventType : UPDATE
-------> before
userid : 1    update=false
name : name1    update=false
age : 20    update=false
-------> after
userid : 1    update=false
name : name13    update=true
age : 13    update=true
```

# 六、Canal Server集群模式(HA模式)
```
Canal Server集群模式Server端和Client端都采用单主多活的方式。这种协调由Zookeeper承担。
除此之外，Zookeeper还保存了一些元数据信息，如备选Canal Server、当前正在运行的Canal Server、Binlog Position信息等。
```

### Server端配置

- Server1
```
[root@node3 canal-1.0.24]# vim conf/canal.properties
#同一个canal server集群,此id唯一
canal.id= 1
canal.ip=
#canal client 端访问的端口
canal.port= 11111
#zk的地址 如果多个Canal 集群共享一个ZK，那么每个Canal集群应使用同一且唯一的rootpath
canal.zkServers= node1:2181,node2:2181,node3:2181/canal/cluster1
#canal 持久化数据到zk上的更新频率,单位毫秒
canal.zookeeper.flush.period = 1000
#canal持久化数据到file上的目录,默认和instance.properties为同一目录
canal.file.data.dir = ${canal.conf.dir}
#canal持久化数据到file上的更新频率，单位毫秒
canal.file.flush.period = 1000
#canal内存中可缓存buffer记录数,为2的指数
canal.instance.memory.buffer.size = 16384
#内存记录的单位大小，默认1KB，和buffer.size组合决定最终的内存使用大小
canal.instance.memory.buffer.memunit = 1024
#canal内存中数据缓存模式
#ITEMSIZE : 根据buffer.size进行限制，只限制记录的数量
#MEMSIZE : 根据buffer.size * buffer.memunit的大小，限制缓存记录的大小
canal.instance.memory.batch.mode = MEMSIZE

#是否开启心跳检查
canal.instance.detecting.enable = false
#canal.instance.detecting.sql = insert into retl.xdual values(1,now()) on duplicate key update x=now()
#心跳检查sql
canal.instance.detecting.sql = select 1
#心跳检查频率，单位秒
canal.instance.detecting.interval.time = 3
#心跳检查失败重试次数
canal.instance.detecting.retry.threshold = 3
#心跳检查失败后，是否开启自动mysql自动切换
#心跳检查失败超过阀值后，如果该配置为true，canal就会自动链到mysql备库获取binlog数据
canal.instance.detecting.heartbeatHaEnable = false

# support maximum transaction size, more than the size of the transaction will be cut into multiple transactions delivery
canal.instance.transaction.size =  1024
#canal发生mysql切换时，在新的mysql库上查找binlog时需要往前查找的时间，单位秒
#mysql主备库可能存在解析延迟或者时钟不统一，需要回退一段时间，保证数据不丢
canal.instance.fallbackIntervalInSeconds = 60

#网络链接参数
canal.instance.network.receiveBufferSize = 16384
canal.instance.network.sendBufferSize = 16384
canal.instance.network.soTimeout = 30

#是否忽略DCL的query语句，比如grant/create user等
canal.instance.filter.query.dcl = false
#是否忽略DML的query语句，比如insert/update/delete
canal.instance.filter.query.dml = false
#是否忽略DDL的query语句，比如create table/alater table/drop table/rename table/create index/drop index.
canal.instance.filter.query.ddl = false
#
canal.instance.filter.table.error = false
canal.instance.filter.rows = false

# binlog format/image check
canal.instance.binlog.format = ROW,STATEMENT,MIXED
canal.instance.binlog.image = FULL,MINIMAL,NOBLOB

#ddl语句是否隔离发送，开启隔离可保证每次只返回发送一条ddl数据，不和其他dml语句混合返回
canal.instance.get.ddl.isolation = false

#################################################
#########       destinations        #############
#################################################
#当前节点对应的destinations
#这里定义了canal.destinations后，需要在canal.conf.dir对应的目录下建立同名目录
canal.destinations= example
#配置文件根目录
canal.conf.dir = ../conf
#开启instance自动扫描
#如果配置为true，canal.conf.dir目录下的instance配置变化会自动触发：
#a. instance目录新增： 触发instance配置载入，lazy为true时则自动启动
#b. instance目录删除：卸载对应instance配置，如已启动则进行关闭
#c. instance.properties文件变化：reload instance配置，如已启动自动进行重启操作
canal.auto.scan = true
#instance自动扫描的间隔时间，单位秒
canal.auto.scan.interval = 5

#全局配置加载方式
canal.instance.global.mode = spring
#全局lazy模式
canal.instance.global.lazy = false
#全局的manager配置方式的链接信息
#canal.instance.global.manager.address = 127.0.0.1:1099
#canal.instance.global.spring.xml = classpath:spring/memory-instance.xml
#全局的spring配置方式的组件文件
canal.instance.global.spring.xml = classpath:spring/file-instance.xml
#canal.instance.global.spring.xml = classpath:spring/default-instance.xml
```

- Server2
```
[root@node3 software]# pwd
/data/software
[root@node3 software]# scp -r canal-1.0.24/ root@node1:/data/software

#修改canal.properties
[root@node1 canal-1.0.24]# vim conf/canal.properties
canal.id= 2
```

### 创建Zookeeper Znode
```
连上任意一台zookeeper
[root@node1 zookeeper]# bin/zkCli.sh

创建znode
create /canal ""
create /canal/cluster1 ""
```

### 启动所有Server
```
[root@node1 canal-1.0.24]# bin/startup.sh
[root@node3 canal-1.0.24]# bin/startup.sh
```

## 查看Zookeeper中Canal数据

### Instance 候选canal server的列表
```
#可看到两个候选canal server
[zk: localhost:2181(CONNECTED) 17] ls /canal/cluster1/otter/canal/destinations/canal_test/cluster
[192.168.113.103:11111, 192.168.113.101:11111]
```

### Instance 当前服务的canal server
```
[zk: localhost:2181(CONNECTED) 18] get /canal/cluster1/otter/canal/destinations/canal_test/running
{"active":true,"address":"192.168.113.101:11111","cid":1}
cZxid = 0x2000000028
ctime = Wed Aug 08 03:59:52 CST 2018
mZxid = 0x2000000028
mtime = Wed Aug 08 03:59:52 CST 2018
pZxid = 0x2000000028
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x16515ef4dae0000
dataLength = 57
numChildren = 0
```

### Instance对应的消费者
```
注意:需要在消费者启动后才能看到。
[zk: localhost:2181(CONNECTED) 23] get /canal/cluster1/otter/canal/destinations/canal_test/1001/running
{"active":true,"address":"192.168.113.1:54048","clientId":1001}
cZxid = 0x2000000036
ctime = Wed Aug 08 04:09:25 CST 2018
mZxid = 0x2000000037
mtime = Wed Aug 08 04:09:26 CST 2018
pZxid = 0x2000000036
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x36515ef48010001
dataLength = 63
numChildren = 0
```

### Client端消费
```
同server单节点模式，只需要修改一行即可。
使用集群连接:
    CanalConnector connector = CanalConnectors.newClusterConnector("192.168.113.101:2181,192.168.113.102:2181,192.168.113.103:2181/canal/cluster1", "canal_test", "", "");
```

### 总结和注意
- 1、生产环境下尽量采用HA的方式。
- 2、关于Canal消费binlog的顺序，为保证binlog严格有序，尽量不要用多线程。
- 3、如果Canal消费binlog后的数据要发往kafka，又要保证有序，kafka topic 的partition可以设置成1个分区。
