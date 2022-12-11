[logstash手册：](http://doc.yonyoucloud.com/doc/logstash-best-practice-cn/dive_into/write_your_own.html)

[grok表达式：](https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/ecs-v1/grok-patterns)

https://blog.csdn.net/qq_29595629/article/details/114289054

**过滤器插件**
- 过滤器插件对事件执行中间处理，过滤器一般根据事件的特征有条件地应用。

| 插件 | 描述 | Github仓库 |
|------|------|------------|
| aggregate | 聚合来自单个任务的多个事件的信息 | [logstash-filter-aggregate](https://github.com/logstash-plugins/logstash-filter-aggregate) |
| alter | 对mutate过滤器没法处理的字段执行通常更改 | [logstash-filter-alter](https://github.com/logstash-plugins/logstash-filter-alter) |
| cidr | 根据网络块列表检查IP地址 | logstash-filter-cidr |
| cipher | 向事件应用或移除密码 | logstash-filter-cipher |
| clone | 重复事件 | logstash-filter-clone |
| csv | 将逗号分隔的值数据解析为单个字段 | logstash-filter-csv |
| date | 从字段中解析日期，用做事件的Logstash时间戳 | logstash-filter-date |
| de_dot | 从字段名中删除点的高昂计算过滤器 | logstash-filter-de_dot |
| dissect | 使用分隔符将非结构化事件数据提取到字段中 | logstash-filter-dissect |
| dns | 执行标准或反向DNS查找 | logstash-filter-dns |
| drop | 删除全部事件 | logstash-filter-drop |
| elapsed | 计算一对事件之间的通过时间 | logstash-filter-elapsed |
| elasticsearch | 将之前Elasticsearch中的日志事件的字段复制到当前事件 | logstash-filter-elasticsearch |
| environment | 将环境变量存储为元数据子字段 | logstash-filter-environment |
| extractnumbers | 从字符串中提取数字 | logstash-filter-extractnumbers |
| fingerprint | 经过使用一致的哈希替换值的指纹字段 | logstash-filter-fingerprint |
| geoip | 添加关于IP地址的地理信息 | logstash-filter-geoip |
| grok | 将非结构化事件数据解析为字段 | logstash-filter-grok |
| i18n | 从字段中删除特殊字符 | logstash-filter-i18n |
| jdbc_static	 | 用预先从远程数据库加载的数据丰富事件 | logstash-filter-jdbc_static |
| jdbc_streaming | 使用数据库数据丰富事件 | logstash-filter-jdbc_streaming |
| json | 解析JSON事件 | logstash-filter-json |
| json_encode | 将字段序列化为JSON | logstash-filter-json_encode |
| kv | 解析键值对 | logstash-filter-kv |
| metricize | 获取包含多个指标的复琐事件，并将其分解为多个事件，每一个事件都包含一个指标 | logstash-filter-metricize |
| metrics | 聚合指标 | logstash-filter-metrics |
| mutate | 在字段上执行转变 | logstash-filter-mutate |
| prune | 基于要列入黑名单或白名单的字段列表来精简事件数据 | logstash-filter-prune |
| range | 检查指定字段是否保持在给定的大小或长度限制内	 | ogstash-filter-range |
| ruby | 执行任意Ruby代码 | logstash-filter-ruby |
| sleep | 休眠指定的时间跨度 | logstash-filter-sleep |
| split | 将多行消息分解为不一样的事件 | logstash-filter-split |
| syslog_pri | 解析syslog消息的PRI（priority）字段 | logstash-filter-syslog_pri |
| throttle | 限制事件的数量 | logstash-filter-throttle |
| tld | 用你在配置中指定的内容替换默认消息字段的内容 | logstash-filter-tld |
| translate | 基于哈希或YAML文件替换字段内容 | logstash-filter-translate |
| truncate | 截断比给定长度长的字段 | logstash-filter-truncate |
| urldecode | 解码url编码字段 | logstash-filter-urldecode |
| useragent | 将user agent字符串解析为字段 | logstash-filter-useragent |
| uuid | 向事件添加UUID | logstash-filter-uuid |
| xml | 将XML解析为字段 | logstash-filter-xml |
