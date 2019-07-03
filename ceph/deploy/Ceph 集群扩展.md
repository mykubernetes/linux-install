Ceph 集群扩展
===
从根本上说，Ceph一直致力于成长从几个节点到几百个，它应该在没有停机的情况下即时扩展。  

添加节点和 OSD  
---

一、新节点环境配置  
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
``` # sed -i 's/Defaults requiretty/#Defaults requiretty/' /etc/sudoers ```  

8、部署节点执行ssh免密  
```
su - cephadmin
ssh-copy-id ceph@node04
```  

二、新节点查看可用的磁盘
1、查看可用的磁盘  
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

2、安装 ceph 包  
```
$ sudo yum install -y ceph ceph-radosgw #安装 ceph包，替代 ceph-deploy install node04 ,不过下面的命令需要在每台node上安装
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

2)添加osd  
```
for dev in /dev/sdb /dev/sdc /dev/sdd
do
ceph-deploy disk zap node04 $dev
ceph-deploy osd create node04 --data $dev
done
```  
- 新的OSD添加到Ceph集群后，Ceph集群数据就会开始重新平衡到新的OSD，过一段时间后，Ceph 集群就变得稳定了。 生产中，就不能这样添加，否则会影响性能 。  
- 添加磁盘会自动将主机加入集群  

3）查看
```
# watch ceph -s     # 实时查看
# rados df
# ceph df
# ceph osd tree
```  


添加 Ceph MON
===
在生产设置中，应该始终在Ceph集群中具有奇数个监视节点以形成仲裁：  
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

# ceph mon stat    #注意检查 node04 的状态
```  

更新 ceph.conf  
```
# vi ceph.conf
...
mon_initial_members = node01,node02,node03,node04
mon_host = 192.168.101.66,192.168.101.67,192.168.101.68,192.168.101.69

# ceph-deploy --overwrite-conf config push node01 node02 node03 node04
```  

Ceph 集群缩减
---
删除 Ceph OSD  

1、把osd标记出群集  
``` ceph osd out osd.9 ```
此时，Ceph就会通过将PG从OSD中移出到群集内的其他OSD来开始重新平衡群集。群集状态将在一段时间内变得不健康。根据删除的OSD数量，在恢复时间完成之前，群集性能可能会有所下降。  

2、查看集群平衡状态，直到osd.9的数据完全写入其他磁盘后继续操作  
```
# ceph -s     # 集群现在应该处于恢复模式，但同时向客户端提供数据
# ceph -w
```  

注意：一个一个移除，然后移除osd.10和osd.11,否则会导致数据丢失


3、停止移除的osd  
虽然已把osd.9，osd.10，osd.11从集群中标记out，不会参与存储数据，但他们的服务仍然还在运行。下面top OSD  
```
# systemctl -H node04 stop ceph-osd.target     # 此操作关闭node04上的所有 osd
# ceph osd tree
```  

4、既然这些OSD不再是Ceph集群的一部分，那么就从Crush map中删除  
```
# ceph osd crush remove osd.9
# ceph osd crush remove osd.10
# ceph osd crush remove osd.11
```  
- 一旦从CRUSH地图中移除OSD，Ceph集群就会变得健康还应该观察OSD地图; 因为还没有删除OSD，它仍然会显示12个OSD，9个UP和9个IN：  

``` # ceph -s ```  

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
