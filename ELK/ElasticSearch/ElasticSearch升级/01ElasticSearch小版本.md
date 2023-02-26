生产集群的时候，版本升级，是不可避免的，es主要的版本，es 2.x，es 5.x，es 1.x

三种策略：
- 1、面向的场景，就是同一个大版本之间的各个小版本的升级，比如说，我们这一节课，es 5.3升级到es 5.5
- 2、相邻的两个大版本之间的升级，比如es 2.x升级到es 5.x，es 2.4.3，升级到es 5.5
- 3、跨了几个大版本之间的升级，就比如说es 1.x升级到es 5.x

 

# 每一种场景使用的技术方案都是不一样的

## 1、es版本升级的通用步骤
（1）看一下最新的版本的breaking changes文档，官网，看一下，每个小版本之间的升级，都有哪些变化，新功能，bugfix
（2）用elasticsearch migration plugin在升级之前检查以下潜在的问题（在老版本的时候可能还会去用，现在新版本这个plugin很少用了）
（3）在开发环境的机器中，先实验一下版本的升级，定一下升级的技术方案和操作步骤的文档，然后先在你的测试环境里，先升级一次，搞一下
（4）对数据做一次全量备份，备份和恢复，最次最次的情况，哪怕是升级失败了，哪怕是你重新搭建一套全新的es
（5）检查升级之后各个plugin是否跟es主版本兼容，升级完es之后，还要重新安装一下你的plugin

 es不同版本之间的升级，用的升级策略是不一样的
（1）es 1.x升级到es 5.x，是需要用索引重建策略的
（2）es 2.x升级到es 5.x，是需要用集群重启策略的
（3）es 5.x升级到es 5.y，是需要用节点依次重启策略的

es的每个大版本都可以读取上一个大版本创建的索引文件，但是如果是上上个大版本创建的索引，是不可以读取的。比如说es 5.x可以读取es 2.x创建的索引，但是没法读取es 1.x创建的索引。

## 2、rolling upgrade（节点依次重启策略）
 

rolling upgrade会让es集群每次升级一个node，对于终端用户来说，是没有停机时间的。在一个es集群中运行多个版本，长时间的话是不行的，因为shard是没法从一较新版本的node上replicate到较旧版本的node上的。

先部署一个es 5.3.2版本，将配置文件放在外部目录，同时将data和log目录都放在外部，然后插入一些数据，然后再开始下面的升级过程
```
adduser elasticsearch
passwd elasticsearch
chown -R elasticsearch /usr/local/elasticsearch
chown -R elasticsearch /var/log/elasticsearch
chown -R elasticsearch /var/data/elasticsearch
chown -R elasticsearch /etc/elasticsearch
su elasticsearch

elasticsearch -d -Epath.conf=/etc/elasticsearch
```

向es写入测试数据
```
curl -XPUT 'http://localhost:9200/forum/article/1?pretty' -d '
{
  "title": "first article",
  "content": "this is my first article"
}'
```
 

### （1）禁止shard allocation
 

停止一个node之后，这个node上的shard全都不可用了，此时shard allocation机制会等待一分钟，然后开始shard recovery过程，也就是将丢失掉的primary shard的replica shard提升为primary shard，同时创建更多的replica shard满足副本数量，但是这个过程会导致大量的IO操作，是没有必要的。因此在开始升级一个node，以及关闭这个node之前，先禁止shard allocation机制：

```
curl -XPUT 'http://localhost:9200/_cluster/settings?pretty' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": "none"
  }
}'
```
 

### （2）停止非核心业务的写入操作，以及执行一次flush操作
可以在升级期间继续写入数据，但是如果在升级期间一直写入数据的话，可能会导致重启节点的时候，shard recovery的时间变长，因为很多数据都是translog里面，没有flush到磁盘上去。如果我们暂时停止数据的写入，而且还进行一次flush操作，把数据都刷入磁盘中，这样在node重启的时候，几乎没有什么数据要从translog中恢复的，重启速度会很快，因为shard recovery过程会很快。用下面这行命令执行flush：POST _flush/synced。但是flush操作是尽量执行的，有可能会执行失败，如果有大量的index写入操作的话。所以可能需要多次执行flush，直到它执行成功。
```
curl -XPOST 'http://localhost:9200/_flush/synced?pretty'
```
 

### （3）停止一个node然后升级这个node
在完成node的shard allocation禁用以及flush操作之后，就可以停止这个node。

如果你安装了一些插件，或者是自己设置过jvm.options文件的话，需要先将/usr/local/elasticsearch/plugins拷贝出来，作为一个备份，jvm.options也拷贝出来

将老的es安装目录删除，然后将最新版本的es解压缩，而且要确保我们绝对不会覆盖config、data、log等目录，否则就会导致我们丢失数据、日志、配置文件还有安装好的插件。
```
kill -SIGTERM 15516
```

### （4）升级plugin
可以将备份的plugins目录拷贝回最新解压开来的es安装目录中，包括你的jvm.options

自己去官网，找到各个plugin的git地址，git地址上，都有每个plugin version跟es version之间的对应关系。要检查一下所有的plugin是否跟要升级的es版本是兼容的，如果不兼容，那么需要先用elasticsearch-plugin脚本重新安装最新版本的plugin。


### （5）启动es node
接着要注意在启动es的时候，在命令行里用-Epath.conf= option来指向一个外部已经配置好的config目录。这样的话最新版的es就会复用之前的所有配置了，而且也会根据配置文件中的地址，找到对应的log、data等目录。然后再日志中查看这个node是否正确加入了cluster，也可以通过下面的命令来检查：GET _cat/nodes。
```
elasticsearch -d -Epath.conf=/etc/elasticsearch
```
 
### （6）在node上重新启用shard allocation
一旦node加入了cluster之后，就可以重新启用shard allocation
```
curl -XPUT 'http://localhost:9200/_cluster/settings?pretty' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": "all"
  }
}'
```
 

### （7）等待node完成shard recover过程
我们要等待cluster完成shard allocation过程，可以通过下面的命令查看进度：GET _cat/health。一定要等待cluster的status从yellow变成green才可以。green就意味着所有的primary shard和replica shard都可以用了。
```
curl -XGET 'http://localhost:9200/_cat/health?pretty'
```
在rolling upgrade期间，primary shard如果分配给了一个更新版本的node，是一定不会将其replica复制给较旧的版本的node的，因为较新的版本的数据格式跟较旧的版本是不兼容的。但是如果不允许将replica shard复制给其他node的话，比如说此时集群中只有一个最新版本的node，那么有些replica shard就会是unassgied状态，此时cluster status就会保持为yellow。此时，就可以继续升级其他的node，一旦其他node变成了最新版本，那么就会进行replica shard的复制，然后cluster status会变成green。

如果没有进行过flush操作的shard是需要一些时间去恢复的，因为要从translog中恢复一些数据出来。可以通过下面的命令来查看恢复的进度：`GET _cat/recovery`。

### （8）重复上面的步骤，直到将所有的node都升级完成
