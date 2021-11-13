# 基本概念

## 1、什么是 Scrub
- Scrub是 Ceph 集群副本进行数据扫描的操作，用于检测副本间数据的一致性，包括 scrub 和 deep-scrub。其中scrub 只对元数据信息进行扫描，相对比较快；而deep-scrub 不仅对元数据进行扫描，还会对存储的数据进行扫描，相对比较慢。


- scrub：主要是检查object数量、object源数据（object metadata）信息是否一致（文件大小等），若存在不一致的情况则从主节点重新复制一份。轻量级检查主要是检查磁盘坏道等，默认每天检查一次。
- deep-scrub：进行数据的内容进行Hash检查（bit to bit），那么在数据量非常大的时候将对性能造成影响。默认深度检查时每周检查一次。


## 2、Scrub默认执行周期
- OSD 的scrub 默认策略是每天到每周（如果集群负载大周期就是一周，如果集群负载小周期就是一天）进行一次，时间区域默认为全体（0时-24时），deep-scrub默认策略是每周一次。


## 配置scrub策略
- 为了避开客户业务高峰时段，建议在晚上0点到第二天早上5点之间，执行scrub 操作。

1、设置标识位
```
ceph osd set noscrub
ceph osd set nodeep-scrub
```

2、临时配置

先通过tell 方式，让scrub 时间区间配置立即生效
```
ceph tell osd.* injectargs '--osd_scrub_begin_hour 0'
ceph tell osd.* injectargs '--osd_scrub_end_hour 5'
ceph tell mon.* injectargs '--osd_scrub_begin_hour 0'
ceph tell mon.* injectargs '--osd_scrub_end_hour 5'
```

查看配置
```
ceph daemon osd.0 config show|grep osd |grep scrub
```

3、修改配置文件

为了保证集群服务重启或者节点重启依然有效，需要修改Ceph集群所有节点的配置文件 /etc/ceph/ceph.conf
```
# vim /etc/ceph/ceph.conf

添加以下区段配置
[osd]
osd_scrub_begin_hour = 0    # scrub操作的起始时间为0点
osd_scrub_end_hour = 5      # scrub操作的结束时间为5点
```
注意: 该时间设置需要参考物理节点的时区设置

4、取消标识位
```
ceph osd unset noscrub
ceph osd unset nodeep-scrub
```

5、向 OSD {osd-num} 下达一个scrub命令. (用通配符 * 把命令下达到所有 OSD 。实测ceph 12.2.x版本不能加*)
```
ceph osd scrub {osd-num}

实例：
ceph osd scrub osd.0
```

6、设置 light scrub 周期

将osd_scrub_min_interval 和 osd_scrub_max_interval都设为4分钟,这里的单位是秒
```
 ceph --admin-daemon /var/run/ceph/ceph-mon.node0.asok config set osd_scrub_max_interval 240
{ "success": "osd_scrub_max_interval = '240' "} 

 ceph --admin-daemon /var/run/ceph/ceph-mon.node0.asok config get osd_scrub_max_interval 
{ "osd_scrub_max_interval": "240"} 

 ceph --admin-daemon /var/run/ceph/ceph-mon.node0.asok config set osd_scrub_min_interval 240 
{ "success": "osd_scrub_min_interval = '240' "} 

 ceph --admin-daemon /var/run/ceph/ceph-mon.node0.asok config get osd_scrub_min_interval 
{ "osd_scrub_min_interval": "240"}
```

7、通过命令手动启动scrub ：
```
ceph pg scrub 9.1e

ceph pg deep-scrub 9.1e
```

8、尝试 pg repair
```
ceph pg repair 9.1e
```

## 一致性检查参数

| 配置项 | 默认值 | 说明 |
|-------|-------|------|
| osd_scrub_chunk_min | 5 | PGScrub对应的Object数目的最小值 |
| osd_scrub_chunk_max | 25 | PGScrub对应的Object数目的最大值 |
| osd_deep_scrub_interval | 604800 | Deep scrub周期，单位是秒，默认是604800，也就是一周 |
| osd_scrub_sleep | 0 | 两个PGScrub Op间休息一段时间 |
| osd_heartbeat_interval | 6 | 周期性执行OSD::sched_scrub函数 |
| osd_scrub_begin_hour | 0 | 允许触发Scrub的时间段的起始时间 |
| osd_scrub_end_hour | 0 | 允许触发Scrub的时间段的结束时间，结束时间可以小于起始时间 |
| osd_scrub_auto_repair | FALSE | 自动repair不一致Object，不支持副本池，只支持EC池 |
| osd_max_scrubs | 1 | OSD允许同时运行的Scrub任务的最大数目 |
| osd_scrub_min_interval | 86400 | 一天，单位是秒，默认是86400，也就是一天 |
| osd_scrub_max_interval | 604800 | 一周，单位是秒，默认是604800，也就是一周 |
| osd_scrub_interval_randomize_ratio | 0.5 | [min, min*(1+randomize_ratio)] |
| osd_scrub_during_recovery | TRUE | 允许在OSD Recovery过程中执行Scrub任务 |
| osd_scrub_load_threshold | 0.5 | 只有负载低于该值时才允许触发Scrub |
