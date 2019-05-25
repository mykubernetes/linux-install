rbd常见操作  
1、存储池pool  
1)创建一个存储池  
```
# rados mkpool pool
```  

2)查看创建出的pool
```
# rados lspools
```  

2、RBD image  
1)在pool存储池中创建一个大小1GB的image  
```
# rbd create pool/image1--size 1024 --image-format 2
```  

2)查看创建出的image  
```
# rbd ls pool
```  

3)查看image详细信息  
```
# rbd info pool/image1
```  

ceph集群中一个object对象默认大小为4MB,也可以在创建image时指定object大小  
```
# rbd create pool/image 2 --size 1024 --order 24 --image-format 2
```  
注  
- --order 24表示指定object大小为2^24 bytes,即16MB.若不指定--order参数，则--order默认值为22，即4MB  

4)查看image2的order和object大小  
```
# rbd info pool/image2
```  

5)删除image  
```
# rbd rm pool/image2
```  

3、快照  
1)为image创建一个快照,快照名为image1_snap  
```
# rbd snap create pool/image1@image1_snap
```  

2)查看上面创建的快照  
```
# rbd snap list pool/image1
或者长格式形式查看
# rbd ls pool -l
```  

3)查看快照更详细信息  
```
#  rbd info pool/image1_snap
```  

4、克隆  
在克隆前，快照必须处于被保护状态，才能被克隆  
```
# rbd snap protect pool/image1@image1_snap
# rbd info pool/image1@image1_snap
protected: True状态
```  

克隆快照到另一个RBD pool 并成为一个新的image  
```
# rbd clone pool/image1@image1_snap rbd/image2
```
新的image2依赖父image  
```
# rbd ls rbd -l
```  

5、依赖Children/Flatten  
1)查看快照的"子"(children)  
```
# rbd children pool/image1@image1_snap
rbd/image2
```  

2)把分层的RBD image 变为扁平的没有层级的image  
```
# rbd flatten rbd/image2
```  

3)再次查看rbd/image2已经没有父(parent)image存在了，即断开了依赖关系  
```
# rbd ls rbd -l
```  

6、RBD导入导出  
导出RBD image  
```
# rbd export pool/image1 /tmp/image_export
```  

导入RBD image  
```
# rbd import /tmp/image_export pool/image3 --image-fromat 2
# rbd ls pool
```  
