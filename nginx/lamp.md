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

三、安装  
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
cp /usr/local/apache2.4/bin/apachectl  /etc/init.d/httpd

脚本添加参数
vim /etc/init.d/httpd
#!/bin/sh
# chkconfig: 2345 64 36
# description: Apache2.4.16 start script


# service httpd start
# chkconfig httpd on

手动启动
/usr/local/apache2.4/bin/httpd -k start

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
useradd -M -s /sbin/nologin apache
vim /usr/local/apache2.4/conf/httpd.conf
User apache
Group apache

重启
/usr/local/apache2.4/bin/httpd -k restart

查看用户
# ps aux |grep httpd
root      48913  0.0  0.1  72632  2720 ?        Ss   10:58   0:00 /usr/local/apache2.4/bin/httpd -k start
apache    49062  0.2  0.2 361596  4204 ?        Sl   11:16   0:00 /usr/local/apache2.4/bin/httpd -k start
apache    49063  0.4  0.2 361596  4204 ?        Sl   11:16   0:00 /usr/local/apache2.4/bin/httpd -k start
apache    49064  0.2  0.2 361596  4204 ?        Sl   11:16   0:00 /usr/local/apache2.4/bin/httpd -k start
```  







