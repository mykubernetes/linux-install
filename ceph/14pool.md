# pool管理
介绍pool管理相关的命令

## 创建pool
```
# ceph osd pool create pool-frank6866 128
pool 'pool-frank6866' created
```

## 列出所有pool
```
# ceph osd pool ls
rbd
pool-frank6866
```

也可以查看pool的详细信息:  

```
# ceph osd pool ls detail
pool 0 'rbd' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 64 pgp_num 64 last_change 1 flags hashpspool stripe_width 0
pool 1 'pool-frank6866' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 37 flags hashpspool stripe_width 0
```
* replicated size: 副本数
* min_size: 最小的副本数
* pg_num: pg数量	

## 查看某个pool的pg个数
查看名为pool-frank6866的pool中pg的个数

```
# ceph osd pool get pool-frank6866 pg_num
pg_num: 128
```

## 修改pool中对象的副本数
将pool-frank6866的副本数设置为5

```
# ceph osd pool set pool-frank6866 size 5
set pool 1 size to 5
```

## 查看所有pool的状态
```
# ceph osd pool stats
pool rbd id 0
  nothing is going on

pool volumes id 369
  client io 0 B/s rd, 264 kB/s wr, 44 op/s rd, 55 op/s wr

pool images id 370
  nothing is going on

pool vms id 371
  nothing is going on
```
* pool后面是pool的名称，比如rbd、volumes等，id后面是pool的id。
* io表示的是客户端使用这个pool的io情况，B/s rd表示读的速率，kB/s wr表示写速度；op/s rd表示读的iops，op/s wr表示写的iops

## 获取pool的配额信息

```
# ceph osd pool get-quota volumes
quotas for pool 'volumes':
  max objects: N/A
  max bytes  : N/A
```
* max objects: 最大对象数，默认为N/A，表示不限制
* max bytes: 最大空间，默认为N/A，表示不限制

## 往pool中上传对象
```
# dd if=/dev/zero of=data.img bs=1M count=32
# rados -p pool-frank6866 put object-data data.img
```

## 列出pool中的对象

```
# rados -p pool-frank6866 ls
object-data
```

```
# ceph osd map pool-frank6866 object-data
osdmap e42 pool 'pool-frank6866' (1) object 'object-data' -> pg 1.c9cf1b74 (1.74) -> up ([2,0,1], p2) acting ([2,0,1], p2)
```
* osdmap e42: 表示osdmap的版本是42
* pool 'pool-frank6866': 表示pool的名称是pool-frank6866
* (1): 表示pool的id是1
* object 'object-data': 表示对象名是object-data
* pg 1.c9cf1b74 (1.74): 表示对象所属pg的id是1.74,c9cf1b74表示的是对象的id
* up ([2,0,1], p2): 这里副本数设置的是3,up表示该对象所在的osd的id



查找id为2的osd所在的主机
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


登录osd所在主机上查看挂载的目录信息:
```
# df -lTh /var/lib/ceph/osd/ceph-2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb1      xfs    45G   68M   45G   1% /var/lib/ceph/osd/ceph-2
```

根据pg id查看该pg存放数据的地方:
```
# ls -al /var/lib/ceph/osd/ceph-2/current | grep 1.74
drwxr-xr-x   2 ceph ceph    67 Jun  3 17:20 1.74_head
drwxr-xr-x   2 ceph ceph     6 Jun  3 16:53 1.74_TEMP
```

查看pg所在目录的结构:
```
# tree /var/lib/ceph/osd/ceph-2/current/1.74_head/
/var/lib/ceph/osd/ceph-2/current/1.74_head/
├── __head_00000074__1
└── object-data__head_C9CF1B74__1
```


纠删码池概述
---
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



1、列出现有的 erasure-code-profile 规则
```
# ceph osd erasure-code-profile ls
default
```
	
2、查看指定erasure-code-profile 规则的详细内容：
```
# ceph osd erasure-code-profile get default
k=2
m=1
plugin=jerasure
technique=reed_sol_van
```
	
3、自定义erasure-code-profile ， 创建一个只用hdd的 erasure-code-profile, 故障转移域为osd级别
```
# ceph osd erasure-code-profile set hdd-3-2 k=3 m=2 crush-device-class=hdd crush-failure-domain=osd
```
- crush-device-class（设备分类）
- crush-failure-domain（故障域）

4、创建一个纠删码池名字为ceph125-erasure 的池 使用ceph125策略

命令：`ceph osd pool create pool-name pg-num [pgp-num] erasure [erasure-code-profile] \[crush-ruleset-name] [expected-num-objects]`
```
ceph osd pool create hdd-3-2-erasure 128 128 erasure hdd-3-2
```
- pool-name：池名称；
- pg-num：池中的pg总数；
- pgp-num：池的有效放置组数。通常，这应该等于pg的总数。
- erasure：指定这是一个纠删码池，如果不包含在命令中，则默认是复制池。
- erasure-code-profile：指定是要使用的配置文件。可以使用ceph osd erasure-code-profile创建新的配置文件，配置文件定义要使用的k和m值以及erasure插件。
- crush-ruleset-name是：用于此池的CRUSH名称。如果没有设置，Ceph将使用erasure-code-profile文件中定义。


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