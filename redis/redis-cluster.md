redis_3.0版本以后  
配置每个redis以集群的方式启动  
```
# bind 127.0.0.1                      #注销绑定地址
protected-mode no                     #关闭保护模式
port 6379
daemonize yes                         #工作在守护进程
pidfile /usr/...                      #pid文件路径
logfile /usr/...                      #日志保存路径
dir /usr/...                          #数据保存目录
# requirepass 123456                  #注释配置密码必须
cluster-enabled yes                   #开启
cluster-config-file nodes-6379.conf   #定义cluster配置的保存文件
cluster-node-timeout 15000            #定义节点超时时间
```  
注意：每台port和cluster-config-file需要修改对应文件  

查看redis是否启动  
```
ps -ef |grep redis
root    5035   1   0  10:04 ?     00:00:00  /usr/local/redis/bin/redis-server *:6379 [cluster]
root    5037   1   0  10:04 ?     00:00:00  /usr/local/redis/bin/redis-server *:6380 [cluster]
root    5036   1   0  10:04 ?     00:00:00  /usr/local/redis/bin/redis-server *:6381 [cluster]
root    5038   1   0  10:04 ?     00:00:00  /usr/local/redis/bin/redis-server *:6382 [cluster]
root    5039   1   0  10:04 ?     00:00:00  /usr/local/redis/bin/redis-server *:6383 [cluster]
root    5028   1   0  10:04 ?     00:00:00  /usr/local/redis/bin/redis-server *:6384 [cluster]
```  
注意：配置成功后，后边会出现[cluster]字样  

配置redis-cluster集群  
需要安装ruby环境  
```
yum install ruby rubygems -y
```  
首先对redis进行编译处理  
```
gem install redis
```  



https://www.cnblogs.com/gomysql/p/4395504.html
