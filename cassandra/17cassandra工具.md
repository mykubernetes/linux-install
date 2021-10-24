
- cassandra-stress  用于Cassandra的压力测试
- sstableloader 加载 sstable 到集群中
- sstablescrub 删除集群中的冗余数据
- sstablesplit 将大的sstable 分割成小的文件
- sstablekeys 列出sstable中包含的关键字
- sstable2json 以Json形式显示sstable中的内容


# 工具 cassandra-stress


用于压力测试，可以模拟写入和读取

./tools/bin/cassandra-stress help option   # 查看帮助

- -node 指定连接的节点，多个节点逗号隔开
- -port 指定端口，如果修改过端口，那就必须指定
```
./tools/bin/cassandra-stress write n=1000000    # 插入一百万数据

./tools/bin/cassandra-stress read n=200000        # 读取20万行数据

./tools/bin/cassandra-stress read duration=3m # 持续三分钟，一直读取
```


# 工具 sstableloader


用于加载sstable数据

载入大量外部数据至一集群；

将已经存在的SSTable载入到另外一个节点数不同或者复制策略不同的集群；

从快照恢复数据。

直接输入sstableloader会弹出帮助信息


# 工具 sstablescrub


清洗指定的表的SSTable, 试图删除损坏的部分，保留完好的部分。
因为是在节点关闭的状况下可以运行，所以它可以修复nodetool scrub不能修复的问题。

一般出现问题的时候先运行 nodetool scrub

如果第一步没解决问题，使用sstablescrub

关闭节点

运行sstablescrub命令  sstablescrub ks1 student --debug



# 运维工具 — sstablesplit 


运行前必须关闭cassandra服务

sstablesplit -s 40 /var/lib/cassandra/data/Keyspace1/Standard1/*

SizeTieredCompactionStrategy写密集型

LeveledCompactionStrategy 读密集型

DateTieredCompactionStrategy按照时间段压缩




# 运维工具 — sstablekeys 







# 运维工具 — sstable2json  


以JSON的形式显示SSTable文件中的内容


https://developer.aliyun.com/article/715496?spm=a2c6h.12873581.0.0.56e715235VYTNw&groupCode=cassandra
