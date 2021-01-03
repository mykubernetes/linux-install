xtrabackup实现完全备份、增量备份和部分备份
=====================================
安装 xtrabackup工具包
---
1、几个percona 官方yum源  
http://repo.percona.com/centos/  
https://www.percona.com/downloads/percona-release/  

2、下载rpm源
```
wget https://www.percona.com/redir/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
# rpm -ivh percona-release-0.0-1.x86_64.rpm
```

4、yum安装
```
# yum list percona-xtrabackup*
通过 yum 方式安装 percona-xtrabackup：
# yum install percona-xtrabackup-20.x86_64
```

一、完全备份
-----------
1、备份
```
#完全备份到指定目录
innobackupex --user=root --p 123 -H localhost /data/backup/
如果配置文件不在etc下需要手动指定批准文件
innobackupex --user=root --p 123 -H localhost --defaults-file=/usr/local/mysql/my.cnf /data/backup/

#查看备份目录内容 
ls /data/backup/2108_08-35-24
```

恢复时操作  
2、prepare数据库
-  创建完备份之后的数据还不能马上用来还原， 需要回滚未提交事务，前滚提交事务，让数据库文件保持一致性。
- prepare  的过程，其实是读取备份文件夹中的配置文件，然后 innobackupex  重做已提交事务，回滚未提交事务，之后数据就被写到了备份的数据文件(innodb  文件) 中，并重建日志文件。
- --user-memory：指定 prepare 阶段可使用的内存，内存多则速度快，默认为 10MB。
```
#在备份点目录下，合并已提交的事物，回滚未提交的事物
innobackupex --apply-log --defaults-file=/usr/local/mysql/my.cnf /data/backup/2108_08-35-24
```

3、恢复数据库
```
#复制备份点的备份目录，到此要恢复的目录下
innobackupex --copy-back --defaults-file=/usr/local/mysql/my.cnf /data/backup/2108_08-35-24
#修改mysql目录下属主属组
chown -R mysql.mysql  /var/lib/mysql/
#启动mysql
systemctl start mariadb.service
```  



二、增量备份  
----------
```
#因为Myisa不支持增量，修改存储引擎为innodb
USE 'hellodb';

#指明基于那个全量备份路径做增量备份
innobackupex -u root -p 123 --incrementanl /data/backup/  --incremental-basedir=/data/backup/2018_xx1
#指明基于上一个增量备份路径做增量备份
innobackupex -u root -p 123 --incrementanl /data/backup/  --incremental-basedir=/data/backup/2018_xx2

#备份二进制文件
cd /data/backup/2018.xx2
less xtravackup_binlog_info #查看最后位置
#保持二进制文件到指定目录
cd /var/lib/mysql
mysqlbinlog -j xxxx master-log.xxxxx > /data/backup/binlog.sql
```

#还原数据库
```
#准备，全量合并第一个增量备份，只提交不回滚
innobackupex --apply-log --redo-only 2018.xxx  --incremental-dir=2018.xx1
#准备，全量合并第二个增量备份，只提交不回滚
innobackupex --apply-log --redo-only 2018.xxx  --incremental-dir=2018.xx2
#对合并后的全量备份做回滚
innobackupex --apply-log  2018.xxx
#恢复
innobackupex --copy-back 2018.xxx
cd /var/lib/mysql/
chown -R mysql.mysql ./*
systemctl start mariadb.service
mysql
mysql < /data/backup/binlog.sql
```  

三、完全备份加差异备份
-------------------

1、准备
```
innobackupex --apply-log --redo-only BASEDIR
innobackupex --apply-log --redo-only BASEDIR  --incremental-dir=INCREMENTAL-DIR
```

2、恢复
```
innobackupex --copy-back BASEDIR
```  

mysql备份恢复例子
1、对 mysql 的 zztx 库进行备份
```
innobackupex --user=root --password=123456 --defaults-file=/etc/my.cnf --database=zztx --stream=tar  /data/back_data/  2>/data/back_data/zztx.log  |  gzip 1>/data/back_data/zztx.tar.gz
```
- --database=zztx 单独对 zztx 数据库做备份 ，若是不添加此参数那就那就是对全库做备份
- 2>/data/back_data/zztx.log 输出信息写入日志中
- 1>/data/back_data/zztx.tar.gz 打包压缩存储到该文件中

2、此处可以写个脚本做备份(backup.sh)
```
#!/bin/sh
echo "开始备份..."`date`
log=zztx01_`date +%y%m%d%H%M`.log
str=zztx01_`date +%y%m%d%H%M`.tar.gz
innobackupex --user=root --password=123456 --defaults-file=/etc/my.cnf --database=zztx --stream=tar /data/back_data/ 2>/data/back_data/$log | gzip 1>/data/back_data/$str
echo "备份完毕..."`date`
```

3、恢复数据
```
1) 先停止数据库：service mysqld stop
2) 解 压 tar -izxvf zztx.tar.gz -C /data/back_data/db/ (没 有 db ,需 要 mkdir/data/back_data/db/)
3) 恢复 innobackupex --user=root --password --defaults-file=/etc/my.cnf --apply-log /data/back_data/db/ innobackupex --user=root --password --defaults-file=/etc/my.cnf --copy-back /data/back_data/db/
4) 赋权 chown -R mysql.mysql /var/lib/mysql/*
5) 重启数据库 service mysqld restart
```
