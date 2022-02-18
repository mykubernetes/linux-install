# Ceph RBD 使用

## 2.1 RBD简介

Ceph 可以同时提供对象存储 RADOSGW、块存储 RBD、文件系统存储 Ceph FS,RBD 即 RADOSBlock Device 的简称，RBD 块存储是常用的存储类型之一，RBD 块设备类似磁盘可以被挂载，RBD 块设备具有快照、多副本、克隆和一致性等特性，数据以条带化的方式存储在 Ceph 集群的多个 OSD 中。

## 2.2 创建存储池
```
#deploy节点
#创建存储池
test@ceph-deploy:~/ceph-cluster$ ceph osd pool create rbd-data1 32 32
pool 'rbd-data1' created

#验证存储池
test@ceph-deploy:~/ceph-cluster$ ceph osd pool ls
device_health_metrics
mypool
myrbd1
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta
cephfs-metadata
cephfs-data
rbd-data1

#在存储池启用 rbd
test@ceph-deploy:~/ceph-cluster$ ceph osd pool application enable -h
osd pool application enable <pool> <app> [--yes-i-really-mean-it]

test@ceph-deploy:~/ceph-cluster$ ceph osd pool application enable rbd-data1 rbd
enabled application 'rbd' on pool 'rbd-data1'

#初始化RBD
test@ceph-deploy:~/ceph-cluster$ rbd pool init -p rbd-data1
```

## 2.3 创建 img 镜像

rbd 存储池并不能直接用于块设备，而是需要事先在其中按需创建映像（image），并把映像文件作为块设备使用。rbd 命令可用于创建、查看及删除块设备相在的映像（image），以及克隆映像、创建快照、将映像回滚到快照和查看快照等管理操作。

### 2.3.1 创建镜像
```
#deploy节点
#创建2个镜像
test@ceph-deploy:~/ceph-cluster$ rbd create data-img1 --size 3G --pool rbd-data1 --image-format 2 --image-feature layering
test@ceph-deploy:~/ceph-cluster$ rbd create data-img2 --size 5G --pool rbd-data1 --image-format 2 --image-feature layering

#验证镜像
test@ceph-deploy:~/ceph-cluster$ rbd ls --pool rbd-data1
data-img1
data-img2

#查看镜像信息
test@ceph-deploy:~/ceph-cluster$ rbd ls --pool rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  3 GiB            2            
data-img2  5 GiB            2 
```

### 2.3.2 查看镜像详细信息
```
#deploy节点
#查看data-img2的详细信息
test@ceph-deploy:~/ceph-cluster$ rbd --image data-img2 --pool rbd-data1 info
rbd image 'data-img2':
    size 5 GiB in 1280 objects
    order 22 (4 MiB objects)
    snapshot_count: 0
    id: 12468e5b9a04b
    block_name_prefix: rbd_data.12468e5b9a04b
    format: 2
    features: layering
    op_features: 
    flags: 
    create_timestamp: Sun Aug 29 00:08:51 2021
    access_timestamp: Sun Aug 29 00:08:51 2021
    modify_timestamp: Sun Aug 29 00:08:51 2021

#查看data-img1的详细信息
test@ceph-deploy:~/ceph-cluster$ rbd --image data-img1 --pool rbd-data1 info
rbd image 'data-img1':
    size 3 GiB in 768 objects
    order 22 (4 MiB objects)
    snapshot_count: 0
    id: 1245f7ae95595
    block_name_prefix: rbd_data.1245f7ae95595
    format: 2
    features: layering
    op_features: 
    flags: 
    create_timestamp: Sun Aug 29 00:08:41 2021
    access_timestamp: Sun Aug 29 00:08:41 2021
    modify_timestamp: Sun Aug 29 00:08:41 2021
```

### 2.3.3 以 json 格式显示镜像信息
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ rbd ls --pool rbd-data1 -l --format json --pretty-format
[
    {
        "image": "data-img1",
        "id": "1245f7ae95595",
        "size": 3221225472,
        "format": 2
    },
    {
        "image": "data-img2",
        "id": "12468e5b9a04b",
        "size": 5368709120,
        "format": 2
    }
]
```

### 2.3.4 镜像特性的启用
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ rbd feature enable exclusive-lock --pool rbd-data1 --image data-img1
test@ceph-deploy:~/ceph-cluster$ rbd feature enable object-map --pool rbd-data1 --image data-img1
test@ceph-deploy:~/ceph-cluster$ rbd feature enable fast-diff --pool rbd-data1 --image data-img1

#验证镜像特性
test@ceph-deploy:~/ceph-cluster$ rbd --image data-img1 --pool rbd-data1 info
rbd image 'data-img1':
    size 3 GiB in 768 objects
    order 22 (4 MiB objects)
    snapshot_count: 0
    id: 1245f7ae95595
    block_name_prefix: rbd_data.1245f7ae95595
    format: 2
    features: layering, exclusive-lock, object-map, fast-diff
    op_features: 
    flags: object map invalid, fast diff invalid
    create_timestamp: Sun Aug 29 00:08:41 2021
    access_timestamp: Sun Aug 29 00:08:41 2021
    modify_timestamp: Sun Aug 29 00:08:41 2021
```

### 2.3.5 镜像特性的禁用
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ rbd feature disable fast-diff --pool rbd-data1 --image data-img1
test@ceph-deploy:~/ceph-cluster$ rbd --image data-img1 --pool rbd-data1 info
rbd image 'data-img1':
    size 3 GiB in 768 objects
    order 22 (4 MiB objects)
    snapshot_count: 0
    id: 1245f7ae95595
    block_name_prefix: rbd_data.1245f7ae95595
    format: 2
    features: layering, exclusive-lock #少了一个fast-diff 特性
    op_features: 
    flags: 
    create_timestamp: Sun Aug 29 00:08:41 2021
    access_timestamp: Sun Aug 29 00:08:41 2021
    modify_timestamp: Sun Aug 29 00:08:41 2021
```

## 2.4 配置客户端使用 RBD

在 ubuntu 客户端挂载 RBD,并分别使用 admin 及普通用户挂载 RBD 并验证使用

### 2.4.1 客户端配置源
```
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

cat > /etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
EOF

sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic main" >> /etc/apt/sources.list

apt update
```


### 2.4.2 客户端安装 ceph-common
```
#client节点
root@ubuntu:~# apt install ceph-common

#deploy节点，把ceph.conf ceph.client.admin.keyring 发送到client节点
root@ceph-deploy:~/ceph-cluster# scp ceph.conf ceph.client.admin.keyring root@10.0.0.109:/etc/ceph
ceph.conf                                                                                                                  100%  262    60.5KB/s   00:00    
ceph.client.admin.keyring                                                                                                  100%  151    83.2KB/s   00:00
```
  
#### 2.4.3.1 客户端映射镜像
```
#client节点
root@ubuntu:~# rbd -p rbd-data1 map data-img1
/dev/rbd0
root@ubuntu:~# rbd -p rbd-data1 map data-img2
/dev/rbd1
```

#### 2.4.3.2 客户端验证镜像
```
#client节点
root@ubuntu:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk 
└─sda1   8:1    0   20G  0 part /
sr0     11:0    1 1024M  0 rom  
rbd0   252:0    0    3G  0 disk 
rbd1   252:16   0    5G  0 disk
```

#### 2.4.3.3 客户端格式化磁盘并挂载使用
```
#client节点
#客户端格式化 rbd
root@ubuntu:~# mkfs.xfs /dev/rbd0
meta-data=/dev/rbd0              isize=512    agcount=9, agsize=97280 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=786432, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
root@ubuntu:~# mkfs.xfs /dev/rbd1
meta-data=/dev/rbd1              isize=512    agcount=9, agsize=162816 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=1310720, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

#挂载
root@ubuntu:~# mkdir /data /data1 -p
root@ubuntu:~# mount /dev/rbd0 /data
root@ubuntu:~# mount /dev/rbd1 /data1
root@ubuntu:~# df -TH
Filesystem     Type      Size  Used Avail Use% Mounted on
udev           devtmpfs  1.1G     0  1.1G   0% /dev
tmpfs          tmpfs     207M  7.0M  200M   4% /run
/dev/sda1      ext4       22G  3.0G   17G  15% /
tmpfs          tmpfs     1.1G     0  1.1G   0% /dev/shm
tmpfs          tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs          tmpfs     1.1G     0  1.1G   0% /sys/fs/cgroup
tmpfs          tmpfs     207M     0  207M   0% /run/user/1000
/dev/rbd0      xfs       3.3G   38M  3.2G   2% /data
/dev/rbd1      xfs       5.4G   41M  5.4G   1% /data1
```

#### 2.4.3.4 客户端验证写入数据
```
#client节点
root@ubuntu:~# sudo cp /var/log/syslog /data
root@ubuntu:~# sudo cp /var/log/syslog /data1
root@ubuntu:~# df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            964M     0  964M   0% /dev
tmpfs           198M  6.7M  191M   4% /run
/dev/sda1        20G  2.8G   16G  15% /
tmpfs           986M     0  986M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           986M     0  986M   0% /sys/fs/cgroup
tmpfs           198M     0  198M   0% /run/user/1000
/dev/rbd0       3.0G   38M  3.0G   2% /data
/dev/rbd1       5.0G   40M  5.0G   1% /data1
```

#### 2.4.3.5 验证 rbd 数据
```
#client节点 
root@ubuntu:~# ll /data
total 1160
drwxr-xr-x  2 root root      20 Aug 28 09:42 ./
drwxr-xr-x 24 root root    4096 Aug 28 09:38 ../
-rw-r-----  1 root root 1181490 Aug 28 09:42 syslog
root@ubuntu:~# ll /data1
total 1160
drwxr-xr-x  2 root root      20 Aug 28 09:43 ./
drwxr-xr-x 24 root root    4096 Aug 28 09:38 ../
-rw-r-----  1 root root 1181490 Aug 28 09:43 syslog
```

#### 2.4.3.6 查看存储池空间
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph df 
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
hdd    240 GiB  239 GiB  861 MiB   861 MiB       0.35
TOTAL  240 GiB  239 GiB  861 MiB   861 MiB       0.35
 
--- POOLS ---
POOL                   ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
device_health_metrics   1    1      0 B        0      0 B      0     76 GiB
mypool                  2   32      0 B        0      0 B      0     76 GiB
myrbd1                  3   64   12 MiB       18   35 MiB   0.02     76 GiB
.rgw.root               4   32  1.3 KiB        4   48 KiB      0     76 GiB
default.rgw.log         5   32  3.6 KiB      209  408 KiB      0     76 GiB
default.rgw.control     6   32      0 B        8      0 B      0     76 GiB
default.rgw.meta        7    8      0 B        0      0 B      0     76 GiB
cephfs-metadata         8   32   56 KiB       22  254 KiB      0     76 GiB
cephfs-data             9   64  121 MiB       31  363 MiB   0.16     76 GiB
rbd-data1              10   32   23 MiB       32   69 MiB   0.03     76 GiB
```

### 2.4.4 客户端使用普通账户挂载并使用 RBD

测试客户端使用普通账户挂载并使用 RBD

#### 2.4.4.1 创建普通账户并授权 (资源有限，使用了之前的虚拟机，可以新建一台client来做实验)
```
#deploy节点
#创建普通账户
test@ceph-deploy:~/ceph-cluster$ ceph auth add client.shijie mon 'allow r' osd 'allow rwx pool=rbd-data1'
added key for client.shijie

#验证用户信息
test@ceph-deploy:~/ceph-cluster$ ceph auth get client.shijie
[client.shijie]
    key = AQCAaCphzIAHMxAAddWTSYWGP6+lQuJV2OW/mQ==
    caps mon = "allow r"
    caps osd = "allow rwx pool=rbd-data1"
exported keyring for client.shijie

#创建 keyring 文件
test@ceph-deploy:~/ceph-cluster$ ceph-authtool --create-keyring ceph.client.shijie.keyring
creating ceph.client.shijie.keyring

#导出用户 keyring
test@ceph-deploy:~/ceph-cluster$ ceph auth get client.shijie -o ceph.client.shijie.keyring
exported keyring for client.shijie
```

#### 2.4.4.2 安装 ceph 客户端
```
#ceph-client
root@ceph-client:~# wget -q -O- 'https://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc' | sudo apt-key add - 
root@ceph-client:~# vim /etc/apt/sources.list 
root@ceph-client:~# apt install ceph-common
```

#### 2.4.4.3 同步普通用户认证文件
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ scp ceph.conf ceph.client.admin.keyring root@10.0.0.200:/etc/ceph/
```

#### 2.4.4.4 在客户端验证权限
```
#ceph-client 
root@ceph-client:~# ll /etc/ceph/
total 20
drwxr-xr-x  2 root root 4096 Aug 28 09:56 ./
drwxr-xr-x 81 root root 4096 Aug 28 09:51 ../
-rw-r--r--  1 root root  125 Aug 28 09:47 ceph.client.shijie.keyring
-rw-r--r--  1 root root  261 Aug 20 10:11 ceph.conf
-rw-r--r--  1 root root   92 Jun  7 07:39 rbdmap

#默认使用 admin 账户
root@ceph-client:~# # ceph --user shijie -s
```

#### 2.4.4.5 映射 rbd
```
#ceph-client节点
#映射 rbd
root@ceph-client:~# rbd --user shijie -p rbd-data1 map data-img2
/dev/rbd2

#验证rbd
root@ceph-client:~# fdisk -l /dev/rbd0
Disk /dev/rbd0: 3 GiB, 3221225472 bytes, 6291456 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 4194304 bytes / 4194304 bytes
```

#### 2.4.4.6 格式化并使用 rbd 镜像
```
#ceph-client节点

root@ceph-client:~# mkfs.ext4 /dev/rbd2
mke2fs 1.44.1 (24-Mar-2018)
/dev/rbd2 contains a xfs file system
Proceed anyway? (y,N) y
Discarding device blocks: done                            
Creating filesystem with 1310720 4k blocks and 327680 inodes
Filesystem UUID: fb498e3f-e8cb-40dd-b10d-1e91e0bfbbed
Superblock backups stored on blocks: 
    32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

root@ceph-client:~# mkdir /data2
root@ceph-client:~# mount /dev/rbd2 /data2/
root@ceph-client:~# # cp /var/log/messages /data2/
root@ceph-client:~# ll /data2
total 24
drwxr-xr-x  3 root root  4096 Aug 28 10:00 ./
drwxr-xr-x 25 root root  4096 Aug 28 10:01 ../
drwx------  2 root root 16384 Aug 28 10:00 lost+found/
root@ceph-client:~# df -TH
Filesystem     Type      Size  Used Avail Use% Mounted on
udev           devtmpfs  1.1G     0  1.1G   0% /dev
tmpfs          tmpfs     207M  7.0M  200M   4% /run
/dev/sda1      ext4       22G  3.0G   17G  15% /
tmpfs          tmpfs     1.1G     0  1.1G   0% /dev/shm
tmpfs          tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs          tmpfs     1.1G     0  1.1G   0% /sys/fs/cgroup
/dev/rbd0      xfs       3.3G   39M  3.2G   2% /data
/dev/rbd1      xfs       5.4G   42M  5.4G   1% /data1
tmpfs          tmpfs     207M     0  207M   0% /run/user/1000
/dev/rbd2      ext4      5.3G   21M  5.0G   1% /data2

#deploy节点
#管理端验证镜像状态
test@ceph-deploy:~/ceph-cluster$ rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  3 GiB            2        excl
data-img2  5 GiB            2
```

#### 2.4.4.7 验证 ceph 内核模块

挂载 rbd 之后系统内核会自动加载 libceph.ko 模块
```
#client节点
root@ceph-client:~# lsmod|grep ceph
libceph               315392  1 rbd
libcrc32c              16384  2 xfs,libceph
root@ceph-client:~# modinfo libceph
filename:       /lib/modules/4.15.0-112-generic/kernel/net/ceph/libceph.ko
license:        GPL
description:    Ceph core library
author:         Patience Warnick <patience@newdream.net>
author:         Yehuda Sadeh <yehuda@hq.newdream.net>
author:         Sage Weil <sage@newdream.net>
srcversion:     899059C79545E4ADF47A464
depends:        libcrc32c
retpoline:      Y
intree:         Y
name:           libceph
vermagic:       4.15.0-112-generic SMP mod_unload 
signat:         PKCS#7
signer:         
sig_key:        
sig_hashalgo:   md4
```

#### 2.4.4.8 rbd 镜像空间拉伸
```
#deploy节点
#当前 rbd 镜像空间大小
test@ceph-deploy:~/ceph-cluster$ rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  3 GiB            2        excl
data-img2  5 GiB            2            

#拉伸 rbd 镜像空间
test@ceph-deploy:~/ceph-cluster$ rbd resize --pool rbd-data1 --image data-img2 --size 8G
Resizing image: 100% complete...done.
test@ceph-deploy:~/ceph-cluster$ rbd resize --pool rbd-data1 --image data-img1 --size 6G
Resizing image: 100% complete...done.

#验证rgb信息
test@ceph-deploy:~/ceph-cluster$ rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  6 GiB            2            
data-img2  8 GiB            2 
```

#### 2.4.4.9 客户端验证镜像空间
```
#client节点
root@ceph-client:~# fdisk -l /dev/rbd2
Disk /dev/rbd2: 8 GiB, 8589934592 bytes, 16777216 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 4194304 bytes / 4194304 bytes
```

#### 2.4.4.10 开机自动挂载
```
#client节点
root@ceph-client:~# cat /etc/fstab 
rbd --user shijie -p rbd-data1 map data-img2 mount /dev/rbd2 /data2/
root@ceph-client:~# chmod a+x /etc/fstab 
root@ceph-client:~# reboot

#查看映射
root@ceph-client:~# rbd showmapped
id pool image snap device 
0 rbd-data1 data-img2 - /dev/rbd2
```

#### 2.4.4.11 卸载 rbd 镜像
```
#client节点
root@ceph-client:~# umount /data2
root@ceph-client:~# umount /data2 rbd --user shijie -p rbd-data1 unmap data-img2
```

#### 2.4.4.12 删除 rbd 镜像

删除存储池 rbd -data1 中的 data-img1 镜像
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ rbd rm --pool rbd-data1 --image data-img1
Removing image: 100% complete...done.
```

#### 2.4.4.13 rbd 镜像回收站机制

删除的镜像数据无法恢复，但是还有另外一种方法可以先把镜像移动到回收站，后期确认删除的时候再从回收站删除即可。
```
#deploy节点
#查看镜像状态
test@ceph-deploy:~/ceph-cluster$ rbd status --pool rbd-data1 --image data-img2

#将进行移动到回收站
test@ceph-deploy:~/ceph-cluster$ rbd trash move --pool rbd-data1 --image data-img2

#查看回收站的镜像
test@ceph-deploy:~/ceph-cluster$ rbd trash list --pool rbd-data1
12468e5b9a04b data-img2

#从回收站删除镜像 如果镜像不再使用，可以直接使用 trash remove 将其从回收站删除

#还原镜像
test@ceph-deploy:~/ceph-cluster$ rbd trash restore --pool rbd-data1 --image data-img2 --image-id 12468e5b9a04b

#验证镜像
test@ceph-deploy:~/ceph-cluster$ rbd ls --pool rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img2  8 GiB            2  
```

## 2.5 镜像快照

### 2.5.1 客户端当前数据
```
#client节点
root@ceph-client:~# ll /data2
total 24
drwxr-xr-x  3 root root  4096 Aug 28 10:00 ./
drwxr-xr-x 25 root root  4096 Aug 28 10:01 ../
drwx------  2 root root 16384 Aug 28 10:00 lost+found/
```

### 2.5.2 创建并验证快照
```
#deploy节点
#创建快照
test@ceph-deploy:~/ceph-cluster$ rbd snap create --pool rbd-data1 --image data-img2 --snap img2-snap-12468e5b9a04b
Creating snap: 100% complete...done.

#验证快照
test@ceph-deploy:~/ceph-cluster$ rbd snap list --pool rbd-data1 --image data-img2
SNAPID  NAME                     SIZE   PROTECTED  TIMESTAMP               
     4  img2-snap-12468e5b9a04b  8 GiB             Sun Aug 29 01:41:32 2021
```

### 2.5.3 删除数据并还原快照
```
#客户端删除数据 
root@ceph-client:~# rm -rf  /data2/lost+found

#验证数据
root@ceph-client:~# ll /data2
total 8
drwxr-xr-x  2 root root 4096 Aug 28 10:01 ./
drwxr-xr-x 25 root root 4096 Aug 28 10:01 ../

#卸载 rbd
root@ceph-client:~# umount /data2 
root@ceph-client:~# rbd unmap /dev/rbd2

#回滚快照
#deploy节点
test@ceph-deploy:~/ceph-cluster$ rbd snap rollback --pool rbd-data1 --image data-img2 --snap img2-snap-12468e5b9a04b
```

### 2.5.4 客户端验证数据
```
#client节点
#客户端映射 rbd
root@ceph-client:~# rbd --user shijie -p rbd-data1 map data-img2

#客户端挂载 rbd
root@ceph-client:~# mount /dev/rbd0 /data/

#客户端验证数据
root@ceph-client:~# ll /data/
```

### 2.5.5 删除快照
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ rbd snap remove --pool rbd-data1 --image data-img2 --snap img2-snap-12468e5b9a04b
Removing snap: 100% complete...done.

#验证快照是否删除
test@ceph-deploy:~/ceph-cluster$ rbd snap list --pool rbd-data1 --image data-img2
```

### 2.5.6 快照数量限制
```
#deploy节点
#设置与修改快照数量限制
test@ceph-deploy:~/ceph-cluster$ rbd snap limit set --pool rbd-data1 --image data-img2 --limit 30

#清除快照数量限制
test@ceph-deploy:~/ceph-cluster$ rbd snap limit clear --pool rbd-data1 --image data-img2
```
