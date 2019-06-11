redis安装  
=========
1、下载  
``` # wget 'http://download.redis.io/releases/redis-4.0.9.tar.gz' ```  
2、安装开发者工具  
``` # yum install -y wget net-tools gcc gcc-c++ make tar openssl openssl-devel cmake ```  
3、安装  
```
# cd /usr/local/src
# tar -zxf redis-4.0.9.tar.gz
# cd redis-4.0.9
# make
# mkdir -pv /usr/local/redis/conf /usr/local/redis/bin
# cp src/redis* /usr/local/redis/bin/
# cp redis.conf /usr/local/redis/conf

启动
# /usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf
```  

4、配置文件  
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
5、sentinel管理多个redis服务实现HA  
```
vim /etc/redis-sentinel.conf
  # sentinel monitor <master-name> <ip> <redis-port> <quorum> #此项可以出现多次，可以监控多组redis主从架构，此项用于监控主节点
	<master-name> 自定义的主节点名称
	<ip> 主节点的IP地址
	<redis-port>主节点的端口号
	<quorum>主节点对应的quorum法定数量，用于定义sentinel的数量，是一个大于值尽量使用奇数，如果sentinel有3个，则指定为2即可
  sentinel auth-pass <master-name> <password>                     #切换master是从节点配置为master的认证
  sentinel down-after-milliseconds <master-name> <milliseconds>   #sentinel连接其他节点超时时间，单位为毫秒（默认为30秒）
  sentinel parallel-syncs <master-name> <numslaves>               #提升主服务器时，允许多少个从服务向新的主服务器发起同步请求
  sentinel failover-timeout <master-name> <milliseconds>          #故障转移超时时间，在指定时间没能完成则判定为失败，单位为毫秒（默认为180秒）


# systemctl start redis-sentinel 启动
# redis-cli -p 26379
127.0.0.1:26379> info sentinel
  # Sentinel
  sentinel_masters:1
  sentinel_tilt:0
  sentinel_running_scripts:0
  sentinel_scripts_queue_length:0
  sentinel_simulate_failure_flags:0
  master0:name=mymaster,status=sdown,address=127.0.0.1:6379,slaves=0,sentinels=1
  
# 127.0.0.1:26379> sentinel masters
1)  1) "name"
    2) "mymaster"
    3) "ip"
    4) "127.0.0.1"

127.0.0.1:26379> sentinel slaves mymaster
(empty list or set)
```  
6、密码配置  
```
# vim /etc/redis.conf
  requirepass 123456    
# systemctl restart redis
# redis-cli
  127.0.0.1:6379> auth  123456
  OK
或者 redis-cli -a 123456  启动直接输入密码
```  
7、RDB和AOF相关配置 默认值即可  
配置文件中的与RDB相关的参数：  
```
stop-writes-on-bgsave-error yes		#在进行快照备份时，一旦发生错误的话是否停止写操作
rdbcompression yes			#RDB文件是否使用压缩，压缩会消耗CPU
rdbchecksum yes				#是否对RDB文件做校验码检测
dbfilename dump.rdb 			#定义RDB文件的名称
dir /var/lib/redis 			#定义RDB文件存放的目录路径
```  
配置文件中的与AOF相关的参数：  
```
appendonly no 				#定义是否开启AOF功能，默认为关闭
appendfilename "appendonly.aof" 	#定义AOF文件
appendfsync always 			#表示每次收到写命令时，立即写到磁盘上的AOF文件，虽然是最好的持久化功能，但是每次有写命令时都会有磁盘的I/O操作，容易影响redis的性能
appendfsync everysec 			#表示每秒钟写一次，不管每秒钟收到多少个写请求都往磁盘中的AOF文件中写一次
appendfsync no 				#表示append功能不会触发写操作，所有的写操作都是提交给OS，由OS自行决定是如何写的
no-appendfsync-on-rewrite no 		#当此项为yes时，表示在重写时，对于新的写操作不做同步，而暂存在内存中
auto-aof-rewrite-percentage 100		#表示当前AOF文件的大小是上次重写AOF文件的二倍时，则自动日志重写过程
auto-aof-rewrite-min-size 64mb		#定义AOF文件重写过程的条件，最少为定义大小则触发重写过程
```  
注意：持久本身不能取代备份；还应该制定备份策略，对redis数据库定期进行备份；  

RDB与AOF同时启用：  
	(1) BGSAVE和BGREWRITEAOF不会同时执行，为了避免对磁盘的I/O影响过大，在某一时刻只允许一者执行；  
	如果BGSAVE在执行当中，而用户手动执行BGREWRITEAOF时，redis会立即返回OK，但是redis不会同时执行，会等BGSAVE执行完成，再执行BGREWRITEAOF  
	(2) 在Redis服务器启动用于恢复数据时，会优先使用AOF  

8、redis主从架构  
主库会基于pingcheck方式检查从库是否在线，如果在线则直接同步数据文件至从服务端，从服务端也可以主动发送同步请求到主服务端，主库如果是启动了持久化功能时，会不断的同步数据到磁盘上，主库一旦收到从库的同步请求时，主库会将内存中的数据做快照，然后把数据文件同步给从库，从库得到以后是保存在本地文件中（磁盘），而后则把该文件装载到内存中完成数据重建，链式复制也同步如此，因为主是不区分是真正的主，还是另外一个的从  

1、启动一slave  
2、slave会向master发送同步命令，请求主库上的数据，不论从是第一次连接，还是非第一次连接，master此时都会启动一个后台的子进程将数据快照保存在数据文件中，然后把数据文件发送给slave  
3、slave收到数据文件 以后会保存到本地，而后把文件重载装入内存  

主从相关配置：
```
slave-serve-stale-data yes      #表示当主服务器不可以用时，则无法判定数据是否过期，此时从服务器仍然接收到读请求时，yes表示继续使用过期数据
slave-read-only yes	        #启用slave时，该服务器是否为只读
repl-diskless-sync no 	        #是否基于diskless机制进行sync操作，一般情况下如果disk比较慢，网络带宽比较大时，在做复制时，此项可以改为Yes
repl-diskless-sync-delay 5      #在slave下同步数据到磁盘的延迟时间，默认为5秒，0表示不延迟
slave-priority 100 	        #指定slave优先级，如果有多个slave时，那一个slave将优先被同步
# min-slaves-to-write 3         #主从复制模式，如果给主服务器配置多个从服务器，在从服务器少于3个时，主服务器将拒绝接收写请求，从服务器不能少于该项的指定值，主服务器才能正常接收用户的写请求
# min-slaves-max-lag 10		#表示从服务器与主服务器的时差不能够相差于10秒钟以上，否则写操作将拒绝进行
```  
9、命令行工具  
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

清空数据库：
   FLUSHDB：删除当前选择的数据库所有key
   FLUSHALL：清空所有库
127.0.0.1:6379> flushdb
	OK
```


redis数据分片  
https://github.com/twitter/twemproxy  
