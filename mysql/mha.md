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
# mkdir -p /etc/mha/scripts

# vim /etc/masterha/app1.cnf
[server default]
user=root                 # 这个是mysql的root 用户
password=123456           # mysql的root用户密码
ssh_user=root             # 设置ssh的登录用户名
repl_user=repl_user       # 设置复制环境中的复制用户名
repl_password=repl_passwd # 设置复制用户的密码
ping_interval=1           # 设置监控主库，发送ping包的时间间隔，默认是3秒,尝试三次没有回应的时候自动进行failover
secondary_check_script = masterha_secondary_check -s 192.168.101.66 -s 192.168.101.67 -s 192.168.101.68 --user=repl_user --master_host=node01 --master_ip=192.168.101.66 --master_port=3306   #强烈建议有两个或多个网络线路检查MySQL主服务器的可用性
master_ip_failover_script="/etc/mha/scripts/master_ip_failover"    #设置自动failover时，即在MySQL从服务器提升为新的主服务器时，调用此脚本，因此可以将 vip 信息写到此配置文件
manager_log=/var/log/mha/app1/manager.log   #设置 manager 的日志路径
manager_workdir=/var/log/mha/app1           #设置 manager 的工作目录

[server1]
master_binlog_dir="/usr/local/mysql/data" #指定每个节点 mysql 的 bin-log日志路径
hostname=192.168.101.67
#ssh_port=22022
candidate_master=1        # 表示该主机优先可被选为new master，当多个[serverX]等设置此参数时，优先级由[serverX]配置的顺序决定

[server2]
hostname=192.168.101.68
#ssh_port=22022
candidate_master=1

[server3]
hostname=192.168.101.69
master_binlog_dir="/usr/local/mysql/data"
#ssh_port=22022
#no_master=1               #no_master 可以让某一个节点永远不成为新的主节点
```  

配置vip  

```
# 在master上生成vip地址，把地址写到脚本中
# /sbin/ifconfig eth0:1 192.168.101.50/24

# vim /etc/mha/scripts/master_ip_failover

#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';
use Getopt::Long;
my (
$command, $ssh_user, $orig_master_host, $orig_master_ip,
$orig_master_port, $new_master_host, $new_master_ip, $new_master_port
);
my $vip = '192.168.101.50/24';             #master的vip地址
my $key = '1';
my $ssh_start_vip = "/sbin/ifconfig eth1:$key $vip";
my $ssh_stop_vip = "/sbin/ifconfig eth1:$key down";
GetOptions(
'command=s' => \$command,
'ssh_user=s' => \$ssh_user,
'orig_master_host=s' => \$orig_master_host,
'orig_master_ip=s' => \$orig_master_ip,
'orig_master_port=i' => \$orig_master_port,
'new_master_host=s' => \$new_master_host,
'new_master_ip=s' => \$new_master_ip,
'new_master_port=i' => \$new_master_port,
);
exit &main();
sub main {
print "\n\nIN SCRIPT TEST====$ssh_stop_vip==$ssh_start_vip===\n\n";
if ( $command eq "stop" || $command eq "stopssh" ) {
my $exit_code = 1;
eval {
print "Disabling the VIP on old master: $orig_master_host \n";
&stop_vip();
$exit_code = 0;
};
if ($@) {
warn "Got Error: $@\n";
exit $exit_code;
}
exit $exit_code;
}
elsif ( $command eq "start" ) {
my $exit_code = 10;
eval {
print "Enabling the VIP - $vip on the new master - $new_master_host \n";
&start_vip();
$exit_code = 0;
};
if ($@) {
warn $@;
exit $exit_code;
}
exit $exit_code;
}
elsif ( $command eq "status" ) {
print "Checking the Status of the script.. OK \n";
exit 0;
}
else {
&usage();
exit 1;
}
}
sub start_vip() {
`ssh $ssh_user\@$new_master_host \" $ssh_start_vip \"`;
}
sub stop_vip() {
return 0 unless ($ssh_user);
`ssh $ssh_user\@$orig_master_host \" $ssh_stop_vip \"`;
}
sub usage {
print
"Usage: master_ip_failover --command=start|stop|stopssh|status --orig_master_host=host
--orig_master_ip=ip --orig_master_port=port --new_master_host=host --new_master_ip=ip
--new_master_port=port\n";
}
```  
注意:为了防止脑裂发生，推荐生产环境采用脚本的方式来管理虚拟ip，而不是使用keepalived来完成  

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
