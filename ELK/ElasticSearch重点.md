# 一、集群核心配置

在elasticsearch.yml配置中
- 1、cluster.name：集群名称，节点根据集群名称确定是否同一个集群
- 2、node.name：节点名称，集群内唯一
- 3、node.roles：[data数据节点,master候选节点,voting_only仅投票节点,remote_cluster_client远程节点]
- 4、network.host：节点对外提供服务的地址以及集群内通信的ip地址
- 5、http.port：对外提供服务的端口号，默认为9200
- 6、discovery.send_hosts：集群初始化的种子节点，可配置部分或全部候选节点，一般配置全部节点即可
- 7、cluster.initial_master_nodes：节点初始主节点，必须有master角色的节点，可以理解为集群启动时指定某一节点为主节点
- 8、多个节点直接通信使用tcp协议，es默认为9300

# 二、节点角色
- 1、active master：主节点要进行轻量级的任务，如索引的创建、删除等
- 2、在elasticsearch.yml配置中node.roles如果配置为master仅代表这个节点可作为候选节点，而不代表该节点为主节点
- 3、master节点既可以作为候选节点又可以作为投票节点，当master节点同时设置voting-only时，该节点只能作为投票节点
- 4、考试考点：
  - ①配置主节点（master-eligible node）：node.roles:[master,.......]　　
  - ②配置专用主节点（dedicates master-eligible node）：node.roles:[master]
  - ③配置仅投票节点（只有选举权，没有被选举权，这样的节点同时可以充当数据节点避免资源浪费）：node.roles:[master,data,voting_only]
- 5、配置专用主节点只能将节点设置为master
- 6、配置仅投票节点就是将节点设置为master和voting-only
- 7、ingest节点：预处理节点，假如数据中含有\n或者其他或者空字符串时我们需要将这些处理掉，这时就可以通过ingest节点进行曹祖
- 8、remote_cluster_client节点：远程节点。跨集群搜索必须的角色

# 三、分片

- 1、主分片：假设有3000条数据，那么每个主分片上会将数据平分
  - 副本分片：每一个主分片的备份分片
- 2、_cat/health?v   输出title及集群状态
- 3、cat命令api
  - _cat/indices?health=yellow&v=true：查看当前集群中的所有索引
  - _cat/nodeattrs：查看节点属性
  - _cat/nodes：查看集群中的节点
  - _cat/shards：查看指定索引的分片分配
  - _cat/shards?h=index,shard,prirep,state,unassigned.reason：查看指定属性分片分配

- 4、_cluster/allocation/explain：用于诊断分片未分配原因
  - _cluster/health/：检查集群状态
