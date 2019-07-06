nginx开启四层代理
===
nginx从1.9.0版本开始，新增了ngx_stream_core_module模块，使nginx支持四层负载均衡。默认编译的时候该模块并未编译进去，需要编译的时候添加--with-stream，使其支持stream代理。  

官方文档stream模块地址：http://nginx.org/en/docs/stream/ngx_stream_core_module.html  

1、下载安装nginx  
```
wget http://nginx.org/download/nginx-1.16.0.tar.gz
cd nginx-1.16.0
./configure --prefix=/opt/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-pcre --with-stream
make && make install
groupadd -r nginx
useradd -g nginx -r nginx
#检查配置文件语法
/opt/sbin/nginx -t
#启动
/opt/sbin/nginx
#查看服务器是否启动
netstat -lntp|grep nginx
```  

2、修改配置文件  
```
worker_processes  1;
events {
    worker_connections  1024;
}

stream {
      upstream telnet {
        server node02:23  weight=5 max_fails=3 fail_timeout=30s;
     }

     server {
            listen 1023;
            proxy_pass telnet;
            proxy_connect_timeout 10s;
            proxy_timeout 24h;
              }
  }

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }
  }
}
```  

3、检查端口是否监听  
```
# lsof -i:1023
COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
nginx   8743  root   11u  IPv4 162505      0t0  TCP *:1023 (LISTEN)
nginx   8818 nginx   11u  IPv4 162505      0t0  TCP *:1023 (LISTEN)

#netstat -lntp|grep nginx
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      8743/nginx: master  
tcp        0      0 0.0.0.0:1023            0.0.0.0:*               LISTEN      8743/nginx: master
```  

4、测试  
```
# telnet node03 1023
Trying 192.168.101.71...
Connected to node03.
Escape character is '^]'.

Kernel 3.10.0-693.el7.x86_64 on an x86_64
node02 login:
```  
