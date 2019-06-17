使用方法：  
1、安装ansible  
```
yum install ansible -y
```  

2、配置需要安装的主机
```
vim /etc/ansible/hosts
[zabbix-agent]
node01
node02
node03
```  

3、使用ansible批量部署zabbix-agent端  
```
ansible-playbook zabbix_agent.yml -u root -k
- -u用户
- -k密码
```  
