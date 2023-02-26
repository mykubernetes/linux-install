滚动升级策略，集群，集群里面有多个节点，一个节点一个节点的重启和升级

如果是大版本之间的升级，集群重启策略，要先将整个集群全部停掉，如果采取滚动升级策略的话，可能导致说，一个集群内，有些节点是es 5.5，有些节点是es 2.4.3，这样的话是可能会有问题的

升级的过程，其实是跟之前的一模一样的

es在进行重大版本升级的时候，一般都需要采取full cluster restart的策略，重启整个集群来进行升级。rolling upgrade在重大版本升级的时候是不合适的。

执行一个full cluster restart升级的过程如下：

我们先停掉之前的es 5.5，删除所有相关的目录，然后安装一个es 2.4.3，再将其升级到es 5.5
```
chown -R elasticsearch /usr/local/elasticsearch
chown -R elasticsearch /var/log/elasticsearch
chown -R elasticsearch /var/data/elasticsearch
chown -R elasticsearch /etc/elasticsearch
su elasticsearch
elasticsearch -d -Dpath.conf=/etc/elasticsearch
kill -SIGTERM 15516
```

```
curl -XPUT 'http://localhost:9200/forum/article/1?pretty' -d '
{
  "title": "first article",
  "content": "this is my first article"
}'
```
 

# （1）禁止shard allocation
 

我们停止一个node时，可能导致部分replica shard死掉了，此时shard allocation机制会立即在其他节点上分配一些replica shard过去。如果是停止node导致primary shard死掉了，会将其他node上的replica shard提升为primary shard，同理会给其复制足够的replica shard，保持replica副本数量。但是这回导致大量的IO开销。我们首先得先禁止这个机制：
```
curl -XPUT 'http://localhost:9200/_cluster/settings?pretty' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": "none"
  }
}'
```

# （2）执行一次flush操作

我们最好是停止接受新的index写入操作，并且执行一次flush操作，确保数据都fsync到磁盘上。这样的话，确保没有数据停留在内存和WAL日志中。shard recovery的时间就会很短。
```
curl -XPOST 'http://localhost:9200/_flush/synced?pretty'
```
此时，最好是执行synced flush操作，因为我们最好是确保说flush操作成功了，再执行下面的操作

如果flush操作报错了，那么可以反复多执行几次

# （3）关闭和升级所有的node
如果是将es 2.x版本升级到es 5.x版本，唯一的区别就在这里开始了，先将整个集群中所有的节点全部停止

将最新版本的es解压缩替代之前的es安装目录之前，一定要记得先将plugins做个备份

将集群上所有node上的es服务都给停止，然后按照rolling upgrade中的步骤对集群中所有的node进行升级

将所有的节点全部停掉，将所有的node全部替换为最新版本的es安装目录

# （4）升级plugin
最新版的es解压开来以后，就可以看看，可以去做一个plugin的升级

es plugin的版本是跟es版本相关联的，因此必须使用elasticsearch-plugin脚本来安装最新的plugin版本

# （5）启动cluster集群
如果我们有专门的master节点的话，就是那些将node.master设置为true的节点（默认都是true，都有能力作为master节点），而且node.data设置为false，那么就先将master node启动。等待master node组建成一个cluster之后，这些master node中会选举一个正式的master node出来。可以在log中检查master的选举。

只要minimum number of master-eligible nodes数量的node发现了彼此，他们就会组成一个cluster，并且选举出来一个master。从这时开始，可以监控到加入cluster的node。


依次将所有的node重新启动起来
```
elasticsearch -d -Epath.conf=/etc/elasticsearch
```
 
如果是将es 2.x升级到es 5.x，记得将log4j.properties拷贝到你外部的目录中去，而且还要重新做目录的权限的更改
```
curl -XGET 'http://localhost:9200/_cat/health?pretty'
curl -XGET 'http://localhost:9200/_cat/nodes?pretty'
```
 

# （6）等待cluster状态变成yellow
只要每个ndoe都加入了cluster，就会开始对primary shard进行receover过程，就是看有没有数据在WAL日志中的，给恢复到内存里。刚开始的话，_cat/health请求会反馈集群状态是red，这意味着不是所有的primary shard都被分配了。

只要每个node发现了自己本地的shard之后，集群status就会变成yellow，意味着所有的primary shard都被发现了，但是并不是所有的replica shard都被分配了。

# （7）重新启用allocation
直到所有的node都加入了集群，再重新启用shard allocation，可以让master将replica分配给那些本地已经有replica shard的node上。
```
curl -XPUT 'http://localhost:9200/_cluster/settings?pretty' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": "all"
  }
}'
```

cluster这个时候就会开始将replica shard分配给data node。此时可以恢复index和search操作，不过最好还是等待replica shard全部分配完之后，再去恢复读写操作。

我们可以通过下面的api来监控这个过程
```
GET _cat/health
GET _cat/recovery
```
 

如果_cat/health中的status列变成了green，那么所有的primary和replica shard都被成功分配了
