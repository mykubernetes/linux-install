
https://github.com/opentracing-contrib/opentracing-specification-zh



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
