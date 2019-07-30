链接：https://pan.baidu.com/s/1dv_iVJah3j1p-STt99nDNg 提取码：1y0n  

一、LAMP相关网站  
```
Apache=http://httpd.apache.org/                          httpd主程序包
MySQL=http://dev.mysql.com/downloads/mysql/              mysql主程序包
PHP=http://php.net/downloads.php                         php主程序包
apr=http://apr.apache.org/                               apr是httpd的依赖包
apr-util=http://apr.apache.org/                          apr-util是httpd的第二个依赖包
pcre=http://pcre.org/                                    pcre是httpd的第三个依赖包 
```  
- apr和apr-util这个两个软件是对后端服务软件进行优化的  
- apr-util只是在apr的基础上提供了更多的数据结构和操作系统封装接口而已  

二、编译安装LAMP所需要及其所使用的源码版本  
httpd version：httpd-2.4.16  
apr version：apr-1.5.2  
pcre version：pcre-8.37  
apr-util version：apr-util-1.5.4  
mysql version：mysql-5.6.26  
php version：php-5.6.13  

三、安装http  
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

3、安装pcre依赖  
```
tar xf pcre-8.37.tar.bz2 -C /usr/local/src/
cd /usr/local/src/pcre-8.37/
./configure --prefix=/usr/local/pcre && make -j 2 && make install
```  

4、Apache源码编译  
```
tar xvf httpd-2.4.16.tar.bz2 -C /usr/local/src/
cd /usr/local/src/httpd-2.4.16
./configure --prefix=/usr/local/apache2.4 --enable-so --enable-rewrite --enable-ssl --with-pcre=/usr/local/pcre --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mpms-shared=all --with-mpm=event && make -j 2 && make install
```  
- --prefix=/usr/local/apache2.4 #安装路径  
- --enable-so #支持动态加载模块  
- --enable-rewrite #支持网站地址重写  
- --enable-ssl #支持SSL加密  
- --with-pcre=/usr/local/pcre #pcre路径  
- --with-apr=/usr/local/apr #apr路径  
- --with-apr-util=/usr/local/apr-util #apr-util路径  

5、配置Apache的启动脚本  
```
# cp /usr/local/apache2.4/bin/apachectl  /etc/init.d/httpd

脚本添加参数
# vim /etc/init.d/httpd
#!/bin/sh
# chkconfig: 2345 64 36
# description: Apache2.4.16 start script

设置开启启动
# service httpd start
# chkconfig httpd on

手动启动
# /usr/local/apache2.4/bin/httpd -k start

查看进程是否启动
# netstat -an|grep 80
tcp6       0      0 :::80                   :::*                    LISTEN     
unix  2      [ ACC ]     STREAM     LISTENING     19280    private/rewrite
unix  2      [ ]         DGRAM                    16803 

发现运行用户为daemon
# ps aux |grep httpd
root      48913  0.0  0.1  72632  2184 ?        Ss   10:58   0:00 /usr/local/apache2.4/bin/httpd -k start
daemon    48914  0.1  0.2 361596  3968 ?        Sl   10:58   0:01 /usr/local/apache2.4/bin/httpd -k start
daemon    48915  0.1  0.2 361596  3964 ?        Sl   10:58   0:01 /usr/local/apache2.4/bin/httpd -k start
daemon    48916  0.1  0.2 361596  3972 ?        Sl   10:58   0:01 /usr/local/apache2.4/bin/httpd -k start

创建apache用户
# useradd -M -s /sbin/nologin apache
# chown -R apache:apache /usr/local/apache2.4/
# vim /usr/local/apache2.4/conf/httpd.conf
User apache
Group apache

重启
# /usr/local/apache2.4/bin/httpd -k restart

查看用户
# ps aux |grep httpd
root      48913  0.0  0.1  72632  2720 ?        Ss   10:58   0:00 /usr/local/apache2.4/bin/httpd -k start
apache    49062  0.2  0.2 361596  4204 ?        Sl   11:16   0:00 /usr/local/apache2.4/bin/httpd -k start
apache    49063  0.4  0.2 361596  4204 ?        Sl   11:16   0:00 /usr/local/apache2.4/bin/httpd -k start
apache    49064  0.2  0.2 361596  4204 ?        Sl   11:16   0:00 /usr/local/apache2.4/bin/httpd -k start
```  

6、查看web  
http://192.168.101.70/


四、MYSQL源码编译  

1、安装依赖  
```
yum install -y cmake ncurses-devel
```  

2、编译安装MySql  
```
# tar xf mysql-5.6.26.tar.gz -C /usr/local/src/
# cd /usr/local/src/mysql-5.6.26
# useradd -M -s /sbin/nologin mysql
# cmake \
 -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
 -DDEFAULT_CHARSET=utf8 \
 -DDEFAULT_COLLATION=utf8_general_ci \
 -DWITH_EXTRA_CHARSETS=all \
 -DWITH_MYISAM_STORAGE_ENGINE=1\
 -DWITH_INNOBASE_STORAGE_ENGINE=1\
 -DWITH_MEMORY_STORAGE_ENGINE=1\
 -DWITH_READLINE=1\
 -DENABLED_LOCAL_INFILE=1\
 -DMYSQL_DATADIR=/usr/local/mysql/data \
 -DMYSQL-USER=mysql

# make -j 4 && make install
```  
- DCMAKE_INSTALL_PREFIX #制定mysql的安装根目录，目录在安装的时候会自动创建，这个值也可以在服务器启动时，用--basedir来设置
- DMYSQL_UNIX_ADDR #服务器与本地客户端进行通信的Unix套接字文件，必须是绝对路径，默认位置/tmp/mysql.sock，可以在服务器启动时，用--socket改变
- DDEFAULT_CHARSET #mysql默认使用的字符集，不指定将默认使用Latin1西欧字符集
- DDEFAULT_COLLATION #默认字符校对
- DWITH_EXTRA_CHARSETS #制定mysql拓展字符集，默认值也是all支持所有的字符集
- DWITH_MYISAM_STORAGE_ENGINE #静态编译MYISAM，INNOBASE，MEMORY存储引擎到MYSQL服务器，这样MYSQL就支持这三种存储引擎
- DWITH_INNOBASE_STORAGE_ENGINE #静态编译MYISAM，INNOBASE，MEMORY存储引擎到MYSQL服务器，这样MYSQL就支持这三种存储引擎
- DWITH_MEMORY_STORAGE_ENGINE #静态编译MYISAM，INNOBASE，MEMORY存储引擎到MYSQL服务器，这样MYSQL就支持这三种存储引擎
- DWITH_READLINE #支持readline库
- DENABLED_LOCAL_INFILE #允许本地倒入数据，启用加载本地数据
- DMYSQL_DATADIR #mysql数据库存放路径
- DMYSQL-USER #运行mysql的用户
官网参数详解  
https://dev.mysql.com/doc/refman/5.6/en/source-configuration-options.html  


3、配置mysql  
```
修改属主属组
# chown -R mysql:mysql /usr/local/mysql/

复制配置文件
# cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf

复制启动脚本
# cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld 

更改启动脚本中指定mysql位置
# vim /etc/init.d/mysqld
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data

开启启动
# chkconfig mysqld  on
```  

4、初始化数据库  
```
# /usr/local/mysql/scripts/mysql_install_db \
--defaults-file=/etc/my.cnf  \
--basedir=/usr/local/mysql/\
--datadir=/usr/local/mysql/data/\
--user=mysql
```  

5、配置软连接  
```
ln -s /usr/local/mysql/bin/* /bin/ 
```  

6、启动  
```
# servie mysqld  start          启动数据库
# mysql_secure_installation     初始安全设置（设置root密码，123456）
# mysql -uroot -p123456         测试登录（OK）
```  

五、安装php  
1、安装依赖  
```
# yum install -y libxml2-devel
```  

2、安装php  
```
# tar xf php-5.6.13.tar.bz2 -C  /usr/local/src/
# cd /usr/local/src/php-5.6.13
# ./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql/ --with-apxs2=/usr/local/apache2.4/bin/apxs --with-config-file-path=/usr/local/php

# make –j 3 ; make install
```  
- --prefix #指定安装路径
- --with-apxs2 #用apache的apxs工具将php编译成apache的一个模块
- --with-mysql #与mysql结合，如果不跟路径，编译出来的版本将是低版本
- --with-config-file-path #php的主配置文件php.ini路径

3、复制配置文件
```
 # cd /usr/local/src/php-5.6.13
 # cp php.ini-production /usr/local/php/php.ini
```  

4、只有有下面这两个文件（模块），代表apache就可以支持php了  
```
#ls  /usr/local/apache2.4/modules/httpd.exp 
/usr/local/apache2.4/modules/httpd.exp

# ls /usr/local/apache2.4/modules/libphp5.so
/usr/local/apache2.4/modules/libphp5.so
```  

5、配置Apache支持PHP  
```
# vim /usr/local/apache2.4/conf/httpd.conf
……
248    <IfModule dir_module>
249       DirectoryIndex index.html index.php           #添加index.php
250    </IfModule>
……
376     AddType application/x-compress .Z
377     AddType application/x-gzip .gz .tgz       #上面两行是以前有的
378     AddType application/x-httpd-php .php      #下面两行是添加的，需要添加以支持PHP
379     AddType application/x-httpd-php-source .phps
修改完，重启下Apache服务。
```  

6、测试  
```
# vim /usr/local/apache2.4/htdocs/index.php 
<?php
        phpinfo();
?>
```  

浏览器访问web  
192.168.101.70/index.php
