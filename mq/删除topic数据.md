# 删除topic数据:

如果想保留主题，只删除主题现有数据（log）。可以通过修改数据保留时间实现
``` 
bin/kafka-configs --zookeeper localhost:2181 --entity-type topics --entity-name test --alter --add-config retention.ms=3000
```
修改保留时间为三秒，但不是修改后三秒就马上删掉，kafka是采用轮训的方式，轮训到这个主题发现三秒前的数据都是删掉。时间由自己在server.properties里面设置，设置见下面。


数据删除后，继续使用主题，那主题数据的保留时间就不可能为三秒，所以把上面修改的配置删掉，采用server.properties里面统一的配置。
```
bin/kafka-configs --zookeeper localhost:2181 --entity-type topics --entity-name test --alter --delete-config retention.ms
```

server.properties里面数据保留时间的配置
```
log.retention.hours=168 //保留时间，单位小时
log.retention.check.interval.ms=300000 //保留时间检查间隔，单位毫秒
```

https://segmentfault.com/a/1190000016106045#item-4
