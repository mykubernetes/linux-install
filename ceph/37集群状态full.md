# 集群状态full的问题

## 设置集群状态为full
```
# ceph osd set full
full is set

# ceph -s
 cluster:
    id:     35a91e48-8244-4e96-a7ee-980ab989d20d
    health: HEALTH_WARN
            full flag(s) set
 
  services:
    mon:        3 daemons, quorum ceph2,ceph3,ceph4
    mgr:        ceph4(active), standbys: ceph2, ceph3
    mds:        cephfs-1/1/1 up  {0=ceph2=up:active}, 1 up:standby
    osd:        9 osds: 9 up, 9 in; 32 remapped pgs
                flags full
    rbd-mirror: 1 daemon active
 
  data:
    pools:   14 pools, 536 pgs
    objects: 220 objects, 240 MB
    usage:   1768 MB used, 133 GB / 134 GB avail
    pgs:     508 active+clean
             28  active+clean+remapped                       #pg有问题
 
  io:
    client:   2558 B/s rd, 0 B/s wr, 2 op/s rd, 0 op/s wr
```

## 取消full状态
```
# ceph osd unset full
full is unset

# ceph -s
cluster:
id: 35a91e48-8244-4e96-a7ee-980ab989d20d
health: HEALTH_ERR
full ratio(s) out of order
Reduced data availability: 32 pgs inactive, 32 pgs peering, 32 pgs stale
Degraded data redundancy: 32 pgs unclean                    #PG也有问题

services:
mon: 3 daemons, quorum ceph2,ceph3,ceph4
mgr: ceph4(active), standbys: ceph2, ceph3
mds: cephfs-1/1/1 up {0=ceph2=up:active}, 1 up:standby
osd: 9 osds: 9 up, 9 in
rbd-mirror: 1 daemon active

data:
pools: 14 pools, 536 pgs
objects: 221 objects, 240 MB
usage: 1780 MB used, 133 GB / 134 GB avail
pgs: 5.970% pgs not active
504 active+clean
32 stale+peering

io:
client: 4911 B/s rd, 0 B/s wr, 5 op/s rd, 0 op/s wr
``` 
- 查看，去的定是一个存储池ssdpool的问题

## 删除ssdpool
```
# ceph osd pool delete ssdpool ssdpool --yes-i-really-really-mean-it

# ceph -s
  cluster:
    id:     35a91e48-8244-4e96-a7ee-980ab989d20d
    health: HEALTH_ERR
            full ratio(s) out of order
 
  services:
    mon:        3 daemons, quorum ceph2,ceph3,ceph4
    mgr:        ceph4(active), standbys: ceph2, ceph3
    mds:        cephfs-1/1/1 up  {0=ceph2=up:active}, 1 up:standby
    osd:        9 osds: 9 up, 9 in
    rbd-mirror: 1 daemon active
 
  data:
    pools:   13 pools, 504 pgs
    objects: 221 objects, 241 MB
    usage:   1772 MB used, 133 GB / 134 GB avail
    pgs:     504 active+clean
 
  io:
    client:   341 B/s rd, 0 op/s rd, 0 op/s wr



# ceph osd unset full

# ceph -s
cluster:
    id:     35a91e48-8244-4e96-a7ee-980ab989d20d
    health: HEALTH_ERR
            full ratio(s) out of order                    #依然不起作用
 
  services:
    mon:        3 daemons, quorum ceph2,ceph3,ceph4
    mgr:        ceph4(active), standbys: ceph2, ceph3
    mds:        cephfs-1/1/1 up  {0=ceph2=up:active}, 1 up:standby
    osd:        9 osds: 9 up, 9 in
    rbd-mirror: 1 daemon active
 
  data:
    pools:   13 pools, 504 pgs
    objects: 221 objects, 241 MB
    usage:   1773 MB used, 133 GB / 134 GB avail
    pgs:     504 active+clean
 
  io:
    client:   2046 B/s rd, 0 B/s wr, 2 op/s rd, 0 op/s wr


# ceph health detail
HEALTH_ERR full ratio(s) out of order
OSD_OUT_OF_ORDER_FULL full ratio(s) out of order
full_ratio (0.85) < backfillfull_ratio (0.9), increased             #发现是在前面配置full_ratio导致小于backfillfull_ratio
```

##  重设full_ratio
```
# ceph osd set-full-ratio 0.95
osd set-full-ratio 0.95

# ceph osd set-nearfull-ratio 0.9
osd set-nearfull-ratio 0.9


# ceph osd dump
epoch 325
fsid 35a91e48-8244-4e96-a7ee-980ab989d20d
created 2019-03-16 12:39:22.552356
modified 2019-03-28 10:54:42.035882
flags sortbitwise,recovery_deletes,purged_snapdirs
crush_version 46
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.9
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
max_osd 9
osd.0 up   in  weight 1 up_from 314 up_thru 315 down_at 313 last_clean_interval [308,312) 172.25.250.11:6808/1141125 172.25.250.11:6809/1141125 172.25.250.11:6810/1141125 172.25.250.11:6811/1141125 exists,up 745dce53-1c63-4c50-b434-d441038dafe4
osd.1 up   in  weight 1 up_from 315 up_thru 315 down_at 313 last_clean_interval [310,312) 172.25.250.13:6805/592704 172.25.250.13:6806/592704 172.25.250.13:6807/592704 172.25.250.13:6808/592704 exists,up a7562276-6dfd-4803-b248-a7cbdb64ebec
osd.2 up   in  weight 1 up_from 314 up_thru 315 down_at 313 last_clean_interval [308,312) 172.25.250.12:6800/94300 172.25.250.12:6801/94300 172.25.250.12:6802/94300 172.25.250.12:6803/94300 exists,up bbef1a00-3a31-48a0-a065-3a16b9edc3b1
osd.3 up   in  weight 1 up_from 315 up_thru 315 down_at 314 last_clean_interval [308,312) 172.25.250.11:6800/1140952 172.25.250.11:6801/1140952 172.25.250.11:6802/1140952 172.25.250.11:6803/1140952 exists,up e934a4fb-7125-4e85-895c-f66cc5534ceb
osd.4 up   in  weight 1 up_from 315 up_thru 315 down_at 313 last_clean_interval [310,312) 172.25.250.13:6809/592702 172.25.250.13:6810/592702 172.25.250.13:6811/592702 172.25.250.13:6812/592702 exists,up e2c33bb3-02d2-4cce-85e8-25c419351673
osd.5 up   in  weight 1 up_from 314 up_thru 315 down_at 313 last_clean_interval [308,312) 172.25.250.12:6804/94301 172.25.250.12:6805/94301 172.25.250.12:6806/94301 172.25.250.12:6807/94301 exists,up d299e33c-0c24-4cd9-a37a-a6fcd420a529
osd.6 up   in  weight 1 up_from 315 up_thru 315 down_at 314 last_clean_interval [308,312) 172.25.250.11:6804/1140955 172.25.250.11:6805/1140955 172.25.250.11:6806/1140955 172.25.250.11:6807/1140955 exists,up debe7f4e-656b-48e2-a0b2-bdd8613afcc4
osd.7 up   in  weight 1 up_from 314 up_thru 315 down_at 313 last_clean_interval [309,312) 172.25.250.13:6801/592699 172.25.250.13:6802/592699 172.25.250.13:6803/592699 172.25.250.13:6804/592699 exists,up 8c403679-7530-48d0-812b-72050ad43aae
osd.8 up   in  weight 1 up_from 315 up_thru 315 down_at 313 last_clean_interval [310,312) 172.25.250.12:6808/94302 172.25.250.12:6810/94302 172.25.250.12:6811/94302 172.25.250.12:6812/94302 exists,up bb73edf8-ca97-40c3-a727-d5fde1a9d1d9
```

## 再次尝试
```
# ceph osd unset full
full is unset


# ceph -s
 cluster:
    id:     35a91e48-8244-4e96-a7ee-980ab989d20d
    health: HEALTH_OK                                 #成功
 
  services:
    mon:        3 daemons, quorum ceph2,ceph3,ceph4
    mgr:        ceph4(active), standbys: ceph2, ceph3
    mds:        cephfs-1/1/1 up  {0=ceph2=up:active}, 1 up:standby
    osd:        9 osds: 9 up, 9 in
    rbd-mirror: 1 daemon active
 
  data:
    pools:   13 pools, 504 pgs
    objects: 221 objects, 241 MB
    usage:   1773 MB used, 133 GB / 134 GB avail
    pgs:     504 active+clean
 
  io:
    client:   0 B/s wr, 0 op/s rd, 0 op/s wr
```
