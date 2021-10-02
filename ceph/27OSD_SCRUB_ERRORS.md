# 一、错误描述

```
# ceph health detail
HEALTH_ERR 1 scrub errors; Possible data damage: 1 pg inconsistent
OSD_SCRUB_ERRORS 1 scrub errors
PG_DAMAGED Possible data damage: 1 pg inconsistent
    pg 2.33c6 is active+clean+inconsistent, acting [355,138,29]
```


```
ceph pg dump | grep inconsistent
dumped all
 2.33c6    76    0    0    0    0 551575468  569   569 active+clean+inconsistent 2020-12-10 20:58:11.528662   205'569    205:1522  [355,138,29]  20 [355,138,29]
```
- 可以看到2.22c6这样开头的，这就是pg的id，前面的2表示这个pg是对应哪个存储池

# 二、问题定位

1、获取osd所在节点的IP信息和挂载信息。
```
# OSD_ID=355
# ceph $OSD_ID | grep -E 'hostname|osd_data'

# OSD_ID=138
# ceph osd metadata $OSD_ID | grep -E 'hostname|osd_data'

# OSD_ID=29
# ceph osd metadata $OSD_ID | grep -E 'hostname|osd_data'
```

或者查询osd所在服务器的ip地址
```
# ceph osd find $OSD_ID
```

2、查看对应PG的不一致对象列表
```
# rados list-inconsistent-obj 2.33c6 --format=json-pretty
{
    "epoch": 560,
    "inconsistents": [
        {
            "object": {
                "name": "1159921",
                "nspace": "",
                "locator": "",
                "snap": "head",
                "version": 67
            },
            "errors": [],
            "union_shard_errors": [
                "read_error"
            ],
            "selected_object_info": {
                "oid": {
                    "oid": "1159921",
                    "key": "",
                    "snapid": -2,
                    "hash": 1986311110,
                    "max": 0,
                    "pool": 2,
                    "namespace": ""
                },
                "version": "584'67",
                "prior_version": "0'0",
                "last_reqid": "client.453617.0:72999",
                "user_version": 67,
                "size": 4194304,
                "mtime": "2020-12-10 20:58:11.523179",
                "local_mtime": "2020-12-10 20:58:11.528662",
                "lost": 0,
                "flags": [
                    "dirty",
                    "data_digest"
                ],
                "legacy_snaps": [],
                "truncate_seq": 0,
                "truncate_size": 0,
                "data_digest": "0xf45029cc",
                "omap_digest": "0xffffffff",
                "expected_object_size": 0,
                "expected_write_size": 0,
                "alloc_hint_flags": 0,
                "manifest": {
                    "type": 0,
                    "redirect_target": {
                        "oid": "",
                        "key": "",
                        "snapid": 0,
                        "hash": 0,
                        "max": 0,
                        "pool": -9223372036854775808,
                        "namespace": ""
                    }
                },
                "watchers": {}
            },
            "shards": [
                {
                    "osd": 29,
                    "primary": false,
                    "errors": [],
                    "size": 4194304,
                    "omap_digest": "0xffffffff",
                    "data_digest": "0xf45029cc"
                },
                {
                    "osd": 138,
                    "primary": false,
                    "errors": [
                        "read_error"                         # 可以看到osd138上read_error报错
                    ],
                    "size": 4194304
                },
                {
                    "osd": 355,
                    "primary": true,
                    "errors": [],
                    "size": 4194304,
                    "omap_digest": "0xffffffff",
                    "data_digest": "0xf45029cc"
                }
            ]
        }
    ]
}
```
- 需要到osd138对应的服务器上检查，对应的挂载盘是否也显示有`read error`

2、查看138对应的盘符
```
df -h |grep 138
/dev/sdh        11T   11G   11T    1% /var/lib/ceph/osd/ceph-138
```

3、发现有一个对象的一个138副本出现了read_error，去主osd355上查看日志可以看到具体scrub-error日志
```
# grep '2.33c6' ceph-osd.355.log-20201125
2020-12-08 23:00:00.469371 7ff5b8c43700  0 log_channel(cluster) log [DBG] : 2.33c6 scrub starts
2020-12-08 23:00:00.472653 7ff5b8c43700  0 log_channel(cluster) log [DBG] : 2.33c6 scrub ok
2020-12-10 23:00:05.031243 7ff5b8c43700  0 log_channel(cluster) log [DBG] : 2.33c6 deep-scrub starts
2020-12-10 23:00:19.077055 7ff5b8c43700 -1 log_channel(cluster) log [ERR] : 2.33c6 shard 138 soid 2:63cd266e:::1159921:head : candidate had a read error
2020-12-10 23:00:19.938043 7ff5b8c43700 -1 log_channel(cluster) log [ERR] : 2.33c6 deep-scrub 0 missing, 1 inconsistent objects
2020-12-10 23:00:19.938052 7ff5b8c43700 -1 log_channel(cluster) log [ERR] : 2.33c6 deep-scrub 1 errors
```

4、去osd138上查看系统日志发现sdh坏道
```
[四 12月 10 23:03:02 2020] Process accounting resumed
[四 12月 10 23:03:15 2020] megaraid_sas 0000:02:00.0: 5305 (660927610s/0x0002/FATAL) - Unrecoverable medium error during recovery on PD 06(e0x20/s6) at 255d319
[四 12月 10 23:03:18 2020] sd 0:2:7:0: [sdh] tag#0 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:18 2020] sd 0:2:7:0: [sdh] tag#2 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#2 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#0 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] megaraid_sas 0000:02:00.0: 5307 (660927613s/0x0001/FATAL) - Uncorrectable medium error logged for VD 07/7 at 255d319 (on PD 06(e0x20/s6) at 255d319)
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#1 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#0 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] megaraid_sas 0000:02:00.0: 5308 (660927613s/0x0002/FATAL) - Unrecoverable medium error during recovery on PD 06(e0x20/s6) at 255d412
[四 12月 10 23:03:20 2020] megaraid_sas 0000:02:00.0: 5309 (660927613s/0x0001/FATAL) - Uncorrectable medium error logged for VD 07/7 at 255d412 (on PD 06(e0x20/s6) at 255d412)
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#3 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#4 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#3 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#4 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#5 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#5 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#5 Sense Key : Medium Error [current]
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#5 Add. Sense: No additional sense information
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#5 CDB: Read(16) 88 00 00 00 00 00 02 55 d3 80 00 00 02 00 00 00
[四 12月 10 23:03:20 2020] blk_update_request: I/O error, dev sdh, sector 39179136
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#3 BRCM Debug mfi stat 0x2d, data len requested/completed 0x40000/0x0
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#3 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#3 Sense Key : Medium Error [current]
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#3 Add. Sense: No additional sense information
[四 12月 10 23:03:20 2020] sd 0:2:7:0: [sdh] tag#3 CDB: Read(16) 88 00 00 00 00 00 02 55 d1 80 00 00 02 00 00 00
[四 12月 10 23:03:20 2020] blk_update_request: I/O error, dev sdh, sector 39178624
[四 12月 10 23:04:02 2020] Process accounting resumed
```

5、sdh正是osd138对应的硬盘
```
# pwd
/var/lib/ceph/osd/ceph-138

# ls -l
总用量 48
-rw-r--r-- 1 ceph ceph 768 11月 23 18:05 activate.monmap
lrwxrwxrwx 1 ceph ceph  93 11月 23 18:05 block -> /dev/ceph-799147d1-13d6-4229-b5db-4e31a61ad5b4/osd-block-389e5a16-060a-515e-bbc3-9a0d74beccf2
-rw-r--r-- 1 ceph ceph   2 11月 23 18:05 bluefs
-rw-r--r-- 1 ceph ceph  37 11月 23 18:05 ceph_fsid
-rw-r--r-- 1 ceph ceph  37 11月 23 18:05 fsid
-rw------- 1 ceph ceph  57 11月 23 18:05 keyring
-rw-r--r-- 1 ceph ceph   8 11月 23 18:05 kv_backend
-rw-r--r-- 1 ceph ceph  21 11月 23 18:05 magic
-rw-r--r-- 1 ceph ceph   4 11月 23 18:05 mkfs_done
-rw-r--r-- 1 ceph ceph  41 11月 23 18:05 osd_key
-rw-r--r-- 1 ceph ceph   6 11月 23 18:05 ready
-rw-r--r-- 1 ceph ceph  10 11月 23 18:05 type
-rw-r--r-- 1 ceph ceph   4 11月 23 18:05 whoami

# pvs
  PV         VG                                        Fmt  Attr PSize  PFree
  /dev/sdb   ceph-612fc205-5d11-4818-bd83-251959a71bf3 lvm2 a--  <3.64t    0
  /dev/sdc   ceph-f31c27c4-0c5a-4b82-af21-790647433f49 lvm2 a--  <3.64t    0
  /dev/sdd   ceph-87748016-6b8d-422f-9d25-75c50046331c lvm2 a--  <3.64t    0
  /dev/sde   ceph-94928fab-d6b5-42eb-b77d-4f507a7c3c95 lvm2 a--  <3.64t    0
  /dev/sdf   ceph-c488371e-b364-4e04-be75-d41abc561591 lvm2 a--  <3.64t    0
  /dev/sdg   ceph-efeaff04-c72a-48fe-9742-56030c4cf82d lvm2 a--  <3.64t    0
  /dev/sdh   ceph-799147d1-13d6-4229-b5db-4e31a61ad5b4 lvm2 a--  <3.64t    0  ### sdh正是osd-138对应的盘
  /dev/sdi   ceph-90a95edd-539e-4ca9-806a-f994f29972af lvm2 a--  <3.64t    0
  /dev/sdj   ceph-006f3237-d6b3-4353-beb9-8d6307c0cf24 lvm2 a--  <3.64t    0
  /dev/sdk   ceph-361dae3d-c7e2-4ec7-bb14-ffac49acbb3a lvm2 a--  <3.64t    0
  /dev/sdl   ceph-6b4f8394-9b01-4c21-a8a5-6aa283ff3662 lvm2 a--  <3.64t    0
  /dev/sdm   ceph-1fc4f01f-bc05-489a-a15c-33834adc197b lvm2 a--  <3.64t    0
```

6、数据修复
```
# ceph pg repair 2.33c6
instructing pg 2.33c6 on osd.355 to repair
# ...

# ceph health detail
HEALTH_OK

# rados list-inconsistent-obj 2.33c6 --format=json-pretty
{
    "epoch": 560,
    "inconsistents": []
}
# 
```

7、如果无法恢复，只能更换硬盘盘。




