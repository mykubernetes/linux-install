下载当前最新release版本redis 源码包：http://download.redis.io/releases/

# 1、编译安装

官方的安装方法：
```
https://redis.io/download
```

范例: 编译安装过程
```
#安装依赖包
[root@centos7 ~]#yum -y install gcc jemalloc-devel

#下载源码
[root@centos7 ~]#wget http://download.redis.io/releases/redis-5.0.7.tar.gz
[root@centos7 ~]#tar xvf redis-5.0.7.tar.gz

#编译安装
[root@centos7 ~]#cd redis-5.0.7/
[root@centos7 redis-5.0.7]#make PREFIX=/apps/redis install #指定redis安装目录

#配置变量
[root@centos7 ~]#echo 'PATH=/apps/redis/bin:$PATH' > /etc/profile.d/redis.sh
[root@centos7 ~]#. /etc/profile.d/redis.sh

#目录结构
[root@centos7 ~]#tree /apps/redis/
/apps/redis/
└── bin
   ├── redis-benchmark
   ├── redis-check-aof
   ├── redis-check-rdb
   ├── redis-cli
   ├── redis-sentinel -> redis-server
   └── redis-server
1 directory, 6 files

#准备相关目录和配置文件
[root@centos7 ~]#mkdir /apps/redis/{etc,log,data,run} #创建配置文件、日志、数据等目录
[root@centos7 redis-5.0.7]#cp redis.conf /apps/redis/etc/
```

bin下文件说明：
- redis-server redis服务器启动命令
- redis-cli redis命令行客户端
- redis-benchmark redis性能测试工具
- redis-check-aof AOF文件修复工具
- redis-check-rdb RDB文件检索工具（快照持久化文件）

# 2、前台启动 redis

redis-server 是 redis 服务器程序
```
[root@centos7 ~]#redis-server --help
Usage: ./redis-server [/path/to/redis.conf] [options]
       ./redis-server - (read config from stdin)
       ./redis-server -v or --version
       ./redis-server -h or --help
       ./redis-server --test-memory <megabytes>
Examples:
       ./redis-server (run the server with default conf)
       ./redis-server /etc/redis/6379.conf
       ./redis-server --port 7777
       ./redis-server --port 7777 --slaveof 127.0.0.1 8888
       ./redis-server /etc/myredis.conf --loglevel verbose
Sentinel mode:
       ./redis-server /etc/sentinel.conf --sentinel
```

前台启动 redis
```
[root@centos7 ~]#redis-server /apps/redis/etc/redis.conf 
27569:C 16 Feb 2020 21:18:20.412 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
27569:C 16 Feb 2020 21:18:20.412 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=27569, just started
27569:C 16 Feb 2020 21:18:20.412 # Configuration loaded
27569:M 16 Feb 2020 21:18:20.413 * Increased maximum number of open files to 
10032 (it was originally set to 1024).
              _._                                                  
          _.-``__ ''-._                                             
     _.-``    `. `_.  ''-._           Redis 5.0.7 (00000000/0) 64 bit
 .-`` .-```. ```\/   _.,_ ''-._                                   
 (    '      ,      .-` | `,   )      Running in standalone mode
 |`-._`-...-`__...-.``-._|'`_.-'|     Port: 6379
 |    `-._   `._   /     _.-'   |     PID: 27569
  `-._   `-._  `-./ _.-'   _.-'                                   
 |`-._`-._     `-.__.-' _.-'_.-'|                                  
 |    `-._`-._       _.-'_.-'   |           http://redis.io        
  `-._   `-._`-.__.-'_.-'   _.-'                                   
 |`-._`-._   `-.__.-'   _.-'_.-'|                                  
 |    `-._`-._       _.-'_.-'   |                                  
  `-._   `-._`-.__.-'_.-'   _.-'                                   
      `-._   `-.__.-'   _.-'                                       
          `-._       _.-'                                           
              `-.__.-'                                               
27569:M 16 Feb 2020 21:18:20.414 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
27569:M 16 Feb 2020 21:18:20.414 # Server initialized
27569:M 16 Feb 2020 21:18:20.414 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
27569:M 16 Feb 2020 21:18:20.414 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
27569:M 16 Feb 2020 21:18:20.414 * Ready to accept connections

[root@centos7 ~]#ss -ntl
State     Recv-Q Send-Q Local Address:Port  Peer Address:Port 
LISTEN     0      100         127.0.0.1:25                *:*           
LISTEN     0      128       127.0.0.1:6379                *:*   
LISTEN     0      128                 *:22                *:*   
LISTEN     0      100             [::1]:25             [::]:*   
LISTEN     0      128              [::]:22             [::]:* 
```

范例: 开启 redis 多实例
```
[root@centos7 ~]#redis-server --port 6380

[root@centos7 ~]#ss -ntl
State     Recv-Q Send-Q Local Address:Port   Peer Address:Port              
LISTEN    0      511               *:6379                *:*
LISTEN    0      511               *:6380                *:*
LISTEN    0      128                 *:22                *:*
LISTEN    0      100         127.0.0.1:25                *:*
LISTEN    0      511            [::]:6380             [::]:*
LISTEN    0      128              [::]:22             [::]:*
LISTEN    0      100             [::1]:25             [::]:*

[root@centos7 ~]#ps -ef|grep redis
redis      4407      1  0 10:56 ?        00:00:01 /apps/redis/bin/redis-server 0.0.0.0:6379
root       4451    963  0 11:05 pts/0    00:00:00 redis-server *:6380
root       4484   4455  0 11:09 pts/1    00:00:00 grep --color=auto redis

[root@centos7 ~]#redis-cli -p 6380
127.0.0.1:6380> 
```

# 3、解决启动时的三个警告提示

1）tcp-backlog
```
WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
```
- backlog参数控制的是三次握手的时候server端收到client ack确认号之后的队列值，即全连接队列

范例: 
```
#vim /etc/sysctl.conf
net.core.somaxconn = 1024
#sysctl -p 
```

2) vm.overcommit_memory
```
WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
```
内核参数说明:
- 0、表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
- 1、表示内核允许分配所有的物理内存，而不管当前的内存状态如何
- 2、表示内核允许分配超过所有物理内存和交换空间总和的内存

范例: 
```
#vim /etc/sysctl.conf
vm.overcommit_memory = 1
#sysctl -p 
```

3) transparent hugepage
```
WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
警告：您在内核中启用了透明大页面（THP,不同于一般内存页的4k为2M）支持。 这将在Redis中造成延迟和内存使用问题。 要解决此问题，请以root 用户身份运行命令“echo never> /sys/kernel/mm/transparent_hugepage/enabled”，并将其添加到您的/etc/rc.local中，以便在重启后保留设置。禁用THP后，必须重新启动Redis。
```

范例: 
```
[root@centos7 ~]#echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local 
[root@centos7 ~]#cat /etc/rc.d/rc.local
#!/bin/bash
# THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
#
# It is highly advisable to create own systemd services or udev rules
# to run scripts during boot instead of using this file.
#
# In contrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.

touch /var/lock/subsys/local
echo never > /sys/kernel/mm/transparent_hugepage/enabled

[root@centos7 ~]#chmod +x /etc/rc.d/rc.local
```

4) 再次启动 redis
- 将以上配置同步到其他redis 服务器
```
[root@centos7 ~]#redis-server /apps/redis/etc/redis.conf 
27646:C 16 Feb 2020 21:26:52.690 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
27646:C 16 Feb 2020 21:26:52.690 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=27646, just started
27646:C 16 Feb 2020 21:26:52.690 # Configuration loaded
27646:M 16 Feb 2020 21:26:52.690 * Increased maximum number of open files to 10032 (it was originally set to 1024).
               _._                                                  
         _.-``__ ''-._                                             
    _.-``    `. `_.  ''-._            Redis 5.0.7 (00000000/0) 64 bit
 .-`` .-```. ```\/   _.,_ ''-._                                   
 (    '     ,       .-` | `,   )      Running in standalone mode
 |`-._`-...-`__...-.``-._|'`_.-'|     Port: 6379
 |    `-._   `._   /     _.-'   |     PID: 27646
  `-._   `-._  `-./ _.-'   _.-'                                   
 |`-._`-._    `-.__.-'  _.-'_.-'|                                  
 |    `-._`-._       _.-'_.-'   |           http://redis.io        
  `-._   `-._`-.__.-'_.-'   _.-'                                   
 |`-._`-._    `-.__.-'   _.-'_.-'|                                  
 |    `-._`-._       _.-'_.-'   |                                  
  `-._   `-._`-.__.-'_.-'   _.-'                                   
      `-._   `-.__.-'   _.-'                                       
          `-._       _.-'                                           
              `-.__.-'                                               
27646:M 16 Feb 2020 21:26:52.691 # Server initialized
27646:M 16 Feb 2020 21:26:52.692 * DB loaded from disk: 0.000 seconds
27646:M 16 Feb 2020 21:26:52.692 * Ready to accept connections
```

# 4、创建 redis 用户和数据目录
```
[root@centos7 ~]#useradd -r -s /sbin/nologin redis

#设置目录权限
[root@centos7 ~]#chown -R redis.redis /apps/redis/  
```

# 5、编辑 redis 服务启动文件
```
#复制CentOS8安装生成的redis.service文件，进行修改
[root@centos7 ~]#scp 10.0.0.8:/lib/systemd/system/redis.service /lib/systemd/system/
[root@centos7 ~]#vim /usr/lib/systemd/system/redis.service

[root@centos7 ~]#cat /usr/lib/systemd/system/redis.service
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
ExecStart=/apps/redis/bin/redis-server /apps/redis/etc/redis.conf --supervised systemd
ExecStop=/bin/kill -s QUIT $MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
```

# 6、验证 redis 启动
```
[root@centos7 ~]# systemctl daemon-reload
[root@centos7 ~]# systemctl enable redis.service
[root@centos7 ~]# systemctl start redis

[root@centos7 ~]# systemctl status redis
● redis.service - Redis persistent key-value database
   Loaded: loaded (/usr/lib/systemd/system/redis.service; enabled; vendor preset: 
disabled)
   Active: active (running) since Sun 2020-02-16 23:08:08 CST; 2s ago
 Process: 1667 ExecStop=/bin/kill -s QUIT $MAINPID (code=exited, 
status=0/SUCCESS)
 Main PID: 1669 (redis-server)
   CGroup: /system.slice/redis.service
           └─1669 /apps/redis/bin/redis-server 127.0.0.1:6379
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: |`-._`-._`-.__.-' _.-'_.-'|
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: |`-._`-.__.-'_.-'|
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: `-._`-._`-.__.-'_.-'_.-'
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: `-._`-.__.-'_.-'
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: `-.__.-'
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: `-.__.-'
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: 1669:M 16 Feb 202023:08:08.931 # Server ini...ed
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: 1669:M 16 Feb 202023:08:08.931 * DB loaded ...ds
Feb 16 23:08:08 centos7.wangxiaochun.com redis-server[1669]: 1669:M 16 Feb 202023:08:08.931 * Ready to a...ns
Feb 16 23:08:08 centos7.wangxiaochun.com systemd[1]: Started Redis persistent key-value database.
Hint: Some lines were ellipsized, use -l to show in full.

#ss -ntl
State     Recv-Q Send-Q     Local Address:Port               Peer Address:Port 
LISTEN     0      100             127.0.0.1:25                             *:*   
LISTEN     0      511           127.0.0.1:6379                             *:*   
LISTEN     0      128                     *:22                             *:*   
LISTEN     0      100                 [::1]:25                          [::]:*   
LISTEN     0      128                  [::]:22                          [::]:* 
```

# 7、服务操作命令
```
systemctl start redis.service    #启动redis服务
systemctl stop redis.service     #停止redis服务
systemctl restart redis.service  #重新启动服务
systemctl status redis.service   #查看服务当前状态
systemctl enable redis.service   #设置开机自启动
systemctl disable redis.service  #停止开机自启动
```
