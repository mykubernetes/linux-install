# ES 集群级路由和分片分配

集群级路由和分片分配(Cluster Level Shard Allocationedit)用于控制在何处，何时以及如何将分片分配给节点的设置。Master 节点的主要角色之一是确定将哪些分片分配给哪些节点，以及何时在节点之间移动分片以重新平衡群集。有许多设置可用于控制分片分配过程：
- 群集级分片分配列出了用于控制分配和重新平衡操作的设置。
- 基于磁盘的分片分配阐述了Elasticsearch如何考虑可用磁盘空间以及相关设置。
- 分片分配策略和强制分配策略控制如何在不同机架或可用性区域之间分配分片。
- 碎片分配过滤允许某些节点或某些节点组从分配中排除，以便将其停用。

# 集群级别分片分配（Cluster Level Shard Allocationedit）

分片分配是将分片分配给节点的过程。在初始恢复，副本分配，重新平衡或添加或删除节点时，可能会发生这种情况。

# 一、分片分配设置 Shard Allocation Settingsedit

以下动态设置可用于控制分片分配和恢复：

## 1.1、cluster.routing.allocation.enable

启用或禁用特定种类的分片的分配：
- all -（默认值）允许为所有类型的分片分配分片。
- primaries -仅允许为主要分片分配分片。
- new_primaries -仅允许为新索引的主分片分配分片。
- none -不允许对任何索引进行任何类型的分片分配。

重新启动节点时，此设置不会影响本地主分片的恢复。如果重新启动的节点有一个未分配的主分片的副本，则该节点将立即恢复该主分片，前提是其分配id与处于群集状态的活动分配id之一匹配。

## 1.2、cluster.routing.allocation.node_concurrent_incoming_recoveries

一个节点上允许进行多少并发的传入分片恢复。传入恢复是在节点上分配目标分片（很可能是副本，除非重新分配分片）的恢复。默认为2。

## 1.3、cluster.routing.allocation.node_concurrent_outgoing_recoveries

一个节点上允许进行多少并发的传出分片恢复。传出恢复是指在节点上分配了源分片（很可能是主分片，除非重新分配分片）的恢复。默认为2。

## 1.4、cluster.routing.allocation.node_concurrent_recoveries

同时设置cluster.routing.allocation.node_concurrent_incoming_recoveries和 cluster.routing.allocation.node_concurrent_outgoing_recoveries的快捷方式。

## 1.5、cluster.routing.allocation.node_initial_primaries_recoveries

尽管副本的恢复是通过网络进行的，但节点重启后未分配的主数据库的恢复将使用本地磁盘中的数据。这些操作应该很快，以便可以在同一节点上并行进行更多的初始主要恢复。默认为4。

## 1.6、cluster.routing.allocation.same_shard.host

允许执行检查以防止基于主机名和主机地址在单个主机上分配同一分片的多个实例。默认为false，表示默认情况下不执行任何检查。仅当在同一台计算机上启动多个节点时，此设置才适用。

# 二、分片重新平衡设置 Shard Rebalancing Settingsedit

以下动态设置可用于控制整个群集中的分片重新平衡：

## 2.1、cluster.routing.rebalance.enable

（动态）为特定种类的分片启用或禁用重新平衡：
- all -（默认值）允许所有种类的分片进行分片平衡。
- primaries -仅允许对主要分片进行分片平衡。
- replicas -仅允许对副本分片进行分片平衡。
- none -任何索引都不允许任何形式的分片平衡。

## 2.2、cluster.routing.allocation.allow_rebalance

(动态)指定何时允许分片重新平衡：
- always -始终允许重新平衡。
- indices_primaries_active -仅在分配了集群中的所有主节点时。
- indices_all_active -（默认）仅当分配了集群中的所有分片（主和副本）时。

## 2.3、cluster.routing.allocation.cluster_concurrent_rebalance

允许控制在集群范围内允许多少并发碎片重新平衡。默认为2。请注意，此设置仅控制由于集群中的不平衡而导致的并发碎片重定位的数量。此设置不会由于分配筛选或强制感知而限制碎片重新定位。

# 三、分片平衡启发式

以下设置一起用于确定每个碎片的放置位置。当没有允许的重新平衡操作使任何节点的权重比任何其他节点的权重更接近时，群集便达到平衡balance.threshold。

## 3.1、cluster.routing.allocation.balance.shard

为节点（浮动）上分配的分片总数定义权重因子。默认为0.45f。提出这一要求会增加使群集中所有节点上的分片数量相等的趋势。

## 3.2、cluster.routing.allocation.balance.index

为在特定节点（浮动）上分配的每个索引的分片数量定义权重因子。默认为0.55f。提出这一要求会增加在群集中所有节点上使每个索引的分片数量相等的趋势。

## 3.3、cluster.routing.allocation.balance.threshold

应当执行的操作的最小优化值（非负浮点数）。默认为1.0f。增大此值将导致群集在优化分片平衡方面不那么积极。

无论平衡算法的结果如何，由于强制感知或分配过滤，可能不允许重新平衡。
