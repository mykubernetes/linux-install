# Etcd 添加节点

1、通过如下准备添加一个自定证书的节点：

| 名称 | IP |
|-----|-----|
| cluster.server.01 | 192.168.111.201 |
| cluster.server.02 | 192.168.111.202 |	
| cluster.server.03 | 192.168.111.203 |
| cluster.server.04 | 192.168.111.204 |

在开始下面的示例时，请保证本地用 cfssl 的执行文件。

# CA 证书准备

## 201 首先所有的证书保存存放指定的路径：
```
$ mkdir /certs && cd /certs
```

创建 CA 证书：
```
$ cat > ca-config.json << EOF
{
    "signing": {
        "default": {
          "expiry": "87600h"
        },
        "profiles": {
            "server": {
                "usages": [
                  "signing",
                  "key encipherment",
                  "server auth",
                  "client auth"
                ],
                "expiry": "87600h"
            },
            "client": {
                "usages": [
                  "signing",
                  "key encipherment",
                  "server auth",
                  "client auth"
                ],
                "expiry": "87600h"
            }
        }
    }
}
EOF
```
```
$ cat > etcd-ca-csr.json << EOF
{
    "CN": "etcd",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "BeiJing",
            "L": "BeiJing",
            "O": "etcd",
            "OU": "Etcd Security"
        }
    ]
}
EOF
```

生成证书：
```
$ cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare etcd-ca
```

## 为每个 Etcd 成员生成对等证书

201 为每个 Etcd 成员生成对等证书的具体代码如下：
```
$ cat > etcd-server.json << EOF
{
    "CN": "etcd",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "BeiJing",
            "L": "BeiJing",
            "O": "etcd",
            "OU": "Etcd Security"
        }
    ]
}
EOF

$ cfssl gencert -ca=etcd-ca.pem -ca-key=etcd-ca-key.pem -config=ca-config.json -hostname=127.0.0.1,192.168.111.201,192.168.111.202,192.168.111.203 -profile=server etcd-server.json | cfssljson -bare etcd-server
```

## 复制 TLS 证书和密钥对

将秘钥对复制到所有节点:
```
$ scp /certs root@192.168.111.202:/
$ scp /certs root@192.168.111.203:/
$ scp /certs root@192.168.111.204:/
```

## Start Etcd Cluster

201 启动 Etcd：
```
$ etcd --name=onfra0 \
    --listen-client-urls=https://0.0.0.0:2379 \
    --listen-peer-urls=https://0.0.0.0:2380 \
    --advertise-client-urls=https://192.168.111.201:2379 \
    --initial-advertise-peer-urls=https://192.168.111.201:2380 \
    --client-cert-auth \
    --peer-client-cert-auth \
    --auto-tls \
    --peer-auto-tls \
    --cert-file=/certs/etcd-server.pem \
    --key-file=/certs/etcd-server-key.pem \
    --trusted-ca-file=/certs/etcd-ca.pem \
    --peer-cert-file=/certs/etcd-server.pem \
    --peer-key-file=/certs/etcd-server-key.pem \
    --peer-trusted-ca-file=/certs/etcd-ca.pem \
    --initial-cluster=onfra0=https://192.168.111.201:2380,onfra1=https://192.168.111.202:2380,onfra2=https://192.168.111.203:2380 \
    --initial-cluster-token=etcd-cluster \
    --initial-cluster-state=new \
    --data-dir=/etcd-data
```

202 启动 Etcd：
```
$ etcd --name=onfra1 \
    --listen-client-urls=https://0.0.0.0:2379 \
    --listen-peer-urls=https://0.0.0.0:2380 \
    --advertise-client-urls=https://192.168.111.202:2379 \
    --initial-advertise-peer-urls=https://192.168.111.202:2380 \
    --client-cert-auth \
    --peer-client-cert-auth \
    --auto-tls \
    --peer-auto-tls \
    --cert-file=/certs/etcd-server.pem \
    --key-file=/certs/etcd-server-key.pem \
    --trusted-ca-file=/certs/etcd-ca.pem \
    --peer-cert-file=/certs/etcd-server.pem \
    --peer-key-file=/certs/etcd-server-key.pem \
    --peer-trusted-ca-file=/certs/etcd-ca.pem \
    --initial-cluster=onfra0=https://192.168.111.201:2380,onfra1=https://192.168.111.202:2380,onfra2=https://192.168.111.203:2380 \
    --initial-cluster-token=etcd-cluster \
    --initial-cluster-state=new \
    --data-dir=/etcd-data
```

203 启动 Etcd：
```
$ etcd --name=onfra2 \
    --listen-client-urls=https://0.0.0.0:2379 \
    --listen-peer-urls=https://0.0.0.0:2380 \
    --advertise-client-urls=https://192.168.111.203:2379 \
    --initial-advertise-peer-urls=https://192.168.111.203:2380 \
    --client-cert-auth \
    --peer-client-cert-auth \
    --auto-tls \
    --peer-auto-tls \
    --cert-file=/certs/etcd-server.pem \
    --key-file=/certs/etcd-server-key.pem \
    --trusted-ca-file=/certs/etcd-ca.pem \
    --peer-cert-file=/certs/etcd-server.pem \
    --peer-key-file=/certs/etcd-server-key.pem \
    --peer-trusted-ca-file=/certs/etcd-ca.pem \
    --initial-cluster=onfra0=https://192.168.111.201:2380,onfra1=https://192.168.111.202:2380,onfra2=https://192.168.111.203:2380 \
    --initial-cluster-token=etcd-cluster \
    --initial-cluster-state=new \
    --data-dir=/etcd-data
```

查看集群状态，首先创建 Client 证书。
```
$ cat > etcd-client.json << EOF
{
    "CN": "etcd",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "BeiJing",
            "L": "BeiJing",
            "O": "etcd",
            "OU": "Etcd Security"
        }
    ]
}
EOF
  
$ cfssl gencert -ca=etcd-ca.pem -ca-key=etcd-ca-key.pem -config=ca-config.json -hostname=192.168.111.201,192.168.111.202,192.168.111.203,192.168.111.204,127.0.0.1 -profile=client etcd-client.json | cfssljson -bare etcd-client
```

通过客户端证书查看集群状态信息：
```
$ ETCDCTL_API=2 etcdctl --ca-file=./etcd-ca.pem --key-file=./etcd-client-key.pem --cert-file=./etcd-client.pem --endpoints https://192.168.111.201:2379 member list
22f69347520bc065: name=onfra0 peerURLs=https://192.168.111.201:2380 clientURLs=https://192.168.111.201:2379 isLeader=true
31f594e98f861eb7: name=onfra1 peerURLs=https://192.168.111.202:2380 clientURLs=https://192.168.111.202:2379 isLeader=false
54e5fbcfbe557469: name=onfra2 peerURLs=https://192.168.111.203:2380 clientURLs=https://192.168.111.203:2379 isLeader=false
```
此时集群中有三个示例，192.168.111.201 为主节点。

## Add instance

下面启动第四个实例：（首先保证示例 4 拥有证书）

204 启动 Etcd：
```
$ etcd --name=onfra3 \
     --listen-client-urls=https://0.0.0.0:2379 \
     --listen-peer-urls=https://0.0.0.0:2380 \
     --advertise-client-urls=https://192.168.111.204:2379 \
     --initial-advertise-peer-urls=https://192.168.111.204:2380 \
     --client-cert-auth \
     --peer-client-cert-auth \
     --auto-tls \
     --peer-auto-tls \
     --cert-file=/certs/etcd-server.pem \
     --key-file=/certs/etcd-server-key.pem \
     --trusted-ca-file=/certs/etcd-ca.pem \
     --peer-cert-file=/certs/etcd-server.pem \
     --peer-key-file=/certs/etcd-server-key.pem \
     --peer-trusted-ca-file=/certs/etcd-ca.pem \
     --initial-cluster=onfra0=https://192.168.111.201:2380,onfra1=https://192.168.111.202:2380,onfra2=https://192.168.111.203:2380,onfra3=https://192.168.111.204:2380 \
     --initial-cluster-token=etcd-cluster \
     --initial-cluster-state=existing \
     --data-dir=/etcd-data
2019-05-22 02:17:40.564462 I | etcdmain: etcd Version: 3.3.13
2019-05-22 02:17:40.564542 I | etcdmain: Git SHA: 98d3084
2019-05-22 02:17:40.564548 I | etcdmain: Go Version: go1.10.8
2019-05-22 02:17:40.564552 I | etcdmain: Go OS/Arch: linux/amd64
2019-05-22 02:17:40.564580 I | etcdmain: setting maximum number of CPUs to 4, total number of available CPUs is 4
2019-05-22 02:17:40.564666 W | embed: ignoring peer auto TLS since certs given
2019-05-22 02:17:40.564694 I | embed: peerTLS: cert = /certs/etcd-server.pem, key = /certs/etcd-server-key.pem, ca = , trusted-ca = /certs/etcd-ca.pem, client-cert-auth = true, crl-file =
2019-05-22 02:17:40.565640 I | embed: listening for peers on https://0.0.0.0:2380
2019-05-22 02:17:40.565666 W | embed: ignoring client auto TLS since certs given
2019-05-22 02:17:40.565701 I | embed: listening for client requests on 0.0.0.0:2379
2019-05-22 02:17:40.618095 W | etcdserver: could not get cluster response from https://192.168.111.201:2380: Get https://192.168.111.201:2380/members: EOF
2019-05-22 02:17:40.630877 W | etcdserver: could not get cluster response from https://192.168.111.202:2380: Get https://192.168.111.202:2380/members: EOF
2019-05-22 02:17:40.640388 W | etcdserver: could not get cluster response from https://192.168.111.203:2380: Get https://192.168.111.203:2380/members: EOF
2019-05-22 02:17:40.641042 C | etcdmain: cannot fetch cluster info from peer urls: could not retrieve cluster information from the given urls
```

此时报错说明证书无效，其他节点报错如下：
```
...
2019-05-22 02:00:40.973843 I | rafthttp: established a TCP streaming connection with peer 54e5fbcfbe557469 (stream Message writer)
2019-05-22 02:00:40.977040 I | rafthttp: established a TCP streaming connection with peer 54e5fbcfbe557469 (stream MsgApp v2 writer)
2019-05-22 02:00:41.975896 N | etcdserver/membership: updated the cluster version from 3.0 to 3.3
2019-05-22 02:00:41.976007 I | etcdserver/api: enabled capabilities for version 3.3
2019-05-22 02:16:29.022827 I | embed: rejected connection from "192.168.111.204:33942" (error "x509: certificate is valid for 127.0.0.1, 192.168.111.201, 192.168.111.202, 192.168.111.203, not 192.168.111.204", ServerName "", IPAddresses ["127.0.0.1" "192.168.111.201" "192.168.111.202" "192.168.111.203"], DNSNames [])
...
```

204 节点加入集群时，使用的证书无效。

此时创建新的证书 etcd-server2：
```
$ cfssl gencert -ca=etcd-ca.pem -ca-key=etcd-ca-key.pem -config=ca-config.json -hostname=127.0.0.1,192.168.111.204 -profile=server etcd-server.json | cfssljson -bare etcd-server2
```

204 启动 Etcd：
```
$ etcd --name=onfra3 \
    --listen-client-urls=https://0.0.0.0:2379 \
    --listen-peer-urls=https://0.0.0.0:2380 \
    --advertise-client-urls=https://192.168.111.204:2379 \
    --initial-advertise-peer-urls=https://192.168.111.204:2380 \
    --client-cert-auth \
    --peer-client-cert-auth \
    --auto-tls \
    --peer-auto-tls \
    --cert-file=/certs/etcd-server2.pem \
    --key-file=/certs/etcd-server2-key.pem \
    --trusted-ca-file=/certs/etcd-ca.pem \
    --peer-cert-file=/certs/etcd-server2.pem \
    --peer-key-file=/certs/etcd-server2-key.pem \
    --peer-trusted-ca-file=/certs/etcd-ca.pem \
    --initial-cluster=onfra0=https://192.168.111.201:2380,onfra1=https://192.168.111.202:2380,onfra2=https://192.168.111.203:2380,onfra3=https://192.168.111.204:2380 \
    --initial-cluster-token=etcd-cluster \
    --initial-cluster-state=existing \
    --data-dir=/etcd-data
2019-05-22 02:18:52.920602 I | etcdmain: etcd Version: 3.3.13
2019-05-22 02:18:52.920657 I | etcdmain: Git SHA: 98d3084
2019-05-22 02:18:52.920661 I | etcdmain: Go Version: go1.10.8
2019-05-22 02:18:52.920677 I | etcdmain: Go OS/Arch: linux/amd64
2019-05-22 02:18:52.920705 I | etcdmain: setting maximum number of CPUs to 4, total number of available CPUs is 4
2019-05-22 02:18:52.920757 N | etcdmain: the server is already initialized as member before, starting as etcd member...
2019-05-22 02:18:52.920782 W | embed: ignoring peer auto TLS since certs given
2019-05-22 02:18:52.920828 I | embed: peerTLS: cert = /certs/etcd-server2.pem, key = /certs/etcd-server2-key.pem, ca = , trusted-ca = /certs/etcd-ca.pem, client-cert-auth = true, crl-file =
2019-05-22 02:18:52.921659 I | embed: listening for peers on https://0.0.0.0:2380
2019-05-22 02:18:52.921673 W | embed: ignoring client auto TLS since certs given
2019-05-22 02:18:52.921735 I | embed: listening for client requests on 0.0.0.0:2379
2019-05-22 02:18:52.935282 C | etcdmain: error validating peerURLs {ClusterID:f44ba854c1b9bc45 Members:[&{ID:22f69347520bc065 RaftAttributes:{PeerURLs:[https://192.168.111.201:2380]} Attributes:{Name:onfra0 ClientURLs:[https://192.168.111.201:2379]}} &{ID:31f594e98f861eb7 RaftAttributes:{PeerURLs:[https://192.168.111.202:2380]} Attributes:{Name:onfra1 ClientURLs:[https://192.168.111.202:2379]}} &{ID:54e5fbcfbe557469 RaftAttributes:{PeerURLs:[https://192.168.111.203:2380]} Attributes:{Name:onfra2 ClientURLs:[https://192.168.111.203:2379]}}] RemovedMemberIDs:[]}: member count is unequal
```

报错说明实例中的节点不对等，但实际情况是 204 实例没有被允许加入到集群中，需要执行 API 操作让其加入集群，执行命令：
```
$ ETCDCTL_API=2 etcdctl --ca-file=./etcd-ca.pem --key-file=./etcd-client-key.pem --cert-file=./etcd-client.pem --endpoints https://192.168.111.201:2379 member add onfra3 https://192.168.111.204:2380
Added member named onfra3 with ID 99cd5ef5f1c952ce to cluster
 
ETCD_NAME="onfra3"
ETCD_INITIAL_CLUSTER="onfra0=https://192.168.111.201:2380,onfra1=https://192.168.111.202:2380,onfra2=https://192.168.111.203:2380,onfra3=https://192.168.111.204:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```
说明 204 节点以及被允许加入集群，并且说明其配置项。

204 启动 Etcd：
```
$ etcd --name=onfra3 \
    --listen-client-urls=https://0.0.0.0:2379 \
    --listen-peer-urls=https://0.0.0.0:2380 \
    --advertise-client-urls=https://192.168.111.204:2379 \
    --initial-advertise-peer-urls=https://192.168.111.204:2380 \
    --client-cert-auth \
    --peer-client-cert-auth \
    --auto-tls \
    --peer-auto-tls \
    --cert-file=/certs/etcd-server2.pem \
    --key-file=/certs/etcd-server2-key.pem \
    --trusted-ca-file=/certs/etcd-ca.pem \
    --peer-cert-file=/certs/etcd-server2.pem \
    --peer-key-file=/certs/etcd-server2-key.pem \
    --peer-trusted-ca-file=/certs/etcd-ca.pem \
    --initial-cluster=onfra0=https://192.168.111.201:2380,onfra1=https://192.168.111.202:2380,onfra2=https://192.168.111.203:2380,onfra3=https://192.168.111.204:2380 \
    --initial-cluster-token=etcd-cluster \
    --initial-cluster-state=existing \
    --data-dir=/etcd-data
```

此时节点加入集群成功，查看当前的集群状态：
```
$ ETCDCTL_API=2 etcdctl --ca-file=./etcd-ca.pem --key-file=./etcd-client-key.pem --cert-file=./etcd-client.pem --endpoints https://192.168.111.201:2379 member list
 
22f69347520bc065: name=onfra0 peerURLs=https://192.168.111.201:2380 clientURLs=https://192.168.111.201:2379 isLeader=true
31f594e98f861eb7: name=onfra1 peerURLs=https://192.168.111.202:2380 clientURLs=https://192.168.111.202:2379 isLeader=false
54e5fbcfbe557469: name=onfra2 peerURLs=https://192.168.111.203:2380 clientURLs=https://192.168.111.203:2379 isLeader=false
99cd5ef5f1c952ce: name=onfra3 peerURLs=https://192.168.111.204:2380 clientURLs=https://192.168.111.204:2379 isLeader=false
```
此时集群状态实例为4。说明已经成功的添加。
