官网  
https://www.rabbitmq.com/  

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

3、配置rabbitmq cluster
```
# cd /var/lib/rabbitmq
# chmod u+w .erlang.cookie
```

4、修改host
```
vim /etc/hosts
10.64.16.123    l-rabbitmq1
10.64.17.11      l-rabbitmq2
```


```
rabbitmqctl stop_app

rabbitmqctl join_cluster rabbit@ l-rabbitmq1

rabbitmqctl start_app
```

启动一个节点为RAM模式
```
rabbitmqctl change_cluster_node_type  ram  (需要先停掉,才能更改)
```

6、mirror queue policy设置
```
rabbitmqctl set_policy ha-all "^ha\." '{"ha-mode":"all","ha-sync-mode":"automatic"}'               //意思表示以ha.开头的queue都会复制到各个节点 
```
