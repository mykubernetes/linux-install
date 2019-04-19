zabbix安装
========== 
官网介绍  
https://www.zabbix.com/documentation/3.4/zh/manual/introduction/features  

1. 安装MySQL
```
# yum -y install yum-utils 
# rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
# yum-config-manager --disable mysql80-community
# yum-config-manager --enable mysql57-community
# yum install mysql-community-server
# systemctl start mysqld
# systemctl status mysqld
# grep 'temporary password' /var/log/mysqld.log
# mysql -uroot -p
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'Zabbix2018!';
# vi /etc/my.cnf
[mysql]
socket = /tmp/mysql.sock
[mysqld]
user = mysql
port = 3306
datadir = /var/lib/mysql
socket = /tmp/mysql.sock
bind-address = 0.0.0.0
pid-file = /var/run/mysqld/mysqld.pid
character-set-server = utf8
collation-server = utf8_general_ci
log-error = /var/log/mysqld.log

max_connections = 10240
open_files_limit = 65535
innodb_buffer_pool_size = 3G
innodb_flush_log_at_trx_commit = 2
innodb_log_file_size = 256M
# systemctl restart mysqld

mysql> create database zabbix;
mysql> grant all on zabbix.* to zabbix@'192.168.1.%' identified by 'Zabbix2018!';
```  

2. YUM方式部署Zabbix服务器  
```
# rpm -ivh http://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
# yum install zabbix-server-mysql zabbix-web-mysql
# yum install zabbix-agent
# mysql –uroot –p
mysql> create database zabbix;
mysql> grant all on zabbix.* to 'zabbix'@'localhost' identified by 'Zabbix2018!';

导入表结构和数据：
# cd /usr/share/doc/zabbix-server-mysql-4.0.0
# zcat create.sql.gz | mysql -uroot -p zabbix

启动Zabbix Server进程：
# vi /etc/zabbix/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=Zabbix2018!
# systemctl start zabbix-server

# vi /etc/httpd/conf.d/zabbix.conf
php_value max_execution_time 300
php_value memory_limit 128M
php_value post_max_size 16M
php_value upload_max_filesize 2M
php_value max_input_time 300
php_value always_populate_raw_post_data -1
php_value date.timezone Asia/Shanghai
# systemctl start httpd
```  

2.1 YUM方式部署Zabbix_Agent服务器
```
# rpm -ivh http://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
# yum install zabbix-agent
# vi /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
DebugLevel=3
Server=
ListenPort=10050
ListenIP=0.0.0.0
ServerActive=
Hostname=
Include=/etc/zabbix/zabbix_agentd.d/*.conf
# UserParameter= =
```  

3. 源码编译方式部署Zabbix服务器  
```
3.1 部署Nginx
# wget http://nginx.org/download/nginx-1.15.3.tar.gz
# yum install gcc pcre-devel openssl-devel –y
# useradd -M -s /sbin/nologin nginx
# tar zxvf nginx-1.15.3.tar.gz
# cd nginx-1.15.3
# ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module
# make && make install
# chown nobody -R /usr/local/nginx/
# vi /usr/local/nginx/conf/nginx.conf
pid        /var/run/nginx.pid;

# vi /usr/lib/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```  

3.2 部署PHP  
```
安装依赖包:
# yum install -y gcc gcc-c++ make gd-devel libxml2-devel \
libcurl-devel libjpeg-devel libpng-devel openssl-devel \
libxslt-devel

安装PHP:
# wget http://docs.php.net/distributions/php-5.6.36.tar.gz
# tar zxf php-5.6.36.tar.gz
# cd php-5.6.36
# ./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm --enable-opcache \
--with-mysql --with-mysqli  \
--enable-session --with-zlib --with-curl --with-gd \
--with-jpeg-dir --with-png-dir --with-freetype-dir \
--enable-mbstring --enable-xmlwriter --enable-xmlreader \
--enable-xml --enable-sockets --enable-bcmath --with-gettext
# make -j 8 && make install
# cp php.ini-production /usr/local/php/etc/php.ini
# cp sapi/fpm/php-fpm.conf /usr/local/php/etc/php-fpm.conf
# cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
# cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/
# vi /usr/lib/systemd/system/php-fpm.service 
[Unit]
Description=The PHP FastCGI Process Manager
After=syslog.target network.target

[Service]
Type=simple
PIDFile=/usr/local/php/var/run/php-fpm.pid
ExecStart=/usr/local/php/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID

[Install]
WantedBy=multi-user.target
[root@web-01 ~]# systemctl daemon-reload
[root@web-01 ~]# systemctl start php-fpm
[root@web-01 ~]# systemctl enable php-fpm
```  
3.3 部署Zabbix Server  
https://www.zabbix.com/download_sources  
```
导入表结构：
# cd database/mysql
# mysql -uzabbix -p<password> zabbix < schema.sql
# mysql -uzabbix -p<password> zabbix < images.sql
# mysql -uzabbix -p<password> zabbix < data.sql

# yum install libxml2-devel libcurl-devel libevent-devel net-snmp-devel mysql-community-devel -y

# tar -zxf zabbix-4.0.0.tar.gz
# groupadd zabbix
# useradd -g zabbix zabbix -s /sbin/nologin
# cd zabbix-4.0.0
# ./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --enable-java --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
# make install
# vi /usr/local/zabbix/etc/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=Zabbix2018!

# vi /usr/lib/systemd/system/zabbix_server.service
[Unit]
Description=Zabbix Server
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/usr/local/zabbix/etc/zabbix_server.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-server
Type=forking
Restart=on-failure
PIDFile=/tmp/zabbix_server.pid
KillMode=control-group
ExecStart=/usr/local/zabbix/sbin/zabbix_server -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
TimeoutSec=0

[Install]
WantedBy=multi-user.target

启动Agent：
# /usr/local/zabbix/sbin/zabbix_agentd
```  

3.4 部署Zabbix Web界面  
Zabbix前端使用PHP写的，所以必须运行在PHP支持的Web服务器上。  
```
# cp zabbix-4.0.0/frontends/php/* /usr/local/nginx/html/ -rf
# vi /usr/local/php/etc/php.ini
max_execution_time = 300
memory_limit = 128M
post_max_size = 16M
upload_max_filesize = 2M
max_input_time = 300
always_populate_raw_post_data = -1
date.timezone = Asia/Shanghai
# systemctl restart php-fpm  

    server {
        listen       80;
        server_name  localhost;

        access_log  logs/zabbix.access.log  main;

        location / {
            root   html;
            index  index.php index.html index.htm;
        }

        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
    }
```  
