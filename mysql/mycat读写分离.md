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
mysqladmin -uroot password '123456'
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

4、配置mysql主从  
```
#在master端
# vim /etc/my.cnf
server_id=1
log_bin=mysql-bin-1
# systemctl restart mysql
# mysql -uroot -p123456
mysql> show master status;
+--------------------+----------+--------------+------------------+-------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+--------------------+----------+--------------+------------------+-------------------+
| mysql-bin-1.000001 |      120 |              |                  |                   |
+--------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
mysql> grant replication slave on *.* to 'repl_user'@'192.168.101.%' identified by 'repl_passwd';
mysql> flush privileges;



#在slave端
# vim /etc/my.cnf
server_id=1
log_bin=mysql-bin-1
# systemctl restart mysql
# mysql -uroot -p123456
mysql> stop slave;
mysql> change master to master_host='192.168.101.69', \
    -> master_user='repl_user', \
    -> master_password='repl_passwd', \
    -> master_log_file='mysql-bin.000001', \
    -> master_log_pos=120;
mysql> start slave;
mysql> show slave status\G
```  

5、配置hosts文件  
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
		<dataHost name="localhost1" maxCon="1000" minCon="10" balance="3" writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
			<!-- 配置真实MySQL与MyCat的心跳 -->
			<heartbeat>select user()</heartbeat>
			<!-- 配置真实的MySQL的连接路径 -->
			<writeHost host="hostM1" url="192.168.101.69:3306" user="root" password="123456">
			<readHost host="hostS1" url="192.168.101.70:3306" user="root" password="123456"/>
			</writeHost>
		</dataHost>
</mycat:schema>
```  
balance属性，负载均衡类型
- 0,不开启读写分离机制，所有读操作都发送到当前可用的writeHost上
- 1,全部的readHost与writeHost参与select语句的负载均衡
- 2,所有读操作都随机在writeHost、readHost上分发
- 3,所有读请求随机分发到wiriterHost对应的readHost执行，writerHost不负担读压力

writeType属性，复制均衡类型
- 0，所有的写操作发送到第一个writeHost,第一个挂了切到第二个writeHost
- 1，所有的写操作都随机的发送到配置的writeHost
- 2，没实现

switchType属性，有三种取值
- -1，表示不自动切换
- 1，默认值，自动切换
- 2，基于mysql主从同步状态决定是否切换


启动mycat :mycat start  
停止mycat:mycat stop  
前台运行:mycat console  
重启服务:mycat restart  
暂停:mycat pause  
查看启动状态:mycat status  

7、启动  
```
# mycat console      #查看日志是否有报错
# mycat start        #如果没有报错可以后台启动
```  

8、查看运行状态  
管理端口:9066 (查看mycat的运行状态)  
数据端口:8066 (进行数据的CRUD操作)  
```
# netstat -ntlup |grep 66
tcp6       0      0 :::8066                 :::*                    LISTEN      13777/java          
tcp6       0      0 :::9066                 :::*                    LISTEN      13777/java
```  

9、查看连接mycat用户密码权限  
```
# vim server.xml
        <user name="root">
                <property name="password">123456</property>
                <property name="schemas">TESTDB</property>   #TESTDB对应schema.xml配置文件的<schema name="TESTDB"配置

                <!-- 表级 DML 权限设置 -->
                <!--            
                <privileges check="false">
                        <schema name="TESTDB" dml="0110" >
                                <table name="tb01" dml="0000"></table>
                                <table name="tb02" dml="1111"></table>
                        </schema>
                </privileges>           
                 -->
        </user>

        <user name="user">
                <property name="password">user</property>
                <property name="schemas">TESTDB</property>
                <property name="readOnly">true</property>
        </user>
```  


10、连接mycat的管理端口  
```
# mysql -uroot -p123456 -h192.168.101.70 -P9066 -D TESTDB
# show @@help;      #查看所有管理命令
# show @@database;  #查看所有数据库
# show @@datanode;  #查看所有数据节点
show @@datasource;  #查看所有数据源
```  

11、进入数据端口  
```
# mysql -uroot -p123456 -h192.168.101.70 -P8066 -D TESTDB
```  

