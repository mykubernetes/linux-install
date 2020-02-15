1、安装java
```
yum install java -y
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
