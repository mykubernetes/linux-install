# 集群重启升级

1）关闭分片分配，当视图关闭一个节点的时候，Elasticsearch 会立刻尝试复制这个节点的数据到集群中的其他节点上。这将导致大量的 IO 请求。在关闭该节点的时候可以通过设置一个参数来避免此问题的发生：
```
curl -X PUT 'http://localhost:9200/_cluster/settings
{
  "transient": {"cluster.routing.allocation.enable": "none"}
}
```

2）执行一个同步刷新，当停止一个索引的时候，分片的恢复会很快，所以要进行同步刷新请求。
```
curl -X PUT 'http://localhost:9200/_flush/synced
```
同步刷新请求是非常有效的一个操作，当任何所以操作失败的时候，可以执行同步刷新请求，必要的时候可以执行多次。

3）关闭和升级所有节点。停止在集群中的所有节点上的服务。每一个节点都要进行单独升级。这个主要就是文件替换操作，注意保留日志目录。

4）启动集群。如果有专门的主节点，侧先启动主节点。等待他们形成一个集群，然后选择一个主数据节点进行启动。可以通过查询日志来检查启动情况，通过下面的命令可以监控集群的启动情况，检查所有节点是否已成功加入集群。
```
curl -X GET 'http://localhost:9200/_cat/health
curl -X GET 'http://localhost:9200/_cat/nodes
```

5）等待黄色集群状态。当节点加入集群后，它首先恢复储存在本地的主分片数据。最初的时候，通过 _cat/health 请求发现集群的状态是红色，意味着不是所有的主分片都已经分配。当每个节点都恢复完成后，集群的状态将会变成黄色，这意味着所有主分片都已经被找到，但是并不是所有的副本分片都恢复。

6）重新分配。延迟副本的分配知道所有节点都加入集群，在集群的所有节点，可以重新启用碎片分配：
```
curl -X PUT 'http://localhost:9200/_cluster/settings
{
  "persistent": {"cluster.routing.allocation.enable": "all"}
}
```
这个时候集群将开始复制所有副本到数据节点上，这样可以安全的恢复索引和搜索。如果能延迟索引和搜索直到所有的分片已经恢复，这样可以加快集群的恢复。可以通过下面 API 监控恢复的进度和监控状况：
```
curl -X GET 'http://localhost:9200/_cat/health
curl -X GET 'http://localhost:9200/_cat/recovery
```
最后当集群的状态出现绿色时，表示本次集群生成全部完成。

# 滚动升级
滚动升级允许 Elasticsearch 节点升级一个节点，同时又不影响系统的使用。在同一个集群中的所有节点的版本最好保持一致，否则可能会产生不可预测的结果，滚动升级的步骤如下：

1）关闭分片分配。当我们试图变比一个节点的时候，Elasticsearch 会立刻试图复制这个节点的数据到集群中的其他节点上。这将导致大量的 IO 请求。在关闭该节点的时候可以通过设置一下参数来避免此问题的发生。
```
curl -X PUT 'http://localhost:9200/_cluster/settings
{
  "trabsuebt": {"cluster.routing.allocation.enable": "none"}
}
```

2）停止不必要的索引和执行同步刷新（可选）。你可以在升级过程中继续索引。如果暂时停止不必要的索引碎片，但它恢复要快得多。所以可以执行同步刷新操作：
```
curl -X POST 'http://localhost:9200/flush/synced
```
同步刷新请求时非常有效的一种操作，当任何索引操作失败的时候，可以执行同步刷新请求，必要的时候可以执行多次。

3）停止和升级一个节点。在启动升级前，将节点中的一个节点关闭，可以通过绿色解压安装或通过 RPM 等安装包安装。不管是解压安装还是压缩包安装都要保留之前的数据文件不能被破坏。可以在新的目录中安装，把 path.conf 和 path.data 的位置指向之前的数据。

4）启动升级节点。启动 “升级” 节点，并通过接口检查是否正确：
```
curl -X GET 'http://localhost:9200/_cat/nodes
```

5）启动共享配置。一旦节点加入节点，在节点启动重现启用碎片分配：
```
curl -X PUT 'http://localhost:9200/_cluster/settings
{
  "persistent": {"cluster.routing.allocation.enable": "all"}
}
```

6）等待节点恢复。应该在集群下一个节点升级之前完成碎片分配。可以通过以下接口进行查询：
```
curl -X GET 'http://localhost:9200/_cat/health
```
最后当集群的状态出现绿色时，表示本次集群生成全部完成。

https://my.oschina.net/u/4302004/blog/3521139
