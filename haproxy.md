官方提供配置信息 https://cbonte.github.io/haproxy-dconv/  

```
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

frontend api_http
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

frontend api_https
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
      
listen test1
      bind 0.0.0.0:8008
      mode tcp
      balance roundrobin
      server s1 127.0.0.1:8010 weight 1 maxconn 10000 check inter 10s
      server s2 127.0.0.1:8011 weight 1 maxconn 10000 check inter 10s
      server s3 127.0.0.1:8012 weight 1 maxconn 10000 check inter 10s
```  

算法：  
- roundrobin：动态算法：支持权重的运行时调整，支持慢启动；每个后端中最多支持4095个server；
- static-rr：静态算法：不支持权重的运行时调整及慢启动；后端主机数量无上限；
- leastconn：推荐使用在具有较长会话的场景中，例如MySQL、LDAP等；
- first：根据服务器在列表中的位置，自上而下进行调度；前面服务器的连接数达到上限，新请求才会分配给下一台服务；
- source：源地址hash；除权取余法：一致性哈希：
- uri：对URI的左半部分做hash计算，并由服务器总权重相除以后派发至某挑出的服务器；
- url_param：对用户请求的uri听<params>部分中的参数的值作hash计算，并由服务器总权重相除以后派发至某挑出的服务器；通常用于追踪用户，以确保来自同一个用户的请求始终发往同一个Backend Server；
- hdr(name)：对于每个http请求，此处由<name>指定的http首部将会被取出做hash计算； 并由服务器总权重相除以后派发至某挑出的服务器；没有有效值的会被轮询调度； 
- rdp-cookie	


hash-type：哈希算法  
- map-based：除权取余法，哈希数据结构是静态的数组；
- consistent：一致性哈希，哈希数据结构是一个树；

连接超时时长：  
```
timeout client <timeout> 默认单位是毫秒;
timeout server <timeout>
timeout http-keep-alive <timeout> 持久连接的持久时长
timeout http-request <timeout> HTTP请求的最大允许时间
timeout connect <timeout> 设置等待服务器连接尝试成功的最长时间
timeout client-fin <timeout> 为半关闭的连接在客户端设置非活动超时。
timeout server-fin <timeout> 为半关闭的连接在服务器端设置的非活动超时。 
```  

日志系统：	
```
log：
  log global  
  log <address> [len <length>] <facility> [<level> [<minlevel>]]  
  no log  
log-format <string>：
capture cookie <name> len <length>  在请求和响应中捕获并记录cookie。 

capture request header <name> len <length> 捕获并记录指定请求头的最后一次出现。 
列:
capture request header X-Forwarded-For len 15  

capture response header <name> len <length> 捕获并记录指定响应头的最后一次出现。
列:
capture response header Content-length len 9  
capture response header Location len 15  
```  
