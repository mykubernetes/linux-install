安装rbd客户端工具
===============

服务器端配置认证
-----------
1、在服务器端创建 ceph 块客户端用户名和认证密钥  
``` # ceph auth get-or-create client.rbd mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd' |tee ./ceph.client.rbd.keyring ```  

2、将认证秘钥和配置文件拷贝到客户端  
```
# scp ceph.client.rbd.keyring node04:/etc/ceph/
# scp /etc/ceph/ceph.conf node04:/etc/ceph/
```  




客户端安装客户端工具
-----------
1、客户端检查是否符合块设备环境要求
```
# uname -r
# modprobe rbd
# echo $?
```  
2、安装ceph客户端
```
配置yum源
# cat /etc/yum.repos.d/ceph.repo 
[ceph]
name=ceph
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/x86_64/
gpgcheck=0
priority=1

[ceph-noarch]
name=cephnoarch
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/noarch/
gpgcheck=0
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/SRPMS
enabled=0
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

安装
# yum -y install ceph
# cat /etc/ceph/ceph.client.rbd.keyring
# ceph -s --name client.rbd
```  


服务器端配置存储池
------------------
默认创建块设备，会直接创建在rbd 池中，但使用 deploy 安装后，该rbd池并没有创建。  
1、在服务器端创建池和块  
```
# ceph osd lspools              # 查看集群存储池
# ceph osd pool create rbd 512  # 50 为place group数量(pg)
```  
确定 pg_num 取值是强制性的，因为不能自动计算。下面是几个常用的值：  
• 少于 5 个 OSD 时可把 pg_num 设置为 128  
• OSD 数量在 5 到 10 个时，可把pg_num 设置为 512  
• OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096  
• OSD 数量大于 50 时，你得理解权衡方法、以及如何自己计算pg_num 取值  

客户端申请image
-------------
1、客户端创建 块设备  
创建一个10G大小的块设备
```
创建块设备rbd1为块名 --size默认以M为单位 --pool 池名
# rbd create rbd1 --size 10240 --pool rbd --name client.rbd
```  
查看创建的块设备  
```
# rbd ls --name client.rbd
# rbd ls -p rbd --name client.rbd
# rbd list --name client.rbd
# rbd --image rbd1 info --name client.rbd
```  

查看块设备的详细信息  
```
# rbd info rbd/rbd1
rbd image 'rbd1':
    size 512 MB in 128 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.1ad6e2ae8944a
    format: 2
    features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
    flags:
```  
- size: 512 MB in 128 objects，表示该块设备的大小是512MBytes，分布在128个objects中，RBD默认的块大小是4MBytes
- order: order 22 (4096 kB objects)，指定RBD在OSD中存储时的block size，block size的计算公式是1<<order(单位是bytes)，在本例中order=22，所有block         size是1<<22bytes，也就是4096KBytes。order的默认值是22，RBD在OSD中默认的对象大小是4MBytes
- format: rbd image的格式，format1已经过期了。现在默认都是format2，被librbd和kernel3.11后面的版本支持
- block_name_prefix: 表示这个image在pool中的名称前缀，可以通过rados -p pool-frank6866 ls | grep rbd_data.1ad6e2ae8944a命令查看这个rbd image在rados中的所有object。但是要注意的是，刚创建的image，如果里面没有数据，不会在rados中创建object，只有写入数据时才会有。size字段中的objects数量表示的是最大的objects数量




客户端映射块设备
------------

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

2、动态禁用  
``` # rbd feature disable rbd1 exclusive-lock object-map deep-flatten fast-diff --name client.rbd ```  

3、映射到本地  
``` 
# rbd map --image rbd1 --name client.rbd 
/dev/rbd0
```  
或者  
``` # rbd map rbd1 --pool rbd --name client.rbd ```  

4、查看系统中已经映射到本地的块  
``` 
# rbd showmapped --name client.rbd
id pool image snap device    
0  rbd  rbd1  -    /dev/rbd0
```  

5、取消映射  
``` # rbd unmap /dev/rbd0 ```  

6、创建文件系统，并挂载  
```
# fdisk -l /dev/rbd0
# mkfs.xfs /dev/rbd0
# mkdir /mnt/ceph-disk1
# mount /dev/rbd0 /mnt/ceph-disk1
# df -h /mnt/ceph-disk1
```  
7、写入数据测试  
``` # dd if=/dev/zero of=/mnt/ceph-disk1/file1 count=100 bs=1M ```  
8、做成服务，开机自动挂载  
1)做成服务  
```
# cat /usr/local/bin/rbd-mount

#!/bin/bash

# Pool name where block device image is stored
export poolname=rbd
 
# Disk image name
export rbdimage=rbd1
 
# Mounted Directory
export mountpoint=/mnt/ceph-disk1
 
# Image mount/unmount and pool are passed from the systemd service as arguments
# Are we are mounting or unmounting
if [ "$1" == "m" ]; then
   modprobe rbd
   rbd feature disable $rbdimage object-map fast-diff deep-flatten
   rbd map $rbdimage --id rbd --keyring /etc/ceph/ceph.client.rbd.keyring
   mkdir -p $mountpoint
   mount /dev/rbd/$poolname/$rbdimage $mountpoint
fi
if [ "$1" == "u" ]; then
   umount $mountpoint
   rbd unmap /dev/rbd/$poolname/$rbdimage
fi

添加执行权限
# chmod +x /usr/local/bin/rbd-mount
```  

2)开机自动挂载
```
# cat /etc/systemd/system/rbd-mount.service 
[Unit]
Description=RADOS block device mapping for $rbdimage in pool $poolname"
Conflicts=shutdown.target
Wants=network-online.target
After=NetworkManager-wait-online.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/rbd-mount m
ExecStop=/usr/local/bin/rbd-mount u
[Install]
WantedBy=multi-user.target


# systemctl daemon-reload
# systemctl enable rbd-mount.service
```  

重启测试  
```
# reboot -f
# df -h
```  

调整Ceph RBD块大小
---
扩大RBD img  
```
# 调整块设备增加到3G
rbd resize --image rbd1 --size 3000 --name client.rbd
# 查看调整后的大小
rbd info --image rbd1 -n client.rbd
# 重新读取配置
xfs_growfs -d /mnt/ceph-disk1
```  


创建快照
---

1、创建一个测试文件到挂载目录  
``` echo "Hello cephtest,This is snapshot test" > /opt/ceph/ceph-snapshot-file ```  

2、创建快照  
语法： rbd snap create <pool name>/<image name>@<snap name>  
``` rbd snap create rbd/rbd1@snapshot1 -n client.rbd ```  

3、显示 image 的快照  
语法： rbd snap ls <pool name>/<image name>  
``` rbd snap ls rbd/rbd1 -n client.rbd ```  
    
恢复快照测试  
---
1、删除文件  
```  rm -rf /opt/ceph/* ```  

2、恢复快照  
语法： rbd snap rollback <pool-name>/<image-name>@<snap-name>  
```
# umount /opt/ceph-disk1 # 卸载文件系统
# rbd snap rollback rbd/rbd1@snapshot1 --name client.rbd # 回滚快照
```  

3、验证回滚  
```
# mount /dev/rbd0 /opt/ceph-disk1 # 重新挂载
# cat /opt/ceph/ceph-snapshot-file
Hello cephtest,This is snapshot test
```  

重命名快照  
---
1、重命名  
语法： rbd snap rename <pool-name>/<image-name>@<original-snapshot-name> <pool-name>/<image-name>@<new-snapshot-name>  
``` rbd snap rename rbd/rbd1@snapshot1 rbd/rbd1@snapshot1_new -n client.rbd ```  
 
删除快照  
---  
1、删除  
语法： rbd snap rm <pool-name>/<image-name>@<snap-name>  
```
# rbd snap rm rbd/rbd1@snapshot1_new --name client.rbd
Removing snap: 100% complete...done.
```  

删除多个快照,使用 purge  
---
语法： rbd snap purge <pool-name>/<image-name>  
``` rbd snap purge rbd/rbd1 --name client.rbd ```  


克隆
---
1、创建具有 layering 功能的 RBD image  
```
# rbd create rbd2 --size 1024 --image-feature layering --name client.rbd

# rbd info --image rbd2 -n client.rbd
rbd image 'rbd2':
    size 10240 MB in 2560 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.1102238e1f29
    format: 2
    features: layering
    flags:
```  

2、挂载 rbd2 块设备  
```
# rbd map --image rbd2 --name client.rbd
# mkfs.xfs /dev/rbd1
# mkdir /opt/ceph-disk2
# mount /dev/rbd1 /opt/ceph-disk2
# df -h /opt/ceph-disk2
# echo "devopsedu.net,rbd2" > /opt/ceph-disk2/rbd2file
# sync
```  

3、创建此 RBD image 的快照  
``` # rbd snap create rbd/rbd2@snapshot_for_clone -n client.rbd ```  

注意：要创建COW克隆，需要保护快照，因为如果快照被删除，所有附加的COW克隆将被销毁：  

4、保护快照  
```
# rbd snap protect rbd/rbd2@snapshot_for_clone -n client.rbd
# echo "devopsedu.net,rbd2snapshot" > /opt/ceph-disk2/rbd2-snapshot
```  

5、创建链接克隆  
语法： rbd clone <pool-name>/<parent-image-name>@<snap-name> <pool-name>/<child_image-name> --image-feature <feature-name>  
``` # rbd clone rbd/rbd2@snapshot_for_clone rbd/clone_rbd2 --image-feature layering -n client.rbd ```  

克隆的速度应该是非常快的，这时一个链接克隆。  
查看克隆后信息  
```
# rbd info rbd/clone_rbd2 -n client.rbd
rbd image 'clone_rbd2':
    size 1024 MB in 2560 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.110b2eb141f2
    format: 2
    features: layering
    flags:
    parent: rbd/rbd2@snapshot_for_clone
    overlap: 1024 MB

# rbd children rbd/rbd2@snapshot_for_clone -n client.rbd
rbd/clone_rbd2

# umount /opt/ceph-disk2
# rbd map --image clone_rbd2 --name client.rbd
# mount /dev/rbd2 /opt/ceph-disk2
# ll /opt/ceph-disk2
  -rw-r--r-- 1 root root 19 May 4 15:03 rbd2file
# echo "devopsedu.net,clone_rbd2" > /opt/ceph-disk2/clone_rbd2  
```  

6、创建完整克隆  
```
# rbd flatten rbd/clone_rbd2 -n client.rbd
Image flatten: 100% complete...done.
# rbd info --image clone_rbd2 --name client.rbd
rbd image 'clone_rbd2':
    size 10240 MB in 2560 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.110b2eb141f2
    format: 2
    features: layering
    flags:
```  
注意：如果在deep-flatten映像上启用了该功能，则默认情况下图像克隆与其父级分离。  

删除父镜像  
```
# rbd snap unprotect rbd/rbd2@snapshot_for_clone -n client.rbd    # 掉快照保护
# rbd snap rm rbd/rbd2@snapshot_for_clone -n client.rbd
Removing snap: 100% complete...done.
```  

验证数据  
验证父映像 rbd2  
```
# rbd list -n client.rbd
clone_rbd2
rbd1
rbd2

# umount /opt/ceph-disk2
# mount /dev/rbd1 /opt/ceph-disk2
# ll /opt/ceph-disk2/         # rbd2最终的文件
-rw-r--r-- 1 root root 19 May 4 15:03 rbd2file
-rw-r--r-- 1 root root 27 May 4 15:04 rbd2-snapshot
```  

验证完整克隆映像 clone_rbd2  
```
# umount /opt/ceph-disk2
# rbd unmap /dev/rbd1
# rbd rm rbd2 -n client.rbd
# mount /dev/rbd2 /opt/ceph-disk2
# ll /opt/ceph-disk2/
```  
