Metric类型
---
Prometheus会将所有采集到的样本数据以时间序列（time-series）的方式保存在内存数据库TSDB中，并且定时保存到硬盘上。time-series是按照时间戳和值的序列顺序存放的，我们称之为向量(vector)。每条time-series通过指标名称(metrics name)和一组标签集(labelset)命名。

在time-series中的每一个点称为一个样本（sample），样本由以下三部分组成：
- 指标(metric)：metric name和描述当前样本特征的labelsets;
- 时间戳(timestamp)：一个精确到毫秒的时间戳;
- 样本值(value)： 一个folat64的浮点型数据表示当前样本的值。

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


集合运算
---
- and (并且)
- or (或者)
- unless (排除)


匹配模式（联合查询）
---
与数据库中的join类似，promsql有两种典型的匹配查询：

- 一对一（one-to-one）
- 多对一（many-to-one）或一对多（one-to-many）

例如当存在样本：
```
method_code:http_errors:rate5m{method="get", code="500"}  24
method_code:http_errors:rate5m{method="get", code="404"}  30
method_code:http_errors:rate5m{method="put", code="501"}  3
method_code:http_errors:rate5m{method="post", code="500"} 6
method_code:http_errors:rate5m{method="post", code="404"} 21

method:http_requests:rate5m{method="get"}  600
method:http_requests:rate5m{method="del"}  34
method:http_requests:rate5m{method="post"} 120
```
使用 PromQL 表达式：
```
method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m

{method="get"} 0.04 // 24 / 600
{method="post"} 0.05 // 6 / 120
```
该表达式会返回在过去 5 分钟内，HTTP 请求状态码为 500 的在所有请求中的比例。如果没有使用 ignoring(code)，操作符两边表达式返回的瞬时向量中将找不到任何一个标签完全相同的匹配项。


同时由于 method 为 put 和 del 的样本找不到匹配项，因此不会出现在结果当中。

多对一模式

```
method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
```
该表达式中，左向量 method_code:http_errors:rate5m 包含两个标签 method 和 code。而右向量 method:http_requests:rate5m 中只包含一个标签 method，因此匹配时需要使用 ignoring 限定匹配的标签为 code。

在限定匹配标签后，右向量中的元素可能匹配到多个左向量中的元素 因此该表达式的匹配模式为多对一，需要使用 group 修饰符 group_left 指定左向量具有更好的基数。

最终的运算结果如下：
```
{method="get", code="500"} 0.04 // 24 / 600
{method="get", code="404"} 0.05 // 30 / 600
{method="post", code="500"} 0.05 // 6 / 120
{method="post", code="404"} 0.175 // 21 / 120
```
提醒：group 修饰符只能在比较和数学运算符中使用。在逻辑运算 and，unless 和 or 操作中默认与右向量中的所有元素进行匹配。

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

https://prometheus.io/docs/prometheus/latest/querying/functions/

Prometheus 提供了其它大量的内置函数，可以对时序数据进行丰富的处理。如上文提到的irate
```
100 * (1 - avg (irate(node_cpu{mode='idle'}[5m])) by(job) )
```
常用的有两分钟内的平均CPU使用率：
```
rate(node_cpu[2m])
irate(node_cpu[2m])
```

```
需要注意的是使用rate或者increase函数去计算样本的平均增长速率，容易陷入“长尾问题”当中，

其无法反应在时间窗口内样本数据的突发变化。 

例如，对于主机而言在2分钟的时间窗口内，可能在某一个由于访问量或者其它问题导致CPU占用100%的情况，

但是通过计算在时间窗口内的平均增长率却无法反应出该问题。

为了解决该问题，PromQL提供了另外一个灵敏度更高的函数irate(v range-vector)。

irate同样用于计算区间向量的计算率，但是其反应出的是瞬时增长率。

irate函数是通过区间向量中最后两个两本数据来计算区间向量的增长速率。

这种方式可以避免在时间窗口范围内的“长尾问题”，并且体现出更好的灵敏度，通过irate函数绘制的图标能够更好的反应样本数据的瞬时变化状态。

irate函数相比于rate函数提供了更高的灵敏度，不过当需要分析长期趋势或者在告警规则中，irate的这种灵敏度反而容易造成干扰。

因此在长期趋势分析或者告警中更推荐使用rate函数。
```

完整的函数列表为：
- abs()
- absent()
- ceil()
- changes()
- clamp_max()
- clamp_min()
- day_of_month()
- day_of_week()
- days_in_month()
- delta()
- deriv()
- exp()
- floor()
- histogram_quantile()
- holt_winters()
- hour()
- idelta()
- increase()
- irate()
- label_join()
- label_replace()
- ln()
- log2()
- log10()
- minute()
- month()
- predict_linear()
- rate()
- resets()
- round()
- scalar()
- sort()
- sort_desc()
- sqrt()
- time()
- timestamp()
- vector()
- year()
- <aggregation>_over_time()

API访问
---
Prometheus当前稳定的HTTP API可以通过/api/v1访问

错误状态码：
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

瞬时数据查询
---
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

区间查询
---
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
