# 快照

备份数据之前，要创建一个仓库来保存数据，仓库的类型支持共享文件系统、Amazon S3、 HDFS和Azure Cloud。 

### 共享文件系统的仓库

- 共享文件系统仓库 ("type": "fs") 是使用共享的文件系统去存储快照。 在 location 参数里指定的具体存储路径必须和共享文件系统里的位置是一样的并且能被所有的数据节点和master节点访问。 另外还支持如下的一些参数设置：

| 参数 | 描述 |
|-----|-------|
| location | 指定快照的存储位置。必须要有 |
| compress | 指定是否对快照文件进行压缩. 默认是 true. |
| chunk_size | 如果需要在做快照的时候大文件可以被分解成几块。这个参数指明了每块的字节数。也可用不同的单位标识。 比如，1g，10m，5k等。默认是 null (表示不限制块大小)。 |
| max_restore_bytes_per_sec | 每个节点恢复数据的最高速度限制. 默认是 20mb/s |
| max_snapshot_bytes_per_sec | 每个节点做快照的最高速度限制。默认是 20mb/s |


### 只读URL仓库

- URL仓库("type": "url")可以作为使用共享文件系统存储快照创建的共享文件系统仓库的只读访问方式。 url 参数指定的URL必须指向共享文件系统仓库的根。支持的配置方式如下：

| 参数 | 描述 |
|-----|-------|
| url | 指定快照位置。必须要有 |

# 一、创建存储仓库

- 在进行任何快照或者恢复操作之前必须有一个快照仓库注册在Elasticsearch里。

1.创建仓库目录并授权
```
# mkdir -p /mount/EsDataBackupDir
# chmod -R 755 /mount/EsDataBackupDir
```

2、修改ES配置文件
```
# vim config/elasticsearch.yml
path.repo: ["/mount/EsDataBackupDir"]        #添加仓库路径
```

3、注册快照仓库（注册仓库用PUT，更新仓库用POST）
```
# curl -XPUT -uelastic:elastic -H "Content-Type: application/json" http://127.0.0.1:9200/_snapshot/EsBackup
{
    "type": "fs", 
    "settings": {
        "location": "/mount/EsDataBackupDir",
        "max_snapshot_bytes_per_sec" : "50mb",
        "max_restore_bytes_per_sec" : "50mb",
        "compress" : true           
    }
}
```
注意：共享存储路径，必须是所有的ES节点都可以访问的，最简单的就是nfs系统，然后每个节点都需要挂载到本地。
 
4、如果指定的是相对路径，则根据配置文件中的`path.repo`路径位置
```
# curl -XPUT -uelastic:elastic -H "Content-Type: application/json" http://127.0.0.1:9200/_snapshot/EsBackup
{
    "type": "fs", 
    "settings": {
        "location": "EsDataBackupDir" 
    }
}
```

5、查看所有的快照仓库
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 127.0.0.1:9200/_snapshot
或者
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 127.0.0.1:9200/_snapshot/_all?pretty
```

6、查看仓库的信息
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://localhost:9200/_snapshot/EsBackup?pretty'

# 返回
{
  "EsBackup" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/mount/EsDataBackupDir"
    }
  }
}
```

7、更新已经存在的存储库的settings配置。 
```
# curl -XPOST -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup'
{
    "type": "fs", 
    "settings": {
        "location": "/mount/EsDataBackupDir" 
        "max_snapshot_bytes_per_sec" : "30mb", 
        "max_restore_bytes_per_sec" : "30mb"
    }
}
```
- max_snapshot_bytes_per_sec 指定备份时的速度，默认值都是20mb/s
- max_restore_bytes_per_sec 指定恢复时的速度，默认值都是20mb/s

8、查看快照仓库列表
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_cat/repositories?v'
id                   type
elasticsearch_backup   fs
EsBackup               fs
```

9、删除一个快照仓库
```
curl -XDELETE -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup?pretty'
```

# 二、备份索引

- 一个仓库可以包含多个快照（snapshots），快照可以存所有的索引或者部分索引，当然也可以存储一个单独的索引。(要注意的一点就是快照只会备份open状态的索引，close状态的不会备份)

1、备份所有索引

将所有正在运行的open状态的索引，备份到EsBacup仓库下一个叫snapshot_all的快照中。
```
# api会立刻返回{"accepted":true}，然后备份工作在后台运行
curl -XPUT -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115'

# api同步执行，可以加wait_for_completion,备份完全完成后才返回，如果快照数据量大的话，会花很长时间。
curl -XPUT -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115?wait_for_completion=true'
```

2、备份部分索引

默认是备份所有open状态的索引，如果只备份某些或者某个索引，可以指定indices参数来完成：
```
curl -XPUT -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211116' -d '
{
  "indices": "index_1,index_2"
}'
```

# 三、查看快照状态

1、获取当前正在运行的快照及其详细状态信息的列表
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/_status'
```

2、获取指定仓库正在运行的快照的信息
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/_status'
```

3、如果仓库名字和快照id都指明了，这个命令就会返回这个快照的详细信息，甚至这个快照不是正在运行。
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115/_status'
```

4、同样支持多个快照id：
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115,snapshot_20211116/_status'
```

5、查看所有快照信息如下
```
# curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/_all'
```

6、删除快照
```
# curl -XDELETE -uelastic:elastic -H "Content-Type: application/json" 'http://localhost:9200/_snapshot/EsBackup/snapshot_20211116'
```

7、查看所有快照
```
# curl -XDELETE -uelastic:elastic -H "Content-Type: application/json" 'http://localhost:9200/_snapshot/EsBackup/_all
{
  "snapshots": [
    {
      "snapshot": "snapshot_20211115",
      "uuid": "n7YxxxxxxxxxxxxdA",
      "version_id": 5050399,
      "version": "5.5.3",
      "indices": [
        ".kibana"
      ],
      "state": "SUCCESS",
      "start_time": "2021-11-15T01:22:39.609Z",
      "start_time_in_millis": 1530148959609,
      "end_time": "2021-11-15T01:22:39.923Z",
      "end_time_in_millis": 1530148959923,
      "duration_in_millis": 314,
      "failures": [],
      "shards": {
        "total": 1,
        "failed": 0,
        "successful": 1
      }
    },
    {
      "snapshot": "snapshot_20211116",
      "uuid": "frdxxxxxxxxxxxxKLA",
      "version_id": 5050399,
      "version": "5.5.3",
      "indices": [
        ".kibana"
      ],
      "state": "SUCCESS",
      "start_time": "2021-11-16T01:25:00.764Z",
      "start_time_in_millis": 1530149100764,
      "end_time": "2021-11-16T01:25:01.482Z",
      "end_time_in_millis": 1530149101482,
      "duration_in_millis": 718,
      "failures": [],
      "shards": {
        "total": 1,
        "failed": 0,
        "successful": 1
      }
    }
  ]
}
```
- state：快照状态

| 快照状态 | 说明 |
|--------|------|
| IN_PROGRESS | 快照正在执行。 |
| SUCCESS | 快照执行结束，且所有shard中的数据都存储成功。 |
| FAILED | 快照执行结束，但部分索引中的数据存储不成功。 |
| PARTIAL | 部分数据存储成功，但至少有1个shard中的数据没有存储成功。 |
| INCOMPATIBLE | 快照与阿里云ES实例的版本不兼容。 |


8、查看指定快照详细信息
```
curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115'

{
   "snapshots": [
      {
         "snapshot": "snapshot_20211115",
         "indices": [
            ".marvel_2014_28_10",
            "index1",
            "index2"
         ],
         "state": "SUCCESS",
         "start_time": "2021-11-15T13:01:43.115Z",
         "start_time_in_millis": 1409662903115,
         "end_time": "2021-11-15T13:01:43.439Z",
         "end_time_in_millis": 1409662903439,
         "duration_in_millis": 324,
         "failures": [],
         "shards": {
            "total": 10,
            "failed": 0,
            "successful": 10
         }
      }
   ]
}
```

9、查看更加详细的信息
```
curl -XGET http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115/_status
{
   "snapshots": [
      {
         "snapshot": "snapshot_20211115",
         "repository": "EsBackup",
         "state": "SUCCESS", 
         "shards_stats": {
            "initializing": 0,
            "started": 1, 
            "finalizing": 0,
            "done": 4,
            "failed": 0,
            "total": 5
         },
         "stats": {
            "number_of_files": 5,
            "processed_files": 5,
            "total_size_in_bytes": 1792,
            "processed_size_in_bytes": 1792,
            "start_time_in_millis": 1409663054859,
            "time_in_millis": 64
         },
         "indices": {
            "index_3": {
               "shards_stats": {
                  "initializing": 0,
                  "started": 0,
                  "finalizing": 0,
                  "done": 5,
                  "failed": 0,
                  "total": 5
               },
               "stats": {
                  "number_of_files": 5,
                  "processed_files": 5,
                  "total_size_in_bytes": 1792,
                  "processed_size_in_bytes": 1792,
                  "start_time_in_millis": 1409663054859,
                  "time_in_millis": 64
               },
               "shards": {
                  "0": {
                     "stage": "DONE",
                     "stats": {
                        "number_of_files": 1,
                        "processed_files": 1,
                        "total_size_in_bytes": 514,
                        "processed_size_in_bytes": 514,
                        "start_time_in_millis": 1409663054862,
                        "time_in_millis": 22
                     }
                  },
                  ...
```


# 四、恢复快照

1、恢复snapshot_20211115里的全部索引
```
curl -XPOST -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115/_restore'
```

2、恢复指定索引的快照
```
curl -XPOST -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115/_restore'
{
  "indices": "index_1,index_2", 
  "ignore_unavailable": true,
  "rename_pattern": "index_(.+)", 
  "rename_replacement": "restored_index_$1" 
}
```
- indices 设置只恢复index_1索引
- rename_pattern和rename_replacement用来正则匹配要恢复的索引，并且重命名

 
# 五、查看快照恢复状态
```
curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_recovery/snapshot_20211115'

curl -XGET -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_recovery/'
{
  "snapshot_20211115" : {
    "shards" : [ {
      "id" : 0,
      "type" : "snapshot",                            #type
      "stage" : "index",
      "primary" : true,
      "start_time" : "2014-02-24T12:15:59.716",
      "stop_time" : 0,
      "total_time_in_millis" : 175576,
      "source" : {                                    #source
        "repository" : "my_backup",
        "snapshot" : "snapshot_3",
        "index" : "restored_index_3"
      },
      "target" : {
        "id" : "ryqJ5lO5S4-lSFbGntkEkg",
        "hostname" : "my.fqdn",
        "ip" : "10.0.1.7",
        "name" : "my_es_node"
      },
      "index" : {
        "files" : {
          "total" : 73,
          "reused" : 0,
          "recovered" : 69,
          "percent" : "94.5%"                          #percent
        },
        "bytes" : {
          "total" : 79063092,
          "reused" : 0,
          "recovered" : 68891939,
          "percent" : "87.1%"
        },
        "total_time_in_millis" : 0
      },
      "translog" : {
        "recovered" : 0,
        "total_time_in_millis" : 0
      },
      "start" : {
        "check_index_time" : 0,
        "total_time_in_millis" : 0
      }
    } ]
  }
}
```
- type 字段告诉你恢复的本质；这个分片是在从一个快照恢复。
- source 哈希描述了作为恢复来源的特定快照和仓库。
- percent 字段让你对恢复的状态有个概念。这个特定分片目前已经恢复了 94% 的文件；它就快完成了。


如果要取消恢复过程（不管是已经恢复完，还是正在恢复），直接删除索引即可：
```
curl -XDELETE -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/restored_index_3'
```

# 六、删除快照
```
curl -XDELETE -uelastic:elastic -H "Content-Type: application/json" 'http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_20211115'
```
重要的是使用API来删除快照,而不是其他一些机制(如手工删除,或使用自动s3清理工具)。因为快照增量,它是可能的,许多快照依靠old seaments。删除API了解最近仍在使用的数据快照,并将只删除未使用的部分。如果你手动文件删除,但是,你有可能严重破坏你的备份,因为你删除数据仍在使用,如果备份正在后台进行，也可以直接删除来取消此次备份。
 

# 七、备份数据要在新集群恢复

1、需要先在新集群创建相同结构的index及type，并创建快照仓储
```
curl -X POST \
  http://192.168.0.39:9200/yuqing \
  -d '{
    "settings":{
        "number_of_shards":5,
        "number_of_replicas":1
    },
    "mappings":{
        "article":{
            "dynamic":"strict",
            "properties":{
                "title":{"type":"string","store":"yes","index":"analyzed","analyzer": "ik_max_word","search_analyzer": "ik_max_word"},
                "types":{"type":"string","store":"yes","index":"analyzed","analyzer": "ik_max_word","search_analyzer": "ik_max_word"},
                "url":{"type":"string","store":"no","index":"no"}
            }
        }
    }
}'
```

2、需要先关闭index，否则会出现问题【cannot restore index [myindex] because it's open】
```
curl -X POST  http://192.168.0.38:9200/yuqing/_close
```

3、恢复数据（去掉参数即可恢复所有索引，否则恢复指定索引 myindex）
```
curl -X POST http://192.168.0.38:9200/_snapshot/mybackup/snapshot_1/_restore \
-d '{
    "indices": "myindex"
}'

#查看恢复进度
curl -X GET http://192.168.0.38:9200/yuqing/_recovery

#取消恢复(索引yuqing正在被恢复)
curl -X DELETE http://192.168.0.38:9200/yuqing
```
  

4、重新开启index
```
curl -X POST  http://192.168.0.38:9200/yuqing/_open

# 查看看到备份的数据
curl -X GET   http://192.168.0.38:9200/yuqing/article/_search
```


参考:
- https://www.elastic.co/guide/en/elasticsearch/reference/6.8/modules-snapshots.html#_snapshot
- https://blog.51cto.com/niubdada/1959065
