一、mysql监控
1.1 监控项
| 名称 | PromQL	描述
| mysql正常运行时间	mysql_global_status_uptime{instance="$host"}	mysqld 服务器进程最后一次重启的时间。
| 当前的 QPS	rate(mysql_global_status_queries{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_queries{instance=”$host"}[5m])	每秒查询率
| InnoDB 缓冲池大小	mysql_global_variables_innodb_buffer_pool_size{instance="$host"}	InnoDB 维护了一个缓冲池，用于在内存当中进行数据缓存与索引。
| 当前连接数	max(max_over_time(mysql_global_status_threads_connected{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or mysql_global_status_threads_connected{instance=”$host"} )	MySQL 连接数统计
| 服务器最大连接记录	mysql_global_status_max_used_connections{instance="$host"}	MySQL 连接数统计
| 最大连接数	mysql_global_variables_max_connections{instance="$host"}	MySQL 连接数统计
| 已连接的线程数	max_over_time(mysql_global_status_threads_connected{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or max_over_time(mysql_global_status_threads_connected{instance=”$host"}[5m])	MySQL 活动的线程数
| 运行中的线程数	max_over_time(mysql_global_status_threads_running{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or max_over_time(mysql_global_status_threads_running{instance=”$host"}[5m])	MySQL 活动的线程数
| 平均运行的线程数	avg_over_time(mysql_global_status_threads_running{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or avg_over_time(mysql_global_status_threads_running{instance=”$host"}[5m])	MySQL 活动的线程数
| mysql查询数	rate(mysql_global_status_questions{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_questions{instance=”$host"}[5m])	MySQL 服务器执行的查询语句统计
| 线程缓存池大小	mysql_global_variables_thread_cache_size{instance="$host"}	MySQL 线程缓存
| 已经缓存的线程	mysql_global_status_threads_cached{instance="$host"}	MySQL 线程缓存
| 已创建的线程	rate(mysql_global_status_threads_created{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_threads_created{instance=”$host"}[5m])	MySQL 线程缓存
MySQL 慢查询	rate(mysql_global_status_slow_queries{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_slow_queries{instance=”$host"}[5m])	慢查询的定义是比 long_query_time 所设置的值还要慢的查询
| 异常中断的客户端 (尝试连接)	rate(mysql_global_status_aborted_connects{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_aborted_connects{instance=”$host"}[5m])	MySQL 异常中断的连接
| 异常中断的客户端 (超时)	rate(mysql_global_status_aborted_clients{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_aborted_clients{instance=”$host"}[5m])	MySQL 异常中断的连接
锁	rate(mysql_global_status_table_locks_immediate{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_table_locks_immediate{instance=”$host"}[5m])	MySQL 表锁定
锁等待	rate(mysql_global_status_table_locks_waited{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_table_locks_waited{instance=”$host"}[5m])	MySQL 表锁定
入站流量	rate(mysql_global_status_bytes_received{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_bytes_received{instance=”$host"}[5m])	MySQL 网络流量
出站流量	rate(mysql_global_status_bytes_sent{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_bytes_sent{instance=”$host"}[5m])	MySQL 网络流量
执行命令排行	topk(5, rate(mysql_global_status_commands_total{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval])>0) or topk(5, irate(mysql_global_status_commands_total{instance=”$host"}[5m])>0)	
MySQL 处理计数	rate(mysql_global_status_handlers_total{instance=“KaTeX parse error: Expected 'EOF', got '&' at position 24: …andler!~"commit&̲#124;rollback&#…interval]) or irate(mysql_global_status_handlers_total{instance=”$host", handler!~“commit|rollback|savepoint.*|prepare”}[5m])	MySQL 处理统计是 MySQL 内部执行查询、修改、插入行和修改行、表和索引的内部统计信息。
mysql事务处理统计	rate(mysql_global_status_handlers_total{instance=“KaTeX parse error: Expected 'EOF', got '&' at position 24: …andler=~"commit&̲#124;rollback&#…interval]) or irate(mysql_global_status_handlers_total{instance=”$host", handler=~“commit|rollback|savepoint.*|prepare”}[5m])	
mysql读取文件统计	rate(mysql_global_status_opened_files{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲[interval]) or irate(mysql_global_status_opened_files{instance=”$host"}[5m])	正在打开的文件
MySQL 打开的文件数	mysql_global_status_open_files{instance="$host"}	MySQL 打开的文件
允许最大打开的文件数	mysql_global_variables_open_files_limit{instance="$host"}	MySQL 打开的文件
InnoDB 打开的文件数	mysql_global_status_innodb_num_open_files{instance="$host"}	MySQL 打开的文件
1.2 告警项
promQL	描述
floor(delta(mysql_global_status_slow_queries{mysql_addr!~“10.8.6.44:3306|10.8.9.20:3306|10.8.12.212:3306”}[5m])) >= 100	mysql慢查询5分钟100条
floor(sum by(group, role, mysql_addr) (irate(mysql_global_status_commands_total{group!~"product	product_backend"}[5m]))) > 8000
mysql_mem_used_rate <= 99	mysql内存99%
mysql_disk_used_rate{mysql_addr!~“10.8.161.53:3306|10.8.115.31:3306”} >= 85	mysql磁盘85%
loor(mysql_global_status_threads_connected / mysql_global_variables_max_connections * 100) >= 80	mysql连接数80%
floor(delta(mysql_global_status_threads_running{mysql_addr!~“10.8.136.10:3306|10.10.129.116:3306”}[5m])) >= 150	mysql运行进程数5分钟增长>150
(mysql_slave_status_slave_io_running{role!=“master”} == 0) or (mysql_slave_status_slave_sql_running{role!=“master”} == 0)	mysql主从同步异常
floor(mysql_slave_status_seconds_behind_master{mysql_addr!~“10.8.137.173:3306|10.8.11.17:3306”}) >= 30	mysql主从同步延时>30s
mysql_global_status_max_used_connections{instance="$host"} >	最大连接数大于两百
二、linux服务器
2.1 监控项
名称	PromQL	描述
系统运行时间	time() - node_boot_time_seconds{instance=~"$node"}	
CPU 核数	count(count(node_cpu_seconds_total{instance=~"$node", mode=‘system’}) by (cpu))	
内存总量	node_memory_MemTotal_bytes{instance=~"$node"}	
CPU使用率（5m）	100 - (avg(irate(node_cpu_seconds_total{instance=~"$node",mode=“idle”}[5m])) * 100)	
CPU iowait（5m）	avg(irate(node_cpu_seconds_total{instance=~"$node",mode=“iowait”}[5m])) * 100 | %iowait 表示在一个采样周期内有百分之几的时间属于以下情况：CPU空闲、并且有仍未完成的I/O请求	
内存使用率	((node_memory_MemTotal_bytes{instance=~“KaTeX parse error: Expected 'EOF', got '}' at position 6: node"}̲ - node_memory_…node”} - node_memory_Buffers_bytes{instance=~“KaTeX parse error: Expected 'EOF', got '}' at position 6: node"}̲ - node_memory_…node”}) / (node_memory_MemTotal_bytes{instance=~"$node"} )) * 100	
根分区使用率	100 - ((node_filesystem_avail_bytes{instance=~“KaTeX parse error: Expected 'EOF', got '&' at position 35: …",fstype=~"ext4&̲#124;xfs"} * 10…node”,mountpoint="/",fstype=~“ext4|xfs”})	
最大分区($maxmount)使用率	100 - ((node_filesystem_avail_bytes{instance="$node",mountpoint="$maxmount",fstype=“ext4|xfs”} * 100) / node_filesystem_size_bytes {instance="$node",mountpoint="$maxmount",fstype=“ext4|xfs”})	通过变量maxmount获取最大的分区。
系统平均负载	node_load1{instance=~"$node"}	每分钟平均负载
磁盘总空间	node_filesystem_size_bytes {instance="$node",fstype=“ext4|xfs”}	
总内存	node_memory_MemTotal_bytes{instance=~"$node"}	
已用内存	node_memory_MemTotal_bytes{instance=~“KaTeX parse error: Expected 'EOF', got '}' at position 6: node"}̲ - (node_memory…node”} + node_memory_Buffers_bytes{instance=~“KaTeX parse error: Expected 'EOF', got '}' at position 6: node"}̲ + node_memory_…node”})	
可用内存	node_memory_MemAvailable_bytes{instance=~"$node"}	
磁盘可用空间	node_filesystem_avail_bytes {instance=’$node’,fstype=“ext4|xfs”}	
磁盘总空间	node_filesystem_size_bytes{instance=’$node’,fstype=“ext4|xfs”}	
磁盘读取速率	irate(node_disk_reads_completed_total{instance=~"$node"}[1m])	每个磁盘分区每秒读完成次数
磁盘写入速率	irate(node_disk_writes_completed_total{instance=~"$node"}[1m])	每个磁盘分区每秒写完成次数
磁盘分区每秒正在处理的输入/输出请求数	node_disk_io_now{instance=~"$node"}	
磁盘分区读操作花费的秒数（1m）	irate(node_disk_read_time_seconds_total{instance=~"$node"}[1m])	
磁盘分区写操作花费的秒数（1m）	irate(node_disk_write_time_seconds_total{instance=~"$node"}[1m])	磁盘读写速率（IOPS）
网络下载流量	irate(node_network_receive_bytes_total{instance=’$node’,device!‘tap.*’}[5m])*8	
网络上传流量	irate(node_network_transmit_bytes_total{instance=’$node’,device!‘tap.*’}[5m])*8	
硬件温度	node_hwmon_temp_celsius{instance="$node"}	
当前状态为 ESTABLISHED 或 CLOSE-WAIT 的 TCP 连接数	node_netstat_Tcp_CurrEstab{instance=~’$node’}	
已从 CLOSED 状态直接转换到 SYN-SENT 状态的 TCP 平均连接数(1m)	node_sockstat_TCP_tw{instance=~’$node’}	
已从 LISTEN 状态直接转换到 SYN-RCVD 状态的 TCP 平均连接数(1m)	irate(node_netstat_Tcp_ActiveOpens{instance=~’$node’}[1m])	
已分配（已建立、已申请到sk_buff）的TCP套接字数量	irate(node_netstat_Tcp_PassiveOpens{instance=~’$node’}[1m])	
正在使用（正在侦听）的TCP套接字数量	node_sockstat_TCP_alloc{instance=~’$node’}	
等待关闭的TCP连接数	node_sockstat_TCP_inuse{instance=~’$node’}	
2.2 告警项
promQL	描述
round(100- node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes*100) > 80	内存使用率 > 80%
round(100 - ((avg by (instance,job)(irate(node_cpu_seconds_total{mode=“idle”,instance!~‘bac-.*’}[5m]))) *100)) > 80	CPU使用率 >80%
round(100-100*(node_filesystem_avail_bytes{fstype=~“ext4|xfs”} / node_filesystem_size_bytes{fstype=~“ext4|xfs”})) > 80	磁盘使用率 > 80%
round(node_filesystem_avail_bytes{fstype=“ext4&#124;xfs”,instance!“testnode”,mountpoint!~"/boot.*"}/1024/1024/1024) < 10	分区容量 < 10%
round(irate(node_network_receive_bytes_total{instance!“data.*”,device!‘tap.|veth.|br.|docker.|vir.|lo.|vnet.*’}[1m])/1024) > 2048	网络流出速率过高 > 2048kb/s
三、redis监控
3.1 redis监控项
名称	PromQL	描述
系统运行时间	redis_uptime_in_seconds{addr="$addr"}	
redis客户端数量	redis_connected_clients{addr="$addr"}	
执行命令数（5m）	rate(redis_commands_processed_total{addr=~"$addr"}[5m])	
命令命中数（5m）	irate(redis_keyspace_hits_total{addr="$addr"}[5m])	
命令未命中数（5m）	irate(redis_keyspace_misses_total{addr="$addr"}[5m])	
已用内存	redis_memory_used_bytes{addr=~"$addr"}	
总内存	redis_config_maxmemory{addr=~"$addr"}	
io速率（写）	rate(redis_net_input_bytes_total{addr="$addr"}[5m])	
io速率（度）	rate(redis_net_output_bytes_total{addr="$addr"}[5m])	
每个库的key总数	sum (redis_db_keys{addr=~"$addr"}) by (db)	
未过期key	sum (redis_db_keys{addr=~“KaTeX parse error: Expected 'EOF', got '}' at position 6: addr"}̲) - sum (redis_…addr”})	
过期key	sum (redis_db_keys_expiring{addr=~"$addr"})	
redis慢日志	redis_slowlog_length{instance=~"$instance"}	
过期	sum(rate(redis_evicted_keys_total{addr=~"$addr"}[5m])) by (addr)	
逐出	sum(rate(redis_expired_keys_total{addr=~"$addr"}[5m])) by (addr)	
3.2 告警项
promQL	描述
redis_up == 0	redis 服务 down
(count(redis_instance_info{role=“master”}) or vector(0)) < 1	redis 缺少主节点(集群，或者sentinel 模式才有)
delta(redis_connected_slaves[1m]) < 0	Redis实例丢失了一个slave
redis_memory_used_bytes / redis_total_system_memory_bytes * 100 > 90	Redis内存耗尽（>90%）。
redis_connected_clients > 200	Redis实例有太多的连接
increase(redis_rejected_connections_total[1m]) > 0	Redis拒绝连接
四、nginx监控
4.1 监控项
nginx-vts-exporter
名称	PromQL	描述
QPS（5m）	sum(irate(nginx_server_requests{code=“total”,host=~"$DomainName"}[5m]))	
4xx百分率	(sum(irate(nginx_server_requests{code=“4xx”,host=~“KaTeX parse error: Expected 'EOF', got '}' at position 12: DomainName"}̲[5m])) / sum(ir…DomainName”}[5m]))) * 100	401、402等4xx百分率
求upstream的QPS	sum(irate(nginx_upstream_requests{code=“total”,upstream=“group1”}[5m]))	示例求group1的qps
求upstream后端server的响应时间	nginx_upstream_responseMsec{upstream=“group1”}	
系统运行时间	time() - process_start_time_seconds{job=~“kubernetes-pods”, instance=~“i n s t a n c e " , n a m e s p a c e =   " instance", namespace=~"instance",namespace= "namespace”}	
当前活动的连接数量（包括等待的）	nginx_connections_current{state=“active”, instance=~“i n s t a n c e " , n a m e s p a c e =   " instance", namespace=~"instance",namespace= "namespace”}	
正在读取的连接数量	nginx_connections_current{state=“reading”, instance=~“i n s t a n c e " , n a m e s p a c e =   " instance", namespace=~"instance",namespace= "namespace”}	
nginx正在响应的连接数量	nginx_connections_current{state=“writing”, instance=~“i n s t a n c e " , n a m e s p a c e =   " instance", namespace=~"instance",namespace= "namespace”}	
当前空闲的连接数量	nginx_connections_current{state=“waiting”, instance=~“i n s t a n c e " , n a m e s p a c e =   " instance", namespace=~"instance",namespace= "namespace”}	
nginx-module-vts
名称	PromQL	描述
统计nginx几种连接状态type的连接数	nginx_server_connections{instance=~"$Instance", status=~"active	writing
统计nginx缓存计算器，精确到每一种状态和转发type	sum(irate(nginx_server_cache{instance=~“KaTeX parse error: Expected group after '^' at position 19: …tance", host=~"^̲Host$”}[5m])) by (status)	
统计nginx各个host 各个请求的总数，精确到状态码	sum(irate(nginx_server_requests{instance=~"$Instance", code!=“total”}[5m])) by (code)	
统计nginx进出的字节计数可以精确到每个host，in进，out出	sum(irate(nginx_server_bytes{instance=~“KaTeX parse error: Expected group after '^' at position 19: …tance", host=~"^̲Host$”}[5m])) by (direction)	
统计各个upstream 请求总数，精确到状态码	sum(irate(nginx_upstream_requests{instance=~“KaTeX parse error: Expected group after '^' at position 23: …e", upstream=~"^̲Upstream$”,code!=“total”}[5m])) by (code)	
统计nginx各个 upstream 分组的字节总数，细分到进出	sum(irate(nginx_upstream_bytes{instance=~“KaTeX parse error: Expected group after '^' at position 23: …e", upstream=~"^̲Upstream$”}[5m])) by (direction)	
统计各个upstream 平均响应时长，精确到每个节点	sum(nginx_upstream_responseMsec{instance=~“KaTeX parse error: Expected group after '^' at position 23: …e", upstream=~"^̲Upstream$”}) by (backend)	
4.2 告警项
promQL	描述
sum(rate(nginx_http_requests_total{status=~"^4…"}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5	状态为4xx（> 5％）的HTTP请求过多
sum(rate(nginx_http_requests_total{status=~"^5…"}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5	状态为5xx（> 5％）的HTTP请求过多
histogram_quantile(0.99, sum(rate(nginx_http_request_duration_seconds_bucket[2m])) by (host, node)) > 3	Nginx P99延迟时间超过3秒
五、kafka监控
5.1 监控项
名称	PromQL	描述
Max	max(kafka_server_replicafetchermanager_maxlag)by(service_name)	
扩大率(Service / Broker)	kafka_server_replicamanager_isrexpandspersec_5minuterate	
收缩率(Service / Broker)	kafka_server_replicamanager_isrshrinkspersec_5minuterate	
平均响应时间	avg(kafka_network_requestmetrics_responsesendtimems_mean)by(service_name)	
平均请求队列等待时间	avg(kafka_network_requestmetrics_requestqueuetimems_mean)by(service_name)	
平均请求follower时间	avg(kafka_network_requestmetrics_remotetimems_mean)by(service_name)	
日志刷新延迟	kafka_log_logflushstats_logflushrateandtimems_count	
最大消息延迟 > 4000ms	kafka_server_replicafetchermanager_minfetchrate	
leader选举次数 15m	kafka_controller_controllerstats_uncleanleaderelectionspersec	
分区复制错误	kafka_server_replicamanager_underreplicatedpartitions	
活跃的 Controller 的数量	kafka_controller_kafkacontroller_activecontrollercount	
争议的 leader 选举次数	kafka_controller_controllerstats_uncleanleaderelectionspersec	
将ISR中处于关闭状态的副本从集合中去除掉，返回一个新的ISR集合，然后选取第一个副本作为leader，然后令当前AR作为接收LeaderAndIsr请求的副本	kafka_controller_controllerstats_controlledshutdownrateandtimems	
从活着的ISR中选择一个broker作为leader，如果ISR中没有活着的副本，则从assignedReplicas中选择一个副本作为leader，leader选举成功后注册到Zookeeper中，并更新所有的缓存。	kafka_controller_kafkacontroller_offlinepartitionscount	
所有topic消息(进出)流量 消息写入总量	kafka_server_brokertopicmetrics_messagesin_total	
扔掉的流量	kafka_server_brokertopicmetrics_bytesrejected_total	
当前机器fetch请求失败的数量	kafka_server_brokertopicmetrics_failedfetchrequests_total	
输出的流量	kafka_server_brokertopicmetrics_bytesout_total	
输入的流量	kafka_server_brokertopicmetrics_bytesin_total	
当前机器produce请求失败的数量	kafka_server_brokertopicmetrics_failedproducerequests_total	
该broker上的partition的数量	kafka_server_replicamanager_partitioncount	
Leader的replica的数量	kafka_server_replicamanager_leadercount	
一个请求FetchConsumer\FetchFollower\Produce耗费的所有时间	kafka_network_requestmetrics_totaltimems{FetchConsumer\FetchFollower\Produce}	
5.2 告警项
promQL	描述
avg_over_time(kafka_server_BrokerTopicMetrics_OneMinuteRate{name=“BytesOutPerSec”,topic=""}[1m]) / 1024 /1024 >= 150	网络流量M/s
avg_over_time(kafka_server_KafkaRequestHandlerPool_OneMinuteRate{name=“RequestHandlerAvgIdlePercent”,}[1m]) <= 0.3	请求处理程序线程空闲的平均时间百分比
sum(avg_over_time(kafka_server_socket_server_metrics_connection_creation_rate[1m])) by (instance) > 100	每秒新建连接数
avg_over_time(kafka_network_RequestMetrics_999thPercentile{name=“LocalTimeMs”,request=“Produce”,}[1m]) > 5000	请求在请求队列中等待的时间大于5000ms
avg_over_time(kafka_network_RequestMetrics_999thPercentile{name=“ResponseQueueTimeMs”,request=“Produce”,}[1m]) > 1000	请求在响应队列中等待的时间大于1000ms
六、oracle监控
6.1 监控项
名称	PromQL	描述
数据库状态	oracledb_up{instance="$host"}	
执行计数	oracledb_activity_execute_count{instance="$host"}	
用户提交数	oracledb_activity_user_commits{instance="$host"}	
表空间剩余百分比	1-(oracledb_tablespace_free{instance=“KaTeX parse error: Expected 'EOF', got '}' at position 6: host"}̲/oracledb_table…host”})	
表空间剩余空间	oracledb_tablespace_free{instance="$host"}	
活动会话(USER)	oracledb_sessions_value{instance="$host",status=“ACTIVE”,type=“USER”}	
进程计数	oracledb_process_count{instance="$host"}	
用户回滚	oracledb_activity_user_rollbacks{instance="$host"}	
并发等待时间	oracledb_wait_time_concurrency{instance="$host"}	
提交等待时间	oracledb_wait_time_commit{instance="$host"}	
网络等待	oracledb_wait_time_network{instance="$host"}	
应用等待	oracledb_wait_time_application{instance="$host"}	
系统I/O等待	oracledb_wait_time_system_io{instance="$host"}	
用户I/O等待	oracledb_wait_time_user_io{instance="$host"}	
组态等待时间	oracledb_wait_time_configuration{instance="$host"}	
Scheduler 等待时间	oracledb_wait_time_scheduler{instance="$host"}	
资源利用率	oracledb_resource_current_utilization{instance="$host"}	
active sessions	oracledb_sessions_active{instance="$host"}
