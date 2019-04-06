
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

本文参考同事的文档  

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

