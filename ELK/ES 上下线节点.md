# 节点下线

1、首先要确认现在集群中节点的数量
```
# curl -X GET http://localhost:9200/_cat/nodes

ip        heap.percent ram.percent cpu load_1m load_5m load_15m node.role master      name
10.1.1.23           25          98   7    0.15    0.21     0.23       mdi      -    node-1
10.1.1.33           37          96   5    0.41    0.33     0.27       mdi      *    node-4
10.1.1.24           51          98   4    0.29    0.24     0.23       mdi      -    node-2
10.1.1.25           43          97   7    0.51    0.51     0.20       mdi      -    node-3
```

2、节点剔除

节点下线只需要一条命令即可，如果有多台服务器需要下线，在后面用逗号隔开然后写入节点 IP，如果提交的命令有两个，它会覆盖前一个，被下线的服务器会把数据迁移后才会在集群中消失，如果数据没被迁移完，又执行了命令，这个节点不会被下线。
```
curl -X PUT "localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "transient" : {
    "cluster.routing.allocation.exclude._ip" : "10.1.1.33"
  }
}
'
```

3、耐心等待后即可通过以下命令检查node中的分片数量
```
curl -X GET "localhost:9200/_cat/allocation?v"
```
- 确认分片数量为0后，即可登入到elasticsearch节点关闭服务

4、node重新加入集群后并不会自动同步分片，因为上面已经将它的IP剔除了，此时需要执行以下命令将其加入其中
```
curl -X PUT "localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "transient" : {
    "cluster.routing.allocation.include._ip" : "10.1.1.*"
  }
}
'
```

5、当有一个node从集群中离线时会出现Unassigned Shards，直至新node加入并恢复（recovery），而默认情况下，恢复的速度被限制在40mbps。如果你的网络和磁盘IO都支持更高的速度，则可以通过以下命令对该参数进行调整：
```
curl -X PUT "localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
{
    "persistent" : {
        "indices.recovery.max_bytes_per_sec" : "100mb"
    }
}
'
```
