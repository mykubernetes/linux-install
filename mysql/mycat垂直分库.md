mycat垂直分库
===

1、架构分配  
node01 mysql01   
node02 mysqp02 mycat  

2、两台mysql分别导入数据库
# node01  
```
DROP DATABASE IF EXISTS mdb ;
CREATE DATABASE mdb CHARACTER SET UTF8 ;
use mdb ;
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

# node02  
```
DROP DATABASE IF EXISTS gdb ;
CREATE DATABASE gdb CHARACTER SET UTF8 ;
use gdb ;
CREATE TABLE goods(
   gid INT AUTO_INCREMENT ,
   title VARCHAR(50) ,
   price DOUBLE ,
   CONSTRAINT pk_gid PRIMARY KEY(gid)
) ;
```  

3、配置mycat  
```
# vim schema.xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">
        <schema name="TESTGDB" checkSQLschema="false" sqlMaxLimit="100" dataNode="dnGdb"/>
        <schema name="TESTMDB" checkSQLschema="false" sqlMaxLimit="100" dataNode="dnMdb"/>
        <dataNode name="dnGdb" dataHost="localhost1" database="gdb" />
        <dataNode name="dnMdb" dataHost="localhost2" database="mdb" />
        <dataHost name="localhost1" maxCon="1000" minCon="10" balance="2"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <writeHost host="hostM1" url="192.168.101.69:3306" user="root" password="123456"/>
        </dataHost>
        <dataHost name="localhost2" maxCon="1000" minCon="10" balance="2"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <writeHost host="hostM2" url="192.168.101.70:3306" user="root" password="123456"/>
        </dataHost>
</mycat:schema>
```  
