
向该集群的 discovery 发送一个 GET 请求, 查看 member 组成。
```
curl -X GET http://192.168.99.101:2379/e77afb997af5a84983baa98fd42cf12f
返回
    {
        "action": "get", 
        "node": {
            "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f", 
            "dir": true, 
            "nodes": [
                {
                    "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f/4eb2dcba58da982f", 
                    "value": "etcd0=http://192.168.99.101:2380", 
                    "modifiedIndex": 1113260929, 
                    "createdIndex": 1113260929
                }, 
                {
                    "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f/aa5569b385caf33b", 
                    "value": "etcd2=http://192.168.99.103:2380", 
                    "modifiedIndex": 1113261715, 
                    "createdIndex": 1113261715
                }, 
                {
                    "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f/f84fe4a4e816e778", 
                    "value": "etcd1=http://192.168.99.102:2380", 
                    "modifiedIndex": 1113261726, 
                    "createdIndex": 1113261726
                }
            ], 
            "modifiedIndex": 1113260647, 
            "createdIndex": 1113260647
        }
    }
```
- 从结果中可以发现，etcd1 的节点的 key 为 f84fe4a4e816e778。

2、向 discovery 发送一个 DELETE 请求, 删除该节点 member
```
curl -X DELETE http://10.127.3.110:8087/e77afb997af5a84983baa98fd42cf12f/f84fe4a4e816e778
```


# 操作

## 查看版本
```
curl http://192.168.99.101:2379/version

返回
{"etcdserver":"2.3.6","etcdcluster":"2.3.0"}
```

## 查看键
```
curl http://192.168.99.101:2379/v2/keys

返回
{"action":"get","node":{"dir":true}}
```

## 创建键值

put方法如果key之前存在，则默认会先删除，再新建一个key。如果想要直接update，则追加 -d prevExist=true，但是加了这个参数，如果key之前不存在会报错。
```
curl http://192.168.99.101:2379/v2/keys/hello -XPUT -d value="world"

返回
    {
        "action": "set", 
        "node": {
            "key": "/hello", 
            "value": "world", 
            "modifiedIndex": 8, 
            "createdIndex": 8
        }
    }
```

## 创建目录
```
curl http://192.168.99.101:2379/v2/keys/dir -XPUT -d dir=true

返回
    {
        "action": "set", 
        "node": {
            "key": "/dir", 
            "dir": true, 
            "modifiedIndex": 9, 
            "createdIndex": 9
        }
    }
```

## 查看键
```
curl http://192.168.99.101:2379/v2/keys

返回
    {
        "action": "get", 
        "node": {
            "dir": true, 
            "nodes": [
                {
                    "key": "/hello", 
                    "value": "world", 
                    "modifiedIndex": 8, 
                    "createdIndex": 8
                }, 
                {
                    "key": "/dir", 
                    "dir": true, 
                    "modifiedIndex": 9, 
                    "createdIndex": 9
                }
            ]
        }
    }
```

## 创建带ttl的键值

- 单位为秒
```
curl http://192.168.99.101:2379/v2/keys/ttlvar -XPUT -d value="ttl_value" -d ttl=10

返回
    {
        "action": "set", 
        "node": {
            "key": "/ttlvar", 
            "value": "ttl_value", 
            "expiration": "2016-06-04T13:11:00.406180341Z", 
            "ttl": 10, 
            "modifiedIndex": 10, 
            "createdIndex": 10
        }
    }
```

## 创建有序键值
```
curl http://192.168.99.101:2379/v2/keys/seqvar -XPOST -d value="seq1"
curl http://192.168.99.101:2379/v2/keys/seqvar -XPOST -d value="seq2"
curl http://192.168.99.101:2379/v2/keys/seqvar -XPOST -d value="seq3"

curl http://192.168.99.101:2379/v2/keys/seqvar

返回
    {
        "action": "get", 
        "node": {
            "key": "/seqvar", 
            "dir": true, 
            "nodes": [
                {
                    "key": "/seqvar/00000000000000000012", 
                    "value": "seq1", 
                    "modifiedIndex": 12, 
                    "createdIndex": 12
                }, 
                {
                    "key": "/seqvar/00000000000000000013", 
                    "value": "seq2", 
                    "modifiedIndex": 13, 
                    "createdIndex": 13
                }, 
                {
                    "key": "/seqvar/00000000000000000014", 
                    "value": "seq3", 
                    "modifiedIndex": 14, 
                    "createdIndex": 14
                }
            ], 
            "modifiedIndex": 12, 
            "createdIndex": 12
        }
    }
```

## 删除指定的键
```
curl http://192.168.99.101:2379/v2/keys/for_delete -XPUT -d value="fordelete"
curl http://192.168.99.101:2379/v2/keys/
curl http://192.168.99.101:2379/v2/keys/for_delete -XDELETE
curl http://192.168.99.101:2379/v2/keys/

返回
    {
        "action": "delete", 
        "node": {
            "key": "/for_delete", 
            "modifiedIndex": 16, 
            "createdIndex": 15
        }, 
        "prevNode": {
            "key": "/for_delete", 
            "value": "fordelete", 
            "modifiedIndex": 15, 
            "createdIndex": 15
        }
    }
```

## 成员管理

列出所有集群成员
```
curl http://192.168.99.101:2379/v2/members

返回
    {
        "members": [
            {
                "id": "4eb2dcba58da982f", 
                "name": "etcd0", 
                "peerURLs": [
                    "http://192.168.99.101:2380"
                ], 
                "clientURLs": [
                    "http://192.168.99.101:2379", 
                    "http://192.168.99.101:4001"
                ]
            }, 
            {
                "id": "aa5569b385caf33b", 
                "name": "etcd2", 
                "peerURLs": [
                    "http://192.168.99.103:2380"
                ], 
                "clientURLs": [
                    "http://192.168.99.103:2379", 
                    "http://192.168.99.103:4001"
                ]
            }, 
            {
                "id": "f84fe4a4e816e778", 
                "name": "etcd1", 
                "peerURLs": [
                    "http://192.168.99.102:2380"
                ], 
                "clientURLs": [
                    "http://192.168.99.102:2379", 
                    "http://192.168.99.102:4001"
                ]
            }
        ]
    }
```

## 统计信息

查看leader
```
curl http://192.168.99.101:2379/v2/stats/leader

返回
    {
        "leader": "4eb2dcba58da982f", 
        "followers": {
            "aa5569b385caf33b": {
                "latency": {
                    "current": 0.001687, 
                    "average": 0.0026333315088053265, 
                    "standardDeviation": 0.0082522530707236, 
                    "minimum": 0.000508, 
                    "maximum": 0.184366
                }, 
                "counts": {
                    "fail": 0, 
                    "success": 8404
                }
            }, 
            "f84fe4a4e816e778": {
                "latency": {
                    "current": 0.001158, 
                    "average": 0.017216567181926247, 
                    "standardDeviation": 1.236027691414708, 
                    "minimum": 0.000493, 
                    "maximum": 113.333953
                }, 
                "counts": {
                    "fail": 0, 
                    "success": 8410
                }
            }
        }
    }
```

## 节点自身信息
```
curl http://192.168.99.101:2379/v2/stats/self

返回
    {
        "name": "etcd0", 
        "id": "4eb2dcba58da982f", 
        "state": "StateLeader", 
        "startTime": "2016-06-04T12:51:22.901345036Z", 
        "leaderInfo": {
            "leader": "4eb2dcba58da982f", 
            "uptime": "28m29.401994375s", 
            "startTime": "2016-06-04T12:51:23.406751734Z"
        }, 
        "recvAppendRequestCnt": 0, 
        "sendAppendRequestCnt": 17544, 
        "sendPkgRate": 10.52589669646476, 
        "sendBandwidthRate": 746.7071116472099
    }
```

## 查看集群运行状态
```
curl http://192.168.99.101:2379/v2/stats/store

返回
    {
        "getsSuccess": 7, 
        "getsFail": 16, 
        "setsSuccess": 8, 
        "setsFail": 0, 
        "deleteSuccess": 1, 
        "deleteFail": 0, 
        "updateSuccess": 0, 
        "updateFail": 0, 
        "createSuccess": 6, 
        "createFail": 0, 
        "compareAndSwapSuccess": 0, 
        "compareAndSwapFail": 0, 
        "compareAndDeleteSuccess": 0, 
        "compareAndDeleteFail": 0, 
        "expireCount": 1, 
        "watchers": 0
    }
```


# V3版本，注意在V3版本中所有的key和value都必须转换为base64编码然后才可以存储
```
# foo is 'Zm9v' in Base64
# bar is 'YmFy' in Base64

# 创建键值对 foo:bar
# curl -L http://127.0.0.1:2379/v3beta/kv/put -X POST -d '{"key": "Zm9v", "value": "YmFy"}'

# 查看键值对 foo
# curl -L http://127.0.0.1:2379/v3beta/kv/range -X POST -d '{"key": "Zm9v"}' 
```
