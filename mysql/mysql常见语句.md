

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
CREATE DATABASE IF NOT EXISTS books;    #如果不存在就创建

#删除数据库
drop database DB1;
DROP DATABASE IF EXISTS DB1;        #如果存在就删除

#清除表数据
truncate tablev T1

#创建表
create table T1 (id int(5) not null,name char(10) );

#插入值
insert into mysql.user(Host,User,Password) values("localhost","test",password("1234"));
insert into mysql.user values("localhost","test",password("1234"));   #可以不写字段，但是得写全values


insert into user set Host=192.168.1.1,User=admin,Password=password("1234");

insert into user SELECT 192.168.1.1,app,123;   #支持子查询的插入方式

#更新数据
update TABLE set user="user1" where user="user1";

#删除数据
delete from mysql.user where user="user1";

#使用表
use DB1；

#删除表
delete from T1；

#删除表（打碎表后再创建新表）
truncat T2； 

#修改库的字符集
ALTER DATABASE books CHARACTER SET utf8;

##############################修改表##############################
1.添加列
alter table 表名 add column 列名 类型 【first|after 字段名】;

2.修改列的类型或约束
alter table 表名 modify column 列名 新类型 【新约束】;

3.修改列名
alter table 表名 change column 旧列名 新列名 类型;

4 .删除列
alter table 表名 drop column 列名;

5.修改表名
alter table 表名 rename 【to】 新表名;

删除表
drop table【if exists】 表名;

复制表
1、复制表的结构
create table 表名 like 旧表;

2、复制表的结构+数据
create table 表名 
select 查询列表 from 旧表【where 筛选】;
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
去重后求和 select sum(distinct fieldl) from table1
```
- sum和avg 只能适应于数值型
- max和mix 可以适应于数值型和字符型，以及日期型
- count 只记录非NUlL的个数
- NULL+任何数值都为NULL
- SUM、AVG、MAX、MIN、COUNT函数都忽略NULL

```
#去重
select DISTINCT id from T1;

#查询的结果做拼接，若拼接的字段中有NULL则显示为NULL
select CONCAT(last_name,firest_name) AS 姓名 from employees;
select CONCAT(last_name,'_',firest_name) AS 姓名 from employees;      #指定分隔符

#判断如果结果为NULL则显示为自定义的值（commission_pct为空显示为0）
select IFNULL(commission_pct,0) AS 奖金,commission_pct FROM employees;

########################内连接########################

#1、等值连接，和不同表的连接
select 查询列表 from 表1 别名,表2 别名 where 表1.key=表2.key [and 筛选条件] [group by 分组字段] [having 分组后的筛选] [order by 排序字段]

select s.Name as stuName,c.Class as claName from students as s,classes as c where s.ClassID=c.ClassID;
sql99写法：INNER JOIN可以简写为JOIN
select s.Name as stuName,c.Class as claName from students as s INNER JOIN classes as c ON s.ClassID=c.ClassID;
SELECT city,COUNT(*) FROM departments d INNER JOIN locations l ON d.`location_id`=l.`localion_id` GROUP BY HAVING COUNT(*)>3;

select s.Name as StuName,t.Name as TeaName from students as s,teachers as t where s.teacherID=t.TID;


#2、非等值连接，和不同表的连接
select 查询列表 from 表1 别名,表2 别名 where 非等值的连接条件 [and 筛选条件] [group by 分组字段] [having 分组后的筛选] [order by 排序字段]

SELECT  salary,grade_level FROM employees e,job_grades g WHERE salary BETWEEN g.`lowest_sal` AND g.`highest_sal` AND g.`grade_level`='A';
sql99写法：INNER JOIN可以简写为JOIN
SELECT salary,grade_level FROM employess e JOIN job_grades g ON e.`salary` BETWEEN g.`lowest_sal` AND g.`highest_sal`;

#3、自连接,自己的表和自己的表连接
select 查询列表 from 表 别名1,表 别名2 where 等值的连接条件 [and 筛选条件] [group by 分组字段] [having 分组后的筛选] [order by 排序字段

select s.Name,t.Name from students as s,students as t where s.teacherID=t.StuID;
sql99写法：INNER JOIN可以简写为JOIN
select s.Name,t.Name from students as s JOIN students as t ON s.teacherID=t.StuID;


########################外连接########################

#1、左外连接  左边有的右边没有留空'LEFT OUTER JOIN'可简写
select s.Name,c.class from students as s LEFT JOIN classes as c ON s.classID=c.ClassId;

#2、右外连接  右边有的左边没有左边留空'RIGHT OUTER JOIN'可简写
select s.Name,c.class from students as s RIGHT JOIN classes as c ON s.classID=c.ClassId;

#3、全外连接
select s.Name,c.class from students as s FULL JOIN classes as c ON s.classID=c.ClassId;


###################联合查询###########################
#1、联合查询 将第一个表和第二个表合一起
select Name,Age from students UNION select Name,Age from teachers;  


########################子查询########################
#1、子查询
select Name,Age from students where Age>(select avg(Age) from students); 

2、子查询中的多行查询
#1）子查询 用于IN中
select Name,Age from students where Age IN (select Age from teachers); 
select Name,Age from students where Age NOT IN (select Age from teachers); 

#2）子查询 (ANY/SOME 和子查询返回的某一个值比较）any和some意思一样
select last_name,employee_id,job_id,salary FROM employees WHERE salary<ANY(select DISTINCT salary FROM employees WHERE job_id = 'IT_PROG');


#3）子查询 (ALL 和子查询返回的所有值比较)
select last_name,employee_id,job_id,salary FROM employees WHERE salary<ALL(select DISTINCT salary FROM employees WHERE job_id = 'IT_PROG');

#4、select后面
SELECT d.*,(SELECT COUNT(*) FROM employees e WHERE e.department_id = d.`department_id`) 个数 FROM departments d;

#5、子查询 用于from中
select s.aage,s.ClassID from (select avg(Age) as aage,ClassID from students where ClassID is not null group by ClassID) as s where s.aage>30;

#5、exists后面,结果只有1或者0，有值则为1，无值则为0
select EXISTS(SELECT employee_id FROM employees);

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

#IN语句,判断某字段的值是否属于in列表中的某一项
select last_name,job_id FROM employees WHERE job_id IN ('IT_PROT','AD_VP','ADPRESS');


#is null 判断值为空值时使用
select * FROM employees WHERE commission_pct IS NULL;

#is not null 判断值不为空值时使用
select * FROM employees WHERE commission_pct IS NOT NULL;


#排序:order by
select * from T1 order by yuwen; 从小到大
select * from T1 order by yuwen desc; 从大到小,默认asc不用输入 
select * from T1 order by yuwen desc limit 3; 打印前三行
select *,yuwen+shuxue+yingyu as total T1 order by total; 总分
select LENGTH(last_name) as a FROM employees ORDER BY a DESC;


#分组:group by
select 分组函数，分组后的字段 from 表 [where 筛选条件] group by 分组的字段 [having 分组后的筛选] [order by 排序列表]
update T1 set class=1 where id=1 || id=3;
update T1 set class=2 where id=2 or id=4;
select class,count(class) from T1; 没有分组信息
select class,count(class) from T1 group by class; 显示分组信息
#使用group by的时候不能用where 使用having 替换
select class，count（class） from T1 group by class where count（class）>=2; 不可以
select class，count（class） from T1 group by class having count（class）>=2; 可以
select MAX(salary),job_id FROM employees WHERE commission_pct IS NOT NOLL GROUP BY job_id HAVING MAX(salary) > 12000;
	     使用关键字     筛选的表           位置
分组前筛选    where         原始表             group by的前面
分组后筛选    having        分组后的结果        group by 的后面



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
