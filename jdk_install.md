1、解压jdk
```
#tar -zxvf server-jre-8u171-linux-x64.tar.gz
```

2、移动解压内容至特定目录
```
# mkdir /usr/lib/jvm
# mv jdk1.8.0_171 /usr/lib/jvm
```

3、配置环境
```
# vim /etc/profile
添加以下内容

export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_144
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```

4、查看jdk版本
```
# java -version
```
