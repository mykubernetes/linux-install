Prometheus提供了一个非常有用的支持命令行工具promtool。这个小型的Golang二进制文件可用于快速执行几个故障排除操作，并且包含了许多有用的子命令。

#### 1. 检查
属于这个类别的子命令为用户提供了检查和验证普罗米修斯服务器的几个配置方面和度量标准遵从性的能力。

##### 1.1 检查配置
promtool提供了几种类型的检查。其中最有价值的是检查Prometheus服务器的主配置文件。

检查配置时，0表示成功，1表示失败。

案例如下：
```shell
$ promtool check config /etc/prometheus/prometheus.yml 
Checking /etc/prometheus/prometheus.yml
  SUCCESS: 1 rule files found

Checking /etc/prometheus/first_rules.yml
  SUCCESS: 1 rules found
```

##### 1.2 规则检查
`check rules`分析并确定规则配置文件中的错误配置。它允许直接针对特定的规则文件，这允许您测试在主Prometheus配置中尚未引用的文件。这种能力对于规则文件的开发周期和在使用配置管理时验证上述文件中的自动更改非常方便。

案例如下：
```shell
$ promtool check rules /etc/prometheus/first_rules.yml 
Checking /etc/prometheus/first_rules.yml
  SUCCESS: 1 rules found
```

##### 1.3 度量值检查

`check metrics`子命令验证传递给它的度量在一致性和正确性方面是否遵循普罗米修斯准则。

```shell
~$ curl -s http://prometheus:9090/metrics | promtool check metrics
prometheus_tsdb_storage_blocks_bytes_total non-counter metrics should not have "_total" suffix
```

可以看到，prometheus_tsdb_storage_blocks_bytes_total度量似乎有问题。让我们看看这个特殊的度量来排除错误:

```shell
~$ curl -s http://prometheus:9090/metrics | grep prometheus_tsdb_storage_blocks_bytes_total
# HELP prometheus_tsdb_storage_blocks_bytes_total The number of bytes that are currently used for local storage by all blocks.
# TYPE prometheus_tsdb_storage_blocks_bytes_total gauge
prometheus_tsdb_storage_blocks_bytes_total 0
```

#### 2. 查询
属于这个类别的子命令允许直接从命令行执行PromQL表达式。这些查询依赖于Prometheus公共HTTP API。下面的主题将演示如何使用它们。

##### 2.1 查询实例
`query instant`子命令允许根据当前时间通过命令行直接查询普罗米修斯服务器。要使其工作，必须提供一个Prometheus服务器URL作为参数，以及要执行的查询，就像这样

```shell
$ promtool query instant 'http://prometheus:9090' 'up == 1'
up{instance="prometheus:9090", job="prometheus"} => 1 @[1550609854.042]
up{instance="prometheus:9100", job="node"} => 1 @[1550609854.042]
```

##### 2.2 查询范围
与前面的子命令类似，查询范围允许在指定的时间范围内显示结果。因此，我们必须提供开始和结束unix格式的时间戳，以及查询和Prometheus服务器端点。

例如，我们将使用date命令来定义开始和结束时间戳，生成五分钟前的unix格式时间戳和现在的另一个时间戳。我们还可以使用——step标志指定查询的解析，在我们的示例中，它是一分钟。最后，我们放置PromQL表达式来执行，最后得到一个类似下面的指令:

```shell
$ promtool query range --start=$(date -d '5 minutes ago' +'%s') --end=$(date -d 'now' +'%s') --step=1m 'http://prometheus:9090' 'node_network_transmit_bytes_total{device="eth0",instance="prometheus:9100",job="node"}'
node_network_transmit_bytes_total{device="eth0", instance="prometheus:9100", job="node"} =>
139109 @[1551019990]
139251 @[1551020050]
139401 @[1551020110]
139543 @[1551020170]
139693 @[1551020230]
140571 @[1551020290]
```

##### 2.3 query series
使用`query series`可以搜索与一组度量名称和标签匹配的所有时间序列。以下是使用方法:
```shell
$ promtool query series 'http://prometheus:9090' --match='up' --match='go_info{job="prometheus"}'
{__name__="go_info", instance="prometheus:9090", job="prometheus", version="go1.11.5"}
{__name__="up", instance="prometheus:9090", job="prometheus"}
{__name__="up", instance="prometheus:9100", job="node"}
```

##### 2.4 query labels
使用查询标签，您可以跨所有可用的指标搜索特定的标签，并返回附加到它的所有可能的值;例如:

```shell
$ promtool query labels 'http://prometheus:9090' 'mountpoint'
/
/run
/run/lock
/run/user/1000
/vagrant
/var/lib/lxcfs
```

#### 3. Debug
属于这个类别的子命令允许从运行的Prometheus服务器提取调试数据，以便对其进行分析。接下来我们将演示如何使用它们。

##### 3.1 debug pprof
```shell
$ promtool debug pprof 'http://prometheus:9090'
collecting: http://prometheus:9090/debug/pprof/profile?seconds=30
collecting: http://prometheus:9090/debug/pprof/block
collecting: http://prometheus:9090/debug/pprof/goroutine
collecting: http://prometheus:9090/debug/pprof/heap
collecting: http://prometheus:9090/debug/pprof/mutex
collecting: http://prometheus:9090/debug/pprof/threadcreate
collecting: http://prometheus:9090/debug/pprof/trace?seconds=30
Compiling debug information complete, all files written in "debug.tar.gz".
```

当我们提取前一个命令生成的存档文件时，我们可以看到几个文件:
```shell
$ tar xzvf debug.tar.gz 
cpu.pb
block.pb
goroutine.pb
heap.pb
mutex.pb
threadcreate.pb
trace.pb
```

使用pprof，我们可以生成转储的镜像，在下一个代码片段中我们可以观察到这一点

```shell
$ pprof -svg heap.pb > /vagrant/cache/heap.svg
```

在主机上，在./cache/ 路径(相对于存储库根)下的代码存储库中，您现在应该有一个可伸缩的向量图形文件heap。可由浏览器打开以供查看。下面的截图显示了你可能会看到什么时，看看由上述例子产生的文件:

![](../uploads/y20191113/images/m_40b83a418def32464ab3f89369f10e7e_r.png)

##### 3.2 debug metrics
此子命令下载提供的普罗米修斯实例在压缩归档中公开的度量。调试指标并不常用，因为/metrics Prometheus端点对于任何能够运行此命令的人都是可用的;它的存在是为了在需要时更容易地向外部援助(例如普罗米修斯的维护者)提供普罗米修斯实例的当前状态。这个子命令可以使用如下:

```shell
vagrant@prometheus:~$ promtool debug metrics 'http://prometheus:9090'
collecting: http://prometheus:9090/metrics
Compiling debug information complete, all files written in "debug.tar.gz".

vagrant@prometheus:~$ tar xzvf debug.tar.gz 
metrics.txt

vagrant@prometheus:~$ tail -n 5 metrics.txt 
# HELP promhttp_metric_handler_requests_total Total number of scrapes by HTTP status code.
# TYPE promhttp_metric_handler_requests_total counter
promhttp_metric_handler_requests_total{code="200"} 284
promhttp_metric_handler_requests_total{code="500"} 0
promhttp_metric_handler_requests_total{code="503"} 0
```

##### 3.3 debug all
该选项将之前的调试子命令聚合为一条指令，如下例所示:

```shell
vagrant@prometheus:~$ promtool debug all 'http://prometheus:9090'
collecting: http://prometheus:9090/debug/pprof/threadcreate
collecting: http://prometheus:9090/debug/pprof/profile?seconds=30
collecting: http://prometheus:9090/debug/pprof/block
collecting: http://prometheus:9090/debug/pprof/goroutine
collecting: http://prometheus:9090/debug/pprof/heap
collecting: http://prometheus:9090/debug/pprof/mutex
collecting: http://prometheus:9090/debug/pprof/trace?seconds=30
collecting: http://prometheus:9090/metrics
Compiling debug information complete, all files written in "debug.tar.gz".
```
