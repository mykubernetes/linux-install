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

1、counter
- 通常，Counter的总数并没有直接作用，而是需要借助于rate、topk、increase和irate等函数来生成样本数据的变化状况（增长率）；
  - rate(http_requests_total[2h])，获取2小内，该指标下各时间序列上的http总请求数的增长速率；
  - topk(3, http_requests_total)，获取该指标下http请求总数排名前3的时间序列；
  - irate(http_requests_total[2h])，高灵敏度函数，用于计算指标的瞬时速率；
    - 基于样本范围内的最后两个样本进行计算，相较于rate函数来说，irate更适用于短期时间范围内的变化速率分析；

2、Gauge
- Gauge用于存储其值可增可减的指标的样本数据，常用于进行求和、取平均值、最小值、最大值等聚合计算；也会经常结合PromQL的predict_linear和delta函数使用；
  - predict_linear(v range-vector, t, scalar)函数可以预测时间序列v在t秒后的值，它通过线性回归的方式来预测样本数据的Gauge变化趋势；
  - delta(v range-vector)函数计算范围向量中每个时间序列元素的第一个值与最后一个值之差，从而展示不同时间点上的样本值的差值；
    - delta(cpu_temp_celsius{host="web01.magedu.com"}[2h])，返回该服务器上的CPU温度与2小时之前的差异；

3、Histogram
- Histogram是一种对数据分布情况的图形表示，由一系列高度不等的长条图（bar）或线段表示，用于 展示单个测度的值的分布
  - 它一般用横轴表示某个指标维度的数据取值区间，用纵轴表示样本统计的频率或频数，从而能够以二维图的形式展现数值的分布状况
  - 为了构建Histogram，首先需要将值的范围进行分段，即将所有值的整个可用范围分成一系列连续、相邻（相邻处可以是等同值）但不重叠的间隔，而后统计每个间隔中有多少值
  -  从统计学的角度看，分位数不能被聚合，也不能进行算术运算；
- 对于Prometheus来说，Histogram会在一段时间范围内对数据进行采样（通常是请求持续时长或响应大小等），并将其计入可配置的bucket（存储桶）中
  - Histogram事先将特定测度可能的取值范围分隔为多个样本空间，并通过对落入bucket内的观测值进行计数以及求和操作
  - 与常规方式略有不同的是，Prometheus取值间隔的划分采用的是累积（Cumulative）区间间隔机制，即每个bucket中的样本均包含了其前面所有bucket中的样本，因而也称为累积直方图
    - 可降低Histogram的维护成本
    - 支持粗略计算样本值的分位数
    - 单独提供了_sum和_count指标，从而支持计算平均值
- Histogram类型的每个指标有一个基础指标名称<basename>，它会提供多个时间序列：
  - <basename>_bucket{le="<upper inclusive bound>"}：观测桶的上边界（upper inclusivebound），即样本统计区间，最大区间（包含所有样本）的名称为<basename>_bucket{le="+Inf"}；
  - <basename>_sum：所有样本观测值的总和；
  - <basename>_count ：总的观测次数，它自身本质上是一个Counter类型的指标；
- 累积间隔机制生成的样本数据需要额外使用内置的histogram_quantile()函数即可根据Histogram指标来计算相应的分位数（quantile），即某个bucket的样本数在所有样本数中占据的比例
  - histogram_quantile()函数在计算分位数时会假定每个区间内的样本满足线性分布状态，因而它的结果仅是一个预估值，并不完全准确；
  - 预估的准确度取决于bucket区间划分的粒度；粒度越大，准确度越低；

4、
- 指标类型是客户端库的特性，而Histogram在客户端仅是简单的桶划分和分桶计数，分位数计算由Prometheus Server基于样本数据进行估算，因而其结果未必准确，甚至不合理的bucket划分会导致较大的误差；
- Summary是一种类似于Histogram的指标类型，但它在客户端于一段时间内（默认为10分钟）的每个采样点进行统计，计算并存储了分位数数值，Server端直接抓取相应值即可；
- 但Summary不支持sum或avg一类的聚合运算，而且其分位数由客户端计算并生成，Server端无法获取客户端未定义的分位数，而Histogram可通过PromQL任意定义，有着较好的灵活性；
- 对于每个指标，Summary以指标名称<basename>为前缀，生成如下几个个指标序列
  - <basename>{quantile="<φ>"}，其中φ是分位点，其取值范围是(0 ≤φ≤ 1)；计数器类型指标；如下是几种典型的常用分位点；
    - 0、0.25、0.5、0.75和1几个分位点；
    - 0.5、0.9和0.99几个分位点；
    - 0.01、0.05、0.5、0.9和0.99几个分位点；
  - <basename>_sum，抓取到的所有样本值之和；
  - <basename>_count，抓取到的所有样本总数；
  
标签匹配器
---
```
http_requests_total{job="prometheus",group="canary"}
```
匹配器用于定义标签过滤条件，目前支持4种匹配操作符
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
http_requests_total{job="prometheus",group="canary"}
```

2、范围向量
```
http_requests_total{job="prometheus",group="canary"}[5m]
```

- ms -毫秒
- s - 秒
- m - 分钟
- h - 小时
- d - 天
- w - 周
- y - 年

必须使用整数时间，且能够将多个不同级别的单位进行串联组合，以时间单位由大到小为顺序，例如1h30m，但不能使用1.5h

3、在两个标量之间进行数学运算，得到的结果也是标量。
```
# 根据 node_disk_bytes_written 和 node_disk_bytes_read 获取主机磁盘IO的总量
node_disk_bytes_written + node_disk_bytes_read

# node的内存数GB
node_memory_free_bytes_total / (1024 * 1024)
```

偏移量修改器
---

- 默认情况下，即时向量选择器和范围向量选择器都以当前时间为基准时间点，而偏移量修改器能够修改该基准；
- 偏移量修改器的使用方法是紧跟在选择器表达式之后使用“offset”关键字指定
  - “http_requests_total offset 5m”，表示获取以http_requests_total为指标名称的所有时间序列在过去5分钟之时的即时样本；
  - “http_requests_total[5m] offset 1d”，表示获取距此刻1天时间之前的5分钟之内的所有样本；


操作符
---
Prometheus 的查询语言支持基本的逻辑运算和算术运算
```
二元算术运算：
- + 加法
- - 减法
- * 乘法
- / 除法
- % 模
- ^ 幂等
```

布尔运算
---
```
- == (相等)
- != (不相等)
- > (大于)
- < (小于)
- >= (大于等于)
- <= (小于等于)
```
获取http_requests_total请求总数是否超过10000，返回0和1，1则报警
```
http_requests_total > 10000             # 结果为 true 或 false
http_requests_total > bool 10000        # 结果为 1 或 0
```


集合运算
---
- and (并且)
- or (或者)
- unless (排除)

优先级
---
查询主机的CPU使用率
```
100 * (1 - avg (irate(node_cpu{mode='idle'}[5m])) by(job) )
```
在PromQL操作符中优先级由高到低依次为
- ^
- *, /, %
- +, -
- ==, !=, <=, <, >=, >
- and, unless
- or

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
Prometheus 还提供了下列内置的聚合操作符，这些操作符作用域瞬时向量。可以将瞬时表达式返回的样本数据进行聚合，形成一个具有较少样本值的新的时间序列。

- sum (求和)
- min (最小值)
- max (最大值)
- avg (平均值)
- stddev (标准差)
- stdvar (标准差异)
- count (计数)
- count_values (对 value 进行计数)
- bottomk (样本值最小的 k 个元素)
- topk (样本值最大的k个元素)
- quantile (分布统计)

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

内置函数
---
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
