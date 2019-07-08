1、集群规划  
```
主机      服务                 表
node01   mysql          mdb.member mdb.dict
node02   mysql mycat    gdb.goods gbd.dict
```  

2、导入表  
node01创建一个数据库两个表  
```
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


CREATE TABLE dict(
   did INT AUTO_INCREMENT ,
   title VARCHAR(50) ,
   content VARCHAR(200) ,
   CONSTRAINT pk_did PRIMARY KEY(did)
) ;
```  



node02创建一个数据库两个表  
```
CREATE DATABASE gdb CHARACTER SET UTF8 ;
use gdb ;
CREATE TABLE goods(
   gid INT AUTO_INCREMENT ,
   title VARCHAR(50) ,
   price DOUBLE ,
   CONSTRAINT pk_gid PRIMARY KEY(gid)
) ;


CREATE TABLE dict(
   did INT AUTO_INCREMENT ,
   title VARCHAR(50) ,
   content VARCHAR(200) ,
   CONSTRAINT pk_did PRIMARY KEY(did)
) ;
```  

3、配置mycat  
```
# vim schema.xml
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">
        <schema name="TESTADB" checkSQLschema="false" sqlMaxLimit="100">
                <table name="dict" primaryKey="did" type="global" dataNode="dnGdb,dnMdb"/>
        </schema>
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


4、配置连接逻辑数据库  
```
        <user name="root">
                <property name="password">123456</property>
                <property name="schemas">TESTGDB,TESTMDB,TESTADB</property>

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
                <property name="schemas">TESTGDB,TESTMDB,TESTADB</property>
                <property name="readOnly">true</property>
        </user>
```  

测试  
```
# mysql -uroot -p123456 -h192.168.101.70 -P8066 -D TESTADB
mysql> show tables;
+-------------------+
| Tables in TESTADB |
+-------------------+
| dict              |
+-------------------+
1 row in set (0.00 sec)

mysql> insert into dict(title,content) values ('news','mldn');
Query OK, 1 row affected (2.21 sec)

mysql> select * from dict;
+-----+-------+---------+
| did | title | content |
+-----+-------+---------+
|   1 | news  | mldn    |
+-----+-------+---------+
1 row in set (0.32 sec)

#分别进入node01和node02测试
# node01
mysql> select * from dict;
+-----+-------+---------+
| did | title | content |
+-----+-------+---------+
|   1 | news  | mldn    |
+-----+-------+---------+
1 row in set (0.01 sec)

# node02
mysql> select * from dict;
+-----+-------+---------+
| did | title | content |
+-----+-------+---------+
|   1 | news  | mldn    |
+-----+-------+---------+
1 row in set (0.01 sec)
说明全局数据表，可以一次写入多个数据库
```  
