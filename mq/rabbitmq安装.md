官网  
https://www.rabbitmq.com/  

配置文件地址  
http://www.rabbitmq.com/configure.html#configuration-file

常用命令
===

用户相关
---
| 命令 | 描述 |
|------|-----|
| `rabbitmqctl add_user <username> <password>` | 添加用户 |
| `rabbitmqctl list_user`  | 列出所有用户 |
| `rabbitmqctl delete_user <username>` | 删除用户 |
| `rabbtimqctl clear_permissions -p <vhostpath> <username>` | 清除用户权限 |
| `rabbitmqctl list_user_permissions <username>` | 列出用户权限 |
| `rabbitmqctl change_password <username newpassword>` | 修改密码 |
| `rabbitmqctl set_permission -p <vhostpath> <username> ".*" ".*" ".*"` | 设置用户权限 |

| 命令 | 描述 |
|------|-----|
| vhost | 授予用户访问权限的虚拟主机的名称，默认为"/" |
| user | 授予对指定虚拟主机的访问权限的用户名 |
| conf | 与资源名称（用户被授予配置权限）匹配的正则表达式 |
| write | 与资源名称相匹配的正则表达式，用户被授予写权限 |
| read | 与资源名称相匹配的正则表达式，已授予用户读取权限 |
```
set_permissions [-p vhost] user conf write read
```

虚拟主机相关
---
| 命令 | 描述 |
|------|-----|
| `rabbitmqctl add_vhost vhostpath` | 创建虚拟主机 |
| `rabbitmqctl list_vhosts` | 列出所有虚拟主机 |
| `rabbitmqctl list_permissions -p <vhostpath>` | 列出虚拟主机上所有权限 |
| `rabbtimqctl delete_vhost <vhostpath>` | 删除虚拟主机 |

队列相关
---
| 命令 | 描述 |
|------|-----|
| `rabbitmqctl list_queues` | 查看所有队列信息 |
| `rabbitmqctl list_queues -p /blog` | 查看/blog这个虚拟机下的所有消息队列 |
| `rabbitmqctl list_queues name message consumers memory durable auto_delete` | 查看队列名称、消息数目、消费者数目、以及内存使用情况(单位:b/字节)、是否持久化、是否自动删除 |
| `rabbitmqctl -p <vhostpath> purge_queue blue` | 清除队列里的消息 |


交换机相关
---
| 命令 | 描述 |
|------|-----|
| `rabbitmqctl list_exchanges` | 查看所有交换机信息，返回交换机名称和类型 |
| `rabbitmqctl list_exchanges name type durable auto_delete` | 查看交换机的额外信息，默认是持久化不会被删除 |
| `rabbitmqctl list_bindings` | 列出绑定 |
 
高级命令
---
| 命令 | 描述 |
|------|-----|
| `rabbitmqctl reset` | 移除所数据，要在rabbitmqctl stop_app之后使用 |
| `rabbitmqctl force_reset` | 作用和rabbitmqctl reset一样，区别是无条件重置节点，不管当前管理数据库状态以及集群的配置。如果数据库或者集群配置发生错误才使用这个最后的手段 |
| `rabbitmqctl join_cluster <clusternode> [--ram]` | 组成集群 |
| `rabbitmqctl status` | 节点状态 |
| `rabbitmqctl cluster_status` | 查看集群状态 |
| `rabbitmqctl change_cluster_node_type [disc] or [ram]` | 修改集群节点的存储形式 |
| `rabbitmqctl forget_cluster_node [--offline]` | 忘记节点（摘除节点） |
| `rabbitmqctl raname_cluster_node [oldnode1] [newnode1] [oldnode2] [newnode2] ...` | 修改节点名称 |
| `rabbitmqctl stop_app` | 关闭应用（关闭当前启动的节点） |
| `rabbitmqctl start_app` | 启动应用，和上述关闭命令配合使用，达到清空队列的目的 |
| `rabbitmq-server` | 前台启动 |
| `rabbitmq-server -detached` | 后台启动 |


用户角色分类
--- 
用户角色可分为五类，超级管理员, 监控者, 策略制定者, 普通管理者以及其他。
- 超级管理员(administrator): 可登陆管理控制台(启用management plugin的情况下)，可查看所有的信息，并且可以对用户，策略(policy)进行操作。
- 监控者(monitoring): 可登陆管理控制台(启用management plugin的情况下)，同时可以查看rabbitmq节点的相关信息(进程数，内存使用情况，磁盘使用情况等)
- 策略制定者(policymaker): 可登陆管理控制台(启用management plugin的情况下), 同时可以对policy进行管理。但无法查看节点的相关信息
- 普通管理者(management): 仅可登陆管理控制台(启用management plugin的情况下)，无法看到节点信息，也无法对策略进行管理。
- 其他: 无法登陆管理控制台，通常就是普通的生产者和消费者。

设置用户角色的命令为：
```
rabbitmqctl set_user_tags User Tag
User为用户名， Tag为角色名(对应于上面的administrator，monitoring，policymaker，management，或其他自定义名称)。
也可以给同一用户设置多个角色，例如
rabbitmqctl set_user_tags hncscwc monitoring policymaker
```

安装
---
1、首先需要安装erlang
```
# rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/epel/epel-release-latest-7.noarch.rpm
# yum install erlang -y
```

2、安装RabbitMQ
```
# wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.6/rabbitmq-server-3.6.6-1.el7.noarch.rpm
# yum install rabbitmq-server-3.6.6-1.el7.noarch.rpm 

完成后启动服务：
# service rabbitmq-server start
可以查看服务状态：
#s ervice rabbitmq-server status
```

3、修改host
```
vim /etc/hosts
192.168.101.66      rabbitmq1
192.168.101.67      rabbitmq2
192.168.101.68      rabbitmq3
```

4、配置文件

我们要自己在$Home/etc/rabbitmq中创建rabbitmq-env.conf, 详细信息请参阅 官方配置说明
```
# 创建持久化目录
➜  mkdir -p /ahdata/rabbitmq/store
➜  mkdir -p /ahdata/rabbitmq/logs

# 创建配置文件
➜  vim /opt/rabbitmq_server-3.8.2/etc/rabbitmq/rabbitmq-env.conf

# 指定节点的名字，默认rabbit@${hostname}
NODENAME=rabbit@MQ1

# 指定端口，默认5672
NODE_PORT=5672

# 配置持久目录
MNESIA_BASE=/ahdata/rabbitmq/store

# 配置日志目录 默认文件名字：${NODENAME}.log 可以用配置修改
LOG_BASE=/ahdata/rabbitmq/logs
```

5、常用命令
```
➜  sbin/rabbitmq-server                          # 启动server
➜  sbin/rabbitmq-server -detached                # 后台启动server
➜  sbin/rabbitmqctl status                       # 查看节点状态
➜  sbin/rabbitmqctl shutdown                     # 停止运行的节点
➜  sbin/rabbitmqctl stop_app
➜  sbin/rabbitmqctl start_app
➜  sbin/rabbitmqctl cluster_status               # 查看集群状态
➜  sbin/rabbitmqctl set_cluster_name rabbit@MQ1  # 修改集群名称
➜  sbin/rabbitmqctl join_cluster <cluster_name>  # 加入集群
➜  sbin/rabbitmqctl change_cluster_node_type --node <node_name> [ disk | ram ]  # 修改节点类型、
```

6、启动服务
```
rabbitmq-server start stop status restart
lsof -i:5672

# 查看节点状态
rabbitmqctl status

rabbitmq-plugins enable rabbitmq_management
lsof -i:15672 或者 netstat -tnlp|grep 15672
```

7、网页验证  
http://192.168.101.66:15672/

以上操作三个节点同时进行操作

8、选择66、67、68任意一个节点为Master（这里选择66为Master），需要把66的Cookie文件同步到67、68节点上，

- Erlang 节点间通过认证 Erlang cookie 的方式允许互相通信。因为 rabbitmqctl 使用 Erlang OTP 通信机制来和 Rabbit 节点通信，运行 rabbitmqctl 的机器和所要连接的 Rabbit 节点必须使用相同的 Erlang cookie 。否则你会得到一个错误。
```
# rabbitmq-server stop 
# cd /var/lib/rabbitmq
文件的权限修改为777，未修改前是400
# chmod 777 /var/lib/rabbitmq/.erlang.cookie
或者
# chmod u+w .erlang.cookie
然后把.erlang.cookie文件copy到各个节点下；最后把所有cookie文件权限还原为400即可
scp /var/lib/rabbitmq/.erlang.cookie 192.168.101.67:/var/lib/rabbitmq
scp /var/lib/rabbitmq/.erlang.cookie 192.168.101.68:/var/lib/rabbitmq
```

组件成集群
---
1、停止MQ服务
```
rabbitmqctl stop
```

2、组成集群操作，3个节点（66，67,68）执行启动命令
```
rabbitmq-server -detached
```

3、slave加入集群操作（重新加入集群也是如此，以最开始的主节点为加入节点）
```
节点rabbitmq2执行操作
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rabbitmq1
rabbitmqctl start_app

节点rabbitmq3执行操作
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rabbitmq1
rabbitmqctl start_app

其他节点上操作要移除的集群节点
rabbitmqctl forget_cluster_node rabbit@hadoop1
```

4、修改集群名称
```
rabbitmqctl set_cluster_name rabbitmq_cluster1
```

5、查看集群状态
```
rabbitmqctl cluster_status
```

6、管控台界面

http://192.168.101.66:15672

7、配置镜像队列
```
rabbitmqctl set_policy ha-all "^ha\." '{"ha-mode":"all","ha-sync-mode":"automatic"}'
```
将所有队列设置为镜像队列，即队列会被复制到各个节点，各个节点状态一致，RabbitMQ高可用集群就已经搭建好了

安装KeepAlived 
---

1、安装keepalived
```
yum -y install keepalived
```

2、主 master
```
vim  /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
notification_email {
acassen@firewall.loc
failover@firewall.loc
sysadmin@firewall.loc
}
notification_email_from Alexandre.Cassen@firewall.loc
smtp_server 192.168.200.1
smtp_connect_timeout 30
router_id LVS_DEVEL
vrrp_skip_check_adv_addr
#vrrp_strict                         #要注释掉
vrrp_garp_interval 0
vrrp_gna_interval 0
}
 
vrrp_script chk_haproxy {
    script "service haproxy status"  # 服务探测，返回0说明服务是正常的
    interval 1                       # 每隔1秒探测一次
    weight -2                        # 不正常时，权重-1，即haproxy上线，权重加2；下线，权重减2
}
 
vrrp_instance haproxy {
    state MASTER                 # 主机为MASTER，备机为BACKUP
    interface eth0               # 监测网络端口，用ifconfig查看
    virtual_router_id 108        # 虚拟路由标识，同一个VRRP实例要使用同一个标识，主备机必须相同
    priority 100                 # 主备机取不同的优先级，确保主节点的优先级高过备用节点
    advert_int 1                 # VRRP Multicast广播周期秒数  用于设定主备节点间同步检查时间间隔
    authentication {
        auth_type PASS           # VRRP认证方式
        auth_pass 1234           # VRRP口令 主备机密码必须相同
    }
    track_script {               # 调用haproxy进程检测脚本，备节点不配置
        chk_haproxy
    }
    virtual_ipaddress {
        192.168.101.200             #vip
    }
    notify_master "/etc/keepalived/notify.sh master"      # 当前节点成为master时，通知脚本执行任务，一般用于启动某服务
    notify_backup "/etc/keepalived/notify.sh backup"      # 当前节点成为backup时，通知脚本执行任务，一般用于关闭某服务
}

```

3、备 slave
```
! Configuration File for keepalived
 
global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
   vrrp_skip_check_adv_addr
   # vrrp_strict                    #要注释掉
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}
 
 
vrrp_script chk_haproxy {
    script "service haproxy status" # 服务探测，返回0说明服务是正常的
    interval 1                      # 每隔1秒探测一次
    weight -2                       # 不正常时，权重-1，即haproxy上线，权重加2；下线，权重减2
}
 
vrrp_instance haproxy {
    state BACKUP            # 主机为MASTER，备机为BACKUP
    interface eth0         # 监测网络端口，用ifconfig查看
    virtual_router_id 108   # 虚拟路由标识，同一个VRRP实例要使用同一个标识，主备机必须相同
    priority 99            # 主备机取不同的优先级，确保主节点的优先级高过备用节点
    advert_int 1            # VRRP Multicast广播周期秒数  用于设定主备节点间同步检查时间间隔
    authentication {
        auth_type PASS      # VRRP认证方式
        auth_pass 1234      # VRRP口令 主备机密码必须相同
    }
 
    virtual_ipaddress {     # VIP 漂移地址 即集群IP地址
        192.168.101.200
    }
}
```

4、编辑haproxy_check.sh脚本
```
# cd /etc/keepalived/

#vim haproxy_check.sh
#!/bin/bash
COUNT=`ps -C haproxy --no-header |wc -l`
if [ $COUNT -eq 0 ];then
    /usr/local/haproxy/sbin/haproxy -f /etc/haproxy/haproxy.cfg
    sleep 2
    if [ `ps -C haproxy --no-header |wc -l` -eq 0 ];then
        killall keepalived
    fi
fi
```

```
chmod +x /etc/keepalived/haproxy_check.sh
```

5、编辑notify.sh脚本
```
# cd /etc/keepalived/

vim notify.sh
#!/bin/bash
 
case "$1" in
    master)
        notify master
        service haproxy start
        exit 0
    ;;
    backup)
        notify backup
        service haproxy stop
        exit 0
    ;;
    fault)
        notify fault
        service haproxy stop
        exit 0
    ;;
    *)
        echo 'Usage: `basename $0` {master|backup|fault}'
        exit 1
    ;;
esac
```

```
chmod +x /etc/keepalived/notify.sh
```

Haproxy负载代理
---

1、安装haproxy
```
yum install haproxy
```

2、编辑配置文件
```
vim  /etc/haproxy/haproxy.cfg

#######################HAproxy监控页面#########################
listen http_front
        bind 0.0.0.0:1080           #监听端口
        stats refresh 30s           #统计页面自动刷新时间
        stats uri /haproxy?stats    #统计页面url
        stats realm Haproxy Manager #统计页面密码框上提示文本
        stats auth admin:1234      #统计页面用户名和密码设置
        #stats hide-version         #隐藏统计页面上HAProxy的版本信息
 
#####################RabbitMQ的管理界面###############################
listen rabbitmq_admin
    bind 192.168.101.200:15673
    server rabbitmq1 192.168.101.66:15672
    server rabbitmq2 192.168.101.67:15672
    server rabbitmq3 192.168.101.68:15672
 
#####################RabbitMQ服务代理###########################################
listen rabbitmq_cluster 192.168.101.200:5673
    mode tcp
    stats enable
    balance roundrobin
    option tcpka
    option tcplog
    timeout client 3h
    timeout server 3h
    timeout connect 3h
    #balance url_param userid
    #balance url_param session_id check_post 64
    #balance hdr(User-Agent)
    #balance hdr(host)
    #balance hdr(Host) use_domain_only
    #balance rdp-cookie
    #balance leastconn
    #balance source //ip
    server   rabbitmq1 192.168.101.66:5672 check inter 5s rise 2 fall 3   #check inter 2000 是检测心跳频率，rise 2是2次正确认为服务器可用，fall 3是3次失败认为服务器不可用
    server   rabbitmq2 192.168.101.67:5672 check inter 5s rise 2 fall 3
    server   rabbitmq2 192.168.101.68:5672 check inter 5s rise 2 fall 3
```

启动
```
service haproxy start
```

通过vip访问HAProxy管理页面  
http://192.168.101.200:1080/haproxy?stats


通过vip访问rabbitmq管理页面  
http://192.168.101.200:15673



集群配置文件
---
1、创建目录
```
mkdir /etc/rabbitmq
```

2、配置文件rabbitmq.config（可以不创建和配置，修改）

3、环境变量配置文件
```
# vim rabbitmq-env.conf
RABBITMQ_NODE_IP_ADDRESS=本机IP地址
RABBITMQ_NODE_PORT=5672
RABBITMQ_LOG_BASE=/var/lib/rabbitmq/log
RABBITMQ_MNESIA_BASE=/var/lib/rabbitmq/mnesia
```
配置参考参数如下：
- RABBITMQ_NODENAME=FZTEC-240088 节点名称
- RABBITMQ_NODE_IP_ADDRESS=127.0.0.1 监听IP
- RABBITMQ_NODE_PORT=5672 监听端口
- RABBITMQ_LOG_BASE=/data/rabbitmq/log 日志目录
- RABBITMQ_PLUGINS_DIR=/data/rabbitmq/plugins 插件目录
- RABBITMQ_MNESIA_BASE=/data/rabbitmq/mnesia 后端存储目录  

http://www.rabbitmq.com/configure.html#configuration-file

配置文件信息修改：
```
rabbit.app和rabbitmq.config配置文件配置任意一个即可，我们进行配置如下：
vim rabbit.app
```
- tcp_listerners 设置rabbimq的监听端口，默认为[5672]。
- disk_free_limit 磁盘低水位线，若磁盘容量低于指定值则停止接收数据，默认值为{mem_relative, 1.0},即与内存相关联1：1，也可定制为多少byte.
- vm_memory_high_watermark，设置内存低水位线，若低于该水位线，则开启流控机制，默认值是0.4，即内存总量的40%。
- hipe_compile 将部分rabbimq代码用High Performance Erlang compiler编译，可提升性能，该参数是实验性，若出现erlang vm segfaults，应关掉。
- force_fine_statistics， 该参数属于rabbimq_management，若为true则进行精细化的统计，但会影响性能


http://www.rabbitmq.com/configure.html
