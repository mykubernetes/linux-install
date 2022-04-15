# 一 etcd简介

etcd是一种高度一致的分布式键值存储，它提供了一种可靠的方式来存储需要由分布式系统或机器集群访问的数据。

etcd内部采用raft协议作为一致性算法，etcd基于go语言实现。

官方网站：https://etcd.io/

github地址：https://github.com/etcd-io/etcd

官方文档：https://etcd.io/docs/v3.5/

# 二 etcd特性

- 完全复制：集群中的每个节点都可以使用完整的存档。
- 高可用性：etcd可用于避免硬件的单点故障或网络问题。
- 一致性：每次读取都会返回跨多主机的最新写入。
- 简单：包括一个定义良好、面向用户的API。
- 安全：实现了带可有可选的客户端证书身份验证的自动化TLS。
- 快速：每秒10000次写入的基准速度。
- 可靠：使用Raft算法实现了存储的合理分布etcd的工作原理。


# 三 etcd启动参数
```
root@k8s-etcd-01:~# cat /etc/systemd/system/etcd.service 
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd
ExecStart=/usr/local/bin/etcd \
  --name=etcd-192.168.174.103 \
  --cert-file=/etc/kubernetes/ssl/etcd.pem \
  --key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --peer-cert-file=/etc/kubernetes/ssl/etcd.pem \
  --peer-key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --initial-advertise-peer-urls=https://192.168.174.103:2380 \
  --listen-peer-urls=https://192.168.174.103:2380 \
  --listen-client-urls=https://192.168.174.103:2379,http://127.0.0.1:2379 \
  --advertise-client-urls=https://192.168.174.103:2379 \
  --initial-cluster-token=etcd-cluster-0 \
  --initial-cluster=etcd-192.168.174.103=https://192.168.174.103:2380,etcd-192.168.174.104=https://192.168.174.104:2380,etcd-192.168.174.105=https://192.168.174.105:2380 \
  --initial-cluster-state=new \
  --data-dir=/var/lib/etcd \
  --wal-dir= \
  --snapshot-count=50000 \
  --auto-compaction-retention=1 \
  --auto-compaction-mode=periodic \
  --max-request-bytes=10485760 \
  --quota-backend-bytes=8589934592
Restart=always
RestartSec=15
LimitNOFILE=65536
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```

# 四 查看etcd集群成员信息

etcd有多个不同的API访问版本，v1版本已经废弃。etcd v2和etcd v3本质上是共享同一套raft协议代码的两个独立的应用，接口不一样，存储不一样，数据互相隔离。也就是说如果从etcd v2升级到etcd v3。原来v2的数据还是只能用v2接口访问，v3创建的数据也只能通过v3访问。

## 4.1 etcdctl使用帮助
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl --help
NAME:
	etcdctl - A simple command line client for etcd3.

USAGE:
	etcdctl [flags]

VERSION:
	3.5.0

API VERSION:
	3.5


COMMANDS:
	alarm disarm     解除所有警报
	alarm list       列出所有警报
	auth disable     禁用身份验证
	auth enable      启用身份验证
	auth status      返回认证状态
	check datascale  检查在给定服务器端点上为不同工作负载保存数据的内存使用情况。
	check perf       查看etcd集群的性能
	compaction       在 etcd 中压缩事件历史
	defrag           对具有给定端点的 etcd 成员的存储进行碎片整理
	del              删除指定的键或键范围 [key, range_end)
	elect            观察并参与leader选举
	endpoint hashkv  在 --endpoints 中打印每个端点的 KV 历史哈希
	endpoint health  检查`--endpoints`标志中指定的端点的健康状况
	endpoint status  打印出`--endpoints`标志中指定的端点的状态
	get              获取键或键范围
	help             有关任何命令的帮助
	lease grant      创建租赁
	lease keep-alive 保持租约有效（续订）
	lease list       列出所有活动租用
	lease revoke     撤销租约
	lease timetolive 获取租约信息
	lock             获取一个命名锁
	make-mirror      在目标 etcd 集群上创建镜像
	member add       添加一个成员到集群中
	member list      列出集群中的所有成员
	member promote   在集群中提升一个无投票权的成员
	member remove    从集群中删除一个成员
	member update    更新集群中的一个成员
	move-leader      将领导权转移到另一个 etcd 集群成员。
	put              将给定的密钥放入商店
	role add         添加一个新角色
	role delete      删除角色
	role get         获取角色的详细信息
	role grant-permission 授予一个角色的密钥
	role list       列出所有角色
	role revoke-permission 从角色中撤销密钥
	snapshot restore 将 etcd 成员快照恢复到 etcd 目录
	snapshot save   将 etcd 节点后端快照存储到给定文件
	snapshot status	 [已弃用] 获取给定文件的后端快照状态
	txn Txn         处理一个事务中的所有请求
	user add        添加一个新用户
	user delete     删除用户
	user get        获取用户的详细信息
	user grant-role 授予用户角色
	user list       列出所有用户
	user passwd     修改用户密码
	user revoke-role 撤销用户的角色
	version         打印 etcdctl 的版本
	watch           在键或前缀上观看事件流

选项：
      --cacert=""          使用此 CA 包验证启用 TLS 的安全服务器的证书
      --cert=""            使用此 TLS 证书文件识别安全客户端
      --command-timeout=5s 短时间运行命令超时（不包括拨号超时）
      --debug[=false]      启用客户端调试日志
      --dial-timeout=2s    客户端连接拨号超时
  -d, --discovery-srv=""   用于查询描述集群端点的 SRV 记录的域名
      --discovery-srv-name=""    使用 DNS 发现时要查询的服务名称
      --endpoints=[127.0.0.1:2379] gRPC 端点
  -h, --help[=false]       对 etcdctl 的帮助
      --hex[=false]        将字节字符串打印为十六进制编码的字符串
      --insecure-discovery[=true]        接受描述集群端点的不安全 SRV 记录
      --insecure-skip-tls-verify[=false] 跳过服务器证书验证（注意：此选项应仅用于测试目的）
      --insecure-transport[=true]        禁用客户端连接的传输安全
      --keepalive-time=2s                客户端连接的保活时间
      --keepalive-timeout=6s             客户端连接的 keepalive 超时
      --key=""             使用此 TLS 密钥文件识别安全客户端
      --password=""        用于身份验证的密码（如果使用此选项，--user 选项不应包含密码）
      --user="" username[:password]      用于身份验证（如果未提供密码则提示）
  -w, --write-out="simple"               设置输出格式(fields, json, protobuf, simple, table)
```

## 4.2 查看成员命令格式
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl member  --help
NAME:
	member - Membership related commands

USAGE:
	etcdctl member <subcommand> [flags]

API VERSION:
	3.5


命令：
	add      添加一个成员到集群中
	list     列出集群中的所有成员
	promote  提升集群中的无投票权成员
	remove   从集群中删除一个成员
	update   更新集群中的一个成员

选项：
  -h, --help[=false] 成员帮助

全局选项：
      --cacert=""          使用此 CA 包验证启用 TLS 的安全服务器的证书
      --cert=""            使用此 TLS 证书文件识别安全客户端
      --command-timeout=5s 短时间运行命令超时（不包括拨号超时）
      --debug[=false]      启用客户端调试日志
      --dial-timeout=2s    客户端连接拨号超时
  -d, --discovery-srv=""   用于查询描述集群端点的 SRV 记录的域名
      --discovery-srv-name="" 使用 DNS 发现时要查询的服务名称
      --endpoints=[127.0.0.1:2379] gRPC 端点
      --hex[=false]          将字节字符串打印为十六进制编码的字符串
      --insecure-discovery[=true] 接受描述集群端点的不安全 SRV 记录
      --insecure-skip-tls-verify[=false] 跳过服务器证书验证（注意：此选项应仅用于测试目的）
      --insecure-transport[=true]        禁用客户端连接的传输安全
      --keepalive-time=2s                客户端连接的保活时间
      --keepalive-timeout=6s             客户端连接的 keepalive 超时
      --key=""                           使用此 TLS 密钥文件识别安全客户端
      --password=""                      用于身份验证的密码（如果使用此选项，--user 选项不应包含密码）
      --user="" username[:password]      用于身份验证（如果未提供密码则提示）
  -w, --write-out="simple"               设置输出格式(fields, json, protobuf, simple, table)
```

## 4.3 查看etcd成员心跳信息
```
root@k8s-etcd-01:~# export NODE_IPS="192.168.174.103 192.168.174.104 192.168.174.105"
root@k8s-etcd-01:~# for ip in ${NODE_IPS}; do ETCDCTL_API=3 etcdctl --endpoints=https://${ip}:2379  --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem   endpoint health; done
https://192.168.174.103:2379 is healthy: successfully committed proposal: took = 41.022164ms
https://192.168.174.104:2379 is healthy: successfully committed proposal: took = 50.092099ms
https://192.168.174.105:2379 is healthy: successfully committed proposal: took = 10.772432ms
```

## 4.4 查看etcd集群成员信息
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl --endpoints=https://192.168.174.104:2379  --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem  -w table member list
+------------------+---------+----------------------+------------------------------+------------------------------+------------+
|        ID        | STATUS  |         NAME         |          PEER ADDRS          |         CLIENT ADDRS         | IS LEARNER |
+------------------+---------+----------------------+------------------------------+------------------------------+------------+
| 1eb5eb9e512f1150 | started | etcd-192.168.174.104 | https://192.168.174.104:2380 | https://192.168.174.104:2379 |      false |
| 620a973f2f735d63 | started | etcd-192.168.174.105 | https://192.168.174.105:2380 | https://192.168.174.105:2379 |      false |
| 7094f5ff5dcb144b | started | etcd-192.168.174.103 | https://192.168.174.103:2380 | https://192.168.174.103:2379 |      false |
+------------------+---------+----------------------+------------------------------+------------------------------+------------+
```

## 3.5 查看etcd集群节点信息
```
root@k8s-etcd-01:~# for ip in ${NODE_IPS}; do ETCDCTL_API=3 etcdctl --endpoints=https://${ip}:2379  --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem   -w table endpoint status; done
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|           ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.174.103:2379 | 7094f5ff5dcb144b |   3.5.0 |  3.9 MB |     false |      false |        15 |      79807 |              79807 |        |
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|           ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.174.104:2379 | 1eb5eb9e512f1150 |   3.5.0 |  3.9 MB |     false |      false |        15 |      79807 |              79807 |        |
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|           ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.174.105:2379 | 620a973f2f735d63 |   3.5.0 |  4.0 MB |      true |      false |        15 |      79807 |              79807 |        |
+------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

# 五 查看etcd数据信息


以k8s集群数据为例

## 5.1 查看etcd集群key

### 5.1.1 查看pod信息
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get / --prefix --keys-only |grep pods
/registry/pods/kube-system/calico-kube-controllers-6f8794d6c4-6hjzq
/registry/pods/kube-system/calico-node-22pk5
/registry/pods/kube-system/calico-node-8lzw4
/registry/pods/kube-system/calico-node-c2f2q
/registry/pods/kube-system/calico-node-pbfcs
/registry/pods/kube-system/calico-node-qmn6j
/registry/pods/kube-system/calico-node-smw9x
/registry/pods/kube-system/coredns-8568fcb45d-ghnrd
/registry/pods/kubernetes-dashboard/dashboard-metrics-scraper-c5f49cc44-lhr2n
/registry/pods/kubernetes-dashboard/kubernetes-dashboard-688994654d-mt7nl
```

### 5.1.2 查看namespace信息
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get / --prefix --keys-only |grep namespaces
/registry/namespaces/default
/registry/namespaces/kube-node-lease
/registry/namespaces/kube-public
/registry/namespaces/kube-system
/registry/namespaces/kubernetes-dashboard
```

### 5.1.3 查看控制器信息
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get / --prefix --keys-only |grep deployments
/registry/deployments/kube-system/calico-kube-controllers
/registry/deployments/kube-system/coredns
/registry/deployments/kubernetes-dashboard/dashboard-metrics-scraper
/registry/deployments/kubernetes-dashboard/kubernetes-dashboard
```

### 5.1.4 查看calico组件信息
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get / --prefix --keys-only |grep calico
/calico/ipam/v2/assignment/ipv4/block/10.200.151.128-26
/calico/ipam/v2/assignment/ipv4/block/10.200.154.192-26
/calico/ipam/v2/assignment/ipv4/block/10.200.183.128-26
/calico/ipam/v2/assignment/ipv4/block/10.200.44.192-26
/calico/ipam/v2/assignment/ipv4/block/10.200.89.128-26
/calico/ipam/v2/assignment/ipv4/block/10.200.95.0-26
/calico/ipam/v2/handle/ipip-tunnel-addr-k8s-master-01
/calico/ipam/v2/handle/ipip-tunnel-addr-k8s-master-02
/calico/ipam/v2/handle/ipip-tunnel-addr-k8s-master-03
/calico/ipam/v2/handle/ipip-tunnel-addr-k8s-node-01
/calico/ipam/v2/handle/ipip-tunnel-addr-k8s-node-02
/calico/ipam/v2/handle/ipip-tunnel-addr-k8s-node-03
```

## 4.2 查看指定key
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get /calico/ipam/v2/assignment/ipv4/block/10.200.151.128-26
/calico/ipam/v2/assignment/ipv4/block/10.200.151.128-26
{"cidr":"10.200.151.128/26","affinity":"host:k8s-master-01","allocations":[0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"unallocated":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63],"attributes":[{"handle_id":"ipip-tunnel-addr-k8s-master-01","secondary":{"node":"k8s-master-01","type":"ipipTunnelAddress"}}],"deleted":false}
```

# 六 etcd 数据watch机制

基于不断检测数据，发生变化就主动触发通知客户端，etcd v3的watch机制支持watch某个固定的key，也支持watch一个范围。

相比etcd v2，etcd v3的一些主要变化：
- 接口通过grpc提供rpc接口，放弃了v2的http接口，优势是长连接效率提升明显，缺点是使用不如以前方便，尤其对不方便维护长连接的场景。
- 废弃了原来目录结构，变成了纯粹的kv，用户可以通过前缀匹配模式模拟目录。
- 内存中不在保存value，同样的内存可以支持存储更多的key。
- watch机制更稳定，基本上可以通过watch机制实现数据的完全同步。
- 提供了批量操作以及事务机制，用户可以通过批量事务请求来实现etcd v2的cas机制（批量事务支持if条件判断）。

## 6.1 watch测试

### 6.1.1 etcd-01节点执行watch
```
root@k8s-etcd-01:~# ETCDTL_API=3 etcdctl watch /name/wgs
```
6.1.2 etcd-02节点写入数据
```
root@k8s-etcd-02:~# ETCDTL_API=3 etcdctl put /name/wgs wgs
OK
root@k8s-etcd-02:~# ETCDTL_API=3 etcdctl put /name/wgs wgs-01
OK
root@k8s-etcd-02:~# ETCDTL_API=3 etcdctl put /name/wgs wgs-02
OK
root@k8s-etcd-02:~# ETCDTL_API=3 etcdctl put /name/wgs wgs-03
OK
```

### 6.1.3 etcd-01观察数据变化
```
root@k8s-etcd-01:~# ETCDTL_API=3 etcdctl watch /name/wgs
PUT
/name/wgs
wgs
PUT
/name/wgs
wgs-01
PUT
/name/wgs
wgs-02
PUT
/name/wgs
wgs-03
```


# 七、etcd增删改查

1、添加数据
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl put /name "wgs"
OK
```

2、查询数据
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get  /name 
/name
wgs
```

3、修改数据
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl put  /name "wgs_update"
OK
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get  /name 
/name
wgs_update
```

4、删除数据
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl del  /name 
1
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl get  /name
```

# 八、etcd数据备份与还原

## 8.1 wal介绍

wal是write ahead log的缩写，顾名思义，也就是在执行真正的写操作之前先写一个日志，预写日志。

wal:存放预写式日志，最大的作用是记录了整个数据变化的全部历程。在etcd中,所有数据的修改在提交前，都要先写入wal中。

## 8.2 etcd 数据备份

8.2.1 查看etcd版本信息
```
root@k8s-etcd-01:~# etcdctl version
etcdctl version: 3.5.0
API version: 3.5
```

8.2.2 查看etcd v3版本备份帮助
```
root@k8s-etcd-01:~# etcdctl snapshot save --help
NAME:
	snapshot save - Stores an etcd node backend snapshot to a given file

USAGE:
	etcdctl snapshot save <filename> [flags]

OPTIONS:
  -h, --help[=false]	help for save

GLOBAL OPTIONS:
      --cacert=""				verify certificates of TLS-enabled secure servers using this CA bundle
      --cert=""					identify secure client using this TLS certificate file
      --command-timeout=5s			timeout for short running command (excluding dial timeout)
      --debug[=false]				enable client-side debug logging
      --dial-timeout=2s				dial timeout for client connections
  -d, --discovery-srv=""			domain name to query for SRV records describing cluster endpoints
      --discovery-srv-name=""			service name to query when using DNS discovery
      --endpoints=[127.0.0.1:2379]		gRPC endpoints
      --hex[=false]				print byte strings as hex encoded strings
      --insecure-discovery[=true]		accept insecure SRV records describing cluster endpoints
      --insecure-skip-tls-verify[=false]	skip server certificate verification (CAUTION: this option should be enabled only for testing purposes)
      --insecure-transport[=true]		disable transport security for client connections
      --keepalive-time=2s			keepalive time for client connections
      --keepalive-timeout=6s			keepalive timeout for client connections
      --key=""					identify secure client using this TLS key file
      --password=""				password for authentication (if this option is used, --user option shouldn't include password)
      --user=""					username[:password] for authentication (prompt if password is not supplied)
  -w, --write-out="simple"			set the output format (fields, json, protobuf, simple, table)
```

8.2.3 etcd v3版本数据手动备份
```
root@k8s-etcd-01:~# etcdctl snapshot save snapshot.db
{"level":"info","ts":1636787145.641446,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"snapshot.db.part"}
{"level":"info","ts":1636787145.6563053,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1636787145.6563435,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}
{"level":"info","ts":1636787145.6818144,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
{"level":"info","ts":1636787145.7401688,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"3.9 MB","took":"now"}
{"level":"info","ts":1636787145.7402475,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"snapshot.db"}
Snapshot saved at snapshot.db
```

8.2.4 etcd v3版本查看备份文件
```
root@k8s-etcd-01:~# etcdctl snapshot status snapshot.db
4a52e822, 79010, 2343, 19 MB
```

8.2.5 etcd v3版本数据自动备份
```
#!/bin/bash

source /etc/profile
DATE=`date +%Y-%m-%d_%H_%M_%S`
ETCDCTL_API=3 /usr/bin/etcdctl snaphost save /data/etcd-backup-dri/etcd-snapshot-${DATE}.db
```

## 8.3 etcd v3版本数据恢复

8.3.1 etcd v3版本数据恢复帮助
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl  snapshot restore --help
NAME:
	snapshot restore - Restores an etcd member snapshot to an etcd directory

USAGE:
	etcdctl snapshot restore <filename> [options] [flags]

DESCRIPTION:
	Moved to `etcdctl snapshot restore ...`

OPTIONS:
      --data-dir=""						Path to the data directory
  -h, --help[=false]						help for restore
      --initial-advertise-peer-urls="http://localhost:2380"	List of this member's peer URLs to advertise to the rest of the cluster
      --initial-cluster="default=http://localhost:2380"		Initial cluster configuration for restore bootstrap
      --initial-cluster-token="etcd-cluster"			Initial cluster token for the etcd cluster during restore bootstrap
      --name="default"						Human-readable name for this member
      --skip-hash-check[=false]					Ignore snapshot integrity hash value (required if copied from data directory)
      --wal-dir=""						Path to the WAL directory (use --data-dir if none given)

GLOBAL OPTIONS:
      --cacert=""				verify certificates of TLS-enabled secure servers using this CA bundle
      --cert=""					identify secure client using this TLS certificate file
      --command-timeout=5s			timeout for short running command (excluding dial timeout)
      --debug[=false]				enable client-side debug logging
      --dial-timeout=2s				dial timeout for client connections
  -d, --discovery-srv=""			domain name to query for SRV records describing cluster endpoints
      --discovery-srv-name=""			service name to query when using DNS discovery
      --endpoints=[127.0.0.1:2379]		gRPC endpoints
      --hex[=false]				print byte strings as hex encoded strings
      --insecure-discovery[=true]		accept insecure SRV records describing cluster endpoints
      --insecure-skip-tls-verify[=false]	skip server certificate verification (CAUTION: this option should be enabled only for testing purposes)
      --insecure-transport[=true]		disable transport security for client connections
      --keepalive-time=2s			keepalive time for client connections
      --keepalive-timeout=6s			keepalive timeout for client connections
      --key=""					identify secure client using this TLS key file
      --password=""				password for authentication (if this option is used, --user option shouldn't include password)
      --user=""					username[:password] for authentication (prompt if password is not supplied)
  -w, --write-out="simple"			set the output format (fields, json, protobuf, simple, table)
```

8.3.2 停止etcd服务
```
root@k8s-etcd-01:~# systemctl stop etcd
```

8.3.3 删除etcd存储数据目录
```
root@k8s-etcd-01:~# ls -l /var/lib/etcd/
total 4
drwx------ 4 root root 4096 Nov 13 14:42 member

root@k8s-etcd-01:~# rm -rf /var/lib/etcd
```

8.3.4 etcd v3版本数据恢复
```
root@k8s-etcd-01:~# ETCDCTL_API=3 etcdctl  snapshot restore snapshot.db --data-dir=/var/lib/etcd             # --data-dir将数据恢复到一个新的不存在的目录中
Deprecated: Use `etcdutl snapshot restore` instead.

2021-11-13T15:19:07+08:00	info	snapshot/v3_snapshot.go:251	restoring snapshot	{"path": "snapshot.db", "wal-dir": "/var/lib/etcd/member/wal", "data-dir": "/var/lib/etcd", "snap-dir": "/var/lib/etcd/member/snap", "stack": "go.etcd.io/etcd/etcdutl/v3/snapshot.(*v3Manager).Restore\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdutl/snapshot/v3_snapshot.go:257\ngo.etcd.io/etcd/etcdutl/v3/etcdutl.SnapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdutl/etcdutl/snapshot_command.go:147\ngo.etcd.io/etcd/etcdctl/v3/ctlv3/command.snapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/command/snapshot_command.go:128\ngithub.com/spf13/cobra.(*Command).execute\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:856\ngithub.com/spf13/cobra.(*Command).ExecuteC\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:960\ngithub.com/spf13/cobra.(*Command).Execute\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:897\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.Start\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/ctl.go:107\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.MustStart\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/ctl.go:111\nmain.main\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/main.go:59\nruntime.main\n\t/home/remote/sbatsche/.gvm/gos/go1.16.3/src/runtime/proc.go:225"}
2021-11-13T15:19:07+08:00	info	membership/store.go:119	Trimming membership information from the backend...
2021-11-13T15:19:07+08:00	info	membership/cluster.go:393	added member	{"cluster-id": "cdf818194e3a8c32", "local-member-id": "0", "added-peer-id": "8e9e05c52164694d", "added-peer-peer-urls": ["http://localhost:2380"]}
2021-11-13T15:19:07+08:00	info	snapshot/v3_snapshot.go:272	restored snapshot	{"path": "snapshot.db", "wal-dir": "/var/lib/etcd/member/wal", "data-dir": "/var/lib/etcd", "snap-dir": "/var/lib/etcd/member/snap"}
```
