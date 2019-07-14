Master节点配置keepalived  
---
```
# vim /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   notification_email {
     # acassen@firewall.loc
     # failover@firewall.loc
     # sysadmin@firewall.loc
   }   
   notification_email_from Alexandre.Cassen@firewall.loc
   # smtp_server 192.168.200.1
   # smtp_connect_timeout 30
   router_id LVS_DEVEL
   vrrp_skip_check_adv_addr
   vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_script chk_http_port {　　　　# vrrp_script定义脚本检测nginx服务是否在运行
    script "/opt/chk_ngx.sh"　　　 # 自定义脚本所在的路径，并将脚本添加可执行权限。
    interval 2　　　　             # 脚本执行的时间间隔；此处为2s检查一次
    weight -5　　　　              # 脚本结果导致的优先级变更
    fall 2　　　　                 # 检测2次失败才算是真的失败
    rise 1　　　　                 # 检测1次成功就算是真的成功
}

vrrp_instance VI_1 {　　　　   # vrrp实例；keepalived的virtual_router_id中priority(0-255)最大的成为MASTER，也就是接管虚拟IP(VIP)
    state MASTER　　　　       # 指定keepalived的状态为MASTER，但决定MASTER状态的为priority参数，该参数的权限值需要比BACKUP节点的设的要高，才能成为真正的MASTER，否则会被BACKUP抢占。
    interface ens3　　　　     # 侦听HA的网卡接口，防火墙规则需对该网卡指定vrrp协议。
    virtual_router_id 51　　  # 虚拟路由标志，该标志是一个数字；在同一个vrrp实例中使用同一个标志，即同一个vrrp实例中的MASTER和BACKUP使用相同的virtual_router_id。 
    priority 100　　　　       # 配置优先级；在同一个vrrp实例中，MASTER的优先级必须大于BACKUP的优先级，否则即使state定义为MASTER，也会被优先级定义更高的BACKUP所抢占。
    advert_int 1　　　　       # 配置MASTER与BACKUP节点间互相检查的时间间隔，单位是秒。
    authentication {　　　　   # 配置MASTER和BACKUP的验证类型和密码，两者必须一样。
        auth_type PASS　　　 　# 配置vrrp验证类型，主要有PASS和AH两种。
        auth_pass 1111　　　 　# 配置vrrp验证密码，在同一个vrrp_instance下，MASTER和BACKUP必须使用相同的密码才能正常通信。
    }
    virtual_ipaddress {　　　　# vrrp虚拟IP(VIP)，如果有多个VIP的话，可以写成多行。
        192.168.0.16/24
    }
    track_script {
        chk_http_port　　　　  # 引用vrrp_script中定义的脚本，定时运行，可实现MASTER和BACKUP间的切换。
    }
}
```

检查nginx存活行脚本  
---
```
# vim /opt/chk_ngx.sh　　　　# 监测nginx负载均衡服务的脚本，可根据nginx进程状态来切换keepalived的状态。
#!/bin/bash
status=$(ps -C nginx --no-headers | wc -l)
if [ $status -eq 0 ]; then　　　　# nginx服务停止后，再次启动nginx。
    /usr/local/nginx/sbin/nginx
    sleep 2
    counter=$(ps -C nginx --no-headers | wc -l)
    if [ "${counter}" -eq 0 ]; then　　　　# nginx再次启动失败后，停止master节点的keepalived，切换并启用backup节点。
        systemctl stop keepalived
    fi  
fi
```  


backup节点配置keepalived  
---
```
! Configuration File for keepalived

global_defs {
   notification_email {
     # acassen@firewall.loc
     # failover@firewall.loc
     # sysadmin@firewall.loc
   }   
   notification_email_from Alexandre.Cassen@firewall.loc
   # smtp_server 192.168.200.1
   # smtp_connect_timeout 30
   router_id LVS_DEVEL
   vrrp_skip_check_adv_addr
   vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_script chk_http_port {
    script "/opt/chk_ngx.sh"
    interval 2
    weight -5
    fall 2
    rise 1
}

vrrp_instance VI_1 {
    state BACKUP　　　　        # backup节点的keepalived状态必须配置为BACKUP
    interface ens3
    virtual_router_id 51　　　　# 在同一个vrrp实例中，master节点与backup节点的virtual_router_id必须相同。 
    priority 50　　　　         # backup节点的优先级必须小于master节点的优先级
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }   
    virtual_ipaddress {
        192.168.0.16/24
    }   
    track_script {
        chk_http_port
    }
}
```  

如果检查haproxy可使用此脚本  
---
```
#!/bin/bash
log_file="/usr/local/keepalived/haproxy_check.log"
date=`date '+%F_%H_%M'`
if [ `ps -C haproxy --no-header |wc -l` -eq 0 ];then
  echo "date" >> $ log_fileecho "haproxy is stopped, vip shift!" >> $ log_file
  echo " " >> $ log_file
  exit 1
else
  exit 0
fi
```  
