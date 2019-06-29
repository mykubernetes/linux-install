安装fastdfs
===
一、所有tracker和storage节点都执行如下操作  
---
1、安装所需的依赖包  
``` yum install make cmake gcc gcc-c++ ```  
2、安装libfatscommon  
```
git clone https://github.com/happyfish100/libfastcommon.git
cd libfastcommon
./make.sh
./make.sh install
```  
3、安装FastDFS  
```
git clone https://github.com/happyfish100/fastdfs.git
cd fastdfs
./make.sh
./make.sh install
```  
采用默认安装方式，相应的文件与目录检查如下：  
1> 服务脚本：  
```
/etc/init.d/fdfs_storaged
/etc/init.d/fdfs_trackerd
```
2> 配置文件（示例配置文件）：  
 ```
 ll /etc/fdfs/
-rw-r--r-- 1 root root  1461 1月   4 14:34 client.conf.sample
-rw-r--r-- 1 root root  7927 1月   4 14:34 storage.conf.sample
-rw-r--r-- 1 root root  7200 1月   4 14:34 tracker.conf.sample
```  
3> 命令行工具（/usr/bin目录下）  
```
ll /usr/bin/fdfs_*

-rwxr-xr-x    1 root root     260584 1月   4 14:34 fdfs_appender_test
-rwxr-xr-x    1 root root     260281 1月   4 14:34 fdfs_appender_test1
-rwxr-xr-x    1 root root     250625 1月   4 14:34 fdfs_append_file
-rwxr-xr-x    1 root root     250045 1月   4 14:34 fdfs_crc32
-rwxr-xr-x    1 root root     250708 1月   4 14:34 fdfs_delete_file
-rwxr-xr-x    1 root root     251515 1月   4 14:34 fdfs_download_file
-rwxr-xr-x    1 root root     251273 1月   4 14:34 fdfs_file_info
-rwxr-xr-x    1 root root     266401 1月   4 14:34 fdfs_monitor
-rwxr-xr-x    1 root root     873233 1月   4 14:34 fdfs_storaged
-rwxr-xr-x    1 root root     266952 1月   4 14:34 fdfs_test
-rwxr-xr-x    1 root root     266153 1月   4 14:34 fdfs_test1
-rwxr-xr-x    1 root root     371336 1月   4 14:34 fdfs_trackerd
-rwxr-xr-x    1 root root     251651 1月   4 14:34 fdfs_upload_appender
-rwxr-xr-x    1 root root     252781 1月   4 14:34 fdfs_upload_file
```  

二、配置tracker服务器  
---
1、修改tracker配置文件
```
cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
vim /etc/fdfs/tracker.conf
disabled=false              # 启用配置文件
port=22122                  # tracker服务器端口（默认22122）
base_path=/fastdfs/tracker  # 存储日志和数据的根目录
store_lookup=2              # 如果有多个group,写入group的方式，0代表轮训，1代表挑选的组，如果是1则安装store_group=group1的配置写入，2挑选空闲最多的空间写入
store_group=group1          # store_lookup=1才生效
reserved_storage_space = 10%   # 硬盘空间至少保留的最大空间，以免被占满，影响其他进程使用
```  
其它参数保留默认配置， 具体配置解释可参考官方文档说明：http://bbs.chinaunix.net/thread-1941456-1-1.html  
2、创建base_path指定的目录  
``` mkdir -p /fastdfs/tracker ```  

3、启动tracker服务器  
```
/etc/init.d/fdfs_trackerd start
初次启动，会在/fastdfs/tracker目录下生成logs、data两个目录。
drwxr-xr-x. 2 root root 83 Jun 28 23:40 data
drwxr-xr-x. 2 root root 26 Jun 28 23:39 logs
检查FastDFS Tracker Server是否启动成功：
ps -ef | grep fdfs_trackerd
tailf /fastdfs/tracker/logs/trackerd.log
```  

三、配置storage服务器  
---
1、编辑配置文件  
```
cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
vi /etc/fdfs/storage.conf
disabled=false                         # 启用配置文件
group_name=group1                      # 属于第几个组，默认属于第一个组
port=23000                             # storage服务端口
base_path=/fastdfs/storage             # 数据和日志文件存储根目录
store_path_count=1                     # 指定默认有几个设备存储数据默认一个，如果有多个需要store_path0,store_path1来指定
store_path0=/fastdfs/storage/0         # 第一个存储目录
# store_path1=/fastdfs/storage/1       # 第二个存储目录
tracker_server=192.168.101.69:22122    # tracker服务器IP和端口
tracker_server=192.168.101.70:22122    #tracker服务器IP2和端口
http.server_port=8888                  # http访问文件的端口
```  
其它参数保留默认配置， 具体配置解释可参考官方文档说明：http://bbs.chinaunix.net/thread-1941456-1-1.html  
2、创建基础数据目录  
``` mkdir -p /fastdfs/storage/0 ```  

3、启动storage服务器  
```
/etc/init.d/fdfs_storaged start
初次启动，会在/fastdfs/storage目录下生成logs、data两个目录。
drwxr-xr-x. 3 root root 18 Jun 29 04:19 0
drwxr-xr-x. 3 root root 90 Jun 29 04:19 data
drwxr-xr-x. 2 root root 26 Jun 29 04:19 logs
检查FastDFS Tracker Server是否启动成功：
ps -ef | grep fdfs_storaged
tailf /fastdfs/storage/logs/storaged.log
```  


查看集群状态  
```
fdfs_monitor /etc/fdfs/storage.conf
```  

四、文件上传测试 
---
1、修改Tracker服务器客户端配置文件  
```
cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
vim /etc/fdfs/client.conf
base_path=/fastdfs/tracker
tracker_server=192.168.101.69:22122  # tracker服务器IP和端口
tracker_server=192.168.101.70:22122  #tracker服务器IP2和端口
```  

2、查看节点状态  
```
fdfs_monitor /etc/fdfs/client.conf
```  

3、执行文件上传命令  
```
#/etc/fstab 是需要上传文件路径
/usr/bin/fdfs_upload_file /etc/fdfs/client.conf /etc/fstab
返回文件ID号：group1/M00/00/00/wKhlRV0XJJmAJsndAAAB0ZE__og7799337
（能返回以上文件ID，说明文件已经上传成功）
或者: 
/usr/bin/fdfs_test /etc/fdfs/client.conf upload client.conf
```  

4、查看上传的文件  
```
fdfs_file_info /etc/fdfs/client.conf group1/M00/00/00/wKhlRV0XJJmAJsndAAAB0ZE__og7799337
```  

5、下载文件  
```
fdfs_download_file /etc/fdfs/client.conf group1/M00/00/00/wKhlRV0XJJmAJsndAAAB0ZE__og7799337 /tmp/fstab
```  

五、在所有storage节点安装fastdfs-nginx-module  
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

./configure --prefix=/opt/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-pcre --add-module=/opt/fastdfs-nginx-module/src
 
make && make install
```  

5、复制 fastdfs-nginx-module 源码中的配置文件到/etc/fdfs 目录,并修改  
```
cp /opt/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/ 
vim /etc/fdfs/mod_fastdfs.conf
connect_timeout=10
base_path=/fastdfs/storage
tracker_server=192.168.101.69:22122    # tracker服务器IP和端口
tracker_server=192.168.101.70:22122    # tracker服务器IP2和端口
url_have_group_name=true               # url中包含group名称
store_path0=/fastdfs/storage
group_count = 2                        # group个数
#在最后添加
[group1]
group_name=group1 
storage_server_port=23000 
store_path_count=1 
store_path0=/fastdfs/storage/0

[group2]
group_name=group2 
storage_server_port=23000 
store_path_count=1 
store_path0=/fastdfs/storage/0
```  

6、复制 FastDFS 的部分配置文件到/etc/fdfs 目录  
```
cd /opt/fastdfs/conf
cp http.conf mime.types /etc/fdfs/
```  

7、在/fastdfs/storage 文件存储目录下创建软连接,将其链接到实际存放数据的目录  
``` ln -s /fastdfs/storage/0/data/ /fastdfs/storage/0/data/M00 ```  

8、配置 Nginx  
```
user nobody;
worker_processes 1;
events {
    worker_connections 1024;
}
http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    
    server {
        listen 8888;
        server_name localhost;
        location ~/group([0-9])/M00 {
            ngx_fastdfs_module;
        }

        error_page 500 502 503 504 /50x.html;

        location = /50x.html {
            root html;
        }
    }
}
```  

 A、8888 端口值是要与/etc/fdfs/storage.conf 中的 http.server_port=8888 相对应, 因为 http.server_port 默认为 8888,如果想改成 80,则要对应修改过来。  
 B、Storage 对应有多个 group 的情况下,访问路径带 group 名,如/group1/M00/00/00/xxx, 对应的 Nginx 配置为:  
 ```
     location ~/group([0-9])/M00 {
         ngx_fastdfs_module;
}
```  
C、如查下载时如发现老报 404,将 nginx.conf 第一行 user nobody 修改为 user root 后重新启动。  

9、防火墙中打开 Nginx 的 8888 端口  
```
vim /etc/sysconfig/iptables
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8888 -j ACCEPT

service iptables restart
```  

10、启动 Nginx  
```
groupadd -r nginx                  #创建nginx组
useradd -g nginx -r nginx          #创建ngixn用户
/opt/nginx/sbin/nginx              #启动
/opt/nginx/sbin/nginx -s reload    #重启
```  
 
浏览器访问  
http://192.168.101.69:8888/group1/M00/00/00/wKhlRV0XJJmAJsndAAAB0ZE__og7799337  
http://192.168.101.70:8888/group1/M00/00/00/wKhlRV0XJJmAJsndAAAB0ZE__og7799337  


六、在所有tracker节点安装ngx_chche_purge_module  
---

1、下载ngx_chche_purge_module模块  
``` git clone https://github.com/FRiCKLE/ngx_cache_purge.git ```  

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

./configure --prefix=/opt/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-pcre --add-module=/opt/ngx_cache_purge
 
make && make install
```  

5、配置nginx  
```
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
    #设置缓存
    server_names_hash_bucket_size 128;
    client_header_buffer_size 32k;
    large_client_header_buffers 4 32k;
    client_max_body_size 300m;

    proxy_redirect off;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_connect_timeout 90;
    proxy_send_timeout 90;
    proxy_read_timeout 90;
    proxy_buffer_size 16k;
    proxy_buffers 4 64k;
    proxy_busy_buffers_size 128k;
    proxy_temp_file_write_size 128k;
    #设置缓存存储路径，存储方式，分别内存大小，磁盘最大空间，缓存期限
    proxy_cache_path /fastdfs/cache/nginx/proxy_cache levels=1:2
    keys_zone=http-cache:200m max_size=1g inactive=30d;
    proxy_temp_path /fastdfs/cache/nginx/proxy_cache/tmp;
    #group1的服务设置
    upstream fdfs_group1 {
        server 192.168.101.69:8888 weight=1 max_fails=2 fail_timeout=30s;
        server 192.168.101.70:8888 weight=1 max_fails=2 fail_timeout=30s;
    }
    #group1的服务设置
    upstream fdfs_group2 {
        server 192.168.101.71:8888 weight=1 max_fails=2 fail_timeout=30s;
        server 192.168.101.72:8888 weight=1 max_fails=2 fail_timeout=30s;
    }

    server {
        listen       8000;
        server_name  localhost;

        #charset koi8-r;
        #group1的复制均衡配置
        location /group1/M00 {
            proxy_next_upstream http_502 http_504 error timeout invalid_header;
            proxy_cache http-cache;
            proxy_cache_valid 200 304 12h;
            #对应group1的服务设置
            proxy_cache_key $uri$is_args$args;
            proxy_pass http://fdfs_group1;
            expires 30d;
        }

       #group2的复制均衡配置
       location /group2/M00 {
            proxy_next_upstream http_502 http_504 error timeout invalid_header;
            proxy_cache http-cache;
            proxy_cache_valid 200 304 12h;
            #对应group2的服务设置
            proxy_cache_key $uri$is_args$args;
            proxy_pass http://fdfs_group2;
            expires 30d;
        }
                                            
        #清除缓存的访问权限
        location  ~/purge(/.*) {
            allow 127.0.0.1;
            allow 192.168.101.0/24;
            deny all;
            proxy_cache_purge http-cache $1$is_args$args;
        }

```  

6、创建缓存目录  
``` mkdir /fastdfs/cache/nginx/proxy_cache -pv ```  
