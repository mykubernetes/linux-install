
1、连接数据库
```
redis-cli -h 192.168.101.66
```

2、查看帮助信息
```
127.0.0.1:6379> help @generic        #通用命令
127.0.0.1:6379> help @string
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

3、选择数据库
```
127.0.0.1:6379> SELECT 1
OK
127.0.0.1:6379[1]> SELECT 0
OK
```

4、String使用
```
127.0.0.1:6379> set disto feddora      #设置一个key
OK
127.0.0.1:6379> get disto              #获取key
"feddora"
127.0.0.1:6379> set disto centos       #修改key
OK
127.0.0.1:6379> append disto slackware    #在原有的value上追加新值
(integer) 15
127.0.0.1:6379> get disto              #查看追加的新值
"centosslackware"
127.0.0.1:6379> STRLEN disto           #查看字符串长度
(integer) 15


127.0.0.1:6379> set count 0          #设置一个key值为0
OK
127.0.0.1:6379> incr count           #自动+1
(integer) 1
127.0.0.1:6379> incr count
(integer) 2
127.0.0.1:6379> incr count
(integer) 3
127.0.0.1:6379> decr count           #自动-1
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
