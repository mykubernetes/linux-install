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


# 启用 SSL

- 生成签名证书并配置 radosgw 启用 SSL

1、自签名证书
```
#mgr2节点
# mkdir /etc/ceph/certs
# cd /etc/ceph/certs/
# sudo openssl genrsa -out civetweb.key 2048
# sudo openssl req -new -x509 -key civetweb.key -out civetweb.crt -subj "/CN=rgw.magedu.net"
# cat civetweb.key civetweb.crt > civetweb.pem
# ls
civetweb.crt  civetweb.key  civetweb.pem
```

2、SSL配置
```
# mgr节点
# cat /etc/ceph/ceph.conf 
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
rgw_host = ceph-mgr1 
rgw_frontends = civetweb port=9900

[client.rgw.ceph-mgr2] 
rgw_host = ceph-mgr2
rgw_frontends = civetweb port=9900

[client.rgw.ceph-mgr2] 
rgw_host = ceph-mgr2 
rgw_frontends = "civetweb port=9900+9443s ssl_certificate=/etc/ceph/certs/civetweb.pem"          # 添加证书

#重启服务
# systemctl restart ceph-radosgw@rgw.ceph-mgr2.service
```

3、mgr节点验证9443端口
```
# ss -tln
State         Recv-Q       Send-Q           Local Address:Port              Peer Address:Port               
LISTEN        0            128                  127.0.0.1:6010                   0.0.0.0:*                 
LISTEN        0            128                    0.0.0.0:9443                   0.0.0.0:*                 
LISTEN        0            128                    0.0.0.0:9900                   0.0.0.0:*                 
LISTEN        0            128                 10.0.0.105:6800                   0.0.0.0:*                 
LISTEN        0            128                 10.0.0.105:6801                   0.0.0.0:*                 
LISTEN        0            128              127.0.0.53%lo:53                     0.0.0.0:*                 
LISTEN        0            128                    0.0.0.0:22                     0.0.0.0:*                 
LISTEN        0            128                  127.0.0.1:43447                  0.0.0.0:*                 
LISTEN        0            128                      [::1]:6010                      [::]:*                 
LISTEN        0            128                       [::]:22                        [::]:*  
```

4、浏览器验证
https://10.0.0.105:9443

# 优化配置
```
# mgr节点
# 创建日志目录
# sudo mkdir /var/log/radosgw
# sudo chown -R ceph:ceph /var/log/radosgw

# 修改配置
# cat /etc/ceph/ceph.conf 
[client.rgw.ceph-mgr2] 
rgw_host = ceph-mgr2 
rgw_frontends = "civetweb port=9900+9443s ssl_certificate=/etc/ceph/certs/civetweb.pem error_log_file=/var/log/radosgw/civetweb.error.log access_log_file=/var/log/radosgw/civetweb.access.log request_timeout_ms=30000 num_threads=200"

# 重启服务
# sudo systemctl restart ceph-radosgw@rgw.ceph-mgr2.service

# 访问测试
# curl -k https://10.0.0.105:9443
# curl -k https://10.0.0.105:9443

# 验证日志
# tail /var/log/radosgw/civetweb.access.log 
10.0.0.105 - - [31/Aug/2021:14:44:47 +0800] "GET / HTTP/1.1" 200 414 - curl/7.58.0
10.0.0.105 - - [31/Aug/2021:14:44:48 +0800] "GET / HTTP/1.1" 200 414 - curl/7.58.0
10.0.0.105 - - [31/Aug/2021:14:44:50 +0800] "GET / HTTP/1.1" 200 414 - curl/7.58.0

注:mgr1做一样的操作
```

