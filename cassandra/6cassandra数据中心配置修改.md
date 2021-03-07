修改多数据中心配置
---

```
# vi /etc/cassandra/default.conf/cassandra.yaml
cluster_name: 'TCS01'
num_tokens: 256
    seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
    parameters:
    - seeds:  "192.168.120.83,192.168.120.85"
listen_address:192.168.120.83
endpoint_snitch: GossipingPropertyFileSnitch
start_rpc: true
rpc_address: 192.168.120.83
```
- endpoint_snitch 对于跨数据中心的集群，此参数的值必须为GossipingPropertyFileSnitch；如果为SimpleSnitch，所有节点都会加入一个数据中心。 

```
1、修改/conf/cassandra-rackdc.properties
dc=dc1
rack=rack1

2、修改/conf/jvm.options增加如下配置
-Dcassandra.ignore_dc=true

3、修改表空间
ALTER KEYSPACE mytestdb WITH replication = {'class':'NetworkTopologyStrategy','sz':2};
ALTER KEYSPACE system_auth WITH replication = {'class':'NetworkTopologyStrategy','sz':3};

4、集群实例一台台重启、完成一台再启下一台

5、nodetool repair system_auth
```
