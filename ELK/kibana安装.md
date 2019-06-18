三、安装Kibana  
1、下载安装包  
```
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.6.0-linux-x86_64.tar.gz
tar -xvf kibana-6.6.0-linux-x86_64.tar.gz -C /opt/module/
```  
2、修改配置文件  
```
# vim /opt/module/kibana-6.6.0/kibana/kibana.yml
  server.port: 5601
  server.host: "0.0.0.0"
  elasticsearch.hosts: "http://node001:9200"
  logging.dest: /var/log/kibana.log
```  

4、启动kibana  
``` nohup ./kibana & ```  
``` http://node001:5601 ```  

5、配置nginx反向代理kibana认证  
```
# htpasswd -bc /usr/local/nginx/htpass.txt kibana 123456
#chown nginx.nginx /usr/local/nginx/ -R

server字段添加
auth_basic "Restricted Access";
auth_basic_user_file /usr/local/nginx/htpass.txt;
```  

