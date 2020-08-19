安装redis
---
```
yum -y install cpp binutils glibc glibc-kernheaders glibc-common glibc-devel gcc make gcc-c++ libstdc++-devel tcl

mkdir -p /usr/local/src/redis
cd /usr/local/src/redis
wget http://download.redis.io/releases/redis-3.0.2.tar.gz  或者 rz 上传
tar -xvf redis-3.0.2.tar.gz
cd redis-3.0.2
make
make test #这个就不要执行了，需要很长时间
make install


cp redis.conf /etc/
vi /etc/redis.conf
# 修改如下，默认为no
daemonize yes

#启动
redis-server /etc/redis.conf
#测试
redis-cli
```


主从复制（读写分离）
---
```
在redis中设置主从有2种方式：

#在redis.conf中设置slaveof
slaveof <masterip> <masterport>


#使用redis-cli客户端连接到redis服务，执行slaveof命令
slaveof <masterip> <masterport>
第二种方式在重启后将失去主从复制关系。

查看主从信息：INFO replication
```



配置哨兵
---
启动哨兵进程首先需要创建哨兵配置文件
```
vim sentinel.conf
输入内容：
sentinel monitor taotaoMaster 127.0.0.1 6379 1
```
- taotaoMaster：监控主数据的名称，自定义即可，可以使用大小写字母和“.-_”符号
- 127.0.0.1：监控的主数据库的IP
- 6379：监控的主数据库的端口
- 1：最低通过票数

启动哨兵进程：
```
redis-sentinel ./sentinel.conf
```

