Promtail 是负责收集日志发送给 loki 的代理程序，Promtail 默认通过一个 config.yaml 文件进行配置，其中包含 Promtail 服务端信息、存储位置以及如何从文件中抓取日志等配置。

要指定加载哪个配置文件，只需要在命令行下通过 -config.file 参数传递 YAML 配置文件即可。此外我们还可以通过在配置文件中使用环境变量引用来设置需要的配置，但是需要在命令行中配置 -config.expand-env=true。

然后可以使用 ${VAR} 来配置，其中 VAR 是环境变量的名称，每个变量的引用在启动时被环境变量的值替换，替换是区分大小写的，而且在 YAML 文件被解析之前发生，对未定义变量的引用将被替换为空字符串，除非你指定了一个默认值或自定义的错误文本，要指定一个默认值：
```
${VAR:default_value}
```
其中 default_value 是在环境变量未定义的情况下要使用的默认值。

默认的 config.yaml 配置文件支持的内容格式为：
```
# 配置 Promtail 服务端
[server: <server_config>]
 
# 描述 Promtail 如何连接到 Loki 的多个实例，向每个实例发送日志。
# WARNING：如果其中一个远程 Loki 服务器未能回应或回应时出现任何可重试的错误，这将影响其他配置的远程 Loki 服务器发送日志。
# 发送是在单线程上完成的!
# 如果你想向多个远程 Loki 实例发送，一般建议并行运行多个  promtail 客户端。
clients:
  - [<client_config>]
 
# 描述了如何将读取的文件偏移量保存到磁盘上
[positions: <position_config>]
 
# 抓取日志配置
scrape_configs:
  - [<scrape_config>]
 
# 配置被 watch 的目标如何 tailed
# Configures how tailed targets will be watched.
[target_config: <target_config>]
```

# server

- server 属性配置了 Promtail 作为 HTTP 服务器的行为。
```
# 禁用 HTTP 和 GRPC 服务
[disable: <boolean> | default = false]
 
# HTTP 服务监听的主机
[http_listen_address: <string>]
 
# HTTP 服务监听的端口（0表示随机）
[http_listen_port: <int> | default = 80]
 
# gRPC 服务监听主机
[grpc_listen_address: <string>]
 
# gRPC 服务监听的端口（0表示随机）
[grpc_listen_port: <int> | default = 9095]
 
# 注册指标处理器
[register_instrumentation: <boolean> | default = true]
 
# 优雅退出超时时间
[graceful_shutdown_timeout: <duration> | default = 30s]
 
# HTTP 服务读取超时时间
[http_server_read_timeout: <duration> | default = 30s]
 
# HTTP 服务写入超时时间
[http_server_write_timeout: <duration> | default = 30s]
 
# HTTP 服务空闲超时时间
[http_server_idle_timeout: <duration> | default = 120s]
 
# 可接收的最大 gRPC 消息大小
[grpc_server_max_recv_msg_size: <int> | default = 4194304]
 
# 可发送的最大 gRPC 消息大小
[grpc_server_max_send_msg_size: <int> | default = 4194304]
 
# 对 gRPC 调用的并发流数量的限制 (0 = unlimited)
[grpc_server_max_concurrent_streams: <int> | default = 100]
 
# 只记录给定严重程度或以上的信息，支持的值：[debug, info, warn, error]
[log_level: <string> | default = "info"]
 
# 所有 API 路由服务的基本路径(e.g., /v1/).
[http_path_prefix: <string>]
 
# 目标管理器检测 promtail 可读的标志，如果设置为 false 检查将被忽略
[health_check_target: <bool> | default = true]
```

# client

- client 属性配置了 Promtail 如何连接到 Loki 的实例。
```
# Loki 正在监听的 URL，在 Loki 中表示为 http_listen_address 和 http_listen_port
# 如果 Loki 在微服务模式下运行，这就是 Distributor 的 URL，需要包括 push API 的路径。
# 例如：http://example.com:3100/loki/api/v1/push
url: <string>
 
# 默认使用的租户 ID，用于推送日志到 Loki。
# 如果省略或为空，则会假设 Loki 在单租户模式下运行，不发送 X-Scope-OrgID 头。
[tenant_id: <string>]
 
# 发送一批日志前的最大等待时间，即使该批次日志数据未满。
[batchwait: <duration> | default = 1s]
 
# 在向 Loki 发送批处理之前要积累的最大批处理量（以字节为单位）。
[batchsize: <int> | default = 102400]
 
# 如果使用了 basic auth 认证，则需要配置用户名和密码
basic_auth:
  [username: <string>]
  [password: <string>]
  # 包含basic auth认证的密码文件
  [password_file: <filename>]
 
# 发送给服务器的 Bearer token
[bearer_token: <secret>]
 
# 包含 Bearer token 的文件
[bearer_token_file: <filename>]
 
# 用来连接服务器的 HTTP 代理服务器
[proxy_url: <string>]
 
# 如果连接到一个 TLS 服务器，配置 TLS 认证方式。
tls_config:
  # 用来验证服务器的 CA 文件
  [ca_file: <string>]
  # 发送给服务器用于客户端认证的 cert 文件
  [cert_file: <filename>]
  # 发送给服务器用于客户端认证的密钥文件
  [key_file: <filename>]
  # 验证服务器证书中的服务器名称是这个值。
  [server_name: <string>]
  # 如果为 true，则忽略由未知 CA 签署的服务器证书。
  [insecure_skip_verify: <boolean> | default = false]
 
# 配置在请求失败时如何重试对 Loki 的请求。
# 默认的回退周期为：
# 0.5s, 1s, 2s, 4s, 8s, 16s, 32s, 64s, 128s, 256s(4.267m)
# 在日志丢失之前的总时间为511.5s(8.5m)
backoff_config:
  # 重试之间的初始回退时间
  [min_period: <duration> | default = 500ms]
  # 重试之间的最大回退时间
  [max_period: <duration> | default = 5m]
  # 重试的最大次数
  [max_retries: <int> | default = 10]
 
# 添加到所有发送到 Loki 的日志中的静态标签
# 使用一个类似于 {"foo": "bar"} 的映射来添加一个 foo 标签，值为 bar
# 这些也可以从命令行中指定：
# -client.external-labels=k1=v1,k2=v2
# (或 --client.external-labels 依赖操作系统)
# 由命令行提供的标签将应用于所有在 "clients" 部分的配置。
# 注意：如果标签的键相同，配置文件中定义的值将取代命令行中为特定 client 定义的值
external_labels:
  [ <labelname>: <labelvalue> ... ]
 
# 等待服务器响应一个请求的最长时间
[timeout: <duration> | default = 10s]
```

# positions
- positions 属性配置了 Promtail 保存文件的位置，表示它已经读到了文件什么程度。当 Promtail 重新启动时需要它，以允许它从中断的地方继续读取日志。
```
# positions 文件的路径
[filename: <string> | default = "/var/log/positions.yaml"]
 
# 更新 positions 文件的周期
[sync_period: <duration> | default = 10s]
 
# 是否忽略并覆盖被破坏的 positions 文件
[ignore_invalid_yaml: <boolean> | default = false]
```

# scrape_configs
- scrape_configs 属性配置了 Promtail 如何使用指定的发现方法从一系列目标中抓取日志。
```
# 用于在 Promtail 中识别该抓取配置的名称。
job_name: <string>
 
# 描述如何对目标日志进行结构化
[pipeline_stages: <pipeline_stages>]
 
# 如何从 jounal 抓取日志
[journal: <journal_config>]
 
# 如何从 syslog 抓取日志
[syslog: <syslog_config>]
 
# 如何通过 Loki push API 接收日志 (例如从其他 Promtails 或 Docker Logging Driver 中获取的数据)
[loki_push_api: <loki_push_api_config>]
 
# 描述了如何 relabel 目标，以确定是否应该对其进行处理
relabel_configs:
  - [<relabel_config>]
 
# 抓取日志静态目标配置
static_configs:
  - [<static_config>]
 
# 包含要抓取的目标文件
file_sd_configs:
  - [<file_sd_configs>]
 
# 描述了如何发现在同一主机上运行的 Kubernetes 服务
kubernetes_sd_configs:
  - [<kubernetes_sd_config>]
```

# pipeline_stages
- pipeline_stages 用于转换日志条目和它们的标签，该管道在发现操作结束后执行，pipeline_stages 对象由一个阶段列表组成。
```
- [
    <docker> |
    <cri> |
    <regex> |
    <json> |
    <template> |
    <match> |
    <timestamp> |
    <output> |
    <labels> |
    <metrics> |
    <tenant>,
  ]
```
在大多数情况下，你用 regex 或 json 阶段从日志中提取数据，提取的数据被转化为一个临时的字典 Map 对象，然后这些数据是可以被 promtail 使用的，比如可以作为标签的值或作为输出。此外，除了 docker 和 cri 之外，任何其他阶段都可以访问提取的数据。在前文 pipeline 章节详细介绍了如何配置。

# loki_push_api
- loki_push_api 属性配置 Promtail 来暴露一个 Loki push API 服务。每个配置了 loki_push_api 的任务都会暴露这个 API，并且需要一个单独的端口。
```
# push 服务配置选项
[server: <server_config>]
 
# 标签映射，用于添加到发送到 push API 的每一行日志上
labels:
  [ <labelname>: <labelvalue> ... ]
 
# promtail 是否应该从传入的日志中传递时间戳
# 当为 false 时，promtail 将把当前的时间戳分配给日志
[use_incoming_timestamp: <bool> | default = false]
```

比如下面的配置示例，将 Promtail 作为一个 Push 接收器启动，并将接受来自其他 Promtail 实例或 Docker Logging Dirver 的日志。
```
server:
  http_listen_port: 9080
  grpc_listen_port: 0
 
positions:
  filename: /tmp/positions.yaml
 
clients:
  - url: http://ip_or_hostname_where_Loki_run:3100/loki/api/v1/push
 
scrape_configs:
  - job_name: push1
    loki_push_api:
      server:
        http_listen_port: 3500
        grpc_listen_port: 3600
      labels:
        pushserver: push1
```
注意必须提供 job_name，并且在多个 loki_push_api 与 scrape_configs 之间必须是唯一的，它将被用来注册监控指标。

由于一个新的服务器实例被创建，所以 http_listen_port 和 grpc_listen_port 必须与 promtail 服务器配置部分不同（除非它被禁用）。

# relabel_configs
- Relabeling 是一个强大的工具，可以在目标日志被抓取之前动态地重写其标签集。每个抓取配置可以配置多个 relabeling 步骤，按照它们在配置文件中出现的顺序应用于每个目标的标签集。

在 relabeling 之后，如果 `instance` 标签在 `relabeling` 的时候没有被设置，则默认设置为 `__address__` 的值，`__scheme__` 和 `__metrics_path__` 标签被分别设置为目标的协议和 `metrics` 指标路径。`__param_<name>` 标签被设置为第一个传递的 URL 参数 `<name>` 的值。

在 relabeling 阶段，以 `__meta_` 为前缀的额外标签也是可用的，它们是由提供目标的服务发现机制设置的，并且在不同的机制之间有所不同。

在目标 relabeling 完成后，以 `__` 开头的标签将从标签集中删除。

如果一个 relabeling 操作只需要临时存储一个标签值（作为后续重新标注步骤的输入），请使用 `__tmp` 标签名称前缀。

```
# 从现有标签中选择 values 值的源标签
# 它们的内容使用配置的分隔符连接起来，并与配置的正则表达式相匹配，以进行替换、保留和删除操作。
[ source_labels: '[' <labelname> [, ...] ']' ]
 
# 连接源标签值之间的分隔符
[ separator: <string> | default = ; ]
 
# 在一个 replace 替换操作后结果值被写入的标签
# 它对替换动作是强制性的，Regex 捕获组是可用的。
[ target_label: <labelname> ]
 
# 正则表达式，提取的值与之匹配
[ regex: <regex> | default = (.*) ]
 
[ modulus: <uint64> ]
 
Replacement 值：如果正则表达式匹配，则对其进行 regex 替换
[ replacement: <string> | default = $1 ]
 
# 根据正则匹配结果执行的动作
[ action: <relabel_action> | default = replace ]
```
- `<regex>` 是任何有效的 RE2 正则表达式，它是 `replace`、`keep`、`drop`、`labelmap`、`labeldrop` 和 `labelkeep` 操作的必要条件，该正则表达式在两端都是固定的，要取消对正则的锚定，请使用 `.*<regex>.*`。
- `<relabel_action>` 决定了要采取的 `relabeling` 动作：
  - `replace`：将正则表达式与连接的 `source_labels` 匹配，然后设置 `target_label` 为 `replacement`，用 `replacement` 中的匹配组引用`（、{2}…）`替换其值，如果正则表达式不匹配，则不会进行替换。
  - `keep`：删除那些 `regex 与 `source_labels` 不匹配的目标。
  - `drop`：删除与 `regex` 相匹配的 source_labels` 目标。
  - `hashmod`：将 `target_label` 设置为 source_labels` 的哈希值的模。
  - `labelmap`：将正则表达式与所有标签名称匹配，然后将匹配的标签值复制到由 `replacement` 给出的标签名中，`replacement`` 中的匹配组引用`（{2}, ...）`由其值代替。
  - `labeldrop`：将正则表达式与所有标签名称匹配，任何匹配的标签都将从标签集中删除。
  - `labelkeep`：将正则表达式与所有标签名称匹配，任何不匹配的标签将被从标签集中删除。

使用 `labeldrop` 和 `labelkeep` 时必须注意，一旦标签被移除，`logs` 仍然是唯一的标签。

# static_configs
- static_configs 静态配置允许指定一个目标列表和标签集：
```
# 配置发现在当前节点上查找
# 这是 Prometheus 服务发现代码所要求的，但并不适用于Promtail，它只能查看本地机器上的文件。
# 因此，它应该只有 localhost 的值，或者可以完全移除它，Promtail 会使用 localhost 的默认值。
targets:
  - localhost
 
# 定义一个要抓取的日志文件和一组可选的附加标签，以应用于由__path__定义的文件日志流。
labels:
  # 要加载日志的路径，可以使用 glob 模式(e.g., /var/log/*.log).
  __path__: <string>
 
  # 添加的额外标签
  [ <labelname>: <labelvalue> ... ]
```

比如这里我们配置一个如下所示的静态配置：
```
server:
  http_listen_port: 9080
  grpc_listen_port: 0
positions:
  filename: /var/log/positions.yaml # 这个位置需要是可以被promtail写入的
client:
  url: http://ip_or_hostname_where_Loki_run:3100/loki/api/v1/push
# 抓取配置
scrape_configs:
  - job_name: system
    pipeline_stages:
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs # 在 Prometheus中，job 标签对于连接指标和日志很有用
          host: yourhost # `host` 标签可以帮助识别日志来源
          __path__: /var/log/*.log # 路径匹配使用了一个第三方库: https://github.com/bmatcuk/doublestar
```

# file_sd_config
- 基于文件的服务发现提供了一种更通用的方式来配置静态目标。它读取一组包含零个或多个 `<static_config>` 列表的文件。对所有定义文件的改变通过监视磁盘变化来应用。文件可以以 YAML 或 JSON 格式提供。JSON 文件必须包含一个静态配置的列表，使用这种格式。
```
[
  {
    "targets": [ "localhost" ],
    "labels": {
      "__path__": "<string>", ...
      "<labelname>": "<labelvalue>", ...
    }
  },
  ...
]
```

此外文件内容也将以指定的刷新间隔定期重新读取。在 relabeling 标记阶段，每个目标都有一个元标签 `__meta_filepath`，它的值被设置为被提取的目标文件路径。
```
# 从中提取目标文件的模式。
files:
  [ - <filename_pattern> ... ]
 
# 重新读取文件的刷新频率
[ refresh_interval: <duration> | default = 5m ]
```
其中 `<filename_pattern>` 可以是一个以 .json、.yml 或 .yaml 结尾的路径，最后一个路径段可以包含一个匹配任何字符序列的 `*`，例如 `my/path/tg_*.json`。

# kubernetes_sd_config

- Kubernetes SD 配置允许从 Kubernetes 的 REST API 中检索抓取的目标，并始终与集群状态保持同步。关于 Kubernetes 发现的配置选项，如下所示：
```
# Kubernetes API 地址
# 如果留空，Prometheus 将被假定在集群内运行，并将自动发现 API 服务器并使用 pod 的 CA 证书和 bearer token 文件（在 /var/run/secrets/kubernetes.io/serviceaccount/ 目录下面）
[ api_server: <host> ]
 
# 发现的 Kubernetes 角色
role: <role>
 
# 可选的认证信息
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]
 
[ bearer_token: <secret> ]
[ bearer_token_file: <filename> ]
[ proxy_url: <string> ]
 
# TLS 配置
tls_config:
  [ <tls_config> ]
 
# 可选的命名空间发现，如果省略，将使用所有命名空间。
namespaces:
  names:
    [ - <string> ]
```

其中 `<role>` 必须是 endpoints、service、pod、node 或 ingress。具体的配置使用可以完全参考 Prometheus 中的基于 Kubernetes 的发现机制，可以查看 Promtheus 自动发现配置文件：https://github.com/prometheus/prometheus/blob/main/documentation/examples/prometheus-kubernetes.yml 了解更多配置。

参考：
- https://grafana.com/docs/loki/latest/clients/promtail/configuration/
