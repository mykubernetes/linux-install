cephfs
======
1、部署 cephfs  
``` # ceph-deploy mds create node02 ```  
注意：查看输出，应该能看到执行了哪些命令，以及生成的keyring  
```
# ceph osd pool create cephfs_data 128
# ceph osd pool create cephfs_metadata 64
# ceph fs new cephfs cephfs_metadata cephfs_data
# ceph mds stat
# ceph osd pool ls
# ceph fs ls
```  
2、创建用户(可选，因为部署时，已经生成)
```
ceph auth get-or-create client.cephfs mon 'allow r' mds 'allow r, allow rw path=/' osd 'allow rw pool=cephfs_data' -o ceph.client.cephfs.keyring
拷贝到客户端
scp ceph.client.cephfs.keyring node04:/etc/ceph/
```  
