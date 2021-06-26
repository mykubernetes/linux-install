Zookeeper概念简介和应用场景
===

概念简介

Zookeeper是一个分布式协调服务；就是为用户的分布式应用程序提供协调服务。
- A、zookeeper是为别的分布式程序服务的
- B、Zookeeper本身就是一个分布式程序（只要有半数以上节点存活，zk就能正常服务）
- C、Zookeeper所提供的服务涵盖：主从协调、服务器节点动态上下线、统一配置管理、分布式共享锁、统一名称服务……
- D、虽然说可以提供各种服务，但是zookeeper在底层其实只提供了两个功能：
  - 1)、管理(存储，读取)用户程序提交的数据；
  - 2)、并为用户程序提供数据节点监听服务；

Zookeeper集群的角色： Leader 和 follower

只要集群中有半数以上节点存活，集群就能提供服务

Zookeeper特性和数据结构
===

zookeeper特性
- 1、Zookeeper：一个leader，多个follower组成的集群
- 2、全局数据一致：每个server保存一份相同的数据副本，client无论连接到哪个server，数据都是一致的
- 3、分布式读写，更新请求转发，由leader实施
- 4、更新请求顺序进行，来自同一个client的更新请求按其发送顺序依次执行
- 5、数据更新原子性，一次数据更新要么成功，要么失败
- 6、实时性，在一定时间范围内，client能读到最新数据

zookeeper数据结构
- 1、层次化的目录结构，命名符合常规文件系统规范
- 2、每个节点在zookeeper中叫做znode,并且只有一个唯一的路径标识
- 3、节点Znode可以包含数据和子节点（但是EPHEMERAL类型的节点不能有子节点）
- 4、客户端应用可以在节点上设置监视器

节点类型
- 1、Znode有两种类型：
  - 短暂（ephemeral）（断开连接zookeeper自己删除记录）
  - 持久（persistent）（断开连接不删除）
- 2、Znode有四种形式的目录节点（默认是persistent ）
  - PERSISTENT
  - PERSISTENT_SEQUENTIAL（持久序列/test0000000019 ）
  - EPHEMERAL
  - EPHEMERAL_SEQUENTIAL
- 3、创建znode时设置顺序标识，znode名称后会附加一个值，顺序号是一个单调递增的计数器，由父节点维护
- 4、在分布式系统中，顺序号可以被用于为所有的事件进行全局排序，这样客户端可以通过顺序号推断事件的顺序

zookeeper原理
===
- Zookeeper虽然在配置文件中并没有指定master和slave,但是，zookeeper工作时，是有一个节点为leader，其他则为follower,Leader是通过内部的选举机制临时产生的

zookeeper的选举机制（全新集群paxos）
===

假设有五台服务器组成的zookeeper集群,它们的id从1-5,同时它们都是最新启动的,也就是没有历史数据,在存放数据量这一点上,都是一样的.假设这些服务器依序启动,来看看会发生什么.
- 1、服务器1启动,此时只有它一台服务器启动了,它发出去的报没有任何响应,所以它的选举状态一直是LOOKING状态
- 2、 服务器2启动,它与最开始启动的服务器1进行通信,互相交换自己的选举结果,由于两者都没有历史数据,所以id值较大的服务器2胜出,但是由于没有达到超过半数以上的服务器都同意选举它(这个例子中的半数以上是3),所以服务器1,2还是继续保持LOOKING状态.
- 3、服务器3启动,根据前面的理论分析,服务器3成为服务器1,2,3中的老大,而与上面不同的是,此时有三台服务器选举了它,所以它成为了这次选举的leader.
- 4、服务器4启动,根据前面的分析,理论上服务器4应该是服务器1,2,3,4中最大的,但是由于前面已经有半数以上的服务器选举了服务器3,所以它只能接收当小弟的命了.
- 5、服务器5启动,同4一样,当小弟.

非全新集群的选举机制(数据恢复)
===
当zookeeper运行了一段时间之后，有机器down掉，重新选举时，选举过程就相对复杂。

需要加入数据id、leader id和逻辑时钟。
- 数据id：数据新的id就大，数据每次更新都会更新id。
- Leader id：就是我们配置的myid中的值，每个机器一个。
- 逻辑时钟：这个值从0开始递增,每次选举对应一个值,也就是说: 如果在同一次选举中,那么这个值应该是一致的 ; 逻辑时钟值越大,说明这一次选举leader的进程更新.

选举的标准就变成：
- 1、逻辑时钟小的选举结果被忽略，重新投票
- 2、统一逻辑时钟后，数据id大的胜出
- 3、数据id相同的情况下，leader id大的胜出

根据这个规则选出leader。



分布式安装部署  
=============
0）首先安装jdk    
``` $ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/ ```  
JDK环境变量配置  
```
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
```  
1）解压安装  
（1）解压zookeeper安装包到/opt/module/目录下  
```
tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/
```  

（2）创建data目录和log目录
```
mkdir /opt/module/zookeeper-3.4.10/{data,logs}

```  

（3）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg  
```
mv zoo_sample.cfg zoo.cfg
```  

2）配置zoo.cfg文件  
（1）具体配置  
```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/module/zookeeper-3.4.10/data
dataLogDir=/opt/module/zookeeper-3.4.10/logs
clientPort=2181
maxClientCnxns=60
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
集群配置
#######################cluster##########################
server.1=node001:2888:3888
server.2=node002:2888:3888
server.3=node003:2888:3888
```

ZooKeeper配置详解
```
tickTime=2000
#ZooKeeper服务器之间或客户单与服务器之间维持心跳的时间间隔，单位是毫秒，默认为2000。

initLimit=10
#zookeeper接受客户端（这里所说的客户端不是用户连接zookeeper服务器的客户端,而是zookeeper服务器集群中连接到leader的follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。
#当已经超过10个心跳的时间（也就是tickTime）长度后 zookeeper 服务器还没有收到客户端的返回信息,那么表明这个客户端连接失败。总的时间长度就是 10*2000=20秒。

syncLimit=5
#标识ZooKeeper的leader和follower之间同步消息，请求和应答时间长度，最长不超过多少个tickTime的时间长度，总的时间长度就是5*2000=10秒。

dataDir=/opt/module/zookeeper-3.4.10/data
#存储内存数据库快照的位置；ZooKeeper保存Client的数据都是在内存中的，如果ZooKeeper节点故障或者服务停止，那么ZooKeeper就会将数据快照到该目录当中。

clientPort=2181
#ZooKeeper客户端连接ZooKeeper服务器的端口，监听端口

maxClientCnxns=60
#ZooKeeper可接受客户端连接的最大数量，默认为60

dataLogDir=/opt/module/zookeeper-3.4.10/logs
#如果没提供的话使用的则是dataDir。zookeeper的持久化都存储在这两个目录里。dataLogDir里是放到的顺序日志(WAL)。而dataDir里放的是内存数据结构的snapshot，便于快速恢复。为了达到性能最大化，一般建议把dataDir和dataLogDir分到不同的磁盘上，这样就可以充分利用磁盘顺序写的特性

autopurge.snapRetainCount=3
#ZooKeeper要保留dataDir中快照的数量

autopurge.purgeInterval=1
#ZooKeeper清楚任务间隔(以小时为单位)，设置为0表示禁用自动清除功能

server.1=localhost:2888:3888
#指定ZooKeeper集群主机地址及通信端口
#1 为集群主机的数字标识，一般从1开始，三台ZooKeeper集群一般都为123
#localhost 为集群主机的IP地址或者可解析主机名
#2888 端口用来集群成员的信息交换端口，用于ZooKeeper集群节点与leader进行信息同步
#3888 端口是在leader挂掉时或者刚启动ZK集群时专门用来进行选举leader所用的端口
```

添加zookeeper环境变量
```
cat << EOF >> /etc/profile

export ZOOKEEPER_HOME=/opt/module/zookeeper-3.4.10/
export PATH=\$PATH:\$ZOOKEEPER_HOME/bin
EOF

source /etc/profile
```


3）集群操作  
（1）在/opt/module/zookeeper-3.4.10/data/目录下创建一个myid的文件并配置 
```
touch /opt/module/zookeeper-3.4.10/data/myid
echo 1 > /opt/module/zookeeper-3.4.10/data/myid
```  
 
（2）拷贝配置好的zookeeper到其他机器上并修改myid
```
scp -r zookeeper-3.4.10/ root@node002:/opt/module/
scp -r zookeeper-3.4.10/ root@node003:/opt/module/
并分别修改myid文件中内容为2、3
```  

ZooKeeper执行程序简介
```
/opt/module/zookeeper-3.4.10/bin/ -l
total 44
-rwxr-xr-x 1 2002 2002  232 Mar  7 00:50 README.txt
-rwxr-xr-x 1 2002 2002 1937 Mar  7 00:50 zkCleanup.sh  
-rwxr-xr-x 1 2002 2002 1056 Mar  7 00:50 zkCli.cmd
-rwxr-xr-x 1 2002 2002 1534 Mar  7 00:50 zkCli.sh           #ZK客户端连接ZK的脚本程序
-rwxr-xr-x 1 2002 2002 1759 Mar  7 00:50 zkEnv.cmd
-rwxr-xr-x 1 2002 2002 2919 Mar  7 00:50 zkEnv.sh           #ZK变量脚本程序
-rwxr-xr-x 1 2002 2002 1089 Mar  7 00:50 zkServer.cmd
-rwxr-xr-x 1 2002 2002 6773 Mar  7 00:50 zkServer.sh        #ZK启动脚本程序
-rwxr-xr-x 1 2002 2002  996 Mar  7 00:50 zkTxnLogToolkit.cmd
-rwxr-xr-x 1 2002 2002 1385 Mar  7 00:50 zkTxnLogToolkit.sh
```

zkServer.sh启动文件
```
/opt/module/zookeeper-3.4.10/bin/zkServer.sh 
ZooKeeper JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Usage: /opt/module/zookeeper-3.4.10/bin/zkServer.sh {start|start-foreground|stop|restart|status|upgrade|print-cmd}

#关闭ZK服务
/opt/module/zookeeper-3.4.10/bin/zkServer.sh stop

#启动ZK服务
/opt/module/zookeeper-3.4.10/bin/zkServer.sh start

#启动ZK服务并打印启动信息到标准输出，方便于排错
/opt/module/zookeeper-3.4.10/bin/zkServer.sh start-foreground

#重启ZK服务
/opt/module/zookeeper-3.4.10/bin/zkServer.sh restart

#查看ZK服务状态
/opt/module/zookeeper-3.4.10/bin/zkServer.sh status
```

4）分别启动zookeeper  
 ``` # bin/zkServer.sh start ```  

5）查看状态  
```
# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
	
# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: leader
	
# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
```  

zkCli.sh客户端连接
```
/opt/module/zookeeper-3.4.10/bin/zkCli.sh -server localhost:2181
#连接ZK服务
#-server：指定ZK服务
#localhost：指定要连接的主机
#2181：指定连接端口，默认不加参数会连接到本机的2181端口

#使用?号或者help可以获取帮助命令
[zk: localhost:2181(CONNECTED) 0] ?
ZooKeeper -server host:port cmd args
        stat path [watch]                       #获取节点数据内容和属性信息,[watch] 观察模式，有改变则会被通知，watch一次有效一次
        set path data [version]                 #更新节点数据内容
        ls path [watch]                         #列出节点,[watch] 观察模式，有改变则会被通知，watch一次有效一次
        delquota [-n|-b] path
        ls2 path [watch]                        #列出节点数据内容和属性信息,[watch] 观察模式，有改变则会被通知，watch一次有效一次
        setAcl path acl                         #设置ACL访问控制权限
        setquota -n|-b val path
        history                                 #获取历史命令记录
        redo cmdno
        printwatches on|off
        delete path [version]                   #删除节点，version表示数据版本
        sync path                               #同步节点
        listquota path
        rmr path                                #删除节点，忽略节点下的子节点
        get path [watch]                        #读取数据内容和属性信息,[watch] 观察模式，有改变则会被通知，watch一次有效一次
        create [-s] [-e] path data acl          #创建节点命令 -s 序列化【避免重复】 -e 临时数据【常用】 ,acl权限控制
        addauth scheme auth
        quit                                    #退出当前ZK连接
        getAcl path                             #获取节点ACL策略信息
        close                                   #断开当前ZK连接，但不退出窗口
        connect host:port                       #断开当前ZK连接后，可使用connect加参数来连接指定ZK节点
```

数据的属性说明
---
| 属性 | 描述 |
|------|------|
| czxid | 节点被创建的Zxid值 |
| mzxid | 节点被修改的Zxid值 |
| ctime | 节点被创建的时间 |
| mtime | 节点最后一次被修改的时间 |
| versoin | 节点被修改的版本号 |
| cversion | 节点的所拥有子节点被修改的版本号 |
| aversion | 节点的ACL被修改的版本号 |
| emphemeralOwner | 如果此节点为临时节点，那么它的值为这个节点拥有者的会话ID；否则，它的值为0 |
| dataLength | 节点数据域的长度 |
| numChildren | 节点拥有的子节点个数 |


创建ZooKeeper持久节点
```
#创建持久节点permanent，关联字符串permanent
[zk: localhost:2181(CONNECTED) 0] create /permanent "permanent"
Created /permanent

#在持久节点permanent下创建子目录zk-node1和zk-nod2
[zk: localhost:2181(CONNECTED) 1] create /permanent/zk_node1 "zk_node1"
Created /permanent/zk_node1
[zk: localhost:2181(CONNECTED) 2] create /permanent/zk_node2 "zk_node2"
Created /permanent/zk_node2

#查看创建的zk数据文件
[zk: localhost:2181(CONNECTED) 3] ls /
[zookeeper, permanent]
[zk: localhost:2181(CONNECTED) 4] ls /permanent
[zk_node1, zk_node2]

[zk: localhost:2181(CONNECTED) 4] get /permanent
yang01
cZxid = 0x100000018
ctime = Sat May 26 15:33:47 CST 2018
mZxid = 0x100000018
mtime = Sat May 26 15:33:47 CST 2018
pZxid = 0x100000018
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0                     # 代表持久节点 
dataLength = 6
numChildren = 0
```

创建ZooKeeper顺序节点
```
#创建顺序节点order，关联字符串order，创建好之后并不会以我们创建的order命名，zk会自动在后面加上一排递增数字来显示此文件夹，递增数据不会从重复
[zk: localhost:2181(CONNECTED) 5] create -s /order "order"
Created /order0000000004
[zk: localhost:2181(CONNECTED) 6] ls /
[zookeeper, permanent, order0000000004]

#我们再次创建一个顺序节点，会发现后面的增至数字默认加1，并没有重复
[zk: localhost:2181(CONNECTED) 8] create -s /tow_order "two_order"
Created /tow_order0000000005
[zk: localhost:2181(CONNECTED) 9] ls /
[tow_order0000000005, zookeeper, permanent, order0000000004]

#创建顺序节点order的子节点
[zk: localhost:2181(CONNECTED) 10] create -s /order0000000004/order_node1 "order_node1"
Created /order0000000004/order_node10000000000
```

创建ZooKeeper临时节点
```
#创建临时节点temp

[zk: localhost:2181(CONNECTED) 15] create -e /temp "temp"
Created /temp
[zk: localhost:2181(CONNECTED) 16] ls /             #查看已经创建完成的临时节点temp
[tow_order0000000005, temp, zookeeper, permanent, order0000000004]

#在临时节点temp中创建子目录，
[zk: localhost:2181(CONNECTED) 17] create -e /temp/two_temp "tow_temp"
Ephemerals cannot have children: /temp/two_temp     #你会发现创建子目录，ZK给你报错误说”临时节点不允许子目录存在“，我们上面也说过了，临时节点不允许存在子目录
[zk: localhost:2181(CONNECTED) 18] ls /temp         #查看临时节点/temp下，并没有我们所创建的two_temp子目录
[]

[zk: localhost:2181(CONNECTED) 19] get /temp
temp
cZxid = 0x100000019
ctime = Sat May 26 15:33:55 CST 2018
mZxid = 0x100000019
mtime = Sat May 26 15:33:55 CST 2018
pZxid = 0x100000019
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x1639b3087ac0002                   # 代表临时节点  
dataLength = 6
numChildren = 0

#测试临时节点
#创建的临时节点如果当前客户端断开了连接后临时节点会自动消失，而持久节点和顺序节点则需要使用删除命令来消失
#退出当前ZK连接，再次连接到ZK
[zk: localhost:2181(CONNECTED) 19] quit                                 #退出当前ZK连接
/application/zookeeper-3.4.14/bin/zkCli.sh -server localhost:2181       #再次连接到ZK

#查看临时目录是否存在
[zk: localhost:2181(CONNECTED) 0] ls /
[tow_order0000000005, zookeeper, permanent, order0000000004]            #当我们结束当
```

读取节点命令 读取节点命令有以下四个
```
ls path [watch]
ls2 path [watch]
get path [watch]
stat path [watch]
```

ls path [watch]
```
ls只显示列出目录下的数据节点
[zk: localhost:2181(CONNECTED) 2] ls /          #列出当前/下的数据节点
[tow_order0000000005, zookeeper, permanent, order0000000004]
[zk: localhost:2181(CONNECTED) 3] ls /permanent #列出permanent下的数据节点
[zk_node1, zk_node2]
[zk: localhost:2181(CONNECTED) 4] ls /order0000000004  #列出order0000000004下的数据节点
[order_node10000000000]
```

ls2 path [watch]
```
ls2列出节点数据内容和属性信息
[zk: localhost:2181(CONNECTED) 7] ls2 /permanent
[zk_node1, zk_node2]                            #ls2命令同样可以列出permanent下的子目录
cZxid = 0x2e                                    #创建permanent节点时生成的事物ID
ctime = Sat Jun 22 21:00:00 CST 2019            #创建permanent节点时的时区及时间
mZxid = 0x2e                                    #修改permanent节点后改变的事物ID
mtime = Sat Jun 22 21:00:00 CST 2019            #修改permanent节点后的时区及时间
pZxid = 0x30
cversion = 2                                    #permanent的znode子节点版本
dataVersion = 0                                 #permanent数据节点版本信息
aclVersion = 0                                  #permanent的znode的ACL版本
ephemeralOwner = 0x0
dataLength = 9                                  #permanent数据节点的关联字符长度
numChildren = 2                                 #permanent数据节点下有两个子节点

#列出/下的数据内容及属性信息
[zk: localhost:2181(CONNECTED) 11] ls2 /
[tow_order0000000005, zookeeper, permanent, order0000000004]
cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0x37
cversion = 10
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 4
```

get path [watch]
```
get读取数据内容和属性信息
可以看到get不像ls2一样更够列出/下的文件名称，只显示当前节点的属性信息
[zk: localhost:2181(CONNECTED) 12] get /permanent
permanent                                        # 内容
cZxid = 0x2e                                     # 创建数据时的事物编号
ctime = Sat Jun 22 21:00:00 CST 2019             # 创建时间
mZxid = 0x2e                                     # 修改数据时的事物编号
mtime = Sat Jun 22 21:00:00 CST 2019             # 修改时间
pZxid = 0x30                                     # 持久化事物编号
cversion = 2                                     # 创建版本号
dataVersion = 0                                  # 数据版本
aclVersion = 0                                   # 权限版本
ephemeralOwner = 0x0                             # 持久接待
dataLength = 9                                   # 数据长度
numChildren = 2                                  # 子节点数

获取/的数据内容和属性信息
[zk: localhost:2181(CONNECTED) 13] get /
cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0x37
cversion = 10
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 4
```

stat path [watch]
```
stat命令和get命令基本一致
[zk: localhost:2181(CONNECTED) 14] stat /permanent
cZxid = 0x2e
ctime = Sat Jun 22 21:00:00 CST 2019
mZxid = 0x2e
mtime = Sat Jun 22 21:00:00 CST 2019
pZxid = 0x30
cversion = 2
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 9
numChildren = 2

[zk: localhost:2181(CONNECTED) 15] stat /
cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0x37
cversion = 10
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 4
```

set path data [version]  
set命令用来更新节点数据内容 先使用ls2获取当前节点的属性信息
```
[zk: localhost:2181(CONNECTED) 16] ls /permanent        #当前permanent下有两个数据文件
[zk_node1, zk_node2]
[zk: localhost:2181(CONNECTED) 17] ls2 /permanent       #列出permanent的属性信息，等下更新完成之后permanent的属性信息会改变
[zk_node1, zk_node2]
cZxid = 0x2e
ctime = Sat Jun 22 21:00:00 CST 2019
mZxid = 0x2e
mtime = Sat Jun 22 21:00:00 CST 2019
pZxid = 0x30
cversion = 2                                            
dataVersion = 0                                     
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 9
numChildren = 2
```
更新数据节点
```
[zk: localhost:2181(CONNECTED) 18] create /permanent/zk_node3 "zk_node3"        #在permanent下再创建一个数据节点zk_node3
Created /permanent/zk_node3

[zk: localhost:2181(CONNECTED) 21] set /permanent "permanent_set"               #更新permanent的关联符号为"permanent_set"
cZxid = 0x2e
ctime = Sat Jun 22 21:00:00 CST 2019
mZxid = 0x3a                                                                    #可以看到事物ID比着创建时的事物ID已经发生改变
mtime = Sat Jun 22 21:47:29 CST 2019                                            #时间也已经发生改变
pZxid = 0x39
cversion = 3                                                                   #permanent的znode子节点版本也已经发生改变
dataVersion = 1                                                                #permanent的数据版本也已经发生改变
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 13                                                                #permanent关联字符串长也已经发生改变
numChildren = 3   
```

delete path [version] 持久节点以及顺序节点只有使用删除命令才能够消失 使用delete命令来删除持久节点permanent 注意：如果数据节点下有子目录的时候必须先删除子目录，然后在删除父目录，否则使用delete是不可取的 例子：
```
[zk: localhost:2181(CONNECTED) 23] delete /permanent
Node not empty: /permanent              #ZK会告诉你节点非空，所以必须要先删除permanent下的子节点才能够删除permanent节点

[zk: localhost:2181(CONNECTED) 24] delete /permanent/zk_node1
[zk: localhost:2181(CONNECTED) 25] delete /permanent/zk_node2
[zk: localhost:2181(CONNECTED) 26] delete /permanent/zk_node3
[zk: localhost:2181(CONNECTED) 27] delete /permanent        #当删除了permanent后，再次删除permanet则正常
[zk: localhost:2181(CONNECTED) 28] ls /                     #可以看到/下已经没有了permanent数据节点
[tow_order0000000005, zookeeper, order0000000004]
```

rmr path rmr也同时删除节点命令，但它和delete的区别在于，它会忽略节点下的子目录，直接递归删除数据节点下的所有目录及数据节点
```
[zk: localhost:2181(CONNECTED) 31] ls /
[tow_order0000000005, zookeeper, order0000000004]

#删除顺序节点order0000000004,可以看到该数据节点下存在order_node10000000000子目录
[zk: localhost:2181(CONNECTED) 33] ls /order0000000004
[order_node10000000000]

[zk: localhost:2181(CONNECTED) 34] rmr /order0000000004     #使用rmr命令可以直接递归删除该数据节点
[zk: localhost:2181(CONNECTED) 35] ls /
[tow_order0000000005, zookeeper]
```



节点的值变化监听  
```
在一台主机上注册监听/app1节点数据变化
[zk: localhost:2181(CONNECTED) 26] get /app1 watch

在另一台主机上修改/app1节点的数据
[zk: localhost:2181(CONNECTED) 5] set /app1  777

观察监听主机收到数据变化的监听
WATCHER::
WatchedEvent state:SyncConnected type:NodeDataChanged path:/app1
```  

节点的子节点变化监听（路径变化）  
```
在一台主机上注册监听/app1节点的子节点变化
[zk: localhost:2181(CONNECTED) 1] ls /app1 watch
[aa0000000001, server101]

在另一台主机/app1节点上创建子节点
[zk: localhost:2181(CONNECTED) 6] create /app1/bb 666
Created /app1/bb

观察监听主机收到子节点变化的监听
WATCHER::
WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/app1
```  

监控ZK的四字命令
---
ZooKeeper支持某些特定的四字命令与其交互，他们大多数是查询命令，用来获取ZK服务当前状态及相关信息。用户在客户端可通过telnet或nc向ZooKeeper提交相应的命令 可用的四字命令如下：
```
ruok：测试是否启动了ZooKeeper
stat：查询当前连接的端口及IP和其它信息
srvr：显示当前ZK服务的信息
conf：输出ZK相关的服务配置相信信息
cons：列出所有连接到ZK服务器的客户端的完全连接/会话详细信息
wchs：列出watch的详细信息
envi：输出关于ZK服务的环境详细信息，相当于linux系统中的env
dump：列出未经处理的回话和临时节点
reqs：列出未处理的请求
mntr：列出一些监控信息
```

ruok 测试是否启动了ZooKeeper
```
telnet示范
#使用telnet来连接本地的ZK端口
telnet localhost 2181
Trying ::1...
Connected to localhost.
Escape character is '^]'.
ruok                                    #连接成功后输入ruok，可得到ZK服务的回应信息
imokConnection closed by foreign host.  #它回应给你imokConnecntion，我已连接

nc示范
#使用nc来连接到指定的ZK服务器
nc localhost 2181       
ruok            #输入ruok
imok            #ZK服务器回应imok
Ncat: Broken pipe.
```

stat 查询当前连接的端口及IP和其它信息
```
nc localhost 2181
stat                #输入stat
Zookeeper version: 3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT       #当前ZK版本和构建时间，我那了我们线上在用的一台设备，所以跟你们使用的版本不一致
Clients:            #以下是已连接的客户端的节点信息
 /10.150.50.38:59627[1](queued=0,recved=206423,sent=206423)
 /10.150.50.38:59635[1](queued=0,recved=206426,sent=206426)
 /10.150.50.40:22297[1](queued=0,recved=1348114,sent=1348114)
 /0:0:0:0:0:0:0:1:51498[0](queued=0,recved=1,sent=0)
 /10.150.50.38:59631[1](queued=0,recved=206435,sent=206435)
Latency min/avg/max: 0/0/10     #延迟分别是最小值、平均值、最大值
Received: 1967678               #收到的请求数
Sent: 1967679                   #返回发出的请求数
Connections: 5                  #已连接当前ZK的客户端主机数量
Outstanding: 0
Zxid: 0x1e000002a7              #事物ID
Mode: follower                  #当前节点的集群状态为follower
Node count: 365                 
Ncat: Broken pipe.
```

srvr 显示当前ZK服务的信息，跟stat很相似，但是它只显示ZK的自身信息
```
nc localhost 2181
srvr                            #输入srvr
Zookeeper version: 3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT
Latency min/avg/max: 0/0/10
Received: 1967953
Sent: 1967954
Connections: 5
Outstanding: 0
Zxid: 0x1e000002a7
Mode: follower
Node count: 365
Ncat: Broken pipe.
```

conf 输出ZK相关的服务配置相信信息
```
nc localhost 2181
conf                            #输入conf，可以显示当前ZK的配置信息
clientPort=2181
dataDir=/zk_data/zk1/version-2
dataLogDir=/zk_data/zk1/version-2
tickTime=2000
maxClientCnxns=60
minSessionTimeout=4000
maxSessionTimeout=40000
serverId=1
initLimit=10
syncLimit=5
electionAlg=3
electionPort=4181
quorumPort=3181
peerType=0
Ncat: Broken pipe.
```

cons 列出所有连接到ZK服务器的客户端的完全连接/会话详细信息
```
nc localhost 2181
cons                        #输入cons，可以显示连接到当前ZK服务器的客户端的所有信息，下面的一个/0:0:0:0:0:0:0:1:51514[0](queued=0,recved=1,sent=0)，代表本机也算作是一个连接
 /10.150.50.38:59627[1](queued=0,recved=206476,sent=206476,sid=0x16adec1f078000d,lop=PING,est=1559147830451,to=30000,lcxid=0x0,lzxid=0xffffffffffffffff,lresp=1561214262376,llat=0,minlat=0,avglat=0,maxlat=5)
 /10.150.50.38:59635[1](queued=0,recved=206479,sent=206479,sid=0x16adec1f078000f,lop=PING,est=1559147830758,to=30000,lcxid=0x0,lzxid=0xffffffffffffffff,lresp=1561214264713,llat=0,minlat=0,avglat=0,maxlat=4)
 /0:0:0:0:0:0:0:1:51514[0](queued=0,recved=1,sent=0)
 /10.150.50.40:22297[1](queued=0,recved=1348381,sent=1348381,sid=0x16adec1f0780000,lop=PING,est=1558515870093,to=6000,lcxid=0x110,lzxid=0xffffffffffffffff,lresp=1561214271686,llat=0,minlat=0,avglat=0,maxlat=10)
 /10.150.50.38:59631[1](queued=0,recved=206488,sent=206488,sid=0x16adec1f078000e,lop=PING,est=1559147830593,to=30000,lcxid=0x0,lzxid=0xffffffffffffffff,lresp=1561214263232,llat=0,minlat=0,avglat=0,maxlat=5)
Ncat: Broken pipe.
```

wchs 列出watch的详细信息
```
nc localhost 2181
wchs                            #输入wchs
1 connections watching 2 paths  #一个连接，两个数据节点
Total watches:2
Ncat: Broken pipe.
```

envi 列出当前jdk，以及zk所用到的jdk配置信息
```
nc localhost 2181
envi                        #输入env，列出当前jdk，以及zk所用到的jdk配置信息
Environment:
zookeeper.version=3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT
host.name=kafka01
java.version=1.8.0_162
java.vendor=Oracle Corporation
java.home=/usr/local/jdk1.8.0_162/jre
java.class.path=/usr/local/zookeeper/bin/../build/classes:/usr/local/zookeeper/bin/../build/lib/*.jar:/usr/local/zookeeper/bin/../lib/slf4j-log4j12-1.6.1.jar:/usr/local/zookeeper/bin/../lib/slf4j-api-1.6.1.jar:/usr/local/zookeeper/bin/../lib/netty-3.10.5.Final.jar:/usr/local/zookeeper/bin/../lib/log4j-1.2.16.jar:/usr/local/zookeeper/bin/../lib/jline-0.9.94.jar:/usr/local/zookeeper/bin/../zookeeper-3.4.10.jar:/usr/local/zookeeper/bin/../src/java/lib/*.jar:/usr/local/zookeeper/bin/../conf:::/usr/local/jdk1.8.0_162/lib/dt.jar:/usr/local/jdk1.8.0_162/lib/tools.jar
java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
java.io.tmpdir=/tmp
java.compiler=<NA>
os.name=Linux
os.arch=amd64
os.version=3.10.0-514.21.1.el7.x86_64
user.name=root
user.home=/root
user.dir=/root
Ncat: Broken pipe.
```

dump 列出未经处理的回话和临时节点
```
nc localhost 2181
dump                        #输入dump，列出未处理的回话和临时节点
SessionTracker dump:
org.apache.zookeeper.server.quorum.LearnerSessionTracker@7241fb18
ephemeral nodes dump:
Sessions with Ephemerals (3):
0x16adec1f0780000:
        /brokers/ids/2
0x36adec1f32e0003:
        /brokers/ids/1
0x26adec1f3160000:
        /controller
        /brokers/ids/0
Ncat: Broken pipe.
```

reqs 列出未处理的请求
```
nc localhost 2181
reqs                    #输入reqs，当前得到的为空值，则代表没有未处理的请求
Ncat: Broken pipe.
```

mntr 列出一些监控信息
```
nc localhost 2181
mntr                                    #输入mntr，得到一监控信息
zk_version      3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT      #ZK版本及构建时间
zk_avg_latency  0                       #ZK平均延时
zk_max_latency  10                      #ZK最大延时
zk_min_latency  0                       #ZK最小延时
zk_packets_received     1968459         #接收到客户端请求的包数量
zk_packets_sent 1968460                 #发送给客户端的包数量，主要是响应和通知
zk_num_alive_connections        5       #检测存活的节点数量
zk_outstanding_requests 0               #排队请求的数量，当ZooKeeper超过了它的处理能力时，这个值会增大，建议设置报警阀值为10
zk_server_state follower                #当前ZK是什么状态节点
zk_znode_count  365                     #Znodes的数量
zk_watch_count  3                       #watches的数量
zk_ephemerals_count     4               #临时节点的数量
zk_approximate_data_size        23709   #数据大小
zk_open_file_descriptor_count   37      #打开文件描述符数量
zk_max_file_descriptor_count    65536   #最大文件描述符数量
Ncat: Broken pipe.
```

ACL
===

ACL 权限控制，使用：`schema:id:permission` 来标识，主要涵盖 3 个方面：
- 权限模式（Schema）：代表采用的某种权限机制
- 授权对象（ID）: 代表允许访问的用户
- 权限（Permission）: 权限组合字符串

其特性如下：
- ZooKeeper的权限控制是基于每个znode节点的，需要对每个节点设置权限
- 每个znode支持设置多种权限控制方案和多个权限
- 子节点不会继承父节点的权限，客户端无权访问某节点，但可能可以访问它的子节点

1、schema：ZooKeeper内置了一些权限控制方案，可以用以下方案为每个节点设置权限：
| 方案 | 描述 |
|------|-----|
| world | world下只有一个id,即只有一个用户，也就是anyone,那么组合的写法就是`world:anyone:[permissions]` |
| ip | 当设置为ip指定的ip地址，此时限制ip进行访问，比如`ip:192.168.1.1:[permissions]` |
| auth | 代表认证登录，需要注册用户有权限就可以，形式为`auth:user:password:[permissions]` |
| digest | 需要对密码加密才能访问，组合形式为`digest:username:BASE64(SHA1(password)):[permissions]` |
- auth与digest区别是auth是明文密码digest是密文密码，`setAcl /path auth:lee:lee:cdrwa`与`setAcl /path digest:leeBASE64(SHA1(password)):cdrwa`是等价的addauth digest lee:lee后等能操作指定节点的权限


2、id：
| 权限模式 | 授权对象 |
|---------|---------|
| IP | 通常是一个IP地址或一个ip段，列入"192.168.0.110"或"192.168.0.1/24" |
| Digest | 自定义，通常是"username:BASE64(SHA-1(username:password))",列如"foo:kWN6aNSbjcKWPqjiV7cg0N24raU=" |
| World | 只有一个ID: "anyone" |
| Super | 与Digest模式一致 |


3、权限permission：
| 权限 | ACL简写 | 描述 |
|-----|---------|------|
| CREATE | c | 可以创建子节点 |
| DELETE | d | 可以删除子节点（仅下一级节点） |
| READ | r | 可以读取节点数据及显示子节点列表 |
| WRITE | w | 可以设置节点数据 |
| ADMIN | a | 可以设置节点访问控制列表权限 |


一、权限相关命令
| 命令 | 使用方式 | 描述 |
|-----|----------|-----|
| getAcl | `getAcl <path>` | 读取ACL权限 |
| setAcl | `setAcl <path> <acl>` | 设置ACL权限 |
| addauth | `addauth <scheme> <auth>` | 添加认证用户 |

