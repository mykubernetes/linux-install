cassandra配置优化(3.11.3)
---
1、修改/conf/cassandra-env.sh(修复3.11.3版本gc日志打印问题),补充如下内容：
```
  if [ ! -f "${CASSANDRA_HOME}/logs/gc.log" ];then
      touch ${CASSANDRA_HOME}/logs/gc.log
  fi
```

2、配置/conf/cassandra.yaml, 各配置项及说明如下：
```
cluster_name: 集群名称
num_tokens:384                                     # 默认256，根据集群内各实例性能按比例划分
authenticator:PasswordAuthenticator

authorizer:CassandraAuthorizer
(授权表只有一个复制因子，如果一台主机挂掉就可能不能登录，通过如下两步来修改复制因子为3
a.登录数据库执行
ALTER KEYSPACE system_auth WITH replication = {'class':'NetworkTopologyStrategy','sh':3}
b.主机执行如下命令
nodetool repair system_auth)
  
data_file_directories:               # 数据文件目录，每个挂1T磁盘，共2T，多磁盘目的有两个：减少SSTABLE压缩次数，增加总IO能力
   - /cassandra/data/disk1
   - /cassandra/data/disk2
commitlog_diretory:/cassandra/commitlog            # 挂100G磁盘，最好SSD  
hints_directory:/cassandra/hints                   # 挂200G磁盘，根据允许单台实例宕机多长时间设定，注意，此盘不能撑满，否则会造成整个集群不可用
seeds:"xx.xx.xx.xx,xx.xx.xx.xx1"                   # 种子节点，一般设置2台以上
listen_address:xx.xx.xx.xx                         # 本机实例IP，用来链接其他节点
rpc_address:xx.xx.xx.xx                            # 本机实例IP，客户端链接的监听地址
concurrent_reads:32                                # 一般CPU核数的2倍
concurrent_writes:128                              # 一般CPU核数的8倍
concurrent_counter_writes:32                       # 一般CPU核数的2倍
read_request_timeout_in_ms:30000                   # 协调器应为完成读操作等待多长时间
request_timeout_in_ms:35000                        # 其他操作的默认超时
write_request_timeout_in_ms:5000                   # 写超时，适量调大
commitlog_total_space_in_mb:12800                  # cleanup设置参数
cdc_total_space_in_mb:2125                         # cleanup设置参数
memtable_heap_space_in_mb:12288                    # 堆内存32G
memtable_offheap_space_in_mb:12288                 # 物理机总内存64G
memtable_allocation_type:offheap_objects
streaming_socket_timeout_in_ms:345600000           # 保证扩容时session时间足够，迁移数据量很大需要更长迁移时间
compaction_throughput_mb_per_sec:0 
enable_user_defined_functions:true
user_function_timeout_policy:ignore
user_defined_function_fail_timeout:1500
concurrent_compactors:4                            # 压缩线程，默认2，数据量大，压缩任务重的情况调整为4，特别是物理机有富余CPU能力的情况下
```

多数据中心配置（根据情况选择配置）
---
1、配置/conf/cassandra.yaml
```
endpoint_snitch:GossipingPropertyFileSnitch
```

2、配置/conf/cassandra-rackdc.properties
```
dc=sz/sh                  # 根据节点所在机房配置
```

3、建表空间时指定不同机房的复制因子
```
create keyspace "test_keyspace" with replication = {'class' : 'NetworkTopologyStrategy','sz' : 2,'sh' : 2};
```


JVM优化（JDK1.8）
---
主机：24核284G物理机
配置/conf/jvm.options
1,配置G1垃圾回收器
```
 a，注释掉CMS相关配置
 b，增加G1配置项
-XX:+UseG1GC
-XX:G1RSetUpdatingPauseTimePercent=5
-XX:+PrintFlagsFinal
-XX:MaxGCPauseMillis=500
```

2，内存:堆内存不要超过32G，否则性能反而下降
```
-Xms32G
-Xmx32G
```

3，其它
```
-XX:+ExplicitGCInvokesConcurrent   # nio使用的本地内存需要配置
```


主机系统调优(Centos6.7)
---
1、时钟同步：

2、TCP参数优化
```
# vim /etc/sysctl.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=16777216
net.core.wmem_default=16777216
net.core.optmem_max=40960
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 87380 16777216

# sysctl -p /etc/sysctl.conf
```

3、禁用zone_reclaim_mode
```
# cat /proc/sys/vm/zone_reclaim_mode  0:关闭  1：开启

# vim /etc/sysctl.conf   
vm.zone_reclaim_mode=0

# sysctl -p /etc/sysctl.conf
```

4、资源限制放开
```
# vim /etc/security/limits.conf, 不同操作系统可能不同
*           -    nofile      100000
*           -    nproc       32768
*           -    memlock     unlimited
*           -    as          unlimited
   
   查看设置，重新登录系统
   ulimit -a 或  cat /proc/{pid}/limits
```


5、禁用swap
```
# vim /etc/sysctl.conf
vm.swappiness = 0
# sysctl -p /etc/sysctl.conf
# swapoff -a

# vim /etc/fstab 去掉swap挂载，将所有的swap文件从/etc/fstab中移除
```

6、线程最大连接数
```
# vim /etc/sysctl.conf
vm.max_map_count = 1048575

# sysctl -p /etc/sysctl.conf
```

7、关闭透明分页hugePages  
说明：对数据库(oracle/mongoDb/cassandra)需要关闭此功能
```
a.查看是否启用： 
# cat /sys/kernel/mm/transparent_hugepage/defrag
# cat /sys/kernel/mm/transparent_hugepage/enabled
显示： [always] madvise never  则表示开启
或使用：grep Huge /proc/meminfo 也可以查看是否启用
 
b.禁用：
# vim /etc/rc.d/rc.local
增加如下内容
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then echo     never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
保存退出，然后赋予rc.local文件执行权限
chmod +x /etc/rc.d/rc.local

c.执行如下命令立即生效
# echo never > /sys/kernel/mm/transparent_hugepage/defrag;
# echo never > /sys/kernel/mm/transparent_hugepage/enabled;

d.查看 
cat /sys/kernel/mm/transparent_hugepage/defrag (enabled)
结果显示 always madvise [never] 表示已禁用。
```
