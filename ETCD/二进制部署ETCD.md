1、安装cfssl
---
```
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64  
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64  
  
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64  
  
mv cfssl_linux-amd64 /usr/local/bin/cfssl  
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson  
```

2、创建ca证书，客户端，服务端，节点之间的证书
---
Etcd属于server ,etcdctl 属于client，二者之间通过http协议进行通信。
- ca证书 自己给自己签名的权威证书，用来给其他证书签名
- server证书 etcd的证书
- client证书 客户端，比如etcdctl的证书
- peer证书 节点与节点之间通信的证书

1） 创建目录
```
mkdir -p /etc/etcd/pki  
cd /etc/etcd/pki  
cfssl print-defaults config > ca-config.json  
cfssl print-defaults csr > ca-csr.json  
```

2） 创建ca证书

修改ca-config.json

server auth表示client可以用该ca对server提供的证书进行验证

client auth表示server可以用该ca对client提供的证书进行验证
```
{  
    "signing": {  
        "default": {  
            "expiry": "43800h"  
        },  
        "profiles": {  
            "server": {  
                "expiry": "43800h",  
                "usages": [  
                    "signing",  
                    "key encipherment",  
                    "server auth",  
                    "client auth"  
                ]  
            },  
            "client": {  
                "expiry": "43800h",  
                "usages": [  
                    "signing",  
                    "key encipherment",  
                    "client auth"  
                ]  
            },  
            "peer": {  
                "expiry": "43800h",  
                "usages": [  
                    "signing",  
                    "key encipherment",  
                    "server auth",  
                    "client auth"  
                ]  
            }  
        }  
    }  
}
```

创建证书签名请求ca-csr.json
```
{  
    "CN": "etcd",  
    "key": {  
        "algo": "rsa",  
        "size": 2048  
    }  
}  
```

生成CA证书和私钥
```
# cfssl gencert -initca ca-csr.json | cfssljson -bare ca  
# ls ca*  
ca-config.json ca.csr ca-csr.json ca-key.pem ca.pem
```

3） 生成客户端证书
```
vim client.json

{  
    "CN": "client",  
    "key": {  
        "algo": "ecdsa",  
        "size": 256  
    }  
}
```

生成
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client client.json  | cfssljson -bare client -  
# ls ca*  
ca-config.json ca.csr ca-csr.json ca-key.pem ca.pem client-key.pem client.pem  
```

4） 生成server，peer证书
```
vim etcd.json

{  
    "CN": "etcd",  
    "hosts": [  
        "127.0.0.1",  
        "192.168.255.131",  
        "192.168.255.132",  
        "192.168.255.133"  
    ],  
    "key": {  
        "algo": "ecdsa",  
        "size": 256  
    },  
    "names": [  
        {  
            "C": "CN",  
            "L": "SH",  
            "ST": "SH"  
        }  
    ]  
}
```
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server etcd.json | cfssljson -bare server  
  
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer etcd.json | cfssljson -bare peer  
```

3、安装etcd二进制文件
```
wget https://github.com/coreos/etcd/releases/download/v3.1.5/etcd-v3.1.5-linux-amd64.tar.gz  
tar -xvf etcd-v3.1.5-linux-amd64.tar.gz  
mv etcd-v3.1.5-linux-amd64/etcd* /usr/local/bin  
```

创建etcd的工作目录
```
mkdir -p /var/lib/etcd
```

4、service配置文件
```
vim /usr/lib/systemd/system/etcd.service, 三台机器配置不一样，需要替换为相应的IP和name。


[Unit]  
Description=Etcd Server  
After=network.target  
After=network-online.target  
Wants=network-online.target  
Documentation=https://github.com/coreos  
  
[Service]  
Type=notify  
WorkingDirectory=/var/lib/etcd  
ExecStart=/usr/local/bin/etcd \  
--data-dir=/var/lib/etcd \  
--name=master1 \  
--cert-file=/etc/etcd/pki/server.pem \  
--key-file=/etc/etcd/pki/server-key.pem \  
--trusted-ca-file=/etc/etcd/pki/ca.pem \  
--peer-cert-file=/etc/etcd/pki/peer.pem \  
--peer-key-file=/etc/etcd/pki/peer-key.pem \  
--peer-trusted-ca-file=/etc/etcd/pki/ca.pem \  
--listen-peer-urls=https://192.168.255.131:2380 \  
--initial-advertise-peer-urls=https://192.168.255.131:2380 \  
--listen-client-urls=https://192.168.255.131:2379,http://127.0.0.1:2379 \  
--advertise-client-urls=https://192.168.255.131:2379 \  
--initial-cluster-token=etcd-cluster-0 \  
--initial-cluster=master1=https://192.168.255.131:2380,master2=https://192.168.255.132:2380,master3=https://192.168.255.133:2380 \  
--initial-cluster-state=new \  
--heartbeat-interval=250 \  
--election-timeout=2000  
Restart=on-failure  
RestartSec=5  
LimitNOFILE=65536  
  
[Install]  
WantedBy=multi-user.target 
```
配置参数的含义

- --name：方便理解的节点名称，默认为 default，在集群中应该保持唯一，可以使用 hostname  
- --data-dir：服务运行数据保存的路径，默认为 ${name}.etcd  
- --snapshot-count：指定有多少事务（transaction）被提交时，触发截取快照保存到磁盘  
- --heartbeat-interval：leader 多久发送一次心跳到 followers。默认值是 100ms  
- --eletion-timeout：重新投票的超时时间，如果 follow 在该时间间隔没有收到心跳包，会触发重新投票，默认为 1000 ms  
- --listen-peer-urls：和集群内其他节点通信的地址， http://ip:2380，如果有多个，使用逗号分隔。需要所有节点都能够访问，所以不要使用 localhost！  
- --listen-client-urls：节点与客户端通信的地址，比如 http://ip:2379,http://127.0.0.1:2379，客户端会连接到这里和 etcd 交互  
- --advertise-client-urls：对外通告的该节点客户端监听地址，http://ip:2379，这个值会通知集群中其他节点  
- --initial-advertise-peer-urls：节点与其他节点通信的地址，会通告给集群的其他成员。这个地址用来传输集群数据。因此这个地址必须是可以被集群中所有的成员访问http://ip:2380  
- --initial-cluster：集群中所有节点的信息，格式为 node1=http://ip1:2380,node2=http://ip2:2380,…。注意：这里的 node1 是节点的 --name 指定的名字；后面的 ip1:2380 是 --initial-advertise-peer-urls 指定的值  
- --initial-cluster-state：新建集群的时候，这个值为 new；假如已经存在的集群，这个值为 existing  
- --initial-cluster-token：创建集群的 token，这个值每个集群保持唯一。这样的话，如果你要重新创建集群，即使配置和之前一样，也会再次生成新的集群和节点 uuid；否则会导致多个集群之间的冲突，造成未知的错误  
  
所有以--initial 开头的配置都是在 bootstrap（引导） 集群的时候才会用到，后续节点重启时会被忽略。  

# etcd常用配置阐述
| 配置参数 | 参数说明 |
|----------|---------|
| --name | 指定节点名称 |
| --data-dir | 指定节点数据存储目录，用于保存日志和快照 |
| --add | 公布IP地址和端口；默认为127.0.0.1:2379 |
| --bind-dir | 用于客户端连接的监听地址；默认为--addr配置 |
| --peers | 集群成员逗号分隔的列表；列如127.0.0.1:2380，127.0.0.1:2381 |
| --peer-addr | 集群服务同学的公布的IP地址；默认为127.0.0.1:2380 |
| --peer-bind-addr | 集群服务通讯的监听地址；默认为--peer-addr配置 |
| --wal-dir | 指定节点的wal文件的存储魔力，若指定了该参数wal文件会和其他数据文件分开存储 |
| --listen-client-urls | 监听URL;用于客户端通讯 |
| --listen-peer-urls | 监听URL;用于与其他节点通讯 |
| --initial-advertise-peer-urls | 告知集群其他节点URL |
| --advertise-client-urls | 告知客户端URL |
| --initial-cluster-token | 集群的ID |
| --initial-cluster | 集群中所有节点 |
| --initial-cluster-state | new表示从无到有搭建etcd集群 |
| --discovery-srv | 用于DNS动态服务发现，指定DNS SRV域名 |
| --discovery | 用于etcd动态发现，指定etcd发现服务的URL |



5、创建存放etcd数据的目录，启动 etcd
```
mkdir /var/lib/etcd  
  
systemctl daemon-reload && systemctl enable etcd && systemctl start etcd && systemctl status etcd
```

6、验证是否成功

在任意一台机器（无论是不是集群节点，前提是需要有etcdctl工具和ca证书，server证书）上执行如下命令：
```
[root@master1] /etc/etcd/pki$ etcdctl --ca-file=/etc/etcd/pki/ca.pem --cert-file=/etc/etcd/pki/server.pem --key-file=/etc/etcd/pki/server-key.pem --endpoints=https://192.168.255.131:2379 cluster-health  
2019-01-27 20:41:26.909601 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated  
2019-01-27 20:41:26.910165 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated  
member 5d7a44f5c39446c1 is healthy: got healthy result from https://192.168.255.132:2379  
member e281e4e43dceb752 is healthy: got healthy result from https://192.168.255.133:2379  
member ea5e4f12ed162d4b is healthy: got healthy result from https://192.168.255.131:2379  
cluster is healthy  
```

如果没有指定证书，会报如下错误
```
client: etcd cluster is unavailable or misconfigured; error #0: x509: certificate signed by unknown authority  
```

查看集群成员
```
[root@master1] /etc/etcd/pki$ etcdctl --ca-file=/etc/etcd/pki/ca.pem --cert-file=/etc/etcd/pki/server.pem --key-file=/etc/etcd/pki/server-key.pem --endpoints=https://192.168.255.131:2379 member list  
2019-01-27 22:58:46.914338 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated  
5d7a44f5c39446c1: name=master2 peerURLs=https://192.168.255.132:2380 clientURLs=https://192.168.255.132:2379 isLeader=false  
e281e4e43dceb752: name=master3 peerURLs=https://192.168.255.133:2380 clientURLs=https://192.168.255.133:2379 isLeader=false  
ea5e4f12ed162d4b: name=master1 peerURLs=https://192.168.255.131:2380 clientURLs=https://192.168
``` 


# ETCD数据目录介绍

指定了数据存放目录/var/lib/etcd，查看这个目录下的内容，目录下存在两个子目录snap和wal目录，具体如下：
```
[root@k8s001 ~]# ls /var/lib/etcd/member
snap  wal
```

- snap
  - 存放快照数据，存储etcd的数据状态
  - etcd防止WAL文件过多而设置的快照
- wal
  - 存放预写式日志
  - 最大的作用是记录了整个数据变化的全部历程
  - 在etcd中，所有数据的修改在提交前，都要先写入到WAL中。
```
[root@k8s001 etcd]# tree member
member
├── snap
│   ├── 0000000000000006-000000000056f9d9.snap
│   ├── 0000000000000006-000000000058807a.snap
│   ├── 0000000000000006-00000000005a071b.snap
│   ├── 0000000000000006-00000000005b8dbc.snap
│   ├── 0000000000000006-00000000005d145d.snap
│   └── db
└── wal
    ├── 0000000000000065-00000000005a0f54.wal
    ├── 0000000000000066-00000000005adeea.wal
    ├── 0000000000000067-00000000005bae72.wal
    ├── 0000000000000068-00000000005c7dfd.wal
    ├── 0000000000000069-00000000005d4d81.wal
    └── 1.tmp

2 directories, 12 files
```
使用WAL进行数据的存储使得etcd拥有两个重要功能，那就是故障快速恢复和数据回滚/重做。故障快速恢复就是当你的数据遭到破坏时，就可以通过执行所有WAL中记录的修改操作，快速从最原始的数据恢复到数据损坏前的状态。数据回滚重做就是因为所有的修改操作都被记录在WAL中，需要回滚或重做，只需要方向或正向执行日志中的操作即可。
既然有了WAL实时存储了所有的变更，为什么还需要snapshot呢？随着使用量的增加，WAL存储的数据会暴增。为了防止磁盘很快就爆满，etcd默认每10000条记录做一次snapshot操作，经过 snapshot 以后的WAL文件就可以删除。而通过API可以查询的历史etcd操作默认为 1000 条。
首次启动时，etcd会把启动的配置信息存储到data-dir参数指定的数据目录中。配置信息包括本地节点的ID、集群ID和初始时集群信息。用户需要避免etcd从一个过期的数据目录中重新启动，因为使用过期的数据目录启动的节点会与集群中的其他节点产生不一致。所以，为了最大化集群的安全性，一旦有任何数据损坏或丢失的可能性，你就应该把这个节点从集群中移除，然后加入一个不带数据目录的新节点。
