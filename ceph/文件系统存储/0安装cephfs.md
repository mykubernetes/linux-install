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
``` scp ceph.client.cephfs.keyring root@c720153:/etc/ceph/ ```  

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
none /mnt/cephfs fuse.ceph ceph.id=cephfs,_netdev,defaults 0 0
```  
注：因为 keyring文件包含了用户名，前提是，必须要有ceph.conf文件，指明 mon地址。
