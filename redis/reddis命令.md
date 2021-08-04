
1、连接数据库
```
redis-cli -h 192.168.101.66 -p 6379
```

2、查看帮助信息
```
127.0.0.1:6379> help @generic        #通用命令
127.0.0.1:6379> help @string         #字符串
127.0.0.1:6379> help @list           #列表
127.0.0.1:6379> help @set            #集合
127.0.0.1:6379> help @sorted_set     #有序集合
127.0.0.1:6379> help @hash           #哈希
127.0.0.1:6379> help @pubsub         #订阅发布
127.0.0.1:6379> help @transactions   #事务
127.0.0.1:6379> help @connection     #连接
127.0.0.1:6379> help @server         #配置相关
127.0.0.1:6379> help @scripting      #脚本
127.0.0.1:6379> help @hyperloglog
127.0.0.1:6379> help @cluster        #集群
127.0.0.1:6379> help @geo


127.0.0.1:6379> help @server
127.0.0.1:6379> client list
id=3 addr=127.0.0.1:53154 fd=5 name= age=149 idle=0 flags=N db=0 sub=0 psub=0 multi=-1 qbuf=0 qbuf-free=32768 obl=0 oll=0 omem=0 events=r cmd=client
```

清空数据库
```
flushdb            #清空当前库
flushall           #清空所有库
keys *             #列出所有key
```
3、选择数据库
```
127.0.0.1:6379> SELECT 1
OK
127.0.0.1:6379[1]> SELECT 0
OK
```

4、String使用
```
127.0.0.1:6379> set disto feddora         #设置一个key
OK
127.0.0.1:6379> get disto                 #获取key
"feddora"
127.0.0.1:6379> exists disto              #判断当前key是否存在
(integer) 1
127.0.0.1:6379> move disto                #移除当前key
127.0.0.1:6379> set disto centos          #修改key
OK
127.0.0.1:6379> append disto slackware    #在原有的value上追加新值
(integer) 15
127.0.0.1:6379> get disto                 #查看追加的新值
"centosslackware"
127.0.0.1:6379> STRLEN disto              #查看字符串长度
(integer) 15

127.0.0.1:6379> set count 0               #设置一个key值为0
OK
127.0.0.1:6379> incr count                #自动+1
(integer) 1
127.0.0.1:6379> incr count
(integer) 2
127.0.0.1:6379> incr count
(integer) 3
127.0.0.1:6379> decr count                #自动-1
(integer) 2
127.0.0.1:6379> decr count
(integer) 1

127.0.0.1:6379> set disto gentoo NX    #NX 不存在才设置
(nil)
127.0.0.1:6379> set foo bar XX         #XX 存在才设置
(nil)
127.0.0.1:6379> set foo bar EX 10      #EX 过期时间以秒为单位
```
- set
- get
- incr
- decr
- exist

5、list使用
```
127.0.0.1:6379> LPUSH l1 mon       #这是一个列表
(integer) 1
127.0.0.1:6379> LINDEX l1 0        #查看里边第0个所有的值
"mon"
127.0.0.1:6379> LPUSH l1 sun       #在左侧插入一个值
(integer) 2
127.0.0.1:6379> LINDEX l1 0        #查看里边第0个所有的值
"sun"
127.0.0.1:6379> LINDEX l1 1        #查看里边第1个所有的值
"mon"
127.0.0.1:6379> RPUSH l1 tue       #右侧插入一个值
(integer) 3
127.0.0.1:6379> LINDEX l1 2        #查看右侧插入的值
"tue"

127.0.0.1:6379> LSET l1 1 fri     #修改一个值
OK
127.0.0.1:6379> LINDEX l1 1       #查看修改
"fri"

127.0.0.1:6379> RPOP l1           #从右侧删除一个值，LPOP是从左侧删除
"tue"
127.0.0.1:6379> RPOP l1
"fri"
127.0.0.1:6379> RPOP l1
"sun"
127.0.0.1:6379> RPOP l1
(nil)
```
- lpush
- rpush
- lpop
- rpop
- lindex
- lset

6、set使用
```
127.0.0.1:6379> SADD v1 mon tue ved thu fre sat sun            #设置一个集合
(integer) 7
127.0.0.1:6379> SADD v2 tue thu day                            #设置一个集合
(integer) 3

127.0.0.1:6379> SINTER v1 v2                                   #查看两个集合的交集，两个都有的值
1) "thu"
2) "tue"

127.0.0.1:6379> SUNION v1 w1                                   #查看两个集合的并集，所有的只显示一份
1) "day"
2) "mon"
3) "ved"
4) "sun"
5) "thu"
6) "tue"
7) "sat"
8) "fre"

127.0.0.1:6379> SPOP v1                                        #随机删除一个
"ved"
127.0.0.1:6379> SPOP v1
"mon"

127.0.0.1:6379> SISMEMBER v1 mon                               #查看集合中的mon是否还是元素,0代表不是集合的元素，1代表是集合的元素
(integer) 0
127.0.0.1:6379> SISMEMBER v1 sun                               #查看集合中的sun是否还是元素,0代表不是集合的元素，1代表是集合的元素
(integer) 1
```
- sadd
- sinter
- sunion
- spop
- sismember

7、sorted_set使用
```
127.0.0.1:6379> zadd weekday 1 mon 2 tue 3 ved         #设置一个有序集合
(integer) 3
127.0.0.1:6379> ZCARD weekday                          #查看元素个数
(integer) 3

127.0.0.1:6379> ZRANK weekdey tue                      #查看索引号
(integer) 1
127.0.0.1:6379> ZRANK weekdey ved
(integer) 2

127.0.0.1:6379> ZSCORE weekdey tue                     #查看自定义的序号
"2"

127.0.0.1:6379> ZRANGE weekdey 0 2                     #通过所有查看元素
1) "mon"
2) "tue"
3) "ved"
```
- zadd
- zrnge
- zcard
- zrank

8、hash使用
```
127.0.0.1:6379> HSET h1 a  mon                    #设置一个hash a是mon
(integer) 1
127.0.0.1:6379> HGET h1 a                         #获取a的值
"mon"

127.0.0.1:6379> HSET h1 b tue                     #设置一个hash b是mon
(integer) 1
127.0.0.1:6379> HGET h1 b                         #获取a的值    h1为外键 a和b是内键
"tue"

127.0.0.1:6379> HKEYS h1                          #获取所有键
1) "a"
2) "b"

127.0.0.1:6379> HVALS h1                          #获取所有值
1) "mon"
2) "tue"

127.0.0.1:6379> HLEN h1                           #获取元素个数
(integer) 2
```
- hset
- hsetnx
- hget
- hkeys
- hvals
- hdel


事务
---
通过MULTI,EXEC,WATCH等命令实现事务功能：将一个或多个命令归并为一个操作提交后按顺序执行的机制
```
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379> set ip 192.168.0.1
QUEUED
127.0.0.1:6379> get ip
QUEUED
127.0.0.1:6379> set port 8080
QUEUED
127.0.0.1:6379> get port
QUEUED
127.0.0.1:6379> EXEC
1) OK
2) "192.168.0.1"
3) OK
4) "8080"
127.0.0.1:6379>
```
- MULTI 启动一个事务
- EXEC 执行事务，一次性将事务中的所有操作执行完成后返回给客户端

```
第一个终端
127.0.0.1:6379> WATCH ip
OK
127.0.0.1:6379> MULTI 
OK
127.0.0.1:6379> set ip 10.0.0.1
QUEUED
127.0.0.1:6379> get ip
QUEUED
127.0.0.1:6379> exec           #使用watch机制后如果被监听的key发生改变事务机制将不能提交
(nil)

第二个终端
127.0.0.1:6379> get ip
"192.168.0.1"
127.0.0.1:6379> set ip 172.16.100.1
OK
127.0.0.1:6379> get ip
"172.16.100.1"
```

发布订阅
---
```
订阅
127.0.0.1:6379> SUBSCRIBE news
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "news"
3) (integer) 1
1) "message"
2) "news"
3) "hello"
1) "message"
2) "news"
3) "redis"

发布
127.0.0.1:6379> PUBLISH news hello
(integer) 1
127.0.0.1:6379> PUBLISH news redis
(integer) 1


退订之前的订阅
127.0.0.1:6379> UNSUBSCRIBE news
1) "unsubscribe"
2) "news"
3) (integer) 0


订阅多个消息，模式订阅支持正则表达式
127.0.0.1:6379> PSUBSCRIBE "news.i[to]"
Reading messages... (press Ctrl-C to quit)
1) "psubscribe"
2) "news.i[to]"
3) (integer) 1
1) "pmessage"
2) "news.i[to]"
3) "news.io"
4) "hello"
1) "pmessage"
2) "news.i[to]"
3) "news.it"
4) "redis"

127.0.0.1:6379> PUBLISH news.io hello
(integer) 1
127.0.0.1:6379> PUBLISH news.it redis
(integer) 1
```
