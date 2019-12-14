部署nginx
```
# yum install epel-release -y  
# yum install nginx -y
```

配置nginx代理tomcat
```
upstream static.solo {
   server 192.168.0.217:80;
   server 192.168.0.218:80;
}
upstream dynamic.solo {
   server 192.168.0.215:8080;
   server 192.168.0.216:8080;
}
server {
    listen       80;
    server_name  test.aliangedu.com;
    access_log  logs/solo.access.log  main;

    location ~ \.(html|css|js|jpg|png|gif)$ {
        proxy_pass http://static.solo;
    }

    location / {
        proxy_pass http://dynamic.solo$request_uri;
        proxy_set_header  Host $host:$server_port;
        proxy_set_header  X-Real-IP  $remote_addr;
        client_max_body_size  10m;
    }
}
```

部署redis
```
# yum install redis –y
# vi /etc/redis.conf
bind 0.0.0.0
requirepass 123456

# systemctl start redis
# systemctl enable redis
```


1、配置JDK和Maven环境变量
```
# tar zxvf jdk-8u45-linux-x64.tar.gz
# mv jdk1.8.0_45 /usr/loca/jdk.18

# tar apache-maven-3.5.0-bin.tar.gz
# mv apache-maven-3.5.0 /usr/local/maven3.5
# vi /etc/profile
JAVA_HOME=/usr/local/jdk1.8
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
MAVEN_HOME=/usr/local/maven3.5
PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH
export JAVA_HOME CLASSPATH MAVEN_HOME PATH
```

2、安装tomcat  
JAVA博客项目：  
https://github.com/b3log/solo  

```
# tar zxvf apache-tomcat-8.0.46.tar.gz
# cd apache-tomcat-8.0.46/webapps
# rm -rf ./*
# unzip solo-2.7.0.war -d ROOT
# ../bin/startup.sh
```

3、Tomcat基于Redis实现Session共享
```
# git clone https://github.com/chexagon/redis-session-manager
# cd redis-session-manager
# mvn package
# cp target/redis-session-manager-with-dependencies-2.2.2-SNAPSHOT.jar tomcat/lib
```

编辑配置文件
```
# vi tomcat/conf/context.xml
<Manager className="com.crimsonhexagon.rsm.redisson.SingleServerSessionManager"
        endpoint="redis://192.168.0.219:6379"
        sessionKeyPrefix="_rsm_"
        saveOnChange="false"
        forceSaveAfterRequest="false"
        dirtyOnMutation="false"
        ignorePattern=".*\\.(ico|png|gif|jpg|jpeg|swf|css|js)$"
        maxSessionAttributeSize="-1"
        maxSessionSize="-1"
        allowOversizedSessions="false"
        connectionPoolSize="100"
        database="0"
        password="123456"
        timeout="60000"
        pingTimeout="1000"
        retryAttempts="20"
        retryInterval="1000"
/>
```
