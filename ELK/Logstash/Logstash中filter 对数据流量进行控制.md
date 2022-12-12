# 一、Logstash过滤器对数据流量进行控制

Logstash提供了一些插件用来控制数据传输的流量。这个流量控制主要是：
- 削减数据量，剪除掉不需要的数据内容
- 控制数据来源的速度，减少想目标推送数据的频率

涉及这些操作的过滤器主要是下面：
- drop过滤器：删除掉经过过滤器的事件
- prune过滤器: 设置黑白名单，只允许部分字段或者禁止部分字段数据进行传输
- sleep过滤器：休眠过滤器，设置数据传输的最短间隔
- throttle过滤器：是一种限制一段时间内事件数量的过滤器

# 二、drop

此过滤器的作用是删除到达此过滤器的所有内容。这一个过滤器在日志收集上使用非常广泛，程序有时候会写入大量日志内容，但是很多日志内容并不是需要的内容。这些日志不仅消耗大量的磁盘空间，而且对数据查询也可能带来影响。

**可配置参数**

此过滤器可配置的非公共参数只有`percentage`。其配置内容为0-100。表示删除通过此过滤器数据的比例。0为不删除、100为完全删除。

**使用方式**

下面的demo就是使用drop过滤器来屏蔽不使用的日志信息。

日志数据

一般说起来我们的日志内容大概是这样子的
```
2020-05-19 10:59:25.844  INFO 10724 [main-1] o.s.j.e.a.AnnotationMBeanExporter: Registering beans for JMX exposure on startup
```
因为有的时候我们系统和业务上都会打印一些INFO甚至DEBUG日志，这些日志很可能并不是我们需要的内容，所以需要通过drop过滤器用来移除。

配置

使用下面的配置，可以将上面的日志内容进行解析然后通过drop过滤掉未能解析的或者INFO级别的日志
```
filter {
	grok {
		match => { "message" => "%{TIMESTAMP_ISO8601:log_date}  %{LOGLEVEL:log_info} %{DATA:thread} %{NOTSPACE} %{SPACE} %{NOTSPACE} %{JAVACLASS:log_class} %{SPACE}: %{GREEDYDATA:log_message}" }
	}
	if "_grokparsefailure" in [tags] {
		drop {}
	}
	if [log_info] == "INFO" {
		drop {}
	}
}	
```

控制台

现在发送三条消息依次是上面日志的INFO、WARN、ERROR版本，最后可以看到控制台打印内容



只打印了两条信息

# 三、prune

prune过滤器用于根据字段名或其值(名称和值也可以是正则表达式)的白名单或黑名单从事件中删除字段。此过滤器提供了两种选择，一种是指定允许通过的字段内容，一种是指定了不允许通过的字段内容。配置此参数的时候需要考虑实际情况。使用此过滤器的时机主要是当事件存在多种字段，但是一些字段并不是业务中需要或者只有部分字段是业务需要的时候使用的。

**可配置参数**

| 参数 | 作用 |
|------|------|
| blacklist_names | 需要被排除的名单 |
| blacklist_values | 需要被排除字段中的指定值 |
| interpolate |  |
| whitelist_names | 允许被通过的字段 |
| whitelist_values | 允许被通过的字段的值 |

**使用方式**

配置

使用下面配置，限制只通过name字段
```
filter {
	prune {
		whitelist_names => [ "name" ]
	}	
}	
```

或者使用下面配置，禁止掉字段中固定值的获取
```
filter {
	prune {
		blacklist_values  => [ "name","test message:3" ]
	}	
}	
```

请求测试

现在使用下面两条数据分布请求对应filter的通道，尝试获取结果：

- 使用下面数据请求`whitelist_names`的配置
```
{"age":10,"name":"test message:"}
```

返回结果，只有name显示了出来

- 使用下面请求blacklist_values的配置
```

{"age":1,"name":"test message:1"}
{"age":2,"name":"test message:2"}
{"age":3,"name":"test message:3"}
{"age":4,"name":"test message:4"}
{"age":5,"name":"test message:5"}
```

返回结果，此时第三条数据中name字段没有了，同时增加了tag内容



# 四、sleep

sleep过滤器的作用是让logstash在指定的时间内停止运行。使用这种方式会强制性的限制每条事件进过logstash的最低间隔。使用此过滤器可以明显的限制数据的传输速率。

**可配置的参数**

| 参数 | 描述 |
|------|------|
| every | 配置每经历一定数量的事件之后执行睡眠操作 |
| replay | 启用重播模式 |
| time | 每个事件的睡眠时间长度 |

让速度慢下来
```
filter {
	sleep {
		time => "1"   
		every => 3   
	}		
}	
```

使用上面的配置可以让logstash没接收到3条消息就强制的停止1秒钟。这个时候我们发送10条数据,可以看到速度有一个明显的减缓。
```
test message:1; send time:1589868027500
```

**重播模式**

sleep过滤器提供了replay参数来实现重播模式。而重播模式是一种弹性的休眠。具体的休眠时间为：(当前事件的时间戳中)-(前一个事件的时间戳)。而在次模式下time不再表示时间，而是一个时间放大系数，比如设置为0.25则表示1/4的速度重放，设置为2则为2倍速度重放。

使用方式

配置

下面配置就是使用的重放模式，此配置表示间隔时间将以0.5倍速度重放。现在以每1秒一条数据向队列中发送消息，这个时候每条数据会以2秒（1/0.5）的速度去处理事件
```
filter {
	  sleep {
		time => 0.5
		replay => true
	  }	
}
```

**关于sleep插件**

之前查看文档的时候，发现这个插件只有3个可以配置的参数，功能也简单所以觉得应该是一个比较简单的filter。但实际中几个关于数据流量控制的filter中，此filter消耗了我最多的时间。sleep目前的问题有这些：

- 按照文档的说法sleep在进行执行的时候整个logstash都会被暂停，但是实际上logstash拉取数据并不是一次拉取一条（实际上真正应用环境下也不会这样），最终输出的时间戳为事件到达logstash的时间，除非人肉观察根据时间戳是没法得出每条消息是否有间隔。
- 消息并不是总能按照配置进行休眠。在非重放模式下，消息经常在睡眠结束后，多条消息同时刷出。并没有设想中的休眠。

鉴于sleep可配置的参数不多，且文档描述也不算很多，而在网上其他关于sleep的内容也很稀少。其源码地址在这里：https://github.com/logstash-plugins/logstash-filter-sleep 但是因为自己并未接触过Ruby语言，所以暂时没办法通过其代码逻辑判断是个人理解错误还是其他问题。

# 五、throttle

sleep过滤器用来控制事件的速率而throttle过滤器则是用来控制事件的数量。

**可配置参数**

| 参数 | 描述 |
|------|------|
| after_count | 大于此计数的事件将被限制 |
| before_count | 少于此计数的事件将被限制 |
| key | 用于标识事件的密钥。具有相同键的事件被分组在一起。 |
| max_age | 一个时隙的最大年龄。较高的值可以更好地跟踪事件的异步流，但需要更多的内存。根据经验，应将此值至少设置为周期的两倍。 |
| max_counters | 减少时隙的最大期限之前要存储的最大计数器数 |
| period | 从首次发生事件到创建新时隙之间的时间 |

throttle过滤器控制事件需要两个方面的设置：对周期的定义、周期内的事件数量。

对周期的定义
- period: 此参数定义了一个周期的长度，当logstash没有在周期中的时候，接收到第一个事件则会创建一个新的周期。
- max_counters: 此参数限制了一个周期内存储的计数器的最大数量。因为涉及到周期内事件数量的控制，过滤器需要进行事件计数，此配置值应仅用作内存控制机制，如果达到此值，可能会导致计数器提前过期。
- max_age: 时间段的最大年龄。更高的值允许更好地跟踪异步事件流，但是需要更多的内存。根据经验，您应该将此值设置为周期至少两倍。

周期内的事件数量
- before_count :对接收事件下限的控制，当周期内接收的事件数量低于此值的时候则被设置为throttled
- after_count: 对接收事件上限的控制，当周期内接收的事件数量高于此值的时候则被设置为throttled

使用方式

配置
```
filter {
  throttle {
	before_count => -1
	after_count => 5
	period => 20
	max_age => 40
	key => "%{userType}"
	add_tag => "throttled"
  }
}
```

在上面配置中，设置了一个20秒只接收5条数据的限制，同时设置了时间间隔最长40秒的限制。

现在分别进行三批数据请求：

1、2秒一次发送20词，会在中间被被标记throttled
```
{"age":1,"name":"test1 message:1","userType":1}
```


此时会发现中间5条数据因为在一个周期（20秒）内因为超过了5条被标注为节流。而20秒后新来的数据会进入一个新的周期，此时不再被throttled

2、上面userType内容改为递增，2秒一次发送20词，则全程不会被标记throttled
{"age":1,"name":"test1 message:1","userType":1}
{"age":1,"name":"test1 message:1","userType":2}
{"age":1,"name":"test1 message:1","userType":3}
......
