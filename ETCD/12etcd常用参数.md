# Etcd 常用配置参数

Etcd 可以通过命令行选项和变量配置启动参数。命令行参数选项与环境变量命名的关系是命令行选项的小写字母转换成环境变量的大写字母加一个 "ETCD_" 前缀，形如：“--my-flag” 和 "ETCD_MY_FLAG"，这条规则适用于所有配置项。

## Member 相关参数项

Etcd Member 相关参数说明如表：

| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --name | ETCD_NAME | 识别该 member 的对人友好的名字 | default |  |
| --data-dir | ETCD_DATA_DIR | 数据目录的路径 | ${name}.etcd |  |
| --wal-dir | ETCD_WAL_DIR | WAL 文件专用目录 | "" | 如果该值设置，那么Etcd 就会将 WAL 文件写入该目录，而不是数据目录。 |
| --snapshot-count | ETCD_SNAPSHOT_COUNT | 触发一次磁盘快照的提交事务的次数 | 100000 |  |
| --heartbeat-interval | ETCD_HEARTBEAT_INTERVAL | Leader 心跳时间 | 100 | 单位: ms |
| --election-timeout | ETCD_ELECTION_TIMEOUT | 一次等待选举的超时时间 | 1000 | 单位: ms |
| --listen-peer-urls | ETCD_LISTEN_PEER_URLS | 集群节点之间通信监听的 URL | http://localhost:2380 | 如果指定 IP 是 0.0.0.0，那么 Etcd 会监听所有网卡的指定端口。 |
| --listen-client-urls | ETCD_LISTEN_CLIENT_URLS | 监听客户端请求的 URL | http://localhost:2379 | 如果指定 IP 是 0.0.0.0，那么 Etcd 会监听所有网卡的指定端口。 |
| --max-snapshots | ETCD_MAX_SNAPSHOTS | ETCD 保存的最大快照文件数 | 5 | 0 代表无限制。Windows 上无限制，但建议定期手动删除。 |
| --max-wals | ETCD_MAX_WALS | ETCD 保存的 WAL 最大文件数 | 5 | 0 代表无限制。Windows 上无限制，但建议定期手动删除。 |
| --cors | ETCD_CORS | 逗号分隔的跨域资源共享（CORS）报名单 | 空 | 0 代表无限制。Windows 上无限制，但建议定期手动删除。 |

Cluster 相关参数项
- 以 "--initial" 为前缀的选项用于一个 Member 最初的启动 过程和运行时，重启时则会被忽略。以 "--discovery" 为前缀的选项用于服务发现。Cluster 相关参数项如下表：

| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --initial-adver-tise-peer-urls | ETCD_INITIAL_ADVERTISE_PEER_URLS | 该 member 的 peer URL。这些地址用于 Etcd 数据在集群内进行交互 | http://localhost:2380 | 至少一个，必须能够对集群中的所有 member 均可路由，可以是域名
| --initial-cluster | ETCD_INITIAL_CLUSTER | 起始启动的集群配置 | default=http://localhost:2380 | key/value 形式，key 值每个节点 --name 选项的值
| --initial-cluster-state | ETCD_INITIAL_CLUSTER_STATE | 初始化集群状态 | new | 当静态启动或当 DNS 服务发现所有 member 都存在时设置成 new。设置成 existing 时，etcd 会尝试加入一个已经存在的集群。
| --initial-cluster-token | ETCD_INITIAL_CLUSTER_TOKEN | 集群初始化所使用的 Token 值，集群唯一 |  |  |
| --discovery | ETCD_DISCOVERY | 最初创建一个集群的服务发现 URL | 空 |  |
| --discovery-srv | ETCD_DISCOVERY_SRV | 最初创建一个集群的服务发现 DNS | 空 |  |
| --discovery-fallback | ETCD_DISCOVERY_ERY_FALLBACK | 服务发现失败时的行为：proxy 或 exit | proxy | proxy 只支持 v2 的 API |
| --discovery-proxy | ETCD_DISCOVERY_ERY_PROXY | 服务发现使用的 HTTP 代理 | proxy | proxy 只支持 v2 的 API |
| --strict-reconfig-cheek | ETCD_STRICT_RECONFIG_CHECK | 拒绝所有会引起 quorum 丢失的重配置 | 空 |  |
| --auto-compaction-retention | ETCD_AUTO_COMPACTION_RETENTION | MVCC 键值存储不被自动压缩的时间 | 0 | 单位: h（小时）。0 意味着屏蔽自动压缩 |
| --enable-v2 | ETCD_ENABLE_V2 | 接受 Etcd v2 的 API 请求 | true |  |

安全相关参数项

- 安全相关参数用于构建一个安全的 Etcd 集群，具体说明如下表：

| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --ca-file | ETCD_CA_FILE | 客户端服务器 TLS CA 文件路径 | 空 |
| --cert-file | ETCD_CERT_FILE | 客户端服务器 TLS 证书文件路径 | 空 |
| --key-file | ETCD_KEY_FILE | 客户端服务器 TLS 密钥（key）文件路径 | 空 |
| --client-cert-auth | ETCD_CLIENT_CERT_AUTH | 是否开启客户端认证 | false |
| --trusted-ca-file | ETCD_TRUSTED_CA_FILE | 客户端服务器 TLS 授信 CA 文件路径 | 空 |
| --auto-tls | ETCD_AUTO_TLS | 客户端 TLS 是否使用自动生成的证书 | false |
| --peer-cert-file | ETCD_PEER_CERT_FILE | 服务器 TLS 证书文件路径 | 空 |
| --peer-key-file | ETCD_PEER_KEY_FILE | 服务器 TLS key 文件路径 | 空 |
| --peer-client-cert-auth | ETCD_PEER_CLIENT_CERT_AUTH | 是否启用 peer 客户端证书认证 | false |
| --peer-trusted-ca-file | ETCD_PEER_TRUSTED_CA_FILE | 服务端 TLS 授信 CA 文件路径 | 空 |
| --peer-auto-tls | ETCD_PEER_AUTO_TLS | 是否使用自动生成的 TLS 证书	false	

Proxy 相关参数项
- 以 "–proxy" 为前缀的选项配置 Etcd 运行在 Proxy 模式下。Proxy 模式只支持 v2 API。相关参数和环境变量说明如下表：

| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --proxy | ETCD_PROXY | 设置 proxy 模式与否：off、readonly、on | off |  |
| --proxy-failure-wait | ETCD_PROXY_FAILURE_WAIT | 当后端发生错误时 Proxy 下次发给它的等待时间 | 5000 | 单位: ms |
| --proxy-refresh-interval | ETCD_PROXY_REFRESH_INTERVAL | 后端刷新时间间隔 | 30000 | 单位: ms |
| --proxy-dial-timeout | ETCD_PROXY_DIAL_TIMEOUT | 与后端建立链接的超时时间 | 1000 | 单位: ms。0 代表没有 timeout |
| --proxy-write-timeout | ETCD_PROXY_WRITE_TIMEOUT | 写后端的超时时间 | 5000 | 单位: ms。0 代表没有 timeout |
| --proxy-read-timeout | ETCD_PROXY_READ_TIMEOUT | 读后端的超时时间 | 0 | 单位: ms。0 代表没有 timeout |

日志相关参数项
- Etcd 日志相关参数项的含义如下表：

| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --debug | ETCD_DEBUG | 将 Etcd 所有的子项目日志级别都调整到 DEBUG | false | 默认日志级别是 INFO |
| --log-package-levels | ETCD_LOGPACKAGE_LEVELS | 为 Etcd 某个独立的子项目设置日志级别，默认所有子项目的日志级别是 INFO | 空 | 例如 etcdserver=WARNING,secureity=DEBUG |

不安全参数项
- 使用不安全选项请三思，因为这会破坏一致性协议的保证。例如，如果集群内的 member 还存活着，咋可能会引起异常，具体如下表：

| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --force-new-cluster | ETCD_FORCE_NEW_CLUSTER | 强制创建只有一个节点的 Etcd 集群 | false | 该选项会强制移除集群内所有现存的节点（包括自身）。一般与备份恢复配合使用。 |

统计相关参数项
- Etcd 统计（包括运行时性能分析和监控数据）相关参数如下表：

| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --enable-pprof | ETCD_ENABLE_PPROF | 启用收集运行时 profile 数据，并通过 HTTP 服务器对外暴露 | false | URL 是 client URL + /debug/pprof/ |
| --metrics | ETCD_METRICS | 设置导出 metric 数据的详细程度 | basic |  |

认证相关参数项
- Etcd 认证相关参数如下表：
| 参数 | 环境变量 | 含义 | 默认值 | 备注 |
|------|---------|------|-------|------|
| --auth-token | ETCD_AUTO_TOKEN | 指定 token 的类型和选项，并通过 HTTP 服务器对外暴露 | 空 | 格式: type,val1=val1,var2=val2,... |




