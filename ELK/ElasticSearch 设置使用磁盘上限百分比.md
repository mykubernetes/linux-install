设置 elasticsearch 磁盘上限，避免磁盘空间达到80%出现数据大批量转移 或 多节点磁盘空不足导致故障
```
PUT /_cluster/settings
{
  "transient": {
    "cluster.routing.allocation.disk.watermark.low": "90%",
    "cluster.routing.allocation.disk.watermark.high": "95%",
    "cluster.info.update.interval": "1m"
  }
}
```
