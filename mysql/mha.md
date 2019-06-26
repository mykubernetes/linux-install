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
node1: 192.168.101.66 Master  
node2: 192.168.101.67 Slave/备选master  
node3: 192.168.101.68 Slave/MHAManager 192.168.101.68  

3、所有节点配置  
```
server-id = 1
read-only=1
log-bin=mysql-bin
relay-log = mysql-relay-bin
replicate-wild-ignore-table=mysql.%
replicate-wild-ignore-table=test.%
replicate-wild-ignore-table=information_schema.%
```  

4、在所有mysql节点运行权拥有管理权限  
```
mysql>grant replication slave on *.* to 'repl_user'@'192.168.101.%' identified by 'repl_passwd';
mysql>grant all on *.* to 'root'@'192.168.101.%' identified by '123456'; 
第二条语句为防止权限过大也可以拆分为三条授权
grant all on *.* to 'root'@'192.168.101.66' identified by '123456';
grant all on *.* to 'root'@'192.168.101.67' identified by '123456';
grant all on *.* to 'root'@'192.168.101.68' identified by '123456';
```  

5、配置主从  
```
#在node01上面查看master日志状态
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      542 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)


#配置slave主机连接master主机
mysql> change master to \
master_host='192.168.101.66', \
master_user='repl_user', \
master_password='repl_passwd', \
master_log_file='mysql-bin.000001', \
master_log_pos=542;

启动两个从库
mysql> start slave;
```  

如果mysql是安装在/usr/local/mysql 路径下，那么还需要做如下操作,rpm包安装无需此操作  
``` ln -s /usr/local/mysql/bin/* /usr/bin/ # ```  

6、ssh互信  
```
ssh-keygen -t rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.101.66
ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.101.67
ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.101.68
```  


7、安装mha  

每个节点安装perl链接mysql依赖  
```
# yum install perl-DBD-MySQL -y
```  
所有mysql节点，包括 Manager：  
``` # yum install mha4mysql-node-0.56-0.el6.noarch.rpm ```  

MHA_Manager管理节点节点：  
``` 
# yum install perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Config-IniFiles perl-Time-HiRes
# yum install mha4mysql-manager-0.56-0.el6.noarch.rpm
```  


8、初始化 MHA
```
# vim /etc/masterha/app1.cnf
[server default]
user=mhaadmin # MySQLAdministrator
password=mhapass # MySQLAdministrator's password
manager_workdir=/data/masterha/app1
manager_log=/data/masterha/app1/manager.log
remote_workdir=/data/masterha/app1
ssh_user=root
repl_user=repluser
repl_password=replpass
ping_interval=1
[server1]
hostname=192.168.101.67
#ssh_port=22022
candidate_master=1
[server2]
hostname=192.168.101.68
#ssh_port=22022
candidate_master=1
[server3]
hostname=192.168.101.69
#ssh_port=22022
#no_master=1
```  
配置文件详解  
```
[server default]
#设置manager的工作目录
manager_workdir=/var/log/masterha/app1
#设置manager的日志
manager_log=/var/log/masterha/app1/manager.log 
#设置master 保存binlog的位置，以便MHA可以找到master的日志，我这里的也就是mysql的数据目录
master_binlog_dir=/data/mysql
#设置自动failover时候的切换脚本
master_ip_failover_script= /usr/local/bin/master_ip_failover
#设置手动切换时候的切换脚本
master_ip_online_change_script= /usr/local/bin/master_ip_online_change
#设置mysql中root用户的密码，这个密码是前文中创建监控用户的那个密码
password=123456
#设置监控用户root
user=root
#设置监控主库，发送ping包的时间间隔，尝试三次没有回应的时候自动进行failover
ping_interval=1
#设置远端mysql在发生切换时binlog的保存位置
remote_workdir=/tmp
#设置复制用户的密码
repl_password=123456
#设置复制环境中的复制用户名 
repl_user=rep
#设置发生切换后发送的报警的脚本
report_script=/usr/local/send_report
#一旦MHA到server02的监控之间出现问题，MHA Manager将会尝试从server03登录到server02
secondary_check_script= /usr/local/bin/masterha_secondary_check -s server03 -s server02 --user=root --master_host=server02 --master_ip=192.168.0.50 --master_port=3306
#设置故障发生后关闭故障主机脚本（该脚本的主要作用是关闭主机放在发生脑裂,这里没有使用）
shutdown_script=""
#设置ssh的登录用户名
ssh_user=root 

[server1]
hostname=10.0.0.51
port=3306

[server2]
hostname=10.0.0.52
port=3306
#设置为候选master，如果设置该参数以后，发生主从切换以后将会将此从库提升为主库，即使这个主库不是集群中事件最新的slave。
candidate_master=1
#默认情况下如果一个slave落后master 100M的relay logs的话，MHA将不会选择该slave作为一个新的master，因为对于这个slave的恢复需要花费很长时间，通过设置check_repl_delay=0,MHA触发切换在选择一个新的master的时候将会忽略复制延时，这个参数对于设置了candidate_master=1的主机非常有用，因为这个候选主在切换的过程中一定是新的master
check_repl_delay=0
```  

9、检测各节点间 ssh 互信通信配置是否 OK：  
```
# masterha_check_ssh --conf=/etc/masterha/app1.cnf
```  

10、检查管理的 MySQL 复制集群的连接配置参数是否 OK：  
```
# masterha_check_repl --conf=/etc/masterha/app1.cnf

Mon Nov 9 17:22:48 2015 - [info] Slaves settings check done.
Mon Nov 9 17:22:48 2015 - [info]
172.16.100.68(172.16.100.68:3306) (current master)
+--172.16.100.69(172.16.100.69:3306)
+--172.16.100.70(172.16.100.70:3306)
MySQL Replication Health is OK.
```  

11、启动 MHA  
```
nohup masterha_manager --conf=/etc/masterha/app1.cnf >/data/masterha/app1/manager.log 2>&1 &
```  

12、启动成功后，可通过如下命令来查看 master 节点的状态  
```
# masterha_check_status --conf=/etc/masterha/app1.cnf
app1 (pid:4978) is running(0:PING_OK), master:192.168.101.67
```  

13、停止 MHA  
```
# masterha_stop --conf=/etc/masterha/app1.cnf
```  
