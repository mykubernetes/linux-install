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

4、radosgw存储池类型
```
# ceph osd pool ls
device_health_metrics
cephfs-metadata
cephfs-data
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta
default.rgw.buckets.index
default.rgw.buckets.data
default.rgw.buckets.non-ec

# ceph osd pool get default.rgw.buckets.data crush_rule
crush_rule: replicated_rule            # 默认是副本池

# ceph osd pool get default.rgw.buckets.data size
size: 3                                # 默认的副本数

# ceph osd pool get default.rgw.buckets.data pgp_num
pgp_num: 32                            # 默认的pgp数量

# ceph osd pool get default.rgw.buckets.data pg_num
pg_num: 32                             # 默认的pg数量
```
- .rgw.root: 包含realm(领域信息)。比如zone和zonegroup。
- default.rgw.log: 存储日志信息，用于记录各种log信息。
- default.rgw.control: 系统控制池，在有数据更新时，通知其他RGW更新缓存。
- default.rgw.meta: 元数据存储池，通过不同的名称空间分别存储不同的rados对象，这些名称空间包括用户UID及其bucket映射信息的名称空间users.uid、用户的密钥名称空间users.keys、用户的email名称空间users.email、用户的subuser的名称空间users.swift,以及bucket的名称空间root等。
- default.rgw.buckets.index: 存放bucket到object的索引信息
- default.rgw.buckets.data: 存放对象的数据
- default.rgw.buckets.non-ec: 数据的额外信息存储池


5、访问radosgw服务
```
# curl http://10.0.0.104:7480
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>

# curl http://10.0.0.105:7480
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>
```
- 浏览器访问： http://192.168.20.176:7480  

6、自定义端口

https://docs.ceph.com/en/latest/radosgw/frontends/

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

# 测试数据的读写

1、创建RGW账户
```
# radosgw-admin user create --uid="user1" --display-name="test  user"
{
    "user_id": "user1",
    "display_name": "test  user",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "user1",
            "access_key": "6LO8046SQ3DVGVKS84LX",
            "secret_key": "iiVFHXC6qc4iTnKVcKDVJaOLeIpl39EbQ2OwueRV"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

2、安装s3cmd客户端
```
# yum install s3cmd
```

3、配置客户端执行环境

- s3cmd客户端添加域名解析
```
# cat /etc/hosts
127.0.0.1    localhost
127.0.1.1    ubuntu

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
10.0.0.100 ceph-deploy.example.local ceph-deploy 
10.0.0.101 ceph-mon1.example.local ceph-mon1 
10.0.0.102 ceph-mon2.example.local ceph-mon2 
10.0.0.103 ceph-mon3.example.local ceph-mon3 
10.0.0.104 ceph-mgr1.example.local ceph-mgr1 
10.0.0.105 ceph-mgr2.example.local ceph-mgr2 
10.0.0.106 ceph-node1.example.local ceph-node1 
10.0.0.107 ceph-node2.example.local ceph-node2 
10.0.0.108 ceph-node3.example.local ceph-node3 
10.0.0.109 ceph-node4.example.local ceph-node4
10.0.0.105 rgw.test.net
```

4、进行s3cm3配置
```
# s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key: 6LO8046SQ3DVGVKS84LX                                 #创建用户的时候的access key
Secret Key: iiVFHXC6qc4iTnKVcKDVJaOLeIpl39EbQ2OwueRV             #创建用户的secret key
Default Region [US]:                                             #region选项

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: rgw.test.net:9900                #RGW域名

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: rgw.test.net:9900/%(bucket)           #bucket域名格式

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:                                             #是否需要加密
Path to GPG program [/usr/bin/gpg]:                              #gpg命令路径，用于认证管理

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: No                                     #是否使用https

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't connect to S3 directly
HTTP Proxy server name:                                          #是否使用代理

New settings:                                                    #最终配置
  Access Key: 6LO8046SQ3DVGVKS84LX
  Secret Key: iiVFHXC6qc4iTnKVcKDVJaOLeIpl39EbQ2OwueRV
  Default Region: US
  S3 Endpoint: rgw.test.net:9900
  DNS-style bucket+hostname:port template for accessing a bucket: rgw.test.net:9900/%(bucket)
  Encryption password: 
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name: 
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] Y                   #是否对最终配置进行测试验证
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Not configured. Never mind.

Save settings? [y/N] y                                           #是否保存以上配置
Configuration saved to '/home/test/.s3cfg'                       #配置文件保存路径
```

5、创建bucket验证权限
```
# s3cmd la

# s3cmd mb s3://test
Bucket 's3://test/' created

# s3cmd ls
2021-08-31 08:08  s3://test
```

6、验证上传数据
```
# 上传文件
# s3cmd put /home/test/test.pdf s3://test/pdf/test.pdf                    #不写文件名默认文件名
upload: '/home/test/test.pdf' -> 's3://test/pdf/test.pdf'  [1 of 1]
 4809229 of 4809229   100% in    1s     2.47 MB/s  done

# 查看文件
# s3cmd la
DIR   s3://test/pdf/

# 查看文件信息
# s3cmd ls s3://test/pdf/
2021-08-31 08:25   4809229   s3://test/pdf/test.pdf


# 上传文件，并访问
# echo 11111 >/tmp/demoobject
# s3cmd put --acl-public /tmp/demoobject s3://test/demoobject

# vim /etc/hosts
172.25.250.14  ceph5    ceph5.lab.example.com servere  test.ceph5.lab.example.com

# curl http://test.ceph5.lab.example.com/demoobject
11111
```

7、验证下载文件
```
# sudo s3cmd get s3://test/pdf/test.pdf /opt/
download: 's3://test/pdf/test.pdf' -> '/opt/test.pdf'  [1 of 1]
 4809229 of 4809229   100% in    0s   171.89 MB/s  done

# ll /opt/
total 4708
drwxr-xr-x  2 root root    4096 Aug 31 16:43 ./
drwxr-xr-x 23 root root    4096 Aug 22 15:29 ../
-rw-r--r--  1 root root 4809229 Aug 31 08:25 test.pdf
```

8、删除文件
```
# s3cmd ls s3://test/pdf/test.pdf
2021-08-31 08:25   4809229   s3://test/pdf/test.pdf
test@ceph-deploy:~$ s3cmd rm s3://test/pdf/test.pdf
delete: 's3://test/pdf/test.pdf'

# s3cmd ls s3://test/pdf/test.pdf
```

9、修改信息
```
# radosgw-admin user modify --uid user1 --display-name 'joy Ningrui'  --max_buckets 2000
{
    "user_id": "user1",
    "display_name": "joy Ningrui",
    "email": "",
    "suspended": 0,
    "max_buckets": 2000,
    "subusers": [],
    "keys": [
        {
            "user": "user1",
            "access_key": "6LO8046SQ3DVGVKS84LX",
            "secret_key": "iiVFHXC6qc4iTnKVcKDVJaOLeIpl39EbQ2OwueRV"
        }
    ],
```

10、 禁用user1用户
```
# radosgw-admin user suspend --uid user1
"user_id": "user1",
"email": "",
"suspended": 1,                    #禁用
"max_buckets": 2000,
"auid": 0,
"subusers": [],
```

11、启用
```
# radosgw-admin user enable --uid user1
"user_id": "user1",
"email": "",
"suspended": 0,                    #启用
"max_buckets": 2000,
"auid": 0,
"subusers": [],
```

12、列出用户
```
# radosgw-admin user list
user1
```
 

13、删除用户
```
# radosgw-admin user rm --uid joy
# radosgw-admin user list
```

14、创建用户并添加一个key
```
#  radosgw-admin user create --uid joy --display-name 'Joy Ning'
{
    "user_id": "joy",
    "display_name": "Joy Ning",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}


# radosgw-admin key create --uid joy --display-name 'Joy Ning' --key-type=s3  --gen-access-key --gen-secret
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        },
        {
            "user": "joy",
            "access_key": "HPT1SBAXCXW46ZACKPY0",
            "secret_key": "KPqC0NUOAJEOSiKkZRrCB19iyqPyeyaBY7utCRO8"
        }
    ],
```

15、删除key
```
# radosgw-admin key rm --uid joy --display-name 'Joy Ning' --key-type=s3 --access-key HPT1SBAXCXW46ZACKPY0
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        },
```

16、设置配额

16.1)基于用户的配额
```
# radosgw-admin quota set --quota-scope=user --uid=joy --max-size 1

# radosgw-admin user info --uid joy
"user_quota": {
    "enabled": false,
    "check_on_raw": false,
    "max_size": 1024,
    "max_size_kb": 1,
    "max_objects": -1
},
"temp_url_keys": [],
"type": "rgw"
``` 

开启配额
```
# radosgw-admin quota enable --quota-scope=user --uid joy

# radosgw-admin user info --uid joy
"user_quota": {
    "enabled": true,
    "check_on_raw": false,
    "max_size": 1024,
    "max_size_kb": 1,
    "max_objects": -1
},
"temp_url_keys": [],
"type": "rgw"
```

16.2)基于bucket的配额
```
# radosgw-admin quota set --quota-scope=bucket --uid=joy --max-size 1

# radosgw-admin quota enable --quota-scope=bucket --uid=joy

# radosgw-admin user info --uid joy
"bucket_quota": {
    "enabled": true,
    "check_on_raw": false,
    "max_size": 1024,
    "max_size_kb": 1,
    "max_objects": -1
},
```
- 如果两个都进行配置，则那个先到，使用哪一个



16.3)关闭配额
```
# 可以disable
# radosgw-admin quota disable  --quota-scope=bucket --uid=joy

# 也可以参数设为-1
# radosgw-admin quota set --quota-scope=user --uid joy --max-size -1

# radosgw-admin user info --uid joy
"bucket_quota": {
    "enabled": false,
    "check_on_raw": false,
    "max_size": 1024,
    "max_size_kb": 1,
    "max_objects": -1
},
"user_quota": {
    "enabled": true,
    "check_on_raw": false,
    "max_size": -1,
    "max_size_kb": 1,
    "max_objects": -1
},
```

17、统计数据
```
# 统计所有
# radosgw-admin usage show --uid joy
{
    "entries": [],
    "summary": []
}

# radosgw-admin usage show --uid joy --start-date 2019-03-19 21:00:00 --end-date 2019-03-19 22:00:00
{
    "entries": [],
    "summary": []
}
```

18、查看bucket
```
# radosgw-admin bucket list
"test"


# radosgw-admin bucket stats --bucket=test
{
    "bucket": "test",
    "zonegroup": "e80133e1-a513-44f5-ba90-e25b6c987b26",
    "placement_rule": "default-placement",
    "explicit_placement": {
        "data_pool": "",
        "data_extra_pool": "",
        "index_pool": ""
    },
    "id": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed.4235.1",
    "marker": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed.4235.1",
    "index_type": "Normal",
    "owner": "joy",
    "ver": "0#3",
    "master_ver": "0#0",
    "mtime": "2019-03-19 22:02:50.726716",
    "max_marker": "0#",
    "usage": {
        "rgw.main": {
            "size": 6,
            "size_actual": 4096,
            "size_utilized": 6,
            "size_kb": 1,
            "size_kb_actual": 4,
            "size_kb_utilized": 1,
            "num_objects": 1
        }
    },
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    }
}


# radosgw-admin bucket check --bucket=test
[]
```

19、删除bucket
```
# radosgw-admin bucket rm --bucket=test
```

20、上传，下载
```
# s3cmd put --acl-public  /etc/ceph/ceph.conf  s3://test/ceph
upload: '/etc/ceph/ceph.conf' -> 's3://test/ceph'  [1 of 1]
 589 of 589   100% in    0s    20.96 kB/s  done
Public URL of the object is: http://test.ceph5/ceph


# curl http://test.ceph5.lab.example.com/ceph
# Please do not change this file directly since it is managed by Ansible and will be overwritten

[global]
fsid = 35a91e48-8244-4e96-a7ee-980ab989d20d



mon initial members = ceph2,ceph3,ceph4
mon host = 172.25.250.11,172.25.250.12,172.25.250.13

public network = 172.25.250.0/24
cluster network = 172.25.250.0/24

auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

[osd]
osd mkfs type = xfs
osd mkfs options xfs = -f -i size=2048
osd mount options xfs = noatime,largeio,inode64,swalloc
osd journal size = 5120

[mon]


# s3cmd get s3://test/demoobject ./demoobject
download: 's3://test/demoobject' -> './demoobject' [1 of 1]
6 of 6 100% in 0s 1346.20 B/s done


# cat ./demoobject
11111
```

21、 查看底层数据
```
# ceph osd pool ls
rbd
rbdmirror
.rgw.root
default.rgw.control
default.rgw.meta
default.rgw.log
default.rgw.buckets.index
default.rgw.buckets.data

#  rados -p  default.rgw.buckets.index ls --cluster backup
.dir.1b85c5b1-19d2-48a1-bb45-3ac75895aeed.4235.1

#  rados -p  default.rgw.buckets.data ls
error opening pool default.rgw.buckets.data: (2) No such file or directory

#  rados -p  default.rgw.buckets.data ls --cluster backup
1b85c5b1-19d2-48a1-bb45-3ac75895aeed.4235.1_demoobject
1b85c5b1-19d2-48a1-bb45-3ac75895aeed.4235.1_ceph
```
