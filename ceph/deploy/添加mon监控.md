添加mon监控
===========
1、修改配置文件
```
vim /etc/ceph/ceph.conf
[global]
fsid = ee409f5a-96c8-4d82-9672-26a17c82af17
mon_initial_members = node01, node02                #添加主机名
mon_host = 192.168.101.69,192.168.101.70            #添加IP地址
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

public network = 192.168.101.0/24
cluster network = 192.168.101.0/24
```  

2、推送配置到新添加节点  
```
ceph-deploy --overwrite-conf config push node02
```  

3、使用ceph-deploy工具添加mon新节点
```
ceph-deploy mon create node02 
```  
