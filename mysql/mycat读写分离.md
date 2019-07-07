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

4、配置hosts文件  
```
# cat /etc/hosts
192.168.101.69 node01
192.168.101.70 node02
```  

5、安装mycat  
```
wget http://dl.mycat.io/1.6-RELEASE/Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz
tar xvf Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz
cd mycat
```  

6、配置mycat  
```
vim schema.xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">
		<!-- 定义一个MyCat的模式，此处定义了一个逻辑数据库名称TestDB -->
		<!-- “checkSQLschema”：描述的是当前的连接是否需要检测数据库的模式 -->
		<!-- “sqlMaxLimit”：表示返回的最大的数据量的行数 -->
		<!-- “dataNode="dn1"”：该操作使用的数据节点是dn1的逻辑名称 -->
		<schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="100" dataNode="dn1"/>
		<!-- 定义个数据的操作节点，以后这个节点会进行一些库表分离使用 -->
		<!-- “dataHost="localhost1"”：定义数据节点的逻辑名称 -->
		<!-- “database="mldn"”：定义数据节点要使用的数据库名称 -->
        <dataNode name="dn1" dataHost="localhost1" database="mldn" />
		<!-- 定义数据节点，包括了各种逻辑项的配置 -->
		<dataHost name="localhost1" maxCon="1000" minCon="10" balance="0" writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
			<!-- 配置真实MySQL与MyCat的心跳 -->
			<heartbeat>select user()</heartbeat>
			<!-- 配置真实的MySQL的连接路径 -->
			<writeHost host="hostM1" url="192.168.101.69:3306" user="root" password="123456">
				<readHost host="hostS1" url="192.168.101.70:3306" user="root" password="123456"/>
			</writeHost>
		</dataHost>
</mycat:schema>
```  
