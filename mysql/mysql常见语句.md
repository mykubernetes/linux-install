

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

#查看在哪个表
select database()；

#查看表
select * from T2; 
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

表结构修改
```
#修改表
alter table 表名 rename 新表名

#添加一列
alter table 表名 add 列名选项
#修改调整 类型
alter table 表名 modify 列名 类型

#修改调整 列名和类型
alter table 表名 change 列名 新表名+类型

#删除
alter table 表名 drop 列名
```


```
#数据运算：+ - * / % 加 减 乘 除 余数

#at 别名
select name,shuxue+yuwen+yinyu as zongfen from T1;

#比较运算： > , < , >= , <= , !=

#逻辑运算：与&& 或|| 非 not

#条件检索： where
select name from T1 where yuwen=100;

#区间检索：between...and
select name,yuwen from T1 where yuwen between 59 and 99;

#排序:order by
select * from T1 order by yuwen; 从小到大
select * from T1 order by yuwen desc; 从大到小
select * from T1 order by yuwen desc limit 3; 打印前三行
select *,yuwen+shuxue+yingyu as total T1 order by total; 总分

#分组:group by
update T1 set class=1 where id=1 || id=3;
update T1 set class=2 where id=2 or id=4;
select class,count(class) from T1; 没有分组信息
select class,count(class) from T1 group by class; 显示分组信息
#使用group by的时候不能用where 使用having 替换
select class，count（class） from T1 group by class where count（class）>=2; 不可以
select class，count（class） from T1 group by class having count（class）>=2; 可以

#统计函数:count sum avg max min
select avg（shuxue） from T1；
```

```
创建用户：
create user 用户名
用户名组成：'name'@'host'    name 相当于'name'@'%'

删除匿名用户：
delete from mysql.user where user='';

权限管理
show grants for user1;
GRANT ALL PRIVILEGES ON *.* TO 'user1'@'%';

GRANT 权限 ON 库.表 TO '用户名称'@'host';
grant create on db2.* to 'user3'@'10.1.1.11';

回收：
revoke create on db2.* from 'user3'@'10.1.1.11';

删除用户
drop user user1；

查看用户
select user，password，host from mysql.user;
```

```
mysql_secure_installation
1，设置密码
2，删除匿名用户
3，禁止root远程登录
4，删除测试数据库
5，是否重载设置
```
