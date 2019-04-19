zabbix安装
========== 
官网介绍  
https://www.zabbix.com/documentation/3.4/zh/manual/introduction/features  

1. 安装MySQL
```
# yum -y install yum-utils 
# rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
# yum-config-manager --disable mysql80-community
# yum-config-manager --enable mysql57-community
# yum install mysql-community-server
# systemctl start mysqld
# systemctl status mysqld
# grep 'temporary password' /var/log/mysqld.log
# mysql -uroot -p
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'Zabbix2018!';
# vi /etc/my.cnf
[mysql]
socket = /tmp/mysql.sock
[mysqld]
user = mysql
port = 3306
datadir = /var/lib/mysql
socket = /tmp/mysql.sock
bind-address = 0.0.0.0
pid-file = /var/run/mysqld/mysqld.pid
character-set-server = utf8
collation-server = utf8_general_ci
log-error = /var/log/mysqld.log

max_connections = 10240
open_files_limit = 65535
innodb_buffer_pool_size = 3G
innodb_flush_log_at_trx_commit = 2
innodb_log_file_size = 256M
# systemctl restart mysqld

mysql> create database zabbix;
mysql> grant all on zabbix.* to zabbix@'192.168.1.%' identified by 'Zabbix2018!';
```  
