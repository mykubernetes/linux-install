
```
# ceph -s
cluster:
    id:     146cbeb9-2cd0-4471-89df-47793593ab21
    health: HEALTH_ERR
            Reduced data availability: 63 pgs inactive, 62 pgs peering
            119 slow requests are blocked > 32 sec. Implicated osds
            9017 stuck requests are blocked > 4096 sec. Implicated osd 42,104,193,219
 
  services:
    mon: 3 daemons, quorum 11.141.0.14-CLUSTERMON_A,11.140.1.14-CLUSTERMON_B, out of quorum: 11.141.0.142-CLUSTERMON_C
    mgr: CLUSTERMGR-11.140.1.14(active), standbys: CLUSTERMGR-11.141.0.14
    osd: 220 osds: 209 up, 220 in
    rgw: 1 daemon active
 
  data:
    pools:   7 pools, 17536 pgs
    objects: 303.01k objects, 74.8GiB
    usage:   343GiB used, 2.13PiB / 2.13PiB avail
    pgs:     0.359 pgs not active
             17473 active+clean
             62    peering
             1     activating
```
