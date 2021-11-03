# DataX
- DataX是阿里开源的离线数据同步工具,可以实现包括 MySQL、Oracle、MongoDB、Hive、HDFS、HBase、Elasticsearch等各种异构数据源之间的高效同步。

# DataX原理

## 设计理念

- 为了解决异构数据源同步问题，DataX将复杂的网状同步链路变成星型链路，DataX作为中间传输载体负责连接各种数据源。当需要接入一个新的数据源的时候，只需将此数据源对接到DataX，便能跟已有数据源做到无缝数据同步。

## 框架设计

采用Framework + plugin架构构建。将数据源读取和写入抽象成为Reader/Writer插件，纳入到整个同步框架中。
- Reader：数据采集模块，负责采集数据源的数据，将数据发送给Framework。
- Writer： 数据写入模块，负责不断从Framework取数据，并将数据写入到目的端。
- Framework：Framework用于连接Reader和Writer，作为两者的数据传输通道，并处理缓冲，流控，并发，数据转换等核心技术问题。

## 核心架构

- 核心模块介绍
  - DataX完成单个数据同步的作业，我们称之为Job，DataX接受到一个Job之后，将启动一个进程来完成整个作业同步过程。DataX Job模块是单个作业的中枢管理节点，承担了数据清理、子任务切分(将单一作业计算转化为多个子Task)、TaskGroup管理等功能。
  - DataXJob启动后，会根据不同的源端切分策略，将Job切分成多个小的Task(子任务)，以便于并发执行。Task便是DataX作业的最小单元，每一个Task都会负责一部分数据的同步工作。
  - 切分多个Task之后，DataX Job会调用Scheduler模块，根据配置的并发数据量，将拆分成的Task重新组合，组装成TaskGroup(任务组)。每一个TaskGroup负责以一定的并发运行完毕分配好的所有Task，默认单个任务组的并发数量为5。
  - 每一个Task都由TaskGroup负责启动，Task启动后，会固定启动Reader—>Channel—>Writer的线程来完成任务同步工作。
  - DataX作业运行起来之后， Job监控并等待多个TaskGroup模块任务完成，等待所有TaskGroup任务完成后Job成功退出。否则，异常退出，进程退出值非0。
- 调度流程
  - 举例来说，用户提交了一个DataX作业，并且配置了20个并发，目的是将一个100张分表的mysql数据同步到odps里面。 DataX的调度决策思路是：
  - DataXJob根据分库分表切分成了100个Task。
  - 根据20个并发，DataX计算共需要分配4个TaskGroup。
  - 4个TaskGroup平分切分好的100个Task，每一个TaskGroup负责以5个并发共计运行25个Task。

# DataX 部署

## 工具部署
```shell
[root@node2 /data/software]# wget http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz
[root@node2 /data/software]# tar -zxvf datax.tar.gz
[root@node2 /data/software/datax]# python bin/datax.py job/job.json #自检
```

##目录结构
```
 [root@node2 /data/software/datax]# tree -L 3 -I '*jar*'
    .
    ├── bin 启动脚本
    │   ├── datax.py
    │   ├── dxprof.py
    │   └── perftrace.py
    ├── conf 核心配置
    │   ├── core.json
    │   └── logback.xml
    ├── job  job目录
    │   └── job.json
    ├── lib 核心类库
    ├── log
    ├── log_perf
    ├── plugin 插卡目录
    │   ├── reader 
    │   │   ├── drdsreader
    │   │   ├── ftpreader
    │   │   ├── hbase094xreader
    │   │   ├── hbase11xreader
    │   │   ├── hdfsreader
    │   │   ├── mongodbreader
    │   │   ├── mysqlreader
    │   │   ├── odpsreader
    │   │   ├── oraclereader
    │   │   ├── ossreader
    │   │   ├── otsreader
    │   │   ├── otsstreamreader
    │   │   ├── postgresqlreader
    │   │   ├── rdbmsreader
    │   │   ├── sqlserverreader
    │   │   ├── streamreader
    │   │   └── txtfilereader
    │   └── writer
    │       ├── adswriter
    │       ├── drdswriter
    │       ├── ftpwriter
    │       ├── hbase094xwriter
    │       ├── hbase11xsqlwriter
    │       ├── hbase11xwriter
    │       ├── hdfswriter
    │       ├── mongodbwriter
    │       ├── mysqlwriter
    │       ├── ocswriter
    │       ├── odpswriter
    │       ├── oraclewriter
    │       ├── osswriter
    │       ├── otswriter
    │       ├── postgresqlwriter
    │       ├── rdbmswriter
    │       ├── sqlserverwriter
    │       ├── streamwriter
    │       └── txtfilewriter
    ├── script
    │   └── Readme.md
    └── tmp
        └── readme.txt
```

# DataX全量同步 Mysql-HDFS

## DataX配置
```
 {
    "job":{
        "setting":{
            "errorLimit":{
                "record":1,
                "percentage":0.2
            },
            "speed": {
                 "channel":1
            }
        },
        "content":[
            {
                "reader":{
                    "name":"mysqlreader",
                    "parameter":{
                        "username":"root",
                        "password":"111",
                        "column":["id","log_type","event_time","uid"],
            "where":"event_time>='2018-08-10 01:01:01' and event_time<='2018-08-10 01:10:01'",
            "connection":[ { "table":[ "log_0", "log_1", "log_2" ], "jdbcUrl":[ "jdbc:mysql://localhost:3306/test" ] } ] }
                },
                "writer":{
                    "name":"hdfswriter",
                    "parameter":{
                        "defaultFS":"hdfs://node1:8020",
                        "fileType":"text",
                        "path":"/test/access_log",
                        "fileName":"log_",
                        "fieldDelimiter":"\t",
                        "writeMode": "append",
                        "column":[ { "name": "id", "type": "bigint" }, { "name": "log_type", "type": "string" }, { "name": "event_time", "type": "string" }, { "name": "uid", "type": "string" } ] }
                }
            }
        ]
    }
}
```

## DataX运行结果
```
 [root@node2 /data/software/datax]# python bin/datax.py -j"-Xms125m -Xmx125m" job/mysql_hdfs.json

任务启动时刻                    : 2018-08-10 23:51:58
任务结束时刻                    : 2018-08-10 23:52:24
任务总计耗时                    :                 25s
任务平均流量                    :                5B/s
记录写入速度                    :              0rec/s
读出记录总数                    :                   3
读写失败总数                    :                   0

[root@node3 /data/software]# hdfs dfs -cat /test/access_log/*
1   appError    2018-08-10 01:01:01 2
2   appError    2018-08-10 01:10:01 2
3   appError    2018-08-10 01:01:01 2
```

## DataX增量同步 Mysql-HDFS

### 思路
```
增量模板+shell+crontab。
1.定义datax任务运行模板文件 如"where":"event_time>='${start_time}' and event_time<='${end_time}'"。
2.每次定时任务启动时根据上次偏移量替换模板文件中增量变量。
3.运行完后记录此次偏移量。
```

### 注意
```
1.时间增量,需记录每次时间偏移量。
2.自增id增量,需记录每次自增id偏移量。
3.不论是时间增量还是自增id增量,记得给数据同步留下足够的时间。如从库同步延迟。
4.实际中,要结合数据库索引情况合理设置增量条件，提高每次查询速度。
5.若没有任何增量规律,datax只能做全量同步。
```
