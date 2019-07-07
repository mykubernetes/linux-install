1、安装atlas  
```
# wget https://github.com/Qihoo360/Atlas/releases/download/2.2.1/Atlas-2.2.1.el6.x86_64.rpm
# rpm -ivh Atlas-2.2.1.el6.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:Atlas-2.2.1-1                    ################################# [100%]
```  

2、编辑配置文件  
```
#进入Atlas工具目录
# cd /usr/local/mysql-proxy/bin/

#生成密码
# ./encrypt 123456

#修改Atlas配置文件
# vim /usr/local/mysql-proxy/conf/test.cnf
proxy-backend-addresses = 10.0.0.51:3306       #Atlas后端连接的MySQL主库的IP和端口，可设置多项，用逗号分隔，可填写vip
proxy-read-only-backend-addresses = 10.0.0.52:3306,10.0.0.53:3306    #Atlas后端连接的MySQL从库的IP和端口
pwds = root:1N/CNLSgqXuTZ6zxvGQr9A==           #用户名与其对应的加密过的MySQL密码，填写./encrypt 123456后生成的密码
sql-log = ON                                   #SQL日志的开关
proxy-address = 0.0.0.0:3307                   #Atlas监听的工作接口IP和端口
charset = utf8                                 #默认字符集，设置该项后客户端不再需要执行SET NAMES语句
```  

3、启动
```
# /usr/local/mysql-proxy/bin/mysql-proxyd test start
OK: MySQL-Proxy of test is started
```  

4、Atlas管理操作  
```
#用atlas管理用户登录
# mysql -uuser -ppwd -h127.0.0.1 -P2345
#查看可用命令帮助
mysql> select * from help;
#查看后端代理的库
mysql> SELECT * FROM backends;
+-------------+----------------+-------+------+
| backend_ndx | address        | state | type |
+-------------+----------------+-------+------+
|           1 | 10.0.0.51:3307 | up    | rw   |
|           2 | 10.0.0.53:3307 | up    | ro   |
|           3 | 10.0.0.52:3307 | up    | ro   |
+-------------+----------------+-------+------+
#平滑摘除mysql
mysql> REMOVE BACKEND 2;
Empty set (0.00 sec)
#检查是否摘除成功
mysql> SELECT * FROM backends;
+-------------+----------------+-------+------+
| backend_ndx | address        | state | type |
+-------------+----------------+-------+------+
|           1 | 10.0.0.51:3307 | up    | rw   |
|           2 | 10.0.0.52:3307 | up    | ro   |
+-------------+----------------+-------+------+
#保存到配置文件中
mysql> SAVE CONFIG;
Empty set (0.06 sec)
```  
