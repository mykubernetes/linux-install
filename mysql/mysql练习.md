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

### 1. 查询"01"课程比"02"课程成绩高的学生的信息及课程分数

```
SELECT
	st.*,
	sc.s_score AS '语文',
	sc2.s_score '数学' 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
	AND sc.c_id = '01'
	LEFT JOIN score sc2 ON sc2.s_id = st.s_id 
	AND sc2.c_id = '02';

+------+--------------+------------+-------+--------+--------+
| s_id | s_name       | s_birth    | s_sex | 语文   | 数学   |
+------+--------------+------------+-------+--------+--------+
| 01   | 赵信         | 1990-01-01 | 男    |     80 |     90 |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |     70 |     60 |
| 03   | 艾希         | 1990-05-20 | 男    |     80 |     80 |
| 04   | 德莱文       | 1990-08-06 | 男    |     50 |     30 |
| 05   | 俄洛依       | 1991-12-01 | 女    |     76 |     87 |
| 06   | 光辉女郎     | 1992-03-01 | 女    |     31 |   NULL |
| 07   | 崔丝塔娜     | 1989-07-01 | 女    |   NULL |     89 |
| 08   | 安妮         | 1990-01-20 | 女    |   NULL |   NULL |
+------+--------------+------------+-------+--------+--------+
8 rows in set (0.00 sec)
```

### 2. 查询"01"课程比"02"课程成绩低的学生的信息及课程分数

```
SELECT
	st.*,
	s.s_score AS 数学,
	s2.s_score AS 语文 
FROM
	student st
	LEFT JOIN score s ON s.s_id = st.s_id 
	AND s.c_id = '01'
	LEFT JOIN score s2 ON s2.s_id = st.s_id 
	AND s2.c_id = '02' 
WHERE
	s.s_score < s2.s_score;

+------+-----------+------------+-------+--------+--------+
| s_id | s_name    | s_birth    | s_sex | 数学   | 语文   |
+------+-----------+------------+-------+--------+--------+
| 01   | 赵信      | 1990-01-01 | 男    |     80 |     90 |
| 05   | 俄洛依    | 1991-12-01 | 女    |     76 |     87 |
+------+-----------+------------+-------+--------+--------+
2 rows in set (0.00 sec)
```

### 3. 查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩

```
SELECT
    -> st.s_id AS '学生编号',
    -> st.s_name AS '学生姓名',
    -> AVG( s.s_score ) AS avgScore 
    -> FROM
    -> student st
    -> LEFT JOIN score s ON st.s_id = s.s_id 
    -> GROUP BY
    -> st.s_id 
    -> HAVING
    -> avgScore >= 60;

+--------------+--------------+----------+
| 学生编号     | 学生姓名     | avgScore |
+--------------+--------------+----------+
| 01           | 赵信         |  89.6667 |
| 02           | 德莱厄斯     |  70.0000 |
| 03           | 艾希         |  80.0000 |
| 05           | 俄洛依       |  81.5000 |
| 07           | 崔丝塔娜     |  93.5000 |
+--------------+--------------+----------+
5 rows in set (0.00 sec)

```

### 4. 查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩
(包括有成绩的和无成绩的)
```
SELECT
	st.s_id AS '学生编号',
	st.s_name AS '学生姓名',(
	CASE
			
			WHEN ROUND( AVG( sc.s_score ), 2 ) IS NULL THEN
			0 ELSE ROUND( AVG( sc.s_score ), 2 ) 
		END 
		) 
	FROM
		student st
		LEFT JOIN score sc ON st.s_id = sc.s_id 
	GROUP BY
		st.s_id 
	HAVING
	AVG( sc.s_score )< 60 
	OR AVG( sc.s_score ) IS NULL;

+--------------+--------------+------------------------------------------------------------------------------------------------------+
| 学生编号     | 学生姓名     | ( CASE  WHEN ROUND( AVG( sc.s_score ), 2 ) IS NULL THEN 0 ELSE ROUND( AVG( sc.s_score ), 2 )  END  ) |
+--------------+--------------+------------------------------------------------------------------------------------------------------+
| 04           | 德莱文       |                                                                                                33.33 |
| 06           | 光辉女郎     |                                                                                                32.50 |
| 08           | 安妮         |                                                                                                    0 |
+--------------+--------------+------------------------------------------------------------------------------------------------------+
3 rows in set (0.00 sec)
```

### 5. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩

```
SELECT
	st.s_id AS '学生编号',
	st.s_name AS '学生姓名',
	COUNT( sc.c_id ) AS '选课总数',
	sum( CASE WHEN sc.s_score IS NULL THEN 0 ELSE sc.s_score END ) AS '总成绩' 
FROM
	student st
	LEFT JOIN score sc ON st.s_id = sc.s_id 
GROUP BY
	st.s_id;

+--------------+--------------+--------------+-----------+
| 学生编号     | 学生姓名     | 选课总数     | 总成绩    |
+--------------+--------------+--------------+-----------+
| 01           | 赵信         |            3 |       269 |
| 02           | 德莱厄斯     |            3 |       210 |
| 03           | 艾希         |            3 |       240 |
| 04           | 德莱文       |            3 |       100 |
| 05           | 俄洛依       |            2 |       163 |
| 06           | 光辉女郎     |            2 |        65 |
| 07           | 崔丝塔娜     |            2 |       187 |
| 08           | 安妮         |            0 |         0 |
+--------------+--------------+--------------+-----------+
8 rows in set (0.00 sec)
```

### 6. 查询"流"姓老师的数量

```
SELECT COUNT(t_id) FROM teacher WHERE t_name LIKE '流%';

+-------------+
| COUNT(t_id) |
+-------------+
|           1 |
+-------------+
1 row in set (0.00 sec)
```

### 7. 查询学过"流浪法师"老师授课的同学的信息

```
SELECT
	st.* 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id
	LEFT JOIN course cs ON cs.c_id = sc.c_id
	LEFT JOIN teacher tc ON tc.t_id = cs.t_id 
	WHERE tc.t_name = '流浪法师';

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 01   | 赵信         | 1990-01-01 | 男    |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |
| 03   | 艾希         | 1990-05-20 | 男    |
| 04   | 德莱文       | 1990-08-06 | 男    |
| 05   | 俄洛依       | 1991-12-01 | 女    |
| 06   | 光辉女郎     | 1992-03-01 | 女    |
+------+--------------+------------+-------+
6 rows in set (0.00 sec)
```

### 8. 查询没学过"张三"老师授课的同学的信息

```
-- 查询流浪法师教的课
SELECT
	cs.* 
FROM
	course cs
	LEFT JOIN teacher tc ON tc.t_id = cs.t_id 
WHERE
	tc.t_name = '流浪法师';



-- 查询有流浪法师课程成绩的学生id
SELECT
	sc.s_id 
FROM
	score sc 
WHERE
	sc.c_id IN (
	SELECT
		cs.c_id 
	FROM
		course cs
		LEFT JOIN teacher tc ON tc.t_id = cs.t_id 
	WHERE
	tc.t_name = '流浪法师');



-- 取反，查询没有学过流浪法师课程的同学信息
SELECT
	st.* 
FROM
	student st 
WHERE
	st.s_id NOT IN (
	SELECT
		sc.s_id 
	FROM
		score sc 
	WHERE
	sc.c_id IN ( SELECT cs.c_id FROM course cs LEFT JOIN teacher tc ON tc.t_id = cs.t_id WHERE tc.t_name = '流浪法师' ) 
	);

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 07   | 崔丝塔娜     | 1989-07-01 | 女    |
| 08   | 安妮         | 1990-01-20 | 女    |
+------+--------------+------------+-------+
2 rows in set (0.00 sec)
```

### 9. 查询学过编号为"01"并且也学过编号为"02"的课程的同学的信息
- 方法 1
```
-- 查询学过编号为01课程的同学id
SELECT
	st.s_id 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id
	INNER JOIN course cs ON cs.c_id = sc.c_id 
	AND cs.c_id = '01';
	
	

-- 查询学过编号为02课程的同学id
SELECT
	st2.s_id 
FROM
	student st2
	INNER JOIN score sc2 ON sc2.s_id = st2.s_id
	INNER JOIN course cs2 ON cs2.c_id = sc2.c_id 
	AND cs2.c_id = '02';
	
	

-- 查询学过编号为"01"并且也学过编号为"02"的课程的同学的信息
SELECT
	st.* 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id
	INNER JOIN course cs ON cs.c_id = sc.c_id 
	AND sc.c_id = '01' 
WHERE
	st.s_id IN (
	SELECT
		st2.s_id 
	FROM
		student st2
		INNER JOIN score sc2 ON sc2.s_id = st2.s_id
		INNER JOIN course cs2 ON cs2.c_id = sc2.c_id 
		AND cs2.c_id = '02' 
	);

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 01   | 赵信         | 1990-01-01 | 男    |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |
| 03   | 艾希         | 1990-05-20 | 男    |
| 04   | 德莱文       | 1990-08-06 | 男    |
| 05   | 俄洛依       | 1991-12-01 | 女    |
+------+--------------+------------+-------+
5 rows in set (0.00 sec)
```

- 方法 2
```
SELECT
	a.* 
FROM
	student a,
	score b,
	score c 
WHERE
	a.s_id = b.s_id 
	AND a.s_id = c.s_id 
	AND b.c_id = '01' 
	AND c.c_id = '02';

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 01   | 赵信         | 1990-01-01 | 男    |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |
| 03   | 艾希         | 1990-05-20 | 男    |
| 04   | 德莱文       | 1990-08-06 | 男    |
| 05   | 俄洛依       | 1991-12-01 | 女    |
+------+--------------+------------+-------+
5 rows in set (0.00 sec)
```

### 10. 查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息
```
SELECT
	st.s_id 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id
	INNER JOIN course cs ON cs.c_id = sc.c_id 
	AND cs.c_id = '01' 
WHERE
	st.s_id NOT IN (
	SELECT
		st.s_id 
	FROM
		student st
		INNER JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course cs ON cs.c_id = sc.c_id 
		AND cs.c_id = '02' 
	);

+------+
| s_id |
+------+
| 06   |
+------+
1 row in set (0.00 sec)
```

### 11. 查询没有学全所有课程的同学的信息

- 方法 1
```
SELECT
	* 
FROM
	student 
WHERE
	s_id NOT IN (
	SELECT
		st.s_id 
	FROM
		student st
		INNER JOIN score sc ON sc.s_id = st.s_id 
		AND sc.c_id = '01' 
	WHERE
		st.s_id IN (
		SELECT
			st.s_id 
		FROM
			student st
			INNER JOIN score sc ON sc.s_id = st.s_id 
			AND sc.c_id = '02' 
		WHERE
			st.s_id 
		) 
		AND st.s_id IN (
		SELECT
			st.s_id 
		FROM
			student st
			INNER JOIN score sc ON sc.s_id = st.s_id 
			AND sc.c_id = '03' 
		WHERE
			st.s_id 
		) 
	);

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 05   | 俄洛依       | 1991-12-01 | 女    |
| 06   | 光辉女郎     | 1992-03-01 | 女    |
| 07   | 崔丝塔娜     | 1989-07-01 | 女    |
| 08   | 安妮         | 1990-01-20 | 女    |
+------+--------------+------------+-------+
4 rows in set (0.00 sec)
```

- 方法 2
```
SELECT
	a.* 
FROM
	student a
	LEFT JOIN score b ON a.s_id = b.s_id 
GROUP BY
	a.s_id 
HAVING
	COUNT( b.c_id ) != '3';

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 05   | 俄洛依       | 1991-12-01 | 女    |
| 06   | 光辉女郎     | 1992-03-01 | 女    |
| 07   | 崔丝塔娜     | 1989-07-01 | 女    |
| 08   | 安妮         | 1990-01-20 | 女    |
+------+--------------+------------+-------+
4 rows in set (0.00 sec)
```

### 12. 查询至少有一门课与学号为"01"的同学所学相同的同学的信息
```
SELECT DISTINCT
	st.* 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
WHERE
	sc.c_id IN ( SELECT sc2.c_id FROM student st2 LEFT JOIN score sc2 ON sc2.s_id = st2.s_id WHERE st2.s_id = '01' );
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
+------+--------------+------------+-------+
7 rows in set (0.00 sec)
```

### 13. 查询和"01"号的同学学习的课程完全相同的其他同学的信息

```
SELECT
	st.* 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
GROUP BY
	st.s_id 
HAVING
	GROUP_CONCAT( sc.c_id )=(
	SELECT
		GROUP_CONCAT( sc2.c_id ) 
	FROM
		student st2
		LEFT JOIN score sc2 ON sc2.s_id = st2.s_id 
	WHERE
		st2.s_id = '01' 
	);

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 01   | 赵信         | 1990-01-01 | 男    |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |
| 03   | 艾希         | 1990-05-20 | 男    |
| 04   | 德莱文       | 1990-08-06 | 男    |
+------+--------------+------------+-------+
4 rows in set (0.00 sec)
```


### 14. 查询没学过"邪恶小法师"老师讲授的任一门课程的学生姓名

```
SELECT
	* 
FROM
	student 
WHERE
	s_id NOT IN (
	SELECT
		sc.s_id 
	FROM
		score sc
		INNER JOIN course cs ON cs.c_id = sc.c_id
	INNER JOIN teacher t ON t.t_id = cs.t_id 
	AND t.t_name = '邪恶小法师');

+------+-----------+------------+-------+
| s_id | s_name    | s_birth    | s_sex |
+------+-----------+------------+-------+
| 05   | 俄洛依    | 1991-12-01 | 女    |
| 08   | 安妮      | 1990-01-20 | 女    |
+------+-----------+------------+-------+
2 rows in set (0.00 sec)
```

### 15. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩

```
SELECT
	st.s_id AS '学号',
	st.s_name AS '姓名',
	AVG( sc.s_score ) AS '平均成绩' 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
WHERE
	sc.s_id IN (
	SELECT
		sc.s_id 
	FROM
		score sc 
	WHERE
		sc.s_score < 60 
		OR sc.s_score IS NULL 
	GROUP BY
		sc.s_id 
	HAVING
		COUNT( 1 )>= 2 
	) 
GROUP BY
	st.s_id;

+--------+--------------+--------------+
| 学号   | 姓名         | 平均成绩     |
+--------+--------------+--------------+
| 04     | 德莱文       |      33.3333 |
| 06     | 光辉女郎     |      32.5000 |
+--------+--------------+--------------+
2 rows in set (0.01 sec)
```


### 16. 检索"01"课程分数小于60，按分数降序排列的学生信息
```
SELECT
	st.* 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id 
	AND sc.c_id = '01' 
	AND sc.s_score < '60' 
ORDER BY
	sc.s_score DESC;
	
	
SELECT
	st.* 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
WHERE
	sc.c_id = '01' 
	AND sc.s_score < '60' 
ORDER BY
	sc.s_score DESC;

+------+--------------+------------+-------+
| s_id | s_name       | s_birth    | s_sex |
+------+--------------+------------+-------+
| 04   | 德莱文       | 1990-08-06 | 男    |
| 06   | 光辉女郎     | 1992-03-01 | 女    |
+------+--------------+------------+-------+
2 rows in set (0.00 sec)
```

### 17. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩

- 方法 1
```
SELECT
	st.*,
	AVG( sc4.s_score ) AS '平均分',
	sc.s_score AS '语文',
	sc2.s_score AS '数学',
	sc3.s_score AS '英语' 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
	AND sc.c_id = '01'
	LEFT JOIN score sc2 ON sc2.s_id = st.s_id 
	AND sc2.c_id = '02'
	LEFT JOIN score sc3 ON sc3.s_id = st.s_id 
	AND sc3.c_id = '03'
	LEFT JOIN score sc4 ON sc4.s_id = st.s_id 
GROUP BY
	st.s_id 
ORDER BY
	AVG( sc4.s_score ) DESC;

+------+--------------+------------+-------+-----------+--------+--------+--------+
| s_id | s_name       | s_birth    | s_sex | 平均分    | 语文   | 数学   | 英语   |
+------+--------------+------------+-------+-----------+--------+--------+--------+
| 07   | 崔丝塔娜     | 1989-07-01 | 女    |   93.5000 |   NULL |     89 |     98 |
| 01   | 赵信         | 1990-01-01 | 男    |   89.6667 |     80 |     90 |     99 |
| 05   | 俄洛依       | 1991-12-01 | 女    |   81.5000 |     76 |     87 |   NULL |
| 03   | 艾希         | 1990-05-20 | 男    |   80.0000 |     80 |     80 |     80 |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |   70.0000 |     70 |     60 |     80 |
| 04   | 德莱文       | 1990-08-06 | 男    |   33.3333 |     50 |     30 |     20 |
| 06   | 光辉女郎     | 1992-03-01 | 女    |   32.5000 |     31 |   NULL |     34 |
| 08   | 安妮         | 1990-01-20 | 女    |      NULL |   NULL |   NULL |   NULL |
+------+--------------+------------+-------+-----------+--------+--------+--------+
8 rows in set (0.00 sec)
```


- 方法 2
```
SELECT
	st.*,
	( CASE WHEN AVG( sc4.s_score ) IS NULL THEN 0 ELSE AVG( sc4.s_score ) END ) AS '平均分',
	( CASE WHEN sc.s_score IS NULL THEN 0 ELSE sc.s_score END ) AS '语文',
	( CASE WHEN sc2.s_score IS NULL THEN 0 ELSE sc2.s_score END ) AS '数学',
	( CASE WHEN sc3.s_score IS NULL THEN 0 ELSE sc3.s_score END ) AS '英语' 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
	AND sc.c_id = '01'
	LEFT JOIN score sc2 ON sc2.s_id = st.s_id 
	AND sc2.c_id = '02'
	LEFT JOIN score sc3 ON sc3.s_id = st.s_id 
	AND sc3.c_id = '03'
	LEFT JOIN score sc4 ON sc4.s_id = st.s_id 
GROUP BY
	st.s_id 
ORDER BY
	AVG( sc4.s_score ) DESC;

+------+--------------+------------+-------+-----------+--------+--------+--------+
| s_id | s_name       | s_birth    | s_sex | 平均分    | 语文   | 数学   | 英语   |
+------+--------------+------------+-------+-----------+--------+--------+--------+
| 07   | 崔丝塔娜     | 1989-07-01 | 女    |   93.5000 |      0 |     89 |     98 |
| 01   | 赵信         | 1990-01-01 | 男    |   89.6667 |     80 |     90 |     99 |
| 05   | 俄洛依       | 1991-12-01 | 女    |   81.5000 |     76 |     87 |      0 |
| 03   | 艾希         | 1990-05-20 | 男    |   80.0000 |     80 |     80 |     80 |
| 02   | 德莱厄斯     | 1990-12-21 | 男    |   70.0000 |     70 |     60 |     80 |
| 04   | 德莱文       | 1990-08-06 | 男    |   33.3333 |     50 |     30 |     20 |
| 06   | 光辉女郎     | 1992-03-01 | 女    |   32.5000 |     31 |      0 |     34 |
| 08   | 安妮         | 1990-01-20 | 女    |         0 |      0 |      0 |      0 |
+------+--------------+------------+-------+-----------+--------+--------+--------+
8 rows in set (0.00 sec)
```

### 18. 查询各科成绩最高分、最低分和平均分：

- 以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
- 及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
```
SELECT
	cs.c_id,
	cs.c_name,
	MAX( sc1.s_score ) AS '最高分',
	MIN( sc2.s_score ) AS '最低分',
	AVG( sc3.s_score ) AS '平均分',
	((
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			s_score >= 60 
			AND c_id = cs.c_id 
			)/(
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			c_id = cs.c_id 
		)) AS '及格率',
	((
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			s_score >= 70 
			AND s_score < 80 
			AND c_id = cs.c_id 
			)/(
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			c_id = cs.c_id 
		)) AS '中等率',
	((
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			s_score >= 80 
			AND s_score < 90 
			AND c_id = cs.c_id 
			)/(
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			c_id = cs.c_id 
		)) AS '优良率',
	((
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			s_score >= 90 
			AND c_id = cs.c_id 
			)/(
		SELECT
			COUNT( s_id ) 
		FROM
			score 
		WHERE
			c_id = cs.c_id 
		)) AS '优秀率' 
FROM
	course cs
	LEFT JOIN score sc1 ON sc1.c_id = cs.c_id
	LEFT JOIN score sc2 ON sc2.c_id = cs.c_id
	LEFT JOIN score sc3 ON sc3.c_id = cs.c_id 
GROUP BY
	cs.c_id;

+------+--------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| c_id | c_name | 最高分    | 最低分    | 平均分    | 及格率    | 中等率    | 优良率    | 优秀率    |
+------+--------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| 01   | 语文   |        80 |        31 |   64.5000 |    0.6667 |    0.3333 |    0.3333 |    0.0000 |
| 02   | 数学   |        90 |        30 |   72.6667 |    0.8333 |    0.0000 |    0.5000 |    0.1667 |
| 03   | 英语   |        99 |        20 |   68.5000 |    0.6667 |    0.0000 |    0.3333 |    0.3333 |
+------+--------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
3 rows in set (0.00 sec)
```

### 19. 按各科成绩进行排序，并显示排名(实现不完全)

- mysql没有rank函数
- 加@score是为了防止用union all 后打乱了顺序
```
SELECT
	c1.s_id,
	c1.c_id,
	c1.c_name,
	@score := c1.s_score,
	@i := @i + 1 
FROM
	(
	SELECT
		c.c_name,
		sc.* 
	FROM
		course c
		LEFT JOIN score sc ON sc.c_id = c.c_id 
	WHERE
		c.c_id = "01" 
	ORDER BY
		sc.s_score DESC 
	) c1,
	( SELECT @i := 0 ) a UNION ALL
SELECT
	c2.s_id,
	c2.c_id,
	c2.c_name,
	c2.s_score,
	@ii := @ii + 1 
FROM
	(
	SELECT
		c.c_name,
		sc.* 
	FROM
		course c
		LEFT JOIN score sc ON sc.c_id = c.c_id 
	WHERE
		c.c_id = "02" 
	ORDER BY
		sc.s_score DESC 
	) c2,
	( SELECT @ii := 0 ) aa UNION ALL
SELECT
	c3.s_id,
	c3.c_id,
	c3.c_name,
	c3.s_score,
	@iii := @iii + 1 
FROM
	(
	SELECT
		c.c_name,
		sc.* 
	FROM
		course c
		LEFT JOIN score sc ON sc.c_id = c.c_id 
	WHERE
		c.c_id = "03" 
	ORDER BY
		sc.s_score DESC 
	) c3;

SET @iii = 0;

+------+------+--------+----------------------+--------------+
| s_id | c_id | c_name | @score := c1.s_score | @i := @i + 1 |
+------+------+--------+----------------------+--------------+
| 01   | 01   | 语文   |                   80 |            1 |
| 03   | 01   | 语文   |                   80 |            2 |
| 05   | 01   | 语文   |                   76 |            3 |
| 02   | 01   | 语文   |                   70 |            4 |
| 04   | 01   | 语文   |                   50 |            5 |
| 06   | 01   | 语文   |                   31 |            6 |
| 01   | 02   | 数学   |                   90 |            1 |
| 07   | 02   | 数学   |                   89 |            2 |
| 05   | 02   | 数学   |                   87 |            3 |
| 03   | 02   | 数学   |                   80 |            4 |
| 02   | 02   | 数学   |                   60 |            5 |
| 04   | 02   | 数学   |                   30 |            6 |
| 01   | 03   | 英语   |                   99 |            1 |
| 07   | 03   | 英语   |                   98 |            2 |
| 03   | 03   | 英语   |                   80 |            3 |
| 02   | 03   | 英语   |                   80 |            4 |
| 06   | 03   | 英语   |                   34 |            5 |
| 04   | 03   | 英语   |                   20 |            6 |
+------+------+--------+----------------------+--------------+
18 rows in set (0.01 sec)
```

### 20. 查询学生的总成绩并进行排名

```
SELECT
	st.s_id,
	st.s_name,
	( CASE WHEN sum( sc.s_score ) IS NULL THEN 0 ELSE SUM( sc.s_score ) END ) 
FROM
	student st
	LEFT JOIN score sc ON st.s_id = sc.s_id 
GROUP BY
	st.s_id 
ORDER BY
	SUM( sc.s_score ) DESC
```


### 21. 查询不同老师所教不同课程平均分从高到低显示

```
SELECT
	t.t_id,
	t.t_name,
	AVG( sc.s_score ) 
FROM
	teacher t
	LEFT JOIN course c ON c.t_id = t.t_id
	LEFT JOIN score sc ON sc.c_id = c.c_id 
GROUP BY
	t.t_id 
ORDER BY
	AVG( sc.s_score ) DESC

```

### 22. 查询所有课程的成绩第2名到第3名的学生信息及该课程成绩

```
SELECT
	a.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_id,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON sc.c_id = c.c_id 
		AND c.c_id = '01' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 1,
		2 
	) a UNION ALL
SELECT
	b.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_id,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '02' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 1,
		2 
	) b UNION ALL
SELECT
	c.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_id,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '03' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 1,
		2 
	) c;

```

### 23. 统计各科成绩各分数段人数：课程编号,课程名称,[100-85],[85-70],[70-60],[0-60]及所占百分比

```
SELECT
	c.c_id,
	c.c_name,
	(
	SELECT
		COUNT( 1 ) 
	FROM
		score sc 
	WHERE
		sc.c_id = c.c_id 
		AND sc.s_score <= 100 AND sc.s_score > 80 
		)/(
	SELECT
		COUNT( 1 ) 
	FROM
		score sc 
	WHERE
		sc.c_id = c.c_id 
	) AS '100-85',
	((
		SELECT
			COUNT( 1 ) 
		FROM
			score sc 
		WHERE
			sc.c_id = c.c_id 
			AND sc.s_score <= 85 AND sc.s_score > 70 
			)/(
		SELECT
			COUNT( 1 ) 
		FROM
			score sc 
		WHERE
			sc.c_id = c.c_id 
		)) AS '85-70',
	((
		SELECT
			COUNT( 1 ) 
		FROM
			score sc 
		WHERE
			sc.c_id = c.c_id 
			AND sc.s_score <= 70 AND sc.s_score > 60 
			)/(
		SELECT
			COUNT( 1 ) 
		FROM
			score sc 
		WHERE
			sc.c_id = c.c_id 
		)) AS '70-60',
	((
		SELECT
			COUNT( 1 ) 
		FROM
			score sc 
		WHERE
			sc.c_id = c.c_id 
			AND sc.s_score <= 60 AND sc.s_score >= 0 
			)/(
		SELECT
			COUNT( 1 ) 
		FROM
			score sc 
		WHERE
			sc.c_id = c.c_id 
		)) AS '85-70' 
FROM
	course c 
ORDER BY
	c.c_id 

```

### 24. 查询学生平均成绩及其名次

```
SET @i = 0;
SELECT
	a.*,
	@i := @i + 1 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		round( CASE WHEN AVG( sc.s_score ) IS NULL THEN 0 ELSE AVG( sc.s_score ) END, 2 ) AS agvScore 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id 
	GROUP BY
		st.s_id 
	ORDER BY
		agvScore DESC 
	) a

```

### 25. 查询各科成绩前三名的记录

```
SELECT
	a.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_id,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '01' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 0,
		3 
	) a UNION ALL
SELECT
	b.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_id,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '02' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 0,
		3 
	) b UNION ALL
SELECT
	c.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_id,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '03' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 0,
		3 
	) c

```

### 26. 查询每门课程被选修的学生数

```
SELECT
	c.c_id,
	c.c_name,
	COUNT( 1 ) 
FROM
	course c
	LEFT JOIN score sc ON sc.c_id = c.c_id
	INNER JOIN student st ON st.s_id = c.c_id 
GROUP BY
	c.c_id

```

### 27. 查询出只有两门课程的全部学生的学号和姓名

```
SELECT
	st.s_id,
	st.s_name 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id
	INNER JOIN course c ON c.c_id = sc.c_id 
GROUP BY
	st.s_id 
HAVING
	COUNT( 1 ) = 2

```

### 28. 查询男生、女生人数

```
SELECT s_sex, COUNT(1) FROM student GROUP BY s_sex
```


### 29. 查询名字中含有"德"字的学生信息

```
SELECT * FROM student WHERE s_name LIKE '%德%'
```


### 30. 查询同名同性学生名单，并统计同名人数

```
select st.s_name,st.s_sex,count(1) from student st group by st.s_name,st.s_sex having count(1)>1
```


### 31. 查询1990年出生的学生名单

```
SELECT st.* FROM student st WHERE st.s_birth LIKE '1990%';
```


### 32. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列

```
SELECT
	c.c_id,
	c_name,
	AVG( sc.s_score ) AS scoreAvg 
FROM
	course c
	INNER JOIN score sc ON sc.c_id = c.c_id 
GROUP BY
	c.c_id 
ORDER BY
	scoreAvg DESC,
	c.c_id ASC;

```

### 33. 查询平均成绩大于等于85的所有学生的学号、姓名和平均成绩

```
SELECT
	st.s_id,
	st.s_name,
	( CASE WHEN AVG( sc.s_score ) IS NULL THEN 0 ELSE AVG( sc.s_score ) END ) scoreAvg 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
GROUP BY
	st.s_id 
HAVING
	scoreAvg > '85';
```


### 34. 查询课程名称为"数学"，且分数低于60的学生姓名和分数

```
SELECT
	* 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id 
	AND sc.s_score < 60
	INNER JOIN course c ON c.c_id = sc.c_id 
	AND c.c_name = '数学';
```

### 35. 查询所有学生的课程及分数情况

```
SELECT
	* 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id
	LEFT JOIN course c ON c.c_id = sc.c_id 
ORDER BY
	st.s_id,
	c.c_name;

```

### 36. 查询任何一门课程成绩在70分以上的姓名、课程名称和分数

```
SELECT
	st.s_id,st.s_name,c.c_name,sc.s_score 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id
	LEFT JOIN course c ON c.c_id = sc.c_id 
WHERE
	st.s_id IN (
	SELECT
		st2.s_id 
	FROM
		student st2
		LEFT JOIN score sc2 ON sc2.s_id = st2.s_id 
	GROUP BY
		st2.s_id 
	HAVING
		MIN( sc2.s_score )>= 70 
	ORDER BY
	st2.s_id 
	)

```

### 37. 查询不及格的课程

```
SELECT
	st.s_id,
	c.c_name,
	st.s_name,
	sc.s_score 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id 
	AND sc.s_score < 60
	INNER JOIN course c ON c.c_id = sc.c_id

```

### 38. 查询课程编号为01且课程成绩在80分以上的学生的学号和姓名

```
SELECT
	st.s_id,
	st.s_name,
	sc.s_score 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id 
	AND sc.c_id = '01' 
	AND sc.s_score >= 80;

```

### 39. 求每门课程的学生人数

```
SELECT
	c.c_id,
	c.c_name,
	COUNT( 1 ) 
FROM
	course c
	INNER JOIN score sc ON sc.c_id = c.c_id 
GROUP BY
	c.c_id;

```

### 40. 查询选修"死亡歌颂者"老师所授课程的学生中，成绩最高的学生信息及其成绩

```
SELECT
	st.*,
	sc.s_score 
FROM
	student st
	INNER JOIN score sc ON sc.s_id = st.s_id
	INNER JOIN course c ON c.c_id = sc.c_id
	INNER JOIN teacher t ON t.t_id = c.t_id 
	AND t.t_name = '死亡歌颂者' 
ORDER BY
	sc.s_score DESC 
	LIMIT 0,1;

```

### 41. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩

```
SELECT
	st.s_id,
	st.s_name,
	sc.c_id,
	sc.s_score 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id
	LEFT JOIN course c ON c.c_id = sc.c_id 
WHERE
	(
	SELECT
		COUNT( 1 ) 
	FROM
		student st2
		LEFT JOIN score sc2 ON sc2.s_id = st2.s_id
		LEFT JOIN course c2 ON c2.c_id = sc2.c_id 
	WHERE
		sc.s_score = sc2.s_score 
	AND c.c_id != c2.c_id 
	)>1;

```

### 42. 查询每门功成绩最好的前两名

```
SELECT
	a.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '01' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 0,
		2 
	) a UNION ALL
SELECT
	b.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '02' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 0,
		2 
	) b UNION ALL
SELECT
	c.* 
FROM
	(
	SELECT
		st.s_id,
		st.s_name,
		c.c_name,
		sc.s_score 
	FROM
		student st
		LEFT JOIN score sc ON sc.s_id = st.s_id
		INNER JOIN course c ON c.c_id = sc.c_id 
		AND c.c_id = '03' 
	ORDER BY
		sc.s_score DESC 
		LIMIT 0,
	2 
	) c;

```

- 写法 2
```
SELECT
	a.s_id,
	a.c_id,
	a.s_score 
FROM
	score a 
WHERE
	( SELECT COUNT( 1 ) FROM score b WHERE b.c_id = a.c_id AND b.s_score > a.s_score ) <= 2 
ORDER BY
	a.c_id;

```


### 43. 统计每门课程的学生选修人数（超过5人的课程才统计）

- 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

```
SELECT
	c.c_id,
	COUNT( 1 ) 
FROM
	score sc
	LEFT JOIN course c ON c.c_id = sc.c_id 
GROUP BY
	c.c_id 
HAVING
	COUNT( 1 ) > 5 
ORDER BY
	COUNT( 1 ) DESC,
	c.c_id ASC;

```

### 44. 检索至少选修两门课程的学生学号

```
SELECT
	st.s_id 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
GROUP BY
	st.s_id 
HAVING
	COUNT( 1 )>= 2;

```

### 45. 查询选修了全部课程的学生信息

```
SELECT
	st.* 
FROM
	student st
	LEFT JOIN score sc ON sc.s_id = st.s_id 
GROUP BY
	st.s_id 
HAVING
	COUNT( 1 )=(
	SELECT
		COUNT( 1 ) 
FROM
	course)

```

### 46. 查询各学生的年龄

```
SELECT
	st.*,
	TIMESTAMPDIFF(
		YEAR,
		st.s_birth,
	NOW()) 
FROM
	student st

```

### 47. 查询本周过生日的学生

```
SELECT
	st.* 
FROM
	student st 
WHERE
	WEEK (
	NOW())+ 1 = WEEK (
	DATE_FORMAT( st.s_birth, '%Y%m%d' ))

```

### 48. 查询下周过生日的学生

```
SELECT
	st.* 
FROM
	student st 
WHERE
	WEEK (
		NOW())+ 1 = WEEK (
	DATE_FORMAT( st.s_birth, '%Y%m%d' ));

```

### 49. 查询本月过生日的学生

```
SELECT
	st.* 
FROM
	student st 
WHERE
	MONTH (
	NOW())= MONTH (
	DATE_FORMAT( st.s_birth, '%Y%m%d' ));

```

### 50. 查询下月过生日的学生

```
SELECT
	st.* 
FROM
	student st 
WHERE
	MONTH (
		TIMESTAMPADD(
			MONTH,
			1,
		NOW()))= MONTH (
	DATE_FORMAT( st.s_birth, '%Y%m%d' ));

```




