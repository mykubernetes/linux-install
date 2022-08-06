kafka 单独设置某个topic的数据过期时间

kafka 默认存放7天的临时数据，如果遇到磁盘空间小，存放数据量大，可以设置缩短这个时间。

1、全局设置，修改配置文件server.properties
```
log.retention.hours=72
log.cleanup.policy=delete
```

2、单独对某一个topic设置过期时间

如果你这样设置完，可以磁盘空间还是不够，或只有某一个topic数据量过大。想单独对这个topic的过期时间设置短点。
```
# ./kafka-configs.sh --zookeeper localhost:2181 --alter --entity-name wordcounttopic --entity-type topics --add-config retention.ms=86400000
```
- retention.ms=86400000 为一天，单位是毫秒。

3、查看设置
```
# ./kafka-configs.sh --zookeeper localhost:2181 --describe --entity-name wordcounttopic --entity-type topics
Configs for topics:wordcounttopic are retention.ms=86400000
```

4、如果没有立刻删除的话你可以设置下面参数。
```
# ./kafka-topics.sh --zookeeper localhost:2181 --alter --topic wordcounttopic --config cleanup.policy=delete
```
