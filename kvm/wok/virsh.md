# 一、virsh help
```
分组的命令：
域管理（虚拟机实例管理）
 Domain Management (help keyword 'domain'):
    attach-device                  从一个XML文件附加装置
    attach-disk                    附加磁盘设备
    attach-interface               获得网络界面
    autostart                      自动开始一个域
    blkdeviotune                   设定或者查询块设备 I/O 调节参数。
    blkiotune                      获取或者数值 blkio 参数
    blockcommit                    启动块提交操作。
    blockcopy                      启动块复制操作。
    blockjob                       管理活跃块操作
    blockpull                      使用其后端映像填充磁盘。
    blockresize                    创新定义域块设备大小
    change-media                   更改 CD 介质或者软盘驱动器
    console                        连接到客户会话
    cpu-stats                      显示域 cpu 统计数据
    create                         从一个 XML 文件创建一个域
    define                         从一个 XML 文件定义（但不开始）一个域
    desc                           显示或者设定域描述或者标题
    destroy                        销毁（停止）域
    detach-device                  从一个 XML 文件分离设备
    detach-device-alias            detach device from an alias
    detach-disk                    分离磁盘设备
    detach-interface               分离网络界面
    domdisplay                     域显示连接 URI
    domfsfreeze                    Freeze domain's mounted filesystems.
    domfsthaw                      Thaw domain's mounted filesystems.
    domfsinfo                      Get information of domain's mounted filesystems.
    domfstrim                      在域挂载的文件系统中调用 fstrim。
    domhostname                    输出域主机名
    domid                          把一个域名或 UUID 转换为域 id
    domif-setlink                  设定虚拟接口的链接状态
    domiftune                      获取/设定虚拟接口参数
    domjobabort                    忽略活跃域任务
    domjobinfo                     域任务信息
    domname                        将域 id 或 UUID 转换为域名
    domrename                      rename a domain
    dompmsuspend                   使用电源管理功能挂起域
    dompmwakeup                    从 pmsuspended 状态唤醒域
    domuuid                        把一个域名或 id 转换为域 UUID
    domxml-from-native             将原始配置转换为域 XML
    domxml-to-native               将域 XML 转换为原始配置
    dump                           把一个域的内核 dump 到一个文件中以方便分析
    dumpxml                        XML 中的域信息
    edit                           编辑某个域的 XML 配置
    event                          Domain Events
    inject-nmi                     在虚拟机中输入 NMI
    iothreadinfo                   view domain IOThreads
    iothreadpin                    control domain IOThread affinity
    iothreadadd                    add an IOThread to the guest domain
    iothreaddel                    delete an IOThread from the guest domain
    send-key                       向虚拟机发送序列号
    send-process-signal            向进程发送信号
    lxc-enter-namespace            LXC 虚拟机进入名称空间
    managedsave                    管理域状态的保存
    managedsave-remove             删除域的管理保存
    managedsave-edit               edit XML for a domain's managed save state file
    managedsave-dumpxml            Domain information of managed save state file in XML
    managedsave-define             redefine the XML for a domain's managed save state file
    memtune                        获取或者数值内存参数
    perf                           Get or set perf event
    metadata                       show or set domain's custom XML metadata
    migrate                        将域迁移到另一个主机中
    migrate-setmaxdowntime         设定最大可耐受故障时间
    migrate-getmaxdowntime         get maximum tolerable downtime
    migrate-compcache              获取/设定压缩缓存大小
    migrate-setspeed               设定迁移带宽的最大值
    migrate-getspeed               获取最长迁移带宽
    migrate-postcopy               Switch running migration from pre-copy to post-copy
    numatune                       获取或者数值 numa 参数
    qemu-attach                    QEMU 附加
    qemu-monitor-command           QEMU 监控程序命令
    qemu-monitor-event             QEMU Monitor Events
    qemu-agent-command             QEMU 虚拟机代理命令
    reboot                         重新启动一个域
    reset                          重新设定域
    restore                        从一个存在一个文件中的状态恢复一个域
    resume                         重新恢复一个域
    save                           把一个域的状态保存到一个文件
    save-image-define              为域的保存状态文件重新定义 XML
    save-image-dumpxml             在 XML 中保存状态域信息
    save-image-edit                为域保存状态文件编辑 XML
    schedinfo                      显示/设置日程安排变量
    screenshot                     提取当前域控制台快照并保存到文件中
    set-lifecycle-action           change lifecycle actions
    set-user-password              set the user password inside the domain
    setmaxmem                      改变最大内存限制值
    setmem                         改变内存的分配
    setvcpus                       改变虚拟 CPU 的号
    shutdown                       关闭一个域
    start                          开始一个（以前定义的）非活跃的域
    suspend                        挂起一个域
    ttyconsole                     tty 控制台
    undefine                       取消定义一个域
    update-device                  从 XML 文件中关系设备
    vcpucount                      域 vcpu 计数
    vcpuinfo                       详细的域 vcpu 信息
    vcpupin                        控制或者查询域 vcpu 亲和性
    emulatorpin                    控制火车查询域模拟器亲和性
    vncdisplay                     vnc 显示
    guestvcpus                     query or modify state of vcpu in the guest (via agent)
    setvcpu                        attach/detach vcpu or groups of threads
    domblkthreshold                set the threshold for block-threshold event for a given block device or it's backing chain element

#监控虚拟机资源使用情况
 Domain Monitoring (help keyword 'monitor'):
    domblkerror                    在块设备中显示错误
    domblkinfo                     域块设备大小信息
    domblklist                     列出所有域块
    domblkstat                     获得域设备块状态
    domcontrol                     域控制接口状态
    domif-getlink                  获取虚拟接口链接状态
    domifaddr                      Get network interfaces' addresses for a running domain
    domiflist                      列出所有域虚拟接口
    domifstat                      获得域网络接口状态
    dominfo                        域信息
    dommemstat                     获取域的内存统计
    domstate                       域状态
    domstats                       get statistics about one or multiple domains
    domtime                        domain time
    list                           列出域

#当前宿主机的状态的
 Host and Hypervisor (help keyword 'host'):
    allocpages                     Manipulate pages pool size
    capabilities                   性能
    cpu-baseline                   计算基线 CPU
    cpu-compare                    使用 XML 文件中描述的 CPU 与主机 CPU 进行对比
    cpu-models                     CPU models
    domcapabilities                domain capabilities
    freecell                       NUMA可用内存
    freepages                      NUMA free pages
    hostname                       打印管理程序主机名
    hypervisor-cpu-baseline        compute baseline CPU usable by a specific hypervisor
    hypervisor-cpu-compare         compare a CPU with the CPU created by a hypervisor on the host
    maxvcpus                       连接 vcpu 最大值
    node-memory-tune               获取或者设定节点内存参数
    nodecpumap                     节点 cpu 映射
    nodecpustats                   输出节点的 cpu 状统计数据。
    nodeinfo                       节点信息
    nodememstats                   输出节点的内存状统计数据。
    nodesuspend                    在给定时间段挂起主机节点
    sysinfo                        输出 hypervisor sysinfo
    uri                            打印管理程序典型的URI
    version                        显示版本

#管理网络接口的命令
 Interface (help keyword 'interface'):
    iface-begin                    生成当前接口设置快照，可在今后用于提交 (iface-commit) 或者恢复 (iface-rollback)
    iface-bridge                   生成桥接设备并为其附加一个现有网络设备
    iface-commit                   提交 iface-begin 后的更改并释放恢复点
    iface-define                   define an inactive persistent physical host interface or modify an existing persistent one from an XML file
    iface-destroy                  删除物理主机接口（启用它请执行 "if-down"）
    iface-dumpxml                  XML 中的接口信息
    iface-edit                     为物理主机界面编辑 XML 配置
    iface-list                     物理主机接口列表
    iface-mac                      将接口名称转换为接口 MAC 地址
    iface-name                     将接口 MAC 地址转换为接口名称
    iface-rollback                 恢复到之前保存的使用 iface-begin 生成的更改
    iface-start                    启动物理主机接口（启用它请执行 "if-up"）
    iface-unbridge                 分离其辅助设备后取消定义桥接设备
    iface-undefine                 取消定义物理主机接口（从配置中删除）

管理网络规则的
 Network Filter (help keyword 'filter'):
    nwfilter-define                使用 XML 文件定义或者更新网络过滤器
    nwfilter-dumpxml               XML 中的网络过滤器信息
    nwfilter-edit                  为网络过滤器编辑 XML 配置
    nwfilter-list                  列出网络过滤器
    nwfilter-undefine              取消定义网络过滤器
    nwfilter-binding-create        create a network filter binding from an XML file
    nwfilter-binding-delete        delete a network filter binding
    nwfilter-binding-dumpxml       XML 中的网络过滤器信息
    nwfilter-binding-list          list network filter bindings

管理网络的
 Networking (help keyword 'network'):
    net-autostart                  自动开始网络
    net-create                     从一个 XML 文件创建一个网络
    net-define                     define an inactive persistent virtual network or modify an existing persistent one from an XML file
    net-destroy                    销毁（停止）网络
    net-dhcp-leases                print lease info for a given network
    net-dumpxml                    XML 中的网络信息
    net-edit                       为网络编辑 XML 配置
    net-event                      Network Events
    net-info                       网络信息
    net-list                       列出网络
    net-name                       把一个网络UUID 转换为网络名
    net-start                      开始一个(以前定义的)不活跃的网络
    net-undefine                   undefine a persistent network
    net-update                     更新现有网络配置的部分
    net-uuid                       把一个网络名转换为网络UUID

管理节点上上的设备的
 Node Device (help keyword 'nodedev'):
    nodedev-create                 根据节点中的 XML 文件定义生成设备
    nodedev-destroy                销毁（停止）节点中的设备
    nodedev-detach                 将节点设备与其设备驱动程序分离
    nodedev-dumpxml                XML 中的节点设备详情
    nodedev-list                   这台主机中中的枚举设备
    nodedev-reattach               重新将节点设备附加到他的设备驱动程序中
    nodedev-reset                  重置节点设备
    nodedev-event                  Node Device Events

管理虚拟机上认证信息的
 Secret (help keyword 'secret'):
    secret-define                  定义或者修改 XML 中的 secret
    secret-dumpxml                 XML 中的 secret 属性
    secret-event                   Secret Events
    secret-get-value               secret 值输出
    secret-list                    列出 secret
    secret-set-value               设定 secret 值
    secret-undefine                取消定义 secret

管理快照的命令
 Snapshot (help keyword 'snapshot'):
    snapshot-create                使用 XML 生成快照
    snapshot-create-as             使用一组参数生成快照
    snapshot-current               获取或者设定当前快照
    snapshot-delete                删除域快照
    snapshot-dumpxml               为域快照转储 XML
    snapshot-edit                  编辑快照 XML
    snapshot-info                  快照信息
    snapshot-list                  为域列出快照
    snapshot-parent                获取快照的上级快照名称
    snapshot-revert                将域转换为快照

存储池的设备
 Storage Pool (help keyword 'pool'):
    find-storage-pool-sources-as   找到潜在存储池源
    find-storage-pool-sources      发现潜在存储池源
    pool-autostart                 自动启动某个池
    pool-build                     建立池
    pool-create-as                 从一组变量中创建一个池
    pool-create                    从一个 XML 文件中创建一个池
    pool-define-as                 在一组变量中定义池
    pool-define                    define an inactive persistent storage pool or modify an existing persistent one from an XML file
    pool-delete                    删除池
    pool-destroy                   销毁（删除）池
    pool-dumpxml                   XML 中的池信息
    pool-edit                      为存储池编辑 XML 配置
    pool-info                      存储池信息
    pool-list                      列出池
    pool-name                      将池 UUID 转换为池名称
    pool-refresh                   刷新池
    pool-start                     启动一个（以前定义的）非活跃的池
    pool-undefine                  取消定义一个不活跃的池
    pool-uuid                      把一个池名称转换为池 UUID
    pool-event                     Storage Pool Events

存储卷的命令
 Storage Volume (help keyword 'volume'):
    vol-clone                      克隆卷。
    vol-create-as                  从一组变量中创建卷
    vol-create                     从一个 XML 文件创建一个卷
    vol-create-from                生成卷，使用另一个卷作为输入。
    vol-delete                     删除卷
    vol-download                   将卷内容下载到文件中
    vol-dumpxml                    XML 中的卷信息
    vol-info                       存储卷信息
    vol-key                        为给定密钥或者路径返回卷密钥
    vol-list                       列出卷
    vol-name                       为给定密钥或者路径返回卷名
    vol-path                       为给定密钥或者路径返回卷路径
    vol-pool                       为给定密钥或者路径返回存储池
    vol-resize                     创新定义卷大小
    vol-upload                     将文件内容上传到卷中
    vol-wipe                       擦除卷

管理自身的virsh命令
 Virsh itself (help keyword 'virsh'):
    cd                             更改当前目录
    echo                           echo 参数
    exit                           退出这个非交互式终端
    help                           打印帮助
    pwd                            输出当前目录
    quit                           退出这个非交互式终端
    connect                        连接（重新连接）到 hypervisor
```

# 二、安装

1、检查是否支持虚拟化
```
egrep '(svm|vmx)' /proc/cpuinfo
```

2、安装
```
yum install qemu-kvm libvirt virt-manager
```

3、验证
```
lsmod|grep kvm
```

4、开启图形
```
vim /etc/libvirt/qemu.conf
user="root"
group="root"
vnc_listen="0.0.0.0"
vnc_password="12345"
```

```
systemctl start libvirtd
systemctl enable libvirtd
virt-manager
```

# 三、常用命令

1、查看虚拟主机 (获取当前节点上所有域(VM)的列表)
```
virsh list              查看启动的虚拟机
virsh list --inactive   查看没有运行的虚拟机
virsh list --all        查看所有的虚拟机
```

2、连接虚拟机
```
virsh console <ID>                     连接到一个VM上.
virsh domid <Name | UUID>              根据名称或UUID返回ID值
virsh domname <ID | UUID>
virsh domstatc <[ID | Name | UUID]>    获取一个VM的运行状态
virsh dominfo <ID>                     获取一个VM的基本信息
virsh vncdisplay <ID>                  显示一个VM的VNC连接IP和端口
```

3、命令创建虚拟机并远程装机
```
mkdir /foo
virsh pool-create-as --name foo --type dir --target /foo
virsh vol-create-as --pool foo --name foo.qcow2 --format qcow2 --capacity 8GiB
mkdir /iso
virsh pool-create-as --name iso --type dir --target /iso
cp /path/to/x.iso /iso
yum install virt-install
yum install virt-viewer
virt-install --name foo --vcpus 2 --ram 1024 --cdrom /iso/x.iso --disk /foo/foo.qcow2 --boot hd,cdrom --graphics vnc,listen=0.0.0.0,port=5918,password=12345 --cpu host

VNC客户端连接装机即可
```

4、定义和创建、关闭、暂停
```
virsh define <VM.xml>          定义一个VM域.使其永久有效,并可使用start来启动VM,VM.xml会被复制一份到/etc/libvirt/qemu/下。
virsh create <VM.xml>          它可通过VM.xml来启动临时VM.
virsh suspend <ID>　　          在内存挂起一台VM
virsh resume <ID> 　　          唤醒一台VM
virsh save <ID> <file.img>     类似与VMware上的暂停,并保存内存数据到image文件.
virsh restore <file.img> 　　   重新载入暂停的VM
```

```
保存当前状态,并destroy VM 【注: 当VM的启动配置文件在/etc/libvirt/qemu下时,才能使用它保存VM】.
# --bypass: 保存VM时不保存文件系统缓存
# --running：使用start恢复运行时,直接进入running状态.

virsh managedsave [--bypass] <VMName> [--running | --paused] 
virsh start <VMName>            重新启动managedsave 保存的VM.
virsh shutdown <ID>
virsh reboot <ID>
virsh reset <ID>
virsh destroy <ID>
virsh undefine <VM.xml>
```

5、修改虚拟机配置
```
virsh edit VM_NAME
```

6、磁盘格式转换并使用它启动虚拟机
```
virsh shutdown foo
qemu-img convert -f qcow2 -O raw /foo/foo.qcow2 /foo/foo.raw

virsh edit VM_NAME
<disk type='file' device='disk'>
  <driver name='qemu' type='raw'/>
  <source file='/foo/foo.raw'/>
  ...
</disk>

virsh start foo

VNC客户端连接测试
```

7、快照管理

创建一个VM快照;直接创建其名为'date +%s'所的得值.指定一个xml的快照配置可自定义名称.
```
virsh snapshot-create <VMName | xxx.xml>
virsh snapshot-list <VMName> 　　               显示当前VM的所有快照
virsh snapshot-current <VMName>                 查看快照配置
virsh snapshot-info <VMName> <SnapName>         查看快照详细信息
```

导出一个快照的配置文件.
```
# 注: 测试时,我是先创建一个快照,然后,导出成xml配置文件,修改其<name>标签值,
# 再通过"date +%s"计算当前时间,最后创建快照,这样就实现了自定义快照名的目的.
# 另注：virsh创建快照时,总是默认会将前一个快照做为当前创建快照的parent快照.
# 但我测试时,即便删除parent快照,也不会对当前快照有影响.

virsh snapshot-dumpxml <VMName> <SnapName>
```

编辑一个快照的配置信息
```
#注： --rename：参数可改名,但在qemu-kvm 0.12.1这边版本中存在bug,改名后,快照将失效.
virsh snapshot-edit <VMName> <SnapName>
virsh snapshot-delete <VMName> <SnapName>          删除快照
```

恢复一个快照.注:0.12.1版本中存在bug,只能恢复一次,第二次将当中VM宕机。
```
virsh snapshot-revert <VMName> <SnapName>
virsh snapshot-info <VMName> <SnapName>             显示快照的详情.
```

8、VM的网络接口管理
```
virsh domiflist <VMName>                显示VM的接口信息
virsh domifstat <VMName> <Viface>       显示VM的接口通信统计信息
```

9、网络管理

接口管理
```
virsh iface-list 　　　　　　              显示物理主机的网络接口列表
virsh iface-mac <if-name>                显示指定接口名的MAC
virsh iface-name <MAC>
virsh iface-dempxml <if-name | UUID>     导出一份xml格式的接口状态信息
virsh iface-edit <if-name | UUID>　　　   编辑一个物理主机的网络接口的xml配置文件.
virsh iface-destrey <if-name | UUID>     关闭宿主机上一个物理网卡
```

虚拟网络管理
```
virsh net-list 　　　　　　                显示libvirt的虚拟网络
virsh net-info <NetName | UUID>          根据名称或UUID查询一个虚拟网络的基本信息
virsh net-uuid <NetName>　　　　          根据名称查询虚拟网络的UUID
virsh net-name <NetUUID>
virsh net-dumpxml <NetName | UUID> 　　   导出一份xml格式的虚拟网络配置信息
virsh net-edit <NetName | UUID> 　　　　  编辑一个虚拟网络的xml配置文件
virsh net-create <net.xml> 　　　　　　    根据网络xml配置信息文件创建一个虚拟网络
virsh net-destroy <NetName | UUID>　　    删除一个虚拟网络
```
 
10、VM磁盘管理
```
virsh domblklist <VMName> 　　　　                          显示VM当前连接的块设备
virsh domblkinfo <VMName> </path/to/img.img> 　　　　       显示img.img的容量信息.
virsh domblkstat <VMName> [--human] </path/to/img.img>     显示img的读写等信息的统计结果
virsh domblkerror <VMName> 　　                            显示VM连接的块设备的错误信息
```

11、存储池管理
- 关于存储池的构建,可参看IBM知识库的一篇文章:http://www.ibm.com/developerworks/cn/linux/l-cn-mgrtvm2/
```
virsh pool-list 　　　　　　　　           显示出libvirt管理的存储池
virsh pool-info <poolName> 　　          根据一个存储池名称查询其基本信息
virsh pool-uuid <PoolName>
virsh pool-edit <PoolName | UUID> 　　   编辑一个存储池的xml配置文件
virsh pool-create <pool.xml> 　　　　     根据xml配置文件的信息创建一个存储池
virsh pool-destroy <PoolName | UUID>     关闭一个存储池
virsh pool-delete <PoolName | UUID>      删除一个存储池
```

12、存储卷管理
```
virsh vol-list <PoolName | UUID> 　　 #查询一个存储池中存储卷的列表
virsh vol-name <VolKey | Path> 　　    #查询一个存储卷的名字
virsh vol-path --pool <pool> <VolName | Key>    #查询一个存储卷的路径
virsh vol-create <Vol.xml> 　　　　　　 #根据xml配置文件创建一个存储池
virsh vol-clone <VolNamePath> <Name>  　#克隆一个存储卷
virsh vol-delete <VolName | Key | Path>        #删除一个存储卷
```

13、迁移
```
# virsh migrate [OptionParas] <VMName> <TargetURI> [<MigrateURI>] [--dname <DestNewVMName>]
```
OptionParas:
- --live : 在线迁移
- --p2p : 点到点的迁移
- --direct : 直接迁移
- --tunnelled：隧道模式迁移
- --persistent ：指迁移VM到目标后,再执行virsh define VM，使其持久化。
- --undefinesource ：指迁移VM到目标后,在源宿主机上执行 virsh undefine VM。
- --suspend ： 迁移到目标后不重启VM
- --copy-storage-all ：在不使用共享存储的情况下,迁移时一同将VM的磁盘映像一起复制到目标端。
- --copy-storage-inc : 在不使用共享存储时,仅将VM的磁盘映像的增量文件复制到目标端,但前提是后端磁盘映像文件必须先复制到目标端,且位置要与源端一致。
- --dname :指定迁移到目标后,将VM的名字该成指定名称.

```
virsh migrate <ID> <Target_URL> #将一个VM迁移到另一个目的地址
示例：
#注: 源和目的宿主机采用NFS共享cirros-01的磁盘映像文件.
virsh migrate --live cirros-01 qemu+tcp://192.168.10.12:16666/system --dname cirros0001
```

14、迁移

1）offline:
```
A:172.16.0.100/24
B:172.16.0.101/24
A --> B
A: virsh dumpxml foo > foo.xml
  ls --> foo.xml foo.qcow2
  scp -P 22 foo.xml root@172.16.0.101:/root
  scp -P 22 foo.qcow2 root@172.16.0.101:/root
  ssh -p 22 root@172.16.0.101
  mkdir /foo
  mv foo.qcow2 /foo
  virsh pool-create-as --name foo --type dir --target /foo
  virsh create foo.xml(virsh define foo.xml && virsh start foo)
  VNC测试
```

2）online:
```
  NFS(172.16.0.64/24):
  yum -y install rpcbind nfs-utils && systemctl start rpcbind && systemctl start nfs
  mkdir /data
  vim /etc/exports
  /data *(rw,sync,no_root_squash)
  exportfs -r
  A and B:
  exportfs -e 172.16.0.64
  mkdir /data
  mount -t nfs 172.16.0.64:/data /data
  virsh pool-create-as --name foo --type dir /data
  A.install centos-7-x86_64
  virsh migrate foo qemu+ssh://B_IP/system --live --persistent
  VNC在B上测试
```

15、vCPU相关
```
virsh vcpinfo <ID>
virsh vcppin <ID> <vCPU> <pCPU>       将一个VM的vCPU绑定到指定的物理核心上
virsh setvcpus <ID> <vCPU-Num> 　　   设置一个VM的最多vCPU个数。
virsh nodecpustats <CPU-Num> 　　     显示VM(某个)CPU使用情况的统计
```

16、内存相关
```
virsh dommemstat <ID> 　　　　    获取一个VM内存使用情况统计信息。
virsh setmem <ID> <MemSize>      设置一个VM的内存大小(默认单位:KB)
virsh freecell 　　　　　　　　     显示当前MUMA单元的可用空闲内存
virsh nodememstats <cell>　　     显示VM的(某个)内存单元使用情况的统计
```

17、热插拔设备
- 注：USB控制器、IDE等设备是不支持热插拔的,测试添加SCSI 磁盘是可以的.
```
# 如: scsi.xml
# <disk type='file' device='disk'>
# 　　 <driver name='qemu' type='qcow2' cache='none'/>
# 　　 <source file='/images/kvm/10g.img'/>
# 　　 <target dev='sda' bus='scsi'/>
# 　　 <alias name='scsi0-0-0'/>
# 　　 <address type='drive' controller='1' bus='0' target='0' unit='0'/>
# </disk>

attach-device <ID> <device.xml> 　　  向一个域中添加XML文件中的热插拔设备.
detach-device <ID> <device.xml> 　　  从一个VM中移除XML文件中指定的热插拔设备。
```

18、其它
```
virsh dumpxml <ID> 　　     显示一个运行中的VM的xml格式的配置信息.
virsh version 　　　　　　   显示libvirt 和 Hypervisor的版本信息
virsh sysinfo 　　　　　　   以xml格式打印宿主机的系统信息
virsh capabilities 　　　　 显示当前连接节点所在的宿主机和其自身的架构和特性
virsh nodeinfo 　　　　　　  显示当前连接节点的基本信息
virsh uri 　　　　 　　　　   显示当前连接节点的URI
virsh hostname
virsh connect <URI> 　　     连接到URI指定的Hypervisor
virsh qemu-attach <PID>     根据PID添加一个Qemu进程到libvirt中
````

19、直接向Qemu monitor中发送命令; --hmp:直接传入monitor中无需转换.
```
virsh qemu-monitor-command domain [--hmp] CMD 
```

20、help
```
[root@localhost ~]# virsh help snapshot
 Snapshot (help keyword 'snapshot'):
    snapshot-create                使用 XML 生成快照
    snapshot-create-as             使用一组参数生成快照
    snapshot-current               获取或者设定当前快照
    snapshot-delete                删除域快照
    snapshot-dumpxml               为域快照转储 XML
    snapshot-edit                  编辑快照 XML
    snapshot-info                  快照信息
    snapshot-list                  为域列出快照
    snapshot-parent                获取快照的上级快照名称
    snapshot-revert                将域转换为快照
```

```
[root@localhost ~]# virsh snapshot-create-as --help
  NAME
    snapshot-create-as - 使用一组参数生成快照

  SYNOPSIS
    snapshot-create-as <domain> [--name <string>] [--description <string>] [--print-xml] [--no-metadata] [--halt] [--disk-only] [--reuse-external] [--quiesce] [--atomic] [--live] [--memspec <string>] [[--diskspec] <string>]...

  DESCRIPTION
    使用一组参数生成快照（磁盘和 RAM）

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --name <string>  快照名称
    --description <string>  快照描述
    --print-xml      输出 XML 文档而不是生成 XML
    --no-metadata    提取快照但不生成元数据
    --halt           生成快照后停止域
    --disk-only      捕获磁盘状态而不是 vm 状态
    --reuse-external  重新使用任意现有外部文件
    --quiesce        静默虚拟机的文件系统
    --atomic         需要自动操作
    --live           提取实时快照
    --memspec <string>  内存属性：[file=]name[,snapshot=type]
    [--diskspec] <string>  磁盘属性: disk[,snapshot=type][,driver=type][,file=name]
```

```
[root@localhost ~]# virsh snapshot-list --help
  NAME
    snapshot-list - 为域列出快照

  SYNOPSIS
    snapshot-list <domain> [--parent] [--roots] [--leaves] [--no-leaves] [--metadata] [--no-metadata] [--inactive] [--active] [--disk-only] [--internal] [--external] [--tree] [--from <string>] [--current] [--descendants] [--name]

  DESCRIPTION
    快照列表

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --parent         添加一列显示上级快照
    --roots          只列出快照不列出其上级
    --leaves         列出没有下级的快照
    --no-leaves      只列出没有离开的快照（附带下级快照）
    --metadata       只列出可防止取消定义的元数据的快照
    --no-metadata    只列出 libvirt 未管理元数据的快照
    --inactive       不活跃时提取快照时的过滤器
    --active         活跃是提取快照时的过滤器（系统检查点）
    --disk-only      用于 disk-only 快照的过滤器
    --internal       内部快照的过滤器
    --external       外部快照的过滤器
    --tree           列出树中的快照
    --from <string>  将列表限制为给定快照的下级
    --current        将列表限制为当前快照的下级
    --descendants    使用 --from 列出所有下级
    --name           只列出快照名称
```

```
[root@localhost ~]# virsh snapshot-revert --help
  NAME
    snapshot-revert - 将域转换为快照

  SYNOPSIS
    snapshot-revert <domain> [--snapshotname <string>] [--current] [--running] [--paused] [--force]

  DESCRIPTION
    将域转换为快照

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --snapshotname <string>  快照名称
    --current        转换为当前快照
    --running        转换后将状态改为 running
    --paused         转换后将状态改为 paused
    --force          更努力地尝试有风险的转换
```

```
[root@localhost ~]# virsh snapshot-current --help
  NAME
    snapshot-current - 获取或者设定当前快照

  SYNOPSIS
    snapshot-current <domain> [--name] [--security-info] [--snapshotname <string>]

  DESCRIPTION
    获取或者设定当前快照

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --name           列出名称儿不是完整 xml
    --security-info  包括 XML 转储中与安全性相关的信息
    --snapshotname <string>  要设定为 current 的当前快照名称
```

```
[root@localhost ~]# virsh snapshot-create --help
  NAME
    snapshot-create - 使用 XML 生成快照

  SYNOPSIS
    snapshot-create <domain> [--xmlfile <string>] [--redefine] [--current] [--no-metadata] [--halt] [--disk-only] [--reuse-external] [--quiesce] [--atomic] [--live]

  DESCRIPTION
    使用 XML 生成快照（磁盘和 RAM）

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --xmlfile <string>  域快照 XML
    --redefine       重新定义现有快照元数据
    --current        使用 redefice 设定当前快照
    --no-metadata    提取快照但不生成元数据
    --halt           生成快照后停止域
    --disk-only      捕获磁盘状态而不是 vm 状态
    --reuse-external  重新使用任意现有外部文件
    --quiesce        静默虚拟机的文件系统
    --atomic         需要自动操作
    --live           提取实时快照
```

```
[root@localhost ~]# virsh snapshot-dumpxml --help
  NAME
    snapshot-dumpxml - 为域快照转储 XML

  SYNOPSIS
    snapshot-dumpxml <domain> <snapshotname> [--security-info]

  DESCRIPTION
    快照转储 XML

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    [--snapshotname] <string>  快照名称
    --security-info  包括 XML 转储中与安全性相关的信息
```

```
[root@localhost ~]# virsh snapshot-parent --help
  NAME
    snapshot-parent - 获取快照的上级快照名称

  SYNOPSIS
    snapshot-parent <domain> [--snapshotname <string>] [--current]

  DESCRIPTION
    如果有则提取快照上级

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --snapshotname <string>  查找快照名称上级
    --current        查找当前快照名称上级
```

```
[root@localhost ~]# virsh snapshot-info --help
  NAME
    snapshot-info - 快照信息

  SYNOPSIS
    snapshot-info <domain> [--snapshotname <string>] [--current]

  DESCRIPTION
    返回快照的基本信息。

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --snapshotname <string>  快照名称
    --current        当前快照信息
```

```
[root@localhost ~]# virsh snapshot-edit --help
  NAME
    snapshot-edit - 编辑快照 XML

  SYNOPSIS
    snapshot-edit <domain> [--snapshotname <string>] [--current] [--rename] [--clone]

  DESCRIPTION
    为命名快照编辑域快照 XML

  OPTIONS
    [--domain] <string>  域名，id 或 uuid
    --snapshotname <string>  快照名称
    --current        也将编辑的快照设定为 current
    --rename         允许对现有快照创新命名
    --clone          允许克隆为新名称
```

# 使用virt-install创建虚拟机并安装GuestOS

virt-install是一个命令行工具，它能够为KVM、Xen或其它支持libvirt API的hypervisor创建虚拟机并完成GuestOS安装；此外，它能够基于串行控制台、VNC或SDL支持文本或图形安装界面。安装过程可以使用本地的安装介质如CDROM，也可以通过网络方式如NFS、HTTP或FTP服务实现。对于通过网络安装的方式，virt-install可以自动加载必要的文件以启动安装过程而无须额外提供引导工具。当然，virt-install也支持PXE方式的安装过程，也能够直接使用现有的磁盘映像直接启动安装过程。

### virt-install命令有许多选项，这些选项大体可分为下面几大类，同时对每类中的常用选项也做出简单说明。
一般选项：指定虚拟机的名称、内存大小、VCPU个数及特性等；
```
-n NAME, --name=NAME：虚拟机名称，需全局惟一；
-r MEMORY, --ram=MEMORY：虚拟机内在大小，单位为MB；
--vcpus=VCPUS[,maxvcpus=MAX][,sockets=#][,cores=#][,threads=#]：VCPU个数及相关配置；
--cpu=CPU：CPU模式及特性，如coreduo等；可以使用qemu-kvm -cpu ?来获取支持的CPU模式；
--keymap=en-us #指定键盘布局.
#xml配置文件中可修改VNC配置项: <graphics type='vnc' port='-1' keymap='en-us'/>
```

安装方法：指定安装方法、GuestOS类型等；
```
-c CDROM, --cdrom=CDROM：光盘安装介质；
-l LOCATION, --location=LOCATION：安装源URL，支持FTP、HTTP及NFS等，如ftp://172.16.0.1/pub；
--pxe：基于PXE完成安装；
--livecd: 把光盘当作LiveCD；
--os-type=DISTRO_TYPE：操作系统类型，如linux、unix或windows等；
--os-variant=DISTRO_VARIANT：某类型操作系统的变体，如rhel5、fedora8等；
-x EXTRA, --extra-args=EXTRA：根据--location指定的方式安装GuestOS时，用于传递给内核的额外选项，例如指定kickstart文件的位置，--extra-args "ks=http://172.16.0.1/class.cfg"
--boot=BOOTOPTS：指定安装过程完成后的配置选项，如指定引导设备次序、使用指定的而非安装的kernel/initrd来引导系统启动等 ；例如：
--boot cdrom,hd,network：指定引导次序；
--boot kernel=KERNEL,initrd=INITRD,kernel_args=”console=/dev/ttyS0”：指定启动系统的内核及initrd文件；
```

存储配置：指定存储类型、位置及属性等；
```
--disk=DISKOPTS：指定存储设备及其属性；格式为--disk /some/storage/path,opt1=val1，opt2=val2等；常用的选项有：
  device：设备类型，如cdrom、disk或floppy等，默认为disk；
  bus：磁盘总线类型，其值可以为ide、scsi、usb、virtio或xen；
  perms：访问权限，如rw、ro或sh（共享的可读写），默认为rw；
  size：新建磁盘映像的大小，单位为GB；
  cache：缓存模型，其值有none、writethrouth（缓存读）及writeback（缓存读写）；
  format：磁盘映像格式，如raw、qcow2、vmdk等；
  sparse：磁盘映像使用稀疏格式，即不立即分配指定大小的空间；
--nodisks：不使用本地磁盘，在LiveCD模式中常用；
```

网络配置：指定网络接口的网络类型及接口属性如MAC地址、驱动模式等；
```
-w NETWORK, --network=NETWORK,opt1=val1,opt2=val2：将虚拟机连入宿主机的网络中，其中NETWORK可以为：
　　bridge=BRIDGE：连接至名为“BRIDEG”的桥设备；
　　network=NAME：连接至名为“NAME”的网络；
其它常用的选项还有：
　　model：GuestOS中看到的网络设备型号，如e1000、rtl8139或virtio等；
　　mac：固定的MAC地址；省略此选项时将使用随机地址，但无论何种方式，对于KVM来说，其前三段必须为52:54:00；
　　--nonetworks：虚拟机不使用网络功能；
```

图形配置：定义虚拟机显示功能相关的配置，如VNC相关配置；
```
--graphics TYPE,opt1=val1,opt2=val2：指定图形显示相关的配置，此选项不会配置任何显示硬件（如显卡），而是仅指定虚拟机启动后对其进行访问的接口；
　　TYPE：指定显示类型，可以为vnc、sdl、spice或none等，默认为vnc；
　　port：TYPE为vnc或spice时其监听的端口；
　　listen：TYPE为vnc或spice时所监听的IP地址，默认为127.0.0.1，可以通过修改/etc/libvirt/qemu.conf定义新的默认值；
　　password：TYPE为vnc或spice时，为远程访问监听的服务进指定认证密码；
--noautoconsole：禁止自动连接至虚拟机的控制台；
```

设备选项：指定文本控制台、声音设备、串行接口、并行接口、显示接口等；
```
--serial=CHAROPTS：附加一个串行设备至当前虚拟机，根据设备类型的不同，可以使用不同的选项，格式为“--serial type,opt1=val1,opt2=val2,...”，例如：
--serial pty：创建伪终端；
--serial dev,path=HOSTPATH：附加主机设备至此虚拟机；
--video=VIDEO：指定显卡设备模型，可用取值为cirrus、vga、qxl或vmvga；
```

虚拟化平台：虚拟化模型（hvm或paravirt）、模拟的CPU平台类型、模拟的主机类型、hypervisor类型（如kvm、xen或qemu等）以及当前虚拟机的UUID等；
```
-v, --hvm：当物理机同时支持完全虚拟化和半虚拟化时，指定使用完全虚拟化；
-p, --paravirt：指定使用半虚拟化；
--virt-type：使用的hypervisor，如kvm、qemu、xen等；所有可用值可以使用’virsh capabilities’命令获取；
```

其它：
```
--autostart：指定虚拟机是否在物理启动后自动启动；
--print-xml：如果虚拟机不需要安装过程(--import、--boot)，则显示生成的XML而不是创建此虚拟机；默认情况下，此选项仍会创建磁盘映像；
--force：禁止命令进入交互式模式，如果有需要回答yes或no选项，则自动回答为yes；
--dry-run：执行创建虚拟机的整个过程，但不真正创建虚拟机、改变主机上的设备配置信息及将其创建的需求通知给libvirt；
-d, --debug：显示debug信息；
```

　　尽管virt-install命令有着类似上述的众多选项，但实际使用中，其必须提供的选项仅包括--name、--ram、--disk（也可是--nodisks）及安装过程相关的选项。此外，有时还需要使用括--connect=CONNCT选项来指定连接至一个非默认的hypervisor。


## 使用示例：

(1) 
```
# virt-install \
-n "centos6" \
-r 512 \
--vcpus=2 \
-l http://172.16.0.1/cobbler/ks_mirror/CentOS-6.6-x86_64/ \
-x "ks=http://172.16.0.1/centos6.x86_64.cfg" \
--disk path=/images/kvm/centos6.img,size=120,sparse \
--force \
-w bridge=br100,model=virtio
```

(2)下面这个示例创建一个名为rhel5的虚拟机，其hypervisor为KVM，内存大小为512MB，磁盘为8G的映像文件/var/lib/libvirt/images/rhel5.8.img，通过boot.iso光盘镜像来引导启动安装过程。
```
# virt-install \
--connect qemu:///system \
--virt-type kvm \
--name rhel5 \
--ram 512 \
--disk path=/var/lib/libvirt/images/rhel5.img,size=8 \
--graphics vnc \
--cdrom /tmp/boot.iso \
--os-variant rhel5
```

(3) 下面的示例将创建一个名为rhel6的虚拟机，其有两个虚拟CPU，安装方法为FTP，并指定了ks文件的位置，磁盘映像文件为稀疏格式，连接至物理主机上的名为brnet0的桥接网络：
```
# virt-install \
--connect qemu:///system \
--virt-type kvm \
--name rhel6 \
--ram 1024 \
--vcpus 2 \
--network bridge=brnet0 \
--disk path=/VMs/images/rhel6.img,size=120,sparse \
--location ftp://172.16.0.1/rhel6/dvd \
--extra_args “ks=http://172.16.0.1/rhel6.cfg” \
--os-variant rhel6 \
--force
```

(4) 下面的示例将创建一个名为rhel5.8的虚拟机，磁盘映像文件为稀疏模式的格式为qcow2且总线类型为virtio，安装过程不启动图形界面（--nographics），但会启动一个串行终端将安装过程以字符形式显示在当前文本模式下，虚拟机显卡类型为cirrus：
```
# virt-install \
--connect qemu:///system \
--virt-type kvm \
--name rhel5.8 \
--vcpus 2,maxvcpus=4 \
--ram 512 \
--disk path=/VMs/images/rhel5.8.img,size=120,format=qcow2,bus=virtio,sparse \
--network bridge=brnet0,model=virtio
--nographics \
--location ftp://172.16.0.1/pub \
--extra-args "ks=http://172.16.0.1/class.cfg console=ttyS0 serial" \
--os-variant rhel5 \
--force \
--video=cirrus
```

(5) 下面的示例则利用已经存在的磁盘映像文件（已经有安装好的系统）创建一个名为rhel5.8的虚拟机：
```
# virt-install \
--name rhel5.8
--ram 512
--disk /VMs/rhel5.8.img
--import
```
注意：每个虚拟机创建后，其配置信息保存在/etc/libvirt/qemu目录中，文件名与虚拟机相同，格式为XML。




