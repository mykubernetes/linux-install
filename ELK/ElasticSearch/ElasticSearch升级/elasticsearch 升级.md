elasticsearch通常可以使用滚动升级，在升级中不会中断服务。下面是支持滚动升级的情况:
- 小版本之间的升级
- 从5.6到6.8
- 从6.8到7.2.0

对于不支持滚动升级的情况，必须关闭群集，安装7.2.0，然后重新启动。

Elasticsearch可以读取在先前主要版本中创建的索引。如果您在5.x或之前创建了索引，则必须在升级到7.2.0之前重新索引或删除它们。如果存在不兼容的索引，Elasticsearch节点将无法启动。即使它们是由6.x群集创建的，5.x或更早索引的快照也无法还原到7.x群集。解决这一问题的办法是使用 reindex api 重建索引。

有两种方法可以重新索引旧索引：
- 在升级之前，在6.x群集上重新编制索引。
- 从远程创建一个新的7.2.0集群然后Reindex。

那么如何知道index的创建版本呢？
```
GET {index}?human=true
 
"settings": {
      "index": {
        ...
        "version": {
          "created_string": "6.3.0",
          "created": "6030099"
        }
      }
    }
```

[version.created 的参数转换](https://github.com/elastic/elasticsearch/issues/11484)

升级前准备工作:
- [检查弃用日志](https://www.elastic.co/guide/en/elasticsearch/reference/current/logging.html#deprecation-logging)以查看您是否使用任何已弃用的功能并相应地更新代码。默认情况下，日志级别设置为WARN时会记录弃用警告。
- 查看[重大更改](https://www.elastic.co/guide/en/elasticsearch/reference/current/breaking-changes.html)，并对要升级版本的代码和配置进行必要的更改。
- 如果使用自定义插件，请确保兼容版本可用。
- 在升级生产群集之前，在开发环境中测试升级。
- 备份数据！必须拥有数据快照才能回滚到早期版本。

# 完全集群重启升级

## 禁用分片分配

关闭节点时，分配进程会等待 index.unassigned.node_left.delayed_timeout（默认情况下为1分钟），然后再开始将该节点上的分片复制到群集中的其他节点，这可能涉及大量I / O. 由于节点很快将重新启动，因此可以通过在关闭节点之前禁用副本分配来避免这个问题:
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "primaries"
  }
}
```

## 停止索引并执行同步刷新

执行同步刷新可以加快碎片恢复速度。
```
POST _flush/synced
```

## 关闭所有节点
```
# systemd 运行的 elasticsearch
sudo systemctl stop elasticsearch.service
# service 运行的 elasticsearch
sudo -i service elasticsearch stop
# 守护进程运行的 elasticsearch
kill $(cat pid)
```

## 升级所有的节点
- 1、安装升级的elasticsearch
- 2、config和data目录
  - 1、需要修改ES_PATH_CONF参数来指定外部config目录和jvm.options文件的位置。如果未使用外部config目录，请将旧配置复制到新安装。
  - 2、在config/elasticsearch.yml中设置path.data指向外部数据目录。如果未使用外部data目录，请将旧数据目录复制到新安装。
  - 3、在config/elasticsearch.yml中设置path.logs指向要保存你的日志的位置。如果未指定此设置，则日志将存储在您将存档解压缩到的目录中。
- 3、使用elasticsearch-plugin脚本安装每个已安装的Elasticsearch插件的升级版本。升级节点时，必须升级所有插件。
- 4、启动所有升级的节点。如果从6.x群集升级，则必须通过设置cluster.initial_master_nodes来配置群集引导。只要有足够的符合主节点的节点相互发现，它们就会形成一个集群并选出一个主节点。
- 5、等待所有节点加入群集并恢复主分片。一旦节点恢复其本地分片，群集status将切换到yellow，表示已恢复所有主分片，但并未分配所有副本分片。这是预料之中的，因为您还没有重新启用分配。

## 重新启用分配

当所有节点都已加入群集并恢复其主分片时，请通过恢复cluster.routing.allocation.enable其默认值来重新启用分配：
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
```

# 滚动升级

滚动升级允许Elasticsearch集群一次升级一个节点，因此升级不会中断服务。不支持在升级期间在同一群集中运行多个版本的Elasticsearch。

## 禁用分片分配

关闭节点时，分配进程会等待 index.unassigned.node_left.delayed_timeout（默认情况下为1分钟），然后再开始将该节点上的分片复制到群集中的其他节点，这可能涉及大量I / O. 由于节点很快将重新启动，因此不需要此I / O. 您可以通过在关闭节点之前禁用副本分配来避免这个问题:
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "primaries"
  }
}
```

## 停止非必要索引并执行同步刷新

虽然可以在升级期间继续索引，但如果暂时停止非必要索引并执行同步刷新，则碎片恢复会快得多 。
```
POST _flush/synced
```

## 关闭单个节点并升级
```
# systemd 运行的 elasticsearch
sudo systemctl stop elasticsearch.service

# service 运行的 elasticsearch
sudo -i service elasticsearch stop

# 守护进程运行的 elasticsearch
kill $(cat pid)
```

- 1、安装升级的elasticsearch
- 2、config和data目录
  - 1、需要修改ES_PATH_CONF参数来指定外部config目录和jvm.options文件的位置。如果未使用外部config目录，请将旧配置复制到新安装。
  - 2、在config/elasticsearch.yml中设置path.data指向外部数据目录。如果未使用外部data目录，请将旧数据目录复制到新安装。
  - 3、在config/elasticsearch.yml中设置path.logs指向要保存你的日志的位置。如果未指定此设置，则日志将存储在您将存档解压缩到的目录中。
- 3、使用elasticsearch-plugin脚本安装每个已安装的Elasticsearch插件的升级版本。升级节点时，必须升级所有插件。
- 4、启动已升级的节点。可以通过日志或下面的命令来确认：GET _cat/nodes。

## 重新打开分片再平衡
```
PUT /_cluster/settings
{
  "transient": {
    "cluster.routing.allocation.enable": null
  }
}
```

> 在处理完一个节点后，需要开启这个设置。

## 等待节点恢复正常

等待集群分片平衡结束后，再升级下一个节点。这一过程可以使用_cat/health命令检查：
```
GET _cat/health
```
```
等到 status 这一列由 yellow 变成 green，Green 表示主分片和副本都分配完了。

滚动升级过程中，高版本上的主分片不会把副本分配到低版本的节点，因为高版本的数据格式老版本不认识。如果高版本的主分片没法分配副本，换句话说如果集群中只剩下了一个高版本节点，那么节点就保持未分配的状态，集群健康会保持 yellow。这种情况下，检查下有没有初始化或分片分配在执行。一旦另一个节点升级结束后，分片将会被分配，然后集群状态会恢复到 green 。

没有使用同步刷新的分片恢复时间会慢一点。分片的状态可以通过_cat/recovery请求监控：
```
```
GET _cat/recovery
```

```
如果你在这之前停止索引操作，那么在节点恢复完成之后重启也是安全的。当集群稳定并且节点恢复后，对剩下的节点重复上述过程。

在滚动升级期间，群集继续正常运行。但是，任何新功能都将被禁用或以向后兼容模式运行，直到群集中的所有节点都升级为止。升级完成且所有节点都运行新版本后，新功能即可运行。一旦发生这种情况，就无法返回以向后兼容模式运行。运行先前主要版本的节点将不被允许加入完全更新的群集。
如果在升级过程中网络出现故障，将所有剩余的旧节点与群集隔离，则必须使旧节点脱机并升级它们以使其能够加入群集。
如果在升级期间同时停止一半或更多符合主节点的节点，则群集将变为不可用，这意味着升级不再是滚动升级。如果发生这种情况，您应升级并重新启动所有已停止的符合主节点的节点，以允许再次形成群集，就像执行完全群集重新启动升级一样。可能还需要升级所有剩余的旧节点，然后才能在重新形成后加入群集。
```
 

[restart-upgrade](https://www.elastic.co/guide/en/elasticsearch/reference/current/restart-upgrade.html)
[rolling-upgrades](https://www.elastic.co/guide/en/elasticsearch/reference/current/rolling-upgrades.html)
