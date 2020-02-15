1、安装java
---
```
1、解压缩jdk
# tar xvf jdk-8u141-linux-x64.tar.gz

2、配置环境变量
# vim /etc/profile
export JAVA_HOME=/data/software/java8
export JRE_HOME=/data/software/java8/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib 
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

# source /etc/profile
```

2、安装maven
---
```
1、下载
# wget http://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz

2、解压
# tar xvf apache-maven-3.6.3-bin.tar.gz

3、配置环境变量
# vim /etc/profile
  export MAVEN_HOME=/opt/apache-maven-3.6.3
  export PATH=$MAVEN_HOME/bin:$PATH

# source /etc/profile

4、查看maven版本
# mvn -version
Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)
Maven home: /opt/apache-maven-3.6.3
Java version: 1.8.0_65, vendor: Oracle Corporation, runtime: /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.65-3.b17.el7.x86_64/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-693.el7.x86_64", arch: "amd64", family: "unix"
```


3、安装zookeeper
---
```
1、下载zookeeper
# wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz

2解压
# tar -zxvf zookeeper-3.4.9.tar.gz

服务器1：
#mv zookeeper-3.4.9 zookeeper
服务器2：
#mv zookeeper-3.4.9 zookeeper
服务器3：
#mv zookeeper-3.4.9 zookeeper

3、在zookeeper的各个节点下 创建数据和日志目录
# cd zookeeper
# mkdir data
# mkdir logs

4、重命名配置文件
# cd conf
# cp zoo_sample.cfg zoo.cfg

5、修改配置文件
clientPort=2181
dataDir=/data/software/zookeeper/data
dataLogDir=/data/software/zookeeper/logs

server.1=node01:2881:3881
server.2=node02:2881:3881
server.3=node03:2881:3881

6、创建myid文件
# cd /data/software/zookeeper/data
服务器1：
# echo 1 > myid
服务器2：
# echo 2 > myid
服务器3：
# echo 3 > myid

7、启动测试zookeeper
进入/bin目录下执行：
服务器1：
# /zkServer.sh start
服务器2：
# /zkServer.sh start
服务器3：
# /zkServer.sh start

8、jps命令查看进程
# jps

9、查看状态
# /zkServer.sh status
```

4、安装dubbo
---
```
1、下载dubbo项目
# git clone https://github.com/apache/dubbo.git

2、进入dubbo
# cd dubbo

3、编译dubbo
# mvn install -Dmaven.test.skip=true

4、修改pom.xml文件，将jar上传到nexus
在dubbox目录下，修改pom.xml文件，添加如下代码：
    <distributionManagement>
       <repository>
         <id>nexus-releases</id>
         <url>http://10.211.55.7:8081/repository/maven-releases/</url>
       </repository> 
    </distributionManagement>

然后进入到dubbox目录下执行
# mvn deploy -Dmaven.test.skip=true

需要用到的war包
# ls dubbo-admin/target/dubbo-admin-2.8.4.war
# ls dubbo-simple/target/dubbo-monitor-simple-2.8.4-assembly.tar.gz

5、安装tomcat
# tar -zxvf  apache-tomcat-7.0.81.tar.gz  

6、移动war包到tomcat目录
# ls dubbo-admin/target/dubbo-admin-2.8.4.war
# mv dubbo-admin-2.8.4.war /data/software/apache-tomcat-7.0.81/webapps

7、重命名
# cd /data/software/apache-tomcat-7.0.81/webapps
# mv dubbo-admin-2.8.4.war ROOT.war

8、启动tomcat
# /data/software/apache-tomcat-7.0.81/bin/startup.sh

9、设置dubbo.registry.address
# cd /data/software/apache-tomcat-7.0.81/webapps/ROOT/WEB-INF
# vim dubbo.registry.address
dubbo.registry.address=zookeeper://192.168.101.66:2181?backup=192.168.101.67:2181,192.168.101.68:2181
dubbo.admin.root.password=root
dubbo.admin.guest.password=guest

10、重启tomcat
# /data/software/apache-tomcat-7.0.81/bin/stop.sh
# /data/software/apache-tomcat-7.0.81/bin/startup.sh
```

打开地址：http://192.168.101.66:8080/  
用户名为：root   
密码：root  

5、安装dubbo监控
---
```
1、进入目录解压
# ls dubbo-simple/target/dubbo-monitor-simple-2.8.4-assembly.tar.gz
# tar -zxf dubbo-monitor-simple-2.8.4-assembly.tar.gz

2、进入目录修改配置文件
# cd /data/software/dubbo-monitor-simple-2.8.4/conf
# vim dubbo.properties
dubbo.container=log4j,spring,registry,jetty
dubbo.application.name=simple-monitor
dubbo.application.owner=
#dubbo.registry.address=multicast://224.5.6.7:1234
dubbo.registry.address=zookeeper://192.168.101.66:2181?backup=192.168.101.67:2181,192.168.101.68:2181  #zk地址
#dubbo.registry.address=redis://127.0.0.1:6379
#dubbo.registry.address=dubbo://127.0.0.1:9090
dubbo.protocol.port=7070
dubbo.jetty.port=9080        #http访问端口
dubbo.jetty.directory=${user.home}/monitor
dubbo.charts.directory=${dubbo.jetty.directory}/charts
dubbo.statistics.directory=${user.home}/monitor/statistics
dubbo.log4j.file=logs/dubbo-monitor-simple.log
dubbo.log4j.level=WARN

3、启动
./start.sh 
Starting the simple-monitor .....OK!
PID: 3262
STDOUT: logs/stdout.log
```

http://192.168.101.66:9080/
