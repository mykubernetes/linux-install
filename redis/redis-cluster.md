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

启动redis  
```
redis-server redis-6379.conf
```
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
https://github.com/redis/redis-rb/  
```
gem install redis
```  
复制集群管理程序到/usr/local/bin  
```
cp redis-3.0.0/src/redis-trib.rb /usr/local/bin/redis-trib 
```  
创建集群：  
```
redis-trib create --replicas 1 192.168.101.66:6379 192.168.101.66:6380 192.168.101.66:6381 192.168.101.66:6382 192.168.101.66:6383 ...
```  
- 给定 redis-trib.rb 程序的命令是 create ， 这表示我们希望创建一个新的集群。  
- 选项 --replicas 1 表示我们希望为集群中的每个主节点创建一个从节点。  

redis-cluster安装完毕  

每个节点动态配置  
```
redis-cli -h 192.168.101.66 -p 6379
> config set protected-mode yes     #开启保护模式 
> config set requirepass 123456     #设置密码
> auth 123456                       #因为设置了密码，需要先认证
> config set masterauth 123456      #设置所有的master的认证
> config rewrite                    #将配置写回到配置文件中
> shutdown                          #关闭redis进程
```  
注意：所有节点依次执行此操作成功后重启所有节点  

修改配置文件支持认证功能，否则不可以链接redis服务器  
```
vim /var/lib/gems/2.3.0/gems/redis-3.3.3/lib/redis/client.rb
  :password => "123456"
```  

连接检查  
```
redis-trib.rb check 192.168.101.66:6379
```  

https://www.cnblogs.com/gomysql/p/4395504.html
