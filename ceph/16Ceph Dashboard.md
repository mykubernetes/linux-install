# Ceph dashboard

- dashboard（管理看板）是将多个仪表、图表、报表等组件内容整合在一个面板上进行综合显示的功能模块，提供灵活的组件及面板定义，并且提供大量预设置的组件模板，方便用户灵活选择，提高工作效率。可以使分析结果更具有良好的直观性、可理解性，快速掌握运营动态，为决策者做出决策提供更有利的数据支持。

## 1、启用 dashboard 插件
```
1、在每个mgr节点安装
# yum install ceph-mgr-dashboard 

2、列出所以版块
# ceph mgr module ls 

3、开启mgr功能
# ceph mgr module enable dashboard
```
> 注：模块启用后还不能直接访问，需要配置关闭 SSL 或启用 SSL 及指定监听地址。


## 2、启用 dashboard 模块
- Ceph dashboard 在mgr节点进行开启设置，并且可以配置开启或者关闭 SSL
```
#关闭 SSL
# ceph config set mgr mgr/dashboard/ssl false

#指定 dashboard 监听地址
# ceph config set mgr mgr/dashboard/ceph-mgr1/server_addr 10.0.0.104

#指定 dashboard 监听端口
# ceph config set mgr mgr/dashboard/ceph-mgr1/server_port 9009

#验证集群状态
# ceph -s
  cluster:
    id:     635d9577-7341-4085-90ff-cb584029a1ea
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 4h)
    mgr: ceph-mgr1(active, since 3m), standbys: ceph-mgr2
    mds: 2/2 daemons up, 2 standby
    osd: 12 osds: 12 up (since 4h), 12 in (since 3d)
    rgw: 2 daemons active (2 hosts, 1 zones)
 
  data:
    volumes: 1/1 healthy
    pools:   10 pools, 329 pgs
    objects: 372 objects, 314 MiB
    usage:   1.2 GiB used, 239 GiB / 240 GiB avail
    pgs:     329 active+clean
```

3、在 mgr 节点验证端口与进程
```
#mgr节点
#检查mgr服务是否正常运行，查看端口信息，如果不正常启动，重启一下服务
# sudo systemctl restart ceph-mgr@ceph-mgr1.service 

# ss -tnl
State          Recv-Q         Send-Q         Local Address:Port             Peer Address:Port    
LISTEN         0              128                  0.0.0.0:54113                 0.0.0.0:* 
LISTEN         0              128                  0.0.0.0:9443                  0.0.0.0:* 
LISTEN         0              128                127.0.0.1:42569                 0.0.0.0:* 
LISTEN         0              128                  0.0.0.0:9900                  0.0.0.0:* 
LISTEN         0              128                  0.0.0.0:111                   0.0.0.0:* 
LISTEN         0              5                 10.0.0.104:9009                  0.0.0.0:* 
LISTEN         0              128            127.0.0.53%lo:53                    0.0.0.0:* 
LISTEN         0              128                  0.0.0.0:22                    0.0.0.0:* 
LISTEN         0              128                127.0.0.1:6010                  0.0.0.0:* 
LISTEN         0              128         [::ffff:0.0.0.0]:2049                        *:* 
LISTEN         0              128                     [::]:43399                    [::]:* 
LISTEN         0              128                     [::]:111                      [::]:* 
LISTEN         0              128                     [::]:22                       [::]:* 
LISTEN         0              128                    [::1]:6010                     [::]:* 
```

4、设置 dashboard 账户及密码
```
# sudo touch pass.txt
# echo "123456" > pass.txt

# ceph dashboard set-login-credentials test -i pass.txt
******************************************************************
***          WARNING: this command is deprecated.              ***
*** Please use the ac-user-* related commands to manage users. ***
******************************************************************
Username and password updated

# 或者直接创建一个dashboard登录用户名密码
# ceph dashboard ac-user-create admin 123456 administrator 
```

5、dashboard 访问验证

http://10.0.0.104:9009

## 3、dashboard SSL

- 如果要使用 SSL 访问。则需要配置签名证书。证书可以使用 ceph 命令生成，或是 opessl 命令生成

1、ceph 自签名证书
```
# 生成证书
# ceph dashboard create-self-signed-cert
Self-signed certificate created

# 启用 SSL
# ceph config set mgr mgr/dashboard/ssl true

# 查看当前 dashboard 状态
# ceph mgr services
{
    "dashboard": "http://10.0.0.104:9009/"
}

# 使用配置生效
# ceph mgr module disable dashboard
# ceph mgr module enable dashboard

# 再次验证dashboard 状态
# ceph mgr services
{
    "dashboard": "https://10.0.0.104:9009/"
}
```


# Dashboard中启用RGW

```
1、创建rgw用户
# radosgw-admin user create --uid=rgw --display-name=rgw --system

2、记下输出的access_key 和 secret_key的值，之前没有记下也可以通过以下命令查看(可选)
# radosgw-admin user info --uid=rgw

3、为Dashboard设置access_key 和 secret_key。
# ceph dashboard set-rgw-api-access-key $access_key
# ceph dashboard set-rgw-api-secret-key $secret_key

4、配置rgw主机名和端口
# ceph dashboard set-rgw-api-host 10.0.0.104

5、刷新web页面
```

https://blog.51cto.com/renlixing/2487852
