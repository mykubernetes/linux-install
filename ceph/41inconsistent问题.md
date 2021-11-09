1、查看集群状态，提示有181个pg处于不一致状态
```
[root@ceph-osd-3 ~]# ceph -s
    cluster 9d717e10-a708-482d-b91c-4bd21f4ae36c
     health HEALTH_ERR 181 pgs inconsistent; 10009 scrub errors
     monmap e9: 1 mons at {ceph-osd-1=10.10.200.163:6789/0}, election epoch 1, quorum 0 ceph-osd-1
     osdmap e2455: 7 osds: 7 up, 7 in
      pgmap v92795: 1536 pgs, 6 pools, 306 GB data, 85633 objects
            830 GB used, 11075 GB / 11905 GB avail
                   1 active+clean+scrubbing+deep
                1354 active+clean
                 181 active+clean+inconsistent
```

2、查看详细信息
```
[root@ceph-osd-3 ~]# ceph health detail
HEALTH_ERR 181 pgs inconsistent; 10009 scrub errors
pg 4.f9 is active+clean+inconsistent, acting [6,3,0]
pg 2.fe is active+clean+inconsistent, acting [4,3,0]
pg 4.ff is active+clean+inconsistent, acting [4,0,1]
pg 2.f8 is active+clean+inconsistent, acting [4,2,0]
pg 1.f8 is active+clean+inconsistent, acting [6,0,3]
pg 2.fa is active+clean+inconsistent, acting [5,0,3]
.......
pg 2.f5 is active+clean+inconsistent, acting [4,0,2]
pg 4.f2 is active+clean+inconsistent, acting [6,3,0]
pg 4.f1 is active+clean+inconsistent, acting [6,0,1]
pg 2.f7 is active+clean+inconsistent, acting [4,3,0]
```

3、修复处于不一致状态的pgs
```
#ceph pg repair $pgid
```

4、经过一段时间的修复后，查看ceph状态恢复正常
```
[root@ceph-osd-1 ~]# ceph -s
    cluster 9d717e10-a708-482d-b91c-4bd21f4ae36c
     health HEALTH_OK
     monmap e9: 1 mons at {ceph-osd-1=10.10.200.163:6789/0}, election epoch 1, quorum 0 ceph-osd-1
     osdmap e2459: 7 osds: 7 up, 7 in
      pgmap v93412: 1536 pgs, 6 pools, 306 GB data, 85633 objects
            830 GB used, 11075 GB / 11905 GB avail
                1536 active+clean
```

