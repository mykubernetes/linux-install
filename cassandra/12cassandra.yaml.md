https://blog.imdst.com/centos-7-an-zhuang-bu-shu-cassandra/

```
disk_access_mode: standard
cluster_name: 'mycluster'                                      #集群的名称
num_tokens: 64
hinted_handoff_enabled: true                                   #是否开启当前Cassandra服务器的HINT操作
hinted_handoff_throttle_in_kb: 1024
max_hints_delivery_threads: 2
hints_directory: /opt/cassandra/hints                          #存储提示目录
hints_flush_period_in_ms: 10000
max_hints_file_size_in_mb: 128
batchlog_replay_throttle_in_kb: 1024
authenticator: PasswordAuthenticator                           #验证使用Cassandra的用户是否合法,这是安全认证的第一步
authorizer: CassandraAuthorizer                                #验证该用户是否具备操作某一个Column Family的权限，这是安全认证的第一步
role_manager: CassandraRoleManager
roles_validity_in_ms: 2000
permissions_validity_in_ms: 2000
credentials_validity_in_ms: 2000
partitioner: org.apache.cassandra.dht.Murmur3Partitioner       #集群中数据分区的策略
cdc_enabled: false
data_file_directories:                                         #SSTable文件在磁盘中的存储位置
    - /opt/cassandras/data
commitlog_directory: /opt/cassandras/commitlog                 #commitlog文件在磁盘中的存储位置
disk_failure_policy: best_effort
commit_failure_policy: stop_commit
key_cache_size_in_mb: 5120
key_cache_save_period: 14400
prepared_statements_cache_size_mb:
thrift_prepared_statements_cache_size_mb:
row_cache_size_in_mb: 0
row_cache_save_period: 0
counter_cache_size_in_mb:
counter_cache_save_period: 7200
saved_caches_directory: /opt/cassandras/saved_caches           #数据缓存文件在磁盘中的存储位置,保存表和行的缓存
commitlog_sync: periodic                                       #记录commitlog的方式,periodic每一次有数据更新都将操作commitlog,batch批量记录commitlog,每一段时间内数据的更新将批量一次操作commitlog。
commitlog_sync_period_in_ms: 1000                              #周期记录commitlog时，刷新commitlog文件的时间间隔,在commitlog_sync= periodic时才能设置
commitlog_segment_size_in_mb: 32
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
        - seeds: "192.168.101.74"                             # 集群种子节点ip
concurrent_reads: 16                                          # 默认32,读取数据的瓶颈是在磁盘上，设置16倍于磁盘数量可以减少操作队列。
concurrent_writes: 32                                         # 默认32,在Cassandra里写很少出现I/O不稳定，所以并发写取决于CPU的核心数量。推荐8倍于CPU数。
concurrent_counter_writes: 16
concurrent_materialized_view_writes: 16
disk_optimization_strategy: ssd
memtable_allocation_type: heap_buffers
commitlog_total_space_in_mb: 8192
memtable_flush_writers: 2
index_summary_capacity_in_mb:
index_summary_resize_interval_in_minutes: 60
trickle_fsync: false
trickle_fsync_interval_in_kb: 10240
storage_port: 7000                             #Cassandra集群中服务器与服务器之间相互通信的端口号
ssl_storage_port: 7001                         #https的Cassandra集群中服务器与服务器之间相互通信的端口号
listen_address: 192.168.101.74                 #集群中服务器与服务器之间相互通信的地址
start_native_transport: true
native_transport_port: 9042                    #默认的CQL本地服务端口
start_rpc: True
rpc_address:192.168.101.74                     #对外提供服务的地址
broadcast_rpc_address: 192.168.101.74
rpc_port: 9160                                 #对外提供服务的端口号
rpc_keepalive: true                            #对外提供服务连接是否一直保持
rpc_server_type: sync                          #默认: sync,Cassandra提供了三种RPC服务器的选择sync,hsha
thrift_framed_transport_size_in_mb: 15
incremental_backups: false                     #默认false，最后一次快照发生时备份更新的数据（增量备份）。当增量备份可用时，Cassandra创建一个到SSTable的的硬链接或者流式存储到本地的备份/子目录。删除这些硬链接是操作员的责任。
snapshot_before_compaction: false              #默认false，启用或禁用在压缩前执行快照。这个选项在数据格式改变的时候来备份数据是很有用的。注意使用这个选项，因为Cassandra不会自动删除过期的快照。
auto_snapshot: true                            #默认: true,在清空keyspace或者删除tables之前要拍摄快照
tombstone_warn_threshold: 10000
tombstone_failure_threshold: 100000
column_index_size_in_kb: 64
column_index_cache_size_in_kb: 2
batch_size_warn_threshold_in_kb: 5
batch_size_fail_threshold_in_kb: 50
concurrent_compactors: 2
compaction_throughput_mb_per_sec: 32                     #限制特定吞吐量下的压缩速率。如果插入数据的速度越快，越应该压缩SSTable减少其数量。推荐16-32倍于写入速度（MB/s）。如果是0表示不限制。
unlogged_batch_across_partitions_warn_threshold: 10
compaction_large_partition_warning_threshold_mb: 10000
sstable_preemptive_open_interval_in_mb: 50
read_request_timeout_in_ms: 10000
range_request_timeout_in_ms: 10000
write_request_timeout_in_ms: 5000
counter_write_request_timeout_in_ms: 5000
cas_contention_timeout_in_ms: 1000
truncate_request_timeout_in_ms: 300000
request_timeout_in_ms: 10000
slow_query_log_timeout_in_ms: 500
cross_node_timeout: false
endpoint_snitch: SimpleSnitch                            #用于设置Cassandra定位节点和路由请求的snitch
dynamic_snitch_update_interval_in_ms: 100
dynamic_snitch_reset_interval_in_ms: 600000
dynamic_snitch_badness_threshold: 0.1
request_scheduler: org.apache.cassandra.scheduler.NoScheduler
server_encryption_options:
    internode_encryption: none
    keystore: conf/.keystore
    keystore_password: cassandra
    truststore: conf/.truststore
    truststore_password: cassandra
client_encryption_options:
    enabled: false
    optional: false
    keystore: conf/.keystore
    keystore_password: cassandra
internode_compression: dc
inter_dc_tcp_nodelay: false
tracetype_query_ttl: 86400
tracetype_repair_ttl: 604800
gc_warn_threshold_in_ms: 1000
enable_user_defined_functions: false
enable_scripted_user_defined_functions: false
enable_materialized_views: true
windows_timer_interval: 1
transparent_data_encryption_options:
    enabled: false
    chunk_length_kb: 64
    cipher: AES/CBC/PKCS5Padding
    key_alias: testing:1
    key_provider:
    - class_name: org.apache.cassandra.security.JKSKeyProvider
      parameters:
        - keystore: conf/.keystore
          keystore_password: cassandra
          store_type: JCEKS
          key_password: cassandra
back_pressure_enabled: false
back_pressure_strategy:
    - class_name: org.apache.cassandra.net.RateBasedBackPressure
      parameters:
        - high_ratio: 0.90
          factor: 5
          flow: FAST
```


# 快速入门：最小化配置集群
```
cluster_name                                      # 集群的名字，默认情况下是TestCluster。对于这个属性的配置可以防止某个节点加入到其他集群中去，所以一个集群中的节点必须有相同的cluster_name属性。
listen_address                                    # Cassandra需要监听的IP或主机名，默认是localhost。建议配置私有IP，不要用0.0.0.0。
commitlog_directory                               # commit log的保存目录，压缩包安装方式默认是/var/lib/cassandra/commitlog。通过前面的了解，我们可以知道，把这个目录和数据目录分开存放到不同的物理磁盘可以提高性能。
data_file_directories                             # 数据文件的存放目录，压缩包安装方式默认是/var/lib/cassandra/data。为了更好的效果，建议使用RAID 0或SSD。
saved_caches_directory                            # 保存表和行的缓存，压缩包安装方式默认是/var/lib/cassandra/saved_caches。
```

# 通常使用：用得比较频繁的属性
```
在启动节点前，需要仔细评估你的需求。
commit_failure_policy                            # 提交失败时的策略（默认stop）：
                                                   stop：关闭gossip和Thrift，让节点挂起，但是可以通过JMX进行检测。
                                                   sto_commit：关闭commit log，整理需要写入的数据，但是提供读数据服务。
                                                   ignore：忽略错误，使得该处理失败。
disk_failure_policy                              # 设置Cassandra如何处理磁盘故障（默认stop）。
                                                   stop：关闭gossip和Thrift，让节点挂起，但是可以通过JMX进行检测。
                                                   stop_paranoid：在任何SSTable错误时就闭gossip和Thrift。
                                                   best_effort：这是Cassandra处理磁盘错误最好的目标。如果Cassandra不能读取磁盘，那么它就标记该磁盘为黑名单，可以继续在其他磁盘进行写入数据。如果Cassandra不能从磁盘读取数据，那个这些SSTable就标记为不可读，其他可用的继续堆外提供服务。所以就有可能在一致性水平为ONE时会读取到过期的数据。
                                                   ignore：用于升级情况。
endpoint_snitch                                  # 用于设置Cassandra定位节点和路由请求的snitch（默认org.apache.cassandra.locator.SimpleSnitch），必须设置为实现了IEndpointSnitch的类。
rpc_address                                      # 用于监听客户端连接的地址。可用的包括：
seed_provider                                    # 需要联系的节点地址。Cassandra使用-seeds集合找到其他节点并学习其整个环中的网络拓扑。
    - class_name：                               # （默认org.apache.cassandra.locator.SimpleSeedProvider），可用自定义，但通常不必要。
      parameters:
        - seeds：                                # （默认127.0.0.1）逗号分隔的IP列表。
compaction_throughput_mb_per_sec                 # 限制特定吞吐量下的压缩速率。如果插入数据的速度越快，越应该压缩SSTable减少其数量。推荐16-32倍于写入速度（MB/s）。如果是0表示不限制。
memtable_total_space_in_mb                       # 指定节点中memables最大使用的内存数（默认1/4heap）。
concurrent_reads                                 # （默认32）读取数据的瓶颈是在磁盘上，设置16倍于磁盘数量可以减少操作队列。
concurrent_writes                                # （默认32）在Cassandra里写很少出现I/O不稳定，所以并发写取决于CPU的核心数量。推荐8倍于CPU数。
incremental_backups                              # （默认false）最后一次快照发生时备份更新的数据（增量备份）。当增量备份可用时，Cassandra创建一个到SSTable的的硬链接或者流式存储到本地的备份/子目录。删除这些硬链接是操作员的责任。
snapshot_before_compaction                       # （默认false）启用或禁用在压缩前执行快照。这个选项在数据格式改变的时候来备份数据是很有用的。注意使用这个选项，因为Cassandra不会自动删除过期的快照。
phi_convict_threshold                            # （默认8）调整失效检测器的敏感度。较小的值增加了把未响应的节点标注为挂掉的可能性，反之就会降低其可能性。在不稳定的网络环境下（比如EC2），把这个值调整为10或12有助于防止错误的失效判断。大于12或小于5的值不推荐！
```

# 性能调优
```
commit_sync                                      # （默认：periodic）Cassandra用来确认每毫秒写操作的方法。
                                                    periodic：和commitlog_sync_period_in_ms（默认10000 – 10 秒）一起控制把commit log同步到磁盘的频繁度。周期性的同步会立即确认。
                                                    batch：和commitlog_sync_batch_window_in_ms（默认disabled）一起控制Cassandra在执行同步前要等待其他写操作多久时间。当使用该方法时，写操作在同步数据到磁盘前不会被确认。
commitlog_periodic_queue_size                    # （默认1024*CPU的数量）commit log队列上的等待条目。当写入非常大的blob时，请减少这个数值。比如，16倍于CPU对于1MB的Blob工作得很好。这个设置应该至少和concurrent_writes一样大。
commitlog_segment_size_in_mb                     # （默认32）设置每个commit log文件段的大小。一个commit log段在其所有数据刷新到SSTable后可能会被归档、删除或回收。数据的总数可以潜在的包含系统中所有表的commit log段。默认值适合大多数情况，当然你也可以修改，比如8或16MB。
commitlog_total_space_in_mb                      # （默认32位JVM为32,64位JVM为1024）commit log使用的总空间。如果使用的空间达到以上指定的值，Cassandra进入下一个临近的部分，或者把旧的commit log刷新到磁盘，删除这些日志段。该个操作减少了在启动时加载过多数据引起的延迟，防止了把无限更新的表保存到有限的commit log段中。
compaction_preheat_key_cache                     # （默认true）当设置为true的时候，缓存的row key在压缩期间被跟踪，并且重新缓存其在新压缩的SSTable中的位置。如果有及其大的key要缓存，把这个值设为false。
concurrent_compactors                            # （默认每个CPU一个）设置每个节点并发压缩处理的值，不包含验证修复逆商。并发压缩可以在混合读写工作下帮助保持读的性能——通过减缓把一堆小的SSTable压缩而进行的长时间压缩。如果压缩运行得太慢或太快，请首先修改compaction_throughput_mb_per_sec的值。
in_memory_compaction_limit_in_mb                 # （默认64）针对数据行在内存中的压缩限制。超大的行会溢出磁盘并且使用更慢的二次压缩。当这个情况发生时，会对特定的行的key记录一个消息。推荐5-10%的Java对内存大小。
multithreaded_compaction                         # （默认false）当设置为true的时候，每个压缩操作使用一个线程，一个线程用于合并SSTable。典型的，这个只在使用SSD的时候有作用。使用HDD的时候，受限于磁盘I/O（可参考compaction_throughput_mb_per_sec）。
preheat_kernel_page_cache                        # （默认false） 启用或禁用内核页面缓存预热压缩后的key缓存。当启用的时候会预热第一个页面（4K）用于优每个数据行的顺序访问。对于大的数据行通常是有危害的。
file_cache_size_in_mb                            # （小于1/4堆内存或512）用于SSTable读取的缓存内存大小。
memtable_flush_queue_size                        # （默认4）等待刷新的满的memtable的数量（等待写线程的memtable）。最小是设置一个table上索引的最大数量。
memtable_flush_writers                           # （默认每数据目录一个）设置用于刷新memtable的线程数量。这些线程是磁盘I/O阻塞的，每个线程在阻塞的情况下都保持了memtable。如果有大的堆内存和很多数据目录，可以增加该值提升刷新性能。
column_index_size_in_kb                          # （默认64）当数据到达这个值的时候添加列索引到行上。这个值定义了多少数据行必须被反序列化来读取列。如果列的值很大或有很多列，那么就需要增加这个值。
populate_io_cache_on_flush                       #（默认false）添加新刷新或压缩的SSTable到操作系统的页面缓存。
reduce_cache_capacity_to                         #（默认0.6）设置由reduce_cache_sizes_at定义的Java对内存达到限制时的最大缓存容量百分比。
reduce_cache_sizes_at                            #（默认0.85）当Java对内存使用率达到这个百分比，Cassandra减少通过reduce_cache_capacity_to定义的缓存容量。禁用请使用1.0。
stream_throughput_outbound_megabits_per_sec      #（默认200）限制所有外出的流文件吞吐量。Cassandra在启动或修复时使用很多顺序I/O来流化数据，这些可以导致网络饱和以及降低RPC的性能。
trickle_fsync                                    #（默认false）当使用顺序写的时候，启用该选项就告诉fsync强制操作系统在trickle_fsync_interval_in_kb设定的间隔刷新脏缓存。建议在SSD启用。
trickle_fsync_interval_in_kb                     #（默认10240）设置fsync的大小
```



```
################部署调整############### 
#集群名称
cluster_name: XXXXX

#加密验证
authenticator: PasswordAuthenticator

#数据文件位置
data_file_directories:/home/xxx/dev/cassandra/cassdata/cassdata1

#日志文件位置 
commitlog_directory: /home/xxx/dev/cassandra/casscomm/casscomm1

#Key Cache和Row Cache缓存文件对应地址
saved_caches_directory: /home/xxx/dev/cassandra/applogs/saved_caches/1

#集群种子节点配置，同一个集群的每个节点的种子节点必须一致，配置2-3个种子就可以了
seed_provider:  
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
    parameters:          
        - seeds: "xxx.xxx.xxx.xxx,xxx.xxx.xxx.xxx"

#本地IP和端口
native_transport_port: 9042
listen_address: xxx.xxx.xxx.xxx
rpc_address: xxx.xxx.xxx.xxx

#网关设置时间，保持一致
request_timeout_in_ms: 30000

#集群拓扑结构感知方式
endpoint_snitch: GossipingPropertyFileSnitch
dynamic_snitch_update_interval_in_ms: 100
dynamic_snitch_reset_interval_in_ms: 10000
dynamic_snitch_badness_threshold: 0.1
################部署调整###############


################数据结构############### 
#批量数据大小超过5M则报警，增加该值可能引起节点不稳定，根据自己业务数据评估来针对性优化
batch_size_warn_threshold_in_kb: 5000

#批量数据大小超过100M则批量操作失败
batch_size_fail_threshold_in_kb: 100000

#提交日志相关优化
#行情是周期性很强的应用，所以为了保证数据能够异步持久化到磁盘上，并减少损失，使用1s间隔刷新，避免因为batch导致写阻塞block
commitlog_sync: periodic
commitlog_sync_period_in_ms: 1000
#每个commit log 32M
commitlog_segment_size_in_mb: 32
#全部commit log大小 4G，促使memtable刷入sstable
commitlog_total_space_in_mb: 4096

batchlog_replay_throttle_in_kb: 32768

#结合业务特点，大量写，尽快进行压缩
compaction_throughput_mb_per_sec: 256


################数据结构###############

###############线程优化###############  
#处理CQL的最大线程数          
native_transport_max_threads: 4092

#刷盘线程
memtable_flush_writers: 2

#压缩线程
concurrent_compactors: 8

#并发读线程
concurrent_reads: 512

#并发写线程
concurrent_writes: 256

#并发计数器线程
concurrent_counter_writes: 512
###############线程优化############### 


###############内存优化############### 
#确保CDC配置关闭
cdc_enabled: false

#调整key cache占用heap大小，设置为0，关闭key cache
key_cache_size_in_mb: 0

#调整row cache，使用操作系统物理内存
row_cache_size_in_mb: 32768

#定时将缓存刷入磁盘，启动时预热缓存，优化读性能
row_cache_save_period: 1000

#设置缓存的key数量，根据业务场景分析，可以保存所有key值
row_cache_keys_to_save: 0

#实现类
row_cache_class_name: org.apache.cassandra.cache.OHCProvider

#通过Java NIO操作非堆，如果允许，配置成offheap_objects
memtable_allocation_type: offheap_buffers
memtable_offheap_space_in_mb: 32768
#memtable_heap_space_in_mb: 4096


#SSTable读缓存大小
file_cache_size_in_mb: 8192

#当SSTable读缓存耗尽，不分配heap作为读缓存
buffer_pool_use_heap_if_exhausted: false

#数据回传机制的同步带宽 260MB/s
hinted_handoff_throttle_in_kb: 262144

hints_flush_period_in_ms: 1000
max_hints_file_size_in_mb: 256

#索引内存大小
index_summary_capacity_in_mb: 1024
###############内存优化############### 

```
