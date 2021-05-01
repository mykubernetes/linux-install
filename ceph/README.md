| ceph 书籍 | 网址 |
|-----------|------|
| 官方中文文档 | http://docs.ceph.org.cn/architecture/ |
| Ceph实践 | https://github.com/frank6866/gitbook-ceph |
| ceph运维手册 | https://github.com/lihaijing/ceph-handbook |
| 博客 | https://blog.51cto.com/michaelkang/category9.html |
| ceph运维手册 | https://lihaijing.gitbooks.io/ceph-handbook/content/ |








# Ceph核心概念
## RADOS
>全称Reliable Autonomic Distributed Object Store，即可靠的、自动化的、分布式对象存储系统。RADOS是Ceph集群的精华，用户实现数据分配、Failover等集群操作。
## Librados
>Rados提供库，因为RADOS是协议很难直接访问，因此上层的RBD、RGW和CephFS都是通过librados访问的，目前提供PHP、Ruby、Java、Python、C和C++支持。
## Crush
>Crush算法是Ceph的两大创新之一，通过Crush算法的寻址操作，Ceph得以摒弃了传统的集中式存储元数据寻址方案。而Crush算法在一致性哈希基础上很好的考虑了容灾域的隔离，使得Ceph能够实现各类负载的副本放置规则，例如跨机房、机架感知等。同时，Crush算法有相当强大的扩展性，理论上可以支持数千个存储节点，这为Ceph在大规模云环境中的应用提供了先天的便利。
## Pool
>Pool是存储对象的逻辑分区，它规定了数据冗余的类型和对应的副本分布策略，支持两种类型：副本（replicated）和 纠删码（ Erasure Code）；
## PG
>PG（ placement group）是一个放置策略组，它是对象的集合，该集合里的所有对象都具有相同的放置策略，简单点说就是相同PG内的对象都会放到相同的硬盘上，PG是 ceph的逻辑概念，服务端数据均衡和恢复的最小粒度就是PG，一个PG包含多个OSD。引入PG这一层其实是为了更好的分配数据和定位数据；
## Object
>简单来说块存储读写快，不利于共享，文件存储读写慢，利于共享。能否弄一个读写快，利 于共享的出来呢。于是就有了对象存储。最底层的存储单元，包含元数据和原始数据。

# Ceph核心组件
## OSD
>OSD是负责物理存储的进程，一般配置成和磁盘一一对应，一块磁盘启动一个OSD进程。主要功能是存储数据、复制数据、平衡数据、恢复数据，以及与其它OSD间进行心跳检查，负责响应客户端请求返回具体数据的进程等；  

Pool、PG和OSD的关系：
* 一个Pool里有很多PG；  
* 一个PG里包含一堆对象，一个对象只能属于一个PG；  
* PG有主从之分，一个PG分布在不同的OSD上（针对三副本类型）;  

## Monitor
>一个Ceph集群需要多个Monitor组成的小集群，它们通过Paxos同步数据，用来保存OSD的元数据。负责坚实整个Ceph集群运行的Map视图（如OSD Map、Monitor Map、PG Map和CRUSH Map），维护集群的健康状态，维护展示集群状态的各种图表，管理集群客户端认证与授权；
## MDS
>MDS全称Ceph Metadata Server，是CephFS服务依赖的元数据服务。负责保存文件系统的元数据，管理目录结构。对象存储和块设备存储不需要元数据服务；
## Mgr
>ceph 官方开发了 ceph-mgr，主要目标实现 ceph 集群的管理，为外界提供统一的入口。例如cephmetrics、zabbix、calamari、promethus
## RGW
>RGW全称RADOS gateway，是Ceph对外提供的对象存储服务，接口与S3和Swift兼容。
## Admin
>Ceph常用管理接口通常都是命令行工具，如rados、ceph、rbd等命令，另外Ceph还有可以有一个专用的管理节点，在此节点上面部署专用的管理工具来实现近乎集群的一些管理工作，如集群部署，集群组件管理等。


# Ceph三种存储类型
## 1、 块存储（RBD）  

- 优点：
    * 通过Raid与LVM等手段，对数据提供了保护；
    * 多块廉价的硬盘组合起来，提高容量；
    * 多块磁盘组合出来的逻辑盘，提升读写效率；  

- 缺点：
    * 采用SAN架构组网时，光纤交换机，造价成本高；
    * 主机之间无法共享数据；
- 使用场景
    * docker容器、虚拟机磁盘存储分配；
    * 日志存储；
    * 文件存储；
    
## 2、文件存储（CephFS）
- 优点：
    * 造价低，随便一台机器就可以了；
    * 方便文件共享；

- 缺点：
    * 读写速率低；
    * 传输速率慢；
- 使用场景
    * 日志存储；
    * FTP、NFS；
    * 其它有目录结构的文件存储
## 3、对象存储（Object）(适合更新变动较少的数据)
- 优点：
    * 具备块存储的读写高速；
    * 具备文件存储的共享等特性；

| 版本名称 | 版本号 | 发布时间 |
| ------ | ------ | ------ |
| Argonaut | 0.48版本(LTS) | 　2012年6月3日 |
| Bobtail | 0.56版本(LTS) | 　2013年5月7日 |
| Cuttlefish | 0.61版本 | 　2013年1月1日 |
| Dumpling | 0.67版本(LTS) | 　2013年8月14日 |
| Emperor | 0.72版本 | 　2013年11月9 |
| Firefly | 0.80版本(LTS) | 　2014年5月 |
| Giant | Giant | 　October 2014 - April 2015 |
| Hammer | Hammer | 　April 2015 - November 2016|
| Infernalis | Infernalis | 　November 2015 - June 2016 |
| Jewel | 10.2.9 | 　2016年4月 |
| Kraken | 11.2.1 | 　2017年10月 |
| Luminous |12.2.12  | 　2017年10月 |
| mimic | 13.2.7 | 　2018年5月 |
| nautilus | 14.2.5 | 　2019年2月 |

## Luminous新版本特性
- Bluestore
  * ceph-osd的新后端存储BlueStore已经稳定，是新创建的OSD的默认设置。
BlueStore通过直接管理物理HDD或SSD而不使用诸如XFS的中间文件系统，来管理每个OSD存储的数据，这提供了更大的性能和功能。
  * BlueStore支持Ceph存储的所有的完整的数据和元数据校验。
  * BlueStore内嵌支持使用zlib，snappy或LZ4进行压缩。（Ceph还支持zstd进行RGW压缩，但由于性能原因，不为BlueStore推荐使用zstd）
- 集群的总体可扩展性有所提高。我们已经成功测试了多达10,000个OSD的集群。
- ceph-mgr
  * ceph-mgr是一个新的后台进程，这是任何Ceph部署的必须部分。虽然当ceph-mgr停止时，IO可以继续，但是度量不会刷新，并且某些与度量相关的请求（例如，ceph df）可能会被阻止。我们建议您多部署ceph-mgr的几个实例来实现可靠性。
  * ceph-mgr守护进程daemon包括基于REST的API管理。注：API仍然是实验性质的，目前有一些限制，但未来会成为API管理的基础。
  * ceph-mgr还包括一个Prometheus插件。
  * ceph-mgr现在有一个Zabbix插件。使用zabbix_sender，它可以将集群故障事件发送到Zabbix Server主机。这样可以方便地监视Ceph群集的状态，并在发生故障时发送通知。

# 二、安装前准备
1. 安装要求 
- 最少三台Centos7系统虚拟机用于部署Ceph集群。硬件配置：2C4G，另外每台机器最少挂载三块硬盘(每块盘5G)  
cephnode01 10.151.30.125  
cephnode02 10.151.30.126  
cephnode03 10.151.30.127  
- 内网yum源服务器，硬件配置2C4G  
cephyumresource01 10.151.30.110

2. 环境准备（在Ceph三台机器上操作）
```
（1）关闭防火墙：
systemctl stop firewalld
systemctl disable firewalld
（2）关闭selinux：
sed -i 's/enforcing/disabled/' /etc/selinux/config
setenforce 0
（3）关闭NetworkManager
systemctl disable NetworkManager && systemctl stop NetworkManager
（4）添加主机名与IP对应关系：
vim /etc/hosts
10.151.30.125 cephnode01
10.151.30.126 cephnode02
10.151.30.127 cephnode03
（5）设置主机名：
hostnamectl set-hostname cephnode01
hostnamectl set-hostname cephnode02
hostnamectl set-hostname cephnode03
（6）同步网络时间和修改时区
systemctl restart chronyd.service && systemctl enable chronyd.service
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
（7）设置文件描述符
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
* soft nofile 65535
* hard nofile 65535
EOF
（8）内核参数优化
cat >> /etc/sysctl.conf << EOF
kernel.pid_max = 4194303
echo "vm.swappiness = 0" /etc/sysctl.conf 
EOF
sysctl -p
（9）在cephnode01上配置免密登录到cephnode02、cephnode03
ssh-copy-id root@cephnode02
ssh-copy-id root@cephnode03
(10)read_ahead,通过数据预读并且记载到随机访问内存方式提高磁盘读操作
echo "8192" > /sys/block/sda/queue/read_ahead_kb
(11) I/O Scheduler，SSD要用noop，SATA/SAS使用deadline
echo "deadline" >/sys/block/sd[x]/queue/scheduler
echo "noop" >/sys/block/sd[x]/queue/scheduler
```
# 三、安装内网yum源
1、安装httpd、createrepo和epel源
```
yum install httpd createrepo epel-release -y
```
2、编辑yum源文件
```
[root@cephyumresource01 ~]# more /etc/yum.repos.d/ceph.repo 
[Ceph]
name=Ceph packages for $basearch
baseurl=http://mirrors.163.com/ceph/rpm-nautilus/el7/$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.163.com/ceph/rpm-nautilus/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
```
3、下载Ceph安装包
```
yum --downloadonly --downloaddir=/var/www/html/ceph/rpm-nautilus/el7/x86_64/ install ceph ceph-radosgw 
```
4、下载Ceph依赖文件
```
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/ceph-14.2.4-0.el7.src.rpm 
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/ceph-deploy-2.0.1-0.src.rpm
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-deploy-2.0.1-0.noarch.rpm
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-grafana-dashboards-14.2.4-0.el7.noarch.rpm 
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-mgr-dashboard-14.2.4-0.el7.noarch.rpm
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-mgr-diskprediction-cloud-14.2.4-0.el7.noarch.rpm
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-mgr-diskprediction-local-14.2.4-0.el7.noarch.rpm
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-mgr-rook-14.2.4-0.el7.noarch.rpm 
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-mgr-ssh-14.2.4-0.el7.noarch.rpm 
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/ceph-release-1-1.el7.noarch.rpm 
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/ceph-release-1-1.el7.src.rpm 
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/ceph-medic-1.0.4-16.g60cf7e9.el7.src.rpm
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/repodata/repomd.xml 
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/repodata/repomd.xml
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/repodata/a4bf0ee38cd4e64fae2d2c493e5b5eeeab6cf758beb7af4eec0bc4046b595faf-filelists.sqlite
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/repodata/a4bf0ee38cd4e64fae2d2c493e5b5eeeab6cf758beb7af4eec0bc4046b595faf-filelists.sqlite.bz2
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/repodata/183278bb826f5b8853656a306258643384a1547c497dd8b601ed6af73907bb22-other.sqlite.bz2 
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/repodata/52bf459e39c76b2ea2cff2c5340ac1d7b5e17a105270f5f01b454d5a058adbd2-filelists.sqlite.bz2
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/repodata/4f3141aec1132a9187ff5d1b4a017685e2f83a761880884d451a288fcedb154e-primary.sqlite.bz2
wget mirrors.163.com/ceph/rpm-nautilus/el7/SRPMS/repodata/0c554884aa5600b1311cd8f616aa40d036c1dfc0922e36bcce7fd84e297c5357-other.sqlite.bz2 
wget mirrors.163.com/ceph/rpm-nautilus/el7/noarch/repodata/597468b64cddfc386937869f88c2930c8e5fda3dd54977c052bab068d7438fcb-primary.sqlite.bz2
```
5、更新yum源
```
createrepo --update  /var/www/html/ceph/rpm-nautilus
```
# 四、安装Ceph集群
1、编辑内网yum源,将yum源同步到其它节点并提前做好yum makecache
```
# vim /etc/yum.repos.d/ceph.repo 
[Ceph]
name=Ceph packages for $basearch
baseurl=http://10.151.30.110/ceph/rpm-nautilus/el7/$basearch
gpgcheck=0
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://10.151.30.110/ceph/rpm-nautilus/el7/noarch
gpgcheck=0
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://10.151.30.110/ceph/rpm-nautilus/el7/srpms
gpgcheck=0
priority=1
```
2、安装ceph-deploy(确认ceph-deploy版本是否为2.0.1)
```
# yum install -y ceph-deploy
```
3、创建一个my-cluster目录，所有命令在此目录下进行（文件位置和名字可以随意）
```
# mkdir /my-cluster
# cd /my-cluster
```
4、创建一个Ceph集群
```
# ceph-deploy new cephnode01 cephnode02 cephnode03 
```
5、安装Ceph软件（每个节点执行）
```
# yum -y install epel-release
# yum install -y ceph
```
6、生成monitor检测集群所使用的的秘钥
```
# ceph-deploy mon create-initial
```
7、安装Ceph CLI，方便执行一些管理命令
```
# ceph-deploy admin cephnode01 cephnode02 cephnode03
```
8、配置mgr，用于管理集群
```
# ceph-deploy mgr create cephnode01 cephnode02 cephnode03
```
9、部署rgw
```
# yum install -y ceph-radosgw
# ceph-deploy rgw create cephnode01
```
10、部署MDS（CephFS）
```
# ceph-deploy mds create cephnode01 cephnode02 cephnode03 
```
11、添加osd
```
ceph-deploy osd create --data /dev/sdb cephnode01
ceph-deploy osd create --data /dev/sdc cephnode01
ceph-deploy osd create --data /dev/sdd cephnode01
ceph-deploy osd create --data /dev/sdb cephnode02
ceph-deploy osd create --data /dev/sdc cephnode02
ceph-deploy osd create --data /dev/sdd cephnode02
ceph-deploy osd create --data /dev/sdb cephnode03
ceph-deploy osd create --data /dev/sdc cephnode03
ceph-deploy osd create --data /dev/sdd cephnode03
```
# 五、ceph.conf

1、该配置文件采用init文件语法，#和;为注释，ceph集群在启动的时候会按照顺序加载所有的conf配置文件。 配置文件分为以下几大块配置。

    global：全局配置。
    osd：osd专用配置，可以使用osd.N，来表示某一个OSD专用配置，N为osd的编号，如0、2、1等。
    mon：mon专用配置，也可以使用mon.A来为某一个monitor节点做专用配置，其中A为该节点的名称，ceph-monitor-2、ceph-monitor-1等。使用命令 ceph mon dump可以获取节点的名称。
    client：客户端专用配置。

2、配置文件可以从多个地方进行顺序加载，如果冲突将使用最新加载的配置，其加载顺序为。

    $CEPH_CONF环境变量
    -c 指定的位置
    /etc/ceph/ceph.conf
    ~/.ceph/ceph.conf
    ./ceph.conf

3、配置文件还可以使用一些元变量应用到配置文件，如。

    $cluster：当前集群名。
    $type：当前服务类型。
    $id：进程的标识符。
    $host：守护进程所在的主机名。
    $name：值为$type.$id。

4、ceph.conf详细参数
```
[global]#全局设置
fsid = xxxxxxxxxxxxxxx                                  #集群标识ID 
mon host = 10.0.1.1,10.0.1.2,10.0.1.3                   #monitor IP 地址
auth cluster required = cephx                           #集群认证
auth service required = cephx                           #服务认证
auth client required = cephx                            #客户端认证
osd pool default size = 3                               #最小副本数 默认是3
osd pool default min size = 1                           #PG 处于 degraded 状态不影响其 IO 能力,min_size是一个PG能接受IO的最小副本数
public network = 10.0.1.0/24                            #公共网络(monitorIP段) 
cluster network = 10.0.2.0/24                           #集群网络
max open files = 131072                                 #默认0#如果设置了该选项，Ceph会设置系统的max open fds
mon initial members = node1, node2, node3               #初始monitor (由创建monitor命令而定)
##############################################################
[mon]
mon data = /var/lib/ceph/mon/ceph-$id
mon clock drift allowed = 1                             #默认值0.05#monitor间的clock drift
mon osd min down reporters = 13                         #默认值1#向monitor报告down的最小OSD数
mon osd down out interval = 600            #默认值300    #标记一个OSD状态为down和out之前ceph等待的秒数
##############################################################
[osd]
osd data = /var/lib/ceph/osd/ceph-$id
osd mkfs type = xfs                                        #格式化系统类型
osd max write size = 512                   #默认值90        #OSD一次可写入的最大值(MB)
osd client message size cap = 2147483648   #默认值100       #客户端允许在内存中的最大数据(bytes)
osd deep scrub stride = 131072             #默认值524288    #在Deep Scrub时候允许读取的字节数(bytes)
osd op threads = 16                        #默认值2         #并发文件系统操作数
osd disk threads = 4                       #默认值1         #OSD密集型操作例如恢复和Scrubbing时的线程
osd map cache size = 1024                  #默认值500       #保留OSD Map的缓存(MB)
osd map cache bl size = 128                #默认值50        #OSD进程在内存中的OSD Map缓存(MB)
osd mount options xfs = "rw,noexec,nodev,noatime,nodiratime,nobarrier"   #默认值rw,noatime,inode64  #Ceph OSD xfs Mount选项
osd recovery op priority = 2               #默认值10        #恢复操作优先级，取值1-63，值越高占用资源越高
osd recovery max active = 10               #默认值15        #同一时间内活跃的恢复请求数 
osd max backfills = 4                      #默认值10        #一个OSD允许的最大backfills数
osd min pg log entries = 30000             #默认值3000      #修建PGLog是保留的最大PGLog数
osd max pg log entries = 100000            #默认值10000     #修建PGLog是保留的最大PGLog数
osd mon heartbeat interval = 40            #默认值30        #OSD ping一个monitor的时间间隔（默认30s）
ms dispatch throttle bytes = 1048576000    #默认值 104857600     #等待派遣的最大消息数
objecter inflight ops = 819200             #默认值1024      #客户端流控，允许的最大未发送io请求数，超过阀值会堵塞应用io，为0表示不受限
osd op log threshold = 50                  #默认值5         #一次显示多少操作的log
osd crush chooseleaf type = 0              #默认值为1       #CRUSH规则用到chooseleaf时的bucket的类型
##############################################################
[client]
rbd cache = true                     #默认值 true     #RBD缓存
rbd cache size = 335544320           #默认值33554432           #RBD缓存大小(bytes)
rbd cache max dirty = 134217728      #默认值25165824      #缓存为write-back时允许的最大dirty字节数(bytes)，如果为0，使用write-through
rbd cache max dirty age = 30         #默认值1                #在被刷新到存储盘前dirty数据存在缓存的时间(seconds)
rbd cache writethrough until flush = false #默认值true  #该选项是为了兼容linux-2.6.32之前的virtio驱动，避免因为不发送flush请求，数据不回写
              #设置该参数后，librbd会以writethrough的方式执行io，直到收到第一个flush请求，才切换为writeback方式。
rbd cache max dirty object = 2       #默认值0              #最大的Object对象数，默认为0，表示通过rbd cache size计算得到，librbd默认以4MB为单位对磁盘Image进行逻辑切分
      #每个chunk对象抽象为一个Object；librbd中以Object为单位来管理缓存，增大该值可以提升性能
rbd cache target dirty = 235544320   #默认值16777216    #开始执行回写过程的脏数据大小，不能超过 rbd_cache_max_dirty
```
