异机恢复过程就是将旧库的数据文件拷贝到新环境对应的目录，然后启动数据库即可，但是在恢复之前还需要对新环境做一些必要的修改。这里的环境是单机版，另外此方法也适用于集群模式。

1、获取tokens

如果是集群模式，需要获取每个节点IP的tokens。这里是单机版，获取方法如下：
```
# nodetool ring | grep -w 192.168.120.83 | awk '{print $NF ","}' | xargs
```

2、新节点安装cassandra
```
# yum -y install cassandra cassandra-tools
```

3、同步旧库的配置文件

由于新库是全新安装的，所以直接同步旧库的配置文件，做少量修改即可。
```
# scp 192.168.120.83:/etc/cassandra/default.conf/cassandra.yaml /etc/cassandra/default.conf/
# scp 192.168.120.83:/etc/cassandra/default.conf/cassandra-env.sh /etc/cassandra/default.conf/
# scp 192.168.120.83:/root/.cassandra/cqlshrc /root/.cassandra
```

4、修改cassandra.yaml文件，主要修改以下几条，替换旧IP为新IP；initial_token值为第二步获取到的每个IP的tokens。
```
seeds: "192.168.120.84"
listen_address: 192.168.120.84
rpc_address: 192.168.120.84
initial_token: 
```

5、停止旧库并同步数据文件

停止源环境的旧库，并拷贝数据文件到目标环境的对应目录：
```
# systemctl stop cassandra
# scp -r /var/lib/cassandra/data/* 192.168.120.84:/var/lib/cassandra/data/
```

6、启动新库并验证
```
# systemctl start cassandra
# cqlsh 192.168.120.84
```
