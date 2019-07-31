mysql cluster
===

Mysql cluster的下载地址：https://dev.mysql.com/downloads/cluster/  
http://repo.mysql.com/yum/  

mysql cluster集群各机器角色如下分配：  
mysql 管理节点：node01 IP：192.168.101.69  
mysql 数据节点：node02 IP：192.168.101.70  
mysql 数据节点：node03 IP：192.168.101.71  
msyql SQL节点：node02 IP：192.168.101.72  
msyql SQL节点：node03 IP：192.168.101.73  


mysql cluster 7.5版本安装
===

每台节点执行以下操作  
---
1、安装最新的EPEL源 和 mysql社区版源安装包  
```
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum install epel-release -y
wget http://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
rpm -ivh mysql57-community-release-el7-11.noarch.rpm

开启mysql cluster源
vim /etc/yum.repos.d/mysql-community.repo
[mysql-cluster-7.5-community]
name=MySQL Cluster 7.5 Community
baseurl=http://repo.mysql.com/yum/mysql-cluster-7.5-community/el/7/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

批量开启mysql cluster源
sed -i "55s/0/1/g" /etc/yum.repos.d/mysql-community.repo
```  

2、安装解决Cluster的依赖包  
```
yum install -y perl perl-Class-MethodMaker perl-DBI  libaio numactl
```  

3、安装Mysql Cluster  
```
yum install -y mysql-cluster-community-server
rpm -ql mysql-cluster-community-server
```  


数据节点主机都要安装数据节点的相关包  
---
```
# yum install -y mysql-cluster-community-data-node
```  

管理节点安装management管理包  
---
```
# yum -y install mysql-cluster-community-management-server
```  

管理节点创建配置目录：
```
# mkdir -p /usr/mysql-cluster/
```  


管理节点配置(生产环境配置数值需要调大)  
```
[ndbd default]
#数据写入数量。2表示两份
NoOfReplicas=2
#配置数据存储可使用的内存
DataMemory=200M
#索引给100M
IndexMemory=100M
[ndb_mgmd]
nodeid=1
#管理结点的日志
datadir=/var/lib/mysql
#管理结点的IP地址。本机IP
HostName=192.168.101.69
###### data node options:#存储结点
[ndbd]
HostName=192.168.101.70
#mysql数据存储路径
DataDir=/var/lib/mysql
nodeid=2
[ndbd]
HostName=192.168.101.71
#mysql数据存储路径
DataDir=/var/lib/mysql
nodeid=3
# SQL node options: #关于SQL结点
[mysqld]
HostName=192.168.101.72
nodeid=4
[mysqld]
HostName=192.168.101.73
nodeid=5
```  

数据节点配置
```
# vim /etc/my.cnf	
[mysqld]
# mysql数据存储路径
datadir=/var/lib/mysql
#启动ndb引擎
ndbcluster
# 管理节点IP地址 
ndb-connectstring=192.168.101.69
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
[mysql_cluster]
# 管理节点IP地址
ndb-connectstring=192.168.101.69
```  

SQL节点配置  
```
# vim /etc/my.cnf   
[mysqld]
#启动ndb引擎
ndbcluster
# 管理节点IP地址
ndb-connectstring=192.168.101.69
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
[mysql_cluster]
# 管理节点IP地址
ndb-connectstring=192.168.101.69
```  

注意：数据节点和SQL结点配置文件区别 ，就多一行，数据结点有：datadir=/var/lib/mysql SQL节点上没有。


