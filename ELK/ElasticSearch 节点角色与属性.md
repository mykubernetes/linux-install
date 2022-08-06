# ES节点角色

ES如果采用单节点部署，不用考虑什么节点角色，默认就好。但是在大规模的ES集群中，一定要根据服务器配置，数据冷热，并发情况等合理配置节点的角色，才能让ES集群节点更好的协调合作，对外提供稳定的服务。

如果不通过 node.roles 设置节点的角色，一个ES节点默认的节点角色有：master 、data 、data_content、data_hot、data_warm、data_cold、ingest、ml、remote_cluster_client。

如果设置集群角色。每个集群至少要有master、data 或data_hot或data_content

## 主节点（master）

**主要负责集群元数据的管理和分发，是整个集群的大脑。** 能够在集群故障时被选举为master node，master node负责创建、删除索引，追踪集群中的节点，并确定每个node的shard分配。

## 数据节点（data）
**主要负责数据存储和数据读写请求处理，是整个集群的工人。** Data node保存索引数据，并且执行数据相关的操作：CRUD、search搜索、聚合搜索等，这些操作都比较耗费I/O、内存和CPU资源，在资源不够的情况下应该合理添加data node。

## 协调节点（coordinating）
**主要负责请求转发，将读写流量调度到具体的数据节点。** 协调节点负责处理所有来自客户端的请求以及返回给客户端的响应结果，默认情况下每个node都是协调节点。如果将node按功能分配角色：master node处理主节点事务、data node保存数据、ingest node进行数据预处理，那么coordinating node则是 route 客户端请求、处理搜索数据整合阶段并且分配批量索引操作 bulk indexing。

## 摄取节点（ingest）
**主要负责对数据进行处理转换。** Ingest node可以在文档索引之前执行ingest pipeline，进行数据清洗、字段填充等工作，对于数据预处理较为复杂，负载较重的ingest来说，应该单独部署ingest node。

## 其他节点

### 内容数据节点（data_content ）
处理用户创建的文档内容。包括CRUD、数据搜索和聚合等。

### 热点数据节点（data_hot）
存储近期经常读写的索引数据。该角色的nodes会根据数据进入ES的时间存储时序数据，hot层对数据读写要求较快，可以使用SSD。

### 暖数据节点（data_warm ）
存储不再被经常更新但是仍然被查询的索引数据。相比较于在hot层数据查询的频率要低。

### 冷数据节点（data_cold ）
存储很少被获取的只读索引数据。该层耗费资源少，可以搜索快照索引减少资源需求。

### 冻结数据节点（data_frozen ）
存储已被冻结的索引数据

### 机器学习节点（ml）
用于机器学习专用节点。需要在 xpack.ml.enabled 开关打开

### 远程集群客户端节点（remote_cluster_client ）
充当远程客户端。默认情况下，集群内任意节点都可以作为跨集群的客户端连接到远程集群。

### 转换节点（transform）
转换节点运行转换并处理转换 API 请求。一般开启transform角色的节点，推荐同时开启remote_cluster_client角色。

### 仅投票节点（voting_only ）
在master node的选举过程中参与投票，但是不会作为候选人被选为master node
