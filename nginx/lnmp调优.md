1、Nginx编译前的优化
更改源码隐藏软件名称和版本号
```
安装依赖
# yum install gcc gcc-c++ autoconf automake zlib zlib-devel openssl openssl-devel  pcre pcre-devel -y

# wget http://nginx.org/download/nginx-1.16.0.tar.gz
# tar xvf nginx-1.16.0.tar.gz
# cd nginx-1.16.0

修改3处地方
# vim src/core/nginx.h
将
#define nginx_version      1016000
#define NGINX_VERSION      "1.16.0"                         #程序版本号
#define NGINX_VER          "nginx/" NGINX_VERSION           #程序名称
修改为
#define nginx_version      1016000
#define NGINX_VERSION      "8.8.8"
#define NGINX_VER          "web/" NGINX_VERSION


# vim src/http/ngx_http_header_filter_module.c
将
static u_char ngx_http_server_string[] = "Server: nginx" CRLF;   #修改HTTP头信息中的connection字段，防止回显具体版本号
修改为
static u_char ngx_http_server_string[] = "Server: web" CRLF;


# vim src/http/ngx_http_special_response.c
将
"<hr><center>" NGINX_VER_BUILD "</center>" CRLF
修改为
"<hr><center>" web "</center>" CRLF
```  
