# Pool 开启 enabled
```
pool 的 enabled 开启：

$ ceph -s
  cluster:
    id:     b313ec26-5aa0-4db2-9fb5-a38b207471ee
    health: HEALTH_WARN
            application not enabled on 3 pool(s)
  
$ ceph health detail
HEALTH_WARN application not enabled on 3 pool(s); mon master003 is low on available space
POOL_APP_NOT_ENABLED application not enabled on 3 pool(s)
    application not enabled on pool 'nextcloud'
    application not enabled on pool 'gitlab-ops'
    application not enabled on pool 'kafka-ops'
    use 'ceph osd pool application enable <pool-name> <app-name>', where <app-name> is 'cephfs', 'rbd', 'rgw', or freeform for custom applications.
MON_DISK_LOW mon master003 is low on available space
    mon.master003 has 24% avail
```

执行 enabled：
```
$ ceph osd pool application enable nextcloud rbd
$ ceph osd pool application enable gitlab-ops rbd
$ ceph osd pool application enable kafka-ops rbd
```
