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
BAN_PERIOD=600                                   #禁止时间
```  
3、周期性任务计划  
```
cat  /etc/cron.d/ddos.cron 
SHELL=/bin/sh
0-59/1 * * * * root /usr/local/ddos/ddos.sh >/dev/null 2>&1
```  
