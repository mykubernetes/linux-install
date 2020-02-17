# 一、CephFs介绍
 >Ceph File System (CephFS) 是与 POSIX 标准兼容的文件系统, 能够提供对 Ceph 存储集群上的文件访问. Jewel 版本 (10.2.0) 是第一个包含稳定 CephFS 的 Ceph 版本. CephFS 需要至少一个元数据服务器 (Metadata Server - MDS) daemon (ceph-mds) 运行, MDS daemon 管理着与存储在 CephFS 上的文件相关的元数据, 并且协调着对 Ceph 存储系统的访问。  
 >>对象存储的成本比起普通的文件存储还是较高，需要购买专门的对象存储软件以及大容量硬盘。如果对数据量要求不是海量，只是为了做文件共享的时候，直接用文件存储的形式好了，性价比高。
 # 二、CephFS 架构
 底层是核心集群所依赖的, 包括:

- OSDs (ceph-osd): CephFS 的数据和元数据就存储在 OSDs 上
- MDS (ceph-mds): Metadata Servers, 管理着 CephFS 的元数据
- Mons (ceph-mon): Monitors 管理着集群 Map 的主副本
Ceph 存储集群的协议层是 Ceph 原生的 librados 库, 与核心集群交互.

CephFS 库层包括 CephFS 库 libcephfs, 工作在 librados 的顶层, 代表着 Ceph 文件系统.最上层是能够访问 Ceph 文件系统的两类客户端.

# 三、配置 CephFS MDS
  要使用 CephFS， 至少就需要一个 metadata server 进程。可以手动创建一个 MDS， 也可以使用 ceph-deploy 或者 ceph-ansible 来部署 MDS。  
```
登录到ceph-deploy工作目录执行
# ceph-deploy mds create $hostname
```
# 四、部署Ceph文件系统
部署一个 CephFS, 步骤如下:

1. 在一个 Mon 节点上创建 Ceph 文件系统.
2. 若使用 CephX 认证,需要创建一个访问 CephFS 的客户端
3. 挂载 CephFS 到一个专用的节点.
   - 以 kernel client 形式挂载 CephFS
   - 以 FUSE client 形式挂载 CephFS
## 1、创建一个 Ceph 文件系统
1、CephFS 需要两个 Pools - cephfs-data 和 cephfs-metadata, 分别存储文件数据和文件元数据
```
# ceph osd pool create cephfs-data 256 256
# ceph osd pool create cephfs-metadata 64 64
```
注：一般 metadata pool 可以从相对较少的 PGs 启动, 之后可以根据需要增加 PGs. 因为 metadata pool 存储着 CephFS 文件的元数据, 为了保证安全, 最好有较多的副本数. 为了能有较低的延迟, 可以考虑将 metadata 存储在 SSDs 上.

2、创建一个 CephFS, 名字为 cephfs:
```
# ceph fs new cephfs cephfs-metadata cephfs-data
```
3、验证至少有一个 MDS 已经进入 Active 状态
```
ceph fs status cephfs
```
4、在 Monitor 上, 创建一个用户，用于访问CephFs
```
# ceph auth get-or-create client.cephfs mon 'allow r' mds 'allow rw' osd 'allow rw pool=cephfs-data, allow rw pool=cephfs-metadata'
```
5、验证key是否生效
```
ceph auth get client.cephfs
```
6、检查CephFs和mds状态
```
ceph mds stat
ceph fs ls
ceph fs status
```
### 1.1 以 kernel client 形式挂载 CephFS
1、创建挂载目录 cephfs
```
# mkdir /cephfs
```
2、挂载目录
```
# mount -t ceph 10.151.30.125:6789,10.151.30.126:6789,10.151.30.127:6789:/ /cephfs/ -o name=cephfs,secret=AQDHjeddHlktJhAAxDClZh9mvBxRea5EI2xD9w==
```
3、自动挂载
```
# echo "mon1:6789,mon2:6789,mon3:6789:/ /cephfs ceph name=cephfs,secretfile=/etc/ceph/cephfs.key,_netdev,noatime 0 0" | sudo tee -a /etc/fstab
```
4、验证是否挂载成功
```
# stat -f /cephfs
```

### 1.2 以 FUSE client 形式挂载 CephFS
1、安装ceph-common
```
yum install -y ceph-common
```
2、安装ceph-fuse
```
yum install -y ceph-fuse
```
3、将集群的ceph.conf拷贝到客户端
```
scp root@10.151.30.125:/etc/ceph/ceph.conf /etc/ceph/
chmod 644 /etc/ceph/ceph.conf
```
4、使用 ceph-fuse 挂载 CephFS
```
ceph-fuse --keyring  /etc/ceph/ceph.client.cephfs.keyring  --name client.cephfs -m 10.151.30.125:6789,10.151.30.126:6789,10.151.30.127:6789  /cephfs/
```
5、验证 CephFS 已经成功挂载
```
stat -f /cephfs
```

6、自动挂载
```
echo "none /cephfs fuse.ceph ceph.id=cephfs[,ceph.conf=/etc/ceph/ceph.conf],_netdev,defaults 0 0"| sudo tee -a /etc/fstab
或
echo "id=cephfs,conf=/etc/ceph/ceph.conf /mnt/ceph2  fuse.ceph _netdev,defaults 0 0"| sudo tee -a /etc/fstab
```
7、卸载
```
fusermount -u /cephfs
```
# 五、MDS主备与主主切换
## 1、配置主主模式
- 当cephfs的性能出现在MDS上时，就应该配置多个活动的MDS。通常是多个客户机应用程序并行的执行大量元数据操作，并且它们分别有自己单独的工作目录。这种情况下很适合使用多主MDS模式。  
- 配置MDS多主模式  
每个cephfs文件系统都有一个max_mds设置，可以理解为它将控制创建多少个主MDS。注意只有当实际的MDS个数大于或等于max_mds设置的值时，mdx_mds设置才会生效。例如，如果只有一个MDS守护进程在运行，并且max_mds被设置为两个，则不会创建第二个主MDS。
```
# ceph fs set max_mds 2
```
1.3、配置备用MDS
即使有多个活动的MDS，如果其中一个MDS出现故障，仍然需要备用守护进程来接管。因此，对于高可用性系统，实际配置max_mds时，最好比系统中MDS的总数少一个。

但如果你确信你的MDS不会出现故障，可以通过以下设置来通知ceph不需要备用MDS，否则会出现insufficient standby daemons available告警信息：
```
# ceph fs set <fs> standby_count_wanted 0 
```

## 2、还原单主MDS
2.1、设置max_mds
```
# ceph fs set max_mds 1
```
2.2 删除不需要的rank
```
ceph mds deactivate cephfs:2
```
