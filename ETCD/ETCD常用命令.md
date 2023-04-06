# 集群管理命令

etcdctl是一个命令行的客户端，它提供了一些命令，可以方便我们在对服务进行测试或者手动修改数据库内容。etcdctl命令基本用法如下所示：
```
etcdctl [global options] command [command options] [args...]
```

具体的命令选项参数可以通过 `etcdctl command --help`来获取相关帮助

## 环境变量

如果遇到使用了TLS加密的集群，通常每条指令都需要指定证书路径和etcd节点地址，可以把相关命令行参数添加在环境变量中，在 **~/.bashrc** 添加以下内容：
```
[root@tiaoban etcd]# cat ~/.bashrc
HOST_1=https://192.168.10.100:2379
HOST_2=https://192.168.10.11:2379
HOST_3=https://192.168.10.12:2379
ENDPOINTS=${HOST_1},${HOST_2},${HOST_3}
# 如果需要使用原生命令，在命令开头加一个\ 例如：\etcdctl command
alias etcdctl="etcdctl --endpoints=${ENDPOINTS} --cacert=/root/cfssl/etcd/ca.pem --cert=/root/cfssl/etcd/client.pem --key=/root/cfssl/etcd/client-key.pem"
alias etcdctljson="etcdctl --endpoints=${ENDPOINTS} --cacert=/root/cfssl/etcd/ca.pem --cert=/root/cfssl/etcd/client.pem --key=/root/cfssl/etcd/client-key.pem --write-out=json"
alias etcdctltable="etcdctl --endpoints=${ENDPOINTS} --cacert=/root/cfssl/etcd/ca.pem --cert=/root/cfssl/etcd/client.pem --key=/root/cfssl/etcd/client-key.pem --write-out=table"
[root@tiaoban etcd]# source ~/.bashrc
```

## 查看etcd版本
```
[root@tiaoban etcd]# etcdctl version
etcdctl version: 3.4.23
API version: 3.4
```

## 查看etcd集群节点信息
```
[root@tiaoban ~]# etcdctl member list -w table
+------------------+---------+-------+----------------------------+----------------------------+------------+
|        ID        | STATUS  | NAME  |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+-------+----------------------------+----------------------------+------------+
| 2e0eda3ad6bc6e1e | started | etcd1 | http://192.168.10.100:2380 | http://192.168.10.100:2379 |      false |
| 5d2c1bd3b22f796f | started | etcd3 |  http://192.168.10.12:2380 |  http://192.168.10.12:2379 |      false |
| bc34c6bd673bdf9f | started | etcd2 |  http://192.168.10.11:2380 |  http://192.168.10.11:2379 |      false |
+------------------+---------+-------+----------------------------+----------------------------+------------+
```

## 查看集群健康状态
```
[root@tiaoban ~]# etcdctl endpoint status -w table
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|      ENDPOINT       |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 192.168.10.100:2379 | 2e0eda3ad6bc6e1e |  3.4.23 |   20 kB |      true |      false |         4 |          9 |                  9 |        |
|  192.168.10.11:2379 | bc34c6bd673bdf9f |  3.4.23 |   20 kB |     false |      false |         4 |          9 |                  9 |        |
|  192.168.10.12:2379 | 5d2c1bd3b22f796f |  3.4.23 |   20 kB |     false |      false |         4 |          9 |                  9 |        |
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
[root@tiaoban ~]# etcdctl endpoint health -w table
+---------------------+--------+------------+-------+
|      ENDPOINT       | HEALTH |    TOOK    | ERROR |
+---------------------+--------+------------+-------+
| 192.168.10.100:2379 |   true | 4.391924ms |       |
|  192.168.10.11:2379 |   true | 7.091404ms |       |
|  192.168.10.12:2379 |   true | 7.571706ms |       |
+---------------------+--------+------------+-------+
```

## 查看告警事件

如果内部出现问题，会触发告警，可以通过命令查看告警引起原因，命令如下所示：
```
etcdctl alarm <subcommand> [flags]
```

常用的子命令主要有两个：
```
# 查看所有告警
etcdctl alarm list
# 解除所有告警
etcdctl alarm disarm
```

## 添加成员

当集群部署完成后，后续可能需要进行节点扩缩容，就可以使用member命令管理节点。先查看当前集群信息
```
[root@tiaoban etcd]# etcdctl endpoint status --cluster -w table
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://192.168.10.100:2379 | 2e0eda3ad6bc6e1e |  3.4.23 |   20 kB |      true |      false |         8 |         16 |                 16 |        |
|  http://192.168.10.12:2379 | 5d2c1bd3b22f796f |  3.4.23 |   20 kB |     false |      false |         8 |         16 |                 16 |        |
|  http://192.168.10.11:2379 | bc34c6bd673bdf9f |  3.4.23 |   20 kB |     false |      false |         8 |         16 |                 16 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

在启动新的etcd节点前，先向etcd集群声明添加节点的peer-urls和节点名称
```
[root@tiaoban etcd]# etcdctl member add etcd4 --peer-urls=http://192.168.10.100:12380
Member b112a60ec305e42a added to cluster cd30cff36981306b

ETCD_NAME="etcd4"
ETCD_INITIAL_CLUSTER="etcd1=http://192.168.10.100:2380,etcd3=http://192.168.10.12:2380,etcd4=http://192.168.10.100:12380,etcd2=http://192.168.10.11:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.10.100:12380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

接下来使用docker创建一个版本为3.4.23的etcd节点，运行在192.168.10.100上，使用host网络模式，endpoints地址为http://192.168.10.100:12379，节点名称为etcd4。
```
[root@tiaoban etcd]# mkdir -p /opt/docker/etcd/{conf,data}
[root@tiaoban etcd]# chown -R 1001:1001 /opt/docker/etcd/data/
[root@tiaoban etcd]# cat /opt/docker/etcd/conf/etcd.conf 
# 节点名称
name: 'etcd4'
# 指定节点的数据存储目录
data-dir: '/data'
# 监听客户端请求的地址列表
listen-client-urls: "http://192.168.10.100:12379"
# 监听URL，用于节点之间通信监听地址
listen-peer-urls: "http://192.168.10.100:12380"
# 对外公告的该节点客户端监听地址，这个值会告诉集群中其他节点
advertise-client-urls: "http://192.168.10.100:12379"
# 服务端之间通讯使用的地址列表,该节点同伴监听地址，这个值会告诉集群中其他节点
initial-advertise-peer-urls: "http://192.168.10.100:12380"
# etcd启动时，etcd集群的节点地址列表
initial-cluster: "etcd1=http://192.168.10.100:2380,etcd3=http://192.168.10.12:2380,etcd2=http://192.168.10.11:2380,etcd4=http://192.168.10.100:12380"
# etcd集群初始化的状态，new代表新建集群，existing表示加入现有集群
initial-cluster-state: 'existing'
[root@tiaoban etcd]# docker run --name=etcd4 --net=host -d -v /opt/docker/etcd/data:/data -v /opt/docker/etcd/conf:/conf bitnami/etcd:latest etcd --config-file /conf/etcd.conf
a142f38c785f2b7c217fb15f01ac62addfeb22eeb44da00363b1f7b5ce398439
```

etcd4启动后，查看集群节点信息：
```
[root@tiaoban etcd]# etcdctl endpoint status --cluster -w table
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|  http://192.168.10.100:2379 | 2e0eda3ad6bc6e1e |  3.4.23 |   20 kB |      true |      false |         6 |         11 |                 11 |        |
|   http://192.168.10.12:2379 | 5d2c1bd3b22f796f |  3.4.23 |   20 kB |     false |      false |         6 |         11 |                 11 |        |
| http://192.168.10.100:12379 | b112a60ec305e42a |  3.4.23 |   20 kB |     false |      false |         6 |         11 |                 11 |        |
|   http://192.168.10.11:2379 | bc34c6bd673bdf9f |  3.4.23 |   20 kB |     false |      false |         6 |         11 |                 11 |        |
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

## 更新成员

当etcd节点故障，启动etcd时报错**member count is unequal**。如果有保留的数据目录下的文件时，可以通过使用 member update 命令，在保留 etcd 数据的情况下初始化集群数据，重新构建一个新的etcd集群节点。 模拟192.168.10.100:12380节点故障，但数据目录文件有备份，启动一个新的节点，地址为：192.168.10.100:22380
```
# 停用旧节点
[root@tiaoban etcd]# docker stop etcd4
etcd4
[root@tiaoban etcd]# docker rm etcd4
etcd4

# 更新节点地址
[root@tiaoban etcd]# cat conf/etcd.conf 
# 节点名称
name: 'etcd4'
# 指定节点的数据存储目录
data-dir: '/data'
# 监听客户端请求的地址列表
listen-client-urls: "http://192.168.10.100:22379"
# 监听URL，用于节点之间通信监听地址
listen-peer-urls: "http://192.168.10.100:22380"
# 对外公告的该节点客户端监听地址，这个值会告诉集群中其他节点
advertise-client-urls: "http://192.168.10.100:22379"
# 服务端之间通讯使用的地址列表,该节点同伴监听地址，这个值会告诉集群中其他节点
initial-advertise-peer-urls: "http://192.168.10.100:22380"
# etcd启动时，etcd集群的节点地址列表
initial-cluster: "etcd1=http://192.168.10.100:2380,etcd2=http://192.168.10.11:2380,etcd3=http://192.168.10.12:2380,etcd4=http://192.168.10.100:22380"
# etcd集群初始化的状态，new代表新建集群，existing表示加入现有集群
initial-cluster-state: 'existing'

# 启动新节点
[root@tiaoban etcd]# docker run --name=etcd4 --net=host -d -v /opt/docker/etcd/data:/data -v /opt/docker/etcd/conf:/conf bitnami/etcd:3.4.23 etcd --config-file /conf/etcd.conf
03c03ac7e6b50a8600cefe443ecafdb03f8f61f153b1a1138029c1726826d74e
[root@tiaoban etcd]# docker ps
CONTAINER ID   IMAGE                 COMMAND                   CREATED         STATUS         PORTS     NAMES
03c03ac7e6b5   bitnami/etcd:3.4.23   "/opt/bitnami/script…"   3 seconds ago   Up 3 seconds             etcd4
```

执行更新member操作，指定新的节点地址。
```
[root@tiaoban etcd]# etcdctl member update b112a60ec305e42a --peer-urls=http://192.168.10.100:22380
Member b112a60ec305e42a updated in cluster cd30cff36981306b
```

查看集群节点信息，节点信息更新完成。
```
[root@tiaoban etcd]# etcdctl endpoint status --cluster -w table
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|  http://192.168.10.100:2379 | 2e0eda3ad6bc6e1e |  3.4.23 |   20 kB |      true |      false |         6 |         14 |                 14 |        |
|   http://192.168.10.12:2379 | 5d2c1bd3b22f796f |  3.4.23 |   20 kB |     false |      false |         6 |         14 |                 14 |        |
| http://192.168.10.100:22379 | b112a60ec305e42a |  3.4.23 |   20 kB |     false |      false |         6 |         14 |                 14 |        |
|   http://192.168.10.11:2379 | bc34c6bd673bdf9f |  3.4.23 |   20 kB |     false |      false |         6 |         14 |                 14 |        |
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

## 删除成员

主要用法如下所示：
```
etcdctl member remove <memberID> [flags]
```

模拟192.168.10.100:22379节点下线操作
```
[root@tiaoban etcd]# docker stop etcd4
etcd4
[root@tiaoban etcd]# docker rm etcd4
etcd4
[root@tiaoban etcd]# etcdctl member remove b112a60ec305e42a
Member b112a60ec305e42a removed from cluster cd30cff36981306b
[root@tiaoban etcd]# etcdctl endpoint status --cluster -w table
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://192.168.10.100:2379 | 2e0eda3ad6bc6e1e |  3.4.23 |   20 kB |      true |      false |         6 |         16 |                 16 |        |
|  http://192.168.10.12:2379 | 5d2c1bd3b22f796f |  3.4.23 |   20 kB |     false |      false |         6 |         16 |                 16 |        |
|  http://192.168.10.11:2379 | bc34c6bd673bdf9f |  3.4.23 |   20 kB |     false |      false |         6 |         16 |                 16 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

# 数据库操作命令

## 增加(put)

添加一个键值，基本用法如下所示：
```
etcdctl put [options] <key> <value> [flags]
```

常用参数如下所示：

| 参数 | 功能描述 |
|------|---------|
| --prev-kv | 输出修改前的键值 |

注意事项：
- 其中value接受从stdin的输入内容
- 如果value是以横线-开始，将会被视为flag，如果不希望出现这种情况，可以使用两个横线代替--
- 若键已经存在，则进行更新并覆盖原有值，若不存在，则进行添加

示例
```
[root@tiaoban etcd]# etcdctl put name cuiliang
OK
[root@tiaoban etcd]# etcdctl put location -- -beijing
OK
[root@tiaoban etcd]# etcdctl put foo1 bar1
OK
[root@tiaoban etcd]# etcdctl put foo2 bar2
OK
[root@tiaoban etcd]# etcdctl put foo3 bar3
OK
```

## 查询(get)

查询键值，基本用法如下所示：
```
etcdctl get [options] <key> [range_end] [flags]
```

常用参数如下所示：

| 参数 | 功能描述 |
|------|---------|
| --hex | 以十六进制形式输出 |
| --limit number | 设置输出结果的最大值 |
| --prefix | 根据prefix进行匹配key |
| --order | 对输出结果进行排序，ASCEND 或 DESCEND |
| --sort-by | 按给定字段排序，CREATE, KEY, MODIFY, VALUE, VERSION |
| --print-value-only | 仅输出value值 |
| --from-key | 按byte进行比较，获取大于等于指定key的结果 |
| --keys-only | 仅获取keys |

示例
```
# 获取键值
[root@tiaoban etcd]# etcdctl get name
name
cuiliang
# 只获取值
[root@tiaoban etcd]# etcdctl get location --print-value-only
-beijing
# 批量取从foo1到foo3的值，不包括foo3
[root@tiaoban etcd]# etcdctl get foo foo3 --print-value-only
bar1
bar2
# 批量获取前缀为foo的值
[root@tiaoban etcd]# etcdctl get --prefix foo --print-value-only
bar1
bar2
bar3
# 批量获取符合前缀的前两个值
[root@tiaoban etcd]# etcdctl get --prefix --limit=2 foo --print-value-only
bar1
bar2
# 批量获取前缀为foo的值，并排序
[root@tiaoban etcd]# etcdctl get --prefix foo --print-value-only --order DESCEND
bar3
bar2
bar1
```

## 删除(del)

删除键值，基本用法如下所示：
```
etcdctl del [options] <key> [range_end] [flags]
```

常用参数如下所示：

| 参数 | 功能描述 |
|------|---------|
| --prefix | 根据prefix进行匹配删除 |
| --prev-kv | 输出删除的键值 |
| --from-key | 按byte进行比较，删除大于等于指定key的结果 |

示例
```
# 删除name的键值
[root@tiaoban etcd]# etcdctl del name
1
# 删除从foo1到foo3且不包含foo3的键值
[root@tiaoban etcd]# etcdctl del foo1 foo3
2
# 删除前缀为foo的所有键值
[root@tiaoban etcd]# etcdctl del --prefix foo
1
```

## 更新(put覆盖)

若键已经存在，则进行更新并覆盖原有值，若不存在，则进行添加。

## 查询键历史记录查询

etcd在每次键值变更时，都会记录变更信息，便于我们查看键变更记录

# 监听命令

watch是监听键或前缀发生改变的事件流， 主要用法如下所示：
```
etcdctl watch [options] [key or prefix] [range_end] [--] [exec-command arg1 arg2 ...] [flags]
```

示例如下所示：
```
# 对某个key监听操作，当key1发生改变时，会返回最新值
etcdctl watch name
# 监听key前缀
etcdctl watch name --prefix
# 监听到改变后执行相关操作
etcdctl watch name --  etcdctl get age
```
etcdctl watch name --  etcdctl put name Kevin，如果写成，会不会变成死循环，导致无限监视，尽量避免。 示例

## 监听单个键
```
# 启动监听命令
[root@tiaoban etcd]# etcdctl watch foo

#另一个控制台执行新增命令
[root@tiaoban ~]# etcdctl put foo bar
OK

# 观察控制台监听输出
[root@tiaoban etcd]# etcdctl watch foo
PUT
foo
bar

#另一个控制台执行更新命令
[root@tiaoban ~]# etcdctl put foo bar123
OK

# 观察控制台监听输出
[root@tiaoban etcd]# etcdctl watch foo
PUT
foo
bar
PUT
foo
bar123

#另一个控制台执行删除命令
[root@tiaoban ~]# etcdctl del foo
1

# 观察控制台监听输出
[root@tiaoban etcd]# etcdctl watch foo
PUT
foo
bar
PUT
foo
bar123
DELETE
foo
```

## 同时监听多个键
```
# 监听前缀为foo的键
[root@tiaoban etcd]# etcdctl watch --prefix foo
# 另一个控制台执行操作
[root@tiaoban ~]# etcdctl put foo1 bar1
OK
[root@tiaoban ~]# etcdctl put foo2 bar2
OK
[root@tiaoban ~]# etcdctl del foo1
1
# 观察控制台输出
[root@tiaoban etcd]# etcdctl watch --prefix foo
PUT
foo1
bar1
PUT
foo2
bar2
DELETE
foo1


# 监听指定的多个键
[root@tiaoban etcd]# etcdctl watch -i
watch name
watch location

# 另一个控制台执行操作
[root@tiaoban ~]# etcdctl put name cuiliang
OK
[root@tiaoban ~]# etcdctl del name
1
[root@tiaoban ~]# etcdctl put location beijing
OK
# 观察控制台输出
[root@tiaoban etcd]# etcdctl watch -i
watch name
watch location
PUT
name
cuiliang
DELETE
name

PUT
location
beijing
```

# 租约命令

租约具有生命周期，需要为租约授予一个TTL(time to live)，将租约绑定到一个key上，则key的生命周期与租约一致，可续租，可撤销租约，类似于redis为键设置过期时间。其主要用法如下所示：
```
etcdctl lease <subcommand> [flags]
```

## 添加租约

主要用法如下所示：
```
etcdctl lease grant <ttl> [flags]
```

示例：
```
# 设置60秒后过期时间
[root@tiaoban etcd]# etcdctl lease grant 60
lease 6e1e86f4c6512a2b granted with TTL(60s)
# 把foo和租约绑定，设置成60秒后过期
[root@tiaoban etcd]# etcdctl put --lease=6e1e86f4c6512a29 foo bar
OK
# 租约期内查询键值
[root@tiaoban etcd]# etcdctl get foo
foo
bar
# 租约期外查询键值
[root@tiaoban etcd]# etcdctl get foo
返回为空
```

## 查看租约

查看租约信息，以便续租或查看租约是否仍然存在或已过期。 查看租约详情主要用法如下所示：
```
etcdctl lease timetolive <leaseID> [options] [flags]
```

示例：
```
# 添加一个50秒的租约
[root@tiaoban etcd]# etcdctl lease grant 50
lease 6e1e86f4c6512a32 granted with TTL(50s)
# 将name键绑定到6e1e86f4c6512a32租约上
[root@tiaoban etcd]# etcdctl put --lease=6e1e86f4c6512a32 name cuiliang
OK
# 查看所有租约列表
[root@tiaoban etcd]# etcdctl lease list
found 1 leases
6e1e86f4c6512a32
# 查看租约详情，remaining(6s) 剩余有效时间6秒；--keys 获取租约绑定的 key
[root@tiaoban etcd]# etcdctl lease timetolive --keys 6e1e86f4c6512a32
lease 6e1e86f4c6512a32 granted with TTL(50s), remaining(6s), attached keys([name])
```

## 租约续约

通过刷新 TTL 值来保持租约的有效，使其不会过期。 主要用法如下所示：
```
etcdctl lease keep-alive [options] <leaseID> [flags]
```

示例如下所示：
```
# 设置60秒后过期租约
[root@tiaoban etcd]# etcdctl lease grant 60
lease 6e1e86f4c6512a36 granted with TTL(60s)
# 把name和租约绑定，设置成 60 秒后过期
[root@tiaoban etcd]# etcdctl put --lease=6e1e86f4c6512a36 name cuiliang
OK
# 自动定时执行续约，续约成功后每次租约为60秒
[root@tiaoban etcd]# etcdctl lease keep-alive 6e1e86f4c6512a36
lease 6e1e86f4c6512a36 keepalived with TTL(60)
lease 6e1e86f4c6512a36 keepalived with TTL(60)
lease 6e1e86f4c6512a36 keepalived with TTL(60)
……
```

## 删除租约

通过租约 ID 撤销租约，撤销租约将删除其所有绑定的 key。 主要用法如下所示：
```
etcdctl lease revoke <leaseID> [flags]
```

示例如下所示：
```
# 设置600秒后过期租约
[root@tiaoban etcd]# etcdctl lease grant 600
lease 6e1e86f4c6512a39 granted with TTL(600s)
# 把foo和租约绑定，600秒后过期
[root@tiaoban etcd]# etcdctl put --lease=6e1e86f4c6512a39 foo bar
OK
# 查看租约详情
[root@tiaoban etcd]# etcdctl lease timetolive --keys 6e1e86f4c6512a39
lease 6e1e86f4c6512a39 granted with TTL(600s), remaining(556s), attached keys([foo])
# 删除租约
[root@tiaoban etcd]# etcdctl lease revoke 6e1e86f4c6512a39
lease 6e1e86f4c6512a39 revoked
# 查看租约详情
[root@tiaoban etcd]# etcdctl lease timetolive --keys 6e1e86f4c6512a39
lease 6e1e86f4c6512a39 already expired
# 获取键值
[root@tiaoban etcd]# etcdctl get foo
返回为空
```

## 多key同一租约

一个租约支持绑定多个 key
```
# 设置60秒后过期的租约
[root@tiaoban etcd]# etcdctl lease grant 60
lease 6e1e86f4c6512a3e granted with TTL(60s)
# foo1与租约绑定
[root@tiaoban etcd]# etcdctl put --lease=6e1e86f4c6512a3e foo1 bar1
OK
# foo2与租约绑定
[root@tiaoban etcd]# etcdctl put --lease=6e1e86f4c6512a3e foo2 bar2
OK
# 查看租约详情
[root@tiaoban etcd]# etcdctl lease timetolive --keys 6e1e86f4c6512a3e
lease 6e1e86f4c6512a3e granted with TTL(60s), remaining(14s), attached keys([foo1 foo2])
```

租约过期后，所有 key 值都会被删除，因此：
- 当租约只绑定了一个 key 时，想删除这个 key，最好的办法是撤销它的租约，而不是直接删除这个 key。
- 当租约没有绑定key时，应主动把它撤销掉，单纯删除 key 后，续约操作持续进行，会造成内存泄露。

直接删除key演示：
```
# 设置租约并绑定 zoo1
[root@tiaoban etcd]# etcdctl lease grant 60
lease 6e1e86f4c6512a43 granted with TTL(60s)
[root@tiaoban etcd]# etcdctl --lease=6e1e86f4c6512a43 put zoo1 val1
OK
# 续约
[root@tiaoban etcd]# etcdctl lease keep-alive 6e1e86f4c6512a43
lease 6e1e86f4c6512a43 keepalived with TTL(60)

# 此时在另一个控制台执行删除key操作：
[root@tiaoban ~]# etcdctl del zoo1
1
# 单纯删除 key 后，续约操作持续进行，会造成内存泄露
[root@tiaoban etcd]# etcdctl lease keep-alive 6e1e86f4c6512a43
lease 6e1e86f4c6512a43 keepalived with TTL(60)
lease 6e1e86f4c6512a43 keepalived with TTL(60)
lease 6e1e86f4c6512a43 keepalived with TTL(60)
...
```

撤销key的租约演示：
```
# 设置租约并绑定 zoo1
[root@tiaoban etcd]# etcdctl lease grant 50
lease 32698142c52a1717 granted with TTL(50s)
[root@tiaoban etcd]# etcdctl --lease=32698142c52a1717 put zoo1 val1
OK

# 续约
[root@tiaoban etcd]# etcdctl lease keep-alive 32698142c52a1717
lease 32698142c52a1717 keepalived with TTL(50)
lease 32698142c52a1717 keepalived with TTL(50)

# 另一个控制台执行：etcdctl lease revoke 32698142c52a1717

# 续约撤销并退出
lease 32698142c52a1717 expired or revoked.
[root@tiaoban etcd]# etcdctl get zoo1
# 返回空
```

# 备份恢复命令

主要用于管理节点的快照，其主要用法如下所示：
```
etcdctl snapshot <subcommand> [flags]
```

## 生成快照

其主要用法如下所示：
```
etcdctl snapshot save <filename> [flags]
```

示例如下所示：
```
etcdctl snapshot save etcd-snapshot.db
```

## 查看快照

其主要用法如下所示：
```
etcdctl snapshot status <filename> [flags]
```

示例如下所示：
```
etcdctl snapshot status etcd-snapshot.db -w table
```

## 恢复快照

其主要用法如下所示：
```
etcdctl snapshot restore <filename> [options] [flags]
```

## 备份恢复演示

- 新建一个名为name的key
```
[root@tiaoban ~]# etcdctl put name cuiliang
OK
[root@tiaoban ~]# etcdctl get name
name
cuiliang
[root@tiaoban ~]# etcdctl endpoint status -w table
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|      ENDPOINT       |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 192.168.10.100:2379 | 2e0eda3ad6bc6e1e |  3.4.23 |   20 kB |      true |      false |         4 |         10 |                 10 |        |
|  192.168.10.11:2379 | bc34c6bd673bdf9f |  3.4.23 |   20 kB |     false |      false |         4 |         10 |                 10 |        |
|  192.168.10.12:2379 | 5d2c1bd3b22f796f |  3.4.23 |   20 kB |     false |      false |         4 |         10 |                 10 |        |
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

- 生成快照，创建名为snap.db的备份文件
```
[root@k8s-work1 ~]# etcdctl snapshot save snap.db
{"level":"info","ts":1679220752.5883558,"caller":"snapshot/v3_snapshot.go:119","msg":"created temporary db file","path":"snap.db.part"}
{"level":"info","ts":"2023-03-19T18:12:32.592+0800","caller":"clientv3/maintenance.go:200","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1679220752.5924425,"caller":"snapshot/v3_snapshot.go:127","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}
{"level":"info","ts":"2023-03-19T18:12:32.595+0800","caller":"clientv3/maintenance.go:208","msg":"completed snapshot read; closing"}
{"level":"info","ts":1679220752.597161,"caller":"snapshot/v3_snapshot.go:142","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"25 kB","took":0.008507131}
{"level":"info","ts":1679220752.5973082,"caller":"snapshot/v3_snapshot.go:152","msg":"saved","path":"snap.db"}
Snapshot saved at snap.db
```

- 查看备份文件详情
```
[root@k8s-work1 ~]# ls -lh snap.db 
-rw------- 1 root root 25K 3月  19 18:12 snap.db
[root@k8s-work1 ~]# etcdctl snapshot status snap.db -w table
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| 8f097221 |       39 |         47 |      25 kB |
+----------+----------+------------+------------+
```

- 把快照文件传到其他节点
```
[root@k8s-work1 ~]# scp snap.db 192.168.10.100:/root                                                                                                                      100%   24KB   6.9MB/s   00:00    
[root@k8s-work1 ~]# scp snap.db 192.168.10.12:/root
```

- 停止所有节点的etcd服务，并删除数据目录
```
[root@k8s-work1 ~]# systemctl stop etcd
[root@k8s-work1 ~]# rm -rf /data/etcd
# 其余两个节点相同操作
```

- 在所有节点上开始恢复数据
```
[root@k8s-work1 ~]# etcdctl snapshot restore snap.db --name=etcd2 --data-dir=/data/etcd/cluster.etcd --initial-cluster=etcd1=http://192.168.10.100:2380,etcd2=http://192.168.10.11:2380,etcd3=http://192.168.10.12:2380 --initial-advertise-peer-urls=http://192.168.10.11:2380
{"level":"info","ts":1679221421.2932272,"caller":"snapshot/v3_snapshot.go:296","msg":"restoring snapshot","path":"snap.db","wal-dir":"/data/etcd/cluster.etcd/member/wal","data-dir":"/data/etcd/cluster.etcd","snap-dir":"/data/etcd/cluster.etcd/member/snap"}
{"level":"info","ts":1679221421.3019996,"caller":"membership/cluster.go:392","msg":"added member","cluster-id":"cd30cff36981306b","local-member-id":"0","added-peer-id":"2e0eda3ad6bc6e1e","added-peer-peer-urls":["http://192.168.10.100:2380"]}
{"level":"info","ts":1679221421.30208,"caller":"membership/cluster.go:392","msg":"added member","cluster-id":"cd30cff36981306b","local-member-id":"0","added-peer-id":"5d2c1bd3b22f796f","added-peer-peer-urls":["http://192.168.10.12:2380"]}
{"level":"info","ts":1679221421.3021913,"caller":"membership/cluster.go:392","msg":"added member","cluster-id":"cd30cff36981306b","local-member-id":"0","added-peer-id":"bc34c6bd673bdf9f","added-peer-peer-urls":["http://192.168.10.11:2380"]}
{"level":"info","ts":1679221421.3094716,"caller":"snapshot/v3_snapshot.go:309","msg":"restored snapshot","path":"snap.db","wal-dir":"/data/etcd/cluster.etcd/member/wal","data-dir":"/data/etcd/cluster.etcd","snap-dir":"/data/etcd/cluster.etcd/member/snap"}
[root@tiaoban ~]# etcdctl snapshot restore snap.db --name=etcd1 --data-dir=/data/etcd/cluster.etcd --initial-cluster=etcd1=http://192.168.10.100:2380,etcd2=http://192.168.10.11:2380,etcd3=http://192.168.10.12:2380 --initial-advertise-peer-urls=http://192.168.10.100:2380
[root@k8s-work2 ~]# etcdctl snapshot restore snap.db --name=etcd3 --data-dir=/data/etcd/cluster.etcd --initial-cluster=etcd1=http://192.168.10.100:2380,etcd2=http://192.168.10.11:2380,etcd3=http://192.168.10.12:2380 --initial-advertise-peer-urls=http://192.168.10.12:2380
```

- 所有节点重启etcd服务
```
[root@tiaoban ~]# systemctl restart etcd
```

- 查看验证
```
[root@tiaoban ~]# etcdctl get name
name
cuiliang
[root@tiaoban ~]# etcdctl endpoint status -w table
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|      ENDPOINT       |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 192.168.10.100:2379 | 2e0eda3ad6bc6e1e |  3.4.23 |   20 kB |      true |      false |         4 |         10 |                 10 |        |
|  192.168.10.11:2379 | bc34c6bd673bdf9f |  3.4.23 |   20 kB |     false |      false |         4 |         10 |                 10 |        |
|  192.168.10.12:2379 | 5d2c1bd3b22f796f |  3.4.23 |   20 kB |     false |      false |         4 |         10 |                 10 |        |
+---------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```
重启etcd后，仍能正常获取name的值，并且节点ID未发生改变。

# 用户管理命令

etcd默认是没有开启访问控制的，如果开启外网访问etcd的话就需要考虑访问控制的问题，etcd提供了两种访问控制的方式：
- 基于身份验证的访问控制
- 基于证书的访问控制

从v3.2版本开始，如果使用参数 --client-cert-auth=true 启动etcd服务器，则客户端的TLS证书中的 “通用名称（CN）” 字段将用作 etcd 用户。在这种情况下，公用名将对用户进行身份验证，并且客户端不需要密码。如果同时传递了 --client-cert-auth=true 且客户端提供了 CN，并且客户端提供了用户名和密码，则将优先考虑基于用户名和密码的身份验证。 etcd有一个特殊用户root和一个特殊角色root：
- **root用户**：root用户是etcd的超级管理员，拥有etcd的所有权限，在开启角色认证之前为们必须要先建立好root用户
- **root角色**：具有该root角色的用户既具有全局读写访问权限，具有更新集群的身份验证配置的权限。此外，该root角色还授予常规集群维护的特权，包括修改集群成员资格，对存储进行碎片整理以及拍摄快照。

etcd的权限资源：
- **Users**: user用来设置身份认证(user:passwd)，一个用户可以拥有多个角色，每个角色被分配一定的权限(只读、只写、可读写)，用户分为root用户和非root用户。
- **Roles**: 角色用来关联权限，角色主要三类： root角色:默认创建root用户时即创建了root角色，该角色拥有所有权限； guest角色:默认自动创建，主要用于非认证使用。普通角色， 由root用户创建角色，并分配指定权限。
- **Permissions**: 权限分为只读、只写、可读写三种权限，权限即对指定目录或key的读写权限。
如果没有指定任何验证方式，即未显示指定以什么用户进行访问，那么默认会设定为 guest 角色。默认情况下 guest 也是具有全局访问权限的

## 用户管理

其主要用法如下所示：
```
etcdctl user <subcommand> [flags]
```

其主要子命令主要如下所示：

| 子命令 | 常用用法 | 功能描述 |
|-------|----------|---------|
| add | `etcdctl user add < user name or user:password > [options] [flags]` | 添加新用户 |
| delete | `etcdctl user delete < user name > [flags]` | 删除用户 |
| list | `etcdctl user list [flags]` | 列出所有用户 |
| get | `etcdctl user get < user name > [options] [flags]` | 获取用户详细信息 |
| passwd | `etcdctl user passwd < user name > [options] [flags]` | 修改密码 |
| grant-role | `etcdctl user grant-role < user name > < role name > [flags]` | 赋予用户角色 |
| revoke-role | `etcdctl user revoke-role < user name > < role name > [flags]` | 删除用户角色 |

## 角色管理

其主要用法如下所示：
```
etcdctl role <subcommand> [flags]
```

其主要子命令主要如下所示：

| 子命令 | 常用用法 | 功能描述 |
|-------|----------|---------|
| add | `etcdctl role add < role name > [flags]` | 添加角色 |
| delete | `etcdctl role delete[flags]` | 删除角色 |
| list | `etcdctl role list [flags]` | 列出所有角色 |
| get	etcdctl | `role get[flags]` | 获取角色详情 |
| grant-permission | `etcdctl role grant-permission [options] < role name > < permission type > < key > [endkey] [flags]` | 把key操作权限授予给一个角色 |
| revoke-permission | `etcdctl role revoke-permission < role name > < key > [endkey] [flags]` | 从角色中撤销key操作权限 |

## 开启root身份验证

在开启身份验证后，注意事项如下所示：
- 开启身份验证：所有etcdctl命令操作都需要指定用户参数--user，参数值为用户名:密码
- 开启证书验证：所有etcdctl命令操作都需要添加证书参数--cacert

开启root身份验证的步骤如下所示：
```
# 添加root 用户，密码为123456
[root@tiaoban ~]# etcdctl user add root:123456
User root created
# 开启身份验证，开启为enable，取消为disable
[root@tiaoban ~]# etcdctl auth enable --user=root:123456
Authentication Enabled
# 在开启身份验证后，直接获取键值报错
[root@tiaoban ~]# etcdctl get name
{"level":"warn","ts":"2023-03-19T19:00:03.922+0800","caller":"clientv3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"endpoint://client-bdd66650-a0b8-4fb4-ab60-47336cfb7523/192.168.10.100:2379","attempt":0,"error":"rpc error: code = InvalidArgument desc = etcdserver: user name is empty"}
Error: etcdserver: user name is empty
# 添加用户信息访问
[root@tiaoban ~]# etcdctl get name --user=root:123456
name
cuiliang
```

## 角色授权

在开启了root身份验证后，就可以对普通用户和角色操作了。用户增删改查
```
# 增加普通用户
[root@tiaoban ~]# etcdctl user add test:123 --user=root:123456
User test created
# 获取用户信息
[root@tiaoban ~]# etcdctl user get test --user=root:123456
User: test
Roles:
# 查看所有用户
[root@tiaoban ~]# etcdctl user list --user=root:123456
root
test
# 修改用户密码
[root@tiaoban ~]# etcdctl user passwd test --user=root:123456
Password of test: 
Type password of test again for confirmation: 
Password updated
# 删除用户
[root@tiaoban ~]# etcdctl user delete test --user=root:123456
User test deleted
```

## 角色增删改查
```
# 添加角色
[root@tiaoban ~]# etcdctl role add test-role --user=root:123456
Role test-role created
# 获取角色详细信息
[root@tiaoban ~]# etcdctl role get test-role --user=root:123456
Role test-role
KV Read:
KV Write:
# 获取所有角色
[root@tiaoban ~]# etcdctl role list --user=root:123456
root
test-role
# 删除角色
[root@tiaoban ~]# etcdctl role delete test-role --user=root:123456
Role test-role deleted
```

用户角色绑定
```
# 增加普通用户
[root@tiaoban ~]# etcdctl user add test:123 --user=root:123456
User test created
# 添加角色
[root@tiaoban ~]# etcdctl role add test-role --user=root:123456
Role test-role created
# 将角色绑定给指定用户
[root@tiaoban ~]# etcdctl user grant-role test test-role --user=root:123456
Role test-role is granted to user test
# 查看用户信息
[root@tiaoban ~]# etcdctl user get test --user=root:123456
User: test
Roles: test-role

# 取消用户与角色绑定
[root@tiaoban ~]# etcdctl user revoke-role test test-role --user=root:123456
Role test-role is revoked from user test
# 查看用户信息
[root@tiaoban ~]# etcdctl user get test --user=root:123456
User: test
Roles: 
```

## 角色授权权限分为：只读（read）、只写(write)和读写(readwrite)权限

```
# 使用test用户获取name值会报错，权限拒绝
[root@tiaoban ~]# etcdctl get name --user=test:123
{"level":"warn","ts":"2023-03-19T19:10:50.515+0800","caller":"clientv3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"endpoint://client-dbe4e470-b1f4-40a1-b48f-71fcab9f32f0/192.168.10.100:2379","attempt":0,"error":"rpc error: code = PermissionDenied desc = etcdserver: permission denied"}
Error: etcdserver: permission denied

# 按key进行授权，test-role角色可以读写name
[root@tiaoban ~]# etcdctl role grant-permission test-role readwrite name  --user=root:123456
Role test-role updated
# 查看角色权限详情
[root@tiaoban ~]# etcdctl role get test-role --user=root:123456
Role test-role
KV Read:
        name
KV Write:
        name

# 也可以按key的prefix进行授权
[root@tiaoban ~]# etcdctl role grant-permission test-role readwrite foo --prefix=true --user=root:123456
Role test-role updated
# 查看角色权限详情
[root@tiaoban ~]# etcdctl role get test-role --user=root:123456
Role test-role
KV Read:
        [foo, fop) (prefix foo)
        name
KV Write:
        [foo, fop) (prefix foo)
        name

# 撤消角色授权
[root@tiaoban ~]# etcdctl role revoke-permission test-role name --user=root:123456
Permission of key name is revoked from role test-role
# 查看角色权限详情
[root@tiaoban ~]# etcdctl role get test-role --user=root:123456
Role test-role
KV Read:
        [foo, fop) (prefix foo)
KV Write:
        [foo, fop) (prefix foo)
```
