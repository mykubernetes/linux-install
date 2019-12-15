```
! Configuration File for keepalived

global_defs {
   # 接收邮件地址
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   # 邮件发送地址
   notification_email_from Alexandre.Cassen@firewall.loc
   # 本地邮件服务器发邮件
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id NGINX_MASTER
}
vrrp_instance VI_1 {
    state MASTER
    interface ens33
    # mcast_src_ip 192.168.1.149   # 指定VRRP多播（组播）源IP地址
    # unicast_src_ip IP            # 指定VRRP单播源IP地址
    # unicast_peer {
    #     IP                 # 接收VRRP单播的IP地址
    # }
    virtual_router_id 51     # VRRP路由ID实例，每个实例是唯一的
    priority 100             # 优先级，备服务器设置90
    advert_int 1             # 指定VRRP心跳包通告间隔时间，默认1秒
    # VRRP验证块
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    # VIP定义块
    virtual_ipaddress {
        192.168.0.200/24
    }
}
virtual_server 192.168.0.200 80 {
    delay_loop 6
    lb_algo rr               #调度算法轮训
    lb_kind DR               #模式是DR模式
    protocol TCP             #协议tcp
    real_server 192.168.0.213 80 {
        # 四层健康检查
        TCP_CHECK {
            connect_port 80        #连接远程服务器的TCP端口
            connect_timeout 3      # 连接远程服务器超时时间
            nb_get_retry 3         # 最大重试次数
            delay_before_retry 3   # 连续两个重试之间的延迟时间
        }
    }
    real_server 192.168.0.214 80 {
        TCP_CHECK {
            connect_port 80
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
}

```

LVS DR RS配置
```
#!/bin/bash

VIP=192.168.0.200

NIC="lo:0"

case $1 in
    start)
        echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
        echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce

        ifconfig $NIC $VIP netmask 255.255.255.255 broadcast $VIP up  # 只有在即在这个网段内

        route add -host $VIP dev $NIC
    	;;
    stop)
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
      
        ifconfig $NIC down

        route del $VIP 
    	;;
    status)
        if ifconfig $NIC |grep $VIP &> /dev/null; then
            echo "$NIC is configured."
        else
            echo "$NIC not configured."
        fi

        if ifconfig $NIC |grep $VIP &> /dev/null; then
            echo "$NIC is configured."
        else 
            echo "$NIC not configured."
        fi   
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 0
esac

```
