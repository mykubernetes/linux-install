````
# cat /etc/haproxy/haproxy.cfg
global
      maxconn     5000
      nbproc      16
      cpu-map   1    0
      cpu-map   2    1
      cpu-map   3    2
      cpu-map   4    3
      cpu-map   5    4
      cpu-map   6    5
      cpu-map   7    6
      cpu-map   8    7
      cpu-map   9    8
      cpu-map   10   9
      cpu-map   11   10
      cpu-map   12   11
      cpu-map   13   12
      cpu-map   14   13
      cpu-map   15   14
      cpu-map   16   15
      daemon
      ssl-default-bind-options no-sslv3
      ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
      log         127.0.0.1    local0
      tune.ssl.default-dh-param 2048
       

defaults
      mode        http
      option      httplog
      log         global
      option      forceclose
      timeout connect 60000ms
      timeout client  60000ms
      timeout server  60000ms
      #maxconn 50000
      #crt-base /etc/haproxy

listen admin_status
      bind 192.168.101.69:6575           #监听地址
      mode http                          #模式为http
      stats enable                       #开启管理页面
      stats realm Haproxy\ Statistics    #认证时显示的名
      stats uri /admin?stats             #管理页面的uri路径
      stats refresh 5s                   #设定自动刷新时间间隔
      stats hide-version                 #隐藏统计页面上HAProxy的版本信息
      stats auth admin:admin             #开启认证
      stats admin if TRUE                #启用管理功能，如果认证成功就开启

frontend oos_api_http
      bind 192.169.101.69:80
#      bind *:80
      backlog 8192
      reqadd X-Forwarded-Proto:\ http

#      acl is_post method POST
#      acl is_put method PUT
#      use_backend local_api if is_put or is_post
      default_backend api_backend

      option forwardfor
      option logasap
      option dontlognull
      log-format %ST\ %ts\ [%t]\ %ci:%cp\ %ft/%b/%s\ %Tq/%Tw/%Tc/%Tr/%Tt\ %ac/%fc/%bc/%sc/%rc\ %sq/%bq\ %B\ %hr\ %hs\ %{+Q}r

      capture response header x-amz-request-id len 60
      capture request header Content-Length len 60
      capture request  header Host len 40

frontend oos_api_https
      bind 192.168.101.69:443 ssl crt /etc/haproxy/crt/test.ca.pem
      backlog 8192

      reqadd X-Forwarded-Proto:\ https

      default_backend api_backend
      option forwardfor
      option logasap
      option dontlognull
      log-format %ST\ %ts\ [%t]\ %ci:%cp\ %ft/%b/%s\ %Tq/%Tw/%Tc/%Tr/%Tt\ %ac/%fc/%bc/%sc/%rc\ %sq/%bq\ %B\ %hr\ %hs\ %{+Q}r

      capture response header x-amz-request-id len 60
      capture request header Content-Length len 60
      capture request  header Host len 40

backend api_backend
      option allbackups
      mode        http
      hash-type   consistent
      balance     roundrobin
      #option      forwardfor
      server localhost  localhost:8080 check inter 1s rise 2 fall 5 
      server node001  node001:8080 check inter 1s rise 2 fall 5 backup
      server node002  node002:8080 check inter 1s rise 2 fall 5 backup 
      server node003  node003:8080 check inter 1s rise 2 fall 5 backup
      server node004  node004:8080 check inter 1s rise 2 fall 5 backup
```
