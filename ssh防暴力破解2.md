ssh防暴力破解
=============  
DenyHosts官方网站为：http://denyhosts.sourceforge.net  
1. 安装DenyHosts  
```
wget "downloads.sourceforge.net/project/denyhosts/denyhosts/2.6/DenyHosts-2.6.tar.gz"
tar -xzf DenyHosts-2.6.tar.gz 
cd DenyHosts-2.6
python setup.py install
```  
DenyHosts默认安装到/usr/share/denyhosts目录  

2.配置  
```
# cd /usr/share/denyhosts/
# cp denyhosts.cfg-dist denyhosts.cfg
# vim denyhosts.cfg
  PURGE_DENY = 1h                          #过多久后清除已阻止IP
  HOSTS_DENY = /etc/hosts.deny             #将阻止IP写入到hosts.deny
  BLOCK_SERVICE = sshd                     #阻止服务名
  DENY_THRESHOLD_INVALID = 1               #允许无效用户登录失败的次数
  DENY_THRESHOLD_VALID = 10                #允许普通用户登录失败的次数
  DENY_THRESHOLD_ROOT = 5                  #允许root登录失败的次数
  WORK_DIR = /usr/share/denyhosts/data     #将deny的host或ip纪录到Work_dir中
  DENY_THRESHOLD_RESTRICTED = 1            #设定 deny host 写入到该资料夹
  LOCK_FILE = /var/lock/subsys/denyhosts   #将DenyHOts启动的pid纪录到LOCK_FILE中，已确保服务正确启动，防止同时启动多个服务。
  HOSTNAME_LOOKUP=NO                       #是否做域名反解
  ADMIN_EMAIL =                            #设置管理员邮件地址
  DAEMON_LOG = /var/log/denyhosts          #自己的日志文件
  DAEMON_PURGE = 1h                        #该项与PURGE_DENY 设置成一样，也是清除hosts.deniedssh 用户的时间
```  

3.设置启动脚本  
```
# cp daemon-control-dist daemon-control
# ln -s /usr/share/denyhosts/daemon-control /etc/init.d/denyhosts
# chkconfig --add denyhosts
  chkconfig denyhosts on
# service denyhosts start
```  
4.查看屏蔽IP  
```
# cat /etc/hosts.deny
# DenyHosts: Mon Mar  7 16:04:00 2016 | sshd: 123.30.135.177
sshd: 123.30.135.177
# DenyHosts: Mon Mar  7 16:25:31 2016 | sshd: 125.88.177.95
sshd: 125.88.177.95
```
