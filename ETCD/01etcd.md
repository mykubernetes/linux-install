一、概述
===
http://www.xuyasong.com/?p=1983

1、etcd 简介

etcd 是 CoreOS 团队于 2013 年 6月发起的开源项目，它的目标是构建一个高可用的分布式键值(key-value)数据库。etcd 内部采用raft协议作为一致性算法，etcd 基于 Go 语言实现。

2、etcd 的特点
- 简单：安装配置简单，而且提供了HTTP API进行交互，使用也很简单
- 安全：支持SSL证书验证
- 快速：根据官方提供的benchmark数据，单实例支持每秒2k+读操作
- 可靠：采用raft算法，实现分布式系统数据的可用性和一致性

3、概念术语
- Raft：etcd所采用的保证分布式系统强一致性的算法。
- Node：一个Raft状态机实例。
- Member：一个etcd实例。它管理着一个Node，并且可以为客户端请求提供服务。
- Cluster：由多个Member构成可以协同工作的etcd集群。
- Peer：对同一个etcd集群中另外一个Member的称呼。
- Client：向etcd集群发送HTTP请求的客户端。
- WAL：预写式日志，etcd用于持久化存储的日志格式。
- snapshot：etcd防止WAL文件过多而设置的快照，存储etcd数据状态。
- Proxy：etcd的一种模式，为etcd集群提供反向代理服务。
- Leader：Raft算法中通过竞选而产生的处理所有数据提交的节点。
- Follower：竞选失败的节点作为Raft中的从属节点，为算法提供强一致性保证。
- Candidate：当Follower超过一定时间接收不到Leader的心跳时转变为Candidate开始竞选。
- Term：某个节点成为Leader到下一次竞选时间，称为一个Term。
- Index：数据项编号。Raft中通过Term和Index来定位数据。

4、数据读写顺序

为了保证数据的强一致性，etcd 集群中所有的数据流向都是一个方向，从 Leader （主节点）流向 Follower，也就是所有 Follower 的数据必须与 Leader 保持一致，如果不一致会被覆盖。

用户对于 etcd 集群所有节点进行读写
- 读取：由于集群所有节点数据是强一致性的，读取可以从集群中随便哪个节点进行读取数据
- 写入：etcd 集群有 leader，如果写入往 leader 写入，可以直接写入，然后然后Leader节点会把写入分发给所有 Follower，如果往 follower 写入，然后Leader节点会把写入分发给所有 Follower

5、leader 选举

假设三个节点的集群，三个节点上均运行 Timer（每个 Timer 持续时间是随机的），Raft算法使用随机 Timer 来初始化 Leader 选举流程，第一个节点率先完成了 Timer，随后它就会向其他两个节点发送成为 Leader 的请求，其他节点接收到请求后会以投票回应然后第一个节点被选举为 Leader。

成为 Leader 后，该节点会以固定时间间隔向其他节点发送通知，确保自己仍是Leader。有些情况下当 Follower 们收不到 Leader 的通知后，比如说 Leader 节点宕机或者失去了连接，其他节点会重复之前选举过程选举出新的 Leader。


6、判断数据是否写入

etcd 认为写入请求被 Leader 节点处理并分发给了多数节点后，就是一个成功的写入。那么多少节点如何判定呢，假设总结点数是 N，那么多数节点 Quorum=N/2+1。关于如何确定 etcd 集群应该有多少个节点的问题，上图的左侧的图表给出了集群中节点总数(Instances)对应的 Quorum 数量，用 Instances 减去 Quorom 就是集群中容错节点（允许出故障的节点）的数量。

所以在集群中推荐的最少节点数量是3个，因为1和2个节点的容错节点数都是0，一旦有一个节点宕掉整个集群就不能正常工作了。

etcd除了受到Zookeeper与doozer启发而催生的项目，还拥有与之类似的功能外，更具有以下4个特点：
- 简单：基于HTTP+JSON的API让你用curl命令就可以轻松使用。
- 安全：可选SSL客户认证机制。
- 快速：每个实例每秒支持一千次写操作。
- 可信：使用Raft算法充分实现了分布式。

至于为什么不用zookeeper或者eureka等，除了根据项目考虑之外，就看个人喜好了，如果有哪位大佬知道更多内容，麻烦也在留言区告知小编一下，万分感谢！

以下是常用的服务发现产品之间的比较：

| Feature | Consul | zookeeper | etcd | euerka |
|---------|-------|------------|------|---------|
| 服务健康检查 | 服务状态，内存，硬盘等 | (弱)长连接，keepalive | 连接心跳 | 可配支持 |
| 多数据中心 | 支持 | — | — | — |
| kv存储服务 | 支持 | 支持 | 支持 | — |
| 一致性 | raft | paxos | raft | — |
| cap | ca | cp | cp | ap |
| 使用接口(多语言能力) | 支持http和dns | 客户端 | http/grpc | http（sidecar） |
| watch支持 | 全量/支持long polling | 支持 | 支持 long polling | 支持 long polling/大部分增量 |
| 自身监控 | metrics | — | metrics | metrics |
| 安全 | acl | /https	acl | https支持（弱） | — |
| spring cloud集成 | 已支持 | 已支持 | 已支持 | 已支持 |



二、etcd 架构及解析
===
1、架构图

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd001.png)

2、架构解析

从 etcd 的架构图中我们可以看到，etcd 主要分为四个部分。
- HTTP Server：用于处理用户发送的 API 请求以及其它 etcd 节点的同步与心跳信息请求。
- Store：用于处理 etcd 支持的各类功能的事务，包括数据索引、节点状态变更、监控与反馈、事件处理与执行等等，是 etcd 对用户提供的大多数 API 功能的具体实现。
- Raft：Raft 强一致性算法的具体实现，是 etcd 的核心。
- WAL：Write Ahead Log（预写式日志），是 etcd 的数据存储方式。除了在内存中存有所有数据的状态以及节点的索引以外，etcd 就通过 WAL 进行持久化存储。WAL 中，所有的数据提交前都会事先记录日志。
- Snapshot 是为了防止数据过多而进行的状态快照；
- Entry 表示存储的具体日志内容。

通常，一个用户的请求发送过来，会经由 HTTP Server 转发给 Store 进行具体的事务处理，如果涉及到节点的修改，则交给 Raft 模块进行状态的变更、日志的记录，然后再同步给别的 etcd 节点以确认数据提交，最后进行数据的提交，再次同步。

三、应用场景

1、服务注册与发现

etcd 可以用于服务的注册与发现
- 前后端业务注册发现

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd002.png)

中间价已经后端服务在 etcd 中注册，前端和中间价可以很轻松的从 etcd 中发现相关服务器然后服务器之间根据调用关系相关绑定调用

- 多组后端服务器注册发现

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd003.png)

后端多个无状态相同副本的 app 可以同事注册到 etcd 中，前端可以通过 haproxy 从etcd 中获取到后端的 ip 和端口组，然后进行请求转发，可以用来故障转移屏蔽后端端口已经后端多组app实例。

2、消息发布与订阅

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd004.png)

etcd 可以充当消息中间件，生产者可以往 etcd 中注册 topic 并发送消息，消费者从etcd 中订阅 topic，来获取生产者发送至 etcd 中的消息。

3、负载均衡

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd005.png)

后端多组相同的服务提供者可以经自己服务注册到 etcd 中，etcd 并且会与注册的服务进行监控检查，服务请求这首先从 etcd 中获取到可用的服务提供者真正的 ip:port，然后对此多组服务发送请求，etcd 在其中充当了负载均衡的功能

4、分部署通知与协调

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd006.png)

- 当 etcd watch 服务发现丢失，会通知服务检查
- 控制器向 etcd 发送启动服务，etcd通知服务进行相应操作
- 当服务完成 work 会讲状态更新至 etcd，etcd 对应会通知用户


5、分布式锁

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd007.png)

当有多个竞争者 node 节点，etcd 作为总控，在分布式集群中与一个节点成功分配 lock

6、分布式队列

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd008.png)

有对个 node，etcd 根据每个 node 来创建对应 node 的队列，根据不同的队列可以在etcd 中找到对应的 competitor

7、集群与监控与 Leader 选举

![image](https://github.com/mykubernetes/linux-install/blob/master/image/etcd/etcd009.png)

etcd 可以根据 raft 算法在多个 node 节点来选举出 leader。


四、安装
===
集群部署最好部署奇数位，此能达到最好的集群容错

1、host 配置

在此示例用三个节点来部署 etcd 集群，各节点修改 hosts

```
cat >> /etc/hosts << EOF
172.16.0.8 etcd-0-8
172.16.0.14 etcd-0-14
172.16.0.17 etcd-0-17
EOF
```

2、etcd 安装

三个节点均安装 etcd
```
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum -y install etcd
systemctl enable etcd
mkdir -p /data/app/etcd/
chown etcd:etcd /data/app/etcd/
```

3、etcd 配置

etcd-0-8配置：
```
[root@etcd-server ~]# hostnamectl set-hostname etcd-0-8
[root@etcd-0-8 ~]# egrep "^#|^$" /etc/etcd/etcd.conf -v
ETCD_DATA_DIR="/data/app/etcd/"
ETCD_LISTEN_PEER_URLS="http://172.16.0.8:2380"
ETCD_LISTEN_CLIENT_URLS="http://127.0.0.1:2379,http://172.16.0.8:2379"
ETCD_NAME="etcd-0-8"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://172.16.0.8:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://127.0.0.1:2379,http://172.16.0.8:2379"
ETCD_INITIAL_CLUSTER="etcd-0-8=http://172.16.0.8:2380,etcd-0-17=http://172.16.0.17:2380,etcd-0-14=http://172.16.0.14:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-token"
ETCD_INITIAL_CLUSTER_STATE="new"
```

etcd-0-14配置：
```
[root@etcd-server ~]# hostnamectl set-hostname etcd-0-14
[root@etcd-server ~]# mkdir -p /data/app/etcd/
[root@etcd-0.14 ~]# egrep "^#|^$" /etc/etcd/etcd.conf -v
ETCD_DATA_DIR="/data/app/etcd/"
ETCD_LISTEN_PEER_URLS="http://172.16.0.14:2380"
ETCD_LISTEN_CLIENT_URLS="http://127.0.0.1:2379,http://172.16.0.14:2379"
ETCD_NAME="etcd-0-14"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://172.16.0.14:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://127.0.0.1:2379,http://172.16.0.14:2379"
ETCD_INITIAL_CLUSTER="etcd-0-8=http://172.16.0.8:2380,etcd-0-17=http://172.16.0.17:2380,etcd-0-14=http://172.16.0.14:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-token"
ETCD_INITIAL_CLUSTER_STATE="new"
```

etcd-0-7配置:
```
[root@etcd-server ~]# hostnamectl set-hostname etcd-0-17
[root@etcd-server ~]# mkdir -p /data/app/etcd/
[root@etcd-0-17 ~]# egrep "^#|^$" /etc/etcd/etcd.conf -v
ETCD_DATA_DIR="/data/app/etcd/"
ETCD_LISTEN_PEER_URLS="http://172.16.0.17:2380"
ETCD_LISTEN_CLIENT_URLS="http://127.0.0.1:2379,http://172.16.0.17:2379"
ETCD_NAME="etcd-0-17"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://172.16.0.17:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://127.0.0.1:2379,http://172.16.0.17:2379"
ETCD_INITIAL_CLUSTER="etcd-0-8=http://172.16.0.8:2380,etcd-0-17=http://172.16.0.17:2380,etcd-0-14=http://172.16.0.14:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-token"
ETCD_INITIAL_CLUSTER_STATE="new"
```

4、配置完成后启动服务
```
systemctl start etcd
systemctl enable etcd
```

5、配置etcd API 版本为3#
```
# cat .bash_profile
export ETCDCTL_API=3
```

6、查看集群状态

查看 etcd 状态
```
[root@etcd-0-8 default.etcd]# systemctl status etcd
● etcd.service - Etcd Server
   Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-12-03 15:55:28 CST; 8s ago
 Main PID: 24510 (etcd)
   CGroup: /system.slice/etcd.service
           └─24510 /usr/bin/etcd --name=etcd-0-8 --data-dir=/data/app/etcd/ --listen-client-urls=http://172.16.0.8:2379

12月 03 15:55:28 etcd-0-8 etcd[24510]: set the initial cluster version to 3.0
12月 03 15:55:28 etcd-0-8 etcd[24510]: enabled capabilities for version 3.0
12月 03 15:55:30 etcd-0-8 etcd[24510]: peer 56e0b6dad4c53d42 became active
12月 03 15:55:30 etcd-0-8 etcd[24510]: established a TCP streaming connection with peer 56e0b6dad4c53d42 (stream Message reader)
12月 03 15:55:30 etcd-0-8 etcd[24510]: established a TCP streaming connection with peer 56e0b6dad4c53d42 (stream Message writer)
12月 03 15:55:30 etcd-0-8 etcd[24510]: established a TCP streaming connection with peer 56e0b6dad4c53d42 (stream MsgApp v2 reader)
12月 03 15:55:30 etcd-0-8 etcd[24510]: established a TCP streaming connection with peer 56e0b6dad4c53d42 (stream MsgApp v2 writer)
12月 03 15:55:32 etcd-0-8 etcd[24510]: updating the cluster version from 3.0 to 3.3
12月 03 15:55:32 etcd-0-8 etcd[24510]: updated the cluster version from 3.0 to 3.3
12月 03 15:55:32 etcd-0-8 etcd[24510]: enabled capabilities for version 3.3
```


查看端口监听(如果未在本地监听环回地址，那么在本地使用etcdctl不能正常连入进去)
```
# netstat -lntup |grep etcd
tcp 0      0 172.16.0.8:2379   0.0.0.0:*     LISTEN 25167/etcd
tcp 0      0 127.0.0.1:2379    0.0.0.0:*     LISTEN 25167/etcd
tcp 0      0 172.16.0.8:2380   0.0.0.0:*     LISTEN 25167/etcd
```

查看版本
```
$ etcd --version
etcd Version: 3.1.5
Git SHA: 20490ca
Go Version: go1.7.5
Go OS/Arch: linux/amd64
```

查看帮助
```
$ etcdctl -h
NAME:
   etcdctl - A simple command line client for etcd.
 
USAGE:
   etcdctl [global options] command [command options] [arguments...]
 
VERSION:
   3.1.5
 
COMMANDS:
     backup          backup an etcd directory
     cluster-health  check the health of the etcd cluster
     mk              make a new key with a given value
     mkdir           make a new directory
     rm              remove a key or a directory
     rmdir           removes the key if it is an empty directory or a key-value pair
     get             retrieve the value of a key
     ls              retrieve a directory
     set             set the value of a key
     setdir          create a new directory or update an existing directory TTL
     update          update an existing key with a given value
     updatedir       update an existing directory
     watch           watch a key for changes
     exec-watch      watch a key for changes and exec an executable
     member          member add, remove and list subcommands
     user            user add, grant and revoke subcommands
     role            role add, grant and revoke subcommands
     auth            overall auth controls
     help, h         Shows a list of commands or help for one command
 
GLOBAL OPTIONS:
   --debug                          output cURL commands which can be used to reproduce the request
   --no-sync                        don't synchronize cluster information before sending request
   --output simple, -o simple       output response in the given format (simple, `extended` or `json`) (default: "simple")
   --discovery-srv value, -D value  domain name to query for SRV records describing cluster endpoints
   --insecure-discovery             accept insecure SRV records describing cluster endpoints
   --peers value, -C value          DEPRECATED - "--endpoints" should be used instead
   --endpoint value                 DEPRECATED - "--endpoints" should be used instead
   --endpoints value                a comma-delimited list of machine addresses in the cluster (default: "http://127.0.0.1:2379,http://127.0.0.1:4001")
   --cert-file value                identify HTTPS client using this SSL certificate file
   --key-file value                 identify HTTPS client using this SSL key file
   --ca-file value                  verify certificates of HTTPS-enabled servers using this CA bundle
   --username value, -u value       provide username[:password] and prompt if password is not supplied.
   --timeout value                  connection timeout per request (default: 2s)
   --total-timeout value            timeout for the command execution (except watch) (default: 5s)
   --help, -h                       show help
   --version, -v                    print the version
```

常用命令选项
```
--debug 输出CURL命令，显示执行命令的时候发起的请求
--no-sync 发出请求之前不同步集群信息
--output, -o 'simple' 输出内容的格式(simple 为原始信息，json 为进行json格式解码，易读性好一些)
--peers, -C 指定集群中的同伴信息，用逗号隔开(默认为: "127.0.0.1:4001")
--cert-file HTTPS下客户端使用的SSL证书文件
--key-file HTTPS下客户端使用的SSL**文件
--ca-file 服务端使用HTTPS时，使用CA文件进行验证
--help, -h 显示帮助命令信息
--version, -v 打印版本信息
```

查看集群状态
```
# 查看集群成员
# etcdctl member list
2d2e457c6a1a76cb: name=etcd-0-8 peerURLs=http://172.16.0.8:2380 clientURLs=http://127.0.0.1:2379,http://172.16.0.8:2379 isLeader=false
56e0b6dad4c53d42: name=etcd-0-14 peerURLs=http://172.16.0.14:2380 clientURLs=http://127.0.0.1:2379,http://172.16.0.14:2379 isLeader=true
d2d2e9fc758e6790: name=etcd-0-17 peerURLs=http://172.16.0.17:2380 clientURLs=http://127.0.0.1:2379,http://172.16.0.17:2379 isLeader=false

# etcdctl cluster-health
member 2d2e457c6a1a76cb is healthy: got healthy result from http://127.0.0.1:2379
member 56e0b6dad4c53d42 is healthy: got healthy result from http://127.0.0.1:2379
member d2d2e9fc758e6790 is healthy: got healthy result from http://127.0.0.1:2379
cluster is healthy
```

```
# 查看集群状态
# etcdctl --write-out=table --endpoints=172.16.0.8:2379,172.16.0.14:2379,172.16.0.17:2379 endpoint status
+------------------+------------------+---------+---------+-----------+-----------+------------+
|     ENDPOINT     |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+------------------+------------------+---------+---------+-----------+-----------+------------+
| 172.16.0.8:2379  | 2d2e457c6a1a76cb | 3.0.0   | 45 kB   | false     |         4 |      16726 |
| 172.16.0.14:2379 | 56e0b6dad4c53d42 | 3.0.0   | 45 kB   | true      |         4 |      16726 |
| 172.16.0.17:2379 | d2d2e9fc758e6790 | 3.0.0   | 45 kB   | false     |         4 |      16726 |
+------------------+------------------+---------+---------+-----------+-----------+------------+

# etcdctl --endpoints=172.16.0.8:2379,172.16.0.14:2379,172.16.0.17:2379 endpoint health
172.16.0.8:2379 is healthy: successfully committed proposal: took = 3.345431ms
172.16.0.14:2379 is healthy: successfully committed proposal: took = 3.767967ms
172.16.0.817:2379 is healthy: successfully committed proposal: took = 4.025451ms
```

五、简单使用
===

| 命令 | 说明 |
| :------: | :--------: |
| alarm disarm | 接触所有的报警 |
| alarm list | 列出所有的报警 |
| auth disable | 禁用 authentication |
| auth enable | 启动 authentication |
| check datascale | 对于给定的服务器实例，检查持有数据的存储使用率 |
| check perf | 检查etcd集群的性能表现 |
| compaction | 压缩etcd中的事件历史 |
| defrag | 整理给定etcd实例的存储碎片 |
| del | 移除指定范围的[key,range_end]的键值对 |
| elect | 加入leader选举 |
| endpoint hashkv | 打印指定的etcd实例的历史键值对hash信息 |
| endpoint health | 打印指定的etcd实例的健康信息 |
| endpoint status | 打印指定的etcd实例的状态信息 |
| get | 获取键值对 |
| help | 帮助命令 |
| lease grant | 创建leases |
| lease keep-alive | 刷新leases |
| lease list | 列出所有有效的leases |
| lease revoke | 撤销leases |
| lease timetolive | 获取leases信息 |
| lock | 获取一个锁名 |
| make-mirror | 指定一个etcd集群作为镜像集群 |
| member add | 增加一个成员到集群 |
| member list | 列出集群的所有成员 |
| member promote | 提升集群中的一个non-voting成员 |
| member remove | 移除集群中的成员 |
| member update | 更新集群中的成员信息 |
| migrate | 迁移V2存储中的键值对到MVCC存储 |
| move-leader | 移动etcd集群的leader给另一个etcd成员 |
| put | 写入一个键值对 |
| role add | 添加一个角色 |
| role delete | 删除一个角色 |
| role get | 获取某个角色的详细信息 |
| role grant-permission | 给某个角色授予key |
| role list | 罗列所有的角色|
| role revoke-permission | 撤销一个角色的key |
| snapshot restore | 恢复快照 |
| snapshot save | 存储某一个etcd节点的快照文件到指定位置 |
| snapshot status | 获取指定文件的后端快照文件状态 |
| txn | Txn在一个事务内处理所有的请求 |
| user add | 增加一个用户 |
| user delete | 删除某个用户 |
| user get | 获取某个用户的详细信息 |
| user grant-role | 将某个角色赋予某个用户 |
| user list | 列出所有用户 |
| user passwd | 更改某个用户的密码 |
| user revoke-role | 撤销某个用户的角色 |
| version | 输出etcdctl的版本 |
| watch | 检测指定键或者前缀的事件流 |

| options | 说明 |
| :------: | :--------: |
| --cacert="" | 服务端使用https时，使用的CA文件进行验证 |
| --cert="" | https下客户端使用ssl证书文件 |
| --command-timeout=5s | 命令执行超时时间设置 |
| --debug[=false] | 输出CURL命令，显示执行命令时发起的请求日志 |
| --dial-timeout=2s | 客户端连接超时时间 |
| -d,--discovery-srv="" | 使用查询描述集群端点SRV记录的郁闷 |
| --discovery-srv-name="" | 使用DNS发现时，查询的服务名 |
| --endpoints=[172.0.0.1:2379] | gRPC端点 |
| -h,--help[=false] | etcdctl帮助 |
| --hex[=false] |输出二进制字符串为十六进制编码的字符串 |
| --insecure-discovery[=true] | 接受集群成员中不安全的SRV记录 |
| --insecure-skip-tls-verify[=false] | 跳过服务端证书认证 |
| --insecure-transport[=true] | 客户端紧张安全传输 |
| --keepalive-time=2s | 客户端连接的keepalive时间 |
| --keepalive-timeout=6s | 客户端连接的keepalive的超时时间 |
| --key="" | HTTPS下客户端使用SSL密钥文件 |
| --password="" | 认证的密码，当该选项开启，--user参数中不要包含密码 |
| --user="" | username[:password]的形式 |
| -w,--wirte-out="simple" | 输出内容格式（Fields、Json、Protobuf、Simple、Table） |


1）增加
---

1、put 

设置或者更新某个键的值
```
$ etcdctl put /test/foo1 "Hello world"
$ etcdctl put /test/foo2 "Hello world2"
$ etcdctl put /test/foo3 "Hello world3"
```

1、set

指定某个键的值。例如:

```
$ etcdctl set /testdir/testkey "Hello world"
Hello world
```
#支持的选项包括：
- --ttl '0' 该键值的超时时间(单位为秒)，不配置(默认为0)则永不超时
- --swap-with-value value 若该键现在的值是value，则进行设置操作
- --swap-with-index '0'   若该键现在的索引值是指定索引，则进行设置操作

2、mk

如果给定的键不存在，则创建一个新的键值。例如:

```
$ etcdctl mk /testdir/testkey "Hello world"
Hello world
```
#当键存在的时候，执行该命令会报错，例如:
```
$ etcdctl mk /testdir/testkey "Hello world"
Error: 105: Key already exists (/testdir/testkey) [8]
```
#支持的选项为:
- --ttl '0' 超时时间(单位为秒），不配置(默认为 0)。则永不超时


3、mkdir

如果给定的键目录不存在，则创建一个新的键目录。例如：

```
$ etcdctl mkdir testdir2
```
#支持的选项为：
- --ttl '0' 超时时间(单位为秒)，不配置(默认为0)则永不超时。


4、setdir

创建一个键目录。如果目录不存在就创建，如果目录存在更新目录TTL。
```
$ etcdctl setdir testdir3
```
#支持的选项为:
- --ttl '0' 超时时间(单位为秒)，不配置(默认为0)则永不超时。


2）删除
---
1、rm

删除某个键值。例如:
```
$ etcdctl rm /testdir/testkey
PrevNode.Value: Hello
```
#当键不存在时，则会报错。例如:
```
$ etcdctl rm /testdir/testkey
Error: 100: Key not found (/testdir/testkey) [7]
```
#支持的选项为：
- --dir 如果键是个空目录或者键值对则删除
- --recursive 删除目录和所有子键
- --with-value 检查现有的值是否匹配
- --with-index '0'检查现有的index是否匹配


2、rmdir

删除一个空目录，或者键值对。
```
$ etcdctl setdir dir1
$ etcdctl rmdir dir1
```
#若目录不空，会报错:
```
$ etcdctl set /dir/testkey hi
hi
$ etcdctl rmdir /dir
Error: 108: Directory not empty (/dir) [17]
```

3、删除了一个键
```
$ etcdctl del foo
#删除从 foo 到 foo9 范围的键的命令
$ etcdctl del foo foo9
```

4、删除键 zoo 并返回被删除的键值对
```
$ etcdctl del --prev-kv zoo
1   # 一个键被删除
zoo # 被删除的键
val # 被删除的键的值
```

5、删除前缀为 zoo 的键
```
$ etcdctl del --prefix zoo
2 # 删除了两个键
```

6、删除大于等于键 b 的 byte 值的键
```
a = 123
b = 456
z = 789

$ etcdctl del --from-key b
2 # 删除了两个键
```

3）更新
---
1、update

当键存在时，更新值内容。例如：
```
$ etcdctl update /testdir/testkey "Hello"
Hello
```
#当键不存在时，则会报错。例如:
```
$ etcdctl update /testdir/testkey2 "Hello"
Error: 100: Key not found (/testdir/testkey2) [6]
```
#支持的选项为:
- --ttl '0' 超时时间(单位为秒)，不配置(默认为 0)则永不超时。


2、updatedir

更新一个已经存在的目录。
```
$ etcdctl updatedir testdir2
```
#支持的选项为:
- --ttl '0' 超时时间(单位为秒)，不配置(默认为0)则永不超时。


4)查询
---

1、get获取指定键的值。
```
$ etcdctl get /testdir/testkey
Hello world
```
#当键不存在时，则会报错。例如：
```
$ etcdctl get /testdir/testkey2
Error: 100: Key not found (/testdir/testkey2) [5]
```
#支持的选项为:
- --sort 对结果进行排序
- --consistent 将请求发给主节点，保证获取内容的一致性。

2、根据指定的键（key），获取其对应的十六进制格式值
```
$ etcdctl get /test/foo1 --hex
\x2f\x74\x65\x73\x74\x64\x69\x72\x2f\x74\x65\x73\x74\x6b\x65\x79 #键
\x48\x65\x6c\x6c\x6f\x20\x77\x6f\x72\x6c\x64 #值
```
- --print-value-only可以读取对应的值

3、GET 范围内的值
```
$ etcdctl get /test/foo1 /test/foo3
/test/foo1
Hello world
/test/foo2
Hello world2
```
- 获取了大于等于 /test/foo1，且小于 /test/foo3 的键值对

4、获取某个前缀的所有键值对，通过--prefix可以指定前缀
```
$ etcdctl get --prefix --limit=3 /test/foo
/test/foo1
Hello world
/test/foo2
Hello world2
/test/foo3
Hello world3
```
- --limit=2 限制获取的数量

5、访问以前版本的key 
```
$ etcdctl get --prefix foo  # 访问最新版本的 key
$ etcdctl get --prefix --rev=4 foo  # 访问第 4 个版本的 key
$ etcdctl get --prefix --rev=3 foo  # 访问第 3 个版本的 key
$ etcdctl get --prefix --rev=2 foo  # 访问第 2 个版本的 key
$ etcdctl get --prefix --rev=1 foo  # 访问第 1 个版本的 key
```

6、读取大于等于键 b 的 byte 值的键
```
a = 123
b = 456
z = 789

$ etcdctl get --from-key b
b
456
z
789
```

7、ls

列出目录(默认为根目录)下的键或者子目录，默认不显示子目录中内容。
```
$ etcdctl ls
/testdir
/testdir2
/dir

$ etcdctl ls dir
/dir/testkey
```
#支持的选项包括:
- --sort 将输出结果排序
- --recursive 如果目录下有子目录，则递归输出其中的内容
- -p 对于输出为目录，在最后添加/进行区分


5)watch
---
1、watch

监测一个键值的变化，一旦键值发生更新，就会输出最新的值并退出。

例如:用户更新testkey键值为Hello watch。
```
$ etcdctl get /testdir/testkey
Hello world
$ etcdctl set /testdir/testkey "Hello watch"
Hello watch
$ etcdctl watch testdir/testkey
Hello watch
```
- --forever  一直监测直到用户按CTRL+C退出
- --after-index '0' 在指定index之前一直监测
- --recursive 返回所有的键值和子键值
- -i 观察多个键

2、从上一次历史修改开始观察
```
etcdctl watch --prev-kv testdir/testkey
```

3、exec-watch

监测一个键值的变化，一旦键值发生更新，就执行给定命令。

例如：用户更新testkey键值。
```
$ etcdctl exec-watch testdir/testkey -- sh -c 'ls'
config Documentation etcd etcdctl README-etcdctl.md README.md READMEv2-etcdctl.md
```
支持的选项包括:
- --after-index '0' 在指定 index 之前一直监测
- --recursive 返回所有的键值和子键值

6)压缩修订版本
---
etcd 保存修订版本以便应用客户端可以读取键的历史版本，为了避免积累无限数量的历史数据，对历史的修订版本进行压缩。压缩后etcd删除历史修订版本，释放空间，压缩修订版本之前的数据将不可访问。
```
$ etcdctl compact 5
compacted revision 5      #在压缩修订版本之前的任何修订版本都不可访问

$ etcdctl get --rev=4 foo
{"level":"warn","ts":"2020-05-04T16:37:38.020+0800","caller":"clientv3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"endpoint://client-c0d35565-0584-4c07-bfeb-034773278656/127.0.0.1:2379","attempt":0,"error":"rpc error: code = OutOfRange desc = etcdserver: mvcc: required revision has been compacted"}

Error: etcdserver: mvcc: required revision has been compacted
```

7)lease（租约）
---

1、授予租约，一旦租约的 TTL 到期，租约就会过期并且所有附带的键都将被删除。
```
# 授予租约，TTL 为 100 秒
$ etcdctl lease grant 100
lease 694d71ddacfda227 granted with TTL(10s)

# 附加键 foo 到租约 694d71ddacfda227
$ etcdctl put --lease=694d71ddacfda227 foo10 bar
OK
```

2、撤销租约,撤销租约将删除所有附带的 key
```
$ etcdctl lease revoke 694d71ddacfda227
lease 694d71ddacfda227 revoked

$ etcdctl get foo10
```

3、刷新租期,应用程序可以通过刷新其TTL保持租约存活，因此不会过期。
```
$ etcdctl lease keep-alive 694d71ddacfda227
lease 694d71ddacfda227 keepalived with TTL(100)
lease 694d71ddacfda227 keepalived with TTL(100)
...
```

4、查询租期
```
#授予租约
$ etcdctl lease grant 300
lease 694d71ddacfda22c granted with TTL(300s)

$ etcdctl put --lease=694d71ddacfda22c foo10 bar
OK

#获取有关租赁信息以及哪些 key 绑定了租赁信息
$ etcdctl lease timetolive 694d71ddacfda22c
lease 694d71ddacfda22c granted with TTL(300s), remaining(282s)

$ etcdctl lease timetolive --keys 694d71ddacfda22c
lease 694d71ddacfda22c granted with TTL(300s), remaining(220s), attached keys([foo10])
```

8)备份
---
备份etcd的数据。
```
$ etcdctl backup --data-dir /var/lib/etcd --backup-dir /home/etcd_backup
```
支持的选项包括:
- --data-dir  etcd的数据目录
- --backup-dir 备份到指定路径

9)member
---

1、通过list、add、remove命令列出、添加、删除 etcd 实例到 etcd 集群中。
```
member add          #已有集群中增加成员
member remove       #移除已有集群中的成员
member update       #更新集群中的成员
member list         #集群成员列表

```

2、查看集群中存在的节点
```
$ etcdctl member list
8e9e05c52164694d: name=dev-master-01 peerURLs=http://localhost:2380 clientURLs=http://localhost:2379 isLeader=true
```
- --write-out table
- --endpoints=http://localhost:2379

3、更新成员
- 更新 client URLs
  - 只需要使用更新后的 client URL 标记（即 --advertise-client-urls）或者环境变量来重启这个成员（ETCD_ADVERTISE_CLIENT_URLS）。重启后的成员将自行发布更新后的 URL，错误更新的 client URL 将不会影响 etcd 集群的健康。
- 更新 peer URLs
```
#查询所有的集群成员
$ etcdctl --endpoints=http://localhost:22379 member list -w table
+------------------+---------+--------+------------------------+------------------------+------------+
|        ID        | STATUS  |  NAME  |       PEER ADDRS       |      CLIENT ADDRS      | IS LEARNER |
+------------------+---------+--------+------------------------+------------------------+------------+
| 8211f1d0f64f3269 | started | infra1 | http://127.0.0.1:12380 | http://127.0.0.1:12379 |      false |
| 91bc3c398fb3c146 | started | infra2 | http://127.0.0.1:22380 | http://127.0.0.1:22379 |      false |
| fd422379fda50e48 | started | infra3 | http://127.0.0.1:32380 | http://127.0.0.1:32379 |      false |
+------------------+---------+--------+------------------------+------------------------+------------+

#通过集群id修改peer addrs地址
$ etcdctl --endpoints=http://localhost:12379 member update 8211f1d0f64f3269 --peer-urls=http://127.0.0.1:2380
Member 8211f1d0f64f3269 updated in cluster ef37ad9dc622a7c4

#查看修改后的结果
$ etcdctl --endpoints=http://localhost:22379  member list -w table
+------------------+---------+--------+------------------------+------------------------+------------+
|        ID        | STATUS  |  NAME  |       PEER ADDRS       |      CLIENT ADDRS      | IS LEARNER |
+------------------+---------+--------+------------------------+------------------------+------------+
| 8211f1d0f64f3269 | started | infra1 |  http://127.0.0.1:2380 | http://127.0.0.1:12379 |      false |
| 91bc3c398fb3c146 | started | infra2 | http://127.0.0.1:22380 | http://127.0.0.1:22379 |      false |
| fd422379fda50e48 | started | infra3 | http://127.0.0.1:32380 | http://127.0.0.1:32379 |      false |
+------------------+---------+--------+------------------------+------------------------+------------+

```


4、删除集群中存在的节点
```
$ etcdctl --endpoints=http://localhost:2379 member remove 8e9e05c52164694d
Removed member 8e9e05c52164694d from cluster
```

5、向集群中新加节点
```
$ etcdctl --endpoints=http://localhost:2379 member add etcd3 --peer-urls=http://192.168.1.100:2380
Added member named etcd3 with ID 8e9e05c52164694d to cluster
ETCD_NAME="etcd3"
ETCD_INITIAL_CLUSTER="etcd1=http://localhost:12380,etcd2=http://127.0.0.1:22380,etcd3=http://127.0.0.1:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://localhost:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

10)etcd 网关模式
---
1、启动 etcd 网关，以通过 etcd gateway 命令代理这些静态端点
```
$ etcd gateway start --endpoints=http://192.168.10.7:2379,http://192.168.10.8:2379,http://192.168.10.9:2379 –listen-addr=192.168.10.7:12379

$ETCDCTL_API=3 etcdctl --endpoints=192.168.10.7:12379 put foo bar
$ETCDCTL_API=3 etcdctl --endpoints=192.168.10.7:12379 get foo
```
- –listen-addr 绑定的接口和端口，用于接受客户端请求，默认配置为 127.0.0.1:23790；
- –retry-delay 重试连接到失败的端点延迟时间。默认为 1m0s。需要注意的是，值的后面标注单位，类似123的设置不合法，命令行会出现参数不合法。

2、在启动时指定自定义的前缀___grpc_proxy_endpoint来注册gRPC代理
```
$ etcd grpc-proxy start --endpoints=localhost:12379 \
--listend-addr=172.0.0.1:23790 \
--advertise-client-url=127.0.0.1:23790 \
--resolver-prefix="___grpc_proxy_endpoint" \
--resolver-ttl=60

$ etcd grpc-proxy start --endpoints=localhost:12379 \
--listend-addr=172.0.0.1:23791 \
--advertise-client-url=127.0.0.1:23791 \
--resolver-prefix="___grpc_proxy_endpoint" \
--resolver-ttl=60

$ ETCDCTL_API=3 etcdctl --endpoints=http://localhost:23790 member list --write-out table
+-------+----------+-----------------------+------------+------------------+---------------+
|   ID  | STSTUS   |           NAME        | PEER ADDRS | CLIENT ADDRS     | IS LEARNER    |
+-------+----------+-----------------------+------------+------------------+---------------+
|     0 | started  | localhost.localdomain |            | 127.0.0.1:23791  |         false |
|-------+----------+-----------------------+------------+------------------+---------------+
|     0 | started  | localhost.localdomain |            | 127.0.0.1:23790  |         false |
+-------+----------+-----------------------+------------+------------------+---------------+
```

11）命名空间的实现
---
1、当给代理提供标志--namespace时，所有进入代理的客户端请求都将转换为在键上具有用户定义的前缀
```
$ ./etcd grpc-proxy start --endpoints=localhost:12379 \
>   --listen-addr=127.0.0.1:23790 \
>   --namespace=my-prefix/
{"level":"info","ts":"2020-12-13T01:53:16.875+0800","caller":"etcdmain/grpc_proxy.go:320","msg":"listening for gRPC proxy client requests","address":"127.0.0.1:23790"}
{"level":"info","ts":"2020-12-13T01:53:16.876+0800","caller":"etcdmain/grpc_proxy.go:218","msg":"started gRPC proxy","address":"127.0.0.1:23790"}


$ ETCDCTL_API=3 etcdctl --endpoints=localhost:23790 put my-key abc
# OK

$ ETCDCTL_API=3 etcdctl --endpoints=localhost:23790 get my-key
# my-key
# abc

$ ETCDCTL_API=3 etcdctl --endpoints=localhost:2379 get my-prefix/my-key
# my-prefix/my-key
# abc
```
- 使用 proxy 的命名空间即可实现 etcd 键空间分区

12）指标与健康检查接口
---
1、gRPC 代理为--endpoints定义的 etcd 成员公开了/health和 Prometheus 的/metrics接口
```
curl 192.168.10.7:12379/metrics
curl 192.168.10.7:12379/health
```

2、指定监听的metric地址
```
$ ./etcd grpc-proxy start \
  --endpoints http://localhost:12379 \
  --metrics-addr http://0.0.0.0:6633 \
  --listen-addr 127.0.0.1:23790 \
```

13）TLS 加密的代理
---
```
$ ETCDCTL_API=3 etcdctl --endpoints=http://localhost:2379 endpoint status
# works

$ ETCDCTL_API=3 etcdctl --endpoints=https://localhost:2379 \
--cert=client.crt \
--key=client.key \
--cacert=ca.crt \
endpoint status
```

示例
---
```
# 设置一个key值
[root@etcd-0-8 ~]# etcdctl set /msg "hello k8s"
hello k8s

# 获取key的值
[root@etcd-0-8 ~]# etcdctl get /msg
hello k8s

# 获取key值的详细信息
[root@etcd-0-8 ~]# etcdctl -o extended get /msg
Key: /msg
Created-Index: 12
Modified-Index: 12
TTL: 0
Index: 12

hello k8s

# 获取不存在的key回报错
[root@etcd-0-8 ~]# etcdctl get /xxzx
Error: 100: Key not found (/xxzx) [12]

# 设置key的ttl，过期后会被自动删除
[root@etcd-0-8 ~]# etcdctl set /testkey "tmp key test" --ttl 5
tmp key test
[root@etcd-0-8 ~]# etcdctl get /testkey
Error: 100: Key not found (/testkey) [14]

# key 替换操作
[root@etcd-0-8 ~]# etcdctl get /msg
hello k8s
[root@etcd-0-8 ~]# etcdctl set --swap-with-value "hello k8s" /msg "goodbye"
goodbye
[root@etcd-0-8 ~]# etcdctl get /msg
goodbye

# mk 仅当key不存在时创建(set对同一个key会覆盖)
[root@etcd-0-8 ~]# etcdctl get /msg
goodbye
[root@etcd-0-8 ~]# etcdctl mk /msg "mktest"
Error: 105: Key already exists (/msg) [18]
[root@etcd-0-8 ~]# etcdctl mk /msg1 "mktest"
mktest

# 创建自排序的key
[root@etcd-0-8 ~]# etcdctl mk --in-order /queue s1
s1
[root@etcd-0-8 ~]# etcdctl mk --in-order /queue s2
s2
[root@etcd-0-8 ~]# etcdctl ls --sort /queue
/queue/00000000000000000021
/queue/00000000000000000022
[root@etcd-0-8 ~]# etcdctl get /queue/00000000000000000021
s1

# 更新key值
[root@etcd-0-8 ~]# etcdctl update /msg1 "update test"
update test
[root@etcd-0-8 ~]# etcdctl get /msg1
update test

# 更新key的ttl及值
[root@etcd-0-8 ~]# etcdctl update --ttl 5 /msg "aaa"
aaa

# 创建目录
[root@etcd-0-8 ~]# etcdctl mkdir /testdir

# 删除空目录
[root@etcd-0-8 ~]# etcdctl mkdir /test1
[root@etcd-0-8 ~]# etcdctl rmdir /test1

# 删除非空目录
[root@etcd-0-8 ~]# etcdctl get /testdir
/testdir: is a directory
[root@etcd-0-8 ~]#
[root@etcd-0-8 ~]# etcdctl rm --recursive /testdir

# 列出目录内容
[root@etcd-0-8 ~]# etcdctl ls /
/tmp
/msg1
/queue
[root@etcd-0-8 ~]# etcdctl ls /tmp
/tmp/a
/tmp/b

# 递归列出目录的内容
[root@etcd-0-8 ~]# etcdctl ls --recursive /
/msg1
/queue
/queue/00000000000000000021
/queue/00000000000000000022
/tmp
/tmp/b
/tmp/a

# 监听key，当key发生改变的时候打印出变化
[root@etcd-0-8 ~]# etcdctl watch /msg1
xxx

[root@VM_0_17_centos ~]# etcdctl update /msg1 "xxx"
xxx

# 监听某个目录，当目录中任何 node 改变的时候，都会打印出来
[root@etcd-0-8 ~]# etcdctl watch --recursive /
[update] /msg1
xxx

[root@VM_0_17_centos ~]# etcdctl update /msg1 "xxx"
xxx

# 一直监听，除非 `CTL + C` 导致退出监听
[root@etcd-0-8 ~]# etcdctl watch --forever /

# 监听目录，当发生变化时执行一条命令
[root@etcd-0-8 ~]# etcdctl exec-watch --recursive / -- sh -c "echo change"
change

# backup
[root@etcd-0-14 ~]# etcdctl backup --data-dir /data/app/etcd --backup-dir /root/etcd_backup
2019-12-04 10:25:16.113237 I | ignoring EntryConfChange raft entry
2019-12-04 10:25:16.113268 I | ignoring EntryConfChange raft entry
2019-12-04 10:25:16.113272 I | ignoring EntryConfChange raft entry
2019-12-04 10:25:16.113293 I | ignoring member attribute update on /0/members/2d2e457c6a1a76cb/attributes
2019-12-04 10:25:16.113299 I | ignoring member attribute update on /0/members/d2d2e9fc758e6790/attributes
2019-12-04 10:25:16.113305 I | ignoring member attribute update on /0/members/56e0b6dad4c53d42/attributes
2019-12-04 10:25:16.113310 I | ignoring member attribute update on /0/members/56e0b6dad4c53d42/attributes
2019-12-04 10:25:16.113314 I | ignoring member attribute update on /0/members/2d2e457c6a1a76cb/attributes
2019-12-04 10:25:16.113319 I | ignoring member attribute update on /0/members/d2d2e9fc758e6790/attributes
2019-12-04 10:25:16.113384 I | ignoring member attribute update on /0/members/56e0b6dad4c53d42/attributes

# 使用v3版本
[root@etcd-0-14 ~]# export ETCDCTL_API=3
[root@etcd-0-14 ~]# etcdctl --endpoints="http://172.16.0.8:2379,http://172.16.0.14:2379,http://172.16.0.17:2379" snapshot save mysnapshot.db
Snapshot saved at mysnapshot.db
[root@etcd-0-14 ~]# etcdctl snapshot status mysnapshot.db -w json
{"hash":928285884,"revision":0,"totalKey":5,"totalSize":20480}
```

总结
===
- etcd 默认只保存 1000 个历史事件，所以不适合有大量更新操作的场景，这样会导致数据的丢失。etcd 典型的应用场景是配置管理和服务发现，这些场景都是读多写少的。
- 相比于 zookeeper，etcd 使用起来要简单很多。不过要实现真正的服务发现功能，etcd 还需要和其他工具（比如 registrator、confd 等）一起使用来实现服务的自动注册和更新。
- 目前 etcd 还没有图形化的工具。


键值对读写操作
===
1、 /v3/kv/put接口，将键值对写入到etcd
```
$ curl -L http://localhost:2379/v3/kv/put \
  -X POST -d '{"key": "Zm9v", "value": "YmFy"}'

# 输出结果如下：
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"16","raft_term":"9"}}
```
- 键Zm9v，值YmFy。键值对经过base64编码，实际写入的键值对为foo:bar

2、 /v3/kv/range接口，来读取刚写入的键值对
```
$ curl -L http://localhost:2379/v3/kv/range \
  -X POST -d '{"key": "Zm9v"}'

# 输出结果如下：
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"16","raft_term":"9"},"kvs":[{"key":"Zm9v","create_revision":"13","mod_revision":"16","version":"4","value":"YmFy"}],"count":"1"}
```

3、获取前缀为指定值的键值对时，可以使用如下请求
```
$ curl -L http://localhost:2379/v3/kv/range \
  -X POST -d '{"key": "Zm9v", "range_end": "Zm9w"}'

# 输出结果如下：
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"16","raft_term":"9"},"kvs":[{"key":"Zm9v","create_revision":"13","mod_revision":"16","version":"4","value":"YmFy"}],"count":"1"}
```

4、/v3/watch接口来监测keys，watch刚写入的"Zm9v"请求
```
$ curl -N http://localhost:2379/v3/watch \
  -X POST -d '{"create_request": {"key":"Zm9v"} }' &

# 输出结果如下：
{"result":{"header":{"cluster_id":"12585971608760269493","member_id":"13847567121247652255","revision":"1","raft_term":"2"},"created":true}}
```

发起一个请求，用以更新该键值
```
$ curl -L http://localhost:2379/v3/kv/put \
  -X POST -d '{"key": "Zm9v", "value": "YmFy"}' >/dev/null 2>&1
```

etcd 事务的实现
---
1、通过 /v3/kv/txn 接口发起一个事务
```
# 查询键值对的版本
$ curl -L http://localhost:2379/v3/kv/range   -X POST -d '{"key": "Zm9v"}'
#响应结果
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"20","raft_term":"9"},"kvs":[{"key":"Zm9v","create_revision":"13","mod_revision":"20","version":"8","value":"YmFy"}],"count":"1"}
# 事务，对比指定键值对的创建版本

$ curl -L http://localhost:2379/v3/kv/txn \
  -X POST \
  -d '{"compare":[{"target":"CREATE","key":"Zm9v","createRevision":"13"}],"success":[{"requestPut":{"key":"Zm9v","value":"YmFy"}}]}'
 #响应结果
 {"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"20","raft_term":"9"},"succeeded":true,"responses":[{"response_put":{"header":{"revision":"20"}}}]}
```

2、对比指定键值对版本的事务
```
# 事务，对比指定键值对的版本
$ curl -L http://localhost:2379/v3/kv/txn \
  -X POST \
  -d '{"compare":[{"version":"8","result":"EQUAL","target":"VERSION","key":"Zm9v"}],"success":[{"requestRange":{"key":"Zm9v"}}]}'
 #响应结果
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"6","raft_term":"3"},"succeeded":true,"responses":[{"response_range":{"header":{"revision":"6"},"kvs":[{"key":"Zm9v","create_revision":"2","mod_revision":"6","version":"4","value":"YmF6"}],"count":"1"}}]}
```

HTTP 请求的安全认证
---
1、通过 /v3/auth 接口设置认证
```
#1、创建 root 用户
$ curl -L http://localhost:2379/v3/auth/user/add -X POST -d '{"name": "root", "password": "123456"}'
#响应结果
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"20","raft_term":"9"}}

#2、创建 root 角色
curl -L http://localhost:2379/v3/auth/role/add -X POST -d '{"name": "root"}'
#响应结果	{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"20","raft_term":"9"}}

#3、为 root 用户授予角色
curl -L http://localhost:2379/v3/auth/user/grant -X POST -d '{"user": "root", "role": "root"}'
#响应结果{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"20","raft_term":"9"}}

#4、开启权限
$ curl -L http://localhost:2379/v3/auth/enable -X POST -d '{}'
#响应结果 {"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"20","raft_term":"9"}}
```

2、使用 /v3/auth/authenticate API 接口对 etcd 进行身份验证以获取身份验证令牌
```
# 获取 root 用户的认证令牌
$ curl -L http://localhost:2379/v3/auth/authenticate \
  -X POST -d '{"name": "root", "password": "123456"}'
#响应结果
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"21","raft_term":"9"},"token":"DhRvXkWhOkINVQXI.57"}
```
- 请求获取到 token 的值为 DhRvXkWhOkINVQXI.57

3、设置请求的头部 Authorization 为刚刚获取到的身份验证令牌，以使用身份验证凭据设置 key 值
```
$ curl -L http://localhost:2379/v3/kv/put \
  -H 'Authorization : DhRvXkWhOkINVQXI.57' \
  -X POST -d '{"key": "Zm9v", "value": "YmFy"}'
#响应结果
{"header":{"cluster_id":"14841639068965178418","member_id":"10276657743932975437","revision":"21","raft_term":"9"}}
```
