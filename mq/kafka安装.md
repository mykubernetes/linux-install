Kafka集群部署
============
一、 集群规划  
```
node001			node002			node003
zk			zk			zk
kafka			kafka		  	kafka
```
![image](https://github.com/mykubernetes/hadoop/blob/master/image/kafka.png)
jar包下载  
http://kafka.apache.org/downloads.html   

二、安装jdk  
1、卸载现有jdk  
（1）查询是否安装java软件：  
``` $ rpm -qa|grep java ```  
（2）如果安装的版本低于1.7，卸载该jdk：  
``` $ rpm -e 软件包 ```  
2、在linux系统下的opt目录中查看软件包是否导入成功。  
``` $ jdk-7u79-linux-x64.gz  hadoop-2.7.2.tar.gz ```  
3、解压jdk到/opt/module目录下  
``` $ tar -zxf jdk-7u79-linux-x64.gz -C /opt/module/ ```  
4、配置jdk环境变量  
（1）先获取jdk路径：  
``` $ pwd ```  
``` /opt/module/jdk1.7.0_79 ```  
（2）打开/etc/profile文件：  
```
$ vi /etc/profile
在profie文件末尾添加jdk路径：
##JAVA_HOME
export JAVA_HOME=/opt/module/jdk1.7.0_79
export PATH=$PATH:$JAVA_HOME/bin
```  
（3）让修改后的文件生效：  
``` $ source  /etc/profile ```   
（4）测试jdk安装成功  
```
$ java -version
$ java version "1.7.0_79"
```  

三、安装Zookeeper  
1）解压安装  
（1）解压zookeeper安装包到/opt/module/目录下  
``` $ tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/ ```  
（2）在/opt/module/zookeeper-3.4.10/这个目录下创建zkData  
``` $ mkdir -p zkData ```  
（3）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg  
``` $ mv zoo_sample.cfg zoo.cfg ```  

2）配置zoo.cfg文件
```
dataDir=/opt/module/zookeeper-3.4.10/zkData
增加如下配置
#######################cluster##########################
server.1=node001:2888:3888
server.2=node002:2888:3888
server.3=node003:2888:3888
集群模式下配置一个文件myid，这个文件在dataDir目录下
```  

3）集群操作  
（1）在/opt/module/zookeeper-3.4.10/zkData目录下创建一个myid的文件  
``` $ echo 1 > myid ```  
（2）拷贝配置好的zookeeper到其他机器上  
```
$ scp -r zookeeper-3.4.10/ root@node002:/opt/app/
$ scp -r zookeeper-3.4.10/ root@node003:/opt/app/
并分别修改myid文件中内容为2、3
```  
（3）分别启动zookeeper  
``` $ bin/zkServer.sh start ```  
       
（4）查看状态  
```
[root@node001 zookeeper-3.4.10]# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
	
[root@node002 zookeeper-3.4.10]# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: leader
	
[root@node003 zookeeper-3.4.5]# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
```  


四、Kafka集群部署    
 1）解压安装包  
``` $ tar -zxvf kafka_2.11-0.11.0.0.tgz -C /opt/module/ ```
  
 2）修改解压后的文件名称  
``` $ mv kafka_2.11-0.11.0.0/ kafka ```  
  
 3）在/opt/module/kafka目录下创建logs文件夹  
``` $ mkdir logs ```  
  
 4）修改配置文件  
 ```
$ cd config/
$ vi server.properties
输入以下内容：
#broker的全局唯一编号，不能重复
broker.id=0
#删除topic功能使能
delete.topic.enable=true
#处理网络请求的线程数量
num.network.threads=3
#用来处理磁盘IO的现成数量
num.io.threads=8
#发送套接字的缓冲区大小
socket.send.buffer.bytes=102400
#接收套接字的缓冲区大小
socket.receive.buffer.bytes=102400
#请求套接字的缓冲区大小
socket.request.max.bytes=104857600
#kafka运行日志存放的路径
log.dirs=/opt/module/kafka/logs
#topic在当前broker上的分区个数
num.partitions=1
#用来恢复和清理data下数据的线程数量
num.recovery.threads.per.data.dir=1
#segment文件保留的最长时间，超时将被删除
log.retention.hours=168
#配置连接Zookeeper集群地址
zookeeper.connect=node001:2181,node002:2181,node003:2181
```  
 5）配置环境变量  
```
$ cat /etc/profile
   #KAFKA_HOME
   export KAFKA_HOME=/opt/module/kafka
   export PATH=$PATH:$KAFKA_HOME/bin
$ source /etc/profile
```  
 6）分发安装包  
``` $ scp -rp /opt/module/kafka node02:/opt/module/ ```  
``` $ scp -rp /opt/module/kafka node03:/opt/module/ ```  
 7）分别在node002和node003上修改配置文件/opt/module/kafka/config/server.properties中的broker.id=1、broker.id=2  
	注：broker.id不得重复  
  
 8）启动集群  
      依次在node001、node002、node003节点上启动kafka  
``` $ bin/kafka-server-start.sh -daemon config/server.properties ```   
      
      
五、Kafka命令行操作  
  1）查看当前服务器中的所有topic  
``` $ bin/kafka-topics.sh --list --zookeeper node001:2181 ```  
  2）创建topic  
``` $ bin/kafka-topics.sh --create --zookeeper node001:2181 --replication-factor 3 --partitions 1 --topic first ```  
  选项说明：  
    --topic 定义topic名  
    --replication-factor  定义副本数  
    --partitions  定义分区数  
  3）删除topic  
``` $ bin/kafka-topics.sh --delete --zookeeper node001:2181 --topic first ```  
    需要server.properties中设置delete.topic.enable=true否则只是标记删除或者直接重启。  
  4）发送消息  
```
$ bin/kafka-console-producer.sh --broker-list node001:9092 --topic first
>hello world
>kafka  kafka
```  
  5）消费消息    
``` $ bin/kafka-console-consumer.sh --zookeeper node001:2181 --from-beginning --topic first ```  
  6）查看某个Topic的详情  
``` $ bin/kafka-topics.sh --topic first --describe --zookeeper node001:2181 ```  
