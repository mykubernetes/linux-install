权限分级的角色划分

划分三种角色类型：xxopr、xxdata、cassandra，权限依次增大。
- xxopr: 应用账号,只能进行对表的查询、数据插入、数据删除等DML操作
- xxdata: 相当于数据OWNER用户，对表空间内的对象拥有增删改查等DDL操作
- cassandra: 超级用户，用于创建表空间的，DBA权限管理


创建用户
---
1、使用超级用户登录
```
cqlsh xx.xx.xx.xx  -u cassandra -p cassandra
```

2、修改超级用户cassandra密码
```
alter user cassandra with password '密码'
```

3、创建用户，（使用超级账号cassandra）
```
create user xxopr WITH PASSWORD '密码'  NOSUPERUSER;
create user xxdata WITH PASSWORD '密码'  NOSUPERUSER;
```

4、修改授权表空间复制因子为3，（使用超级账号cassandra）
```
a.登录数据库执行
ALTER KEYSPACE system_auth WITH replication = {'class':'NetworkTopologyStrategy','sz':3}

b.主机执行如下命令
nodetool repair system_auth
```


创建表空间
```
CREATE KEYSPACE mytestdb  WITH REPLICATION = { "class" : "NetworkTopologyStrategy", "sz" : 2 } and durable_writes = false;
```

建表
```
create table mytable (
area text,
name text,
age bigint,
sex text,
primary key ((area,name),bigint,sex)
) wiht compaction = {'class' : 'TimeWindowCompactionStrategy','compaction_window_size' : '1' ,'compaction_window_unit':'DAYS'} 
AND default_time_to_live = 864000
and gc_grace_seconds = 60
and dclocal_read_repair_chance = 0
and read_repair_chance = 0
and clustering order by (age DESC,sex  ASC);
```


授权流程管理

1、应用系统开发人员提交申请创建keyspace,DBA创建keyspace，并给xxdata账号授权；
```
CREATE KEYSPACE mytestdb  WITH REPLICATION = { "class" : "NetworkTopologyStrategy", "sz" : 2 } and durable_writes = false;
grant ALL PERMISSIONS on keyspace mytestdb to xxdata;
grant ALL PERMISSIONS on ALL FUNCTIONS in keyspace mytestdb to xxdata;
```

2、应用系统开发人员开发建表脚本，在建表脚本中定义授权脚本， 由部署人员使用xxdata执行脚本
```
grant select on keyspace mytestdb to xxopr;
grant modify on keyspace mytestdb to xxopr;
grant EXECUTE on ALL FUNCTIONS in keyspace mytestdb to xxopr;
```
3、应用系统及运营人员使用xxopr账号查询修改数据。
