# flag	介绍


Ceph是一个分布式系统，旨在从数十个OSD扩展到数千个。维护Ceph集群所需的关键之一是管理其OSD。

我们假设您要在生产Ceph集群中添加新节点。一种方法是简单地将具有多个磁盘的新节点添加到Ceph集群，并且集群将开始回填并将数据混洗到新节点上。这适用于测试集群。

然而，当涉及到生产系统中，你应该使用noin，nobackfill，等等。这样做是为了在新节点进入时集群不会立即启动回填过程。然后，您可以在非高峰时段取消设置这些标志，并且集群将花时间重新平衡：

# 集群标志

| Flag字段 | 描述 |
|----------|-----|
| noup | 防止osd进入up状态，标记osd进程未启动，一般用于新添加osd。 |
| nodown | 防止osd进入down状态，一般用在检查osd进程时，而导致osd down，发生数据迁移。 |
| noout | 防止osd进入out状态，down状态的osd	300s后会自动被标记未	out，此时，数据就会发生迁移。noout标记后，如果osd	down,	该osd的pg会切换到副本osd上 |
| noin | 防止osd加入ceph	集群，一般用在新添加osd后，又不想马上加入集群，导致数据迁移。 |
| nobackfill | 防止集群进行数据回填操作，Ceph集群故障会触发	backfill |
| norebalance | 防止数据平衡操作，Ceph集群在扩容时会触发rebalance操作。一般和 nobackfill,norecover一起使用，用于防止数据发生数据迁移等操作。 |
| norecover | 防止数据发生恢复操作。 |
| noscrub | 防止集群清洗操作，在高负载、recovery,	backfilling,rebalancing等期间，为了保证集群性能，可以和	nodeep-scrub	一起设置。 |
| nodeep-scrub | 防止集群进行深度清洗操作。因为会阻塞读写操作，影响性能。一般不要长时间设置该值，否则，一旦取消该值，则会由大量的pg进行深度清洗。 |
| pause | 设置该标志位，则集群停止读写，但不影响osd自检 |
| full | 标记集群已满，将拒绝任何数据写入，但可读 |

设置flag
```
$ ceph osd set <flag_name>
$ ceph osd set noout
$ ceph osd set nodown
$ ceph osd set norecover
```

取消flag
```
$ ceph osd unset <flag_name>
$ ceph osd unset noout
$ ceph osd unset nodown
$ ceph osd unset norecover
```

## 集群flag操作

- 只能对整个集群操作，不能针对单个osd

1、设置为noout状态
```
# ceph osd set noout
noout is set

# ceph -s
cluster:
id: 35a91e48-8244-4e96-a7ee-980ab989d20d
health: HEALTH_WARN
noout flag(s) set

services:
mon: 3 daemons, quorum ceph2,ceph3,ceph4
mgr: ceph4(active), standbys: ceph2, ceph3
mds: cephfs-1/1/1 up {0=ceph2=up:active}, 1 up:standby
osd: 9 osds: 9 up, 9 in; 32 remapped pgs
flags noout
rbd-mirror: 1 daemon active

data:
pools: 14 pools, 536 pgs
objects: 220 objects, 240 MB
usage: 1764 MB used, 133 GB / 134 GB avail
pgs: 508 active+clean
28 active+clean+remapped

io:
client: 409 B/s rd, 0 op/s rd, 0 op/s wr
```

2、取消设置noout状态
```
# ceph osd unset noout
noout is unset

# ceph -s
cluster:
id: 35a91e48-8244-4e96-a7ee-980ab989d20d
health: HEALTH_OK

services:
mon: 3 daemons, quorum ceph2,ceph3,ceph4
mgr: ceph4(active), standbys: ceph2, ceph3
mds: cephfs-1/1/1 up {0=ceph2=up:active}, 1 up:standby
osd: 9 osds: 9 up, 9 in; 32 remapped pgs
rbd-mirror: 1 daemon active

data:
pools: 14 pools, 536 pgs
objects: 220 objects, 240 MB
usage: 1764 MB used, 133 GB / 134 GB avail
pgs: 508 active+clean
28 active+clean+remapped

io:
client: 2558 B/s rd, 0 B/s wr, 2 op/s rd, 0 op/s wr
```

3、full状态测试
```
# 设置为full状态
# ceph osd set full
full is set

# ceph -s
cluster:
id: 35a91e48-8244-4e96-a7ee-980ab989d20d
health: HEALTH_WARN
full flag(s) set

services:
mon: 3 daemons, quorum ceph2,ceph3,ceph4
mgr: ceph4(active), standbys: ceph2, ceph3
mds: cephfs-1/1/1 up {0=ceph2=up:active}, 1 up:standby
osd: 9 osds: 9 up, 9 in; 32 remapped pgs
flags full
rbd-mirror: 1 daemon active

data:
pools: 14 pools, 536 pgs
objects: 220 objects, 240 MB
usage: 1768 MB used, 133 GB / 134 GB avail
pgs: 508 active+clean
28 active+clean+remapped

io:
client: 2558 B/s rd, 0 B/s wr, 2 op/s rd, 0 op/s wr


# 向集群写入文件
# rados -p ssdpool put testfull /etc/ceph/ceph.conf
2019-03-27 21:59:14.250208 7f6500913e40 0 client.65175.objecter FULL, paused modify 0x55d690a412b0 tid 0


# 取消full状态
# ceph osd unset full
full is unset


# ceph -s
cluster:
id: 35a91e48-8244-4e96-a7ee-980ab989d20d
health: HEALTH_OK

services:
mon: 3 daemons, quorum ceph2,ceph3,ceph4
mgr: ceph4(active), standbys: ceph2, ceph3
mds: cephfs-1/1/1 up {0=ceph2=up:active}, 1 up:standby
osd: 9 osds: 9 up, 9 in; 32 remapped pgs
rbd-mirror: 1 daemon active

data:
pools: 14 pools, 536 pgs
objects: 220 objects, 240 MB
usage: 1765 MB used, 133 GB / 134 GB avail
pgs: 508 active+clean
28 active+clean+remapped

io:
client: 409 B/s rd, 0 op/s rd, 0 op/s wr


# 向集群写入文件
# rados -p ssdpool put testfull /etc/ceph/ceph.conf

# 查看文件
# rados -p ssdpool ls
testfull
test
```


# pool相关配置文件

| 配置 | 描述 |
|-----|------|
| osd_pool_default_flag_nodelete | 禁止池被删除 |
| osd_pool_default_flag_nopgchange | 禁止池的pg_num和pgp_num被修改 |
| osd_pool_default_flag_nosizechang | 禁止修改池的size和min_size |

```
# ceph daemon osd.0  config show|grep osd_pool_default_flag
"osd_pool_default_flag_hashpspool": "true",
"osd_pool_default_flag_nodelete": "false",
"osd_pool_default_flag_nopgchange": "false",
"osd_pool_default_flag_nosizechange": "false",
"osd_pool_default_flags": "0",

# ceph tell osd.* injectargs --osd_pool_default_flag_nodelete true

# ceph daemon osd.0 config show|grep osd_pool_default_flag
"osd_pool_default_flag_hashpspool": "true",
"osd_pool_default_flag_nodelete": "true",
"osd_pool_default_flag_nopgchange": "false",
"osd_pool_default_flag_nosizechange": "false",
"osd_pool_default_flags": "0",

# 删除资源池
# ceph osd pool delete ssdpool  ssdpool yes-i-really-really-mean-it
Error EPERM: WARNING: this will *PERMANENTLY DESTROY* all data stored in pool ssdpool.  If you are *ABSOLUTELY CERTAIN* that is what you want, pass the pool name *twice*, followed by --yes-i-really-really-mean-it.   #不能删除

修改osd_pool_default_flag_nodelete为false
# ceph tell osd.* injectargs --osd_pool_default_flag_nodelete false

# ceph daemon osd.0 config show|grep osd_pool_default_flag
"osd_pool_default_flag_hashpspool": "true",
"osd_pool_default_flag_nodelete": "true",                   #依然显示为ture
"osd_pool_default_flag_nopgchange": "false",
"osd_pool_default_flag_nosizechange": "false",
"osd_pool_default_flags": "0"


# 使用配置文件修改

# 在ceph1的配置文件上修改osd_pool_default_flag_nodelete false

# 推送配置到ceph集群节点
# ansible all -m copy -a 'src=/etc/ceph/ceph.conf dest=/etc/ceph/ceph.conf owner=ceph group=ceph mode=0644'
# ansible mons -m shell -a ' systemctl restart ceph-mon.target'
# ansible mons -m shell -a ' systemctl restart ceph-osd.target'

# 查看配置
# ceph daemon osd.0 config show|grep osd_pool_default_flag
"osd_pool_default_flag_hashpspool": "true",
"osd_pool_default_flag_nodelete": "false",
"osd_pool_default_flag_nopgchange": "false",
"osd_pool_default_flag_nosizechange": "false",
"osd_pool_default_flags": "0",

# 删除ssdpool
# ceph osd pool delete ssdpool ssdpool --yes-i-really-really-mean-it
```


# 节流回填和恢复

在业务高峰期添加新的OSD节点，又希望对客户端IO中产生的影响最小，这时就可以借助以下命令限制回填和恢复。
```
# vim ceph.conf
[osd]
osd_max_backfills = 1                   # 限制回填线程
osd_recovery_max_active = 1             # 限制恢复线程
osd_recovery_op_priority = 1            # 降低恢复优先
```

通过命令动态设置回填速度
```
# ceph tell osd.* injectargs '--osd_max_backfills 1'
# ceph tell osd.* injectargs '--osd_recovery_max_active 1'
# ceph tell osd.* injectargs '--osd_recovery_op_priority 1'
```
- 注意回填和恢复完成后调回之前参数

# OSD	和	PG	修复

```
# 这将在指定的OSD上执行修复。
ceph osd repair

# 这将在指定的PG上执行修复。请谨慎使用此命令;根据您的群集状态，如果未仔细使用，此命令可能会影响用户数据。
ceph pg repair

# 这将在指定的PG上执行清理。
ceph pg scrub 

# 这会对指定的PG执行深度清理。
ceph deep-scrub 
```

# 集群空间限制(OSD容量)

- 当集群容量达到mon_osd_nearfull_ratio的值时，集群会进入HEALTH_WARN状态。这是为了在达到full_ratio之前，提醒添加OSD。默认设置为0.85，即85%
- 当集群容量达到mon_osd_full_ratio的值时，集群将停止写入，但允许读取。集群会进入到HEALTH_ERR状态。默认为0.95，即95%。这是为了防止当一个或多个OSD故障时仍留有余地能重平衡数据

```
# 设置方法
# ceph osd set-full-ratio 0.95
# ceph osd set-nearfull-ratio 0.85

# ceph osd dump
crush_version 43
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.85
```

动态修复方式
```
# ceph daemon osd.0 config show|grep full_ratio
"mon_osd_backfillfull_ratio": "0.900000",
"mon_osd_full_ratio": "0.950000",
"mon_osd_nearfull_ratio": "0.850000",
"osd_failsafe_full_ratio": "0.970000",
"osd_pool_default_cache_target_full_ratio": "0.800000",

# ceph tell osd.* injectargs --mon_osd_full_ratio 0.85
# ceph daemon osd.0 config show|grep full_ratio
"mon_osd_backfillfull_ratio": "0.900000",
"mon_osd_full_ratio": "0.850000",
"mon_osd_nearfull_ratio": "0.850000",
"osd_failsafe_full_ratio": "0.970000",
"osd_pool_default_cache_target_full_ratio": "0.800000",
```

# 物理机关机维护
```
ceph osd set noout  
ceph osd set nobackfill  
ceph osd set norecover
```

# 关闭顺序
```
# 关闭服务前设置 noout 
关闭存储客户端停止读写数据 
如果使用了 RGW，关闭 RGW
关闭 cephfs 元数据服务 
关闭 ceph OSD 
关闭 ceph manager 
关闭 ceph monitor
```

# 启动顺序
```
启动 ceph monitor
启动 ceph manager
启动 ceph OSD
关闭 cephfs 元数据服务
启动 RGW
启动存储客户端
# 启动服务后取消 noout-->ceph osd unset noout
```
