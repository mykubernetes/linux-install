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

测试版本是否修改
# curl  -I  192.168.101.70
HTTP/1.1 200 OK
Server: web/8.8.8          # 以修改成功
Date: Tue, 06 Aug 2019 06:42:13 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 06 Aug 2019 06:40:10 GMT
Connection: keep-alive
ETag: "5d4920ca-264"
Accept-Ranges: bytes
```  
- --with-http_dav_module          #启用支持（增加PUT,DELETE,MKCOL：创建集合，COPY和MOVE方法）默认关闭，需要编译开启
- --with-http_stub_status_module  #启用支持（获取Nginx上次启动以来的工作状态）
- --with-http_addition_module         #启用支持（作为一个输出过滤器，支持不完全缓冲，分部分相应请求）
- --with-http_sub_module              #启用支持（允许一些其他文本替换Nginx相应中的一些文本）
- --with-http_flv_module              #启用支持（提供支持flv视频文件支持）
- --with-http_mp4_module              #启用支持（提供支持mp4视频文件支持，提供伪流媒体服务端支持）
- --with-pcre   #需要注意，这里指的是源码,用#./configure --help |grep pcre查看帮助

2隐藏版本信息  
```
# vim /usr/local/nginx/conf/nginx.conf
http{
  server_tokens off;
}

# /usr/local/nginx/sbin/nginx -s reload
# curl  -I  192.168.101.70
HTTP/1.1 200 OK
Server: web         #版本号以隐藏
Date: Tue, 06 Aug 2019 06:46:04 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 06 Aug 2019 06:40:10 GMT
Connection: keep-alive
ETag: "5d4920ca-264"
Accept-Ranges: bytes
```  

3、修改nginx运行用户  
```
创建没家目录，非登录用户
# useradd -M -s /sbin/nologin nginx

查看现有用户
# ps -aux | grep nginx
root       6639  0.0  0.0  20740  1364 ?        Ss   02:42   0:00 nginx: master process /usr/local/nginx/sbinnginx
nobody     6645  0.0  0.1  21172  1688 ?        S    02:45   0:00 nginx: worker process
root       6698  0.0  0.0 112712   988 pts/0    S+   02:54   0:00 grep --color=auto nginx

修改启动用户
# vim /usr/local/nginx/conf/nginx.conf
user  nginx;

重新加载配置
# /usr/local/nginx/sbin/nginx -s reload

# ps -aux | grep nginx
root       6639  0.0  0.0  20644  1404 ?        Ss   02:42   0:00 nginx: master process /usr/local/nginx/sbinnginx
nginx      6701  0.0  0.0  21072  1364 ?        S    02:55   0:00 nginx: worker process
```  

4、Nginx运行进程个数  
```
# vim /usr/local/nginx/conf/nginx.conf
将
worker_processes  1;
修改为
worker_processes  4;

重新加载配置
# /usr/local/nginx/sbin/nginx -s reload

查看nginx启动进程各数，发现启动了四个，之前是一个
# ps -aux | grep nginx
root       6639  0.0  0.0  20644  1408 ?        Ss   02:42   0:00 nginx: master process /usr/local/nginx/sbinnginx
nginx      6707  0.0  0.0  21076  1460 ?        S    02:58   0:00 nginx: worker process
nginx      6708  0.0  0.0  21076  1460 ?        S    02:58   0:00 nginx: worker process
nginx      6709  0.0  0.0  21076  1460 ?        S    02:58   0:00 nginx: worker process
nginx      6710  0.0  0.0  21076  1460 ?        S    02:58   0:00 nginx: worker process
```  

5、Nginx运行CPU亲和力  
```
查看cpu各数
# cat /proc/cpuinfo
# top 安1 查看

# vim /usr/local/nginx/conf/nginx.conf
4核4线程配置
worker_processes  4;
worker_cpu_affinity 0001 0010 0100 1000;

8核8线程配置
4  worker_processes  8;
5  worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;

如果是4线程的CPU，我只想跑两个进程
worker_processes  2;
worker_cpu_affinity 0101 1010;
```  

6、Nginx最多可以打开文件数
```
# vim /usr/local/nginx/conf/nginx.conf
worker_rlimit_nofile 102400;
```  

7、Nginx事件处理模型  
```
# vim /usr/local/nginx/conf/nginx.conf
events {
    use epoll;
    worker_connections  1024;
}
```  
select，poll，epoll都是IO多路复用的机制。I/O多路复用就通过一种机制，可以监视多个描述符，一旦某个描述符就绪（一般是读就绪或者写就绪），能够通知程序进行相应的读写操作。  
Epoll 在Linux2.6内核中正式引入，和select相似，其实都I/O多路复用技术。  
epoll优势：  
1)Epoll没有最大并发连接的限制，上限是最大可以打开文件的数目，这个数字一般远大于2048, 一般来说这个数目和系统内存关系很大，具体数目可以cat /proc/sys/fs/file-max查看。  
```
# cat /proc/sys/fs/file-max
148218
```  
2)效率提升，Epoll最大的优点就在于它只管你“活跃”的连接，而跟连接总数无关，因此在实际的网络环境中，Epoll的效率就会远远高于select和poll。  
3)内存拷贝，Epoll在这点上使用了“共享内存”，这个内存拷贝也省略了  

8、单个进程允许客户端最大并发连接数  
这个数值一般根据服务器性能和内存来制定，也就是单个进程最大连接数，实际最大并发值就是work进程数乘以这个数。  
可以根据设置一个进程启动所占内存，top -u nginx，但是实际我们填入一个102400，足够了，这些都算并发值，一个网站的并发达到这么大的数量，也算一个大站了！  
```
# vim /usr/local/nginx/conf/nginx.conf
events {
    worker_connections  102400;
}
```  
