
https://github.com/opentracing-contrib/opentracing-specification-zh

1、CAT： 由国内美团点评开源的，基于java语言开发，目前提供java、C/C++、Node.js、Python、Go等语言的客户端，监控数据会全量统计，国内很多公司在用，例如美团点评、携程、拼多多等，CAT需要开发人员手动在应用程序中埋点，对代码侵入性比较强。

2、Zipking：由Twitter公司开发并开源，基于java语言实现，侵入性相对于CAT要低一点，需要对web.xml等相关配置文件进行修改，但依然对系统有一定的侵入性，Zipking可以轻松与Spring Cloud进行基础，也是Spring Cloud推荐的APM系统。

3、jaeger: 是Uber推出的一款开源分布式追踪系统，主要使用go语言开发，对业务代码侵入性较小。

4、Pinpoint: 韩国团队开源的APM产品，运用了字节码增加技术，只需要在启动时添加启动参数即可实现APM功能，对代码无侵入，目前支持java和PHP语言，底层采用HBase来存储数据，探针手机的数据粒度非常细，但性能损耗较大，因其出现的时间较长，完成度也很高，文档也较为丰富，应用的公司较多。

5、Skywalking：Skywalking是由国内开源爱好者吴晟开源并提交到Apache孵化器的开源项目，2017年12月SkyWalking成为Apache国内首个个人孵化项目，2019年4月17日SkyWalking从Apache基金会的孵化器毕业成为顶级项目，目前SkyWalking支持java、.Net、Node.js、go、python等探针，数据存储支持mysql、ElasticSearch等，SkyWalking与Pinpoint相同，对业务代码无侵入，不过探针采集数据粒度相较于Pinpoint来说略粗，但是性能表现优秀，目前SkyWalking增长势头强劲，社区活跃，中午文档齐全，没有语言障碍，支持多语言探针，这些都是SkyWalking的优势所在，还有就是SkyWalking支持很多框架，包括很多国产框架，例如，Dubbo、gRPC、SOFARPC等等，同时也由很多开发者正在不断向社区提供更多插件以支持更多组件无缝接入SkyWalking.

6、开源： Piwik等 #http://blogs.studylinux.net/?p=750

7、商业的： 百度统计/growingio等


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


https://blog.csdn.net/xulong5000/article/details/113625357?spm=1001.2014.3001.5502

https://blog.csdn.net/xulong5000/article/details/113632628


https://skywalking.apache.org/downloads/

https://skywalking.apache.org/docs/skywalking-java/v8.9.0/en/setup/service-agent/java-agent/readme/
