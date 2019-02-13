redis安装  
=========
1、配置yum源  
``` yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm ```  
2、安装  
``` yum --enablerepo=remi install redis ```  
3、配置文件  
```
vim /etc/redis.conf
daemonize no  
port 6379                               #端口号
bind 127.0.0.1                		#监听地址
timeout 0                    		#0表示不启用此功能
tcp-keepalive 0                 	#定义是否启用tcp-keepalive功能
loglevel notice            		#定义日志级别
logfile /var/log/redis/redis.log 	#定义日志文件
databases 16         			#定义redis默认有多少个databases，但是在分布式中，只能使用一个

#### SNAPSHOTTING  ####        		#定义RDB的持久化相关
save <seconds> <changes>          	#使用save指令，并指定每隔多少秒，如果发生多大变化，进行存储
save 900 1                     		#表示在900秒（15分钟内），如果至少有1个键发生改变，则做一次快照（持久化）
save 300 10                		#表示在300秒（5分钟内），如果至少有10个键发生改变，则做一次快照（持久化）
save 60 10000                 		#表示在60秒（1分钟内），如果至少有10000个键发生改变，则做一次快照（持久化）
save ""                          	#如果redis中的数据不需做持久化，只是作为缓存，则可以使用此方式关闭持久化功能

######## REPLICATION #######     	#配置主从相关
# slaveof <masterip> <masterport>	#此项不启用时，则为主，如果启动则为从，但是需要指明主服务器的IP，端口
# masterauth <master-password>    	#如果主服务设置了密码认证，那么从的则需要启用此项并指明主的认证密码
slave-read-only yes          		#定义从服务对主服务是否为只读（仅复制）

##### LIMITS #####           		#定义与连接和资源限制相关的配置
# maxclients 10000  			#定义最大连接限制（并发数）
# maxmemory <bytes>              	#定义使用主机上的最大内存，默认此项关闭，表示最大将使用主机上的最大可用内存

###### APPEND ONLY MODE #######  	#定义AOF的持久化功能相关配置，一旦有某一个键发生变化，将修改键的命令附加到命令列表的文件中
appendonly no                  		#定义是否开启此功能，no表示关闭，yes表示开启
                                    	说明：RDB和AOF两种持久功能可以同时启用，两者不影响
```  
4、密码配置  
```
# vim /etc/redis.conf
  requirepass 123456    
# systemctl restart redis
# redis-cli
  127.0.0.1:6379> auth  123456
  OK
或者 redis-cli -a 123456  启动直接输入密码
```  

命令行工具
```
切换库（名称空间）：
	127.0.0.1:6379> select 1        #表示切换到1号库中，默认为0号库，共16个，0-15
	OK
	127.0.0.1:6379[1]>              #表示已经切换数据库

添加和获取
  127.0.0.1:6379> set cjk lzll
  OK
  127.0.0.1:6379> get cjk
  "lzll"
  
定义一个键并设置过期时间为60秒
  127.0.0.1:6379> set fda abc EX 60
  OK

