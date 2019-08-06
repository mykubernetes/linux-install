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
老版本需要修改，新版本不需要
static u_char ngx_http_error_full_tail[] =
"<hr><center>" NGINX_VER "</center>" CRLF
"</body>" CRLF
"</html>" CRLF
;


static u_char ngx_http_error_build_tail[] =
"<hr><center>" NGINX_VER_BUILD "</center>" CRLF
"</body>" CRLF
"</html>" CRLF


编译安装
# ./configure --prefix=/usr/local/nginx --with-http_dav_module --with-http_stub_status_module --with-http_addition_module --with-http_sub_module --with-http_flv_module --with-http_mp4_module --with-pcre
# make && make install

启动
# /usr/local/nginx/sbin/nginx -t
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful

# /usr/local/nginx/sbin/nginx
# netstat -antup|grep nginx
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      3988/nginx: master 
```  
- --with-http_dav_module          #启用支持（增加PUT,DELETE,MKCOL：创建集合，COPY和MOVE方法）默认关闭，需要编译开启
- --with-http_stub_status_module  #启用支持（获取Nginx上次启动以来的工作状态）
- --with-http_addition_module         #启用支持（作为一个输出过滤器，支持不完全缓冲，分部分相应请求）
- --with-http_sub_module              #启用支持（允许一些其他文本替换Nginx相应中的一些文本）
- --with-http_flv_module              #启用支持（提供支持flv视频文件支持）
- --with-http_mp4_module              #启用支持（提供支持mp4视频文件支持，提供伪流媒体服务端支持）
- --with-pcre   #需要注意，这里指的是源码,用#./configure --help |grep pcre查看帮助

