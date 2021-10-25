# 创建表（并初始化数据）
```
-- 学生表
CREATE TABLE `student`(
`s_id` VARCHAR(20),
`s_name` VARCHAR(20) NOT NULL DEFAULT '',
`s_birth` VARCHAR(20) NOT NULL DEFAULT '',
`s_sex` VARCHAR(10) NOT NULL DEFAULT '',
PRIMARY KEY(`s_id`)
);
-- 课程表
CREATE TABLE `course`(
`c_id` VARCHAR(20),
`c_name` VARCHAR(20) NOT NULL DEFAULT '',
`t_id` VARCHAR(20) NOT NULL,
PRIMARY KEY(`c_id`)
);
-- 教师表
CREATE TABLE `teacher`(
`t_id` VARCHAR(20),
`t_name` VARCHAR(20) NOT NULL DEFAULT '',
PRIMARY KEY(`t_id`)
);
-- 成绩表
CREATE TABLE `score`(
`s_id` VARCHAR(20),
`c_id` VARCHAR(20),
`s_score` INT(3),
PRIMARY KEY(`s_id`,`c_id`)
);

-- 插入学生表测试数据
insert into student values('01' , '赵信' , '1990-01-01' , '男');
insert into student values('02' , '德莱厄斯' , '1990-12-21' , '男');
insert into student values('03' , '艾希' , '1990-05-20' , '男');
insert into student values('04' , '德莱文' , '1990-08-06' , '男');
insert into student values('05' , '俄洛依' , '1991-12-01' , '女');
insert into student values('06' , '光辉女郎' , '1992-03-01' , '女');
insert into student values('07' , '崔丝塔娜' , '1989-07-01' , '女');
insert into student values('08' , '安妮' , '1990-01-20' , '女');
-- 课程表测试数据
insert into course values('01' , '语文' , '02');
insert into course values('02' , '数学' , '01');
insert into course values('03' , '英语' , '03');

-- 教师表测试数据
insert into teacher values('01' , '死亡歌颂者');
insert into teacher values('02' , '流浪法师');
insert into teacher values('03' , '邪恶小法师');

-- 成绩表测试数据
insert into score values('01' , '01' , 80);
insert into score values('01' , '02' , 90);
insert into score values('01' , '03' , 99);
insert into score values('02' , '01' , 70);
insert into score values('02' , '02' , 60);
insert into score values('02' , '03' , 80);
insert into score values('03' , '01' , 80);
insert into score values('03' , '02' , 80);
insert into score values('03' , '03' , 80);
insert into score values('04' , '01' , 50);
insert into score values('04' , '02' , 30);
insert into score values('04' , '03' , 20);
insert into score values('05' , '01' , 76);
insert into score values('05' , '02' , 87);
insert into score values('06' , '01' , 31);
insert into score values('06' , '03' , 34);
insert into score values('07' , '02' , 89);
insert into score values('07' , '03' , 98);
```



# 表结构
- 这里建的表主要用于sql语句的练习，所以并没有遵守一些规范。下面让我们来看看相关的表结构吧

## 学生表（student）

```
mysql> desc student;
+---------+-------------+------+-----+---------+-------+
| Field   | Type        | Null | Key | Default | Extra |
+---------+-------------+------+-----+---------+-------+
| s_id    | varchar(20) | NO   | PRI | NULL    |       |
| s_name  | varchar(20) | NO   |     |         |       |
| s_birth | varchar(20) | NO   |     |         |       |
| s_sex   | varchar(10) | NO   |     |         |       |
+---------+-------------+------+-----+---------+-------+
4 rows in set (0.00 sec)
```
- s_id = 学生编号，s_name = 学生姓名，s_birth = 出生年月，s_sex = 学生性别

## 课程表（course）

```
mysql> desc course;
+--------+-------------+------+-----+---------+-------+
| Field  | Type        | Null | Key | Default | Extra |
+--------+-------------+------+-----+---------+-------+
| c_id   | varchar(20) | NO   | PRI | NULL    |       |
| c_name | varchar(20) | NO   |     |         |       |
| t_id   | varchar(20) | NO   |     | NULL    |       |
+--------+-------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
```
- c_id = 课程编号，c_name = 课程名称，t_id = 教师编号

## 教师表（teacher）

```
mysql> desc teacher;
+--------+-------------+------+-----+---------+-------+
| Field  | Type        | Null | Key | Default | Extra |
+--------+-------------+------+-----+---------+-------+
| t_id   | varchar(20) | NO   | PRI | NULL    |       |
| t_name | varchar(20) | NO   |     |         |       |
+--------+-------------+------+-----+---------+-------+
2 rows in set (0.00 sec)
```
- t_id = 教师编号，t_name = 教师姓名

## 成绩表（score）

```
mysql> desc score;
+---------+-------------+------+-----+---------+-------+
| Field   | Type        | Null | Key | Default | Extra |
+---------+-------------+------+-----+---------+-------+
| s_id    | varchar(20) | NO   | PRI | NULL    |       |
| c_id    | varchar(20) | NO   | PRI | NULL    |       |
| s_score | int(3)      | YES  |     | NULL    |       |
+---------+-------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
```
- s_id = 学生编号，c_id = 课程编号，s_score = 分数


# 习题

- 开始之前我们先来看看四张表中的数据。

## course表
```
mysql> select * from course;
+------+--------+------+
| c_id | c_name | t_id |
+------+--------+------+
| 01   | 语文   | 02   |
| 02   | 数学   | 01   |
| 03   | 英语   | 03   |
+------+--------+------+
3 rows in set (0.00 sec)
```

## score表
```
mysql> select * from score;
+------+------+---------+
| s_id | c_id | s_score |
+------+------+---------+
| 01   | 01   |      80 |
| 01   | 02   |      90 |
| 01   | 03   |      99 |
| 02   | 01   |      70 |
| 02   | 02   |      60 |
| 02   | 03   |      80 |
| 03   | 01   |      80 |
| 03   | 02   |      80 |
| 03   | 03   |      80 |
| 04   | 01   |      50 |
| 04   | 02   |      30 |
| 04   | 03   |      20 |
| 05   | 01   |      76 |
| 05   | 02   |      87 |
| 06   | 01   |      31 |
| 06   | 03   |      34 |
| 07   | 02   |      89 |
| 07   | 03   |      98 |
+------+------+---------+
18 rows in set (0.00 sec)
```

## student表
```
mysql> select * from student;
+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 01   | 赵信         | 1990-01-01 | 男    |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |
| 03   | 艾希         | 1990-05-20 | 男    |
| 04   | 德莱文       | 1990-08-06 | 男    |
| 05   | 俄洛依       | 1991-12-01 | 女    |
| 06   | 光辉女郎     | 1992-03-01 | 女    |
| 07   | 崔丝塔娜     | 1989-07-01 | 女    |
| 08   | 安妮         | 1990-01-20 | 女    |
+------+--------------+------------+-------+
8 rows in set (0.00 sec)
```

## teacher表
```
mysql> select * from teacher;
+------+-----------------+
| t_id | t_name          |
+------+-----------------+
| 01   | 死亡歌颂者      |
| 02   | 流浪法师        |
| 03   | 邪恶小法师      |
+------+-----------------+
3 rows in set (0.00 sec)
```
