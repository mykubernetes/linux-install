flag	介绍
---

Ceph是一个分布式系统，旨在从数十个OSD扩展到数千个。维护Ceph集群所需的关键之一是管理其OSD。

我们假设您要在生产Ceph集群中添加新节点。一种方法是简单地将具有多个磁盘的新节点添加到Ceph集群，并且集群将开始回填并将数据混洗到新节点上。这适用于测试集群。

然而，当涉及到生产系统中，你应该使用noin，nobackfill，等等。这样做是为了在新节点进入时集群不会立即启动回填过程。然后，您可以在非高峰时段取消设置这些标志，并且集群将花时间重新平衡：

设置flag
```
$ ceph osd set <flag_name>
$ ceph osd set noout
$ ceph osd set nodown
$ ceph osd set norecover
```

取消flag
```
$ ceph osd unset <flag_name>
$ ceph osd unset noout
$ ceph osd unset nodown
$ ceph osd unset norecover
```


| Flag字段 | 描述 |
|----------|-----|
| noup | 防止osd进入up状态，标记osd进程未启动，一般用于新添加osd。 |
| nodown | 防止osd进入down状态，一般用在检查osd进程时，而导致osd down，发生数据迁移。 |
| noout | 防止osd进入out状态，down状态的osd	300s后会自动被标记未	out，此时，数据就会发生迁移。noout标记后，如果osd	down,	该osd的pg会切换到副本osd上 |
| noin | 防止osd加入ceph	集群，一般用在新添加osd后，又不想马上加入集群，导致数据迁移。 |
| nobackfill | 防止集群进行数据回填操作，Ceph集群故障会触发	backfill |
| norebalance | 防止数据平衡操作，Ceph集群在扩容时会触发rebalance操作。一般和 nobackfill,norecover一起使用，用于防止数据发生数据迁移等操作。 |
| norecover | 防止数据发生恢复操作。 |
| noscrub | 防止集群清洗操作，在高负载、recovery,	backfilling,rebalancing等期间，为了保证集群性能，可以和	nodeep-scrub	一起设置。 |
| nodeep-scrub | 防止集群进行深度清洗操作。因为会阻塞读写操作，影响性能。一般不要长时间设置该值，否则，一旦取消该值，则会由大量的pg进行深度清洗。 |
| pause | 设置该标志位，则集群停止读写，但不影响osd自检 |
| full | 标记集群已满，将拒绝任何数据写入，但可读 |


节流回填和恢复
---
如果要在生产峰值中添加新的OSD节点，又希望对客户端IO中产生的影响最小，这时就可以借助以下命令限制回填和恢复。

设置`osd_max_backfills = 1`选项以限制回填线程。可以在`ceph.conf [osd]`部分中添加它，也可以使用以下命令动态设置
```
$ ceph tell osd.* injectargs '--osd_max_backfills 1'
```

设置`osd_recovery_max_active = 1`选项以限制恢复线程。可以在`ceph.conf [osd]`部分中添加它，也可以使用以下命令动态设置
```
$ ceph tell osd.* injectargs '--osd_recovery_max_active 1'
```

设置`osd_recovery_op_priority = 1`选项以降低恢复优先
```
$ ceph tell osd.* injectargs '--osd_recovery_op_priority 1'
```


OSD	和	PG	修复
---
```
# 这将在指定的OSD上执行修复。
ceph osd repair

# 这将在指定的PG上执行修复。请谨慎使用此命令;根据您的群集状态，如果未仔细使用，此命令可能会影响用户数据。
ceph pg repair

# 这将在指定的PG上执行清理。
ceph pg scrub 

# 这会对指定的PG执行深度清理。
ceph deep-scrub 
```

集群空间限制
---
当集群到达到 mon_osd_full_ratio 参数的值时，他会停止接受来自客户端的写入请求，并进入HEALTH_ERR 状态。默认情况下，设置为集群中的可用空间的0.95（95%）。应该使用全满比率来保留充足的空间，这样一个或多个OSD同时出现故障时，仍然留有足够的保留空间，自动恢复就不会造成集群真正耗尽空间。

```
ceph osd set-full-ratio 0.8
```


mon_osd_nearfull_ration 参数是一个根据保守的限值。超出这个限值时，集群会进入 HEALTH_WARN状态。 这是为了在达到全满比率之前，提醒需要添加OSD到集群或者修复问题。默认情况下，设置为集群中可用空间的0.85（85%）。
