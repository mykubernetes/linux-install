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
