# RGW 高可用

| 节点 | 组键 |
|-----|------|
| node1、node2 | 分别部署 radosgw，使用的80端口 |
| node1、node2 | 分别部署 keepalived，做高可用 |
| node1、node2 | 分别部署 haproxy，做负载均衡，使用 8080 端口 |

1、创建 rgw 2
```
# ceph-deploy rgw create node2
```

2、修改 rgw 端口
```
# cat ceph.conf
[global]
fsid = 3f5560c6-3af3-4983-89ec-924e8eaa9e06
public_network = 192.168.6.0/24
cluster_network = 172.16.79.0/16
mon_initial_members = node1
mon_host = 192.168.6.160
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
mon_allow_pool_delete = true

[client.rgw.node1]
rgw_frontends = "civetweb port=80"

[client.rgw.node2]
rgw_frontends = "civetweb port=80"

[osd]
osd crush update on start = false
[root@node1 my-cluster]# ceph-deploy --overwrite-conf config push node1 node2 node3
```

3、重启 node2 的 radosgw，使配置文件生效
```
# systemctl restart ceph-radosgw.target

# ceph -s
  cluster:
    id:     3f5560c6-3af3-4983-89ec-924e8eaa9e06
    health: HEALTH_WARN
            application not enabled on 1 pool(s)

  services:
    mon: 3 daemons, quorum node1,node2,node3 (age 6h)
    mgr: node1(active, since 6d), standbys: node2, node3
    mds: cephfs-demo:1 {0=node1=up:active} 2 up:standby
    osd: 6 osds: 6 up (since 6h), 6 in (since 2d)
    rgw: 2 daemons active (node1, node2)

  task status:
    scrub status:
        mds.node1: idle

  data:
    pools:   8 pools, 240 pgs
    objects: 386 objects, 430 MiB
    usage:   7.4 GiB used, 143 GiB / 150 GiB avail
    pgs:     240 active+clean
```



# keepalived 配置
```
# 两台节点部署 keepalived，node1 为 MASTER , node2 为 BACKUP

# cat /etc/keepalived/keepalived.conf
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

#   vrrp_strict

   vrrp_garp_interval 0
   vrrp_gna_interval 0
}
vrrp_script chk_haproxy {
        script "killall -0 haproxy"
        interval 1
        weight -20
}
vrrp_instance RGW {
    state MASTER
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        172.16.79.110/16
    }
    track_script {
        chk_haproxy
    }
}
```

# haproxy 配置模板
```
# haproxy 在 node1 和 node2 节点内容一致
[root@node1 ~]# cat /etc/haproxy/haproxy.cfg
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
frontend  http_web *:8080
    mode http
    default_backend rgw
backend rgw
    balance     roundrobin
    mode http
    server node1 172.16.79.100:80 check
    server node2 172.16.79.101:80 check
```

# 修改客户端指向为集群 Vip 地址即可
