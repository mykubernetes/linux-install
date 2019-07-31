mysql cluster
===

Mysql cluster的下载地址：https://dev.mysql.com/downloads/cluster/  
http://repo.mysql.com/yum/  

mysql cluster集群各机器角色如下分配：  
mysql 管理节点：node01 IP：192.168.101.69  
mysql 数据节点：node02 IP：192.168.101.70  
mysql 数据节点：node03 IP：192.168.101.71  
msyql SQL节点：node04 IP：192.168.101.72  
msyql SQL节点：node05 IP：192.168.101.73  


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


MySQL Cluster启动  
---
初次启动命令以及用户密码更改调整：（请严格按照次序启动）  
启动顺序：管理结点服务->数据结点服务->sql结点服务  
关闭顺序：关闭管理结点服务，关闭管理结点服务后，nbdb数据结点服务会自动关闭->手动把sql结点服务关了

1、管理节点启动mysql cluster  
```
ndb_mgmd --ndb_nodeid=1 --initial -f /usr/mysql-cluster/config.ini
```  
- --ndb_nodeid 管理节点ID为1的是管理节点
- --initial 初始化
- -f 配置文件

2、启动数据节点服务  
```
# ndbd --initial
```  

3、启动SQL结点服务
```
# systemctl start mysqld
```  

4、查看mysql 集群状态  
```
#ndb_mgm
ndb_mgm> show
```  

数据同步实验测试
---
1、修改mysql密码
```
查看mysql root用户密码
注意：我们只需修改sql节点的密码
# grep password /var/log/messages
# The random password set for the root user at Wed Apr  1 21:10:53 2015 (local time): gDVpNRBxTcgd17di

此步骤可忽略
5.7以上版本 关闭密码安全策略插件，否则需要输入复杂密码
在my.cnf添加 validate-password=off 重启mysql
命令执行方式去掉复杂密码格式
set global validate_password_policy=0;
set global validate_password_length=1;

修改密码
# mysql –uroot –p'gDVpNRBxTcgd17di'
mysql> set password for 'root'@'localhost'=password('123456');
mysql> grant all privileges on *.* to cluster@'%' identified by '123456' #授权
mysql> flush privileges;
```  

2、模拟外部机器的一个客户端插入数据  
```
# mysql -ucluster -p123456 -h 192.168.101.72
注意：创建表的时候使用ndb引擎
mysql> create database db;
mysql> use db;
mysql> create table test(id int) engine=ndb;
mysql> insert into test values(1000);
mysql> select * from test;


登陆另一台sql节点查看 
# mysql -ucluster -p123456 -h 10.10.10.73
mysql> use db;
mysql> select * from test;
```  

3、停掉一个sql节点测试  
```
# mysqladmin -uroot -p123456 shutdown
ndb_mgm> show       #查看状态
```  

MySQL Cluster关闭  
---
关闭mysql集群顺序： 关闭管理节点服务-》 关闭管理节点时，数据结点服务自动关闭 –》 需要手动关闭SQL结点服务

1、关闭管理节点服务  
```
# ndb_mgm
-- NDB Cluster -- Management Client --
ndb_mgm> shutdown
Node 2: Cluster shutdown initiated
Node 3: Cluster shutdown initiated
3 NDB Cluster node(s) have shutdown.
Disconnecting to allow management server to shutdown.
Node 2: Node shutdown completed.
ndb_mgm> exit

# ps -axu | grep ndbd	   	#查看不到，说明数据节点已经被关
```  


2、手动关闭SQL节点服务  
```
# mysqladmin -uroot -p123456 shutdown
# ps -aux | grep mysq
```  
