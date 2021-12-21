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

1、查看虚拟主机
```
virsh list              查看启动的虚拟机
virsh list --inactive   查看没有运行的虚拟机
virsh list --all        查看所有的虚拟机
```

2、命令创建虚拟机并远程装机
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

3、开关机
```
virsh start VM_NAME
virsh shutdown VM_NAME
virsh reboot VM_NAME
virsh destroy VM_NAME
```

4、修改虚拟机配置
```
virsh edit VM_NAME
```

5、磁盘格式转换并使用它启动虚拟机
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

6、快照管理
```
virsh snapshot-list foo
virsh snapshot-create-as --name foo-hello --domain foo
virsh snapshot-revert --domain foo --snapshotname foo-hello
virsh snapshot-delete --domain foo --snapshotname foo-hello
virsh snapshot-info --domain foo --snapshotname foo-hello
virsh snapshot-current --domain foo
```

7、迁移

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

8、help
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













