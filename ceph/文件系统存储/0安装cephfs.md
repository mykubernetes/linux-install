# cephfs

## 服务器端部署

1、部署 cephfs  
```
# ceph-deploy mds create node01
```
注意：查看输出，应该能看到执行了哪些命令，以及生成的keyring  

2、使用 CephFS 之前需要事先于集群中创建一个文件系统，并为其分别指定元数据和数据相关的存储池
```
# ceph osd pool create cephfs-metadata 32 32
# ceph osd pool create cephfs-data 64 64
# ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 7m)
    mgr: ceph-mgr2(active, since 6m), standbys: ceph-mgr1
    mds: 1/1 daemons up
    osd: 12 osds: 12 up (since 6m), 12 in (since 39h)
    rgw: 1 daemon active (1 hosts, 1 zones)
 
  data:
    volumes: 1/1 healthy
    pools:   10 pools, 329 pgs
    objects: 328 objects, 213 MiB
    usage:   894 MiB used, 239 GiB / 240 GiB avail
    pgs:     329 active+clean
```

3、创建 cephFS 并验证
```
# ceph fs new mycephfs cephfs-metadata cephfs-data
# ceph fs ls
name: mycephfs, metadata pool: cephfs-metadata, data pools: [cephfs-data ]

# ceph fs status mycephfs
mycephfs - 0 clients
========
RANK  STATE      MDS        ACTIVITY     DNS    INOS   DIRS   CAPS  
 0    active  ceph-mgr1  Reqs:    0 /s    12     15     12      0   
      POOL         TYPE     USED  AVAIL  
cephfs-metadata  metadata   247k  75.5G  
  cephfs-data      data     362M  75.5G  
MDS version: ceph version 16.2.5 (0883bdea7337b95e4b611c768c0279868462204a) pacific (stable)
```

4、验证 cepfFS 服务状态 
```
# ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active}

# ceph osd pool ls
# ceph fs ls
```  

5、创建用户并赋予权限  
```
ceph auth get-or-create client.cephfs mon 'allow r' mds 'allow r, allow rw path=/' osd 'allow rw pool=cephfs_data' -o ceph.client.cephfs.keyring
拷贝到客户端
scp ceph.client.cephfs.keyring node04:/etc/ceph/
```  

客户端挂载
--------
在linux中挂载有两种方式Kernel Driver和Fuse  
1、通过内核驱动挂载Ceph FS  
mount挂载ceph选项参考  
http://docs.ceph.org.cn/man/8/mount.ceph/#mount-ceph-ceph  
1)创建挂载目录  
``` # mkdir /mnt/cephfs ```  
2)挂载  

手动输入key挂载  
```
# ceph auth get-key client.cephfs        #在ceph fs服务器上执行，获取key
AQCpdblcDYdhGBAATHHTR0Fd7cwZ0hFmz1VjtQ==
# mount -t ceph node01:6789:/ /mnt/cephfs -o name=cephfs,secret=AQCpdblcDYdhGBAATHHTR0Fd7cwZ0hFmz1VjtQ==      # -o name=cephfs的name为创建key的时候client.cephfs的cephfs名


$ umount /mnt/cephfs //使用多个mon挂载
$ mount -t ceph node01,node02,node03:/ /mnt/cephfs -o name=cephfs,secret=AQCpdblcDYdhGBAATHHTR0Fd7cwZ0hFmz1VjtQ==
```

通过指定key文件挂载  
```
# echo AQCpdblcDYdhGBAATHHTR0Fd7cwZ0hFmz1VjtQ== > /etc/ceph/cephfskey        #把 key保存起来
# mount -t ceph node02:6789:/ /mnt/cephfs -o name=cephfs,secretfile=/etc/ceph/cephfskey   #name为认证用户名
```  

启动挂载  
```
# echo "node02:6789:/ /mnt/cephfs ceph name=cephfs,secretfile=/etc/ceph/cephfskey,_netdev,noatime 0 0" >> /etc/fstab
```  

3)、校验  
```
umount /mnt/cephfs
mount /mnt/cephfs
dd if=/dev/zero of=/mnt/cephfs/file1 bs=1M count=1024
```  


通过FUSE客户端挂载  
---
1)安装软件包  
```
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



# rpm -qa |grep -i ceph-fuse 
# yum -y install ceph-fuse
``` 

2)从服务器把 key文件拷贝到客户端  
``` scp ceph.client.cephfs.keyring root@c720153:/etc/ceph/ ```  

3)挂载  
命令挂载  
```
# ceph-fuse --keyring /etc/ceph/ceph.client.cephfs.keyring --name client.cephfs -m node02:6789 /mnt/cephfs
# df -h /mnt/cephfs/
Filesystem      Size  Used Avail Use% Mounted on
ceph-fuse       6.5G     0  6.5G   0% /mnt/cephfs
```  

使用配置文件命令挂载挂载  
```
# vi /etc/ceph/ceph.conf
[global]
mon_host = node01,node02,node03

# vi /etc/fstab
...
none /mnt/cephfs fuse.ceph ceph.id=cephfs,_netdev,defaults 0 0
```  
注：因为 keyring文件包含了用户名，前提是，必须要有ceph.conf文件，指明 mon地址。
