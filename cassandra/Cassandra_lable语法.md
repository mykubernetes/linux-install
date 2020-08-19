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
