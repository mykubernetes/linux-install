# LVM(Logical Volume Manager)

| 功能/命令 | 物理卷管理 | 卷管理 | 逻辑卷管理 |
|----------|-----------|--------|-----------|
| 扫描 | pvscan | vgscan | lvscan |
| 建立 | pvcreate | vgcreate | lvcreate |
| 显示 | pvdisplay\|pvs | vgdisplay\|vgs | lvdisplay\|lvs |
| 删除 | pvremove | vgremove | lvremove |
| 扩容 | 物理卷不能扩展 | vgextend | lvextend |
| 缩小 | 物理卷不能缩小 | vgreduce | lvreduce |

```
  物理卷PV
  pvcreate   创建pv                例：pvcreate /dev/sda1
  pvs        查看pv信息            例：直接在命令行里输入pvs
  pvdisplay  查看pv详细信息        例：pvcreate /dev/sda1
  pvmove     将pv数据移动到其他pv  例：pvmove /dev/sda1 /dev/sda4
  pvremove   将pv删除             例：pvremove /dev/sda1
  ================================================================
  卷组VG
  vgcreate   创建vg              例：vgcreate vg01  /dev/sda{m,n}
  vgs        查看vg信息          例：直接在命令行里输入vgs
  vgdisplay  查看vg详细信息      例：vgdisplay vg01
  vgremove   将vg删除            例：vgremove vg01
  vgextend   扩容vg             例：vgextend vg01 /dev/sdb2 扩展vg01卷组，把/dev/sda2加进去
  vgreduce   缩减vg             例：vgreduce vg01 /dev/sdb2 缩减vg01卷组，把/dev/sda2去掉
  ================================================================
  逻辑卷LV
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

生成环境配置过程
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

参考：
- https://zhuanlan.zhihu.com/p/581145034
- https://blog.csdn.net/weixin_42915431/article/details/121881054
- [gentoo-LVM](https://wiki.gentoo.org/wiki/LVM)
- [archlinux-LVM](https://wiki.archlinux.org/title/LVM)
- [debian-LVM](https://wiki.debian.org/LVM)
