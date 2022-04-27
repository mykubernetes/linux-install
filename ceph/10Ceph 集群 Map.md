# 一、理解Cluster Map

cluster map由monitor维护，用于跟踪ceph集群状态

当client启动时，会连接monitor获取cluster map副本，发现所有其他组件的位置，然后直接与所需的进程通信，以存储和检索数据

monitor跟踪这些集群组件的状态，也负责管理守护进程和客户端之间的身份验证

cluster map实际是多种map的集群，包含：monitor map、osd map、pg map、mds map、mgr map、service map

## 1.1 Clisuter Map内容
- monitor map：包含集群ID、monitor节点名称、IP以及端口号以及monitor map的版本号
- OSD map：包含集群ID、自身的版本号以及存储池相关的信息，包括存储池名称、ID、类型、副本级别和PG。还包括OSD的信息，比如数量、状态、权限以及OSD节点信息
- PG map：包含PG的版本、时间戳、OSD map的最新版本号、容量相关的百分比。还记录了每个PG的ID、对象数量、状态、状态时间戳等
- MDS map：包含MDS的地址、状态、数据池和元数据池的ID
- MGR map：包含MGR的地址和状态，以及可用和已启用模块的列表
- service map：跟踪通过librados部署的一些服务的实例，如RGW、rbd-mirror等。service map收集这些服务的信息然后提供给其他服务，如MGR的dashboard插件使用该map报告这些客户端服务的状态



# 1.2  Cluster Map基本查询

## 查询mon map
```
# ceph mon dump
dumped monmap epoch 1
epoch 1
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
last_changed 2019-03-16 12:39:14.839999
created 2019-03-16 12:39:14.839999
0: 172.25.250.11:6789/0 mon.ceph2
1: 172.25.250.12:6789/0 mon.ceph3
2: 172.25.250.13:6789/0 mon.ceph4
```

## 查询osd map
```
# ceph osd dump
epoch 281
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
created 2019-03-16 12:39:22.552356
modified 2019-03-26 22:32:15.354383
flags sortbitwise,recovery_deletes,purged_snapdirs
crush_version 43
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.85
require_min_compat_client jewel
min_compat_client jewel
require_osd_release luminous
pool 1 'testpool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 190 flags hashpspool stripe_width 0 application rbd
    snap 1 'testpool-snap-20190316' 2019-03-16 22:27:34.150433
    snap 2 'testpool-snap-2' 2019-03-16 22:31:15.430823
pool 5 'rbd' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 last_change 191 flags hashpspool stripe_width 0 application rbd
    removed_snaps [1~13]
pool 6 'rbdmirror' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 last_change 192 flags hashpspool stripe_width 0 application rbd
    removed_snaps [1~7]
pool 7 '.rgw.root' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 176 flags hashpspool stripe_width 0 application rgw
pool 8 'default.rgw.control' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 178 flags hashpspool stripe_width 0 application rgw
pool 9 'default.rgw.meta' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 180 flags hashpspool stripe_width 0 application rgw
pool 10 'default.rgw.log' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 182 flags hashpspool stripe_width 0 application rgw
pool 11 'xiantao.rgw.control' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 194 owner 18446744073709551615 flags hashpspool stripe_width 0 application rgw
pool 12 'xiantao.rgw.meta' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 196 owner 18446744073709551615 flags hashpspool stripe_width 0 application rgw
pool 13 'xiantao.rgw.log' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 198 owner 18446744073709551615 flags hashpspool stripe_width 0 application rgw
pool 14 'cephfs_metadata' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 last_change 214 flags hashpspool stripe_width 0 application cephfs
pool 15 'cephfs_data' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 214 flags hashpspool stripe_width 0 application cephfs
pool 16 'test' replicated size 3 min_size 2 crush_rule 3 object_hash rjenkins pg_num 32 pgp_num 32 last_change 280 flags hashpspool stripe_width 0 application rbd
pool 17 'ssdpool' replicated size 3 min_size 2 crush_rule 4 object_hash rjenkins pg_num 32 pgp_num 32 last_change 281 flags hashpspool stripe_width 0 application rbd
max_osd 9
osd.0 up   in  weight 1 up_from 54 up_thru 264 down_at 53 last_clean_interval [7,51) 172.25.250.11:6800/185671 172.25.250.11:6801/185671 172.25.250.11:6802/185671 172.25.250.11:6803/185671 exists,up 745dce53-1c63-4c50-b434-d441038dafe4
osd.1 up   in  weight 1 up_from 187 up_thru 258 down_at 184 last_clean_interval [54,186) 172.25.250.13:6809/60269 172.25.250.13:6807/1060269 172.25.250.13:6803/1060269 172.25.250.13:6813/1060269 exists,up a7562276-6dfd-4803-b248-a7cbdb64ebec
osd.2 up   in  weight 1 up_from 258 up_thru 264 down_at 257 last_clean_interval [54,257) 172.25.250.12:6804/59201 172.25.250.12:6810/8059201 172.25.250.12:6811/8059201 172.25.250.12:6815/8059201 exists,up bbef1a00-3a31-48a0-a065-3a16b9edc3b1
osd.3 up   in  weight 1 up_from 54 up_thru 272 down_at 53 last_clean_interval [13,51) 172.25.250.11:6804/185668 172.25.250.11:6805/185668 172.25.250.11:6806/185668 172.25.250.11:6807/185668 exists,up e934a4fb-7125-4e85-895c-f66cc5534ceb
osd.4 up   in  weight 1 up_from 187 up_thru 267 down_at 184 last_clean_interval [54,186) 172.25.250.13:6805/60272 172.25.250.13:6802/1060272 172.25.250.13:6810/1060272 172.25.250.13:6811/1060272 exists,up e2c33bb3-02d2-4cce-85e8-25c419351673
osd.5 up   in  weight 1 up_from 261 up_thru 275 down_at 257 last_clean_interval [54,258) 172.25.250.12:6808/59198 172.25.250.12:6806/8059198 172.25.250.12:6807/8059198 172.25.250.12:6814/8059198 exists,up d299e33c-0c24-4cd9-a37a-a6fcd420a529
osd.6 up   in  weight 1 up_from 54 up_thru 273 down_at 52 last_clean_interval [21,51) 172.25.250.11:6808/185841 172.25.250.11:6809/185841 172.25.250.11:6810/185841 172.25.250.11:6811/185841 exists,up debe7f4e-656b-48e2-a0b2-bdd8613afcc4
osd.7 up   in  weight 1 up_from 187 up_thru 266 down_at 184 last_clean_interval [54,186) 172.25.250.13:6801/60271 172.25.250.13:6806/1060271 172.25.250.13:6808/1060271 172.25.250.13:6812/1060271 exists,up 8c403679-7530-48d0-812b-72050ad43aae
osd.8 up   in  weight 1 up_from 151 up_thru 265 down_at 145 last_clean_interval [54,150) 172.25.250.12:6800/59200 172.25.250.12:6801/7059200 172.25.250.12:6802/7059200 172.25.250.12:6805/7059200 exists,up bb73edf8-ca97-40c3-a727-d5fde1a9d1d9
```


## 查询osd crush map
```
# ceph osd  crush dump
{
    "devices": [
        {
            "id": 0,
            "name": "osd.0",
            "class": "hdd"
        },
        {
            "id": 1,
            "name": "osd.1",
            "class": "hdd"
        },
        {
            "id": 2,
            "name": "osd.2",
            "class": "hdd"
        },
        {
            "id": 3,
            "name": "osd.3",
            "class": "hdd"
        },
        {
            "id": 4,
            "name": "osd.4",
            "class": "hdd"
        },
        {
            "id": 5,
            "name": "osd.5",
            "class": "hdd"
        },
        {
            "id": 6,
            "name": "osd.6",
            "class": "hdd"
        },
        {
            "id": 7,
            "name": "osd.7",
            "class": "hdd"
        },
        {
            "id": 8,
            "name": "osd.8",
            "class": "hdd"
        }
    ],
    "types": [
        {
            "type_id": 0,
            "name": "osd"
        },
        {
            "type_id": 1,
            "name": "host"
        },
        {
            "type_id": 2,
            "name": "chassis"
        },
        {
            "type_id": 3,
            "name": "rack"
        },
        {
            "type_id": 4,
            "name": "row"
        },
        {
            "type_id": 5,
            "name": "pdu"
        },
        {
            "type_id": 6,
            "name": "pod"
        },
        {
            "type_id": 7,
            "name": "room"
        },
        {
            "type_id": 8,
            "name": "datacenter"
        },
        {
            "type_id": 9,
            "name": "region"
        },
        {
            "type_id": 10,
            "name": "root"
        },
        {
            "type_id": 11,
            "name": "aaa"
        }
    ],
    "buckets": [
        {
            "id": -1,
            "name": "default",
            "type_id": 10,
            "type_name": "root",
            "weight": 8649,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -3,
                    "weight": 2883,
                    "pos": 0
                },
                {
                    "id": -5,
                    "weight": 2883,
                    "pos": 1
                },
                {
                    "id": -7,
                    "weight": 2883,
                    "pos": 2
                }
            ]
        },
        {
            "id": -2,
            "name": "default~hdd",
            "type_id": 10,
            "type_name": "root",
            "weight": 5898,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -4,
                    "weight": 1966,
                    "pos": 0
                },
                {
                    "id": -6,
                    "weight": 1966,
                    "pos": 1
                },
                {
                    "id": -8,
                    "weight": 1966,
                    "pos": 2
                }
            ]
        },
        {
            "id": -3,
            "name": "ceph2",
            "type_id": 1,
            "type_name": "host",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 3,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": 6,
                    "weight": 983,
                    "pos": 1
                }
            ]
        },
        {
            "id": -4,
            "name": "ceph2~hdd",
            "type_id": 1,
            "type_name": "host",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 3,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": 6,
                    "weight": 983,
                    "pos": 1
                }
            ]
        },
        {
            "id": -5,
            "name": "ceph4",
            "type_id": 1,
            "type_name": "host",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 4,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": 7,
                    "weight": 983,
                    "pos": 1
                }
            ]
        },
        {
            "id": -6,
            "name": "ceph4~hdd",
            "type_id": 1,
            "type_name": "host",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 4,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": 7,
                    "weight": 983,
                    "pos": 1
                }
            ]
        },
        {
            "id": -7,
            "name": "ceph3",
            "type_id": 1,
            "type_name": "host",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 5,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": 8,
                    "weight": 983,
                    "pos": 1
                }
            ]
        },
        {
            "id": -8,
            "name": "ceph3~hdd",
            "type_id": 1,
            "type_name": "host",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 5,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": 8,
                    "weight": 983,
                    "pos": 1
                }
            ]
        },
        {
            "id": -9,
            "name": "dc1",
            "type_id": 10,
            "type_name": "root",
            "weight": 11796,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -10,
                    "weight": 2949,
                    "pos": 0
                },
                {
                    "id": -11,
                    "weight": 8847,
                    "pos": 1
                },
                {
                    "id": -12,
                    "weight": 0,
                    "pos": 2
                }
            ]
        },
        {
            "id": -10,
            "name": "rack1",
            "type_id": 3,
            "type_name": "rack",
            "weight": 2949,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -3,
                    "weight": 2949,
                    "pos": 0
                }
            ]
        },
        {
            "id": -11,
            "name": "rack2",
            "type_id": 3,
            "type_name": "rack",
            "weight": 2949,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -7,
                    "weight": 2949,
                    "pos": 0
                }
            ]
        },
        {
            "id": -12,
            "name": "rack3",
            "type_id": 3,
            "type_name": "rack",
            "weight": 2949,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -5,
                    "weight": 2949,
                    "pos": 0
                }
            ]
        },
        {
            "id": -13,
            "name": "rack3~hdd",
            "type_id": 3,
            "type_name": "rack",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -6,
                    "weight": 1966,
                    "pos": 0
                }
            ]
        },
        {
            "id": -14,
            "name": "rack2~hdd",
            "type_id": 3,
            "type_name": "rack",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -8,
                    "weight": 1966,
                    "pos": 0
                }
            ]
        },
        {
            "id": -15,
            "name": "rack1~hdd",
            "type_id": 3,
            "type_name": "rack",
            "weight": 1966,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -4,
                    "weight": 1966,
                    "pos": 0
                }
            ]
        },
        {
            "id": -16,
            "name": "dc1~hdd",
            "type_id": 10,
            "type_name": "root",
            "weight": 5898,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -15,
                    "weight": 1966,
                    "pos": 0
                },
                {
                    "id": -14,
                    "weight": 1966,
                    "pos": 1
                },
                {
                    "id": -13,
                    "weight": 1966,
                    "pos": 2
                }
            ]
        },
        {
            "id": -17,
            "name": "ceph2-ssd",
            "type_id": 1,
            "type_name": "host",
            "weight": 983,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 0,
                    "weight": 983,
                    "pos": 0
                }
            ]
        },
        {
            "id": -18,
            "name": "ceph3-ssd",
            "type_id": 1,
            "type_name": "host",
            "weight": 983,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 2,
                    "weight": 983,
                    "pos": 0
                }
            ]
        },
        {
            "id": -19,
            "name": "ceph4-ssd",
            "type_id": 1,
            "type_name": "host",
            "weight": 983,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 1,
                    "weight": 983,
                    "pos": 0
                }
            ]
        },
        {
            "id": -20,
            "name": "ssd-root",
            "type_id": 10,
            "type_name": "root",
            "weight": 2949,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -17,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": -18,
                    "weight": 983,
                    "pos": 1
                },
                {
                    "id": -19,
                    "weight": 983,
                    "pos": 2
                }
            ]
        },
        {
            "id": -21,
            "name": "ceph2-ssd~hdd",
            "type_id": 1,
            "type_name": "host",
            "weight": 983,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 0,
                    "weight": 983,
                    "pos": 0
                }
            ]
        },
        {
            "id": -22,
            "name": "ssd-root~hdd",
            "type_id": 10,
            "type_name": "root",
            "weight": 2949,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -21,
                    "weight": 983,
                    "pos": 0
                },
                {
                    "id": -24,
                    "weight": 983,
                    "pos": 1
                },
                {
                    "id": -23,
                    "weight": 983,
                    "pos": 2
                }
            ]
        },
        {
            "id": -23,
            "name": "ceph4-ssd~hdd",
            "type_id": 1,
            "type_name": "host",
            "weight": 983,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 1,
                    "weight": 983,
                    "pos": 0
                }
            ]
        },
        {
            "id": -24,
            "name": "ceph3-ssd~hdd",
            "type_id": 1,
            "type_name": "host",
            "weight": 983,
            "alg": "straw2",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 2,
                    "weight": 983,
                    "pos": 0
                }
            ]
        }
    ],
    "rules": [
        {
            "rule_id": 0,
            "rule_name": "replicated_rule",
            "ruleset": 0,
            "type": 1,
            "min_size": 1,
            "max_size": 10,
            "steps": [
                {
                    "op": "take",
                    "item": -1,
                    "item_name": "default"
                },
                {
                    "op": "chooseleaf_firstn",
                    "num": 0,
                    "type": "host"
                },
                {
                    "op": "emit"
                }
            ]
        },
        {
            "rule_id": 2,
            "rule_name": "replicated1_rule",
            "ruleset": 2,
            "type": 1,
            "min_size": 1,
            "max_size": 11,
            "steps": [
                {
                    "op": "take",
                    "item": -1,
                    "item_name": "default"
                },
                {
                    "op": "chooseleaf_firstn",
                    "num": 0,
                    "type": "host"
                },
                {
                    "op": "emit"
                }
            ]
        },
        {
            "rule_id": 3,
            "rule_name": "indc1",
            "ruleset": 3,
            "type": 1,
            "min_size": 1,
            "max_size": 10,
            "steps": [
                {
                    "op": "take",
                    "item": -9,
                    "item_name": "dc1"
                },
                {
                    "op": "chooseleaf_firstn",
                    "num": 0,
                    "type": "rack"
                },
                {
                    "op": "emit"
                }
            ]
        },
        {
            "rule_id": 4,
            "rule_name": "ssdrule",
            "ruleset": 4,
            "type": 1,
            "min_size": 1,
            "max_size": 10,
            "steps": [
                {
                    "op": "take",
                    "item": -20,
                    "item_name": "ssd-root"
                },
                {
                    "op": "chooseleaf_firstn",
                    "num": 0,
                    "type": "host"
                },
                {
                    "op": "emit"
                }
            ]
        }
    ],
    "tunables": {
        "choose_local_tries": 0,
        "choose_local_fallback_tries": 0,
        "choose_total_tries": 50,
        "chooseleaf_descend_once": 1,
        "chooseleaf_vary_r": 1,
        "chooseleaf_stable": 1,
        "straw_calc_version": 1,
        "allowed_bucket_algs": 54,
        "profile": "jewel",
        "optimal_tunables": 1,
        "legacy_tunables": 0,
        "minimum_required_version": "jewel",
        "require_feature_tunables": 1,
        "require_feature_tunables2": 1,
        "has_v2_rules": 0,
        "require_feature_tunables3": 1,
        "has_v3_rules": 0,
        "has_v4_buckets": 1,
        "require_feature_tunables5": 1,
        "has_v5_rules": 0
    },
    "choose_args": {}
}
```

## 查询pg map
```
# ceph pg dump|more
dumped all
version 4724
stamp 2019-03-28 14:25:04.562309
last_osdmap_epoch 0
last_pg_scan 0
full_ratio 0
nearfull_ratio 0
PG_STAT OBJECTS MISSING_ON_PRIMARY DEGRADED MISPLACED UNFOUND BYTES    LOG  DISK_LOG STATE        STATE_STAMP                VERSION    REPORTED   UP      UP_PRIMARY ACTING  ACTING_PRIMARY LAST_SCRUB SCRUB_STAMP   
             LAST_DEEP_SCRUB DEEP_SCRUB_STAMP           
15.71         0                  0        0         0       0        0    0        0 active+clean 2019-03-28 13:36:32.993398        0'0    349:100 [1,8,3]          1 [1,8,3]              1        0'0 2019-03-27 20:
08:33.926844             0'0 2019-03-27 20:08:33.926844 
1.7f          0                  0        0         0       0        0    0        0 active+clean 2019-03-28 13:36:33.579411        0'0    349:505 [8,7,6]          8 [8,7,6]              8        0'0 2019-03-27 13:
28:11.129286             0'0 2019-03-21 00:37:48.245632 
15.70         0                  0        0         0       0        0    0        0 active+clean 2019-03-28 13:36:33.014554        0'0    349:118 [3,1,8]          3 [3,1,8]              3        0'0 2019-03-28 01:
50:35.263257             0'0 2019-03-26 17:10:19.390530 
1.7e          0                  0        0         0       0        0    0        0 active+clean 2019-03-28 13:36:34.401107        0'0     349:18 [6,4,8]          6 [6,4,8]              6        0'0 2019-03-27 13:
28:30.900982             0'0 2019-03-24 06:16:20.594466 
15.73         0                  0        0         0       0        0    0        0 active+clean 2019-03-28 11:47:32.722556        0'0    349:107 [2,4,3]          2 [2,4,3]              2        0'0 2019-03-28 01:
43:48.489676             0'0 2019-03-26 17:10:19.390530 
1.7d          0                  0        0         0       0        0    0        0 active+clean 2019-03-28 11:47:32.509177        0'0    349:611 [3,2,7]          3 [3,2,7]              3        0'0 2019-03-27 16:
42:45.842781             0'0 2019-03-24 00:45:38.159371 
15.72         0                  0        0         0       0        0    0        0 active+clean 2019-03-28 13:34:53.428161        0'0    349:128 [2,4,6]          2 [2,4,6]              2        0'0 2019-03-27 23:
17:37.129695             0'0 2019-03-26 17:10:19.390530 
1.7c          0                  0        0         0       0        0    0        0 active+clean 2019-03-28 13:36:31.590563        0'0     349:18 [7,2,6]          7 [7,2,6]              7        0'0 2019-03-28 08:
02:05.697728             0'0 2019-03-27 05:33:02.267544 
15.75         0                  0        0         0       0        0    0        0 active+clean 2019-03-28 13:34:53.899879        0'0     349:19 [6,7,8]          6 [6,7,8]              6        0'0 2019-03-28 02:
48:45.705922             0'0 2019-03-26 17:10:19.390530 
16   1 0 0 0 0       589    1    1 
15   1 0 0 0 0        11    2    2 
14  21 0 0 0 0     13624   67   67 
1    5 0 0 0 0     22678    8    8 
12   0 0 0 0 0         0    0    0 
5  138 0 0 0 0 252669555 7632 7632 
6   16 0 0 0 0       688 6293 6293 
7   21 0 0 0 0      7429   91   91 
8    8 0 0 0 0         0   24   24 
9    2 0 0 0 0       346    2    2 
10   0 0 0 0 0         0    0    0 
11   8 0 0 0 0         0   96   96 
13   0 0 0 0 0         0    0    0 
                                      
sum 221 0 0 0 0 252714920 14216 14216 
OSD_STAT USED  AVAIL  TOTAL  HB_PEERS        PG_SUM PRIMARY_PG_SUM 
8         201M 15147M 15348M [1,2,3,4,5,6,7]    182             81 
7         207M 15141M 15348M [1,2,3,4,5,6,8]    165             66 
6         216M 15132M 15348M [1,2,3,4,5,7,8]    256             80 
5         188M 15160M 15348M [1,2,3,4,6,7,8]    151             54 
4         209M 15139M 15348M [1,2,3,5,6,7,8]    166             27 
3         260M 15088M 15348M [1,2,4,5,6,7,8]    248             72 
2         197M 15151M 15348M [1,3,4,5,6,7,8]    171             65 
1         173M 15175M 15348M [2,3,4,5,6,7,8]    173             59 
sum      1656M   118G   119G                                       
```

## 查询fs map
```
# ceph fs dump
dumped fsmap epoch 9
e9
enable_multiple, ever_enabled_multiple: 0,0
compat: compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,8=file layout v2}
legacy client fscid: 1
Filesystem 'cephfs' (1)
fs_name    cephfs
epoch    7
flags    c
created    2019-03-26 17:11:16.787966
modified    2019-03-26 17:11:16.787966
tableserver    0
root    0
session_timeout    60
session_autoclose    300
max_file_size    1099511627776
last_failure    0
last_failure_osd_epoch    0
compat    compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,8=file layout v2}
max_mds    1
in    0
up    {0=64815}
failed    
damaged    
stopped    
data_pools    [15]
metadata_pool    14
inline_data    disabled
balancer    
standby_count_wanted    1
64815:    172.25.250.11:6812/3899100688 'ceph2' mds.0.6 up:active seq 67
Standby daemons:
64825:    172.25.250.12:6809/2239498662 'ceph3' mds.-1.0 up:standby seq 2
```

## 查询 mgr map
```
# ceph mgr dump
{
    "epoch": 6,
    "active_gid": 64118,
    "active_name": "ceph4",
    "active_addr": "172.25.250.13:6800/60569",
    "available": true,
    "standbys": [
        {
            "gid": 64113,
            "name": "ceph2",
            "available_modules": [
                "dashboard",
                "prometheus",
                "restful",
                "status",
                "zabbix"
            ]
        },
        {
            "gid": 64114,
            "name": "ceph3",
            "available_modules": [
                "dashboard",
                "prometheus",
                "restful",
                "status",
                "zabbix"
            ]
        }
    ],
    "modules": [
        "restful",
        "status"
    ],
    "available_modules": [
        "dashboard",
        "prometheus",
        "restful",
        "status",
        "zabbix"
    ]
}
```

## 查询 service dump
```
# ceph service dump
{
    "epoch": 3,
    "modified": "2019-03-18 21:19:18.667275",
    "services": {
        "rbd-mirror": {
            "daemons": {
                "summary": "",
                "admin": {
                    "start_epoch": 3,
                    "start_stamp": "2019-03-18 21:19:18.318802",
                    "gid": 64489,
                    "addr": "172.25.250.11:0/4114752834",
                    "metadata": {
                        "arch": "x86_64",
                        "ceph_version": "ceph version 12.2.1-40.el7cp (c6d85fd953226c9e8168c9abe81f499d66cc2716) luminous (stable)",
                        "cpu": "QEMU Virtual CPU version 1.5.3",
                        "distro": "rhel",
                        "distro_description": "Red Hat Enterprise Linux Server 7.4 (Maipo)",
                        "distro_version": "7.4",
                        "hostname": "ceph2",
                        "instance_id": "64489",
                        "kernel_description": "#1 SMP Thu Dec 28 14:23:39 EST 2017",
                        "kernel_version": "3.10.0-693.11.6.el7.x86_64",
                        "mem_swap_kb": "0",
                        "mem_total_kb": "3881716",
                        "os": "Linux"
                    }
                }
            }
        }
    }
}
```

# 二、 管理monitor map

## 2.1 多Momitor的同步机制

在生产环境建议最少三节点monitor，以确保cluster map的高可用性和冗余性
- monitor使用paxos算法作为集群状态上达成一致的机制。paxos是一种分布式一致性算法。每当monitor修改map时，它会通过paxos发送更新到其他monitor。Ceph只有在大多数monitor就更新达成一致时提交map的新版本
- cluster map的更新操作需要Paxos确认，但是读操作不经由Paxos，而是直接访问本地的kv存储

## 2.2 Monitor的选举机制

多个monitor之间需要建立仲裁并选择出一个leader，其他节点则作为工作节点（peon）

在选举完成并确定leader之后，leader将从所有其他monitor请求最新的map epoc，以确保leader具有集群的最新视图

要维护monitor集群的正常工作，必须有超过半数的节点正常

## 2.3 Monitor租期

在Monitor建立仲裁后，leader开始分发短期的租约到所有的monitors。让它们能够分发cluster map到OSD和client

Monitor租约默认每3s续期一次

当peon monitor没有确认它收到租约时，leader假定该monitor异常，它会召集新的选举以建立仲裁

如果peon monitor的租约到期后没有收到leader的续期，它会假定leader异常，并会召集新的选举

## 2.4 管理monitor map

将monitor map导出为一个二进制文件
```
# ceph mon getmap -o ./monmap
got monmap epoch 1
```

打印导出的二进制文件的内容
```
# monmaptool --print  ./monmap

monmaptool: monmap file ./monmap
epoch 1
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
last_changed 2019-03-16 12:39:14.839999
created 2019-03-16 12:39:14.839999
0: 172.25.250.11:6789/0 mon.ceph2
1: 172.25.250.12:6789/0 mon.ceph3
2: 172.25.250.13:6789/0 mon.ceph4
```


修改二进制文件，从monmap删除某个monitor
```
# monmaptool ./monmap  --rm ceph2
monmaptool: monmap file ./monmap
monmaptool: removing ceph2
monmaptool: writing epoch 1 to ./monmap (2 monitors)


# monmaptool --print ./monmap
monmaptool: monmap file ./monmap
epoch 1
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
last_changed 2019-03-16 12:39:14.839999
created 2019-03-16 12:39:14.839999
0: 172.25.250.12:6789/0 mon.ceph3
1: 172.25.250.13:6789/0 mon.ceph4


# ceph mon dump
dumped monmap epoch 1
epoch 1
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
last_changed 2019-03-16 12:39:14.839999
created 2019-03-16 12:39:14.839999
0: 172.25.250.11:6789/0 mon.ceph2
1: 172.25.250.12:6789/0 mon.ceph3
2: 172.25.250.13:6789/0 mon.ceph4
```

修改二进制文件，往monmap中添加一个monitor
```
# monmaptool ./monmap --add ceph2 172.25.254.11:6789
monmaptool: monmap file ./monmap
monmaptool: writing epoch 1 to ./monmap (3 monitors)
[root@ceph2 ~]# monmaptool --print ./monmap 
monmaptool: monmap file ./monmap
epoch 1
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
last_changed 2019-03-16 12:39:14.839999
created 2019-03-16 12:39:14.839999
0: 172.25.250.12:6789/0 mon.ceph3
1: 172.25.250.13:6789/0 mon.ceph4
2: 172.25.254.11:6789/0 mon.ceph2
```

导入一个二进制文件，在导入之前，需要先停止monitor
```
ceph-mon -i <id> --inject-monmap ./monmap
```
    
# 三、 管理osd map

## 3.1 OSD map生命周期
- 每当OSD加入或离开集群时，Ceph都会更新OSD map
- OSD不使用leader来管理OSD map，它们会在自身之间传播map。OSD会利用OSD map epoch标记它们交换的每一条信息，当OSD检测到自己已落后时，它会使用其对等OSD执行map更新
- 在大型集群中OSD map更新会非常频繁，节点会执行递增map更新
- Ceph也会利用epoch来标记OSD和client之间的消息。当client连接到OSD时OSD会检查epoch。如果发现epoch不匹配，则OSD会以正确的epoch响应，以便客户端可以更新其OSD map
- OSD定期向monitor报告自己的状态，OSD之间会交换心跳，以便检测对等点的故障，并报告给monitor
- leader monitor发现OSD故障时，它会更新map，递增epoch，并使用Paxos更新协议来通知其他monitor，同时撤销租约，并发布新的租约，以使monitor以分发最新的OSD map

## 3.2 管理 osd map

- osd上pg的分布决定了数据分布的均匀与否，所以能直观的看到pg到osd的上分布是很有必要

```
# ceph pg ls-by-osd.{osd_id}
# for i in `ceph osd  ls`; do ceph pg ls-by-osd osd.$i |awk '{print $1}' >> /tmp/aaa ;done       #NOTE: 每次osd输出，第一行有一个pg_stat,需要去掉之后，就可以获取pg总数是ceph -s中 pg个数*副本数
```


```
# 获取map
#  ceph osd getmap -o ./osdmap
got osdmap epoch 281

# 打印导出的二进制文件的内容
# osdmaptool --print ./osdmap
osdmaptool: osdmap file './osdmap'
epoch 281
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
created 2019-03-16 12:39:22.552356
modified 2019-03-26 22:32:15.354383
flags sortbitwise,recovery_deletes,purged_snapdirs
crush_version 43
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.85
require_min_compat_client jewel
min_compat_client jewel
require_osd_release luminous
pool 1 'testpool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 190 flags hashpspool stripe_width 0 application rbd
    snap 1 'testpool-snap-20190316' 2019-03-16 22:27:34.150433
    snap 2 'testpool-snap-2' 2019-03-16 22:31:15.430823
pool 5 'rbd' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 last_change 191 flags hashpspool stripe_width 0 application rbd
    removed_snaps [1~13]
pool 6 'rbdmirror' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 last_change 192 flags hashpspool stripe_width 0 application rbd
    removed_snaps [1~7]
pool 7 '.rgw.root' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 176 flags hashpspool stripe_width 0 application rgw
pool 8 'default.rgw.control' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 178 flags hashpspool stripe_width 0 application rgw
pool 9 'default.rgw.meta' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 180 flags hashpspool stripe_width 0 application rgw
pool 10 'default.rgw.log' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 182 flags hashpspool stripe_width 0 application rgw
pool 11 'xiantao.rgw.control' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 194 owner 18446744073709551615 flags hashpspool stripe_width 0 application rgw
pool 12 'xiantao.rgw.meta' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 196 owner 18446744073709551615 flags hashpspool stripe_width 0 application rgw
pool 13 'xiantao.rgw.log' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 198 owner 18446744073709551615 flags hashpspool stripe_width 0 application rgw
pool 14 'cephfs_metadata' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 last_change 214 flags hashpspool stripe_width 0 application cephfs
pool 15 'cephfs_data' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 214 flags hashpspool stripe_width 0 application cephfs
pool 16 'test' replicated size 3 min_size 2 crush_rule 3 object_hash rjenkins pg_num 32 pgp_num 32 last_change 280 flags hashpspool stripe_width 0 application rbd
pool 17 'ssdpool' replicated size 3 min_size 2 crush_rule 4 object_hash rjenkins pg_num 32 pgp_num 32 last_change 281 flags hashpspool stripe_width 0 application rbd
max_osd 9
osd.0 up   in  weight 1 up_from 54 up_thru 264 down_at 53 last_clean_interval [7,51) 172.25.250.11:6800/185671 172.25.250.11:6801/185671 172.25.250.11:6802/185671 172.25.250.11:6803/185671 exists,up 745dce53-1c63-4c50-b434-d441038dafe4
osd.1 up   in  weight 1 up_from 187 up_thru 258 down_at 184 last_clean_interval [54,186) 172.25.250.13:6809/60269 172.25.250.13:6807/1060269 172.25.250.13:6803/1060269 172.25.250.13:6813/1060269 exists,up a7562276-6dfd-4803-b248-a7cbdb64ebec
osd.2 up   in  weight 1 up_from 258 up_thru 264 down_at 257 last_clean_interval [54,257) 172.25.250.12:6804/59201 172.25.250.12:6810/8059201 172.25.250.12:6811/8059201 172.25.250.12:6815/8059201 exists,up bbef1a00-3a31-48a0-a065-3a16b9edc3b1
osd.3 up   in  weight 1 up_from 54 up_thru 272 down_at 53 last_clean_interval [13,51) 172.25.250.11:6804/185668 172.25.250.11:6805/185668 172.25.250.11:6806/185668 172.25.250.11:6807/185668 exists,up e934a4fb-7125-4e85-895c-f66cc5534ceb
osd.4 up   in  weight 1 up_from 187 up_thru 267 down_at 184 last_clean_interval [54,186) 172.25.250.13:6805/60272 172.25.250.13:6802/1060272 172.25.250.13:6810/1060272 172.25.250.13:6811/1060272 exists,up e2c33bb3-02d2-4cce-85e8-25c419351673
osd.5 up   in  weight 1 up_from 261 up_thru 275 down_at 257 last_clean_interval [54,258) 172.25.250.12:6808/59198 172.25.250.12:6806/8059198 172.25.250.12:6807/8059198 172.25.250.12:6814/8059198 exists,up d299e33c-0c24-4cd9-a37a-a6fcd420a529
osd.6 up   in  weight 1 up_from 54 up_thru 273 down_at 52 last_clean_interval [21,51) 172.25.250.11:6808/185841 172.25.250.11:6809/185841 172.25.250.11:6810/185841 172.25.250.11:6811/185841 exists,up debe7f4e-656b-48e2-a0b2-bdd8613afcc4
osd.7 up   in  weight 1 up_from 187 up_thru 266 down_at 184 last_clean_interval [54,186) 172.25.250.13:6801/60271 172.25.250.13:6806/1060271 172.25.250.13:6808/1060271 172.25.250.13:6812/1060271 exists,up 8c403679-7530-48d0-812b-72050ad43aae
osd.8 up   in  weight 1 up_from 151 up_thru 265 down_at 145 last_clean_interval [54,150) 172.25.250.12:6800/59200 172.25.250.12:6801/7059200 172.25.250.12:6802/7059200 172.25.250.12:6805/7059200 exists,up bb73edf8-ca97-40c3-a727-d5fde1a9d1d9


获取crushmap
# osdmaptool osdmap --export-crush crushmap                        # 或者 ceph osd getcrushmap -o crushmap　
osdmaptool: osdmap file 'osdmap'
osdmaptool: exported crush map to crushmap


获取某个pool在pg上的分布情况
# osdmaptool osdmap --import-crush crushmap --test-map-pgs --pool {pool_id}

# osdmaptool osdmap --import-crush crushmap --test-map-pgs --pool 16
osdmaptool: osdmap file 'osdmap'
osdmaptool: imported 864 byte crush map from crushmap
pool 16 pg_num 32
#osd    count    first    primary    c wt        wt
osd.1   14       4        4          0.149994    1
osd.2   5        1        1          0.149994    1
osd.3   7        4        4          0.149994    1
osd.4   6        1        1          0.149994    1
osd.5   6        3        3          0.149994    1
osd.6   5        3        3          0.149994    1
osd.7   9        8        8          0.149994    1
osd.8   6        4        4          0.149994    1
osd.9   6        4        4          0.149994    1
 in 9
 avg 7 stddev 2.68742 (0.383917x) (expected 2.51416 0.359165x))
 min osd.2 5
 max osd.1 14
size 0    0
size 1    0
size 2    32
size 3    0
osdmaptool: writing epoch 2383 to osdmap
```
参考：
- https://blog.csdn.net/zd147896325/article/details/111032003
