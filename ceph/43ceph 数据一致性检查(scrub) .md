Ceph为了保障数据高可用一般来说同一份数据会存储3份，那么数据在写入的时候就会存在数据同步的问题。Ceph也是提供了对应的工具可以周期性的进行数据一致性检查。

## 一般来说有以下两种检查方式：
- 轻量级：主要是检查object数量、object源数据（object metadata）信息是否一致（文件大小等），若存在不一致的情况则从主节点重新复制一份。轻量级检查主要是检查磁盘坏道等，默认每天检查一次。
- 深度检查：进行数据的内容进行Hash检查（bit to bit），那么在数据量非常大的时候将对性能造成影响。默认深度检查时每周检查一次。

## 手动触发数据检查
```
# 查看当前pg信息
$ ceph pg dump

# 轻量检查
$ ceph pg scrub 3.b
instructing pg 3.b on osd.0 to scrub

# 深度检查
$ ceph pg deep-scrub 3.b
instructing pg 3.b on osd.0 to deep-scrub
```

## 设置scrub参数
```
# 获取默认配置
$ ceph --admin-daemon /var/run/ceph/ceph-mon.pod4-core-20-10.asok config get osd_scrub_max_interval 
{
    "osd_scrub_max_interval": "604800.000000"
}

# 设置配置参数
$ ceph --admin-daemon /var/run/ceph/ceph-mon.pod4-core-20-10.asok config set osd_scrub_max_interval 24000
{
    "success": "osd_scrub_max_interval = '24000.000000' (not observed, change may require restart) "
}

# 确认已修改成功
$ ceph --admin-daemon /var/run/ceph/ceph-mon.pod4-core-20-10.asok config get osd_scrub_max_interval      
{
    "osd_scrub_max_interval": "24000.000000"
}
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
