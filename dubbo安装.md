1、安装java
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
```
1、下载dubbo项目
# git clone https://github.com/apache/dubbo.git

2、进入dubbo
# cd dubbo

3、编译dubbo
# 
```

```
