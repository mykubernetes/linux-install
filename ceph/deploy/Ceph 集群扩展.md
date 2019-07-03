Ceph 集群扩展
===
从根本上说，Ceph一直致力于成长从几个节点到几百个，它应该在没有停机的情况下即时扩展。  
添加节点和 OSD  
---
新节点环境配置  
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
手动修改配置文件  
注释Defaults requiretty  
``` # sed -i 's/Defaults requiretty/#Defaults requiretty/' /etc/sudoers ```  
