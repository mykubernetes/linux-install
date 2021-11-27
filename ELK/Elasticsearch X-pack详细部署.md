1) 操作系统设置，需要在所有ES节点上执行
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
node.master: true                                                       # ES master节点填写为true，否则为false
node.data: false                                                        # ES 数据节点填写为true，否则为false
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

11) 以elasticsearch用户运行，在其中一个ES节点上运行配置xpack

- es6.8已经可以免费使用xpack了,所以不需要进行破解即可使用了

```
# cd /opt/elasticsearch/elasticsearch-6.8.2/bin
# ./elasticsearch-certgen                                #根据前面的ES集群信息进行配置

Please enter the desired output file [certificate-bundle.zip]: cert.zip        # 生成的压缩包名称
Enter instance name: elasticsearch                                             # 实例名称可以自定义设置
Enter name for directories and files [elasticsearch]: elasticsearch            # 存储实例证书的文件夹名，可以随意指定或保持默认
Enter IP Addresses for instance (comma-separated if more than one) []: 192.168.101.66,192.168.101.67,192.168.101.68   # 实例ip，多个ip用逗号隔开
Enter DNS names for instance (comma-separated if more than one) []: node01,node02,node03                              # 节点名，多个节点用逗号隔开，无解析可用ip代替
Would you like to specify another instance? Press ‘y‘ to continue entering instance information: n                    # 不需要按y重新设置,按空格键就完成
Certificates written to /opt/elasticsearch/elasticsearch-6.8.2/bin/bin/cert.zip                                       # 生成的文件存放地址，不用填写

This file should be properly secured as it contains the private keys for all
instances and the certificate authority.

After unzipping the file, there will be a directory for each instance containing
the certificate and private key. Copy the certificate, key, and CA certificate
to the configuration directory of the Elastic product that they will be used for
and follow the SSL configuration instructions in the product guide.

For client applications, you may only need to copy the CA certificate and
configure the client to trust this certificate.


# 会在当前目录生成cert.zip文件，将改文件拷贝到所有ES节点 /opt/elasticsearch/elasticsearch-6.8.2/config目录并解压
# chown -R elasticsearch:elasticsearch cert.zip
# unzip cert.zip
```

12）以elasticsearch用户操作，在所有的ES节点新增xpack配置
```
# vim /opt/elasticsearch/elasticsearch-6.8.2/config/elasticsearch.yml

# 集群名称,必须统一
cluster.name: es-cluster

# 节点名称
node.name: master1

# 数据目录和日志目录
path.data: /opt/elasticsearch/data
path.logs: /opt/elasticsearch/logs

# 监听地址
network.host: 0.0.0.0
http.port: 9200

# 集群角色
node.master: true				                                                # ES master节点填写为true，否则为false
node.data: false				                                                # ES 数据节点填写为true，否则为false

# 配置集群的节点地址
discovery.zen.ping.unicast.hosts: ["192.168.101.66:9300", "192.168.101.67:9300", "192.168.101.68:9300"]       #填写所有ES节点的信息，包括master和data节点
discovery.zen.minimum_master_nodes: 2

# 开通高级权限后,打开安全配置功能
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
# 配置ssl和CA证书配置
xpack.security.transport.ssl.enabled: true
xpack.ssl.key: elasticsearch/elasticsearch.key
xpack.ssl.certificate: elasticsearch/elasticsearch.crt
```


