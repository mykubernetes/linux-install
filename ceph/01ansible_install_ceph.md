ansible部署ceph
===

一、环境配置
---
1、配置 ceph 仓库  
```
yum -y install wget epel-release
wget -O /etc/yum.repos.d/ceph.repo https://raw.githubusercontent.com/aishangwei/ceph-demo/master/ceph-deploy/ceph.repo
```  

2、配置NTP  
```
yum -y install ntpdate ntp
ntpdate cn.ntp.org.cn
systemctl restart ntpd && systemctl enable ntpd
```  

3、安装notario  
```
yum -y install python-pip
pip install notario
```  

4、安装ansible  
```
wget https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.0-1.el7.ans.noarch.rpm
yum -y install ansible-2.6.0-1.el7.ans.noarch.rpm
```  

5、主机名解析  
```
cat /etc/hosts
192.168.101.69 node01
192.168.101.70 node02
192.168.101.71 node03
```  

6、ssh 免密钥登陆  
```
ssh-keygen
$ ssh-copy-id node01
$ ssh-copy-id node02
$ ssh-copy-id node03
```  

二、ceph配置详解  
---

Ansible部署Ceph相关yml
- /usr/share/ceph-ansible/group_vars/all.yml：所有节点相关yml配置；
- /usr/share/ceph-ansible/group_vars/osds.yml：所有OSD节点的yml配置；
- /usr/share/ceph-ansible/group_vars/client.yml：客户端节点的yml配置。
- /usr/share/ceph-ansible：运行Ansible部署的主目录。


yml主要相关参数

- all.yml参数

| 变量 | 值 | 含义 |
|-----|----|------|
| fetch_directory | ~/ceph-ansible-keys | 用于将身份验证密钥复制到集群节点的临时目录的位置。 |
| ceph_origin | repository | Ceph来源，repository表示使用包存储库 |
| ceph_repository | rhcs | 用于安装Red Hat的存储库Ceph存储。rhcs使用官方红帽Ceph存储包。 |
| ceph_repository_type | cdn or iso | rhcs的安装源，CDN或本地ISO映像。 |
| ceph_rhcs_iso_path | path to iso | 如果使用iso存储库类型，则指向Red Hat Ceph存储iso的路径。 |
| ceph_rhcs_version | 3 | Red Hat Ceph安装的版本。 |
| monitor_interface | network interface | Monitor用于侦听的网络接口。 |
| public_network | address and netmask | 集群的公共网络的子网，如192.168.122.0/24。 |
| cluster_network | address and netmask | 集群专用网络的子网。默认设置为public_network的值。 |
| journal_size | size in MB | 分配给OSD日志的大小。应该是预期的两倍。在大多数情况下不应小于5120 MB。 |

提示：可以在group_vars/all.yml中将common_single_host_mode这个特殊参数设置为true。用于部署一个单节点、集所有功能于一身的Ceph集群作为测试学习使用。

- osds.ym

| 变量 | 值 | 含义 |
|-----|----|------|
| osd_scenario | collocated or non-collocated | OSD日志部署类型。 |
| devices | 用于OSDs的设备的名称列表。 | 用于并行OSD数据和日志分区或非并行OSD数据分区的设备。 |
| dedicated_devices | 用于非并列OSD期刊的设备名称列表。 | OSD日志设备。 |

1、假定所有OSD主机具有相同的硬件并使用相同的设备名称。
```
group_vars/osds.yml配置示例：
osd_scenario: "collocated"
devices:
 - /dev/sdb
 - /dev/sdc
 - /dev/sdd
```

2、非并置方案：将不同的存储设备用于OSD数据和OSD日志。
```
group_vars/osds.yml配置示例：
osd_scenario: "non-collocated"
devices:
 - /dev/sdb
 - /dev/sdc
dedicated_devices:
 - /dev/sdd
 - /dev/sde
```

三、安装ceph集群  
---
1、下载 ceph-ansible  
```
yum -y install git
git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible
git branch -r
git checkout stable-3.2
```  

2、all.yml 文件配置  
```
$ cp group_vars/{all.yml.sample,all.yml}
$ cat group_vars/all.yml|grep -Ev "^#|^$"      # 这里的集群名称要改动
---
dummy:
fetch_directory: ~/ceph-ansible-keys
cluster: back
centos_package_dependencies:
- python-pycurl
- python-setuptools
- libselinux-python
ntp_service_enabled: false

ceph_origin: distro
ceph_repository: custom
ceph_mirror: http://mirrors.163.com/ceph
ceph_stable_key: http://mirrors.163.com/ceph/keys/release.asc
ceph_stable_release: luminous
ceph_stable_repo: "{{ ceph_mirror }}/debian-{{ ceph_stable_release }}"
ceph_stable_redhat_distro: el7

cephx: true
monitor_interface: eth0
public_network: 192.168.20.0/24
cluster_network: 192.168.30.0/24

rbd_cache: "true"                                    #开启RBD回写缓存
rbd_cache_writethrough_until_flush: "false"          #在切换回写之前，不从写透开始
rbd_client_directories: false                        ##不要创建客户机目录(应该已经存在)

radosgw_civetweb_port: 80
radosgw_interface: eth0

ceph_conf_overrides:
  global:
    mon_osd_allow_primary_affinity: 1
    mon_clock_drift_allowed: 0.5                     #允许MON时钟间隔最多0.5秒
    osd_pool_default_size: 2
    osd_pool_default_min_size:1                      #降低存储池复制大小的默认设置
    mon_pg_warn_min_per_osd: 0                       #见提示一
    mon_pg_warn_max_per_osd: 0                       #见提示二
    mon_pg_warn_max_object_skew: 0                   #见提示三
  client:
    rbd_default_features: 1
  client.rgw.node01:
    rgw_dns_name: node01
```  
- 提示一：根据每个OSD的pg数量关闭集群健康警告。通常，第一个变量被设置为30，如果OSD中的每个“in”平均少于30个pg，集群就会发出警告。
- 提示二：此变量默认值为300，如果OSD中的每个“in”平均超过300个pg，集群就会发出警告，在本实验的小集群中可能没有很多pg，因此采用禁用。
- 提示三：根据某个池中对象的数量大于集群中一组池中对象的平均数量，关闭集群健康警告。同样，我们有一个非常小的集群，这避免了通常指示我们需要调优集群的额外警告。


3、osds.yml 文件配置  
```
$ cp group_vars/{osds.yml.sample,osds.yml}
$ grep -Ev "^#|^$" group_vars/osds.yml
---
dummy:
devices:
- /dev/sdb                                 #使用/dev/sdb作为后端存储设备
- /dev/sdc
- /dev/sdd
osd_scenario: collocated                   #OSD使用并列的OSD形式
```  

4、mdss.yml 文件配置  
```
$ cp group_vars/{mdss.yml.sample,mdss.yml}
```

5、修改rgws.yml 配置文件
```
$ cp group_vars/{rgws.yml.sample,rgws.yml}
$ vim rgws.yml
copy_admin_key: true
```

6、修改clients.yml 配置文件
```
$ cp group_vars/{clients.yml.sample,clients.yml}
$ vim clients.yml
copy_admin_key: true
```

7、site.yml 文件配置（保持默认）  
```
cp site.yml.sample site.yml
```  

8、hosts 文件配置  
```
$ cat /etc/ansible/hosts

[mons]
node01
node02
node03

[osds]
node01
node02
node03

[mgrs]
node01
node02
node03

[clients]
node01

[rgws]
node01

[mdss]
node01
node02
```  

9、开始安装  
```
$ ansible-playbook site.yml
```  

10、验证,因为配置文件里设置的集群名称为back,默认为ceph,所以修改为back测试，否则命令不可以执行成功
```
$ export CEPH_ARGS="--cluster back"
$ ceph -s
```  


四、扩容Ceph集群
---

1、扩容前置条件
- 在不中断服务的前提下，扩展ceph集群存储容量
- 可通过ceph-ansible以两种方式扩展集群中的存储：
  - 可以添加额外OSD主机到集群（scale-out）
  - 可以添加额外存储设备到现有的OSD主机（scale-up）
- 开始部署额外的OSD前，需确保集群处于HEALTH_OK状态
  - 相关主机解析已正常添加指hosts


2、扩容额外的OSD主机
```
$ cat /etc/ansible/hosts

[mons]
node01
node02
node03

[osds]
node01
node02
node03
node04             #追加node04

[mgrs]
node01
node02
node03

[clients]
node01

[rgws]
node01

[mdss]
node01
node02
```

3、添加额外OSD存储设备
```
devices:
 - /dev/vdb
 - /dev/vdc
 - /dev/vdd						#追加存储设备
```

4、正式部署OSD节点
```
ansible-playbook site.yml
```

https://blog.csdn.net/szh1124/article/details/83902670?spm=1001.2014.3001.5501
