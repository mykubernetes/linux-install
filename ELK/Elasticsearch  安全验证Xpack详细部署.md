1、操作系统设置，需要在所有ES节点上执行
```
# vim /etc/sysctl.conf 文件，添加或修改 vm.max_map_count 配置
vm.max_map_count=655360

# 保存后刷新操作系统配置
# sysctl -p
```

2、修改系统资源配置，需要在所有ES节点执行
```
# 修改 /etc/security/limits.conf 文件，在最后添加内容
*  soft    nproc   1024000
*  hard    nproc   1024000
*  soft    nofile  1024000
*  hard    nofile  1024000
```

3、添加ES用户，需要在所有ES节点执行
```
# groupadd elasticsearch
# useradd elasticsearch -g elasticsearch -b /opt
```

4、解压es安装包到 /opt/elasticsearch 目录下，并修改解压后的目录属主为elasticsearch，在所有ES节点执行
```
# cd /opt
# tar -zxvf elasticsearch-6.8.2.tar.gz -C /opt/elasticsearch

# cd /opt/elasticsearch
# chown -R elasticsearch:elasticsearch elasticsearch-6.8.2/
```

5、配置JAVA_HOME环境变量，需要在所有ES节点执行
```
# vim /etc/profile
export JAVA_HOME=/opt/java
export PATH=$JAVA_HOME/bin:$PATH

# source /etc/profile
```

6、创建ES集群的数据和日志目录，需要在ES所有节点执行
```
# mkdir -p /opt/elasticsearch/{data,logs}
# chown -R elasticsearch:elasticsearch /opt/elasticsearch
```

7、切换到elasticsearch用户, 在所有ES节点进行如下操作：
```
# cd /opt/elasticsearch/elasticsearch-6.8.2/config

# vim elasticsearch.yml 
cluster.name: es-cluster
node.name: master1                                                      #根据节点信息填写，独立部署推荐为master1~3，node1~3
path.data: /opt/elasticsearch/data
path.logs: /opt/elasticsearch/logs
network.host: 0.0.0.0
http.port: 9200
node.master: true                                                       # ES master节点填写为true，否则为false
node.data: false                                                        # ES 数据节点填写为true，否则为false
discovery.zen.ping.unicast.hosts: ["192.168.101.66:9300", "192.168.101.67:9300", "192.168.101.68:9300"]       #填写所有ES节点的信息，包括master和data节点
discovery.zen.minimum_master_nodes: 2
```

8、以elasticsearch用户，修改ES配置信息，在所有ES节点进行如下操作：
```
# cd /opt/elasticsearch/elasticsearch-6.8.2/config
# vim jvm.options文件，修改或添加 Xms 和 Xmx 配置
-Xms8g                                              #设置为节点内存的一半
-Xmx8g                                              #与xms值保持一致
```

9、以elasticsearch用户，启动ES进程，在所有ES节点进行：
```
# cd /opt/elasticsearch/elasticsearch-6.8.2/bin && ./elasticsearch -d
```

10、检查ES集群状态信息，确认9200服务端口处于监听状态

- 查看端口是否监听
```
# netstat -ltnp | grep 9200
```

- 查看es是否正常启动
```
# curl -X GET 'localhost:9200/'
{
  "name" : "node01",
  "cluster_name" : "es-cluster",
  "cluster_uuid" : "53LLexx8RSW16nE4lsJMQQ",
  "version" : {
    "number" : "6.8.2",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "159a78a",
    "build_date" : "2021-11-06T20:11:28.826501Z",
    "build_snapshot" : false,
    "lucene_version" : "7.5.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

- 查看集群是否正常
```
# curl -X GET 'localhost:9200/_cluster/health?pretty'
{
  "cluster_name" : "es-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

- 查看集群状态
```
# curl -XGET 'http://localhost:9200/_cat/nodes'
192.168.101.66 48 39 0 0.22 0.07 0.06 mdi * node01       # 带*号的表示master
192.168.101.67 41 98 0 0.03 0.06 0.05 -   - node02       # 注意这个节点并不参与数据处理。
192.168.101.68 44 57 0 0.00 0.01 0.05 mdi - node03
```

- 查看集群详细状态
```
# curl -XGET 'http://127.0.0.1:9200/_cat/nodes?v'
ip             heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.101.66           34          39   0    0.13    0.10     0.07 mdi       *      node01
192.168.101.67           20          98   0    0.01    0.05     0.05 -         -      node02
192.168.101.68           32          57   0    0.00    0.01     0.05 mdi       -      node03
```

- 查询master。
```
# curl -XGET 'http://localhost:9200/_cluster/state/master_node?pretty'
{
  "cluster_name" : "es-clusterr",
  "compressed_size_in_bytes" : 14291,
  "cluster_uuid" : "53LLexx8RSW16nE4lsJMQQ",
  "master_node" : "oCNARqdUT5KXLZTlcS22GA"
}

# curl -XGET 'http://localhost:9200/_cat/master?v'
id                     host           ip             node
oCNARqdUT5KXLZTlcS22GA 192.168.101.67 192.168.101.67 node02
```

- 查询集群健康状态。
```
# curl -XGET 'http://localhost1:9200/_cat/health?v'
epoch      timestamp cluster    status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1545386516 10:01:56  es-cluster green           4         3     22  11    0    0        0             0                  -                100.0%
```

- 查看集群详细信息。
```
# curl -XGET 'http://localhost:9200/_cluster/state/nodes?pretty'
{
  "cluster_name" : "es-cluster",                        #集群名称
  "compressed_size_in_bytes" : 14291,
  "cluster_uuid" : "53LLexx8RSW16nE4lsJMQQ",            #集群id
  "nodes" : {
    "oCNARqdUT5KXLZTlcS22GA" : {                        #node的ID值
      "name" : "node01",                                #node名称
      "ephemeral_id" : "y-NCFJULTEmWdWjNjCPS2A",
      "transport_address" : "192.168.101.66:9300",       #集群通讯地址
      "attributes" : {
        "ml.machine_memory" : "8202727424",
        "xpack.installed" : "true",
        "ml.max_open_jobs" : "20",
        "ml.enabled" : "true"
      }
    },
    "8F_rZuR1TByEb6bXz0EgzA" : {
      "name" : "node02",
      "ephemeral_id" : "b3CtPKpyRUahT4njpRqjlQ",
      "transport_address" : "192.168.101.67:9300",
      "attributes" : {
        "ml.machine_memory" : "8202039296",
        "ml.max_open_jobs" : "20",
        "xpack.installed" : "true",
        "ml.enabled" : "true"
      }
    },
    "ptEOHzaPTgmlqW3NRhd7SQ" : {
      "name" : "node03",
      "ephemeral_id" : "YgypZZNcTfWcIYDhOlUAzw",
      "transport_address" : "192.168.101.68:9300",
      "attributes" : {
        "ml.machine_memory" : "8202039296",
        "ml.max_open_jobs" : "20",
        "xpack.installed" : "true",
        "ml.enabled" : "true"
      }
    }
  }
}
```

### 高可用验证

通过刚刚的测试，已经看出，master在node01，现在将node1的es停掉，看看是否会自动漂移。
```
# curl -XGET 'http://127.0.0.1:9200/_cat/nodes?v'
ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.101.66          36          39   0    0.03    0.04     0.05 mdi       *      elk-node01
192.168.101.67          22          98   0    0.00    0.02     0.05 -         -      elk-node02
192.168.101.68          38          57   0    0.00    0.01     0.05 mdi       -      elk-node03

[root@localhost ~]$systemctl stop elasticsearch
```

然后到另外一个节点查看一下：
```
# curl -XGET 'http://127.0.0.1:9200/_cat/nodes?v'
ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.101.67           30          62   0    0.00    0.01     0.05 mdi       *      elk-node02
192.168.101.68           24          98   0    0.00    0.02     0.05 -         -      elk-node03
```

11、以elasticsearch用户运行，在其中一个ES节点上运行配置xpack

- es6.8已经可以免费使用xpack了,所以不需要进行破解即可使用了
```
# cd /opt/elasticsearch/elasticsearch-6.8.2/bin
# ./elasticsearch-certgen                                #根据前面的ES集群信息进行配置

Please enter the desired output file [certificate-bundle.zip]: cert.zip        # 生成的压缩包名称
Enter instance name: elasticsearch                                             # 实例名称可以自定义设置
Enter name for directories and files [elasticsearch]: elasticsearch            # 存储实例证书的文件夹名，可以随意指定或保持默认
Enter IP Addresses for instance (comma-separated if more than one) []: 192.168.101.66,192.168.101.67,192.168.101.68   # 实例ip，多个ip用逗号隔开
Enter DNS names for instance (comma-separated if more than one) []: node01,node02,node03                              # 节点名，多个节点用逗号隔开，无解析可用ip代替
Would you like to specify another instance? Press ‘y‘ to continue entering instance information: n                    # 不需要按y重新设置,按空格键就完成
Certificates written to /opt/elasticsearch/elasticsearch-6.8.2/bin/bin/cert.zip                                       # 生成的文件存放地址，不用填写

This file should be properly secured as it contains the private keys for all
instances and the certificate authority.

After unzipping the file, there will be a directory for each instance containing
the certificate and private key. Copy the certificate, key, and CA certificate
to the configuration directory of the Elastic product that they will be used for
and follow the SSL configuration instructions in the product guide.

For client applications, you may only need to copy the CA certificate and
configure the client to trust this certificate.


# 会在当前目录生成cert.zip文件，将改文件拷贝到所有ES节点 /opt/elasticsearch/elasticsearch-6.8.2/config目录并解压
# chown -R elasticsearch:elasticsearch cert.zip
# unzip cert.zip
```

解压cert.zip文件会得到
```
   creating: ca/
  inflating: ca/ca.crt               
  inflating: ca/ca.key               
   creating: elasticsearch/
  inflating: elasticsearch/elasticsearch.crt  
  inflating: elasticsearch/elasticsearch.key 
```

12、以elasticsearch用户操作，在所有的ES节点新增xpack配置
```
# vim /opt/elasticsearch/elasticsearch-6.8.2/config/elasticsearch.yml

# 集群名称,必须统一
cluster.name: es-cluster

# 节点名称
node.name: master1

# 数据目录和日志目录
path.data: /opt/elasticsearch/data
path.logs: /opt/elasticsearch/logs

# 监听地址
network.host: 0.0.0.0
http.port: 9200

# 集群角色
node.master: true				                                                # ES master节点填写为true，否则为false
node.data: false				                                                # ES 数据节点填写为true，否则为false

# 配置集群的节点地址
discovery.zen.ping.unicast.hosts: ["192.168.101.66:9300", "192.168.101.67:9300", "192.168.101.68:9300"]       #填写所有ES节点的信息，包括master和data节点
discovery.zen.minimum_master_nodes: 2

# 开通高级权限后,打开安全配置功能
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true

# 配置ssl和CA证书配置
xpack.ssl.key: elasticsearch/elasticsearch.key
xpack.ssl.certificate: elasticsearch/elasticsearch.crt
xpack.ssl.certificate_authorities: ca/ca.crt
```

13、以elasticsearch用户运行，重启ES节点服务，在所有的ES节点进行
```
# ps -ef | grep elasticsearch | grep -v grep | awk '{print $2}' | xargs kill -9
# cd /opt/elasticsearch/elasticsearch-6.8.2/bin && ./elasticsearch -d
```

14、以elasticsearch用户运行，设置ES集群密码，在任意一个ES节点上运行

- ES中内置了几个管理其他集成组件的账号即：`apm_system`, `beats_system`, `elastic`, `kibana`, `logstash_system`, `remote_monitoring_user`，使用之前，首先需要添加一下密码。
```
# cd cd /opt/elasticsearch/elasticsearch-6.8.2/bin 
# ./elasticsearch-setup-passwords interactive                       # 密码全都填写 elastic （现场根据需求修改）
Initiating the setup of passwords for reserved users elastic,apm_system,kibana,logstash_system,beats_system,remote_monitoring_user.
You will be prompted to enter passwords as the process progresses.
Please confirm that you would like to continue [y/N]y

Enter password for [elastic]:                                       # 在这里设置密码，注意最少六位，下面也一样
Reenter password for [elastic]:
Enter password for [apm_system]:
Reenter password for [apm_system]:
Enter password for [kibana]:
Reenter password for [kibana]:
Enter password for [logstash_system]:
Reenter password for [logstash_system]:
Enter password for [beats_system]:
Reenter password for [beats_system]:
Enter password for [remote_monitoring_user]:
Reenter password for [remote_monitoring_user]:
Changed password for user [apm_system]
Changed password for user [kibana]
Changed password for user [logstash_system]
Changed password for user [beats_system]
Changed password for user [remote_monitoring_user]
Changed password for user [elastic]
```
- interactive：给用户一一设置密码。
- auto：自动生成密码。

如果这个地方报如下错误：
```
Failed to determine the health of the cluster running at http://10.3.7.7:9200
Unexpected response code [503] from calling GET http://10.3.7.7:9200/_cluster/health?pretty
Cause: master_not_discovered_exception

It is recommended that you resolve the issues with your cluster before running elasticsearch-setup-passwords.
It is very likely that the password changes will fail when run against an unhealthy cluster.

Do you want to continue with the password setup process [y/N]y
```
- 可能是有脏数据导致，此时可以停掉es，删除 data 数据目录，然后重新启动在进行操作。

清理密码数据方法
```
# curl -XDELETE http://localhost:9200/.secutity-6
```

15、验证集群状态，确认集群状态为green
```
# curl -XGET -uelastic:elastic 'localhost:9200/_xpack/security/user?pretty'
# curl -XGET -uelastic:elastic 'localhost:9200/_cluster/health?pretty'
```

16、es六个内置账号及权限

| username | role | 权限 |
|----------|-------|-----|
| elastic | superuser | 内置的超级用户 |
| kibana | kibana_system | 用户kibana用来连接elasticsearch并与之通信。Kibana服务器以该用户身份提交请求以访问集群监视API和 .kibana索引。不能访问index。 |
| logstash_system | logstash_system | 用户Logstash在Elasticsearch中存储监控信息时使用 |


查询所有用户
```
# curl -XGET -uelastic:elastic 'localhost:9200/_xpack/security/user?pretty'
```

查看指定用户
```
# curl -X GET -uelastic:elastic "localhost:9200/_xpack/security/user/jacknich"
```

查询所有roles
```
# curl -XGET -uelastic:elastic 'localhost:9200/_xpack/security/role?pretty'
```

创建用户[chengen]
```
# curl -X POST -u elastic "localhost:9200/_xpack/security/user/chengen" -H 'Content-Type: application/json' -d'
{
  "password" : "your passwd",
  "roles" : [ "admin"],
  "full_name" : "chengen",
  "email" : "xxxxxx@qq.com",
  "metadata" : {
    "intelligence" : 7
  }
}'
```
- 加上`-u elastic`是因为只有elastic用户有管理用户权限，另外，请求参数后面可以带上`?pretty`，这样返回的格式会好看一点儿

修改账户密码
```
# curl -X POST -uelastic:elastic "localhost:9200/_xpack/security/user/test/_password" -H 'Content-Type: application/json' -d'
{
  "password" : "your passwd"
}'
```

禁用/启动/删除用户
```
# curl -X PUT -uelastic:elastic "localhost:9200/_xpack/security/user/test/_disable"  
# curl -X PUT -uelastic:elastic "localhost:9200/_xpack/security/user/test/_enable"
# curl -X DELETE -uelastic:elastic "localhost:9200/_xpack/security/user/test"
```

```
# 创建events_admin的roles，该用户组对events*有all权限，对.kibana有manage，read，index权限
# curl -XPOST -uelastic:elastic 'localhost:9200/_xpack/security/role/events_admin' -H "Content-Type: application/json" -d '{
  "indices" : [
    {
      "names" : [ "events*" ],
      "privileges" : [ "all" ]
    },
    {
      "names" : [ ".kibana*" ],
      "privileges" : [ "manage", "read", "index" ]
    }
  ]
}'

# 创建johndoe用户，设置密码为123456，使用events_admin角色
# curl -XPOST -uelastic:elastic 'localhost:9200/_xpack/security/user/johndoe' -H "Content-Type: application/json" -d '{
  "password" : "123456",
  "full_name" : "John Doe",
  "email" : "john.doe@anony.mous",
  "roles" : [ "events_admin" ]
}'
```

```
# 设置集群权限角色
curl -X POST "localhost:9200/_xpack/security/role/my_admin_role" -H 'Content-Type: application/json' -d'
{
  "cluster": ["all"],
  "indices": [
    {
      "names": [ "index1", "index2" ],
      "privileges": ["all"],
      "field_security" : { // 可选
        "grant" : [ "title", "body" ]
      },
      "query": "{\"match\": {\"title\": \"foo\"}}" // 可选
    }
  ],
  "run_as": [ "other_user" ], // 可选
  "metadata" : { // 可选
    "version" : 1
  }
}'
```

验证admin用户，通过admin账户和admin的密码访问ES的/_xpack/security/_authenticate接口，能看到用户的信息
```
# curl -XGET -uelastic:elastic 'localhost:9200/_xpack/security/_authenticate -u admin:admin
返回：
{
  "username": "admin",
  "roles": [],                       #注意，还没有绑定任何角色，现在角色是空的
  "full_name": null,
  "email": null,
  "metadata": {
    "ldap_dn": "cn=admin,ou=person,dc=intelli706,dc=com",
    "ldap_groups": []
  },
  "enabled": true,
  "authentication_realm": {
    "name": "ldap1",
    "type": "ldap"
  },
  "lookup_realm": {
    "name": "ldap1",
    "type": "ldap"
  }
}
```

```
# 1、创建角色
curl -X POST "localhost:9200/_xpack/security/role/xsjc -H 'Content-Type: application/json' -d'
{
  "cluster": ["all"],
  "indices": [
    {
      "names": [ "tyyw*"],
      "privileges": ["read"],
      "field_security" : {
        "grant" : [ "TYYW_2001_AJ__CBDW_MC", "TYYW_2001_AJ__CBDW_MC.keyword" ]
      }
    }
  ]
}
返回：
{
  "role": {
    "created": true
  }
}

# 2、查询角色
# curl -XGET -uelastic:elastic 'localhost:9200/_xpack/security/role/xsjc #查询指定角色

返回
{
  "xsjc": {
    "cluster": [
      "all"
    ],
    "indices": [
      {
        "names": [
          "tyyw*"
        ],
        "privileges": [
          "read"
        ],
        "field_security": {
          "grant": [
            "TYYW_2001_AJ__CBDW_MC",
            "TYYW_2001_AJ__CBDW_MC.keyword"          #注意，这个角色只给这两列的read权限
          ]
        },
        "allow_restricted_indices": false
      }
    ],
    "applications": [],
    "run_as": [],
    "metadata": {},
    "transient_metadata": {
      "enabled": true
    }
  }
}

# 3、给用户绑定角色
# 本质上是创建一个用户和角色的映射关系，<user_role_map_name>就是这个角色和映射关系的名称
curl -X POST "localhost:9200/_xpack/security/role_mapping/zhangyan_role -H 'Content-Type: application/json' -d'
{
    "enabled": true,
    "roles": "xsjc",
    "rules": {
        "field": {
            "dn": "cn=zhangyan,ou=person,dc=intelli706,dc=com"
        }
    }
}
返回：
{
  "role_mapping": {
    "created": true
  }
}

# 4、查询用户_角色绑定映射关系
# curl -XGET -uelastic:elastic 'localhost:9200/_xpack/security/role_mapping/zhangyan_role           #查询指定的用户_角色映射关系
返回：
{
  "zhangyan_role": {
    "enabled": true,
    "roles": [
      "xsjc"
    ],
    "rules": {
      "field": {
        "dn": "cn=zhangyan,ou=person,dc=intelli706,dc=com"
      }
    },
    "metadata": {}
  }
}

# 5、查询用户信息
# curl -XGET -uelastic:elastic 'localhost:9200/_xpack/security/_authenticate -u zhangyan:zhangyan
返回:
{
  "username": "zhangyan",
  "roles": [
    "xsjc" # 可以看到已经有权限了
  ],
  "full_name": null,
  "email": null,
  "metadata": {
    "ldap_dn": "cn=zhangyan,ou=person,dc=intelli706,dc=com",
    "ldap_groups": []
  },
  "enabled": true,
  "authentication_realm": {
    "name": "ldap1",
    "type": "ldap"
  },
  "lookup_realm": {
    "name": "ldap1",
    "type": "ldap"
  }
}
```

角色管理API：
- https://www.elastic.co/guide/en/elasticsearch/reference/6.0/security-api-roles.html

用户管理API：
- https://www.elastic.co/guide/en/elasticsearch/reference/6.0/security-api-users.html

将用户和组映射到角色API：
- https://www.elastic.co/guide/en/x-pack/6.0/mapping-roles.html#ldap-role-mapping

设置字段和文档级别的安全性：
- https://www.elastic.co/guide/en/x-pack/6.0/field-and-document-access-control.html

安全特权
- https://www.elastic.co/guide/en/x-pack/6.0/security-privileges.html#privileges-list-cluster

x-pack内置角色
- https://www.elastic.co/guide/en/x-pack/6.0/built-in-roles.html

eg:
- ingest_admin: #授予访问权限以管理所有索引模板和所有摄取管道配置。这个角色不能提供创建索引的能力; 这些特权必须在一个单独的角色中定义。
- kibana_dashboard_only_user: #授予对Kibana仪表板的访问权限以及对.kibana索引的只读权限。 这个角色无法访问Kibana中的编辑工具。
- kibana_system: #授予Kibana系统用户读取和写入Kibana索引所需的访问权限，管理索引模板并检查Elasticsearch集群的可用性。 此角色授予对.monitoring- 索引的读取访问权限以及对.reporting- 索引的读取和写入访问权限。
- kibana_user: #授予Kibana用户所需的最低权限。 此角色授予访问集群的Kibana索引和授予监视权限。
- logstash_admin: #授予访问用于管理配置的.logstash *索引的权限。
- logstash_system: #授予Logstash系统用户所需的访问权限，以将系统级别的数据（如监视）发送给Elasticsearch。不应将此角色分配给用户，因为授予的权限可能会在不同版本之间发生变化。此角色不提供对logstash索引的访问权限，不适合在Logstash管道中使用。
- machine_learning_admin: #授予manage_ml群集权限并读取.ml- *索引的访问权限。
- machine_learning_user: #授予查看X-Pack机器学习配置，状态和结果所需的最低权限。此角色授予monitor_ml集群特权，并可以读取.ml-notifications和.ml-anomalies *索引，以存储机器学习结果。
- monitoring_user: #授予除使用Kibana所需的X-Pack监视用户以外的任何用户所需的最低权限。 这个角色允许访问监控指标。 监控用户也应该分配kibana_user角色。
- remote_monitoring_agent: #授予远程监视代理程序将数据写入此群集所需的最低权限。
- reporting_user: #授予使用Kibana所需的X-Pack报告用户所需的特定权限。 这个角色允许访问报告指数。 还应该为报告用户分配kibana_user角色和一个授予他们访问将用于生成报告的数据的角色。
- superuser: #授予对群集的完全访问权限，包括所有索引和数据。 具有超级用户角色的用户还可以管理用户和角色，并模拟系统中的任何其他用户。 由于此角色的宽容性质，在将其分配给用户时要格外小心。
- transport_client: #通过Java传输客户端授予访问集群所需的权限。 Java传输客户端使用节点活性API和群集状态API（当启用嗅探时）获取有关群集中节点的信息。 如果他们使用传输客户端，请为您的用户分配此角色。使用传输客户端有效地意味着用户被授予访问群集状态的权限。这意味着用户可以查看所有索引，索引模板，映射，节点以及集群基本所有内容的元数据。但是，此角色不授予查看所有索引中的数据的权限。
- watcher_admin: #授予对.watches索引的写入权限，读取对监视历史记录的访问权限和触发的监视索引，并允许执行所有监视器操作。
- watcher_user: #授予读取.watches索引，获取观看动作和观察者统计信息的权限。

### 可以分配给角色的权限 

- cluster权限

| 权限 | 详情 |
|------|-----|
| all | 所有集群管理操作，如快照，节点关闭/重新启动，设置更新，重新路由或管理用户和角色。 |
| monitor | 所有集群只读操作，如集群运行状况，热线程，节点信息，节点和集群统计信息，快照/恢复状态，等待集群任务。 |
| monitor_ml | 所有只读机器学习操作，例如获取有关数据传输，作业，模型快照或结果的信息。 |
| monitor_watcher | 所有只读操作，例如获取watch和watcher统计信息。 |
| manage | 构建monitor并添加更改集群中值的集群操作。这包括快照，更新设置和重新路由。此特权不包括管理安全性的能力。 |
| manage_index_templates | 索引模板上的所有操作。 |
| manage_ml | 所有机器学习操作，例如创建和删除数据传输，作业和模型快照。数据处理以具有提升特权的系统用户身份运行，包括读取所有索引的权限。 |
| manage_pipeline | 摄取管道的所有操作。 |
| manage_security | 所有与安全相关的操作，例如对用户和角色的CRUD操作以及缓存清除。 |
| manage_watcher | 所有观察者操作，例如放置watches，执行，激活或确认。Watches作为具有提升特权的系统用户运行，包括读取和写入所有索引的权限。Watches作为具有提升特权的系统用户运行，包括读取和写入所有索引的权限。 |
| transport_client | 传输客户端连接所需的所有权限。远程群集需要启用跨级群搜索。 |

- indices权限

| 权限 | 详情 |
|------|------|
| all | 索引上的任何操作。 |
| monitor | 监控所需的所有操作（恢复，细分信息，索引统计信息和状态）。 |
| manage | 所有monitor特权加索引管理（别名，分析，缓存清除，关闭，删除，存在，刷新，映射，打开，强制合并，刷新，设置，搜索分片，模板，验证）。 |
| view_index_metadata | 对索引元数据（别名，别名存在，获取索引，存在，字段映射，映射，搜索分片，类型存在，验证，warmers，设置）进行只读访问。此特权主要供Kibana用户使用。 |
| read | 只读操作（计数，解释，获取，mget，获取索引脚本，更多像这样，多渗透/搜索/ termvector，渗透，滚动，clear_scroll，搜索，建议，tv）。 |
| read_cross_cluster | 只读访问来自远程集群的搜索操作。 |
| index | 索引和更新文件。还授予对更新映射操作的访问权限。 |
| create | 索引文件。还授予对更新映射操作的访问权限。 |
| delete | 删除文件。 |
| write | 对文档执行所有写入操作的权限，包括索引，更新和删除文档以及执行批量操作的权限。还授予对更新映射操作的访问权限。 |
| delete_index | 删除索引。 |
| create_index | 创建索引。创建索引请求可能包含在创建索引时添加到索引的别名。在这种情况下，该请求最好有manage权限，同时设置索引和别名。 |

参考：
- https://www.modb.pro/db/105875
- https://blog.csdn.net/pistolove/article/details/53838138
