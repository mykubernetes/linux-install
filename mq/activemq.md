官方下载地址
http://activemq.apache.org/components/classic/download/  

http://activemq.apache.org/persistence  

一、 集群规划  
---
```
node001			node002			node003
zk       	  zk          zk
activemq		activemq    activemq
```

二、安装jdk  
---
1、卸载现有jdk  
（1）查询是否安装java软件：  
``` # rpm -qa|grep java ```  
（2）如果安装的版本低于1.7，卸载该jdk：  
``` # rpm -e 软件包 ```  
2、在linux系统下的opt目录中查看软件包是否导入成功。  
``` # jdk-7u79-linux-x64.gz  hadoop-2.7.2.tar.gz ```  
3、解压jdk到/opt/module目录下  
``` # tar -zxf jdk-7u79-linux-x64.gz -C /opt/module/ ```  
4、配置jdk环境变量  
（1）先获取jdk路径：  
``` # pwd ```  
``` /opt/module/jdk1.7.0_79 ```  
（2）打开/etc/profile文件：  
```
# vi /etc/profile
在profie文件末尾添加jdk路径：
##JAVA_HOME
export JAVA_HOME=/opt/module/jdk1.7.0_79
export PATH=$PATH:$JAVA_HOME/bin
```  
（3）让修改后的文件生效：  
``` # source  /etc/profile ```   
（4）测试jdk安装成功  
```
# java -version
# java version "1.7.0_79"
```  

三、安装Zookeeper  
---
1、解压安装  
（1）解压zookeeper安装包到/opt/module/目录下  
``` $ tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/ ```  
（2）在/opt/module/zookeeper-3.4.10/这个目录下创建zkData  
``` $ mkdir -p zkData ```  
（3）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg  
``` $ mv zoo_sample.cfg zoo.cfg ```  

2、配置zoo.cfg文件
```
dataDir=/opt/module/zookeeper-3.4.10/zkData
增加如下配置
#######################cluster##########################
server.1=node001:2888:3888
server.2=node002:2888:3888
server.3=node003:2888:3888
集群模式下配置一个文件myid，这个文件在dataDir目录下
```  

3、集群操作  
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

四、安装activemq  
---
1、3台机器分别下载activemq  
```
# wget http://archive.apache.org/dist/activemq/5.15.9/apache-activemq-5.15.9-bin.tar.gz
# tar xvf apache-activemq-5.15.9-bin.tar.gz
```  

2、3台机器分别配置activemq  
参考官网配置http://activemq.apache.org/replicated-leveldb-store.html  
```
vim apache-activemq-5.15.9/conf/activemq.xml
注释默认的kahanDB持久化存储
        <!--
        <persistenceAdapter>
            <kahaDB directory="${activemq.data}/kahadb"/>
        </persistenceAdapter>
        -->
	
       <persistenceAdapter>
          <replicatedLevelDB  
            directory="${activemq.data}/leveldb"  
            replicas="3"  
            bind="tcp://0.0.0.0:0"  
            zkAddress="192.168.101.69:2181,192.168.101.70:2181,192.168.101.71:2181"   
            zkPath="/activemq/leveldb-stores"  
            hostname="192.168.101.69"  
         />
       </persistenceAdapter>
```  
- directory： 存储数据的路径
- replicas：集群中的节点数【(replicas/2)+1公式表示集群中至少要正常运行的服务数量】，3台集群那么允许1台宕机， 另外两台要正常运行  
- bind：当该节点成为master后，它将绑定已配置的地址和端口来为复制协议提供服务。还支持使用动态端口。只需使用tcp://0.0.0.0:0进行配置即可，默认端口为61616。 
- zkAddress：ZK的ip和port， 如果是集群，则用逗号隔开
- zkPassword：当连接到ZooKeeper服务器时用的密码，没有密码则不配置。 
- zkPah：ZK选举信息交换的存贮路径，启动服务后actimvemq会到zookeeper上注册生成此路径   
- hostname： ActiveMQ所在主机的IP

3、修改监听地址和端口号保持默认，不用修改  
```
vim activemq/conf/jetty.xml
    <bean id="jettyPort" class="org.apache.activemq.web.WebConsolePort" init-method="start">
             <!-- the default port number for the web console -->
        <property name="host" value="0.0.0.0"/>
        <property name="port" value="8161"/>
    </bean>
```  

4、3台机器分别启动activemq  
```
./activemq start
```  

5、进入zk查看  
```
[zk: localhost:2181(CONNECTED) 11] get /activemq/leveldb-stores/00000000000
{"id":"localhost","container":null,"address":"tcp://192.168.101.69:46019","position":-1,"weight":1,"elected":"0000000000"}
cZxid = 0x400000004
ctime = Sat Jul 20 23:13:08 EDT 2019
mZxid = 0x40000000c
mtime = Sat Jul 20 23:13:19 EDT 2019
pZxid = 0x400000004
cversion = 0
dataVersion = 4
aclVersion = 0
ephemeralOwner = 0x16c1247c8f80000
dataLength = 122
numChildren = 0

[zk: localhost:2181(CONNECTED) 12] get /activemq/leveldb-stores/00000000001
{"id":"localhost","container":null,"address":null,"position":-1,"weight":1,"elected":null}
cZxid = 0x400000007
ctime = Sat Jul 20 23:13:18 EDT 2019
mZxid = 0x40000000a
mtime = Sat Jul 20 23:13:18 EDT 2019
pZxid = 0x400000007
cversion = 0
dataVersion = 2
aclVersion = 0
ephemeralOwner = 0x26c1247c9a80000
dataLength = 90
numChildren = 0

[zk: localhost:2181(CONNECTED) 13] get /activemq/leveldb-stores/00000000002
{"id":"localhost","container":null,"address":null,"position":-1,"weight":1,"elected":null}
cZxid = 0x40000000e
ctime = Sat Jul 20 23:13:31 EDT 2019
mZxid = 0x40000000e
mtime = Sat Jul 20 23:13:31 EDT 2019
pZxid = 0x40000000e
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x16c1247c8f80001
dataLength = 90
numChildren = 0
```  
