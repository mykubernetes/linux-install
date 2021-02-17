一、前言
---
Kong配置文件是Kong服务的核心文件，它配置了Kong以怎么的方式运行，并且依赖于这个配置生成Nginx的配置文件


在Kong的配置文件中，约定了以下的几条规则：
- 配置文件中以#开头的行均为注释行，程序不会读取这些内容。
- 在官方提供的默认配置文件中，以#开头的有值的配置项目均为默认配置。
- 所有的配置项，均可以在系统环境变量中配置，但是必须要加上KONG_为前缀。
- 值为布尔型的配置，可以使用on/off或者true/false。
- 值为列表的，必须使用半角逗号分割。

Kong的配置，大概分为几种，分别是：
- 常规配置：配置服务运行目录，插件加载，日志等等
- NGINX配置：配置Nginx注入，例如监听IP和端口配置等等，用于Kong在启动的时候生成Nginx配置文件
- 数据库存储配置：配数据库类型，地址、用户名密码等等信息
- 数据库缓存配置：配置数据的缓存规则，Kong会缓存诸如API信息、用户、凭证等信息，以减少访问数据库次数提高性能
- DNS解析器配置：默认情况会使用系统设置，如hosts和resolv.conf的配置，你也可以通过DNS的解析器配置来修改
- 其他杂项配置：继承自lua-nginx模块的其他设置允许更多的灵活性和高级用法。

```
mv /etc/kong/kong.conf.default /etc/kong/kong.conf
```

二、常规配置
---

| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| prefix | /usr/local/kong/ | 配置Kong的工作目录 |
| log_level | notice | Nginx的日志级别。日志存放/logs/error.log |
| proxy_access_log | logs/access.log | 代理端口请求的日志文件 |
| proxy_error_log | logs/error.log | 代理端口请求的错误日志文件 |
| admin_access_log | logs/admin_access.log | Kong管理的API端口请求的日志文件 |
| admin_error_log | logs/error.log | Kong管理的API端口请求的错误日志文件 |
| plugins | bundled | Kong启动的时候加载的插件，如果多个必须要使用半角逗号分割 |
| anonymous_reports | on | 如果Kong进程发生错误，会以匿名方式将错误提交给Kong官方 |


三、Nginx注入配置
---

| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| proxy_listen | 0.0.0.0:8000, 0.0.0.0:8443 ssl| 配置Kong代理监听的地址和端口 |
| admin_listen | 127.0.0.1:8001, 127.0.0.1:8444 ssl | 配置Kong的管理API监听的端口 |
| nginx_user | nobody nobody | 配置Nginx的用户名和用户组，和Nginx的配置规则一样 |
| nginx_worker_processes | auto | 设置Nginx的进程书，通常等于CPU核心数 |
| nginx_daemon | on | 是否以daemon的方式运行Ngxin |
| mem_cache_size | 128m | 内存的缓存大小，可以使用k和m为单位 |
| ssl_cipher_suite | modern | 定义Nginx提供的TLS密码，可以配置的值有：modern,intermediate, old, custom. |
| ssl_ciphers | | 定义Nginx提供的TLS密码的列表，参考Nginx的配置 |
| ssl_cert | | 配置SSL证书的crt路径，必须是要绝对路径 |
| ssl_cert_key | | 设置SSL证书的key文件，必须是绝对路径 |
| client_ssl | off | ..... |
| client_ssl_cert | | ..... |
| client_ssl_cert_key | | ..... |
| admin_ssl_cert | | ..... |
| admin_ssl_cert_key | | ..... |
| headers | server_tokens, latency_tokens | 设置客户端注入的头部，可以设置的值如下：- server_tokens: 注入'Via'和'Server'头部.- latency_tokens: 注入'X-Kong-Proxy-Latency'和'X-Kong-Upstream-Latency' 头部.- X-Kong-<header-name>: 只有在适当的时候注入特定的头部 |
| trusted_ips | | 定义可信的IP地址段，通常不建议在此处限制请求，应该再插件中过滤 |
| real_ip_header | X-Real-IP | 获取客户端真实的IP，将值通过同步的形式传递给后端 |
| real_ip_recursive | off | 这个值在Nginx配置中设置了同名的ngx_http_realip_module指令 |
| client_max_body_size | 0 | 配置Nginx接受客户端最大的body长度，如果超过此配置 将返回413。设置为0则不检查长度 |
| client_body_buffer_size | 8k | 设置读取缓冲区大小，如果超过内存缓冲区大小，那么NGINX会缓存在磁盘中，降低性能。 |
| error_default_type | text/plain | 当请求' Accept '头丢失，Nginx返回请求错误时使用的默认MIME类型。可以配置的值为：text/plain,text/html, application/json, application/xml. |

四、 数据库存储配置
---

| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| database | postgres | 设置数据库类型，Kong支持两种数据库，一种是postgres，一种是cassandra |
| PostgreSQL配置 | | 如果database设置为postgres以下配置生效 |
| pg_host | 127.0.0.1 | 设置PostgreSQL的连接地址 |
| pg_port | 5432 | 设置PostgreSQL的端口 |
| pg_user | kong | 设置PostgreSQL的用户名 |
| pg_password | 设置PostgreSQL的密码 |
| pg_database | kong 	设置数据库名称 |
| pg_ssl | off | 是否开启ssl连接 |
| pg_ssl_verify | off | 如果启用了' pg_ssl '，则切换服务器证书验证。 |
| cassandra配置 | | 如果database设置为cassandra以下配置生效 |
| cassandra_contact_points | 127.0.0.1 | ..... |
| cassandra_port | 9042 | ..... |
| cassandra_keyspace | kong | ..... |
| cassandra_timeout | 5000 | ..... |
| cassandra_ssl | off | ..... |
| cassandra_ssl_verify | off | ..... |
| cassandra_username | kong | ..... |
| cassandra_password | | ..... |
| cassandra_consistency | ONE | ..... |
| cassandra_lb_policy | RoundRobin | ..... |
| cassandra_local_datacenter | | ..... |
| cassandra_repl_strategy | SimpleStrategy | ..... |
| cassandra_repl_factor | 1 | ..... |
| cassandra_data_centers | dc1:2,dc2:3 | ..... |
| cassandra_schema_consensus_timeout | 10000 	..... |

五、 数据库缓存配置
---

| 配置项 | 默认值 | 说明 |
|--------|-------|------|
| db_update_frequency | 5 | 节点更新数据库的时间，以秒为单位。这个配置设置了节点查询数据库的时间，假如有3台Kong服务器节点ABC，如果再A节点增加了一个API网关，那么B和C节点最多需要等待db_update_frequency时间才能被更新到。 |
| db_update_propagation | 0 | 数据库节点的更新时间。如果使用了Cassandra数据库集群，那么如果数据库有更新，最多需要db_update_propagation时间来同步所有的数据库副本。如果使用PostgreSQL或者单数据库，这个值可以被设置为0 |
| db_cache_ttl | 0 | 缓存生效时间，单位秒。如果设置为0表示永不过期Kong从数据库中读取数据并且缓存，在ttl过期后会删除这个缓存然后再一次读取数据库并缓存 |
| db_resurrect_ttl | 30 | 缓存刷新时间，单位秒。当数据存储中的陈旧实体无法刷新时(例如，数据存储不可访问)，应该对其进行恢复。当这个TTL过期时，将尝试刷新陈旧的实体。 |

六、 DNS解析器配置
---
默认情况下，DNS解析器将使用标准配置文件/etc/hosts和/etc/resolv.conf。如果设置了环境变量LOCALDOMAIN和RES_OPTIONS，那么后一个文件中的设置将被覆盖。

| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| dns_resolver | | 配置DNS服务器列表，用半角逗号分割，每个条目使用ip[:port]的格式，这个配置仅提供给Kong使用，不会覆盖节点系统的配置，如果没有配置则使用系统的设置。接受IPv4和IPv6的地址。 |
| dns_hostsfile | /etc/hosts |	配置Kong的hosts文件，这个配置同样仅提供给Kong使用，不会覆盖节点系统的配置。需要说明的是这个文件仅读取一次，读取的内容会缓存再内存中，如果修改了此文件，必须要重启Kong才能生效。 |
| dns_order | LAST,SRV,A,CNAME | 解析不同记录类型的顺序。“LAST”类型表示最后一次成功查找的类型(用于指定的名称) |
| dns_stale_ttl | 4 | 配置DNS记录缓存过期时间 |
| dns_not_found_ttl | 30 | 这个配置值不知道该如何理解？？ |
| dns_error_ttl | 1 | ..... |
| dns_no_sync | off | 如果启用了该项，那么在DNS缓存过期之后，每一次请求都会发起DNS查询。在禁用此项时，那么相同的域名多次请求会同步到一个查询中共享返回值。 |

- 基本上不需要更改，官网的配置给出了最优的配置。

七、 其他杂项配置
---

| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| lua_ssl_trusted_certificate | .... |
| lua_ssl_verify_depth |	1 | .... |
| lua_package_path | ./?.lua;./?/init.lua; | .... |
| lua_package_cpath | |	....  |
| lua_socket_pool_size | 30 |.... |
