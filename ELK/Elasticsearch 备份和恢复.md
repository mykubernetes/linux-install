# 快照

备份数据之前，要创建一个仓库来保存数据，仓库的类型支持共享文件系统、Amazon S3、 HDFS和Azure Cloud。 

 
# 一、创建存储仓库

- 在进行任何快照或者恢复操作之前必须有一个快照仓库注册在Elasticsearch里。

### 共享文件系统的仓库

共享文件系统仓库 ("type": "fs") 是使用共享的文件系统去存储快照。 在 location 参数里指定的具体存储路径必须和共享文件系统里的位置是一样的并且能被所有的数据节点和master节点访问。 另外还支持如下的一些参数设置：

| 参数 | 描述 |
|-----|-------|
| location | 指定快照的存储位置。必须要有 |
| compress | 指定是否对快照文件进行压缩. 默认是 true. |
| chunk_size | 如果需要在做快照的时候大文件可以被分解成几块。这个参数指明了每块的字节数。也可用不同的单位标识。 比如，1g，10m，5k等。默认是 null (表示不限制块大小)。 |
| max_restore_bytes_per_sec | 每个节点恢复数据的最高速度限制. 默认是 20mb/s |
| max_snapshot_bytes_per_sec | 每个节点做快照的最高速度限制。默认是 20mb/s |

### 只读URL仓库

URL仓库("type": "url")可以作为使用共享文件系统存储快照创建的共享文件系统仓库的只读访问方式。 url 参数指定的URL必须指向共享文件系统仓库的根。支持的配置方式如下：

| 参数 | 描述 |
|-----|-------|
| url | 指定快照位置。必须要有 |

1、修改ES配置文件
```
vi config/elasticsearch.yml
path.repo: ["/mount/EsDataBackupDir"]        #添加仓库路径
```

2、共享文件系统实例如下：
```
curl -XPUT http://127.0.0.1:9200/_snapshot/EsBackup
{
    "type": "fs", 
    "settings": {
        "location": "/mount/EsDataBackupDir" 
    }
}
```
- 创建了一个名为EsBackup的存仓库
- 指定的备份方式为共享文件系统(type: fs)
- 指定共享存储的具体路径（location参数）

注意：共享存储路径，必须是所有的ES节点都可以访问的，最简单的就是nfs系统，然后每个节点都需要挂载到本地。
 
3、一旦仓库被注册了，就可以只用下面的命令去获取这个仓库的信息
```
curl -XGET 'http://localhost:9200/_snapshot/EsBackup?pretty'
{
  "my_backup" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/mount/EsDataBackupDir"
    }
  }
}
```

4、查看所有的存储桶
```
curl -XGET localhost:9200/_snapshot
或者
curl -XGET localhost:9200/_snapshot/_all?pretty
```

5、更新已经存在的存储库的settings配置。 
```
curl -XPOST http://127.0.0.1:9200/_snapshot/EsBackup
{
    "type": "fs", 
    "settings": {
        "location": "/mount/EsDataBackupDir" 
        "max_snapshot_bytes_per_sec" : "50mb", 
        "max_restore_bytes_per_sec" : "50mb"
    }
}
```
- max_snapshot_bytes_per_sec 指定备份时的速度，默认值都是20mb/s
- max_restore_bytes_per_sec 指定恢复时的速度，默认值都是20mb/s


6、Amazon S3存储库实例如下：
```
curl -XPUT 'http://localhost:9200/_snapshot/s3-backup' -d '{
    "type": "s3",
    "settings": {
        "bucket": "esbackup",
        "region": "cn-north-1",
        "access_key": "xxooxxooxxoo",
        "secret_key": "xxxxxxxxxooooooooooooyyyyyyyyy"
    }
}'
```
- Type: 仓库类型
- Setting: 仓库的额外信息
- Region: AWS Region
- Access_key: 访问秘钥
- Secret_key: 私有访问秘钥
- Bucket: 存储桶名称

不同的ES版本支持的region参考：https://github.com/elastic/elasticsearch-cloud-aws#aws-cloud-plugin-for-elasticsearch  
使用上面的命令，创建一个仓库（s3-backup），并且还创建了存储桶（esbackup）,返回{"acknowledged":true} 信息证明创建成功。




### 删除一个快照存储桶
```
curl -XDELETE localhost:9200/_snapshot/EsBackup?pretty
```

### 查看快照仓库列表
```
# curl -X GET "10.17.4.200:9200/_cat/repositories?v"
id                   type
elasticsearch_backup   fs
test                   fs
```

# 二、备份索引

- 一个仓库可以包含多个快照（snapshots），快照可以存所有的索引或者部分索引，当然也可以存储一个单独的索引。(要注意的一点就是快照只会备份open状态的索引，close状态的不会备份)


1、备份所有索引

将所有正在运行的open状态的索引，备份到EsBacup仓库下一个叫snapshot_all的快照中。
```
# api会立刻返回{"accepted":true}，然后备份工作在后台运行
curl -XPUT http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_all

api同步执行，可以加wait_for_completion,备份完全完成后才返回，如果快照数据量大的话，会花很长时间。
curl -XPUT http://127.0.0.1:9200/_snapshot/EsBackup/snapshot_all?wait_for_completion=true
```


2、备份部分索引

默认是备份所有open状态的索引，如果只备份某些或者某个索引，可以指定indices参数来完成：
```
curl -XPUT 'http://localhost:9200/_snapshot/EsBackup/snapshot_12' -d '{ "indices": "index_1,index_2" }'
```

三、查看快照信息
---
查看快照snapshot_2的详细信息：
```
curl -XGET http://127.0.0.1:9200/_snapshot/my_backup/snapshot_2

{
   "snapshots": [
      {
         "snapshot": "snapshot_2",
         "indices": [
            ".marvel_2014_28_10",
            "index1",
            "index2"
         ],
         "state": "SUCCESS",
         "start_time": "2014-09-02T13:01:43.115Z",
         "start_time_in_millis": 1409662903115,
         "end_time": "2014-09-02T13:01:43.439Z",
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

```
# 查看所有快照信息如下
curl -XGET http://127.0.0.1:9200/_snapshot/my_backup/_all

# 查看更加详细的信息
curl -XGET http://127.0.0.1:9200/_snapshot/my_backup/snapshot_2/_status
```
 
四、删除快照
---
```
curl -XDELETE http://127.0.0.1:9200/_snapshot/my_backup/snapshot_2
```
重要的是使用API来删除快照,而不是其他一些机制(如手工删除,或使用自动s3清理工具)。因为快照增量,它是可能的,许多快照依靠old seaments。删除API了解最近仍在使用的数据快照,并将只删除未使用的部分。如果你手动文件删除,但是,你有可能严重破坏你的备份,因为你删除数据仍在使用,如果备份正在后台进行，也可以直接删除来取消此次备份。
 

五、监控快照进展
---
 
查看更细节的状态的快照
```
curl -XGET http://127.0.0.1:9200/_snapshot/my_backup/snapshot_3
```
 
API立即返回并给出一个更详细的输出的统计
```
curl -XGET http://127.0.0.1:9200/_snapshot/my_backup/snapshot_3/_status
{
   "snapshots": [
      {
         "snapshot": "snapshot_3",
         "repository": "my_backup",
         "state": "IN_PROGRESS", 
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
快照当前运行将显示IN_PROGRESS作为其状态，这个特定的快照有一个碎片仍然转移(其他四个已经完成)。
 
响应包括总体状况的快照,但还深入每和每个实例统计数据。
- INITIALIZING： 集群的碎片是检查状态是否可以快照。这通常是非常快。
- STARTED：数据被转移到存储库。
- FINALIZING：数据传输完成;碎片现在发送快照的元数据。
- DONE：快照完成。
- FAILED：在快照过程中错误的出处,这碎片/索引/快照无法完成。检查你的日志以获取更多信息。
 

六、恢复
---
恢复snapshot_1里的全部索引
```
curl -XPOST http://127.0.0.1:9200/_snapshot/my_backup/snapshot_1/_restore
```

带参数恢复
```
curl -XPOST http://127.0.0.1:9200/_snapshot/my_backup/snapshot_1/_restore
{
    "indices": "index_1", 
    "rename_pattern": "index_(.+)", 
    "rename_replacement": "restored_index_$1" 
}
```
- indices 设置只恢复index_1索引
- rename_pattern 和rename_replacement用来正则匹配要恢复的索引，并且重命名

 
可以使用下面两个api查看状态：
```
curl -XGET http://127.0.0.1:9200/_recovery/restored_index_3
curl -XGET http://127.0.0.1:9200/_recovery/
```

如果要取消恢复过程（不管是已经恢复完，还是正在恢复），直接删除索引即可：
```
curl -XDELETE http://127.0.0.1:9200/restored_index_3
```

七、备份数据要在新集群恢复
---

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
