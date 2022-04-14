# ceph mds高可用

Ceph mds(etadata service)作为 ceph 的访问入口，需要实现高性能及数据备份，假设启动 4 个 MDS 进程，设置 2 个 Rank。这时候有 2 个 MDS 进程会分配给两个 Rank，还剩下 2 个 MDS 进程分别作为另外2个的备份。

官方帮助：https://docs.ceph.com/en/latest/cephfs/add-remove-mds/

设置每个 Rank 的备份 MDS，也就是如果此 Rank 当前的 MDS 出现问题马上切换到另个 MDS。 设置备份的方法有很多，常用选项如下。
```
mds_standby_replay       #值为 true 或 false，true 表示开启 replay 模式，这种模式下主 MDS 内的数量将实时与从 MDS 同步，如果主宕机，从可以快速的切换。如果为 false 只有宕机的时候才去同步数据，这样会有一段时间的中断。
mds_standby_for_name     #设置当前 MDS 进程只用于备份于指定名称的 MDS。
mds_standby_for_rank     #设置当前 MDS 进程只用于备份于哪个 Rank，通常为 Rank 编号。另外在存在之个 CephFS 文件系统中，还可以使用 mds_standby_for_fscid 参数来为指定不同的文件系统。
mds_standby_for_fscid    #指定 CephFS 文件系统 ID，需要联合 mds_standby_for_rank 生效，如果设置 mds_standby_for_rank，那么就是用于指定文件系统的指定 Rank，如果没有设置，就是指定文件系统的所有 Rank。
```

## 1 当前mds服务器状态
```
[16:59:20 root@ceph-node1 ~]#ceph mds stat
cephfs-1/1/1 up  {0=ceph-node2=up:active}
```

## 2 添加mds服务器

将ceph-node1,ceph-node3,ceph-node4服务角色添加至ceph集群
```
#服务器安装ceph-mds服务
[17:23:16 root@ceph-node1 ~]#yum install ceph-mds
[17:50:59 root@ceph-node3 ~]#yum install ceph-mds
[17:51:09 root@ceph-node4 ~]#yum install ceph-mds

#添加 mds 服务器
[ceph@ceph-deploy ceph-cluster]$ ceph-deploy mds create ceph-node1
[ceph@ceph-deploy ceph-cluster]$ ceph-deploy mds create ceph-node3
[ceph@ceph-deploy ceph-cluster]$ ceph-deploy mds create ceph-node4
#验证当前mfs服务器当前状态
[17:52:58 root@ceph-node1 ~]#ceph mds stat 
cephfs-1/1/1 up  {0=ceph-node2=up:active}, 3 up:standby


#验证当前集群状态
[17:53:05 root@ceph-node1 ~]#ceph fs status 
cephfs - 0 clients
======
+------+--------+------------+---------------+-------+-------+
| Rank | State  |    MDS     |    Activity   |  dns  |  inos |
+------+--------+------------+---------------+-------+-------+
|  0   | active | ceph-node2 | Reqs:    0 /s |   11  |   14  |
+------+--------+------------+---------------+-------+-------+
+-----------------+----------+-------+-------+
|       Pool      |   type   |  used | avail |
+-----------------+----------+-------+-------+
| cephfs-metadata | metadata | 8211  |  109G |
|   cephfs-data   |   data   | 1749  |  109G |
+-----------------+----------+-------+-------+
+-------------+
| Standby MDS |
+-------------+
|  ceph-node1 |
|  ceph-node3 |
|  ceph-node4 |
+-------------+
MDS version: ceph version 13.2.10 (564bdc4ae87418a232fc901524470e1a0f76d641) mimic (stable)
```

### 3 当前的文件系统状态
```
[17:53:17 root@ceph-node1 ~]#ceph fs get cephfs
Filesystem 'cephfs' (2)
fs_name	cephfs
epoch	30
flags	12
created	2021-06-15 16:47:15.982006
modified	2021-06-15 16:47:16.990688
tableserver	0
root	0
session_timeout	60
session_autoclose	300
max_file_size	1099511627776
min_compat_client	-1 (unspecified)
last_failure	0
last_failure_osd_epoch	0
compat	compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,8=no anchor table,9=file layout v2,10=snaprealm v2}
max_mds	1
in	0
up	{0=105645}
failed
damaged
stopped
data_pools	[14]
metadata_pool	13
inline_data	disabled
balancer
standby_count_wanted	1
105645:	172.16.10.72:6800/2326179293 'ceph-node2' mds.0.29 up:active seq 27
```

## 4 设置处于激活状态 mds 的数量

如果有四个 mds 服务器，可以设置为两主两备
```
#设置cephfs的FS存储处于激活状态的节点数量
[17:53:43 root@ceph-node1 ~]#ceph fs set cephfs max_mds 2
#验证
[17:55:00 root@ceph-node1 ~]#ceph fs status 
cephfs - 0 clients
======
+------+--------+------------+---------------+-------+-------+
| Rank | State  |    MDS     |    Activity   |  dns  |  inos |
+------+--------+------------+---------------+-------+-------+
|  0   | active | ceph-node2 | Reqs:    0 /s |   11  |   14  |
|  1   | active | ceph-node4 | Reqs:    0 /s |   10  |   13  |
+------+--------+------------+---------------+-------+-------+
+-----------------+----------+-------+-------+
|       Pool      |   type   |  used | avail |
+-----------------+----------+-------+-------+
| cephfs-metadata | metadata | 9531  |  109G |
|   cephfs-data   |   data   | 1749  |  109G |
+-----------------+----------+-------+-------+
+-------------+
| Standby MDS |
+-------------+
|  ceph-node1 |
|  ceph-node3 |
+-------------+
MDS version: ceph version 13.2.10 (564bdc4ae87418a232fc901524470e1a0f76d641) mimic (stable)
```

## 5 MDS高可用配置

现在是ceph-node2和ceph-node4分别是active状态，ceph-node1和ceph-mgr3分别处于standby 状态，现在将 ceph-node1 设置为 ceph-node2 的 standby，将 ceph-node3 设置为 ceph-node4 的 standby，则配置文件如下：
```
[ceph@ceph-deploy ceph-cluster]$ cat ceph.conf 
[global]
fsid = 613e7f7c-57fe-4f54-af43-9d88ab1b861b
public_network = 172.16.10.0/24
cluster_network = 192.168.10.0/24
mon_initial_members = ceph-node1
mon_host = 172.16.10.71
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

[mds.ceph-node1]
mds_standby_for_name = ceph-node2
mds_standby_replay = true

[mds.ceph-node3]
mds_standby_for_name = ceph-node4
mds_standby_replay = true
```

## 6 分发配置文件重启mds服务
```
#分发配置文件
[ceph@ceph-deploy ceph-cluster]$ ceph-deploy --overwrite-conf config push ceph-node1
[ceph@ceph-deploy ceph-cluster]$ ceph-deploy --overwrite-conf config push ceph-node2
[ceph@ceph-deploy ceph-cluster]$ ceph-deploy --overwrite-conf config push ceph-node3
[ceph@ceph-deploy ceph-cluster]$ ceph-deploy --overwrite-conf config push ceph-node4

#重启服务
[18:03:12 root@ceph-node1 ~]#systemctl restart ceph-mds@ceph-node1.service
[18:03:12 root@ceph-node2 ~]#systemctl restart ceph-mds@ceph-node2.service
[18:03:12 root@ceph-node3 ~]#systemctl restart ceph-mds@ceph-node3.service 
[18:03:16 root@ceph-node4 ~]#systemctl restart ceph-mds@ceph-node4.service 
```

## 7 ceph集群mds高可用状态
```
[18:06:45 root@ceph-node4 ~]#ceph fs status
cephfs - 0 clients
======
+------+--------+------------+---------------+-------+-------+
| Rank | State  |    MDS     |    Activity   |  dns  |  inos |
+------+--------+------------+---------------+-------+-------+
|  0   | active | ceph-node3 | Reqs:    0 /s |   11  |   14  |
|  1   | active | ceph-node1 | Reqs:    0 /s |   10  |   13  |
+------+--------+------------+---------------+-------+-------+
+-----------------+----------+-------+-------+
|       Pool      |   type   |  used | avail |
+-----------------+----------+-------+-------+
| cephfs-metadata | metadata | 11.4k |  109G |
|   cephfs-data   |   data   | 1749  |  109G |
+-----------------+----------+-------+-------+
+-------------+
| Standby MDS |
+-------------+
|  ceph-node2 |
|  ceph-node4 |
+-------------+
MDS version: ceph version 13.2.10 (564bdc4ae87418a232fc901524470e1a0f76d641) mimic (stable)


[18:06:46 root@ceph-node4 ~]#ceph fs get cephfs
Filesystem 'cephfs' (2)
fs_name	cephfs
epoch	55
flags	12
created	2021-06-15 16:47:15.982006
modified	2021-06-15 18:06:25.277751
tableserver	0
root	0
session_timeout	60
session_autoclose	300
max_file_size	1099511627776
min_compat_client	-1 (unspecified)
```
