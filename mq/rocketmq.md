一、RocketMQ集群方式  
1、单个 Master模式  
这种方式风险较大，一旦Broker重启或者宕机时，会导致整个服务不可用，不建议线上环境使用  

2、多Master模式  
一个集群无Slave，全是Master，例如2个Master或者 3个Master  
优点：配置简单，单个 Master 宕机或重启维护对应用无影响，在磁盘配置为 RAID10时，即使机器宕机不可恢复情况下，由与 RAID10 磁盘非常可靠，消息也不会丢（异步刷盘丢失少量消息，同步刷盘一条不丢）。性能最高。  
缺点：单台机器宕机期间，这台机器上未被消费的消息在机器恢复之前不可订阅，消息实时性会受到受到影响。  


3、  多Master多Slave模式，异步复制  
每个Master配置一个Slave，有多对 Master-Slave，HA采用异步复制方式，主备有短暂消息延迟，毫秒级。  
优点：即使磁盘损坏，消息丢失的非常少，且消息实时性不会受影响，因为Master宕机后，消费者仍然可以从Slave消费，此过程对应用透明。不需要人工干预。性能同多Master 模式几乎一样。  
缺点：Master 宕机，磁盘损坏情况，会丢失少量消息。  

4、多Master多Slave模式，同步双写  
每个Master配置一个Slave，有多对 Master-Slave，HA 采用同步双写方式，主备都写成功，向应用返回成功。  
优点：数据与服务都无单点，Master 宕机情况下，消息无延迟，服务可用性与数据可用性都非常高  
缺点：性能比异步复制模式略低，大约低 10%左右，发送单个消息的 RT 会略高。目前主宕机后，备机不能自动切换为主机，后续会支持自动切换功能。  
 

以上Broker与Slave配对是通过指定相同的brokerName参数来配对，Master的BrokerId必须是 0，Slave的 rokerId必须是大与0的数。另外一个Master下面可以挂载多个Slave，同一Master下的多个Slave通过指定不同的 BrokerId 来区分。  

多主多从模式部署
---
https://github.com/apache/rocketmq  

1、多主多从模式分为俩种方式，第一种为异步复制，第二种为同步双写  
双主模式，文件夹配置为： conf/2m-noslave/  
多主多从模式（异步复制），文件夹配置为： conf/2m-2s-async/  
多主多从模式（同步双写），文件夹配置为： conf/2m-2s-sync/  

2、集群规划如下  
```
192.168.101.68  rocketmq-nameserver1、rocketmq-master1
192.168.101.69  rocketmq-nameserver2、rocketmq-master2
192.168.101.70  rocketmq-nameserver3、rocketmq-master1-slave
192.168.101.71  rocketmq-nameserver4、rocketmq-master2-slave
```  

3、添加hosts信息  

4、解压上传  
```
上传 alibaba-rocketmq-3.2.6.tar.gz 文件至/usr/local
# tar -zxvf alibaba-rocketmq-3.2.6.tar.gz -C /usr/local
# mv alibaba-rocketmq alibaba-rocketmq-3.2.6
# ln -s alibaba-rocketmq-3.2.6 rocketmq
# ll /usr/local
```  

5、创建存储目录  
```
# mkdir /usr/local/rocketmq/store
# mkdir /usr/local/rocketmq/store/commitlog
# mkdir /usr/local/rocketmq/store/consumequeue
# mkdir /usr/local/rocketmq/store/index
```  


6、RocketMQ 配置文件【四台机器】  
```
cd /usr/local/rocketmq/conf/
分别编辑配置文件
# vim /usr/local/rocketmq/conf/2m-2s-async/broker-a.properties
# vim /usr/local/rocketmq/conf/2m-2s-async/broker-b.properties
# vim /usr/local/rocketmq/conf/2m-2s-async/broker-a-s.properties
# vim /usr/local/rocketmq/conf/2m-2s-async/broker-b-s.properties
```  

1)broker-a.properties、broker-b.properties 配置如下：  
```
brokerClusterName=rocketmq-cluster               #所属集群名字
brokerName=broker-a|broker-b                     #broker 名字，注意此处不同的配置文件填写的不一样
brokerId=0                                       #0 表示 Master，>0 表示 Slave
namesrvAddr=rocketmq-nameserver1:9876;rocketmq-nameserver2:9876;rocketmq-nameserver3:9876;rocketmq-nameserver4:9876      #nameServer 地址，分号分割
defaultTopicQueueNums=4                          #在发送消息时，自动创建服务器不存在的 topic，默认创建的队列数
autoCreateTopicEnable=true                       #是否允许 Broker 自动创建 Topic，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true                 #是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
listenPort=10911                                 #Broker 对外服务的监听端口
deleteWhen=04                                    #删除文件时间点，默认凌晨 4 点
fileReservedTime=120                             #文件保留时间，默认 48 小时
mapedFileSizeCommitLog=1073741824                #commitLog 每个文件的大小默认 1G
mapedFileSizeConsumeQueue=300000                 #ConsumeQueue 每个文件默认存 30W 条，根据业务情况调整
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88                         #检测物理文件磁盘空间
storePathRootDir=/usr/local/rocketmq/store       #存储路径
storePathCommitLog=/usr/local/rocketmq/store/commitlog              #commitLog 存储路径
storePathConsumeQueue=/usr/local/rocketmq/store/consumequeue        #消费队列存储路径存储路径
storePathIndex=/usr/local/rocketmq/store/index                      #消息索引存储路径
storeCheckpoint=/usr/local/rocketmq/store/checkpoint                #checkpoint 文件存储路径
abortFile=/usr/local/rocketmq/store/abort                           #abort 文件存储路径
maxMessageSize=65536                             #限制的消息大小
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#Broker 的角色
#- ASYNC_MASTER 异步复制 Master
#- SYNC_MASTER 同步双写 Master
#- SLAVE
brokerRole=SYNC_MASTER
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=ASYNC_FLUSH
#checkTransactionMessageEnable=false
#sendMessageThreadPoolNums=128                  #发消息线程池数量
#pullMessageThreadPoolNums=128                  #拉消息线程池数量
```  

2)broker-a-s.properties、broker-b-s.properties 配置如下：  
```
brokerClusterName=rocketmq-cluster               #所属集群名字
brokerName=broker-a|broker-b                     #broker 名字，注意此处不同的配置文件填写的不一样，与 Master 通过 brokerName 来配对
brokerId=1                                       #0 表示 Master，>0 表示 Slave
namesrvAddr=rocketmq-nameserver1:9876;rocketmq-nameserver2:9876;rocketmq-nameserver3:9876;rocketmq-nameserver4:9876       #nameServer 地址，分号分割
defaultTopicQueueNums=4                          #在发送消息时，自动创建服务器不存在的 topic，默认创建的队列数
autoCreateTopicEnable=true                       #是否允许 Broker 自动创建 Topic，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true                 #是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
listenPort=10911                                 #Broker 对外服务的监听端口
deleteWhen=04                                    #删除文件时间点，默认凌晨 4 点
fileReservedTime=120                             #文件保留时间，默认 48 小时
mapedFileSizeCommitLog=1073741824                #commitLog 每个文件的大小默认 1G
mapedFileSizeConsumeQueue=300000                 #ConsumeQueue 每个文件默认存 30W 条，根据业务情况调整
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88                        #检测物理文件磁盘空间
storePathRootDir=/usr/local/rocketmq/store                       #存储路径
storePathCommitLog=/usr/local/rocketmq/store/commitlog           #commitLog 存储路径
storePathConsumeQueue=/usr/local/rocketmq/store/consumequeue     #消费队列存储路径存储路径
storePathIndex=/usr/local/rocketmq/store/index                   #消息索引存储路径
storeCheckpoint=/usr/local/rocketmq/store/checkpoint             #checkpoint 文件存储路径
abortFile=/usr/local/rocketmq/store/abort                        #abort 文件存储路径
maxMessageSize=65536                            #限制的消息大小
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#Broker 的角色
#- ASYNC_MASTER 异步复制 Master
#- SYNC_MASTER 同步双写 Master
#- SLAVE
brokerRole=SLAVE
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=ASYNC_FLUSH
#checkTransactionMessageEnable=false
#sendMessageThreadPoolNums=128                  #发消息线程池数量
#pullMessageThreadPoolNums=128                  #拉消息线程池数量
```  

7、修改日志配置文件  
```
#  mkdir -p /usr/local/rocketmq/logs
#  cd /usr/local/rocketmq/conf && sed -i 's#${user.home}#/usr/local/rocketmq#g' *.xml
```  

8、修改脚本启动参数根据情况配置使用内存大小  
```
# vim /usr/local/rocketmq/bin/runbroker.sh
#==============================================================================
# 开发环境 JVM Configuration
#==============================================================================
JAVA_OPT="${JAVA_OPT}  -server  -Xms1g  -Xmx1g  -Xmn512m  -XX:PermSize=128m  -XX:MaxPermSize=320m"


# vim /usr/local/rocketmq/bin/runserver.sh
JAVA_OPT="${JAVA_OPT}  -server  -Xms1g  -Xmx1g  -Xmn512m  -XX:PermSize=128m  -XX:MaxPermSize=320m"
```  

9、启动NameServer【四台机器】  
```
#  cd /usr/local/rocketmq/bin
#  nohup sh mqnamesrv &
```  

10、启动 Master1:BrokerServerA [192.168.101.68]  
```
#  cd /usr/local/rocketmq/bin
#  nohup sh mqbroker -c /usr/local/rocketmq/conf/2m-2s-async/broker-a.properties >/dev/null 2>&1 &
#  netstat -ntlp
#  jps
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/broker.log
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/namesrv.log
```  

11、启动 Master2:BrokerServerB [192.168.101.69]  
```
#  cd /usr/local/rocketmq/bin
#  nohup sh mqbroker -c /usr/local/rocketmq/conf/2m-2s-async/broker-b.properties >/dev/null 2>&1 &
#  netstat -ntlp
#  jps
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/broker.log
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/namesrv.log
```  

12、启动Master1-Slave:BrokerServerC [192.168.101.70]  
```
#  cd /usr/local/rocketmq/bin
#  nohup sh mqbroker -c /usr/local/rocketmq/conf/2m-2s-async/broker-a-s.properties >/dev/null 2>&1 &
#  netstat -ntlp
#  jps
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/broker.log
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/namesrv.log
```  

13、启动Master2-Slave:BrokerServerD  [192.168.101.71]  
```
#  cd /usr/local/rocketmq/bin
#  nohup sh mqbroker -c /usr/local/rocketmq/conf/2m-2s-async/broker-b-s.properties >/dev/null 2>&1 &
#  netstat -ntlp
#  jps
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/broker.log
#  tail -f -n 500 /usr/local/rocketmq/logs/rocketmqlogs/namesrv.log
```  


```
# sh bin/mqadmin clusterList -n "192.168.101.68:9876;192.168.101.70:9876"
RocketMQLog:WARN No appenders could be found for logger (io.netty.util.internal.PlatformDependent0).
RocketMQLog:WARN Please initialize the logger system properly.
#Cluster Name     #Broker Name            #BID  #Addr                  #Version                #InTPS(LOAD)       #OutTPS(LOAD) #PCWait(ms) #Hour #SPACE
rocketmq-cluster  broker-a                0     192.168.101.68:10911   V4_7_0                   0.00(0,0ms)         0.00(0,0ms)          0 441917.21 -1.0000
rocketmq-cluster  broker-a                1     192.168.101.69:11011   V4_7_0                   0.00(0,0ms)         0.00(0,0ms)          0 441917.21 0.1308
rocketmq-cluster  broker-b                0     192.168.101.70:10911   V4_7_0                   0.00(0,0ms)         0.00(0,0ms)          0 441917.21 -1.0000
rocketmq-cluster  broker-b                1     192.168.101.71:11011   V4_7_0  
```

14、服务停止（首先关闭4个BrokerServer，再关闭4个NameServer）：  
```
#  cd /usr/local/rocketmq/bin
#  sh mqshutdown broker
#  sh mqshutdown namesrv
```  

安装rocketmq-console
---
rocketmq-console是RocketMQ项目的扩展插件，是一个图形化管理控制台，提供Broker集群状态查看，Topic管理，Producer、Consumer状态展示，消息查询等常用功能，这个功能在安装好RocketMQ后需要额外单独安装、运行。

在本地有git+maven的开发环境可以自行在https://github.com/apache/rocketmq-externals克隆下载项目后，再通过maven打包rocketmq-console，或者可以在服务器上参考如下步骤进行。


1、安装maven
```
# wget http://mirrors.cnnic.cn/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
# tar zxvf apache-maven-3.5.4-bin.tar.gz

# vi /etc/profile
export MAVEN_HOME=/data/apache-maven-3.5.4
export PATH=$MAVEN_HOME/bin:$PATH

# source /etc/profile
# mvn -v
```

2、下载打包rocketmq-console  
在https://github.com/apache/rocketmq-externals页面下载zip包上传至任意一个服务器上。

```
解压
# unzip rocketmq-externals-master.zip
进入rocketmq-console目录
# cd rocketmq-externals-master/rocketmq-console/
打包
# mvn clean package -Dmaven.test.skip=true
```

3、启动rocketmq-console
```
# java -jar target/rocketmq-console-ng-1.0.1.jar --rocketmq.config.namesrvAddr='192.168.101.68:9876;192.168.101.70:9876'
```

4、验证

http://192.168.101.68:8080


http://rocketmq.apache.org/docs/quick-start/
https://github.com/apache/rocketmq/tree/master/docs/cn
https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console
