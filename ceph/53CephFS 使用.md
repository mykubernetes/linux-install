# CephFS 使用

ceph FS 即 ceph filesystem，可以实现文件系统共享功能,客户端通过 ceph 协议挂载并使用

## 3.1 部署 MDS 服务
```
#mgr节点
test@ceph-mgr1:~$ apt-cache madison ceph-mds
  ceph-mds | 16.2.5-1bionic | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic/main amd64 Packages
  ceph-mds | 12.2.13-0ubuntu0.18.04.8 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/universe amd64 Packages
  ceph-mds | 12.2.13-0ubuntu0.18.04.4 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-security/universe amd64 Packages
  ceph-mds | 12.2.4-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic/universe amd64 Packages
#安装mds
test@ceph-mgr1:~$ sudo apt install ceph-mds
```

## 3.2 创建 CephFS metadata 和 data 存储池

使用 CephFS 之前需要事先于集群中创建一个文件系统，并为其分别指定元数据和数据相关的存储池
```
#deploy节点
test@ceph-deploy:~$ ceph osd pool create cephfs-metadata 32 32
test@ceph-deploy:~$ ceph osd pool create cephfs-data 64 64
test@ceph-deploy:~$ ceph -s
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

## 3.3 创建 cephFS 并验证
```
#deploy节点
test@ceph-deploy:~$ ceph fs new mycephfs cephfs-metadata cephfs-data
test@ceph-deploy:~$ ceph fs ls
name: mycephfs, metadata pool: cephfs-metadata, data pools: [cephfs-data ]
test@ceph-deploy:~$ ceph fs status mycephfs
mycephfs - 0 clients
========
RANK  STATE      MDS        ACTIVITY     DNS    INOS   DIRS   CAPS  
 0    active  ceph-mgr1  Reqs:    0 /s    12     15     12      0   
      POOL         TYPE     USED  AVAIL  
cephfs-metadata  metadata   247k  75.5G  
  cephfs-data      data     362M  75.5G  
MDS version: ceph version 16.2.5 (0883bdea7337b95e4b611c768c0279868462204a) pacific (stable)
```

## 3.4 验证 cepfFS 服务状态
```
#deploy节点
test@ceph-deploy:~$ ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active}
```

## 3.5 创建客户端账户
```
#deploy节点
#创建用户
test@ceph-deploy:~/ceph-cluster$ ceph auth add client.yanyan mon 'allow r' mds 'allow rw' osd 'allow rwx pool=cephfs-data'
added key for client.yanyan

#验证账户
test@ceph-deploy:~/ceph-cluster$ ceph auth get client.yanyan
[client.yanyan]
    key = AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
    caps mds = "allow rw"
    caps mon = "allow r"
    caps osd = "allow rwx pool=cephfs-data"
exported keyring for client.yanyan

#创建keyring 文件
test@ceph-deploy:~/ceph-cluster$ ceph auth get client.yanyan -o ceph.client.yanyan.keyring
exported keyring for client.yanyan

#创建 key 文件
test@ceph-deploy:~/ceph-cluster$ ceph auth print-key client.yanyan > yanyan.key

#验证用户的 keyring 文件
test@ceph-deploy:~/ceph-cluster$ cat ceph.client.yanyan.keyring
[client.yanyan]
    key = AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
    caps mds = "allow rw"
    caps mon = "allow r"
    caps osd = "allow rwx pool=cephfs-data"
```

## 3.6 安装 ceph 客户端
```
#client节点
root@ceph-client:/etc/ceph# apt install ceph-common -y
```

## 3.7 同步客户端认证文件
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ scp ceph.conf ceph.client.yanyan.keyring yanyan.key root@10.0.0.200:/etc/ceph/
```

## 3.8 客户端验证权限
```
#client节点
root@ceph-client2:/etc/ceph# ceph --user yanyan -s
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

## 3.9 内核空间挂载 ceph-fs

客户端挂载有两种方式，一是内核空间一是用户空间，内核空间挂载需要内核支持 ceph 模块，用户空间挂载需要安装 ceph-fuse

### 3.9.1 客户端通过 key 文件挂载
```
#deploy节点
root@ceph-client2:~# mount -t ceph 10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/ /data -o name=yanyan,secretfile=/etc/ceph/yanyan.key
root@ceph-client2:~# df -h
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
root@ceph-client2:~# cp /var/log/syslog /data/
root@ceph-client2:~# dd if=/dev/zero of=/data/testfile bs=1M count=100
100+0 records in
100+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 0.0415206 s, 2.5 GB/s
```

### 3.9.2 客户端通过 key 挂载
```
#client节点
root@ceph-client2:~# tail /etc/ceph/yanyan.key
AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
root@ceph-client2:~# umount /data/
root@ceph-client2:~# mount -t ceph 10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/ /data -o name=yanyan,secret=AQAhMCth/3d/HxAA7sMakmCr5tOFj8l2vmmaRA==
root@ceph-client2:~# df -h
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
root@ceph-client2:~# cp /var/log/syslog /data/

#查看挂载点状态
root@ceph-client2:~# stat -f /data/
  File: "/data/"
    ID: 2f5ea2f36fe16833 Namelen: 255     Type: ceph
Block size: 4194304    Fundamental block size: 4194304
Blocks: Total: 19319      Free: 19264      Available: 19264
Inodes: Total: 56         Free: -1
```

### 3.9.3 开机挂载
```
#client节点
root@ceph-client2:~# cat /etc/fstab 
10.0.0.101:6789,10.0.0.102:6789,10.0.0.103:6789:/ /data ceph defaults,name=yanyan,secretfile=/etc/ceph/yanyan.key,_netdev 0 0
root@ceph-client2:~# mount -a
```

### 3.9.4 客户端模块

客户端内核加载 ceph.ko 模块挂载 cephfs 文件系统
```
#client节点
root@ceph-client2:~# lsmod|grep ceph
ceph                  376832  1
libceph               315392  1 ceph
libcrc32c              16384  1 libceph
fscache                65536  1 ceph
root@ceph-client2:~# madinfo ceph
```

## 3.10 ceph mds 高可用

Ceph mds(etadata service)作为 ceph 的访问入口，需要实现高性能及数据备份，假设启动 4个 MDS 进程，设置 2 个 Rank。这时候有 2 个 MDS 进程会分配给两个 Rank，还剩下 2 个 MDS进程分别作为另外个的备份。

### 3.10.1 当前 mds 服务器状态
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active}
```

### 3.10.2 添加 MDS 服务器

将 ceph-mgr2 和 ceph-mon2 和 ceph-mon3 作为 mds 服务角色添加至 ceph 集群，最后实两主两备的 mds 高可用和高性能结构。
```
#mds 服务器安装 ceph-mds 服务
test@ceph-mgr2:~$ sudo apt install ceph-mds -y
test@ceph-mon2:~$ sudo apt install ceph-mds -y
test@ceph-mon3:~$ sudo apt install ceph-mds -y

#添加 mds 服务器
test@ceph-deploy:~/ceph-cluster$ ceph-deploy mds create ceph-mgr2
test@ceph-deploy:~/ceph-cluster$ ceph-deploy mds create ceph-mon2
test@ceph-deploy:~/ceph-cluster$ ceph-deploy mds create ceph-mon3

#验证 mds 服务器当前状态：
test@ceph-deploy:~/ceph-cluster$ ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active} 3 up:standby
```

### 3.10.3 验证 ceph 集群当前状态

当前处于激活状态的 mds 服务器有一台，处于备份状态的 mds 服务器有三台
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph fs status
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

### 3.10.4 当前的文件系统状态
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph fs get mycephfs
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

### 3.10.5 设置处于激活状态 mds 的数量

目前有四个 mds 服务器，但是有一个主三个备，可以优化一下部署架构，设置为为两主两备
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph fs set mycephfs max_mds 2#设置同时活跃的主 mds 最大值为 2
test@ceph-deploy:~/ceph-cluster$ ceph fs status
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

### 3.10.6 MDS 高可用优化

目前的状态是 ceph-mgr1 和 ceph-mon2 分别是 active 状态，ceph-mon3 和 ceph-mgr2 分别处于 standby 状态，现在可以将 ceph-mgr2 设置为 ceph-mgr1 的 standby，将 ceph-mon3 设置为 ceph-mon2 的 standby，以实现每个主都有一个固定备份角色的结构，
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ cat ceph.conf
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

### 3.10.7 分发配置文件并重启 mds 服务
```
#deploy节点
#分发配置文件保证各 mds 服务重启有效
test@ceph-deploy:~/ceph-cluster$ ceph-deploy --overwrite-conf config push ceph-mon3
test@ceph-deploy:~/ceph-cluster$ ceph-deploy --overwrite-conf config push ceph-mon2
test@ceph-deploy:~/ceph-cluster$ ceph-deploy --overwrite-conf config push ceph-mgr1
test@ceph-deploy:~/ceph-cluster$ ceph-deploy --overwrite-conf config push ceph-mgr2

test@ceph-mon2:~$ sudo systemctl restart ceph-mds@ceph-mon2.service
test@ceph-mon3:~$ sudo systemctl restart ceph-mds@ceph-mon3.service
test@ceph-mgr1:~$ sudo systemctl restart ceph-mds@ceph-mgr1.service
test@ceph-mgr2:~$ sudo systemctl restart ceph-mds@ceph-mgr2.service
```

### 3.10.8 ceph 集群 mds 高可用状态
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph fs status
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

#查看 active 和 standby 对应关系
test@ceph-deploy:~/ceph-cluster$ ceph fs get mycephfs
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

## 3.11 通过 ganesha 将 cephfs 导出为 NFS

通过 ganesha 将 cephfs 通过 NFS 协议共享使用

### 3.11.1 服务端配置
```
#mgr1节点
test@ceph-mgr1:~$ sudo apt install nfs-ganesha-ceph
test@ceph-mgr1:~$ cd /etc/ganesha/
test@ceph-mgr1:/etc/ganesha$ cat /etc/ganesha/ganesha.conf
NFS_CORE_PARAM { 
 #disable NLM 
 Enable_NLM = false; 
 # disable RQUOTA (not suported on CephFS) 
 Enable_RQUOTA = false; 
 # NFS protocol 
 Protocols = 4; 
 }

 EXPORT_DEFAULTS { 
 # default access mode 
 Access_Type = RW; 
 }

 EXPORT { 
 # uniq ID 
 Export_Id = 1;
 # mount path of CephFS 
 Path = "/"; 
 FSAL {
 name = CEPH; 
 # hostname or IP address of this Node 
 hostname="10.0.0.104"; 
 }
 # setting for root Squash 
 Squash="No_root_squash"; 
 # NFSv4 Pseudo path 
 Pseudo="/test"; 
 # allowed security options 
 SecType = "sys"; 
 }

 LOG {
 # default log level 
 Default_Log_Level = WARN; 
 }

test@ceph-mgr1:/etc/ganesha$ sudo systemctl restart nfs-ganesha
```

### 3.11.2 挂载测试

在新的客户端进行挂载测试
```
root@client3:~# apt installnfs-common
root@client3:~# mount -t nfs 10.0.0.104:/test /data
root@client3:~# df -h
Filesystem        Size  Used Avail Use% Mounted on
udev              964M     0  964M   0% /dev
tmpfs             198M  6.7M  191M   4% /run
/dev/sda1          20G  2.6G   16G  15% /
tmpfs             986M     0  986M   0% /dev/shm
tmpfs             5.0M     0  5.0M   0% /run/lock
tmpfs             986M     0  986M   0% /sys/fs/cgroup
tmpfs             198M     0  198M   0% /run/user/1000
tmpfs             198M     0  198M   0% /run/user/0
10.0.0.104:/test   70G  100M   70G   1% /data
root@client3:~# cp /var/log/syslog /data
root@client3:~# ll /data
total 103734
drwxr-xr-x  2 nobody 4294967294 107113225 Sep 23 15:31 ./
drwxr-xr-x 24 root   root            4096 Sep 23 15:50 ../
-rw-r-----  1 nobody 4294967294   1360733 Sep 23 15:58 syslog
```
