
# 问题

1、查看ceph集群的状态，看到归置组pg 4.210丢了一个块
```
# ceph health detail
HEALTH_WARN 481/5647596 objects misplaced (0.009%); 1/1882532 objects unfound (0.000%); Degraded data redundancy: 965/5647596 objects degraded (0.017%), 1 pg degraded, 1 pg undersized
OBJECT_MISPLACED 481/5647596 objects misplaced (0.009%)
OBJECT_UNFOUND 1/1882532 objects unfound (0.000%)
    pg 4.210 has 1 unfound objects
PG_DEGRADED Degraded data redundancy: 965/5647596 objects degraded (0.017%), 1 pg degraded, 1 pg undersized
    pg 4.210 is stuck undersized for 38159.843116, current state active+recovery_wait+undersized+degraded+remapped, last acting [2]
```

# 处理过程

## 1、先让集群可以正常使用

1) 查看pg 4.210，可以看到它现在只有一个副本
```
# ceph pg dump_json pools |grep 4.210
dumped all
4.210       482                  1      965       481       1  2013720576 3461     3461 active+recovery_wait+undersized+degraded+remapped 2019-07-10 09:34:53.693724   9027'1835435   9027:1937140  [6,17,20]          6        [2]              2   6368'1830618 2019-07-07 01:36:16.289885    6368'1830618 2019-07-07 01:36:16.289885             2

# ceph pg map 4.210
osdmap e9181 pg 4.210 (4.210) -> up [26,20,2] acting [2]
丢了两个副本，而且最主要的是主副本也丢了…
```

2）因为默认指定的pool的min_size为2，这就导致4.210所在的池vms不能正常使用
```
# ceph osd pool stats vms
pool vms id 4
  965/1478433 objects degraded (0.065%)
  481/1478433 objects misplaced (0.033%)
  1/492811 objects unfound (0.000%)
  client io 680 B/s rd, 399 kB/s wr, 0 op/s rd, 25 op/s wr
```

```
# ceph osd pool ls detail|grep vms
pool 4 'vms' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 1024 pgp_num 1024 last_change 10312 lfor 0/874 flags hashpspool stripe_width 0 application rbd
```
- 直接影响了部分虚拟机，导致部分虚拟机夯住了，执行命令无回应

3）为了可以正常使用，先见vms池的min_size调整为1
```
# ceph osd pool set vms min_size 1
set pool 4 min_size to 1
```

## 2、尝试恢复pg4.210丢失的块

1)查看pg4.210
```
# ceph pg 4.210 query 
    "recovery_state": [
        {
            "name": "Started/Primary/Active",
            "enter_time": "2019-07-09 23:04:31.718033",
            "might_have_unfound": [
                {
                    "osd": "4",
                    "status": "already probed"
                },
                {
                    "osd": "6",
                    "status": "already probed"
                },
                {
                    "osd": "15",
                    "status": "already probed"
                },
                {
                    "osd": "17",
                    "status": "already probed"
                },
                {
                    "osd": "20",
                    "status": "already probed"
                },
                {
                    "osd": "22",
                    "status": "osd is down"
                },
                {
                    "osd": "23",
                    "status": "already probed"
                },
                {
                    "osd": "26",
                    "status": "osd is down"
                }
            ]
```
- 字面上理解，pg 4.210的自我恢复状态，它已经探查了osd4、6、15、17、20、23,osd22和26已经down了，而我这里的osd22和26都已经移出了集群

might_have_unfound的osd有以下四种状态
- already probed
- querying
- OSD is down
- not queried (yet)


两种解决方案，回退旧版或者直接删除
```
# ceph pg 4.210 mark_unfound_lost revert
Error EINVAL: pg has 1 unfound objects but we haven't probed all sources,not marking lost

# ceph pg 4.210 mark_unfound_lost delete
Error EINVAL: pg has 1 unfound objects but we haven't probed all sources,not marking lost
```
- 提示报错，pg那个未发现的块还没有探查所有的资源，不能标记为丢失，也就是不会回退也不可以删除,可能是已经down的osd22和26未探查，刚好坏的节点也重装完成，重新添加osd



添加完成后，再次查看pg 4.210
```
    "recovery_state": [
            {
                "name": "Started/Primary/Active",
                "enter_time": "2019-07-15 15:24:32.277667",
                "might_have_unfound": [
                    {
                        "osd": "4",
                        "status": "already probed"
                    },
                    {
                        "osd": "6",
                        "status": "already probed"
                    },
                    {
                        "osd": "15",
                        "status": "already probed"
                    },
                    {
                        "osd": "17",
                        "status": "already probed"
                    },
                    {
                        "osd": "20",
                        "status": "already probed"
                    },
                    {
                        "osd": "22",
                        "status": "already probed"
                    },
                    {
                        "osd": "23",
                        "status": "already probed"
                    },
                    {
                        "osd": "24",
                        "status": "already probed"
                    },
                    {
                        "osd": "26",
                        "status": "already probed"
                    }
                ],
                "recovery_progress": {
                    "backfill_targets": [
                        "20",
                        "26"
     
                    ],
```

可以看到所有的资源都probed了，此时执行回退命令
```
# ceph pg  4.210  mark_unfound_lost revert
pg has 1 objects unfound and apparently lost marking
```

查看集群状态
```
# ceph health detail
HEALTH_OK
```

恢复池vms的min_size为2
```
# ceph osd pool set vms min_size 2
set pool 4 min_size to 2
```
















