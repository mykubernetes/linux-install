一、安装nginx  
---

1、下载fastdfs-nginx-module模块  
```
git clone https://github.com/happyfish100/fastdfs-nginx-module.git
```  

2、下载nginx  
```
wget http://nginx.org/download/nginx-1.16.0.tar.gz
```  

3、安装编译 Nginx 所需的依赖包  
```
yum install gcc gcc-c++ make automake autoconf libtool pcre* zlib openssl openssl-devel
```  

4、编译安装 Nginx (添加 fastdfs-nginx-module 模块)  
```
tar -zxvf nginx-1.16.0.tar.gz
cd nginx-1.16.0

./configure --prefix=/opt/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-pcre
 
make && make install
```  

5、启动测试  
```
groupadd -r nginx
useradd -g nginx -r nginx
/opt/nginx/sbin/nginx -t           #测试配置文件
/opt/nginx/sbin/nginx              #启动
/opt/nginx/sbin/nginx -s reload    #重启
```  

