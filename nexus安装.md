# nexus安装

Nexus 是一个强大的 Maven 仓库管理器，它极大地简化了自己内部仓库的维护和外部仓库的访问。

- maven官方仓库地址：https://repo.maven.apache.org/
- Nexus官方下载地址：https://help.sonatype.com/repomanager3/download

```
#需要先安装jdk1.8
[19:06:06 root@nexus ~]#ls
nexus-3.30.1-01-unix.tar.gz
[19:06:08 root@nexus ~]#mkdir /apps/nexus -p
[19:06:26 root@nexus ~]#mv nexus-3.30.1-01-unix.tar.gz /apps/nexus/
[19:06:31 root@nexus ~]#cd /apps/nexus/
[19:06:35 root@nexus nexus]#tar xf nexus-3.30.1-01-unix.tar.gz

# 修改配置，一般修改端口号，其他无需修改。  
vim /apps/nexus/nexus-3.30.1-01/conf/nexus.properties
application-port=8081
application-host=0.0.0.0
nexus-webapp=${bundleBasedir}/nexus
nexus-webapp-context-path=/nexus

# Nexus section
nexus-work=${bundleBasedir}/../sonatype-work/nexus
runtime=${bundleBasedir}/nexus/WEB-INF

# vim /apps/nexus/nexus-3.30.1-01/bin/nexus
RUN_AS_USER=root

#启动
[19:10:21 root@nexus nexus-3.30.1-01]#/apps/nexus/nexus-3.30.1-01/bin/nexus --help

[19:10:21 root@nexus nexus-3.30.1-01]#/apps/nexus/nexus-3.30.1-01/bin/nexus start
```

登录验证: http://192.168.10.184:8081/

初始化密码
```
#这里是查询默认admin用户密码登录之后需要修改
[19:12:42 root@nexus ~]#cat /apps/nexus/sonatype-work/nexus3/admin.password
d9ee323f-506a-486d-876c-37bc1e2f6dcf
```
