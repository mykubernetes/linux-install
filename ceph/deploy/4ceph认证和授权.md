一、认证
---
1、关闭认证
```
# vim /etc/ceph/ceph.conf
auth cluster required = none
auth service required = none
auth client required = none
```  

2、开启认证
```
# vim /etc/ceph/ceph.conf
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
```  

二、授权  
---

用户通过身份验证后，即可获得不同类型的访问权限，活动或角色的授权  
语法：{daemon-type} 'allow {capability}' [{daemon-type} 'allow {capability}']  

1、mon
包括r，w，x，参数，并允许 profiles（配置） {cap}。例如：  
```
mon 'allow rwx' or mon 'allow profile osd'
```  

2、osd  
包括r，w，x，class-read，class-write，和 profile OSD。例如：  
```
osd 'allow rwx' or osd 'allow class-read, allow rwx pool=rbd'
```  

3、MDS  
仅支持allow 例如  
```
mds 'allow'
```  

参数的具体解释：  
- allow： 仅适合 MDS
- r： 读取访问权限，这是监视器读取CRUSH映射所必需的。
- w： 对对象的写访问权限。
- x： 这使用户能够调用类方法，包括读取和写入，以及auth在监视器上执行操作的权限。
- class-read： 这是x的一个子集，允许用户调用类读取方法。
- class-write： 这是x允许用户调用类写方法的子集。
- *： 这为用户提供特定池的完全权限（r，w和x）以及执行管理命令。
- profile（配置） osd： 这允许用户以OSD的形式连接到其他OSD或监视器。用于OSD心跳流量和状态报告。
- profile mds： 这允许用户作为MDS连接到其他MDS。
- profile bootstrap-osd： 这允许用户引导OSD。例如，ceph-deploy和ceph-disk工具使用的客户端。bootstrap-osduser，有权添加密钥和引导OSD。
- profile bootstrap-mds： 这允许用户引导元数据服务器。例如，该ceph-deploy工具使用
- client.bootstrap-mds用户添加密钥并引导元数据服务器。

1、列出集群中的用户  
```
# ceph auth list
```

2、查看特定用户  
```
# ceph auth get client.admin
```

3、创建用户  
```
# ceph auth get-or-create client.rbd | tee /etc/ceph/ceph.client.rbd.keyring      #ceph集群名.client.rbd用户名.keyring格式保存
```

4、删除用户
```
# ceph auth del client.rbd
```

5、用户添加功能  
```
# ceph auth caps client.rbd mon 'allow r' osd 'allow rwx pool=rbd'
# ceph auth get client.rbd
```  



