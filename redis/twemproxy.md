redis数据分片
---


配置redis集群主从配置  
这里使用三台redis主机，每台主机启动三台redis,配置为一主两从模式  
分别配置redis从主机
```
# vim redis-6370
port 6380
pidfile /var/run/redis_6380.pid
slaveof 192.168.101.69 6379
requirepass 123456

# vim redis-6371
port 6380
pidfile /var/run/redis_6380.pid
slaveof 192.168.101.69 6379
requirepass 123456
```  

将配置拷贝到其他节点，分别启动redis  
```
# scp -rp redis node02:/opt/
# scp -rp redis node03:/opt/

src/redis-server conf/redis-6379.conf
src/redis-server conf/redis-6380.conf
src/redis-server conf/redis-6381.conf

# ps -ef |grep redis
root      35722      1  0 01:43 ?        00:00:00 src/redis-server 127.0.0.1:6379
root      35925      1  0 01:46 ?        00:00:00 src/redis-server 127.0.0.1:6380
root      35978      1  0 01:47 ?        00:00:00 src/redis-server 127.0.0.1:6381
```  



安装twemproxy  
https://github.com/twitter/twemproxy  
```
wget https://github.com/twitter/twemproxy/archive/v0.4.1.tar.gz
tar xvf v0.4.1.tar.gz
cd twemproxy-0.4.1/
autoreconf -fvi            #使用autoreconf工具生成一些编译的程序文件
mkdir /opt/twemproxy       #安装目录
./configure --prefix=/opt/twemproxy
make && make install
```  

配置  
```
mkdir /opt/twemproxy/conf  #创建配置文件目录
cp twemproxy-0.4.1/conf/nutcracker.yml /opt/twemproxy/conf/redis_master.conf     #将源码包里的配置文件拷贝到安装路径并重命名，文件名格式为redis_master.conf

vim redis_master.conf               #修改配置文
redis_master:                       #需要与配置文件名一样
  listen: 0.0.0.0:22121             #twemproxy监听地址
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  redis: true
  redis_auth: 123456                #redis的master认证
  server_retry_timeout: 2000
  server_failure_limit: 1
  servers:                          #配置redis的master节点
   - 192.168.101.66:6379:1
   - 192.168.101.67:6379:1
   - 192.168.101.68:6379:1
```  

启动服务  
```
mkdir /opt/twemproxy/{logs,pid}
/opt/twemproxy/sbin/nutcracker -c /opt/twemproxy/conf/redis_master.conf -p /opt/twemproxy/pid/redis_master.pid -o /opt/twemproxy/pid/redis_master.log -d 
```  
- -c指定配置文件  
- -p指定pid文件  
- -o指定log文件
- -d后台运行

测试  
```
redis-cli -h localhost -a 123456 -p 22121           #链接redis端口需要换成twemproxy的端口进行测试
set a a
set b b
set c c                                             #数据将根据算法写到不同的redis数据库里
```  

配置sentinel整合twemproxy管理3个redis的master节点  
---
所有sentinel节点需要配置此文件  
```
prot 26379
dir /usr/data/redis/sentinel
protected-mode no

sentinel monitor redis_master_group1 192.169.101.66 6379 2     #redis_master需要与配置文件一样为固定格式，后边的随便起
sentinel auth-pass redis_master_group1 123456
sentinel down-after-milliseconds redis_master_group1 10000
sentinel failover-timeout redis_master_group1 10000

sentinel monitor redis_master_group2 192.169.101.67 6379 2
sentinel auth-pass redis_master_group2 123456
sentinel down-after-milliseconds redis_master_group2 10000
sentinel failover-timeout redis_master_group2 10000

sentinel monitor redis_master_group3 192.169.101.68 6379 2
sentinel auth-pass redis_master_group3 123456
sentinel down-after-milliseconds redis_master_group3 10000
sentinel failover-timeout redis_master_group3 10000
```  
注意三台redis的master节点需要跑sentinel进程外，twemproxy节点也需要启动sentinel进程  

创建重启twemproxy的重启脚本  
```
mkdir /opt/twemproxy/sh

vim /opt/twemproxy/sh/client-reconfig.sh
#!/bin/sh 
#
monitor_name="$1"
master_old_ip="$4"
master_old_port="$5"
master_new_ip="$6"
master_new_port="$7"
twemproxy_name=$(echo $monitor_name |awk -F'_' '{print $1"_"$2}')

twemproxy_bin="/usr/local/twemproxy/sbin/nutcracker"
twemproxy_conf="/usr/local/twemproxy/conf/${twemproxy_name}.conf"
twemproxy_pid="/usr/local/twemproxy/pid/${twemproxy_name}.pid"
twemproxy_log="/usr/local/twemproxy/logs/${twemproxy_name}.log"
twemproxy_cmd="${twemproxy_bin} -c ${twemproxy_conf} -p ${twemproxy_pid} -o ${twemproxy_log} -d"

sed -i "s/${master_old_ip}:${master_old_port}/${master_new_ip}:${master_new_port}/" ${twemproxy_conf}

ps -ef |grep "${twemproxy_cmd}" |grep -v grep |awk '{print $2}'|xargs kill
${twemproxy_cmd}

sleep 1
ps -ef |grep "${twemproxy_cmd}" |grep -v grep
```

启动
```
redis-cli -h 192.168.101.66 -p 26379 sentinel set redis_master_group1 client-reconfig-script /opt/twemproxy/sh/client-reconfig.sh
redis-cli -h 192.168.101.67 -p 26379 sentinel set redis_master_group2 client-reconfig-script /opt/twemproxy/sh/client-reconfig.sh
redis-cli -h 192.168.101.68 -p 26379 sentinel set redis_master_group3 client-reconfig-script /opt/twemproxy/sh/client-reconfig.sh
```  
https://blog.csdn.net/shmilychan/article/details/73433804  
