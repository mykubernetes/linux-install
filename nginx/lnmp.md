链接：https://pan.baidu.com/s/1u-A2cgHXTzuoOTrldH2Egw 提取码：ylx3  

一、LNMP软件所需要的软件包  
```
MySQL=http://dev.mysql.com/downloads/mysql/                mysql主程序包
PHP=http://php.net/downloads.php                           php主程序包
Nginx=http://nginx.org/en/download.html                    Nginx主程序包
libmcrypt=http://mcrypt.hellug.gr/index.html               libmcrypt加密算法扩展库，支持3DES等加密
或者：http://mcrypt.sourceforge.net/                        MCrypt/Libmcrypt development site (secure access)
pcre=http://pcre.org/                                      pcre是php的依赖包
```  

二、软件版本  
libmcrypt-2.5.8  
mysql-5.6.26  
nginx-1.8.0  
pcre-8.37  
php-5.6.13  

旧版本下载：http://mirrors.sohu.com/  

三、编译安装Nginx  

1、安装依赖  
```
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum groupinstall "Development Tools" "Development Libraries" -y
yum install gcc gcc-c++ autoconf automake zlib zlib-devel openssl openssl-devel pcre* pcre-devel  -y
```  

2、解压编译安装  
```
# tar xf pcre-8.37.tar.bz2 -C /usr/local/src/
# tar xvf nginx-1.8.0.tar.gz -C /usr/local/src/
# cd /usr/local/src/nginx-1.8.0
# ./configure --prefix=/usr/local/nginx --with-http_dav_module --with-http_stub_status_module --with-http_addition_module --with-http_sub_module --with-http_flv_module --with-http_mp4_module --with-pcre=/usr/local/src/pcre-8.37
# make –j 3 ; make install
# useradd -M -u 8001 -s /sbin/nologin nginx 
# ll /usr/local/nginx/
total 4
drwxr-xr-x. 2 root root 4096 Jul 30 21:44 conf   #Nginx相关配置文件
drwxr-xr-x. 2 root root   40 Jul 30 21:44 html   #网站根目录
drwxr-xr-x. 2 root root    6 Jul 30 21:44 logs   #日志文件
drwxr-xr-x. 2 root root   19 Jul 30 21:44 sbin   #Nginx启动脚本
```  

3、配置Nginx支持php文件  
```

#user  nobody;
worker_processes  1;

user nginx nginx;
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index index.php index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

    location ~ \.php$ {
        root           html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html$fastcgi_script_name;  
        include        fastcgi_params;
    }
}
}
```  

4、启动nginx  
```
# /usr/local/nginx/sbin/nginx
# netstat -tlnp | grep nginx
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      20177/nginx: master
```  
使用浏览器测试  
http://192.168.101.70/  


四、编译安装Mysql  

1、安装依赖  
```
yum install -y cmake ncurses-devel
```  



2、配置mysql  
```
配置属主属组
# chown -R mysql:mysql /usr/local/mysql/
拷贝配置文件
# cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
拷贝启动脚本
# cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld

更改启动脚本中指定mysql位置
vim /etc/init.d/ 
basedir=
datadir=
#修改为
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data

开机启动
# chkconfig mysqld  on
```  

3、初始化数据库  
```
# /usr/local/mysql/scripts/mysql_install_db \
--defaults-file=/etc/my.cnf  \
--basedir=/usr/local/mysql/\
--datadir=/usr/local/mysql/data/\
--user=mysql
```  

4、命令软连接  
```
# ln -s /usr/local/mysql/bin/*
```  

5、启动  
```
# service mysqld  start
```  

