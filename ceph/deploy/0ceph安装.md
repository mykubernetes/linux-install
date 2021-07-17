官方网站: http://ceph.org.cn/

官方yum源: https://download.ceph.com/rpm-hammer/

官方提供ansible部署:http://docs.ceph.com/ceph-ansible/master/


一、安装前准备
=========

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


二、使用 ceph-deploy 部署集群
======================

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
