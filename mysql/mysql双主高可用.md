通过KeepAlived搭建MySQL双主模式的高可用集群系统  

1、准备环境  
```
node01: mysql主/备 keepalived
node02: mysql主/备 keepalived
```  

2、两台主机分别安装mysql  
```
yum -y install mysql mysql-server mysql-devel
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld.service
mysqladmin -uroot password '123456'
```  

3、分别修改配置文件  
```
# node01:
server-id = 1
log-bin=mysql-bin
relay-log = mysql-relay-bin
replicate-wild-ignore-table=mysql.%
replicate-wild-ignore-table=test.%
replicate-wild-ignore-table=information_schema.%

# node02:
server-id = 2
log-bin=mysql-bin
relay-log = mysql-relay-bin
replicate-wild-ignore-table=mysql.%
replicate-wild-ignore-table=test.%
replicate-wild-ignore-table=information_schema.%
```  

注意:不要在主库上使用binlog-do-db或binlog-ignore-db选项，也不要在从库上使用replicate-do-db或replicate-ignore-db选项，因为这样可能产生 跨库更新失败的问题。推荐在从库上使用 replicate_wild_do_table 和 和 replicate-wild-ignore-table  两个选项来解决复制过滤问题。  

4、两台主机分别配置主从同步  
```
# 配置master端
mysql> grant replication slave on *.* to 'repl_user'@'192.168.101.%' identified by 'repl_passwd';
mysql> flush privileges;
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      542 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)


# 配置slave主机连接master主机
mysql> change master to \
master_host='192.168.101.69', \
master_user='repl_user', \
master_password='repl_passwd', \
master_log_file='mysql-bin.000001', \
master_log_pos=542;

# 启动两个从库
mysql> start slave;
mysql> show slave status\G
```  

5、安装keepalived  
```
# yum install keepalived -y
# vim /etc/keepalived/keepalived.conf
global_defs {
  notification_email {
    acassen@firewall.loc
    failover@firewall.loc
    sysadmin@firewall.loc
  }

  notification_email_from Alexandre.Cassen@firewall.loc
  smtp_server 192.168.101.11
  smtp_connect_timeout 30
  router_id MySQLHA_DEVEL
}
vrrp_script check_mysqld {
  script "/etc/keepalived/mysqlcheck/check_slave.pl 127.0.0.1" # 检测 mysql  复制状态的脚本
  interval 2
}

vrrp_instance HA_1 {
  state BACKUP   #在DB1和DB2上均配置为BACKUP
  interface ens33
  virtual_router_id 80
  priority 100
  advert_int 2
  nopreempt      #不抢占模式，只在优先级高的机器上设置即可，优先级低的机器不设置

  authentication {
    auth_type PASS
    auth_pass qweasdzxc
  }

  track_script {
    check_mysqld
  }
  virtual_ipaddress {
    192.168.101.71/24 dev eth0 #mysql的对外服务 IP，即VIP
  }
}
```  

6、检查mysql复制状态脚本
```
# cat check_slave.pl 
#!/usr/bin/perl -w
use DBI;
use DBD::mysql;

# CONFIG VARIABLES
$SBM = 120;
$db = "mysql";
$host = $ARGV[0];
$port = 3306;
$user = "root";
$pw = "123456";

# SQL query
$query = "show slave status";

$dbh = DBI->connect("DBI:mysql:$db:$host:$port", $user, $pw, { RaiseError => 0,PrintError => 0 });

if (!defined($dbh)) {
    exit 1;
}

$sqlQuery = $dbh->prepare($query);
$sqlQuery->execute;

$Slave_IO_Running = "";
$Slave_SQL_Running = "";
$Seconds_Behind_Master = "";

while (my $ref = $sqlQuery->fetchrow_hashref()) {
    $Slave_IO_Running = $ref->{'Slave_IO_Running'};
    $Slave_SQL_Running = $ref->{'Slave_SQL_Running'};
    $Seconds_Behind_Master = $ref->{'Seconds_Behind_Master'};
}

$sqlQuery->finish;
$dbh->disconnect();

if ( $Slave_IO_Running eq "No" || $Slave_SQL_Running eq "No" ) {
    exit 1;
} else {
    if ( $Seconds_Behind_Master > $SBM ) {
        exit 1;
    } else {
        exit 0;
    }
}
```  

