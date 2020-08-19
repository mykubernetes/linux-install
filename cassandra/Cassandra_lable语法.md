一、Cqlsh创建表
---
语句
```
CREATE (TABLE | COLUMNFAMILY) <tablename>
('<column-definition>' , '<column-definition>')
(WITH <option> AND <option>)
```

示例
```
cqlsh> USE tutorialspoint;
cqlsh:tutorialspoint>; CREATE TABLE emp(
   emp_id int PRIMARY KEY,
   emp_name text,
   emp_city text,
   emp_sal varint,
   emp_phone varint
   );
```

验证
```
cqlsh:tutorialspoint> select * from emp;

 emp_id | emp_city | emp_name | emp_phone | emp_sal
--------+----------+----------+-----------+---------

(0 rows)
```

二、修改表
---
句法
```
ALTER (TABLE | COLUMNFAMILY) <tablename> <instruction>
```
- 添加列
- 删除列

添加列
```
cqlsh:tutorialspoint> ALTER TABLE emp
   ... ADD emp_email text;
```

示例
```
cqlsh:tutorialspoint> select * from emp;

 emp_id | emp_city | emp_email | emp_name | emp_phone | emp_sal
--------+----------+-----------+----------+-----------+---------
```

删除列
```
cqlsh:tutorialspoint> ALTER TABLE emp DROP emp_email;
```

示例
```
cqlsh:tutorialspoint> select * from emp;

 emp_id | emp_city | emp_name | emp_phone | emp_sal
--------+----------+----------+-----------+---------
(0 rows)
```

三、删除表
---

语法: DROP TABLE <tablename>

示例
```
cqlsh:tutorialspoint> DROP TABLE emp;
```

验证
```
cqlsh:tutorialspoint> DESCRIBE COLUMNFAMILIES;

employee
```


四、截断表
---
使用TRUNCATE命令截断表。截断表时，表的所有行都将永久删除。

语法
```
TRUNCATE <tablename>
```

示例
```
cqlsh:tp> select * from student;

 s_id | s_aggregate | s_branch | s_name
------+-------------+----------+--------
    1 |          70 |       IT | ram
    2 |          75 |      EEE | rahman
    3 |          72 |     MECH | robbin

(3 rows)
```
现在使用TRUNCATE命令截断表。
```
cqlsh:tp> TRUNCATE student;
```
验证

通过执行select语句验证表是否被截断。下面给出截断后学生表上的select语句的输出。
```
cqlsh:tp> select * from student;

 s_id | s_aggregate | s_branch | s_name
------+-------------+----------+--------

(0 rows)
```


五、创建索引
---
语法
```
CREATE INDEX <identifier> ON <tablename>
```

为emp的表中为列“emp_name”创建索引。
```
cqlsh:tutorialspoint> CREATE INDEX name ON emp1 (emp_name);
```

六删除索引
---

语法
```
DROP INDEX <identifier>
```

删除表emp中的列名的索引。
```
cqlsh:tp> drop index name;
```


七、批处理语句
---

使用BATCH，可以同时执行多个修改语句（插入，更新，删除）。语法
```
BEGIN BATCH
<insert-stmt>/ <update-stmt>/ <delete-stmt>
APPLY BATCH
```

示例
```
cqlsh:tutorialspoint> BEGIN BATCH
... INSERT INTO emp (emp_id, emp_city, emp_name, emp_phone, emp_sal) values(  4,'Pune','rajeev',9848022331, 30000);
... UPDATE emp SET emp_sal = 50000 WHERE emp_id =3;
... DELETE emp_city FROM emp WHERE emp_id = 2;
... APPLY BATCH;
```

验证
```
cqlsh:tutorialspoint> select * from emp;

 emp_id |  emp_city | emp_name |  emp_phone | emp_sal
--------+-----------+----------+------------+---------
      1 | Hyderabad | ram      | 9848022338 | 50000
      2 | null      | robin    | 9848022339 | 50000
      3 | Chennai   | rahman   | 9848022330 | 50000
      4 | Pune      | rajeev   | 9848022331 | 30000
    
(4 rows)
```
