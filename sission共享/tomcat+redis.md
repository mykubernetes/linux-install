1、部署redis环境
```
1、解压redis
# tar xvf redis-5.0.12.tar.gz
# cd redis-5.0.12

2、编译
# make 

3、修改配置文件
# cp redis.conf /etc/
# cd src 
# cp redis-cli redis-server redis-sentinel /usr/sbin/ 

# vim /etc/redis.conf
69行  bind 0.0.0.0
136行 daemonize yes

4、启动redis服务即可
#/usr/sbin/redis-server /etc/redis.conf

# ss -antpu|grep 6379
tcp    LISTEN     0      128       *:6379                  *:*                   users:(("redis-server",pid=6030,fd=6))
```

2、安装JDK
```
# yum remove java-*  -y

# tar xf jdk-8u191-linux-x64.tar.gz -C /usr/local/
# cd /usr/local/

# ln -sv jdk1.8.0_191 jdk1.8
"jkd1.8" -> "jdk1.8.0_191"

# vim /etc/profile.d/jdk8.sh
export JAVA_HOME=/usr/local/jdk1.8.0_191
export CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/jar/tools.jar:$JAVA_HOME/jre/lib
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH

# . /etc/profile.d/jdk8.sh

# java -version
java version "1.8.0_191"
Java(TM) SE Runtime Environment (build 1.8.0_152-b16)
Java HotSpot(TM) 64-Bit Server VM (build 25.152-b16, mixed mode) 
```

3、安装tomcat 
```
# tar xf apache-tomcat-8.5.35.tar.gz -C /usr/local/src/
# cd /usr/local/src/apache-tomcat-8.5.35/

# ls
|---bin         #存放Tomcat启动和关闭tomcat脚本；
|---conf        #存放Tomcat不同的配置文件（server.xml和web.xml）；
|---lib         #包含Tomcat使用的jar文件.unix平台此目录下的任何文件都被加到Tomcat的 classpath中；
|---logs        #存放Tomcat执行时的LOG文件；
|---webapps     #Tomcat的主要Web发布目录（包括应用程序示例）；
|---ROOT        #Tomcat的家目录
|---index.jsp   #Tomcat的默认首页文件
|---work        #存放jsp编译后产生的class文件或servlet文件存放
|---temp        #存放Tomcat运行时所产生的临时文件 


# ls bin/        #tomcat的执行脚本文件
bootstrap.jar           configtest.bat    setclasspath.sh  tomcat-native.tar.gz
catalina.bat            configtest.sh     shutdown.bat     tool-wrapper.bat
catalina.sh             daemon.sh         shutdown.sh      tool-wrapper.sh
catalina-tasks.xml      digest.bat        startup.bat      version.bat
commons-daemon.jar      digest.sh         startup.sh       version.sh
commons-daemon-native.tar.gz       setclasspath.bat        tomcat-juli.jar 

#创建Tomcat启动脚本 
# vim /etc/init.d/tomcat
#!/bin/bash
#
# tomcat startup script for the Tomcat server
#   # chkconfig: 345 80 20
# description: start the tomcat deamon
#
# Source function library
JAVA_HOME=/usr/local/jdk1.8.0_191
export JAVA_HOME
CATALANA_HOME=/usr/local/tomcat
export CATALINA_HOME

case "$1" in
  start)
    echo "Starting Tomcat..." 
    $CATALANA_HOME/bin/startup.sh
    ;;
  stop)
    echo "Stopping Tomcat..."
    $CATALANA_HOME/bin/shutdown.sh      
    ;;
  restart)
    echo "Stopping Tomcat..."
    $CATALANA_HOME/bin/shutdown.sh
    sleep 2
    echo
    echo "Starting Tomcat..."
    $CATALANA_HOME/bin/startup.sh
    ;;
  *)
    echo "Usage: $prog {start|stop|restart}"
    ;;
esac   
exit 0 


#启动tomcat
# chmod +x /etc/init.d/tomcat 
# service tomcat
start  Starting Tomcat...
Using CATALINA_BASE:   /usr/local/tomcat
Using CATALINA_HOME:   /usr/local/tomcat
Using CATALINA_TMPDIR: /usr/local/tomcat/temp
Using JRE_HOME:        /usr/local/jdk1.8.0_191
Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar Tomcat started.

#设置开机启动
# chkconfig --add tomcat
# chkconfig tomcat on
# chkconfig --list tomcat
# lsof -i :8080        # #查看是否启动8080端口
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    2334 root   49u  IPv6  44241      0t0  TCP *:webcache (LISTEN)   

# 览器访问
http://IP:8080 
```

配置tomcat-session共享 
---

```
1、需要部署jar包环境
https://github.com/redisson/redisson/tree/master/redisson-tomcat
下载对应jar包
redisson-all-3.15.3.jar
redisson-tomcat-8-3.15.3.jar

2、将jar包拷贝到tomcat的lib目录中
# cp redisson-all-3.15.3.jar redisson-tomcat-8-3.15.3.jar /usr/local/tomcat/lib

3、修改context.xml配置文件
vim /usr/local/tomcat/conf/context.xml
增加RedissonSessionManager 配置
<Manager className="org.redisson.tomcat.RedissonSessionManager"
  configPath="${catalina.base}/redisson.conf"
  readMode="REDIS" updateMode="DEFAULT" broadcastSessionEvents="false"
  keyPrefix=""
/> 

4、创建redisson.conf配置文件
# vim /usr/local/tomcat/conf/redisson.conf
---
singleServerConfig:
  idleConnectionTimeout: 10000
  connectTimeout: 10000
  timeout: 3000
  retryAttempts: 3
  retryInterval: 1500
  password: null
  subscriptionsPerConnection: 5
  clientName: null
  address: "redis://127.0.0.1:6379"                    # redis地址要修改
  subscriptionConnectionMinimumIdleSize: 1 
  subscriptionConnectionPoolSize: 50
  connectionMinimumIdleSize: 24
  connectionPoolSize: 64
  database: 0
  dnsMonitoringInterval: 5000
threads: 16
nettyThreads: 32
codec: !<org.redisson.codec.FstCodec> {}
transportMode: "NIO" 

5、server.xml添加配置 
vim  /usr/local/tomcat/conf/server.xml
37行  <GlobalNamingResources>下
Resource修改为如下内容
<Resource name="bean/redisson"
            auth="Container"
            factory="org.redisson.JndiRedissonFactory"
            configPath="${catalina.base}/conf/redisson.yaml"
            closeMethod="shutdown"
/>

6、创建redisson.yaml配置文件
vim /usr/local/tomcat/conf/redisson.yaml
singleServerConfig:
  address: "redis://127.0.0.1:6379" 
 
7、重启服务
service  tomcat  restart
http://IP:8080/testsession.jsp 

8、查看redis 的session
redis-cli
> KEYS *
1) "redisson:tomcat_session:E66E721BE5615AAF984F463E90D2C510"       # 与页面id显示一致 
> exit

9、拷贝数据到另一个节点
# cd /usr/local/tomcat/conf/

# scp server.xml context.xml redisson.conf redisson.yaml 192.168.1.201:/usr/local/tomcat/conf/
复制之前另一台机器先备份相应配置文件
# scp /usr/local/tomcat/webapps/ROOT/testsession.jsp 192.168.1.201:/usr/local/tomcat/webapps/ROOT/ 
 
另一台机器操作
修改redisson两个配置文件里的address为192.168.1.202
修改testsession.jsp 显示内容如tomcat2
写testsession.jsp
vim  /usr/local/tomcat/webapps/ROOT/testsession.jsp 
 
10、重启服务
service  tomcat  restart
http://192.168.1.201:8080/testsession.jsp

11、测试
http://192.168.1.201/testsession.jsp
```
