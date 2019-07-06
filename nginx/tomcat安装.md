tomcat安装
===

1、安装java  
```
下载安装
wget http://down.i4t.com/jdk1.8.0_66.tar.gz
配置Java环境

# tar zxf jdk1.8.0_66.tar.gz -C /usr/local/
# ln –s /usr/local/jdk1.8.0_66 /usr/local/jdk

# vim /etc/profile
export JAVA_HOME=/usr/local/jdk
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH


# source /etc/profile
看到如下信息，java环境配置成功
# java -version
java version "1.8.0_66"
Java(TM) SE Runtime Environment (build 1.8.0_91-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.91-b14, mixed mode)
```  
注意: JDK版本最好对应tomcat版本(可能会出现不兼容现学)  

2、安装Tomcat  
```
# wget http://down.i4t.com/apache-tomcat-8.5.39.tar.gz
# tar xf apache-tomcat-8.5.39.tar.gz -C /usr/local/
# mv /usr/local/apache-tomcat-8.5.39 /usr/local/tomcat

启动
# /usr/local/tomcat/bin/startup.sh && tailf /usr/local/tomcat/logs/catalina.out 
#这样启动是为了方便看日志

tomcat启动停止脚本
# 启动startup.sh
# 停止shutdown.sh
```  

3、浏览器访问  
http://192.168.101.66:8080  

https://www.zyops.com/java-tomcat/


4、service服务配置  
```
 port="8221" protocol="HTTP/1.1"    #port 端口配置
    connectionTimeout="20000"       #connectionTimeout指定超时的时间数(以毫秒为单位)
    maxThreads="3000"               #tomcat起动的最大线程数，即同时处理的任务个数，默认值为200
    minSpareThreads="100"　　　　　  #初始化时创建的线程数
    acceptCount="800"　             #指定当所有可以使用的处理请求的线程数都被使用时，可以放到处理队列中的请求数，超过这个数的请求将不予处理
    maxKeepAliveRequests="200"　    #表示该连接最大支持的请求数。超过该请求数的连接也将被关闭（此时就会返回一个Connection: close头给客户端）。

    URIEncoding="UTF-8"　　　　　    #指定字符集
    redirectPort="8443" />          #指定服务器正在处理http请求时收到了一个SSL传输请求后重定向的端口号
```  


5、Tomcat获取用户IP地址  
```
className="org.apache.catalina.valves.AccessLogValve" directory="logs"
    prefix="localhost_access_log" suffix=".txt"
    pattern="%h %l %u %t %r %s %b" />


前面有负载均衡的时候，获取真实IP可以使用下面的配置     

 className="org.apache.catalina.valves.AccessLogValve" directory="logs"
    prefix="localhost_access_log." suffix=".txt"
    pattern="%{X-Forwarded-For}i %h %l %u %t %r %s %b" />
```  


6、tomcat启动停止脚本  
```
#!/bin/bash
# chkconfig: 2345 74 44
# description: Tomcat is a Java Servlet Container
. /etc/profile
TOMCAT_HOME=/usr/local/tomcat

start () {
TOMCAT_PID=`ps -ef |grep "$TOMCAT_HOME" |grep -v "grep" |awk '{print $2}'`
if [ -z $TOMCAT_PID ];then
    /bin/bash $TOMCAT_HOME/bin/startup.sh
else
    echo "$0 is  running"
fi
}

stop () {
TOMCAT_PID=`ps -ef |grep "$TOMCAT_HOME" |grep -v "grep" |awk '{print $2}'`
if [ -z $TOMCAT_PID ];then
        echo "$0 is not running"
else
        echo "shutting down $0"
        kill -9 "$TOMCAT_PID" && echo "PID $TOMCAT_PID killed."
fi
}

status () {
TOMCAT_PID=`ps -ef |grep "$TOMCAT_HOME" |grep -v "grep" |awk '{print $2}'`
if [ -z $TOMCAT_PID ];then
        echo "$0 is not running"
else
        echo "$0 is running PID is $TOMCAT_PID"
fi
}

case $1 in
start)
start
#tail -f $TOMCAT_HOME/logs/catalina.out
;;
stop)
stop
;;
status)
status
;;
restart)
stop
start
#tail -f $TOMCAT_HOME/logs/catalina.out
;;
*)
echo "Usage:$0  {start|stop|status|restart}."
;;
esac
```  
