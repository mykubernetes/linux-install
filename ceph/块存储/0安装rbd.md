# 启用RBD的特性
- ceph为rbd提供了一些功能增强，但是都是需要内核的支持以下大多数参数内核3.0都不支持，若需要则升级高版本的内核
- 默认情况下如有配置文件或者命令行创建rbd的时候不指定feature则会默认开启很多特性，如果客户端内核版本低则会导致无法挂载盘，这个时候就需要去指定具体的rbd关闭不支持的特性
- 当RBD启用了一些内核不支持的功能，需要关闭之后才能正常映射可通过rbd feature enable/disable来开启或禁用功能
- rbd feature enable rbd/test object-map

## rbd的特性

| 特点 | 描述信息 | id号 |
|-----|---------|-------|
| layering | 是否支持克隆 | 1 |
| striping | 是否支持数据对象间的数据条带化，提升性能只支持librbd的客户端使用(内核态) | 2 |
| exclusive-lock | 是否支持分布式排他锁机制以限制同时仅能有一个客户端访问当前 image | 4 |
| object-map | 是否支持object位图，主要用于加速导入、导出及已用容量统计等操 作，依赖于exclusive-lock特性 | 8 |
| fast-diff | 是否支持快照间的快速比较操作，依赖于object-map特性 | 16 |
| deep-flatten | 是否支持克隆分离时解除在克隆image时创建的快照与其父image之间的关联关系 | 32 |
| journaling | 是否支持日志IO，即是否支持记录image的修改操作至日志对象；依赖于exclusive-lock特性 | 64 |
| data-pool | 是否支持将image的数据对象存储于纠删码存储池，主要用于将image的元数据与数据放置于不同的存储池 | 128 |

## 配置文件中设置
```
#在配置文件中正确的feature配置方法
vim /etc/ceph/ceph.conf

#这个值等于以上的ID号之和，如果你想开启(layering+striping)那值就=3(表示开启这两个)
#生产环境推荐开启的是=69
[client]
rbd_default_features = 69
```

## 命令行界面的操作
```
# 命令模型
# rbd create [poolname/iamgename] --size 大小 --image-format <1|2> --image-feature <xxx> --stripe-unit=1M --stripe-count=4

# 具体例子
# rbd create rbd/dataname --size 1G --image-format 2 --image-feature layering,exclusive,journaling
```
- --size: 指定块设备大小
- --image-format: 指定块存储设备类型，默认为2，1已经废弃（1和2在底层的存储实现上不同）
- --stripe-unit: 块存储中object大小，不得小于4k，不得大于32M，默认为4M
- --stripe-count: 并发写入的对象个数
- --image-feature: 指定的rbd块设备开启的特性



## 关闭feature

- 要注意关闭feature必须一个个的关闭，部分特性有关联性必先关闭前一个才能关闭后一个具体看报错信息判断
```
#查看当前拥有的块设备名称[-id idname]中的代表用户，如果是管理员权限则忽略
# rbd ls [-id idname]

# 查看具体的feature信息
# rbd info rbd/rbdname [-id idname]

# 关闭具体的特性
# rbd [-id idname] feature disable rbd/rbdname [特性名称]

# 查看你具体报错信息
# dmesg |tail
```

# RBD常用命令
| 命令 | 功能 |
| ------ | ------ |
| rbd create [img_name] --size nM|G|T --pool [pool_name] --image-format 2 --image-feature layering | 创建RBD |
| rbd ls -p  [pool_name] -l  | 列出RBD |
| rbd ls [pool_name] | 查看RBD镜像 |
| rbd info [pool-name/]image-name | 检索RBD镜像详情 |
| rbd status [pool-name/]image-name | 检查rbd镜像状态 |
| rbd du [pool-name/]image-name | 检索RBD镜像的调配磁盘使用量和实际磁盘使用量 |
| rbd resize [pool-name/]image-name --size nM|G|T  | 调整RBD镜像大小 |
| rbd rm --pool [pool_name]--image [img_name] | 删除RBD映像 |
| rbd cp [pool-name/]src-image-name [pool-name] tgt-image-name | 复制RBD镜像 |
| rbd mv [pool-name/]src-image-name [pool-name] tgt-image-name | 重命名RBD镜像 |
| rbd trash mv [pool-name/]image-name | 将RBD镜像移动到回收站 |
| rbd trash rm [pool-name/]image-name | 从回收站删除RBD镜像 |
| rbd trash restore [pool-name/]image-name | 从回收站恢复RBD镜像 |
| rbd trash ls [pool-name] | 列出回收站中所有镜像 |
| rbd diff  | 可以统计 rbd 使用量 |
| rbd map  | 映射块设备 |
| rbd showmapped | 查看已映射块设备 |
| rbd unmap | 取消映射 |

# 一、服务器端配置认证

1、在服务器端创建 ceph 块客户端用户名和认证密钥
```
# ceph auth get-or-create client.rbd mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd' |tee ./ceph.client.rbd.keyring
```

2、将认证秘钥和配置文件拷贝到客户端
```
# scp ceph.client.rbd.keyring node04:/etc/ceph/
# scp /etc/ceph/ceph.conf node04:/etc/ceph/
```  


# 二、客户端安装客户端工具

1、客户端检查是否符合块设备环境要求
```
# uname -r
# modprobe rbd
# echo $?
```  
2、安装ceph客户端
```
配置yum源
# cat /etc/yum.repos.d/ceph.repo 
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

安装
# yum -y install ceph
# cat /etc/ceph/ceph.client.rbd.keyring
# ceph -s --name client.rbd
```  

# 三、服务器端配置存储池

默认创建块设备，会直接创建在rbd 池中，但使用 deploy 安装后，该rbd池并没有创建。  
1、在服务器端创建池和块  
```
# ceph osd lspools              # 查看集群存储池
# ceph osd pool create rbd-data1 512  # 50 为place group数量(pg)
```  
确定 pg_num 取值是强制性的，因为不能自动计算。下面是几个常用的值：  
• 少于 5 个 OSD 时可把 pg_num 设置为 128  
• OSD 数量在 5 到 10 个时，可把pg_num 设置为 512  
• OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096  
• OSD 数量大于 50 时，你得理解权衡方法、以及如何自己计算pg_num 取值  

2、在存储池启用 rbd
```
# ceph osd pool application enable rbd-data1 rbd
enabled application 'rbd' on pool 'rbd-data1'
```

3、初始化RBD
```
# rbd pool init -p rbd-data1
```

# 四、客户端申请image

1、客户端创建 块设备  
创建一个10G大小的块设备
```
创建块设备rbd1为块名 --size默认以M为单位 --pool 池名
# rbd create rbd1 --size 10240 --pool rbd-data1 --name client.rbd
```

查看创建的块设备  
```
# rbd ls --name client.rbd  或 # rbd list --name client.rbd
# rbd ls -p rbd-data1 --name client.rbd
# rbd ls --pool rbd-data1 -l
# rbd --image rbd1 info --name client.rbd
```  

| 命令 | 描述 |
|------|------|
| size M GiB in N objects | image空间大小为M，共分割至N个对象（分割的数量由条带大小决定） |
| order 22 (4 MiB objects) | 块大小（条带）的标识序号，有效范围为12-25，分别对应着4K-32M之间的大小 |
| id | 当前image的标识符 |
| block_name_prefix | 当前image相关的object的名称前缀 |
| format | image的格式，其中的”2″表示”v2″ |
| features | 当前image启用的功能特性，其值是一个以逗号分隔的字符串列表，例如layering、 exclusive-lock等 |
| op_features | 可选的功能特性 |

查看块设备的详细信息  
```
# rbd info rbd/rbd1
rbd image 'rbd1':
    size 512 MB in 128 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.1ad6e2ae8944a
    format: 2
    features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
    flags:
```  
- size: 512 MB in 128 objects，表示该块设备的大小是512MBytes，分布在128个objects中，RBD默认的块大小是4MBytes
- order: order 22 (4096 kB objects)，指定RBD在OSD中存储时的block size，block size的计算公式是1<<order(单位是bytes)，在本例中order=22，所有block         size是1<<22bytes，也就是4096KBytes。order的默认值是22，RBD在OSD中默认的对象大小是4MBytes
- format: rbd image的格式，format1已经过期了。现在默认都是format2，被librbd和kernel3.11后面的版本支持
- block_name_prefix: 表示这个image在pool中的名称前缀，可以通过rados -p pool-frank6866 ls | grep rbd_data.1ad6e2ae8944a命令查看这个rbd image在rados中的所有object。但是要注意的是，刚创建的image，如果里面没有数据，不会在rados中创建object，只有写入数据时才会有。size字段中的objects数量表示的是最大的objects数量

# 五、客户端映射块设备


映射到客户端，应该会报错  
```
# rbd map --image rbd1 --name client.rbd

# 以下是解决办法
# 需要手动，动态禁用features
# rbd feature disable rbd1 exclusive-lock object-map deep-flatten fast-diff --name client.rbd

# 或者在创建RBD镜像时，只启用分层特性。
rbd create data-img1 --size 3G --pool rbd-data1 --image-format 2 --image-feature layering --name client.rbd

# ceph.conf 配置文件中禁用
# rbd_default_features = 1
```

# 六、实验

1、创建镜像
```
#创建2个镜像
# rbd create data-img1 --size 3G --pool rbd-data1 --image-format 2 --image-feature layering
# rbd create data-img2 --size 5G --pool rbd-data1 --image-format 2 --image-feature layering

# 验证镜像
# rbd ls --pool rbd-data1
data-img1
data-img2

# 查看镜像信息
# rbd ls --pool rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  3 GiB            2            
data-img2  5 GiB            2 
```

2、查看镜像详细信息
```
#查看data-img2的详细信息
# rbd --image data-img2 --pool rbd-data1 info
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
# rbd --image data-img1 --pool rbd-data1 info
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

3、以json格式显示镜像信息
```
# rbd ls --pool rbd-data1 -l --format json --pretty-format
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

4、镜像特性的启用
```
# rbd feature enable exclusive-lock --pool rbd-data1 --image data-img1
# rbd feature enable object-map --pool rbd-data1 --image data-img1
# rbd feature enable fast-diff --pool rbd-data1 --image data-img1
```

5、验证镜像特性
```
# rbd --image data-img1 --pool rbd-data1 info
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

6、镜像特性的禁用
```
# rbd feature disable fast-diff --pool rbd-data1 --image data-img1
# rbd --image data-img1 --pool rbd-data1 info
rbd image 'data-img1':
    size 3 GiB in 768 objects
    order 22 (4 MiB objects)
    snapshot_count: 0
    id: 1245f7ae95595
    block_name_prefix: rbd_data.1245f7ae95595
    format: 2
    features: layering, exclusive-lock                   #少了一个fast-diff 特性
    op_features: 
    flags: 
    create_timestamp: Sun Aug 29 00:08:41 2021
    access_timestamp: Sun Aug 29 00:08:41 2021
    modify_timestamp: Sun Aug 29 00:08:41 2021
```

7、客户端映射镜像到本地
``` 
# rbd -p rbd-data1 map data-img1
/dev/rbd0
# rbd -p rbd-data1 map data-img2
/dev/rbd1
```  

8、查看系统中已经映射到本地的块
``` 
# rbd showmapped --name client.rbd
id pool image snap device    
0  rbd  data-img1  -    /dev/rbd0
0  rbd  data-img2  -    /dev/rbd1
```

9、客户端验证镜像
```
# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk 
└─sda1   8:1    0   20G  0 part /
sr0     11:0    1 1024M  0 rom  
rbd0   252:0    0    3G  0 disk 
rbd1   252:16   0    5G  0 disk
```

10、客户端格式化磁盘并挂载使用
```
#客户端格式化 rbd
# mkfs.xfs /dev/rbd0
meta-data=/dev/rbd0              isize=512    agcount=9, agsize=97280 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=786432, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

# mkfs.xfs /dev/rbd1
meta-data=/dev/rbd1              isize=512    agcount=9, agsize=162816 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=1310720, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

# 挂载
# mkdir /data /data1 -p
# mount /dev/rbd0 /data
# mount /dev/rbd1 /data1

# df -TH
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

11、客户端验证写入数据
```
# sudo cp /var/log/syslog /data
# sudo cp /var/log/syslog /data1
# df -h
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

12、验证 rbd 数据
```
# ll /data
total 1160
drwxr-xr-x  2 root root      20 Aug 28 09:42 ./
drwxr-xr-x 24 root root    4096 Aug 28 09:38 ../
-rw-r-----  1 root root 1181490 Aug 28 09:42 syslog

# ll /data1
total 1160
drwxr-xr-x  2 root root      20 Aug 28 09:43 ./
drwxr-xr-x 24 root root    4096 Aug 28 09:38 ../
-rw-r-----  1 root root 1181490 Aug 28 09:43 syslog
```

13、服务器端查看存储池空间
```
# ceph df 
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

14、取消映射
```
# rbd unmap /dev/rbd0
```

15、设置自动挂载
```
# 1、开机自动映射到本地
# vim /etc/ceph/rbdmap
  rbd/rbd1  id=admin,keyring=/etc/ceph/ceph.client.admin.keyring

# systemctl start rbdmap.service 
# systemctl enable rbdmap.service 
# systemctl status rbdmap.service


# 2、开机自动挂载
# vim /etc/fstab
 /dev/rbd/rbd/rbd1 /mnt/ceph-test001 xfs defaults,noatime,_netdev 0 0
# mount -a
```

# 客户端使用普通账户挂载并使用 RBD

1、创建普通账户并授权 (资源有限，使用了之前的虚拟机，可以新建一台client来做实验)
```
# 创建普通账户
# ceph auth add client.shijie mon 'allow r' osd 'allow rwx pool=rbd-data1'
added key for client.shijie

# 验证用户信息
# ceph auth get client.shijie
[client.shijie]
    key = AQCAaCphzIAHMxAAddWTSYWGP6+lQuJV2OW/mQ==
    caps mon = "allow r"
    caps osd = "allow rwx pool=rbd-data1"
exported keyring for client.shijie

# 创建 keyring 文件
# ceph-authtool --create-keyring ceph.client.shijie.keyring
creating ceph.client.shijie.keyring

# 导出用户 keyring
# ceph auth get client.shijie -o ceph.client.shijie.keyring
exported keyring for client.shijie
```

2、同步普通用户认证文件
```
# scp ceph.conf ceph.client.admin.keyring root@10.0.0.200:/etc/ceph/
```

3、在客户端验证权限
```
# ll /etc/ceph/
total 20
drwxr-xr-x  2 root root 4096 Aug 28 09:56 ./
drwxr-xr-x 81 root root 4096 Aug 28 09:51 ../
-rw-r--r--  1 root root  125 Aug 28 09:47 ceph.client.shijie.keyring
-rw-r--r--  1 root root  261 Aug 20 10:11 ceph.conf
-rw-r--r--  1 root root   92 Jun  7 07:39 rbdmap

# 默认使用 admin 账户
# ceph --user shijie -s
```

4、映射 rbd
```
# 映射 rbd
# rbd --user shijie -p rbd-data1 map data-img2
/dev/rbd2

# 验证rbd
# fdisk -l /dev/rbd0
Disk /dev/rbd0: 3 GiB, 3221225472 bytes, 6291456 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 4194304 bytes / 4194304 bytes
```

5、格式化并使用 rbd 镜像
```
# mkfs.ext4 /dev/rbd2
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

# mkdir /data2
# mount /dev/rbd2 /data2/
# cp /var/log/messages /data2/

# ll /data2
total 24
drwxr-xr-x  3 root root  4096 Aug 28 10:00 ./
drwxr-xr-x 25 root root  4096 Aug 28 10:01 ../
drwx------  2 root root 16384 Aug 28 10:00 lost+found/

# df -TH
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

#管理端验证镜像状态
# rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  3 GiB            2        excl
data-img2  5 GiB            2
```

6、验证 ceph 内核模块

- 挂载 rbd 之后系统内核会自动加载 libceph.ko 模块
```
# lsmod|grep ceph
libceph               315392  1 rbd
libcrc32c              16384  2 xfs,libceph

# modinfo libceph
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

7、rbd 镜像空间拉伸
```
#当前 rbd 镜像空间大小
# rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  3 GiB            2        excl
data-img2  5 GiB            2            

#拉伸 rbd 镜像空间
# rbd resize --pool rbd-data1 --image data-img2 --size 8G
Resizing image: 100% complete...done.

# rbd resize --pool rbd-data1 --image data-img1 --size 6G
Resizing image: 100% complete...done.

#验证rgb信息
# rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  6 GiB            2            
data-img2  8 GiB            2 
```

8、客户端验证镜像空间
```
# fdisk -l /dev/rbd2
Disk /dev/rbd2: 8 GiB, 8589934592 bytes, 16777216 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 4194304 bytes / 4194304 bytes
```

9、开机自动挂载
```
# cat /etc/fstab 
rbd --user shijie -p rbd-data1 map data-img2 mount /dev/rbd2 /data2/
# chmod a+x /etc/fstab 
# reboot

#查看映射
# rbd showmapped
id pool image snap device 
0 rbd-data1 data-img2 - /dev/rbd2
```

10、卸载 rbd 镜像
```
# umount /data2
# umount /data2 rbd --user shijie -p rbd-data1 unmap data-img2
```

11、删除 rbd 镜像
- 删除存储池 rbd -data1 中的 data-img1 镜像
```
# rbd rm --pool rbd-data1 --image data-img1
Removing image: 100% complete...done.
```

七、调整Ceph RBD块大小
---
扩大RBD img
```
# 调整块设备增加到3G
rbd resize --image rbd1 --size 3000 --name client.rbd
rbd resize rbd/test1 --size=5G

# 查看调整后的大小
rbd info --image rbd1 -n client.rbd

# 重新读取配置
xfs_growfs -d /mnt/ceph-disk1
```  

# 八、回收站

```
# 查看镜像状态
# rbd status --pool rbd-data1 --image data-img2

# 将进行移动到回收站
# rbd trash move --pool rbd-data1 --image data-img2

# 查看回收站的镜像
# rbd trash list --pool rbd-data1
12468e5b9a04b data-img2

# 从回收站删除镜像,如果镜像不再使用，可以直接使用 trash remove 将其从回收站删除
# rbd trash remove --pool rbd-data1 --image data-img2

# 还原镜像
# rbd trash restore --pool rbd-data1 --image data-img2 --image-id 12468e5b9a04b

# 验证镜像
# rbd ls --pool rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img2  8 GiB            2
```

# 九、创建快照

| 命令 | 描述 |
|------|-----|
| rbd feature enable rbd/test layering | 启动快照 |
| rbd feature disable rbd/test layering | 禁用快照 |
| rbd snap create rbd/rbd1@snap1 | 创建快照 |
| rbd snap list rbd/rbd1 (或者rdb snap ls) | 列出快照 |
| rbd snap limit set --limit 1 | 设置一个镜像的快照上限 |
| rbd snap limit clear rbd/rbd1 | 清除镜像的快照数量限制 |
| rbd snap rename rbd/rbd1@snap1 rbd/rbd1@snap2 | 重命名快照 |
| rbd snap remove rbd/rbd1@snap1 （或者rbd snap rm） | 删除一个快照 |
| rbd snap purge rbd/rbd1 | 删除所有未保护的快照 |
| rbd snap rollback rbd/rbd1 | 还原快照 |
| rbd snap protect rbd/rbd1@snap1 | 保护快照，不被删除 |
| rbd snap unprotect rbd/rbd1@snap1 | 允许一个快照被删除(取消快照保护) |

1、创建一个测试文件到挂载目录
```
# echo "Hello cephtest,This is snapshot test" > /data2/ceph-snapshot-file
```

2、创建快照
```
# 创建快照
# rbd snap create --pool rbd-data1 --image data-img2 --snap img2-snap-12468e5b9a04b
Creating snap: 100% complete...done.

# 验证快照
# rbd snap list --pool rbd-data1 --image data-img2
SNAPID  NAME                     SIZE   PROTECTED  TIMESTAMP               
     4  img2-snap-12468e5b9a04b  8 GiB             Sun Aug 29 01:41:32 2021

# 或者
# rbd snap create rbd-data1/data-img2@img2-snap-12468e5b9a04b
# rbd snap ls rbd-data1/data-img2
# rbd ls -l

# 查看快照详细信息
# rbd info rbd-data1/data-img2
```

3、删除数据并还原快照
```
# 删除文件
rm -rf /data2/*


# 卸载 rbd
# umount /data2 
# rbd unmap /dev/rbd2

#回滚快照
# rbd snap rollback --pool rbd-data1 --image data-img2 --snap img2-snap-12468e5b9a04b
或者
# rbd snap rollback  rbd-data1/data-img2@img2-snap-12468e5b9a04b --name client.rbd


# 验证回滚
# rbd --user shijie -p rbd-data1 map data-img2
# mount /dev/rbd0 /data2/

# cat /data2/ceph-snapshot-file
Hello cephtest,This is snapshot test
``` 

4、重命名快照  

语法： `rbd snap rename <pool-name>/<image-name>@<original-snapshot-name> <pool-name>/<image-name>@<new-snapshot-name>`
```
# rbd snap rename rbd/rbd1@snapshot1 rbd/rbd1@snapshot1_new -n client.rbd
```
 
5、删除快照  

```
# rbd snap remove --pool rbd-data1 --image data-img2 --snap img2-snap-12468e5b9a04b
Removing snap: 100% complete...done.

# rbd snap rm rbd-data1/data-img2@img2-snap-12468e5b9a04b
Removing snap: 100% complete...done.

#验证快照是否删除
# rbd snap list --pool rbd-data1 --image data-img2
```

6、清除所有快照
```
# rbd snap purge --pool rbd-data1 --image data-img2
或者
# rbd snap purge  rbd-data1/data-img2
```

7、快照数量限制
```
设置与修改快照数量限制
# rbd snap limit set --pool rbd-data1 --image data-img2 --limit 30

清除快照数量限制
# rbd snap limit clear --pool rbd-data1 --image data-img2
```

8、快照保护
```
# 保护快照
# rbd snap protect rbd-data1/data-img2@img2-snap-12468e5b9a04b

取消保护快照
# rbd snap unprotect rbd-data1/data-img2@img2-snap-12468e5b9a04b
```
- 保护的快照只能可读无法进行操作除非取消才能操作

十、克隆
---

| 命令 | 描述 |
|------|-----|
| rbd children rbd/rbd1@snap1 | 列出快照 |
| rbd clone rbd/rbd1@snap1 rbd/rbd2 | 创建快照 |
| rbd flatten rbd/rbd2 | 扁平化克隆 |


1、创建具有 layering 功能的 RBD image  
```
# rbd create rbd2 --size 1024 --image-feature layering --name client.rbd

# rbd info --image rbd2 -n client.rbd
rbd image 'rbd2':
    size 10240 MB in 2560 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.1102238e1f29
    format: 2
    features: layering
    flags:
```  

2、挂载 rbd2 块设备  
```
# rbd map --image rbd2 --name client.rbd
# mkfs.xfs /dev/rbd1
# mkdir /opt/ceph-disk2
# mount /dev/rbd1 /opt/ceph-disk2
# df -h /opt/ceph-disk2
# echo "devopsedu.net,rbd2" > /opt/ceph-disk2/rbd2file
# sync
```  

3、创建此 RBD image 的快照  
```
# rbd snap create rbd/rbd2@snapshot_for_clone -n client.rbd
```
注意：要创建COW克隆，需要保护快照，因为如果快照被删除，所有附加的COW克隆将被销毁：  

4、保护快照  
```
# rbd snap protect rbd/rbd2@snapshot_for_clone -n client.rbd
# echo "devopsedu.net,rbd2snapshot" > /opt/ceph-disk2/rbd2-snapshot
```  

5、创建链接克隆  
语法：`rbd clone <pool-name>/<parent-image-name>@<snap-name> <pool-name>/<child_image-name> --image-feature <feature-name>`
```
# rbd clone rbd/rbd2@snapshot_for_clone rbd/clone_rbd2 --image-feature layering -n client.rbd
```

6、查看克隆后信息  
```
# rbd info rbd/clone_rbd2 -n client.rbd
rbd image 'clone_rbd2':
    size 1024 MB in 2560 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.110b2eb141f2
    format: 2
    features: layering
    flags:
    parent: rbd/rbd2@snapshot_for_clone
    overlap: 1024 MB

# rbd children rbd/rbd2@snapshot_for_clone -n client.rbd
rbd/clone_rbd2

# umount /opt/ceph-disk2
# rbd map --image clone_rbd2 --name client.rbd
# mount /dev/rbd2 /opt/ceph-disk2
# ll /opt/ceph-disk2
  -rw-r--r-- 1 root root 19 May 4 15:03 rbd2file
# echo "devopsedu.net,clone_rbd2" > /opt/ceph-disk2/clone_rbd2  
```  

6、创建完整克隆  
```
# rbd flatten rbd/clone_rbd2 -n client.rbd
Image flatten: 100% complete...done.
# rbd info --image clone_rbd2 --name client.rbd
rbd image 'clone_rbd2':
    size 10240 MB in 2560 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.110b2eb141f2
    format: 2
    features: layering
    flags:
```  
注意：如果在deep-flatten映像上启用了该功能，则默认情况下图像克隆与其父级分离。  

7、删除父镜像  
```
# rbd snap unprotect rbd/rbd2@snapshot_for_clone -n client.rbd    # 掉快照保护
# rbd snap rm rbd/rbd2@snapshot_for_clone -n client.rbd
Removing snap: 100% complete...done.
```  

8、验证数据，验证父映像rbd2  
```
# rbd list -n client.rbd
clone_rbd2
rbd1
rbd2

# umount /opt/ceph-disk2
# mount /dev/rbd1 /opt/ceph-disk2
# ll /opt/ceph-disk2/         # rbd2最终的文件
-rw-r--r-- 1 root root 19 May 4 15:03 rbd2file
-rw-r--r-- 1 root root 27 May 4 15:04 rbd2-snapshot
```  

9、验证完整克隆映像 clone_rbd2  
```
# umount /opt/ceph-disk2
# rbd unmap /dev/rbd1
# rbd rm rbd2 -n client.rbd
# mount /dev/rbd2 /opt/ceph-disk2
# ll /opt/ceph-disk2/
```  

# RBD的镜像导入和导出

- ceph存储可以利用快照做数据恢复，但是快照依赖于底层的存储系统没有被破坏,可以利用rbd的导入导出功能将快照导出备份,RBD导出功能可以基于快照实现增量导出 


## 导出

常见的几种导出方式
- 1.导出从创建rbd到第一次快照
- 2.导出从创建rbd到第二次快照
- 3.导出从第一次快照到第二次快照的差异
- 4.导出第二次快照到当前状态的差异
- 5.导出完整的

```
# 创建快照
rbd snap create testimage@v1
rbd snap create testimage@v2

# 导出创建image到快照v1时间点的差异数据
rbd export-diff rbd/testimage@v1 testimage_v1

# 导出创建image到快照v2时间点的差异数据
rbd export-diff rbd/testimage@v2 testimage_v2

# 导出v1快照时间点到v2快照时间点的差异数据
rbd export-diff  rbd/testimage@v2 --from-snap v1 testimage_v1_v2

# 导出创建image到当前时间点的差异数据
rbd export rbd/testimage testimage_now
```

## 导入

常见导入方式
- 1.导入完整的rbd
- 2.导入从创建rbd到第一次快照，导入第一次快照到第二次快照，导入第二次快照到当前状态
- 3.导入第二次快照，导入第二次快照到当前状态的差异

```
# 随便创建一个image，名称大小都不限制（恢复时会覆盖大小信息）
rbd create testbacknew --size 1

# 恢复到v2时间点,直接基于v2的时间点快照做恢复
rbd import-diff testimage_v2 rbd/testbacknew

# 基于v1的时间点数据，增量v1_v2的数据
rbd import-diff testimage_v1 rbd/testbacknew
rbd import-diff testimage_v1_v2 rbd/testbacknew
```
