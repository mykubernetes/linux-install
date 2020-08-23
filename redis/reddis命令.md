
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

