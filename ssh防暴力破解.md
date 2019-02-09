ssh防暴力破解
============
通过开源的防护软件来防护安全  
官方地址：  
http://www.fail2ban.org  
下载地址  
http://www.fail2ban.org/wiki/index.php/Downloads  
一、安装 
```
# tar xf fail2ban-0.8.14.tar.gz -C /usr/local/
# cd /usr/local/fail2ban-0.8.14
# python -V
  Python 2.6.6
# python setup.py install
```  

二、生成服务启动脚本：
```
# cp /usr/local/fail2ban-0.8.14/files/redhat-initd /etc/rc.d/init.d/fail2ban
# chkconfig --add fail2ban  #开机自动启动
```  

三、修改配置文件（在第94行）
```
# vim /etc/fail2ban/jail.conf
  [DEFAULT]                     #全局设置
  ignoreip = 127.0.0.1/8        #忽略的IP列表,不受设置限制
  bantime  = 600                #屏蔽时间，单位：秒
  findtime  = 600               #这个时间段内超过规定次数会被ban掉
  maxretry = 3                  #最大尝试次数
  backend = auto                #日志修改检测机制（gamin、polling和auto这三种）

  [ssh-iptables]          
  enabled  = true             
  filter   = sshd               
  action   = iptables[name=SSH, port=宿主机端口号, protocol=tcp]
             sendmail-whois[name=SSH, dest=you@example.com, sender=fail2ban@example.com, sendername="Fail2Ban"]
  logpath  = /var/log/secure    #检测的系统的登陆日志文件。这里要写sshd服务日志文件。
  bantime  = 3600               #禁止用户IP访问主机1小时
  findtime  = 300               #在5分钟内内出现规定次数就开始工作
  maxretry = 3                  #3次密码验证失败

# vim /etc/fail2ban/action.d/iptables.conf
  port=宿主机端口号
```

四、启动服务：  
```
# systemctl start fail2ban 
# systemctl enable fail2ban 
```  

五、查看状态  
```
# fail2ban-client status
# fail2ban-client status ssh-iptables
Status for the jail: ssh-iptables
|- filter
|  |- File list:	/var/log/secure 
|  |- Currently failed:	0
|  `- Total failed:	3
`- action
   |- Currently banned:	1
   |  `- IP list:	192.168.1.103 
   `- Total banned:	1
```  

六、查看fail2ban的日志能够看到相关的信息  
```
# tail /var/log/fail2ban.log
2019-02-03 19:43:59,233 fail2ban.actions[12132]: WARNING [ssh-iptables] Ban 192.168.1.103
```  

