# 一、linux下安装多路径multipath

1.安装多路径
```
# yum install device-mapper-multipath
```

2.检查安装是否正常
```
# lsmod | grep multipath
dm_multipath           17884  6 dm_round_robin
dm_mod                 95622  30 dm_multipath,dm_mirror,dm log
```

3.如果模块没有加载成功，使用下面的命令初始化DM
```
# modprobe dm-multipath
# modprobe dm-round-robin
```

4.开机自启动
```
# systemctl enable multipathd.service
```

```
#查看主机或者存储交换机上的WWN号，在存储上将LUN映射给需要的主机
cat /sys/class/fc_host/host*/port_name
0x2002d0431efb7f5d
0x2001d0431efb7f5d

#在系统内执行扫盘命令，没有命令先安装sg3_utils
yum install sg3_utils
rescan-scsi-bus.sh

#查看本地存储wwid
/lib/udev/scsi_id --whitelisted --device=/dev/sda
36141877030bcca001d9c4d52106b9d90

#查看存储参数
cat /sys/block/sdb/device/vendor 
3PARdata
cat /sys/block/sdb/device/model
VV
```

5.配置配置文件

5.1.拷贝默认的multipath.conf到/etc目录下，也可以使用mpathconf命令创建默认模板
```
# cp /usr/share/doc/device-mapper-multipath-0.4.9/multipath.conf /etc/
或者
mpathconf --enable --with_multipathd y
```

5.2.根据实际情况进行修改

```
# cat /etc/multipath.conf 
blacklist { 
  devnode "^sda"                          #本地系统盘加入黑名单
} 

defaults { 
  user_friendly_names yes                 #如果是集群环境yes最好改成no
  path_grouping_policy multibus
  failback immediate
  no_path_retry fail
} 

multipaths { 
  multipath { 
  wwid 3600508b4000892b90002a00000050000  #磁盘的WWID 
  alias comsys-dm0                        #映射后的别名，自己命名 
  path_grouping_policy multibus           #路径组策略 
  path_checker tur                        #决定路径状态的方法
  path_selector "round-robin 0"           #选择那一条路径进行下次IO操作 
  } 

multipath { 
  wwid 3600508b4000892b90002a00000090000 
  alias comsys-dm1 
  path_grouping_policy multibus 
  path_selector "round-robin 0" 
  } 

multipath { 
  wwid 3600508b4000892b90002a00000140000 
  alias comsys-backup 
  path_grouping_policy multibus 
  path_selector "round-robin 0" 
  } 
} 

devices { 
  device { 
    vendor "HP"                         #厂商名称，可通过multipath –v3获取到 
    product "HSV300"                    #产品型号 
    path_grouping_policy multibus       #默认的路径组策略 
    getuid_callout "/sbin/scsi_id -g -u -s /block/%n"  #获得唯一设备号使用的默认程序 
    path_checker readsector0            #决定路径状态的方法 
    path_selector "round-robin 0"       #选择那条路径进行下一个IO操作的方法 
    #failback immediate                 #故障恢复的模式 
    #no_path_retry queue                #在disable queue之前系统尝试使用失效路径的次数的数值 
    #rr_min_io 100                      #在当前的用户组中，在切换到另外一条路径之前的IO请求的数目 
  } 
} 
```

6.启动服务
```
systemctl start multipathd.service
```

## multipath常用命令

| 命令 | 描述 |
|------|------|
| multipath -r | 修改multipath.conf配置文件之后重新加载 | 
| multipath -ll | 查看多路径状态 | 
| multipath -v2 | 格式化路径，检测路径，合并路径 | 
| multipath -v3 | 查看多路径详情blacklist、whitelist和设备wwid | 
| multipath -F | 清空已有的multipath记录 | 

7.查看相关配置文件

服务器启动之后设备的wwid会自动添加到/etc/multipath/wwids文件中,wwid自动生成到该文件中,不需要进行编辑,如下:
```
# more /etc/multipath/wwids
# Multipath wwids, Version : 1.0
# NOTE: This file is automatically maintained by multipath and multipathd.
# You should not need to edit this file in normal circumstances.
#
# Valid WWIDs:
/VBOX_HARDDISK_VBa08577cb-9ee269dc/
/VBOX_HARDDISK_VB74301632-13d08c3c/
/VBOX_HARDDISK_VBfa94873f-504b6993/
/VBOX_HARDDISK_VB4f84df6d-a94b8da6/
```

绑定文件/etc/multipath/bindings,该文件里面的映射关系是自动生成的,不需要进行手工编辑
```
# more /etc/multipath/bindings
# Multipath bindings, Version : 1.0
# NOTE: this file is automatically maintained by the multipath program.
# You should not need to edit this file in normal circumstances.
#
# Format:
# alias wwid
#
mpatha VBOX_HARDDISK_VBa08577cb-9ee269dc
mpathb VBOX_HARDDISK_VB74301632-13d08c3c
mpathc VBOX_HARDDISK_VBfa94873f-504b6993
mpathd VBOX_HARDDISK_VB4f84df6d-a94b8da6
```

8.查看服务
```
# multipath -ll
mpathd (VBOX_HARDDISK_VB4f84df6d-a94b8da6) dm-4 ATA     ,VBOX HARDDISK   
size=40G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 6:0:0:0 sde 8:64 active ready running
mpathc (VBOX_HARDDISK_VBfa94873f-504b6993) dm-3 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 5:0:0:0 sdd 8:48 active ready running
mpathb (VBOX_HARDDISK_VB74301632-13d08c3c) dm-2 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 4:0:0:0 sdc 8:32 active ready running
mpatha (VBOX_HARDDISK_VBa08577cb-9ee269dc) dm-1 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 3:0:0:0 sdb 8:16 active ready running
```

执行lsblk命令就可以看到多路径磁盘mpatha了
```
# lsblk
NAME              MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                 8:0    0   50G  0 disk  
├─sda1              8:1    0  300M  0 part  /boot
├─sda2              8:2    0  5.6G  0 part  [SWAP]
└─sda3              8:3    0 44.1G  0 part  
  └─vgroot-lvroot 253:0    0 44.1G  0 lvm   /
sdb                 8:16   0   30G  0 disk  
└─mpatha          253:1    0   30G  0 mpath
sdc                 8:32   0   30G  0 disk  
└─mpathb          253:2    0   30G  0 mpath
sdd                 8:48   0   30G  0 disk  
└─mpathc          253:3    0   30G  0 mpath
sde                 8:64   0   40G  0 disk  
└─mpathd          253:4    0   40G  0 mpath
sr0                11:0    1 1024M  0 rom   
loop0               7:0    0  4.4G  0 loop  /mnt
```

9.查看设备情况
```
# ls -al /dev/mapper
total 0
drwxr-xr-x.  2 root root     160 Apr 11 21:37 .
drwxr-xr-x. 19 root root    3300 Apr 11 21:37 ..
crw-------.  1 root root 10, 236 Apr 10 05:30 control
lrwxrwxrwx.  1 root root       7 Apr 11 21:43 mpatha -> ../dm-1
lrwxrwxrwx.  1 root root       7 Apr 11 21:43 mpathb -> ../dm-2
lrwxrwxrwx.  1 root root       7 Apr 11 21:43 mpathc -> ../dm-3
lrwxrwxrwx.  1 root root       7 Apr 11 21:43 mpathd -> ../dm-4
lrwxrwxrwx.  1 root root       7 Apr 10 05:30 vgroot-lvroot -> ../dm-0
```

10.重新编辑配置文件

编辑`/etc/multipath.conf`文件
```
multipaths {
       multipath {
               wwid                    VBOX_HARDDISK_VBa08577cb-9ee269dc
               alias                   ocrdisk01
               path_grouping_policy    multibus
       }
       multipath {
               wwid                    VBOX_HARDDISK_VB74301632-13d08c3c
               alias                   ocrdisk02
               path_grouping_policy    multibus
       }
       multipath {
               wwid                    VBOX_HARDDISK_VBfa94873f-504b6993
               alias                   ocrdisk03
               path_grouping_policy    multibus
       }       
       multipath {
               wwid                    VBOX_HARDDISK_VB4f84df6d-a94b8da6
               alias                   datadisk01
               path_grouping_policy    multibus
       }  
}
```

9.重启加载配置
```
# multipath -r
```

查看加载后的配置
```
# multipath -ll
ocrdisk03 (VBOX_HARDDISK_VBfa94873f-504b6993) dm-3 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 5:0:0:0 sdd 8:48 active ready running
datadisk01 (VBOX_HARDDISK_VB4f84df6d-a94b8da6) dm-4 ATA     ,VBOX HARDDISK   
size=40G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 6:0:0:0 sde 8:64 active ready running
ocrdisk02 (VBOX_HARDDISK_VB74301632-13d08c3c) dm-2 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 4:0:0:0 sdc 8:32 active ready running
ocrdisk01 (VBOX_HARDDISK_VBa08577cb-9ee269dc) dm-1 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  `- 3:0:0:0 sdb 8:16 active ready running
```

可以看到mapper下面的磁盘名称也改变了
```
# ls -al /dev/mapper/
total 0
drwxr-xr-x.  2 root root     160 Apr 11 22:16 .
drwxr-xr-x. 19 root root    3300 Apr 11 21:37 ..
crw-------.  1 root root 10, 236 Apr 10 05:30 control
lrwxrwxrwx.  1 root root       7 Apr 11 22:16 datadisk01 -> ../dm-4
lrwxrwxrwx.  1 root root       7 Apr 11 22:16 ocrdisk01 -> ../dm-1
lrwxrwxrwx.  1 root root       7 Apr 11 22:16 ocrdisk02 -> ../dm-2
lrwxrwxrwx.  1 root root       7 Apr 11 22:16 ocrdisk03 -> ../dm-3
lrwxrwxrwx.  1 root root       7 Apr 10 05:30 vgroot-lvroot -> ../dm-0
```

10.若不想使用配置别名的话,可以修改如下文件(但是不建议修改),将映射关系写到配置文件
```
vi /etc/multipath/bindings
ocrdisk01 VBOX_HARDDISK_VBa08577cb-9ee269dc
ocrdisk02 VBOX_HARDDISK_VB74301632-13d08c3c
ocrdisk03 VBOX_HARDDISK_VBfa94873f-504b6993
datadisk01 VBOX_HARDDISK_VB4f84df6d-a94b8da6
```

然后进行重新加载配置,删除后进行加载
```
# multipath -F
# multipath -r
# multipath -ll
ocrdisk03 (VBOX_HARDDISK_VBfa94873f-504b6993) dm-3 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=enabled
  `- 5:0:0:0 sdd 8:48 active ready running
datadisk01 (VBOX_HARDDISK_VB4f84df6d-a94b8da6) dm-4 ATA     ,VBOX HARDDISK   
size=40G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=enabled
  `- 6:0:0:0 sde 8:64 active ready running
ocrdisk02 (VBOX_HARDDISK_VB74301632-13d08c3c) dm-2 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=enabled
  `- 4:0:0:0 sdc 8:32 active ready running
ocrdisk01 (VBOX_HARDDISK_VBa08577cb-9ee269dc) dm-1 ATA     ,VBOX HARDDISK   
size=30G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=enabled
  `- 3:0:0:0 sdb 8:16 active ready running
```
 
## 添加新的lun

新增lun请参考
- https://www.cnblogs.com/hxlasky/p/15014211.html

## 配置udev

1.编辑规则文件
```
# cd /etc/udev/rules.d/
# vi 99-oracle-asmdevices.rules
文件文件内容如下:
ENV{DM_NAME}=="ocrdisk01", OWNER:="grid", GROUP:="asmadmin", MODE:="660"
ENV{DM_NAME}=="ocrdisk02", OWNER:="grid", GROUP:="asmadmin", MODE:="660"
ENV{DM_NAME}=="ocrdisk03", OWNER:="grid", GROUP:="asmadmin", MODE:="660"
ENV{DM_NAME}=="datadisk01", OWNER:="grid", GROUP:="asmadmin", MODE:="660"
ENV{DM_NAME}=="datadisk02", OWNER:="grid", GROUP:="asmadmin", MODE:="660"
```
这里的磁盘名称需要跟/etc/multipath.conf配置里的对应起来

2.启用
```
# /sbin/udevadm trigger --type=devices --action=change
# udevadm trigger                  ##新增磁盘的情况 执行该句即可
```

如执行上面两个命令不生效的情况下，可以执行如下命令
```
#/sbin/udevadm control --reload 
# /sbin/udevadm trigger --type=devices --action=change
# udevadm trigger
```

3.查看设备权限
```
# ls -al /dev/dm*
brw-rw----. 1 root disk     253, 0 Apr 12 03:09 /dev/dm-0
brw-rw----. 1 grid asmadmin 253, 1 Apr 12 03:09 /dev/dm-1
brw-rw----. 1 grid asmadmin 253, 2 Apr 12 03:09 /dev/dm-2
brw-rw----. 1 grid asmadmin 253, 3 Apr 12 03:09 /dev/dm-3
brw-rw----. 1 grid asmadmin 253, 4 Apr 12 03:09 /dev/dm-4
brw-rw----. 1 grid asmadmin 253, 5 Apr 12 03:09 /dev/dm-5
```

4.安装rac的时候选择发现磁盘路径为:/dev/mapper/*

配置完成后建议重启动机器.

参考:
- https://cloud.tencent.com/developer/article/2129437
- https://www.cnblogs.com/hxlasky/p/14647226.html
- https://blog.csdn.net/neo949332116/article/details/106253255/
- https://blog.csdn.net/JReno/article/details/89520851
- http://www.360doc.com/content/20/0521/07/6279508_913612900.shtml
