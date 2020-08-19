一、Cassandra 创建键空间

语法: CREATE KEYSPACE <identifier> WITH <properties>
```
CREATE KEYSPACE "KeySpace Name"
WITH replication = {'class': 'Strategy name', 'replication_factor' : 'No.Of   replicas'};

CREATE KEYSPACE "KeySpace Name"
WITH replication = {'class': 'Strategy name', 'replication_factor' : 'No.Of  replicas'}
AND durable_writes = 'Boolean value';
```
- replication 副本数
- durable_writes 默认情况下，表的durable_writes属性设置为true，但可以将其设置为false。您不能将此属性设置为simplex策略。

示例
```
#简单副本策略
cqlsh.> CREATE KEYSPACE tutorialspoint
WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3};

#持久化写入
cqlsh> CREATE KEYSPACE test
... WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3 }
... AND DURABLE_WRITES = false;
```

验证
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
