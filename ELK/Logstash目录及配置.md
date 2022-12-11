# LogStash目录布局

| 类型 | 描述 | 位置 | 环境 |
|------|------|------|------|
| home | logstash安装的主目录 | {extract.path} | |
| bin | 二进制脚本目录 | {extract.path}/bin |
| settings | 配置文件目录 | {extract.path}/config | path.settings |
| logs | 日志文件目录 | {extract.path}/logs | path.logs |
| plugins | 本地的，非Ruby-Gem插件 | {extract.path}/plugins | path.plugins |
| data | logstash 及其插件用于任何持久性需求的数据文件。 | {extract.path}/data | path.data |

# LogStash的配置文件

设置文件已在 Logstash 安装中定义。Logstash 包括以下设置文件：

- logstash.yml

包含 Logstash 配置标志。您可以在此文件中设置标志，而不是在命令行中传递标志。您在命令行设置的任何标志都会覆盖文件中的相应设置logstash.yml。[logstash.yml官方文档](https://www.elastic.co/guide/en/logstash/current/logstash-settings-file.html)。

- pipelines.yml

包含在单个 Logstash 实例中运行多个管道的框架和指令。[pipelines.yml官方配置](https://www.elastic.co/guide/en/logstash/current/multiple-pipelines.html)。

- jvm.options

包含 JVM 配置标志。使用此文件设置总堆空间的初始值和最大值。您还可以使用此文件来设置 Logstash 的语言环境。在单独的行上指定每个标志。此文件中的所有其他设置都被视为专家设置。

- log4j2.properties

包含库的默认设置log4j 2。有关详细信息，请参阅[log4j2.properties官方文档](https://www.elastic.co/guide/en/logstash/current/logging.html#log4j2)。

# LogStash命令行可选参数

## 一、`--config.test_and_exit`

- 解析配置文件并报告错误
```
logstash -f test.conf --config.test_and_exit
```

## 二、`--config.reload.automatic`

- 启用自动重载加载配置
```
logstash -f test.conf --config.reload.automatic
```

# LogStash的工作原理

LogStash事件处理管道具有三个阶段：input->filter->output。input生成事件，filter修改它们，output将它们发送到其他地方。input和output支持编解码器，能够在数据进入或退出管道时对其进行编码或解码，而无需使用单独的过滤器

## 1.input

[input插件的官方文档](https://www.elastic.co/guide/en/logstash/current/input-plugins.html)

使用输入将数据输入LogStash，一些常用的输入包括：
- file：从文件系统上的文件中读取
- syslog：在514端口上监听syslog消息并根据RFC3164格式进行解析
- beats：处理Beats发送的事件

## 2.filter

[filter的官方文档](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html)

filter是LogStash管道中的中间处理设备。如果事件符合特定条件，可以将过滤器与条件结合起来对事件执行操作。一些常用的过滤器包括：
- grok：解析和构造任意文本。Grok目前是LogStash中将非结构化日志数据解析为结构化和可查询的最佳方式 [grok官网](https://www.elastic.co/guide/en/logstash/8.1/plugins-filters-grok.html)
- mutate：对事件字段执行一般转换。可以重命名、删除、替换和修改事件中的字段
- drop：完全删除事件，例如调试事件
- clone：复制一个事件，可能添加或删除字段
- geoip：添加有关IP地址地理位置的信息系 [geoip官网](https://www.elastic.co/guide/en/logstash/8.1/plugins-filters-geoip.html)

## 3.output

[output的官方文档](https://www.elastic.co/guide/en/logstash/current/output-plugins.html)

output是LogStash的最后阶段。一个事件可以通过多个输出，但是一旦所有输出处理完成，事件就完成了它的执行。一些常用的输出包括：
- elasticsearch：将事件数据发送到ElasticSearch。
- file：将事件数据写入磁盘上的文件
- graphite：将事件数据发送到Graphite，用于存储和绘制指标
- statsd：将事件数据发送到statsd，这是一项“监听统计信息，如计数器和计时器，通过UDP发送并将聚合发送到一个或多个可插入后端服务”的服务

## 4.codec

[codec的官方文档](https://www.elastic.co/guide/en/logstash/current/codec-plugins.html)

codec是基础的流过滤器，可以作为输入或输出的一部分进行操作。编码器能够将消息的传输与序列化过程分开。
- json：以JSON格式编码或解码数据
- multiline：将多行文本事件合并为单个事件
