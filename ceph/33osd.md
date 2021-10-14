# osd状态
       
- 运行状态有：up，in，out，down

- 正常状态的OSD为up且in

- 当OSD故障时，守护进程offline，在5分钟内，集群仍会将其标记为up和in，这是为了防止网络抖动

- 如果5分钟内仍未恢复，则会标记为down和out。此时该OSD上的PG开始迁移。这个5分钟的时间间隔可以通过mon_osd_down_out_interval配置项修改

- 当故障的OSD重新上线以后，会触发新的数据再平衡

- 当集群有noout标志位时，则osd下线不会导致数据重平衡

- OSD每隔6s会互相验证状态。并每隔120s向mon报告一次状态。

- 容量状态：nearfull，full




# osd管理
对于每个osd，ceph都会启动一个进程，如下:  

```
# ps -f -u ceph
UID        PID  PPID  C STIME TTY          TIME CMD
ceph     22937     1  0 Mar02 ?        15:46:29 /usr/bin/ceph-mon -f --cluster ceph --id ceph-3 --setuser ceph --setgroup
ceph     23849     1  3 Mar02 ?        2-13:36:15 /usr/bin/ceph-osd -f --cluster ceph --id 10 --setuser ceph --setgroup ceph
ceph     24014     1  2 Mar02 ?        2-00:58:38 /usr/bin/ceph-osd -f --cluster ceph --id 11 --setuser ceph --setgroup ceph
ceph     24177     1  3 Mar02 ?        2-12:34:28 /usr/bin/ceph-osd -f --cluster ceph --id 9 --setuser ceph --setgroup ceph
ceph     24970     1  0 Mar02 ?        04:23:39 /usr/bin/radosgw -f --cluster ceph --name client.rgw.ceph-3 --se
```

创建osd可以使用ceph-deploy工具。


## 查询集群osd状态
```
# ceph osd stat
     osdmap e1952: 10 osds: 9 up, 9 in
            flags sortbitwise,require_jewel_osds
```




## 查看所有osd的id
```
# ceph osd ls
1
3
4
5
6
7
......
```


## 查看osd的空间使用率
```
# ceph osd df
ID WEIGHT  REWEIGHT SIZE  USE    AVAIL %USE  VAR  PGS
 3 0.86909  1.00000  889G 78631M  813G  8.63 0.99 329
 4 0.86909  0.98000  889G 81207M  810G  8.91 1.02 333
 5 0.86909  1.00000  889G 78747M  813G  8.64 0.99 346
...... 
              TOTAL 8016G   698G 7317G  8.72
MIN/MAX VAR: 0.74/1.21  STDDEV: 1.13
```

* ID: osd id
* WEIGHT: 权重，和osd容量有关系
* REWEIGHT: 自动以的权重
* SIZE: osd大小
* USE: 已用空间大小
* AVAIL: 可用空间大小
* %USE: 已用空间百分比
* PGS: pg数量


## 查询osd在哪个主机上

```
# ceph osd find 0
{
    "osd": 0,
    "ip": "10.10.10.75:6800\/2101",
    "crush_location": {
        "host": "ceph-1",
        "root": "default"
    }
}
```

osd会使用6800-7300之间可用的端口号，一个osd最多会用到4个端口号。


```
# ss -ntpl | grep ceph
LISTEN     0      128                       *:6800                     *:*      users:(("ceph-osd",2101,4))
LISTEN     0      128                       *:6801                     *:*      users:(("ceph-osd",2101,5))
LISTEN     0      128                       *:6802                     *:*      users:(("ceph-osd",2101,6))
LISTEN     0      128                       *:6803                     *:*      users:(("ceph-osd",2101,7))
```


## 查看osd的metadata

```
# ceph osd metadata 1
{
    "id": 1,
    "arch": "x86_64",
    "back_addr": "10.10.10.26:6801\/154023",
    "backend_filestore_dev_node": "unknown",
    "backend_filestore_partition_path": "unknown",
    "ceph_version": "ceph version 10.2.5-6099-gd9eaab4 (d9eaab456ff45ae88e83bd633f0c4efb5902bf07)",
    "cpu": "Intel(R) Xeon(R) CPU E5-2620 v2 @ 2.10GHz",
    "distro": "centos",
    "distro_description": "CentOS Linux 7 (Core)",
    "distro_version": "7",
    "filestore_backend": "xfs",
    "filestore_f_type": "0x58465342",
    "front_addr": "10.10.10.26:6800\/154023",
    "hb_back_addr": "10.10.10.26:6803\/154023",
    "hb_front_addr": "10.10.10.26:6804\/154023",
    "hostname": "ceph-1",
    "kernel_description": "#1 SMP Fri Mar 6 11:36:42 UTC 2015",
    "kernel_version": "3.10.0-229.el7.x86_64",
    "mem_swap_kb": "4194300",
    "mem_total_kb": "131812072",
    "os": "Linux",
    "osd_data": "\/var\/lib\/ceph\/osd\/ceph-1",
    "osd_journal": "\/var\/lib\/ceph\/osd\/ceph-1\/journal",
    "osd_objectstore": "filestore"
}
```

* id: osd的id
* filestore_backend: filestore所使用的文件系统类型
* hostname: osd所在的主机
* osd_data: osd数据存放位置
* osd_journal: osd的日志存放位置
* osd_objectstore: osd存储对象使用的store类型


## 查看osd tree
```
# ceph osd tree
ID WEIGHT  TYPE NAME                UP/DOWN REWEIGHT PRIMARY-AFFINITY
-1 8.73654 root default
-2 3.51538     host ceph-1
 3 0.86909         osd.3                 up  1.00000          1.00000
 4 0.86909         osd.4                 up  0.98000          1.00000
 5 0.86909         osd.5                 up  1.00000          1.00000
 1 0.90810         osd.1               down        0          1.00000
-3 2.61058     host ceph-2
 6 0.87019         osd.6                 up  1.00000          1.00000
 7 0.87019         osd.7                 up  0.79999          1.00000
 8 0.87019         osd.8                 up  1.00000          1.00000
-4 2.61058     host ceph-3
 9 0.87019         osd.9                 up  0.98999          1.00000
10 0.87019         osd.10                up  1.00000          1.00000
11 0.87019         osd.11                up  0.98000          1.00000
```

* ID: 如果为负数，表示的是主机或者root；如果是正数，表示的是osd的id
* WEIGHT: osd的weight，root的weight是所有host的weight的和。某个host的weight是它上面所有osd的weight的和
* NAME: 主机名或者osd的名称
* UP/DOWN: osd的状态信息
* REWEIGHT: osd的reweight值，如果osd状态为down，reweight值为0



## 查看osd map的概要信息

```
# ceph osd dump
epoch 38
fsid c712f08b-c001-4b1c-969d-abec240138f7
created 2017-03-16 17:52:12.901166
modified 2017-06-03 16:53:28.572763
flags sortbitwise,require_jewel_osds
pool 0 'rbd' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 64 pgp_num 64 last_change 1 flags hashpspool stripe_width 0
pool 1 'pool-frank6866' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 37 flags hashpspool stripe_width 0
max_osd 3
osd.0 up   in  weight 1 up_from 28 up_thru 37 down_at 26 last_clean_interval [23,25) 10.10.10.75:6800/2101 10.10.10.75:6801/2101 10.10.10.75:6802/2101 10.10.10.75:6803/2101 exists,up 79b807fa-d0cd-4d70-a47b-acd4148c9d16
osd.1 up   in  weight 1 up_from 8 up_thru 37 down_at 0 last_clean_interval [0,0) 10.10.10.76:6800/20176 10.10.10.76:6801/20176 10.10.10.76:6802/20176 10.10.10.76:6803/20176 exists,up 9dded204-2d3b-4a5d-a820-d817385a0e35
osd.2 up   in  weight 1 up_from 13 up_thru 37 down_at 0 last_clean_interval [0,0) 10.10.10.77:6800/20546 10.10.10.77:6801/20546 10.10.10.77:6802/20546 10.10.10.77:6803/20546 exists,up 7d01124b-c6f9-46cd-b32b-34aa40493621
```

还可以看到pool的信息




























