DDoS deflate 防止DDOS攻击
=========================
1、下载软件  
```
wget http://www.inetbase.com/scripts/ddos/install.sh
# chmod 700 install.sh
#./install.sh
```  
2、配置文件  
```
# vim /usr/local/ddos/ddos.conf 
PROGDIR="/usr/local/ddos"
PROG="/usr/local/ddos/ddos.sh"                   #要执行的DDOS脚本
IGNORE_IP_LIST="/usr/local/ddos/ignore.ip.list"  #IP地址白名单，注：在这个文件中IP不受控制。
CRON="/etc/cron.d/ddos.cron"                     #定时执行程序
FREQ=1                                           #检查区间间隔
NO_OF_CONNECTIONS=150                            #限制IP个数
APF_BAN=0                                        #1为屏蔽IP,0为使用iptables
BAN_PERIOD=600                                   #禁止时间以秒为单位默认10分钟
```  
3、周期性任务计划  
```
cat  /etc/cron.d/ddos.cron 
SHELL=/bin/sh
0-59/1 * * * * root /usr/local/ddos/ddos.sh >/dev/null 2>&1
```  
4、无需重启进程  

5、测试  
```
# ab -n 1000 -c 10 http://192.168.1.1/index.html
# iptables -L -n
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
DROP       all  --  192.168.1.64         0.0.0.0/0 
```  
测试需要等待一分钟才能生效，因为crontab一分钟执行一次  
6、卸载  
```
# wget http://www.inetbase.com/scripts/ddos/uninstall.ddos
# chmod +x uninstall.ddos 
# ./uninstall.ddos
```  
注意：在卸载之前所被该程序拒绝访问的iptables的规则，不会自动清除  

 
