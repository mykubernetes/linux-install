https://blog.csdn.net/weixin_43304804/article/details/85345695
---

```
#组件集群
# gluster peer probe giant2
# gluster peer probe giant3
# gluster peer probe giant4

#创建逻辑卷

分布卷,将文件进行分布，10G+10G=20G
# gluster volume create gv1 giant1:/storage/brick1 giant2:/storage/brick1 force

复制卷，相当于raid1,10G+10G=10G
# gluster volume create gv2 replica 2 giant3:/storage/brick1 giant4:/storage/brick1 force

条带卷,相当于raid0,10G+10G=20G
# gluster volume create gv3 stripe 2 giant3:/storage/brick2 giant4:/storage/brick2 force

# 分布式复制卷（先复制，后分布）
# gluster volume add-brick gv2 replica 2 giant1:/storage/brick2 giant2:/storage/brick2 force
# gluster volume rebalance gv2 start      # 平衡工作
# gluster volume rebalance gv2 status

# 删除卷
# gluster volume remove-brick gv2 replica 2 giant3:/storage/brick1 giant4:/storage/brick1 force
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
