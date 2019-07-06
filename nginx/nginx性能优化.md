隐藏Nginx版本号信息  
---
1、修改配置文件  
```
vim /etc/nginx/conf/nginx.conf
http{
  server_tokens off;
}
```  
2、curl查看
```
# curl -I 192.168.101.69
HTTP/1.1 200 OK
Server: nginx                  #不显示版号
Date: Sat, 06 Jul 2019 15:12:01 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Sat, 06 Jul 2019 15:04:35 GMT
Connection: keep-alive
ETag: "5d20b883-264"
Accept-Ranges: bytes
```  


修改Nginx软件名及版本号  
---
```
# wget http://nginx.org/download/nginx-1.16.0.tar.gz
# tar xvf nginx-1.16.0.tar.gz
# cd nginx-1.16.0

# 编译前配置版本信息
# vim src/core/nginx.h
#define NGINX_VERSION      "9.9.9"                                    #修改为想要的版本号
#define NGINX_VER              "ABCDE/" NGINX_VERSION   #将nginx修改想要修改的软件名称
#define NGINX_VAR              "ABCDE"                                #将nginx修改想要修改的软件名称


# vim src/http/ngx_http_header_filter_module.c
static u_char ngx_http_server_string[] = "Server: ABCDE" CRLF;      #Curl显示的名称


#安装
# yum install -y gcc glibc gcc-c++ prce-devel openssl-devel pcre-devel lua-devel libxml2 libxml2-dev libxslt-devel  perl-ExtUtils-Embed   GeoIP GeoIP-devel GeoIP-data
# ./configure --prefix=/opt/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-pcre --with-stream
# make && make install
# groupadd -r nginx
# useradd -g nginx -r nginx
#检查配置文件语法
# /opt/nginx/sbin/nginx -t
#启动
# /opt/nginx/sbin/nginx
#查看服务器是否启动
# netstat -lntp|grep nginx
```

更改Nginx服务的默认用户  
---
为了Web服务更安全，我们要尽可能地改掉软件默认的所有配置，包括端口、用户等  
1)修改配置文件方式  
```
vim /etc/nginx/nginx.conf
user  nginx;
```  

2)或者在编译时直接指定用户即可  

优化Nginx服务的worker进程个数  
---

```
worker_processes  4;                        #Nginx服务的Worker进程数,cpu核心数或者cpu核心数减1
worker_cpu_affinity 0001 0010 0100 1000;    #优化绑定不同的Nginx进程到不同CPU上
```  

调整Nginx单个进程允许的客户端最大连接数
---
```
events {
    worker_connections  20480;
}
```  


配置Nginx worker进程最大打开文件数
---  
```
worker_rlimit_nofile 65535
#最大打开文件数，可设置为系统优化有的ulimit-HSn的结果。
```  
参考资料: http://nginx.org/en/docs/ngx_core_module.html#worker_rlimit_nofile  
















