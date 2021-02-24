https://blog.csdn.net/han949417140/article/details/112462319

Metric类型
---
Prometheus会将所有采集到的样本数据以时间序列（time-series）的方式保存在内存数据库TSDB中，并且定时保存到硬盘上。time-series是按照时间戳和值的序列顺序存放的，我们称之为向量(vector)。每条time-series通过指标名称(metrics name)和一组标签集(labelset)命名。

可以将time-series理解为一个以时间为Y轴的数字矩阵
```
  ^
  │     . . . . . . . . . . . . . . . . . . .   node_cpu{cpu="cpu0",mode="idle"}
  │     . . . . . . . . . . . . . . . . . . .   node_cpu{cpu="cpu0",mode="system"}
  │     . . . . . . . . . .   . . . . . . . .   node_load1{}
  │     . . . . . . . . . . . . . . . .   . .  
  v
    <------------------ 时间 ---------------->
```


在time-series中的每一个点称为一个样本（sample），样本由以下三部分组成：
- 指标(metric)：metric name和描述当前样本特征的labelsets;
- 时间戳(timestamp)：一个精确到毫秒的时间戳;
- 样本值(value)： 一个folat64的浮点型数据表示当前样本的值。
```
<--------------- metric ---------------------><-timestamp -><-value->
http_request_total{status="200", method="GET"}@1434417560938 => 94355
http_request_total{status="200", method="GET"}@1434417561287 => 94334

http_request_total{status="404", method="GET"}@1434417560938 => 38473
http_request_total{status="404", method="GET"}@1434417561287 => 38544

http_request_total{status="200", method="POST"}@1434417560938 => 4748
http_request_total{status="200", method="POST"}@1434417561287 => 4785
```


Prometheus定义了4中不同的指标类型(metric type):
---
- Counter 计数器,只增不减，除非重置（例如服务器或进程重启）
- Gauge 仪表盘，可增可减的数据。
- Histogram 直方图，将时间范围内的数据划分成不同的时段，并各自评估其样本个数及样本值之和，因而可计算出分位数
  - 可用于分析因异常值而引起的平均值过大的问题
  - 分位数计算要使用专用的histogram_quantile函数
- Summary 摘要，类似于Histogram,但客户端会直接计算并上报分位数

1、Counter：只增不减的计数器

Counter类型的指标其工作方式和计数器一样，只增不减（除非系统发生重置）。常见的监控指标，如http_requests_total，node_cpu都是Counter类型的监控指标。 一般在定义Counter类型指标的名称时推荐使用_total作为后缀。
```
//例如，通过rate()函数获取HTTP请求量的增长率：
rate(http_requests_total[5m])
//查询当前系统中，访问量前10的HTTP地址：
topk(10, http_requests_total)
```

2、Gauge：可增可减的仪表盘

与Counter不同，Gauge类型的指标侧重于反应系统的当前状态。因此这类指标的样本数据可增可减。常见指标如：node_memory_MemFree（主机当前空闲的内容大小）、node_memory_MemAvailable（可用内存大小）都是Gauge类型的监控指标。
```
//通过Gauge指标，用户可以直接查看系统的当前状态：
node_memory_MemFree
//还可以使用deriv()计算样本的线性回归模型，甚至是直接使用predict_linear()对数据的变化趋势进行预测。例如，预测系统磁盘空间在4个小时之后的剩余情况：
predict_linear(node_filesystem_free{job="node"}[1h], 4 * 3600)
```
3、Histogram和Summary分析数据分布情况

Histogram和Summary主用用于统计和分析样本的分布情况。

1)summary示例：
```
例如，指标prometheus_tsdb_wal_fsync_duration_seconds的指标类型为Summary。 它记录了Prometheus Server中wal_fsync处理的处理时间，通过访问Prometheus Server的/metrics地址，可以获取到以下监控样本数据：
# HELP prometheus_tsdb_wal_fsync_duration_seconds Duration of WAL fsync.
# TYPE prometheus_tsdb_wal_fsync_duration_seconds summary
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.5"} 0.012352463
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.9"} 0.014458005
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.99"} 0.017316173
prometheus_tsdb_wal_fsync_duration_seconds_sum 2.888716127000002
prometheus_tsdb_wal_fsync_duration_seconds_count 216
```
从上面的样本中可以得知当前Prometheus Server进行wal_fsync操作的总次数为216次，耗时2.888716127000002s。其中中位数（quantile=0.5）的耗时为0.012352463，9分位数（quantile=0.9）的耗时为0.014458005s

2)Histogram示例:
```
# HELP prometheus_tsdb_compaction_chunk_range Final time range of chunks on their first compaction
# TYPE prometheus_tsdb_compaction_chunk_range histogram
prometheus_tsdb_compaction_chunk_range_bucket{le="100"} 0
prometheus_tsdb_compaction_chunk_range_bucket{le="400"} 0
prometheus_tsdb_compaction_chunk_range_bucket{le="1600"} 0
prometheus_tsdb_compaction_chunk_range_bucket{le="6400"} 0
prometheus_tsdb_compaction_chunk_range_bucket{le="25600"} 0
prometheus_tsdb_compaction_chunk_range_bucket{le="102400"} 0
prometheus_tsdb_compaction_chunk_range_bucket{le="409600"} 0
prometheus_tsdb_compaction_chunk_range_bucket{le="1.6384e+06"} 260
prometheus_tsdb_compaction_chunk_range_bucket{le="6.5536e+06"} 780
prometheus_tsdb_compaction_chunk_range_bucket{le="2.62144e+07"} 780
prometheus_tsdb_compaction_chunk_range_bucket{le="+Inf"} 780
prometheus_tsdb_compaction_chunk_range_sum 1.1540798e+09
prometheus_tsdb_compaction_chunk_range_count 780
```
与Summary类型的指标相似之处在于Histogram类型的样本同样会反应当前指标的记录的总数(以_count作为后缀)以及其值的总量（以_sum作为后缀）。不同在于Histogram指标直接反应了在不同区间内样本的个数，区间通过标签len进行定义。同时对于Histogram的指标，我们还可以通过histogram_quantile()函数计算出其值的分位数。不同在于Histogram通过histogram_quantile函数是在服务器端计算的分位数。 而Sumamry的分位数则是直接在客户端计算完成。因此对于分位数的计算而言，Summary在通过PromQL进行查询时有更好的性能表现，而Histogram则会消耗更多的资源。反之对于客户端而言Histogram消耗的资源更少。在选择这两种方式时用户应该按照自己的实际场景进行选择。


选择器
---
选择器指的是一组标签匹配器，标签匹配器包含度量名称和标签名，__name__是一个特殊标签。

```
$ prometheus_build_info{version="2.17.0"}

上面的选择器等同于如下：
$ {__name__="prometheus_build_info", version="2.17.0"}
```

标签匹配器
---
匹配器用于将查询搜索限制为特定的一组标签值。
```
1、查询关于所有cpu的结果
$ node_cpu_seconds_total

2、 查询cpu=0的结果
$ node_cpu_seconds_total{cpu="0"}

3、查询cpu不等于0的结果。
$ node_cpu_seconds_total{cpu!="0"}
`=~`和`!~`支持RE2类型的正则表达式

4、比如只对`mode="user"`和`mode="system"`的感兴趣,那么可以执行如下：
$ node_cpu_seconds_total{mode=~"(system|user)"}


5、查询和上一条相反的结果
$ node_cpu_seconds_total{mode!~"(system|user)"}
```
- =：选择正好相等的字符串标签
- !=：选择不相等的字符串标签
- =~：选择匹配正则表达式的标签（或子标签）
- !=：选择不匹配正则表达式的标签（或子标签）


PromQl的数据类型
---
- 即时向量（Instant vector）：特定或全部的时间序列集合上，具有相同时间戳的一组样本值称为即时向量
- 范围向量（Range vector） 特定或全部的时间序列集合上，在指定的同一时间范围内的所有样本值
- 标量（Scalar） 一个浮点型的数据值。
- 字符串（String） 支持使用单引号、双引号或反引号进行引用，但反引号中不会对转义字符进行转义

1、即时向量
```
$ http_requests_total{job="prometheus",group="canary"}
```

2、范围向量

定义一个范围向量选择查询，必须设置一个即时向量选择器和使用`[]`追加一个范围。

检查最后两分钟HTTP的响应代码是200的。
```
$ prometheus_http_requests_total{code="200"}[2m]
```
|缩写   |单位   |
| ------------ | ------------ |
|s   |Seconds   |
|m   |Minutes   |
|h   |Hours   |
|d   |Days   |
|w   |Weeks   |
|y   |Years   |

必须使用整数时间，且能够将多个不同级别的单位进行串联组合，以时间单位由大到小为顺序，例如1h30m，但不能使用1.5h

3、在两个标量之间进行数学运算，得到的结果也是标量。
```
# 根据 node_disk_bytes_written 和 node_disk_bytes_read 获取主机磁盘IO的总量
node_disk_bytes_written + node_disk_bytes_read

# node的内存数GB
node_memory_free_bytes_total / (1024 * 1024)
```

偏移量的修饰符
---
offset的修饰符查询过去的数据。可双选择相对于当前时间的多长时间以前。

```
查询1小时前的最后两分钟响应代码是200的。
$ prometheus_http_requests_total{code="200"}[2m] offset 1h
```

子查询
---

```
max_over_time(rate(http_requests_total{handler="/health", instance="172.17.0.9:8000"}[5m])[1h:1m])
```

|组件   |描述   |
| ------------ | ------------ |
|rate(http_requests_total{handler="/health", instance="172.17.0.9:8000"}[5m])   |内部的查询，它将五分钟的数据聚合成一个即时向量。   |
|[1h   |就像范围向量选择器一样，它定义了相对于查询求值时间的范围大小。   |
|:1m]   |要使用的间隔值。如果没有定义，它默认为全局计算区间。   |
|max_over_time   |子查询返回一个范围向量，随着时间的推移，这个范围向量现在可以成为这个聚合操作的参数。   |

算术操作符
---
算术运算符提供两个操作数之间的基本数学运算。
|操作符   |描述   |
| ------------ | ------------ |
|+   |加   |
|-   |减   |
|*   |乘   |
|/   |除   |
|%   |取余   |
|^   |平方   |

对比操作符
---
|操作符   |描述   |
| ------------ | ------------ |
|==   |等于   |
|!=   |不等于   |
|>   |大于   |
|<   |小于   |
|>=   |大于或等于   |
|<=   |小于或等于   |

1、即时向量
```
process_open_fds{instance="192.168.20.113:9100",job="node"}
```
2、对比操作
```
process_open_fds{job="node"} > 5
```

3、获取http_requests_total请求总数是否超过10000，返回0和1，1则报警
```
http_requests_total > 10000             # 结果为 true 或 false
http_requests_total > bool 10000        # 结果为 1 或 0
```

逻辑操作
---
这些操作符是PromQL中唯一可以多对多工作的操作符。有三个逻辑运算符可以在表达式之间使用:

|操作   |描述   |
| ------------ | ------------ |
|and   |Intersectikon   |
|or   |Union   |
|unless   |Complement   |

1、and的应用案例
```
1. 使用下面的案例:
node_filesystem_avail_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/"}
node_filesystem_avail_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/boot"}
node_filesystem_size_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/"}
node_filesystem_size_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/boot"}


2. 应用如下表达式:
node_filesystem_size_bytes and node_filesystem_size_bytes < 2000000000


3. 返回如下结果:
node_filesystem_size_bytes{device="/dev/sda1",fstype="xfs",instance="192.168.20.113:9100",job="node",mountpoint="/boot"}	1063256064
node_filesystem_size_bytes{device="tmpfs",fstype="tmpfs",instance="192.168.20.113:9100",job="node",mountpoint="/run"}	1986519040
node_filesystem_size_bytes{device="tmpfs",fstype="tmpfs",instance="192.168.20.113:9100",job="node",mountpoint="/run/user/0"}
```

2 or的应用案例
```
node_filesystem_avail_bytes > 200000 or node_filesystem_avail_bytes < 2500000
```

3 unless应用案例

unless逻辑运算符将返回第一个表达式中与第二个表达式的标签名/值对不匹配的元素。在集合理论中，这叫做补集。实际上，这个操作符的工作方式与and相反，这意味着它也可以用作if not语句。
```
node_filesystem_avail_bytes unless node_filesystem_avail_bytes < 200000
```


向量匹配
---
由于二进制操作符需要两个操作数，当相同大小和标签集的向量位于一个操作符(即一对一)的每一侧时，将具有完全相同的标签/值对的样本匹配在一起，同时删除度量名称和所有不匹配的元素。

- 一对一（one-to-one）
- 多对一（many-to-one）或一对多（one-to-many）

1、one-to-one

由于二进制操作符需要两个操作数，当相同大小和标签集的向量位于一个操作符(即一对一)的每一侧时，将具有完全相同的标签/值对的样本匹配在一起，同时删除度量名称和所有不匹配的元素。

```
1. 如下案例将会是我们使用的即时向量:
node_filesystem_avail_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/"}
node_filesystem_avail_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/boot"}
node_filesystem_size_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/"}
node_filesystem_size_bytes{instance="192.168.20.113:9100", job="node", mountpoint="/boot"}

2. 应用如下操作:
node_filesystem_avail_bytes{} / node_filesystem_size_bytes{} * 100

3. 将会返回如下的瞬时向量:
{device="/dev/mapper/centos-root",fstype="xfs",instance="192.168.20.113:9100",job="node",mountpoint="/"}	86.614480029033
{device="/dev/sda1",fstype="xfs",instance="192.168.20.113:9100",job="node",mountpoint="/boot"}	81.76120253944774
{device="rootfs",fstype="rootfs",instance="192.168.20.113:9100",job="node",mountpoint="/"}	86.614480029033
{device="tmpfs",fstype="tmpfs",instance="192.168.20.113:9100",job="node",mountpoint="/run"}	99.12616754984639
{device="tmpfs",fstype="tmpfs",instance="192.168.20.113:9100",job="node",mountpoint="/run/user/0"}	100
```

2、Many-to-one和one-to-many

需要执行这样的操作:一边的元素与另一边的几个元素相匹配。当这种情况发生时，您需要向普罗米修斯提供解释这种操作的方法。如果较高的基数在操作的左侧,你可以在`on`或`ignoring`后使用`group_left`修饰符; 假如在它的右侧,那么可以使用`group_right`. 

聚合操作
---
通过使用聚合操作符，我们可以获取一个即时向量并聚合它的元素，从而得到一个新的即时向量，通常包含更少的元素。像这样的即时向量的每次聚合都以我们在垂直聚合中描述的方式工作.

|操作符   |描述   | 必须|
| ------------ | ------------ | -----------|
|sum   |元素的和   |
|min   |选择最小的元素   |
|max   |选择最大的元素   |
|avg   |计算元素的平均值   |
|stddev |计算元素的标准差   |
|stdvar   |计算元素的标准方差   |
|count   |计算元素的数量   |
|count_values   |计算具有相同值的元素的数目   |
|bottomk   |k以下的元素   |请求使用一个(K)作为标尺|
|topq   |k以上的元素   |请求使用一个(K)作为标尺 |
|quantile   |计算元素的分位数   |Requires the quantile (0 ≤ φ ≤ 1) definition as a scalar |

```
1、使用以下查询的样本数据
rate(prometheus_http_requests_total[5m])

{code="200",handler="/metrics",instance="localhost:9090",job="prometheus"}	0.2
{code="200",handler="/api/v1/query",instance="localhost:9090",job="prometheus"}	0.010169491525423728
{code="400",handler="/api/v1/query",instance="localhost:9090",job="prometheus"}	0

2、如果想所有请求的总和，可以应用以下表达式:
sum(rate(prometheus_http_requests_total[5m]))

{}	0.21355932203389832

3、如果想添加by操作符，可以通过处理程序端点聚合:
sum by (handler)(rate(prometheus_http_requests_total[5m]))

{handler="/metrics"}	0.2
{handler="/api/v1/query"}	0.01694915254237288
```

这些操作符被用于聚合所有标签维度，或者通过 without 或者 by 子语句来保留不同的维度。
- without 用于从计算结果中移除列举的标签，而保留其它标签。
- by 则正好相反，结果向量中只保留列出的标签，其余标签则移除。

1、通过 without 和 by 可以按照样本的问题对数据进行聚合。

如果指标 http_requests_total 的时间序列的标签集为 application, instance, 和 group，可以通过以下方式计算所有 instance 中每个 application 和 group 的请求总量：
```
sum(http_requests_total) without (instance)
等价于
sum(http_requests_total) by (application, group)
```

2、计算整个应用的 HTTP 请求总量
```
sum(http_requests_total)
```
count_values 用于时间序列中每一个样本值出现的次数。count_values 会为每一个唯一的样本值输出一个时间序列，并且每一个时间序列包含一个额外的标签。

这个标签的名字由聚合参数指定，同时这个标签值是唯一的样本值。

例如要计算运行每个构建版本的二进制文件的数量：
```
count_values("version", build_version)

{count="641"}   1
{count="3226"}  2
{count="644"}   4
```

3、topk 和 bottomk则用于对样本值进行排序，返回当前样本值前 n 位，或者后 n 位的时间序列。

获取 HTTP 请求数前 5 位的时序样本数据
```
topk(5, http_requests_total)
```

4、quantile 用于计算当前样本数据值的分布情况 quantile(φ, express) ，其中 0 ≤ φ ≤ 1

当 φ 为 0.5 时，即表示找到当前样本数据中的中位数：
```
quantile(0.5, http_requests_total)

{}   656
```

操作优先级
---
当使用PromQL查询时，应用二进制操作符的顺序由操作符优先级决定。

|优先级   |操作符   |描述   |
| ------------ | ------------ | ------------ |
|1   |^   |Evaluated right to left, for example, 1 ^ 2 ^ 3 is evaluated as 1 ^ (2 ^ 3)   |
|2  |*, /, %   |Evaluated left to right, for example, 1 / 2 * 3 is evaluated as (1 / 2) * 3   |
|3   |+, -   |Evaluated left to right   |
|4   |==, !=, <=, <, >=, >  |Evaluated left to right   |
|5   |and , unless   |Evaluated left to right   |
|6   |or   |Evaluated left to right   |

内置函数
---
官网介绍  
https://prometheus.io/docs/prometheus/latest/querying/functions/

PromQL对于各种用例(比如math)有近50个不同的函数;排序;计数器、gauge和直方图操作;标签转换;随着时间的推移聚合;类型转换;最后是日期和时间函数。

| 内置函数 |
|-------|
| abs() |
| absent() |
| absent_over_time() |
| ceil() |
| changes()	|
| clamp_max()	|
| clamp_min()	|
| day_of_month() |
| day_of_week()	|
| days_in_month()	|
| delta()	|
| deriv()	|
| exp()	|
| floor()	|
| histogram_quantile() |
| holt_winters() |
| hour() |
| idelta() |
| increase() |
| irate()	|
| label_join() |
| label_replace()	|
| ln() |
| log2() |
| log10()	|
| minute() |
| month()	|
| predict_linear() |
| rate() |
| resets() |
| round() |
| scalar() |
| sort() |
| sort_desc()	|
| sqrt() |
| time() |
| timestamp() |
| vector() |
| year() |

1、absent()函数的作用是:获取一个瞬时向量作为参数，并返回以下内容:
- 如果传递给它的向量参数具有样本数据，则返回空向量；
- 如果传递的向量参数没有样本数据，则返回不带度量指标名称且带有标签的时间序列，且样本值为1。

1)当监控度量指标时，如果获取到的样本数据是空的， 使用 absent 方法对告警是非常有用的。例如：
```
absent(prometheus_http_requests_total)
no data
```

2) 我们使用一个表达式与标签matcher使用不存在的标签值，就像下面的例子:

```
absent(prometheus_http_requests_total2)
{}	1
```



2、lable_join()和lable_replace()

这些函数用于操作标签—它们允许您将标签连接到其他标签，提取标签值的一部分，甚至删除标签(尽管使用标准的聚合操作更容易、更符合人体工程学)。在这两个函数中，如果定义的目标标签是一个新的，它将被添加到标签集;如果它是一个现有的标签，它将被取代。

1. 在使用label_join时，您需要提供一个即时向量，定义一个结果标签，识别结果连接的分隔符，并建立要连接的标签，如下面的语法所示:
```
label_join(<vector>, <resulting_label>, <separator>, source_label1, source_labelN)
```

```
# 1、按例
http_requests_total{code="200",endpoint="hey-port", handler="/",instance="172.17.0.10:8000",job="hey-service",method="get"} 1366
http_requests_total{code="200",endpoint="hey-port", handler="/health",instance="172.17.0.10:8000",job="hey-service",method="get"} 942

# 2、应用如下表达式
label_join(http_requests_total{instance="172.17.0.10:8000"}, "url", "", "instance", "handler")

# 3、得到如下的瞬时向量:
http_requests_total{code="200",endpoint="hey-port", handler="/",instance="172.17.0.10:8000",job="hey-service", method="get",url="172.17.0.10:8000/"} 1366
http_requests_total{code="200",endpoint="hey-port", handler="/health",instance="172.17.0.10:8000",job="hey-service", method="get",url="172.17.0.10:8000/health"} 942
```

当需要对标签进行任意操作时，可以使用label_replace函数。它的工作方式是将正则表达式应用于所选源标签的值，并将匹配的捕获组存储在目标标签上。源和目标可以是同一个标签，有效地替换其值。这听起来很复杂，但实际上并不复杂;让我们来看看label_replace的语法
```
label_replace(<vector>, <destination_label>, <regex_match_result>, <source_label>, <regex>)
```

假设我们使用前面的示例数据并应用下面的表达式：

```
label_replace(http_requests_total{instance="172.17.0.10:8000"}, "port", "$1", "instance", ".*:(.*)")
```
然后，结果将是与新标签(称为port)匹配的元素:

```
http_requests_total{code="200",endpoint="hey-port",handler="/", instance="172.17.0.10:8000", job="hey-service",method="get",port="8000"} 1366
http_requests_total{code="200",endpoint="hey-port",handler="/health", instance="172.17.0.10:8000", job="hey-service",method="get",port="8000"} 942
```

在使用label_replace时，如果正则表达式与标签值不匹配，则原始时间序列将不加更改地返回。

3、predict_linear()

predict_linear(v range-vector, t scalar) 函数可以预测时间序列 v 在 t 秒后的值。它基于简单线性回归的方式，对时间窗口内的样本数据进行统计，从而可以对时间序列的变化趋势做出预测。该函数的返回结果不带有度量指标，只有标签列表。

例如，基于 2 小时的样本数据，来预测主机可用磁盘空间的是否在 4 个小时候被占满，可以使用如下表达式：

```
predict_linear(node_filesystem_free{job="node"}[2h], 4 * 3600) < 0
```

我们将应用下面的表达式，它使用一个1小时数据范围内的predict_linear，并推断出未来4小时的样本值(60(秒)* 60(分钟)* 4):

```
predict_linear(node_filesystem_free_bytes{mountpoint="/data"}[1h], 60 * 60 * 4)

{device="/dev/sda1", endpoint="node-exporter",fstype="ext4",instance="10.0.2.15:9100", job="node-exporter-service",mountpoint="/data", namespace="monitoring", pod="node-exporter-r88r6", service="node-exporter-service"} 15578514805.533087
```

4、rate()和irate()

rate(v range-vector) 函数可以直接计算区间向量 v 在时间窗口内平均增长速率，它会在单调性发生变化时(如由于采样目标重启引起的计数器复位)自动中断。该函数的返回结果不带有度量指标，只有标签列表。

例如，以下表达式返回区间向量中每个时间序列过去 5 分钟内 HTTP 请求数的每秒增长率：
```
rate(http_requests_total[5m])
结果：
{code="200",handler="label_values",instance="120.77.65.193:9090",job="prometheus",method="get"} 0
{code="200",handler="query_range",instance="120.77.65.193:9090",job="prometheus",method="get"} 0
{code="200",handler="prometheus",instance="120.77.65.193:9090",job="prometheus",method="get"} 0.2
```

irate(v range-vector) 函数用于计算区间向量的增长率，但是其反应出的是瞬时增长率。irate 函数是通过区间向量中最后两个两本数据来计算区间向量的增长速率，它会在单调性发生变化时(如由于采样目标重启引起的计数器复位)自动中断。这种方式可以避免在时间窗口范围内的“长尾问题”，并且体现出更好的灵敏度，通过irate函数绘制的图标能够更好的反应样本数据的瞬时变化状态。

例如，以下表达式返回区间向量中每个时间序列过去 5 分钟内最后两个样本数据的 HTTP 请求数的增长率：

```
irate(http_requests_total{job="api-server"}[5m])
```

irate 只能用于绘制快速变化的计数器，在长期趋势分析或者告警中更推荐使用 rate 函数。因为使用 irate 函数时，速率的简短变化会重置 FOR 语句，形成的图形有很多波峰，难以阅读。

6、sort()和sort_desc()

顾名思义，sort接收一个向量并根据样本值按升序排序，而sort_desc执行相同的函数，但按降序排序。


API访问
---

https://prometheus.io/docs/prometheus/latest/querying/api/


Prometheus当前稳定的HTTP API可以通过/api/v1访问

错误状态码：
- 200 success：调用成功的返回状态码
- 404 Bad Request：当参数错误或者缺失时。
- 422 Unprocessable Entity 当表达式无法执行时。
- 503 Service Unavailiable 当请求超时或者被中断时。

所有的API请求均使用以下的JSON格式：
```
{
  "status": "success" | "error",
  "data": <data>,

  // 为error时，有如下报错信息
  "errorType": "<string>",
  "error": "<string>"
}
```
通过HTTP API可以分别通过/api/v1/query和/api/v1/query_range查询PromQL表达式当前或者一定时间范围内的计算结果。

1、瞬时数据查询

URL请求参数：
- query=：PromQL表达式。
- time=：用于指定用于计算PromQL的时间戳。可选参数，默认情况下使用当前系统时间。
- timeout=：超时设置。可选参数，默认情况下使用-query,timeout的全局设置。
    
```
$ curl 'http://localhost:9090/api/v1/query?query=up&time=2015-07-01T20:10:51.781Z'

{
   "status" : "success",
   "data" : {
      "resultType" : "vector",
      "result" : [
         {
            "metric" : {
               "__name__" : "up",
               "job" : "prometheus",
               "instance" : "localhost:9090"
            },
            "value": [ 1435781451.781, "1" ]
         },
         {
            "metric" : {
               "__name__" : "up",
               "job" : "node",
               "instance" : "localhost:9100"
            },
            "value" : [ 1435781451.781, "0" ]
         }
      ]
   }
}
```

2、区间查询

URL请求参数：
- query=: PromQL表达式。
- start=: 起始时间。
- end=: 结束时间。
- step=: 查询步长。
- timeout=: 超时设置。可选参数，默认情况下使用-query,timeout的全局设置。
- 
```
$ curl 'http://localhost:9090/api/v1/query_range?query=up&start=2015-07-01T20:10:30.781Z&end=2015-07-01T20:11:00.781Z&step=15s'

{
   "status" : "success",
   "data" : {
      "resultType" : "matrix",
      "result" : [
         {
            "metric" : {
               "__name__" : "up",
               "job" : "prometheus",
               "instance" : "localhost:9090"
            },
            "values" : [
               [ 1435781430.781, "1" ],
               [ 1435781445.781, "1" ],
               [ 1435781460.781, "1" ]
            ]
         },
         {
            "metric" : {
               "__name__" : "up",
               "job" : "node",
               "instance" : "localhost:9091"
            },
            "values" : [
               [ 1435781430.781, "0" ],
               [ 1435781445.781, "0" ],
               [ 1435781460.781, "1" ]
            ]
         }
      ]
   }
}
```
