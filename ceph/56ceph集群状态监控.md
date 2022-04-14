# Ceph本身的健康状态信息：

## HEALTH_WARN：

| 集群健康状态描述信息 | 代表的现象 |
|-------------------|-----------|
| Monitor clock skew detected | 时钟偏移 |
| mons down, quorum | Ceph Monitor down |
| some monitors are running older code | 署完就可以看到，运行过程中不会出现 |
| in osds are down | OSD down后会出现 |
| flag(s) set | 标志位设置，可以忽略 |
| crush map has legacy tunables | 部署完就可以看到，运行过程中不会出现 |
| crush map has straw_calc_version=0 | 部署完就可以看到，运行过程中不会出现 |
| cache pools are missing hit_sets | 使用cache tier后会出现 |
| no legacy OSD present but 'sortbitwise' flag is not set | 部署完就可以看到，运行过程中不会出现 |
| has mon_osd_down_out_interval set to 0 | 将mon_osd_down_out_interval参数设置为0会出现，这个参数设置为0，和noout效力一致 |
| 'require_jewel_osds' osdmap flag is not set | 部署完就可以看到，运行过程中不会出现 |
| is full | pool满后会出现 |
| near full osd | OSD快满时警告 |
| unscrubbed pgs | 有些pg没有scrub |
| pgs stuck | PG处于一些不健康状态的时候，会显示出来 |
| requests are blocked | slow requests会警告 |
| osds have slow requests | slow requests会警告 |
| recovery | 需要recovery的时候会报 |
| at/near target max | 使用cache tier的时候会警告 |
| too few PGs per OSD | 每个OSD的PG数过少 |
| too many PGs per OSD | 每个OSD的PG数过多 |
| > pgp_num | pg_num大于pgp_num |
| has many more objects per pg than average (too few pgs?) | 每个Pg上的objects数过多 |

## HEALTH_ERR：

| 集群健康状态描述信息 | 代表的现象 |
|-------------------|-----------|
| no osds | 部署完就可以看到，运行过程中不会出现 |
| full osd | OSD满时出现 |
| pgs are stuck inactive for more than | Pg处于inactive状态，该Pg读写都不行 |
| scrub errors | scrub 错误出现，是scrub错误?还是scrub出了不一致的pg |

参考:
- https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/2/html/troubleshooting_guide/initial-troubleshooting
