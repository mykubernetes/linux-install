kafka-reassign-partitions.sh是kafka提供的用来重新分配partition和replica到broker上的工具

```
./kafka-reassign-partitions.sh --help
This tool helps to move topic partitions between replicas.
Option                                  Description                           
------                                  -----------                           
--additional                            Execute this reassignment in addition 
                                          to any other ongoing ones. This     
                                          option can also be used to change   
                                          the throttle of an ongoing          
                                          reassignment.                       
--bootstrap-server <String: Server(s)   the server(s) to use for              
  to use for bootstrapping>               bootstrapping. REQUIRED if an       
                                          absolute path of the log directory  
                                          is specified for any replica in the 
                                          reassignment json file, or if --    
                                          zookeeper is not given.             
--broker-list <String: brokerlist>      The list of brokers to which the      
                                          partitions need to be reassigned in 
                                          the form "0,1,2". This is required  
                                          if --topics-to-move-json-file is    
                                          used to generate reassignment       
                                          configuration                       
--cancel                                Cancel an active reassignment.        
--command-config <String: Admin client  Property file containing configs to be
  property file>                          passed to Admin Client.             
--disable-rack-aware                    Disable rack aware replica assignment 
--execute                               Kick off the reassignment as specified
                                          by the --reassignment-json-file     
                                          option.                             
--generate                              Generate a candidate partition        
                                          reassignment configuration. Note    
                                          that this only generates a candidate
                                          assignment, it does not execute it. 
--help                                  Print usage information.              
--list                                  List all active partition             
                                          reassignments.                      
--preserve-throttles                    Do not modify broker or topic         
                                          throttles.                          
--reassignment-json-file <String:       The JSON file with the partition      
  manual assignment json file path>       reassignment configurationThe format
                                          to use is -                         
                                        {"partitions":                        
                                        	[{"topic": "foo",                    
                                        	  "partition": 1,                    
                                        	  "replicas": [1,2,3],               
                                        	  "log_dirs": ["dir1","dir2","dir3"] 
                                          }],                                 
                                        "version":1                           
                                        }                                     
                                        Note that "log_dirs" is optional. When
                                          it is specified, its length must    
                                          equal the length of the replicas    
                                          list. The value in this list can be 
                                          either "any" or the absolution path 
                                          of the log directory on the broker. 
                                          If absolute log directory path is   
                                          specified, the replica will be moved
                                          to the specified log directory on   
                                          the broker.                         
--replica-alter-log-dirs-throttle       The movement of replicas between log  
  <Long: replicaAlterLogDirsThrottle>     directories on the same broker will 
                                          be throttled to this value          
                                          (bytes/sec). This option can be     
                                          included with --execute when a      
                                          reassignment is started, and it can 
                                          be altered by resubmitting the      
                                          current reassignment along with the 
                                          --additional flag. The throttle rate
                                          should be at least 1 KB/s. (default:
                                          -1)                                 
--throttle <Long: throttle>             The movement of partitions between    
                                          brokers will be throttled to this   
                                          value (bytes/sec). This option can  
                                          be included with --execute when a   
                                          reassignment is started, and it can 
                                          be altered by resubmitting the      
                                          current reassignment along with the 
                                          --additional flag. The throttle rate
                                          should be at least 1 KB/s. (default:
                                          -1)                                 
--timeout <Long: timeout>               The maximum time in ms to wait for log
                                          directory replica assignment to     
                                          begin. (default: 10000)             
--topics-to-move-json-file <String:     Generate a reassignment configuration 
  topics to reassign json file path>      to move the partitions of the       
                                          specified topics to the list of     
                                          brokers specified by the --broker-  
                                          list option. The format to use is - 
                                        {"topics":                            
                                        	[{"topic": "foo"},{"topic": "foo1"}],
                                        "version":1                           
                                        }                                     
--verify                                Verify if the reassignment completed  
                                          as specified by the --reassignment- 
                                          json-file option. If there is a     
                                          throttle engaged for the replicas   
                                          specified, and the rebalance has    
                                          completed, the throttle will be     
                                          removed                             
--version                               Display Kafka version.                
--zookeeper <String: urls>              DEPRECATED: The connection string for 
                                          the zookeeper connection in the form
                                          host:port. Multiple URLS can be     
                                          given to allow fail-over.  Please   
                                          use --bootstrap-server instead.
```

常用选项：

| 参数 | 描述 | 例子 |
|------|-----|-------|
| --zookeeper | 连接zk | --zookeeper localhost:2181, localhost:2182 |
| --topics-to-move-json-file | 指定json文件,文件内容为topic配置 | --topics-to-move-json-file config/move-json-file.json |
| --generate | 尝试给出副本重分配的策略,该命令并不实际执行 |  |
| --broker-list | 指定具体的BrokerList,用于尝试给出分配策略,与--generate搭配使用 | --broker-list 0,1,2,3 |
| --reassignment-json-file | 指定要重分配的json文件,与--execute搭配使用 |  |
| --execute | 开始执行重分配任务,与--reassignment-json-file搭配使用 |  |
| --verify | 验证任务是否执行成功,当有使用--throttle限流的话,该命令还会移除限流;该命令很重要,不移除限流对正常的副本之间同步会有影响 | |
| --throttle | 迁移过程Broker之间现在流程传输的速率,单位 bytes/sec | --throttle 500000 |
| --replica-alter-log-dirs-throttle | broker内部副本跨路径迁移数据流量限制功能，限制数据拷贝从一个目录到另外一个目录带宽上限 单位 bytes/sec | --replica-alter-log-dirs-throttle 100000 |
| --disable-rack-aware | 关闭机架感知能力,在分配的时候就不参考机架的信息 |  |
| --bootstrap-server | 如果是副本跨路径迁移必须有此参数 |  |


# 1. 生成分配计划

编写分配脚本：
```
$ vim topics-to-move.json
{"topics":
	[{"topic":"event_request"}],
	"version": 1
}
```

执行分配计划生成脚本：
```
$ kafka-reassign-partitions.sh --zookeeper $ZK_CONNECT --topics-to-move-json-file topics-to-move.json --broker-list "5,6,7,8" --generate
```

执行结果如下：
```
$ kafka-reassign-partitions.sh --zookeeper $ZK_CONNECT --topics-to-move-json-file topics-to-move.json --broker-list "5,6,7,8" --generate
Current partition replica assignment                  #当前分区的副本分配
{"version":1,"partitions":[{"topic":"event_request","partition":0,"replicas":[3,4]},{"topic":"event_request","partition":1,"replicas":[4,5]}]}

Proposed partition reassignment configuration         #建议的分区配置
{"version":1,"partitions":[{"topic":"event_request","partition":0,"replicas":[6,5]},{"topic":"event_request","partition":1,"replicas":[7,6]}]}
```
- `Proposed partition reassignment configuration` 后是根据命令行的指定的brokerlist生成的分区分配计划json格式。

将 `Proposed partition reassignment configuration`的配置copy保存到一个文件中 topic-reassignment.json
```
$ vim topic-reassignment.json
{"version":1,"partitions":[{"topic":"event_request","partition":0,"replicas":[6,5]},{"topic":"event_request","partition":1,"replicas":[7,6]}]}
```

# 2. 执行分配（execute）

根据step1 生成的分配计划配置json文件topic-reassignment.json，进行topic的重新分配。
```
$ kafka-reassign-partitions.sh --zookeeper $ZK_CONNECT --reassignment-json-file topic-reassignment.json --execute
```

执行前的分区分布：
```
$ kafka-topics.sh --describe --topic event_request
Topic:event_request	PartitionCount:2	ReplicationFactor:2	Configs:
	Topic: event_request	Partition: 0	Leader: 3	Replicas: 3,4	Isr: 3,4
	Topic: event_request	Partition: 1	Leader: 4	Replicas: 4,5	Isr: 4,5
```

执行后的分区分布：
```
$ kafka-topics.sh --describe --topic event_request
Topic:event_request	PartitionCount:2	ReplicationFactor:4	Configs:
	Topic: event_request	Partition: 0	Leader: 3	Replicas: 6,5,3,4	Isr: 3,4
	Topic: event_request	Partition: 1	Leader: 4	Replicas: 7,6,4,5	Isr: 4,5
```

# 3. 检查分配的状态

查看分配的状态：正在进行
```
$ kafka-reassign-partitions.sh --zookeeper $ZK_CONNECT --reassignment-json-file topic-reassignment.json --verify
Status of partition reassignment:
Reassignment of partition [event_request,0] is still in progress
Reassignment of partition [event_request,1] is still in progress
```
查看“is still in progress” 状态时的分区，副本分布状态：

发现Replicas有4个哦，说明在重新分配的过程中新旧的副本都在进行工作。
```
$ le-kafka-topics.sh --describe --topic event_request
Topic: event_request	PartitionCount:2	ReplicationFactor:4	Configs:
Topic: event_request	Partition: 0	Leader: 3	Replicas: 6,5,3,4	Isr: 3,4
Topic: event_request	Partition: 1	Leader: 4	Replicas: 7,6,4,5	Isr: 4,5
```

查看分配的状态：分配完成。
```
$ kafka-reassign-partitions.sh --zookeeper $ZK_CONNECT --reassignment-json-file topic-reassignment.json --verify
Status of partition reassignment:
Reassignment of partition [event_request,0] completed successfully
Reassignment of partition [event_request,1] completed successfully
```
查看“completed successfully”状态的分区，副本状态：

已经按照生成的分配计划正确的完成了分区的重新分配。
```
$ le-kafka-topics.sh --describe --topic event_request
Topic:event_request	PartitionCount:2	ReplicationFactor:2	Configs:
Topic: event_request	Partition: 0	Leader: 6	Replicas: 6,5	Isr: 6,5
Topic: event_request	Partition: 1	Leader: 7	Replicas: 7,6	Isr: 6,7
```
