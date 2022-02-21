# 一、minio对象存储基础

## 1.1 基础概念

MinIO 是在 GNU Affero 通用公共许可证 v3.0 下发布的高性能对象存储。 它是与 Amazon S3 云存储服务兼容的 API。 使用 MinIO 为机器学习、分析和应用程序数据工作负载构建高性能基础架构。

独立的 MinIO 服务器最适合早期开发和评估。 某些功能，例如版本控制、对象锁定和存储桶复制需要使用擦除编码分布式部署 MinIO。 对于扩展的开发和生产，请在启用擦除编码的情况下部署 MinIO ， 每个 MinIO 服务器最少4个驱动器。

## 1.2 Minio纠删码

Minio使用纠删码erasure code和校验和checksum来保护数据免受硬件故障和无声数据损坏。 默认配置即便您丢失一半数量（N/2）的硬盘，您仍然可以恢复数据。

纠删码是一种恢复丢失和损坏数据的数学算法， Minio采用Reed-Solomon code将对象拆分成N/2数据和N/2 奇偶校验块。 这就意味着如果是12块盘，一个对象会被分成6个数据块、6个奇偶校验块，你可以丢失任意6块盘（不管其是存放的数据块还是奇偶校验块），你仍可以从剩下的盘中的数据进行恢复。

纠删码的工作原理和RAID或者复制不同，像RAID6可以在损失两块盘的情况下不丢数据，而Minio纠删码可以在丢失一半的盘的情况下，仍可以保证数据安全。 而且Minio纠删码是作用在对象级别，可以一次恢复一个对象，而RAID是作用在卷级别，数据恢复时间很长。 Minio对每个对象单独编码，存储服务一经部署，通常情况下是不需要更换硬盘或者修复。Minio纠删码的设计目标是为了性能和尽可能的使用硬件加速。

位衰减又被称为数据腐化Data Rot、无声数据损坏Silent Data Corruption,是目前硬盘数据的一种严重数据丢失问题。硬盘上的数据可能会神不知鬼不觉就损坏了，也没有什么错误日志。正所谓明枪易躲，暗箭难防，这种背地里犯的错比硬盘直接咔咔宕了还危险。 不过不用怕，Minio纠删码采用了高速HighwayHash基于哈希的校验和来防范位衰减。

## 1.3 分布式Minio
分布式Minio可以让你将多块硬盘（甚至在不同的机器上）组成一个对象存储服务。由于硬盘分布在不同的节点上，分布式Minio避免了单点故障。在大数据领域，通常的设计理念都是无中心和分布式。Minio分布式模式可以帮助你搭建一个高可用的对象存储服务，你可以使用这些存储设备，而不用考虑其真实物理位置。

- 分布式Minio采用 纠删码来防范多个节点宕机和位衰减bit rot。
- 分布式Minio至少需要4个硬盘，使用分布式Minio自动引入了纠删码功能。

**高可用**

单机Minio服务存在单点故障，相反，如果是一个有N块硬盘的分布式Minio,只要有N/2硬盘在线，你的数据就是安全的。不过你需要至少有N/2+1个节点来创建新的对象。

例如，一个16节点的Minio集群，每个节点16块硬盘，就算8台服务器宕机，这个集群仍然是可读的，不过你需要9台服务器才能写数据。

注意，只要遵守分布式Minio的限制，你可以组合不同的节点和每个节点几块硬盘。比如，你可以使用2个节点，每个节点4块硬盘，也可以使用4个节点，每个节点两块硬盘，诸如此类。

**一致性**

Minio在分布式和单机模式下，所有读写操作都严格遵守read-after-write一致性模型。

# 二、minio部署

下载二进制文件：http://dl.minio.org.cn/

以下部署方法全部使用二进制

**集群节点性能优化脚本**
```shell
#!/bin/bash

cat > sysctl.conf <<EOF
# maximum number of open files/file descriptors
fs.file-max = 4194303

# use as little swap space as possible
vm.swappiness = 1

# prioritize application RAM against disk/swap cache
vm.vfs_cache_pressure = 50

# minimum free memory
vm.min_free_kbytes = 1000000

# follow mellanox best practices https://community.mellanox.com/s/article/linux-sysctl-tuning
# the following changes are recommended for improving IPv4 traffic performance by Mellanox

# disable the TCP timestamps option for better CPU utilization
net.ipv4.tcp_timestamps = 0

# enable the TCP selective acks option for better throughput
net.ipv4.tcp_sack = 1

# increase the maximum length of processor input queues
net.core.netdev_max_backlog = 250000

# increase the TCP maximum and default buffer sizes using setsockopt()
net.core.rmem_max = 4194304
net.core.wmem_max = 4194304
net.core.rmem_default = 4194304
net.core.wmem_default = 4194304
net.core.optmem_max = 4194304

# increase memory thresholds to prevent packet dropping:
net.ipv4.tcp_rmem = "4096 87380 4194304"
net.ipv4.tcp_wmem = "4096 65536 4194304"

# enable low latency mode for TCP:
net.ipv4.tcp_low_latency = 1

# the following variable is used to tell the kernel how much of the socket buffer
# space should be used for TCP window size, and how much to save for an application
# buffer. A value of 1 means the socket buffer will be divided evenly between.
# TCP windows size and application.
net.ipv4.tcp_adv_win_scale = 1

# maximum number of incoming connections
net.core.somaxconn = 65535

# maximum number of packets queued
net.core.netdev_max_backlog = 10000

# queue length of completely established sockets waiting for accept
net.ipv4.tcp_max_syn_backlog = 4096

# time to wait (seconds) for FIN packet
net.ipv4.tcp_fin_timeout = 15

# disable icmp send redirects
net.ipv4.conf.all.send_redirects = 0

# disable icmp accept redirect
net.ipv4.conf.all.accept_redirects = 0

# drop packets with LSR or SSR
net.ipv4.conf.all.accept_source_route = 0

# MTU discovery, only enable when ICMP blackhole detected
net.ipv4.tcp_mtu_probing = 1

EOF

echo "Enabling system level tuning params"
sysctl --quiet --load sysctl.conf && rm -f sysctl.conf

# `Transparent Hugepage Support`*: This is a Linux kernel feature intended to improve
# performance by making more efficient use of processor’s memory-mapping hardware.
# But this may cause https://blogs.oracle.com/linux/performance-issues-with-transparent-huge-pages-thp
# for non-optimized applications. As most Linux distributions set it to `enabled=always` by default,
# we recommend changing this to `enabled=madvise`. This will allow applications optimized
# for transparent hugepages to obtain the performance benefits, while preventing the
# associated problems otherwise. Also, set `transparent_hugepage=madvise` on your kernel
# command line (e.g. in /etc/default/grub) to persistently set this value.

echo "Enabling THP madvise"
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
```

## 2.1 单机部署

- 单机部署可以使用单数据盘，但是数据不会实现冗余，如果这个数据盘损坏，minio数据将全部丢失
- 集群与单机多数据盘，默认启用纠删码功能，如果单机使用多数据盘最少4块数据盘

**1.单机单数据盘部署**
```
[root@minio01 ~]# ls /usr/bin/minio 
/usr/bin/minio

[root@minio01 ~]# export MINIO_ROOT_USER=minio
[root@minio01 ~]# export MINIO_ROOT_PASSWORD=minio123
[root@minio01 ~]# minio server /data/minio1 --console-address ":9001"
API: http://192.168.10.51:9000  http://127.0.0.1:9000     
RootUser: minio 
RootPass: minio123 

Console: http://192.168.10.51:9001 http://127.0.0.1:9001   
RootUser: minio 
RootPass: minio123 

Command-line: https://docs.min.io/docs/minio-client-quickstart-guide
   $ mc alias set myminio http://192.168.10.51:9000 minio minio123

Documentation: https://docs.min.io
```

**2.单机多数据盘**
```
[17:20:02 root@centos7 ~]#export MINIO_ROOT_USER=minio
[17:20:25 root@centos7 ~]#export MINIO_ROOT_PASSWORD=minio123
[17:20:32 root@centos7 ~]#minio server /data/minio{1...4} --console-address ":9001"
```

**3.以service守护进行的方式运行**

**创建minio配置文件**
```
[17:23:57 root@centos7 ~]#cat /etc/default/minio.conf
MINIO_ROOT_USER=minio
MINIO_ROOT_PASSWORD=minio123
MINIO_PROMETHEUS_AUTH_TYPE="public"  #监控不需要认证授权
MINIO_VOLUMES="/data/minio{1...4}" 
MINIO_OPTS='--console-address :9001'
```

**创建minio的service文件**
```
#创建minio工作目录
[17:23:58 root@centos7 ~]#mkdir /usr/local/minio
#创建service文件
[17:26:40 root@centos7 ~]#cat /etc/systemd/system/minio.service
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-noline.target
After=network-noline.target

[Service]
WorkingDirectory=/usr/local/minio
User=root
Group=root
EnvironmentFile=-/etc/default/minio.conf
ExecStart=/usr/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always

[Install]
WantedBy=multi-user.target
```

**启动服务验证**
```
[17:28:38 root@centos7 ~]#systemctl restart minio
[17:28:38 root@centos7 ~]#systemctl status minio
● minio.service - MinIO
   Loaded: loaded (/etc/systemd/system/minio.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2021-09-13 17:28:32 CST; 6s ago
     Docs: https://docs.min.io
 Main PID: 1406 (minio)
   CGroup: /system.slice/minio.service
           └─1406 /usr/bin/minio server --console-address :9001 /data/minio{1...4}
Sep 13 17:28:32 centos7 systemd[1]: Stopped MinIO.
Sep 13 17:28:32 centos7 systemd[1]: Started MinIO.
Sep 13 17:28:36 centos7 minio[1406]: You are running an older version of MinIO released 1 month ago
Sep 13 17:28:36 centos7 minio[1406]: Update: Run `mc admin update`
Sep 13 17:28:36 centos7 minio[1406]: Status:         4 Online, 0 Offline.   #出现这个表示集群正常
Sep 13 17:28:36 centos7 minio[1406]: API: http://192.168.10.71:9000  http://127.0.0.1:9000
Sep 13 17:28:36 centos7 minio[1406]: Console: http://192.168.10.71:9001 http://127.0.0.1:9001
Sep 13 17:28:36 centos7 minio[1406]: Documentation: https://docs.min.io
```

**4.以TLS加密方式运行minio**

如果你已经有私钥和公钥证书，你需要将它们拷贝到Minio的config/certs文件夹,分别取名为private.key 和 public.crt。

如果这个证书是被证书机构签发的，public.crt应该是服务器的证书，任何中间体的证书以及CA的根证书的级联。

**生成自签名证书**
```
[17:28:38 root@centos7 ~]#openssl genrsa -out private.key 2048
[17:33:12 root@centos7 ~]#openssl req -new -x509 -days 3650 -key private.key -out public.crt -subj "/C=US/ST=state/L=location/O=organization/CN=domain"
[17:33:40 root@centos7 ~]#ls
private.key  public.crt
```

**移动证书到配置文件**

如果没有设置--config-dir默认配置文件的路径为运行minio用户的${HOME}/.minio
```
[17:36:53 root@centos7 ~]#cp * .minio/certs/
#文件名称必须为这样，不能修改
[17:37:03 root@centos7 ~]#ls .minio/certs/
CAs  private.key  public.crt
```

**重启服务验证**
```
[17:37:15 root@centos7 ~]#systemctl restart minio
[17:38:15 root@centos7 ~]#systemctl status minio
● minio.service - MinIO
   Loaded: loaded (/etc/systemd/system/minio.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2021-09-13 17:38:15 CST; 5s ago
     Docs: https://docs.min.io
 Main PID: 1464 (minio)
   CGroup: /system.slice/minio.service
           └─1464 /usr/bin/minio server --console-address :9001 /data/minio{1...4}

Sep 13 17:38:15 centos7 systemd[1]: Stopped MinIO.
Sep 13 17:38:15 centos7 systemd[1]: Started MinIO.
Sep 13 17:38:19 centos7 minio[1464]: You are running an older version of MinIO released 1 month ago
Sep 13 17:38:19 centos7 minio[1464]: Update: Run `mc admin update`
Sep 13 17:38:19 centos7 minio[1464]: Status:         4 Online, 0 Offline.
Sep 13 17:38:19 centos7 minio[1464]: API: https://192.168.10.71:9000  https://127.0.0.1:9000  #这里变为https
Sep 13 17:38:19 centos7 minio[1464]: Console: https://192.168.10.71:9001 https://127.0.0.1:9001
Sep 13 17:38:19 centos7 minio[1464]: Documentation: https://docs.min.io
```
**如果要minio信任第三方证书**

将这些证书放到Minio配置路径下(~/.minio/certs/CAs/）

## 2.2 参数说明
```
--config-dir  #默认配置目录${HOME}/.minio,你可以使用--config-dir参数进行重写
--address     #服务监听地址与端口
--console-address #web控制台监听的端口
MINIO_ROOT_USER #管理员用户
MINIO_ROOT_PASSWORD #管理员用户密码
MINIO_ACCESS_KEY #对象存储和Web访问的验证凭据，Access key
MINIO_SECRET_KEY #对象存储和Web访问的验证凭据，Secret key
MINIO_PROMETHEUS_AUTH_TYPE="public"  #访问监控指标不需要认证授权
```

## 2.3 minio分布式集群部署

### 1.注意
- 1.所有节点配置全部一致，minio配置文件，hosts解析，数据磁盘大小
- 2.数据目录必须没有任何数据
- 3.分布式集群环境，建议使用hosts文件做地址解析，不要直接使用IP地址，方便后期更换旧的节点不需要修改minio配置文件
- 4.minio分布式集群可以在所有节点进行写操作，所以需要使用nginx代理进行请求转发
- 5.如需要使用TLS也是在nginx端做加密，不需要在minio做加密
- 6.如使用nginx代理，生产环境建议配置2个nginx+keepalived实现负载高可用

### 2.部署说明

所有节点执行，我这里是俩个节点
```
[17:53:01 root@centos7 ~]#mkdir /data/minio{1..4} /usr/local/minio -p

#配置hosts
[17:46:41 root@centos7 ~]#cat /etc/hosts
192.168.10.71 minio1
192.168.10.72 minio2
#修改配置文件
[17:48:10 root@centos7 ~]#cat /etc/default/minio.conf
MINIO_ROOT_USER=minio
MINIO_ROOT_PASSWORD=minio123
MINIO_PROMETHEUS_AUTH_TYPE="public"
MINIO_VOLUMES="http://minio{1...2}:9000/data/minio{1...4}"
MINIO_OPTS='--console-address :9001'
#准备service文件
[17:48:11 root@centos7 ~]#cat /etc/systemd/system/minio.service 
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-noline.target
After=network-noline.target

[Service]
WorkingDirectory=/usr/local/minio
User=root
Group=root
EnvironmentFile=-/etc/default/minio.conf
ExecStart=/usr/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always

[Install]
WantedBy=multi-user.target
#启动服务，验证
[17:54:00 root@centos7 ~]#systemctl status minio
● minio.service - MinIO
   Loaded: loaded (/etc/systemd/system/minio.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2021-09-13 17:53:53 CST; 8s ago
     Docs: https://docs.min.io
 Main PID: 1754 (minio)
   CGroup: /system.slice/minio.service
           └─1754 /usr/bin/minio server --console-address :9001 http://minio{1...2}/data/minio{1...4}

Sep 13 17:53:53 centos7 systemd[1]: Started MinIO.
Sep 13 17:53:57 centos7 minio[1754]: You are running an older version of MinIO released 1 month ago
Sep 13 17:53:57 centos7 minio[1754]: Update: Run `mc admin update`
Sep 13 17:53:57 centos7 minio[1754]: Waiting for all MinIO sub-systems to be initialized.. lock acquired
Sep 13 17:53:57 centos7 minio[1754]: All MinIO sub-systems initialized successfully
Sep 13 17:53:58 centos7 minio[1754]: Waiting for all MinIO IAM sub-system to be initialized.. lock acquired
Sep 13 17:53:58 centos7 minio[1754]: Status:         8 Online, 0 Offline.   #成功
Sep 13 17:53:58 centos7 minio[1754]: API: http://192.168.10.71:9000  http://127.0.0.1:9000
Sep 13 17:53:58 centos7 minio[1754]: Console: http://192.168.10.71:9001 http://127.0.0.1:9001
Sep 13 17:53:58 centos7 minio[1754]: Documentation: https://docs.min.io
```

### 3.nginx配置文件

不加密
```
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  4096;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    keepalive_timeout  65;

    # include /etc/nginx/conf.d/*.conf;

    upstream minio {
        server 10.202.40.183:9000;
        server 10.202.40.83:9000;
        server 10.202.41.126:9000;
        server 10.202.41.174:9000;
    }

    upstream console {
        ip_hash;
        server 10.202.40.183:9001;
        server 10.202.40.83:9001;
        server 10.202.41.126:9001;
        server 10.202.41.174:9001;
    }

    server {
        listen       9000;
        listen  [::]:9000;
        server_name  localhost;

        # To allow special characters in headers
        ignore_invalid_headers off;
        # Allow any size file to be uploaded.
        # Set to a value such as 1000m; to restrict file size to a specific value
        client_max_body_size 0;
        # To disable buffering
        proxy_buffering off;

        location / {
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_connect_timeout 300;
            # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            chunked_transfer_encoding off;

            proxy_pass http://minio;
        }
    }

    server {
        listen       9001;
        listen  [::]:9001;
        server_name  localhost;

        # To allow special characters in headers
        ignore_invalid_headers off;
        # Allow any size file to be uploaded.
        # Set to a value such as 1000m; to restrict file size to a specific value
        client_max_body_size 0;
        # To disable buffering
        proxy_buffering off;

        location / {
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-NginX-Proxy true;

            # This is necessary to pass the correct IP to be hashed
            real_ip_header X-Real-IP;

            proxy_connect_timeout 300;
            # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            chunked_transfer_encoding off;

            proxy_pass http://console;
        }
    }
}
```

### 4.keepalived配置

nginx健康监测脚本
```
[14:14:51 root@centos7 ~]#cat check_nginx_minio.sh 
#!/bin/bash
/usr/bin/killall -0 nginx && [ 200 == `curl -I http://127.0.0.1:9000/minio/health/cluster | head -n1 | awk '{print $2}'` ] && exit
systemctl restart nginx && [ 200 == `curl -I http://127.0.0.1:9000/minio/health/cluster | head -n1 | awk '{print $2}'` ] && exit
```

keepalived具体配置
```
vrrp_script check_nginx {
    script "/root/check_nginx_minio.sh" 
    interval 5
    weight -30
    fall 3
    rise 2   
    timeout 2 
}
vrrp_instance minio_lb {
    state MASTER   
    interface eth0  
    virtual_router_id 80 
    priority 100    
    advert_int 1   
    authentication { 
        auth_type PASS
        auth_pass 1111  
    }
    unicast_src_ip 192.168.10.71
    unicast_peer{
        192.168.10.72
    }
    virtual_ipaddress { 
        192.168.10.100/24 dev eth0 label eth0:1
    }
    track_script {
        check_nginx
    }
}
```

# 三、mc客户端工具使用

客户端工具下载地址：http://dl.minio.org.cn/client/mc/release/linux-amd64/archive/

## 3.1 客户端工具安装
```
[17:56:18 root@centos7 ~]#chmod +x mc.RELEASE.2021-07-27T06-46-19Z 
[17:56:26 root@centos7 ~]#mv mc.RELEASE.2021-07-27T06-46-19Z /usr/bin/mc

#配置客户端工具
[17:56:37 root@centos7 ~]#mc config host add minio http://192.168.10.71:9000 minio minio123 -api s3v4
mc: Configuration written to `/root/.mc/config.json`. Please update your access credentials.
mc: Successfully created `/root/.mc/share`.
mc: Initialized share uploads `/root/.mc/share/uploads.json` file.
mc: Initialized share downloads `/root/.mc/share/downloads.json` file.
Added `minio` successfully.

#shell自动补齐
[18:01:22 root@centos7 ~]#mc --autocompletion bash
mc: Your shell is set to '/bin/bash', by env var 'SHELL'.
mc: autocompletion is enabled. 
* already installed in /root/.bashrc
[18:01:42 root@centos7 ~]#source /root/.bashrc

#验证是否可用
[18:01:56 root@centos7 ~]#mc admin info minio
●  minio2:9000
   Uptime: 10 minutes 
   Version: 2021-07-12T02:44:53Z
   Network: 2/2 OK 
   Drives: 4/4 OK 

●  minio1:9000
   Uptime: 8 minutes 
   Version: 2021-07-12T02:44:53Z
   Network: 2/2 OK 
   Drives: 4/4 OK 

8 drives online, 0 drives offline
```

## 3.2 mc 客户端说明

MinIO Client (mc)为ls，cat，cp，mirror，diff，find等UNIX命令提供了一种替代方案。它支持文件系统和兼容Amazon S3的云存储服务（AWS Signature v2和v4。

### 1.参数说明
```
ls       #列出文件和文件夹。
mb       #创建一个存储桶或一个文件夹。
cat      #显示文件和对象内容。
pipe     #将一个STDIN重定向到一个对象或者文件或者STDOUT。
share    #生成用于共享的URL。
cp       #拷贝文件和对象。
mirror   #给存储桶和文件夹做镜像。
find     #基于参数查找文件。
diff     #对两个文件夹或者存储桶比较差异。
rm       #删除文件和对象。
events   #管理对象通知。
watch    #监视文件和对象的事件。
policy   #管理访问策略。
config   #管理mc配置文件。
update   #检查软件更新。
version  #输出版本信息。
```

### 2.全局参数
`--debug` Debug参数开启控制台输出debug信息。

示例：输出`ls`命令的详细debug信息。
```
[14:26:31 root@centos7 ~]#mc --debug ls  minio
mc: <DEBUG> GET / HTTP/1.1
Host: 192.168.10.71:9000
User-Agent: MinIO (linux; amd64) minio-go/v7.0.11 mc/RELEASE.2021-07-27T06-46-19Z
Authorization: AWS4-HMAC-SHA256 Credential=minio/20210914/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=**REDACTED**
X-Amz-Content-Sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
X-Amz-Date: 20210914T062635Z
Accept-Encoding: gzip

mc: <DEBUG> HTTP/1.1 200 OK
Content-Length: 362
Accept-Ranges: bytes
Content-Security-Policy: block-all-mixed-content
Content-Type: application/xml
Date: Tue, 14 Sep 2021 06:26:35 GMT
Server: MinIO
Vary: Origin
X-Amz-Request-Id: 16A49C475F119FF7
X-Xss-Protection: 1; mode=block

mc: <DEBUG> Response Time:  3.660869ms

[2021-09-13 18:04:48 CST]     0B nide/
```

--json参数启用JSON格式的输出。

示例：列出minio的所有存储桶。
```
[14:26:35 root@centos7 ~]#mc --json ls  minio
{
 "status": "success",
 "type": "folder",
 "lastModified": "2021-09-13T18:04:48.003+08:00",
 "size": 0,
 "key": "nide/",
 "etag": "",
 "url": "http://192.168.10.71:9000/",
 "versionOrdinal": 1
}
```
- --no-color 这个参数禁用颜色主题。对于一些比较老的终端有用
- --quiet 这个参数关闭控制台日志输出
- --config-dir 这个参数参数自定义的配置文件路径。
- --insecure 跳过SSL证书验证。

### 3.命令介绍

`ls`命令 - 列出对象
```
#ls命令列出文件、对象和存储桶。使用--incomplete flag可列出未完整拷贝的内容。
参数
--recursive, -r          递归。
--incomplete, -I         列出未完整上传的对象。
```

`mb`命令 - 创建存储桶
```
#mb命令在对象存储上创建一个新的存储桶。在文件系统，它就和mkdir -p命令是一样的。
参数
--region "us-east-1"         指定存储桶的region，默认是‘us-east-1’
#示例
[14:39:17 root@centos7 ~]#mc  mb  minio/zhang
```

`rb`命令-删除存储桶
```
#mb命令在对象存储上删除一个空的存储桶。
[14:39:17 root@centos7 ~]#mc  rb  minio/zhang
```

`cat`命令 - 合并对象
```
#cat命令将一个文件或者对象的内容合并到另一个上。你也可以用它将对象的内容输出到stdout。
[14:41:37 root@centos7 ~]#mc cat minio/test/1.txt 
zhangzhuo
```

`pipe`命令 - Pipe到对象
```
#pipe命令拷贝stdin里的内容到目标输出，如果没有指定目标输出，则输出到stdout。
[14:42:53 root@centos7 ~]#cat /etc/passwd | mc pipe minio/zhang/passwd
[14:44:15 root@centos7 ~]#mc cat minio/zhang/passwd 
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
```

`cp`命令 - 拷贝对象
```
#cp命令拷贝一个或多个源文件目标输出。所有到对象存储的拷贝操作都进行了MD4SUM checkSUM校验。可以从故障点恢复中断或失败的复制操作。
参数
 --recursive, -r          递归拷贝。
#示例
[14:46:36 root@centos7 ~]#mc cp -r /etc minio/etc
```

`rm`命令 - 删除存储桶和对象
```
#使用rm命令删除文件对象
参数
--recursive, -r        #递归删除。
--force                #强制执行删除操作。
--prefix               #删除批配这个前缀的对象。
--incomplete, -I       #删除未完整上传的对象。
--fake                 #模拟一个假的删除操作。
--stdin                #从STDIN中读对象列表。
--older-than value     #删除N天前的对象（默认是0天）。

示例
#删除一个对象
[14:47:51 root@centos7 ~]#mc rm minio/zhang/passwd

#删除一个存储桶并递归删除里面所有的内容。由于这个操作太危险了，你必须传--force参数指定强制删除。
[14:50:51 root@centos7 ~]#mc rm -r --force minio/etc

#删除所有未完整上传的对象。
[14:55:30 root@centos7 ~]#mc rm --incomplete --recursive --force minio/tar

#删除一天前的对象
[14:57:06 root@centos7 ~]#mc rm --force --older-than=1 minio/zhang/
```

`share`命令 - 共享
```
#share命令安全地授予上传或下载的权限。此访问只是临时的，与远程用户和应用程序共享也是安全的。如果你想授予永久访问权限，你可以看看mc policy命令。
#生成的网址中含有编码后的访问认证信息，任何企图篡改URL的行为都会使访问无效。想了解这种机制是如何工作的，请参考Pre-Signed URL技术。
命令
download   #生成有下载权限的URL。
upload     #生成有上传权限的URL。
list       #列出先前共享的对象和文件夹。
子参数
--recursive, -r              #递归共享所有对象。
--expire, -E "168h"          #设置过期时限，NN[h|m|s].
```

`mirror`命令 - 存储桶镜像
```
#mirror命令和rsync类似，只不过它是在文件系统和对象存储之间做同步。
参数
--force              #强制覆盖已经存在的目标。
--fake               #模拟一个假的操作。
--watch, -w          #监听改变并执行镜像操作。
--remove             #删除目标上的外部的文件。
示例
#将一个本地文件夹镜像到存储桶。
[15:11:33 root@centos7 ~]#mc mirror /etc minio/etc

#持续监听本地文件夹修改并镜像到存储桶。
[15:23:32 root@centos7 ~]#mc mirror -w /etc minio/etc
```

`find`命令 - 查找文件和对象
```
#find命令通过指定参数查找文件，它只列出满足条件的数据
--exec value                     #为每个匹配对象生成一个外部进程（请参阅FORMAT）
--name value                     #查找匹配通配符模式的对象。
--watch, -w                      #监听改变并执行镜像操作
示例
#持续从s3存储桶中查找所有jpeg图像，并复制到其他存储桶
[15:23:32 root@centos7 ~]#mc find minio/etc --name "*.png" --watch --exec "mc cp {} minio/test"
```

`diff`命令 - 显示差异
```
#diff命令计算两个目录之间的差异。它只列出缺少的或者大小不同的内容。
它不比较内容，所以可能的是，名称相同，大小相同但内容不同的对象没有被检测到。这样，它可以在不同站点或者大量数据的情况下快速比较。
[15:28:46 root@centos7 ~]#mc diff /etc/ minio/etc
```

`watch`命令 - 监听文件和对象存储事件
```
#watch命令提供了一种方便监听对象存储和文件系统上不同类型事件的方式。
参数
--events value           过滤不同类型的事件，默认是所有类型的事件 (默认： "put,delete,get")
--prefix value           基于前缀过滤事件。
--suffix value           基于后缀过滤事件。
--recursive              递归方式监听事件。
示例
#监听minio存储所有事件
[15:28:56 root@centos7 ~]#mc watch minio/etc/

#监听本地文件夹所有事件
[15:31:52 root@centos7 ~]#mc watch etc/
```

`events`命令 - 管理存储桶事件通知
```
#events提供了一种方便的配置存储桶的各种类型事件通知的方式。MinIO事件通知可以配置成使用 AMQP，Redis，ElasticSearch，NATS和PostgreSQL服务。MinIO configuration提供了如何配置的更多细节。
参数
add     #添加一个新的存储桶通知。
remove  #删除一个存储桶通知。使用'--force'可以删除所有存储桶通知。
list    #列出存储桶通知。
示例
#列出所有存储桶通知
[15:35:36 root@centos7 ~]#mc event list minio/etc
```

## 3.3 mc管理员说明

MinIO Client（mc）提供了“ admin”子命令来对您的MinIO部署执行管理任务。

### 1. 命令介绍
```
service     服务重启并停止所有MinIO服务器
update      更新更新所有MinIO服务器
info        信息显示MinIO服务器信息
user        用户管理用户
group       小组管理小组
policy      MinIO服务器中定义的策略管理策略
config      配置管理MinIO服务器配置
heal        修复MinIO服务器上的磁盘，存储桶和对象
profile     概要文件生成概要文件数据以进行调试
top         顶部提供MinIO的顶部统计信息
trace       跟踪显示MinIO服务器的http跟踪
console     控制台显示MinIO服务器的控制台日志
prometheus  Prometheus管理Prometheus配置
kms         kms执行KMS管理操作
```

### 2.常用命令介绍

命令info-显示MinIO服务器信息
```
[15:39:45 root@centos7 ~]#mc admin info minio
●  minio2:9000
   Uptime: 5 hours 
   Version: 2021-07-12T02:44:53Z
   Network: 2/2 OK 
   Drives: 4/4 OK 

●  minio1:9000
   Uptime: 5 hours 
   Version: 2021-07-12T02:44:53Z
   Network: 2/2 OK 
   Drives: 4/4 OK 

30 MiB Used, 5 Buckets, 1,819 Objects
8 drives online, 0 drives offline
```

命令`heal`-修复MinIO服务器上的磁盘，存储桶和对象
```
[15:39:47 root@centos7 ~]#mc admin heal -r minio
```

命令`trace`-显示MinIO服务器的http跟踪
```
[15:50:49 root@centos7 ~]#mc admin trace minio -a
```

命令`console`-显示MinIO服务器的控制台日志
```
[15:50:49 root@centos7 ~]#mc admin console minio
```

# 四、minio监控

MinIO 服务器通过端点公开监控数据。监控工具可以从这些端点中挑选数据。本文档列出了监控端点和相关文档。

## 4.1 健康检查探针

MinIO 服务器有两个与健康检查相关的未经身份验证的端点，一个用于指示服务器是否响应的活动探测器，用于检查服务器是否可以停机进行维护的集群探测器。

### 1.k8s中的探针设置

部署到k8s集群的minio可以设置这俩个探针

- 活性探针：/minio/health/live，该探测器正常状态始终以“200 OK”作为响应。
```
livenessProbe:
  httpGet:
    path: /minio/health/live
    port: 9000
    scheme: HTTP
  initialDelaySeconds: 120
  periodSeconds: 30
  timeoutSeconds: 10
  successThreshold: 1
  failureThreshold: 3
```

- 就绪探针：/minio/health/ready，该探针正常情况下始终以“200”作为响应。
```
readinessProbe:
  httpGet:
    path: /minio/health/ready
    port: 9000
    scheme: HTTP
  initialDelaySeconds: 120
  periodSeconds: 15
  timeoutSeconds: 10
  successThreshold: 1
  failureThreshold: 3
```

### 2.集群探针

- 集群可写探针：/minio/health/cluster使用这个探针可以确定集群是否有写入仲裁(即minio集群存活节点大于等于N/2+1个)，正常回复“200”，否则返回“503 Service Unavailable”
```
[14:35:25 root@centos7 ~]#curl 127.0.0.1:9000/minio/health/cluster -I
HTTP/1.1 200 OK

[14:35:27 root@centos7 ~]#curl 127.0.0.1:9000/minio/health/cluster -I
HTTP/1.1 503 Service Unavailable
```

- 集群可读探针：/minio/health/cluster/read这是为了让管理员查看在任何给定集群中是否有可用的读取仲裁(即minio集群存活节点大于等于N/2)。正常回复“200”，否则返回“503 Service Unavailable”。
```
[14:35:39 root@centos7 ~]#curl 127.0.0.1:9000/minio/health/cluster/read -I
HTTP/1.1 200 OK
```

## 4.2 Prometheus指标收集

对于minio集群来说Prometheus可以从任意一个minio节点获取整个minio集群的指标，读取指标的url地址`<Address for MinIO Service>/minio/v2/metrics/cluster`

额外的节点特定指标（包括额外的 go 指标或流程指标）在`<Address for MinIO Node>/minio/v2/metrics/node`.

### 1.Prometheus采集指标配置

- 经过身份验证的 Prometheus 配置

MinIO 中的 Prometheus 端点默认需要身份验证。Prometheus 支持不记名令牌方法来验证 prometheus 抓取请求，使用 mc 生成的配置覆盖默认的 Prometheus 配置。要为别名生成 Prometheus 配置，请使用mc如下`mc admin prometheus generate <alias>`。
```
[14:59:19 root@centos7 ~]#mc admin prometheus generate minio
#会自动生成以下内容
scrape_configs:
- job_name: minio-job
  bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ3ODUyODkxNzQsImlzcyI6InByb21ldGhldXMiLCJzdWIiOiJtaW5pbyJ9.YbPxPraBWUaAR2Zpbhr82iw2clL2fzBvdNg1dKhSLBJ3PSBpFjb2riCDAEiApuT4J0gAEGCmTzDa4tyDiAKdvw
  metrics_path: /minio/v2/metrics/cluster
  scheme: http
  static_configs:
  - targets: ['192.168.10.71:9090']
```

- 公共 Prometheus 配置

如果 Prometheus 端点身份验证类型设置为public. 遵循 prometheus 配置足以开始从 MinIO 抓取指标数据。每次收集都可以从任何服务器收集一次。

集群获取指标配置
```
- job_name：minio-job 
  metrics_path：/minio/v2/metrics/cluster
  方案：http 
  static_configs：
  -目标：['本地主机：9000']
```

节点获取指标配置
```
- job_name：minio-job 
  metrics_path：/minio/v2/metrics/node
  方案：http 
  static_configs：
  -目标：['本地主机：9000']
```

### 2.指标详解

| Name | 描述 |
|------|------|
| minio_bucket_objects_size_distribution | 存储桶中对象大小的分布，包括存储桶名称的标签。 |
| minio_bucket_replication_failed_bytes | 至少一次复制失败的总字节数。 |
| minio_bucket_replication_received_bytes | 从另一个源存储桶复制到此存储桶的总字节数。 |
| minio_bucket_replication_sent_bytes | 复制到目标存储桶的总字节数。 |
| minio_bucket_replication_failed_count | 此存储桶的复制操作失败总数。 |
| minio_bucket_usage_object_total | 对象总数 |
| minio_bucket_usage_total_bytes | 总存储桶大小（以字节为单位） |
| minio_cache_hits_total | 磁盘缓存命中总数 |
| minio_cache_missed_total | 磁盘缓存未命中总数 |
| minio_cache_sent_bytes | 从缓存提供的总字节数 |
| minio_cache_total_bytes | 缓存磁盘的总大小（以字节为单位） |
| minio_cache_usage_info | 缓存使用总百分比，值为 1 表示高，0 表示低，标签级别也设置 |
| minio_cache_used_bytes | 当前缓存使用量（以字节为单位） |
| minio_cluster_capacity_raw_free_bytes | 集群中的在线可用总容量。 |
| minio_cluster_capacity_raw_total_bytes | 集群中的在线总容量。 |
| minio_cluster_capacity_usable_free_bytes | 集群中在线可用的总可用容量。 |
| minio_cluster_capacity_usable_total_bytes | 集群中在线的总可用容量。 |
| minio_cluster_nodes_offline_total | 离线的 MinIO 节点总数。 |
| minio_cluster_nodes_online_total | 在线的 MinIO 节点总数。 |
| minio_heal_objects_error_total | 在当前自我修复运行中修复失败的对象 |
| minio_heal_objects_heal_total | 在当前自我修复运行中修复的对象 |
| minio_heal_objects_total | 当前自愈运行中扫描的对象 |
| minio_heal_time_last_activity_nano_seconds | 自上次自我修复活动以来经过的时间（以纳秒为单位）。设置为 -1 直到初始自我修复活动 |
| minio_inter_node_traffic_received_bytes | 从其他对等节点接收的总字节数。 |
| minio_inter_node_traffic_sent_bytes | 发送到其他对等节点的总字节数。 |
| minio_node_ilm_expiry_pending_tasks | 队列中挂起的 ILM 到期任务的当前数量。 |
| minio_node_ilm_transition_active_tasks | 当前活动的 ILM 过渡任务数。 |
| minio_node_ilm_transition_pending_tasks | 队列中当前挂起的 ILM 转换任务数。 |
| minio_node_disk_free_bytes | 磁盘上可用的总存储空间。 |
| minio_node_disk_total_bytes | 磁盘上的总存储量。 |
| minio_node_disk_used_bytes | 磁盘上使用的总存储空间。 |
| minio_node_file_descriptor_limit_total | 限制 MinIO 服务器进程的打开文件描述符总数。 |
| minio_node_file_descriptor_open_total | MinIO 服务器进程打开的文件描述符总数。 |
| minio_node_io_rchar_bytes | 进程从底层存储系统读取的总字节数，包括缓存，/proc/[pid]/io rchar |
| minio_node_io_read_bytes | 进程从底层存储系统读取的总字节数，/proc/[pid]/io read_bytes |
| minio_node_io_wchar_bytes | 进程写入底层存储系统的总字节数，包括页面缓存，/proc/[pid]/io wchar |
| minio_node_io_write_bytes | 进程写入底层存储系统的总字节数，/proc/[pid]/io write_bytes |
| minio_node_process_starttime_seconds | 每个节点的 MinIO 进程的启动时间，自 Unix epoc 以来的秒数。 |
| minio_node_process_uptime_seconds | 每个节点的 MinIO 进程的正常运行时间（以秒为单位）。 |
| minio_node_syscall_read_total | 对内核的总读取 SysCalls。/proc/[pid]/io syscr |
| minio_node_syscall_write_total | 向内核写入 SysCall 的总数。/proc/[pid]/io syscw |
| minio_s3_requests_error_total | 有错误的 S3 请求总数 |
| minio_s3_requests_inflight_total | 当前进行中的 S3 请求总数 |
| minio_s3_requests_total | S3 请求总数 |
| minio_s3_time_ttbf_seconds_distribution | 跨 API 调用分配第一个字节的时间。 |
| minio_s3_traffic_received_bytes | 接收到的 s3 字节总数。 |
| minio_s3_traffic_sent_bytes | 发送的 s3 字节总数 |
| minio_software_commit_info | MinIO 版本的 Git 提交哈希。 |
| minio_software_version_info | 服务器的 MinIO 发布标签 |

## 4.3 grafana模板

集群监控模板地址：https://grafana.com/grafana/dashboards/13502

# 五、minio联邦集群

从DNS联合查找存储桶需要两个依赖项
- etcd (用于存储桶DNS服务记录)
- CoreDNS (用于基于填充的桶式DNS服务记录的DNS管理，可选)

即通过引入etcd，将多个MinIO分布式集群在逻辑上组成一个联邦，对外以一个整体提供服务，并提供统一的命名空间。MinIO联邦集群的架构如图所示。



其中，etcd是一个开源的分布式键值存储数据库，在联邦中用于记录存储桶IP地址。联邦内的各个集群其数据存储以及一致性维护仍由各集群自行管理，联邦只是对外提供一个整体逻辑视图。通过连接到联邦中任一集群的任一节点，可以查询并访问联邦内所有集群的全部数据，由此获得了逻辑上的空间扩大感。但实际上，对于一个外部应用访问，联邦需依赖etcd定位到存储桶的实际存储节点，再进行数据访问，联邦则对外屏蔽了桶IP查找和定位过程，从而在逻辑上对外形成了一个统一整体。因此，etcd实际上起到了类似路由寻址的效果。

## 5.1 相关的环境变量

### 1.MINIO_ETCD_ENDPOINTS
这是您要用作MinIO联合后端的etcd服务器的逗号分隔列表。 在整个联合部署中，这应该是相同的，即联合部署中的所有MinIO实例都应使用相同的 etcd后端。

### 2.MINIO_DOMAIN
这是用于联合设置的顶级域名。理想情况下，该域名应解析为在所有联合MinIO实例之前运行的负载均衡器。域名用于创建etcd的子域条目。对于例如，如果域名设置为 `domain.com`，水桶 `bucket1`，`bucket2` 将作为访问`bucket1.domain.com` 和 `bucket2.domain.com`。

### 3.MINIO_PUBLIC_IPS
这是用逗号分隔的IP地址列表，此MinIO实例上创建的存储桶将解析为这些IP地址。例如， 可以 `bucket1` 在上访问在当前MinIO实例上创建的存储区 `bucket1.domain.com`，并且的DNS条目 `bucket1.domain.com` 将指向中设置的IP地址`MINIO_PUBLIC_IPS`。

注意
- 对于独立和擦除代码MinIO服务器部署，此字段是必需的，以启用联合模式。
- 对于分布式部署，此字段是可选的。如果您未在联合设置中设置此字段，我们将使用传递给MinIO服务器启动的主机的IP地址，并将其用于DNS条目。

## 5.2 部署过程

### 5.2.1 部署etcd

etcd启动service文件

我这里的etcd不加密，由于minio官方没有提供加密连接etcd的配置参数所以，etcd不加密
```
[10:11:27 root@centos7 ~]#cat /etc/systemd/system/etcd.service 
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/bin/etcd \
  --name etcd-0 \
  --initial-advertise-peer-urls http://192.168.10.72:2380 \
  --listen-peer-urls http://192.168.10.72:2380 \
  --listen-client-urls http://192.168.10.72:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.10.72:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster etcd-0=http://192.168.10.72:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 5.2.2 部署minio集群

**集群1配置 **

启动的service与之前的一致
```
[10:23:46 root@centos7 ~]#cat /etc/default/minio.conf
MINIO_ROOT_USER=minio
MINIO_ROOT_PASSWORD=minio123
MINIO_PROMETHEUS_AUTH_TYPE="public"
MINIO_VOLUMES="http://minio1:9000/data/minio{1...4}"
MINIO_OPTS='--console-address :9001'
MINIO_ETCD_ENDPOINTS="http://192.168.10.72:2379"   #etcd地址，集群的话可以写多个
MINIO_PUBLIC_IPS=192.168.10.71                     #集群1所有节点的IP地址
MINIO_DOMAIN=domain.com                            #联邦集群的域名后缀，同一个联邦集群域名后缀需一致
```
集群2配置
```
[10:23:46 root@centos7 ~]#cat /etc/default/minio.conf 
MINIO_ROOT_USER=minio
MINIO_ROOT_PASSWORD=minio123
MINIO_PROMETHEUS_AUTH_TYPE="public"
MINIO_VOLUMES="http://minio1:9000/data/minio{1...4}"
MINIO_OPTS='--console-address :9001'
MINIO_ETCD_ENDPOINTS="http://192.168.10.72:2379"
MINIO_PUBLIC_IPS=192.168.10.72
MINIO_DOMAIN=domain.com
```

service文件
```
[10:24:43 root@centos7 ~]#cat /etc/systemd/system/minio.service 
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-noline.target
After=network-noline.target

[Service]
WorkingDirectory=/usr/local/minio
User=root
Group=root
EnvironmentFile=-/etc/default/minio.conf
ExecStart=/usr/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always

[Install]
WantedBy=multi-user.target
```

## 5.3 启动minio服务验证

启动minio服务后，etcd集群中会写入一条数据
```
[10:29:05 root@centos7 ~]#etcdctl get / --from-key
config/iam/format.json
{"version":1}
```
之后在不管那个集群节点创建存储桶，minio都会在etcd记录一条路由地址，这个路由地址配合CoreDNS可以实现直接解析dns的方式路由到存储桶所在的minio集群
```
[10:33:08 root@centos7 ~]#mc mb minio1/test1
Bucket created successfully `minio1/test1`.
[10:33:29 root@centos7 ~]#mc mb minio2/test2
Bucket created successfully `minio2/test2`.

#etcd验证
[10:29:08 root@centos7 ~]#etcdctl get / --from-key
/skydns/com/domain/test1/192.168.10.71
{"host":"192.168.10.71","port":9000,"ttl":30,"creationDate":"2021-09-24T02:33:21.562683472Z"}
/skydns/com/domain/test2/192.168.10.72
{"host":"192.168.10.72","port":9000,"ttl":30,"creationDate":"2021-09-24T02:33:34.595317355Z"}
config/iam/format.json
{"version":1}
```
联邦集群中每个集群都是相对独立的，只不过minio通过etcd把每个集群逻辑上组成一个集群，但是在任何一个节点读取其他节点的数据都是可以的，但是创建存储桶需要提前规划创建在联邦集群的那个集群节点，一旦确定这个存储桶创建在这个集群节点，其他集群节点就无法创建了。

## 5.4 使用CoreDNS（可选）

官方地址：https://coredns.io

**二进制部署coreDNS**

**准备配置文件**
```
[10:42:23 root@centos7 ~]#cat /etc/coredns/Corefile 
.:53 {    
    etcd {                              #这里表示使用etcd插件
        fallthrough                     #如果这个区域无法解析，则将请求传递给下一个区域
        stubzones 
        path /skydns                    #etcd中路径，默认/skydns
        endpoint http://localhost:2379  #etcd访问地址
    }
    forward . 114.114.114.114:53        #上面无法处理的请求会传到这里
    prometheus                          #监控开启
    loadbalance                         #该LOADBALANCE将通过在回答随机的A，AAAA和MX记录的顺序作为一个循环DNS负载均衡 
    log                                 #开启日志
}
```

**准备service文件**
```
[10:57:22 root@centos7 ~]#cat /etc/systemd/system/coredns.service 
[Unit]                                                                                                                                                                                                            
Description=coredns
Documentation=https://coredns.io
Wants=network-noline.target
After=network-noline.target

[Service]
WorkingDirectory=/usr/local/coredns
User=root
Group=root
ExecStart=/usr/bin/coredns -conf /etc/coredns/Corefile
Restart=always

[Install]
WantedBy=multi-user.target
```

**验证**

设置主机dns验证
```
[10:58:50 root@centos7 ~]#dig +shor test1.domain.com
192.168.10.71
[10:59:04 root@centos7 ~]#dig +shor test2.domain.com
192.168.10.72
```
