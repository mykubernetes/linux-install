# Logstash配置内容

- Logstash的配置主要分为三部分：数据输入部分、数据处理部分、数据输出部分。这三部分的定义覆盖了数据整个的生命周期。这一篇主要介绍数据输入部分

# 支持的数据来源

- Logstash提供了一个非常长的数据来源支持列表，目前最新版的Logstash可以从下面渠道里面获得数据

| 输入插件 | 支持内容 |
|---------|----------|
| azure_event_hubs | 从Azure事件中心接收事件 |
| beats | 从Elastic Beats框架接收事件 |
| cloudwatch | 从Amazon Web Services CloudWatch API提取事件 |
| couchdb_changes | 从CouchDB的_changesURI 流事件 |
| dead_letter_queue | 从Logstash的死信队列中读取事件 |
| elasticsearch | 从Elasticsearch集群读取查询结果 |
| exec | 将shell命令的输出捕获为事件 |
| file | 从文件流事件 |
| ganglia | 通过UDP读取Ganglia数据包 |
| gelf | 从Graylog2读取GELF格式的消息作为事件 |
| generator | 生成用于测试目的的随机日志事件 |
| github | 从GitHub Webhook读取事件 |
| google_cloud_storage | 从Google Cloud Storage存储桶中的文件中提取事件 |
| google_pubsub | 消费来自Google Cloud PubSub服务的事件 |
| graphite | 从graphite工具读取指标 |
| heartbeat | 生成心跳事件以进行测试 |
| http | 通过HTTP或HTTPS接收事件 |
| http_poller | 将HTTP API的输出解码为事件 |
| imap | 从IMAP服务器读取邮件 |
| irc | 从IRC服务器读取事件 |
| java_generator | 生成综合日志事件 |
| java_stdin | 从标准输入读取事件 |
| jdbc | 从JDBC数据创建事件 |
| jms | 从Jms Broker读取事件 |
| jmx | 通过JMX从远程Java应用程序检索指标 |
| kafka | 读取来自Kafka主题的事件 |
| kinesis | 通过AWS Kinesis流接收事件 |
| log4j | 从Log4j SocketAppender对象通过TCP套接字读取事件 |
| lumberjack | 使用Lumberjack协议接收事件 |
| meetup | 将命令行工具的输出捕获为事件 |
| pipe | 从长时间运行的命令管道流式传输事件 |
| puppet_facter | 接收来自Puppet服务器的事件 |
| rabbitmq | 从RabbitMQ交换中提取事件 |
| redis | 从Redis实例读取事件 |
| relp | 通过TCP套接字接收RELP事件 |
| rss | 将命令行工具的输出捕获为事件 |
| s3 | 从S3存储桶中的文件流式传输事件 |
| s3_sns_sqs | 使用sqs从AWS S3存储桶读取日志 |
| salesforce | 根据Salesforce SOQL查询创建事件 |
| snmp | 使用简单网络管理协议（SNMP）轮询网络设备 |
| snmptrap | 根据SNMP陷阱消息创建事件 |
| sqlite | 根据SQLite数据库中的行创建事件 |
| sqs | 从Amazon Web Services简单队列服务队列中提取事件 |
| stdin | 从标准输入读取事件 |
| stomp | 创建使用STOMP协议接收的事件 |
| syslog | 读取系统日志消息作为事件 |
| tcp | 从TCP套接字读取事件 |
| twitter | 从Twitter Streaming API读取事件 |
| udp | 通过UDP读取事件 |
| unix | 通过UNIX套接字读取事件 |
| varnishlog | 从varnish缓存共享内存日志中读取 |
| websocket | 从网络套接字读取事件 |
| wmi | 根据WMI查询的结果创建事件 |
| xmpp | 通过XMPP / Jabber协议接收事件 |

# 读取文件(File)

> 从文件中流式传输事件，通常以类似于tail -0F但可选地从头开始读取它们。Logstash 使用一个名叫 FileWatch 的 Ruby Gem 库来监听文件变化。而且会记录一个叫 .sincedb 的数据库文件来跟踪被监听的日志文件的当前读取位置。

这是一个完全的示例：
```
input
    file {
        # 日志文件地址
        path => ["/var/log/*.log", "/var/log/message"]
        # 默认一小时
        close_older => 3600
        # 设置新行分隔符，默认为“ \ n”。
        delimiter => "\n"
        # 此参数配合stat_interval，此值用来发现新文件，最终频率为discover_interval × stat_interval。默认15
        discover_interval => 
        # 默认为1秒
        stat_interval => "1 second"
        # 忽略压缩包
        exclude => exclude => "*.gz"
        # 默认为false
        exit_after_read => false
        # 默认为4611686018427387903，是为了保证在读取下一个文件前保证当前文件已经读取完毕
        file_chunk_count => 4611686018427387903
        # 默认为32kb
        file_chunk_size => 32768
        # 默认值为delete，可选值：delete，log，log_and_delete
        file_completed_action => delete
        # 将完全读取的文件路径附加到哪个文件，此内容没有默认值
        file_completed_log_path => "/usr/local/log2/completed.log"
        # 默认值last_modified，可设置内容：last_modified, path
        file_sort_by => last_modified
        # 默认值asc，可设置的值asc, desc
        file_sort_direction => 
        # 设置了忽略1000秒之前修改的文件，此内容没有默认值
        ignore_older => 1000
        # 设置最多打开文件量，此值没有默认值，但是存在一个内部限制4095
        max_open_files => 4095
        # 设置了输入模式为tail
        # tail模式下，start_position 和close_older参数将被忽略。start_position始终从头开始读取文件，close_older到达EOF时文件自动关闭
        # read模式下需要设置ignore_older 、file_completed_action 、file_completed_log_path 参数
        mode => tail
        # 默认值2周
        sincedb_clean_after => "2 weeks"
        # 此为默认值，此值为文件路径而不是目录路径
        sincedb_path => path.data>/plugins/inputs/file
        # 默认值15秒
        sincedb_write_interval => "15 seconds"
        # 默认值"end"，可选值beginning，end。如果启动logstash的时候需要读取旧数据需要设置为beginning
        start_position => "end"
        # 下面是公共配置
        # 设置了type为system
        type => "system" 
        # 默认line
        codec => "json"
        # 默认值为true
        enable_metric => false
        # 指定此数据输入id为input1
        id => input1
        # 添加了键位key值为value的数据到时间
        add_field => {
          "key" => "value"
        }
    }
}
```

**可配置的参数**

| 参数 | 作用 | 参数类型 |
|------|------|---------|
| close_older | 文件输入将关闭最近一次在指定持续时间（如果指定了数字，则为秒）之前读取的所有文件 | number或者string_duration |
| delimiter | 设置新行分隔符，默认为“ \ n”。 | string |
| discover_interval | 每隔多久去检查一次被监听的 path 下是否有新文件。 | number |
| exclude | 排除例外文件 | array |
| exit_after_read | 可以在read模式下使用此选项，以在读取文件时强制关闭所有观察程序。可以用于文件内容为静态且在执行期间不会更改的情况。 | boolean |
| file_chunk_count | 在移至下一个活动文件之前从每个文件读取多少条数据 | number |
| file_chunk_size | 每条数据读取的大小 | number |
| file_completed_action | 在read模式下，完成文件后应执行什么操作。如果指定了删除，则文件将被删除。如果指定了日志，则文件的完整路径将记录到file_completed_log_path设置中指定的文件中 。如果log_and_delete指定，则以上两个动作都会发生。 | string 可选参[“delete”, “log”, “log_and_delete”]数 |
| file_completed_log_path | 完全读取的文件路径应附加到哪个文件。只有当指定文件这条道路file_completed_action是日志或log_and_delete是使用 | string |
| file_sort_by | 应该使用“监视”文件的哪个属性对其进行排序。文件可以按修改日期或全路径字母排序。 | string 可选参数[“last_modified”, “path”] |
| file_sort_direction | 排序“监视”的文件时，在升序和降序之间进行选择 | string 可选参数[“asc”, “desc”] |
| ignore_older | 当文件输入发现在指定持续时间（如果指定了数字，则为秒）之前最后修改的文件时，将忽略该文件。 | number或者string_duration |
| max_open_files | 此输入一次一次消耗的file_handles的最大数量是多少。当打开的文件数量超过指定数量则会关闭一些文件 | number |
| mode | 您希望文件输入以哪种模式操作。 | string 可选参数 [“tail”, “read”] |
| path | 输入的文件的路径。 | array |
| sincedb_clean_after | 如果在过去N天内未在跟踪文件中检测到任何更改，则它的sincedb跟踪记录将过期，并且不会保留。 | number或者string_duration |
| sincedb_path | 定义 sincedb 文件的位置 | string |
| sincedb_write_interval | 每隔多久写一次 sincedb 文件 | number或者string_duration |
| start_position | 从什么位置开始读取文件数据。支持beginning或者end。end的时候从结束位置开始读取数据，而beginning则是从开头开始读取数 | string 可选参数[“beginning”, “end”] |
| stat_interval | 我们统计文件的频率（以秒为单位），以查看它们是否已被修改。 | number或者string_duration |

ps.并非所有支持配置，最后会介绍公共配置

# 读取网络数据(TCP)

> 接收网络中的数据，此方法可以通过log发送数据到logstash，可以很方便的测试数据传输和分析效果。

此方法需要对项目中log进行设置
```
<Configuration>
  <Appenders>
     <Socket name="Socket" host="localhost" port="8081">
       <JsonLayout compact="true" eventEol="true" />
    </Socket>
  </Appenders>
  <Loggers>
    <Root level="info">
      <AppenderRef ref="Socket"/>
    </Root>
  </Loggers>
</Configuration>

```

同时需要添加一个过滤器来获取时间戳
```
filter {
  date {
    match => [ "timeMillis", "UNIX_MS" ]
  }
}
```

示例：
```
input {
  tcp {
        # 主机地址
        host => "192.168.0.2"
        # 此时需要监听客户端
        mode => "server"
        # 要监听的端口
        port => 8081
        # 默认值为false
        tcp_keep_alive => false
        # 默认值为true
        dns_reverse_lookup_enabled => true
        # 下面是公共配置
        # 设置了type为system
        type => "system" 
        # 默认line
        codec => "json"
        # 默认值为true
        enable_metric => false
        # 指定此数据输入id为input1
        id => input1
        # 添加了键位key值为value的数据到时间
        add_field => {
          "key" => "value"
        }
  }
}
```

**可配置的参数**

| 参数 | 作用 | 参数类型 |
|------|------|---------|
| host | 监听的地址(mode=server),连接的地址(mode=client) | string |
| mode | 运行模式。server指侦听客户端连接， client指连接到服务器。 | string 可选参数[“server”, “client”] |
| port | 当mode为时server，要监听的端口。当mode为时client，要连接的端口 | number |
| proxy_protocol | 代理协议 | boolean |
| ssl_cert | PEM格式的证书路径。 |  |
| ssl_certificate_authorities | 根据这些权限验证客户证书或证书链。 | array |
| ssl_enable | 启用SSL | boolean |
| ssl_extra_chain_certs | 额外的X509证书的路径数组。 | array |
| ssl_key | 指定证书（PEM格式）的私钥的路径。	 |
| ssl_key_passphrase | 私钥的SSL密钥密码。 | password |
| ssl_verify | 根据CA验证SSL连接另一端的身份 | boolean |
| tcp_keep_alive | 指示套接字使用TCP保持活动。 | boolean |
| dns_reverse_lookup_enabled | 通过禁用此设置可以避免DNS反向查找。 | boolean |

# 读取 Rabbitmq 数据

> 从队列中读取数据的时候需要有一些额外操作，需要设置一个过滤器来解析`[@metadata][rabbitmq_properties][timestamp]`队列中的时间

```
filter {
  if [@metadata][rabbitmq_properties][timestamp] {
    date {
      match => ["[@metadata][rabbitmq_properties][timestamp]", "UNIX"]
    }
  }
}
```

示例：
```
input {
    rabbitmq {
            
            # 队列的主机
            host => "192.168.1.2"
            # 默认为guest
            password => "guest"
            # 消息服务器端口，默认为5672
            port => 5672
            # 默认为""
            queue => ""
            # 默认值为true
            ack => true
            # 默认值为{}
            arguments => { "x-ha-policy" => "all" }
            # 默认值为false
            auto_delete => false
            # 默认值为true
            automatic_recovery => true
            # 默认值为1秒
            connect_retry_interval => 1
            # 没有默认值，超时时间为无限
            connection_timeout => 1000
            # 默认值为false
            durable => false
            # 队列的交换器信息
            exchange => "log.exchange"
            # 队列的交换器信息
            exchange_type => "direct"
            # 默认值为false
            exclusive => false
            # 没有默认值，但是不指定的时候未60秒，秒为单位
            heartbeat => 60
            # 默认值为logstash，路由键
            key => logstash
            # 默认值为false，启动此功能保存元数据会影响性能
            metadata_enabled => false
            # 默认值为false，当设置true的时候表明为被动队列，则在消息服务器上，此队列已经存在
            passive => false
            # 默认为256
            prefetch_count => 256
            # 下面是公共配置
            # 设置了type为system
            type => "system" 
            # 默认line
            codec => "json"
            # 默认值为true
            enable_metric => false
            # 指定此数据输入id为input1
            id => input1
            # 添加了键位key值为value的数据到时间
            add_field => {
              "key" => "value"
            }
    }
}

```

**可配置的参数**

| 参数 | 作用 | 参数类型 |
|------|------|---------|
| ack | 启用消息确认 | boolean |
| arguments | 可选队列参数 | array |
| auto_delete | 当最后一个使用者断开连接时，是否应该在代理上删除队列 | boolean |
| automatic_recovery | 将此设置为自动从断开的连接中恢复 | boolean |
| connect_retry_interval | 重试连接之前等待的时间 | number |
| connection_timeout | 默认连接超时（以毫秒为单位） | number |
| durable | 是否持久队列 | boolean |
| exchange | 绑定队列的交换的名称 | string |
| exchange_type | 要绑定的交换类型 | string |
| exclusive | 队列是否排他 | boolean |
| heartbeat | 心跳超时（以秒为单位 | number |
| host | Rabbitmq输入/输出RabbitMQ服务器地址主机的通用功能可以是单个主机，也可以是主机列表，即主机⇒“ localhost”或主机⇒[“ host01”，“ host02] | string |
| key | 将队列绑定到交换机时要使用的路由密钥。 | string |
| metadata_enabled | 在中启用消息标头和属性的存储@metadata | boolean |
| passive | 如果为true，将被动声明队列，这意味着它必须已经存在于服务器上。 | boolean |
| password | RabbitMQ密码 | password |
| port | RabbitMQ端口进行连接 | number |
| prefetch_count | 预取计数。如果使用该ack 选项启用了确认，则指定允许的未完成的未确认消息的数量。 | number |
| queue | 从每条消息中提取并存储在@metadata字段中的属性。 | string |
| ssl | 启用或禁用SSL。请注意，默认情况下，远程证书验证处于关闭状态。 | boolean |
| ssl_certificate_password | ssl_certificate_path中指定的加密PKCS12（.p12）证书文件的密码 | string |
| ssl_certificate_path | PKCS12（.p12）格式的SSL证书路径，用于验证远程主机 | |
| ssl_version | 要使用的SSL协议版本。 | string |
| subscription_retry_interval_seconds | 订阅请求失败后，重试之前要等待的时间（秒） | number |

# 读取 Redis 数据

示例：
```
input {
  redis {
    # 默认值为 125
    batch_count => 125
    # 没有默认值，但其可选内容list，channel，pattern_channel
    data_type => list
    # 默认值为 0
    db => 0
    # 默认值为 "127.0.0.1"
    host => "127.0.0.1"
    # 指定channel，没有默认值
    key => "channel"
    # redis的用户密码
    password => "password"
    # redis服务器端口，默认值为 6379
    port => 6379
    # 默认不开启SSL
    ssl => false
    # 初始超时为1秒
    timeout => 1
  }
}
```

**可配置的参数**

| 参数 | 作用 | 参数类型 |
|------|------|---------|
| batch_count | 使用EVAL从Redis返回的事件数 | number |
| data_type | 指定列表或频道，可选内容为：list，channel，pattern_channel，如果data_type为list，将对密钥进行BLPOP锁定。如果data_type为channel，将订阅该密钥。如果data_type为pattern_channel，将订阅该密钥。 | string 可选参数[“list”, “channel”, “pattern_channel”] |
| db | Redis数据库号 | number |
| host | Redis服务器的主机名 | string |
| path | Redis服务器的unix套接字路径 | string |
| key | Redis列表或通道的名称 | string |
| password | 用于验证的密码。默认情况下没有身份验证 | password |
| port | 要连接的端口。 | number |
| ssl | 启用SSL支持。 | boolean |
| threads | 启动的线程 | number |
| timeout | 初始连接超时（以秒为单位） | number |
| command_map | 以“旧名称”⇒“新名称”的形式配置重命名的redis命令。 | hash |

# 读取 JDBC 数据

示例：

这是官方的一个例子，作用就是每一分钟执行一遍SELECT * from songs where artist = Beethoven语句获取结果
```
input {
  jdbc {
    jdbc_driver_library => "mysql-connector-java-5.1.36-bin.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    jdbc_connection_string => "jdbc:mysql://localhost:3306/mydb"
    jdbc_user => "mysql"
    jdbc_password => "root"
    parameters => { "favorite_artist" => "Beethoven" }
    # 设置监听间隔  各字段含义（由左至右）分、时、天、月、年，全部为*默认含义为每分钟都更新
    schedule => "* * * * *"
    statement => "SELECT * from songs where artist = :favorite_artist"
  }
}
```

这是使用了预编译来进行数据查询的例子
```
input {
  jdbc {
    statement => "SELECT * FROM mgd.seq_sequence WHERE _sequence_key > ? AND _sequence_key < ? + ? ORDER BY _sequence_key ASC"
    prepared_statement_bind_values => [":sql_last_value", ":sql_last_value", 4]
    prepared_statement_name => "foobar"
    use_prepared_statements => true
    use_column_value => true
    tracking_column_type => "numeric"
    tracking_column => "_sequence_key"
    last_run_metadata_path => "/elastic/tmp/testing/confs/test-jdbc-int-sql_last_value.yml"
  }
}
```

也可以使用编辑好的SQL文件
```
input {
    jdbc {
      # mysql 数据库链接,test为数据库名
      jdbc_connection_string => "jdbc:mysql://localhost:3306/mydb"
      # 用户名和密码
      jdbc_user => "root"
      jdbc_password => "root"
      # 驱动
      jdbc_driver_library => "mysql-connector-java-5.1.36-bin.jar"
      # 驱动类名
      jdbc_driver_class => "com.mysql.jdbc.Driver"
      jdbc_paging_enabled => "true"
      jdbc_page_size => "50000"
	  # 执行的sql 文件路径+名称
      statement_filepath => "logstash\sql\mysql\jdbc.sql"
      # 设置监听间隔  各字段含义（由左至右）分、时、天、月、年，全部为*默认含义为每分钟都更新
	  schedule => "* * * * *"
    }
}

```

**可配置的参数**

| 参数 | 作用 | 参数类型 |
|------|-----|----------|
| clean_run | 是否应保留先前的运行状态 | boolean |
| columns_charset | 特定列的字符编码 | hash |
| connection_retry_attempts | 尝试连接数据库的最大次数 | number |
| connection_retry_attempts_wait_time | 两次尝试之间休眠的秒数 | number |
| jdbc_connection_string | JDBC连接字符串 | string |
| jdbc_default_timezone | 时区转换。 | string |
| jdbc_driver_class | JDBC驱动程序类 | string |
| jdbc_driver_library | 第三方驱动程序库的JDBC驱动程序库路径。 | string |
| jdbc_fetch_size | JDBC提取大小。 | number |
| jdbc_page_size | JDBC页大小 | number |
| jdbc_paging_enabled | JDBC启用分页 | boolean |
| jdbc_password | JDBC密码 | password |
| jdbc_password_filepath | JDBC密码文件名 |  |
| jdbc_pool_timeout | PoolTimeoutError之前等待获取连接的秒数 | number |
| jdbc_user | JDBC用户 | string |
| jdbc_validate_connection | 使用前验证连接。 | boolean |
| jdbc_validation_timeout | 验证连接的频率（以秒为单位） | number |
| last_run_metadata_path | 上次运行时间的文件路径 | string |
| lowercase_column_names | 是否强制使用标识符字段的小写 | boolean |
| parameters | 查询参数的哈希，例如 { “target_id” => “321” } | hash |
| plugin_timezone | 将时间戳偏移到UTC以外的时区，则可以将此设置设置为local，插件将使用OS时区进行偏移调整。 | string 可选参数 [“local”, “utc”] |
| prepared_statement_bind_values | 准备好的语句的绑定值数组。 | array |
| prepared_statement_name | 准备好的语句的名称 | string |
| record_last_run | 是否保存状态 | boolean |
| schedule | `定期运行语句的时间表，例如Cron格式：“ * * * * *”（每分钟，每分钟执行一次查询）` | string  |
| sequel_opts | 连接池的最大连接数 | hash |
| sql_log_level | 记录SQL查询的日志级别 | string 可选参数[“fatal”, “error”, “warn”, “info”, “debug”] |
| statement | 执行的语句的内容 | string |
| statement_filepath | 执行的语句的文件的路径 |  |
| tracking_column | 要跟踪的列use_column_value	 | tring |
| tracking_column_type | 跟踪列的类型 |  |
| use_column_value | 设置为时true，将定义的 tracking_column值用作:sql_last_value。设置为时false，:sql_last_value反映上一次执行查询的时间。 | string 可选参数[“numeric”, “timestamp”] |
| use_prepared_statements | 设置为时true，启用prepare语句用法 | boolean |

# 创建测试数据(Generator)

在上线之前，可以使用此功能在实际环境中，测试 Logstash 和 Elasticsearch 的性能状况。对于极大数据情况下生产环境的评估有很重要意义

示例：
```
input {
    generator {
        # 默认值是0 具体根据需要测试数据量
        count => 100000
        # 此时消息将会顺序发出，需要注意的是，此配置和message冲突
        lines => [
          "line 1",
          "line 2",
          "line 3"
        ]
        # 默认值是"Hello world!"
        message => '{"key1":"value1","key2":[1,2],"key3":{"subkey1":"subvalue1"}}'
        # 下面是公共配置
        # 设置了type为system
        type => "system" 
        # 默认line
        codec => "json"
        # 默认值为true
        enable_metric => false
        # 指定此数据输入id为input1
        id => input1
        # 添加了键位key值为value的数据到时间
        add_field => {
          "key" => "value"
        }
    }
}
```

**可配置的参数**

| 参数 | 作用 | 参数类型 |
|------|------|----------|
| count | 生成消息数量 | number |
| lines | 顺序消息生成 | array |
| message | 生成的消息 | string |
| threads | 启动的线程 | number |

**公共配置**

> 除了不同数据渠道自有的配置之外，还存在一些公共配置

| 参数 | 作用 | 参数类型 |
|------|------|----------|
| add_field | 向事件添加字段 | hash |
| codec | 输入数据的编解码器 | codec（解编码） |
| enable_metric | 默认情况下，我们会记录我们能记录的所有度量，但是你可以禁用特定插件的度量集合 | boolean |
| id | 设置数据输入的ID，如果未指定ID，Logstash将生成一个。 | string |
| tags | 为你的数据事件设置标签，这样在数据分析的时候可以通过这个标签实现更多的分析结果 | array |
| type | type向此输入处理的所有事件添加一个字段。此参数可以在数据过滤环节实现更多逻辑 | string |

**codec（解编码）类型支持的配置**

| 参数 | 说明 |
|------|------|
| avro | 序列化的Avro记录 |
| cef | 读取ArcSight通用事件格式（CEF） |
| cloudfront | 读取AWS CloudFront报告 |
| cloudtrail | 读取AWS CloudTrail日志文件 |
| collectd | collectd使用UDP 从二进制协议读取事件。 |
| csv | 获取CSV数据，进行解析并传递。 |
| dots | 每个事件发送1点stdout用于性能跟踪 |
| edn | 读取EDN格式数据 |
| edn_lines | 读取以换行符分隔的EDN格式数据 |
| es_bulk | 将Elasticsearch批量格式与元数据一起读取为单独的事件 |
| fluent | 读取fluentd msgpack架构 |
| graphite | 读取graphite格式化的行 |
| gzip_lines | 读取gzip编码内容 |
| jdots | 将每个已处理的事件呈现为一个点 |
| java_line | 编码和解码面向行的文本数据 |
| java_plain | 处理事件之间没有定界符的文本数据 |
| json | 读取JSON格式的内容 |
| json_lines | 读取以换行符分隔的JSON |
| line | 读取行文本数据 |
| msgpack | 读取MessagePack编码的内容 |
| multiline | 将多行消息合并为一个事件 |
| netflow | 读取Netflow v5和Netflow v9数据 |
| nmap | 读取XML格式的Nmap数据 |
| plain | 读取纯文本，事件之间没有定界 |
| protobuf | 读取protobuf消息并转换为Logstash事件 |
| rubydebug | 将Ruby Awesome Print库应用于Logstash事件 |

# string_duration类似数据配置

- 周: 支持格式：e.g. “2 w”, “1 week”, “4 weeks”.
- 天: 支持格式： e.g. “2 d”, “1 day”, “2.5 days”.
- 小时: 支持格式：e.g. “4 h”, “1 hour”, “0.5 hours”.
- 分钟: 支持格式：e.g. “45 m”, “35 min”, “1 minute”, “6 minutes”.
- 秒: 支持格式： e.g. “45 s”, “15 sec”, “1 second”, “2.5 seconds”.
- 毫秒: 支持格式：e.g. “500 ms”, “750 msec”, "50 msecs
- 微秒: 支持格式：e.g. “600 us”, “800 usec”, “900 usecs”
