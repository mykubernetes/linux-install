一、Pool配置
=========
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














