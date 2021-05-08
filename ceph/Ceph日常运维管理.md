## 一、集群监控管理
集群整体运行状态
```
[root@cephnode01 ~]# ceph -s 
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

    id：集群ID
    health：集群运行状态，这里有一个警告，说明是有问题，意思是pg数大于pgp数，通常此数值相等。
    mon：Monitors运行状态。
    osd：OSDs运行状态。
    mgr：Managers运行状态。
    mds：Metadatas运行状态。
    pools：存储池与PGs的数量。
    objects：存储对象的数量。
    usage：存储的理论用量。
    pgs：PGs的运行状态
```
~]$ ceph -w
~]$ ceph health detail
```

### PG状态
查看pg状态查看通常使用下面两个命令即可，dump可以查看更详细信息，如。
```
# 查看pg组的映射信息
~]$ ceph pg dump

# 查看PG状态
~]$ ceph pg stat

# 查看一个PG的map
~]$ ceph pg map 0.3f 
osdmap e88 pg 0.3f (0.3f) -> up [0,2] acting [0,2] #其中的[0,2]代表存储在osd.0、osd.2节点，osd.0代表主副本的存储位置

# 查询一个pg的详细信息
~]$ ceph pg 0.26 query

# 查看pg中stuck的状态
~]$ ceph pg dump_stuck unclean 
ok 
~]$ ceph pg dump_stuck inactive 
ok 
~]$ ceph pg dump_stuck stale 
ok

# 显示一个集群中的所有的pg统计
ceph pg dump -format plain
```

### pg操作
```
# 恢复一个丢失的pg
ceph pg {pg-id} mark_unfound_lost revert

# 显示非正常状态的pg
ceph pg dump_stuck inactive|unclean|stale
```

### Pool状态
```
~]$ ceph osd pool stats
~]$ ceph osd pool stats 
```
### OSD状态
```
# 查看ceph osd运行状态
~]$ ceph osd stat

# 查看osd映射信息
~]$ ceph osd dump

查看osd的目录树
~]$ ceph osd tree

查看osd使用容量
~]$ ceph osd df
```

### osd操作
```
# down掉一个osd硬盘
~]$ ceph osd down 0      #down掉osd.0节点

# 在集群中删除一个osd硬盘
~]$ ceph osd rm 0 

# 在集群中删除一个osd 硬盘 crush map
~]$ ceph osd crush rm osd.0

# 在集群中删除一个osd的host节点
~]$ ceph osd crush rm node1 

# 查看最大osd的个数
~]$ ceph osd getmaxosd 

# 设置最大的osd的个数（当扩大osd节点的时候必须扩大这个值）
~]$ ceph osd setmaxosd 10

# 设置osd crush的权重为1.0
~]$ ceph osd crush set 3 1.0 host=node4
~]$ ceph osd crush reweight osd.3 1.0          # ceph osd crush set {id} {weight} [{loc1} [{loc2} …]]

# 设置osd的权重
~]$ ceph osd reweight 3 0.5

# 把一个osd节点逐出集群
~]$ ceph osd out osd.3


# 把逐出的osd加入集群
~]$ ceph osd in osd.3

# 暂停osd （暂停后整个集群不再接收数据）
~]$ ceph osd pause

# 再次开启osd （开启后再次接收数据）
~]$ ceph osd unpause

# 查看一个集群osd.2参数的配置
~]$ ceph –admin-daemon /var/run/ceph/ceph-osd.2.asok config show | less
```


### Monitor状态和查看仲裁状态
```
# 查看mon的状态信息
~]$ ceph mon stat

# 查看mon的映射信息
~]$ ceph mon dump

# 查看mon的选举状态
~]$ ceph quorum_status
```

### mon操作
```
# 删除一个mon节点
~]$ ceph mon remove node1 

# 获得一个正在运行的mon map，并保存在1.txt文件中
~]$ ceph mon getmap -o 1.txt 

# 查看上面获得的map
~]$ monmaptool -print 1.txt 

# 把上面的mon map注入新加入的节点
~]$ ceph-mon -i node4 –inject-monmap 1.txt

# 查看mon的amin socket
~]$ ceph-conf –name mon.node1 –show-config-value admin_socket

# 查看mon的详细状态
~]$ ceph daemon mon.node1 mon_status

# 删除一个mon节点
~]$ ceph mon remove os-node1
```



### 集群空间用量
```
~]$ ceph df
~]$ ceph df detail
```
## 二、集群配置管理(临时和全局，服务平滑重启)
有时候需要更改服务的配置，但不想重启服务，或者是临时修改。这时候就可以使用tell和daemon子命令来完成此需求。
### 1、查看运行配置
```
命令格式：
# ceph daemon {daemon-type}.{id} config show 

命令举例：
# ceph daemon osd.0 config show 
```
### 2、tell子命令格式
使用 tell 的方式适合对整个集群进行设置，使用 * 号进行匹配，就可以对整个集群的角色进行设置。而出现节点异常无法设置时候，只会在命令行当中进行报错，不太便于查找。
```
命令格式：
# ceph tell {daemon-type}.{daemon id or *} injectargs --{name}={value} [--{name}={value}]
命令举例：
# ceph tell osd.0 injectargs --debug-osd 20 --debug-ms 1

```
- daemon-type：为要操作的对象类型如osd、mon、mds等。
- daemon id：该对象的名称，osd通常为0、1等，mon为ceph -s显示的名称，这里可以输入*表示全部。
- injectargs：表示参数注入，后面必须跟一个参数，也可以跟多个


### 3、daemon子命令
使用 daemon 进行设置的方式就是一个个的去设置，这样可以比较好的反馈，此方法是需要在设置的角色所在的主机上进行设置。  
```
命令格式：
# ceph daemon {daemon-type}.{id} config set {name}={value}
命令举例：
# ceph daemon mon.ceph-monitor-1 config set mon_allow_pool_delete false
```
## 三、集群操作
命令包含start、restart、status
```
1、启动所有守护进程
# systemctl start ceph.target
2、按类型启动守护进程
# systemctl start ceph-mgr.target
# systemctl start ceph-osd@id
# systemctl start ceph-mon.target
# systemctl start ceph-mds.target
# systemctl start ceph-radosgw.target

```
## 四、添加和删除OSD
### 1、添加OSD

```
1、格式化磁盘
ceph-volume lvm zap /dev/sd<id>
2、进入到ceph-deploy执行目录/my-cluster，添加OSD
# ceph-deploy osd create --data /dev/sd<id> $hostname
```
### 2、删除OSD
```
1、调整osd的crush weight为 0
ceph osd crush reweight osd.<ID> 0.0
2、将osd进程stop
systemctl stop ceph-osd@<ID>
3、将osd设置out
ceph osd out <ID>
4、立即执行删除OSD中数据
ceph osd purge osd.<ID> --yes-i-really-mean-it
5、卸载磁盘
umount /var/lib/ceph/osd/ceph-？
```
## 五、扩容PG  
```
ceph osd pool set {pool-name} pg_num 128
ceph osd pool set {pool-name} pgp_num 128 
```
注：  
1、扩容大小取跟它接近的2的N次方  
2、在更改pool的PG数量时，需同时更改PGP的数量。PGP是为了管理placement而存在的专门的PG，它和PG的数量应该保持一致。如果你增加pool的pg_num，就需要同时增加pgp_num，保持它们大小一致，这样集群才能正常rebalancing。
## 六、Pool操作
### 列出存储池
```
ceph osd lspools
```
### 创建存储池
```
命令格式：
# ceph osd pool create {pool-name} {pg-num} [{pgp-num}]
命令举例：
# ceph osd pool create rbd  32 32
```
### 设置存储池配额
```
命令格式：
# ceph osd pool set-quota {pool-name} [max_objects {obj-count}] [max_bytes {bytes}]
命令举例：
# ceph osd pool set-quota rbd max_objects 10000
```
### 删除存储池
```
ceph osd pool delete {pool-name} [{pool-name} --yes-i-really-really-mean-it]
```
### 重命名存储池
```
ceph osd pool rename {current-pool-name} {new-pool-name}
```
### 查看存储池统计信息
```
rados df
```
### 给存储池做快照
```
ceph osd pool mksnap {pool-name} {snap-name}
```
### 删除存储池的快照
```
ceph osd pool rmsnap {pool-name} {snap-name}
```
### 获取存储池选项值
```
ceph osd pool get {pool-name} {key}
```
### 调整存储池选项值
```
ceph osd pool set {pool-name} {key} {value}
size：设置存储池中的对象副本数，详情参见设置对象副本数。仅适用于副本存储池。
min_size：设置 I/O 需要的最小副本数，详情参见设置对象副本数。仅适用于副本存储池。
pg_num：计算数据分布时的有效 PG 数。只能大于当前 PG 数。
pgp_num：计算数据分布时使用的有效 PGP 数量。小于等于存储池的 PG 数。
hashpspool：给指定存储池设置/取消 HASHPSPOOL 标志。
target_max_bytes：达到 max_bytes 阀值时会触发 Ceph 冲洗或驱逐对象。
target_max_objects：达到 max_objects 阀值时会触发 Ceph 冲洗或驱逐对象。
scrub_min_interval：在负载低时，洗刷存储池的最小间隔秒数。如果是 0 ，就按照配置文件里的 osd_scrub_min_interval 。
scrub_max_interval：不管集群负载如何，都要洗刷存储池的最大间隔秒数。如果是 0 ，就按照配置文件里的 osd_scrub_max_interval 。
deep_scrub_interval：“深度”洗刷存储池的间隔秒数。如果是 0 ，就按照配置文件里的 osd_deep_scrub_interval 。
```
### 获取对象副本数
```
ceph osd dump | grep 'replicated size'
```
## 七、用户管理
Ceph 把数据以对象的形式存于各存储池中。Ceph 用户必须具有访问存储池的权限才能够读写数据。另外，Ceph 用户必须具有执行权限才能够使用 Ceph 的管理命令。
### 1、查看用户信息
```
查看所有用户信息
# ceph auth list
获取所有用户的key与权限相关信息
# ceph auth get client.admin
如果只需要某个用户的key信息，可以使用pring-key子命令
# ceph auth print-key client.admin 
```
### 2、添加用户
```
# ceph auth add client.john mon 'allow r' osd 'allow rw pool=liverpool'
# ceph auth get-or-create client.paul mon 'allow r' osd 'allow rw pool=liverpool'
# ceph auth get-or-create client.george mon 'allow r' osd 'allow rw pool=liverpool' -o george.keyring
# ceph auth get-or-create-key client.ringo mon 'allow r' osd 'allow rw pool=liverpool' -o ringo.key
```
### 3、修改用户权限
```
# ceph auth caps client.john mon 'allow r' osd 'allow rw pool=liverpool'
# ceph auth caps client.paul mon 'allow rw' osd 'allow rwx pool=liverpool'
# ceph auth caps client.brian-manager mon 'allow *' osd 'allow *'
# ceph auth caps client.ringo mon ' ' osd ' '
```
### 4、删除用户
```
# ceph auth del {TYPE}.{ID}
其中， {TYPE} 是 client，osd，mon 或 mds 的其中一种。{ID} 是用户的名字或守护进程的 ID 。

```
## 八、增加和删除Monitor
一个集群可以只有一个 monitor，推荐生产环境至少部署 3 个。 Ceph 使用 Paxos 算法的一个变种对各种 map 、以及其它对集群来说至关重要的信息达成共识。建议（但不是强制）部署奇数个 monitor 。Ceph 需要 mon 中的大多数在运行并能够互相通信，比如单个 mon，或 2 个中的 2 个，3 个中的 2 个，4 个中的 3 个等。初始部署时，建议部署 3 个 monitor。后续如果要增加，请一次增加 2 个。  
### 1、新增一个monitor
```
# ceph-deploy mon create $hostname
注意：执行ceph-deploy之前要进入之前安装时候配置的目录。/my-cluster
```
### 2、删除Monitor
```
# ceph-deploy mon destroy $hostname
注意： 确保你删除某个 Mon 后，其余 Mon 仍能达成一致。如果不可能，删除它之前可能需要先增加一个。
```
  

