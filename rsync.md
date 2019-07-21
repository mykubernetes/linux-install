官网
https://rsync.samba.org/  

1、安装  
```
yum install gcc -y
wget https://download.samba.org/pub/rsync/rsync-3.1.3.tar.gz
tar xvf rsync-3.1.3.tar.gz
cd rsync-3.1.3
./configure
make 
make install
```  

2、配置  
```
# vim /etc/rsyncd.conf 
 uid = nobody
 gid = nobody
 use chroot = no
 max connections = 10
 pid file = /var/run/rsyncd.pid
 lock file = /var/run/rsync.lock
 log file = /var/log/rsync.log

 [ixdba]
 path = /webdata
 comment = ixdba file
 ignore errors
 read only = true
 list = false
 uid = root
 gid = root
 auth user = backup
 secrets file = /etc/server.pass
```  

启动  
```
# rsync --daemon
# ps -ef |grep rsync
root      57769      1  1 06:19 ?        00:00:00 rsync --daemon
```  

客户端配置  
```
rsync --delete --progress backup@192.168.101.69::ixdba/ixdba.net --password-file=/etc/server.pass -v
```
- -v 详细信息
- -z 对备份文件进行压缩
- -r 对子目录以递归式处理
- -t 保持文件时间信息
- -o 保持文件属主信息
- -g 保持文件属组信息
- -p 保持文件权限信息
