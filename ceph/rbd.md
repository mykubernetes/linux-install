安装rbd客户端工具
===============

1、在服务器端创建 ceph 块客户端用户名和认证密钥  
``` # ceph auth get-or-create client.rbd mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd' |tee ./ceph.client.rbd.keyring ```  

2、将认证秘钥和配置文件拷贝到客户端  
```
# scp ceph.client.rbd.keyring node04:/etc/ceph/
#scp /etc/ceph/ceph.conf node04:/etc/ceph/
```  
3、客户端检查是否符合块设备环境要求
```
uname -r
modprobe rbd
echo $?
```  
4、安装ceph客户端
```
wget -O /etc/yum.repos.d/ceph.repo https://raw.githubusercontent.com/aishangwei/ceph-demo/master/ceph-deploy/ceph.repo
yum -y install ceph
cat /etc/ceph/ceph.client.rbd.keyring
ceph -s --name client.rbd
```  


客户端创建块设备及映射
=====================

默认创建块设备，会直接创建在rbd 池中，但使用 deploy 安装后，该rbd池并没有创建。  
1、在服务器端创建池和块  
```
ceph osd lspools              # 查看集群存储池
ceph osd pool create rbd 512  # 50 为place group数量(pg)
```  
确定 pg_num 取值是强制性的，因为不能自动计算。下面是几个常用的值：  
• 少于 5 个 OSD 时可把 pg_num 设置为 128  
• OSD 数量在 5 到 10 个时，可把pg_num 设置为 512  
• OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096  
• OSD 数量大于 50 时，你得理解权衡方法、以及如何自己计算pg_num 取值  
2、客户端创建 块设备  
```
rbd create rbd1 --size 10240 --name client.rbd
rbd ls --name client.rbd
rbd ls -p rbd --name client.rbd
rbd list --name client.rbd
rbd --image rbd1 info --name client.rbd
```  



映射块设备
==========

1、映射到客户端，应该会报错  
``` # rbd map --image rbd1 --name client.rbd ``` 
• layering: 分层支持  
• exclusive-lock: 排它锁定支持对  
• object-map: 对象映射支持(需要排它锁定(exclusive-lock))  
• deep-flatten: 快照平支持(snapshot flatten support)  
• fast-diff: 在client-node1上使用krbd(内核rbd)客户机进行快速diff计算(需要对象映射)，我们将无法在CentOS内核3.10上映射块设备映像，因为该内核不支持对象映射(object-map)、深平(deep-flatten)和快速diff(fast-diff)(在内核4.9中引入了支持)。为了解决这个问题，我们将禁用不支持的特性，有几个选项可以做到这一点:  

1）动态禁用  
``` # rbd feature disable rbd1 exclusive-lock object-map deep-flatten fast-diff --name client.rbd ```  
2） 创建RBD镜像时，只启用 分层特性。  
``` # rbd create rbd2 --size 10240 --image-feature layering --name client.rbd ```  
3）ceph 配置文件中禁用  
``` rbd_default_features = 1 ```  

2动态禁用  
```
# rbd feature disable rbd1 exclusive-lock object-map deep-flatten fast-diff
# rbd map --image rbd1 --name client.rbd
# rbd showmapped --name client.rbd
```  
3、创建文件系统，并挂载  
```
# fdisk -l /dev/rbd0
# mkfs.xfs /dev/rbd0
# mkdir /mnt/ceph-disk1
# mount /dev/rbd0 /mnt/ceph-disk1
# df -h /mnt/ceph-disk1
```  
4、写入数据测试  
``` # dd if=/dev/zero of=/mnt/ceph-disk1/file1 count=100 bs=1M ```  
5、做成服务，开机自动挂载  
```
# wget -O /usr/local/bin/rbd-mount https://raw.githubusercontent.com/aishangwei/ceph-demo/master/client/rbd-mount
# chmod +x /usr/local/bin/rbd-mount
# wget -O /etc/systemd/system/rbd-mount.service https://raw.githubusercontent.com/aishangwei/ceph-demo/master/client/rbd-mount.service
# systemctl daemon-reload
# systemctl enable rbd-mount.service
# reboot -f
# df -h
```  
