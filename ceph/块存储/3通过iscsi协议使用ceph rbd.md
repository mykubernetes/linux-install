一、OSD Server side
---

1、安装支持rbd的TGT软件包
```
# echo "deb http://ceph.com/packages/ceph-extras/debian $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/ceph-extras.list
# yum install tgt
```

2、安装完成后确认tgt支持rbd
```
# tgtadm --lld iscsi --op show --mode system | grep rbd
    rbd (bsoflags sync:direct)
```

3、创建一个image（示例中pool名称叫做iscsipool，image叫做iamge1）
```
#rbd create iscsipool/image1 --size 10240 --image-format 2
```

4、在tgt服务中注册刚才创建好的image，只需要将下面的内容添加到/etc/tgt/targets.conf 或者 etc/tgt/conf.d/ceph.conf中即可。
```
<target iqn.2014-04.rbdstore.example.com:iscsi>
    driver iscsi
    bs-type rbd
    backing-store iscsipool/image1  # Format is <iscsi-pool>/<iscsi-rbd-image>
    initiator-address 10.10.2.49    #client address allowed to map the address
</target>
```

5、重启或者重载tgt服务
```
#service tgt reload
or
#service tgt restart
```

6、关闭rbd cache，否则可能导致数据丢失或者损坏
```
vim /etc/ceph/ceph.conf
[client]
rbd_cache = false
```

二、Client side
---

1、安装open-scsi
```
#apt-get install open-iscsi
```

2、启动open-scsi服务
```
# service open-iscsi restart
 * Unmounting iscsi-backed filesystems                                                                                                    [ OK ] 
 * Disconnecting iSCSI targets                                                                                                            [ OK ] 
 * Stopping iSCSI initiator service                                                                                                       [ OK ] 
 * Starting iSCSI initiator service iscsid                                                                                                [ OK ] 
 * Setting up iSCSI targets                                                                                                                      
iscsiadm: No records found
                                                                                                                                          [ OK ]
 * Mounting network filesystems 
```

3、发现目标设备
```
# iscsiadm -m discovery -t st -p 10.10.2.50
10.10.2.50:3260,1 iqn.2014-04.rbdstore.example.com:iscsi
```

4、挂载目标设备
```
#  iscsiadm -m node --login
Logging in to [iface: default, target: iqn.2014-04.rbdstore.example.com:iscsi, portal: 10.10.2.50,3260] (multiple)
Login to [iface: default, target: iqn.2014-04.rbdstore.example.com:iscsi, portal: 10.10.2.50,3260] successful.
```

5、确认设备已经挂载（示例中sda就是iscsdi设备）
```
root@cetune1:~# lsblk 
NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                      8:0    0    10G  0 disk 
vda                    253:0    0    24G  0 disk 
?..vda1                253:1    0   190M  0 part /boot
?..vda2                253:2    0     1K  0 part 
?..vda5                253:5    0  23.8G  0 part 
?..linux-swap (dm-0)   252:0    0   3.8G  0 lvm  [SWAP]
?..linux-root (dm-1)   252:1    0    20G  0 lvm  /
```
