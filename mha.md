MHA工具介绍  
---
1、MHA软件由两部分组成，Manager工具包和Node工具包，具体的说明如下：  
Manager工具包主要包括以下几个工具：  
```
masterha_check_ssh              #检查MHA的ssh-key
masterha_check_repl             #检查主从复制情况
masterha_manger                 #启动MHA
masterha_check_status           #检测MHA的运行状态
masterha_master_monitor         #检测master是否宕机
masterha_master_switch          #手动故障转移
masterha_conf_host              #手动添加server信息
masterha_secondary_check        #建立TCP连接从远程服务器
masterha_stop                   #停止MHA
```
Node工具包主要包括以下几个工具：  
```
save_binary_logs                #保存宕机的master的binlog
apply_diff_relay_logs           #识别relay log的差异
filter_mysqlbinlog              #防止回滚事件
purge_relay_logs                #清除中继日志
```  

2、准备 MySQLReplication环境  
node1: MHA Manager  
node2: MariaDB master  
node3: MariaDB slave  
node4: MariaDB slave  


3、各节点的/etc/hosts 文件配置内容中添加：  
192.168.101.66 node1  
192.168.101.67 node2  
192.168.101.68 node3  
192.168.101.69 node4  

4、配置主从  
```
初始主节点 master 配置：
server_id=1
relay-log=relay-bin
log-bin=master-bin
所有 slava 节点依赖的配置：
server_id=2 # 复制集群中的各节点的 id 均必须惟一；
relay-log=relay-bin
log-bin=master-bin
relay_log_purge=0
read_only=1
```  

5、在master节点运行权拥有管理权限  
``` mysql> GRANTALL ON *.* TO 'mhaadmin'@'192.168.101.%' IDENTIFIED BY 'mhapass'; ```  

6、ssh互信  
```
# ssh-keygen -t rsa -P ''
# cat .ssh/id_rsa.pub >> .ssh/authorized_keys
# chmod go= .ssh/authorized_keys
# scp -p .ssh/id_rsa .ssh/authorized_keys root@node2:/root/.ssh/
# scp -p .ssh/id_rsa .ssh/authorized_keys root@node3:/root/.ssh/
# scp -p .ssh/id_rsa .ssh/authorized_keys root@node4:/root/.ssh/
```  

7、安装mha

Manager 节点：  
``` # yum install mha4mysql-manager-0.56-0.el6.noarch.rpm ```  
所有节点，包括 Manager：  
``` # yum install mha4mysql-node-0.56-0.el6.noarch.rpm ```  

