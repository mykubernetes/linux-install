
Cassandra 数据库安装部署
===

1、添加yum 源
```
cat >/etc/yum.repos.d/cassandra.repo <<-EOF
[cassandra] 
name=Apache Cassandra 
baseurl=https://www.apache.org/dist/cassandra/redhat/311x/ 
gpgcheck=1 
repo_gpgcheck=1 
gpgkey=https://www.apache.org/dist/cassandra/KEYS
EOF
```

2、安装cassandra
```
yum install cassandra -y
```

3、配置cassandra
```
# cd /etc/cassandra/conf

cluster_name: 'pte-test'
num_tokens: 256
seed_provider:
  - class_name: org.apache.cassandra.locator.SimpleSeedProvider
    parameters:
    - seeds: "172.16.2.693"
#listen_address: 172.16.2.693             #由于镜像启动不确定ip地址是什么，因此使用网卡

listen_interface: eth0
#rpc_address: 172.16.2.693                #由于镜像启动不确定ip地址是什么，因此使用网卡

rpc_interface: eth0
endpoint_snitch: SimpleSnitch

data_file_directories:
    - /data/cassandra/data                    #由于添加了ssd硬盘，因此指定一个数据目录
```

4、启动cassandra
```
# systemctl daemon-reload
# service cassandra start
# chkconfig cassandra on
```

启动检查
```
# nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
-- Address Load Tokens Owns (effective) Host ID Rack
UN 172.16.2.131 88.87 KiB 256 48.1% a7311478-5278-4385-be4c-1313f7edf29d rack1
UN 172.16.2.116 109.47 KiB 256 54.1% 29a907a0-f782-4d7e-916c-760d7017617e rack1
UN 172.16.2.228 114.49 KiB 256 50.5% a8a8d7a6-1580-4c2f-9cd8-916d4600e8ff rack1
UN 172.16.2.69 108.62 KiB 256 47.3% 25e080a9-94fc-49a3-a6a2-26fe7c62a309 rack1
```
