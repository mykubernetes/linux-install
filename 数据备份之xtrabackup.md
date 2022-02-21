# xtrabackup工具

官方网站：https://www.percona.com/software/mysql-database/percona-xtrabackup

如果数据库数据量比较大推荐使用xtrabackup工具进行数据备份

## 1.1 xtrabackup介绍
```
xtrabackup命令
#常用参数
--user                  #该选项表示备份账号
--password              #该选项表示备份的密码
--port                  #该选项表示备份数据库的端口
--host                  #选项表示备份数据库的地址
--socket                #该选项表示mysql.sock所在位置，以便备份进程登录mysql。
--defaults-file         #该选项指定了从哪个文件读取MySQL配置，必须放在命令行第一个选项的位置
--databases             #该选项接受的参数为数据名，如果要指定多个数据库，彼此间需要以空格隔开；如："db1 db2"，同时，在指定某数据库时，也可以只指定其中的某张表。如："mydatabase.mytable"。该选项对innodb引擎表无效，还是会备份所有innodb表。此外，此选项也可以接受一个文件为参数，文件中每一行为一个要备份的对象。
--prepare               #实现通过回滚未提交的事务及同步已经提交的事务至数据文件使数据文件处于一致性状态
--target-dir            #备份数据目录

#主从
--slave-info #该选项表示对slave进行备份的时候使用，打印出master的名字和binlog pos，同样将这些信息以change master的命令写入xtrabackup_slave_info文件。可以通过基于这份备份启动一个从库。

#其他选项
--stream #该选项表示流式备份的格式，backup完成之后以指定格式到STDOUT，目前只支持tar和xbstream。
```

## 1.2 xtrabackup备份数据库

### 1.2.1 完全备份
```
#创建备份，如果不指定数据库则表示全部备份--databases=
[16:53:09 root@mysql-1 ~]#xtrabackup --user=root --password=123456  --backup --target-dir=xtrabackup

#将备份文件推送到别的服务器
[16:54:11 root@mysql-1 ~]#scp -r xtrabackup 192.168.10.182:

#准备备份
[16:55:04 root@mysql-2 ~]#ls
xtrabackup
[16:56:22 root@mysql-2 ~]#xtrabackup --prepare --target-dir=xtrabackup

#恢复数据
[16:56:52 root@mysql-2 ~]#systemctl stop mysql
[16:57:05 root@mysql-2 ~]#rm -rf /var/lib/mysql
[16:57:14 root@mysql-2 ~]#cp -rf xtrabackup /var/lib/mysql
[16:57:23 root@mysql-2 ~]#chown mysql: -R /var/lib/mysql

#重启数据库验证
[16:57:46 root@mysql-2 ~]#systemctl start mysql
```

### 1.2.2 增量备份
```
#首先先创建完全备份
[17:00:19 root@mysql-1 ~]#xtrabackup --user=root --password=123456  --backup --target-dir=xtrabackup

#之后在数据库写入大量数据
#创建第一次增量备份
[17:18:13 root@mysql-1 ~]#xtrabackup --user=root --password=123456  --backup --target-dir=inc1 --incremental-basedir=xtrabackup

#创建第二次增量备份
[17:20:27 root@mysql-1 ~]#xtrabackup --user=root --password=123456  --backup --target-dir=inc2 --incremental-basedir=inc1

参数说明
--target-dir  增量备份放在那里
--incremental-basedir  以那个原始数据做增量

#验证文件大小
[17:21:14 root@mysql-1 ~]#du -sh ./*
8.7M	./inc1
2.4M	./inc2
135M	./xtrabackup

#恢复数据
[17:23:29 root@mysql-2 ~]#ls
inc1  inc2  xtrabackup

#准备基础备份
[17:23:33 root@mysql-2 ~]#xtrabackup --prepare --apply-log-only --target-dir=xtrabackup 

#将第一次增量备份应用到完全备份
[17:25:04 root@mysql-2 ~]#xtrabackup --prepare --apply-log-only --target-dir=xtrabackup --incremental-dir=inc1

#将第二次增量备份应用到完全备份
[17:26:37 root@mysql-2 ~]#xtrabackup --prepare --apply-log-only --target-dir=xtrabackup --incremental-dir=inc2

[17:27:04 root@mysql-2 ~]#rm -rf /var/lib/mysql
[17:27:14 root@mysql-2 ~]#cp -rf xtrabackup /var/lib/mysql
[17:27:19 root@mysql-2 ~]#chown mysql: -R /var/lib/mysql
[17:27:26 root@mysql-2 ~]#systemctl restart mysql
```

## 1.3 跨主机备份

### 1.3.1 ncat

ncat 或者说 nc 是一款功能类似 cat 的工具，但是是用于网络的。它是一款拥有多种功能的 CLI 工具，可以用来在网络上读、写以及重定向数据。 它被设计成可以被脚本或其他程序调用的可靠的后端工具。同时由于它能创建任意所需的连接，因此也是一个很好的网络调试工具。

ncat/nc 既是一个端口扫描工具，也是一款安全工具，还是一款监测工具，甚至可以做为一个简单的 TCP 代理。 由于有这么多的功能，它被誉为是网络界的瑞士军刀。 这是每个系统管理员都应该知道并且掌握它。
```
#参数详解
-l, --listen               #绑定并监听传入的连接
-k, --keep-open            #在监听模式下接受多个连接
--max-conns                #最大连接数
-c                         #每次有人连接会执行-c后面的命令并把结果返回给连接的客户端
```

### 1.3.2 跨主机备份数据
```
#在备份数据的服务器执行
[17:50:32 root@mysql-1 ~]#ncat --listen --keep-open --send-only --max-conns=1 3307 -c "xtrabackup --backup --stream=xbstream --host=127.0.0.1 --user=root -p123456"
#验证监听的端口
[17:51:30 root@mysql-1 ~]#ss -ntl | grep 3307
LISTEN   0         10                  0.0.0.0:3307             0.0.0.0:*       
LISTEN   0         10                     [::]:3307                [::]:*
```

### 1.3.3 在备份的节点恢复数据
```
#在恢复数据的节点执行
[17:53:40 root@mysql-2 ~]#ncat --recv-only 192.168.10.181 3307 | xbstream -x -C mysql
#查看恢复的数据文件
[17:54:16 root@mysql-2 ~]#ls mysql/
backup-my.cnf   ibdata1             sys                     xtrabackup_checkpoints
binlog.000012   mysql               test                    xtrabackup_info
binlog.index    mysql.ibd           undo_001                xtrabackup_logfile
bolo            performance_schema  undo_002                xtrabackup_tablespaces
ib_buffer_pool  solo                xtrabackup_binlog_info
#整理数据
[17:55:10 root@mysql-2 ~]#xtrabackup --prepare --target-dir=mysql

#之后数据就可以使用了
```

## 1.4 主从服务器快速扩展slave服务器
```
[20:16:03 root@mysql-2 ~]#xtrabackup --user=root --password=123456  --slave-info --backup --target-dir=xtrabackup

#在备份slave节点时加--slave-info参数会生成xtrabackup_slave_info文件里面会有同步信息，如果是备份的master则文件为空
[20:17:07 root@mysql-2 ~]#cat xtrabackup/xtrabackup_slave_info
CHANGE MASTER TO MASTER_LOG_FILE='binlog.000018', MASTER_LOG_POS=773;

#这样可以快速的扩展slave节点
```

### 1.4.1 示例
```
[20:24:26 root@mysql-3 ~]#cat /var/lib/mysql/xtrabackup_slave_info
CHANGE MASTER TO MASTER_LOG_FILE='binlog.000018',
MASTER_LOG_POS=773,
MASTER_USER='slave',
MASTER_PASSWORD='Zz@123456!',
MASTER_PORT=3306,
MASTER_HOST='192.168.10.181';
#slave节点
[20:18:31 root@mysql-2 ~]#ncat --listen --keep-open --send-only --max-conns=1 3307 -c "xtrabackup --backup --stream=xbstream --slave-info --host=127.0.0.1 --user=root -p123456"

#要扩展的节点
[20:20:09 root@mysql-3 ~]#ncat --recv-only 192.168.10.182 3307 | xbstream -x -C /var/lib/mysql

#处理数据
[20:21:02 root@mysql-3 ~]#xtrabackup --prepare --target-dir=/var/lib/mysql
[20:21:12 root@mysql-3 ~]#chown mysql: -R /var/lib/mysql
[20:21:33 root@mysql-3 ~]#systemctl restart mysql
[20:24:26 root@mysql-3 ~]#cat /var/lib/mysql/xtrabackup_slave_info
CHANGE MASTER TO MASTER_LOG_FILE='binlog.000018',
MASTER_LOG_POS=773,
MASTER_USER='slave',
MASTER_PASSWORD='Zz@123456!',
MASTER_PORT=3306,
MASTER_HOST='192.168.10.181';  #这里的日志与日志位置都有了只需要添加master的地址端口用户名即可
#备份数据库中同步信息，已经存在但是是日志格式与日志位置不对只需要执行下xtrabackup_slave_info中的sql语句从新启动slave即可

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: 192.168.10.181
                  Master_User: slave
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000018
          Read_Master_Log_Pos: 156
               Relay_Log_File: mysql-2-relay-bin.000003
                Relay_Log_Pos: 982
        Relay_Master_Log_File: binlog.000018
             Slave_IO_Running: No
            Slave_SQL_Running: No
#从新导入复制信息
[20:32:28 root@mysql-3 ~]#mysql -uroot -p123456 </var/lib/mysql/xtrabackup_slave_info 

#启动slave

如果直接启动slave线程会提示报错信息
mysql> start slave;
ERROR 1872 (HY000): Slave failed to initialize relay log info structure from the repository

需先执行，清理之前同步过来的中继日志之后在启动slave线程
reset slave;
start slave;

```
