修改多数据中心配置
---
```
1、修改/conf/cassandra-rackdc.properties
dc=sz

2、修改/conf/jvm.options增加如下配置
-Dcassandra.ignore_dc=true

3、修改表空间
ALTER KEYSPACE mytestdb WITH replication = {'class':'NetworkTopologyStrategy','sz':2};
ALTER KEYSPACE system_auth WITH replication = {'class':'NetworkTopologyStrategy','sz':3};

4、集群实例一台台重启、完成一台再启下一台

5、nodetool repair system_auth
```
