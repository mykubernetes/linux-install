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
