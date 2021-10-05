# Pool相关

1、显示资源池列表
```
# rados lspools
```

2、创建资源池
```
语法： rados mkpool pool1 auid rule_id

#创建一个名称为pool1的资源池，执行该资源池的rule编号为2,用户编号为1 
# rados mkpool pool1 12 2 
setting auid:12
using crush rule 2
successfully created pool test
```

3、资源池数据拷贝
```
# rados cppool pool1 pool2    # 将pool1的资源池数据拷贝到pool2的数据资源池
```

4、删除资源池
```
# rados rmpool pool1 pool1 --yes-i-really-really-mean-it
```

5、清除资源池数据
```
# rados purge pool1 --yes-i-really-really-mean-it
```

6、查看资源池信息
```
语法：rados df -p pool1 -p参数是指定具体资源池，如果不加，则显示所有

# rados df -p data
POOL_NAME USED OBJECTS CLONES COPIES MISSING_ON_PRIMARY UNFOUND DEGRADED RD_OPS RD    WR_OPS  WR    
data      662G   51636      0 619632                  0       0        0  48547 7745M 1653358 1274G 

total_objects    51883
total_used       2195G
total_avail      215T
total_space      217T
```

7、列出资源池对象编号
```
语法：rados ls -p poo1，同样指定列出pool1资源池对象，否则列出所有

# rados ls -p data|less
10000004481.00000002
10000001b2f.00000000
100000042f9.00000006
10000004f62.00000001
10000003e8c.00000003
```

8、修改资源池的用户编号，即auid
```
# rados chown auid
```

# Object相关

1、获取对象内容`get`
```
# rados ls -p data
test.txt

# rados -p data get 10000006b70.00000005 test.txt

# cat test.txt     #该对象内容是一些时间戳
161-20:45:49:35
162-20:45:49:536
163-20:45:50:53
164-20:45:50:575
165-20:45:51:83
166-20:45:51:602
167-20:45:52:114
168-20:45:52:623
169-20:45:53:129
170-20:45:53:636
171-20:45:54:150
```

2、 将指定文件作为对象写入到资源池`put`
```
# rados -p test_rep_pool put obj_name test.txt    # 将test.txt以obj_name为名称进行上传

#写入之前的对象数
 data:
pools:   2 pools, 256 pgs
objects: 2 objects, 19B
usage:   15.0GiB used, 96.4TiB / 96.4TiB avail
pgs:     256 active+clean

#写入之后的对象数
data:
    pools:   2 pools, 256 pgs
objects: 3 objects, 2.78MiB
usage:   15.0GiB used, 96.4TiB / 96.4TiB avail
pgs:     256 active+clean

#查看对象列表如下
# rados -p test_rep_pool ls
obj_name
```

此外，该命令可以指定写入对象的偏移量，默认是从0开始，我可以指定具体的偏移量，单位为B
```
# rados -p test_rep_pool put obj_name test.txt --offset 1048576      # 从起始地址偏移1M

data:
pools:   2 pools, 256 pgs
objects: 3 objects, 3.78MiB                    #本应该是2.78M,偏移了1M开始写，现在变为3.78M  
usage:   15.0GiB used, 96.4TiB / 96.4TiB avail
pgs:     256 active+clean
```
- 这个命令极大得方便我们去测试分析bluestore 的io流程

3、向指定对象追加内容`append`
```
# rados -p test_rep_pool append obj_name ceph-osd.16.log
```

4、删除指定长度对象内容`truncate`
```
# rados -p test_rep_pool truncate obj_name 524288            # 删除obj_name 对象512kb的容量
```

5、创建对象`create`
```
# rados -p test_rep_pool create obj_name2         # 创建了一个空对象

# rados -p test_rep_pool ls
obj_name2
obj_name

# rados -p test_rep_pool stat obj_name2         #显示对象信息，包括所在资源池。修改修改时间，大小
test_rep_pool/obj_name2 mtime 2019-05-10 21:12:40.000000, size 0
``` 

6、删除指定对象`rm`
```
# rados -p test_rep_pool rm obj_name2         # 或者加--force-full时强制删除一个对象，不在乎对象此时状态
```

7、拷贝对象`cp`
```
# rados -p test_rep_pool cp obj_name test_cp_obj

# rados -p test_rep_pool ls
obj_name2
test_cp_obj
obj_name
    
#查看这两个对象的信息，可以看到已经成功拷贝
# rados -p test_rep_pool stat obj_name 
test_rep_pool/obj_name mtime 2019-05-10 21:08:49.000000, size 524288

# rados -p test_rep_pool stat test_cp_obj
test_rep_pool/test_cp_obj mtime 2019-05-10 21:17:29.000000, size 524288
```

8、查看对象的属性`listxattr`
```
# rados -p data listxattr obj_name
```

9、获取对象指定属性`getxattr`
```
#rados -p data getxattr obj_name attr
```

10、设置对象属性值`setxattr`
```
# rados -p data setxattr obj_name attr val
```

11、删除对象指定属性`rmxattr`
```
# rados -p data rmxattr obj_name attr
```

```
#先设置对象属性值
rados -p test_rep_pool setxattr obj_name test_attr true
rados -p test_rep_pool setxattr obj_name test_attr2 false

#列出对象属性值
# rados -p test_rep_pool listxattr obj_name
test_attr
test_attr2

#获取对象指定属性值
# rados -p test_rep_pool getxattr obj_name test_attr
true

#删除test_attr属性,只剩下一个属性
# rados -p test_rep_pool rmxattr obj_name test_attr
# rados -p test_rep_pool listxattr obj_name
test_attr2
```
- 可以理解这几个命令可以为对象打标，来标记我们自己操作过的对象

12、查看对象信息
```
# rados -p test_rep_pool stat obj_name
test_rep_pool/obj_name mtime 2019-05-10 21:33:48.000000, size 524288
```

13、设置对象头部内容`setomapheader`
```
# rados -p test_rep_pool setomapheader obj_name 1
```
14、获取对象头部内容`getomapheader`
```
rados -p test_rep_pool getomapheader obj_name
```

```
#设置对象头部信息为1
# rados -p test_rep_pool setomapheader obj_name 1
    
#获取对象头部信息
# rados -p test_rep_pool getomapheader obj_name 
header (1 bytes) :
00000000  31                                                |1|
00000001
```

14、设置对象的键值属性`setomapval`
```
rados -p test_rep_pool setomapval obj_name key val
```

15、列出omap的键`listomapkeys`
```
rados -p test_rep_pool listomapkeys obj_name key val
```

16、列出omap的键`listomapvals` 
```
rados -p test_rep_pool listomap obj_name keys
```

17、获取对象的指定键的值`getomap val`
```
rados -p test_rep_pool getomapval obj_name key
```

18、删除对象的指定键和值`rmomapkey`
```
rados -p test_rep_pool rmomapkey obj_name key
```

19、监控对象操作，并且向监控者发送消息 有点类似与局域网通信
```
#终端一 :监听该对象
# rados -p test_rep_pool watch obj_name
press enter to exit...

#终端二：发送消息到终端一的该对象监听者
# rados -p test_rep_pool notify obj_name message
reply client.86788 cookie 140047050446368 : 11 bytes
00000000  07 00 00 00 6d 65 73 73  61 67 65                 |....message|
0000000b

#此时终端一接收到消息如下
NOTIFY cookie 140047050446368 notify_id 940597837824 from 86797
00000000  07 00 00 00 6d 65 73 73  61 67 65                 |....message|
0000000b
```

20、查看有多少个对象监控者
```
# rados -p test_rep_pool listwatchers obj_name
watcher=192.168.122.1:0/3015025283 client.86788 cookie=140047050446368
```

21、设置一个对象的大小以及写粒度，但是目前并未分析清除该设置所起的作用
```
rados -p test_rep_pool set-alloc-hint 4194304 4194304大小为4M ,写粒度为4M
```

# 导出资源池数据

- 该命令方便数据备份

1、将资源池内容输出或者写入指定文件
```
rados -p test_rep_pool export pool_content
```

因为导出的文件为数据文件，所以查看内容需使用hexdum -C pool_content格式化输出或者使用vim进入一般模式输入:%!xxd 从而将该文件转换为16进制可读文件
```
# vim pool_content 
0000000: ceff ceff 0200 0000 1200 0000 0a00 0000  ................
0000010: 0101 0c00 0000 ceff 0a0a 0000 0000 0000  ................
0000020: 0000 0101 0c00 0000 ceff 0303 2701 0000  ............'...
0000030: 0000 0000 0301 2101 0000 0403 2a00 0000  ......!.....*...
0000040: 0000 0000 0900 0000 6f62 6a5f 6e61 6d65  ........obj_name
0000050: 32fe ffff ffff ffff ff00 0000 0000 0000  2...............
...
00001b0: ec01 010c 0000 00ce ff04 0400 0000 0000  ................
00001c0: 0000 0001 010c 0000 00ce ff03 0328 0100  .............(..
00001d0: 0000 0000 0003 0122 0100 0004 032b 0000  .......".....+..
00001e0: 0000 0000 000a 0000 006f 626a 5f63 7265  .........obj_cre
00001f0: 6174 65fe ffff ffff ffff ff00 0000 0000  ate.............
```

2、将资源文件导入指定资源池
```
rados -p test_rep_pool import pool_content
```

导入之前，我们对以上资源池数据进行清除，操作如下
```
# rados purge test_rep_pool --yes-i-really-really-mean-it
Warning: using slow linear search
Removed 5 objects
successfully purged pool test_rep_pool

# rados -p test_rep_pool import pool_content 
Importing pool
Write #-9223372036854775808:00000000:::obj_name2:head#
Write #-9223372036854775808:00000000:::obj_create:head#
Write #-9223372036854775808:00000000:::test_cp_obj:head#
Write #-9223372036854775808:00000000:::obj_name:head#
Write #-9223372036854775808:00000000:::obj_test:head#
```
