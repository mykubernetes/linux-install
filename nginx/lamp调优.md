1、安装依赖
```
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum groupinstall "Development Tools" "Development Libraries" -y
yum install gcc gcc-c++ openssl-devel
```  

2、安装apr和apr-util依赖
```
tar xf apr-1.5.2.tar.gz -C /usr/local/src/
tar xf apr-util-1.5.4.tar.bz2 -C /usr/local/src/
cd /usr/local/src/apr-1.5.2/
./configure --prefix=/usr/local/apr && make -j 2 && make install

cd /usr/local/src/apr-util-1.5.4/
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr && make -j 2 && make install
```  

3、Apache源码编译
```
tar xf httpd-2.4.27.tar.bz2 -C /usr/local/src/
cd /usr/local/src/httpd-2.4.27/
./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-zlib --with-pcre --with-apr=/usr/local/apr --enable-deflate --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mpms-shared=all --with-mpm=event
make -j 2
make install
```  
注解：
```
--prefix=/usr/local/apache            #指定程序安装路径
--sysconfdir=/etc/httpd               #指定配置文件、或工作目录
--enable-so                           #开启基于DSO动态装载模块
--enable-ssl                          #开启支持ssl协议
--enable-cgi                          #开启cgi机制 
--enable-rewrite                      #开启支持URL重写
--with-zlib                           #zlib是网络上发送数据报文的通用压缩库的API，在apache调用压缩工具压缩发送数据时需要调用该库
--with-pcre                           #支持PCRE，把pcre包含进程序中，（此处没指定pcre程序所在路径，默认会在PATH环境下查找）
--with-apr=/usr/local/apr             #指定apr位置
--with-apr-util=/usr/local/apr-util   #指定apr-util
--enable-modeles=most                 #启动模块，all表示所有，most表示常用的
--enable-mpms-shared=all              #启动所有的MPM模块
--with-mpm=event                      #指定默认使用event模块
```  

4、查看配置文件：
```
# ls /etc/httpd/httpd.conf 
/etc/httpd/httpd.conf
```  

5、存放网站的根目录：  
```
# ls /usr/local/apache/htdocs/index.html 
/usr/local/apache/htdocs/index.html
```  

6、启动http  
1)配置apache可以开机启动并且可以使用systemctl命令启动apache服务器  
```
# vim /usr/lib/systemd/system/httpd.service
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=forking
EnvironmentFile=/etc/httpd/httpd.conf
ExecStart=/usr/local/apache/bin/apachectl
ExecRestart=/usr/local/apache/bin/apachectl restart
ExecStop=/usr/local/apache/bin/apachectl stop
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```  

2)重新加载unit文件：
```
# systemctl daemon-reload
```  

3)设置开机自动启动：
```
# systemctl enable httpd
```  

4)启动apache：
```
# systemctl start httpd
```  

开始调优  
1、隐藏版本信息
```
# vim /etc/httpd/httpd.conf
# 将注释去掉
#Include /etc/httpd/extra/httpd-default.conf
Include /etc/httpd/extra/httpd-default.conf

# vim /etc/httpd/extra/httpd-default.conf
# 将Full改为On
ServerTokens Prod
ServerTokens On
如果这里不是off需要修改
ServerSignature Off

重启前测试
# curl -I 192.168.101.71
HTTP/1.1 200 OK
Date: Mon, 05 Aug 2019 15:46:43 GMT
Server: Apache/2.4.27 (Unix)    #有版本信息
Last-Modified: Mon, 11 Jun 2007 18:53:14 GMT
ETag: "2d-432a5e4a73a80"
Accept-Ranges: bytes
Content-Length: 45
Content-Type: text/html

# systemctl restart httpd

重启后测试
# curl -I 192.168.101.71
HTTP/1.1 200 OK
Date: Mon, 05 Aug 2019 15:46:51 GMT
Server: Apache                  #无版本信息
Last-Modified: Mon, 11 Jun 2007 18:53:14 GMT
ETag: "2d-432a5e4a73a80"
Accept-Ranges: bytes
Content-Length: 45
Content-Type: text/html
```  

2、彻底让版本等敏感信息消失  
```
1、编译前修改配置
# tar xf httpd-2.4.27.tar.bz2 -C /usr/local/src/
# cd /usr/local/src/httpd-2.4.27/
# vim include/ap_release.h
#define AP_SERVER_BASEVENDOR "Apache Software Foundation"   #服务的供应商名称
#define AP_SERVER_BASEPROJECT "Apache HTTP Server"          #服务的项目名称
#define AP_SERVER_BASEPRODUCT "Apache"                      #服务的产品名
#define AP_SERVER_MAJORVERSION_NUMBER 2                     #主要版本号
#define AP_SERVER_MINORVERSION_NUMBER 4                     #小版本号
#define AP_SERVER_PATCHLEVEL_NUMBER  6                      #补丁级别
#define AP_SERVER_DEVBUILD_BOOLEAN  0
修改为：
#define AP_SERVER_BASEVENDOR "web"
#define AP_SERVER_BASEPROJECT "web server"
#define AP_SERVER_BASEPRODUCT "web"

#define AP_SERVER_MAJORVERSION_NUMBER 8
#define AP_SERVER_MINORVERSION_NUMBER 1
#define AP_SERVER_PATCHLEVEL_NUMBER   2
#define AP_SERVER_DEVBUILD_BOOLEAN    3

2、修改完后需要重新编译安装
./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-zlib --with-pcre --with-apr=/usr/local/apr --enable-deflate --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mpms-shared=all --with-mpm=event
make -j 2
make install
```  

3、查看运行apache的默认用户  
通过更改apache的默认用户，可以提升apache的安全性。这样，即使apache服务被攻破，黑客拿到apache普通用户也不会对系统和其他应用造成破坏。  
```
# lsof -i:80
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   60596   root    4u  IPv6  50114      0t0  TCP *:http (LISTEN)
httpd   60597 daemon    4u  IPv6  50114      0t0  TCP *:http (LISTEN)
httpd   60598 daemon    4u  IPv6  50114      0t0  TCP *:http (LISTEN)
httpd   60599 daemon    4u  IPv6  50114      0t0  TCP *:http (LISTEN)

# id daemon
uid=2(daemon) gid=2(daemon) groups=2(daemon)

1、创建apache用户，没有家目录，非登录用户
# useradd -M -s /sbin/nologin apache

# vim /etc/httpd/httpd.conf
User apache
Group apache

重启查看默认用户
# systemctl restart httpd
# lsof -i:80
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   60869   root    4u  IPv6  53228      0t0  TCP *:http (LISTEN)
httpd   60870 apache    4u  IPv6  53228      0t0  TCP *:http (LISTEN)
httpd   60871 apache    4u  IPv6  53228      0t0  TCP *:http (LISTEN)
httpd   60872 apache    4u  IPv6  53228      0t0  TCP *:http (LISTEN)

2、修改apache的工作目录为普通用户权限
# ll -sd /usr/local/apache/htdocs/
0 drwxr-xr-x. 2 root root 24 Jul  6  2017 /usr/local/apache/htdocs/

# chown apache. /usr/local/apache/htdocs/ -R

# ll /usr/local/apache/htdocs/
total 4
-rw-r--r--. 1 apache apache 45 Jun 11  2007 index.html


3、保护apache日志：设置好apache日志文件权限，所以不用修改
# ll -sd /usr/local/apache/logs/*
4 -rw-r--r--. 1 root root 1414 Aug  5 12:12 /usr/local/apache/logs/access_log
4 -rw-r--r--. 1 root root 3180 Aug  5 22:29 /usr/local/apache/logs/error_log
4 -rw-r--r--. 1 root root    6 Aug  5 22:29 /usr/local/apache/logs/httpd.pid
注：由于apache日志的记录是由apache的主进程进行操作的，而apache的主进程又是root用户启动的，所以这样不影响日志的输出。这也是日志记录的最安全的方法。
```  

4、设置错误页面-开启压缩和缓存功能
```
1、错误页面优雅化显示的实现方式主要有两种,下面我们主要以404错误为例：
方法：
# vim /etc/httpd/httpd.conf
# 在http工作目录内添加
<Directory "/usr/local/apache/htdocs">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    ErrorDocument 404 /404.html         #添加此行
</Directory>

追加404错误页面，跳转页面
# echo "404 go to home" > /usr/local/apache/htdocs/404.html
重启后访问web不存在页面测试
# systemctl restart httpd
# curl 192.168.101.71/123
404 go to home

总结：ErrorDocument的命令格式如下：
ErrorDocument 错误代码 跳转到的页面或文件
另外这里需要注意，你若设置跳转到文件，必须要有这个文件才行。另外文件必须在站点目录内，不然会报错。
在跳转到文件的测试中，用全路径和别名路径进行测试，当把404错误页面跳转文件放到其他目录的时候，不报错，但是页面跳转不过去。



2、启用压缩模块mod_deflate
apache的压缩要用到mod_deflate模块，该模块提供了DEFLATE输出过滤器，允许服务器在将输出内容发送到客户端以前进行压缩，以节约带宽。它的核心思想就是把文件先在服务器进行压缩，然后再进行传输，这样可以显著减少文件传输的大小。当传输完毕后，客户端浏览器会重新对压缩过的内容进行解压缩。如果没特殊情况的话，所有的文本内容都应该能被gzip压缩，例如：html（php），js，css，xml，txt等。

mod_deflate模块检查及安装
# /usr/local/apache/bin/apachectl -M | grep deflate


# /usr/local/apache/bin/apachectl -M 
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 192.168.101.71. Set the 'ServerName' directive globally to suppress this message
Loaded Modules:
 core_module (static)
 so_module (static)
 http_module (static)             #(static)弹出此种结果，则为编译安装时装的
 authn_file_module (shared)
 authn_core_module (shared)
 authz_host_module (shared)       #(shared)弹出此种结果，则为DSO方式安装的
 authz_groupfile_module (shared)
 authz_user_module (shared)
 authz_core_module (shared)
 access_compat_module (shared)
 auth_basic_module (shared)
 reqtimeout_module (shared)
 filter_module (shared)
 mime_module (shared)
 log_config_module (shared)
 env_module (shared)
 headers_module (shared)
 setenvif_module (shared)
 version_module (shared)
 mpm_event_module (shared)
 unixd_module (shared)
 status_module (shared)
 autoindex_module (shared)
 dir_module (shared)
 alias_module (shared)
 
 
 如果安装了，就可以直接进行压缩配置了，如果没有安装，下面为安装方法
a）编译时安装方法
编译的时候跟上--enable-deflate即可实现安装
b）DSO方式安装。
扩展：DSO： Dynamic shared object动态共享对象 。DSO模块可以在编译服务器之后编译，也可以用Apache扩展工具(apxs)编译并增加
使用DSO方式安装，/usr/local/apache/bin/apxs后跟的参数详解
-c  此选项表明需要执行编译操作。
-i  此选项表示需要执行安装操作，以安装一个或多个动态共享对象到服务器的modules目录。
-a  此选项自动增加一个LoadModule行到httpd.conf文件中，以激活此模块，或者，如果此行已经存在，则启用之。

开启模块,取消注释
查看该路径下是否有压缩模块，有直接开启
ls /usr/local/src/httpd-2.4.27/modules/filters/ |grep mod_deflate
# vim /etc/httpd/httpd.conf 
#LoadModule deflate_module modules/mod_deflate.so
开启此项
Include /etc/httpd/extra/httpd-default.conf

开始配置压缩功能，在全局模式下配置
在Listen下配置，粘贴配置

<ifmodule mod_deflate.c>
   DeflateCompressionLevel 9   
   SetOutputFilter DEFLATE  
   DeflateFilterNote Input instream 
   DeflateFilterNote Output outstream 
   DeflateFilterNote Ratio ratio  
   AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css application/javascript   
</ifmodule>
```  
- DeflateCompressionLevel 9 #压缩等级，越大效率越高，消耗CPU也越高。
- SetOutputFilter DEFLATE #启用压缩
- DeflateFilterNote Input instream #声明输入流的byte数量
- DeflateFilterNote Output outstream #声明输出流的byte数量
- DeflateFilterNote Ratio ratio #声明压缩的百分比

