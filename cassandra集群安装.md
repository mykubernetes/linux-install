
一、安装java 8
```
[root@ca ~]# java -version
java version "1.8.0_111"
Java(TM) SE Runtime Environment (build 1.8.0_111-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.111-b14, mixed mode)
```

二、安装python 2
```
[root@ca ~]# python -V
Python 2.7.5
```

三、在/etc/hosts里面添加集群服务器信息
```
192.168.1.74 node01
192.168.1.75 node02
192.168.1.76 node03
```

四、进行linux 系统内核 文件连接数的修改
```
vi /etc/sysctl.conf

vm.zone_reclaim_mode=0
vm.max_map_count = 262144
vm.swappiness = 1

sysctl -p

vi /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
```

五、创建cassandra用户名和数据存放目录
```
useradd cassandra
mkdir /opt/data1
mkdir /opt/data2
chmod 777 -R /opt/data1
chmod 777 -R /opt/data2
```

六、下载客户端
```
cd /opt
wget http://mirrors.hust.edu.cn/apache/cassandra/3.11.3/apache-cassandra-3.11.3-bin.tar.gz
tar xvf apache-cassandra-3.11.3-bin.tar.gz -C /opt
mv /opt/apache-cassandra-3.11.3    /opt/cassandra
chown -R cassandra.cassandra /opt/cassandra
```

七、却换到cassandra用户下
```
su - cassandra
mkdir /opt/data1/commitlog
mkdir /opt/data1/data1file
mkdir /opt/data2/data2file
mkdir /opt/data2/saved_caches

cd /opt/cassandra/conf/
修改 cassandra.yaml 配置文件，配置第一台为seeds。
第一台配置：
cluster_name: 'prod Cluster'
data_file_directories:
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog
saved_caches_directory: /opt/data2/saved_caches
- seeds: "192.168.1.74"
listen_address: 192.168.1.74
start_rpc: true
rpc_address: 192.168.1.74


第二台配置：
cluster_name: 'prod Cluster'
data_file_directories:
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog
saved_caches_directory: /opt/data2/saved_caches
- seeds: "192.168.1.74"
listen_address: 192.168.1.75
start_rpc: true
rpc_address: 192.168.1.75

第三台配置：
cluster_name: 'prod Cluster'
data_file_directories:
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog
saved_caches_directory: /opt/data2/saved_caches
- seeds: "192.168.1.74"
listen_address: 192.168.1.76
start_rpc: true
rpc_address: 192.168.1.76
```
- cluster_name: 'MyCluster' 集群的名字，同一个集群的名字要相同
- authenticator: PasswordAuthenticator 生产环境都要用户名密码认证，默认的用户名/密码是cassandra/cassandra
- seeds: 192.168.0.101 种子节点的IP
- broadcast_address: 192.168.0.101 节点的IP
- broadcast_rpc_address: 192.168.0.101 节点的IP
- listen_address: 200.1.1.11 节点容器的IP。
- auto_snapshot: false 尽管官方建议是true，但实际使用时，太消耗磁盘，所以建议改为false
- endpoint_snitch: GossipingPropertyFileSnitch 生产环境标配

八、启动
```
然后重启启动，先启动seed
/opt/cassandra/bin/cassandra

启动完成后，可使用
/opt/cassandra/bin/nodetool status
查看集群状态
[cassandra@harbor conf]$ /opt/cassandra/bin/nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address       Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.1.74  189.2 KiB  256          68.9%             98436d32-5d5d-4e5e-afe2-84550e56daa9  rack1
UN  192.168.1.75  161.43 KiB  256          64.7%             2f52f14c-acbb-4241-9eff-6ed13b2827e5  rack1
UN  192.168.1.76  120.67 KiB  256          66.4%             450b02db-90a1-4b76-831a-9b0b9aa42c27  rack1
```

