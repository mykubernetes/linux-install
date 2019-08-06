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



# top -u nginx
top - 03:15:38 up  1:57,  1 user,  load average: 0.00, 0.01, 0.05
Tasks: 104 total,   1 running, 103 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.2 sy,  0.0 ni, 99.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  1530152 total,   716104 free,   114144 used,   699904 buff/cache
KiB Swap:  2097148 total,  2097148 free,        0 used.  1203568 avail Mem 

   PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                                 
  6740 nginx     20   0   21076   1460    524 S   0.0  0.1   0:00.00 nginx                                   
  6741 nginx     20   0   21076   1460    524 S   0.0  0.1   0:00.00 nginx

RES为占用内存的大小，约14M左右
```  

9、开启高效传输模式  
```
# vim /usr/local/nginx/conf/nginx.conf
Include mime.types;		媒体类型
default_type  application/octet-stream;	默认媒体类型 足够

http {
    sendfile        on;   # 开启高效文件传输模式,sendfile指令指定nginx是否调用sendfile函数来输出文件，对于普通应用设为 on，如果用来进行下载等应用磁盘IO重负载应用，可设置为off，以平衡磁盘与网络I/O处理速度，降低系统的负载。注意：如果图片显示不正常把这个改成off
    #tcp_nopush     on;   # 必须在sendfile开启模式才有效，防止网络阻塞，积极的减少网络报文段的数量
}

# vim /usr/local/nginx/conf/mime.types   支持的媒体类型
```  

10、ServerName匹配和location  
ServerName匹配  
1：精确匹配：www.aa.com  
2：左侧通配符匹配：*.aa.com  
3：右侧通配符匹配：www.*  
4：正则表达式：~ ^.*\.aa\.com$  
5: default_server  
6、服务IP地址   

location匹配  
= 绝对匹配  
^~：URL前半部分匹配，不检查正则  
~：正则匹配，区分大小写  
~*“正则匹配”不区分大小写  
\转义  
* 配置任意个任意字符  
$ 以什么结尾  

11、连接超时时间  
```
# vim /usr/local/nginx/conf/nginx.conf
    keepalive_timeout  65;
    tcp_nodelay on;
    client_header_timeout 15;
    client_body_timeout 15;
    send_timeout 15;
```  
- keepalived_timeout  客户端连接保持会话超时时间，超过这个时间，服务器断开这个链接
- tcp_nodelay；也是防止网络阻塞，不过要包涵在keepalived参数才有效
- client_header_timeout  客户端请求头读取超时时间，如果超过设个时间没有发送任何数据，nginx将返回request time out的错误
- client_body_timeout  客户端求主体超时时间，超过这个时间没有发送任何数据，和上面一样的错误提示
- send_timeout  响应客户端超时时间，这个超时时间仅限于两个活动之间的时间，如果超过这个时间，客户端没有任何活动，nginx关闭连接

12、文件上传大小限制  
```
# vim /usr/local/nginx/conf/nginx.conf
http {
    client_max_body_size 10m;
}
```  

13、Fastcgi调优  
fastcgi cache资料：  
官方文档：http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_cache  
```
http {
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    fastcgi_buffer_size 64k;
    fastcgi_buffers 4 64k;
    fastcgi_busy_buffers_size 128k;
    fastcgi_temp_file_write_size 128k;
    #fastcgi_temp_path /data/ngx_fcgi_tmp;
    fastcgi_cache_path /data/ngx_fcgi_cache   levels=2:2   #缓存路径，levels目录层次2级
    keys_zone=ngx_fcgi_cache:512m  #定义了一个存储区域名字，缓存大小
    inactive=1d max_size=40g;      #不活动的数据在缓存中多长时间，目录总大小
}

在server location标签添加如下：
      location ~ .*\.(php|php5)?$
      {
      fastcgi_pass 127.0.0.1:9000;
      fastcgi_index index.php;
      include fastcgi.conf;
      fastcgi_cache ngx_fcgi_cache;
      fastcgi_cache_valid 200 302 1h;
      fastcgi_cache_valid 301 1d;
      fastcgi_cache_valid any 1m;
      fastcgi_cache_min_uses 1;
      fastcgi_cache_use_stale error timeout invalid_header http_500;
      fastcgi_cache_key http://$host$request_uri;
      }
```  
- fastcgi_connect_timeout 300; #指定链接到后端FastCGI的超时时间。
- fastcgi_send_timeout 300; #向FastCGI传送请求的超时时间，这个值是指已经完成两次握手后向FastCGI传送请求的超时时间。
- fastcgi_read_timeout 300; #指定接收FastCGI应答的超时时间，这个值是指已经完成两次握手后接收FastCGI应答的超时时间。
- fastcgi_buffer_size 64k; #指定读取FastCGI应答第一部分需要用多大的缓冲区，这个值表示将使用1个64KB的缓冲区读取应答的第一部分（应答头），可以设置为fastcgi_buffers选项指定的缓冲区大小。
- fastcgi_buffers 4 64k; #指定本地需要用多少和多大的缓冲区来缓冲FastCGI的应答请求，如果一个php脚本所产生的页面大小为256KB，那么会分配4个64KB的缓冲区来缓存，如果页面大小大于256KB，那么大于256KB的部分会缓存到fastcgi_temp指定的路径中，但是这并不是好方法，因为内存中的数据处理速度要快于磁盘。一般这个值应该为站点中php脚本所产生的页面大小的中间值，如果站点大部分脚本所产生的页面大小为256KB，那么可以把这个值设置为“8 16K”、“4 64k”等。
- fastcgi_busy_buffers_size 128k; #建议设置为fastcgi_buffer的两倍，繁忙时候的buffer
- fastcgi_temp_file_write_size 128k; #在写入fastcgi_temp_path时将用多大的数据库，默认值是fastcgi_buffers的两倍，设置上述数值设置小时若负载上来时可能报502Bad Gateway
- fastcgi_cache gnix; #表示开启FastCGI缓存并为其指定一个名称。开启缓存非常有用，可以有效降低CPU的负载，并且防止502的错误发生，但是开启缓存也可能会引起其他问题，要很据具体情况选择
- fastcgi_cache_valid 200 302 1h; #用来指定应答代码的缓存时间，实例中的值表示将200和302应答缓存一小时，要和fastcgi_cache配合使用
- fastcgi_cache_valid 301 1d; #将301应答缓存一天
- fastcgi_cache_valid any 1m; #将其他应答缓存为1分钟
- fastcgi_cache_min_uses 1; #请求的数量
- fastcgi_cache_path #定义缓存的路径


14、gzip调优  
```
# vim /usr/local/nginx/conf/nginx.conf
    gzip on;
    gzip_min_length  1k;
    gzip_buffers     4 32k;
    gzip_http_version 1.1;
    gzip_comp_level 9;
    gzip_types  text/css text/xml application/javascript;
    gzip_vary on;
```  
- gzip on; #开启压缩功能
- gzip_min_length  1k; #设置允许压缩的页面最小字节数，页面字节数从header头的Content-Length（内容长度）中获取，默认值是0，不管页面多大都进行压缩，建议设置成大于1K，如果小与1K可能会越压越大。
- gzip_buffers 4 32k; #压缩缓冲区大小，表示申请4个单位为32K的内存作为压缩结果流缓存，默认值是申请与原始数据大小相同的内存空间来存储gzip压缩结果。
- gzip_http_version 1.1; #压缩版本（默认1.1，前端为squid2.5时使用1.0）用于设置识别HTTP协议版本，默认是1.1，目前大部分浏览器已经支持GZIP解压，使用默认即可
- gzip_comp_level 9;  #压缩比例，用来指定GZIP压缩比，1压缩比最小，处理速度最快，9压缩比最大，传输速度快，但是处理慢，也比较消耗CPU资源。
- gzip_types  text/css text/xml application/javascript;   #用来指定压缩的类型，‘text/html’类型总是会被压缩。
- gzip_vary on;   #vary header支持，该选项可以让前端的缓存服务器缓存经过GZIP压缩的页面，例如用Squid缓存经过nginx压缩的数据


15、expires缓存调优  
缓存，主要针对于图片，css，js等元素更改机会比较少的情况下使用，特别是图片，占用带宽大，我们完全可以设置图片在浏览器本地缓存365d，css，js，html可以缓存个10来天，这样用户第一次打开加载慢一点，第二次，就非常快了！缓存的时候，我们需要将需要缓存的拓展名列出来！  
xpires缓存配置在server字段里面  
```
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
      {
      expires      3650d;
      }
location ~ .*\.(js|css)?$
      {
      expires      30d;
      }
```  
同时也可以对目录及其进行判断  
```
location ~ ^/(images|javascript|js|css|flash|media|static)/ {
      expires 360d;
      }
location ~(robots.txt) {
      expires 7d;
      break;
      }
```  
expire功能优点  
（1）expires可以降低网站购买的带宽，节约成本  
（2）同时提升用户访问体验  
（3）减轻服务的压力，节约服务器成本，甚至可以节约人力成本，是web服务非常重要的功能。  
expire功能缺点：  
被缓存的页面或数据更新了，用户看到的可能还是旧的内容，反而影响用户体验。  
解决办法：  
第一个 缩短缓存时间，例如：1天，不彻底，除非更新频率大于1天  
第二个 对缓存的对象改名  
a.图片，附件一般不会被用户修改，如果用户修改了，实际上也是更改文件名重新传了而已  
b.网站升级对于js，css元素，一般可以改名，把css，js，推送到CDN。  
网站不希望被缓存的内容  
1）广告图片  
2）网站流量统计工具  
3）更新频繁的文件（google的logo）  


16、日志切割优化  
```
# vim cut_nginx_log.sh		#每天日志分割脚本
#!/bin/bash
date=$(date +%F -d -1day)
cd /usr/local/nginx/logs
if [ ! -d cut ] ; then
        mkdir cut
fi
mv access.log cut/access_$(date +%F -d -1day).log
mv error.log cut/error_$(date +%F -d -1day).log
/usr/local/nginx/sbin/nginx -s reload
tar -jcvf cut/$date.tar.bz2 cut/*
rm -rf cut/access* && rm -rf cut/error*
cat >>/var/spool/cron/root<<eof
00 00 * * * /bin/sh /usr/local/nginx/logs/cut_nginx_log.sh >/dev/null 2>&1
eof
find -type f -mtime +10 | xargs rm -rf
```  
健康检查的日志，不用输入到log中，因为这些日志没有意义，我们分析的话只需要分析访问日志，看看一些页面链接，如200，301，404的状态吗，在SEO中很重要，而且我们统计PV是页面计算，这些都没有意义，反而消耗了磁盘IO，降低了服务器性能，我们可以屏蔽这些如图片，js，css这些不宜变化的内容  

```
# vim /usr/local/nginx/conf/nginx.conf
       location ~ .*\.(js|jpg|jpeg|JPG|JPEG|css|bmp|gif|GIF)$ {
            access_log off;       #匹配到的类型不记录日志
        }
```  

日志目录权限优化  
```
# chown -R root.root logs/
# chmod -R 700 logs/

```

17、日志格式优化  
```
# vim /usr/local/nginx/conf/nginx.conf
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;
```  
1.$remote_addr 与$http_x_forwarded_for 用以记录客户端的ip地址；  
2.$remote_user 用来记录客户端用户名称；  
3.$time_local 用来记录访问时间与时区；  
4.$request 用来记录请求的url与http协议；  
5.$status 用来记录请求状态；成功是200，  
6.$body_bytes_s ent 记录发送给客户端文件主体内容大小；  
7.$http_referer 用来记录从那个页面链接访问过来的；  
8.$http_user_agent 记录客户端浏览器的相关信息；  


18、目录文件访问控制  
主要用在禁止目录下指定文件被访问，当然也可以禁止所有文件被访问！一般什么情况下用？比如是有存储共享，这些文件本来都只是一些下载资源文件，那么这些资源文件就不允许被执行，如sh,py,pl,php等等  
```
例如：禁止访问images下面的php程序文件
location ~ ^/images/.*\.(php|php5|.sh|.py|.pl)$ {
            root   html;
            index  index.html index.htm;
            deny all;
        }
# /usr/local/nginx/sbin/nginx -s reload
# mkdir /usr/local/nginx/html/images
# echo "<?php phpinfo(); ?>" > /usr/local/nginx/html/images/index.php

测试访问
# curl http://192.168.101.70/images/index.php
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx</center>
</body>
</html>
```  

多目录组合配置方法  
```
 location ~ ^/images/(attachment|avatar)/.*\.(php|php5|.sh|.py|.py)$ {
            root   html;
            index  index.html index.htm;
            deny all;     #添加此项
        }
```  

配置nginx禁止访问*.txt文件  
```
# vim /usr/local/nginx/conf/nginx.conf
   location ~* \.(txt|doc)$ {
                if ( -f $request_filename) {
                root /usr/local/nginx/html;
         break; 
        }
		deny all;
	}
```  

重定向到某一个URL  
```
# vim /usr/local/nginx/conf/nginx.conf
     location ~* \.(txt|doc)$ {
                if ( -f $request_filename) {
                root /usr/local/nginx/html;
                rewrite ^/(.*)$ http://www.baidu.com last;
                break;
                }
        }
```  

对目录进行限制的方法  
```
# mkdir -p /usr/local/nginx/html/{prod,gray}
# echo xuegod > /usr/local/nginx/html/prod/index.html
# echo god > /usr/local/nginx/html/gray/index.html
# vim /usr/local/nginx/conf/nginx.conf
    location /prod/       { return 404 ; }
    location /gray/       { return 403 ; }

或者403也可以使用以下方式
# vim /usr/local/nginx/conf/nginx.conf
        location ~ ^/(gray)/ {
        deny all;
        }
# /usr/local/nginx/sbin/nginx -s reload
```  

19、来源访问控制  
这个需要ngx_http_access_module模块支持，不过，默认会安装  
```
# vim /usr/local/nginx/conf/nginx.conf		//写法类似Apache
        location ~ ^/(gray)/ {
        allow 192.168.1.0/24;
        deny all;
        }


针对整个网站的写法，对/限制就OK
  location / {
        allow 192.168.1.0/24;
        deny all;
        }
	
也可以通过if语句控制，给以友好的错误提示
        if ( $remote_addr = 192.168.1.38 ) {
        return 404;
        }
```  

20、IP和301优化  
有时候，我们发现访问网站的时候，使用IP也是可以得，我们可以把这一层给屏蔽掉，让其直接反馈给403,也可以做跳转  
```
跳转的做法：
server {
        listen 80 default_server;
        server_name        localhost;
        rewrite ^ http://www.baidu.com$request_uri?;
}

403反馈的做法
server {
        listen 80 default_server;
        server_name     localhost;
        return 403；
}

301跳转的做法，如我们域名一般在解析的过程中，a.com一般会跳转到www.a.com
server {
    listen       80;
    root        /usr/share/nginx/html/;
    server_name  www.a.com a.com;
                if ($host = 'a.com' ) {
                        rewrite ^/(.*)$ http://www.a.com/$1 permanent;
}
```  

21、错误页面的提示
```
对于自定义的错误页面，我们只需要将errorpage写入到配置文件
server {
 error_page   404  /404.html;
}
```  

22、内部身份验证  
```
# vim /usr/local/nginx/conf/nginx.conf
location /ganglia/ {
                auth_basic "ganglia_auth";
                auth_basic_user_file /usr/local/nginx/conf/passwd;
        }


用户创建，如果没有htpasswd命令，需要手动安装httpd-tools程序包  
# yum install httpd-tools
# htpasswd -cb /usr/local/nginx/conf/passwd aaa 123
# chmod 400 /usr/local/nginx/conf/passwd 
# chown nginx /usr/local/nginx/conf/passwd
# /usr/local/nginx/sbin/nginx -s reload
```  

23、防止DDOS攻击  
通过使用limit_conn_zone进行控制单个IP或者域名的访问次数  
```
# vim /usr/local/nginx/conf/nginx.conf
http字段中配置
limit_conn_zone $binary_remote_addr zone=addr:10m;

server的location字段配置
    location / {
            root   html;
            limit_conn addr 1;
```  
