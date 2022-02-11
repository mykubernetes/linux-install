# 一、简介

[Skywalking官网](https://skywalking.apache.org/)

Skywalking用于分布式系统的应用程序性能监视工具，特别为微服务、云本机和基于容器(Docker, K8s, Mesos)架构设计。

# 二、常见的链路追踪

- 1、CAT： 由国内美团点评开源的，基于java语言开发，目前提供java、C/C++、Node.js、Python、Go等语言的客户端，监控数据会全量统计，国内很多公司在用，例如美团点评、携程、拼多多等，CAT需要开发人员手动在应用程序中埋点，对代码侵入性比较强。
- 2、Zipking：由Twitter公司开发并开源，基于java语言实现，侵入性相对于CAT要低一点，需要对web.xml等相关配置文件进行修改，但依然对系统有一定的侵入性，Zipking可以轻松与Spring Cloud进行基础，也是Spring Cloud推荐的APM系统。
- 3、jaeger: 是Uber推出的一款开源分布式追踪系统，主要使用go语言开发，对业务代码侵入性较小。
- 4、Pinpoint: 韩国团队开源的APM产品，运用了字节码增加技术，只需要在启动时添加启动参数即可实现APM功能，对代码无侵入，目前支持java和PHP语言，底层采用HBase来存储数据，探针手机的数据粒度非常细，但性能损耗较大，因其出现的时间较长，完成度也很高，文档也较为丰富，应用的公司较多。
- 5、Skywalking：Skywalking是由国内开源爱好者吴晟开源并提交到Apache孵化器的开源项目，2017年12月SkyWalking成为Apache国内首个个人孵化项目，2019年4月17日SkyWalking从Apache基金会的孵化器毕业成为顶级项目，目前SkyWalking支持java、.Net、Node.js、go、python等探针，数据存储支持mysql、ElasticSearch等，SkyWalking与Pinpoint相同，对业务代码无侵入，不过探针采集数据粒度相较于Pinpoint来说略粗，但是性能表现优秀，目前SkyWalking增长势头强劲，社区活跃，中午文档齐全，没有语言障碍，支持多语言探针，这些都是SkyWalking的优势所在，还有就是SkyWalking支持很多框架，包括很多国产框架，例如，Dubbo、gRPC、SOFARPC等等，同时也由很多开发者正在不断向社区提供更多插件以支持更多组件无缝接入SkyWalking.
- 6、开源： Piwik等 #http://blogs.studylinux.net/?p=750
- 7、商业的： 百度统计/growingio等

# 三、对比

|  | **pinpoint** | **zipkin** | **jaeger** | **skywalking** |
|--|----------|--------|--------|-------------|
| **OpenTracing兼容** | 否 | 是 | 是 | 是 |
| **客户端支持语言** | java、php | java、c#、go、php等 |  java、c#、go、php等 | java、.NET Core、NodeJS and PHP |
| **存储** | hbase | ES、mysql、Cassandra、内存 | ES、kafka、Cassandra、内存 | ES、H2、mysql、TIDB、[sharding sphere](https://shardingsphere.apache.org/document/current/cn/overview/) |
| **传输协议支持** | thrift | http、MQ | udp、http | gRPC、http |
| **ui丰富程度** | 高 | 低 | 中 | 中 |
| **实现方式-代码侵入** | 字节码注入，无浸入 | 拦截请求，侵入 | 拦截请求，侵入 | 字节码注入，无侵入 |
| **扩展性** | 低 | 高 | 高 | 中 |
| **trace查询** | 不支持 | 支持 | 支持 | 支持 |
| **告警支持** | 支持 | 不支持 | 不支持 | 支持 |
| **jvm监控** | 支持 | 不支持 | 不支持 | 支持 |
| **性能损失** | 高 | 中 | 中 | 低 |

# 四、OpenTracing规范

- 由于以上APM系统较多，各个分布式链路追踪产品的API并不兼容，如果用户在各个产品之间进行切换，成本非常高，因此成立了OpenTracing组织，OpenTracing通过制定统一的API标准和数据结构模型，从而帮助开发人员和用户能够方便地使用或更换追踪系统。https://opentracing.io/

https://github.com/opentracing-contrib/opentracing-specification-zh

# 五、skywalking介绍

## 目前项目中使用的skywalking组件由三部分组成
- skywalking-oap: skywalking主要链路收集组件，用于收集系统中的链路信息。
- skywalking-ui: skywalking主要展示组件，提供了一个ui界面，可以查看各种链路及参数信息。
- skywalking-agent: skywalking提供的客户端接入方式，利用探针技术无侵入的结合到客户端中，收集客户端中的链路信息发送到oap中。

## 从逻辑上讲，SkyWalking分为四个部分
- 探针（Agent）：收集数据并重新格式化以符合SkyWalking的要求（不同的探针支持不同的来源）。
- 后端（Oap）：支持数据聚合，分析并驱动从探针到UI的流程。该分析包括SkyWalking本机跟踪和度量，第三方，包括Istio和Envoy遥测，Zipkin跟踪格式等。您甚至可以通过使用针对本机度量的Observability Analysis Language和针对扩展度量的Meter System来定制聚合和分析。
- 存储：通过开放/可插入的界面存储SkyWalking数据。您可以选择现有的实现，例如ElasticSearch，H2或由Sharding-Sphere管理的MySQL集群，也可以实现自己的实现。欢迎为新的存储实现者打补丁！
- UI：是一个高度可定制的基于Web的界面，允许SkyWalking最终用户可视化和管理SkyWalking数据。

## 后端（Oap）又分为三个角色
- 混合Mixed（默认）：默认角色，OAP应承担以下责任，1.接收代理跟踪或指标，2.进行L1聚合，3.内部通讯（发送/接收），4.进行L2聚合，5.持久化，6.报警
- 接收者Receiver：1.接收代理跟踪或指标，2.进行L1聚合，3.内部通讯（发送/接收）
- 聚合器Aggregator：4.进行L2聚合，5.持久化，6.报警

可以利用Receiver和Aggregator进行高级部署，来区分节点责任，缓解压力

注意：Receiver节点也可以进行持久化，继承Record类的实体在进行L1聚合时持久化


# 六、skywalking部署

SkyWalking有两中版本，ES版本和非ES版。如果我们决定采用ElasticSearch作为存储，那么就下载es版本。

友情提示：这里两个版本不准备，SkyWalking 支持 ES、MySQL 等等作为存储器，实现链路等信息的读写。一般情况下，我们推荐使用 ES 存储器。

1、skywalking下载地址
- https://skywalking.apache.org/downloads/
- https://archive.apache.org/dist/skywalking/

```
# wget https://archive.apache.org/dist/skywalking/8.0.1/apache-skywalking-apm-es7-8.0.1.tar.gz
# tar xvf apache-skywalking-apm-es7-8.0.1.tar.gz
# cd apache-skywalking-apm-bin-es7
total 92
drwxrwxr-x. 8 1001 1002   143 Jun 18  2020 agent
drwxr-xr-x. 2 root root   241 Feb 11 14:28 bin
drwxr-xr-x. 4 root root  4096 Feb 11 14:28 config
-rwxrwxr-x. 1 1001 1002 29805 Jun 18  2020 LICENSE
drwxrwxr-x. 3 1001 1002  4096 Feb 11 14:28 licenses
-rwxrwxr-x. 1 1001 1002 31548 Jun 18  2020 NOTICE
drwxrwxr-x. 2 1001 1002 12288 Jun 18  2020 oap-libs
-rw-rw-r--. 1 1001 1002  1978 Jun 18  2020 README.txt
drwxr-xr-x. 3 root root    30 Feb 11 14:28 tools
drwxr-xr-x. 2 root root    53 Feb 11 14:28 webapp
```
- agent: 目录将来要拷贝到各服务所在机器上用作探针
- bin: 目录是服务启动脚本
- config: 目录是配置文件
- oap-libs: 目录是oap服务运行所需的jar包
- webapp: 目录是web服务运行所需的jar包

2、修改配置application.yml
```
# cd config/

# ll
total 92
-rw-rw-r--. 1 1001 1002  2048 Jun 18  2020 alarm-settings-sample.yml
-rw-rw-r--. 1 1001 1002  3298 Jun 18  2020 alarm-settings.yml                #预警
-rwxrwxr-x. 1 1001 1002 13477 Jun 18  2020 application.yml                   #核心配置
-rwxrwxr-x. 1 1001 1002  7748 Jun 18  2020 component-libraries.yml
-rw-rw-r--. 1 1001 1002  1437 Jun 18  2020 endpoint-name-grouping.yml
drwxr-xr-x. 2 root root    23 Feb 11 14:28 fetcher-prom-rules
-rwxrwxr-x. 1 1001 1002   963 Jun 18  2020 gateways.yml                      #外接网关
-rw-rw-r--. 1 1001 1002  1812 Jun 18  2020 log4j2.xml
drwxr-xr-x. 2 root root    85 Feb 11 14:28 oal
-rw-rw-r--. 1 1001 1002   958 Jun 18  2020 service-apdex-threshold.yml       #服务apdex设置
-rw-rw-r--. 1 1001 1002 43307 Jun 18  2020 ui-initialized-templates.yml
```

作为监控系统，首先排除H2和MySQL，这里推荐InfluxDB，它本身就是时序数据库，非常适合这种场景，这里用ElasticSearch7,支持的存储有
- H2
- ElasticSearch 6, 7
- MySQL
- TiDB
- InfluxDB


https://github.com/apache/skywalking/blob/master/docs/en/setup/backend/backend-storage.md



/config/application.yml部分配置
```
cluster:
   selector: ${SW_CLUSTER:standalone}
   # 单节点模式
   standalone:
   # zk用于管理collector集群协作.
   # zookeeper:
      # 多个zk连接地址用逗号分隔.
      # hostPort: localhost:2181
      # sessionTimeout: 100000
   # 分布式 kv 存储设施，类似于zk，但没有zk重型（除了etcd，consul、Nacos等都是类似功能）
   # etcd:
      # serviceName: ${SW_SERVICE_NAME:"SkyWalking_OAP_Cluster"}
      # 多个节点用逗号分隔, 如: 10.0.0.1:2379,10.0.0.2:2379,10.0.0.3:2379
      # hostPort: ${SW_CLUSTER_ETCD_HOST_PORT:localhost:2379}
core:
   selector: ${SW_CORE:default}
   default:
      # 混合角色：接收代理数据，1级聚合、2级聚合
      # 接收者：接收代理数据，1级聚合点
      # 聚合器：2级聚合点
      role: ${SW_CORE_ROLE:Mixed} # Mixed/Receiver/Aggregator
 
       # rest 服务地址和端口
      restHost: ${SW_CORE_REST_HOST:localhost}
      restPort: ${SW_CORE_REST_PORT:12800}
      restContextPath: ${SW_CORE_REST_CONTEXT_PATH:/}
 
      # gRPC 服务地址和端口
      gRPCHost: ${SW_CORE_GRPC_HOST:localhost}
      gRPCPort: ${SW_CORE_GRPC_PORT:11800}
 
      downsampling:
      - Hour
      - Day
      - Month
 
      # 设置度量数据的超时。超时过期后，度量数据将自动删除.
      # 单位分钟
      recordDataTTL: ${SW_CORE_RECORD_DATA_TTL:90}
 
      # 单位分钟
      minuteMetricsDataTTL: ${SW_CORE_MINUTE_METRIC_DATA_TTL:90}
 
      # 单位小时
      hourMetricsDataTTL: ${SW_CORE_HOUR_METRIC_DATA_TTL:36}
 
      # 单位天
      dayMetricsDataTTL: ${SW_CORE_DAY_METRIC_DATA_TTL:45}
 
      # 单位月
      monthMetricsDataTTL: ${SW_CORE_MONTH_METRIC_DATA_TTL:18}
 
storage:
   selector: ${SW_STORAGE:elasticsearch7}
   elasticsearch7:
      # elasticsearch 的集群名称
      nameSpace: ${SW_NAMESPACE:"TEST-ES"}
 
      # elasticsearch 集群节点的地址及端口
      clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.168.1.1:9200}
      
      # elasticsearch 的用户名和密码
      user: ${SW_ES_USER:""}
      password: ${SW_ES_PASSWORD:""}
 
      # 设置 elasticsearch 索引分片数量
      indexShardsNumber: ${SW_STORAGE_ES_INDEX_SHARDS_NUMBER:2}
 
      # 设置 elasticsearch 索引副本数
      indexReplicasNumber: ${SW_STORAGE_ES_INDEX_REPLICAS_NUMBER:0}
 
      # 批量处理配置
      # 每2000个请求执行一次批量
      bulkActions: ${SW_STORAGE_ES_BULK_ACTIONS:2000}
 
      # 每 20mb 刷新一次内存块
      bulkSize: ${SW_STORAGE_ES_BULK_SIZE:20}
 
      # 无论请求的数量如何，每10秒刷新一次堆
      flushInterval: ${SW_STORAGE_ES_FLUSH_INTERVAL:10}
 
      # 并发请求的数量
      concurrentRequests: ${SW_STORAGE_ES_CONCURRENT_REQUESTS:2}
 
      # elasticsearch 查询的最大数量
      metadataQueryMaxSize: ${SW_STORAGE_ES_QUERY_MAX_SIZE:5000}
 
      # elasticsearch 查询段最大数量
      segmentQueryMaxSize: ${SW_STORAGE_ES_QUERY_SEGMENT_SIZE:200}
      
      profileTaskQueryMaxSize: ${SW_STORAGE_ES_QUERY_PROFILE_TASK_SIZE:200}
      advanced: ${SW_STORAGE_ES_ADVANCED:""}
```
主要修改，`SW_CLUSTER`,`SW_CORE_ROLE`，`SW_STORAGE`，`SW_NAMESPACE`，`SW_STORAGE_ES_CLUSTER_NODES`
- SW_CLUSTER 默认standalone单机模式
- SW_CORE_ROLE 默认Mixed混合模式
- SW_STORAGE 存储，我使用的是es7，所以设置成elasticsearch7
- SW_NAMESPACE es的namespace
- SW_STORAGE_ES_CLUSTER_NODES es地址，多个地址以，分割

3、webapp配置

- 可以在这里修改前端工程端口，默认8080
```
# vim webapp/webapp.yml
server:
  port: 8080

collector:
  path: /graphql
  ribbon:
    ReadTimeout: 10000
    # Point to all backend's restHost:restPort, split by ,
    listOfServers: 127.0.0.1:12800
```

4、启动
```
sh bin/startup.sh
```
- 后端工程会启动两个端口11800和12800，大多数代理使用11800端口，只有少数不支持grpc的代理使用12800。前端工程使用12800

5、启动成功后访问http://localhost:8080

# 六、部署 skywalking 的 Java Agent

https://github.com/apache/skywalking/blob/v8.2.0/docs/en/setup/service-agent/java-agent/README.md

```
wget https://archive.apache.org/dist/skywalking/java-agent/8.9.0/apache-skywalking-java-agent-8.9.0.tgz
tar apache-skywalking-java-agent-8.9.0.tgz
# cd skywalking-agent

# ll
total 19964
drwxrwxr-x. 2 1001 1002     4096 Jan 28 21:38 activations
drwxrwxr-x. 2 1001 1002       85 Jan 28 21:38 bootstrap-plugins
drwxrwxr-x. 2 1001 1002       26 Jan 28 21:36 config                        #配置文件#
-rw-rw-r--. 1 1001 1002    12911 Jan 28 21:36 LICENSE
drwxrwxr-x. 2 1001 1002       29 Jan 28 21:36 licenses
drwxrwxr-x. 2 1001 1002        6 Jan 28 21:36 logs                          #日志
-rw-rw-r--. 1 1001 1002    10003 Jan 28 21:36 NOTICE
drwxrwxr-x. 2 1001 1002     4096 Jan 28 21:39 optional-plugins              #可选插件
drwxrwxr-x. 2 1001 1002      130 Jan 28 21:39 optional-reporter-plugins
drwxrwxr-x. 2 1001 1002     8192 Jan 28 21:38 plugins                       #生效插件
-rw-rw-r--. 1 1001 1002 20391972 Jan 28 21:36 skywalking-agent.jar
```

### 有四种方式配置，优先级如下
```
探针配置 > JVM配置 > 系统环境变量配置 > agent.config文件
```

1.JVM配置覆盖
```
-Dskywalking.agent.service_name = demo-provider
```

2.探针配置覆盖
```
-javaagent:/var/local/agent/skywalking-agent.jar=agent.service_name=service-pfm
# 默认格式是 -javaagent:agent.jar=[option1]=[value1],[option2]=[value2]
```

### 我们使用JVM 配置，所以此处不修改。

/agent/config/agent.config主要配置
```
# 不同的namespace会导致调用链路追踪中断
agent.namespace=${SW_AGENT_NAMESPACE:default-namespace}

# 页面上展示的service的名称，也可以通过-Dskywalking.agent.service_name=xxx指定
agent.service_name=${SW_AGENT_NAME:service-pfm}

# 平台的调用地址，也可以通过-Dskywalking.collector.backend_service=127.0.0.1:11800指定
collector.backend_service=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:127.0.0.1:11800}

# 忽略指定后缀的请求收集
agent.ignore_suffix=${SW_AGENT_IGNORE_SUFFIX:.jpg,.jpeg,.js,.css,.png,.bmp,.gif,.ico,.mp3,.mp4,.html,.svg}

# 每3秒的采样率，负数代表100%
agent.sample_n_per_3_secs=${SW_AGENT_SAMPLE:-1}
```
- 注意：如果Collector以集群方式部署，比如：Acollector和Bcollector，建议Acollector.sampleRate = Bcollector.sampleRate

启动工程接入Agent

在jvm启动参数上添加
```
-javaagent:/var/local/apache-skywalking-apm-bin/agent/skywalking-agent.jar
```

完整的启动命令
```
java -javaagent:/opt/apache-skywalking-apm-bin/agent/skywalking-agent.jar \
-Dskywalking.agent.service_name=service-pfm  \
-Dskywalking.collector.backend_service=127.0.0.1:11800 \
-jar simple-skywalking-test.jar
```
- -javaagent: 指定 agent jar 包的位置
- -Dskywalking.agent.service_name: 指定服务名
- -Dskywalking.collector.backend_service: 指定 oap 服务的地址

# 七、告警

https://github.com/apache/skywalking/blob/v8.2.0/docs/en/setup/backend/backend-alarm.md
