# LVM(Logical Volume Manager)

# LVM 逻辑卷概述

随着企业业务的增加，文件系统负载加大，很可能导致空间不足，用传统的分区方式管理磁盘，得把现有的分区删除，然后重新规划新的存储方案，因此我们需要一种管理机制，可以帮我们动态管理存储，而 LVM 就可以提供这种功能。

LVM（Logical Volume Manager）是基于内核的一种逻辑卷管理器，LVM 适合管理大存储设备，并允许用户动态调整文件系统的大小。此外，LVM 的快照功能可以帮助我们快速备份数据。
下面是关于 LVM的几个概念。

- 物理卷（PV）：物理卷是 LVM 的最底层概念，是 LVM 的逻辑存储块，物理卷与磁盘分区是逻辑的对应关系。多个逻辑卷可以组合或拆分，实现容量扩充或缩减。LVM 提供的命令可以将分区转化成物理卷，通过组合生成卷组。
- 卷组（VG）：卷组时 LVM 逻辑概念上的磁盘设备，通过单个或多个 PV 组合生成的。
- 物理长度（PE）：物理长度为 PV 合成 VG 后，所划分的最小存储单元，PE 默认为 4MB。
- 逻辑卷（LV）：逻辑卷是 LVM 逻辑意义分区，我们可以指定从卷组中分多少容量来创建逻辑卷，最后将此逻辑卷挂载使用。


| 功能/命令 | 物理卷管理 | 卷管理 | 逻辑卷管理 |
|----------|-----------|--------|-----------|
| 扫描 | pvscan | vgscan | lvscan |
| 建立 | pvcreate | vgcreate | lvcreate |
| 显示 | pvdisplay\|pvs | vgdisplay\|vgs | lvdisplay\|lvs |
| 删除 | pvremove | vgremove | lvremove |
| 扩容 | 物理卷不能扩展 | vgextend | lvextend |
| 缩小 | 物理卷不能缩小 | vgreduce | lvreduce |

```
# 物理卷PV
pvcreate   创建pv                例：pvcreate /dev/sda1
pvs        查看pv信息            例：直接在命令行里输入pvs
pvdisplay  查看pv详细信息        例：pvcreate /dev/sda1
pvmove     将pv数据移动到其他pv  例：pvmove /dev/sda1 /dev/sda4
pvremove   将pv删除             例：pvremove /dev/sda1

# 卷组VG
vgcreate   创建vg              例：vgcreate vg01  /dev/sda{m,n}
vgs        查看vg信息          例：直接在命令行里输入vgs
vgdisplay  查看vg详细信息      例：vgdisplay vg01
vgremove   将vg删除            例：vgremove vg01
vgextend   扩容vg             例：vgextend vg01 /dev/sdb2 扩展vg01卷组，把/dev/sda2加进去
vgreduce   缩减vg             例：vgreduce vg01 /dev/sdb2 缩减vg01卷组，把/dev/sda2去掉

# 逻辑卷LV
lvcreate   创建lv          
例：lvcreate -L 100%FREE -n lv01 vg01   将vg01空间全部新建到lv01上
    lvcreate -n lv01 -L 100G vg01       指定新建lv大小100G
lvs        查看lv信息       例：直接在命令行里输入lvs
lvdisplay  查看lv详细信息    例：vgdisplay lv01
lvremove   将lv 移除       例：lvremove  /dev/vg01/lv01
lvextend   扩容lv         
例：lvextend -L +100%FREE /dev/vg01/lv01 将vg01空间全部扩到lv01上
    lvextend -L +100G /dev/vg01/lv01     指定扩容大小100G
```

## 创建LVM

- 物理卷初始化
```
$ pvcreate /dev/sdb1 /dev/sdc2
Physical volume "/dev/sdb1" successfully created.
Physical volume "/dev/sdc2" successfully created.
```

- 查看可用作物理卷的块设备
```
$lvmdisscan
  /dev/centos/root [      46.99 GiB]
  /dev/sda1        [       1.00 GiB]
  /dev/centos/swap [       2.00 GiB]
  /dev/sda2        [     <49.00 GiB] LVM physical volume
  /dev/sdb1        [      50.00 GiB] LVM physical volume
  /dev/sdb2        [     <50.00 GiB]
  /dev/sdc1        [      20.00 GiB]
  /dev/sdc2        [     <30.00 GiB] LVM physical volume
  2 disks
  3 partitions
  0 LVM physical volume whole disks
  3 LVM physical volumes
```

- 创建卷组
```
$ vgcreate tmp /dev/sdb1
  Volume group "tmp" successfully created
$ vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  centos   1   2   0 wz--n- <49.00g   4.00m
  data     2   1   0 wz--n-  49.99g <48.00g
  tmp      1   1   0 wz--n- <50.00g <49.00g
```

- 创建逻辑卷
```
$ lvcreate -n backup -L 1G tmp
  Logical volume "backup" created.
$ lvs
  LV     VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   centos -wi-ao---- 46.99g
  swap   centos -wi-ao----  2.00g
  data   data   -wi-ao---- <2.00g
  backup tmp    -wi-a-----  1.00g
  
$ lvcreate -n backup -l +100%VG

$ lvcreate -l 100%FREE -n lv_data01 vg_data01 分配全部空间
```
- -n lv的名称
- tmp vg的名称

- 挂载逻辑卷
```
$ mkfs.xfs /dev/tmp/backup
$ mount /dev/tmp/backup /backup/
$ df -h /backup
文件系统                容量  已用  可用 已用% 挂载点
/dev/mapper/tmp-backup 1014M   33M  982M    4% /backup
```

## 扩容

- 卷组有空间
```
$ umount /backup	# 卸载磁盘
$ lvextend -L +1G --resizefs /dev/tmp/backup	# 扩容1G空间
$ lvs	# 查看逻辑卷
  LV     VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   centos -wi-ao---- 46.99g
  swap   centos -wi-ao----  2.00g
  data   data   -wi-ao---- <2.00g
  backup tmp    -wi-a-----  2.00g
$ lvextend -l +100%FREE --resizefs /dev/tmp/backup	# 把卷组所有剩余空间扩展给backup逻辑卷
$ lvs
  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   centos -wi-ao----  46.99g
  swap   centos -wi-ao----   2.00g
  data   data   -wi-ao----  <2.00g
  backup tmp    -wi-a----- <50.00g
```

- 卷组没有空间
```
# 添加磁盘
$ umount /backup
$ pvcreate /dev/sdd	
$ vgextend tmp /dev/sdd
$ lvextend -L +1G /dev/tmp/backup
$ lvs
```

- 扩容根分区
```
$ pvcreate /dev/sdx
$ vgextend centos /dev/sdx
$ lvextend -l +100%FREE /dev/centos/root
$ xfs_growfs /dev/centos/root
```

- 更新硬盘
```
# /dev/sdx 磁盘坏使用 /dev/sdz 替换/dev/sdx，sdz空间大于等于sdx。
$ pvcreate /dev/sdz
$ vgextend centos /dev/sdz
$ pvmove /dev/sdx /dev/sdz
$ vgreduce centos /dev/sdx
```

# 生成环境配置过程
```
创建pv
pvcreate /dev/mapper/mpatha
pvcreate /dev/mapper/mpathb
pvcreate /dev/mapper/mpathc
pvcreate /dev/mapper/mpathd
pvcreate /dev/mapper/mpathe
pvcreate /dev/mapper/mpathf
pvcreate /dev/mapper/mpathi
pvcreate /dev/mapper/mpathg
pvcreate /dev/mapper/mpathj

创建vg
vgcreate vg_data01 /dev/mapper/mpatha
vgcreate vg_data02 /dev/mapper/mpathb

扩容vg
vgextend vg_data02 /dev/mapper/mpathb
vgextend vg_data02 /dev/mapper/mpathc
vgextend vg_data02 /dev/mapper/mpathd
vgextend vg_data02 /dev/mapper/mpathe
vgextend vg_data02 /dev/mapper/mpathf
vgextend vg_data02 /dev/mapper/mpathg
vgextend vg_data02 /dev/mapper/mpathi
vgextend vg_data02 /dev/mapper/mpathj

创建lv
lvcreate -l 100%FREE -n lv_data01 vg_data01
lvcreate -l 100%FREE -n lv_data02 vg_data02

格式化
mkfs.xfx /dev/vg_data01/lv_data01
mkfs.xfx /dev/vg_data02/lv_data02

创建目录
mkdir /data01
mkdir /data02

自动挂载
echo "/dev/vg_data01/lv_data01    /data01     xfs         defaults    0 0" >> /etc/fstab
echo "/dev/vg_data01/lv_data02    /data01     xfs         defaults    0 0" >> /etc/fstab

挂载
mount -a 
```

# 删除lvm分区

## 1.删除lvm分区与创建lvm的步骤刚好相反，要先删除逻辑卷，再删除卷组，再删除物理卷，先查看系统中在使用的逻辑卷。

```
# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/vg_root-lv_root      200G  4.0G  196G   2% /
devtmpfs                         126G     0  126G   0% /dev
tmpfs                            126G     0  126G   0% /dev/shm
tmpfs                            126G   13M  126G   1% /run
tmpfs                            126G     0  126G   0% /sys/fs/cgroup
/dev/sda2                       1014M  153M  862M  16% /boot
/dev/sda1                        200M   12M  189M   6% /boot/efi
/dev/mapper/vg_root-lv_app       342G   33M  342G   1% /app
tmpfs                             26G   12K   26G   1% /run/user/42
tmpfs                             26G     0   26G   0% /run/user/0
/dev/mapper/vg_data01-lv_data01  5.0T   33M  5.0T   1% /data01           # 挂载的lvm卷
/dev/mapper/vg_data02-lv_data02  5.0T   33M  5.0T   1% /data02           # 挂载的lvm卷
```

```
# lvdisplay
  --- Logical volume ---
  LV Path                /data01           # lv挂载路径
  LV Name                lv_data01         # lv名字
  VG Name                vg_data01         # vg名字
  LV UUID                f5xsH0-zt90-3T4R-LXWt-i6bv-Bt0U-GJzFEC
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-06-17 01:26:42 +0800
  LV Status              available
  # open                 2
  LV Size                5.00 TiB
  Current LE             99245
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1

  --- Logical volume ---
  LV Path                /data02
  LV Name                lv_data02
  VG Name                vg_data02
  LV UUID                IBN45c-hxUQ-ujc5-e43x-k8SZ-QOOG-It5t03
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-06-17 01:26:42 +0800
  LV Status              available
  # open                 2
  LV Size                5.00 TiB
  Current LE             99245
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
```

## 2.首先要卸载文件系统
```
# umount /data01
# umount /data02
# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/vg_root-lv_root      200G  4.0G  196G   2% /
devtmpfs                         126G     0  126G   0% /dev
tmpfs                            126G     0  126G   0% /dev/shm
tmpfs                            126G   13M  126G   1% /run
tmpfs                            126G     0  126G   0% /sys/fs/cgroup
/dev/sda2                       1014M  153M  862M  16% /boot
/dev/sda1                        200M   12M  189M   6% /boot/efi
/dev/mapper/vg_root-lv_app       342G   33M  342G   1% /app
tmpfs                             26G   12K   26G   1% /run/user/42
tmpfs                             26G     0   26G   0% /run/user/0
```

## 3.然后再删除逻辑卷，删除语法：lvremove  逻辑卷名，删除完成后再查看逻辑卷发现已经删除完成了
```
# lvremove /dev/vg_data01/lv_data01
Do you really want to remove active logical volume choyvg/choylv? [y/n]: y
  Logical volume "lv_data01" successfully removed

# lvremove /dev/lg_data02/lv_data02
Do you really want to remove active logical volume choyvg/choylv? [y/n]: y
  Logical volume "vg_data02" successfully removed

# lvdisplay 
  --- Logical volume ---
  LV Path                /dev/centos/swap
  LV Name                swap
  VG Name                centos
  LV UUID                IBN45c-hxUQ-ujc5-e43x-k8SZ-QOOG-It5t02
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-06-17 01:26:42 +0800
  LV Status              available
  # open                 2
  LV Size                <3.88 GiB
  Current LE             992
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
```


## 4.再接着就是删除卷组，删除语法为：vgremove 卷组名，如下图删除完成后卷组已经不存在了
```
# vgremove vg_data01
  Volume group "vg_data01" successfully removed

# vgremove vg_data02
  Volume group "vg_data02" successfully removed

# vgdisplay 
  --- Volume group ---
  VG Name               centos
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <299.00 GiB
  PE Size               4.00 MiB
  Total PE              76543
  Alloc PE / Size       76542 / 298.99 GiB
  Free  PE / Size       1 / 4.00 MiB
  VG UUID               ia7Ozt-2204-z63a-60m1-1AiS-qktK-gmaKBk
```

## 5.最后就是删除物理卷，删除语法为pvremove /dev/sd*，删除完成后物理卷也没有了
```
# pvremove /dev/sd[b-c]1
Labels on physical volume "/dev/sdb1" successfully wiped.
Labels on physical volume "/dev/sdc1" successfully wiped.

# pvdisplay 
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               <299.00 GiB / not usable 3.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              76543
  Free PE               1
  Allocated PE          76542
  PV UUID               PDu9BL-b3qD-PuSN-dru0-THDK-Q6vB-pQdD9X
```

参考：
- https://zhuanlan.zhihu.com/p/581145034
- https://blog.csdn.net/weixin_42915431/article/details/121881054
- [gentoo-LVM](https://wiki.gentoo.org/wiki/LVM)
- [archlinux-LVM](https://wiki.archlinux.org/title/LVM)
- [debian-LVM](https://wiki.debian.org/LVM)
