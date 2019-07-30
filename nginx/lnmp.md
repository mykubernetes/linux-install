一、安装nginx  
---

1、下载nginx  
```
wget http://nginx.org/download/nginx-1.16.0.tar.gz
```  

2、安装编译 Nginx 所需的依赖包  
```
yum install gcc gcc-c++ make automake autoconf libtool pcre* zlib openssl openssl-devel
```  

3、编译安装 Nginx (添加 fastdfs-nginx-module 模块)  
```
tar -zxvf nginx-1.16.0.tar.gz
cd nginx-1.16.0

./configure --prefix=/opt/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-pcre
 
make && make install
```  

4、启动测试  
```
groupadd -r nginx
useradd -g nginx -r nginx
/opt/nginx/sbin/nginx -t           #测试配置文件
/opt/nginx/sbin/nginx              #启动
/opt/nginx/sbin/nginx -s reload    #重启
```  

二、安装php  

1、下载php  
```
wget https://github.com/php/php-src/archive/php-5.6.37.tar.gz
tar xvf php-5.6.37.tar.gz
cd php-src-php-5.6.37/
```

php与nginx结合  
---
1、nginx.conf配置如下
```
# cat nginx.conf
user  nginx;
worker_processes  2;
error_log  /var/log/nginx/error.log;
pid        /var/run/nginx.pid;



events {
    use epoll;
    worker_connections  65535;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    server_tokens off;
    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  65;
    tcp_nodelay on;
    client_header_buffer_size 4k;
    open_file_cache max=65535 inactive=60s;
    open_file_cache_valid 80s;
    client_body_buffer_size 512k;
    large_client_header_buffers 4 512k;
    proxy_connect_timeout 30;
    proxy_read_timeout 60;
    proxy_send_timeout 20;
    proxy_buffering on;
    proxy_buffer_size 16k;
    proxy_buffers 4 64k;
    proxy_busy_buffers_size 128k;
    proxy_temp_file_write_size 128k;
    gzip  on;
    gzip_min_length 1k;
    gzip_buffers 4 16k;
    gzip_http_version 1.1;
    gzip_comp_level 2;
    gzip_types text/plainapplication/x-javascript text/css application/xml;
    gzip_vary on;

server {

    listen       80;
    server_name  www.test.com;
    access_log  /var/log/nginx/zentao_access.log main;
        root   /application/php_php/zentao/www;
    location / {
        index  index.php index.html index.htm;
    }
    location ~ .*\.(php|php5)?$ {
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
}

}
```  
