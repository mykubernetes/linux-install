
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

