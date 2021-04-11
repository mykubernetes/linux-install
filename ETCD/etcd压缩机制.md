压缩机制
===
Etcd作为 KV 存储，会为每个 key 都保留历史版本，比如用于发布回滚、配置历史等。

对 demo 写入值为 101，然后更为为 102，103。-w json 可以输出这次写入的 revision
```
etcdctl put demo 101 -w json
etcdctl put demo 102 -w json
etcdctl put demo 103 -w json

返回类似：
{"header":{"cluster_id":4871617780647557296,"member_id":3135801277950388570,"revision":434841,"raft_term":2}}
```

取值：
```
etcdctl get demo 默认 --rev=0即最新值=103


如果要拿到历史值，需要指定 rev 版本
etcdctl get demo  --rev=434841，得到 102
```

观察 key的变化:
```
etcdctl watch  foo --rev=0
```
历史版本越多，存储空间越大，性能越差，直到etcd到达空间配额限制的时候，etcd的写入将会被禁止变为只读，影响线上服务，因此这些历史版本需要进行压缩。

数据压缩并不是清理现有数据，只是对给定版本之前的历史版本进行清理，清理后数据的历史版本将不能访问，但不会影响现有最新数据的访问。

手动压缩
```
etcdctl compact 5。 在 5 之前的所有版本都会被压缩，不可访问

如果 etcdctl get --rev=4 demo，会报错
Error:  rpc error: code = 11 desc = etcdserver: mvcc: required revision has been compacted
```

手动操作毕竟繁琐，Etcd提供了启动参数 “–auto-compaction-retention” 支持自动压缩 key 的历史版本，以小时为单位

```
etcd --auto-compaction-retention=1 代表 1 小时压缩一次
```

v3.3之上的版本有这样一个规则：

如果配置的值小于1小时，那么就严格按照这个时间来执行压缩；如果配置的值大于1小时，会每小时执行压缩，但是采样还是按照保留的版本窗口依然按照用户指定的时间周期来定。


k8s api-server支持定期执行压缩操作，其参数里面有这样的配置：
```
- etcd-compaction-interval 即默认 5 分钟一次
```

可以在 etcd 中看到这样的压缩日志，5 分钟一次：
```
Apr 25 11:05:20  etcd[2195]: store.index: compact 433912
Apr 25 11:05:20  etcd[2195]: finished scheduled compaction at 433912 (took 1.068846ms)
Apr 25 11:10:20  etcd[2195]: store.index: compact 434487
Apr 25 11:10:20  etcd[2195]: finished scheduled compaction at 434487 (took 1.019571ms)
Apr 25 11:15:20  etcd[2195]: store.index: compact 435063
Apr 25 11:15:20  etcd[2195]: finished scheduled compaction at 435063 (took 1.659541ms)
Apr 25 11:20:20  etcd[2195]: store.index: compact 435637
Apr 25 11:20:20  etcd[2195]: finished scheduled compaction at 435637 (took 1.676035ms)
Apr 25 11:25:20  etcd[2195]: store.index: compact 436211
Apr 25 11:25:20  etcd[2195]: finished scheduled compaction at 436211 (took 1.17725ms)
```


碎片整理
===
进行压缩操作之后，旧的revision被清理，会产生内部的碎片，内部碎片是指空闲状态的，能被etcd使用但是仍然消耗存储空间的磁盘空间，去碎片化实际上是将存储空间还给文件系统。

```
# defrag命令默认只对本机有效
etcdctl defrag 

# 如果带参数--endpoints，可以指定集群中的其他节点也做整理
etcdctl defrag --endpoints
```
如果etcd没有运行，可以直接整理目录中db的碎片

```
etcdctl defrag --data-dir <path-to-etcd-data-dir>
```
碎片整理会阻塞对etcd的读写操作，因此偶尔一次大量数据的defrag最好逐台进行，以免影响集群稳定性。

etcdctl执行后的返回 Finished defragmenting etcd member[https://127.0.0.1:2379]
