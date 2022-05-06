# redis 数据类型

参考资料：http://www.redis.cn/topics/data-types.html

相关命令参考: http://redisdoc.com/

## 1、字符串 string

字符串是所有编程语言中最常见的和最常用的数据类型，而且也是redis最基本的数据类型之一，而且redis 中所有的 key 的类型都是字符串。常用于保存 Session 信息场景，此数据类型比较常用

| 命令 | 含义| 复杂度 |
|------|-----|--------|
| set key value | 设置key-value | 0(1) |
| get key | 获取key-value | 0(1) |
| del key | 删除key-value | 0(1) |
| setnx setxx | 根据key是否存在设置key-value | 0(1) |
| Incr decr | 计数 | 0(1) |
| mget mset | 批量操作key-value | 0(n) |

### 1.1 添加一个key

set 指令可以创建一个key 并赋值, 使用格式
```
SET key value [EX seconds] [PX milliseconds] [NX|XX]
时间复杂度： O(1)
将字符串值 value 关联到 key 。

如果 key 已经持有其他值， SET 就覆写旧值， 无视类型。
当 SET 命令对一个带有生存时间（TTL）的键进行设置之后， 该键原有的 TTL 将被清除。

从 Redis 2.6.12 版本开始， SET 命令的行为可以通过一系列参数来修改：
EX seconds ： 将键的过期时间设置为 seconds 秒。 执行 SET key value EX seconds 的效果等同于执行 SETEX key seconds value 。
PX milliseconds ： 将键的过期时间设置为 milliseconds 毫秒。 执行 SET key value PX milliseconds 的效果等同于执行 PSETEX key milliseconds value 。
NX ： 只在键不存在时， 才对键进行设置操作。 执行 SET key value NX 的效果等同于执行 SETNX key value 。
XX ： 只在键已经存在时， 才对键进行设置操作。
```

范例:
```
#不论key是否存在.都设置
127.0.0.1:6379> set key1 value1
OK
127.0.0.1:6379> get key1
"value1"
127.0.0.1:6379> TYPE key1            #判断类型
string
127.0.0.1:6379> SET title ceo ex 3   #设置自动过期时间3s
OK
127.0.0.1:6379> set NAME wang
OK
127.0.0.1:6379> get NAME
"wang"

#大小写敏感
127.0.0.1:6379> get name
(nil)
127.0.0.1:6379> set name mage
OK
127.0.0.1:6379> get name
"mage"
127.0.0.1:6379> get NAME
"wang"

#key不存在,才设置,相当于add 
127.0.0.1:6379> get title
"ceo"
127.0.0.1:6379> setnx title coo             #set key value nx
(integer) 0
127.0.0.1:6379> get title
"ceo"

#key存在,才设置,相当于update
127.0.0.1:6379> get title
"ceo"
127.0.0.1:6379> set title coo xx
OK
127.0.0.1:6379> get title
"coo"
127.0.0.1:6379> get age
(nil)
127.0.0.1:6379> set age 20 xx
(nil)
127.0.0.1:6379> get age
(nil)
```

## 1.2 获取一个key的内容
```
127.0.0.1:6379> get key1
"value1"
127.0.0.1:6379> get name age
(error) ERR wrong number of arguments for 'get' command
```

## 1.3 删除一个和多个key
```
127.0.0.1:6379> DEL key1
(integer) 1
127.0.0.1:6379> DEL key1 key2
(integer) 2
```

## 1.4 批量设置多个key
```
127.0.0.1:6379> MSET key1 value1 key2 value2 
OK
```

## 1.5 批量获取多个key
```
127.0.0.1:6379> MGET key1 key2
1) "value1"
2) "value2"

127.0.0.1:6379> KEYS n*
1) "n1"
2) "name"

127.0.0.1:6379> KEYS *
1) "k2"
2) "k1"
3) "key1"
4) "key2"
5) "n1"
6) "name"
7) "k3"
8) "title"
```

## 1.6 追加数据
```
127.0.0.1:6379> APPEND key1 " append new value"
(integer) 12              #添加数据后,key1总共9个字节
127.0.0.1:6379> get key1
"value1 append new value"
```

## 1.7 设置新值并返回旧值
```
#set key newvalue并返回旧的value
127.0.0.1:6379> set name wang
OK
127.0.0.1:6379> getset name magedu
"wang"
127.0.0.1:6379> get name
"magedu"
```

## 1.8 返回字符串 key 对应值的字节数
```
127.0.0.1:6379> SET name wang
OK
127.0.0.1:6379> STRLEN name
(integer) 4
127.0.0.1:6379> APPEND name " xiaochun"
(integer) 13
127.0.0.1:6379> GET name
"wang xiaochun"
127.0.0.1:6379> STRLEN name             #返回字节数
(integer) 13
127.0.0.1:6379> set name 教学
OK
127.0.0.1:6379> get name
"\xe9\xa9\xac\xe5\x93\xa5\xe6\x95\x99\xe8\x82\xb2"
127.0.0.1:6379> strlen name
(integer) 12
127.0.0.1:6379>
```

## 1.9 判断 key 是否存在
```
127.0.0.1:6379> SET name wang ex 10
OK
127.0.0.1:6379> set age 20
OK
127.0.0.1:6379> EXISTS NAME         #key的大小写敏感
(integer) 0
127.0.0.1:6379> EXISTS name age     #返回值为1,表示存在2个key,0表示不存在
(integer) 2
127.0.0.1:6379> EXISTS name         #过几秒再看
(integer) 0
```

## 1.10 查看 key 的过期时间
```
ttl key          #查看key的剩余生存时间,如果key过期后,会自动删除
-1               #返回值表示永不过期，默认创建的key是永不过期，重新对key赋值，也会从有剩余生命周期变成永不过期
-2               #返回值表示没有此key
num              #key的剩余有效期

127.0.0.1:6379> TTL key1
(integer) -1
127.0.0.1:6379> SET name wang EX 100
OK
127.0.0.1:6379> TTL name
(integer) 96
127.0.0.1:6379> TTL name
(integer) 93
127.0.0.1:6379> SET name mage #重新设置，默认永不过期
OK
127.0.0.1:6379> TTL name
(integer) -1
127.0.0.1:6379> SET name wang EX 200
OK
127.0.0.1:6379> TTL name
(integer) 198
127.0.0.1:6379> GET name
"wang"
```

## 1.11 重新设置key的过期时间
```
127.0.0.1:6379> TTL name
(integer) 148
127.0.0.1:6379> EXPIRE name 1000
(integer) 1
127.0.0.1:6379> TTL name
(integer) 999
127.0.0.1:6379>
```

## 1.12 取消key的过期时间
- 即永不过期
```
127.0.0.1:6379> TTL name
(integer) 999
127.0.0.1:6379> PERSIST name
(integer) 1
127.0.0.1:6379> TTL name
(integer) -1
```

## 1.13 数值递增
- 1.13 数值递增
```
127.0.0.1:6379> set num 10 #设置初始值
OK
127.0.0.1:6379> INCR num
(integer) 11
127.0.0.1:6379> get num
"11"
```

## 1.14 数值递减
```
127.0.0.1:6379> set num 10
OK
127.0.0.1:6379> DECR num
(integer) 9
127.0.0.1:6379> get num
"9"
```

## 1.15 数值增加
- 将key对应的数字加decrement(可以是负数)。如果key不存在，操作之前，key就会被置为0。如果key的value类型错误或者是个不能表示成数字的字符串，就返回错误。这个操作最多支持64位有符号的正型数字。

```
redis> SET mykey 10
OK
redis> INCRBY mykey 5
(integer) 15
127.0.0.1:6379> get mykey
"15"
127.0.0.1:6379> INCRBY mykey -10
(integer) 5
127.0.0.1:6379> get mykey
"5"
127.0.0.1:6379> INCRBY nokey  5
(integer) 5
127.0.0.1:6379> get nokey
"5"
```

## 1.16 数据减少
- decrby 可以减小数值(也可以增加)

```
127.0.0.1:6379> SET mykey 10
OK
127.0.0.1:6379> DECRBY mykey 8
(integer) 2
127.0.0.1:6379> get mykey
"2"
127.0.0.1:6379> DECRBY mykey -20
(integer) 22
127.0.0.1:6379> get mykey
"22"
127.0.0.1:6379> DECRBY nokey 3
(integer) -3
127.0.0.1:6379> get nokey
"-3"
```




