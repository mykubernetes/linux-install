# ceph osd reweight 和osd crush weight的区别

- osd crush weight
- osd weight
- crushtool 修改crushmap
- test

在执行ceph osd tree命令的时候显示内容里面会显示一个WEIGHT还有REWEIGHT，那它们到底是什么呢？
```
#  ceph osd tree
# 第二列对应osd crush weight，倒数第二列对应osd weight
ID  WEIGHT   TYPE NAME             UP/DOWN REWEIGHT PRIMARY-AFFINITY
-13  2.66554 root metadata
-14  1.00401     host xt7-metadata
 23  1.00000         osd.23             up  1.00000          1.00000
-15  1.05763     host xt6-metadata
 11  1.00000         osd.11             up  1.00000          1.00000
-16  0.60390     host xt8-metadata
 35  1.00000         osd.35             up  1.00000          1.00000
-12        0 root default
-11        0     host xt7-default
-10        0     host xt6-default
 -9        0     host xt8-default
 -8  2.90688 root ssd
 -7  0.79999     host xt7-ssd
 14  0.79999         osd.14             up  1.00000          1.00000
 -6  0.90689     host xt6-ssd
  2  1.00000         osd.2              up  1.00000          1.00000
 -5  1.20000     host xt8-ssd
 26  1.20000         osd.26             up  1.00000          1.00000
 -4 30.99991 root hdd
 -3  8.99994     host xt7-hdd
 12  0.79999         osd.12             up  1.00000          1.00000
 13  0.79999         osd.13             up  1.00000          1.00000
 15  0.79999         osd.15             up  1.00000          1.00000
 16  0.79999         osd.16             up  1.00000          1.00000
 17  0.79999         osd.17             up  0.70000          1.00000
 18  1.00000         osd.18             up  1.00000          1.00000
 19  1.00000         osd.19             up  1.00000          1.00000
 20  1.00000         osd.20             up  1.00000          1.00000
 21  1.00000         osd.21             up  1.00000          1.00000
 22  1.00000         osd.22             up  1.00000          1.00000
 -2 10.00000     host xt6-hdd
 0  1.00000         osd.0              up  1.00000          1.00000
 1  1.00000         osd.1              up  1.00000          1.00000
 3  1.00000         osd.3              up  1.00000          1.00000
 4  1.00000         osd.4              up  1.00000          1.00000
 5  1.00000         osd.5              up  1.00000          1.00000
 6  1.00000         osd.6              up  1.00000          1.00000
 7  1.00000         osd.7              up  1.00000          1.00000
 8  1.00000         osd.8              up  1.00000          1.00000
 9  1.00000         osd.9              up  1.00000          1.00000
 10  1.00000         osd.10             up  1.00000          1.00000
 -1 11.99997     host xt8-hdd
 24  1.20000         osd.24             up  1.00000          1.00000
 25  1.20000         osd.25             up  1.00000          1.00000
 27  1.20000         osd.27             up  1.00000          1.00000
 28  1.20000         osd.28             up  1.00000          1.00000
 29  1.20000         osd.29             up  1.00000          1.00000
 30  1.20000         osd.30             up  1.00000          1.00000
 31  1.20000         osd.31             up  1.00000          1.00000
 32  1.20000         osd.32             up  1.00000          1.00000
 33  1.20000         osd.33             up  1.00000          1.00000
 34  1.20000         osd.34             up  1.00000          1.00000
```

# osd crush weight

Crush weight实际上为bucket item weight，下面是关于bucket item weight的描述：
```
Weighting Bucket Items
Ceph expresses bucket weights as doubles, which allows for fine weighting. A weight is the relative difference between device capacities. We recommend using 1.00 as the relative weight for a 1TB storage device. In such a scenario, a weight of 0.5 would represent approximately 500GB, and a weight of 3.00 would represent approximately 3TB. Higher level buckets have a weight that is the sum total of the leaf items aggregated by the bucket.
A bucket item weight is one dimensional, but you may also calculate your item weights to reflect the performance of the storage drive. For example, if you have many 1TB drives where some have relatively low data transfer rate and the others have a relatively high data transfer rate, you may weight them differently, even though they have the same capacity (e.g., a weight of 0.80 for the first set of drives with lower total throughput, and 1.20 for the second set of drives with higher total throughput).

“ceph osd crush reweight” sets the CRUSH weight of the OSD. This weight is an arbitrary value (generally the size of the disk in TB or something) and controls how much data the system tries to allocate to the OSD.
```

简单来说，bucket weight表示设备(device)的容量，1TB对应1.00，500G对应0.5，bucket weight是所有item weight之和，item weight的变化会影响bucket weight的变化，也就是osd.X会影响host。对与它的调整会立即重新分配pg,迁移数据，这个值一般在刚init 万osd的时候根据osd的容量进行设置。

Command:
```
ceph osd crush reweight osd.1 1.2
```

# osd weight

Osd weight的取值为0~1。osd reweight并不会影响host。当osd被踢出集群时，osd weight被设置0，加入集群时，设置为1。
```
“ceph osd reweight” sets an override weight on the OSD. This value is in the range 0 to 1, and forces CRUSH to re-place (1-weight) of the data that would otherwise live on this drive. It does *not* change the weights assigned to the buckets above the OSD, and is a corrective measure in case the normal CRUSH distribution isn’t working out quite right. (For instance, if one of your OSDs is at 90% and the others are at 50%, you could reduce this weight to try and compensate for it.)

Note that ‘ceph osd reweight’ is not a persistent setting. When an OSD gets marked out, the osd weight will be set to 0. When it gets marked in again, the weight will be changed to 1.
Because of this ‘ceph osd reweight’ is a temporary solution. You should only use it to keep your cluster running while you’re ordering more hardware.
```

osd weight 也会立即重新分配pg,并且会把 (USE_DATA * (1-weight))的数据重新分配地方，进行数据的在线迁移，一般用于osd near full 或者 osd full 时临时把这个值调低，给集群加盘扩容操作（删除不用的数据也是一种常见的方式）。

Command:
```
ceph osd reweight 1 0.7
```

# 使用crushtool 来修改crushmap：

获取当前的crushmap:
```
ceph osd getcrushmap -o crushmap.bin
```

列出某个pool的使用情况和副本数：
```
ceph osd dump | grep '^pool 0'
```

对crushmap进行反编译：
```
curshtool -d crushmap.bin -o crushmap.txt
```

进行修改：
```
vim crushmap.txt

host xt1-hdd {
    id -1       # do not change unnecessarily
    # weight 2.500
    alg straw
    hash 0  # rjenkins1
    item osd.1 weight 1.500  //修改这两个值，注意这里面只能修改item weight
    item osd.0 weight 1.500
}
```

重新编译新的crushmap：
```
crushtool -c crushmap.txt -o crushmap-new.bin
```

将新的CRUSH map 应用到ceph 集群中:
```
ceph osd setcrushmap -i crushmap-new.bin
```

```
ceph osd df
ID WEIGHT  REWEIGHT SIZE   USE   AVAIL  %USE  VAR  PGS
 2 1.00000  1.00000  7668M  959M  6709M 12.52 1.29 166
 3 1.00000  0.70000  7668M  528M  7140M  6.89 0.71  90
 1 1.50000  1.00000  7668M  920M  6748M 12.00 1.23 141
 0 1.50000  1.00000  7668M  572M  7096M  7.46 0.77 132
              TOTAL 30675M 2980M 27695M  9.72
MIN/MAX VAR: 0.71/1.29  STDDEV: 2.53
```


# 测试: ceph osd crush reweight

1、测试之前：
```
ceph health detail
HEALTH_OK

ceph pg dump pgs_brief | less
pg_stat     state        up   up_primary   acting  acting_primary
9.6b     active+clean    [3,0]     3         [3,0]       3
10.68    active+clean    [0,3]     0         [0,3]       0
10.1f   active+clean  [2,1]    2       [2,1]   2

ceph osd df
ID WEIGHT  REWEIGHT SIZE   USE   AVAIL  %USE  VAR  PGS
 2 1.00000  1.00000  7668M  719M  6949M  9.38 0.97 119
 3 1.00000  1.00000  7668M  754M  6914M  9.84 1.02 137
 1 1.00000  1.00000  7668M  646M  7022M  8.42 0.87 121
 0 1.00000  1.00000  7668M  836M  6832M 10.91 1.13 135
              TOTAL 30675M 2956M 27719M  9.64
MIN/MAX VAR: 0.87/1.13  STDDEV: 0.89

sh /ws/dump_pg.sh
pool :    9    10    | SUM
--------------------------------
osd.0    71    64    | 135
osd.1    57    64    | 121
osd.2    63    56    | 119
osd.3    65    72    | 137
--------------------------------
SUM :    256    256    |
```

2、以osd.1为例，它上面有121个pg, 并且观察它和pg 10.1f变化，它之前在[2,1]上面,而且它下面有个对象是：
```
ceph osd map cephfs_data 10000002213.00000015
osdmap e1148 pool 'cephfs_data' (10) object '10000002213.00000015' -> pg 10.553f4b1f (10.1f) -> up ([2,1], p2) acting ([2,1], p2)

ls /var/lib/ceph/osd/xtao-1/current/10.1f_head/10000002213.00000015__head_553F4B1F__a
-rw-r--r-- 1 root root 4.0M 7月  19 21:36 10000002213.00000015__head_553F4B1F__a
```

3、接下来开始实验：修改osd.1的crush weight 到 1.5
```
ceph osd crush reweight osd.1 1.5
reweighted item id 1 name 'osd.1' to 1.5 in crush map

ceph health detail
HEALTH_ERR 35 pgs are stuck inactive for more than 300 seconds; 1 pgs backfill_wait; 14 pgs degraded; 9 pgs peering; 35 pgs stuck inactive; 38 pgs stuck unclean; recovery 5/912 objects degraded (0.548%); recovery 4/912 objects misplaced (0.439%)
pg 10.9 is stuck inactive for 371.069851, current state activating+remapped, last acting [3,0]

pg 9.4d is stuck inactive for 424.559393, current state activating+remapped, last acting [1,2]
pg 10.1f is stuck inactive for 371.326352, current state activating+remapped, last acting [2,1]
pg 9.25 is stuck inactive for 583.209478, current state activating, last acting [1,2]
pg 10.1f is stuck unclean for 371.326495, current state activating+remapped, last acting [2,1]
pg 9.4d is stuck unclean for 424.559540, current state activating+remapped, last acting [1,2]
pg 9.7d is stuck unclean for 387.550744, current state activating+remapped, last acting [3,1]
pg 9.4c is stuck unclean for 378.600928, current state activating+remapped, last acting [3,0]
...
pg 10.2a is peering, acting [1,3]
pg 9.29 is activating+degraded, acting [3,1]
pg 10.2e is peering, acting [1,2]
pg 10.32 is activating+degraded, acting [1,3]
pg 10.39 is peering, acting [1,2]
pg 9.3a is activating+degraded, acting [2,1]
pg 10.6f is peering, acting [1,2]
pg 10.7d is active+degraded, acting [0,2]
pg 9.f is activating+degraded, acting [2,1]
pg 9.c is activating+degraded, acting [3,1]
recovery 5/912 objects degraded (0.548%)
recovery 4/912 objects misplaced (0.439%)
```
pg 10.1f 状态改变成了 activating+remapped

等到remap + peering完成之后：
```
ceph pg dump pgs_brief | less
pg_stat     state         up   up_primary   acting  acting_primary
10.1f   active+clean  [0,2]    0       [0,2]      0

pg 10.1f的actiing发生了改变：[2,1] -—> [0,2]

ceph osd df --cluster xtao
ID WEIGHT  REWEIGHT SIZE   USE   AVAIL  %USE  VAR  PGS
 2 1.00000  1.00000  7668M  716M  6952M  9.34 0.97 118
 3 1.00000  1.00000  7668M  768M  6900M 10.02 1.04 138
 1 1.50000  1.00000  7668M  912M  6756M 11.90 1.23 162
 0 1.00000  1.00000  7668M  568M  7100M  7.41 0.77  94
              TOTAL 30675M 2964M 27711M  9.66
MIN/MAX VAR: 0.77/1.23  STDDEV: 1.60

osd 1上面的数据变多了： 646M —> 912M


sh /ws/dump_pg.sh
pool :    9    10    | SUM
--------------------------------
osd.0    48    46    | 94
osd.1    80    82    | 162
osd.2    62    56    | 118
osd.3    66    72    | 138
--------------------------------
SUM :    256    256    |

osd 1上面的pg变多了：121 --> 162
```

# 测试: ceph osd reweight

继上面结结果继续测试：
```
ceph osd reweight 3 0.7

eph pg dump pgs_brief --cluster xtao |less
pg_stat     state         up      up_primary      acting  acting_primary
 9.6b    active+clean    [3,0]        3            [3,0]        3

ceph health detail --cluster xtao
HEALTH_ERR 48 pgs are stuck inactive for more than 300 seconds; 5 pgs degraded; 34 pgs peering; 48 pgs stuck inactive
pg 9.39 is stuck inactive for 46841.599332, current state remapped+peering, last acting [3,1]
pg 10.55 is stuck inactive for 47017.191571, current state activating+degraded, last acting [0,2]
pg 9.3e is stuck inactive for 46817.170840, current state remapped+peering, last acting [1,3]
pg 9.7 is stuck inactive for 46841.604976, current state activating+remapped, last acting [0,3]
pg 9.43 is stuck inactive for 46774.034149, current state remapped+peering, last acting [3,1]
pg 10.73 is stuck inactive for 46970.796402, current state remapped+peering, last acting [1,3]
pg 10.46 is stuck inactive for 47000.825895, current state remapped+peering, last acting [1,3]
pg 10.17 is stuck inactive for 47057.230433, current state activating+degraded, last acting [0,2]
pg 10.3c is stuck inactive for 47007.838808, current state remapped+peering, last acting [1,3]
pg 9.44 is stuck inactive for 46841.600278, current state remapped+peering, last acting [3,1]
pg 9.75 is stuck inactive for 46770.993348, current state remapped+peering, last acting [3,1]
pg 9.4b is stuck inactive for 1194759.272957, current state activating+degraded, last acting [0,2]
pg 9.48 is stuck inactive for 46841.600050, current state activating, last acting [0,2]
pg 10.4b is stuck inactive for 46817.057872, current state remapped+peering, last acting [3,1]
pg 9.8 is stuck inactive for 46841.602502, current state remapped+peering, last acting [1,3]
pg 9.6b is stuck inactive for 935534.199493, current state activating+remapped, last acting [0,3]
pg 9.61 is stuck inactive for 46841.598176, current state activating+remapped, last acting [0,3]

ceph osd df --cluster xtao
ID WEIGHT  REWEIGHT SIZE   USE   AVAIL  %USE  VAR  PGS
 2 1.00000  1.00000  7668M  962M  6706M 12.56 1.29 166
 3 1.00000  0.70000  7668M  528M  7140M  6.89 0.71  90
 1 1.50000  1.00000  7668M  917M  6751M 11.97 1.23 159
 0 1.00000  1.00000  7668M  566M  7102M  7.39 0.76  97
              TOTAL 30675M 2975M 27700M  9.70
MIN/MAX VAR: 0.71/1.29  STDDEV: 2.56

osd.3的数据量减少：768M —> 528M,数据量变为了原来的68.75% 

sh /ws/dump_pg.sh
dumped all in format plain

pool :    9    10    | SUM
--------------------------------
osd.0    49    48    | 97
osd.1    79    80    | 159
osd.2    88    78    | 166
osd.3    40    50    | 90
--------------------------------
SUM :    256    256    |

可以看到osd.3上面的pg个数减少：138 --> 90
```
