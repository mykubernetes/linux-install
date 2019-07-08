mycat-web
===

1、安装zookpeer  
```
wget  http://dl.mycat.io/zookeeper-3.4.6.tar.gz
tar -xzvf  zookeeper-3.4.6.tar.gz
cd zookeeper-3.4.6/conf
cp zoo_sample.cfg zoo.cfg
cd zookeeper-3.4.6/bin
./zkServer.sh start
出现一下信息 说明启动成功
JMX enabled by default
Using config: /usr1/zookeeper/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```  


2、安装mycat-web  
```
wget http://dl.mycat.io/mycat-web-1.0/Mycat-web-1.0-SNAPSHOT-20170102153329-linux.tar.gz
tar xvf Mycat-web-1.0-SNAPSHOT-20170102153329-linux.tar.gz
cd mycat-web/mycat-web/WEB-INF/classes
vim mycat.properties
zookeeper=127.0.0.1:2181
sqlonline.server=10.0.0.202
cd mycat-web
#将start.sh文件中的JVM调整到合适的大小
./start.sh &
#8082端口是web端口
访问10.0.0.202:8082/mycat即可进入web页面
```  
