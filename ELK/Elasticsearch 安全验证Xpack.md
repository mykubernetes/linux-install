1)	操作系统设置，需要在所有ES节点上执行
```
# vim /etc/sysctl.conf 文件，添加或修改 vm.max_map_count 配置
vm.max_map_count=655360

# 保存后刷新操作系统配置
# sysctl -p	
```

2）修改系统资源配置，需要在所有ES节点执行
```
# 修改 /etc/security/limits.conf 文件，在最后添加内容
*  soft    nproc   1024000
*  hard    nproc   1024000
*  soft    nofile  1024000
*  hard    nofile  1024000
```

3）添加ES用户，需要在所有ES节点执行
```
# groupadd elasticsearch
# useradd elasticsearch -g elasticsearch -b /opt
```

4) 解压es安装包到 /opt/elasticsearch 目录下，并修改解压后的目录属主为elasticsearch，在所有ES节点执行
```
# cd /opt
# tar -zxvf elasticsearch-6.8.2.tar.gz -C /opt/elasticsearch

# cd /opt/elasticsearch
# chown -R elasticsearch:elasticsearch elasticsearch-6.8.2/
```

5）配置JAVA_HOME环境变量，需要在所有ES节点执行
```
# vim /etc/profile
export JAVA_HOME=/opt/java
export PATH=$JAVA_HOME/bin:$PATH

# source /etc/profile
```

6）创建ES集群的数据和日志目录，需要在ES所有节点执行
```
# mkdir -p /opt/elasticsearch/{data,logs}
# chown -R elasticsearch:elasticsearch /opt/elasticsearch
```

7）切换到elasticsearch用户, 在所有ES节点进行如下操作：
```
# cd /opt/elasticsearch/elasticsearch-6.8.2/config

# vim elasticsearch.yml 
cluster.name: es-cluster
node.name: master1                                                      #根据节点信息填写，独立部署推荐为master1~3，node1~3
path.data: /opt/elasticsearch/data
path.logs: /opt/elasticsearch/logs
network.host: 0.0.0.0
http.port: 9200
node.master: true				                                                # ES master节点填写为true，否则为false
node.data: false				                                                # ES 数据节点填写为true，否则为false
discovery.zen.ping.unicast.hosts: ["192.168.101.66:9300", "192.168.101.67:9300", "192.168.101.68:9300"]       #填写所有ES节点的信息，包括master和data节点
discovery.zen.minimum_master_nodes: 2
```

8）以elasticsearch用户，修改ES配置信息，在所有ES节点进行如下操作：
```
# cd /opt/elasticsearch/elasticsearch-6.8.2/config
# vim jvm.options文件，修改或添加 Xms 和 Xmx 配置
-Xms8g                                              #设置为节点内存的一半
-Xmx8g                                              #与xms值保持一致
```

9) 以elasticsearch用户，启动ES进程，在所有ES节点进行：
```
# cd /opt/elasticsearch/elasticsearch-6.8.2/bin && ./elasticsearch -d
```

10) 检查ES集群状态信息，确认9200服务端口处于监听状态
```
# netstat -ltnp | grep 9200
# curl localhost:9200/_cluster/health?pretty
```






