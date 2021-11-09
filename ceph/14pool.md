# 一、部分概念
池是ceph存储集群的逻辑分区，用于存储对象

对象存储到池中时，使用CRUSH规则将该对象分配到池中的一个PG，PG根据池的配置和CRUSH算法自动映射一组OSD池中PG数量对性能有重要影响。通常而言，池应当配置为每个OSD包含的100-200个归置组

创建池时。ceph会检查每个OSD的PG数量是否会超过200.如果超过，ceph不会创建这个池。ceph3.0安装时不创建存储池。


# 二、存储池（复制池）

## 2.1 创建复制池

| 参数 | 描述 |
|------|------|
| pool-name | 存储池的名称 |
| pg-num | 存储池的pg总数 |
| pgp-num | 存储池的pg的有效数，通常与pg相等 |
| replicated | 指定为复制池，即使不指定，默认也是创建复制池 |
| crush-ruleset-name | 用于这个池的crush规则的名字，默认为osd_pool_default_crush_replicated_ruleset |
| expected-num-objects | 池中预期的对象数量。如果事先知道这个值，ceph可于创建池时在OSD的文件系统上准备文件夹结构。否则，ceph会在运行时重组目录结构，因为对象数量会有所增加。这种重组一会带来延迟影响 |

```
ceph osd pool create <pool-name> <pg-num> [pgp-num] [replicated] [crush-ruleset-name] [expected-num-objects]
```

```
# 创建pool
 ceph osd pool create testpool 128
pool 'testpool' created

# 没有写的参数即使用默认值
# ceph -s
    pools:   1 pools, 128 pgs
    objects: 0 objects,  0 bytes


# 查询集群有哪些pool
# ceph osd pool ls
testpool
# ceph osd lspools 

# ceph df
GLOBAL:
    SIZE       AVAIL      RAW USED     %RAW USED 
    134G        133G          968M          0.70 
POOLS:
    NAME                                    ID     USED        %USED     MAX AVAIL     OBJECTS 
    testpool                                1         0            0        43421M           0 
```
- 注：创建了池后，无法减少PG的数量，只能增加

如果创建池时不指定副本数量，则默认为3，可通过osd_pool_default_size参数修改，还可以通过如下命令修改：`ceph osd pool set pool-name size  number-of-replicas osd_pool_default_min_size`参数可用于设置最对象可用的最小副本数，默认为2

查看pool属性
```
# ceph osd pool get testpool all
size: 3
min_size: 2
crash_replay_interval: 0
pg_num: 128
pgp_num: 128
crush_rule: replicated_rule
hashpspool: true
nodelete: false
nopgchange: false
nosizechange: false
write_fadvise_dontneed: false
noscrub: false
nodeep-scrub: false
use_gmt_hitset: 1
auid: 0
fast_read: 0
expected_num_objects: 0
```

## 2.2 为池启用ceph应用

- 创建池后，必须显式指定能够使用它的ceph应用类型：（ceph块设备 ceph对象网关 ceph文件系统）
- 如果不显示指定类型，集群将显示HEALTH_WARN状态（使用ceph health detail命令查看）

1、指定池为块设备
```
# ceph osd pool application enable testpool rbd
enabled application 'rbd' on pool 'testpool'

# ceph osd pool ls detail
pool 1 'testpool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 33 flags hashpspool stripe_width 0 application rbd
```
- replicated size: 副本数
- min_size: 最小的副本数
- crush_rule： crush规则的id
- pg_num: pg数量
- pgp_num: pgp数量
- application: 存储池类型

## 2.3、查看某个pool的pg和pgp个数
```
# ceph osd pool get testpool pg_num
pg_num: 128

# ceph osd pool get testool  pgp_num
```

## 2.4、设置某个pool的pg和pgp个数
```
# ceph osd pool set testpool pg_num 512
# ceph osd pool set testpool pgp_num 512
```

## 2.5、修改pool中对象的副本数
```
# ceph osd pool set testpool size 5
set pool 1 size to 5
```

## 2.6、查看所有pool的状态
```
# ceph osd pool stats
pool rbd id 0
  nothing is going on

pool volumes id 369
  client io 0 B/s rd, 264 kB/s wr, 44 op/s rd, 55 op/s wr

pool testpool id 1
  nothing is going on
```
- pool后面是pool的名称，比如rbd、volumes等，id后面是pool的id。
- io表示的是客户端使用这个pool的io情况，B/s rd表示读的速率，kB/s wr表示写速度；op/s rd表示读的iops，op/s wr表示写的iops

## 2.7、查看单个pool的状态
```
# ceph osd pool stats testpool
pool testpool id 1
  nothing is going on
```

## 2.8、获取pool的配额信息
```
# ceph osd pool get-quota testpool
quotas for pool 'testpool':
  max objects: N/A
  max bytes  : N/A
```
- max objects: 最大对象数，默认为N/A，表示不限制
- max bytes: 最大空间，默认为N/A，表示不限制

## 2.9、设置配额
```
# ceph osd pool set-quota testpool max_bytes 1048576
set-quota max_bytes = 1048576 for pool testpool

# ceph osd pool set-quota testpool max_bytes 0
set-quota max_bytes = 0 for pool testpool
```

## 2.10、池的重命名
```
# ceph osd pool rename testpool mytestpool
pool 'testpool' renamed to 'mytestpool'

# ceph osd pool ls
mytestpool
```

#  数据处理

## 1、往pool中上传对象
```
# rados -p testpool put object-data /root/anaconda-ks.cfg 
```

## 2、列出pool中的对象
```
# rados -p testpool ls
object-data
```

## 3、查看数据内容，只能下载后查看
```
rados -p testpool get test /root/111
```

## 4、查看osd map信息
```
# ceph osd map testpool object-data
osdmap e42 pool 'testpool' (1) object 'object-data' -> pg 1.c9cf1b74 (1.74) -> up ([2,0,1], p2) acting ([2,0,1], p2)
```
- osdmap e42: 表示osdmap的版本是42
- pool 'pool-frank6866': 表示pool的名称是pool-frank6866
- (1): 表示pool的id是1
- object 'object-data': 表示对象名是object-data
- pg 1.c9cf1b74 (1.74): 表示对象所属pg的id是1.74,c9cf1b74表示的是对象的id
- up ([2,0,1], p2): 这里副本数设置的是3,up表示该对象所在的osd的id


## 4.1、查找id为2的osd所在的主机
```
# ceph osd find 2
{
    "osd": 2,
    "ip": "10.10.10.77:6800\/20546",
    "crush_location": {
        "host": "ceph-3",
        "root": "default"
    }
}
```

## 4.2、登录osd所在主机上查看挂载的目录信息:
```
# df -lTh /var/lib/ceph/osd/ceph-2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb1      xfs    45G   68M   45G   1% /var/lib/ceph/osd/ceph-2
```

## 4.3、根据pg id查看该pg存放数据的地方:
```
# ls -al /var/lib/ceph/osd/ceph-2/current | grep 1.74
drwxr-xr-x   2 ceph ceph    67 Jun  3 17:20 1.74_head
drwxr-xr-x   2 ceph ceph     6 Jun  3 16:53 1.74_TEMP
```

## 4.4、查看pg所在目录的结构:
```
# tree /var/lib/ceph/osd/ceph-2/current/1.74_head/
/var/lib/ceph/osd/ceph-2/current/1.74_head/
├── __head_00000074__1
└── object-data__head_C9CF1B74__1
```

# 池的快照

## 1、创建池快照
```
#  ceph osd pool mksnap testpool  testpool-snap-20190316
created pool testpool snap testpool-snap-20190316

#  rados lssnap -p testpool
1    testpool-snap-20190316    2019.03.16 22:27:34
1 snaps
```

## 2、再上传一个数据
```
# rados -p testpool put test2 /root/anaconda-ks.cfg
# rados -p testpool ls
test2
test
```
- 使用快照的场景：（防止误删除，防止误修改，防止新增错误文件）

## 3、ceph针对文件回退
```
# ceph osd pool mksnap testpool testpool-snap-2
created pool testpool snap testpool-snap-2

# rados lssnap -p  testpool
1    testpool-snap-20190316    2019.03.16 22:27:34
2    testpool-snap-2    2019.03.16 22:31:15
2 snaps
```

## 4、文件删除并恢复
```
# rados -p testpool rm test

# rados -p testpool get test /root/333
error getting testpool/test: (2) No such file or directory

# rados -p testpool -s testpool-snap-2 get test /root/444
selected snap 2 'testpool-snap-2'

# ll /root/444                                    #可以直接从444恢复test文件
-rw-r--r-- 1 root root 7317 Mar 16 22:34 /root/444

# 从快照中还原
# rados -p testpool rollback test testpool-snap-2
rolled back pool testpool to snapshot testpool-snap-2

# rados -p testpool get test /root/555

# diff /root/444 /root/555    #对比文件没有区别，还原成功 
```

## 配置池属性
```
#  ceph osd pool get testpool min_size
min_size: 2

# ceph osd pool set testpool min_size 1
set pool 1 min_size to 1

#  ceph osd pool get testpool min_size
min_size: 1

# ceph osd pool set testpool min_size 2
set pool 1 min_size to 2

#  ceph osd pool get testpool min_size
min_size: 2
```

# 三、存储池（纠删码池）

纠删码池使用擦除纠删码而不是复制来保护对象数据。当将一个对象存储在纠删码池中时，该对象被划分为许多数据块，这些数据块存储在单独的OSDs中。此外，还根据数据块计算了大量的纠删码块，并将其存储在不同的osd中。如果包含块的OSD失败，可以使用纠删码块来重构对象的数据。

纠删码池与复制池不同，它不依赖于存储每个对象的多个完整副本。

每个对象的数据被分成k个数据块,计算了m个编码块大小与数据块大小相同的纠删码块,对象存储在总共k + m 个OSDS上。

提示：纠删码池比复制池需要更少的存储空间来获得类似级别的数据保护。可以降低存储集群的成本和大小。然而，计算纠删码块会增加CPU和内存开销，从而降低纠删码池的性能。此外，在Red Hat Ceph Storage 3中，需要部分对象写的操作不支持擦除编码池。目前纠删码池的使用限制在执行完整对象写入和追加的应用程序中，比如Ceph对象网关。即Red Hat Ceph存储目前只支持通过Ceph对象网关访问的纠删码池。

| 参数 | 含义 | 
|-----|-----|
| k | 跨osd分割的数据块的数量，默认值是2。  |
| m | 数据变得不可用之前可能失败的osd的数量，默认为1。  |
| directory | 默认值是/usr/1ib64/ceph/erasure-code，算法插件库的路径。  |
| plugin | 默认值是jerasure，通常有本地可修复擦除代码(LRC)和ISA(仅限Intel)。  |
| crush-failure-domain | 定义CRUSH故障域，该域控制块的位置。默认情况下，设置为host，这确保对象的块被放置在不同的主机上。如果设置为osd，则对象的块可以放在同一主机上的osd上。将故障域设置为osd的弹性较小，因为如果主机失败，主机上的所有osd都将失败。还可以定义其他故障域，并使用它们来确保将块放在数据中心不同机架上的主机上的OSDs上，或者进行其他类型的定制。 |
| crush-device-class | 此可选参数仅为池选择由该类设备支持的OSDs。典型的类可能包括hdd、ssd或nvme。 |
| crush-root | 这个可选参数设置压碎规则集的根节点。 |
| key=value | 插件可能具有该插件特有的键值参数。 |
| technique | technique为每个插件都提供了一组实现不同算法的不同技术。对于Jerasure插件，默认的技术是reed_sol_van。其他包括:reed_sol_r6_op、cauchy_orig、cauchy_good、liberation、blaum_roth和liber8tion。 |


1、列出现有的纠删码策略
```
# ceph osd erasure-code-profile ls
default
```
	
2、查看指定纠删码策略的详细内容
```
# ceph osd erasure-code-profile get default
k=2
m=1
plugin=jerasure
technique=reed_sol_van
```

3、创建一个纠删码策略
```
# ceph osd erasure-code-profile set hdd-3-2 k=3 m=2 crush-device-class=hdd crush-failure-domain=osd
```
- crush-device-class: 设备分类
- crush-failure-domain: 故障域

4、创建一个纠删码池
- 命令：`ceph osd pool create pool-name pg-num [pgp-num] erasure [erasure-code-profile] [crush-ruleset-name] [expected-num-objects]`
```
ceph osd pool create hdd-3-2-erasure 128 128 erasure hdd-3-2
```
- pool-name：池名称；
- pg-num：池中的pg总数；
- pgp-num：池的有效放置组数。通常，这应该等于pg的总数。
- erasure：指定这是一个纠删码池，如果不包含在命令中，则默认是复制池。
- erasure-code-profile：指定是要使用的配置文件。可以使用ceph osd erasure-code-profile创建新的配置文件，配置文件定义要使用的k和m值以及erasure插件。
- crush-ruleset-name是：用于此池的CRUSH名称。如果没有设置，Ceph将使用erasure-code-profile文件中定义。

```
# ceph osd pool ls
testpool
hdd-3-2-erasure

# ceph osd pool ls detail
pool 1 'testpool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 42 flags hashpspool stripe_width 0 application rbd
    snap 1 'testpool-snap-20190316' 2019-03-16 22:27:34.150433
    snap 2 'testpool-snap-2' 2019-03-16 22:31:15.430823
pool 2 'hdd-3-2-erasure' erasure size 5 min_size 4 crush_rule 1 object_hash rjenkins pg_num 128 pgp_num 128 last_change 46 flags hashpspool stripe_width 12288
```

5、查看hdd-3-2纠删码策略
```
ceph osd erasure-code-profile get hdd-3-2-erasure
crush-device-class=hdd
crush-failure-domain=osd
crush-root=default
jerasure-per-chunk-alignment=false
k=3
m=2
plugin=jerasure
technique=reed_sol_van
w=8
```

6、修改hdd-3-2纠删码策略
```
ceph osd erasure-code-profile set hdd-3-2-erasure k=4
```

7、删除纠删码策略
```
ceph osd erasure-code-profile rm hdd-3-2
```

8、查看所有参数
```
ceph osd pool get hdd-3-2-erasure all
size: 5
min_size: 4
crash_replay_interval: 0
pg_num: 128
pgp_num: 128
crush_rule: hdd-3-2
hashpspool: true
nodelete: false
nopgchange: false
nosizechange: false
write_fadvise_dontneed: false
noscrub: false
nodeep-scrub: false
use_gmt_hitset: 1
auid: 0
erasure_code_profile: hdd-3-2
```

其他
```
ceph osd pool ls
ceph osd pool ls detail
ceph osd pool stats ceph125-erasure
```

查看纠删码池状态
```
# ceph osd dump |grep -i EC-pool
pool 2 'EC-pool' erasure size 5 min_size 4 crush_rule 1 object_hash rjenkins pg_num 64 pgp_num 64 last_change 46 flags hashpspool stripe_width 12288
```

添加数据到纠删码池
```
# rados -p EC-pool ls
# rados -p EC-pool put object1 hello.txt
```

查看数据状态
```
# ceph osd map EC-pool object1
```

## 删除pool
```
# 编辑配置文件可以删除存储池
# vim /etc/ceph/ceph.conf
...
[mon]
mon_allow_pool_delete = true
...

# 重启服务
# systemctl restart ceph-mon.target

# 删除pool
# ceph osd pool delete poolname poolname --yes-i-really-really-mean-it
```
