
1、开启jmx监控  
```
# vim bin/catalina.sh
JAVA_OPTS="-Dcom.sun.management.jmxremote
           -Djava.rmi.server.hostname=192.168.101.66
           -Dcom.sun.management.jmxremote.port=8080
           -Dcom.sun.management.jmxremote.ssl=false
           -Dcom.sun.management.jmxremote.authenticate=false"
           如果开启认证添加如下配置
           -Dcom.sun.management.jmxremote.authenticate=true
           -Dcom.sun.management.jmxremote.password.file=../conf/jmxremote.password
           -Dcom.sun.management.jmxremote.access.file=../conf/jmxremote.access
```  

2、重启tomcat  
```
./shutdown.sh
./startup.sh
```  

3、查看启动日志  
```
tail logs/catalina.out
```  

4、查看服务是否启动  
```
netstat -antp |grep 8080
```  


