一、创建数据
---
语法
```
INSERT INTO <tablename>
(<column1 name>, <column2 name>....)
VALUES (<value1>, <value2>....)
USING <option>
```

示例
```
cqlsh:tutorialspoint> INSERT INTO emp (emp_id, emp_name, emp_city,emp_phone, emp_sal) VALUES(1,'ram', 'Hyderabad', 9848022338, 50000);

cqlsh:tutorialspoint> INSERT INTO emp (emp_id, emp_name, emp_city,emp_phone, emp_sal) VALUES(2,'robin', 'Hyderabad', 9848022339, 40000);

cqlsh:tutorialspoint> INSERT INTO emp (emp_id, emp_name, emp_city,emp_phone, emp_sal) VALUES(3,'rahman', 'Chennai', 9848022330, 45000);
```

验证
```
cqlsh:tutorialspoint> SELECT * FROM emp;

 emp_id |  emp_city | emp_name |  emp_phone | emp_sal
--------+-----------+----------+------------+---------
      1 | Hyderabad |      ram | 9848022338 | 50000
      2 | Hyderabad |    robin | 9848022339 | 40000
      3 |   Chennai |   rahman | 9848022330 | 45000
 
(3 rows)
```

二、更新数据
---
UPDATE是用于更新表中的数据的命令。在更新表中的数据时使用以下关键字：
- Where 此子句用于选择要更新的行。
- Set 使用此关键字设置值。
- Must 包括组成主键的所有列。

语法
```
UPDATE <tablename>
SET <column name> = <new value>
<column name> = <value>....
WHERE <condition>
```

示例
```
cqlsh:tutorialspoint> UPDATE emp SET emp_city='Delhi',emp_sal=50000 WHERE emp_id=2;
```

验证
```
cqlsh:tutorialspoint> select * from emp;

 emp_id |  emp_city | emp_name |  emp_phone | emp_sal
--------+-----------+----------+------------+---------
      1 | Hyderabad |      ram | 9848022338 | 50000
      2 |     Delhi |    robin | 9848022339 | 50000
      3 |   Chennai |   rahman | 9848022330 | 45000
      
(3 rows)
```


三、读取数据
---
语法
```
SELECT FROM <tablename>
```

示例
```
cqlsh:tutorialspoint> select * from emp;

 emp_id |  emp_city | emp_name |  emp_phone | emp_sal
--------+-----------+----------+------------+---------
      1 | Hyderabad |   ram    | 9848022338 | 50000
      2 | null      |   robin  | 9848022339 | 50000
      3 | Chennai   |   rahman | 9848022330 | 50000
      4 | Pune      |   rajeev | 9848022331 | 30000
		
(4 rows)
```


以下示例显示如何读取表中的特定列。
```
cqlsh:tutorialspoint> SELECT emp_name,emp_sal from emp;

 emp_name | emp_sal
----------+---------
      ram | 50000
    robin | 50000
   rajeev | 30000
   rahman | 50000 
	
(4 rows)
```

Where子句

使用WHERE子句，可以对必需的列设置约束。其语法如下：
```
SELECT FROM <table name> WHERE <condition>;
```
注意：WHERE子句只能用于作为主键的一部分或在其上具有辅助索引的列。

在以下示例中，我们正在读取薪水为50000的员工的详细信息。首先，将辅助索引设置为列emp_sal。
```
cqlsh:tutorialspoint> CREATE INDEX ON emp(emp_sal);
cqlsh:tutorialspoint> SELECT * FROM emp WHERE emp_sal=50000;

 emp_id |  emp_city | emp_name |  emp_phone | emp_sal
--------+-----------+----------+------------+---------
      1 | Hyderabad |      ram | 9848022338 | 50000
      2 |      null |    robin | 9848022339 | 50000
      3 |   Chennai |   rahman | 9848022330 | 50000
```

四、删除数据
---
语法如下：
```
DELETE FROM <identifier> WHERE <condition>;
```
示例

删除emp_sal列：
```
cqlsh:tutorialspoint> DELETE emp_sal FROM emp WHERE emp_id=3;
```

验证
```
cqlsh:tutorialspoint> select * from emp;

 emp_id |  emp_city | emp_name |  emp_phone | emp_sal
--------+-----------+----------+------------+---------
      1 | Hyderabad |      ram | 9848022338 | 50000
      2 |     Delhi |    robin | 9848022339 | 50000
      3 |   Chennai |   rahman | 9848022330 | null
(3 rows)
```
由于我们删除了Rahman的薪资，你将看到一个空值代替薪资。

五、删除整行
---
以下命令从表中删除整个行。
```
cqlsh:tutorialspoint> DELETE FROM emp WHERE emp_id=3;
```

验证
```
cqlsh:tutorialspoint> select * from emp;

 emp_id |  emp_city | emp_name |  emp_phone | emp_sal
--------+-----------+----------+------------+---------
      1 | Hyderabad |      ram | 9848022338 | 50000
      2 |     Delhi |    robin | 9848022339 | 50000
 
(2 rows)
```
