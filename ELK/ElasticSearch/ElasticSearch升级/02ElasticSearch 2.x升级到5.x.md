es只能使用上一个大版本创建的索引。举例来说，es 5.x可以使用es 2.x中的索引，但是不能使用es 1.x中的索引。

es 5.x如果使用过于陈旧的索引去启动，就会启动失败

如果我们在运行es 2.x集群，但是索引是从2.x之前的版本创建的，那么在升级到es 5.x之前，我们需要删除旧索引，或者reindex这些索引，用reindex in place的策略。

如果我们在运行es 1.x的集群，有两个选择，首先升级到es 2.4.x，然后reindex所有的旧索引，用reindex in place的策略，接着升级到es 5.x。创建一个新的5.x集群，然后使用reindex-from-remote直接从es 1.x集群中将索引倒入5.x集群中。

同时运行一个es 1.x的集群，同时也运行一个es 5.x的集群，然后用reindex功能，将es 1.x中的所有数据都导入到es 5.x集群中

```
elasticsearch -d -Dpath.conf=/etc/elasticsearch
kill -SIGTERM 15516
chown -R elasticsearch /usr/local/elasticsearch-1.7.4
chown -R elasticsearch /usr/local/elasticsearch-5.5.0

curl -XPUT 'http://localhost:9200/forum/article/1?pretty' -d '
{
  "title": "first article",
  "content": "this is my first article"
}'
```

#（1）reindex in place
 
将1.x中的索引reindex最简单的方法，就是用elasticsearch migration plugin去做reindex。但是首先需要先升级到es 2.3.x或2.4.x。

migration plugin中提供的reindex工具会执行以下操作：

创建新的索引，但是会将es版本号拼接到索引名称上，比如my_index-2.4.1，从旧的索引中拷贝mapping和setting。禁止新索引的refresh，并且将replica数量设置为0.主要是为了更高效的reindex。

将旧索引设置为只读，不允许新的数据写入旧索引中

从旧索引中，将所有的数据reindex到新索引中

对新索引的refresh_interval和number_of_replicas的值重新设置为旧索引中的值，并且等待索引变成green

将旧索引中存在的alias添加到新索引中

删除旧的索引

给新索引添加一个alia，使用旧索引的名称，比如将my_index设置为my_index-2.4.1的alia

此时，就可以有一份新的2.x的索引，可以在5.x中使用


（2）upgrading with reindex-from-remote

如果在运行1.x cluster，并且想要直接迁移到5.x，而不是先迁移到2.x，那么需要进行reindex-from-remote操作

es包含了向后兼容性的代码，从而允许上一个大版本的索引可以直接在这个版本中使用。如果要直接从1.x升级到5.x，我们就需要自己解决向后兼容性的问题。

首先我们需要先建立一个新的5.x的集群。5.x集群需要能够访问1.x集群的rest api接口。

对于每个我们想要迁移到5.x集群的1.x的索引，需要做下面这些事情：

在5.x中创建新的索引，以及使用合适的mapping和setting，将refresh_interval设置为-1，并且设置number_of_replica为0，主要是为了更快的reindex。

用reindex from remote的方式，在两个集群之间迁移index数据
```
curl -XPOST 'http://localhost:9201/_reindex?pretty' -d '
{
  "source": {
    "remote": {
      "host": "http://localhost:9200"
    },
    "index": "forum"
  },
  "dest": {
    "index": "forum"
  }
}'
```

remote cluster必须显示在elasticsearch.yml中列入白名单中，使用reindex.remote.whitelist属性

reinde过程中会使用的默认的on-heap buffer最大大小是100mb，如果要迁移的数据量很大，需要将batch size设置的很小，这样每次同步的数据就很少，使用size参数。还可以设置socket_timeout和connect_timeout，比如下面：
```
POST _reindex
{
  "source": {
    "remote": {
      "host": "http://otherhost:9200",
      "socket_timeout": "1m",
      "connect_timeout": "10s"
    },
    "index": "source",
    "size": 10,
    "query": {
      "match": {
        "test": "data"
      }
    }
  },
  "dest": {
    "index": "dest"
  }
}
```

如果在后台运行reindex job，就是将wait_for_completion设置为false，那么reindex请求会返回一个task_id，后面可以用来监控这个reindex progress的进度，GET _tasks/TASK_ID

一旦reindex完成之后，可以将refresh_interval和number_of_replicas设置为正常的数值，比如30s和1

一旦新的索引完成了replica操作，就可以删除旧的index了
