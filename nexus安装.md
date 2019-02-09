nexus安装
=========
1、下载地址  
``` wget http://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.11.4-01-bundle.tar.gz ```  
2、解压缩nexus  
``` tar -xvf nexus-2.11.4-01-bundle.tar.gz -C module/ ```  
3、修改配置，一般修改端口号，其他无需修改。  
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
4、启动nexus
``` /opt/module/nexus-2.11.4-01/bin/nexus start ```
