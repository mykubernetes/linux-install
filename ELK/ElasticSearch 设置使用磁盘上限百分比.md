# elasticsearch磁盘超过80%后，会出现连接都正常，写接口也不报错，只是数据没有写入，当然也就无法查询到。

经过查找原因，原来磁盘超过80%后，es默认会变成只读模式，扩容后，也不会自动还原，通过下面的语句可以还原回来。
```
PUT _settings
{
  "index": {
    "blocks": {
      "read_only_allow_delete": "false"
    }
  }
}
```

# elasticsearch 设置使用磁盘上限百分比

根据项目情况，可以更改设置 elasticsearch 磁盘上限，避免磁盘空间达到80%出现数据大批量转移 或 多节点磁盘空间不足导致故障
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

参考：
- https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-cluster.html#disk-based-shard-allocation
