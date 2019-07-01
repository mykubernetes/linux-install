官方文档  
https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/  

1、下载文件  
```
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-server-4.0.5-1.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-shell-4.0.5-1.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-tools-4.0.5-1.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-mongos-4.0.5-1.el7.x86_64.rpm
```  
- mongodb-org-4.0.5-1.el7.x86_64.rpm
- mongodb-org-mongos-4.0.5-1.el7.x86_64.rpm #数据分片
- mongodb-org-server-4.0.5-1.el7.x86_64.rpm #服务端包
- mongodb-org-shell-4.0.5-1.el7.x86_64.rpm #客户端包
- mongodb-org-tools-4.0.5-1.el7.x86_64.rpm #备份导入导出包

2、安装  
```
yum install -y mongodb-org-server-4.0.5-1.el7.x86_64.rpm mongodb-org-shell-4.0.5-1.el7.x86_64.rpm mongodb-org-tools-4.0.5-1.el7.x86_64.rpm
```  

3、修改配置文件  
```
vim /etc/mongod.conf
net:
  port: 27017
  bindIp: 0.0.0.0
```  

4、连接数据库及常用命令  
```
mongo --host 192.168.101.69
> show dbs     # 查看数据库
admin   0.000GB
config  0.000GB
local   0.000GB
> use testdb   #无需创建直接使用，延时创建
> db.help()
> db.stats()  数据库状态 
> db.serverStatus() 数据库服务状态
> show collection 查看库的集合
> db.getCollectionNames()
```  
