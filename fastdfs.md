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
store_lookup=2              # 0代表轮训，1代表挑选的组，如果是1则安装store_group=group1的配置写入，2挑选空闲最多的空间写入
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
```  

三、配置storage服务器  
---
1、编辑配置文件  
```
cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
vi /etc/fdfs/storage.conf
disabled=false                       # 启用配置文件
group_name=group1                    # 属于第几个组，默认属于第一个组
port=23000                           # storage服务端口
base_path=/fastdfs/storage           # 数据和日志文件存储根目录
store_path_count=1                   # 指定默认有几个设备存储数据默认一个，如果有多个需要store_path0,store_path1来指定
store_path0=/fastdfs/storage/0         # 第一个存储目录,如果只有一个挂载设备可以不用指0，直接到/fastdfs/storage/即可
store_path1=/fastdfs/storage/1         # 第二个存储目录
tracker_server=192.168.101.69:22122  # tracker服务器IP和端口
tracker_server=192.168.101.70:22122  #tracker服务器IP2和端口
http.server_port=8888                # http访问文件的端口
```  
其它参数保留默认配置， 具体配置解释可参考官方文档说明：http://bbs.chinaunix.net/thread-1941456-1-1.html  
2、创建基础数据目录  
``` mkdir -p /fastdfs/storage ```  

3、启动storage服务器  
```
/etc/init.d/fdfs_storaged start
初次启动，会在/fastdfs/storage目录下生成logs、data两个目录。
drwxr-xr-x 259 root root 4096 Mar 31 06:22 data
drwxr-xr-x   2 root root 4096 Mar 31 06:22 logs
检查FastDFS Tracker Server是否启动成功：
ps -ef | grep fdfs_storaged
```  


注：集群环境下  
追踪+存储节点操作步骤一、步骤二、步骤三  
存储节点只做存储则只操作步骤三  

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
fdfs_monitor client.conf
```  

3、执行文件上传命令  
```
#/etc/fstab 是需要上传文件路径
/usr/bin/fdfs_upload_file /etc/fdfs/client.conf /etc/fstab
返回文件ID号：group1/M00/00/00/tlxkwlhttsGAU2ZXAAC07quU0oE095
（能返回以上文件ID，说明文件已经上传成功）
或者: 
/usr/bin/fdfs_test /etc/fdfs/client.conf upload client.conf
```  

4、查看上传的文件  
```
fdfs_file_info /etc/fdfs/client.conf group1/M00/00/00/tlxkwlhttsGAU2ZXAAC07quU0oE095
```  

5、下载文件  
```
fdfs_download_file /etc/fdfs/client.conf group1/M00/00/00/tlxkwlhttsGAU2ZXAAC07quU0oE095 /tmp/fstab
```  

五、在所有storage节点安装fastdfs-nginx-module  
---
1、下载 fastdfs-nginx-module模块  
```
git clone https://github.com/happyfish100/fastdfs-nginx-module.git
```  

2、修改 fastdfs-nginx-module 的 config 配置文件  
```
cd fastdfs-nginx-module/src
vim config
将
CORE_INCS="$CORE_INCS /usr/local/include/fastdfs /usr/local/include/fastcommon/" 
修改为:
CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
```  

3、安装编译 Nginx 所需的依赖包  
```
yum install gcc gcc-c++ make automake autoconf libtool pcre* zlib openssl openssl-devel
```  

4、编译安装 Nginx (添加 fastdfs-nginx-module 模块)   
```
tar -zxvf nginx-1.10.0.tar.gz
tar –zxvf ngx_cache_purge_2.3.tar.gz

cd nginx-1.10.0

./configure --prefix=/opt/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-pcre --add-module=/root/fastdfs-nginx-module/src --add-module=/root/ngx_cache_purge/src/ngx_cache_purge-2.3
 
make && make install
```  

5.复制 fastdfs-nginx-module 源码中的配置文件到/etc/fdfs 目录,并修改  
```
cp /usr/local/src/fastdfs-nginx-module/src/mod_fastdfs.conf      /etc/fdfs/ 
vim /etc/fdfs/mod_fastdfs.conf
connect_timeout=10
base_path=/tmp  
tracker_server=192.168.101.69:22122  # tracker服务器IP和端口
tracker_server=192.168.101.70:22122  #tracker服务器IP2和端口
url_have_group_name=true   #url中包含group名称 
#在最后添加 [group1] 
group_name=group1 
storage_server_port=23000 
store_path_count=1 
store_path0=/fastdfs/storage
```  

6、复制 FastDFS 的部分配置文件到/etc/fdfs 目录  
```
cd /usr/local/src/FastDFS/conf
cp http.conf mime.types /etc/fdfs/
```  

7、在/fastdfs/storage 文件存储目录下创建软连接,将其链接到实际存放数据的目录  
``` ln -s /fastdfs/storage/data/ /fastdfs/storage/data/M00 ```  

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
        server_name 192.168.101.69;
        location ~/group1/M00 {
            ngx_fastdfs_module;
        }
        error_page 500 502 503 504 /50x.html;

        location = /50x.html {
            root html;
        }
    }
 upstream storage_server_group1{                                                                                              
                 server 192.168.101.69:8888 weight=10;                                                                               
                 server 192.168.101.70:8888 weight=10;                                                                               
                 server 192.168.101.71:8888 weight=10;                                                                               
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
vi /etc/sysconfig/iptables
 添加:
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8888 -j ACCEPT

#重启防火墙
service iptables restart
```  

启动 Nginx  
``` /opt/nginx/sbin/nginx -s reload ```  


六、验证：通过浏览器访问测试时上传的文件  
 
切换追踪服务器IP同样可以访问  
http://192.168.101.69:8888/group1/M00/00/00/CmSKtFj13gyAen4oAAH0yXi-HW8296  
http://192.168.101.70:8888/group1/M00/00/00/CmSKtFj13gyAen4oAAH0yXi-HW8296  

七、客户端配置  
1、项目pom.xml引入  
```
<dependency>
	<groupId>fastdfs_client</groupId>
	<artifactId>fastdfs_client</artifactId>
	<version>0.0.2-SNAPSHOT</version>
</dependency>
```  
2、resources下加入文件fastdfs_client.conf  
注意修改ip0为tracker服务器Ip地址  
```
connect_timeout = 2
network_timeout = 30
charset = ISO8859-1
http.tracker_http_port = 8888
http.anti_steal_token = no
tracker_server=192.168.101.69:22122
tracker_server=192.1618.101.70:22122
default_group_name=group1
```  
