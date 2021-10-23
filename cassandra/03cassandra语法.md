
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

## 7、用户自定义类型

如果内置的数据类型无法满足需求，可以使用自定义数据类型。



# 启动cqlsh

1）进入cassandra安装目录下的 bin 目录，执行 cqlsh 命令
```
# ./bin/cqlsh 192.168.137.131 9042
```

2）help  帮助，输入命令，可以查看cqlsh 支持的命令
```
cqlsh> help
Documented shell commands:
===========================
CAPTURE  CLS          COPY  DESCRIBE  EXPAND  LOGIN   SERIAL  SOURCE   UNICODE
CLEAR    CONSISTENCY  DESC  EXIT      HELP    PAGING  SHOW    TRACING

CQL help topics:
================
AGGREGATES               CREATE_KEYSPACE           DROP_TRIGGER      TEXT     
ALTER_KEYSPACE           CREATE_MATERIALIZED_VIEW  DROP_TYPE         TIME     
ALTER_MATERIALIZED_VIEW  CREATE_ROLE               DROP_USER         TIMESTAMP
ALTER_TABLE              CREATE_TABLE              FUNCTIONS         TRUNCATE 
ALTER_TYPE               CREATE_TRIGGER            GRANT             TYPES    
ALTER_USER               CREATE_TYPE               INSERT            UPDATE   
APPLY                    CREATE_USER               INSERT_JSON       USE      
ASCII                    DATE                      INT               UUID     
BATCH                    DELETE                    JSON            
BEGIN                    DROP_AGGREGATE            KEYWORDS        
BLOB                     DROP_COLUMNFAMILY         LIST_PERMISSIONS
BOOLEAN                  DROP_FUNCTION             LIST_ROLES      
COUNTER                  DROP_INDEX                LIST_USERS      
CREATE_AGGREGATE         DROP_KEYSPACE             PERMISSIONS     
CREATE_COLUMNFAMILY      DROP_MATERIALIZED_VIEW    REVOKE          
CREATE_FUNCTION          DROP_ROLE                 SELECT          
CREATE_INDEX             DROP_TABLE                SELECT_JSON     
```

3）DESCRIBE，此命令配合 一些内容可以输入信息

> Describe cluster 提供有关集群的信息
```
cqlsh> Describe cluster；
```

> Describe Keyspaces   列出集群中的所有Keyspaces（键空间）
```
cqlsh> Describe Keyspaces；
```

> Describe tables  列出键空间的所有表
```
cqlsh> Describe tables;
```

> Describe tables  列出键空间内指定表的信息

4）先指定键空间 ，这里使用  system_traces
```
cqlsh> USE system_traces ；
```

5）列出system_traces 下的 sessions信息
```
cqlsh:system_traces> DESCRIBE sessions；
```

## Expand  扩展输出

> 使用命令后会扩展select输出的结果展示形式，对每个需要的操作先开启扩展，然后进行查询，最后关闭扩展

1、开启扩展输出
```
expand on;
```

2、查询数据
```
select * from table;
```

3、关闭扩展输入
```
expand OFF;
```

4、Capture 捕获命令输出到文件

此命令捕获命令的输出并将其添加到文件。

1）输入命令，将输出内容捕获到名为outputfile的文件
```
CAPTURE '/usr/local/apache-cassandra-3.11.6/outputfile'
```

2）执行一个查询，控制台可以看到输出。然后去看outputfile文件，会发现把刚才查询的

5、show 显示当前cqlsh会话的详细信息  
> show命令后可以跟3个内容 ，分别是 HOST 、SESSION 、VERSION
>
> 输入SHOW ，点击2次TAB 按键，可以看到3个内容提示
```
cqlsh:system_traces> SHOW
```

1）显示当前cqlsh 连接的Cassandra服务的ip和端口
```
cqlsh:system_traces> SHOW HOST
```

2）显示当前的版本
```
cqlsh:system_traces> SHOW VERSION
```

3）显示会话信息，需要参数uuid
```
cqlsh:system_traces> SHOW SESSION <uuid>
```

6、Exit  用于终止cql shell

## CQL-Cassandra查询语言

CQL：Cassandra Query Language  和关系型数据库的 SQL 很类似（一些关键词相似），可以使用CQL和 Cassandra 进行交互，实现 定义数据结构，插入数据，执行查询。

> 注意：CQL 和 SQL 是相互独立，没有任何关系的。CQL 缺少 SQL 的一些关键功能，比如 JOIN 等。

### 数据定义命令

| 指令            | 描述                      |
| --------------- | ------------------------- |
| CREATE KEYSPACE | 在Cassandra中创建KeySpace |
| USE             | 连接到已创建的KeySpace    |
| ALTER KEYSPACE  | 更改KeySpace的属性        |
| DROP KEYSPACE   | 删除KeySpace              |
| CREATE TABLE    | 在KeySpace中创建表        |
| ALTER TABLE     | 修改表的列属性            |
| DROP TABLE      | 删除表                    |
| TRUNCATE        | 从表中删除所有数据        |
| CREATE INDEX    | 在表的单个列上定义新索引  |
| DROP INDEX      | 删除命名索引              |

### 数据操作指令

| 指令   | 描述              |
| ------ | ----------------- |
| INSERT | 在表中添加行的列  |
| UPDATE | 更新行的列        |
| DELETE | 从表中删除数据    |
| BATCH  | 一次执行多个DML语 |

### 查询指令

| 指令    | 描述                                                |
| ------- | --------------------------------------------------- |
| SELECT  | 从表中读取数据                                      |
| WHERE   | where子句与select一起使用以读取特定数据             |
| ORDERBY | orderby子句与select一起使用，以特定顺序读取特定数据 |


## Cassandra的基本操作

### 1、操作键空间

#### 创建Keyspace

> 语法
```
CREATE KEYSPACE <identifier> WITH <properties>;
```

更具体的语法
```
Create keyspace KeyspaceName with replicaton={'class':strategy name,'replication_factor': No of replications on different nodes};
```
- KeyspaceName 代表键空间的名字
- strategy name 代表副本放置策略，内容包括：简单策略、网络拓扑策略，选择其中的一个。
- No of replications on different nodes 代表 复制因子，放置在不同节点上的数据的副本数。


1、创建一个键空间名字为：school，副本策略选择：简单策略 SimpleStrategy，副本因子：3
```
CREATE KEYSPACE school WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3} AND DURABLE_WRITES = false;
```
- SimpleStrategy 简单策略(机架感知策略)，仅适用于单datacenter单rack。根据partitioner存储第一份replica，然后在顺时针方向的下一个node上存放下一份replica（不考虑网络拓扑信息）。
- NetworkTopologyStrategy 网络拓扑策略(数据中心共享策略)，可以方便的扩展到多datacenter，推荐使用，同时，NetworkTopologyStrategy尽量避免将数据存储到相同的rack上。
- replication_factor 复制因子
- durable_writes 默认值durable_writes属性为true，但可以将其设置为false。不能将此属性设置为simplex策略。

2、查看创建的keyspace
```
cqlsh> SELECT * FROM system.schema_keyspaces;
  keyspace_name | durable_writes |                                       strategy_class | strategy_options
----------------+----------------+------------------------------------------------------+----------------------------
         school |          False |          org.apache.cassandra.locator.SimpleStrategy | {"datacenter1" : "3"}
 tutorialspoint |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor" : "4"}
         system |           True |           org.apache.cassandra.locator.LocalStrategy | { }
  system_traces |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor" : "2"}
(4 rows)
```

3、验证
```
DESCRIBE keyspaces ;
```

4、查看键空间的创建语句
```
DESCRIBE school;
```

5、连接Keyspace
```
use school;
```

CREATE TABLE 可以附加的部分属性
```
CREATE TABLE test_ttl(
id int PRIMARY KEY,
value text
) WITH bloom_filter_fp_chance = 0.01
AND caching = '{"keys":"ALL", "rows_per_partition":"NONE"}'
AND comment = ''
AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy'}
AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
AND dclocal_read_repair_chance = 0.1
AND default_time_to_live = 30
AND gc_grace_seconds = 864000
AND max_index_interval = 2048
AND memtable_flush_period_in_ms = 0
AND min_index_interval = 128
AND read_repair_chance = 0.0
AND speculative_retry = '99.0PERCENTILE';
```
- comment  对列族的描述信息。
- bloom_filter_fp_chance 指定bloom_filter算法的容错率，一般写0.01或者0.1。
- caching 设置缓存方案。
- compaction 数据压缩策略。
- compression 数据压缩算法。
- default_time_to_live 存活时间，默认0（永久存活）。
- memtable_flush_period_in_ms 内存数据刷新时间间隔。
- read_repair_chance 0-1之间的数值，与数据的一致性有关。



6、修改键空间 

> 1）编写完整的修改键空间语句，修改school键空间，把副本因子 从3 改为1
```
ALTER KEYSPACE school WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
```

> 2）验证，查看键空间的创建语句
```
DESCRIBE school;
```

> 3)查看创建的keyspace
```
SELECT * FROM system.schema_keyspaces;
  keyspace_name | durable_writes |                                       strategy_class | strategy_options
----------------+----------------+------------------------------------------------------+----------------------------
         school |           True |          org.apache.cassandra.locator.SimpleStrategy | {"datacenter1":"1"}
 tutorialspoint |           True | org.apache.cassandra.locator.NetworkTopologyStrategy | {"replication_factor":"3"}
         system |           True |           org.apache.cassandra.locator.LocalStrategy | { }
  system_traces |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor":"2"}
(4 rows)
```


7、删除键空间，完整删除键空间语句，删除school键空间
```
DROP KEYSPACE school
```

### 2、操作表、索引

1、操作前，先把键空间school键空间创建，并使用school 键空间
```
CREATE KEYSPACE school WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3};
use school;
```

2、查看键空间下所有表
```
DESCRIBE TABLES;
```

3、创建表

> 语法
```
CREATE (TABLE | COLUMNFAMILY) <tablename> ('<column-definition>' , '<column-definition>')
(WITH <option> AND <option>)
```

>完整创建表语句，创建student 表，student包含属性如下：
>
>学生编号（id）， 姓名（name），年龄（age），性别（gender），家庭地址（address），interest（兴趣），phone（电话号码），education（教育经历）
>
>id 为主键，并且为每个Column选择对应的数据类型。
>
>注意：interest 的数据类型是set  ，phone的数据类型是list，education 的数据类型是map

```
CREATE TABLE student(
   id int PRIMARY KEY,  
   name text,  
   age int,  
   gender tinyint,  
   address text ,
   interest set<text>,
   phone list<text>,
   education map<text, text>
);
```

> 验证，查看创建的表
```
cqlsh:school> DESCRIBE TABLE student;
```

4、cassandra的索引（KEY）

> 上面创建student的时候，把id 设置为primary key
>
> 在Cassandra中的primary key是比较宏观概念，用于从表中取出数据。primary key可以由1个或多个column组合而成。
>
> 不要在以下情况使用索引：
>
> - 这列的值很多的情况下，因为你相当于查询了一个很多条记录，得到一个很小的结果。
> - 表中有couter类型的列
> - 频繁更新和删除的列
> - 在一个很大的分区中去查询一条记录的时候（也就是不指定分区主键的查询）

5、Cassandra的5种Key

> 1. Primary Key     主键
> 2. Partition  Key  分区Key
> 3. Composite Key   复合key
> 4. Compound Key    复合Key
> 5. Clustering Key  集群

1）Primary Key

是用来获取某一行的数据， 可以是单一列（Single column Primary Key）或者多列（Composite Primary Key）。

在 Single column Primary Key 决定这一条记录放在哪个节点。
```
create table testTab (
id int PRIMARY KEY,
name text
);
```

2）Composite Primary Key

如果 Primary Key 由多列组成，那么这种情况称为 Compound Primary Key 或 Composite Primary Key。
```
create table testTab (
key_one int,
key_two int,
name text,
PRIMARY KEY(key_one, key_two)
);
```

3）Partition Key 

在组合主键的情况下(上面的例子)，第一部分称作Partition Key（key_one就是partition key），第二部分是CLUSTERING KEY（key_two）

 Cassandra会对Partition key 做一个hash计算，并自己决定将这一条记录放在哪个节点。

如果 Partition key 由多个字段组成，称之为 Composite Partition key
```
create table testTab (
key_part_one int,
key_part_two int,
key_clust_one int,
key_clust_two int,
key_clust_three uuid,
name text,
PRIMARY KEY((key_part_one,key_part_two), key_clust_one, key_clust_two, key_clust_three)
);
```

4）Clustering Key 

决定同一个分区内相同 Partition Key 数据的排序，默认为升序，可以在建表语句里面手动设置排序的方式

####  修改表结构

1、给student添加一个列email
```
ALTER TABLE student ADD email text;
```

2、删除一列
```
cqlsh:school> ALTER table student DROP email;
```

####  删除表

1、删除student
```
DROP TABLE student;
```

#### 清空表

1、表的所有行都将永久删除
```
TRUNCATE student；
```

### 创建索引

#### 1）普通列创建索引

1、为student的 name 添加索引，索引的名字为：sname
```
CREATE INDEX sname ON student (name);
```

2、为student 的age添加索引，不设置索引名字
```
CREATE INDEX ON student (age);
```
- 使用 DESCRIBE student 查看表，可以发现 对age创建索引，没有指定索引名字，会提供一个默认的索引名：student_age_idx。

索引原理：

Cassandra之中的索引的实现相对MySQL的索引来说就要简单粗暴很多了。Cassandra自动新创建了一张表格，同时将原始表格之中的索引字段作为新索引表的Primary Key！并且存储的值为原始数据的Primary Key 

#### 2）集合列创建索引

给集合列设置索引
```
CREATE INDEX ON student(interest);                   -- set集合添加索引
CREATE INDEX mymap ON student(KEYS(education));      -- map结合添加索引
```

#### 3）删除索引

> 删除student的sname 索引
```
drop index sname;
```

## 3、查询数据

##### 1）查询所有数据

当前student表有2行数据，全部查询出来
```
cqlsh:school> select * from student;
```

##### 2）根据主键查询

查询student_id = 1012 的行
```
cqlsh:school> select * from student where id=1012;
```

#### 2 查询时使用索引

> Cassandra对查询时使用索引有一定的要求，具体如下：
>
> - **Primary Key 只能用 = 号查询**
>
> - **第二主键 支持= > < >= <=**
>
> - **索引列 只支持 = 号**
>
> - 非索引非主键字段过滤**可以使用ALLOW FILTERING**

当前有一张表testTab，表中包含一些数据
```
create table testTab (
key_one int,
key_two int,
name text,
age  int,
PRIMARY KEY(key_one, key_two)
);
create INDEX tage ON testTab (age);
```

可以看到key_one 是第一主键，key_two是第二主键，age是索引列，name是普通列


##### 1）第一主键 只能用=号查询

> key_one列是第一主键
>
> 对key_one进行 = 号查询，可以查出结果

```
select * from testtab where key_one=4;
```


> 对key_one 进行范围查询使用 > 号，无法查出结果

```
select * from testtab where key_one>4;
InvalidRequest: Error from server: code=2200 [Invalid query] message="Only EQ and IN relation are supported on the partition key (unless you use the token() function)"
```

##### 2) 第二主键 支持 =  、>、  <、    >= 、  <=

key_two是第二主键

> 不要单独对key_two 进行查询，输出错误信息
```
select * from testtab where key_two = 8;
InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot execute this query as it might involve data filtering and thus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING"
```

意思是如果想要完成这个查询，可以使用 ALLOW FILTERING
```
select * from testtab where key_two = 8 ALLOW FILTERING;
```

**注意：加上ALLOW FILTERING 后确实可以查询出数据，但是不建议这么做**

>正确的做法是 ，在查询第二主键时，前面先写上第一主键
```
select * from testtab where key_one=12 and key_two = 8 ;
select * from testtab where key_one=12 and key_two > 7;
```

##### 3) 索引列 只支持=号

age是索引列
```
select * from testtab where age = 19;                     # 正确
select * from testtab where age > 20 ;                    # 会报错
select * from testtab where age >20 allow filtering;      # 可以查询出结果，但是不建议这么做
```

##### 4）普通列，非索引非主键字段

name是普通列，在查询时需要使用ALLOW FILTERING。
```
select * from testtab where key_one=12 and name='张小仙';                       # 报错
select * from testtab where key_one=12 and name='张小仙' allow filtering;       # 可以查询
```

##### 5）集合列

使用student表来测试集合列上的索引使用。

假设已经给集合添加了索引，就可以使用where子句的CONTAINS条件按照给定的值进行过滤。
```
select * from student where interest CONTAINS '电影';                             # 查询set集合
select * from student where education CONTAINS key  '小学';                       # 查询map集合的key值
select * from student where education CONTAINS '中心第9小学' allow filtering;     # 查询map的value值
```

##### 6） ALLOW FILTERING

ALLOW FILTERING是一种非常消耗计算机资源的查询方式。
- 如果表包含例如100万行，并且其中95％具有满足查询条件的值，则查询仍然相对有效，这时应该使用ALLOW FILTERING。
- 如果表包含100万行，并且只有2行包含满足查询条件值，则查询效率极低。Cassandra将无需加载999,998行。如果经常使用查询，则最好在列上添加索引。
- ALLOW FILTERING在表数据量小的时候没有什么问题，但是数据量过大就会使查询变得缓慢。

#### 3 查询时排序

cassandra也是支持排序的，order by。 排序也是有条件的

##### 1）必须有第一主键的=号查询

cassandra的第一主键是决定记录分布在哪台机器上，cassandra只支持单台机器上的记录排序。

##### 2）只能根据第二、三、四…主键进行有序的，相同的排序。

##### 3）不能有索引查询

cassandra的任何查询，最后的结果都是有序的，内部就是这样存储的。

现在使用 testTab表，来测试排序
```
select * from testtab where key_one = 12 order by key_two;                  # 正确
select * from testtab where key_one = 12 and age =19 order key_two;         # 错误，不能有索引查询
```
- 索引列 支持 like 
- 主键支持 group by 

#### 4 分页查询

- 使用limit 关键字来限制查询结果的条数 进行分页

### 添加数据


1、给student添加2行数据，包含对set，list ，map类型数据
```
INSERT INTO student (id,address,age,gender,name,interest, phone,education) VALUES (1011,'中山路21号',16,1,'Tom',{'游泳', '跑步'},['010-88888888','13888888888'],{'小学' : '城市第一小学', '中学' : '城市第一中学'}) ;

INSERT INTO student (id,address,age,gender,name,interest, phone,education) VALUES (1012,'朝阳路19号',17,2,'Jerry',{'看书', '电影'},['020-66666666','13666666666'],{'小学' :'城市第五小学','中学':'城市第五中学'});
```


2、添加TTL，设定的computed_ttl数值秒后，数据会自动删除
```
INSERT INTO student (id,address,age,gender,name,interest, phone,education) VALUES (1030,'朝阳路30号',20,1,'Cary',{'运动', '游戏'},['020-7777888','139876667556'],{'小学' :'第30小学','中学':'第30中学'}) USING TTL 60;
```


###  更新列数据

更新表中的数据，可用关键字
- **Where** - 选择要更新的行
- **Set** - 设置要更新的值
- **Must** - 包括组成主键的所有列

在更新行时，如果给定行不可用，则UPDATE创建一个新行

#### 1 更新简单数据

把student_id = 1012 的数据的gender列 的值改为1
```
UPDATE student set gender = 1 where student_id= 1012;
```

#### 2 更新set类型数据

> 在student中interest列是set类型

##### 1）添加一个元素

> 使用UPDATE命令 和 ‘+’ 操作符
```
UPDATE student SET interest = interest + {'游戏'} WHERE student_id = 1012;
```

##### 2）删除一个元素

> 使用UPDATE命令 和 ‘-’ 操作符
```
UPDATE student SET interest = interest - {'电影'} WHERE student_id = 1012;
```

##### 3）删除所有元素

> 可以使用UPDATA或DELETE命令，效果一样
```
UPDATE student SET interest = {} WHERE student_id = 1012;
或
DELETE interest FROM student WHERE student_id = 1012;
```


一般来说，Set,list和Map要求最少有一个元素，否则Cassandra无法把其同一个空值区分

#### 3 更新list类型数据

> 在student中phone列是list类型

##### 1）使用UPDATA命令向list插入值

```
UPDATE student SET phone = ['020-66666666', '13666666666'] WHERE student_id = 1012;
```

##### 2）在list前面插入值
```
UPDATE student SET phone = [ '030-55555555' ] + phone WHERE student_id = 1012;
```

可以看到新数据的位置在旧数据的前面

##### 3）在list后面插入值
```
UPDATE student SET phone = phone + [ '040-33333333' ]  WHERE student_id = 1012;
```

可以看到新数据的位置在最后面

##### 4）使用列表索引设置值，覆盖已经存在的值

> 这种操作会读入整个list，效率比上面2种方式差

现在把phone中下标为2的数据，也就是 “13666666666”替换
```
UPDATE student SET phone[2] = '050-22222222' WHERE student_id = 1012;
```

##### 5）【不推荐】使用DELETE命令和索引删除某个特定位置的值

> 非线程安全的，如果在操作时其它线程在前面添加了一个元素，会导致移除错误的元素
```
DELETE phone[2] FROM student WHERE student_id = 1012;
```

##### 6）【推荐】使用UPDATE命令和‘-’移除list中所有的特定值
```
UPDATE student SET phone = phone - ['020-66666666'] WHERE student_id = 1012;
```

#### 4 更新map类型数据

map输出顺序取决于map类型。

##### 1）使用Insert或Update命令
```
UPDATE student SET education=
  {'中学': '城市第五中学', '小学': '城市第五小学'} WHERE student_id = 1012;
```

##### 2）使用UPDATE命令设置指定元素的value
```
UPDATE student SET education['中学'] = '爱民中学' WHERE student_id = 1012;
```


##### 3）可以使用如下语法增加map元素。如果key已存在，value会被覆盖，不存在则插入
```
UPDATE student SET education = education + { '幼儿园' : '大海幼儿园', '中学': '科技路中学'} WHERE student_id = 1012;
```

覆盖“中学”为“科技路中学”，添加“幼儿园”数据

##### 4）删除元素

可以用DELETE 和 UPDATE  删除Map类型中的数据

1、使用DELETE删除数据
```
DELETE education['幼儿园'] FROM student WHERE student_id = 1012;
```

2、使用UPDATE删除数据
```
UPDATE student SET education=education - {'中学','小学'} WHERE student_id = 1012;
```


### 6 删除行

1、删除student中student_id=1012 的数据
```
DELETE FROM student WHERE student_id=1012;
```

###  批量操作

> 作用

把多次更新操作合并为一次请求，减少客户端和服务端的网络交互。 batch中同一个partition key的操作具有隔离性

> 语法

使用**BATCH**，您可以同时执行多个修改语句（插入，更新，删除）
```
BEGIN BATCH
<insert-stmt>/ <update-stmt>/ <delete-stmt>
APPLY BATCH
```

1、先把数据清空，然后使用添加数据的代码，在student中添加2条记录，student_id 为1011 、 1012

2、在批量操作中实现 3个操作：
- 新增一行数据，student_id =1015 
- 更新student_id =1012的数据，把年龄改为11，
- 删除已经存在的student_id=1011的数据
```
BEGIN BATCH
	INSERT INTO student (id,address,age,gender,name) VALUES (1015,'上海路',20,1,'Jack') ;
	UPDATE student set age = 11 where id= 1012;
	DELETE FROM student WHERE id=1011;
APPLY BATCH;
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
