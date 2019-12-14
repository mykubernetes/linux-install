网络源安装
---
```
# vim /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1

# yum install nginx
# nginx -v
# nginx -V
# rpm -ql nginx  # 查看已安装包在系统安装了哪些文件
# systemctl start nginx
# ps -ef |grep nginx
```
替换OS为rhel或centos，OSRELEASE为6或7


编译安装及编译参数
---
```
# useradd -M -s /sbin/nologin nginx  
# yum install gcc pcre-devel openssl-devel -y

# curl -o nginx-1.12.2.tar.gz http://nginx.org/download/nginx-1.12.2.tar.gz
# tar zxvf nginx-1.12.2.tar.gz
# cd nginx-1.12.2
# ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-stream=dynamic

# make && make install
```

常用编译参数：
---
| 参数 | 描述 |
| :------: | :--------: | 
| --prefix=PATH	| 安装目录
| --sbin-path=PATH | nginx可执行文件目录
| --modules-path=PATH	| 模块路径
| --conf-path=PATH | 配置文件路径
| --error-log-path=PATH	| 错误日志路径
| --http-log-path=PATH | 访问日志路径
| --pid-path=PATH	| pid路径
| --lock-path=PATH | lock文件路径
| --user=USER |  运行用户
| --group=GROUP | 运行组
| --with-threads | 启用多线程全局先定义池子： thread_pool one threads=32 max_queue=65535; 在里面引用： aio threads=one;
| --with-http_ssl_module | 提供HTTPS支持
| --with-http_v2_module	| HTTP2.0协议
| --with-http_realip_module	| 获取真实客户端IP
| --with-http_image_filter_module	| 图片过滤模块，比如缩略图、旋转等
| --with-http_geoip_module | 基于客户端IP获取地理位置
| --with-http_sub_module | 在应答数据中可替换静态页面源码内容
| --with-http_dav_module | 为文件和目录指定权限，限制用户对页面有不同的访问权限
| --with-http_flv_module | 支持flv流媒体播放
| --with-http_mp4_module | 支持mp4流媒体播放
| --with-http_gzip_static_module | 针对静态文件，允许发送.gz文件扩展名的预压缩文件给客户端，使用是gzip_static on
| --with-http_gunzip_static_module | Content-Encoding：gzip 用于对不支持gzip压缩的客户端使用，先解压缩后再响应。
| --with-http_secure_link_module | 检查链接，比如实现防盗链
| --with-http_stub_status_module | 获取nginx工作状态模块
| --with-mail_ssl_module |	启用邮件SSL模块
| --with-stream	| 启用TCP/UDP代理模块
| --add-module=PATH	| 启用扩展模块
| --with-stream_realip_module	| 流形式，获取真实客户端IP
| --with-stream_geoip_module | 流形式，获取客户端IP地理位置
| --with-pcre	| 启用PCRE库，rewrite需要的正则库
| --with-pcre=DIR	| 指定PCRE库路径
| --with-zlib=DIR	| 指定zlib库路径，gzip模块依赖
| --with-openssl=DIR | 指定openssl库路径，ssl模块依赖

- --with 这些模块在编译时默认没启用
- --without  默认启用的模块

dynamic  1.9.11版本后支持nginx运行时动态加载模块，像以前需要在编译时指定才会加载此模块，现在不主动加载模块，当使用时才会加载。在安装目录会创建一个目录modules，里面存放着动态加载的模块。

暂时支持这几个模块动态加载
```
# ./configure --help |grep dynamic
```

同时也增加了一个指令：load_module modules/ngx_http_geoip_module.so；# 要放到nginx.conf最上面要想第三方模块为动态加载，需要再编译时指定：
```
./configure --add-dynamic-module=PATH
```

这样动态模块的共享文件会被安装到modules目录下，可以再通过load_module指令动态加载这个模块。tengine早些版本已经实现动态加载模块了。

http://nginx.org/en/docs/

gzip压缩体积越小，对CPU消耗越大  
第三方模块地址：https://www.nginx.com/resources/wiki/modules/


命令行参数
---
nginx命令行参数：
```
# /usr/local/nginx/sbin/nginx –h
```
- -c file 指定配置文件
- -g directives 设置全局配置指令，例如nginx -g“pid /var/run/nginx.pid”
- -t 检查配置文件语法
- -v 打印nginx版本
- -V 打印nginx版本，编译器版本和配置
- -s 向master进程发送信号 
  - stop 快速关闭
  - quit 正常关闭，等待工作进程完成当前请求后停止nginx进程
  - reload 重新加载配置文件
  - reopen 重新打开日志文件

