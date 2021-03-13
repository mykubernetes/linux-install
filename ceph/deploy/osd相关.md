OSD状态表
---
| 状态 | 说明 |
|-----|------|
| up | osd启动 |
| down | osd停止 |
| in | osd在集群中 |
| out | osd不在集群中，默认OSD down 超过300s,Ceph会标记为out，会触发重新平衡操作 |
| up & in | 说明该OSD正常运行，且已经承载至少一个PG的数据。这是一个OSD的标准工作状态 |
| up & out | 说明该OSD正常运行，但并未承载任何PG，其中也没有数据。一个新的OSD刚刚被加入Ceph集群后，便会处于这一状态。而一个出现故障的OSD被修复后，重新加入Ceph集群时，也是处于这一状态 |
| down & in | 说明该OSD发生异常，但仍然承载着至少一个PG，其中仍然存储着数据。这种状态下的OSD刚刚被发现存在异常，可能仍能恢复正常，也可能会彻底无法工作 |
| down & out | 说明该OSD已经彻底发生故障，且已经不再承载任何PG |



# 添加osd

首先进行安装前准备工作  
1.安装ceph相关的package  
```
# ceph-deploy install ceph-1 ceph-2 ceph-3
```  
如果目标结点上/etc/yum.repos.d/ceph.repo文件不存在,ceph-deploy install会在目标结点上创建/etc/yum.repos.d/ceph.repo文件。也可以自定义repo的地址:
```
# ceph-deploy install ceph-1 ceph-2 ceph-3  --repo-url http://mirrors.aliyun.com/ceph/rpm-jewel/el7/
```  
2. 查看磁盘列表  
```
# ceph-deploy disk list ceph-1
......
[ceph_deploy.osd][DEBUG ] Listing disks on ceph-1...
[ceph-1][DEBUG ] find the location of an executable
[ceph-1][INFO  ] Running command: /usr/sbin/ceph-disk list
[ceph-1][DEBUG ] /dev/dm-0 other, xfs, mounted on /
[ceph-1][DEBUG ] /dev/dm-1 swap, swap
[ceph-1][DEBUG ] /dev/sda :
[ceph-1][DEBUG ]  /dev/sda2 other, LVM2_member
[ceph-1][DEBUG ]  /dev/sda1 other, xfs, mounted on /boot
[ceph-1][DEBUG ] /dev/sdb :
[ceph-1][DEBUG ]  /dev/sdb2 other
[ceph-1][DEBUG ]  /dev/sdb1 ceph data, active, cluster ceph, osd.0
[ceph-1][DEBUG ] /dev/sr0 other, unknown
[root@ceph-1 deploy]#
```  
3.清除磁盘数据  

如果磁盘上有数据,可以先清除  
```
# ceph-deploy disk zap ceph-1:/dev/sdb
```  
4.添加osd结点  
```
# ceph-deploy osd create ceph-1:/dev/sdb
```  

# 移除OSD

1.在crush中设置OSD weight为0，等待迁移完成。  
```
# ceph osd crush reweight osd.{osd-num} 0
```  
2.从集群中设置OSD为out（如果OSD还处于in状态）  
```
# ceph osd out {osd-num}
```  
3.停止OSD进程（如果进程还在运行）：  
```
# systemctl stop ceph-osd@{osd-num}
```  
4.从CRUSH map中移除osd  
```
# ceph osd crush remove osd.{osd-num}
```  
5.删除osd认证key  
```
# ceph auth del osd.{osd-num}
```  
6.从集群中移除集群  
```
# ceph osd rm {osd-num}
```  

