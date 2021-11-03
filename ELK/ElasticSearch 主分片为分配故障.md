1、利用 `_shard_stores` 接口，查看故障索引的分片异常原因。
```
[root@***es4 ~]# curl 'http://localhost:9201/s2*******r201908/_shard_stores?pretty'
{
  "indices" : {
    "s2********201908" : {
      "shards" : {
        "0" : {
          "stores" : [
            {
              "kgEDY2A4TBKK6lFzqsurnQ" : {
                "name" : "es3",
                "ephemeral_id" : "72HkjNj5S-qyl6gmVkbWeg",
                "transport_address" : "10.2.97.130:9300",
                "attributes" : { }
              },
              "allocation_id" : "B4G1nHTgQieomyy-KME1ug",
              "allocation" : "unused"
            },
            {
              "d3WYyXhBQvqYbZieXzfCNw" : {
                "name" : "es5",
                "ephemeral_id" : "deBE6DjyRJ-kXdj0XU7FzQ",
                "transport_address" : "10.2.101.116:9300",
                "attributes" : { }
              },
              "allocation_id" : "svMhSywPSROQa7MnbvKB-g",
              "allocation" : "unused",
              "store_exception" : {
                "type" : "corrupt_index_exception",
                "reason" : "failed engine (reason: [corrupt file (source: [index])]) (resource=preexisting_corruption)",
                "caused_by" : {
                  "type" : "i_o_exception",
                  "reason" : "failed engine (reason: [corrupt file (source: [index])])",
                  "caused_by" : {
                    "type" : "corrupt_index_exception",
                    "reason" : "checksum failed (hardware problem?) : expected=24fb23d3 actual=66004bad (resource=BufferedChecksumIndexInput(MMapIndexInput(path=\"/var/lib/elasticsearch/nodes/0/indices/oC_7CtFfS2-pa3OoBDAlDA/0/index/_1fjsf.cfs\") [slice=_1fjsf_Lucene50_0.pos]))"
                  }
                }
              }
            }
          ]
        }
      }
    }
  }
}
```
- （es5 节点上，我调用接口设置了副本数从1 变为 0，所以该只读索引还保存有原有分片 0 的副本分片节点信息，可忽略）

我们看到该索引的 0 主分片（故障主分片）以前是存在于 es3 节点上的。ES 由于数据安全性保证，在两个节点都有离线的情况下，锁住了 0 主分片的写入，导致索引也出于只读状态。

```
[root@*******es4 ~]# curl -XPOST 'http://localhost:9201/_cluster/reroute?master_timeout=5m&pretty' -d '
{
	"commands": [
		{
			"allocate_stale_primary": {
				"index": "s2-********201908", 
				"shard": 0, 
				"node": "es3", 
				"accept_data_loss": true
			}
		}
	]
}'
```
调用集群的 reroute 接口，在接受部分数据丢失的情况下，我们可以把 es3 节点上的原有副本，强制提升为索引的主分片。

官方文档 说明。

此外，/_cluster/reroute 接口还能够接受手动分配一个空的主分片到已有索引分配之中。谨慎使用
```
[root@*******es4 ~]# curl -XPOST 'http://localhost:9201/_cluster/reroute?master_timeout=5m&pretty' -d '
{
	"commands": [
		{
			"allocate_empty_primary": {
				"index": "s2-********201908", 
				"shard": 0, 
				"node": "es3", 
				"accept_data_loss": true
			}
		}
	]
}'
```
