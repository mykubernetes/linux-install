# 1. 虚拟机管理操作
```
attach-device                从XML文件附加设备
attach-disk                  附加磁盘设备
attach-interface             连接网络接口
autostart                    自动启动一个域
blkdeviotune                 设置或查询块设备I/O调整参数。
blkiotune                    获取或设置blkio参数
blockcommit                  开始块提交操作。
blockcopy                    开始一个块复制操作。
blockjob                     管理活动的块操作
blockpull                    从其背景图像填充磁盘。
blockresize                  调整域的块设备。
change-media                 更换CD或软驱的媒体
console                      连接到访客控制台
cpu-baseline                 计算基准CPU
cpu-compare                  比较主机CPU和由XML文件描述的CPU
cpu-stats                    显示域的CPU统计信息
create                       从XML文件创建一个域
define                       从XML文件中定义（但不要启动）域
desc                         显示或设置域的描述或标题
destroy                      摧毁（停止）一个域名
detach-device                从XML文件中分离设备
detach-disk                  分离磁盘设备
detach-interface             分离网络接口
domdisplay                   域显示连接URI
domfsfreeze                  冻结域的挂载文件系统。
domfsthaw                    解冻域的安装文件系统。
domfsinfo                    获取域安装的文件系统的信息。
domfstrim                    在域的挂载文件系统上调用fstrim。
domhostname                  打印域的主机名
domid                        将域名或UUID转换为域ID
domif-setlink                设置虚拟接口的链路状态
domiftune                    获取/设置虚拟接口的参数
domjobabort                  中止活动的域名工作
domjobinfo                   域名工作信息
domname                      将域ID或UUID转换为域名
domrename                    重命名一个域
dompmsuspend                 使用电源管理功能优雅地暂停域
dompmwakeup                  从pmsuspended状态唤醒一个域
domuuid                      将域名或ID转换为域UUID
domxml-from-native           将本地配置转换为域XML
domxml-to-native             将域XML转换为本地配置
dump                         将域的核心转储到文件进行分析
dumpxml                      XML中的域信息
edit                         编辑域的XML配置
event                        域名事件
inject-nmi                   向客人注入NMI
iothreadinfo                 查看域名IOThreads
iothreadpin                  控制域IOThread亲和力
iothreadadd                  将IOThread添加到来宾域
iothreaddel                  从来宾域中删除一个IOThread
send-key                     将密钥发送给客人
send-process-signal          发送信号给进程
lxc-enter-namespace          LXC访客输入名称空间
managedsave                  管理域名状态保存
managedsave-remove           删除管理的域名保存
memtune                      获取或设置内存参数
perf                         获取或设置perf事件
metadata                     显示或设置域的自定义XML元数据
migrate                      将域迁移到其他主机
migrate-setmaxdowntime       设置最大可容忍的停机时间
migrate-compcache            获取/设置压缩缓存大小
migrate-setspeed             设置最大迁移带宽
migrate-getspeed             获得最大的迁移带宽
migrate-postcopy             切换运行从预复制到后复制的迁移
numatune                     获取或设置numa参数
qemu-attach                  QEMU附件
qemu-monitor-command         QEMU监视器命令
qemu-monitor-event           QEMU监控事件
qemu-agent-command           QEMU访客代理命令
reboot                       重新启动一个域
reset                        重置一个域
restore                      从文件中保存的状态恢复域
resume                       恢复一个域名
save                         将域状态保存到文件
save-image-define            重新定义一个域的保存状态文件的XML
save-image-dumpxml           保存XML中的状态域信息
save-image-edit              编辑域的已保存状态文件的XML
schedinfo                    显示/设置调度程序参数
screenshot                   截取当前的域控制台并将其存储到文件中
set-user-password            在域内设置用户密码
setmaxmem                    改变最大内存限制
setmem                       改变内存分配
setvcpus                     更改虚拟CPU的数量
shutdown                     正常关闭域
start                        启动一个（以前定义的）非活动域
suspend                      暂停域名
ttyconsole                   tty控制台
undefine                     取消定义一个域
update-device                从XML文件更新设备
vcpucount                    域的vcpu数量
vcpuinfo                     详细的域名vcpu信息
vcpupin                      控制或查询域vcpu亲和力
emulatorpin                  控制或查询域模拟器亲和力
vncdisplay                   vnc显示
guestvcpus                   查询或修改guest虚拟机中的vcpu状态（通过代理）
setvcpu                      附加/分离vcpu或线程组
domblkthreshold              为给定块设备或其支持链元素设置块阈值事件的阈值
```


## 1.1、虚拟机状态

通过 virsh 管理虚拟机，虚拟机的状态显示为以下几种：
- runing 是运行状态 
- idel 是空闲状态 
- pause 暂停状态 
- shutdown 关闭状态 
- crash 虚拟机崩坏状态 
- daying 垂死状态 
- shut off 不运行完全关闭 
- pmsuspended客户机被关掉电源中中断

 
## 1.2 虚拟机的创建、开机、重启、关机

首先看下 create 和 define 创建虚拟机异同：
```
create 创建虚拟机
[root@192.168.118.14 ~]#virsh list --all
Id    Name                           State
----------------------------------------------------
76    centos                         running

[root@192.168.118.14 ~]#virsh create cirros.xml 
Domain cirros created from cirros.xml

[root@192.168.118.14 ~]#virsh list --all
Id    Name                           State
----------------------------------------------------
76    centos                         running
79    cirros                         running


define 创建虚拟机
[root@192.168.118.14 ~]#virsh list --all
Id    Name                           State
----------------------------------------------------
76    centos                         running

[root@192.168.118.14 ~]#virsh define cirros.xml 
Domain cirros defined from cirros.xml

[root@192.168.118.14 ~]#virsh list --all
Id    Name                           State
----------------------------------------------------
76    centos                         running
-     cirros                         shut off
```
- create  是通过 xml 格式文件创建虚拟机，创建完毕启动。当关闭虚拟机时，create创建的虚拟机消失。
- define  是通过 xml 格式文件创建虚拟机，创建完毕不启动。当关闭虚拟机时，define 在 list 中依然能查看到。

 
### 开启、重启、关闭虚拟机
```
开启：
virsh start domain

重启：
virsh reboot domain

关闭：
virsh shutdown domain      # 正常关闭虚拟机
virsh destroy domain       # 直接断电关闭虚拟机
```

## 1.3 虚拟机 CPU 的操作

cpu-stats 宿主机和虚拟机cpu 运行时间状态
```
[root@192.168.118.14 ~]#virsh cpu-stats centos
CPU0:
    cpu_time           131.344620748 seconds
    vcpu_time           78.559064700 seconds
CPU1:
    cpu_time           145.769793063 seconds
    vcpu_time           81.011781142 seconds
CPU2:
    cpu_time           132.633396527 seconds
    vcpu_time           12.782286092 seconds
CPU3:
    cpu_time            49.708745382 seconds
    vcpu_time           11.473885669 seconds
Total:
    cpu_time           459.456555720 seconds
    user_time            8.220000000 seconds
    system_time         17.180000000 seconds
```
 
vcpucount 查看虚拟机 vcpu 的配置数量
```
[root@192.168.118.14 ~]#virsh vcpucount centos
maximum      config         2
maximum      live           2
current      config         2
current      live           2
```

vcpuinfo 查看 vcpu 详细信息，vcpu0 运行在宿主机的 cpu0 上。
```
[root@192.168.118.14 ~]#virsh vcpuinfo cirros
VCPU:           0
CPU:            3
State:          running
CPU time:       8.1s
CPU Affinity:   yyyy
```

### 1.3.1 vcpu 亲和性绑定

使用 virsh vcpuinfo 命令查看实例 vcpu 和 物理 cpu 的对应关系
```
[root@192.168.118.11 ~]#virsh vcpuinfo cirros
VCPU:           0
CPU:            2
State:          running
CPU time:       3.5s
CPU Affinity:   yyyy

VCPU:           1
CPU:            3
State:          running
CPU time:       1.0s
CPU Affinity:   yyyy
```
- 可以发现， vcpu0 绑定到物理 cpu2 上， vcpu1 绑定到物理 cpu3 上。

使用 emulatorpin 命令可以查看虚拟机可以使用哪些物理逻辑 cpu
```
[root@192.168.118.11 ~]#virsh emulatorpin cirros
emulator: CPU Affinity
----------------------------------
       *: 0-3
```
- 宿主机本身有 4个 cpu。 意味着 cirros 虚拟机可以随意在这 4个cpu上切换。

 
在线绑定虚拟机 cpu

- 可以强制将虚拟机绑定到一个 cpu 区间。例如，将虚拟机 cirros 的 vcpu 绑定在 1-3 区间调度。
```
[root@192.168.118.11 ~]#virsh emulatorpin cirros 1-3
[root@192.168.118.11 ~]#virsh emulatorpin cirros
emulator: CPU Affinity
----------------------------------
       *: 1-3
```
这样，就绑定了虚拟机在 1-3 cpu 区间之类切换。

上面是为虚拟机设置一个物理 cpu 区间，如果要一对一绑定就需要使用 vcpupin
```
[root@192.168.118.11 ~]#virsh vcpuinfo cirros
VCPU:           0
CPU:            3
State:          running
CPU time:       3.6s
CPU Affinity:   yyyy

VCPU:           1
CPU:            2
State:          running
CPU time:       1.0s
CPU Affinity:   yyyy

# 将vcpu0 绑定到 cpu0
[root@192.168.118.11 ~]#virsh vcpupin cirros 0 0
# 将 vcpu1 绑定到 cpu1
[root@192.168.118.11 ~]#virsh vcpupin cirros 1 1
[root@192.168.118.11 ~]#virsh vcpuinfo cirros
VCPU:           0
CPU:            0
State:          running
CPU time:       3.6s
CPU Affinity:   y---

VCPU:           1
CPU:            1
State:          running
CPU time:       1.0s
CPU Affinity:   -y--
```
cpu 绑定技术原理：cpu绑定实际上是 Libvirt 通过 cgroup 来实现的，通过cgroup直接去绑定KVM 虚拟机进程。cgroup 不仅可以做 cpu 绑定，还可以限制虚拟机磁盘、网络资源控制。

cpu 绑定技术适用的应用场景：
- 系统的 CPU 压力较大
- 多核 cpu 压力不平衡，可以通过 cpu vcpupin 技术人工进行调配。

### 1.3.2 动态调配 vcpu 个数（可增大不可减少）

在 kvm 中可动态的调整 vcpu 的个数，简单理解就是，设置一个 vcpu 最大值，这个最大值肯定是要大于当前 vcpu 数量的，然后就可以在 当前 vcpu 数量和 设置的最大vcpu数量之间 动态的调整 vcpu 的个数，如下示例演示：

（1）在虚拟机关闭的情况下，调整 vcpu 最大支持的数目
```
[root@192.168.118.14 ~]#virsh list --all
Id    Name                           State
----------------------------------------------------
76    centos                         running
-     cirros                         shut off


# 查看未虚拟机 cirros 目前主机信息
[root@192.168.118.14 ~]#virsh dominfo cirros
Id:             -
Name:           cirros
UUID:           b7acba73-f70c-4c59-b144-cc20a7665ad4
OS Type:        hvm
State:          shut off
CPU(s):         1
Max memory:     1048576 KiB
Used memory:    0 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0

# 关机状态下修改虚拟机 cirros 最大支持的 vcpu 个数
[root@192.168.118.14 ~]#virsh setvcpus cirros --maximum 4 --config
```

（2）开机状态下动态的调整 vcpu 的数目
```
# 开启虚拟机
[root@192.168.118.14 ~]#virsh start cirros
Domain cirros started


# 查看开机 虚拟机 cirros 主机信息
[root@192.168.118.14 ~]#virsh dominfo cirros
Id:             89
Name:           cirros
UUID:           b7acba73-f70c-4c59-b144-cc20a7665ad4
OS Type:        hvm
State:          running
CPU(s):         1
CPU time:       8.0s
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0
Security label: system_u:system_r:svirt_t:s0:c123,c791 (permissive)


# 动态调整 vcpu 为 2
[root@192.168.118.14 ~]#virsh setvcpus cirros 2

# 查看调整 vcpu 是否成功
[root@192.168.118.14 ~]#virsh dominfo cirros
Id:             89
Name:           cirros
UUID:           b7acba73-f70c-4c59-b144-cc20a7665ad4
OS Type:        hvm
State:          running
CPU(s):         2
CPU time:       20.7s
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0
Security label: system_u:system_r:svirt_t:s0:c123,c791 (permissive)
```

## 1.4 虚拟机 内存 操作

### 1.4.1 虚拟机内存限制

memtune 查看或设置内存参数

作用：限制虚拟机在物理机host上申请内存的大小。
```
[root@192.168.118.14 ~]#virsh memtune centos
hard_limit     : unlimited
soft_limit     : unlimited
swap_hard_limit: unlimited
```
- hard_limit ：设置虚拟机可用物理内存最大值 （单位KB）
- soft_limit：设置虚拟机软限制最大上限（单位KB）
- swap_hard_limit：设置虚拟机 swap 分区硬上限（单位KB）

设置：
```
[root@192.168.118.14 ~]#virsh memtune centos --hard-limit 4G --config --live
[root@192.168.118.14 ~]#virsh memtune centos --swap-hard-limit 4G --config --live
[root@192.168.118.14 ~]#virsh memtune centos --soft-limit 2G --config --live
[root@192.168.118.14 ~]#virsh memtune centos
hard_limit     : 4194304
soft_limit     : 2097152
swap_hard_limit: 4194304
```
说明：
- --config 设置永久配置
- --live 设置当前启动状态配置

 

### 1.4.2 动态修改内存大小（可增大可减小）

动态修改内存和动态调配 vcpu 配置差不多，都是通过设置一个最大值，然后就可以设置的内存 大于等于当前内存了。

（1）关机状态下，修改虚拟机的最大内存数
```
[root@192.168.118.14 ~]#virsh list --all
Id    Name                           State
----------------------------------------------------
90    cirros                         running
-     centos                         shut off

[root@192.168.118.14 ~]#virsh dominfo centos
Id:             -
Name:           centos
UUID:           b149f8c5-f4b4-4d2d-a10d-81b8b13c68eb
OS Type:        hvm
State:          shut off
CPU(s):         1
Max memory:     1048576 KiB
Used memory:    0 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0

[root@192.168.118.14 ~]#virsh setmaxmem centos 10G --config
[root@192.168.118.14 ~]#virsh dominfo centos
Id:             -
Name:           centos
UUID:           b149f8c5-f4b4-4d2d-a10d-81b8b13c68eb
OS Type:        hvm
State:          shut off
CPU(s):         1
Max memory:     10485760 KiB
Used memory:    0 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0
```

（2）开启虚拟机，进行内存大小的调整
```
# 调整前，虚拟机内存大小：
[root@192.168.118.14 ~]free -h
              total        used        free      shared  buff/cache   available
Mem:           623M        107M        426M         16M         90M        376M
Swap:            0B          0B          0B

[root@192.168.118.14 ~]#virsh setmem centos 2G --config --live
[root@192.168.118.14 ~]#virsh dominfo centos
Id:             93
Name:           centos
UUID:           b149f8c5-f4b4-4d2d-a10d-81b8b13c68eb
OS Type:        hvm
State:          running
CPU(s):         1
CPU time:       92.1s
Max memory:     10485760 KiB
Used memory:    2097152 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0
Security label: system_u:system_r:svirt_t:s0:c645,c949 (permissive)

#调整后，虚拟机内存大小：
[root@192.168.118.14 ~]free -h
              total        used        free      shared  buff/cache   available
Mem:           1.6G        148M        1.3G         16M        121M        1.3G
Swap:            0B          0B          0B
```
内存动态调整完成。

 
## 1.5 虚拟机 磁盘 的操作

 

### 1.5.1 磁盘的新增和删除

磁盘的新增和删除有两种实现方式：
- （1）attach-device 和 detach-device
- （2）attach-disk 和 detach-disk

在新增或删除磁盘之前，通过 qemu-img 创建一个虚拟磁盘文件：
```
[root@192.168.118.14 ~]#qemu-img create -f qcow2 /images/share-device.qcow2 -o size=5G,preallocation=metadata
```

#### 第一种方式：

通过 attach-device 新增磁盘时，需要通过 xml 来添加。

编写 xml 文件，这里有个技巧：通过 virsh edit cirros 编辑 xml 文件，复制关于 disk 的部分进行修改，这样不容易出现报错。
```
[root@192.168.118.14 /images]#cat share-device.xml 
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2' cache='writeback' io='threads'/>
  <source file='/images/share-device.qcow2'/>
  <target dev='vdb' bus='virtio'/>
</disk>
```

通过 attach-device 将磁盘附加到虚拟机上
```
[root@192.168.118.14 /images]#virsh attach-device cirros /images/share-device.xml --config --live 
Device attached successfully
# 通过 domblklist 可查看虚拟机目前挂载的磁盘信息
[root@192.168.118.14 /images]#virsh domblklist cirros
Target     Source
------------------------------------------------
vda        /images/cirros-0.3.5-i386-disk.img
vdb        /images/share-device.qcow2
```

查看虚拟机磁盘：
```
# lsblk
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
vda     253:0    0  39.2M 0  disk
`-vda1  253:1    0  31.4M 0  part /
vdb     253:16   0     5G 0  disk
```

删除添加过的磁盘：
```
[root@192.168.118.14 /images]#virsh detach-device cirros /images/share-device.xml --config --live 
Device detached successfully
# 通过 domblklist 可查看虚拟机目前挂载的磁盘信息
[root@192.168.118.14 /images]#virsh domblklist cirros
Target     Source
------------------------------------------------
vda        /images/cirros-0.3.5-i386-disk.img
```

查看虚拟机磁盘：
```
# lsblk
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
vda     253:0    0  39.2M 0  disk
`-vda1  253:1    0  31.4M 0  part /
```
删除成功。

 

注意：使用 attach-device 和 detach-device 时，文件的指向是 xml 文件，而不是虚拟磁盘文件。

 

#### 第二种方式：

通过 attach-disk 新增磁盘时，需要通过 虚拟磁盘文件 来添加。


添加虚拟磁盘：
```
[root@192.168.118.14 /images]#virsh attach-disk cirros /images/share-device.qcow2 vdb --live --config 
Disk attached successfully
```

删除虚拟磁盘：
```
[root@192.168.118.14 /images]#virsh detach-disk cirros /images/share-device.qcow2  --live --config
Disk detached successfully
```
 
## 1.6 虚拟机 网卡 的操作

主要操作命令：
- domiflist ： 查看虚拟机中所有的网卡设备
- attach-interface： 为虚拟机添加网卡设备
- detach-interface：删除虚拟机网卡设备

示例演示：

（1）查看虚拟机所有网络设备：
```
[root@192.168.118.14 /images]#virsh domiflist cirros
Interface  Type       Source     Model       MAC
-------------------------------------------------------
vnet0      network    default    rtl8139     52:54:00:c6:aa:b7
```

（2）为虚拟机再添加一张网卡：
```
[root@192.168.118.14 /images]#virsh attach-interface cirros --type bridge --source virbr0 --live --config
Interface attached successfully

[root@192.168.118.14 /images]#virsh domiflist cirros
Interface  Type       Source     Model       MAC
-------------------------------------------------------
vnet0      network    default    rtl8139     52:54:00:c6:aa:b7
vnet1      bridge     virbr0     rtl8139     52:54:00:de:6d:04
```
网卡添加成功。

（3）删除网络设备：
```
[root@192.168.118.14 ~]#virsh detach-interface cirros --type bridge --mac 52:54:00:e0:2c:44 --live --config
Interface detached successfully

[root@192.168.118.14 ~]#virsh domiflist cirros
Interface  Type       Source     Model       MAC
-------------------------------------------------------
vnet0      network    default    rtl8139     52:54:00:c6:aa:b7
```

## 1.7 虚拟机 其他 的一些操作

### 1.7.1 autostart

autostart ：设置物理机开机启动虚拟机

查看方式：
```
[root@192.168.118.14 ~]#virsh dominfo cirros
Id:             96
Name:           cirros
UUID:           3748ef4e-1c84-4f28-9a4b-53ad22310bfd
OS Type:        hvm
State:          running
CPU(s):         1
CPU time:       25.1s
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0
Security label: system_u:system_r:svirt_t:s0:c184,c860 (permissive)
```
其中 autostart 选项就是是否开机启动。disable 否，enable 是

设置：
```
[root@192.168.118.14 ~]#virsh autostart cirros # 设置开机启动
[root@192.168.118.14 ~]#virsh autostart cirros --disable # 关闭开机启动
```

### 1.7.2 domdisplay

显示虚拟机连接的 URI
```
[root@192.168.118.14 ~]#virsh domdisplay centos
vnc://127.0.0.1:0
```

### 1.7.3 dumpxml

导出虚拟机的 xml 文件
```
[root@192.168.118.14 ~]#virsh dumpxml centos > centos.xml
```
 
# 2. 虚拟机 监控 操作
```
domblkerror                  在块设备上显示错误
domblkinfo                   域块设备大小信息
domblklist                   列出所有的域块
domblkstat                   获取域的设备块统计信息
domcontrol                   域控制接口状态
domif-getlink                获取虚拟接口的链接状态
domifaddr                    获取正在运行的域的网络接口地址
domiflist                    列出所有的域虚拟接口
domifstat                    获取域的网络接口统计信息
dominfo                      域信息
dommemstat                   获取域的内存统计信息
domstate                     域状态
domstats                     获取有关一个或多个域的统计信息
domtime                      域时间
list                         列出域名

Domain Monitoring（帮助关键字'monitor'）
```

## 命令使用详解：

domblkerror：查看虚拟机磁盘块错误信息
```
[root@192.168.118.14 ~]#virsh domblkerror centos
No errors found
```
 

domblklist：查看虚拟机磁盘信息及位置
```
[root@192.168.118.14 ~]#virsh domblklist centos
Target     Source
------------------------------------------------
vda        /images/CentOS-7-x86_64-GenericCloud-1511.qcow2
```

domblkstat：查看磁盘 I/O 等信息
```
[root@192.168.118.14 ~]#virsh domblkstat centos
 rd_req 5476
 rd_bytes 119216128
 wr_req 2271
 wr_bytes 3498496
 flush_operations 50
 rd_total_times 1649970675
 wr_total_times 2319258979
 flush_total_times 627588120
```

domcontrol：查看虚拟机接口信息
```
[root@192.168.118.14 ~]#virsh domcontrol centos
ok
```

domif-getlink：查看虚拟机某一个虚拟接口的状态
```
[root@192.168.118.14 ~]#virsh domif-getlink centos vnet0
vnet0 up
```

domifaddr：查看虚拟机网卡信息
```
[root@192.168.118.14 ~]#virsh domifaddr centos
 Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
 vnet0      52:54:00:cb:f1:75    ipv4         192.168.122.40/24
```

domiflist：查看网卡详细信息
```
[root@192.168.118.14 ~]#virsh domiflist centos
Interface  Type       Source     Model       MAC
-------------------------------------------------------
vnet0      network    default    rtl8139     52:54:00:cb:f1:75
```

domifstat：查看虚拟机网卡流量详细信息
```
[root@192.168.118.14 ~]#virsh domifstat centos vnet0
vnet0 rx_bytes 49615
vnet0 rx_packets 789
vnet0 rx_errs 0
vnet0 rx_drop 0
vnet0 tx_bytes 19422
vnet0 tx_packets 239
vnet0 tx_errs 0
vnet0 tx_drop 0
```

dominfo：查看虚拟机的详细信息
```
[root@192.168.118.14 ~]#virsh dominfo centos
Id:             98
Name:           centos
UUID:           35abdeb1-ef6d-41b4-9c4c-61e3a660c666
OS Type:        hvm
State:          running
CPU(s):         1
CPU time:       114.0s
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0
Security label: system_u:system_r:svirt_t:s0:c555,c926 (permissive)
```

dommemstat：查看内存状态
```
[root@192.168.118.14 ~]#virsh dommemstat centos
actual 1048576
swap_in 3733319892074496
rss 404032
```

domstate：查看虚拟机状态
```
[root@192.168.118.14 ~]#virsh domstate centos
running
```

domstats：查看虚拟机状态参数
```
[root@192.168.118.14 ~]#virsh domstats centos
Domain: 'centos'
  state.state=1
  state.reason=1
  cpu.time=118798719298
  cpu.user=7620000000
  cpu.system=11920000000
  balloon.current=1048576
  …
```
 

 
# 3. 宿主机及 Hypervisor 信息
```
allocpages                   操纵页面池大小
capabilities                 功能
cpu-models                   CPU型号
domcapabilities              域功能
freecell                     NUMA可用内存
freepages                    NUMA免费网页
hostname                     打印管理程序主机名
maxvcpus                     连接vcpu最大
node-memory-tune             获取或设置节点内存参数
nodecpumap                   节点cpu映射
nodecpustats                 打印节点的cpu统计信息。
nodeinfo                     节点信息
nodememstats                 打印节点的内存统计信息。
nodesuspend                  暂停主机节点一段给定的时间
sysinfo                      打印管理程序sysinfo
uri                          打印管理程序规范的URI
version                      显示版本

Host and Hypervisor（帮助关键字'host'）
```

## 主要常用的几个选项：

hostname：查看宿主机名
```
[root@192.168.118.14 ~]#virsh hostname
kvm-test
```

maxvcpus：查看宿主机 vcpu 使用的最大值
```
[root@192.168.118.14 ~]#virsh maxvcpus
16
```

nodeinfo：查看宿主机信息
```
[root@192.168.118.14 ~]#virsh nodeinfo
CPU model:           x86_64
CPU(s):              4
CPU frequency:       2397 MHz
CPU socket(s):       4
Core(s) per socket:  1
Thread(s) per core:  1
NUMA cell(s):        1
Memory size:         8010940 KiB
```

sysinfo：查看宿主机系统参数信息
```
[root@192.168.118.14 ~]#virsh sysinfo
<sysinfo type='smbios'>
  <bios>
    <entry name='vendor'>Seabios</entry>
    <entry name='version'>0.5.1</entry>
    <entry name='date'>01/01/2011</entry>
    <entry name='release'>1.0</entry>
  </bios>
... ...
```

uri：查看连接宿主机的 uri
```
[root@192.168.118.14 ~]#virsh uri 
qemu:///system
```

version：查看宿主机安装libvirt QEMU 的版本信息
```
[root@192.168.118.14 ~]#virsh version
Compiled against library: libvirt 1.2.17
Using library: libvirt 1.2.17
Using API: QEMU 1.2.17
Running hypervisor: QEMU 1.5.3
```

# 4. interface 相关的选项
```
iface-begin                  创建当前接口设置的快照，可以稍后提交（iface-commit）或恢复（iface-rollback）
iface-bridge                 创建一个桥接设备并将一个现有的网络设备连接到它
iface-commit                 提交自iface-开始和自由恢复点以来所做的更改
iface-define                 定义不活动的持久物理主机接口或从XML文件修改现有的持久物理主机接口
iface-destroy                销毁一个物理主机接口（禁用它/“if-down”）
iface-dumpxml                接口信息在XML中
iface-edit                   编辑物理主机接口的XML配置
iface-list                   列出物理主机接口
iface-mac                    将接口名称转换为接口MAC地址
iface-name                   将接口MAC地址转换为接口名称
iface-rollback               回滚到通过iface-begin创建的先前保存的配置
iface-start                  启动一个物理主机接口（启用/“if-up”）
iface-unbridge               取消其从属设备后取消定义桥接设备
iface-undefine               取消定义物理主机接口（将其从配置中移除）

Interface（帮助关键字'interface'）
```

## 4.1 iface-bridge 和 iface-unbridge

- iface-bridge 创建网桥
- iface-unbridge 删除网桥

注意：在使用 iface-bridge 创建网桥之前，请将 NetworkManager 服务关闭，否则会造成创建完网桥之后，网络断开的情况。
```
# 查看网桥设备
[root@localhost ~]# brctl show
bridge name	bridge id		STP enabled	interfaces

# 关闭 NetworkManager 服务
[root@localhost ~]# systemctl stop NetworkManager ; systemctl disable NetworkManager 
Removed symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service.
Removed symlink /etc/systemd/system/dbus-org.freedesktop.NetworkManager.service.
Removed symlink /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service.

# 创建网桥
[root@localhost ~]# virsh iface-bridge eno16777736 br0
Created bridge br0 with attached device eno16777736
Bridge interface br0 started

# 查看创建的网桥信息
[root@localhost ~]# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.000c293178be	yes		eno16777736

[root@localhost ~]# ifconfig 
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.118.11  netmask 255.255.255.0  broadcast 192.168.118.255
        inet6 fe80::20c:29ff:fe31:78be  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:31:78:be  txqueuelen 0  (Ethernet)
        RX packets 121  bytes 16478 (16.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 66  bytes 7360 (7.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eno16777736: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 00:0c:29:31:78:be  txqueuelen 1000  (Ethernet)
        RX packets 2533  bytes 573618 (560.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1673  bytes 643967 (628.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 0  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

通过上面可以看到，物理网卡 eno16777736 的ip地址已经在 br0上生效了，而 物理网卡已经作为一个桥接设备。
```
[root@localhost ~]# cd /etc/sysconfig/network-scripts/
[root@localhost network-scripts]# ls ifcfg-*
ifcfg-br0  ifcfg-eno16777736  ifcfg-lo
```
查看配置文件，iface-bridge 是直接将配置文件也改写了，也就是说，通过 iface-bridge 创建的桥接，重启依然生效。

iface-unbridge 删除网桥的使用：
```
[root@localhost ~]# virsh iface-unbridge br0
Device eno16777736 un-attached from bridge br0
Interface eno16777736 started

[root@localhost ~]# brctl show
bridge name	bridge id		STP enabled	interfaces

[root@localhost ~]# virsh iface-list --all
 Name                 State      MAC Address
---------------------------------------------------
 eno16777736          active     00:0c:29:31:78:be
 lo                   active     00:00:00:00:00:00
```
网桥 br0 删除成功。

 
## 4.2 iface-list 查看宿主机所有的 interface接口
```
[root@localhost ~]# virsh iface-list --all
 Name                 State      MAC Address
---------------------------------------------------
 br0                  active     00:0c:29:31:78:be
 lo                   active     00:00:00:00:00:00
```

## 4.3 iface-edit 编辑宿主机现有的 interface
```
[root@localhost ~]# virsh iface-edit br0

<interface type='bridge' name='br0'>
  <start mode='onboot'/>
  <protocol family='ipv4'>
    <ip address='192.168.118.11' prefix='24'/>
    <route gateway='192.168.118.1'/>
  </protocol>
  <bridge stp='on' delay='0'>
    <interface type='ethernet' name='eno16777736'>
    </interface>
  </bridge>
</interface>
```

## 4.4 iface-dumpxml 导出宿主机现有的 interface 为 xml 文件
```
# 查看
[root@localhost ~]# virsh iface-dumpxml br0
<interface type='bridge' name='br0'>
  <protocol family='ipv4'>
    <ip address='192.168.118.11' prefix='24'/>
  </protocol>
  <protocol family='ipv6'>
    <ip address='fe80::20c:29ff:fe31:78be' prefix='64'/>
  </protocol>
  <bridge>
    <interface type='ethernet' name='vnet0'>
      <link state='unknown'/>
      <mac address='fe:54:00:9c:b2:32'/>
    </interface>
    <interface type='ethernet' name='eno16777736'>
      <link speed='1000' state='up'/>
      <mac address='00:0c:29:31:78:be'/>
    </interface>
  </bridge>
</interface>

# 导入到 xml 文件
[root@localhost ~]# virsh iface-dumpxml br0 > br0.xml
```

## 4.5 iface-destroy 和 iface-start

- iface-destroy 将 interface 设置为 不活动状态
- iface-start 将 interface 设置为 活动状态
```
[root@localhost ~]# virsh iface-list --all
 Name                 State      MAC Address
---------------------------------------------------
 br0                  active     00:0c:29:53:fa:87
 lo                   active     00:00:00:00:00:00

[root@localhost ~]# virsh iface-destroy lo 
Interface lo destroyed

[root@localhost ~]# virsh iface-list --all
 Name                 State      MAC Address
---------------------------------------------------
 br0                  active     00:0c:29:53:fa:87
 lo                   inactive   00:00:00:00:00:00
```
- iface-destroy 不可轻易使用，会造成虚拟机或宿主机网络失联。

iface-start 的使用：
```
[root@localhost ~]# virsh iface-start lo
Interface lo started

[root@localhost ~]# virsh iface-list --all
 Name                 State      MAC Address
---------------------------------------------------
 br0                  active     00:0c:29:31:78:be
 lo                   active     00:00:00:00:00:00
```

## 4.6 iface-mac 获取 接口的 mac 地址
```
[root@localhost ~]# virsh iface-mac lo
00:00:00:00:00:00

[root@localhost ~]# virsh iface-mac br0
00:0c:29:53:fa:87
```
 
## 4.7 iface-name 通过 mac 地址获取 接口名称
```
[root@localhost ~]# virsh iface-name 00:0c:29:53:fa:87
br0

[root@localhost ~]# virsh iface-name 00:00:00:00:00:00
lo
```
 
# 5. 网络相关的选项
```
net-autostart                自动启动一个网络
net-create                   从XML文件创建一个网络
net-define                   定义不活动的永久虚拟网络或从XML文件修改现有的永久虚拟网络
net-destroy                  摧毁（停止）一个网络
net-dhcp-leases              打印给定网络的租赁信息
net-dumpxml                  XML中的网络信息
net-edit                     编辑网络的XML配置
net-event                    网络事件
net-info                     网络信息
net-list                     列表网络
net-name                     将网络UUID转换为网络名称
net-start                    启动一个（以前定义的）不活动的网络
net-undefine                 取消定义一个持久的网络
net-update                   更新现有网络配置的一部分
net-uuid                     将网络名称转换为网络UUID

Networking（帮助关键字'network'）
```

注意： virsh network 选项内容管理对应的文件是 /etc/libvirt/qemu/network/ 如果这里没有关于网络的xml 文件，则通过 virsh net-list -all 是查询不到网络的。

对于上面实例通过 virsh iface-bridge eno16777736 br0 这样创建的网桥，通过 virsh net-list 是查询不到的。

当使用 yum install libvirt 安装不做任何修改进行启动，通过 virsh net-list 查看：
```
[root@localhost ~]# virsh net-list 
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes
```
这里的 default 对应的文件是 /etc/libvirt/qemu/networks/default.xml

 
network选项中，重点掌握一下：
```
net-destroy 	停止网络
net-start 	启用网络
net-dumpxml 	查看网络配置文件 同等于 cat /etc/libvirt/qemu/networks/default.xml
net-edit 	编辑网络配置文件 同等于 vim /etc/libvirt/qemu/networks/default.xml
net-create 	通过 xml 文件创建网络，一般很少使用。
net-info 	查看网络详细信息
net-autostart 	宿主机开启自动启动
```
 
# 6. 快照相关的选项
```
snapshot-create              从XML创建一个快照
snapshot-create-as           从一组参数创建一个快照
snapshot-current             获取或设置当前快照
snapshot-delete              删除域快照
snapshot-dumpxml             转储域快照的XML
snapshot-edit                编辑快照的XML
snapshot-info                快照信息
snapshot-list                列出域的快照
snapshot-parent              获取快照的父级的名称
snapshot-revert              将域恢复为快照

Snapshot（帮助关键字'snapshot'）
```

重点掌握如下选项：
```
snapshot-list 	查看某domain的快照
snapshot-info 	查看快照详细信息
snapshot-dumpxml  查看快照xml文件
snapshot-edit 	编辑快照信息
snapshot-create 	创建一个 xml 格式的快照
snapshot-create-as 	创建一个 xml 格式的快照，但是可以命名快照名
snapshot-revert 	将虚拟机还原到快照信息
```
 
## 6.1 snapshot-create 和 snapshot-create-as

这两个命令创建快照其内部运行机制是一致的，只不过 snapshot-create-as 可以为快照命名，如下：
```
[root@localhost ~]# virsh list 
 Id    Name                           State
----------------------------------------------------
 2     cirros                         running

[root@localhost ~]# virsh snapshot-create cirros 
Domain snapshot 1563634518 created
[root@localhost ~]# virsh snapshot-list cirros
 Name                 Creation Time             State
------------------------------------------------------------
 1563634518           2019-07-20 22:55:18 +0800 running

[root@localhost ~]# virsh snapshot-create-as cirros cirros_bak
Domain snapshot cirros_bak created
[root@localhost ~]# virsh snapshot-list  cirros
 Name                 Creation Time             State
------------------------------------------------------------
 1563634518           2019-07-20 22:55:18 +0800 running
 cirros_bak           2019-07-20 22:55:45 +0800 running
```
可以发现，通过 snapshot-create 创建的快照 Name 为时间戳，而通过 snapshot-create-as 创建的快照则可以自行命名。
 
## 6.2 snapshot-revert 还原快照
```
[root@localhost ~]# virsh snapshot-list cirros
 Name                 Creation Time             State
------------------------------------------------------------
 1563634518           2019-07-20 22:55:18 +0800 running
 cirros_bak           2019-07-20 22:55:45 +0800 running

[root@localhost ~]# virsh snapshot-revert cirros cirros_bak

[root@localhost ~]# virsh list 
 Id    Name                           State
----------------------------------------------------
 2     cirros                         running
```
 
7. 虚拟机存储池操作
```
find-storage-pool-sources-as 找到潜在的存储池来源
find-storage-pool-sources    发现潜在的存储池来源
pool-autostart               自动启动一个池
pool-build                   建立一个存储池
pool-create-as               从一组参数创建一个池
pool-create                  从XML文件创建一个池
pool-define-as               从一组参数中定义一个池
pool-define                  定义不活动的持久性存储池或从XML文件修改现有的持久  性存储池
pool-delete                  删除一个池
pool-destroy                 摧毁（停止）一个存储池
pool-dumpxml                 XML中的池信息
pool-edit                    编辑存储池的XML配置
pool-info                    存储池信息
pool-list                    列表池
pool-name                    将池UUID转换为池名称
pool-refresh                 刷新存储池
pool-start                   启动（之前定义的）非活动池
pool-undefine                取消定义一个不活动的池
pool-uuid                    将池名称转换为池UUID
pool-event                   存储池事件

Storage Pool（帮助关键词'pool'）
```

kvm 平台以存储池的形式对存储进行统一管理，所谓存储池可以理解为本地目录，通过远端磁盘阵列（ISCSI、NFS）分配过来磁盘或目录，当然也支持各类分布式文件系统。

为虚拟机创建存储池的两种方式：

 
## 7.1 通过 xml 文件创建

通过 pool-list --all 查看所有的 存储池， 默认为有一个 default 存储池
```
[root@192.168.118.14 ~]#virsh pool-list --all
 Name                 State      Autostart 
-------------------------------------------
 default              active     yes    
```

通过 pool-dumpxml 将 default 存储池导入出来进行修改
```
[root@192.168.118.14 ~]#virsh pool-dumpxml default > images.xml

修改如下：
[root@192.168.118.14 ~]#cat images.xml 
<pool type='dir'>
  <name>images</name>
  <source>
  </source>
  <target>
    <path>/images</path>
    <permissions>
      <mode>0711</mode>
      <owner>0</owner>
      <group>0</group>
    </permissions>
  </target>
</pool>

/images 目录必须存在。

通过 pool-define 导出存储池
[root@192.168.118.14 ~]#virsh pool-define images.xml 
Pool images defined from images.xml

[root@192.168.118.14 ~]#virsh pool-list --all
 Name                 State      Autostart 
-------------------------------------------
 default              active     yes       
 images               inactive   no        

启用 images 存储池
[root@192.168.118.14 ~]#virsh pool-start images
Pool images started

开机启用 images 存储池
[root@192.168.118.14 ~]#virsh pool-autostart images
Pool images marked as autostarted

[root@192.168.118.14 ~]#virsh pool-list --all
 Name                 State      Autostart 
-------------------------------------------
 default              active     yes       
 images               active     yes
```
 
## 7.2 通过命令创建存储池
```
[root@192.168.118.14 ~]#mkdir /img
[root@192.168.118.14 ~]#virsh pool-define-as img --type dir --target /img/
[root@192.168.118.14 ~]#virsh pool-build img
[root@192.168.118.14 ~]#virsh pool-start img
[root@192.168.118.14 ~]#virsh pool-autostart img
```
 
## 7.3 删除存储池
```
[root@192.168.118.14 ~]#virsh pool-list --all
 Name                 State      Autostart 
-------------------------------------------
 default              active     yes       
 images               active     yes       

[root@192.168.118.14 ~]#virsh pool-destroy images
Pool images destroyed
      
[root@192.168.118.14 ~]#virsh pool-undefine images
Pool images has been undefined

[root@192.168.118.14 ~]#virsh pool-list --all
 Name                 State      Autostart 
-------------------------------------------
 default              active     yes
```
