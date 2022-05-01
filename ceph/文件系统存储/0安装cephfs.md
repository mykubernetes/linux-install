# cephfs

## 服务器端部署

1、部署 cephfs  
```
# ceph-deploy mds create node01
```
注意：查看输出，应该能看到执行了哪些命令，以及生成的keyring  

2、使用 CephFS 之前需要事先于集群中创建一个文件系统，并为其分别指定元数据和数据相关的存储池
```
# ceph osd pool create cephfs-metadata 32 32
# ceph osd pool create cephfs-data 64 64
# ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 7m)
    mgr: ceph-mgr2(active, since 6m), standbys: ceph-mgr1
    mds: 1/1 daemons up
    osd: 12 osds: 12 up (since 6m), 12 in (since 39h)
    rgw: 1 daemon active (1 hosts, 1 zones)
 
  data:
    volumes: 1/1 healthy
    pools:   10 pools, 329 pgs
    objects: 328 objects, 213 MiB
    usage:   894 MiB used, 239 GiB / 240 GiB avail
    pgs:     329 active+clean
```

3、创建 cephFS 并验证
```
# ceph fs new mycephfs cephfs-metadata cephfs-data
# ceph fs ls
name: mycephfs, metadata pool: cephfs-metadata, data pools: [cephfs-data ]

# ceph fs status mycephfs
mycephfs - 0 clients
========
RANK  STATE      MDS        ACTIVITY     DNS    INOS   DIRS   CAPS  
 0    active  ceph-mgr1  Reqs:    0 /s    12     15     12      0   
      POOL         TYPE     USED  AVAIL  
cephfs-metadata  metadata   247k  75.5G  
  cephfs-data      data     362M  75.5G  
MDS version: ceph version 16.2.5 (0883bdea7337b95e4b611c768c0279868462204a) pacific (stable)
```

4、验证 cepfFS 服务状态 
```
# ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active}

# ceph osd pool ls
# ceph fs ls
```  

5、创建用户并赋予权限  
```
ceph auth get-or-create client.cephfs mon 'allow r' mds 'allow r, allow rw path=/' osd 'allow rw pool=cephfs_data' -o ceph.client.cephfs.keyring
拷贝到客户端
scp ceph.client.cephfs.keyring node04:/etc/ceph/
```  

创建客户端账户
```
#创建用户
# ceph auth add client.yanyan mon 'allow r' mds 'allow rw' osd 'allow rwx pool=cephfs-data'
added key for client.yanyan

#验证账户
# ceph auth get client.yanyan
[client.yanyan]
    key = AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
    caps mds = "allow rw"
    caps mon = "allow r"
    caps osd = "allow rwx pool=cephfs-data"
exported keyring for client.yanyan

#创建keyring 文件
# ceph auth get client.yanyan -o ceph.client.yanyan.keyring
exported keyring for client.yanyan

#创建 key 文件
# ceph auth print-key client.yanyan > yanyan.key

#验证用户的 keyring 文件
# cat ceph.client.yanyan.keyring
[client.yanyan]
    key = AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
    caps mds = "allow rw"
    caps mon = "allow r"
    caps osd = "allow rwx pool=cephfs-data"


#同步客户端认证文件
# scp ceph.conf ceph.client.yanyan.keyring yanyan.key root@10.0.0.200:/etc/ceph/
```



# 客户端挂载

> 客户端挂载有两种方式，一是内核空间一是用户空间，内核空间挂载需要内核支持 ceph 模块，用户空间挂载需要安装 ceph-fuse

http://docs.ceph.org.cn/man/8/mount.ceph/#mount-ceph-ceph  

1、客户端验证权限
```
# ceph --user yanyan -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 55m)
    mgr: ceph-mgr2(active, since 54m), standbys: ceph-mgr1
    mds: 1/1 daemons up
    osd: 12 osds: 12 up (since 54m), 12 in (since 39h)
    rgw: 1 daemon active (1 hosts, 1 zones)
 
  data:
    volumes: 1/1 healthy
    pools:   10 pools, 329 pgs
    objects: 328 objects, 213 MiB
    usage:   895 MiB used, 239 GiB / 240 GiB avail
    pgs:     329 active+clean
```

2、客户端通过 key 文件挂载
```
# mount -t ceph 10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/ /data -o name=yanyan,secretfile=/etc/ceph/yanyan.key
# df -h
Filesystem                                         Size  Used Avail Use% Mounted on
udev                                               964M     0  964M   0% /dev
tmpfs                                              198M  6.6M  191M   4% /run
/dev/sda1                                           20G  2.8G   16G  16% /
tmpfs                                              986M     0  986M   0% /dev/shm
tmpfs                                              5.0M     0  5.0M   0% /run/lock
tmpfs                                              986M     0  986M   0% /sys/fs/cgroup
tmpfs                                              198M     0  198M   0% /run/user/1000
10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/   76G  120M   76G   1% /data

#验证写入数据
# cp /var/log/syslog /data/
# dd if=/dev/zero of=/data/testfile bs=1M count=100
100+0 records in
100+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 0.0415206 s, 2.5 GB/s
```

3、客户端通过 key 挂载
```
# tail /etc/ceph/yanyan.key
AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
# umount /data/
# 指定多个mon地址
# mount -t ceph 10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/ /data -o name=yanyan,secret=AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
# df -h
Filesystem                                         Size  Used Avail Use% Mounted on
udev                                               964M     0  964M   0% /dev
tmpfs                                              198M  6.6M  191M   4% /run
/dev/sda1                                           20G  2.8G   16G  16% /
tmpfs                                              986M     0  986M   0% /dev/shm
tmpfs                                              5.0M     0  5.0M   0% /run/lock
tmpfs                                              986M     0  986M   0% /sys/fs/cgroup
tmpfs                                              198M     0  198M   0% /run/user/1000
10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/   76G  220M   76G   1% /data

#测试写入数据
# cp /var/log/syslog /data/

#查看挂载点状态
# stat -f /data/
  File: "/data/"
    ID: 2f5ea2f36fe16833 Namelen: 255     Type: ceph
Block size: 4194304    Fundamental block size: 4194304
Blocks: Total: 19319      Free: 19264      Available: 19264
Inodes: Total: 56         Free: -1
```

4、开机挂载
```
# cat /etc/fstab 
10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/ /data ceph defaults,name=yanyan,secretfile=/etc/ceph/yanyan.key,_netdev,noatime 0 0

# mount -a
```
- `_netdev`参数表示是一个网络存储,作用如果挂载不上，会超时跳过挂载，如果不加`_netdev`参数可能导致一直重试挂载无法进入系统

5、客户端模块
- 客户端内核加载 ceph.ko 模块挂载 cephfs 文件系统
```
# lsmod|grep ceph
ceph                  376832  1
libceph               315392  1 ceph
libcrc32c              16384  1 libceph
fscache                65536  1 ceph

# madinfo ceph
```



# 通过FUSE客户端挂载  

1)安装软件包  
```
[ceph]
name=ceph
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/x86_64/
gpgcheck=0
priority=1

[ceph-noarch]
name=cephnoarch
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/noarch/
gpgcheck=0
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/SRPMS
enabled=0
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.aliyun.com/ceph/keys/release.asc
priority=1



# rpm -qa |grep -i ceph-fuse 
# yum -y install ceph-fuse
``` 

2)从服务器把 key文件拷贝到客户端  
```
scp ceph.client.cephfs.keyring root@c720153:/etc/ceph/
```  

3)挂载  
命令挂载  
```
# ceph-fuse --keyring /etc/ceph/ceph.client.cephfs.keyring --name client.cephfs -m node02:6789 /mnt/cephfs
# df -h /mnt/cephfs/
Filesystem      Size  Used Avail Use% Mounted on
ceph-fuse       6.5G     0  6.5G   0% /mnt/cephfs
```  

使用配置文件命令挂载挂载  
```
# vi /etc/ceph/ceph.conf
[global]
mon_host = node01,node02,node03

# vi /etc/fstab
...
none /mnt/cephfs fuse.ceph ceph.id=cephfs,ceph.conf=/etc/ceph/ceph.conf,_netdev,defaults 0 0
```  
注：因为 keyring文件包含了用户名，前提是，必须要有ceph.conf文件，指明 mon地址。

# ceph mds 高可用

- Ceph mds(etadata service)作为 ceph 的访问入口，需要实现高性能及数据备份，假设启动 4个 MDS 进程，设置 2 个 Rank。这时候有 2 个 MDS 进程会分配给两个 Rank，还剩下 2 个 MDS进程分别作为另外个的备份。

1、 当前 mds 服务器状态
```
# ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active}
```

2、添加 MDS 服务器
```
#mds 服务器安装 ceph-mds 服务
# sudo yum install ceph-mds -y

#添加 mds 服务器
# ceph-deploy mds create ceph-mon2
# ceph-deploy mds create ceph-mon3
# ceph-deploy mds create ceph-mon4

#验证 mds 服务器当前状态
# ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active} 3 up:standby
```

3、验证 ceph 集群当前状态

- 当前处于激活状态的 mds 服务器有一台，处于备份状态的 mds 服务器有三台
```
# ceph fs status
mycephfs - 1 clients
========
RANK  STATE      MDS        ACTIVITY     DNS    INOS   DIRS   CAPS  
 0    active  ceph-mgr1  Reqs:    0 /s    13     16     12      2   
      POOL         TYPE     USED  AVAIL  
cephfs-metadata  metadata   379k  75.2G  
  cephfs-data      data     663M  75.2G  
STANDBY MDS  
 ceph-mon2   
 ceph-mgr2   
 ceph-mon3   
MDS version: ceph version 16.2.5 (0883bdea7337b95e4b611c768c0279868462204a) pacific (stable)
```

4、当前的文件系统状态
```
# ceph fs get mycephfs
Filesystem 'mycephfs' (1)
fs_name    mycephfs
epoch    37
flags    12
created    2021-08-27T11:06:31.193582+0800
modified    2021-08-29T14:48:37.814878+0800
tableserver    0
root    0
session_timeout    60
session_autoclose    300
max_file_size    1099511627776
required_client_features    {}
last_failure    0
last_failure_osd_epoch    551
compat    compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,8=no anchor table,9=file layout v2,10=snaprealm v2}
max_mds    1
in    0
up    {0=84172}
failed    
damaged    
stopped    
data_pools    [9]
metadata_pool    8
inline_data    disabled
balancer    
standby_count_wanted    1
[mds.ceph-mgr1{0:84172} state up:active seq 7 addr [v2:10.0.0.104:6800/3031657167,v1:10.0.0.104:6801/3031657167]]
```

5、设置处于激活状态 mds 的数量

- 目前有四个 mds 服务器，但是有一个主三个备，可以优化一下部署架构，设置为为两主两备
```
# 设置同时活跃的主 mds 最大值为 2
# ceph fs set mycephfs max_mds 2             

# ceph fs status
mycephfs - 1 clients
========
RANK  STATE      MDS        ACTIVITY     DNS    INOS   DIRS   CAPS  
 0    active  ceph-mgr1  Reqs:    0 /s    13     16     12      2   
 1    active  ceph-mon3  Reqs:    0 /s    10     13     11      0   
      POOL         TYPE     USED  AVAIL  
cephfs-metadata  metadata   451k  75.2G  
  cephfs-data      data     663M  75.2G  
STANDBY MDS  
 ceph-mon2   
 ceph-mgr2   
MDS version: ceph version 16.2.5 (0883bdea7337b95e4b611c768c0279868462204a) pacific (stable)
```

6、MDS 高可用优化
- 目前的状态是 ceph-mgr1 和 ceph-mon2 分别是 active 状态，ceph-mon3 和 ceph-mgr2 分别处于 standby 状态，现在可以将 ceph-mgr2 设置为 ceph-mgr1 的 standby，将 ceph-mon3 设置为 ceph-mon2 的 standby，以实现每个主都有一个固定备份角色的结构，
```
# cat ceph.conf
[global]
fsid = 635d9577-7341-4085-90ff-cb584029a1ea
public_network = 10.0.0.0/24
cluster_network = 192.168.133.0/24
mon_initial_members = ceph-mon1
mon_host = 10.0.0.101
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 2 
mon clock drift warn backoff = 30 

[mds.ceph-mgr2] 
#mds_standby_for_fscid = mycephfs 
mds_standby_for_name = ceph-mgr1 
mds_standby_replay = true 

[mds.ceph-mon3] 
mds_standby_for_name = ceph-mon2 
mds_standby_replay = true
```

7、分发配置文件并重启 mds 服务
```
#分发配置文件保证各 mds 服务重启有效
# ceph-deploy --overwrite-conf config push ceph-mon3
# ceph-deploy --overwrite-conf config push ceph-mon2
# ceph-deploy --overwrite-conf config push ceph-mgr1
# ceph-deploy --overwrite-conf config push ceph-mgr2

# sudo systemctl restart ceph-mds@ceph-mon2.service
# sudo systemctl restart ceph-mds@ceph-mon3.service
# sudo systemctl restart ceph-mds@ceph-mgr1.service
# sudo systemctl restart ceph-mds@ceph-mgr2.service
```

8、ceph 集群 mds 高可用状态
```
# ceph fs status
mycephfs - 1 clients
========
RANK  STATE      MDS        ACTIVITY     DNS    INOS   DIRS   CAPS  
 0    active  ceph-mgr2  Reqs:    0 /s    13     16     12      1   
 1    active  ceph-mon2  Reqs:    0 /s    10     13     11      0   
      POOL         TYPE     USED  AVAIL  
cephfs-metadata  metadata   451k  75.2G  
  cephfs-data      data     663M  75.2G  
STANDBY MDS  
 ceph-mon3   
 ceph-mgr1   
MDS version: ceph version 16.2.5 (0883bdea7337b95e4b611c768c0279868462204a) pacific (stable)


# 查看 active 和 standby 对应关系
# ceph fs get mycephfs
Filesystem 'mycephfs' (1)
fs_name    mycephfs
epoch    67
flags    12
created    2021-08-27T11:06:31.193582+0800
modified    2021-08-29T16:34:16.305266+0800
tableserver    0
root    0
session_timeout    60
session_autoclose    300
max_file_size    1099511627776
required_client_features    {}
last_failure    0
last_failure_osd_epoch    557
compat    compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,8=no anchor table,9=file layout v2,10=snaprealm v2}
max_mds    2
in    0,1
up    {0=84753,1=84331}
failed    
damaged    
stopped    
data_pools    [9]
metadata_pool    8
inline_data    disabled
balancer    
standby_count_wanted    1
[mds.ceph-mgr2{0:84753} state up:active seq 7 addr [v2:10.0.0.105:6802/2338760756,v1:10.0.0.105:6803/2338760756]]
[mds.ceph-mon2{1:84331} state up:active seq 14 addr [v2:10.0.0.102:6800/3841027813,v1:10.0.0.102:6801/3841027813]]
```
