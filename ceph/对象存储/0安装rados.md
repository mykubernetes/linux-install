1、安装ceph-radosgw  
```
# yum -y install ceph-radosgw
```

2、部署  
```
# ceph-deploy rgw create node01 node02    # 指定要部署radsgw到的哪些服务器
```

```
# ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 2h)
    mgr: ceph-mgr2(active, since 20h), standbys: ceph-mgr1
    mds: 2/2 daemons up, 2 standby
    osd: 12 osds: 12 up (since 2h), 12 in (since 2d)
    rgw: 2 daemons active (2 hosts, 1 zones) 
 
  data:
    volumes: 1/1 healthy
    pools:   10 pools, 329 pgs
    objects: 372 objects, 314 MiB
    usage:   1.8 GiB used, 238 GiB / 240 GiB avail
    pgs:     329 active+clean
```

3、检查服务是否开启
```
# ps -ef | grep radosgw
ceph        608      1  0 06:43 ?        00:00:27 /usr/bin/radosgw -f --cluster ceph --name client.rgw.ceph-mgr1 --setuser ceph --setgroup ceph

# netstat -tnlupn |grep 7480
```

4、访问radosgw服务
```
# curl http://10.0.0.104:7480
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>

# curl http://10.0.0.105:7480
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>
```
- 浏览器访问： http://192.168.20.176:7480  

4、自定义端口

- radosgw 服务器（node01、node02）的配置文件要和deploy服务器的一致，可以ceph-deploy 服务器修改然后统一推送，或者单独修改每个 radosgw 服务器的配置为同一配置  
```
# cat ceph.conf 
[global]
fsid = 635d9577-7341-4085-90ff-cb584029a1ea
public_network = 10.0.0.0/24
cluster_network = 192.168.133.0/24
mon_initial_members = ceph-mon1
mon_host = 10.0.0.101
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 2 
mon clock drift warn backoff = 30 

[mds.ceph-mgr2] 
#mds_standby_for_fscid = mycephfs 
mds_standby_for_name = ceph-mgr1 
mds_standby_replay = true 

[mds.ceph-mon3] 
mds_standby_for_name = ceph-mon2 
mds_standby_replay = true

[client.rgw.ceph-mgr1]
rgw_host = node01 
rgw_frontends = civetweb port=9900         #修改端口号

[client.rgw.ceph-mgr2] 
rgw_host = node02
rgw_frontends = civetweb port=9900

# 将配置文件推送到rgw节点并重启服务
# ceph-deploy --overwrite-conf config push node01 node02
# sudo systemctl restart ceph-radosgw@rgw.node01.service
# sudo systemctl restart ceph-radosgw@rgw.node02.service
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

