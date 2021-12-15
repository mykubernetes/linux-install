# 基本概念

- Server(broker): 接受客户端连接，实现AMQP消息队列和路由功能的进程。
- Virtual Host:其实是一个虚拟概念，类似于权限控制组，一个Virtual Host里面可以有若干个Exchange和Queue，但是权限控制的最小粒度是Virtual Host。
- Exchange:接受生产者发送的消息，并根据Binding规则将消息路由给服务器中的队列。ExchangeType决定了Exchange路由消息的行为，例如，在RabbitMQ中，ExchangeType有direct、Fanout和Topic三种，不同类型的Exchange路由的行为是不一样的。
- Message Queue：消息队列，用于存储还未被消费者消费的消息。
- Message: 由Header和Body组成，Header是由生产者添加的各种属性的集合，包括Message是否被持久化、由哪个Message Queue接受、优先级是多少等。而Body是真正需要传输的APP数据。
- Binding:Binding联系了Exchange与Message Queue。Exchange在与多个Message Queue发生Binding后会生成一张路由表，路由表中存储着Message Queue所需消息的限制条件即Binding Key。当Exchange收到Message时会解析其Header得到Routing Key，Exchange根据Routing Key与Exchange Type将Message路由到Message Queue。Binding Key由Consumer在Binding Exchange与Message Queue时指定，而Routing Key由Producer发送Message时指定，两者的匹配方式由Exchange Type决定。
- Connection:连接，对于RabbitMQ而言，其实就是一个位于客户端和Broker之间的TCP连接。
- Channel:信道，仅仅创建了客户端到Broker之间的连接后，客户端还是不能发送消息的。需要为每一个Connection创建Channel，AMQP协议规定只有通过Channel才能执行AMQP的命令。一个Connection可以包含多个Channel。之所以需要Channel，是因为TCP连接的建立和释放都是十分昂贵的，如果一个客户端每一个线程都需要与Broker交互，如果每一个线程都建立一个TCP连接，暂且不考虑TCP连接是否浪费，就算操作系统也无法承受每秒建立如此多的TCP连接。RabbitMQ建议客户端线程之间不要共用Channel，至少要保证共用Channel的线程发送消息必须是串行的，但是建议尽量共用Connection。
- Command:AMQP的命令，客户端通过Command完成与AMQP服务器的交互来实现自身的逻辑。例如在RabbitMQ中，客户端可以通过publish命令发送消息，txSelect开启一个事务，txCommit提交一个事务。

# 用户角色

## 用户角色分为5中类型：

- 用户角色可分为五类，超级管理员, 监控者, 策略制定者, 普通管理者以及其他。

### 超级管理员(administrator)

- 可登陆管理控制台(启用management plugin的情况下)，可查看所有的信息，并且可以对用户，策略(policy)进行操作。

### 监控者(monitoring)

- 可登陆管理控制台(启用management plugin的情况下)，同时可以查看rabbitmq节点的相关信息(进程数，内存使用情况，磁盘使用情况等)

### 策略制定者(policymaker)

- 可登陆管理控制台(启用management plugin的情况下), 同时可以对policy进行管理。但无法查看节点的相关信息

### 普通管理者(management)

- 仅可登陆管理控制台(启用management plugin的情况下)，无法看到节点信息，也无法对策略进行管理。

### 其他(none)

- 无法登陆管理控制台，通常就是普通的生产者和消费者。

# 1.5	端口及其用途

| 端口 | 用途 |
|------|-----|
| 5672 | 客户端连接端口 |	
| 15672 | web管控台端口 |
| 25672 | 集群通信端口 |



# 常用命令

## 节点管理
```
# 查询节点状态
rabbitmqctl status

# 停止RabbitMQ应用，但是Erlang虚拟机还是处于运行状态。此命令的执行优先于其他管理操作，比如rabbitmqctl reset。
rabbitmqctl stop_ app 

# 启动RabbitMQ应用。在执行了其他管理操作之后，重新启动之前停止的RabbitMQ应用，比rabbitmqctl reset。
rabbitmqctl start_app

# 重置RabbitMQ节点，将RabbitMQ节点重置还原到最初状态。包括从原来所在的集群中删除此节点，从管理数据库 中删除所有的配置数据，如己配置的用户、 vhost 等，以及删除所有的持久化消息。执行 rabbi tmqctl reset 命令前必须停止RabbitMQ 应用。
rabbitmqctl reset

# 强制将 RabbitMQ 节点重置还原到最初状态。不同于 rabbitmqctl reset 命令， rabbitmqctl force_reset 命令不论当前管理数据库的状态和集群配置是什么，都会无条件地重直节点。它只能在数据库或集群配置己损坏的情况下使用。与 rabbitmqctl reset 命令一样，执行 rabbitmqctl force_reset 命令前必须先停止 RabbitMQ 应用。
rabbitmqctl force_reset

# 指示RabbitMQ节点轮换日志文件。RabbitMQ节点会将原来的日志文件中的内容追加到"原 始名称+后缀"的日志文件中，然后再将新的日志内容记录到新创建的日志中(与原日志文件同名)。当目标文件不存在时，会重新创建。如果不指定后缀suffix. 则日志文件只是重新打开而不会进行轮换。
rabbitmqctl rotate_logs {suffix}

# 停止运行RabbitMQ的Erlang虚拟机和RabbitMQ应用。如果RabbitMQ没有成功关闭，则会返回一个非零值。这个命令和rabbitmqctl stop 不同的是，它不需要指定pid_file而可以阻塞等待指定进程的关闭。
rabbitmqctl shutdown

# 停止运行RabbitMQ的Erlang虚拟机和RabbitMQ服务应用，其中pid_file是通过rabbitmq-server命令启动RabbitMQ 服务时创建的，默认情况下存放于mnesia目录中。注意rabbitmq-server -detach 这个带有 -detach后缀的命令来启动 RabbitMQ 服务则不会生成 pid_file 文件。指定pid_file会等待指定进程的结束。
rabbitmqctl stop [pid_file] 

# 修改节点名称。
rabbitmqctl rename_cluster_node {oldnode1} {newnode1}  [oldnode2  newnode2] 
```

## 插件管理
```
# rabbitmq-plugins [-n node] {command} [command options ...]

# 启动插件
# rabbitmq-plugins enable [--offline] [--online] {plugin ...}
rabbitmq-plugins enable rabbitmq_management

# 禁用插件
# rabbitmq-plugins disable [--offline] [--online] {plugin ...}
rabbitmq-plugins disable  rabbitmq_management
# 表示启用参数指定的插件，并且禁用其他所有插件

# 没有参数表示禁用所有的插件
rabbitmq-plugin set rabbitmq_management

# 显示所有的插件，每一行一个
rabbitmq-plugins list

# 显示所有的插件，并且显示插件的版本号和描述信息
rabbitmq-plugins list -v

# 显示所有名称含有 "management" 的插件
rabbitmq-plugins list -v management

# 显示所有显示或者隐式启动的插件
rabbitmq-plugins list -e rabbit
```

## 对象管理
```
# name：罗列出所有虚拟机，tracing：表示是否使用了 RabbitMQ 的 trace 功能
rabbitmqctl list_vhosts [name,tracing]
# 查看交换器
rabbitmqctl list_exchanges [-p vhost] [exchangeinfoitem ...]
# 查看绑定关系的细节
rabbitmqctl list_bindings [-p vhost] [bindinginfoitem ...]
# 查看已声明的队列
rabbitmqctl list_queues [-p vhost] [queueinfoitem ...] 
# 返回 TCP!IP连接的统计信息。
rabbìtmqctl lìst_connectìons [connectìonìnfoìtem ...]
# 返回当前所有信道的信息。
rabbitmqctl list_channels [channelinfoitem ...]
# 列举消费者信息 每行将显示由制表符分隔的己订阅队列的名称、相关信道的进程标识、consumerTag、是否需要消费端确认 prefetch_count 及参数列表这些信息。
rabbitmqctl list_consumers [-p vhost]

# 创建一个新的 vhost ，大括号里的参 数表示 vhost 的名称。
rabbitmqctl add vhost {vhostName}
# 删除一个vhost，同时也会删除其下所有的队列、交换器、绑定关系、 用户权限、参数和策略等信息。
rabbitmqctl delete_vhost {vhostName}
# RabbitMQ 中的授予权限是指在 vhost 级别对用户而言的权限授予。
rabbitmqctl set permissions [-p vhostName] {userName} {conf} {write} {read} 
# 对RabbitMQ 节点进行健康检查,确认应用是否正常运行、list_queues list_channels 是否能够正常返回等。
rabbitmqctl node_health_check
# 显示每个运行程序环境中每个变量的名称和值。
rabbitmqctl environment
# 为所有服务器状态生成一个服务器状态报告，井将输出重定向到一个文件：rabbitmqctl report > report.txt
rabbitmqctl report
# 显示 Broker 的状态，比如当前 Erlang 节点上运行的应用程序、RabbitMQ/Erlang的版本信息、os 的名称、内 存及文件描述符等统计信息。
rabbitmqctl status
```

## 策略管理
```
# 策略查看
rabbitmqctl list_policies [-p <vhost>]

# 策略设置
rabbitmqctl set_policy [-p <vhost>] [--priority <priority>] [--apply-to <apply-to>] <name> <pattern>  <definition>

# 策略清除
rabbitmqctl clear_policy [-p <vhost>] <name>
```

## 集群管理
```
# 显示集群的状态
rabbitmqctl cluster_status 
# 将节点加入指定集群中。在这个命令执行前需要停止 RabbitMQ应用井重置节点。
rabbitmqctl joio_cluster {cluster_node} [--ram] 
# 修改集群节点的类型。在这个命令执行前需要停止 RabbitMQ应用。
rabbitmqctl change_cluster_node_type {disc|ram}
# 将节点从集群中删除，允许离线执行。
rabbitmqctl forget_cluster_node [--offiine] 

# 来查看那些slaves已经完成同步：
rabbitmqctl list_queues {queue_name} {slave_pids} synchronised_slave_pids
# 手动的方式同步一个queue：
rabbitmqctl sync_queue {queue_name}
# 取消某个queue的同步功能：
rabbitmqctl cancel_sync_queue {queue_name}
```

## 用户管理
```
# 查看用户列表
rabbitmqctl list_users

# 删除用户
rabbitmqctl delete_user {username}

# 清除用户密码
rabbitmqctl clear_password {username}

# 修改密码
rabbitmqctl change_password {username} {newPassword}

# 验证用户
rabbitmqctl authentiçate_user {username} {passWord}

# 新增用户
rabbitmqctl add_user {username} {password}

# 给用户授权
rabbitmqctl set_user_tags {username} {roles}

# 清楚用户对某个虚拟机的权限。
rabbitmqctl clear_permissions [-p vhostName] {username}

# 用来显示虚拟主机上的权限。
rabbitmqctl list_permissions [-p vhost] 

# 用来显示用户在已分配虚拟机上的权限。
rabbitmqctl list_user_permissions {username}

# 设置用户权限。
rabbitmqctl set permissions [-p vhostName] {userName} {conf} {write} {read} 
rabbitmqctl set_permissions -p {vhostpath} {username} ".*"  ".*"  ".*"
vhostName Vhost路径
user 用户名
Conf 一个正则表达式match哪些配置资源能够被该用户访问。
Write 一个正则表达式match哪些配置资源能够被该用户读。
Read 一个正则表达式match哪些配置资源能够被该用户访问
```

# 命令实战

用户操作
```
# 可以创建管理员用户，负责整个MQ的运维
rabbitmqctl add_user admin adminpasspord
# 赋予其administrator角色
rabbitmqctl set_user_tags admin administrator
# 创建RabbitMQ监控用户，负责整个MQ的监控
rabbitmqctl add_user  user_monitoring  passwd_monitor  
# 赋予其monitoring角色
rabbitmqctl set_user_tags user_monitoring monitoring
```

参考：
- https://blog.51cto.com/u_13917261/2164003
- https://www.cnblogs.com/xishuai/p/rabbitmq-cli-rabbitmqadmin.html
