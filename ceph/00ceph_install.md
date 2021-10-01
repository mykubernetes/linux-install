官方网站: http://ceph.org.cn/

官方yum源: https://download.ceph.com/rpm-hammer/

官方提供ansible部署:http://docs.ceph.com/ceph-ansible/master/


# 一、安装前准备

> 1、配置 yum源
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

> 3、部署节点,参数为monitor结点的主机名列表 
```
# ceph-deploy new node01 node02 node03

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

> 10、查看集群硬盘
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



> 11、查看使用容量
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
GLOBAL区域表示整体的空间使用情况:

- SIZE: 表示集群中所有OSD总空间大小
- AVAIL: 表示可以使用的空间大小
- RAW USED: 表示已用空间大小
- %RAW USED: 表示已用空间百分比

POOLS区域表示某个pool的空间使用情况

- NAME: pool名称
- ID: pool id
- USED: 已用空间大小
- %USED: 已用空间百分比
- MAX AVAIL: 最大可用空间大小
- OBJECTS: 这个pool中对象的个数

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
- ID: osd id
- WEIGHT: 权重，和osd容量有关系
- REWEIGHT: 自定义的权重
- SIZE: osd大小
- USE: 已用空间大小
- AVAIL: 可用空间大小
- %USE: 已用空间百分比
- PGS: pg数量

> 12、查询osd在哪个主机上
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

> 13、查看集群状态
```
# ceph -s
# ceph health
# ceph health detail
# ceph quorum_status --format json-pretty
```

> 14、查看osd是否启动
```
# netstat -utpln |grep osd
tcp        0      0 192.168.101.67:6800     0.0.0.0:*               LISTEN      19079/ceph-osd      
tcp        0      0 192.168.101.67:6801     0.0.0.0:*               LISTEN      19079/ceph-osd      
tcp        0      0 192.168.101.67:6802     0.0.0.0:*               LISTEN      19079/ceph-osd      
tcp        0      0 192.168.101.67:6803     0.0.0.0:*               LISTEN      19079/ceph-osd
```

> 15、查看节点信息
```
ceph node ls
ceph node ls mon
ceph node ls osd
ceph node ls mds
```

> 16、部署 mgr ， L版以后才需要部署
```
# ceph-deploy mgr create node01 node02 node03 
```

> 17、开启 dashboard 模块，用于UI查看  
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

