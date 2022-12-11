### 本文记录的是在两个单机ES服务之间的数据迁移。 

# 索引数据迁移主要步骤
- 1、再旧服务上备份索引数据
- 2、在新服务上恢复索引数据

# 在旧服务上备份索引数据

## 一、查看旧服务上的快照仓库信息

1、获取所有已注册快照仓库，省略仓库名或者使用_all
```
curl -X GET "localhost:9200/_snapshot?pretty"

返回
{
  "elasticsearch_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/usr/local/elasticsearch_backup"
    }
  }
}
```

2、查看仓库中所有快照信息
```
curl -X GET "localhost:9200/_snapshot/elasticsearch_backup/_all?pretty"

返回
{
  "snapshots" : [ ]
}
```

## 二、创建最新快照备份

1、创建新快照前，先执行以下命令，确保缓存中的索引落到磁盘中：
```
curl -X POST "localhost:9200/_flush?pretty"

返回
{
  "_shards" : {
    "total" : 270,
    "successful" : 135,
    "failed" : 0
  }
}
```

2、创建快照
```
curl -X PUT "localhost:9200/_snapshot/elasticsearch_backup/snapshot-2018.09.26-01?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "ignore_unavailable": true,  
  "include_global_state": false
}                              
'

上面命令返回
{
    "snapshot":{
        "snapshot":"snapshot-2018.09.26-01",
        "uuid":"Gs4xr5ErSE22sGcSlfpXAQ",
        "version_id":5020299,
        "version":"5.2.2",
        "indices":[
            "60cbd2e0f2c4410eaa7cde7f0f735487",
           .......
            "e39555dec34c4492a6a6ece0daadac19",
            "11d66120782e4583976d5bc235c29d29",
            "27cffb9f205b49b7aa48c6011c5fe1e4"
        ],
        "state":"SUCCESS",
        "start_time":"2018-09-26T03:24:42.052Z",
        "start_time_in_millis":1537932282052,
        "end_time":"2018-09-26T03:24:55.397Z",
        "end_time_in_millis":1537932295397,
        "duration_in_millis":13345,
        "failures":[

        ],
        "shards":{
            "total":135,
            "failed":0,
            "successful":135
        }
    }
}
```
- 设值选项 ignore_unavailable=true，快照过程中会忽略不存在的索引，默认没有设值，遇到不存在的索引，快照过程将失败。设值 include_global_state 为 false，可以阻止集群全局状态信息被保存为快照的一部分。默认情况下，如果如果一个快照中的一个或者多个索引没有所有主分片可用，整个快照创建会失败，该情况可以通过设置 partial 为 true 来改变。


3、查看备份状态
```
curl -X GET "localhost:9200/_snapshot/elasticsearch_backup/snapshot-2018.09.26-01/_status?pretty"
```

## 三、在新服务上重复在就服务上创建仓库的操作

1、创建仓库
```
curl -X PUT "192.168.0.106:9200/_snapshot/my_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/local/elasticsearch_backup_location"
  }
}
'

返回错误
{
  "error" : {
    "root_cause" : [
      {
        "type" : "repository_exception",
        "reason" : "[my_backup] location [/usr/local/elasticsearch_backup_location] doesn't match any of the locations specified by path.repo because this setting is empty"
      }
    ],
    "type" : "repository_exception",
    "reason" : "[my_backup] failed to create repository",
    "caused_by" : {
      "type" : "repository_exception",
      "reason" : "[my_backup] location [/usr/local/elasticsearch_backup_location] doesn't match any of the locations specified by path.repo because this setting is empty"
    }
  },
  "status" : 500
}
```

2、在新ES配置文件 elasticsearch.yml 上添加 path.repo 配置
```
path.repo: /usr/local/elasticsearch_backup_location
```

2.1、重启ES服务，报错
```
[2018-09-26T14:49:49,092][WARN ][o.e.b.ElasticsearchUncaughtExceptionHandler] [] uncaught exception in thread [main]
org.elasticsearch.bootstrap.StartupException: java.lang.IllegalStateException: Unable to access 'path.repo' (/usr/local/elasticsearch_backup_location)
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:125) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:112) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.cli.SettingCommand.execute(SettingCommand.java:54) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:122) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.cli.Command.main(Command.java:88) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:89) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:82) ~[elasticsearch-5.2.2.jar:5.2.2]
Caused by: java.lang.IllegalStateException: Unable to access 'path.repo' (/usr/local/elasticsearch_backup_location)
	at org.elasticsearch.bootstrap.Security.addPath(Security.java:379) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Security.addFilePermissions(Security.java:267) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Security.createPermissions(Security.java:215) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Security.configure(Security.java:121) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:236) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:333) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:121) ~[elasticsearch-5.2.2.jar:5.2.2]
	... 6 more
Caused by: java.nio.file.AccessDeniedException: /usr/local/elasticsearch_backup_location
	at sun.nio.fs.UnixException.translateToIOException(UnixException.java:84) ~[?:1.8.0_121]
	at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:102) ~[?:1.8.0_121]
	at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:107) ~[?:1.8.0_121]
	at sun.nio.fs.UnixFileSystemProvider.createDirectory(UnixFileSystemProvider.java:384) ~[?:1.8.0_121]
	at java.nio.file.Files.createDirectory(Files.java:674) ~[?:1.8.0_121]
	at java.nio.file.Files.createAndCheckIsDirectory(Files.java:781) ~[?:1.8.0_121]
	at java.nio.file.Files.createDirectories(Files.java:767) ~[?:1.8.0_121]
	at org.elasticsearch.bootstrap.Security.ensureDirectoryExists(Security.java:421) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Security.addPath(Security.java:377) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Security.addFilePermissions(Security.java:267) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Security.createPermissions(Security.java:215) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Security.configure(Security.java:121) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:236) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:333) ~[elasticsearch-5.2.2.jar:5.2.2]
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:121) ~[elasticsearch-5.2.2.jar:5.2.2]
	... 6 more
```

3、创建目录 /usr/local/elasticsearch_backup_location，修改权限
```
# chmod -R go+w /usr/local/elasticsearch_backup_location

# ls -l
drwxrwxrwx   2 root       root               6 9月  26 14:53 elasticsearch_backup_location
```


4、ES重启成功，再次执行创建仓库操作
```
curl -X PUT "192.168.0.106:9200/_snapshot/my_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/local/elasticsearch_backup_location"
  }
}
'
`

返回成功
{
  "acknowledged" : true
}
```

5、查看创建仓库
```
curl -X GET "192.168.0.106:9200/_snapshot/my_backup?pretty"

返回
{
  "my_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/usr/local/elasticsearch_backup_location"
    }
  }
}
```


## 四、将旧服务上的快照备份拷贝到新服务仓库目录下

将旧服务快照备份文件压缩拷贝到新服务仓库目录下解压，然后可以查看快照内容
```
# 压缩
tar -zcf index.src.tar.gz ./*

# 解压缩
tar -zxf index.src.tar.gz

# 查看快照
curl -X GET "192.168.0.106:9200/_snapshot/my_backup/_all?pretty"
```


## 五、在新服务上执行快照备份恢复
```
curl -X POST "192.168.0.106:9200/_snapshot/my_backup/snapshot-2018.09.26-01/_restore?pretty"

返回
{
  "accepted" : true
}
```
- 查看索引列表和数据目录，均显示恢复最新数据

## 参考

自动备份并压缩脚本
```
#!/bin/bash
filename=`date +%Y%m%d%H`
backesFile=es$filename.tar.gz
cd /home/elasticsearch/back
mkdir es_dump
cd es_dump
curl -X DELETE "10.17.4.200:9200/_snapshot/backup/$filename?pretty"
echo 'sleep 30'
sleep 30
curl -X PUT "10.17.4.200:9200/_snapshot/backup/$filename?wait_for_completion=true&pretty"
echo 'sleep 30'
sleep 30
cp /home/elasticsearch/snapshot/* /home/elasticsearch/back/es_dump -rf
cd ..
tar czf $backesFile  es_dump/
rm es_dump -rf
```

自动解压缩并恢复脚本
```
#!/bin/bash
filename='2018092609'
backesFile=es$filename.tar.gz
cd /home/elasticsearch/back
tar zxvf $backesFile
rm /home/elasticsearch/snapshot/* -rf
cp /home/elasticsearch/back/es_dump/* /home/elasticsearch/snapshot -rf
curl -X POST "10.17.4.200:9200/users/_close"
curl -X POST "10.17.4.200:9200/products/_close"
echo 'sleep 5'
sleep 5
curl -X POST "10.17.4.200:9200/_snapshot/backup/$filename/_restore?pretty" -d '{
    "indices":"users"
}' 
echo 'sleep 5'
sleep 5
curl -X POST "10.17.4.200:9200/_snapshot/backup/$filename/_restore?pretty" -d '{
    "indices":"products"
}'
echo 'sleep 5'
sleep 5
curl -X POST "10.17.4.200:9200/users/_open"
curl -X POST "10.17.4.200:9200/products/_open" 
rm es_dump -rf 
```
