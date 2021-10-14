# 检查集群的信息

查看看池
```
# ceph osd pool ls
images          #只有一个池
```

查看硬盘状态
```
# ceph osd tree
ID CLASS WEIGHT  TYPE NAME        STATUS REWEIGHT PRI-AFF 
-1       0.13129 root default                             
-5       0.04376     host serverc                         
 2   hdd 0.01459         osd.2        up  1.00000 1.00000      #9块osd状态up in状态
 3   hdd 0.01459         osd.3        up  1.00000 1.00000 
 7   hdd 0.01459         osd.7        up  1.00000 1.00000 
-3       0.04376     host serverd                         
 0   hdd 0.01459         osd.0        up  1.00000 1.00000 
 5   hdd 0.01459         osd.5        up  1.00000 1.00000 
 6   hdd 0.01459         osd.6        up  1.00000 1.00000 
-7       0.04376     host servere                         
 1   hdd 0.01459         osd.1        up  1.00000 1.00000 
 4   hdd 0.01459         osd.4        up  1.00000 1.00000 
 8   hdd 0.01459         osd.8        up  1.00000 1.00000 
```

重现错误
```
# ceph osd pool create images 64 64
# ceph osd pool application enable images rbd

# ceph -s
 cluster:
    id:     04b66834-1126-4870-9f32-d9121f1baccd
    health: HEALTH_WARN
            too few PGs per OSD (21 < min 30)
  services:
    mon: 3 daemons, quorum serverc,serverd,servere
    mgr: servere(active), standbys: serverd, serverc
    osd: 9 osds: 9 up, 9 in
  data:
    pools:   1 pools, 64 pgs
    objects: 8 objects, 12418 kB
    usage:   1005 MB used, 133 GB / 134 GB avail
    pgs:     64 active+clean
```

查看pg映射
```
# ceph pg dump
dumped all
version 1334
stamp 2019-03-29 22:21:41.795511
last_osdmap_epoch 0
last_pg_scan 0
full_ratio 0
nearfull_ratio 0
PG_STAT OBJECTS MISSING_ON_PRIMARY DEGRADED MISPLACED UNFOUND BYTES   LOG DISK_LOG STATE        STATE_STAMP                VERSION REPORTED UP      UP_PRIMARY ACTING  ACTING_PRIMARY LAST_SCRUB SCRUB_STAMP                LAST_DEEP_SCRUB DEEP_SCRUB_STAMP           
1.3f          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.871318     0'0    33:41 [7,1,0]          7 [7,1,0]              7        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.3e          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.867341     0'0    33:41 [4,5,7]          4 [4,5,7]              4        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.3d          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.871213     0'0    33:41 [0,3,1]          0 [0,3,1]              0        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.3c          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.859216     0'0    33:41 [5,7,1]          5 [5,7,1]              5        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.3b          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.870865     0'0    33:41 [0,8,7]          0 [0,8,7]              0        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.3a          2                  0        0         0       0      19  17       17 active+clean 2019-03-29 22:17:34.858977   33'17   33:117 [4,6,7]          4 [4,6,7]              4        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.39          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.871027     0'0    33:41 [0,3,4]          0 [0,3,4]              0        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.38          1                  0        0         0       0      16   1        1 active+clean 2019-03-29 22:17:34.861985    30'1    33:48 [4,2,5]          4 [4,2,5]              4        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.37          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.861667     0'0    33:41 [6,7,1]          6 [6,7,1]              6        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.36          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.860382     0'0    33:41 [6,3,1]          6 [6,3,1]              6        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.35          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.860407     0'0    33:41 [8,6,2]          8 [8,6,2]              8        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.34          0                  0        0         0       0       0   2        2 active+clean 2019-03-29 22:17:34.861874    32'2    33:44 [4,3,0]          4 [4,3,0]              4        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.33          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.860929     0'0    33:41 [4,6,2]          4 [4,6,2]              4        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
1.32          0                  0        0         0       0       0   0        0 active+clean 2019-03-29 22:17:34.860589     0'0    33:41 [4,2,6]          4 [4,2,6]              4        0'0 2019-03-29 21:55:07.534833             0'0 2019-03-29 21:55:07.534833 
…………                          
1 8 0 0 0 0 12716137 78 78                             
sum 8 0 0 0 0 12716137 78 78 
OSD_STAT USED  AVAIL  TOTAL  HB_PEERS          PG_SUM PRIMARY_PG_SUM 
8         119M 15229M 15348M [0,1,2,3,4,5,6,7]     22              6 
7         119M 15229M 15348M [0,1,2,3,4,5,6,8]     22              9 
6         119M 15229M 15348M [0,1,2,3,4,5,7,8]     23              5 
5         107M 15241M 15348M [0,1,2,3,4,6,7,8]     18              7 
4         107M 15241M 15348M [0,1,2,3,5,6,7,8]     18              9 
3         107M 15241M 15348M [0,1,2,4,5,6,7,8]     23              6 
2         107M 15241M 15348M [0,1,3,4,5,6,7,8]     19              6 
1         107M 15241M 15348M [0,2,3,4,5,6,7,8]     24              8 
0         107M 15241M 15348M [1,2,3,4,5,6,7,8]     23              8 
sum      1005M   133G   134G 
```
- 由提示看出，每个osd上的pg数量小于最小的数目30个。是因为在创建池的时候，指定pg和pgs为64，由于是3副本的配置，所以当有9个osd的时候，每个osd上均分了64/9 *3=21个pgs,也就是出现了如上的错误 小于最小配置30个。从pg dump看出每块osd上的PG数，都小于30

- 集群这种状态如果进行数据的存储和操作，会发现集群卡死，无法响应io，同时会导致大面积的osd down。

# 解决办法

修改pool的pg数
```
# ceph osd pool set images pg_num 128
set pool 1 pg_num to 128

# ceph -s
 cluster:
    id:     04b66834-1126-4870-9f32-d9121f1baccd
    health: HEALTH_WARN
            Reduced data availability: 21 pgs peering
            Degraded data redundancy: 21 pgs unclean
            1 pools have pg_num > pgp_num
            too few PGs per OSD (21 < min 30)
 
  services:
    mon: 3 daemons, quorum serverc,serverd,servere
    mgr: servere(active), standbys: serverd, serverc
    osd: 9 osds: 9 up, 9 in
 
  data:
    pools:   1 pools, 128 pgs
    objects: 8 objects, 12418 kB
    usage:   1005 MB used, 133 GB / 134 GB avail
    pgs:     50.000% pgs unknown
             16.406% pgs not active
             64 unknown
             43 active+clean
             21 peering
```
- 出现 too few PGs per OSD

继续修改PGS
```
# ceph osd pool set images pgp_num 128
set pool 1 pgp_num to 128
```


查看
```
# ceph -s
  cluster:
    id:     04b66834-1126-4870-9f32-d9121f1baccd
    health: HEALTH_WARN
            Reduced data availability: 7 pgs peering
            Degraded data redundancy: 24 pgs unclean, 2 pgs degraded
  services:
    mon: 3 daemons, quorum serverc,serverd,servere
    mgr: servere(active), standbys: serverd, serverc
    osd: 9 osds: 9 up, 9 in
  data:
    pools:   1 pools, 128 pgs
    objects: 8 objects, 12418 kB
    usage:   1005 MB used, 133 GB / 134 GB avail
    pgs:     24.219% pgs not active       #pg状态，数据在重平衡（状态信息代表的意义，请参考https://www.cnblogs.com/zyxnhr/p/10616497.html第三部分内容）
             97 active+clean
             20 activating
             9  peering
             2  activating+degraded


# ceph -s
  cluster:
    id:     04b66834-1126-4870-9f32-d9121f1baccd
    health: HEALTH_WARN
            Reduced data availability: 7 pgs peering
            Degraded data redundancy: 3/24 objects degraded (12.500%), 33 pgs unclean, 4 pgs degraded
  services:
    mon: 3 daemons, quorum serverc,serverd,servere
    mgr: servere(active), standbys: serverd, serverc
    osd: 9 osds: 9 up, 9 in
  data:
    pools:   1 pools, 128 pgs
    objects: 8 objects, 12418 kB
    usage:   1005 MB used, 133 GB / 134 GB avail
    pgs:     35.938% pgs not active
             3/24 objects degraded (12.500%)
             79 active+clean
             34 activating
             9  peering
             3  activating+degraded
             2  active+clean+snaptrim
             1  active+recovery_wait+degraded 
  io:
    recovery: 1 B/s, 0 objects/s


# ceph -s
  cluster:
    id:     04b66834-1126-4870-9f32-d9121f1baccd
    health: HEALTH_OK
  services:
    mon: 3 daemons, quorum serverc,serverd,servere
    mgr: servere(active), standbys: serverd, serverc
    osd: 9 osds: 9 up, 9 in
  data:
    pools:   1 pools, 128 pgs
    objects: 8 objects, 12418 kB
    usage:   1050 MB used, 133 GB / 134 GB avail
    pgs:     128 active+clean
  io:
    recovery: 1023 kB/s, 0 keys/s, 0 objects/s
[root@serverc ~]# ceph -s
  cluster:
    id:     04b66834-1126-4870-9f32-d9121f1baccd
    health: HEALTH_OK             #数据平衡完毕，集群状态恢复正常
  services:
    mon: 3 daemons, quorum serverc,serverd,servere
    mgr: servere(active), standbys: serverd, serverc
    osd: 9 osds: 9 up, 9 in
  data:
    pools:   1 pools, 128 pgs
    objects: 8 objects, 12418 kB
    usage:   1016 MB used, 133 GB / 134 GB avail
    pgs:     128 active+clean
  io:
    recovery: 778 kB/s, 0 keys/s, 0 objects/s
```
