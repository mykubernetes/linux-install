upstream_check_module模块实现后端节点健康检查功能  

淘宝技术团队开发的nginx模快nginx_upstream_check_module来检测后服务的健康状态，如果后端服务器不可用，则所有的请求不转发到这台服务器。  

nginx自带是没有针对负载均衡后端节点的健康检查的，但是可以通过默认自带的ngx_http_proxy_module模块和ngx_http_upstream_module模块中的相关指令来完成当后端节点出现故障时，自动切换到健康节点来提供访问，但是还会有请求转发到后端的这台后端节点上面去  

ngx_http_upstream_module是淘宝技术团队开发的nginx模快nginx_upstream_check_module来检测后方服务的健康状态，如果后端服务器不可用，则所有的请求不转发到这台服务器  

github项目地址：https://github.com/yaoweibin/nginx_upstream_check_module/  

1、编译安装  
```
yum install -y gcc glibc gcc-c++ prce-devel openssl-devel pcre-devel lua-devel libxml2 libxml2-dev libxslt-devel  perl-ExtUtils-Embed   GeoIP GeoIP-devel GeoIP-data
```  

2、下载软件包  
```
useradd -s /sbin/nologin nginx -M
wget http://nginx.org/download/nginx-1.14.2.tar.gz
tar xf nginx-1.14.2.tar.gz
```  

3、下载nginx模块  
```
wget https://codeload.github.com/yaoweibin/nginx_upstream_check_module/zip/master
unzip master
```  

4、nginx打补丁  
```
yum install -y patch
cd nginx-1.14.2
patch -p1 < ../nginx_upstream_check_module-master/check_1.14.0+.patch
#因为我们nginx的版本是1.14补丁就选择1.14的,p1代表在nginx目录，p0是不在nginx目录
```  

5、编译Nginx  
```
./configure --prefix=/usr/local/nginx-1.14 --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --add-module=/root/nginx_upstream_check_module-master

make && make install
ln -s /usr/local/nginx-1.14 /usr/local/nginx

#启动测试
/usr/local/nginx/sbin/nginx

# lsof -i:80
COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
nginx   6731  root    6u  IPv4  44182      0t0  TCP *:http (LISTEN)
nginx   6732 nginx    6u  IPv4  44182      0t0  TCP *:http (LISTEN)
```  

6、配置模块  
```
# cat nginx.conf
worker_processes  1;
events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

upstream test {
       server 10.4.81.41:900;
       server 10.4.81.42:900;
       check interval=3000 rise=2 fall=5 timeout=1000 type=tcp;
    }


    server {
        listen       80;
        server_name  localhost;

        location / {
         proxy_pass test;
        }
        location /status1 {
           stub_status on;      #配置nginx内置健康检查
           access_log  off;
        }
        location /status2 {     #配置upstream_check_module模块健康检查
           check_status;
           access_log off;
           #allow SOME.IP.ADD.RESS; #可以设置允许网段访问
           #deny all;
       }
    }
}
```  

check interval=3000 rise=2 fall=5 timeout=1000 type=tcp;  

- interval检测间隔时间，单位为毫秒
- rsie请求2次正常的话，标记此后端的状态为up
- type  类型为tcp
- fall表示请求5次都失败的情况下，标记此后端的状态为down
- timeout为超时时间，单位为毫秒
修改完配置文件，reload即可
/usr/local/nginx/sbin/nginx -t
/usr/local/nginx/sbin/nginx -s reload




