Ceph Mon 负责监测健康状况整个集群的状态，以及维护集群成员资格状态，对等节点状态和集群配置信息。Ceph监视器通过维护集群映射的主副本来执行这些任务。cluster map 包括 monitor maps ， OSD maps 、 PG map 、 Crush map 、 MDS map 。所有这些 map统称为
cluster maps。


monitor map
---
它包含关于监视器节点的端到端信息，包括Ceph集群ID、监视器主机名和带有端口号的IP地址。它还存储用于创建map的当前纪元和最后更改的时间。
```
# ceph mon dump
dumped monmap epoch 1
epoch 1
fsid bc8b9fe7-18de-4dc5-ac07-6ca0ee22966a
last_changed 2019-04-28 13:09:54.705974
created 2019-04-28 13:09:54.705974
0: 192.168.20.176:6789/0 mon.c720176
1: 192.168.20.177:6789/0 mon.c720177
2: 192.168.20.178:6789/0 mon.c720178
```

OSD map
---
它存储一些常见字段，如集群ID、用于创建OSD映射和最后更改的历元，以及与池相关的信息，如池名称、池ID、类型、复制级别和PGs。它还存储OSD信息，如计数、状态、权重、最后一次清洁间隔和OSD主机信息。
```
# ceph osd dump
epoch 62
fsid bc8b9fe7-18de-4dc5-ac07-6ca0ee22966a
created 2019-04-28 13:10:16.058337
modified 2019-04-28 18:33:38.245516
flags sortbitwise,recovery_deletes,purged_snapdirs
crush_version 8
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.85
require_min_compat_client jewel
min_compat_client jewel
require_osd_release luminous
pool 1 'rbd' replicated size 3 min_size 2 crush_rule 0 object_hash rjenk ins pg_num 32 pgp_num 32 last_change 11 flags hashpspool stripe_width 0
...
osd.0 up in weight 1 up_from 24 up_thru 58 down_at 23 last_clean_inte rval [16,19) 192.168.20.176:6804/4332 192.168.30.176:6804/4332 192.168.30.176:6805/4332 192.168.20.176:6805/4332 exists,up 6109c11f-fac6-4c7d-a2b9-673176e32da9
osd.1 up in weight 1 up_from 23 up_thru 61 down_at 0 last_clean_inter val [0,0) 192.168.20.177:6800/3938 192.168.30.177:6800/3938 192.168.30.177:6801/3938 192.168.20.177:6802/3938 exists,up 4f7d9f58-d2d0-4ca1-9f5a-e96767e2ca79
...
```

PG map
---
它包含PG版本、时间戳、最后的OSD map纪元、完整比例和接近完整比例的信息。它还跟踪每个PGID、对象计数、状态、状态戳、up和代理OSD集，最后是擦除细节。
```
# ceph pg dump
dumped all
version 10247
stamp 2019-04-28 20:39:49.514994
last_osdmap_epoch 0
last_pg_scan 0
full_ratio 0
nearfull_ratio 0
PG_STAT OBJECTS MISSING_ON_PRIMARY DEGRADED MISPLACED UNFOUND BYTES LOG DISK_LOG STATE        STATE_STAMP                VERSION REPORTED UP     UP_PRIMARY ACTING ACTING_PRIMARY LAST_SCRUB SCRUB_STAMP                LAST_DEEP_SCRUB DEEP_SCRUB_STAMP SNAPTRIMQ_LEN
6.12          0                  0        0         0       0     0   0        0 active+clean 2019-04-28 15:05:13.658306     0'0    61:30 [5,4,6]         5 [5,4,6]             5        0'0 2019-04-28 15:05:11.648880                              0'0 2019-04-28 15:05:11.648880 0
1.15          0                  0        0         0       0     0   0        0 active+clean 2019-04-28 14:59:57.127233     0'0    61:70 [1,5,0]         1 [1,5,0]             1        0'0 2019-04-28 14:28:16.404335                              0'0 2019-04-28 14:28:16.404335 0
...
sum 210 0 0 0 0 3817 12602 12602
OSD_STAT USED    AVAIL   TOTAL   HB_PEERS          PG_SUM PRIMARY_PG_SUM
8        1.01GiB 19.0GiB 20.0GiB [0,1,2,3,4,5,6,7]     66             20
5        1.01GiB 19.0GiB 20.0GiB [0,1,2,3,4,6,7,8]     65             22
2        1.01GiB 19.0GiB 20.0GiB [0,1,3,4,5,6,7,8]     61             13
7        1.01GiB 19.0GiB 20.0GiB [0,1,2,3,4,5,6,8]     79             32
6        1.01GiB 19.0GiB 20.0GiB [0,1,2,3,4,5,7,8]     77             25
4        1.01GiB 19.0GiB 20.0GiB [0,1,2,3,5,6,7,8]     61             21
3        1.01GiB 19.0GiB 20.0GiB [0,1,2,4,5,6,7,8]     74             25
1        1.01GiB 19.0GiB 20.0GiB [0,2,3,4,5,6,7,8]     76             22
0        1.01GiB 19.0GiB 20.0GiB [1,2,3,4,5,6,7,8]     65             28
sum 9.07GiB 171GiB 180GiB
```


crush map
---
它保存关于集群设备、存储桶、故障域层次结构和存储数据时为故障域定义的规则的信息。要检查集群rush map，请执行以下操作
```
# ceph osd crush dump
{
    "devices": [
        {
            "id": 0,
            "name": "osd.0",
            "class": "hdd"
        },
...
    ],
    "types": [
       {
           "type_id": 0,
           "name": "osd"
       },
...
    ],
    "buckets": [
        {
            "id": -1,
            "name": "default",
            "type_id": 10,
            "type_name": "root",
            "weight": 23001,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -3,
                    "weight": 7667,
                    "pos": 0
                },
                {
                    "id": -5,
                    "weight": 7667,
                    "pos": 1
                },
                {
                    "id": -7,
                    "weight": 7667,
                    "pos": 2
            }
        ]
    },
...
    ],
    "rules": [
...
    ],
    "tunables": {
...
    "has_v5_rules": 0
    },
    "choose_args": {}
}
```

MDS map
---
它存储关于当前MDS地图历元、map创建和修改时间、数据和元数据池ID、集群MDS计数和MDS状态的信息。要检查集群MDS映射，请执行以下操作:
```
# ceph mds dump
dumped fsmap epoch 8
fs_name cephfs
epoch 7
flags c
created 2019-04-28 15:05:34.239364
modified 2019-04-28 15:05:36.356797
tableserver 0
root 0
session_timeout 60
session_autoclose 300
max_file_size 1099511627776
last_failure 0
last_failure_osd_epoch 0
compat compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,8=no anchor table,9=file layout v2}
max_mds 1
in 0
up {0=74143}
failed
damaged
stopped
data_pools [6]
metadata_pool 7
inline_data disabled
balancer
standby_count_wanted 1
74143: 192.168.20.177:6807/3064475320 'c720177' mds.0.6 up:active seq 10
```
