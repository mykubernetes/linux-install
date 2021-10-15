# 一、RBD的导入导出介绍
Ceph存储可以利用快照做数据恢复，但是快照依赖于底层的存储系统没有被破坏

可以利用rbd的导入导出功能将快照导出备份

RBD导出功能可以基于快照实现增量导出

# 二、RBD导出操作

## 2.1 查看创建的快照
```
## rbd snap ls testimg-copy --id rbd
SNAPID NAME          SIZE TIMESTAMP                
    12 for-clone2 2048 MB Sun Mar 17 22:55:07 2019
```

## 2.2 创建快照 
```
# df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/vda1      xfs        40G  1.7G   39G   5% /
devtmpfs       devtmpfs  893M     0  893M   0% /dev
tmpfs          tmpfs     920M     0  920M   0% /dev/shm
tmpfs          tmpfs     920M   17M  904M   2% /run
tmpfs          tmpfs     920M     0  920M   0% /sys/fs/cgroup
/dev/rbd0      xfs       2.0G   33M  2.0G   2% /mnt/ceph
/dev/rbd1      xfs       2.0G   33M  2.0G   2% /mnt/ceph2

# rbd showmapped
id pool image        snap device    
0  rbd  testimg-copy -    /dev/rbd0 
1  rbd  cephrbd1     -    /dev/rbd1 

# cd /mnt/ceph
# ll
-rw-r--r-- 1 root root 17 Mar 17 21:21 111
-rw-r--r-- 1 root root  0 Mar 17 22:13 222
-rw-r--r-- 1 root root  4 Mar 17 22:13 test
-rw-r--r-- 1 root root  4 Mar 17 22:14 test1

# echo 'pretty girl'  >> aaa.txt

# rbd snap create testimg-copy@v1 --id rbd

# rbd snap ls testimg-copy --id rbd
SNAPID NAME          SIZE TIMESTAMP                
    12 for-clone2 2048 MB Sun Mar 17 22:55:07 2019 
    15 v1         2048 MB Tue Mar 19 16:22:13 2019 
```

## 2.3 写数据再次创建快照
```
# echo 'handsome boy' >>boy
# ls
111  222  aaa.txt  boy  test  test1

# rbd snap create testimg-copy@v2 --id rbd
# rbd snap ls testimg-copy --id rbd
SNAPID NAME          SIZE TIMESTAMP                
    12 for-clone2 2048 MB Sun Mar 17 22:55:07 2019 
    15 v1         2048 MB Tue Mar 19 16:22:13 2019 
    16 v2         2048 MB Tue Mar 19 16:27:30 2019 
```

## 2.4 快照导出操作
```
# rbd export-diff  testimg-copy@for-clone2 testimg-copy-for-clone2      #导出for-clone2的数据
Exporting image: 100% complete...done.

# rbd export-diff testimg-copy@v2  --from-snap  for-clone2  testimg-copy-for-clone2-v2   #导出for-clone2到v2时间点的差异数据
Exporting image: 100% complete...done.

# ll
-rw-r--r--  1 root root 2765143 Mar 19 16:35 testimg-copy-for-clone2
-rw-r--r--  1 root root 2332289 Mar 19 16:38 testimg-copy-for-clone2-v2

# rbd export testimg-copy testimg-copy-full                       #导出创建image到当前时间点的差异数据
Exporting image: 100% complete...done.

# ll-rw-r--r--. 1 root root       1702 Mar  1  2018 rabbitmq-signing-key-public.asc
-rw-r--r--  1 root root    2765143 Mar 19 16:35 testimg-copy-for-clone2
-rw-r--r--  1 root root    2332289 Mar 19 16:38 testimg-copy-for-clone2-v2
-rw-r--r--  1 root root 2147483648 Mar 19 16:40 testimg-copy-full
```

## 2.5 删除所有快照
```
# cd
# umount /mnt/ceph
# rbd unmap  /dev/rbd0

# rbd snap unprotect testimg-copy@for-clone2
2019-03-19 16:48:46.270361 7fbafacc2700 -1 librbd::SnapshotUnprotectRequest: cannot unprotect: at least 1 child(ren) [fbba3d1b58ba] in pool 'rbd'    #有一个子镜像没有合并
2019-03-19 16:48:46.271135 7fbafacc2700 -1 librbd::SnapshotUnprotectRequest: encountered error: (16) Device or resource busy
2019-03-19 16:48:46.271166 7fbafacc2700 -1 librbd::SnapshotUnprotectRequest: 0x5601e4e6c520 should_complete_error: ret_val=-16
rbd: unprotecting snap failed: (16) Device or resource busy

# rbd children testimg-copy@for-clone2   #查看子镜像
rbd/test-clone3

# rbd flatten rbd/test-clone3            #合并子镜像
Image flatten: 100% complete...done.

# rbd snap unprotect testimg-copy@for-clone2   #取消保护

#  rbd snap purge testimg-copy                 #删除所有快照
Removing all snapshots: 100% complete...done.
# rbd  snap  ls testimg-copy --id rbd
```

# 三  导入操作

## 3.1 导入所有
```
#  rbd rm testimg-copy     #删除镜像
Removing image: 100% complete...done.

#  rbd ls
test-clone
test-clone2
test-clone3
testimg

# rbd create  testbacknew  --size 1    #随便创建一个image，名称大小都不限制（恢复时会覆盖大小信息）
# rbd ls
test-clone
test-clone2
test-clone3
testbacknew
testimg

# rbd import testimg-copy-full testbacknew     #把所有数据恢复到这个镜像，报错已经存在这个镜像，对于full，不适用
rbd: image creation failed
Importing image: 0% complete...failed.
rbd: import failed: (17) File exists
2019-03-19 16:59:56.843724 7fc50f783d40 -1 librbd: rbd image testbacknew already exists

# rbd import testimg-copy-full testbacknew2     #正确恢复
Importing image: 100% complete...done.

# rbd ls
test-clone
test-clone2
test-clone3
testbacknew
testbacknew2
testimg
```

## 3.2 客户端验证
```
# rbd map testbacknew2 --id rbd                #客户端进行挂载映射，映射失败，feature导致
rbd: sysfs write failed
RBD image feature set mismatch. Try disabling features unsupported by the kernel with "rbd feature disable".
In some cases useful info is found in syslog - try "dmesg | tail".
rbd: map failed: (6) No such device or address
# rbd info testbacknew2  --id rbd
rbd image 'testbacknew2':
    size 2048 MB in 512 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.fc6174b0dc51
    format: 2
    features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
    flags: 
    create_timestamp: Tue Mar 19 17:00:10 2019


# rbd feature disable testbacknew2 exclusive-lock, object-map, fast-diff, deep-flatten --id rbd     #禁掉报错的feature
# rbd map testbacknew2 --id rbd     #映射成功
/dev/rbd0

# mount /dev/rbd0  /mnt/ceph        #挂载
# cd /mnt/ceph                      #检查数据已经恢复

# ls
111  222  aaa.txt  boy  test  test1
```

## 3.3 验证导入到for-clone2的数据
```
# cd 
# umount /mnt/ceph
# rbd unmap /dev/rbd0

#  rbd import-diff  testimg-copy-for-clone2 testbacknew
Importing image diff: 100% complete...done.
# rbd feature disable testbacknew exclusive-lock, object-map, fast-diff, deep-flatten --id rbd

# rbd info testbacknew
rbd image 'testbacknew':
    size 2048 MB in 512 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.fc4b74b0dc51
    format: 2
    features: layering
    flags: 
    create_timestamp: Tue Mar 19 16:57:39 2019

# rbd map testbacknew --id rbd
/dev/rbd0
# mount /dev/rbd0  /mnt/ceph
# cd /mnt/ceph

# ls
111  222  test  test1
```

## 3.4 验证导入至快照v2的数据
```
# cd 
#umount /mnt/ceph
#rbd unmap /dev/rbd0
#rbd import-diff testimg-copy-for-clone2-v2 testbacknew
#rbd import-diff testimg-copy-for-clone2-v2 testbacknew^C
#rbd map testbacknew --id rbd
/dev/rbd0
#mount /dev/rbd0  /mnt/ceph
#cd /mnt/ceph
#ls
111  222  aaa.txt  boy  test  test1
```
