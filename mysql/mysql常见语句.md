

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

#查看表结构
desc T1;

#查看当前mysql的版本号
select version();

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
选择：select * from table1 where 范围
插入：insert into table1(field1,field2) values(value1,value2)
删除：delete from table1 where 范围
更新：update table1 set field1=value1 where 范围
查找：select * from table1 where field1 like ’%value1%’ ---like的语法很精妙，查资料!
排序：select * from table1 order by field1,field2 [desc]
总数：select count as totalcount from table1
求和：select sum(field1) as sumvalue from table1
平均：select avg(field1) as avgvalue from table1
最大：select max(field1) as maxvalue from table1
最小：select min(field1) as minvalue from table1
```

```
#去重
select DISTINCT id from T1;

#查询的结果做拼接，若拼接的字段中有NULL则显示为NULL
select CONCAT(last_name,firest_name) AS 姓名 from employees;
select CONCAT(last_name,'_',firest_name) AS 姓名 from employees;      #指定分隔符

#判断如果结果为NULL则显示为自定义的值（commission_pct为空显示为0）
select IFNULL(commission_pct,0) AS 奖金,commission_pct FROM employees;


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
select Name,Age from students UNION select Name,Age from teachers;  

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

#at 别名,+号做数值运算
select name,shuxue+yuwen+yinyu as zongfen from T1;

#比较运算： > , < , >= , <= , !=, =

#逻辑运算：&& ||  !
and or not

#条件检索： where
select name FROM T1 WHERE yuwen=100;
select * FROM employees WHERE salary>=12000 AND salary<=20000;
select * FROM employees WHERE department_id<90 OR department_id>110 OR salary>15000;
select * FROM employees WHERE NOT(department_id<90 AND department_id>110) OR salary>15000;

#模糊查询，不适用比较符合,%代表任意多个字符,_代码任意单个字符
select * FROM employees WHERE last_name LIKE '%li%';

#模糊查询，查找第二个字符为_的员工名，转义字符\和转义表达式ESCAPE 自定义转义字符
select last_name FROM employees WHERE last_name LIKE '_\_%';
select last_name FROM employees WHERE last_name LIKE '_$_%' ESCAPE '$';

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

mysql_secure_installation安全配置向导
```
# mysql_secure_installation
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MySQL
SERVERS IN PRODUCTION USE! PLEASE READ EACH STEP CAREFULLY!
In order to log into MySQL to secure it, we'll need the current
password for the root user. If you've just installed MySQL, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.
Enter current password for root (enter for none):<–初次运行直接回车
OK, successfully used password, moving on…
Setting the root password ensures that nobody can log into the MySQL
root user without the proper authorisation.
Set root password? [Y/n]    #是否设置root用户密码，输入y并回车或直接回车
New password:               #设置root用户的密码
Re-enter new password:      #再输入一次你设置的密码
Password updated successfully!
Reloading privilege tables..
… Success!
By default, a MySQL installation has an anonymous user, allowing anyone
to log into MySQL without having to have a user account created for
them. This is intended only for testing, and to make the installation
go a bit smoother. You should remove them before moving into a
production environment.
Remove anonymous users? [Y/n]   #是否删除匿名用户,生产环境建议删除，所以直接回车
… Success!
Normally, root should only be allowed to connect from 'localhost'. This
ensures that someone cannot guess at the root password from the network.
Disallow root login remotely? [Y/n] #是否禁止root远程登录,根据自己的需求选择Y/n并回车,建议禁止
… Success!
By default, MySQL comes with a database named 'test' that anyone can
access. This is also intended only for testing, and should be removed
before moving into a production environment.
Remove test database and access to it? [Y/n] #是否删除test数据库,直接回车
- Dropping test database…
… Success!
- Removing privileges on test database…
… Success!
Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.
Reload privilege tables now? [Y/n] #是否重新加载权限表，直接回车
… Success!
Cleaning up…
All done! If you've completed all of the above steps, your MySQL
installation should now be secure.
Thanks for using MySQL!
```

- 设置密码
- 删除匿名用户
- 禁止root远程登录
- 删除test库和对test库的访问权限
- 刷新授权表使修改生效



MySQL批量SQL插入性能优化
---
1、一条SQL语句插入多条数据

常用的插入语句如：
```
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('0', 'userid_0', 'content_0', 0);
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('1', 'userid_1', 'content_1', 1);
```
修改成：
```
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('0', 'userid_0', 'content_0', 0), ('1', 'userid_1', 'content_1', 1);
```
- 降低日志刷盘的数据量和频率，从而提高效率。通过合并SQL语句，同时也能减少SQL语句解析的次数，减少网络传输的IO。

2、在事务中进行插入处理  
把插入修改成：
```
START TRANSACTION;
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('0', 'userid_0', 'content_0', 0);
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('1', 'userid_1', 'content_1', 1);
...
COMMIT;
```

3、数据有序插入

数据有序的插入是指插入记录在主键上是有序排列，例如datetime是记录的主键：
```
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('1', 'userid_1', 'content_1', 1);
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('0', 'userid_0', 'content_0', 0);
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('2', 'userid_2', 'content_2',2);
```
修改成：
```
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('0', 'userid_0', 'content_0', 0);
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('1', 'userid_1', 'content_1', 1);
INSERT INTO `insert_table` (`datetime`, `uid`, `content`, `type`) VALUES ('2', 'userid_2', 'content_2',2);
```
- 由于数据库插入时，需要维护索引数据，无序的记录会增大维护索引的成本
