# 命令行查看集群

1、检查集群的健康状况  
```
# ceph health
HEALTH_OK

# ceph health detail
HEALTH_OK
```
- HEALTH_OK
- HEALTH_WARN
- HEALTH_ERR

2、检查集群的状态  
```
# ceph status
# ceph -s
cluster:
    id:     8230a918-a0de-4784-9ab8-cd2a2b8671d0
    health: HEALTH_WARN
            application not enabled on 1 pool(s)

  services:
    mon: 3 daemons, quorum cephnode01,cephnode02,cephnode03 (age 27h)
    mgr: cephnode01(active, since 53m), standbys: cephnode03, cephnode02
    osd: 4 osds: 4 up (since 27h), 4 in (since 19h)
    rgw: 1 daemon active (cephnode01)

  data:
    pools:   6 pools, 96 pgs
    objects: 235 objects, 3.6 KiB
    usage:   4.0 GiB used, 56 GiB / 60 GiB avail
    pgs:     96 active+clean
```
- id：集群ID
- health：集群运行状态，这里有一个警告，说明是有问题，意思是pg数大于pgp数，通常此数值相等。
- mon：Monitors运行状态。
- osd：OSDs运行状态。
- mgr：Managers运行状态。
- mds：Metadatas运行状态。
- pools：存储池与PGs的数量。
- objects：存储对象的数量。
- usage：存储的理论用量。
- pgs：PGs的运行状态

3、查看集群事件  
```
# ceph -w                    # 集群的动态更改信息
# ceph --watch-debug         # debug
```  
- --watch-info: to watch info events  
- --watch-sec: to watch security events  
- --watch-warn: to watch warning events  
- --watch-error: to watch error events  

4、集群利用率统计  
```
# ceph df
GLOBAL:
    SIZE        AVAIL       RAW USED     %RAW USED 
    5.99GiB     3.93GiB      2.06GiB         34.46 
POOLS:
    NAME     ID     USED        %USED     MAX AVAIL     OBJECTS 
    rbd      1      4.45MiB      0.12       3.61GiB          13 


# ceph df detail
GLOBAL:
    SIZE        AVAIL       RAW USED     %RAW USED     OBJECTS 
    5.99GiB     3.93GiB      2.07GiB         34.47          13 
POOLS:
    NAME     ID     QUOTA OBJECTS     QUOTA BYTES     USED        %USED     MAX AVAIL     OBJECTS     DIRTY     READ     WRITE     RAW USED 
    rbd      1      N/A               N/A             4.45MiB      0.12       3.61GiB          13        13     362B       93B      13.4MiB 
```  

5、集群身份验证  
```
# ceph auth list
```

# 集群标志

| 集群标志 | 集群标志描述 |
|---------|-------------|
| noup | OSD启动时，会将自己在MON上标识为UP状态，设置该标志位，则OSD不会被自动标识为up状态 |
| nodown | OSD停止时，MON会将OSD标识为down状态，设置该标志位，则MON不会将停止的OSD标识为down状态，设置noup和nodown可以防止网络抖动 |
| noout | 设置该标志位，则mon不会从crush映射中删除任何OSD。对OSD作维护时，可设置该标志位，以防止CRUSH在OSD停止时自动重平衡数据。OSD重新启动时，需要清除该flag |
| noin | 设置该标志位，可以防止数据被自动分配到OSD上 |
| norecover | 设置该flag，禁止任何集群恢复操作。在执行维护和停机时，可设置该flag |
| nobackfill | 禁止数据回填 |
| noscrub | 禁止清理操作。清理PG会在短期内影响OSD的操作。在低带宽集群中，清理期间如果OSD的速度过慢，则会被标记为down。可以该标记来防止这种情况发生 |
| nodeep-scrub | 禁止深度清理 |
| norebalance | 禁止重平衡数据。在执行集群维护或者停机时，可以使用该flag |
| pause | 设置该标志位，则集群停止读写，但不影响osd自检 |
| full | 标记集群已满，将拒绝任何数据写入，但可读 |

# 集群标志操作

a)设置noout状态
```
# ceph osd set noout
noout is set
```
b) 取消noout状态
```
# ceph osd unset noout
noout is unset
```
c) 将指定文件作为对象写入到资源池中 put
```
# rados -p ssdpool put testfull /etc/ceph/ceph.conf
2019-03-27 21:59:14.250208 7f6500913e40 0 client.65175.objecter FULL, paused modify 0x55d690a412b0 tid 0

# rados -p ssdpool ls
testfull
test
```

# 检查Mon状态  

## MON 状态表

| 状态 | 说明 |
|-----|------|
| probing | 正在探测态。这意味着MON正在寻找其他的MON。当MON启动时， MON尝试找在monmap定义的其他剩余的MON。在多MON的集群中，直到MON找到足够多的MON构建法定选举人数之前，它一直在这个状态。这意味着如果3个MON中的2个挂掉，剩余的1个MON将一直在probing状态，直到启动其他的MON中的1个为止。 |
| electing | 正在选举态。这意味着MON正在选举中。这应该很快完成，但有时也会卡在正这，这通常是因为MON主机节点间的时钟偏移导致的. |
| synchronizing | 正在同步态。这意味着MON为了加入到法定人数中和集群中其他的MON正在同步. |
| leader或peon | 领导态或员工态。这不应该出现。然而有机会出现，一般和时钟偏移有很大关系 |

client 无法链接mon的可能原因
- 连通性和防火墙规则。在MON主机上修改允许TCP 端口6789的访问。
- 磁盘空间。每个MON主机上必须有超过5%的空闲磁盘空间使MON和levelDB数据库正常工作。
- MON没有工作或者离开选举，检查如上命令输出结果中的quorum_status和mon_status或者ceph -s 的输出来确定失败的MON进程，尝试重启或者部署一个新的来替代它。

Monitor 状态和查看仲裁状态
```
# ceph mon stat
# ceph mon dump
# ceph quorum_status -f json-pretty
```  

# OSD查看  

## OSD状态表

| 状态 | 说明 |
|-----|------|
| up | osd启动 |
| down | osd停止 |
| in | osd在集群中 |
| out | osd不在集群中，默认OSD down 超过300s,Ceph会标记为out，会触发重新平衡操作 |
| up & in | 说明该OSD正常运行，且已经承载至少一个PG的数据。这是一个OSD的标准工作状态 |
| up & out | 说明该OSD正常运行，但并未承载任何PG，其中也没有数据。一个新的OSD刚刚被加入Ceph集群后，便会处于这一状态。而一个出现故障的OSD被修复后，重新加入Ceph集群时，也是处于这一状态 |
| down & in | 说明该OSD发生异常，但仍然承载着至少一个PG，其中仍然存储着数据。这种状态下的OSD刚刚被发现存在异常，可能仍能恢复正常，也可能会彻底无法工作 |
| down & out | 说明该OSD已经彻底发生故障，且已经不再承载任何PG |

常见问题
- 硬盘失败。可以通过系统日志或SMART活动确认。有些有缺陷的硬盘因为密集的有时限的错误修复活动变的很慢。
- 网络连接问题。可以使用ping、iperf等普通网络工具进行调试。
- OSD文件存储的磁盘空间不足。 磁盘到85%将会触发HEALTH_WARN告警。磁盘到95%会触发HEALTH_ERR告警，OSD为了避免填满磁盘会停止。
- 超过系统资源限制。系统内存应该足够主机上所有的OSD进程，打开文件句柄数和最大线程数也应该是足够的。OSD进程处理心跳的限制导致进程自杀。默认的处理和通信超时不足以执行IO饥饿型的操作，尤其是失败后的恢复。这经常会导致OSD闪断的现象出现。

## 查看osd状态
```
# ceph osd tree
# ceph osd dump
# ceph osd stat
# ceph osd status 
# ceph osd dump
# ceph osd tree
# ceph osd df
```  

## Crush map的查看  
```
# ceph osd crush dump
# ceph osd crush rule list
# ceph osd crush rule dump <crush_rule_name>
# ceph osd find <Numeric_OSD_ID>
```  

# PGs的查看  

## 1、pg状态

| 状态 | 描述 |
|-----|------|
| creating | PG正在被创建。通常当存储池被创建或者PG的数目被修改时，会出现这种状态 |
| active | 活跃状态。ceph将处理到达这个PG的读写请求 |
| unactive | 非活跃状态。该PG不能处理读写请求 |
| clean | 干净状态。Ceph复制PG内所有对象到设定正确的数目 |
| unclean | 非干净状态。PG不能从上一个失败中恢复 |
| down | 离线状态。有必需数据的副本挂掉，比如对象所在的3个副本的OSD挂掉，所以PG离线 |
| degraded | 降级状态。ceph有些对象的副本数目没有达到系统设置，一般是因为有OSD挂掉 |
| inconsistent | 不一致态。Ceph 清理和深度清理后检测到PG中的对象在副本存在不一致，例如对象的文件大小不一致或recovery结束后一个对象的副本丢失 |
| peering | 正在同步状态。PG正在执行同步处理 |
| recovering | 正在恢复状态。Ceph正在执行迁移或同步对象和他们的副本 |
| incomplete | 未完成状态。实际的副本数少于min_size。Ceph检测到PG正在丢失关于已经写操作的信息，或者没有任何健康的副本。如果遇到这种状态，尝试启动失败的OSD，这些OSD中可能包含需要的信息或者临时调整副本min_size的值到允许恢复。 |
| stale | 未刷新状态。PG状态没有被任何OSD更新，这说明所有存储这个PG的OSD可能down |
| backfilling | 正在后台填充状态。 当一个新的OSD加入集群后，Ceph通过移动一些其他OSD上的PG到新的OSD来达到新的平衡；这个过程完成后，这个OSD可以处理客户端的IO请求。 |
| remapped | 重新映射状态。PG活动集任何的一个改变，数据发生从老活动集到新活动集的迁移。在迁移期间还是用老的活动集中的主OSD处理客户端请求，一旦迁移完成新活动集中的主OSD开始处理。 |
- 正常是active+clean

## 2、stuck（卡住）状态的PG

- 遇到失败后PG进入如 “degraded” 或 “peering”的状态是正常的。通常这些状态指示失败恢复处理过程中的正常继续，如果PG长时间（mon_pg_stuck_threshold，默认为300s）出现如下状态时，MON会将该PG标记为stuck

| stuck状态 | 描述 |
|----------|-----|
| inactive | PG太长时间不在active态，例如PG长时间不能处理读写请求，通常是peering的问题 |
| unclean | PG太长时间不在clean态，例如PG不能完成从上一个失败的恢复，通常是unfound objects导致 |
| stale | PG状态未被OSD更新，表示所有存储PG的OSD可能挂掉，一般启动相应的OSD进程即可 |
| undersized | pg没有充足的osd来存储它应具有的副本数 |

默认情况下，Ceph会自动执行恢复，但如果未成自动恢复，则集群状态会一直处于HEALTH_WARN或者HEALTH_ERR

如果特定PG的所有osd都是down和out状态，则PG会被标记为stale。要解决这一情况，其中一个OSD必须要重生，且具有可用的PG副本，否则PG不可用

Ceph可以声明osd或PG已丢失，这也就意味着数据丢失。

需要说明的是，osd的运行离不开journal，如果journal丢失，则osd停止

## 3、管理stuck状态的PG
```
# 检查处于stuck状态的pg
# ceph pg  dump_stuck
ok
PG_STAT STATE         UP    UP_PRIMARY ACTING ACTING_PRIMARY 
17.5    stale+peering [0,2]          0  [0,2]              0 
17.4    stale+peering [2,0]          2  [2,0]              2 
17.3    stale+peering [2,0]          2  [2,0]              2 
17.2    stale+peering [2,0]          2  [2,0]              2 
17.1    stale+peering [0,2]          0  [0,2]              0 
17.0    stale+peering [2,0]          2  [2,0]              2 
17.1f   stale+peering [2,0]          2  [2,0]              2 
17.1e   stale+peering [0,2]          0  [0,2]              0 
17.1d   stale+peering [2,0]          2  [2,0]              2 
17.1c   stale+peering [0,2]          0  [0,2]              0 

# ceph osd blocked-by
osd num_blocked 
  0          19 
  2          13 
  
# 检查导致pg一直阻塞在peering 状态的osd
ceph osd blocked-by

# 检查某个pg的状态
ceph pg dump |grep pgid

# 声明pg丢失
ceph pg pgid mark_unfound_lost revert|delete

# 声明osd丢失（需要osd状态为down 且out）
ceph osd lost osdid --yes-i-really-mean-it
```

```
# ceph pg stat
# ceph pg dump -f json-pretty
# ceph pg <pg_id> query            # 查询特定pg的详细信息
```  

# pool管理

a) 查看pool状态
```
ceph osd  pool stats
ceph osd lspools
```
b）限制pool配置更改
```
# 禁止pool被删除
ceph tell osd.* injectargs --osd_pool_default_flag_nodelete true

# 禁止修改pool的pg_num和pgp_num 
ceph tell osd.* injectargs --osd_pool_default_flag_nopgchange true

# 禁止修改pool的size和min_size
ceph tell osd.* injectargs --osd_pool_default_flag_nosizechang true
```

# Ceph MDS的查看  
```
# ceph fs ls
# ceph mds stat
# ceph mds dump
```  



