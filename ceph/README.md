| ceph 书籍 | 网址 |
|-----------|------|
| 官方中文文档 | http://docs.ceph.org.cn/architecture/ |
| Ceph实践 | https://github.com/frank6866/gitbook-ceph |
| ceph运维手册 | https://github.com/lihaijing/ceph-handbook |
| 博客 | https://www.jianshu.com/u/305dfce65e38 |
| 博客 | https://www.jianshu.com/u/e2dfdb98f630 |
| 书 | https://www.kancloud.cn/willseecloud/ceph/1788233 |
| 书 | https://www.bookstack.cn/read/zxj_ceph/deploy |
| 博客 | https://cloud.tencent.com/developer/user/1452146 |
| 博客 | https://blog.csdn.net/weixin_43719988 |
| 博客 | https://www.cnblogs.com/zyxnhr/tag/Ceph/ |
| pglog | https://blog.51cto.com/wendashuai/2493295 |
| 博客 | http://tang-lei.com/categories/ceph/ |


# ceph最小硬件要求

| **HARDWARE**| **OSD** | **MON** | **RADOSGW** | **MDS** |
|-------------|---------|---------|-------------|----------|
| **Processor** | 1X AMD64 or intel 64 | 1X AMD64 or intel 64 | 1X AMD64 or intel 64 | 1X AMD64 or intel 64 |
| **RAM** | 16GB for the host,plus an additional 2GB of RAM per OSD daemon | 1GB per daemon | 1GB per daemon | 1GB per daemon (but depends heavily on configured MDS cachesize)
| **Disk** | One storage device per OSD daemon separate from the system disk | 10GB per daemon | 5GB per daemon | 1MB per daemon,plus space for log file(varies) |
| **Network** | 2x Gigabit Ethernet NICs | 2x Gigabit Ethernet NICs | 2x Gigabit Ethernet NICs | 2x Gigabit Ethernet NICs |

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

# ceph的版本历史：

Ceph的第一个版本是0.1发布日期为2008年1月,多年来ceph的版本号一直采用递归更新的方式没变，直到2015年4月0.94.1（Hammer的第一个修正版）发布后，为了避免0.99（以及0.100或1.00），后期的命名方式发生了改变
- x.0.z: 开发版（给早期厕所者和勇士们）
- x.1.z: 候选版（用于测试集群，高手们）
- x.2.z: 稳定，修正版（给用户们）

> x 将从9算起，它代表infemalis（首字母I是因为单词中的第九个字母），这样我们第九个发布周期的第一个开发版就是9.0.0后期的开发版依次是`9.0.0`->`9.0.1`->`9.0.2`等，测试版本就是`9.1.0`->`9.1.1`->`9.1.2`，稳定版本就是`9.2.0`->`9.2.1`->`9.2.2`。

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


Ceph常用端口
| 端口号 | 用途 |
|--------|-------|
| tcp/6789 | monitor之间进6789端口行通信 |
| tcp/6800-7300 | osd进程会在这个范围内使用可用的端口号 |
| tcp/7480 | rgw的endpoint端口 |


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

## 文件存储过程

第一步：文件计算到对象的映射：
> 计算文件到对象的映射，列如file为客户端要读写的文件，得到oid(object id) = ino + ono
> ion: inode number(ION), file的元数据序列号，file的唯一id.
> ono: object number(ONO), file切分产生的某个object的序号，默认以4M切分一个块大小

第二步：通过hash算法计算出文件对应的pool中的PG:
> 通过一致性HASH计算Object到PG,Object -> PG映射hash(oid) & mask -> pgid

第三步：通过CRUSH把对象映射到OSD
> 通过CRUSH算法计算PG到OSD,PG -> OSD映射：[CRUSH(pgid)->(osd1,osd2,osd3)]

第四步：PG中的主OSD将对象写入到硬盘

第五步：主OSD将数据同步给备份OSD,并等待备份OSD返回确认

第六步：主OSD将写入完成返回给客户端

https://www.jianshu.com/p/9d740d025034

https://www.cnblogs.com/kevingrace/p/5569737.html
