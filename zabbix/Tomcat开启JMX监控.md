
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

5、开启zabbix_java_gateway  
```
./startup
ps -ef |grep java
netstat -antp |grep 10052
```  

6、在zabbix-server中的配置文件添加javagateway  
```
# vim /etc/zabbix_server.conf
JavaGateway=127.0.0.1
JavaGatewayPort=10052
StartJavaPollers=5           #启动线程
```  

7、重启zabbix-server  
``` systemctl restart zabbix-server ```  

8、进入zabbix-web添加主机，添加java模板测试  
