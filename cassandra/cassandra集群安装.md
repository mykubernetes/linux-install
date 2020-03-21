
一、安装java 8
```
# java -version
java version "1.8.0_111"
Java(TM) SE Runtime Environment (build 1.8.0_111-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.111-b14, mixed mode)
```

二、安装python 2
```
# python -V
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
cluster_name: 'prod Cluster'                       #集群的名字，同一个集群的名字要相同
data_file_directories:                             #数据文件存放路径
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog          #操作日志文件存放路径
saved_caches_directory: /opt/data2/saved_caches    #缓存文件存放路径
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "192.168.1.74"                  #集群种子节点ip,新加入集群的节点从种子节点中同步数据。可配置多个，中间用逗号隔开。
listen_address: 192.168.1.74                       #需要监听的IP或主机名
start_rpc: true
storage_port: 7000                                 #集群中服务器与服务器之间相互通信的端口号
native_transport_port: 9042                        #客户端通信端口
rpc_address: 192.168.1.74                          #用于监听客户端连接的地址


第二台配置：
cluster_name: 'prod Cluster'                       #集群的名字，同一个集群的名字要相同
data_file_directories:                             #数据文件存放路径
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog          #操作日志文件存放路径
saved_caches_directory: /opt/data2/saved_caches    #缓存文件存放路径
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "192.168.1.74"                  #集群种子节点ip,新加入集群的节点从种子节点中同步数据。可配置多个，中间用逗号隔开。
listen_address: 192.168.1.75                       #需要监听的IP或主机名
start_rpc: true
storage_port: 7000                                 #集群中服务器与服务器之间相互通信的端口号
native_transport_port: 9042                        #客户端通信端口
rpc_address: 192.168.1.75                          #用于监听客户端连接的地址


第三台配置：
cluster_name: 'prod Cluster'                       #集群的名字，同一个集群的名字要相同
data_file_directories:                             #数据文件存放路径
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog          #操作日志文件存放路径
saved_caches_directory: /opt/data2/saved_caches    #缓存文件存放路径
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "192.168.1.74"                  #集群种子节点ip,新加入集群的节点从种子节点中同步数据。可配置多个，中间用逗号隔开。
listen_address: 192.168.1.76                       #需要监听的IP或主机名
start_rpc: true
storage_port: 7000                                 #集群中服务器与服务器之间相互通信的端口号
native_transport_port: 9042                        #客户端通信端口
rpc_address: 192.168.1.76                          #用于监听客户端连接的地址
```


八、启动
```
然后重启启动，先启动seed
/opt/cassandra/bin/cassandra

启动完成后，可使用
/opt/cassandra/bin/nodetool status
查看集群状态
# /opt/cassandra/bin/nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address       Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.1.74  189.2 KiB  256          68.9%             98436d32-5d5d-4e5e-afe2-84550e56daa9  rack1
UN  192.168.1.75  161.43 KiB  256          64.7%             2f52f14c-acbb-4241-9eff-6ed13b2827e5  rack1
UN  192.168.1.76  120.67 KiB  256          66.4%             450b02db-90a1-4b76-831a-9b0b9aa42c27  rack1
```

九、开启用户名密码认证
1、编辑配置文件添加认证
```
# vim cassandra.yaml
authenticator: PasswordAuthenticator
```

2、重新启动cassandra并且根据默认用户登录cqlsh，用户名密码都是cassandra
```
# ./cassandra
# ./cqlsh -ucassandra -pcassandra
```

3、修改默认用户，进入cqlsh后
```
1 超级用户可以更改用户的密码或超级用户身份。为了防止禁用所有超级,超级用户不能改变自己的超级用户身份。普通用户只能改变自己的密码。附上用户名在单引号如果它包含非字母数字字符。附上密码在单引号。
2 CREATE USER test WITH PASSWORD '123456' SUPERUSER;  #创建一个超级用户
3 CREATE USER test1 WITH PASSWORD '123456' NOSUPERUSER;  #创建一个普通用户
4 ALTER USER test WITH PASSWORD '654321' ( NOSUPERUSER | SUPERUSER ) #修改用户
5 DROP USER cassandra #删除默认用户
```

4、无密码登录Cqlsh
```
vi ~/.cassandra/cqlshrc  #添加下面内容
[authentication]
username = test
password = 654321
```

