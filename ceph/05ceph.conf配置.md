1、该配置文件采用init文件语法，#和;为注释，ceph集群在启动的时候会按照顺序加载所有的conf配置文件。 配置文件分为以下几大块配置。
```
global：全局配置。
osd：osd专用配置，可以使用osd.N，来表示某一个OSD专用配置，N为osd的编号，如0、2、1等。
mon：mon专用配置，也可以使用mon.A来为某一个monitor节点做专用配置，其中A为该节点的名称，ceph-monitor-2、ceph-monitor-1等。使用命令 ceph mon dump可以获取节点的名称。
client：客户端专用配置。
```

2、配置文件可以从多个地方进行顺序加载，如果冲突将使用最新加载的配置，其加载顺序为。
```
$CEPH_CONF环境变量
-c 指定的位置
/etc/ceph/ceph.conf
~/.ceph/ceph.conf
./ceph.conf
```

3、配置文件还可以使用一些元变量应用到配置文件，如。
```
$cluster：当前集群名。
$type：当前服务类型。
$id：进程的标识符。
$host：守护进程所在的主机名。
$name：值为$type.$id。
```

4、ceph.conf
```
[global]#全局设置
fsid = xxxxxxxxxxxxxxx                       #集群标识ID
mon host = 10.0.1.1,10.0.1.2,10.0.1.3        #monitor IP 地址
auth cluster required = cephx                #集群认证
auth service required = cephx                #服务认证
auth client required = cephx                 #客户端认证
osd pool default size = 3                    #最小副本数 默认是3
osd pool default min size = 1                #PG 处于 degraded 状态不影响其 IO 能力,min_size是一个PG能接受IO的最小副本数
public network = 10.0.1.0/24                 #公共网络(monitorIP段)
cluster network = 10.0.2.0/24                #集群网络
max open files = 131072                      #默认0#如果设置了该选项，Ceph会设置系统的max open fds
mon initial members = node1, node2, node3    #初始monitor (由创建monitor命令而定)
##############################################################
[mon]
mon data = /var/lib/ceph/mon/ceph-$id
mon clock drift allowed = 1              #默认值0.05     #monitor间的clock drift
mon osd min down reporters = 13          #默认值1        #向monitor报告down的最小OSD数
mon osd down out interval = 600          #默认值300      #标记一个OSD状态为down和out之前ceph等待的秒数
##############################################################
[osd]
osd data = /var/lib/ceph/osd/ceph-$id
osd journal size = 20000                                  #默认5120    #osd journal大小
osd journal = /var/lib/ceph/osd/$cluster-$id/journal      #osd journal 位置
osd mkfs type = xfs                                       #格式化系统类型
osd max write size = 512                                  #默认值90     #OSD一次可写入的最大值(MB)
osd client message size cap = 2147483648                  #默认值100    #客户端允许在内存中的最大数据(bytes)
osd deep scrub stride = 131072                            #默认值524288 #在Deep Scrub时候允许读取的字节数(bytes)
osd op threads = 16                                       #默认值2      #并发文件系统操作数
osd disk threads = 4                                      #默认值1      #OSD密集型操作例如恢复和Scrubbing时的线程
osd map cache size = 1024                                 #默认值500    #保留OSD Map的缓存(MB)
osd map cache bl size = 128                               #默认值50     #OSD进程在内存中的OSD Map缓存(MB)
osd mount options xfs = "rw,noexec,nodev,noatime,nodiratime,nobarrier"    #默认值rw,noatime,inode64 #Ceph OSD xfs Mount选项
osd recovery op priority = 2                              #默认值10     #恢复操作优先级，取值1-63，值越高占用资源越高
osd recovery max active = 10                              #默认值15     #同一时间内活跃的恢复请求数
osd max backfills = 4                                     #默认值10     #一个OSD允许的最大backfills数
osd min pg log entries = 30000                            #默认值3000   #修建PGLog是保留的最大PGLog数
osd max pg log entries = 100000                           #默认值10000  #修建PGLog是保留的最大PGLog数
osd mon heartbeat interval = 40                           #默认值30     #OSD ping一个monitor的时间间隔（默认30s）
ms dispatch throttle bytes = 1048576000                   #默认值 104857600 #等待派遣的最大消息数
objecter inflight ops = 819200                            #默认值1024   #客户端流控，允许的最大未发送io请求数，超过阀值会堵塞应用io，为0表示不受限
osd op log threshold = 50                                 #默认值5      #一次显示多少操作的log
osd crush chooseleaf type = 0                             #默认值为1    #CRUSH规则用到chooseleaf时的bucket的类型
filestore xattr use omap = true                           #默认false   #为XATTRS使用object map，EXT4文件系统时使用，XFS或者btrfs也可以使用
filestore min sync interval = 10                          #默认0.1     #从日志到数据盘最小同步间隔(seconds)
filestore max sync interval = 15                          #默认5       #从日志到数据盘最大同步间隔(seconds)
filestore queue max ops = 25000                           #默认500     #数据盘最大接受的操作数
filestore queue max bytes = 1048576000                    #默认100     #数据盘一次操作最大字节数(bytes
filestore queue committing max ops = 50000                #默认500     #数据盘能够commit的操作数
filestore queue committing max bytes = 10485760000        #默认100     #数据盘能够commit的最大字节数(bytes)
filestore split multiple = 8                              #默认值2     #前一个子目录分裂成子目录中的文件的最大数量
filestore merge threshold = 40                            #默认值10    #前一个子类目录中的文件合并到父类的最小数量
filestore fd cache size = 1024                            #默认值128   #对象文件句柄缓存大小
filestore op threads = 32                                 #默认值2     #并发文件系统操作数
journal max write bytes = 1073714824                      #默认值1048560 #journal一次性写入的最大字节数(bytes)
journal max write entries = 10000                         #默认值100     #journal一次性写入的最大记录数
journal queue max ops = 50000                             #默认值50      #journal一次性最大在队列中的操作数
journal queue max bytes = 10485760000                     #默认值33554432 #journal一次性最大在队列中的字节数(bytes)
##############################################################
[client]
rbd cache = true                                          #默认值 true #RBD缓存
rbd cache size = 335544320                                #默认值33554432 #RBD缓存大小(bytes)
rbd cache max dirty = 134217728                           #默认值25165824 #缓存为write-back时允许的最大dirty字节数(bytes)，如果为0，使用write-through
rbd cache max dirty age = 30                               #默认值1 #在被刷新到存储盘前dirty数据存在缓存的时间(seconds)
rbd cache writethrough until flush = false                #默认值true #该选项是为了兼容linux-2.6.32之前的virtio驱动，避免因为不发送flush请求，数据不回写
                                                          #设置该参数后，librbd会以writethrough的方式执行io，直到收到第一个flush请求，才切换为writeback方式。
rbd cache max dirty object = 2                            #默认值0 #最大的Object对象数，默认为0，表示通过rbd cache size计算得到，librbd默认以4MB为单位对磁盘Image进行逻辑切分
                                                          #每个chunk对象抽象为一个Object；librbd中以Object为单位来管理缓存，增大该值可以提升性能
rbd cache target dirty = 235544320                        #默认值16777216 #开始执行回写过程的脏数据大小，不能超过 rbd_cache_max_dirty
```

rgw常用的配置项
```
/etc/ceph/ceph.conf
#也可以全部写在rgw_frontends=""中空格分割开
[client.rgw.servera]
rgw_frontends="civetweb port=80"
#生产环境中指向负载均衡器的域名后缀
rgw_dns_name=servera
log_file=/var/log/ceph/servera.rgw.log
access_log_file=/var/log/ceph/civetweb.access.log
error_log_file=/var/log/ceph/civetweb.error.log
num_threads=100
```

# 限制pool配置更改
```
#禁止池被删除
osd_pool_default_flag_nodelete

#禁止池的pg_num和pgp_num被修改
osd_pool_default_flag_nopgchange

#禁止修改池的size和min_size
osd_pool_default_flag_nosizechange
```

# OSD状态参数
```
# osd之间传递心跳的间隔时间
osd_heartbeat_interval

# 一个osd多久没心跳，就会被集群认为它down了
osd_heartbeat_grace

# 确定一个osd状态为down的最少报告来源osd数
mon_osd_min_down_reporters

# 一个OSD必须重复报告一个osd状态为down的次数
mon_osd_min_down_reports

# 当osd停止响应多长时间，将其标记为down和out
mon_osd_down_out_interval

# monitor宣布失败osd为down前的等待时间
mon_osd_report_timeout

# 一个新的osd加入集群时，等待多长时间，开始向monitor报告
osd_mon_report_interval_min

# monitor允许osd报告的最大间隔，超时就认为它down了
osd_mon_report_interval_max

# osd向monitor报告心跳的时间
osd_mon_heartbeat_interval
```

# 清理调优参数
```
osd_scrub_begin_hour =                    #取值范围0-24
osd_scrub_end_hour = end_hbegin_hour our  #取值范围0-24
osd_scrub_load_threshold                  #当系统负载低于多少的时候可以清理，默认为0.5
osd_scrub_min_interval                    #多久清理一次，默认是一天一次（前提是系统负载低于上一个参数的设定）
osd_scrub_interval_randomize_ratio        #在清理的时候，随机延迟的值，默认是0.5
osd_scrub_max_interval                    #清理的最大间隔时间，默认是一周（如果一周内没清理过，这次就必须清理，不管负载是多少）
osd_scrub_priority                        #清理的优先级，默认是5
osd_deep_scrub_interal                    #深度清理的时间间隔，默认是一周
osd_scrub_sleep                           #当有磁盘读取时，则暂停清理，增加此值可减缓清理的速度以降低对客户端的影响，默认为0,范围0-1
```

# 管理回填和恢复操作的配置项
```
#用于限制每个osd上用于回填的并发操作数，默认为1
osd_max_backfills

#用于限制每个osd上用于恢复的并发操作数，默认为3
osd_recovery_max_active

#恢复操作的优先级，默认为3
osd_recovery_op_priority
```

# 资源池管理模块
```
$osd_reuse = 0;                             # 控制是否可以复用osd创建资源池。0、不支持复用，1、支持复用
$system_free_memory_limit = 60;             # 系统剩余内存水线,单位：%
$osd_memory_limit = 2097152;                # osd内存使用水线，单位：KB
$blu_cache_other_limit = 419430400;         # bluestore_cache_other使用水线,单位：byte
```

# bluestore相关
```
bluestore_block_size                        # 设置块大小，以分区建立osd时需要修改
bluestore_cache_size                        # 单个bluestore实例，配置cache大小
bluestore_block_wal_size = 10737418240      # bluestore wal大小
bluestore_block_db_size = 10737418240       # bluestore db大小
bluestore_cache_trim_interval               # bluestore trim周期
bluestore_cache_trim_max_skip_pinned        # 最大trim值
bluestore_prefer_deferred_size_hdd          # 控制io落wal分区io大小
```

# osd rocksdb相关
```
rocksdb_cache_shard_bits                    # 重庆现场修改为4后，导致磁盘读很大
```

# osd相关
```
osd_failsafe_full_ratio = 0.98              # 超过此限制op直接被抛弃
osd_recovery_max_chunk                      # 设置恢复过程中最大的块设备
osd_op_history_slow_op_size = 100           # slow op保存的历史记录数量
osd_op_history_slow_op_threshold = 1        # 当一个op超过多长时间，则记录上报
osd_peering_wq_threads=20                   # 设置peer线程数量
osd_peering_wq_batch_size=10                # 设置peer队列长度
osd_crush_update_on_start = false           # 默认不创建host
osd_heartbeat_use_min_delay_socket = true
osd_heartbeat_interval = 5
osd_heartbeat_grace = 17
osd_client_message_size_cap                 # OSD messenge大小
mon_osd_max_split_count                     # 最大增加的pg数量，如果想一次扩增很多pg，可用该方法
```

# osd性能
```
osd max write size                          # OSD一次可写入的最大值(MB)
osd client message size cap                 # 客户端允许在内存中的最大数据(bytes)
osd deep scrub stride                       # 在Deep Scrub时候允许读取的字节数(bytes)
osd op threads                              # OSD进程操作的线程数
osd disk threads                            # OSD密集型操作例如恢复和Scrubbing时的线程
osd map cache size                          # 保留OSD Map的缓存(MB)
osd map cache bl size                       # OSD进程在内存中的OSD Map缓存(MB)
osd mount options xfs                       # Ceph OSD xfs Mount选项
```

# osd recovery
```
osd recovery op priority                    # 恢复操作优先级，取值1-63，值越高占用资源越高
osd recovery max active                     # 同一时间内活跃的恢复请求数
osd max backfills                           # 一个OSD允许的最大backfills数

如下为生产环境限制回复速率配置：
osd_recovery_priority=3
osd_recovery_op_priority=2
osd_recovery_max_active=2                   # 同一时间内活跃的恢复请求数
osd_recovery_max_single_start=1
osd_recovery_sleep=0.1                      # 实际测试，该项最有效
```

# mon相关
```
mon_election_timeout                        # 设置mon选举超时时间
mon_osd_max_split_count                     # 每个osd最大pg数限制
mon_osd_backfillfull_ratio = 0.95           # 大于此数值时，拒绝pg通过Backfill的方式迁入或者继续迁出本OSD
mon_osd_full_ratio = 0.96                   # 集群停止接受客户端的请求
mon_osd_nearfull_ratio = 0.94               # 产生告警
mon_osd_max_split_count                     # 每个osd上最大的pg数量
mon_osd_full_ratio                          # 集群上的任意一个OSD空间使用率大于等于此数值时，集群将被标记为full，此时集群将停止接受来自客户端的写入请求
mon_osd_nearfull_ratio                      # 集群中的任一OSD空间使用率大于等于此数值时，集群将被标记为NearFull，此时集群将产生告警，并提示所有已经处于NearFull状态的OSD
osd_backfill_full_ratio                     # OSD空间使用率大于等于此数值时，拒绝PG通过Backfill方式迁出或者继续迁入本OSD
osd_failsafe_full_ratio                     # PG执行包含写操作的op时，防止所在的OSD磁盘空间被100%写满的最后一道屏障，超过此限制时，op将直接被丢弃
mon_data_avail_crit                         # 系统卡使用量低于此值时，mon 挂掉
client_mount_timeout                        # ceph命令hand住时间控制，默认300 S
```

# paxos相关：
```
paxos_min                                   # paxos消息上一次trim和当前值最小差距
paxos_service_trim_max                      # Paxos_service维护的15个消息类型每次trim的最数值
paxos_service_trim_min                      # axos_service维护的15个消息类型每次trim的最小值，如果没有到达改值，则不发生trim
paxos_trim_max                              # Paxos消息发送trim时，trim的最大值
paxos_trim_min                              # 和paxos_min共同决定，本次应该不应该发送trim

通过阅读代码分析，源码里面触发compaction的地方一共有下面五处
1、当mon_compact_on_trim为false时，mon直接不触发compact，compact全权由rocksdb自身机制触发
2、first_committed >= get_version() - paxos_min时，翻译一下就是如果当前版本增长量没有超过paxos_min
3、first_committed >= get_first_committed() + paxos_trim_max);翻译一下就是第一次committed值加上paxos_trim_max仍然等于first_committed时，只有当paxos_trim_max为0才有可能
4、get_version() - get_first_committed() <= paxos_min + paxos_trim_min时，即当前版本差异小于paxos_min+paxos_trim_min之和时
5、to_remove < paxos_service_trim_min时
需要注意的是2、3、4限制的是消息头为paxos的数据，5限制的是消息头为auth 、health、 logm、mdsmap、mgr  、mgr_command_descs、 mgr_metadata、mgrstat、monitor、monitor_store  monmap 、osdmap、osd_metadata、osd_pg_creating、pgmap的数据，任何一个数据达到上述限制值都会触发compact
当前设置下：
1、paxos数据版本差距为paxos_min+ paxos_trim_min = 5000+2500=7500时，paxos消息会触发compact
2、auth 、health、 logm、mdsmap、mgr  、mgr_command_descs、 mgr_metadata、mgrstat monitor、monitor_store         monmap  、osdmap、osd_metadata、osd_pg_creating、pgmap任意一个消息版本超过paxos_service_trim_min = 7500时触发compact
```

# 网络相关：
```
public_network={public-network/netmask}      # 负责确保ceph服务端和客户端在同一网络或者子网
cluster_network={cluster-network/netmask}    # 定义一个集群的网络，osd会用这个网络进行心跳控制，对象复制和恢复通信，如果没有配置该网络，Ceph默认会使用public_network用做此网络的作用
max open files                               # 如果设置了该选项， Ceph会设置系统的max open fds
```

# Bluefs相关
```
bluefs_alloc_size                            # 最小进度大小，默认为1M
bluefs_max_prefetch                          # 预读时的最大字节数，默认为1MB，主要用在顺序读场景
//日志文件
bluefs_min_log_runway                        # bluefs日志文件的可用空间小于此值时，新分配空间。默认为1MB
bluefs_max_log_runway                        # bluefs日志文件的单次分配大小，默认为4MB
bluefs_log_compact_min_ratio                 # 通过当前日志文件大小和预估的日志文件的大小的比率控制compact，默认为5
bluefs_log_compact_min_size                  # 通过日志文件大小控制compact，小于此值不做compact。默认为16MB
bluefs_compact_log_sync                      # 日志文件compact的方式，有sync和async两种，默认为false，即采用async方式
bluefs_min_flush_size                        # 因为写文件内容是写到内存中的，当文件内容超过此值就刷新到磁盘。默认为512kb
bluefs_buffered_io                           # bluefs调用BlockDevice的read/write时的参数，默认为false，即采用fd_direct
bluefs_sync_write                            # 是否采用synchronous写。默认为false，即采用aio_write。这时候在flush block
device的时候，需要等待aio完成。参见函数_flush_bdev_safely
bluefs_allocator                             # bluefs分配磁盘空间的分配器，默认为stupid，即基于extent的方式。
bluefs_preextend_wal_files                   # 是否预先更新rocksdb wal文件的大小。默认为false
```

# libaio相关参数
```
bdev_aio                    # 默认为true。不能修改，现在只支持aio方式操作磁盘
bdev_aio_poll_ms            # libaio API io_getevents的超时时间，默认为250
bdev_aio_max_queue_depth    # libaio API io_setup的最大队列深度, 默认为1024
bdev_aio_reap_max           # libaio API io_getevents每次请求返回的最大条目数
bdev_block_size             # 磁盘块大小，默认4096字节
```

# nvme相关参数
```
bdev_nvme_unbind_from_kernel
bdev_nvme_retry_count
```

# rbd相关
```
[client.admin] 
rbd_cache = true                   # RBD缓存
rbd_cache_max_dirty 891289600      # 缓存为write-back时允许的最大dirty字节数(bytes)，如果为0，使用write-through
rbd_cache_max_dirty_age 10         # 在被刷新到存储盘前dirty数据存在缓存的时间(seconds)
rbd_cache_size 1073741824          # RBD缓存大小(bytes)
rbd_cache_target_dirty 754974720
```

# pg相关
```
# 控制pg收敛速度
osd_peering_wq_threads   = 2 
osd_peering_wq_batch_size = 20
```

# rados相关
```
# rados层到osd 与mon的超时检测
rados_mon_op_timeout = 10
rados_osd_op_timeout = 10 
```

```
[global]
fsid = 1235bE62-8ae1-difg-893a-892a675757c6
mon_initial_members = ceph-node01,ceph-node02,ceph-node03
mon_host = 192.168.170.11,192.168.170.12,192.168.170.13
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
public_network = 192.168.170.0/22                           #管理网络
cluster_network = 192.168.180.0/22                          #集群网络
mon_pg_warn_max_per_osd = 1000                              #每个osd上pg数量警告值，这个可以根据具体规划来设定
osd_pool_default_size = 3                                   #默认副本数为3
osd_pool_default_min_size = 2                               #最小副本数为2，也就是只能坏一个
mon_osd_full_ratio = .85                                    #存储使用率达到85%将不再提供数据存储
mon_osd_nearfull_ratio = .70                                #存储使用率达到70%集群将会warn状态
osd_deep_scrub_randomize_ratio = 0.01                       #随机深度清洗概率,值越大，随机深度清洗概率越高,太高会影响业务

[osd]
osd_max_write_size = 1024                                   #默认90M，一次写操作最小值
osd_recovery_op_priority = 1                                #默认为10, 1-63 osd修复操作的优先级, 。值越小，优先级越低
osd_recovery_max_active = 1                                 #限定每个osd上同时有多少个pg可以同时进行recover
osd_recovery_max_single_start = 1                           #和osd_recovery_max_active一起使用，要理解其含义。假设我们配置osd_recovery_max_single_start为1，osd_recovery_max_active为3，那么，这意味着OSD在某个时刻会为一个PG启动一个恢复操作，而且最多可以有三个恢复操作同时处于活动状态。
osd_recovery_max_chunk = 1048576                            #默认为8388608, 设置恢复数据块的大小，以防网络阻塞
osd_recovery_threads = 1                                    #恢复数据所需的线程数
osd_max_backfills = 1                                       #集群故障后,最大backfill数为1，太大会影响业务
osd_scrub_begin_hour = 22                                   #清洗开始时间为晚上22点
osd_scrub_end_hour = 7                                      #清洗结束时间为早上7点
osd_recovery_sleep = 0                                      #默认为0，recovery的时间间隔，会影响recovery时常，如果recovery导致业务不正常，可以调大该值，增加时间间隔
osd_crush_update_on_start = false                           #新加的osd会up/in,但并不会更新crushmap，prepare+active期间不会导致数据迁移
```
