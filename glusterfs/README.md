https://blog.csdn.net/weixin_43304804/article/details/85345695
---

```
#组件集群
# gluster peer probe giant2
# gluster peer probe giant3
# gluster peer probe giant4

#创建逻辑卷
# gluster volume create gv1 giant1:/storage/brick1 giant2:/storage/brick1 force
# gluster volume create gv2 replica 2 giant3:/storage/brick1 giant4:/storage/brick1 force
# gluster volume create gv3 stripe 2 giant3:/storage/brick2 giant4:/storage/brick2 force
# gluster volume add-brick gv2 replica 2 giant1:/storage/brick2 \

giant2:/storage/brick2 force              # 扩容（先复制，后分布）
# gluster volume rebalance gv2 start      # 平衡工作
# gluster volume rebalance gv2 status
# gluster volume remove-brick gv2 replica 2 giant3:/storage/brick1 \
giant4:/storage/brick1 force              # 拆伙
# gluster volume delete gv3

#查看信息
# gluster volume info
# gluster volume info gv2

#客户端挂载
# mount -t glusterfs 127.0.0.1:/gv1 /mnt
# mount -t glusterfs 127.0.0.1:/gv2 /opt
# ls /mnt/
# ls /storage/brick1/
```

安装
---
下载安装包地址  
https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.7/

1、配置yum源
```
# mv /etc/yum.repos.d/* /tmp
# vim /etc/yum.repos.d/gluster.repo 
[gluster]
name=gluster
# baseurl=http://10.0.0.99
baseurl=https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.7/
enabled=1
gpgcheck=0

拷贝文件
# scp /etc/yum.repos.d/gluster.repo 192.168.101.66:/etc/yum.repos.d/
# scp /etc/yum.repos.d/gluster.repo 192.168.101.67:/etc/yum.repos.d/
# scp /etc/yum.repos.d/gluster.repo 192.168.101.68:/etc/yum.repos.d/
```


2、安装
```
# yum install -y glusterfs-server*
# yum install -y glusterfs-rdma*
# yum install -y glusterfs-geo-replication
# rpm -qa glusterfs* | wc -l
```

```
# glusterfs -V
	glusterfs 3.7.20 built on Jan 30 2017 15:39:27

# chkconfig --list glusterd
	glusterd        0:off   1:off   2:on    3:on    4:on    5:on    6:off
# service glusterd start
	Starting glusterd:                                         [  OK  ]
# service glusterd status
	glusterd (pid  3341) is running...

# alias grep='grep --color=auto'
#  netstat -tunlp | grep glus
	tcp        0      0 0.0.0.0:49152      0.0.0.0:*        LISTEN      4633/gluterfsd     
	tcp        0      0 0.0.0.0:24007      0.0.0.0:*        LISTEN      3341/gluterd       
```

确认关闭防火墙
```
# /etc/init.d/iptables status
	iptables: Firewall is not running.
# getenforce
	Disabled
```

```
# gluster volume create gv1 giant1:/storage/brick1 giant2:/storage/brick1 force
	volume create: gv1: success: please start the volume to access data

# gluster volume start gv1
	volume start: gv1: success

# gluster volume info
```
