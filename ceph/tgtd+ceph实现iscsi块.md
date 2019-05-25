1、准备编译环境  
``` #yum install -y rpm-build gcc ceph librbd1-devel ```  

2获取Tgt
``` # git clone https://github.com/mykubernetes/tgt.git ```  

3、进入目录后编辑
```
# vim Makefile
...
# Export the feature switches so sub-make knows about them
export ISCSI_RDMA
export CEPH_RBD = 1   #修改
export GLFS_BD
export SD_NOTIFY
...
```  
```
# vim scripts/tgtd.spec
%{_mandir}/man5/*
%{_mandir}/man8/*
%{_initrddir}/tgtd
/usr/lib/tgt/backing-store/bs_rbd.so   #添加
/etc/bash_completion.d/tgt
%attr(0600,root,root) %config(noreplace) /etc/tgt/targets.conf
```  

4、编译
``` # make rpm ```  

5、生成安装文件  
``` 
# ls pkg/RPMS/x86_64
scsi-target-utils-1.0.62-v1.0.62.x86_64.rpm
scsi-target-utils-debuginfo-1.0.62-v1.0.62.x86_64.rpm
```  

6、在3个mon节点安装tgt rpm 包  
``` # rpm -ivh pkg/RPMS/x86_64/scsi-target-utils-1.0.62-v1.0.62.x86_64.rpm --force ```  

7、在ceph创建块设备  
``` # rbd create pool1/image1 --size 200 --image-format 2 ```  

8、安装完成后，在每个mon服务器上添加ceph/rbd配置文件  
```
cat /etc/tgt/conf.d/ceph.conf
<target iqn.2018-12.rbd.test.com:iscsi-01>
driver iscsi
bs-type rbd
backing-store pool1/image1
</targe>
```  

9、启动tgt服务  
``` # service tgtd start ```  

10、在客户端服务器上安装iscsi initor 程序  
``` # yum install -y iscsi-initiator-utils ```  

11、扫描iscsi target  
```
# iscsiadm -m discovery -t sendtargets -p 10.89.13.71
10.89.13.71:3260,1 iqn.2018-12.rbd.test.com:iscsi-01
# iscsiadm -m discovery -t sendtargets -p 10.89.13.72
10.89.13.72:3260,1 iqn.2018-12.rbd.test.com:iscsi-01
# iscsiadm -m discovery -t sendtargets -p 10.89.13.73
10.89.13.73:3260,1 iqn.2018-12.rbd.test.com:iscsi-01
```  

12、登录iscsi target  
```
# iscsiadm -m node -T iqn.2018-12.rbd.test.com:iscsi-01 -p 10.89.13.71 --login
# iscsiadm -m node -T iqn.2018-12.rbd.test.com:iscsi-01 -p 10.89.13.72 --login
# iscsiadm -m node -T iqn.2018-12.rbd.test.com:iscsi-01 -p 10.89.13.73 --login
```  

13、发现本地设备  
```
# fdisk -l
```  

14、配置多路径  
```
# yum -y install device-mapper-multipath
# vim /etc/multipath.conf
defaults {
user_friendly_names yes
udev_dir /dev
path_grouping_policy multibus
failback immediate
no_path_retry fail
}
```  
```
# service multipathd start
```  
```
multipath -ll
```  
