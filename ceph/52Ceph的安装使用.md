# ceph的简介和安装部署

# 一、 概述

## 1.1、简介
诞生于2006年的Ceph，是一个开源的分布式存储系统，同时支持对象存储、块设备、文件系统，也是私有云事实上的标准-OpenStack的默认存储后端。

Ceph是一种软件定义存储，可以运行在几乎所有主流的Linux发行版（比如CentOS和Ubuntu）和其它类UNIX操作系统（典型如FreeBSD）。

Ceph是一个统一存储系统，即支持传统的块、文件存储协议，例如SAN和NAS；也支持对象存储协议，例如S3和Swift。

## 1.2、Ceph分布式系统优点

特性丰富：Ceph能够同时提供对象存储、块存储和文件系统存储三种存储服务的统一存储架构，因此能够满足不同应用需求前提下的简化部署和运维，这是Ceph被OpenStack用户热衷的最主要原因

Crush算法：Crush算法是Ceph的两大创新之一，通过Crush算法的寻址操作，Ceph得以摒弃了传统的集中式存储元数据寻址方案。而Crush算法在一致性哈希基础上很好的考虑了容灾域的隔离，使得Ceph能够实现各类负载的副本放置规则，例如跨机房、机架感知等。同时，Crush算法有相当强大的扩展性，理论上可以支持数千个存储节点，这为Ceph在大规模云环境中的应用提供了先天的便利。

高可靠性：Ceph中的数据副本数量可以由管理员自行定义，并可以通过Crush算法指定副本的物理存储位置以分隔故障域，支持数据强一致性的特性也使Ceph具有了高可靠性，可以忍受多种故障场景并自动尝试并行修复。而Ceph本身没有主控节点，扩展起来比较容易，并且理论上，它的性能会随着磁盘数量的增加而线性增长，这又使得Ceph具备了云计算所应该拥有的高扩展性。因此，Ceph能够获得OpenStack用户的青睐也就不足为奇了。

# 二、 环境准备

## 2.1、安装环境：

VMware Workstation 虚拟机

Ubuntu 18.04

### 2.1.1 安装准备：

三台服务器作为 ceph 集群 OSD 存储服务器，每台服务器支持两个网络，public 网络针对客户端访问，cluster 网络用于集群管理及数据同步，每台三块或以上的磁盘。

### 2.1.2 网络规划：

Public 网段 10.0.0.100-108 ，网卡（eht0），供客户端使用。

Cluster 网段 192.168.3.100-108 ，网卡(eth1)，供ceph内部通信，ceph中可以互相通信。

### 2.1.3 各节点IP分配如下表:

| 操作系统 | 主机名 | 角色 | public网络 | cluster网络 | CPU | 内存 | 磁盘 |
|---------|--------|------|-----------|-------------|-----|------|-----|
| Ubuntu18.04 | ceph-deploy | deploy、ceph-common | 10.0.0.100 | 192.168.133.100 | 2G | 2G |  |
| Ubuntu18.04 | ceph-mon1 | mon | 10.0.0.101 | 192.168.133.101 | 2G | 2G |  |
| Ubuntu18.04 | ceph-mon2 | mon | 10.0.0.102 | 192.168.133.102 | 2G | 2G |  |
| Ubuntu18.04 | ceph-mon3 | mon | 10.0.0.103 | 192.168.133.103 | 2G | 2G |  |
| Ubuntu18.04 | ceph-mgr1 | mgr | 10.0.0.104 | 192.168.133.104 | 2G | 2G |  |
| Ubuntu18.04 | ceph-mgr2 | mgr | 10.0.0.105 | 192.168.133.105 | 2G | 2G |  |
| Ubuntu18.04 | ceph-node1 | osd | 10.0.0.106 | 192.168.133.106 | 2G | 2G | 3*20G |
| Ubuntu18.04 | ceph-node2 | osd | 10.0.0.107 | 192.168.133.107 | 2G | 2G | 3*20G |
| Ubuntu18.04 | ceph-node3 | osd | 10.0.0.108 | 192.168.133.108 | 2G | 2G | 3*20G |

### 2.1.4 系统环境准备:
- 时间同步
- 配置主机名和域名解析
- 关闭 selinux 和防火墙
- ceph-deploy 节点到所有节点的ssh免密登陆

### 2.1.5 仓库准备：

所有节点配置 ceph yum 仓库（阿里云源或者清华源等国内源）：

清华镜像源：https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/

阿里云镜像源：https://developer.aliyun.com/mirror/

各节点配置ceph仓库：
```
#导入 key 文件
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
#导入源文件
cat > /etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
EOF
#ceph镜像源
sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic main" >> /etc/apt/sources.list
#导入之后一定要进行更新源
apt update
```

# 三、ceph集群安装步骤

## 3.1创建普通用户

在包含 ceph-deploy 节点的存储节点、mon 节点和 mgr 节点等创建 ceph 用户，管理用户

推荐使用指定的普通用户部署和运行 ceph 集群，普通用户只要能以非交互方式执行 sudo命令执行一些特权命令即可，新版的 ceph-deploy 可以指定包含 root 的在内只要可以执行sudo 命令的用户，不过仍然推荐使用普通用户，比如 ceph、cephuser、cephadmin 这样的用户去管理 ceph 集群。
```
#所有节点
groupadd -r -g 2024 test && useradd -r -m -s /bin/bash -u 2024 -g 2024 test && echo test:123456 | chpasswd
```

## 3.2 配置免秘钥登录：

在部署服务器配置免秘钥登录

在 ceph-deploy 节点配置允许以非交互的方式登录到各 ceph node/mon/mgr 节点，即在ceph-deploy 节点生成秘钥对，然后分发公钥到各被管理节点：

#所有节点
```
vim /etc/sudoers
test ALL=(ALL) NOPASSWD:ALL

root@ceph-deploy:~# su - test
test@ceph-deploy:~$ ssh-keygen
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.101
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.102
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.103
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.104
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.105
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.106
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.107
test@ceph-deploy:~$ ssh-copy-id test@10.0.0.108
```

## 3.3 配置主机名解析：

所有节点添加域名解析
```
vim /etc/hosts
10.0.0.100 ceph-deploy.example.local ceph-deploy 
10.0.0.101 ceph-mon1.example.local ceph-mon1 
10.0.0.102 ceph-mon2.example.local ceph-mon2 
10.0.0.103 ceph-mon3.example.local ceph-mon3 
10.0.0.104 ceph-mgr1.example.local ceph-mgr1 
10.0.0.105 ceph-mgr2.example.local ceph-mgr2 
10.0.0.106 ceph-node1.example.local ceph-node1 
10.0.0.107 ceph-node2.example.local ceph-node2 
10.0.0.108 ceph-node3.example.local ceph-node3
```

## 3.4 安装ceph部署工具：

在ceph部署服务器安装ceph-deploy
```
#查看版本号
test@ceph-deploy:~$ apt-cache madison ceph-deploy
ceph-deploy |      2.0.1 | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic/main amd64 Packages
ceph-deploy |      2.0.1 | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic/main i386 Packages
ceph-deploy | 1.5.38-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic/universe amd64 Packages
ceph-deploy | 1.5.38-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic/universe i386 Packages
#进行安装
test@ceph-deploy:~$ sudo apt install ceph-deploy -y
```

## 3.5 初始化mon节点

在管理节点初始化mon节点
```
test@ceph-deploy:~$ mkdir ceph-cluster
test@ceph-deploy:~$ cd ceph-cluster/
```

初始化mon节点过程如下：

所有节点进行安装python2
```
#安装python2
test@ceph-deploy:~/ceph-cluster$ sudo apt install python2.7 -y
test@ceph-deploy:~/ceph-cluster$ sudo ln -sv /usr/bin/python2.7 /usr/bin/python2
```

## 3.6 初始化 ceph 存储节点

### 3.6.1 修改 ceph 镜像源

各节点配置清华的 ceph 镜像源：

清华源的ceph源地址：https://mirrors.tuna.tsinghua.edu.cn/help/ceph/
```
#添加认证
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
#添加ceph镜像源
sudo apt-add-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-octopus/ buster main'
#进行更新
sudo apt update
```

### 3.6.2 初始化mon节点
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph-deploy new --cluster-network 192.168.133.0/24 --public-network 10.0.0.0/24 ceph-mon1.example.local
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/test/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy new --cluster-network 192.168.133.0/24 --public-network 10.0.0.0/24 ceph-mon1.example.local
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7fda3e58bdc0>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  ssh_copykey                   : True
[ceph_deploy.cli][INFO  ]  mon                           : ['ceph-mon1.example.local']
[ceph_deploy.cli][INFO  ]  func                          : <function new at 0x7fda3b845b50>
[ceph_deploy.cli][INFO  ]  public_network                : 10.0.0.0/24
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster_network               : 192.168.133.0/24
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  fsid                          : None
[ceph_deploy.new][DEBUG ] Creating new cluster named ceph
[ceph_deploy.new][INFO  ] making sure passwordless SSH succeeds
[ceph-mon1.example.local][DEBUG ] connected to host: ceph-deploy 
[ceph-mon1.example.local][INFO  ] Running command: ssh -CT -o BatchMode=yes ceph-mon1.example.local
[ceph_deploy.new][WARNIN] could not connect via SSH
[ceph_deploy.new][INFO  ] will connect again with password prompt
The authenticity of host 'ceph-mon1.example.local (10.0.0.101)' can't be established.
ECDSA key fingerprint is SHA256:L00Cik1v48BApDPHRfbuhBR1inspFDYgI3CVmE048Jg.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'ceph-mon1.example.local' (ECDSA) to the list of known hosts.
[ceph-mon1.example.local][DEBUG ] connected to host: ceph-mon1.example.local 
[ceph-mon1.example.local][DEBUG ] detect platform information from remote host
[ceph-mon1.example.local][DEBUG ] detect machine type
[ceph_deploy.new][INFO  ] adding public keys to authorized_keys
[ceph-mon1.example.local][DEBUG ] append contents to file
[ceph-mon1.example.local][DEBUG ] connection detected need for sudo
[ceph-mon1.example.local][DEBUG ] connected to host: ceph-mon1.example.local 
[ceph-mon1.example.local][DEBUG ] detect platform information from remote host
[ceph-mon1.example.local][DEBUG ] detect machine type
[ceph-mon1.example.local][DEBUG ] find the location of an executable
[ceph-mon1.example.local][INFO  ] Running command: sudo /bin/ip link show
[ceph-mon1.example.local][INFO  ] Running command: sudo /bin/ip addr show
[ceph-mon1.example.local][DEBUG ] IP addresses found: [u'192.168.133.101', u'10.0.0.101']
[ceph_deploy.new][DEBUG ] Resolving host ceph-mon1.example.local
[ceph_deploy.new][DEBUG ] Monitor ceph-mon1 at 10.0.0.101
[ceph_deploy.new][DEBUG ] Monitor initial members are ['ceph-mon1']
[ceph_deploy.new][DEBUG ] Monitor addrs are [u'10.0.0.101']
[ceph_deploy.new][DEBUG ] Creating a random mon key...
[ceph_deploy.new][DEBUG ] Writing monitor keyring to ceph.mon.keyring...
[ceph_deploy.new][DEBUG ] Writing initial config to ceph.conf...
```

### 3.6.3 验证mon节点
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ll
total 24
drwxrwxr-x 2 test test 4096 Aug 20 10:11 ./
drwxr-xr-x 6 test test 4096 Aug 20 10:11 ../
-rw-rw-r-- 1 test test  261 Aug 20 10:11 ceph.conf
-rw-rw-r-- 1 test test 6521 Aug 20 10:11 ceph-deploy-ceph.log
-rw------- 1 test test   73 Aug 20 10:11 ceph.mon.keyring
test@ceph-deploy:~/ceph-cluster$ cat ceph.conf 
[global]
fsid = 635d9577-7341-4085-90ff-cb584029a1ea
public_network = 10.0.0.0/24
cluster_network = 192.168.133.0/24
mon_initial_members = ceph-mon1
mon_host = 10.0.0.101
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
```

## 3.7 初始化 ceph 存储节点

### 3.7.1 初始化 node 节点过程：
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph-deploy install --no-adjust-repos --nogpgcheck ceph-node1 ceph-node2 ceph-node3
```

### 3.7.2 配置 mon 节点并生成及同步秘钥

在各个mon 节点按照组件 ceph-mon,并通初始化 mon 节点，mon 节点 还可以后期横向扩容
```
#mon节点
test@ceph-mon1:~$ sudo apt install ceph-mon -y
test@ceph-mon2:~$ sudo apt install ceph-mon -y
test@ceph-mon3:~$ sudo apt install ceph-mon -y
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph-deploy mon create-initial
test@ceph-deploy:~/ceph-cluster$ ll
total 252
drwxrwxr-x 2 test test 4096 Aug 20 10:31 ./
drwxr-xr-x 6 test test 4096 Aug 20 10:11 ../
-rw------- 1 test test 113 Aug 20 10:31 ceph.bootstrap-mds.keyring
-rw------- 1 test test 113 Aug 20 10:31 ceph.bootstrap-mgr.keyring
-rw------- 1 test test 113 Aug 20 10:31 ceph.bootstrap-osd.keyring
-rw------- 1 test test 113 Aug 20 10:31 ceph.bootstrap-rgw.keyring
-rw------- 1 test test 151 Aug 20 10:31 ceph.client.admin.keyring
-rw-rw-r-- 1 test test 261 Aug 20 10:11 ceph.conf
-rw-rw-r-- 1 test test 216060 Aug 20 10:31 ceph-deploy-ceph.log
-rw------- 1 test test 73 Aug 20 10:11 ceph.mon.keyring
```

### 3.7.3 验证 mon 节点
```
#任一mon节点
test@ceph-mon1:~$ ps -ef|grep mon
ceph 13894 1 0 10:31 ? 00:00:00 /usr/bin/ceph-mon -f --cluster ceph --id ceph-mon1 --setuser ceph --setgroup ceph
```

### 3.7.4 分发 admin 秘钥

在 ceph-deploy 节点把配置文件和 admin 密钥拷贝至 Ceph 集群需要执行 ceph 管理命令的节点，从而不需要后期通过 ceph 命令对 ceph 集群进行管理配置的时候每次都需要指定ceph-mon 节点地址和 ceph.client.admin.keyring 文件,另外各 ceph-mon 节点也需要同步ceph 的集群配置文件与认证文件。

如果在 ceph-deploy 节点管理集群
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ sudo apt install ceph-common -y
test@ceph-deploy:~/ceph-cluster$ ceph-deploy admin ceph-node1 ceph-node2 ceph-node3
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/test/.cephdeploy.conf
[ceph_deploy.cli][INFO ] Invoked (2.0.1): /usr/bin/ceph-deploy admin ceph-node1 ceph-node2 ceph-node3
[ceph_deploy.cli][INFO ] ceph-deploy options:
[ceph_deploy.cli][INFO ] username : None
[ceph_deploy.cli][INFO ] verbose : False
[ceph_deploy.cli][INFO ] overwrite_conf : False
[ceph_deploy.cli][INFO ] quiet : False
[ceph_deploy.cli][INFO ] cd_conf : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f5ff83dc0f0>
[ceph_deploy.cli][INFO ] cluster : ceph
[ceph_deploy.cli][INFO ] client : ['ceph-node1', 'ceph-node2', 'ceph-node3']
[ceph_deploy.cli][INFO ] func : <function admin at 0x7f5ff8cdcad0>
[ceph_deploy.cli][INFO ] ceph_conf : None
[ceph_deploy.cli][INFO ] default_release : False
[ceph_deploy.admin][DEBUG ] Pushing admin keys and conf to ceph-node1
[ceph-node1][DEBUG ] connection detected need for sudo
[ceph-node1][DEBUG ] connected to host: ceph-node1
[ceph-node1][DEBUG ] detect platform information from remote host
[ceph-node1][DEBUG ] detect machine type
[ceph-node1][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph_deploy.admin][DEBUG ] Pushing admin keys and conf to ceph-node2
[ceph-node2][DEBUG ] connection detected need for sudo
[ceph-node2][DEBUG ] connected to host: ceph-node2
[ceph-node2][DEBUG ] detect platform information from remote host
[ceph-node2][DEBUG ] detect machine type
[ceph-node2][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph_deploy.admin][DEBUG ] Pushing admin keys and conf to ceph-node3
[ceph-node3][DEBUG ] connection detected need for sudo
[ceph-node3][DEBUG ] connected to host: ceph-node3
[ceph-node3][DEBUG ] detect platform information from remote host
[ceph-node3][DEBUG ] detect machine type
[ceph-node3][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
```

### 3.7.5 ceph 节点验证秘钥
```
#任一node节点test@ceph-node1:~$ ll /etc/ceph/
total 20
drwxr-xr-x  2 root root 4096 Aug 20 10:34 ./
drwxr-xr-x 80 root root 4096 Aug 20 10:17 ../
-rw-------  1 root root  151 Aug 20 10:34 ceph.client.admin.keyring
-rw-r--r--  1 root root  261 Aug 20 10:34 ceph.conf
-rw-r--r--  1 root root   92 Jul  8 07:17 rbdmap
-rw-------  1 root root    0 Aug 20 10:34 tmpRBS5wO
```

认证文件的属主和属组为了安全考虑，默认设置为了 root 用户和 root 组，如果需要 ceph 用户也能执行 ceph 命令，那么就需要对 ceph 用户进行授权
```
#node节点
test@ceph-node1:~$ sudo setfacl -m u:test:rw /etc/ceph/ceph.client.admin.keyring
test@ceph-node2:~$ sudo setfacl -m u:test:rw /etc/ceph/ceph.client.admin.keyring
test@ceph-node3:~$ sudo setfacl -m u:test:rw /etc/ceph/ceph.client.admin.keyring
```

## 3.8 部署 ceph-mgr 节点

mgr 节点需要读取 ceph 的配置文件

### 3.8.1 部署 ceph-mgr 节点
```
#mgr节点
test@ceph-mgr1:~$apt install ceph-mgr
test@ceph-mgr2:~$apt install ceph-mgr
#deploy节点
test@ceph-deploy:~$ceph-deploy mgr create ceph-mgr1 ceph-mgr2
```

### 3.8.2 验证 ceph-mgr 节点
```
#mgr节点
test@ceph-mgr1:~$ ps -ef|grep ceph
root       8547      1  0 Aug20 ?        00:00:00 /usr/bin/python3.6 /usr/bin/ceph-crash
ceph      21198      1  0 00:05 ?        00:00:09 /usr/bin/ceph-mgr -f --cluster ceph --id ceph-mgr1 --setuser ceph --setgroup ceph
test@ceph-mgr2:~$ ps -ef |grep ceph
root       8549      1  0 Aug20 ?        00:00:00 /usr/bin/python3.6 /usr/bin/ceph-crash
ceph      21109      1  0 00:05 ?        00:00:05 /usr/bin/ceph-mgr -f --cluster ceph --id ceph-mgr2 --setuser ceph --setgroup ceph
```

### 3.8.3 ceph-deploy 管理 ceph 集群
```
#deploy节点
test@ceph-deploy:~$ sudo apt install ceph-common -y
test@ceph-deploy:~$ ceph-deploy admin ceph-deploy
```

### 3.8.4 测试 ceph 命令
```
#deploy节点
test@ceph-deploy:~$ sudo setfacl -m u:ceph:rw /etc/ceph/ceph.client.admin.keyring
test@ceph-deploy:~$ ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim #需要禁用非安全模式通信
            OSD count 0 < osd_pool_default_size 3
 
  services:
    mon: 1 daemons, quorum ceph-mon1 (age 115m)
    mgr: ceph-mgr1(active, since 14h), standbys: ceph-mgr2
    osd: 0 osds: 0 up, 0 in
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:

#去除警告
test@ceph-deploy:~$ ceph config set mon auth_allow_insecure_global_id_reclaim false
```

### 3.8.5 准备 OSD 节点
```
#deploy节点
test@ceph-deploy:~$ ceph-deploy install --release pacific ceph-node1 ceph-node2 ceph-node3
```

### 3.8.6 列出 ceph node 节点磁盘
```
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk list ceph-node1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/test/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list ceph-node1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  debug                         : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : list
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f89c5e16f00>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  host                          : ['ceph-node1']
[ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7f89c5df0350>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph-node1][DEBUG ] connection detected need for sudo
[ceph-node1][DEBUG ] connected to host: ceph-node1 
[ceph-node1][DEBUG ] detect platform information from remote host
[ceph-node1][DEBUG ] detect machine type
[ceph-node1][DEBUG ] find the location of an executable
[ceph-node1][INFO  ] Running command: sudo fdisk -l
[ceph-node1][INFO  ] Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
[ceph-node1][INFO  ] Disk /dev/sdb: 20 GiB, 21474836480 bytes, 41943040 sectors
[ceph-node1][INFO  ] Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
[ceph-node1][INFO  ] Disk /dev/sdd: 20 GiB, 21474836480 bytes, 41943040 sectors
```

### 3.8.7 使用 ceph-deploy disk zap 擦除各 ceph node 的 ceph 数据磁盘
```
#node1
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node1 /dev/sdb
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node1 /dev/sdc
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node1 /dev/sdd
#node2
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node2 /dev/sdb
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node2 /dev/sdc
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node2 /dev/sdd
#node3
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node3 /dev/sdb
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node3 /dev/sdc
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node3 /dev/sdd
```

### 3.8.8 添加 OSD
```
#node1
ceph-deploy osd create ceph-node1 --data /dev/sdb
ceph-deploy osd create ceph-node1 --data /dev/sdc
ceph-deploy osd create ceph-node1 --data /dev/sdd
#node2
ceph-deploy osd create ceph-node2 --data /dev/sdb
ceph-deploy osd create ceph-node2 --data /dev/sdc
ceph-deploy osd create ceph-node2 --data /dev/sdd
#node3
ceph-deploy osd create ceph-node3 --data /dev/sdb
ceph-deploy osd create ceph-node3 --data /dev/sdc
ceph-deploy osd create ceph-node3 --data /dev/sdd
```

### 3.8.9 验证OSD 服务
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 1 daemons, quorum ceph-mon1 (age 2h)
    mgr: ceph-mgr1(active, since 15h), standbys: ceph-mgr2
    osd: 9 osds: 9 up (since 54s), 9 in (since 63s)
 
  data:
    pools:   1 pools, 1 pgs
    objects: 0 objects, 0 B
    usage:   51 MiB used, 180 GiB / 180 GiB avail
    pgs:     1 active+clean

#node节点
test@ceph-node1:~$ ps -ef |grep osd
ceph        2397       1  0 02:02 ?        00:00:00 /usr/bin/ceph-osd -f --cluster ceph --id 0 --setuser ceph --setgroup ceph
ceph        3962       1  0 02:03 ?        00:00:00 /usr/bin/ceph-osd -f --cluster ceph --id 1 --setuser ceph --setgroup ceph
ceph        5516       1  0 02:03 ?        00:00:00 /usr/bin/ceph-osd -f --cluster ceph --id 2 --setuser ceph --setgroup ceph

test@ceph-deploy:~/ceph-cluster$ ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
-1         0.17537  root default                                  
-3         0.05846      host ceph-node1                           
 0    hdd  0.01949          osd.0            up   1.00000  1.00000
 1    hdd  0.01949          osd.1            up   1.00000  1.00000
 2    hdd  0.01949          osd.2            up   1.00000  1.00000
-5         0.05846      host ceph-node2                           
 3    hdd  0.01949          osd.3            up   1.00000  1.00000
 4    hdd  0.01949          osd.4            up   1.00000  1.00000
 5    hdd  0.01949          osd.5            up   1.00000  1.00000
-7         0.05846      host ceph-node3                           
 6    hdd  0.01949          osd.6            up   1.00000  1.00000
 7    hdd  0.01949          osd.7            up   1.00000  1.00000
 8    hdd  0.01949          osd.8            up   1.00000  1.00000
```

## 3.9 测试上传与下载数据

### 3.9.1 创建 pool
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph osd pool create mypool 32 32
pool 'mypool' created
test@ceph-deploy:~/ceph-cluster$ ceph pg ls-by-pool mypool #验证 PG 与 PGP 组合
test@ceph-deploy:~/ceph-cluster$ ceph osd pool ls
device_health_metrics
mypool
```

### 3.9.2 上传文件

当前的 ceph 环境还没还没有部署使用块存储和文件系统使用 ceph，也没有使用对象存储的客户端，但是 ceph 的 rados 命令可以实现访问 ceph 对象存储的功能
```
test@ceph-deploy:~/ceph-cluster$ sudo rados put msg1 /var/log/syslog --pool=mypool
```

### 3.9.3 列出文件
```
test@ceph-deploy:~/ceph-cluster$ rados ls --pool=mypool
msg1
```

### 3.9.4 查看文件信息

ceph osd map 命令可以获取到存储池中数据对象的具体位置信息
```
test@ceph-deploy:~/ceph-cluster$ ceph osd map mypool msg1
osdmap e53 pool 'mypool' (2) object 'msg1' -> pg 2.c833d430 (2.10) -> up ([8,1,5], p8) acting ([8,1,5], p8)
```

### 3.9.5 下载文件
```
test@ceph-deploy:~/ceph-cluster$ sudo rados get msg1 --pool=mypool /opt/my.txt
test@ceph-deploy:~/ceph-cluster$ ll /opt/
total 1000
drwxr-xr-x  2 root root    4096 Aug 21 02:20 ./
drwxr-xr-x 22 root root    4096 Aug 17 17:43 ../
-rw-r--r--  1 root root 1015360 Aug 21 02:20 my.txt
#验证下载文件
test@ceph-deploy:~/ceph-cluster$ head /opt/my.txt
Aug 17 17:51:07 ubuntu systemd[1]: Starting Flush Journal to Persistent Storage...
Aug 17 17:51:07 ubuntu systemd[1]: Started udev Kernel Device Manager.
Aug 17 17:51:07 ubuntu systemd[1]: Starting Network Service...
Aug 17 17:51:07 ubuntu systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
Aug 17 17:51:07 ubuntu systemd[1]: Reached target Local Encrypted Volumes.
Aug 17 17:51:07 ubuntu systemd[1]: Reached target Paths.
Aug 17 17:51:07 ubuntu systemd[1]: Started Commit a transient machine-id on disk.
Aug 17 17:51:07 ubuntu systemd[1]: Started Flush Journal to Persistent Storage.
Aug 17 17:51:07 ubuntu systemd[1]: Starting Create Volatile Files and Directories...
Aug 17 17:51:07 ubuntu apparmor[346]:  * Starting AppArmor profiles
```

### 3.9.6 修改文件
```
test@ceph-deploy:~/ceph-cluster$ sudo rados put msg1 /etc/passwd --pool=mypool
test@ceph-deploy:~/ceph-cluster$ sudo rados get msg1 --pool=mypool /opt/2.txt
#验证下载文件
test@ceph-deploy:~/ceph-cluster$ tail /opt/2.txt
systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd/resolve:/usr/sbin/nologin
syslog:x:102:106::/home/syslog:/usr/sbin/nologin
messagebus:x:103:107::/nonexistent:/usr/sbin/nologin
_apt:x:104:65534::/nonexistent:/usr/sbin/nologin
uuidd:x:105:109::/run/uuidd:/usr/sbin/nologin
lzd:x:1000:1000:liangzhida,,,:/home/lzd:/bin/bash
sshd:x:106:65534::/run/sshd:/usr/sbin/nologin
david:x:2023:2023::/home/david:/bin/bash
ceph:x:2022:2022:Ceph storage service:/var/lib/ceph:/bin/bash
test:x:2024:2024::/home/test:/bin/bash
```

### 3.9.7 删除文件
```
test@ceph-deploy:~/ceph-cluster$ sudo rados rm msg1 --pool=mypool
test@ceph-deploy:~/ceph-cluster$ rados ls --pool=mypool
```

## 3.10 扩展 ceph 集群实现高可用

主要是扩展 ceph 集群的 mon 节点以及 mgr 节点，以实现集群高可用

### 3.10.1 扩展ceph-mon节点

Ceph-mon 是原生具备自选举以实现高可用机制的 ceph 服务，节点数量通常是奇数
```
#mon节点
test@ceph-mon2:~$ sudo apt install ceph-mon
test@ceph-mon3:~$ sudo apt install ceph-mon

#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph-deploy mon add ceph-mon2
test@ceph-deploy:~/ceph-cluster$ ceph-deploy mon add ceph-mon3
```

### 3.10.2 查看ceph-mon 状态
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph quorum_status 
test@ceph-deploy:~/ceph-cluster$ ceph quorum_status --format json-pretty #以json形式展示
```

验证ceph集群
```
test@ceph-deploy:~/ceph-cluster$ ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 6m) #3个mon节点
    mgr: ceph-mgr1(active, since 114m), standbys: ceph-mgr2
    osd: 9 osds: 9 up (since 116m), 9 in (since 13h)
 
  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   58 MiB used, 180 
```

### 3.10.3 扩展 mgr 节点
```
#mgr节点
test@ceph-mgr2:~$ sudo apt install ceph-mgr

#deploy节点
test@ceph-deploy:~/ceph-cluster$ceph-deploy mgr create ceph-mgr2
test@ceph-deploy:~/ceph-cluster$ceph-deploy admin ceph-mgr2
```

### 3.10.4 验证mgr节点
```
test@ceph-deploy:~/ceph-cluster$ ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 6m)
    mgr: ceph-mgr1(active, since 114m), standbys: ceph-mgr2
    osd: 9 osds: 9 up (since 116m), 9 in (since 13h)
 
  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   58 MiB used, 180 GiB / 180 GiB avail
    pgs:     33 active+clean
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph quorum_statusceph ^C
test@ceph-deploy:~/ceph-cluster$ ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 19m)
    mgr: ceph-mgr1(active, since 2h), standbys: ceph-mgr2 #2个mgr节点
    osd: 9 osds: 9 up (since 2h), 9 in (since 13h)
 
  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   58 MiB used, 180 GiB / 180 GiB avail
    pgs:     33 active+clean
```

# 四 ceph 集群应用基础

## 4.1 块设备 RBD

RBD即RADOS Block Device的简称，RBD块存储是最稳定且最常用的存储类型。RBD块设备类似磁盘可以被挂载。 RBD块设备具有快照、多副本、克隆和一致性等特性，数据以条带化的方式存储在Ceph集群的多个OSD，rbd是ceph对外的三大存储服务组件之一，也是当前ceph最稳定，应用最广泛的存储接口。因为以openstack为代表的云计算技术闪电崛起，社区果断调整重心，开始着力发展rbd,并使其成长为最炙手可热的分布式统一存储系统，很大程度上得益于收获了OpenStack的青睐，而RBD取代CephFs伴随OpenStack先一步进入公众视野。

### 4.1.1 创建 RBD
```
创建存储池命令格式： 
ceph osd pool create <poolname> pg_num pgp_num {replicated|erasure}
##创建存储池,指定 pg 和 pgp 的数量
test@ceph-deploy:~/ceph-cluster$ ceph osd pool create  myrbd1  64 64 
pool 'myrbd1' created
#对存储池启用 RBD 功能
test@ceph-deploy:~/ceph-cluster$ ceph osd pool application enable myrbd1 rbd  
enabled application 'rbd' on pool 'myrbd1'
#通过 RBD 命令对存储池初始化
test@ceph-deploy:~/ceph-cluster$ rbd pool init -p myrbd1 
```

### 4.1.2 创建并验证 img
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ rbd create myimg1 --size 5G --pool myrbd1
test@ceph-deploy:~/ceph-cluster$ rbd create myimg2 --size 3G --pool myrbd1 --image-format 2 --image-feature layering
test@ceph-deploy:~/ceph-cluster$ rbd ls --pool myrbd1 #列出指定pool的所有img
myimg1
myimg2

test@ceph-deploy:~/ceph-cluster$ rbd --image myimg1 --pool myrbd1 info ##查看指定 rdb 的信息
rbd image 'myimg1':
    size 5 GiB in 1280 objects
    order 22 (4 MiB objects)
    snapshot_count: 0
    id: 854bfce43c75
    block_name_prefix: rbd_data.854bfce43c75
    format: 2
    features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
    op_features: 
    flags: 
    create_timestamp: Sun Aug 22 00:05:24 2021
    access_timestamp: Sun Aug 22 00:05:24 2021
    modify_timestamp: Sun Aug 22 00:05:24 2021
    
test@ceph-deploy:~/ceph-cluster$ rbd --image myimg2 --pool myrbd1 info
rbd image 'myimg2':
    size 3 GiB in 768 objects
    order 22 (4 MiB objects)
    snapshot_count: 0
    id: 5eaa6176a42a
    block_name_prefix: rbd_data.5eaa6176a42a
    format: 2
    features: layering
    op_features: 
    flags: 
    create_timestamp: Sun Aug 22 00:05:32 2021
    access_timestamp: Sun Aug 22 00:05:32 2021
    modify_timestamp: Sun Aug 22 00:05:32 2021
```

### 4.1.3 客户端使用块存储
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL    USED  RAW USED  %RAW USED
hdd    180 GiB  180 GiB  62 MiB    62 MiB       0.03
TOTAL  180 GiB  180 GiB  62 MiB    62 MiB       0.03
 
--- POOLS ---
POOL                   ID  PGS  STORED  OBJECTS    USED  %USED  MAX AVAIL
device_health_metrics   1    1     0 B        0     0 B      0     57 GiB
mypool                  2   32     0 B        0     0 B      0     57 GiB
myrbd1                  3   64   405 B        7  48 KiB      0     57 GiB
```

### 4.1.4 客户端映射 img
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ sudo rbd -p myrbd1 map myimg2
/dev/rbd0
  test@ceph-deploy:~/ceph-cluster$ sudo rbd -p myrdb1 map myimg1
  rbd: sysfs write failed
  In some cases useful info is found in syslog - try "dmesg | tail".
  rbd: map failed: (2) No such file or directory
  test@ceph-deploy:~/ceph-cluster$ sudo rbd -p myrbd1 map myimg1
  rbd: sysfs write failed
  RBD image feature set mismatch. You can disable features unsupported by the kernel with "rbd feature disable myrbd1/myimg1 object-map fast-diff deep-flatten". # 使用这个命令就可以了
  In some cases useful info is found in syslog - try "dmesg | tail".
  rbd: map failed: (6) No such device or address
  test@ceph-deploy:~/ceph-cluster$ rbd feature disable myrbd1/myimg1 object-map fast-diff deep-flatten
  test@ceph-deploy:~/ceph-cluster$ sudo rbd -p myrbd1 map myimg1
  /dev/rbd2
```

### 4.1.5 客户端验证 RBD
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk 
└─sda1   8:1    0   20G  0 part /
sr0     11:0    1 1024M  0 rom  
rbd0   252:0    0    3G  0 disk 
rbd1   252:16   0    3G  0 disk 
rbd2   252:32   0    5G  0 disk
```

### 4.1.6 客户端格式化磁盘并挂载使用
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ sudo mkfs.xfs /dev/rbd0
meta-data=/dev/rbd0              isize=512    agcount=9, agsize=97280 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=786432, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

test@ceph-deploy:~/ceph-cluster$ sudo mount /dev/rbd0 /data

test@ceph-deploy:~/ceph-cluster$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            964M     0  964M   0% /dev
tmpfs           198M  6.7M  191M   4% /run
/dev/sda1        20G  2.9G   16G  16% /
tmpfs           986M     0  986M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           986M     0  986M   0% /sys/fs/cgroup
tmpfs           198M     0  198M   0% /run/user/1000
/dev/rbd0       3.0G   36M  3.0G   2% /data
```

### 4.1.7 客户端验证
```
#deploy节点
test@ceph-deploy:/data$ sudo cp /var/log/syslog /data
test@ceph-deploy:/data$ ll /data
total 1352
drwxr-xr-x  2 root root      20 Aug 22 00:35 ./
drwxr-xr-x 23 root root    4096 Aug 22 00:29 ../
-rw-r-----  1 root root 1378283 Aug 22 00:35 syslog
```

### 4.1.8 ceph 验证数据
```
#deploy节点
test@ceph-deploy:/data$ ceph df 
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
hdd    180 GiB  180 GiB  141 MiB   141 MiB       0.08
TOTAL  180 GiB  180 GiB  141 MiB   141 MiB       0.08
 
--- POOLS ---
POOL                   ID  PGS  STORED  OBJECTS    USED  %USED  MAX AVAIL
device_health_metrics   1    1     0 B        0     0 B      0     57 GiB
mypool                  2   32     0 B        0     0 B      0     57 GiB
myrbd1                  3   64  12 MiB       19  35 MiB   0.02     57 GiB
```

## 4.2 ceph radosgw(RGW)对象存储

RGW 提供的是 REST 接口，客户端通过 http 与其进行交互，完成数据的增删改查等管理操作。

### 4.2.1 部署 radosgw 服务

如果是在使用 radosgw 的场合，则以下命令将 ceph-mgr1 服务器部署为 RGW 主机
```
#mgr节点
test@ceph-mgr1:~$ apt-cache madison radosgw
   radosgw | 16.2.5-1bionic | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic/main amd64 Packages
   radosgw | 12.2.13-0ubuntu0.18.04.8 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 Packages
   radosgw | 12.2.13-0ubuntu0.18.04.4 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-security/main amd64 Packages
   radosgw | 12.2.4-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic/main amd64 Packages
test@ceph-mgr1:~$ sudo apt install radosgw=16.2.5-1bionic
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Suggested packages:
  gawk
The following NEW packages will be installed:
  radosgw
0 upgraded, 1 newly installed, 0 to remove and 100 not upgraded.
Need to get 10.5 MB of archives.
After this operation, 41.1 MB of additional disk space will be used.
Get:1 https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic/main amd64 radosgw amd64 16.2.5-1bionic [10.5 MB]
Fetched 10.5 MB in 4s (2,876 kB/s)  
Selecting previously unselected package radosgw.
(Reading database ... 94119 files and directories currently installed.)
Preparing to unpack .../radosgw_16.2.5-1bionic_amd64.deb ...
Unpacking radosgw (16.2.5-1bionic) ...
Setting up radosgw (16.2.5-1bionic) ...
Created symlink /etc/systemd/system/multi-user.target.wants/ceph-radosgw.target → /lib/systemd/system/ceph-radosgw.target.
Created symlink /etc/systemd/system/ceph.target.wants/ceph-radosgw.target → /lib/systemd/system/ceph-radosgw.target.
Processing triggers for libc-bin (2.27-3ubuntu1.2) ...
Processing triggers for systemd (237-3ubuntu10.42) ...
Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
Processing triggers for ureadahead (0.100.0-21) ...

#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph-deploy --overwrite-conf rgw create ceph-mgr1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/test/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy --overwrite-conf rgw create ceph-mgr1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  rgw                           : [('ceph-mgr1', 'rgw.ceph-mgr1')]
[ceph_deploy.cli][INFO  ]  overwrite_conf                : True
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f74f2b8beb0>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function rgw at 0x7f74f34357d0>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.rgw][DEBUG ] Deploying rgw, cluster ceph hosts ceph-mgr1:rgw.ceph-mgr1
[ceph-mgr1][DEBUG ] connection detected need for sudo
[ceph-mgr1][DEBUG ] connected to host: ceph-mgr1 
[ceph-mgr1][DEBUG ] detect platform information from remote host
[ceph-mgr1][DEBUG ] detect machine type
[ceph_deploy.rgw][INFO  ] Distro info: Ubuntu 18.04 bionic
[ceph_deploy.rgw][DEBUG ] remote host will use systemd
[ceph_deploy.rgw][DEBUG ] deploying rgw bootstrap to ceph-mgr1
[ceph-mgr1][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph-mgr1][WARNIN] rgw keyring does not exist yet, creating one
[ceph-mgr1][DEBUG ] create a keyring file
[ceph-mgr1][DEBUG ] create path recursively if it doesn't exist
[ceph-mgr1][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.ceph-mgr1 osd allow rwx mon allow rw -o /var/lib/ceph/radosgw/ceph-rgw.ceph-mgr1/keyring
[ceph-mgr1][INFO  ] Running command: sudo systemctl enable ceph-radosgw@rgw.ceph-mgr1
[ceph-mgr1][WARNIN] Created symlink /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.ceph-mgr1.service → /lib/systemd/system/ceph-radosgw@.service.
[ceph-mgr1][INFO  ] Running command: sudo systemctl start ceph-radosgw@rgw.ceph-mgr1
[ceph-mgr1][INFO  ] Running command: sudo systemctl enable ceph.target
[ceph_deploy.rgw][INFO  ] The Ceph Object Gateway (RGW) is now running on host ceph-mgr1 and default port 7480
```

### 4.2.2 验证 radosgw 服务
```
#mgr节点
test@ceph-mgr1:~$ ps -aux | grep radosgw
ceph       3066  0.3  2.8 6277048 56936 ?       Ssl  00:51   0:00 /usr/bin/radosgw -f --cluster ceph --name client.rgw.ceph-mgr1 --setuser ceph --setgroup ceph
test       3727  0.0  0.0  14436  1020 pts/0    S+   00:54   0:00 grep --color=auto radosgw
```

```
curl 10.0.0.104:7480
```

### 4.2.3 验证 ceph 状态
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 91m)
    mgr: ceph-mgr1(active, since 3h), standbys: ceph-mgr2
    osd: 9 osds: 9 up (since 3h), 9 in (since 14h)
    rgw: 1 daemon active (1 hosts, 1 zones)
 
  data:
    pools:   7 pools, 201 pgs
    objects: 240 objects, 16 MiB
    usage:   220 MiB used, 180 GiB / 180 GiB avail
    pgs:     201 active+clean
```

### 4.2.4 验证 radosgw 存储池
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph osd pool ls
device_health_metrics
mypool
myrbd1
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta
```

## 4.3 Ceph-FS 文件存储

Ceph FS 即 ceph filesystem，可以实现文件系统共享功能,客户端通过 ceph 协议挂载并使用ceph 集群作为数据存储服务器。

Ceph FS 需要运行 Meta Data Services(MDS)服务，其守护进程为 ceph-mds，ceph-mds 进程管理与 cephFS 上存储的文件相关的元数据，并协调对 ceph 存储集群的访问。

### 4.3.1 部署 MDS 服务

在指定的 ceph-mds 服务器部署 ceph-mds 服务，可以和其它服务器混用(如 ceph-mon、ceph-mgr)
```
#mgr节点
test@ceph-mgr1:~$ sudo apt-cache madison ceph-mds
  ceph-mds | 16.2.5-1bionic | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic/main amd64 Packages
  ceph-mds | 12.2.13-0ubuntu0.18.04.8 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/universe amd64 Packages
  ceph-mds | 12.2.13-0ubuntu0.18.04.4 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-security/universe amd64 Packages
  ceph-mds | 12.2.4-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic/universe amd64 Packages
test@ceph-mgr1:~$ sudo apt install  ceph-mds=16.2.5-1bionic
Reading package lists... Done
Building dependency tree       
Reading state information... Done
ceph-mds is already the newest version (16.2.5-1bionic).
ceph-mds set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 100 not upgraded.


#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph-deploy mds create ceph-mgr1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/test/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy mds create ceph-mgr1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7fe1ee28db90>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function mds at 0x7fe1ee26a450>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  mds                           : [('ceph-mgr1', 'ceph-mgr1')]
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.mds][DEBUG ] Deploying mds, cluster ceph hosts ceph-mgr1:ceph-mgr1
[ceph-mgr1][DEBUG ] connection detected need for sudo
[ceph-mgr1][DEBUG ] connected to host: ceph-mgr1 
[ceph-mgr1][DEBUG ] detect platform information from remote host
[ceph-mgr1][DEBUG ] detect machine type
[ceph_deploy.mds][INFO  ] Distro info: Ubuntu 18.04 bionic
[ceph_deploy.mds][DEBUG ] remote host will use systemd
[ceph_deploy.mds][DEBUG ] deploying mds bootstrap to ceph-mgr1
[ceph-mgr1][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph-mgr1][WARNIN] mds keyring does not exist yet, creating one
[ceph-mgr1][DEBUG ] create a keyring file
[ceph-mgr1][DEBUG ] create path if it doesn't exist
[ceph-mgr1][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.ceph-mgr1 osd allow rwx mds allow mon allow profile mds -o /var/lib/ceph/mds/ceph-ceph-mgr1/keyring
[ceph-mgr1][INFO  ] Running command: sudo systemctl enable ceph-mds@ceph-mgr1
[ceph-mgr1][WARNIN] Created symlink /etc/systemd/system/ceph-mds.target.wants/ceph-mds@ceph-mgr1.service → /lib/systemd/system/ceph-mds@.service.
[ceph-mgr1][INFO  ] Running command: sudo systemctl start ceph-mds@ceph-mgr1
[ceph-mgr1][INFO  ] Running command: sudo systemctl enable ceph.target
```

### 4.3.2 验证 MDS 服务
```
#deploy节点
MDS 服务目前还无法正常使用，需要为 MDS 创建存储池用于保存 MDS 的数据。
test@ceph-deploy:~/ceph-cluster$ ceph mds stat
 1 up:standby
```

### 4.3.3 创建 CephFS metadata 和 data 存储池

使用 CephFS 之前需要事先于集群中创建一个文件系统，并为其分别指定元数据和数据相关的存储池，如下命令将创建名为 mycephfs 的文件系统，它使用 cephfs-metadata 作为元数据存储池，使用 cephfs-data 为数据存储池
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph osd pool create cephfs-metadata 32 32
pool 'cephfs-metadata' created
test@ceph-deploy:~/ceph-cluster$ ceph osd pool create cephfs-data 64 64
pool 'cephfs-data' created
test@ceph-deploy:~/ceph-cluster$ ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 23m)
    mgr: ceph-mgr2(active, since 23m), standbys: ceph-mgr1
    osd: 9 osds: 9 up (since 23m), 9 in (since 31m)
    rgw: 1 daemon active (1 hosts, 1 zones)
 
  data:
    pools:   9 pools, 297 pgs
    objects: 239 objects, 12 MiB
    usage:   163 MiB used, 180 GiB / 180 GiB avail
    pgs:     297 active+clean
```

### 4.3.4 创建 cephFS 并验证
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph fs new mycephfs cephfs-metadata cephfs-data
new fs with metadata pool 8 and data pool 9
test@ceph-deploy:~/ceph-cluster$ ceph fs ls
name: mycephfs, metadata pool: cephfs-metadata, data pools: [cephfs-data ]
test@ceph-deploy:~/ceph-cluster$ ceph fs status mycephfs
mycephfs - 0 clients
========
RANK  STATE      MDS        ACTIVITY     DNS    INOS   DIRS   CAPS  
 0    active  ceph-mgr1  Reqs:    0 /s    10     13     12      0   
      POOL         TYPE     USED  AVAIL  
cephfs-metadata  metadata  96.0k  56.9G  
  cephfs-data      data       0   56.9G  
MDS version: ceph version 16.2.5 (0883bdea7337b95e4b611c768c0279868462204a) pacific (stable)
```

### 4.3.5 验证cephfs的状态
```
#deploy节点
test@ceph-deploy:~/ceph-cluster$ ceph mds stat
mycephfs:1 {0=ceph-mgr1=up:active}
```

### 4.3.6 客户端挂载cephfs

在 ceph 的客户端测试 cephfs 的挂载，需要指定 mon 节点的 6789 端口

## 5.1 ceph 集群维护

### 5.1.1 通过套接字进行单机管理
```
#node节点
test@ceph-node1:~$ sudo ls /var/run/ceph/ -l
total 0
srwxr-xr-x 1 ceph ceph 0 Aug 27 10:40 ceph-osd.0.asok
srwxr-xr-x 1 ceph ceph 0 Aug 27 10:40 ceph-osd.1.asok
srwxr-xr-x 1 ceph ceph 0 Aug 27 10:40 ceph-osd.2.asok

#mon节点
test@ceph-mon1:~$ sudo ls /var/run/ceph/ -l
total 0
srwxr-xr-x 1 ceph ceph 0 Aug 27 10:40 ceph-mon.ceph-mon1.asok

#mon节点
#查看mon的状态
test@ceph-mon1:~$ sudo ceph --admin-daemon /var/run/ceph/ceph-mon.ceph-mon1.asok mon_status

#查看配置信息
test@ceph-mon1:~$ sudo ceph --admin-daemon /var/run/ceph/ceph-mon.ceph-mon1.asok config show
```

### 5.1.2 ceph 集群的停止或重启

重启之前，要提前设置 ceph 集群不要将 OSD 标记为 out，避免 node 节点关闭服务后被踢出ceph 集群外
```
#deploy节点
test@ceph-deploy:~$ ceph osd set noout #关闭服务前设置 noout
noout is set


test@ceph-deploy:~$ ceph osd unset noout #启动服务后取消 noout
noout is unset
```

### 5.1.3 关闭顺序
```
#关闭服务前设置 noout-->ceph osd set noout
关闭存储客户端停止读写数据 
如果使用了 RGW，关闭 RGW
关闭 cephfs 元数据服务 
关闭 ceph OSD 
关闭 ceph manager 
关闭 ceph monitor
```

### 5.1.4 启动顺序
```
启动 ceph monitor
启动 ceph manager
启动 ceph OSD
关闭 cephfs 元数据服务
启动 RGW
启动存储客户端
#启动服务后取消 noout-->ceph osd unset noout
```

### 5.1.5 添加服务器
```
1.先添加仓库源 

2.初始化 node 节点过程
test@ceph-deploy:~/ceph-cluster$ ceph-deploy install --release pacific ceph-node4 

3.擦除磁盘
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node4 /dev/sdb
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node4 /dev/sdc
test@ceph-deploy:~/ceph-cluster$ ceph-deploy disk zap ceph-node4 /dev/sdd

4.添加 osd
test@ceph-deploy:~/ceph-cluster$ ceph-deploy osd create ceph-node4 --data /dev/sdb
test@ceph-deploy:~/ceph-cluster$ ceph-deploy osd create ceph-node4 --data /dev/sdc
test@ceph-deploy:~/ceph-cluster$ ceph-deploy osd create ceph-node4 --data /dev/sdd
```

### 5.1.6 删除服务器

停止服务器之前要把服务器的 OSD 先停止并从 ceph 集群删除

#### 1. 把 osd 踢出集群
```
root@ceph-deploy:~/ceph-cluster# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
-1         0.23383  root default                                  
-3         0.05846      host ceph-node1                           
 0    hdd  0.01949          osd.0            up   1.00000  1.00000
 1    hdd  0.01949          osd.1            up   1.00000  1.00000
 2    hdd  0.01949          osd.2            up   1.00000  1.00000
-5         0.05846      host ceph-node2                           
 3    hdd  0.01949          osd.3            up   1.00000  1.00000
 4    hdd  0.01949          osd.4            up   1.00000  1.00000
 5    hdd  0.01949          osd.5            up   1.00000  1.00000
-7         0.05846      host ceph-node3                           
 6    hdd  0.01949          osd.6            up   1.00000  1.00000
 7    hdd  0.01949          osd.7            up   1.00000  1.00000
 8    hdd  0.01949          osd.8            up   1.00000  1.00000
-9         0.05846      host node4                                
 9    hdd  0.01949          osd.9            up   1.00000  1.00000
10    hdd  0.01949          osd.10           up   1.00000  1.00000
11    hdd  0.01949          osd.11           up   1.00000  1.00000

#先标记为out，标记后再次查看状态，可以发现权重置为0了，但状态还是up
root@ceph-deploy:~/ceph-cluster# ceph osd out osd.9
marked out osd.9. 
root@ceph-deploy:~/ceph-cluster# ceph osd out osd.10
marked out osd.10. 
root@ceph-deploy:~/ceph-cluster# ceph osd out osd.11
marked out osd.11.
```

#### 2. 等一段时间

一段时间后，权重置为0
```
root@ceph-deploy:~/ceph-cluster# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
-1         0.23383  root default                                  
-3         0.05846      host ceph-node1                           
 0    hdd  0.01949          osd.0            up   1.00000  1.00000
 1    hdd  0.01949          osd.1            up   1.00000  1.00000
 2    hdd  0.01949          osd.2            up   1.00000  1.00000
-5         0.05846      host ceph-node2                           
 3    hdd  0.01949          osd.3            up   1.00000  1.00000
 4    hdd  0.01949          osd.4            up   1.00000  1.00000
 5    hdd  0.01949          osd.5            up   1.00000  1.00000
-7         0.05846      host ceph-node3                           
 6    hdd  0.01949          osd.6            up   1.00000  1.00000
 7    hdd  0.01949          osd.7            up   1.00000  1.00000
 8    hdd  0.01949          osd.8            up   1.00000  1.00000
-9         0.05846      host node4                                
 9    hdd  0.01949          osd.9            up         0  1.00000
10    hdd  0.01949          osd.10           up         0  1.00000
11    hdd  0.01949          osd.11           up         0  1.00000
```

#### 3. 停止 osd.x 进程

要先去对应的节点上停止ceph-osd服务，否则rm不了
```
root@node4:~# systemctl stop ceph-osd@9.service 
root@node4:~# systemctl stop ceph-osd@10.service 
root@node4:~# systemctl stop ceph-osd@11.service 
```

#### 4. 删除 osd

停止了对应的osd服务，状态会从up变为down，再进行rm，状态会再进行变化成DNE
```
root@ceph-deploy:~/ceph-cluster# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
-1         0.23383  root default                                  
-3         0.05846      host ceph-node1                           
 0    hdd  0.01949          osd.0            up   1.00000  1.00000
 1    hdd  0.01949          osd.1            up   1.00000  1.00000
 2    hdd  0.01949          osd.2            up   1.00000  1.00000
-5         0.05846      host ceph-node2                           
 3    hdd  0.01949          osd.3            up   1.00000  1.00000
 4    hdd  0.01949          osd.4            up   1.00000  1.00000
 5    hdd  0.01949          osd.5            up   1.00000  1.00000
-7         0.05846      host ceph-node3                           
 6    hdd  0.01949          osd.6            up   1.00000  1.00000
 7    hdd  0.01949          osd.7            up   1.00000  1.00000
 8    hdd  0.01949          osd.8            up   1.00000  1.00000
-9         0.05846      host node4                                
 9    hdd  0.01949          osd.9          down         0  1.00000
10    hdd  0.01949          osd.10         down         0  1.00000
11    hdd  0.01949          osd.11         down         0  1.000

root@ceph-deploy:~/ceph-cluster# ceph osd rm osd.9
removed osd.9
root@ceph-deploy:~/ceph-cluster# ceph osd rm osd.10
removed osd.10
root@ceph-deploy:~/ceph-cluster# ceph osd rm osd.11
removed osd.11
root@ceph-deploy:~/ceph-cluster# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
-1         0.23383  root default                                  
-3         0.05846      host ceph-node1                           
 0    hdd  0.01949          osd.0            up   1.00000  1.00000
 1    hdd  0.01949          osd.1            up   1.00000  1.00000
 2    hdd  0.01949          osd.2            up   1.00000  1.00000
-5         0.05846      host ceph-node2                           
 3    hdd  0.01949          osd.3            up   1.00000  1.00000
 4    hdd  0.01949          osd.4            up   1.00000  1.00000
 5    hdd  0.01949          osd.5            up   1.00000  1.00000
-7         0.05846      host ceph-node3                           
 6    hdd  0.01949          osd.6            up   1.00000  1.00000
 7    hdd  0.01949          osd.7            up   1.00000  1.00000
 8    hdd  0.01949          osd.8            up   1.00000  1.00000
-9         0.05846      host node4                                
 9    hdd  0.01949          osd.9           DNE         0         
10    hdd  0.01949          osd.10          DNE         0         
11    hdd  0.01949          osd.11          DNE         0

#在crush算法中和auth验证中删除
root@ceph-deploy:~/ceph-cluster# ceph osd crush remove osd.9
removed item id 9 name 'osd.9' from crush map
root@ceph-deploy:~/ceph-cluster# ceph osd crush remove osd.10
removed item id 10 name 'osd.10' from crush map
root@ceph-deploy:~/ceph-cluster# ceph osd crush remove osd.11
removed item id 11 name 'osd.11' from crush map
root@ceph-deploy:~/ceph-cluster# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
-1         0.17537  root default                                  
-3         0.05846      host ceph-node1                           
 0    hdd  0.01949          osd.0            up   1.00000  1.00000
 1    hdd  0.01949          osd.1            up   1.00000  1.00000
 2    hdd  0.01949          osd.2            up   1.00000  1.00000
-5         0.05846      host ceph-node2                           
 3    hdd  0.01949          osd.3            up   1.00000  1.00000
 4    hdd  0.01949          osd.4            up   1.00000  1.00000
 5    hdd  0.01949          osd.5            up   1.00000  1.00000
-7         0.05846      host ceph-node3                           
 6    hdd  0.01949          osd.6            up   1.00000  1.00000
 7    hdd  0.01949          osd.7            up   1.00000  1.00000
 8    hdd  0.01949          osd.8            up   1.00000  1.00000
-9               0      host node4
```
  
5.OSD全部操作完成后下线主机
