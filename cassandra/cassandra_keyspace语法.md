Cassandra 
===
一、创建keyspace
---
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
- SimpleStrategy 简单策略(机架感知策略)
- 旧网络拓扑策略(机架感知策略)
- NetworkTopologyStrategy 网络拓扑策略(数据中心共享策略)


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

使用Keyspace
```
cqlsh> USE tutorialspoint;
cqlsh:tutorialspoint>
```

二、修改修改Keyspace
---
语句: ALTER KEYSPACE <identifier> WITH <properties>

```
ALTER KEYSPACE “KeySpace Name”
WITH replication = {'class': ‘Strategy name’, 'replication_factor' : ‘No.Of  replicas’};
```

示例
```
cqlsh.> ALTER KEYSPACE tutorialspoint
WITH replication = {'class':'NetworkTopologyStrategy', 'replication_factor' : 3};
```

```
ALTER KEYSPACE test
WITH REPLICATION = {'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3}
AND DURABLE_WRITES = true;
```

验证
```
SELECT * FROM system.schema_keyspaces;
  keyspace_name | durable_writes |                                       strategy_class | strategy_options
----------------+----------------+------------------------------------------------------+----------------------------
           test |           True | org.apache.cassandra.locator.NetworkTopologyStrategy | {"datacenter1":"3"}

 tutorialspoint |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor":"4"}

         system |           True |           org.apache.cassandra.locator.LocalStrategy | { }

  system_traces |           True |          org.apache.cassandra.locator.SimpleStrategy | {"replication_factor":"2"}

(4 rows)
```

三、删除keyspace
---
语句:DROP KEYSPACE <identifier>

```
DROP KEYSPACE “KeySpace name”
```

示例
```
cqlsh> DROP KEYSPACE tutorialspoint;
```

验证
```
cqlsh> DESCRIBE keyspaces;

system system_traces
```


