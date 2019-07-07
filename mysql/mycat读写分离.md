官方包http://dl.mycat.io/  

1、主机架构
node01  mysql-master  mycat 
node02  mysql-slave

2、两台机器分别安装mysql  
```
yum -y install mysql mysql-server mysql-devel
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld.service
```

3、导入数据库和表  
```
# mysql
DROP DATABASE IF EXISTS mldn ;
CREATE DATABASE mldn CHARACTER SET UTF8 ;
use mldn ;
CREATE TABLE member(
   mid VARCHAR(50) ,
   name VARCHAR(50) ,
   age INT ,
   salary DOUBLE ,
   birthday DATE ,
   note  TEXT ,
   CONSTRAINT pk_mid PRIMARY KEY(mid)
) ;
INSERT INTO member(mid,name,age,salary,birthday,note) VALUES ('mldn','hello',10,2000.0,'2005-11-11','very good') ;
INSERT INTO member(mid,name,age,salary,birthday,note) VALUES ('admin','administrator',10,2000.0,'2005-11-11','very good') ;
INSERT INTO member(mid,name,age,salary,birthday,note) VALUES ('guest','administrator',10,2000.0,'2005-11-11','very good') ;
```  

4、安装mycat  
```
wget http://dl.mycat.io/1.6-RELEASE/Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz
tar xvf Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz
cd mycat
```  
