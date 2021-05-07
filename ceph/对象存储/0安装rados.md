1、安装ceph-radosgw  
``` # yum -y install ceph-radosgw ```  
2、部署  
``` # ceph-deploy rgw create node01 node02 node03     # 指定要部署radsgw到的哪些服务器 ```  
3、检查服务是否开启  
``` netstat -tnlupn |grep 7480 ```  
浏览器打开： http://192.168.20.176:7480  

4、可配置80端口（不用修改）  
```
# vim ceph.conf       # mycluster/ceph.conf
追加
[client.rgw.node01]
rgw_frontends = "civetweb port=80"

[client.rgw.node02]
rgw_frontends = "civetweb port=80"

[client.rgw.node03]
rgw_frontends = "civetweb port=80"

# ceph-deploy --overwrite-conf config push node01 node02 node03
# sudo systemctl restart ceph-radosgw@rgw.node01.service
# sudo systemctl restart ceph-radosgw@rgw.node02.service
# sudo systemctl restart ceph-radosgw@rgw.node03.service
```

5、创建池  
```
# cat ./pool
.rgw
.rgw.root
.rgw.control
.rgw.gc
.rgw.buckets
.rgw.buckets.index
.rgw.buckets.extra
.log
.intent-log
.usage
.users
.users.email
.users.swift
.users.uid



# cat ./create_pool.sh
#!/bin/bash

PG_NUM=30
PGP_NUM=30
SIZE=3

for i in `cat ./pool`
        do
        ceph osd pool create $i $PG_NUM
        ceph osd pool set $i size $SIZE
        done

for i in `cat ./pool`
        do
        ceph osd pool set $i pgp_num $PGP_NUM
        done





# chmod +x create_pool.sh
# ./create_pool.sh
```  
6、测试是否能够访问ceph 集群  
```
sudo cp /var/lib/ceph/radosgw/ceph-rgw.node01/keyring ./
ceph -s -k keyring --name client.rgw.node01
```

7、删除池（如果操作错误，需要删除时，才执行这步，否则请略过）  
```
# vi /etc/ceph/ceph.conf
...
[mon]
mon_allow_pool_delete = true
...

# systemctl restart ceph-mon.target

# ceph osd pool delete poolname poolname --yes-i-really-really-mean-it
```  

