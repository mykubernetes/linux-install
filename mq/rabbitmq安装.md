官网  
https://www.rabbitmq.com/  

安装
--
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

4、启动服务
```
rabbitmq-server start stop status restart
lsof -i:5672

rabbitmq-plugins enable rabbitmq_management
lsof -i:15672 或者 netstat -tnlp|grep 15672
```

5、网页验证  
http://192.168.101.66:15672/

以上操作三个节点同时进行操作

6、选择66、67、68任意一个节点为Master（这里选择66为Master），需要把66的Cookie文件同步到67、68节点上，
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
