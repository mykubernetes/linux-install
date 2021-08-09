
https://blog.csdn.net/itcast_cn/article/details/107559490

# 数据类型

> CQL提供了一组丰富的内置数据类型，用户还可以创建自己的自定义数据类型。
>
> CQL是Cassandra提供的一套查询语言

## 1、数值类型

| 数据类型 | 含义                 | 描述                                   |
| -------- | -------------------- | -------------------------------------- |
| int      | 32位有符号整型       | 和 Java 中的 int 类似                  |
| bigint   | 64位长整型           | 和 Java 中的 long 类似                 |
| smallint | 16位有符号整型       | 和 Java 中的 short 类似                |
| tinyint  | 8位有符号整型        | 和 Java 中的 tinyint 类似              |
| varint   | 可变精度有符号整数   | 和 Java 中的 java.math.BigInteger 类似 |
| float    | 32位 IEEE-754 浮点型 | 和 Java 中的 float 类似                |
| double   | 64位 IEEE-754 浮点型 | 和 Java 中的 double 类似               |
| decimal  | 可变精度的 decimal   | 和 Java 中的 java.math.BigDecimal 类似 |

## 2、文本类型

> CQL提供2种类型存放文本类型，text和varchar基本一致

| 数据类型 | 含义 | 描述                 |
| -------- | ---- | -------------------- |
| ascii    | 文本 | 表示ASCII字符串      |
| text     | 文本 | 表示UTF8编码的字符串 |
| varchar  | 文本 | 表示uTF8编码的字符串 |

## 3、时间类型

| 数据类型  | 含义 | 描述                                       |
| --------- | ---- | ------------------------------------------ |
| timestamp | 时间 | 包含了日期和时间，使用64位有符号的整数表示 |
| date      | 日期 |                                            |
| time      | 时间 |                                            |

## 4、标识符类型

| 类型     | 含义          | 描述                                                         |
| -------- | ------------- | ------------------------------------------------------------ |
| uuid     | 128位数据类型 | 通用唯一识别码<br>CQL 中的 uuid 实现是 Type 4 UUID，其实现完全是基于随机数的 |
| timeuuid |               | Type 1 UUID                                                  |

## 5、集合类型

### 1）set

集合数据类型，set 里面的元素存储是无序的。

set 里面可以存储前面介绍的数据类型，也可以是用户自定义数据类型，甚至是其他集合类型。

### 2）list

list 包含了有序的列表数据，默认情况下，数据是按照插入顺序保存的。

### 3）map

map 数据类型包含了 key/value 键值对。key 和 value 可以是任何类型，除了 counter 类型

> 使用集合类型要注意：
> 1、集合的每一项最大是64K。
> 2、保持集合内的数据不要太大，免得Cassandra 查询延时过长，Cassandra 查询时会读出整个集合内的数据，集合在内部不会进行分页，集合的目的是存储小量数据。
> 3、不要向集合插入大于64K的数据，否则只有查询到前64K数据，其它部分会丢失。

## 6、其他基本类型

| 类型    | 含义                  | 描述                                                         |
| ------- | --------------------- | ------------------------------------------------------------ |
| boolean | 布尔类型              | 值只能为 true/false                                          |
| blob    | 二进制大对象          | 存储媒体或者其他二进制数据类型时很有用                       |
| inet    | IPv4 或 IPv6 网络地址 | cqlsh 接受用于定义 IPv4 地址的任何合法格式，包括包含十进制，八进制或十六进制值的点或非点式表示<br>CQL 会输出为 0.0.0.0 这种 地址形式。 |
| counter | 计数器类型            | 值不能直接设置，而只能递增或递减<br>不能用作主键的一部分；如果使用计数器，则除primary key 列之外的所有列都必须是计数器 |


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

