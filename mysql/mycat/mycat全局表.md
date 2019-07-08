1、集群规划

主机      服务                 表
node01   mysql          mdb.member mdb.dict
node02   mysql mycat    gdb.goods gbd.dict

2、导入表
---
# node01创建一个数据库两个表  
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



# node02创建一个数据库两个表  
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

