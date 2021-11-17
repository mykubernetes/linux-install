官网  
https://docs.janusgraph.org/

github  
https://github.com/JanusGraph/janusgraph/releases/

提供了Gremlin和SQL语句的转化样例，帮助快速上手Gremlin图查询语言  
http://sql2gremlin.com/ 提供了Gremlin和SQL语句的转化样例，帮助快速上手Gremlin图查询语言

https://blog.csdn.net/meifannao789456/category_9289048.html?spm=1001.2014.3001.5482

Gremlin中文文档  
http://tinkerpop-gremlin.cn/

https://blog.csdn.net/weixin_39409615/article/details/101519438

https://www.jianshu.com/p/83e46d70dd92

语句  
http://tinkerpop.apache.org/docs/current/reference/#traversal

基础语句
| 用法 | 说明 |
|------|-----|
| graph = JanusGraphFactory.open('conf/gremlin-server/socket-janusgraph-hbase-server.properties') | 打开数据库连接 |
| g=graph.traversal() | 的到实列 |
| V() | 查询顶点，一般作为图查询的第1步，后面可以续接的语句种类繁多。例，g.V()，g.V('v_id')，查询所有点和特定点； |
| E() | 查询边，一般作为图查询的第1步，后面可以续接的语句种类繁多； |
| id() | 获取顶点、边的id。例：g.V().id()，查询所有顶点的id； |
| label() | 获取顶点、边的 label。例：g.V().label()，可查询所有顶点的label。 |
| key() / values() | 获取属性的key/value的值。 |
| properties() | 获取顶点、边的属性；可以和 key()、value()搭配使用，以获取属性的名称或值。例：g.V().properties('name')，查询所有顶点的 name 属性； |
| valueMap() | 获取顶点、边的属性，以Map的形式体现，和properties()比较像； |
| values() | 获取顶点、边的属性值。例，g.V().values() 等于 g.V().properties().value() |

遍历（以定点为基础）
| 用法 | 说明 |
|------|-----|
| out(label) | 根据指定的 Edge Label 来访问顶点的 OUT 方向邻接点（可以是零个 Edge Label，代表所有类型边；也可以一个或多个 Edge Label，代表任意给定 Edge Label 的边，下同）； |
| in(label) | 根据指定的 Edge Label 来访问顶点的 IN 方向邻接点； |
| both(label) | 根据指定的 Edge Label 来访问顶点的双向邻接点； |
| outE(label) | 根据指定的 Edge Label 来访问顶点的 OUT 方向邻接边； |
| inE(label) | 根据指定的 Edge Label 来访问顶点的 IN 方向邻接边； |
| bothE(label) | 根据指定的 Edge Label 来访问顶点的双向邻接边； |

遍历（以边为基础）
| 用法 | 说明 |
|------|-----|
| outV() | 访问边的出顶点，出顶点是指边的起始顶点； |
| inV() | 访问边的入顶点，入顶点是指边的目标顶点，也就是箭头指向的顶点； |
| bothV() | 访问边的双向顶点； |
| otherV() | 访问边的伙伴顶点，即相对于基准顶点而言的另一端的顶点； |

过滤
| 用法 | 说明 |
|------|-----|
| has(key,value) | 通过属性的名字和值来过滤顶点或边； |
| has(label, key, value) | 通过label和属性的名字和值过滤顶点和边； |
| has(key,predicate) | 通过对指定属性用条件过滤顶点和边，例：g.V().has('age', gt(20))，可得到年龄大于20的顶点； |
| hasLabel(labels…) | 通过 label 来过滤顶点或边，满足label列表中一个即可通过； |
| hasId(ids…) | 通过 id 来过滤顶点或者边，满足id列表中的一个即可通过； |
| hasKey(keys…) | 通过 properties 中的若干 key 过滤顶点或边； |
| hasValue(values…) | 通过 properties 中的若干 value 过滤顶点或边； |
| has(key) | properties 中存在 key 这个属性则通过，等价于hasKey(key)； |
| hasNot(key) | 和 has(key) 相反； |



# 安装JanusGraph


1. Cassandra 安装
```
docker run --name cassandra-3.11.3 -p 7000:7000 -p 7001:7001 -p 7199:7199 -p 9042:9042 -p 9160:9160 -d cassandra:3.11.3
```

2. Elasticsearch 安装
```
docker run --name es-5.5.2 -p 9200:9200 -p 9300:9300 -d elasticsearch:5.5.2
```

安装JanusGraph

1、安装java

2、下载JanusGraph
```
wget https://github.com/JanusGraph/janusgraph/releases/download/v0.3.0/janusgraph-0.3.2-hadoop2.zip
```

3、解压JanusGraph
```
unzip janusgraph-0.3.2-hadoop2.zip

# ls
bin  conf  data  examples  ext  javadocs  lib  LICENSE.txt  NOTICE.txt  scripts

# tree bin/
bin/
├── gremlin.bat
├── gremlin-server.bat
├── gremlin-server.sh
└── gremlin.sh

0 directories, 4 files

# tree conf/
conf/
├── gremlin-server
│   ├── gremlin-server-berkeleyje-es.yaml
│   ├── gremlin-server-berkeleyje.yaml
│   ├── gremlin-server-configuration.yaml
│   ├── gremlin-server-cql-es.yaml
│   ├── gremlin-server.yaml
│   ├── janusgraph-berkeleyje-es-server.properties
│   ├── janusgraph-berkeleyje-server.properties
│   ├── janusgraph-cassandra-es-server.properties
│   ├── janusgraph-cql-es-server.properties
│   └── log4j-server.properties
├── hadoop-graph
│   ├── hadoop-graphson.properties
│   ├── hadoop-gryo.properties
│   ├── hadoop-load.properties
│   ├── hadoop-script.properties
│   ├── read-cassandra.properties
│   ├── read-cassandra-standalone-cluster.properties
│   ├── read-cql.properties
│   ├── read-cql-standalone-cluster.properties
│   ├── read-hbase.properties
│   ├── read-hbase-snapshot.properties
│   └── read-hbase-standalone-cluster.properties
├── janusgraph-berkeleyje-es.properties
├── janusgraph-berkeleyje-lucene.properties
├── janusgraph-berkeleyje.properties
├── janusgraph-berkeleyje-solr.properties
├── janusgraph-cassandra-configurationgraph.properties
├── janusgraph-cassandra-es.properties
├── janusgraph-cassandra.properties
├── janusgraph-cassandra-solr.properties
├── janusgraph-cql-configurationgraph.properties
├── janusgraph-cql-es.properties
├── janusgraph-cql.properties
├── janusgraph-cql-solr.properties
├── janusgraph-hbase-es.properties
├── janusgraph-hbase.properties
├── janusgraph-hbase-solr.properties
├── janusgraph-inmemory.properties
├── log4j-console.properties
├── logback.xml
├── remote-graph.properties
├── remote-objects.yaml
├── remote.yaml
└── solr
    ├── currency.xml
    ├── lang
    │   └── stopwords_en.txt
    ├── protwords.txt
    ├── schema.xml
    ├── solrconfig.xml
    ├── stopwords.txt
    └── synonyms.txt

4 directories, 49 files
```

4、配置启动配置文件conf/gremlin-server/gremlin-server.yaml

配置文件  
https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.janusgraph.org%2Fbasics%2Fconfiguration-reference%2F%23configuration-namespaces-and-options

```
# Copyright 2019 JanusGraph Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
 
host: 0.0.0.0                                                                    #监听地址             
port: 8182                                                                       #监听端口号
scriptEvaluationTimeout: 30000                                                   #指单次查询最长的时间，默认是30s
channelizer: org.apache.tinkerpop.gremlin.server.channel.WebSocketChannelizer
# 服务类型，可选以下内容 
# - WebSocketChannelizer 提供WebSocket服务 
# - HttpChannelizer 提供Http服务 
# - WsAndHttpChannelizer 推荐，同时提供WebSocket和Http服务，从0.2.0版本开始支持

graphs: {
  graph: conf/gremlin-server/janusgraph-cql-es-server.properties                 # 所要用到的配置文件路径，可自定义
}
scriptEngines: {
  gremlin-groovy: {
    plugins: { org.janusgraph.graphdb.tinkerpop.plugin.JanusGraphGremlinPlugin: {},
               org.apache.tinkerpop.gremlin.server.jsr223.GremlinServerGremlinPlugin: {},
               org.apache.tinkerpop.gremlin.tinkergraph.jsr223.TinkerGraphGremlinPlugin: {},
               org.apache.tinkerpop.gremlin.jsr223.ImportGremlinPlugin: {classImports: [java.lang.Math], methodImports: [java.lang.Math#*]},
               org.apache.tinkerpop.gremlin.jsr223.ScriptFileGremlinPlugin: {files: [scripts/empty-sample.groovy]}}}}
serializers:
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { serializeResultToString: true }}
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV3d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
  # Older serialization versions for backwards compatibility:
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV1d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoLiteMessageSerializerV1d0, config: {ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV1d0, config: { serializeResultToString: true }}
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerGremlinV2d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerGremlinV1d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistryV1d0] }}
  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV1d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistryV1d0] }}
processors:
  - { className: org.apache.tinkerpop.gremlin.server.op.session.SessionOpProcessor, config: { sessionTimeout: 28800000 }}
  - { className: org.apache.tinkerpop.gremlin.server.op.traversal.TraversalOpProcessor, config: { cacheExpirationTime: 600000, cacheMaxSize: 1000 }}
metrics: {
  consoleReporter: {enabled: true, interval: 180000},
  csvReporter: {enabled: true, interval: 180000, fileName: /tmp/gremlin-server-metrics.csv},
  jmxReporter: {enabled: true},
  slf4jReporter: {enabled: true, interval: 180000},
  gangliaReporter: {enabled: false, interval: 180000, addressingMode: MULTICAST},
  graphiteReporter: {enabled: false, interval: 180000}}
maxInitialLineLength: 4096
maxHeaderSize: 8192
maxChunkSize: 8192
maxContentLength: 65536
maxAccumulationBufferComponents: 1024
resultIterationBatchSize: 64
writeBufferLowWaterMark: 32768
writeBufferHighWaterMark: 65536
```

5、配置janusgraph-cql-es-server.properties
```
# 存储后端
storage.backend=cql
storage.hostname=127.0.0.1
storage.cql.keyspace=janusgraph

# 缓存配置
cache.db-cache = true
cache.db-cache-clean-wait = 20
cache.db-cache-time = 180000
cache.db-cache-size = 0.25

# 搜索引擎配置
index.search.backend=elasticsearch
index.search.hostname=127.0.0.1
index.search.elasticsearch.client-only=true
```

6、启动janusgraph
```
bin/gremlin-server.sh ./conf/gremlin-server/gremlin-server.yaml
[gremlin-server-boss-1] INFO org.apache.tinkerpop.gremlin.server.GremlinServer - Channel started at port 8182.
```

7、测试 WebSocket,运行 bin/gremlin.sh 。
```
$ bin/gremlin.sh

         \,,,/
         (o o)
-----oOOo-(3)-oOOo-----
plugin activated: janusgraph.imports
plugin activated: tinkerpop.server
plugin activated: tinkerpop.utilities
plugin activated: tinkerpop.hadoop
plugin activated: tinkerpop.spark
plugin activated: tinkerpop.tinkergraph
gremlin> :remote connect tinkerpop.server conf/remote.yaml
==>Configured localhost/127.0.0.1:8182
gremlin> :> g.V().count()
==>0
gremlin>
```

8、测试 Http,运行如下命令测试 http 能否正常响应。
```
curl -XPOST -Hcontent-type:application/json -d '{"gremlin":"g.V().count()"}' http://localhost:8182
应有类似如下返回内容，则为正常。

{
  "requestId": "47608dd1-275d-4708-acf7-fa1e6355328b",
  "status": {
    "message": "",
    "code": 200,
    "attributes": { "@type": "g:Map", "@value": [] }
  },
  "result": {
    "data": {
      "@type": "g:List",
      "@value": [{ "@type": "g:Int64", "@value": 0 }]
    },
    "meta": { "@type": "g:Map", "@value": [] }
  }
}
```

9、守护进程配置 systemd
```
# vim /etc/systemd/system/janusgraph.service
[Unit]
Description=JanusGraph Server

[Service]
ExecStart=/root/janusgraph/bin/gremlin-server.sh /root/janusgraph/conf/gremlin-server/gremlin-server.yaml
ExecReload=/bin/kill -HUP $MAINPID
Type=simple
User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target
```

10、常用命令
```
sudo service janusgraph start
sudo service janusgraph stop
sudo service janusgraph restart
sudo systemctl enable janusgraph
sudo systemctl disable janusgraph
```

## 安全认证
1、HTTP 认证

在 gremlin-server-xxx.yaml 中配置：
```
authentication: {
  authenticator: org.janusgraph.graphdb.tinkerpop.gremlin.server.auth.JanusGraphSimpleAuthenticator,
  authenticationHandler: org.apache.tinkerpop.gremlin.server.handler.HttpBasicAuthenticationHandler,
  config: {
    defaultUsername: user,
    defaultPassword: password,
    credentialsDb: conf/janusgraph-credentials-server.properties
   }
}
```
访问：
```
curl -v -XPOST http://localhost:8182 -d '{"gremlin": "g.V().count()"}' -u user:password
```

2、WebSocket 认证

使用 SASL 身份验证，在 gremlin-server-xxx.yaml 中配置：
```
authentication: {
  authenticator: org.janusgraph.graphdb.tinkerpop.gremlin.server.auth.JanusGraphSimpleAuthenticator,
  authenticationHandler: org.apache.tinkerpop.gremlin.server.handler.SaslAuthenticationHandler,
  config: {
    defaultUsername: user,
    defaultPassword: password,
    credentialsDb: conf/janusgraph-credentials-server.properties
  }
}
```

3、HTTP 和 WebSocket 认证

使用 HMAC token 认证方式，在 gremlin-server-xxx.yaml 中配置：
```
authentication: {
  authenticator: org.janusgraph.graphdb.tinkerpop.gremlin.server.auth.SaslAndHMACAuthenticator,
  authenticationHandler: org.janusgraph.graphdb.tinkerpop.gremlin.server.handler.SaslAndHMACAuthenticationHandler,
  config: {
    defaultUsername: user,
    defaultPassword: password,
    hmacSecret: secret,
    credentialsDb: conf/janusgraph-credentials-server.properties
  }
}
```
