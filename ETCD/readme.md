etcdctl 命令
===
```
ETCDCTL_API=3 ./etcdctl --endpoints=https://0:2379,https://1:2379,https://2:2379 --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem endpoint status --write-out=table
```

etcd 版本为 3.4，可以ETCDCTL_API=3，或ETCDCTL_API=2，默认情况下用的就是v3了，可以不用声明ETCDCTL_API

- version: 查看版本
- member list: 查看节点状态，learner 情况
- endpoint status: 节点状态，leader 情况
- endpoint health: 健康状态与耗时
- alarm list: 查看警告，如存储满时会切换为只读，产生 alarm
- alarm disarm：清除所有警告
- set app demo: 写入
- get app: 获取
- update app demo1:更新
- rm app: 删除
- mkdir demo 创建文件夹
- rmdir dir 删除文件夹
- backup 备份
- compaction： 压缩
- defrag：整理碎片
- watch key : 监测 key 变化
- get / –prefix –keys-only: 查看所有 key
- –write-out=table : 可以用表格形式输出更清晰，注意有些输出并不支持tables


配置调优
---
一般情况下，etcd 默认模式不会有什么问题，影响 etcd 的因素一般是网络和存储延时，尤其是跨地域、跨机房的集群。

网络延迟
---
因为 leader 和 member 之间有频繁的心跳和数据复制，因此网络拥塞影响会很大，当然长时间失败会无响应会导致 etcd 集群不可用。一般是将 etcd 集群规划在一个地域或一个机房内，并且使用tc提高带宽和优先级。

心跳间隔
---
etcd 的一致性协议依赖两个时间参数。

- –heartbeat-interval：心跳间隔，即 leader 通知member 并保证自己 leader 地位的心跳，默认是 100ms，这个应该设置为节点间的 RTT 时间。
- –election-timeout：选举超时时间，即 member 多久没有收到 leader 的回应，就开始自己竞选 leader，默认超时时间为 1s

默认值有可能不满足你的需求，如你的网络延迟较高，RTT 大于 100，就应该按真实延迟来，比如这个 issue，官方文档也对心跳的设置给了详细的解释和配置建议：https://github.com/etcd-io/etcd/blob/master/Documentation/tuning.md

如果心跳间隔太短，则 etcd 将发送不必要的消息，从而增加 CPU 和网络资源的使用。另一方面，心跳间隔过长会导致选举超时。较高的选举超时时间需要更长的时间来检测领导者失败。测量往返时间（RTT）的最简单方法是使用PING。

磁盘 IO
---
除了网络延迟，磁盘 IO 也严重影响 etcd 的稳定性， etcd需要持久化数据，对磁盘速度很敏感，强烈建议对 ETCD 的数据挂 SSD。

另外，要确认机器上没有其他高 IO 操作，否则会影响 etcd 的 fsync，导致 etcd 丢失心跳，leader更换等。一般磁盘有问题时，报错的关键字类似于：

```
took too long (1.483848046s) to execute
etcdserver: failed to send out heartbeat on time
```
磁盘 IO 可以通过监控手段提前发现，并预防这类问题的出现

快照
---
etcd的存储分为内存存储和持久化（硬盘）存储两部分，内存中的存储除了顺序化的记录下所有用户对节点数据变更的记录外，还会对用户数据进行索引、建堆等方便查询的操作。而持久化则使用预写式日志（WAL：Write Ahead Log）进行记录存储。

在WAL的体系中，所有的数据在提交之前都会进行日志记录。在etcd的持久化存储目录中，有两个子目录。一个是WAL，存储着所有事务的变化记录；另一个则是snapshot，用于存储某一个时刻etcd所有目录的数据。通过WAL和snapshot相结合的方式，etcd可以有效的进行数据存储和节点故障恢复等操作。

既然有了WAL实时存储了所有的变更，为什么还需要snapshot呢？随着使用量的增加，WAL存储的数据会暴增，为了防止磁盘很快就爆满，etcd默认每10000条记录做一次snapshot，经过snapshot以后的WAL文件就可以删除。而通过API可以查询的历史etcd操作默认为1000条。

客户端优化
---
etcd 的客户端应该避免一些频繁操作或者大对象操作，如：
- put 时避免大 value，精简再精简（例如 k8s 中 crd 使用）
- 避免创建频繁变化的 kv（例如 k8s 中 node 信息汇报），如 node-lease
- 避免创建大量 lease，尽量选择复用（例如 k8s 中 event 数据管理）
- 合理利用 apiserver 中的缓存，避免大量请求打到 etcd上，如集群异常恢复后大量 pod同步

其他
---
你可能还看到过lease revoke 、boltdb、内存优化等方式，这些已经合入了最新的 etcd3.4版本，因此选择最新的 release 版本也是提高稳定性的一种方式。
