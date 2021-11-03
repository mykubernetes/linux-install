方案一

1、找到状态为 red 的索引，状态为 red 是无法对外提供服务的，说明有主节点没有分配到对应的机子上。
```
curl -X GET "http://172.xxx.xxx.174:9288/_cat/indices?v="
 
red    open   index                          5   1    3058268        97588      2.6gb          1.3gb
```


2、找到 UNASSIGNED 节点，_cat/shards 能够看到节点的分配情况
```
curl -X GET "http://172.xxx.xxx.174:9288/_cat/shards"
 
index                            shard prirep state        docs   store   ip             node         
index                      1    p     STARTED     764505 338.6mb 172.xxx.xxx.174 Calypso      
index                      1    r     STARTED     764505 338.6mb 172.xxx.xxx.89  Savage Steel
index                      2    p     STARTED     763750 336.6mb 172.xxx.xxx.174 Calypso      
index                      2    r     STARTED     763750 336.6mb 172.xxx.xxx.88  Temugin      
index                      3    p     STARTED     764537 340.2mb 172.xxx.xxx.89  Savage Steel
index                      3    r     STARTED     764537 340.2mb 172.xxx.xxx.88  Temugin      
index                      4    p     STARTED     765476 339.3mb 172.xxx.xxx.89  Savage Steel
index                      4    r     STARTED     765476 339.3mb 172.xxx.xxx.88  Temugin      
index                      0    p     UNASSIGNED                                             
index                      0    r     UNASSIGNED


curl -X GET "http://172.xxx.xxx.174:9288/_cat/shards?h=index,shard,prirep,state,unassigned,reason | grep UNASSIGNED"
```
index 有一个主节点 0 和一个副本 0 处于 UNASSIGNED 状态，也就是没有分配到机子上，因为主节点没有分配到机子上，所以状态为 red。

从 ip 列可以看出一共有三台机子，尾数分别为 174，89 以及 88。一共有 10 个 index所以对应的 elasticsearch 的 index.number_of_shards: 5，index.number_of_replicas: 1。一共有 10 个分片，可以按照 3，3，4 这样分配到三台不同的机子上。88 和 89 机子都分配多个节点，所以可以将另外一个主节点分配到 174 机子上。

查看分片在分配过程中的报错
```
curl -XGET localhost:9200/_cluster/allocation/explain?pretty
```

3、找出机子的 id，找到 174 机子对应的 id，后续重新分配主节点得要用到
```
curl -X GET "http://172.xxx.xxx.174:9288/_nodes/process?v="
{
  "cluster_name": "es2.3.2-titan-cl",
  "nodes": {
    "Leivp0laTYSqvMVm49SulQ": {
      "name": "Calypso",
      "transport_address": "172.xxx.xxx.174:9388",
      "host": "172.xxx.xxx.174",
      "ip": "172.xxx.xxx.174",
      "version": "2.3.2",
      "build": "b9e4a6a",
      "http_address": "172.xxx.xxx.174:9288",
      "process": {
        "refresh_interval_in_millis": 1000,
        "id": 32130,
        "mlockall": false
      }
    },
    "EafIS3ByRrm4g-14KmY_wg": {
      "name": "Savage Steel",
      "transport_address": "172.xxx.xxx.89:9388",
      "host": "172.xxx.xxx.89",
      "ip": "172.xxx.xxx.89",
      "version": "2.3.2",
      "build": "b9e4a6a",
      "http_address": "172.xxx.xxx.89:9288",
      "process": {
        "refresh_interval_in_millis": 1000,
        "id": 7560,
        "mlockall": false
      }
    },
    "tojQ9EiXS0m6ZP16N7Ug3A": {
      "name": "Temugin",
      "transport_address": "172.xxx.xxx.88:9388",
      "host": "172.xxx.xxx.88",
      "ip": "172.xxx.xxx.88",
      "version": "2.3.2",
      "build": "b9e4a6a",
      "http_address": "172.xxx.xxx.88:9288",
      "process": {
        "refresh_interval_in_millis": 1000,
        "id": 47701,
        "mlockall": false
      }
    }
  }
}
```
- 174 机子对应的 id 为 Leivp0laTYSqvMVm49SulQ。

为了简单也可以直接将该主分片放到 master 机子上，但是如果节点过于集中肯定会影响性能，同时会影响宕机后数据丢失的可能性，所以建议根据机子目前节点的分布情况重新分配。
```
curl -X GET "http://172.xxx.xxx.174:9288/_cat/master?v="
id                     host          ip            node         
EafIS3ByRrm4g-14KmY_wg 172.xxx.xxx.89 172.xxx.xxx.89 Savage Steel
```

4、分配 UNASSIGNED 节点到机子

得要找到 UNASSIGNED 状态的主分片才能够重新分配，如果重新分配不是 UNASSIGNED 状态的主分片，例如我视图重新分配 shard 1 会出现如下的错误。
```
curl -X POST -d '{
    "commands" : [ {
      "allocate" : {
          "index" : "index",
          "shard" : 1,
          "node" : "EafIS3ByRrm4g-14KmY_wg",
          "allow_primary" : true
      }
    }]
}' "http://172.xxx.xxx.174:9288/_cluster/reroute"
 
{
  "error": {
    "root_cause": [
      {
        "type": "remote_transport_exception",
        "reason": "[Savage Steel][172.xxx.xxx.89:9388][cluster:admin/reroute]"
      }
    ],
    "type": "illegal_argument_exception",
    "reason": "[allocate] failed to find [index][1] on the list of unassigned shards"
  },
  "status": 400
}
```

重新分配 index shard 0 到某一台机子。_cluster/reroute 的参数 allow_primary 得要小心，有概率会导致数据丢失。具体的看看官方文档该接口的说明吧。
```
curl -X POST -d '{
    "commands" : [ {
      "allocate" : {
          "index" : "index",
          "shard" : 0,
          "node" : "Leivp0laTYSqvMVm49SulQ",
          "allow_primary" : true
      }
    }]
}' "http://172.xxx.xxx.174:9288/_cluster/reroute"
 
{
  "acknowledged": true,
  .........
  "index": {
    "shards": {
      "0": [
        {
          "state": "INITIALIZING",
          "primary": true,
          "node": "Leivp0laTYSqvMVm49SulQ",
          "relocating_node": null,
          "shard": 0,
          "index": "index",
          "version": 1,
          "allocation_id": {
            "id": "wk5q0CryQpmworGFalfWQQ"
          },
          "unassigned_info": {
            "reason": "INDEX_CREATED",
            "at": "2017-03-23T12:27:33.405Z",
            "details": "force allocation from previous reason INDEX_REOPENED, null"
          }
        },
        {
          "state": "UNASSIGNED",
          "primary": false,
          "node": null,
          "relocating_node": null,
          "shard": 0,
          "index": "index",
          "version": 1,
          "unassigned_info": {
            "reason": "INDEX_REOPENED",
            "at": "2017-03-23T11:56:25.568Z"
          }
        }
      ]
      }
    }
    .............
}
```

5、输出结果只罗列出了关键部分，主节点处于 INITIALIZING 状态，在看看索引的状态
```
curl -X GET "http://172.xxx.xxx.174:9288/_cat/indices?v="
 
green  open   index                          5   1    3058268        97588      2.6gb          1.3gb
```
索引状态已经为 green，恢复正常使用。


方案二
===
找一台空的机子，与现有的机子组成集群，由于新机子的加入机子的节点将会被分配，状态也就会恢复。等集群中所有的节点的状态变为 green 就可以关闭新加入的机子。
