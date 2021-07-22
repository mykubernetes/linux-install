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

二、安装ceph集群  
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

rbd_cache: "true"
rbd_cache_writethrough_until_flush: "false"
rbd_client_directories: false

radosgw_civetweb_port: 80
radosgw_interface: eth0

ceph_conf_overrides:
  global:
    mon_osd_allow_primary_affinity: 1
    mon_clock_drift_allowed: 0.5
    osd_pool_default_size: 2
    osd_pool_default_min_size:1
    mon_pg_warn_min_per_osd: 0
    mon_pg_warn_max_per_osd: 0
    mon_pg_warn_max_object_skew: 0
  client:
    rbd_default_features: 1
  client.rgw.node01:
    rgw_dns_name: node01
```  

3、osds.yml 文件配置  
```
$ cp group_vars/{osds.yml.sample,osds.yml}
$ grep -Ev "^#|^$" group_vars/osds.yml
---
dummy:
devices:
- /dev/sdb
- /dev/sdc
- /dev/sdd
osd_scenario: collocated
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
