安装grafana  
```
# wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.2.4-1.x86_64.rpm
# yum localinstall grafana-5.2.4-1.x86_64.rpm
# systemctl start grafana-server
安装zabbix插件
# grafana-cli plugins install alexanderzobnin-zabbix-app
# systemctl restart grafana-server
```  

访问地址：http://<server_ip>:3000
