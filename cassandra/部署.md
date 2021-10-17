# CentOS 7 安装部署 cassandra作为kairosdb的数据存储

环境
- Centos 7.4
- java 1.8.0

## 安装步骤

### 一、安装java
```
yum -y install java-1.8.0-openjdk*  
```
 
### 二、安装cassandra

1、下载cassandra
```
wget https://mirrors.cnnic.cn/apache/cassandra/3.11.2/apache-cassandra-3.11.2-bin.tar.gz  
tar zxf apache-cassandra-3.11.2-bin.tar.gz  
ln -s apache-cassandra-3.11.2 cassandra  
mkdir cassandra/{data,commitlog,saved_caches} -p  
```

2、修改配置cassandra.yaml
```
cluster_name: 'Monitor Cluster'     //集群名称。同一个集群要使用同一名称  
num_tokens: 256  
hinted_handoff_enabled: true  
hinted_handoff_throttle_in_kb: 1024  
max_hints_delivery_threads: 2  
hints_flush_period_in_ms: 10000  
max_hints_file_size_in_mb: 128  
batchlog_replay_throttle_in_kb: 1024  
authenticator: AllowAllAuthenticator  
authorizer: AllowAllAuthorizer  
role_manager: CassandraRoleManager  
roles_validity_in_ms: 2000  
permissions_validity_in_ms: 2000  
credentials_validity_in_ms: 2000  
partitioner: org.apache.cassandra.dht.Murmur3Partitioner  
data_file_directories:  
     - /data/cassandra/data    //数据文件存放路径
commitlog_directory: /data/cassandra/commitlog  //操作日志文件存放路径  
cdc_enabled: false  
disk_failure_policy: stop  
commit_failure_policy: stop  
prepared_statements_cache_size_mb:  
thrift_prepared_statements_cache_size_mb:  
key_cache_size_in_mb:  
key_cache_save_period: 14400  
row_cache_size_in_mb: 0  
row_cache_save_period: 0  
counter_cache_size_in_mb:  
counter_cache_save_period: 7200  
saved_caches_directory: /data/cassandra/saved_caches  //缓存文件存放路径  
commitlog_sync: periodic  
commitlog_sync_period_in_ms: 10000  
commitlog_segment_size_in_mb: 32  
seed_provider:  
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: "192.168.0.150"     //集群种子节点ip
concurrent_reads: 32  
concurrent_writes: 32  
concurrent_counter_writes: 32  
concurrent_materialized_view_writes: 32  
memtable_allocation_type: heap_buffers  
index_summary_capacity_in_mb:  
index_summary_resize_interval_in_minutes: 60  
trickle_fsync: false  
trickle_fsync_interval_in_kb: 10240  
storage_port: 7000  
ssl_storage_port: 7001  
listen_address: 192.168.0.150       //需要监听的IP或主机名。  
start_native_transport: true  
native_transport_port: 9042  
start_rpc: false  
rpc_address: 192.168.0.150         //用于监听客户端连接的地址  
rpc_port: 9160  
broadcast_rpc_address: 1.2.3.4     //修改 rpc_address后，取消该行注释  
rpc_keepalive: true  
rpc_server_type: sync  
thrift_framed_transport_size_in_mb: 15  
incremental_backups: false  
snapshot_before_compaction: false  
auto_snapshot: true  
column_index_size_in_kb: 64  
column_index_cache_size_in_kb: 2  
compaction_throughput_mb_per_sec: 16  
sstable_preemptive_open_interval_in_mb: 50  
read_request_timeout_in_ms: 5000  
range_request_timeout_in_ms: 10000  
write_request_timeout_in_ms: 2000  
counter_write_request_timeout_in_ms: 5000  
cas_contention_timeout_in_ms: 1000  
truncate_request_timeout_in_ms: 60000  
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
tombstone_warn_threshold: 1000  
tombstone_failure_threshold: 100000  
batch_size_warn_threshold_in_kb: 5  
batch_size_fail_threshold_in_kb: 50  
unlogged_batch_across_partitions_warn_threshold: 10  
compaction_large_partition_warning_threshold_mb: 100  
gc_warn_threshold_in_ms: 1000  
back_pressure_enabled: false  
back_pressure_strategy:  
    - class_name: org.apache.cassandra.net.RateBasedBackPressure
      parameters:
        - high_ratio: 0.90
          factor: 5
          flow: FAST
```

3、启动
```
cd /opt/cassandra/bin  
./cassandra -R
```

4、查看端口是否启动功
```
# netstat -tpln
Active Internet connections (only servers)  
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name  
tcp        0      0 127.0.0.1:42480         0.0.0.0:*               LISTEN      13212/java  
tcp        0      0 192.168.0.150:9042      0.0.0.0:*               LISTEN      13212/java  
tcp        0      0 192.168.0.150:7000      0.0.0.0:*               LISTEN      13212/java  
tcp        0      0 127.0.0.1:7199          0.0.0.0:*               LISTEN      13212/java  
```

### 三、部署kairosdb

1、下载
```
wget https://github.com/kairosdb/kairosdb/releases/download/v1.2.1/kairosdb-1.2.1-1.tar.gz  
tar zxf kairosdb-1.2.1-1.tar.gz -C /opt  
cat > /opt/kairosdb/conf/kairosdb.properties <<EOF  
kairosdb.telnetserver.port=4242  
kairosdb.telnetserver.address=0.0.0.0  
kairosdb.telnetserver.max_command_size=1024  
kairosdb.service.telnet=org.kairosdb.core.telnet.TelnetServerModule  
kairosdb.service.http=org.kairosdb.core.http.WebServletModule  
kairosdb.service.reporter=org.kairosdb.core.reporting.MetricReportingModule  
kairosdb.datapoints.factory.long=org.kairosdb.core.datapoints.LongDataPointFactoryImpl  
kairosdb.datapoints.factory.double=org.kairosdb.core.datapoints.DoubleDataPointFactoryImpl  
kairosdb.datapoints.factory.string=org.kairosdb.core.datapoints.StringDataPointFactory  
kairosdb.reporter.schedule=0 */1 * * * ?  
kairosdb.reporter.ttl=0  
kairosdb.jetty.port=8080  
kairosdb.jetty.address=0.0.0.0  
kairosdb.jetty.static_web_root=webroot  
#kairosdb.service.datastore=org.kairosdb.datastore.h2.H2Module
kairosdb.service.datastore=org.kairosdb.datastore.cassandra.CassandraModule  
kairosdb.datastore.concurrentQueryThreads=5  
kairosdb.datastore.h2.database_path=build/h2db  
kairosdb.datastore.cassandra.cql_host_list=localhost  
kairosdb.datastore.cassandra.keyspace=kairosdb  
kairosdb.datastore.cassandra.replication={'class': 'SimpleStrategy','replication_factor' : 1}  
kairosdb.datastore.cassandra.simultaneous_cql_queries=20  
kairosdb.datastore.cassandra.query_reader_threads=6  
kairosdb.datastore.cassandra.row_key_cache_size=50000  
kairosdb.datastore.cassandra.string_cache_size=50000  
kairosdb.datastore.cassandra.read_consistency_level=ONE  
kairosdb.datastore.cassandra.write_consistency_level=QUORUM  
kairosdb.datastore.cassandra.connections_per_host.local.core=5  
kairosdb.datastore.cassandra.connections_per_host.local.max=100  
kairosdb.datastore.cassandra.connections_per_host.remote.core=1  
kairosdb.datastore.cassandra.connections_per_host.remote.max=10  
kairosdb.datastore.cassandra.max_requests_per_connection.local=128  
kairosdb.datastore.cassandra.max_requests_per_connection.remote=128  
kairosdb.datastore.cassandra.max_queue_size=500  
kairosdb.datastore.cassandra.use_ssl=false  
kairosdb.datastore.cassandra.align_datapoint_ttl_with_timestamp=false  
kairosdb.datastore.cassandra.force_default_datapoint_ttl=false  
kairosdb.datastore.remote.data_dir=.  
kairosdb.datastore.remote.remote_url=http://192.168.0.150:8080  
kairosdb.datastore.remote.schedule=0 */30 * * * ?  
kairosdb.datastore.remote.random_delay=0  
kairosdb.query_cache.keep_cache_files=false  
kairosdb.query_cache.cache_file_cleaner_schedule=0 0 12 ? * SUN *  
kairosdb.log.queries.enable=false  
kairosdb.log.queries.ttl=86400  
kairosdb.log.queries.greater_than=60  
kairosdb.queries.aggregate_stats=false  
kairosdb.service.health=org.kairosdb.core.health.HealthCheckModule  
kairosdb.health.healthyResponseCode=204  
kairosdb.queue_processor.class=org.kairosdb.core.queue.FileQueueProcessor  
kairosdb.queue_processor.batch_size=200  
kairosdb.queue_processor.min_batch_size=100  
kairosdb.queue_processor.min_batch_wait=500  
kairosdb.queue_processor.memory_queue_size=100000  
kairosdb.queue_processor.seconds_till_checkpoint=90  
kairosdb.queue_processor.queue_path=queue  
kairosdb.queue_processor.page_size=52428800  
kairosdb.ingest_executor.thread_count=10  
kairosdb.host_service_manager.check_delay_time_millseconds=60000  
kairosdb.host_service_manager.inactive_time_seconds=300  
kairosdb.demo.metric_name=demo_data  
kairosdb.demo.number_of_rows=100  
kairosdb.demo.ttl=0  
kairosdb.blast.number_of_rows=1000  
kairosdb.blast.duration_seconds=30  
kairosdb.blast.metric_name=blast_load  
kairosdb.blast.ttl=600  
EOF  
```

2、启动kairosdb
```
cd /opt/kairosdb/bin && ./kairosdb.sh start  
```

3、遇到的问题

- cassandra运行出现了Unable to gossip with any seeds，cqlsh链接不上,提示connection refused处理办法
```
出现这个问题的原因是cassandra.yaml配置文件的seeds 与 ip 设置错误
Check your cassandra.yaml and make sure that your "listen_address" and "seeds" values match, with the exception that the seeds value requires quotes around it.

请检查seeds 和 listen_address 是一致的。
```
