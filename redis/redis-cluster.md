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
