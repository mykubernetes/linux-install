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

```  
