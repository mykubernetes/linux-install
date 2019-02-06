一、日志服务端配置：  
rsyslog的软件包查看  
``` rpm -qa | grep rsyslog ```
``` rsyslog-5.8.10-6.el6.x86_64  ##默认系统已经安装 ```
修改rsyslog配置文件以下内容，去掉#  
```
# vim /etc/rsyslog.conf
$ModLoad imudp  #加载udp的模块
$UDPServerRun 514 #允许接收udp 514的端口传来的日志

$ModLoad imtcp   #加载tcp的模块
$InputTCPServerRun 514
```  
日志服务器安装数据库服务；  
``` # yum install mysql mysql-server ```  

启动mysql服务：  
```
# chkconfig mysqld on
# service mysqld start
```  
日志服务器安装mysql模块：  
``` # yum install rsyslog-mysql ```  
``` cp /usr/share/doc/rsyslog-mysql-5.8.10/createDB.sql /root ```  

登录数据库  
``` mysql ```  
导入mysql表  
``` mysql>source /root/createDB.sql ```

授权rsyslog用户  
```
mysql> GRANT ALL ON Syslog.* to  admin@'192.168.146.%' IDENTIFIED BY 'admin';
mysql> GRANT ALL ON Syslog.* TO admin@'localhost' IDENTIFIED BY 'ctyun.cn';

mysql> FLUSH PRIVILEGES;
```  
编辑日志服务器配置文件添加ommysql模块，日志信息指向数据库服务器，重启服务：  
```
# vim /etc/rsyslog.conf
$ModLoad ommysql
*.info;mail.none;authpriv.none;cron.none    :ommysql:localhost,Syslog,admin,admin
#记录的日志信息                        #数据库IP、 数据库、账号、密码 
#service rsyslog restart
```  
配置php、apache  
```
# yum install httpd php php-mysql
vim /etc/httpd/conf/httpd.conf  ##添加配置

NameVirtualHost *:8008

<VirtualHost ServerIP:8008>
    DocumentRoot /var/www/html/log
    ServerName ServerIP:8008
</VirtualHost>
```  

二、配置loganalyzer  
```
# tar xf loganalyzer-3.6.6.tar.gz
# mkdir -p /var/www/html/log
# cp -a loganalyzer-3.6.6/src/*/var/www/html/log/
# cp -a loganalyzer-3.6.6/contrib/*/var/www/html/log/
# cd /var/www/html/log/
# chmod +x configure.sh secure.sh
# ./configure.sh              
# ./secure.sh             ##和上面的脚步生成config文件
# chmod 666 config.php    ###config要有设置写入权限
# chown -R apache:apache ./*
启动服务：
# chkconfig httpd on
# service httpd start
```  
三、客户端配置  
修改rsyslog配置文件  
```
# vim /etc/rsyslog.conf
*.info;mail.none;authpriv.none;cron.none    @server_ip  ###此处可定义日志类型
```  
配置loganalyzer web界面  
1、
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer1.png)
2、
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer2.png)
3、
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer3.png)
4、
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer4.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer5.png)
5、一直下一步，直到配置日志分析系统管理账户（后期使用）
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer6.png)
6、
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer7.png)
7、
![image](https://github.com/mykubernetes/linux-install/blob/master/image/loganalyzer8.png)

