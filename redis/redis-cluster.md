redis_3.0版本以后  

创建redis的pid,log,和数据保存目录,
```
mkdir -p /opt/redis/data/{redis-6379,redis-6380,redis-6381,redis-6382,redis-6383,redis-6384,redis-6385,redis-6386}/{run,logs,dbcache}
```  

配置每个redis以集群的方式启动  
```
# bind 127.0.0.1                                                                   #注销绑定地址
protected-mode no                                                                  #关闭保护模式
port 6379
daemonize yes                                                                      #工作在守护进程
pidfile /opt/redis/redis-3.2.13/data/redis-6379/run/redis_6379.pid                 #pid文件路径
logfile /opt/redis/redis-3.2.13/data/redis-6379/logs/redis_6379.log                #日志保存路径
dir /opt/redis/redis-3.2.13/data/redis-6379/dbcache/                               #数据保存目录
# requirepass 123456                                                               #注释配置密码必须
cluster-enabled yes                                                                #开启
cluster-config-file nodes-6379.conf                                                #定义cluster配置的保存文件
cluster-node-timeout 15000                                                         #定义节点超时时间
```  
注意：每台port和cluster-config-file需要修改对应文件  

复制配置文件，并修改端口号  
```
cp redis-6379.conf redis-6380.conf 
cp redis-6379.conf redis-6381.conf 
cp redis-6379.conf redis-6382.conf 
cp redis-6379.conf redis-6383.conf 
cp redis-6379.conf redis-6384.conf 
cp redis-6379.conf redis-6385.conf 
cp redis-6379.conf redis-6386.conf 
sed -i 's/6379/6380/g' redis-6380.conf 
sed -i 's/6379/6381/g' redis-6381.conf 
sed -i 's/6379/6382/g' redis-6382.conf 
sed -i 's/6379/6383/g' redis-6383.conf 
sed -i 's/6379/6384/g' redis-6384.conf 
sed -i 's/6379/6385/g' redis-6385.conf 
sed -i 's/6379/6386/g' redis-6386.conf
```  

启动redis  
```
src/redis-server conf/redis-6379.conf 
src/redis-server conf/redis-6378.conf 
src/redis-server conf/redis-6380.conf 
src/redis-server conf/redis-6381.conf 
src/redis-server conf/redis-6382.conf 
src/redis-server conf/redis-6383.conf 
src/redis-server conf/redis-6384.conf 
src/redis-server conf/redis-6385.conf 
src/redis-server conf/redis-6386.conf
```  

查看redis是否启动  
```
# ps -ef |grep redis
root       4464      1  0 22:52 ?        00:00:00 src/redis-server *:6379 [cluster]
root       4469      1  0 22:53 ?        00:00:00 src/redis-server *:6380 [cluster]
root       4473      1  0 22:53 ?        00:00:00 src/redis-server *:6381 [cluster]
root       4477      1  0 22:53 ?        00:00:00 src/redis-server *:6382 [cluster]
root       4481      1  0 22:53 ?        00:00:00 src/redis-server *:6383 [cluster]
root       4485      1  0 22:53 ?        00:00:00 src/redis-server *:6384 [cluster]
root       4489      1  0 22:53 ?        00:00:00 src/redis-server *:6385 [cluster]
root       4493      1  0 22:53 ?        00:00:00 src/redis-server *:6386 [cluster]
root       4506   1154  0 22:54 pts/0    00:00:00 grep --color=auto redis
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
注意：如果升级报错需要升级ruby后只需gem install redis  
https://blog.csdn.net/qq_26440803/article/details/82717244

复制集群管理程序到/usr/local/bin  
```
cp redis-3.0.0/src/redis-trib.rb /usr/local/bin/redis-trib 
```  
创建集群：  
```
redis-trib create --replicas 1 192.168.101.69:6379 192.168.101.69:6380 192.168.101.69:6381 192.168.101.69:6382 192.168.101.69:6383 192.168.101.69:6384 192.168.101.69:6385 192.168.101.69:6386
>>> Creating cluster
>>> Performing hash slots allocation on 8 nodes...
Using 4 masters:
192.168.101.69:6379
192.168.101.69:6380
192.168.101.69:6381
192.168.101.69:6382
Adding replica 192.168.101.69:6383 to 192.168.101.69:6379
Adding replica 192.168.101.69:6384 to 192.168.101.69:6380
Adding replica 192.168.101.69:6385 to 192.168.101.69:6381
Adding replica 192.168.101.69:6386 to 192.168.101.69:6382
M: ecd26de4c96890e75d2a1f5977d35f2129b76115 192.168.101.69:6379
   slots:0-4095 (4096 slots) master
M: ca664f1195919ef8f41be14c092bf03dfd1ef548 192.168.101.69:6380
   slots:4096-8191 (4096 slots) master
M: 4e89d27e29bc95630674ab2d749750e64648f377 192.168.101.69:6381
   slots:8192-12287 (4096 slots) master
M: 3488fa095ec160c044912c14cf0c9d7a66e8f6c8 192.168.101.69:6382
   slots:12288-16383 (4096 slots) master
S: 1792f5d7cc36a46133ffffc92e3ac61ca7b29d36 192.168.101.69:6383
   replicates ecd26de4c96890e75d2a1f5977d35f2129b76115
S: de5a3d575a536e2ee07888cdffae221c102730fb 192.168.101.69:6384
   replicates ca664f1195919ef8f41be14c092bf03dfd1ef548
S: c702d27bc13da0ae89ae5c5ee2be9efcbf01079e 192.168.101.69:6385
   replicates 4e89d27e29bc95630674ab2d749750e64648f377
S: 2c0524f9089213efb72cb97f8d8f11d171aba6b8 192.168.101.69:6386
   replicates 3488fa095ec160c044912c14cf0c9d7a66e8f6c8
Can I set the above configuration? (type 'yes' to accept): yes       #输入yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join.......
>>> Performing Cluster Check (using node 192.168.101.69:6379)
M: ecd26de4c96890e75d2a1f5977d35f2129b76115 192.168.101.69:6379
   slots:0-4095 (4096 slots) master
   1 additional replica(s)
S: 1792f5d7cc36a46133ffffc92e3ac61ca7b29d36 192.168.101.69:6383
   slots: (0 slots) slave
   replicates ecd26de4c96890e75d2a1f5977d35f2129b76115
M: ca664f1195919ef8f41be14c092bf03dfd1ef548 192.168.101.69:6380
   slots:4096-8191 (4096 slots) master
   1 additional replica(s)
S: 2c0524f9089213efb72cb97f8d8f11d171aba6b8 192.168.101.69:6386
   slots: (0 slots) slave
   replicates 3488fa095ec160c044912c14cf0c9d7a66e8f6c8
S: c702d27bc13da0ae89ae5c5ee2be9efcbf01079e 192.168.101.69:6385
   slots: (0 slots) slave
   replicates 4e89d27e29bc95630674ab2d749750e64648f377
M: 4e89d27e29bc95630674ab2d749750e64648f377 192.168.101.69:6381
   slots:8192-12287 (4096 slots) master
   1 additional replica(s)
S: de5a3d575a536e2ee07888cdffae221c102730fb 192.168.101.69:6384
   slots: (0 slots) slave
   replicates ca664f1195919ef8f41be14c092bf03dfd1ef548
M: 3488fa095ec160c044912c14cf0c9d7a66e8f6c8 192.168.101.69:6382
   slots:12288-16383 (4096 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```  
- 给定 redis-trib.rb 程序的命令是 create ， 这表示我们希望创建一个新的集群。  
- 选项 --replicas 1 表示我们希望为集群中的每个主节点创建一个从节点。  

redis-cluster安装完毕  

为redis谁在认证  
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

客户端连接redis命令  
``` redis-cli -h 192.168.101.66 -p 6379 -a 123456 -c ```  
- -c 选项连接集群  
https://www.cnblogs.com/gomysql/p/4395504.html
