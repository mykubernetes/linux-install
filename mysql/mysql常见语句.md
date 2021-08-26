

修改密码
```
mysqladmin -u root password '123456'
alter user 'root@localhost' IDENTIFIED BY '123456';
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

```


数据类型
---
一、数值型

1、整形
| 整数类型	| 字节 | 范围 |
| :------: | :--------: | :------: |
| tinyint | 1 | 有符号：-128至127 无符号：0至255 |
| smallint | 2 | 有符号：-32768至32767 无符号：0至65535 |
| mediumint | 3 | 有符号：-8388608至8388607 无符号：0至1677215 |
| int/integer | 4 | 有符号：- 2147483648至2147483647 无符号：0至4294967295 |
| bigint | 8 | 有符号：-9223372036854775808至9223372036854775807 无符号：0至9223372036854775807*2+1 |

- 都可以设置无符号和有符号，默认有符号，通过unsigned设置无符号
- 如果超出了范围，会报out or range异常，插入临界值
- 长度可以不指定，默认会有一个长度  
长度代表显示的最大宽度，如果不够则左边用0填充，但需要搭配zerofill，并且默认变为无符号整型

2、小数
| 浮点数类型	| 字节 | 范围 |
| :------: | :--------: | :------: |
| float  | 4 | ±1.75494351E-38至±3.402823466E+38 |
| double | 8 | ±2.2250738585072014E-308至±1.7976931348623157E+308 |

| 定点数类型	| 字节 | 范围 |
| :------: | :--------: | :------: |
| DEC(M,D)/DECIMAL(M,D) | M+2 | 最大取值范围与double 相同 ， 给定decimal 的有效取值范围由M 和D决定 |
- M代表整数部位+小数部位的个数，D代表小数部位
- 如果超出范围，则报out or range异常，并且插入临界值
- M和D都可以省略，但对于定点数，M默认为10，D默认为0
- 如果精度要求较高，则优先考虑使用定点数

二、字符型

char、varchar、binary、varbinary、enum、set、text、blob
- 较长文本text、blob(较大的二进制)

1、位类型
| 位数类型	| 字节 | 范围 |
| :------: | :--------: | :------: |
| Bit(M) | 1~8 | Bit(1)~bit(8) |

2、char和varchar类型  
- 用来保存MySQL 中较短的字符串

| 字符串类型	| 最多字符数 | 描述及存储需求 | 特点 | 空间耗费 | 效率 |
| :------: | :--------: | :------: | :------: | :--------: | :------: |
| char(M) | M | M为0~255之间的整数 | 固定长度的字符 | 比较耗费 | 高 |
| varchar (M) | M | M为0~65535之间的整数 | 可变长度的字符 | 比较节省 | 低 |
- char：固定长度的字符，写法为char(M)，最大长度不能超过M，其中M可以省略，默认为1
- varchar：可变长度的字符，写法为varchar(M)，最大长度不能超过M，其中M不可以省略

3、binary和varbinary类型
- 类似于char 和varchar ，不同的是它们包含二进制字符串而不包含非二进制字符串

4、Enum类型
- 又称为枚举类型，要求插入的值必须属于列表中指定的值之一。如果列表成员为1至255，则需要1个字节存储，如果列表成员为255至65535，则需要2个字节存储最多需要65535个成员

5、Set类型
- 和Enum类型类似，里面可以保存0~64个成员。和Enum类型最大的区别是SET类型一次可以选取多个成员，而Enum只能选一个根据成员个数不同，存储所占的字节也不同

| 日期和时间类型 | 字节 | 最小值 | 最大值 |
| :------: | :--------: | :------: | :------: |
| date | 4 | 1000-01-01  | 9999-12-31 |
| datetime | 8 | 1000-01-01 00:00:00 |  9999-12-31 23:59:59 |
| timestamp  | 4 | 19700101080001 | 2038年的某个时刻 |
| time | 3 | -838:59:59 | 838:59:59 |
| year  | 1 | 1901 | 2155 |

datetime和timestamp的区别
- Timestamp支持的时间范围较小，取值范围：19700101080001—2038年的某个时间Datetime的取值范围：1000-1-1 —9999—12-31
- timestamp和实际时区有关，更能反映实际的日期，而datetime则只能反映出插入时的当地时区
- timestamp的属性受Mysql版本和SQLMode的影响很大


常见的约束
---
- NOT NULL：非空，该字段的值必填
- UNIQUE：唯一，该字段的值不可重复,可以为空
- DEFAULT：默认，该字段的值不用手动插入也会有默认值，设置默认值
- CHECK：检查，mysql不支持
- PRIMARY KEY：主键，该字段的值不可重复并且非空  unique+not null
- FOREIGN KEY：外键，该字段的值引用了另外的表的字段

主键和唯一
- 区别：一个表最多有一个主键，但可以有多个唯一。主键不允许为空，唯一可以为空
- 相同点都具有唯一性，都支持组合键，但不推荐

外键：
- 要求在从表设置外键关系，用于限制两个表的关系，从表的字段值引用了主表的某字段值
- 从表外键列和主表的被引用列要求类型一致或兼容，意义一样，名称无要求
- 主表的被引用列必须是一个key（一般就是主键或者唯一）
- 插入数据，先插入主表，再插入从表
- 删除数据，先删除从表,再删除主表

可以通过以下两种方式来删除主表的记录
```
#方式一：级联删除
ALTER TABLE stuinfo ADD CONSTRAINT fk_stu_major FOREIGN KEY(majorid) REFERENCES major(id) ON DELETE CASCADE;

#方式二：级联置空
ALTER TABLE stuinfo ADD CONSTRAINT fk_stu_major FOREIGN KEY(majorid) REFERENCES major(id) ON DELETE SET NULL;
```

创建表时添加约束
```
create table 表名(
	字段名 字段类型 not null,#非空
	字段名 字段类型 primary key,#主键
	字段名 字段类型 unique,#唯一
	字段名 字段类型 default 值,#默认
	constraint 约束名 foreign key(字段名) references 主表（被引用列）
)
```

|   | 支持类型 | 可以起约束名 |
| :------: | :--------: | :------: |
| 列级约束 | 表级约束 | 不可以 |
| 表级约束 | 除了非空和默认 | 可以，但对主键无效 |
- 列级约束可以在一个字段上追加多个，中间用空格隔开，没有顺序要求


修改表时添加或删除约束
```
1、非空
添加非空
alter table 表名 modify column 字段名 字段类型 not null;
删除非空
alter table 表名 modify column 字段名 字段类型 ;

2、默认
添加默认
alter table 表名 modify column 字段名 字段类型 default 值;
删除默认
alter table 表名 modify column 字段名 字段类型 ;

3、主键
添加主键
alter table 表名 add [constraint 约束名] primary key(字段名);
删除主键
alter table 表名 drop primary key;

4、唯一
添加唯一
alter table 表名 add [constraint 约束名] unique(字段名);
删除唯一
alter table 表名 drop index 索引名;

5、外键
添加外键
alter table 表名 add [constraint 约束名] foreign key(字段名) references 主表（被引用列）;
删除外键
alter table 表名 drop foreign key 约束名;
```

自增长列
---
- 不用手动插入值，可以自动提供序列值，默认从1开始，步长为1
  - auto_increment
  - 如果要更改起始值：手动插入值
  - 如果要更改步长：更改系统变量
  - set auto_increment=值;
- 一个表至多有一个自增长列
- 自增长列只能支持数值型
- 自增长列必须为一个key

```
1、创建表时设置自增长列
create table 表(
	字段名 字段类型 约束 auto_increment
)

2、修改表时设置自增长列
alter table 表 modify column 字段名 字段类型 约束 auto_increment

3、删除自增长列
alter table 表 modify column 字段名 字段类型 约束 
```

DDL语音
===
```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
6 rows in set (0.02 sec)

##############################数据库操作##############################
#创建数据库
create database 库名;
CREATE DATABASE [IF NOT EXISTS] 库名;    #如果不存在就创建

create database [if not exists] 库名 [character set 字符集名];

#删除数据库
drop database 库名;
DROP DATABASE [IF EXISTS] 库名;        #如果存在就删除

##############################表操作##############################
#使用表
use 表名；

#创建表
create table 表名 (id int(5) not null,name char(10) );
CREATE TABLE [IF  NOT EXISTS] 表名 (id int(5) not null,name char(10) );

删除表
drop table [if exists] 表名;

##############################修改表##############################
1.添加列
alter table 表名 add column 列名 类型 [first|after 字段名];

2.修改列的类型或约束
alter table 表名 modify column 列名 新类型 [新约束];

3.修改列名
alter table 表名 change column 旧列名 新列名 类型;

4 .删除列
alter table 表名 drop column 列名;

5.修改表名
alter table 表名 rename [to] 新表名;

#修改库的字符集
ALTER DATABASE books CHARACTER SET utf8;

复制表
1、复制表的结构
create table 表名 like 旧表;

2、复制表的结构+数据
create table 表名 select 查询列表 from 旧表 [where 筛选];
```

DML语言
===
```
#插入值
insert into mysql.user(Host,User,Password) values("localhost","test",password("1234"));
insert into mysql.user values("localhost","test",password("1234"));   #可以不写字段，但是得写全values

insert into user set Host=192.168.1.1,User=admin,Password=password("1234");

insert into user SELECT 192.168.1.1,app,123;   #支持子查询的插入方式

#更新数据
update TABLE set user="user1" where user="user1";

#删除数据
delete from mysql.user where user="user1";
delete from T1；

#清除表数据
truncate table T1
```

delete和truncate的区别
- truncate删除后，如果再插入，标识列从1开始，delete删除后，如果再插入，标识列从断点开始
- delete可以添加筛选条件，truncate不可以添加筛选条件
- truncate效率较高
- truncate没有返回值，delete可以返回受影响的行数
- truncate不可以回滚，delete可以回滚


DQL语言
===
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

#6、exists后面,结果只有1或者0，有值则为1，无值则为0
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
===
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
===
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


插入user表user和passwd,如果存在就修改，如果不存在就创建
```
INSERT INTO user(username,password) VALUES('admin','passwd') ON DUPLICATE KEY UPDATE password = 'passwd';
```

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

系统变量
===
- 变量由系统提供的，不用自定义

- 全局变量: 服务器层面上的，必须拥有super权限才能为系统变量赋值，作用域为整个服务器，也就是针对于所有连接（会话）有效,重启失效
- 会话变量: 服务器为每一个连接的客户端都提供了系统变量，作用域为当前的连接（会话）


1、查看所有的系统变量，如果没有显式声明global还是session，则默认是session
```
show [global|session] variables;
```

2、查看满足条件的部分系统变量，如果没有显式声明global还是session，则默认是session
```
show [global|session] variables like '%char%'; 
```

3、查看指定的系统变量的值，如果没有显式声明global还是session，则默认是session
```
select @@[global|session].系统变量名;
```

4、为系统变量赋值
```
方式一：如果没有显式声明global还是session，则默认是session
set [global|session] 变量名=值;

方式二：
set @@global.变量名=值;
set @@变量名=值；
```


自定义变量
---
1、用户变量
- 作用域：针对于当前连接（会话）生效
- 位置：begin end里面，也可以放在外面

使用：
```
1、声明并赋值：
set @变量名=值;
set @变量名:=值;
select @变量名:=值;

2、更新值
方式一：
	set @变量名=值;
	set @变量名:=值;
	select @变量名:=值;
方式二：
	select 字段 into @变量名 from 表;

3、使用
select @变量名;
```


2、局部变量
- 作用域：仅仅在定义它的begin end中有效
- 位置：只能放在begin end中，而且只能放在第一句

使用：
```
1、声明
declare 变量名 类型 [default 值];

2、赋值或更新
方式一：
	set 变量名=值;
	set 变量名:=值;
	select @变量名:=值;
方式二：
	select xx into 变量名 from 表;

3、使用
select 变量名;

```










```
CREATE DATABASE IF NOT EXISTS hos
  DEFAULT CHARACTER SET UTF8
  COLLATE UTF8_GENERAL_CI;

USE hos;

--
-- Table structure for table `USER_INFO`
--
DROP TABLE IF EXISTS USER_INFO;

CREATE TABLE USER_INFO
(
  USER_ID     VARCHAR(32) NOT NULL,
  USER_NAME   VARCHAR(32) NOT NULL,
  PASSWORD    VARCHAR(64) NOT NULL
  COMMENT 'PASSWORD md5',
  SYSTEM_ROLE VARCHAR(32) NOT NULL
  COMMENT 'ADMIN OR USER',
  CREATE_TIME TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  DETAIL      VARCHAR(256),
  PRIMARY KEY (USER_ID),
  UNIQUE KEY AK_UQ_USER_NAME (USER_NAME)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = '用户信息';

--
-- Table structure for table `TOKEN_INFO`
--

DROP TABLE IF EXISTS TOKEN_INFO;

CREATE TABLE TOKEN_INFO
(
  TOKEN        VARCHAR(32) NOT NULL,
  EXPIRE_TIME  INT(11)     NOT NULL,
  CREATE_TIME  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  REFRESH_TIME TIMESTAMP   NOT NULL,
  ACTIVE       TINYINT     NOT NULL,
  CREATOR      VARCHAR(32) NOT NULL,
  PRIMARY KEY (TOKEN)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'token 信息表';

--
-- Table structure for table `HOS_BUCKET`
--

DROP TABLE IF EXISTS HOS_BUCKET;

CREATE TABLE HOS_BUCKET (
  BUCKET_ID   VARCHAR(32),
  BUCKET_NAME VARCHAR(32),
  CREATE_TIME TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  DETAIL      VARCHAR(256),
  CREATOR     VARCHAR(32) NOT NULL,
  UNIQUE KEY AK_KEY_BUCKET_NAME(BUCKET_NAME),
  PRIMARY KEY (BUCKET_ID)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'HOS BUCKET';

--
-- Table structure for table SERVICE_AUTH
--

DROP TABLE IF EXISTS SERVICE_AUTH;

CREATE TABLE SERVICE_AUTH
(
  BUCKET_NAME  VARCHAR(32) NOT NULL,
  TARGET_TOKEN VARCHAR(32) NOT NULL
  COMMENT '被授权对象token',
  AUTH_TIME    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (BUCKET_NAME, TARGET_TOKEN)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = '对象存储服务授权表';
```
