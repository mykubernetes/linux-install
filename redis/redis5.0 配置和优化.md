# redis 主要配置项
```
bind 0.0.0.0                       #监听地址，可以用空格隔开后多个监听IP
protected-mode yes                 #redis3.2之后加入的新特性，在没有设置bind IP和密码的时候,redis只允许访问127.0.0.1:6379，可以远程连接，但当访问将提示警告信息并拒绝远程访问
port 6379                          #监听端口,默认6379/tcp
tcp-backlog 511                    #三次握手的时候server端收到client ack确认号之后的队列值，即全连接队列长度
timeout 0                          #客户端和Redis服务端的连接超时时间，默认是0，表示永不超时
tcp-keepalive 300                  #tcp 会话保持时间300s
daemonize no                       #默认no,即直接运行redis-server程序时,不作为守护进程运行，而是以前台方式运行，如果想在后台运行需改成yes,当redis作为守护进程运行的时候，它会写一个 pid 到/var/run/redis.pid 文件
supervised no                      #和OS相关参数，可设置通过upstart和systemd管理Redis守护进程，centos7后都使用systemd
pidfile /var/run/redis_6379.pid    #pid文件路径,可以修改为/apps/redis/run/redis_6379.pid
loglevel notice                    #日志级别
logfile "/path/redis.log"          #日志路径,示例:logfile "/apps/redis/log/redis_6379.log"
databases 16                       #设置数据库数量，默认：0-15，共16个库
always-show-logo yes               #在启动redis 时是否显示或在日志中记录记录redis的logo
save 900 1                         #在900秒内有1个key内容发生更改,就执行快照机制
save 300 10                        #在300秒内有10个key内容发生更改,就执行快照机制
save 60 10000                      #60秒内如果有10000个key以上的变化，就自动快照备份
stop-writes-on-bgsave-error yes    #默认为yes时,可能会因空间满等原因快照无法保存出错时，会禁止redis写入操作，生产建议为no #此项只针对配置文件中的自动save有效
rdbcompression yes                 #持久化到RDB文件时，是否压缩，"yes"为压缩，"no"则反之
rdbchecksum yes                    #是否对备份文件开启RC64校验，默认是开启
dbfilename dump.rdb                #快照文件名
dir ./                             #快照文件保存路径，示例：dir "/apps/redis/data"
rdb-del-sync-files no              #在没有开启数据库持久化的情况下删除复制中使用的RDB文件，redis6.0以后才有的配置。

#主从复制相关
# replicaof <masterip> <masterport>   #指定复制的master主机地址和端口，5.0版之前的指令为slaveof 
# masterauth <master-password>        #指定复制的master主机的密码

replica-serve-stale-data yes          #当从库同主库失去连接或者复制正在进行，从机库有两种运行方式：
  1、设置为yes(默认设置)，从库会继续响应客户端的读请求，此为建议值
  2、设置为no，除去特定命令外的任何请求都会返回一个错误"SYNC with master in progress"。

replica-read-only yes               #是否设置从库只读，建议值为yes,否则主库同步从库时可能会覆盖数据，造成数据丢失
repl-diskless-sync no               #是否使用socket方式复制数据(无盘同步)，新slave第一次连接master时需要做数据的全量同步，redis server就要从内存dump出新的RDB文件，然后从master传到slave，有两种方式把RDB文件传输给客户端：
  1、基于硬盘（disk-backed）：为no时，master创建一个新进程dump生成RDB磁盘文件，RDB完成之后由父进程（即主进程）将RDB文件发送给slaves，此为默认值
  2、基于socket（diskless）：master创建一个新进程直接dump RDB至slave的网络socket，不经过主进程和硬盘
#推荐使用基于硬盘（为no），是因为RDB文件创建后，可以同时传输给更多的slave，但是基于socket(为yes)， 新slave连接到master之后得逐个同步数据。只有当磁盘I/O较慢且网络较快时，可用diskless(yes),否则一般建议使用磁盘(no)

repl-diskless-sync-delay 5          #diskless时复制的服务器等待的延迟时间，设置0为关闭，在延迟时间内到达的客户端，会一起通过diskless方式同步数据，但是一旦复制开始，master节点不会再接收新slave的复制请求，直到下一次同步开始才再接收新请求。即无法为延迟时间后到达的新副本提供服务，新副本将排队等待下一次RDB传输，因此服务器会等待一段时间才能让更多副本到达。推荐值：30-60
repl-ping-replica-period 10         #slave根据master指定的时间进行周期性的PING master,用于监测master状态,默认10s
repl-timeout 60                     #复制连接的超时时间，需要大于repl-ping-slave-period，否则会经常报超时
repl-disable-tcp-nodelay no         #是否在slave套接字发送SYNC之后禁用 TCP_NODELAY，如果选择"yes"，Redis将合并多个报文为一个大的报文，从而使用更少数量的包向slaves发送数据，但是将使数据传输到slave上有延迟，Linux内核的默认配置会达到40毫秒，如果 "no" ，数据传输到slave的延迟将会减少，但要使用更多的带宽
repl-backlog-size 512mb             #复制缓冲区内存大小，当slave断开连接一段时间后，该缓冲区会累积复制副本数据，因此当slave 重新连接时，通常不需要完全重新同步，只需传递在副本中的断开连接后没有同步的部分数据即可。只有在至少有一个slave连接之后才分配此内存空间,建议建立主从时此值要调大一些或在低峰期配置,否则会导致同步到slave失败
repl-backlog-ttl 3600               #多长时间内master没有slave连接，就清空backlog缓冲区
replica-priority 100                #当master不可用，哨兵Sentinel会根据slave的优先级选举一个master，此值最低的slave会优先当选master，而配置成0，永远不会被选举，一般多个slave都设为一样的值，让其自动选择

#min-replicas-to-write 3            #至少有3个可连接的slave，mater才接受写操作
#min-replicas-max-lag 10            #和上面至少3个slave的ping延迟不能超过10秒，否则master也将停止写操作

requirepass foobared                #设置redis连接密码，之后需要AUTH pass,如果有特殊符号，用" "引起来,生产建议设置
rename-command                      #重命名一些高危命令，示例：rename-command FLUSHALL "" 禁用命令 #示例: rename-command del magedu
maxclients 10000                    #Redis最大连接客户端
maxmemory <bytes>                   #redis使用的最大内存，单位为bytes字节，0为不限制，建议设为物理内存一半，8G内存的计算方式8(G)*1024(MB)1024(KB)*1024(Kbyte)，需要注意的是缓冲区是不计算在maxmemory内,生产中如果不设置此项,可能会导致OOM
appendonly no                       #是否开启AOF日志记录，默认redis使用的是rdb方式持久化，这种方式在许多应用中已经足够用了，但是redis如果中途宕机，会导致可能有几分钟的数据丢失(取决于dump数据的间隔时间)，根据save来策略进行持久化，Append Only File是另一种持久化方式，可以提供更好的持久化特性，Redis会把每次写入的数据在接收后都写入 appendonly.aof 文件，每次启动时Redis都会先把这个文件的数据读入内存里，先忽略RDB文件。默认不启用此功能
appendfilename "appendonly.aof"     #文本文件AOF的文件名，存放在dir指令指定的目录中
appendfsync everysec                #aof持久化策略的配置
  #no表示由操作系统保证数据同步到磁盘,Linux的默认fsync策略是30秒，最多会丢失30s的数据
  #always表示每次写入都执行fsync，以保证数据同步到磁盘,安全性高,性能较差
  #everysec表示每秒执行一次fsync，可能会导致丢失这1s数据,此为默认值,也生产建议值
  
  #同时在执行bgrewriteaof操作和主进程写aof文件的操作，两者都会操作磁盘，而bgrewriteaof往往会涉及大量磁盘操作，这样就会造成主进程在写aof文件的时候出现阻塞的情形,以下参数实现控制

no-appendfsync-on-rewrite no        #在aof rewrite期间,是否对aof新记录的append暂缓使用文件同步策略,主要考虑磁盘IO开支和请求阻塞时间。
  #默认为no,表示"不暂缓",新的aof记录仍然会被立即同步到磁盘，是最安全的方式，不会丢失数据，但是要忍受阻塞的问题
  #为yes,相当于将appendfsync设置为no，这说明并没有执行磁盘操作，只是写入了缓冲区，因此这样并不会造成阻塞（因为没有竞争磁盘），但是如果这个时候redis挂掉，就会丢失数据。丢失多少数据呢？Linux的默认fsync策略是30秒，最多会丢失30s的数据,但由于yes性能较好而且会避免出现阻塞因此比较推荐
  #rewrite 即对aof文件进行整理,将空闲空间回收,从而可以减少恢复数据时间auto-aof-rewrite-percentage 100 #当Aof log增长超过指定百分比例时，重写AOF文件，设置为0表示不自动重写Aof日志，重写是为了使aof体积保持最小，但是还可以确保保存最完整的数据

auto-aof-rewrite-min-size 64mb      #触发aof rewrite的最小文件大小
aof-load-truncated yes              #是否加载由于某些原因导致的末尾异常的AOF文件(主进程被kill/断电等)，建议yes
aof-use-rdb-preamble no             #redis4.0新增RDB-AOF混合持久化格式，在开启了这个功能之后，AOF重写产生的文件将同时包含RDB格式的内容和AOF格式的内容，其中RDB格式的内容用于记录已有的数据，而AOF格式的内容则用于记录最近发生了变化的数据，这样Redis就可以同时兼有RDB持久化和AOF持久化的优点（既能够快速地生成重写文件，也能够在出现问题时，快速地载入数据）,默认为no,即不启用此功能
lua-time-limit 5000                 #lua脚本的最大执行时间，单位为毫秒
cluster-enabled yes                 #是否开启集群模式，默认不开启,即单机模式
cluster-config-file nodes-6379.conf #由node节点自动生成的集群配置文件名称
cluster-node-timeout 15000          #集群中node节点连接超时时间，单位ms,超过此时间，会踢出集群
cluster-replica-validity-factor 10  #单位为次,在执行故障转移的时候可能有些节点和master断开一段时间导致数据比较旧，这些节点就不适用于选举为master，超过这个时间的就不会被进行故障转移,不能当选master，计算公式：(node-timeout * replica-validity-factor) + repl-pingreplica-period 
cluster-migration-barrier 1         #集群迁移屏障，一个主节点至少拥有1个正常工作的从节点，即如果主节点的slave节点故障后会将多余的从节点分配到当前主节点成为其新的从节点。
cluster-require-full-coverage yes   #集群请求槽位全部覆盖，如果一个主库宕机且没有备库就会出现集群槽位不全，那么yes时redis集群槽位验证不全,就不再对外提供服务(对key赋值时,会出现CLUSTERDOWN The cluster is down的提示,cluster_state:fail,但ping 仍PONG)，而no则可以继续使用,但是会出现查询数据查不到的情况(因为有数据丢失)。生产建议为no
cluster-replica-no-failover no      #如果为yes,此选项阻止在主服务器发生故障时尝试对其主服务器进行故障转移。 但是，主服务器仍然可以执行手动强制故障转移，一般为no

#Slow log 是 Redis 用来记录超过指定执行时间的日志系统，执行时间不包括与客户端交谈，发送回复等I/O操作，而是实际执行命令所需的时间（在该阶段线程被阻塞并且不能同时为其它请求提供服务）,由于slow log 保存在内存里面，读写速度非常快，因此可放心地使用，不必担心因为开启 slow log 而影响Redis 的速度
slowlog-log-slower-than 10000       #以微秒为单位的慢日志记录，为负数会禁用慢日志，为0会记录每个命令操作。默认值为10ms,一般一条命令执行都在微秒级,生产建议设为1ms-10ms之间
slowlog-max-len 128                 #最多记录多少条慢日志的保存队列长度，达到此长度后，记录新命令会将最旧的命令从命令队列中删除，以此滚动删除,即,先进先出,队列固定长度,默认128,值偏小,生产建议设为1000以上
```

# CONFIG 动态修改配置
- config 命令用于查看当前redis配置、以及不重启redis服务实现动态更改redis配置等

**注意：** 不是所有配置都可以动态修改,且此方式无法持久保存

```
CONFIG SET parameter value
时间复杂度：O(1)CONFIG SET 命令可以动态地调整 Redis 服务器的配置(configuration)而无须重启。

可以使用它修改配置参数，或者改变 Redis 的持久化(Persistence)方式。CONFIG SET 可以修改的配置参数可以使用命令 CONFIG GET * 来列出，所有被 CONFIG SET 修改的配置参数都会立即生效。

CONFIG GET parameter
时间复杂度： O(N)，其中 N 为命令返回的配置选项数量。CONFIG GET 命令用于取得运行中的 Redis 服务器的配置参数(configuration parameters)，在Redis 2.4 版本中， 有部分参数没有办法用 CONFIG GET 访问，但是在最新的 Redis 2.6 版本中，所有配置参数都已经可以用 CONFIG GET 访问了。

CONFIG GET 接受单个参数 parameter 作为搜索关键字，查找所有匹配的配置参数，其中参数和值以“键值对”(key-value pairs)的方式排列。比如执行 CONFIG GET s* 命令，服务器就会返回所有以 s 开头的配置参数及参数的值：
```

1、设置连接密码
```
#设置连接密码
127.0.0.1:6379> CONFIG SET requirepass 123456
OK

#查看连接密码
127.0.0.1:6379> CONFIG GET requirepass  
1) "requirepass"
2) "123456"
```

2、获取当前配置
```
#奇数行为键，偶数行为值
127.0.0.1:6379> CONFIG GET *
 1) "dbfilename"
 2) "dump.rdb"
 3) "requirepass"
 4) ""
 5) "masterauth"
 6) ""
 7) "cluster-announce-ip"
 8) ""
 9) "unixsocket"
10) ""
11) "logfile"
12) "/var/log/redis/redis.log"
13) "pidfile"
14) "/var/run/redis_6379.pid"
15) "slave-announce-ip"
16) ""
17) "replica-announce-ip"
18) ""
19) "maxmemory"
20) "0"
......

#查看bind 
127.0.0.1:6379> CONFIG GET bind
1) "bind"
2) "0.0.0.0"

#有些设置无法修改
127.0.0.1:6379> CONFIG SET bind 127.0.0.1
(error) ERR Unsupported CONFIG parameter: bind
```

3、更改最大内存
```
127.0.0.1:6379> CONFIG SET maxmemory 8589934592
OK

127.0.0.1:6379> CONFIG GET maxmemory
1) "maxmemory"
2) "8589934592"
```

# 慢查询
```
[root@centos8 ~]#vim /etc/redis.conf
slowlog-log-slower-than 1    #指定为超过1us即为慢的指令
slowlog-max-len 1024         #指定保存1024条慢记录

127.0.0.1:6379> SLOWLOG LEN  #查看慢日志的记录条数
(integer) 14

127.0.0.1:6379> SLOWLOG GET [n] #查看慢日志的n条记录
1) 1) (integer) 14
2) (integer) 1544690617
3) (integer) 4
4) 1) "slowlog"

127.0.0.1:6379> SLOWLOG GET 3
1) 1) (integer) 7
   2) (integer) 1602901545
   3) (integer) 26
   4) 1) "SLOWLOG"
      2) "get"
   5) "127.0.0.1:38258"
   6) ""
2) 1) (integer) 6
   2) (integer) 1602901540
   3) (integer) 22
   4) 1) "SLOWLOG"
      2) "get"
      3) "2"
   5) "127.0.0.1:38258"
   6) ""
3) 1) (integer) 5
   2) (integer) 1602901497
   3) (integer) 22
   4) 1) "SLOWLOG"
      2) "GET"
   5) "127.0.0.1:38258"
   6) ""

127.0.0.1:6379> SLOWLOG RESET #清空慢日志
OK
```
