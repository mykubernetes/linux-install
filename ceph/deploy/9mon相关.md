添加mon监控
===========
1、修改配置文件
```
vim /etc/ceph/ceph.conf
[global]
fsid = ee409f5a-96c8-4d82-9672-26a17c82af17
mon_initial_members = node01, node02                #添加主机名
mon_host = 192.168.101.69,192.168.101.70            #添加IP地址
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

public network = 192.168.101.0/24
cluster network = 192.168.101.0/24
```  

2、推送配置到新添加节点  
```
ceph-deploy --overwrite-conf config push node02
```  

3、使用ceph-deploy工具添加mon新节点
```
ceph-deploy mon create node02 
```  

4、查看  
```
# ceph -s
# ceph mon_status -f json-pretty
```  


# 查询选举状态  
```
# ceph quorum_status | python -mjson.tool
{
    "election_epoch": 118,
    "monmap": {
        "created": "2016-12-16 11:45:55.627125",
        "epoch": 5,
        "fsid": "0657f4e6-0601-430f-b604-bd1219e0ef09",
        "modified": "2016-12-25 09:46:57.098524",
        "mons": [
            {
                "addr": "10.10.10.26:6789/0",
                "name": "ceph-1",
                "rank": 0
            },
            {
                "addr": "10.10.10.27:6789/0",
                "name": "ceph-2",
                "rank": 1
            },
            {
                "addr": "10.10.10.28:6789/0",
                "name": "ceph-3",
                "rank": 2
            }
        ]
    },
    "quorum": [
        0,
        1,
        2
    ],
    "quorum_leader_name": "ceph-1",
    "quorum_names": [
        "ceph-1",
        "ceph-2",
        "ceph-3"
    ]
}
```  
- election_epoch: 总共选举的次数  
- quorum: mon节点rank列表  
- quorum_leader_name: leader节点名称  
- quorum_names: 所有成员的名称  

monmap输出详解  
- created: 创建时间  
- epoch: 当前monmap的版本号  
- mons: 包括每个mon的ip地址和端口号、主机名及rank。rank的计算公式是IP:port越小，rank越小  


# 查看Monitor详细信息  
```
# ceph mon_status | python -mjson.tool
{
    "election_epoch": 118,
    "extra_probe_peers": [],
    "monmap": {
        "created": "2016-12-16 11:45:55.627125",
        "epoch": 5,
        "fsid": "0657f4e6-0601-430f-b604-bd1219e0ef09",
        "modified": "2016-12-25 09:46:57.098524",
        "mons": [
            {
                "addr": "10.10.10.26:6789/0",
                "name": "ceph-1",
                "rank": 0
            },
            {
                "addr": "10.10.10.27:6789/0",
                "name": "ceph-2",
                "rank": 1
            },
            {
                "addr": "10.10.10.28:6789/0",
                "name": "ceph-3",
                "rank": 2
            }
        ]
    },
    "name": "ceph-2",
    "outside_quorum": [],
    "quorum": [
        0,
        1,
        2
    ],
    "rank": 1,
    "state": "peon",
    "sync_provider": []
}
```  

# 查看Monitor概要信息  
```
# ceph mon stat
e5: 3 mons at {ceph-1=10.10.10.26:6789/0,ceph-2=10.10.10.27:6789/0,ceph-3=10.10.10.28:6789/0}, election 
```  
- e5: 表示当前monmap的版本是第5版  
- election epoch 118: 表示选举的总次数  


# 移除Monitor  
```
# ceph mon remove ceph-1
Error EINVAL: removing mon.ceph-1 at 10.10.10.75:6789/0, there will be 2 monitors

# ceph mon stat
7f6b0032e700  0 -- :/3940951470 >> 10.10.10.75:6789/0 pipe(0x7f6afc05cda0 sd=3 :0 s=1 pgs=0 cs=0 l=1 c=0x7f6afc05e060).fault
e2: 2 mons at {ceph-2=10.10.10.76:6789/0,ceph-3=10.10.10.77:6789/0}, election epoch 20, quorum 0,1 ceph-2,ceph-3
```  

# 添加Monitor  
```
# ceph mon add ceph-1 10.10.10.75:6789
adding mon.ceph-1 at 10.10.10.75:6789/0

# ceph mon stat
e3: 3 mons at {ceph-1=10.10.10.75:6789/0,ceph-2=10.10.10.76:6789/0,ceph-3=10.10.10.77:6789/0}, election epoch 22, quorum 1,2 ceph-2,ceph-3
```  

# 获取某个版本的monmap  
版本号为ceph mon_status命令monmap中的epoch值  
```
# ceph mon dump 3
dumped monmap epoch 3
epoch 3
fsid c712f08b-c001-4b1c-969d-abec240138f7
last_changed 2017-05-30 15:48:18.601129
created 2017-03-16 17:52:01.252939
0: 10.10.10.75:6789/0 mon.ceph-1
1: 10.10.10.76:6789/0 mon.ceph-2
2: 10.10.10.77:6789/0 mon.ceph-3
```  

# 如果不加入版本号，默认获取最新的monmap  
```
# ceph mon dump
dumped monmap epoch 3
epoch 3
fsid c712f08b-c001-4b1c-969d-abec240138f7
last_changed 2017-05-30 15:48:18.601129
created 2017-03-16 17:52:01.252939
0: 10.10.10.75:6789/0 mon.ceph-1
1: 10.10.10.76:6789/0 mon.ceph-2
2: 10.10.10.77:6789/0 mon.ceph-3
```  

# 获取Monitor的metadata  
```
# ceph mon metadata ceph-1
{
    "arch": "x86_64",
    "cpu": "Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz",
    "distro": "CentOS",
    "distro_codename": "Core",
    "distro_description": "CentOS Linux release 7.1.1503 (Core) ",
    "distro_version": "7.1.1503",
    "hostname": "ceph-1",
    "kernel_description": "#1 SMP Fri Mar 6 11:36:42 UTC 2015",
    "kernel_version": "3.10.0-229.el7.x86_64",
    "mem_swap_kb": "1679356",
    "mem_total_kb": "1870496",
    "os": "Linux"
}
```  
获取的主要是Monitor所在操作系统的信息  
