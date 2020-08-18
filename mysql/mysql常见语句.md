

修改密码
```
mysqladmin -u root password '123456'
```

刷新
```
flush privileges；
```

修改配置文件不需要密码登录
```
vim /etc/my.cnf
skip-grant-tables
```

查看
```
#查看数据库
show databases;

#查看登陆的用户
show processlist;

查看警告
show warning;

#查看创建表的语句
show create DB1；

#产看表编辑内容
show create table T1; 

#查看用户权限
show grants for user1；
```


增删改操作
```
#创建数据库
create database DB1;

#删除数据库
drop database DB1;

#创建表
create table T1 (id int(5) not null,name char(10) );

#插入值
insert into mysql.user(Host,User,Password) values("localhost","test",password("1234"));

#更新数据
update TABLE set user="user1" where user="user1";

#删除数据
delete from mysql.user where user="user1";

#使用表
use DB1；

#删除表
delete from T1；

删除表（打碎表后再创建新表）
truncat T2； 
```

查询操作
```
#交叉连接
select s.Name as stuName,c.Class as claName from students as s,classes as c where s.ClassID=c.ClassID;

select s.Name as StuName,t.Name as TeaName from students as s,teachers as t where s.teacherID=t.TID;

#左外连接  左边有的右边没有留空
select s.Name,c.class from students as s LEFT JOIN classes as c ON s.classID=c.ClassId;

#右外连接  右边有的左边没有左边留空
select s.Name,c.class from students as s RIGHT JOIN classes as c ON s.classID=c.ClassId;

#自连接
select s.Name,t.Name from students as s,students as t where s.teacherID=t.StuID;

#联合查询 将第一个表和第二个表合一起
select Name,Age from students union select Name,Age from teachers;  

#子查询
select Name,Age from students where Age>(select avg(Age) from students); 

子查询 用于IN中
select Name,Age from students where Age IN (select Age from teachers); 

自查询 用于from中
select s.aage,s.ClassID from (select avg(Age) as aage,ClassID from students where ClassID is not null group by ClassID) as s where s.aage>30;

```
