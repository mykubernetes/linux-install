
https://blog.csdn.net/qq_32523587/article/details/53982900
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
saved_caches_directory: /opt/cassandras/saved_caches            #数据缓存文件在磁盘中的存储位置
commitlog_sync: periodic                     #记录commitlog的方式,periodic每一次有数据更新都将操作commitlog,batch批量记录commitlog,每一段时间内数据的更新将批量一次操作commitlog。
commitlog_sync_period_in_ms: 1000            #周期记录commitlog时，刷新commitlog文件的时间间隔,在commitlog_sync= periodic时才能设置
commitlog_segment_size_in_mb: 32
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
        - seeds: "192.168.101.74"            #集群种子节点ip
concurrent_reads: 16
concurrent_writes: 32
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
incremental_backups: false
snapshot_before_compaction: false
auto_snapshot: true                            #默认: true,在清空keyspace或者删除tables之前要拍摄快照
tombstone_warn_threshold: 10000
tombstone_failure_threshold: 100000
column_index_size_in_kb: 64
column_index_cache_size_in_kb: 2
batch_size_warn_threshold_in_kb: 5
batch_size_fail_threshold_in_kb: 50
concurrent_compactors: 2
compaction_throughput_mb_per_sec: 32
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
endpoint_snitch: SimpleSnitch
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
