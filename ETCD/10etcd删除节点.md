# Etcd 删除节点

1、在集群中删除一个节点，查看当前节点：
```
$ ETCDCTL_API=2 etcdctl --ca-file=./etcd-ca.pem --key-file=./etcd-client-key.pem --cert-file=./etcd-client.pem --endpoints https://192.168.111.201:2379 member list
 
22f69347520bc065: name=onfra0 peerURLs=https://192.168.111.201:2380 clientURLs=https://192.168.111.201:2379 isLeader=true
31f594e98f861eb7: name=onfra1 peerURLs=https://192.168.111.202:2380 clientURLs=https://192.168.111.202:2379 isLeader=false
54e5fbcfbe557469: name=onfra2 peerURLs=https://192.168.111.203:2380 clientURLs=https://192.168.111.203:2379 isLeader=false
99cd5ef5f1c952ce: name=onfra3 peerURLs=https://192.168.111.204:2380 clientURLs=https://192.168.111.204:2379 isLeader=false
```

2、删除最后一个节点，需要使用集群 ID：
```
$ ETCDCTL_API=2 etcdctl --ca-file=./etcd-ca.pem --key-file=./etcd-client-key.pem --cert-file=./etcd-client.pem --endpoints https://192.168.111.201:2379 member remove 99cd5ef5f1c952ce
Removed member 99cd5ef5f1c952ce from cluster
```

3、此时节点被删除：
```
$ ETCDCTL_API=2 etcdctl --ca-file=./etcd-ca.pem --key-file=./etcd-client-key.pem --cert-file=./etcd-client.pem --endpoints https://192.168.111.201:2379 member list
 
22f69347520bc065: name=onfra0 peerURLs=https://192.168.111.201:2380 clientURLs=https://192.168.111.201:2379 isLeader=true
31f594e98f861eb7: name=onfra1 peerURLs=https://192.168.111.202:2380 clientURLs=https://192.168.111.202:2379 isLeader=false
54e5fbcfbe557469: name=onfra2 peerURLs=https://192.168.111.203:2380 clientURLs=https://192.168.111.203:2379 isLeader=false
```

4、此时相应节点的服务也停止。
```
$ ssh 192.168.111.204
$ systemctl stop etcd 
$ systemctl disable etcd
```

5、查看集群当前的心跳状态：
```
$ ETCDCTL_API=3 etcdctl --cacert=./etcd-ca.pem --cert=./etcd-server.pem --key=./etcd-server-key.pem --endpoints=https://192.168.111.201:2379,https://192.168.111.202:2379,https://192.168.111.203:2379 endpoint health
https://192.168.111.201:2379 is healthy: successfully committed proposal: took = 6.687663ms
https://192.168.111.203:2379 is healthy: successfully committed proposal: took = 4.101322ms
https://192.168.111.202:2379 is healthy: successfully committed proposal: took = 5.727796ms
```
