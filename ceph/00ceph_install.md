# 部署方式
- ceph-ansible: https://github.com/ceph/ceph-ansible #python
- ceph-salt: https://github.com/ceph/ceph-salt #python
- ceph-container: https://github.com/ceph/ceph-container #shell
- ceph-chef: https://github.com/ceph/ceph-chef #Ruby
- cephadm: https://docs.ceph.com/en/latest/cephadm/ #ceph官方在ceph15版本加入的
- ceph-deploy: https://github.com/ceph/ceph-deploy #python 是一个ceph官方维护基于ceph-deploy命令行部署的工具，基于ssh执行可以sudo权限的shell命令以及一些python脚本，实现cephalexin集群的部署和管理维护。Ceph-deploy只用于部署和管理ceph集群，客户端需要访问ceph，需要部署客户端工具



官方网站: http://ceph.org.cn/

官方yum源: https://download.ceph.com/rpm-hammer/

官方提供ansible部署:http://docs.ceph.com/ceph-ansible/master/


# 一、安装前准备

> 1、阿里云ceph源地址 https://mirrors.aliyun.com/ceph/
```
rpm-giant/	-	2015-09-16 02:58
rpm-hammer/	-	2016-06-22 02:21
rpm-infernalis/	-	2016-01-07 02:19
rpm-jewel/	-	2017-03-07 20:49
rpm-kraken/	-	2016-10-13 20:29
rpm-luminous/	-	2020-01-31 23:20
rpm-mimic/	-	2018-05-04 23:51
rpm-nautilus/	-	2020-02-01 05:06
rpm-octopus/	-	2022-03-01 20:36
rpm-pacific/	-	2021-12-08 07:59
rpm-quincy/	-	2022-04-20 08:51
rpm-testing/	-	2014-08-26 00:10
tarballs/	-	2022-04-20 08:41
testing-octopus/	-	2020-03-25 03:20
timestamp	11.0 B	2022-04-26 15:00
```

ceph的yum源安装在noarch路径下ceph-release安装包，直接下载安装即可
```
https://mirrors.aliyun.com/ceph/rpm-octopus/el7/noarch/ceph-release-1-1.el7.noarch.rpm
```

> 2、配置 yum源
``` 
# cat /etc/yum.repos.d/ceph.repo 
[ceph]
name=ceph
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/x86_64/
gpgcheck=0
priority=1

[ceph-noarch]
name=cephnoarch
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/noarch/
gpgcheck=0
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/SRPMS
enabled=0
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.aliyun.com/ceph/keys/release.asc
priority=1
```

``` 
# wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# sed -i 's/http/https/g' /etc/yum.repos.d/CentOS-Base.repo
# yum -y install epel-release
```

> 2、配置NTP
```
yum -y install ntpdate ntp
ntpdate  ntp.aliyun.com
systemctl restart ntpd  && systemctl enable ntpd
```  

> 3、创建部署用户和ssh免密码登录
```
useradd ceph
echo 123456 | passwd --stdin ceph
echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
chmod 0440 /etc/sudoers.d/ceph
```

> 4、配置防火墙，或者关闭
```
#firewall-cmd --zone=public --add-port=6789/tcp --permanent
#firewall-cmd --zone=public --add-port=6800-7100/tcp --permanent
#firewall-cmd --reload
#firewall-cmd --zone=public --list-all
```

> 5、关闭 selinux
```
sed -i "/^SELINUX/s/enforcing/disabled/" /etc/selinux/config
setenforce 0
```

> 6、配置主机名解析，使用  /etc/hosts,或者dns
```
cat >>/etc/hosts<<EOF
192.168.101.66   node01
192.168.101.67   node02
192.168.101.68   node03
EOF
```

> 7、配置sudo不需要tty

手动修改配置文件,注释Defaults requiretty  
```
# sed -i 's/Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers
```


# 二、使用 ceph-deploy 部署集群

> 1、配置免密钥登录
```
su - ceph
ssh-keygen
ssh-copy-id ceph@node01
ssh-copy-id ceph@node02
ssh-copy-id ceph@node03
```  

> 2、安装 ceph-deploy
```
# sudo yum install -y ceph-deploy python-pip
# mkdir my-cluster
# cd my-cluster
```

```
# ceph-deploy --help
usage: ceph-deploy [-h] [-v | -q] [--version] [--username USERNAME] [--overwrite-conf]
                   [--ceph-conf CEPH_CONF]
                   COMMAND ...

Easy Ceph deployment

    -^-
   /   \
   |O o|  ceph-deploy v2.0.1
   ).-.(
  '/|||\`
  | '|` |
    '|`

Full documentation can be found at: http://ceph.com/ceph-deploy/docs

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         be more verbose
  -q, --quiet           be less verbose
  --version             the current installed version of ceph-deploy
  --username USERNAME   the username to connect to the remote host
  --overwrite-conf      overwrite an existing conf file on remote host (if present)
  --ceph-conf CEPH_CONF
                        use (or reuse) a given ceph.conf file

commands:
  COMMAND               description
    new                 Start deploying a new cluster, and write a CLUSTER.conf and keyring for it.   # 开始部署一个新的ceph存储集群，并生成CLUSTER.conf集群配置文件和keyring认证文件
    install             Install Ceph packages on remote hosts.                                        # 在远程主机上安装ceph相关的软件包，可以通过--release指定安装的版本
    mds                 Ceph MDS daemon management                                                    # 管理MDS守护程序（Ceph Metadata Server,ceph 管理守护程序）
    mgr                 Ceph MGR daemon management                                                    # 管理MGR守护程序（ceph-mgr,Ceph Manager DaemonCeph 管理器守护程序）
    mon                 Ceph MON Daemon management                                                    # 管理MON守护程序（ceph-mon,ceph监视器）
    rgw                 Ceph RGW daemon management                                                    # 管理RGW守护程序（RADOSGW,对象存储网关）
    gatherkeys          Gather authentication keys for provisioning new nodes.                        # 从指定获取提供新节点的验证keys,这些keys会在添加新的MON/OSD/MDR 加入的时候使用
    disk                Manage disks on a remote host.                                                # 管理远程主机磁盘
    osd                 Prepare a data disk on remote host.                                           # 在远程主机准备数据盘，即将指定远程主机的指定磁盘添加到ceph集群作为osd使用
    admin               Push configuration and client.admin key to a remote host.                     # 推送ceph集群配置文件和client.admin认证文件到远程主机
    config              Copy ceph.conf to/from remote host(s)                                         # 将ceph.conf配置文件推送到远程主机或从远程主机拷贝
    repo                Repo definition management                                                    # 远程主机仓库管理
    purge               Remove Ceph packages from remote hosts and purge all data.                    # 删除远程主机的安装包和所有数据
    purgedata           Purge (delete, destroy, discard, shred) any Ceph data from /var/lib/ceph      # 从/var/lib/ceph 删除ceph数据，会删除/etc/ceph 下的内容
    uninstall           Remove Ceph packages from remote hosts.                                       # 从远端主机删除安装包
    calamari            Install and configure Calamari nodes. Assumes that a repository with          # 安装并配置一个calamari web 节点，calamari是一个web监控平台
                        Calamari packages is already configured. Refer to the docs for examples
                        (http://ceph.com/ceph-deploy/docs/conf.html)
    forgetkeys          Remove authentication keys from the local directory.                          # 从本地主机删除所有的验证keyring,包括client.admin,monitor,bootstrap等认证文件
    pkg                 Manage packages on remote hosts.                                              # 管理远程主机的安装包

See 'ceph-deploy <command> --help' for help on a specific command
```

> 3、部署节点,参数为monitor结点的主机名列表 
```
# ceph-deploy new node01 node02 node03               # 可以指定参数 ceph-deploy new --cluster-network 192.168.0.0/21 --public-network 172.31.0.0/21 node01

# 该命令会在当前目录下创建如下文件
# ls
ceph.conf  ceph-deploy-ceph.log  ceph.mon.keyring
```

> 4、编辑 ceph.conf 配置文件最后添加两行
```
cat ceph.conf
[global]
.....
public network = 192.168.101.0/24
cluster network = 192.168.101.0/24
osd_pool_default_size = 3            # osd副本数设置，默认为3个
```

> 5、安装ceph相关包
``` 
# ceph-deploy install node01 node02 node03

#如果速度慢可以知道阿里源
# ceph-deploy install node01 node02 node03  --repo-url http://mirrors.aliyun.com/ceph/rpm-jewel/el7/
可以使用下面命令代替ceph-deploy命令，因为ceph-deploy命令会下载官方yum源并覆盖本地yum源速度慢
#或者每台ceph节点执行三种人选其一
# yum install -y ceph ceph-radosgw 
```

> 6、配置初始 monitor(s)、并收集所有密钥：
```
# ceph-deploy mon create-initial
ls -l *.keyring
netstat -tlunp |grep 6789
```

> 7、查看mon状态  
```
# ceph mon_status -f json-pretty
# ceph mon_status | python -mjson.tool
```

> 8、把配置信息拷贝到各节点
```
# ceph-deploy admin node01 node02 node03
```

> 9、配置 osd

>> 1）单台添加
```
# ceph-deploy disk list node01                #查看主机可以使用的硬盘       
# ceph-deploy disk zap node01:/dev/sdb        #初始化
# ceph-deploy osd create node01:/dev/sdb      #创建并激活
```

>> 2)这里使用脚本批量执行
```
for dev in /dev/vda /dev/vdc /dev/vdd
do
ceph-deploy disk zap node01 $dev
ceph-deploy osd create node01 --data $dev
ceph-deploy disk zap node02 $dev
ceph-deploy osd create node02 --data $dev
ceph-deploy disk zap node03 $dev
ceph-deploy osd create node03 --data $dev
done
```

### 拓展：
默认采用的是bluestore，如果需要指定更详细的参数请参照下面步骤：

#### 使用filestore

使用filestore采用journal模式（每个节点数据盘需要两块盘或两个分区）

创建OSD
```
# ceph-deploy osd create --filestore --fs-type xfs --data /dev/sdc --journal data/log   storage1
# ceph-deploy osd create --filestore --fs-type xfs --data /dev/sdc --journal data/log   storage2
# ceph-deploy osd create --filestore --fs-type xfs --data /dev/sdc --journal data/log   storage3
```

#### 使用bluestore

```
# 单块磁盘
  > 机械硬盘或者SSD
    > block: rocks DB数据即元数据
    > block-wal: 数据库的wal日志
    > data: 即ceph保存的对象数据

# 两块磁盘
  > SSD:
    > block: rocks DB数据即元数据
    > block-wal: 数据库的wal日志
  > 机械硬盘
    > data: 即ceph保存的对象数据

# 多块磁盘
  > NVME:
    > block: rocks DB数据即元数据
  > SSD:
    > block-wal: 数据库的wal日志
  > 机械硬盘
    > data: 即ceph保存的对象数据

# ceph-deploy osd create {node} --data /path/to/data --block-db /path/to/db-device
# ceph-deploy osd create {node} --data /path/to/data --block-wal /path/to/wal-device
# ceph-deploy osd create {node} --data /path/to/data --block-db /path/to/db-device --block-wal /path/to/wal-device
```

创建OSD
```
# ceph-deploy osd create --bluestore storage1 --data /dev/sdc --block-db cache/db-lv-0 --block-wal cache/wal-lv-0
# ceph-deploy osd create --bluestore storage2 --data /dev/sdc --block-db cache/db-lv-0 --block-wal cache/wal-lv-0
# ceph-deploy osd create --bluestore storage3 --data /dev/sdc --block-db cache/db-lv-0 --block-wal cache/wal-lv-0
```
- --data: ceph保存的对象数据
- --block-db: rocks DB 数据即元数据
- --block-wal: 数据库的wal日志



9.3 wal & db 的大小问题

使用混合机械和固态硬盘设置时，block.db为Bluestore创建足够大的逻辑卷非常重要 。通常，block.db应该具有 尽可能大的逻辑卷。

建议block.db尺寸不小于4％ block。例如，如果block大小为1TB，则block.db 不应小于40GB。

如果不使用快速和慢速设备的混合，则不需要为block.db（或block.wal）创建单独的逻辑卷。Bluestore将在空间内自动管理这些内容block。


9.4 设置SOD服务自启动
```
systemctl enable ceph-osd@0 ceph-osd@1 ceph-osd@2
systemctl enable ceph-osd@3 ceph-osd@4 ceph-osd@5
systemctl enable ceph-osd@6 ceph-osd@7 ceph-osd@8
```

9.5 测试上传与下载数据
```
#创建pool
ceph osd pool create zhang 16 16
pool 'zhang' created

#查看创建的pool
ceph osd pool ls
zhang


#当前的 ceph 环境还没还没有部署使用块存储和文件系统使用 ceph，也没有使用对象存储的客户端，但是 ceph 的 rados 命令可以实现访问 ceph 对象存储的功能

#上传文件
sudo rados put log /var/log/messages --pool=zhang
messages文件上传到 zhang 并指定对象 id 为 log

#列出文件
rados ls --pool=zhang
log

#文件信息查看
#ceph osd map 命令可以获取到存储池中数据对象的具体位置信息
ceph osd map zhang log
osdmap e41 pool 'zhang' (1) object 'log' -> pg 1.27e9d53e (1.e) -> up ([4,2,8], p4) acting ([4,2,8], p4)
表示文件放在了存储池为 1 的 27e9d53e 的 PG 上，在线的 OSD 编号 4,2,8，主 OSD 为 4，活动的 OSD 4,2,8，表示数据放在了 3 个副本，是 ceph 的 crush 算法计算出三份数据保存在哪些 OSD

#下载文件
sudo rados get log --pool=zhang /opt/1.txt
tail /opt/1.txt
Jun  4 11:01:01 centos7 systemd: Started Session 18 of user root.
Jun  4 12:01:01 centos7 systemd: Started Session 19 of user root.
Jun  4 13:01:01 centos7 systemd: Started Session 20 of user root.

#修改文件
sudo rados put log /etc/passwd --pool=zhang
sudo rados get log --pool=zhang /opt/1.txt
tail /opt/1.txt
polkitd:x:999:998:User for polkitd:/:/sbin/nologin

#删除文件
sudo rados rm log --pool=zhang
rados ls --pool=zhang
```


> 10、查看集群状态
```
[root@cephnode01 ~]# ceph -s 
cluster:
    id:     8230a918-a0de-4784-9ab8-cd2a2b8671d0
    health: HEALTH_WARN
            application not enabled on 1 pool(s)
 
  services:
    mon: 3 daemons, quorum cephnode01,cephnode02,cephnode03 (age 27h)
    mgr: cephnode01(active, since 53m), standbys: cephnode03, cephnode02
    osd: 4 osds: 4 up (since 27h), 4 in (since 19h)
    rgw: 1 daemon active (cephnode01)
 
  data:
    pools:   6 pools, 96 pgs
    objects: 235 objects, 3.6 KiB
    usage:   4.0 GiB used, 56 GiB / 60 GiB avail
    pgs:     96 active+clean
```
- id：集群ID
- health：集群运行状态，这里有一个警告，说明是有问题，意思是pg数大于pgp数，通常此数值相等。
- mon：Monitors运行状态。
- osd：OSDs运行状态。
- mgr：Managers运行状态。
- mds：Metadatas运行状态。
- pools：存储池与PGs的数量。
- objects：存储对象的数量。
- usage：存储的理论用量。
- pgs：PGs的运行状态


> 11、查看集群硬盘
```
# ceph osd tree
ID CLASS WEIGHT  TYPE NAME       STATUS REWEIGHT PRI-AFF 
-1       0.02339 root default                            
-3       0.00780     host node01                         
 0   hdd 0.00780         osd.0       up  1.00000 1.00000 
-5       0.00780     host node02                         
 1   hdd 0.00780         osd.1       up  1.00000 1.00000 
-7       0.00780     host node03                         
 2   hdd 0.00780         osd.2       up  1.00000 1.00000
```
- ID: 如果为负数，表示的是主机或者root；如果是正数，表示的是osd的id
- WEIGHT: osd的weight，root的weight是所有host的weight的和。某个host的weight是它上面所有osd的weight的和
- NAME: 主机名或者osd的名称
- UP/DOWN: osd的状态信息
- REWEIGHT: osd的reweight值，如果osd状态为down，reweight值为0



> 12、查看使用容量
```
# ceph df
GLOBAL:
    SIZE        AVAIL       RAW USED     %RAW USED 
    24.0GiB     20.6GiB      3.35GiB         13.98 
POOLS:
    NAME                ID     USED        %USED     MAX AVAIL     OBJECTS 
    rbd                 1       114MiB      1.69       6.48GiB          42 
    cephfs_data         2           0B         0       6.48GiB           0 
    cephfs_metadata     3      6.24KiB         0       6.48GiB          21
```

输出的 **GLOBAL** 段展示了数据所占用集群存储空间的概要。

- **SIZE：** 集群的总容量。
- **AVAIL：** 集群的可用空间总量。
- **RAW USED：** 已用存储空间总量。
- **% RAW USED：** 已用存储空间比率。用此值对比 `full ratio` 和 `near full ratio` 来确保不会用尽集群空间。

输出的 **POOLS** 段展示了存储池列表及各存储池的大致使用率。本段没有反映出副本、克隆和快照的占用情况。例如，如果你把 1MB 的数据存储为对象，理论使用率将是 1MB ，但考虑到副本数、克隆数、和快照数，实际使用量可能是 2MB 或更多。

- **NAME:** 存储池名字。
- **ID:** 存储池唯一标识符。
- **USED:** 大概数据量，单位为 KB 、MB 或 GB ；
- **%USED：** 各存储池的大概使用率。
- **Objects：** 各存储池内的大概对象数。

注意: pool里面的已有空间是业务上的空间,也就是一个副本的空间;将业务上空间乘以副本数,和RAW USED是相等的。RAW USED是集群物理上已近使用的空间。
```
# ceph osd df
ID CLASS WEIGHT  REWEIGHT SIZE    USE     AVAIL   %USE  VAR  PGS 
 0   hdd 0.00780  1.00000 8.00GiB 1.12GiB 6.88GiB 14.00 1.00 242 
 1   hdd 0.00780  1.00000 8.00GiB 1.12GiB 6.88GiB 13.95 1.00 242 
 2   hdd 0.00780  1.00000 8.00GiB 1.12GiB 6.88GiB 13.95 1.00 242 
                    TOTAL 24.0GiB 3.35GiB 20.6GiB 13.97          
MIN/MAX VAR: 1.00/1.00  STDDEV: 0.02
```
- **ID:** osd id
- **WEIGHT:** 权重，和osd容量有关系
- **REWEIGHT:** 自定义的权重
- **SIZE:** osd大小
- **USE:** 已用空间大小
- **AVAIL:** 可用空间大小
- **%USE:** 已用空间百分比
- **PGS:** pg数量

> 13、查询osd在哪个主机上
```
# ceph osd find 0
{
    "osd": 0,
    "ip": "192.168.101.69:6800/1092",
    "osd_fsid": "04fc90fc-8cda-4b60-ab60-43a42cd2fac3",
    "crush_location": {
        "host": "node01",
        "root": "default"
    }
}
```

> 14、查看集群状态
```
# ceph -s
# ceph health
# ceph health detail
# ceph quorum_status --format json-pretty
```

> 15、查看osd是否启动
```
# netstat -utpln |grep osd
tcp        0      0 192.168.101.67:6800     0.0.0.0:*               LISTEN      19079/ceph-osd      
tcp        0      0 192.168.101.67:6801     0.0.0.0:*               LISTEN      19079/ceph-osd      
tcp        0      0 192.168.101.67:6802     0.0.0.0:*               LISTEN      19079/ceph-osd      
tcp        0      0 192.168.101.67:6803     0.0.0.0:*               LISTEN      19079/ceph-osd
```

> 16、查看节点信息
```
ceph node ls
ceph node ls mon
ceph node ls osd
ceph node ls mds
```

> 17、部署 mgr ， L版以后才需要部署
```
# ceph-deploy mgr create node01 node02 node03 
```

> 18、开启 dashboard 模块，用于UI查看  
```
# ceph mgr module enable dashboard
```

curl http://192.168.101.66:7000


# 三、Ceph 集群扩展

- 添加节点和 OSD  

一）新节点环境配置

1、配置yum源
```
# cat /etc/yum.repos.d/ceph.repo 
[ceph]
name=ceph
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/x86_64/
gpgcheck=0
priority=1

[ceph-noarch]
name=cephnoarch
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/noarch/
gpgcheck=0
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/SRPMS
enabled=0
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

# wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# sed -i 's/http/https/g' /etc/yum.repos.d/CentOS-Base.repo
# yum -y install epel-release
```

2、配置NTP
```
yum -y install ntpdate ntp
ntpdate  ntp.aliyun.com
systemctl restart ntpd  && systemctl enable ntpd
```

3、创建部署用户和ssh免密码登录
```
useradd cephadmin
echo cephadmin | passwd --stdin cephadmin
echo "cephadmin ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephadmin
chmod 0440 /etc/sudoers.d/cephadmin
```

4、配置防火墙，或者关闭  
```
firewall-cmd --zone=public --add-port=6789/tcp --permanent
firewall-cmd --zone=public --add-port=6800-7100/tcp --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

5、关闭 selinux
```
sed -i "/^SELINUX/s/enforcing/disabled/" /etc/selinux/config
setenforce 0
```

6、配置主机名解析，使用 /etc/hosts,或者dns
```
cat /etc/hosts
192.168.101.66   node01
192.168.101.67   node02
192.168.101.68   node03
192.168.101.69   node04  #添加新加节点
```

7、配置sudo不需要tty  
```
# sed -i 's/Defaults requiretty/#Defaults requiretty/' /etc/sudoers 
```

8、部署节点执行ssh免密  
```
su - cephadmin
ssh-copy-id ceph@node04
```  

二）新节点查看可用的磁盘

1、安装ceph包 
```
$ sudo yum install -y ceph ceph-radosgw         #安装 ceph包，替代 ceph-deploy install node04 ,不过下面的命令需要在每台node上安装
```  

2、查看可用的磁盘
```
# lsblk
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda 8:0 0 10G 0 disk
├─sda1 8:1 0 1G 0 part /boot
└─sda2 8:2 0 9G 0 part
  ├─centos-root 253:0 0 8G 0 lvm /
  └─centos-swap 253:1 0 1G 0 lvm [SWAP]
sdb 8:16 0 40G 0 disk
sdc 8:32 0 40G 0 disk
sdd 8:48 0 40G 0 disk
sr0 11:0 1 906M 0 rom
```  

也可以使用ceph-deploy命令查看磁盘列表
```
# ceph-deploy disk list node04
......
[ceph_deploy.osd][DEBUG ] Listing disks on node01...
[node01][DEBUG ] find the location of an executable
[node01][INFO  ] Running command: /usr/sbin/ceph-disk list
[node01][DEBUG ] /dev/dm-0 other, xfs, mounted on /
[node01][DEBUG ] /dev/dm-1 swap, swap
[node01][DEBUG ] /dev/sda :
[node01][DEBUG ] /dev/sda2 other, LVM2_member
[node01][DEBUG ] /dev/sda1 other, xfs, mounted on /boot
[node01][DEBUG ] /dev/sdb :
[node01][DEBUG ] /dev/sdb2 other
[node01][DEBUG ] /dev/sdb1 ceph data, active, cluster ceph, osd.0
[node01][DEBUG ] /dev/sr0 other, unknown
......
```

3、ceph-deploy 节点部署

1)目前集群 osd 情况  
```
# ceph osd tree
ID CLASS WEIGHT TYPE NAME STATUS REWEIGHT PRI-AFF
-1 0.17537 root default
-3 0.05846 host node01
0 hdd 0.01949 osd.0 up 1.00000 1.00000
3 hdd 0.01949 osd.3 up 1.00000 1.00000
6 hdd 0.01949 osd.6 up 1.00000 1.00000
-5 0.05846 host node02
1 hdd 0.01949 osd.1 up 1.00000 1.00000
4 hdd 0.01949 osd.4 up 1.00000 1.00000
7 hdd 0.01949 osd.7 up 1.00000 1.00000
-7 0.05846 host node03
2 hdd 0.01949 osd.2 up 1.00000 1.00000
5 hdd 0.01949 osd.5 up 1.00000 1.00000
8 hdd 0.01949 osd.8 up 1.00000 1.00000
```  

2）验证磁盘是否处于干净状态
```
# ceph-deploy disk zap node01 /dev/sde              # 清除分区
# lsblk
```

3）单独添加添加磁盘到集群中
```
# ceph-deploy osd create node01 --data /dev/sde
# lsblk
```

4)使用脚本批量添加osd  
```
for dev in /dev/sdb /dev/sdc /dev/sdd
do
ceph-deploy disk zap node04 $dev
ceph-deploy osd create node04 --data $dev
done
```
- 新的OSD添加到Ceph集群后，Ceph集群数据就会开始重新平衡到新的OSD，过一段时间后，Ceph 集群就变得稳定了。 生产中，就不能这样添加，否则会影响性能。
- 添加磁盘会自动将主机加入集群

5）查看
```
# watch ceph -s
# ceph osd stat
# rados df
# ceph df
# ceph osd tree
``` 
- 一旦ceph-disk prepare命令完成后，集群将执行回填操作并将开始将PG从辅助OSD移动到新的OSD。恢复操作可能需要一段时间，但在此之后，Ceph集群将HEALTH_OK再次出现3、3


# 四、Ceph 集群缩减

- 删除 Ceph OSD  

1、把osd标记出群集  
```
# ceph osd out osd.9
```
- Ceph会通过将PG从OSD中移出到群集内的其他OSD来开始重新平衡群集。群集状态将在一段时间内变得不健康。根据删除的OSD数量，在恢复时间完成之前，群集性能可能会有所下降。  

2、查看集群平衡状态，直到osd.9的数据完全写入其他磁盘后继续操作  
```
# ceph -s     # 集群现在应该处于恢复模式，但同时向客户端提供数据
# ceph -w
```
- 注意：一个一个移除，然后移除osd.10和osd.11,否则会导致数据丢失


3、停止移除的osd

虽然已把osd.9，osd.10，osd.11从集群中标记out，不会参与存储数据，但他们的服务仍然还在运行。下面top OSD  
```
# systemctl -H node04 stop ceph-osd.target      # 此操作关闭node04上的所有 osd
# ceph osd tree
```

4、既然这些OSD不再是Ceph集群的一部分，那么就从Crush map中删除  
```
# ceph osd crush remove osd.9
# ceph osd crush remove osd.10
# ceph osd crush remove osd.11
```
- 一旦从CRUSH地图中移除OSD，Ceph集群就会变得健康还应该观察OSD地图; 因为还没有删除OSD，它仍然会显示12个OSD，9个UP和9个IN

```
# ceph -s
```

5、删除 OSD 身份验证密钥
```
# ceph auth del osd.9
# ceph auth del osd.10
# ceph auth del osd.11
```

6、最后，删除 OSD 并检查集群状态，此时应该有 9个OSD，9个UP和9个IN，并且群集运行状况应该是正常的：  
```
# ceph osd rm osd.9
# ceph osd rm osd.10
# ceph osd rm osd.11
```  

7、从 Crush map 中删除此节点的痕迹  
```
# ceph osd crush remove node04
# ceph -s
```  



# 五、添加 Ceph MON

1、在生产设置中，应该始终在Ceph集群中具有奇数个监视节点以形成仲裁
```
# ceph-deploy mon add node04

# ceph -s
...
  services:
    mon: 4 daemons, quorum node01,node02,node03,node04
    mgr: node01(active), standbys: node02,node03
    mds: cephfs-1/1/1 up {0=c720178=up:active}, 2 up:standby
    osd: 12 osds: 12 up, 12 in
...

# ceph mon stat       #注意检查 node04 的状态
```

2、更新ceph.conf，并同步到其他主机
```
# vi ceph.conf
...
mon_initial_members = node01,node02,node03,node04
mon_host = 192.168.101.66,192.168.101.67,192.168.101.68,192.168.101.69

# ceph-deploy --overwrite-conf config push node01 node02 node03 node04
```



# 六、删除 Ceph MON


1、停止mon服务
```
# ceph mon stat    # 查看 mon 的状态
e3: 3 mons at {node01=192.168.101.69:6789/0,node02=192.168.101.70:6789/0,node03=192.168.101.71:6789/0}, election epoch 22, leader 0 node01,quorum 0,1,2 node01,node02,node03

# sudo systemctl -H node04 stop ceph-mon.target   #停止
```

2、删除mon节点
```
# ceph mon remove node04
```

3、查看mon是否从法定人数里面删除
```
# ceph quorum_status --format json-pretty
{
    "election_epoch": 22,
    "quorum": [
        0,
        1,
        2
    ],
    "quorum_names": [
        "node01",
        "node02",
        "node03"
    ],
...
```

4、备份或删除Mon数据，要去该节点删除
```
# 备份
# mkdir /var/lib/ceph/mon/removed
# mv /var/lib/ceph/mon/ceph-node04 /var/lib/ceph/mon/removed/ceph-node04

# 删除
# rm -r /var/lib/ceph/mon/ceph-node04
```

5、更新ceph.conf文件，并同步到其他主机
```
# vi ceph.conf
...
mon_initial_members = node01,node02,node03
mon_host = 192.168.101.66,192.168.101.67,192.168.101.68
...

# ceph-deploy --overwrite-conf config push node01 node02 node03

# ceph mon stat
```

# 七、数据清除

1、清除安装包
```
# ceph-deploy purge node01 node02 node03
```

2、清除配置信息
```
# ceph-deploy purge node01 node02 node03
# ceph-deploy forgetkeys
```

3、清除配置文件
```
每个节点删除残留的配置文件
# rm -rf /var/lib/ceph/osd/*
# rm -rf /var/lib/ceph/mon/*
# rm -rf /var/lib/ceph/mds/*
# rm -rf /var/lib/ceph/bootstrap-mds/*
# rm -rf /var/lib/ceph/bootstrap-osd/*
# rm -rf /var/lib/ceph/bootstrap-mon/*
# rm -rf /var/lib/ceph/tmp/*
# rm -rf /etc/ceph/*
# rm -rf /var/run/ceph/*
```

上面清除之后需要重新部署 ceph！

