灾难恢复
===
etcd被设计为能承受集群自动从临时失败(例如机器重启)中恢复，而且对于一个有N个成员的集群能容许(N-1)/2 的持续失败。当一个成员持续失败时，不管是因为硬件失败或者磁盘损坏，它丢失到集群的访问。如果集群持续丢失超过(N-1)/2 的成员，则它只能悲惨的失败，无可救药的失去法定人数(quorum)。一旦法定人数丢失，集群无法达到一致性而导致无法继续接收更新。为了从灾难失败中恢复数据，etcd v3提供快照和修复工具来重建集群而不丢失v3键数据。

一、etcd证书制作
---
由于 v3 版本的 etcd 证书是基于 IP 的，所以每次新增 etcd 节点都需要重新制作证书。

二、备份集群
---
```
在单节点etcd上执行下面的命令就可以对etcd进行数据备份
$ export ETCDCTL_API=3
$ etcdctl --endpoints 127.0.0.1:2379 snapshot save $(date +%Y%m%d_%H%M%S)_snapshot.db
```

三、恢复集群
---
为了恢复集群，使用之前任意节点上备份的快照 "db" 文件。恢复的手，可以使用etcdctl snapshot restore命令来恢复etc 数据目录，此时所有成员应该使用相同的快照恢复。因为恢复数据死后，会覆盖某些快照元数据(特别是成员ID和集群ID)信息，集群内的成员可能会丢失它之前的标识。因此为了从快照启动集群，恢复必须启动一个新的逻辑集群。

在恢复时，快照完整性的检验是可选的。如果快照是通过etcdctl snapshot save得到的话，使用etcdctl snapshot restore命令恢复的时候，会检查hash值的完整性。如果快照是从数据目录复制而来，则没有完整性校验，因此它只能通过使用--skip-hash-check来恢复。

1.恢复时，首先停止掉etcd的服务
```
[root@k8s001 ~]# systemctl stop etcd
[root@k8s002 ~]# systemctl stop etcd
[root@k8s003 ~]# systemctl stop etcd
```

2.清除异常数据目录
```
[root@k8s001 ~]# rm -rf /var/lib/etcd
[root@k8s002 ~]# rm -rf /var/lib/etcd
[root@k8s003 ~]# rm -rf /var/lib/etcd
```

3.恢复etcd数据目录
```
[root@k8s001 ~]# export ETCDCTL_API=3
[root@k8s001 ~]# etcdctl snapshot restore 20200629_200504_snapshot.db --name etcd1 --initial-cluster etcd1=https://172.16.1.188:2380,etcd2=https://172.16.1.189:2380,etcd3=https://172.16.1.190:2380 --initial-cluster-token=etcd-cluster-0 --initial-advertise-peer-urls=https://172.16.1.188:2380 --data-dir /var/lib/etcd

[root@k8s002 ~]# export ETCDCTL_API=3
[root@k8s002 ~]# etcdctl snapshot restore 20200629_200504_snapshot.db --name etcd2 --initial-cluster etcd1=https://172.16.1.188:2380,etcd2=https://172.16.1.189:2380,etcd3=https://172.16.1.190:2380 --initial-cluster-token=etcd-cluster-1 --initial-advertise-peer-urls=https://172.16.1.189:2380 --data-dir /var/lib/etcd

[root@k8s003 ~]# export ETCDCTL_API=3
[root@k8s003 ~]# etcdctl snapshot restore 20200629_200504_snapshot.db --name etcd3 --initial-cluster etcd1=https://172.16.1.188:2380,etcd2=https://172.16.1.189:2380,etcd3=https://172.16.1.190:2380 --initial-cluster-token=etcd-cluster-2 --initial-advertise-peer-urls=https://172.16.1.190:2380 --data-dir /var/lib/etcd
```

4.启动etcd服务
```
[root@k8s001 ~]# systemctl restart etcd
[root@k8s002 ~]# systemctl restart etcd
[root@k8s003 ~]# systemctl restart etcd
```

四、单节点集群备份恢复
---
```
[root@k8s001 ~]# export ETCDCTL_API=3
[root@k8s001 ~]# etcdctl --endpoints 127.0.0.1:2379 snapshot save $(date +%Y%m%d_%H%M%S)_snapshot.db
[root@k8s001 ~]# systemctl stop etcd 
[root@k8s001 ~]# rm -rf /var/lib/etcd 
[root@k8s001 ~]# etcdctl snapshot restore 20200629_141504_snapshot.db --data-dir /var/lib/etcd
[root@k8s001 ~]# systemctl restart etcd
```

# 备份恢复,整体步骤
- 通过 etcdctl 子命令即可完成，注意需要停止 etcd 服务并清空对应的 data 目录。
```
# 备份数据
ETCDCTL_API=3 etcdctl snapshot save etcd.db
# 数据状态
etcdctl snapshot status etcd.db  -w table
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| 77e8a851 |        2 |          5 |      20 kB |
+----------+----------+------------+------------+

etcdctl --endpoints $ENDPOINT snapshot restore snapshot.db --data-dir /var/lib/etcd
```
