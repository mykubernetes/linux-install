官方网站  
http://ceph.org.cn/  
官方yum源  
https://download.ceph.com/rpm-hammer/  

官方提供ansible部署  
http://docs.ceph.com/ceph-ansible/master/  


一、安装前准备
=========

# 配置 yum源  
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

# 配置NTP  
```
yum -y install ntpdate ntp
ntpdate  ntp.aliyun.com
systemctl restart ntpd  && systemctl enable ntpd
```  

# 创建部署用户和ssh免密码登录  
```
useradd ceph
echo 123456 | passwd --stdin ceph
echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
chmod 0440 /etc/sudoers.d/ceph
```  

# 配置防火墙，或者关闭  
```
#firewall-cmd --zone=public --add-port=6789/tcp --permanent
#firewall-cmd --zone=public --add-port=6800-7100/tcp --permanent
#firewall-cmd --reload
#firewall-cmd --zone=public --list-all
```  

# 关闭 selinux  
```
sed -i "/^SELINUX/s/enforcing/disabled/" /etc/selinux/config
setenforce 0
```  

# 配置主机名解析，使用  /etc/hosts,或者dns  
```
cat >>/etc/hosts<<EOF
192.168.101.66   node01
192.168.101.67   node02
192.168.101.68   node03
EOF
```  

# 配置sudo不需要tty  
``` # sed -i 's/Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers ```  


二、使用 ceph-deploy 部署集群
======================
# 配置免密钥登录  
```
su - ceph
ssh-keygen
ssh-copy-id ceph@node01
ssh-copy-id ceph@node02
ssh-copy-id ceph@node03
```  

# 安装 ceph-deploy  
```
# sudo yum install -y ceph-deploy python-pip
# mkdir my-cluster
# cd my-cluster
```  

# 部署节点
``` # ceph-deploy new node01 node02 node03  ```  
  
# 编辑 ceph.conf 配置文件最后添加两行  
```
cat ceph.conf
[global]
.....
public network = 192.168.101.0/24
cluster network = 192.168.101.0/24
```  

# 安装 ceph包，替代 ceph-deploy install node1 node2 ,不过下面的命令需要在每台node上安装
``` # yum install -y ceph ceph-radosgw ```  

# 配置初始 monitor(s)、并收集所有密钥：  
```
# ceph-deploy mon create-initial
ls -l *.keyring
```  

# 把配置信息拷贝到各节点  
``` # ceph-deploy admin node01 node02 node03  ```  

# 配置 osd  
1、单台添加
```
# ceph-deploy disk list node01                #查看主机可以使用的硬盘       
# ceph-deploy disk zap node01:/dev/sdb        #初始化
# ceph-deploy osd create node01:/dev/sdb      #创建并激活
```
2、这里使用脚本批量执行
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

# 查看集群硬盘  
``` # ceph osd tree ```  

# 查看集群状态  
```
# ceph -s
# ceph health
# ceph health detail
```  

# 部署 mgr ， L版以后才需要部署  
``` # ceph-deploy mgr create node01 node02 node03 ```  

# 开启 dashboard 模块，用于UI查看  
``` # ceph mgr module enable dashboard ```  

curl http://192.168.101.66:7000
