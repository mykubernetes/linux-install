1、集群规划
```
主机        服务           数据库
node01     mysql            mdb
node02     mysql mycat      gdb
node03     mysql            odb
```  

2、导入数据库
# node01
```
DROP DATABASE IF EXISTS mdb ;
CREATE DATABASE mdb CHARACTER SET UTF8 ;
use mdb ;
CREATE TABLE orders(
   oid INT  ,
   title VARCHAR(50) ,
   pubdate DATE ,
   CONSTRAINT pk_oid PRIMARY KEY(oid)
) ;


# node02
DROP DATABASE IF EXISTS gdb ;
CREATE DATABASE gdb CHARACTER SET UTF8 ;
use gdb ;
CREATE TABLE orders(
   oid INT  ,
   title VARCHAR(50) ,
   pubdate DATE ,
   CONSTRAINT pk_oid PRIMARY KEY(oid)
) ;


# node03
DROP DATABASE IF EXISTS odb ;
CREATE DATABASE odb CHARACTER SET UTF8 ;
use odb ;
CREATE TABLE orders(
   oid INT  ,
   title VARCHAR(50) ,
   pubdate DATE ,
   CONSTRAINT pk_oid PRIMARY KEY(oid)
) ;
```  

3、配置mycat  
```
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">
        <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="100">
                <table name="orders" primaryKey="oid" type="global" dataNode="dn1,dn2,dn3" rule="myorders-mod-long"/>
        </schema>
        <dataNode name="dn1" dataHost="localhost1" database="mdb" />
        <dataNode name="dn2" dataHost="localhost2" database="gdb" />
        <dataNode name="dn3" dataHost="localhost3" database="odb" />
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
        <dataHost name="localhost3" maxCon="1000" minCon="10" balance="2"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <writeHost host="hostM3" url="192.168.101.71:3306" user="root" password="123456"/>
        </dataHost>
</mycat:schema>
```  

4、配置规则  
```
# vim rule.xml
        <tableRule name="myorders-mod-long">        #名字对应上边配置的rule="myorders-mod-long" 名
                <rule>
                        <columns>id</columns>
                        <algorithm>mod-long</algorithm>
                </rule>
        </tableRule>
        
        
        <function name="myorders-mod-long" class="io.mycat.route.function.PartitionByMod">     #名字对应上边配置的rule="myorders-mod-long" 名
                <property name="count">3</property>
        </function>
```  

5、配置连接逻辑数据库
```
# vim server.xml
        <user name="root">
                <property name="password">123456</property>
                <property name="schemas">TESTDB</property>

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
