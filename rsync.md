官网
https://rsync.samba.org/  

sync和scp的区别
---
Remote Sync ：简称rsync，是一种远程同步，高效的数据备份的工具。第一次备份完全备份，以后备份就是差异备份。

scp：secure copy 同样是用来进行远程复制的命令，但是每次备份数据都是完全备份

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

2、服务器端配置  
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

3、配置密码文件
```
# vim /etc/server.pass 
root:123456
```

启动  
```
# rsync --daemon
# ps -ef |grep rsync
root      57769      1  1 06:19 ?        00:00:00 rsync --daemon
```  

4、客户端配置  

```
# rsync -vzrtopg --delete --progress root@192.168.101.69::/ixdba /ixdba.net --password-file=/etc/server.pass
# rsync -avzPL --timeout=600  root@192.168.101.69::/ixdba /test
```
- -vzrtopg 详细信息
- -z 传输时压缩
- -r 对子目录以递归式处理
- -v 同步时显示一些信息
- -P 显示同步过程，比如速率，比-v更加详细
- -t 保持文件时间信息
- -o 保持文件属主信息
- -g 保持文件属组信息
- -p 保持文件权限信息
- -L 同步软链接时会把源文件给同步
- --delete 选项指定以rsync服务端为基准进行数据镜像同步
- ----progress 显示数据进行同步过程
- - backup@192.168.101.69::ixdba 用户@rsync_IP::rsync_模块
- - /ixdba.net 用于指定备份文件在客户端的目录
- --password-file=/etc/server.pass 用于指定客户端存放的密码文件位置
- -c 打开效验开关，强制对文件传输进行效验
- -a 归档模式，以归档方式传输，并保持所有文件属性
  - -a 包含-rtplgoD
  
手动命令方式
```
#推文件
# rsync -av /etc/passwd 192.168.101.70:/tmp/cc.txt

#拉文件
# rsync -avP 192.168.101.70:/tmp/cc.txt /tmp/123.txt

#指定端口号
# rsync -avzP -e "ssh -p 22" /etc/passwd 192.168.101.70:/tmp/cc.txt
```
