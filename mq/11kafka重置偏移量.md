# 重置偏移量

- 通过 kafka-consumer-groups.sh 针对 >= kafka 0.11

0.11.0.0+ 版本丰富了kafka-consumer-groups脚本的功能，用户可以直接使用该脚本很方便地为已有的consumer group重新设置位移，但前提必须是consumer group必须是inactive的，即不能是处于正在工作中的状态。

## 如何确定 consumer group 是不是 inactive

活跃中
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group
TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG        CONSUMER-ID                                    HOST            CLIENT-ID
test_find       0          3               3               0          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer-1
test_find       4          2               2               0          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer-1
test_find       3          3               3               0          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer-1
test_find       1          3               3               0          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer-1
test_find       2          3               3               0          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer-1
```
- TOPIC：该group里消费的topic名称
- PARTITION：分区编号
- CURRENT-OFFSET：该分区当前消费到的offset
- LOG-END-OFFSET：该分区当前latest offset
- LAG：消费滞后区间，为LOG-END-OFFSET-CURRENT-OFFSET，具体大小需要看应用消费速度和生产者速度，一般过大则可能出现消费跟不上，需要引起应用注意
- CONSUMER-ID：server端给该分区分配的consumer编号
- HOST：消费者所在主机
- CLIENT-ID：消费者id，一般由应用指定

非活跃
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group
Consume group 'my-group' has no active members.

TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG        CONSUMER-ID       HOST             CLIENT-ID
test_find       0          3               3               0          -                 -                -
test_find       4          2               2               0          -                 -                -
test_find       3          3               3               0          -                 -                -
test_find       1          3               3               0          -                 -                -
test_find       2          3               3               0          -                 -                -
```

## 执行脚本给出的提示
```
# bin/kafka-consumer-groups.sh  --help

Option                                  Description                            
------                                  -----------                            
--all-topics                            Consider all topics assigned to a      
                                          group in the `reset-offsets` process.
--bootstrap-server <String: server to   REQUIRED: The server(s) to connect to. 
  connect to>                                                                  
--by-duration <String: duration>        Reset offsets to offset by duration    
                                          from current timestamp. Format:      
                                          'PnDTnHnMnS'                         
--command-config <String: command       Property file containing configs to be 
  config property file>                   passed to Admin Client and Consumer. 
--delete                                Pass in groups to delete topic         
                                          partition offsets and ownership      
                                          information over the entire consumer 
                                          group. For instance --group g1 --    
                                          group g2                             
--describe                              Describe consumer group and list       
                                          offset lag (number of messages not   
                                          yet processed) related to given      
                                          group.                               
--dry-run                               Only show results without executing    
                                          changes on Consumer Groups.          
                                          Supported operations: reset-offsets. 
--execute                               Execute operation. Supported           
                                          operations: reset-offsets.           
--export                                Export operation execution to a CSV    
                                          file. Supported operations: reset-   
                                          offsets.                             
--from-file <String: path to CSV file>  Reset offsets to values defined in CSV 
                                          file.                                
--group <String: consumer group>        The consumer group we wish to act on.  
--list                                  List all consumer groups.              
--members                               Describe members of the group. This    
                                          option may be used with '--describe' 
                                          and '--bootstrap-server' options     
                                          only.                                
                                        Example: --bootstrap-server localhost: 
                                          9092 --describe --group group1 --    
                                          members                              
--offsets                               Describe the group and list all topic  
                                          partitions in the group along with   
                                          their offset lag. This is the        
                                          default sub-action of and may be     
                                          used with '--describe' and '--       
                                          bootstrap-server' options only.      
                                        Example: --bootstrap-server localhost: 
                                          9092 --describe --group group1 --    
                                          offsets                              
--reset-offsets                         Reset offsets of consumer group.       
                                          Supports one consumer group at the   
                                          time, and instances should be        
                                          inactive                             
                                        Has 2 execution options: --dry-run     
                                          (the default) to plan which offsets  
                                          to reset, and --execute to update    
                                          the offsets. Additionally, the --    
                                          export option is used to export the  
                                          results to a CSV format.             
                                        You must choose one of the following   
                                          reset specifications: --to-datetime, 
                                          --by-period, --to-earliest, --to-    
                                          latest, --shift-by, --from-file, --  
                                          to-current.                          
                                        To define the scope use --all-topics   
                                          or --topic. One scope must be        
                                          specified unless you use '--from-    
                                          file'.                               
--shift-by <Long: number-of-offsets>    Reset offsets shifting current offset  
                                          by 'n', where 'n' can be positive or 
                                          negative.                            
--state                                 Describe the group state. This option  
                                          may be used with '--describe' and '--
                                          bootstrap-server' options only.      
                                        Example: --bootstrap-server localhost: 
                                          9092 --describe --group group1 --    
                                          state                                
--timeout <Long: timeout (ms)>          The timeout that can be set for some   
                                          use cases. For example, it can be    
                                          used when describing the group to    
                                          specify the maximum amount of time   
                                          in milliseconds to wait before the   
                                          group stabilizes (when the group is  
                                          just created, or is going through    
                                          some changes). (default: 5000)       
--to-current                            Reset offsets to current offset.       
--to-datetime <String: datetime>        Reset offsets to offset from datetime. 
                                          Format: 'YYYY-MM-DDTHH:mm:SS.sss'    
--to-earliest                           Reset offsets to earliest offset.      
--to-latest                             Reset offsets to latest offset.        
--to-offset <Long: offset>              Reset offsets to a specific offset.    
--topic <String: topic>                 The topic whose consumer group         
                                          information should be deleted or     
                                          topic whose should be included in    
                                          the reset offset process. In `reset- 
                                          offsets` case, partitions can be     
                                          specified using this format: `topic1:
                                          0,1,2`, where 0,1,2 are the          
                                          partition to be included in the      
                                          process. Reset-offsets also supports 
                                          multiple topic inputs.               
--verbose                               Provide additional information, if     
                                          any, when describing the group. This 
                                          option may be used with '--          
                                          offsets'/'--members'/'--state' and   
                                          '--bootstrap-server' options only.   
                                        Example: --bootstrap-server localhost: 
                                          9092 --describe --group group1 --    
                                          members --verbose           
```

## 确定topic作用域——当前有3种作用域指定方式：
- --all-topics（为consumer group下所有topic的所有分区调整位移），
- --topic t1 --topic t2（为指定的若干个topic的所有分区调整位移），
- --topic t1:0,1,2（为指定的topic分区调整位移）

## 确定位移重设策略——当前支持8种设置规则：
- --to-earliest：把位移调整到分区当前最小位移
- --to-latest：把位移调整到分区当前最新位移
- --to-current：把位移调整到分区当前位移
- --to-offset `<offset>`： 把位移调整到指定位移处
- --shift-by N： 把位移调整到当前位移 + N处，注意N可以是负数，表示向前移动
- --to-datetime `<datetime>`：把位移调整到大于给定时间的最早位移处，datetime格式是yyyy-MM-ddTHH:mm:ss.xxx，比如2017-08-04T00:00:00.000
- --by-duration `<duration>`：把位移调整到距离当前时间指定间隔的位移处，duration格式是PnDTnHnMnS，比如PT0H5M0S
- --from-file `<file>`：从CSV文件中读取调整策略

## 确定执行方案——当前支持3种方案：
- 什么参数都不加：只是打印出位移调整方案，不具体执行
- --execute：执行真正的位移调整
- --export：把位移调整方案按照CSV格式打印，方便用户成csv文件，供后续直接使用
   

针对上面的8种策略，本文重点演示前面7种策略。首先，我们创建一个测试topic，5个分区，并发送5,000,000条测试消息：
```
> bin/kafka-topics.sh --zookeeper localhost:2181 --create --partitions 5 --replication-factor 1 --topic test
Created topic "test".
     
> bin/kafka-producer-perf-test.sh --topic test --num-records 5000000 --throughput -1 --record-size 100 --producer-props bootstrap.servers=localhost:9092 acks=-1
1439666 records sent, 287760.5 records/sec (27.44 MB/sec), 75.7 ms avg latency, 317.0 max latency.
1541123 records sent, 308163.0 records/sec (29.39 MB/sec), 136.4 ms avg latency, 480.0 max latency.
1878025 records sent, 375529.9 records/sec (35.81 MB/sec), 58.2 ms avg latency, 600.0 max latency.
5000000 records sent, 319529.652352 records/sec (30.47 MB/sec), 86.33 ms avg latency, 600.00 ms max latency, 38 ms 50th, 319 ms 95th, 516 ms 99th, 591 ms 99.9th.
```

然后，启动一个console consumer程序，组名设置为test-group：
```
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning --consumer-property group.id=test-group
..............
```
 
待运行一段时间后关闭consumer程序将group设置为inactive。现在运行kafka-consumer-groups.sh脚本首先确定当前group的消费进度： 
```
bogon       :kafka_0       .1  1 huxi$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --describe
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION CURRENT-OFFSET LOG-END-OFFSET LAG CONSUMER-ID                                     HOST       CLIENT-ID
test  0         1000000        1000000        0   consumer-1-8688633a-2f88-4c41-89ca-fd0cd6d19ec7 /127.0.0.1 consumer-1
test  1         1000000        1000000        0   consumer-1-8688633a-2f88-4c41-89ca-fd0cd6d19ec7 /127.0.0.1 consumer-1
test  2         1000000        1000000        0   consumer-1-8688633a-2f88-4c41-89ca-fd0cd6d19ec7 /127.0.0.1 consumer-1
test  3         1000000        1000000        0   consumer-1-8688633a-2f88-4c41-89ca-fd0cd6d19ec7 /127.0.0.1 consumer-1
test  4         1000000        1000000        0   consumer-1-8688633a-2f88-4c41-89ca-fd0cd6d19ec7 /127.0.0.1 consumer-1
```
- 由上面输出可知，当前5个分区LAG列的值都是0，表示全部消费完毕。现在我们演示下如何重设位移。

 
1. --to-earliest
```
bogon:kafka_0.11 huxi$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --reset-offsets --all-topics --to-earliest --execute
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION NEW-OFFSET 
test  0         0 
test  1         0 
test  4         0 
test  3         0 
test  2         0
```
- 上面输出表明，所有分区的位移都已经被重设为0

2. --to-latest
```
bogon:kafka_0.11 huxi$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --reset-offsets --all-topics --to-latest --execute
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION NEW-OFFSET 
test  0         1000000 
test  1         1000000 
test  4         1000000 
test  3         1000000 
test  2         1000000
```
- 上面输出表明，所有分区的位移都已经被重设为最新位移，即1,000,000

3. --to-offset `<offset>`
```
bogon:kafka_0.11 huxi$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --reset-offsets --all-topics --to-offset 500000 --execute
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION NEW-OFFSET 
test  0         500000 
test  1         500000 
test  4         500000 
test  3         500000 
test  2         500000
```
- 需要注意的是这里面的消息消费过后可能超出了kafka日志留存策略，所以你只能控制到近期仍保留的日志偏移。
- 上面输出表明，所有分区的位移都已经调整为给定的500000

4. --to-current
```
bogon:kafka_0.11 huxi$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --reset-offsets --all-topics --to-current --execute
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION NEW-OFFSET 
test  0         500000 
test  1         500000 
test  4         500000 
test  3         500000 
test  2         500000
```
- 输出表明所有分区的位移都已经被移动到当前位移（这个有点傻，因为位移距上一步没有变动）
 
5. --shift-by N
```
bogon:kafka_0.11 huxi$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --reset-offsets --all-topics --shift-by -100000 --execute
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION NEW-OFFSET 
test  0         400000 
test  1         400000 
test  4         400000 
test  3         400000 
test  2         400000
```
- 输出表明所有分区的位移被移动到(500000 - 100000) = 400000处

6. --to-datetime
```
# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --reset-offsets --all-topics --to-datetime 2017-08-04T14:30:00.000
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION NEW-OFFSET 
test  0         1000000 
test  1         1000000 
test  4         1000000 
test  3         1000000 
test  2         1000000
```
- 将所有分区的位移调整为2017年8月4日14：30之后的最早位移

> 注意：这里需要根据时区设置时间，如以东8时区进行设置例子：

```
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group group --reset-offsets --all-topics --to-datetime 2018-10-23T18:50:00.000+08:00 --execute
```
- 时间 ：  2018-10-23T18:50:00.000+08:00

```
# kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group group --reset-offsets --topic test_find --to-datetime 2018-10-23T18:50:00.000+08:00 --execute
     
TOPIC           PARTITION  NEW-OFFSET     
test_find       0          2              
test_find       4          2              
test_find       3          2              
test_find       1          2              
test_find       2          2    
``` 

7. --by-duration
```
bogon:kafka_0.11 huxi$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --reset-offsets --all-topics --by-duration PT0H30M0S
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).
     
TOPIC PARTITION NEW-OFFSET 
test  0         0 
test  1         0 
test  4         0 
test  3         0 
test  2         0
```
- 将所有分区位移调整为30分钟之前的最早位移

