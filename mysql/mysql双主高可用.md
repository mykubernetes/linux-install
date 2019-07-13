通过KeepAlived搭建MySQL双主模式的高可用集群系统  

1、准备环境  
```
node01: mysql主/备 keepalived
node02: mysql主/备 keepalived
```  

2、两台主机分别安装mysql  
```
yum -y install mysql mysql-server mysql-devel
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld.service
mysqladmin -uroot password '123456'
```  

3、分别修改配置文件  
```
# node01:
server-id = 1
log-bin=mysql-bin
relay-log = mysql-relay-bin
replicate-wild-ignore-table=mysql.%
replicate-wild-ignore-table=test.%
replicate-wild-ignore-table=information_schema.%

# node02:
server-id = 2
log-bin=mysql-bin
relay-log = mysql-relay-bin
replicate-wild-ignore-table=mysql.%
replicate-wild-ignore-table=test.%
replicate-wild-ignore-table=information_schema.%
```  

注意:不要在主库上使用binlog-do-db或binlog-ignore-db选项，也不要在从库上使用replicate-do-db或replicate-ignore-db选项，因为这样可能产生 跨库更新失败的问题。推荐在从库上使用 replicate_wild_do_table 和 和 replicate-wild-ignore-table  两个选项来解决复制过滤问题。  

4、两台主机分别配置主从同步  
```
mysql> grant replication slave on *.* to 'repl_user'@'192.168.101.%' identified by 'repl_passwd';
mysql> flush privileges;
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      542 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)


#配置slave主机连接master主机
mysql> change master to \
master_host='192.168.101.69', \
master_user='repl_user', \
master_password='repl_passwd', \
master_log_file='mysql-bin.000001', \
master_log_pos=542;
```  





