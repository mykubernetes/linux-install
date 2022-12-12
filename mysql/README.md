
https://blog.csdn.net/weixin_45692705/article/details/119003128?spm=1001.2014.3001.5501

MySql 官方函数：https://dev.mysql.com/doc/refman/8.0/en/functions.html

# 社区版mysql安装

```
# wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
# rpm -Uvh mysql57-community-release-el7-11.noarch.rpm
```

安装MySQL，默认最新版本：
```
# yum install mysql-community-server
```

启动MySQL服务：
```
# systemctl start mysqld.service
# systemctl status mysqld.service
# systemctl enable mysqld.service
```

root账户默认密码存储在错误日志中，通过日志文件中找出密码
```
# grep 'temporary password' /var/log/mysqld.log
# mysql -uroot –p
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';         #过滤出的密码
```
注意：密码要求包含一个大写字母，一个小写字母，一位数字和一个特殊字符，并且密码长度至少为8个字符。

查看mysql默认密码复杂度
```
mysql> SHOW VARIABLES LIKE 'validate_password%';
```

修改密码复杂度
```
mysql> set global validate_password_policy=LOW;         #只验证密码的长度
mysql> set global validate_password_length=6;           #验证密码的长度
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '123456'; 
```

开启mysql的远程访问
```
mysql> grant all privileges on *.* to 'root'@'%' identified by 'password'
mysql> flush privileges;
```

MySQL服务器配置
```
[mysqld]
user = mysql
port = 3306
datadir = /var/lib/mysql
socket = /var/lib/mysql/mysql.sock
bind-address = 0.0.0.0
pid-file=/var/run/mysqld/mysqld.pid
character-set-server = utf8
collation-server = utf8_general_ci
log-error=/var/log/mysqld.log

max_connections = 10240
open_files_limit = 65535
innodb_buffer_pool_instances = 4
innodb_buffer_pool_size = 4G
innodb_flush_log_at_trx_commit= 2
sync_binlog = 0
innodb_log_file_size = 256M
innodb_flush_method = O_DIRECT
interactive_timeout = 1800
wait_timeout = 1800
slave-parallel-type = LOGICAL_CLOCK
slave-parallel-workers = 8
master-info-repository=TABLE
relay-log-info-repository=TABLE
```

添加用户并授权
```
mysql> create database aliangedu;
mysql> grant all on aliangedu.* to 'aliangedu'@'192.168.0.%' identified by 'Aliangedu6!';
```

社区版  
https://dev.mysql.com/downloads/mysql/


YUM或APT安装或更新MySQL是最方面的方法。  
https://dev.mysql.com/downloads/repo/yum/  
https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/  
