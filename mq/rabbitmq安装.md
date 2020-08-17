官网  
https://www.rabbitmq.com/  

安装
--
1、首先需要安装erlang
```
# rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/epel/epel-release-latest-7.noarch.rpm
# yum install erlang -y
```

2、安装RabbitMQ
```
# wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.6/rabbitmq-server-3.6.6-1.el7.noarch.rpm
# yum install rabbitmq-server-3.6.6-1.el7.noarch.rpm 

完成后启动服务：
# service rabbitmq-server start
可以查看服务状态：
#s ervice rabbitmq-server status
```

3、修改host
```
vim /etc/hosts
192.168.101.66      rabbitmq1
192.168.101.67      rabbitmq2
192.168.101.68      rabbitmq3
```

4、启动服务
```
rabbitmq-server start stop status restart
lsof -i:5672

rabbitmq-plugins enable rabbitmq_management
lsof -i:15672 或者 netstat -tnlp|grep 15672
```

5、网页验证  
http://192.168.66.66:15672/

以上操作三个节点同时进行操作

6、选择66、67、68任意一个节点为Master（这里选择66为Master），需要把66的Cookie文件同步到67、68节点上，
```
# rabbitmq-server stop 
# cd /var/lib/rabbitmq
文件的权限修改为777，未修改前是400
# chmod 777 /var/lib/rabbitmq/.erlang.cookie
或者
# chmod u+w .erlang.cookie
然后把.erlang.cookie文件copy到各个节点下；最后把所有cookie文件权限还原为400即可
scp /var/lib/rabbitmq/.erlang.cookie 192.168.101.67:/var/lib/rabbitmq
scp /var/lib/rabbitmq/.erlang.cookie 192.168.101.68:/var/lib/rabbitmq
```

组件成集群
---
1、停止MQ服务
```
rabbitmqctl stop
```

2、组成集群操作，3个节点（66，67,68）执行启动命令
```
rabbitmq-server -detached
```

3、slave加入集群操作（重新加入集群也是如此，以最开始的主节点为加入节点）
```
节点rabbitmq2执行操作
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rabbitmq1
rabbitmqctl start_app

节点rabbitmq3执行操作
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rabbitmq1
rabbitmqctl start_app

其他节点上操作要移除的集群节点
rabbitmqctl forget_cluster_node rabbit@hadoop1
```

4、修改集群名称
```
rabbitmqctl set_cluster_name rabbitmq_cluster1
```

5、查看集群状态
```
rabbitmqctl cluster_status
```

6、管控台界面

http://192.168.101.66:15672

7、配置镜像队列
```
rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'
```
将所有队列设置为镜像队列，即队列会被复制到各个节点，各个节点状态一致，RabbitMQ高可用集群就已经搭建好了

