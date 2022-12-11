# logstash监控api 

节点详情：
```
http://localhost:9600/_node?pretty
```

插件详情：
```
http://localhost:9600/_node/plugins?pretty

```
节点运行状态详情：
```
http://localhost:9600/_node/stats?pretty
```

hot threads 详情：
```
http://localhost:9600/_node/hot_threads?pretty
```

# Logstash plugins

- 运行 Logstash 实例时，除了启动配置的管道外，它还会在端口 9600 上启动 Logstash 监视 API 端点。请注意，Logstash 监视 API仅在 Logstash 5.0+  及更高版本中可用。我们可以在浏览器中的如下地址查看我们安装的所有 plugins：

```
http://localhost:9600/_node/plugins?pretty
```

响应
```
{
   "host" : "liuxg-2.local",
   "version" : "7.5.0",
   "http_address" : "127.0.0.1:9600",
   "id': "15fec877-09df-4e6f-8fb6-4f5f-a94b-d682db3f9a94",
   "name": "liuxg-2.local",
   "ephemeral_id": "21850958-ad17-4f5f-a94b-d682db3f9a94",
   "status": "green",
   "snapshot": "false"，
   "pipeline": {
     "workers": 16,
     "batch_size": 125,
     "batch_delay": 50
   }
   "total" : 103,
   "plugins" : [ {
      "name" : "logstash-codec-collectd",
      "version" : "3.0.2"
   },
   {
      "name" : "logstash-codec-dots",
      "version" : "3.0.2"
   },
   {
      "name" : "logstash-codec-edn",
      "version" : "3.0.2"
   },
   {
      "name" : "logstash-codec-edn_lines",
      "version" : "3.0.2"
   },
   ............
}
```
Logstash 是一个非常容易进行扩张的框架。它可以对各种的数据进行分析处理。这依赖于目前提供的超过 200 多个 plugin。首先，我们来查看一下目前有哪些 plugin：

## Input plugins:

我们首先进入到 Logstash 的安装目录下的bin子目录，并在命令行中打入如下的命令：
```
$ ./logstash-plugin list --group input
```

显示：
```
logstash-input-azure_event_hubs
logstash-input-beats
logstash-input-couchdb_changes
logstash-input-elasticsearch
logstash-input-exec
logstash-input-file
logstash-input-ganglia
logstash-input-gelf
logstash-input-generator
logstash-input-graphite
logstash-input-heartbeat
logstash-input-http
logstash-input-http_poller
logstash-input-imap
logstash-input-jdbc
logstash-input-jms
logstash-input-kafka
logstash-input-pipe
logstash-input-rabbitmq
logstash-input-redis
logstash-input-s3
logstash-input-snmp
logstash-input-snmptrap
logstash-input-sqs
logstash-input-stdin
logstash-input-syslog
logstash-input-tcp
logstash-input-twitter
logstash-input-udp
logstash-input-unix
```

## Filter plugs:

在命令行打入如下的命令：
```
$ ./logstash-plugin list --group filter
logstash-filter-aggregate
logstash-filter-anonymize
logstash-filter-cidr
logstash-filter-clone
logstash-filter-csv
logstash-filter-date
logstash-filter-de_dot
logstash-filter-dissect
logstash-filter-dns
logstash-filter-drop
logstash-filter-elasticsearch
logstash-filter-fingerprint
logstash-filter-geoip
logstash-filter-grok
logstash-filter-http
logstash-filter-jdbc_static
logstash-filter-jdbc_streaming
logstash-filter-json
logstash-filter-kv
logstash-filter-memcached
logstash-filter-metrics
logstash-filter-mutate
logstash-filter-prune
logstash-filter-ruby
logstash-filter-sleep
logstash-filter-split
logstash-filter-syslog_pri
logstash-filter-throttle
logstash-filter-translate
logstash-filter-truncate
logstash-filter-urldecode
logstash-filter-useragent
logstash-filter-uuid
logstash-filter-xml
```

## Output plugins:

在命令行打入如下的命令：
```
$ ./logstash-plugin list --group output
logstash-output-cloudwatch
logstash-output-csv
logstash-output-elastic_app_search
logstash-output-elasticsearch
logstash-output-email
logstash-output-file
logstash-output-graphite
logstash-output-http
logstash-output-lumberjack
logstash-output-nagios
logstash-output-null
logstash-output-pipe
logstash-output-rabbitmq
logstash-output-redis
logstash-output-s3
logstash-output-sns
logstash-output-sqs
logstash-output-stdout
logstash-output-tcp
logstash-output-udp
logstash-output-webhdfs
```

## Codec plugins:

在命令行打入如下的命令：
```
$ ./logstash-plugin list codec
logstash-codec-avro
logstash-codec-cef
logstash-codec-collectd
logstash-codec-dots
logstash-codec-edn
logstash-codec-edn_lines
logstash-codec-es_bulk
logstash-codec-fluent
logstash-codec-graphite
logstash-codec-json
logstash-codec-json_lines
logstash-codec-line
logstash-codec-msgpack
logstash-codec-multiline
logstash-codec-netflow
logstash-codec-plain
logstash-codec-rubydebug
````

在这上面显示都是我们在安装 Logstash 后，已经给我们配置好的 plugin。我们可以自己开发自己的 plugin，并安装它。我们也可以安装一个别人已经开发好的 plugin。

从上面我们可以看出来，因为 file 都在 input 及 output 之中，我们甚至可以做如下的配置：
```
input {
   file {
      path => "C:/Program Files/Apache Software Foundation/Tomcat 7.0/logs/*access*"
      type => "apache"
   }
} 
output {
   file {
      path => "C:/tpwork/logstash/bin/log/output.log"
   }
}
```

这样我们把 input 文件读入到 Logstash，经过它的处理后，就会变成下面的这种输出：
```
0:0:0:0:0:0:0:1 - - [25/Dec/2016:18:37:00 +0800] "GET / HTTP/1.1" 200 11418
```

```
{
   "path":"C:/Program Files/Apache Software Foundation/Tomcat 7.0/logs/localhost_access_log.2016-12-25.txt",
   "@timestamp":"2016-12-25T10:37:00.363Z","@version":"1","host":"Dell-PC",
   "message":"0:0:0:0:0:0:0:1 - - [25/Dec/2016:18:37:00 +0800] \"GET / HTTP/1.1\" 200 11418\r","type":"apache","tags":[]
}
```

# 安装 plugins

在标准的 Logstash 中，有很多的 plugin 已经被安装了，但是在有些场合，我们需要手动来安装一些我们所需要的 plugin，比如 Exec output plugin。我们可以在 bin 目录先打人如下的命令：
```
./bin/logstash-plugin install logstash-output-exec
```

这样我们用如下的命令来检查上面的 plugin 是否已经被成功安装了：
```
./bin/logstash-plugin list --group output | grep exec
$ ./bin/logstash-plugin list --group output | grep exec
Java HotSpot(TM) 64-Bit Server VM warning: Option UseConcMarkSweepGC was deprecated in version 9.0 and will likely be removed in a future release.
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.bouncycastle.jcajce.provider.drbg.DRBG (file:/Users/liuxg/elastic/logstash-7.4.0/vendor/jruby/lib/ruby/stdlib/org/bouncycastle/bcprov-jdk15on/1.61/bcprov-jdk15on-1.61.jar) to constructor sun.security.provider.Sun()
WARNING: Please consider reporting this to the maintainers of org.bouncycastle.jcajce.provider.drbg.DRBG
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
logstash-output-exec
```

## 读取 log 文件

Logstash 很容易设置来读取一个 log 文件。比如，我们可以通过如下的方式来读取一个 Apache 的 log 文件：
```
input {
  file { 
  	type => "apache"
  	path => "/Users/liuxg/data/apache_logs"
 	start_position => "beginning"
	sincedb_path => "null"
  }
}
 
output {
	stdout { 
		codec => rubydebug 
	}
}
```

我们甚至可以读取多个文件：
```
# Pull in application-log data. They emit data in JSON form.
input {
  file {
    path => [
      "/var/log/app/worker_info.log",
      "/var/log/app/broker_info.log",
      "/var/log/app/supervisor.log"
    ]
    exclude => "*.gz"
    type    => "applog"
    codec   => "json"
  }
}
```

## 数据的系列化

我们可以使用已经提供的 Codec 来把我们的数据进行系列化，比如：
```
input {
  // Deserialize newline separated JSON
  file  { path => “/some/sample.log”, codec => json }
}
 
output {
  // Serialize to the msgpack format
  redis { codec => msgpack }
  stdout {
    codec => rubydebug
  }
}
```

在我们的 Longstash 运行起来后，我们可以通过如下的命令在一个 terminal 中向文件 sample.json 添加内容：
``` 
$ echo '{"name2", "liuxg2"}' >> ./sample.log
```

我们可以看到如下的输出：
```
{
      "@version" => "1",
       "message" => "{\"name2\", \"liuxg2\"}",
    "@timestamp" => 2019-09-12T07:37:56.639Z,
          "host" => "localhost",
          "tags" => [
        [0] "_jsonparsefailure"
    ],
          "path" => "/Users/liuxg/data/sample.log"
}
```

# 最常用的 codec

- 1) line 使用 “message” 中的数据将每行转换为 Logstash 事件。 也可以将输出格式化为自定义行 。
- 2) multiline: 允许你为 “message” 构成任意边界。 经常用于stacktraces 等。也可以在 filebeat 中完成。
- 3) json_lines: 解析换行符分隔的 JSON 数据
- 4) json: 解析所有JSON。 仅适用于面向消息的输入/输出，如 Redis/Kafka/HTTP 等还有很多其它的 Codec。

## 解析及提取

### Grok Filter
```
filter {
	grok {
		match => [
			"message", "%{TIMESTAMP_ISO8601:timestamp_string}%{SPACE}%{GREEDYDATA:line}"
		]
	}
}
```

上面的例子可以帮我们很方便地把如下的log信息变成一个机构化的数据：
```
2019-09-09T13:00:00Z Whose woods these are I think I know.
```
更多 grok 的 pattern 可以在地址[grok pattern](https://github.com/logstash-plugins/logstash-patterns-core/blob/main/patterns/legacy/grok-patterns)找到。
```

## Date filter
filter {
  date {
    match => ["timestamp_string", "ISO8601"]
  }
}
```
Date filter 可以帮我们把一个字符串，变成一个我们想要的格式的时间，并且把这个值赋予给 @timestamp 字段。
 

## Dissect filter
是一个更快，轻量级的更小的 grok：
```
filter {
  dissect {
    mapping => {“message” => “%{id} %{function->} %{server}”}
  }
}
```

字段和分隔符模式的格式类似于 Grok。
```
"<%{priority}>%{syslog_timestamp} %{+syslog_timestamp} %{+syslog_timestamp} %{logsource} %{rest}".
```


例子：
```
input {
  generator {
    message => "<1>Oct 16 20:21:22 www1 1,2016/10/16 20:21:20,3,THREAT,SCAN,6,2016/10/16 20:21:20,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54"
    count => 1
  }
}
 
filter {
  if [message] =~ "THREAT," {
    dissect {
      mapping => {
        message => "<%{priority}>%{syslog_timestamp} %{+syslog_timestamp} %{+syslog_timestamp} %{logsource} %{pan_fut_use_01},%{pan_rec_time},%{pan_serial_number},%{pan_type},%{pan_subtype},%{pan_fut_use_02},%{pan_gen_time},%{pan_src_ip},%{pan_dst_ip},%{pan_nat_src_ip},%{pan_nat_dst_ip},%{pan_rule_name},%{pan_src_user},%{pan_dst_user},%{pan_app},%{pan_vsys},%{pan_src_zone},%{pan_dst_zone},%{pan_ingress_intf},%{pan_egress_intf},%{pan_log_fwd_profile},%{pan_fut_use_03},%{pan_session_id},%{pan_repeat_cnt},%{pan_src_port},%{pan_dst_port},%{pan_nat_src_port},%{pan_nat_dst_port},%{pan_flags},%{pan_prot},%{pan_action},%{pan_misc},%{pan_threat_id},%{pan_cat},%{pan_severity},%{pan_direction},%{pan_seq_number},%{pan_action_flags},%{pan_src_location},%{pan_dst_location},%{pan_content_type},%{pan_pcap_id},%{pan_filedigest},%{pan_cloud},%{pan_user_agent},%{pan_file_type},%{pan_xff},%{pan_referer},%{pan_sender},%{pan_subject},%{pan_recipient},%{pan_report_id},%{pan_anymore}"
      }
    }
  }
}
 
 
output {
	stdout { 
		codec => rubydebug 
	}
}
```

运行后：
```
{
             "@timestamp" => 2019-09-12T09:20:46.514Z,
             "pan_dst_ip" => "9",
         "pan_nat_src_ip" => "10",
               "sequence" => 0,
              "logsource" => "www1",
         "pan_session_id" => "23",
               "pan_vsys" => "16",
                "pan_cat" => "34",
          "pan_rule_name" => "12",
           "pan_gen_time" => "2016/10/16 20:21:20",
         "pan_seq_number" => "37",
            "pan_subject" => "50",
   
                ....
   
                "message" => "<1>Oct 16 20:21:22 www1 1,2016/10/16 20:21:20,3,THREAT,SCAN,6,2016/10/16 20:21:20,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54",
         "pan_fut_use_02" => "6",
              "pan_flags" => "29",
       "syslog_timestamp" => "Oct 16 20:21:22",
            "pan_anymore" => "53,54"
}
```

更多描述，请到[地址](https://www.elastic.co/cn/blog/logstash-dude-wheres-my-chainsaw-i-need-to-dissect-my-logs)查看。

# KV filter

解析键/值对中数据的简便方法
```
filter {
  kv {
    source => “message”
    target => “parsed”
    value_split => “:”
  }
}
```

我们运行这样的 conf 文件：
```
input {
  generator {
    message => "pin=12345~0&d=123&e=foo@bar.com&oq=bobo&ss=12345"
    count => 1
  }
}
 
filter {
	kv {
		source => "message"
		target => "parsed"
		field_split => "&?"
	}
}
 
output {
	stdout { 
		codec => rubydebug 
	}
}
```
显示的结果是：
```
{
    "@timestamp" => 2019-09-12T09:46:04.944Z,
          "host" => "localhost",
        "parsed" => {
         "ss" => "12345",
          "e" => "foo@bar.com",
        "pin" => "12345~0",
         "oq" => "bobo",
          "d" => "123"
    },
       "message" => "pin=12345~0&d=123&e=foo@bar.com&oq=bobo&ss=12345",
      "sequence" => 0,
      "@version" => "1"
}
```

对于 kv flter 来说，我们也可以使用一个target来把信息组织到一个 object 里，比如：
```
filter {
  kv {
    source => “message”
    target => “parsed”
    value_split => “:”
  }
}
```

# 核心操作

## Mutate filter

这个 filter 提供很多功能：
- 转换字段类型（从字符串到整数等）
- 添加/重命名/替换/复制字段
- 大/小写转换
- 将数组连接在一起（对于Array => String操作很有用）
- 合并哈希
- 将字段拆分为数组
- 剥去空白

```
input {
  generator {
    message => "pin=12345~0&d=123&e=foo@bar.com&oq=bobo&ss=12345"
    count => 1
  }
}
 
filter {
	kv {
		source => "message"
		field_split => "&?"
	}
 
	if [pin] == "12345~0" {
    	mutate { add_tag => [ 'metrics' ]
    }
 
    mutate {
    	split => ["message", "&"]
    	add_field => {"foo" => "bar-%{pin}"}
  	}
  }
}
 
output {
	stdout { 
		codec => rubydebug 
	}
 
	if "metrics" in [tags] {
      stdout {
         codec => line { format => "custom format: %{message}" }
      }
   }
}
```
显示的结果是：
```
{
     "foo" => "bar-12345~0",
      "e" => "foo@bar.com",
      "sequence" => 0,
       "message" => [
        [0] "pin=12345~0",
        [1] "d=123",
        [2] "e=foo@bar.com",
        [3] "oq=bobo",
        [4] "ss=12345"
    ],
           "pin" => "12345~0",
             "d" => "123",
          "host" => "localhost",
            "ss" => "12345",
    "@timestamp" => 2019-09-14T15:03:15.141Z,
            "oq" => "bobo",
      "@version" => "1",
          "tags" => [
        [0] "metrics"
    ]
}
custom format: pin=12345~0,d=123,e=foo@bar.com,oq=bobo,ss=12345
```

## 最核心的转化 filters
- Mute - 修改/添加每个项
- Split - 把一个事件转化为多个事件
- Drop - 丢掉一个事件

## 条件逻辑
- if/else
- 可以用 =~ 来使用 regexps（正则）
- 可以在一个数组里检查一个会员
```
filter {
  mutate { lowercase => “account” }
  if [type] == “batch” {
    split { 
        field => actions 
       target => action 
    }
  }
 
  if { “action” =~ /special/ } {
    drop {}
  }
}
```

## GeoIP

[GeoIP](https://www.elastic.co/guide/en/logstash/current/plugins-filters-geoip.html) 过滤器丰富 IP 地址信息：
```
filter {  geoip {    fields => “my_geoip_field”  }}
```

运行如下的配置：
```
input {
  generator {
    message => "83.149.9.216"
    count => 1
  }
}
 
filter {
	grok {
    	match => {
      		"message" => '%{IPORHOST:clientip}'
    	}
    }
 
    geoip {
    	source => "clientip"
  	}
}
 
output {
	stdout {
		codec => rubydebug
	}
}
```
显示的结果如下：
```
{
          "host" => "localhost",
      "@version" => "1",
      "clientip" => "83.149.9.216",
       "message" => "83.149.9.216",
    "@timestamp" => 2019-09-15T06:54:46.695Z,
      "sequence" => 0,
         "geoip" => {
              "timezone" => "Europe/Moscow",
           "region_code" => "MOW",
              "latitude" => 55.7527,
         "country_code3" => "RU",
        "continent_code" => "EU",
             "longitude" => 37.6172,
          "country_name" => "Russia",
              "location" => {
            "lat" => 55.7527,
            "lon" => 37.6172
        },
                    "ip" => "83.149.9.216",
           "postal_code" => "102325",
         "country_code2" => "RU",
           "region_name" => "Moscow",
             "city_name" => "Moscow"
    }
}
```
我们可以看到在 geoip 之下，有很多具体的信息。

## DNS filter

用 DNS 信息丰富主机名的更多信息
```
filter {  dns {    fields => “my_dns_field”  }}
```

我们定义如下的一个 Logstash 配置文件：
```
input {
  generator {
    message => "www.google.com"
    count => 1
  }
}
 
filter {
 	mutate {
    	add_field => { "hostname" => "172.217.160.110"}
	}
 
 
	dns {
		reverse => ["hostname"]
		action => "replace"	 
	}   
 
}
 
output {
	stdout {
		codec => rubydebug
	}
}
```

上面是谷歌的地址，那么它的输出结果是：
```
{
          "host" => "localhost",
      "sequence" => 0,
       "message" => "www.google.com",
    "@timestamp" => 2019-09-15T11:35:43.791Z,
      "hostname" => "tsa03s06-in-f14.1e100.net",
      "@version" => "1"
}
```
在这里我们可以看到 hostname 的值。

## Useragent filer

让浏览器的 useragent 信息更加丰富。我们使用如下的 Logstash 配置：
```
input {
  generator {
    message => '83.149.9.216 - - [17/May/2015:10:05:50 +0000] "GET /presentations/logstash-monitorama-2013/images/kibana-dashboard.png HTTP/1.1" 200 321631 "http://semicomplete.com/presentations/logstash-monitorama-2013/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"'
    count => 1
  }
}
 
filter {
	grok {
	    match => {
	      "message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
	    }
	  }
 
	useragent {
    	source => "agent"
    	target => "useragent"
  	}
}
 
output {
	stdout {
		codec => rubydebug
	}
}
```
运行出来的结果是：
```
{
        "request" => "/presentations/logstash-monitorama-2013/images/kibana-dashboard.png",
      "useragent" => {
            "name" => "Chrome",
           "build" => "",
          "device" => "Other",
        "os_major" => "10",
              "os" => "Mac OS X",
           "minor" => "0",
           "major" => "32",
         "os_name" => "Mac OS X",
           "patch" => "1700",
        "os_minor" => "9"
    },
       "sequence" => 0,
        "message" => "83.149.9.216 - - [17/May/2015:10:05:50 +0000] \"GET /presentations/logstash-monitorama-2013/images/kibana-dashboard.png HTTP/1.1\" 200 321631 \"http://semicomplete.com/presentations/logstash-monitorama-2013/\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
      "timestamp" => "17/May/2015:10:05:50 +0000",
       "referrer" => "\"http://semicomplete.com/presentations/logstash-monitorama-2013/\"",
       "clientip" => "83.149.9.216",
          "ident" => "-",
           "auth" => "-",
       "response" => 200,
       "@version" => "1",
           "verb" => "GET",
           "host" => "localhost",
     "@timestamp" => 2019-09-15T12:03:34.650Z,
    "httpversion" => "1.1",
          "bytes" => 321631,
          "agent" => "\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\""
}
```
我们在 useragent 里可以看到更加详细的信息啊。

## Translate Filter

使用本地的数据来使得数据更加丰富。我们使用如下的 Logstash 配置文件：
```
input {
  generator {
    message => '83.149.9.216 - - [17/May/2015:10:05:50 +0000] "GET /presentations/logstash-monitorama-2013/images/kibana-dashboard.png HTTP/1.1" 200 321631 "http://semicomplete.com/presentations/logstash-monitorama-2013/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"'
    count => 1
  }
}
 
filter {
	grok {
	    match => {
	      "message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
	    }
	 }
 
	translate {
		field => "[response]"
		destination => "[http_status_description]"
		dictionary => {
         	"100" => "Continue"
          	"101" => "Switching Protocols"
          	"200" => "OK"
          	"500" => "Server Error"
		}
		
		fallback => "I'm a teapot"
	}
	
}
 
 
output {
	stdout {
		codec => rubydebug
	}
}
```

运行显示的结果是：
```
{
                       "auth" => "-",
                       "host" => "localhost",
                  "timestamp" => "17/May/2015:10:05:50 +0000",
                    "message" => "83.149.9.216 - - [17/May/2015:10:05:50 +0000] \"GET /presentations/logstash-monitorama-2013/images/kibana-dashboard.png HTTP/1.1\" 200 321631 \"http://semicomplete.com/presentations/logstash-monitorama-2013/\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
                "httpversion" => "1.1",
                   "@version" => "1",
                   "response" => 200,
                   "clientip" => "83.149.9.216",
                       "verb" => "GET",
                   "sequence" => 0,
                   "referrer" => "\"http://semicomplete.com/presentations/logstash-monitorama-2013/\"",
                      "agent" => "\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
    "http_status_description" => "OK",
                      "ident" => "-",
                 "@timestamp" => 2019-09-15T12:30:09.575Z,
                      "bytes" => 321631,
                    "request" => "/presentations/logstash-monitorama-2013/images/kibana-dashboard.png"
}
```
我们可以看到一项 http_status_description，它的值变为 “OK”。

## Elasticsearch Filter

从 Elasticsearch 中的 index 得到数据，并丰富事件。为了做这个测试，我们先建立一个叫做 elasticsearch_filter 的 index:
```
PUT ç/_doc/1
{
  "name":"liuxg",
  "age": 20,
  "@timestamp": "2019-09-15"
}
```

在这里，我必须指出来的是：我们必须有一个叫做 @timestamp 的项，否则会有错误。这个是用来做 sort 用的。

我们采用如下的 Logstash 配置：
```
input {
  generator {
    message => "liuxg"
    count => 1
  }
}
 
filter {
	elasticsearch {
		hosts => ["http://localhost:9200"]
		index => ["elasticsearch_filter"]
		query => "name.keyword:%{[message]}"
		result_size => 1
		fields => {"age" => "user_age"}
	}
}
 
output {
	stdout {
		codec => rubydebug
	}
}
```
运行上面的例子显示的结果是：
```
{
      "user_age" => 20,
          "host" => "localhost",
       "message" => "liuxg",
      "@version" => "1",
    "@timestamp" => 2019-09-15T13:21:29.742Z,
      "sequence" => 0
}
```
我们可以看到 user_age 是20。这个是通过搜索 name:liuxg 来得到的。

参考：
- [Getting started with Logstash](https://opensource.com/article/17/10/logstash-fundamentals)
- https://blog.csdn.net/UbuntuTouch/article/details/100770828
