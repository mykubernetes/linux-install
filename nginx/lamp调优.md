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
   40  make -j  4
   41  make install
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
