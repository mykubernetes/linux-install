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
1、下载activemq  
```
# wget http://archive.apache.org/dist/activemq/5.15.9/apache-activemq-5.15.9-bin.tar.gz
# tar xvf apache-activemq-5.15.9-bin.tar.gz
```  

2、配置activemq  
```
注释默认的kahanDB持久化存储
        <!--
        <persistenceAdapter>
            <kahaDB directory="${activemq.data}/kahadb"/>
        </persistenceAdapter>
        -->
	
	
```  
