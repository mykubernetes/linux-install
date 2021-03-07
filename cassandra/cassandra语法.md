keyspace操作
---
1、创建keyspace
```
#简单副本策略
cqlsh.> CREATE KEYSPACE tutorialspoint
WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3};

#持久化写入
cqlsh> CREATE KEYSPACE test
... WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3 }
... AND DURABLE_WRITES = false;
```
- SimpleStrategy 简单策略(机架感知策略)
- NetworkTopologyStrategy 网络拓扑策略(数据中心共享策略)
- replication_factor 复制因子
- durable_writes 默认情况下，表的durable_writes属性设置为true，但可以将其设置为false。您不能将此属性设置为simplex策略。

2、查看创建的keyspace
```
cqlsh> SELECT * FROM system.schema_keyspaces;
  keyspace_name | durable_writes |                                       strategy_class | strategy_options
----------------+----------------+------------------------------------------------------+----------------------------
           test |          False | org.apache.cassandra.locator.NetworkTopologyStrategy | {"datacenter1" : "3"}
 tutorialspoint |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor" : "4"}
         system |           True |           org.apache.cassandra.locator.LocalStrategy | { }
  system_traces |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor" : "2"}
(4 rows)
```

3、使用Keyspace
```
cqlsh> USE tutorialspoint;
cqlsh:tutorialspoint>
```

4、修改修改Keyspace
```
cqlsh.> ALTER KEYSPACE tutorialspoint WITH replication = {'class':'NetworkTopologyStrategy', 'replication_factor' : 3};
cqlsh.> ALTER KEYSPACE test WITH REPLICATION = {'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3} AND DURABLE_WRITES = true;
```

验证
```
SELECT * FROM system.schema_keyspaces;
  keyspace_name | durable_writes |                                       strategy_class | strategy_options
----------------+----------------+------------------------------------------------------+----------------------------
           test |           True | org.apache.cassandra.locator.NetworkTopologyStrategy | {"datacenter1":"3"}
 tutorialspoint |           True | org.apache.cassandra.locator.NetworkTopologyStrategy | {"replication_factor":"3"}
         system |           True |           org.apache.cassandra.locator.LocalStrategy | { }
  system_traces |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor":"2"}
(4 rows)
```

5、删除keyspace
```
cqlsh> DROP KEYSPACE tutorialspoint;
```

验证
```
cqlsh> DESCRIBE keyspaces;
system system_traces
```

表操作
---
1、Cqlsh创建表
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

2、修改表
```
1、添加列
cqlsh:tutorialspoint> ALTER TABLE emp ADD emp_email text;

2、删除列
cqlsh:tutorialspoint> ALTER TABLE emp DROP emp_email;
```

3、删除表
```
cqlsh:tutorialspoint> DROP TABLE emp;
```
验证
```
cqlsh:tutorialspoint> DESCRIBE COLUMNFAMILIES;
employee
```

4、截断表，使用TRUNCATE命令截断表。截断表时，表的所有行都将永久删除。
```
cqlsh:tp> TRUNCATE student;
```

5、创建索引，为emp的表中为列emp_name创建索引。
```
cqlsh:tutorialspoint> CREATE INDEX name ON emp1 (emp_name);
```

6、删除索引，删除表emp中的列名的索引。
```
cqlsh:tp> drop index name;
```

7、批处理语句
```
cqlsh:tutorialspoint> BEGIN BATCH
... INSERT INTO emp (emp_id, emp_city, emp_name, emp_phone, emp_sal) values(  4,'Pune','rajeev',9848022331, 30000);
... UPDATE emp SET emp_sal = 50000 WHERE emp_id =3;
... DELETE emp_city FROM emp WHERE emp_id = 2;
... APPLY BATCH;
```

数据增删改查操作
---
1、创建数据
```
cqlsh:tutorialspoint> INSERT INTO emp (emp_id, emp_name, emp_city,emp_phone, emp_sal) VALUES(1,'ram', 'Hyderabad', 9848022338, 50000);
cqlsh:tutorialspoint> INSERT INTO emp (emp_id, emp_name, emp_city,emp_phone, emp_sal) VALUES(2,'robin', 'Hyderabad', 9848022339, 40000);
cqlsh:tutorialspoint> INSERT INTO emp (emp_id, emp_name, emp_city,emp_phone, emp_sal) VALUES(3,'rahman', 'Chennai', 9848022330, 45000);
```

2、更新数据
```
cqlsh:tutorialspoint> UPDATE emp SET emp_city='Delhi',emp_sal=50000 WHERE emp_id=2;
```


3、读取数据
```
cqlsh:tutorialspoint> select * from emp;
cqlsh:tutorialspoint> SELECT emp_name,emp_sal from emp;
cqlsh:tutorialspoint> SELECT * FROM emp WHERE emp_sal=50000;
```

4、删除数据
```
cqlsh:tutorialspoint> DELETE emp_sal FROM emp WHERE emp_id=3;
```

5、删除整行
```
cqlsh:tutorialspoint> DELETE FROM emp WHERE emp_id=3;
```

