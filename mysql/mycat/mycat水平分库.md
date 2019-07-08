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

