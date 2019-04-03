官方中文文档http://docs.ceph.org.cn/architecture/
=====================================
书https://frank6866.gitbooks.io/ceph/content/  
=========
https://www.cnblogs.com/luxiaodai/p/10006036.html

1、创建  pool 
--------------
```
# ceph osd pool create rbd-pool 128
# ceph osd pool create cephfs-pool 128
# ceph osd pool create rgw-pool 128
```  

2、设置pool配额  
---------------
支持 object 个数配额以及容量大小配额。  
设置允许最大 object 数量为 100：  
```
# ceph osd pool set-quota rbd-pool max_objects 100
# ceph osd pool set-quota cephfs-pool max_objects 100
# ceph osd pool set-quota rgw-pool max_objects 100
```  

3、设置容量 限制为 9G 
--------------------
```
# ceph osd pool set-quota rbd-pool max_bytes $((9 * 1024 * 1024 * 1024))
# ceph osd pool set-quota cephfs-pool max_bytes $((9 * 1024 * 1024 * 1024))
# ceph osd pool set-quota rgw-pool max_bytes $((9 * 1024 * 1024 * 1024))
```  

4、重命名 pool  
-------------
``` # ceph osd poolrename rbd-pool rbd-pool-new ```  

5、删除 pool  
-----------  
删除一个 pool 会同时清空 pool 的所有数据，因此非常危险。(和 rm -rf /类似)。因此删除 pool 时 ceph 要求必须输入两次 pool 名称，同时加上--yes-i-really-really-mean-it 选项。  
``` # ceph osd pool delete rbd-pool rbd-pool --yes-i-really-really-mean-it ```  


二、获取参数
===========
1、通过 get 操作能够获取 pool 的配置值,比如获取当前 pg_num  
``` # ceph osd pool get rbd-pool pg_num ```  

2、获取当前副本数量  
``` # ceph osd pool get rbd-pool size ```  

3、查看pool详细信息  
``` # ceph osd dump | grep pool ```  

4、查询参数的命令  
``` # ceph --show-config | grep mon_pg_warn_max_per_osd ```  



三、Cephfs
=======
1、查看服务  
``` # systemctl status ceph-mds@node01 ```  

2、创建mds   
需要切换到建立的集群目录下执行  
``` # ceph-deploy --overwrite-conf mds create node01 node02 ```  

3、创建cephfs的pool  
```
# ceph osd pool create cephfs_metadata 128
# ceph osd pool create cephfs_data 256
```

4、使用 cephfs 的 pool 创建新的文件系统  
``` # ceph fs new cephfs cephfs_metadata cephfs_data ```  

5、在其他主机上建立目录，测试挂载ceph的文件系统  
```
# mkdir /mnt/nas
# cat /etc/ceph/ceph.client.admin.keyring
  [client.admin]
           key = AQCTuRNa40dBIBAAtJWoHqF1R2pw73ERBfs++w==
# mount -t ceph zjs05:6789,zjs06:6789,zjs07:6789:/ /mnt/nas -o name=admin,secret=AQCTuRNa40dBIBAAtJWoHqF1R2pw73ERBfs++w==
```  



四、Rgw
======
1、查看服务  
``` # systemctl status ceph-radosgw@node01 ```  

如果不是清楚的话  
```
# ls /lib/systemd/system -l | grep radosgw
# ls /lib/systemd/system -l | grep ceph-mds
```  

2、开启服务  
``` systemctl restart ceph-radosgw@node01 ```  

五、错误参考
==========
Osd down 情况  
1、使用命令 ceph osd tree 查看发现问题  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/ceph1.png)  
2、需要重新启动下osd.0  
``` # ceph-deploy osd activate ceph01:/dev/sdb1 ```  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/ceph2.png)  


查看权限  
``` # ceph auth list ```  
