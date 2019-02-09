nexus安装
=========
1、首先安装jdk  
``` $ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/ ```  
JDK环境变量配置  
```
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
```  
2、下载地址  
``` wget http://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.11.4-01-bundle.tar.gz ```  
3、解压缩nexus  
``` tar -xvf nexus-2.11.4-01-bundle.tar.gz -C module/ ```  
4、修改配置，一般修改端口号，其他无需修改。  
```
vim /opt/module/nexus-2.11.4-01/conf/nexus.properties
application-port=8081
application-host=0.0.0.0
nexus-webapp=${bundleBasedir}/nexus
nexus-webapp-context-path=/nexus

# Nexus section
nexus-work=${bundleBasedir}/../sonatype-work/nexus
runtime=${bundleBasedir}/nexus/WEB-INF
```  
```
vim /opt/module/nexus-2.11.4-01/bin/nexus
RUN_AS_USER=root
```  
5、启动nexus  
``` /opt/module/nexus-2.11.4-01/bin/nexus start ```  
6、web页面展示  
``` http://192.168.101.68:8081/nexus ```  
默认用户名：admin 密码：admin123  
