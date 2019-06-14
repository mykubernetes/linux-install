codis
===
官方托管代码  
https://github.com/CodisLabs/codis  

一、安装go语言支持  
```
#解压文件
tar -zxvf go1.7.1.linux-amd64.tar.gz -C /usr/local/
#配置环境变量
vim /etc/profile
export GOROOT=/usr/local/go
export PATH=\$PATH:\$GOROOT/bin
#重载配置
source /etc/profile
#检查是否安装成功
go version
```  

二、安装codis  
1、创建go语言工作路径  
``` mkdir -p /usr/data/gowork ```  

2、修改环境属性追加此配置的路径（程序下载的信息都要通过此路径完成）  
```
# vim /etc/profile
export GOPATH=/usr/data/gowork
export GOROOT=/usr/local/go
export PATH=\$PATH:\$GOROOT/bin:$GOPATH/bin:

#重载配置
# source /etc/profile
```  

3、安装go编译依赖库  
```
# go get github.com/tools/godep 
# cd /usr/data/gowork
# ls        #会出现3个目录
bin pkg src
# cd  src/github.com/tools/godep/      #下载的依赖库保存到此位置
# go install ./                        #安装到bin目录里
```  

4、下载godis  
```
go get -u -d github.com/CodisLabs/codis
```  

5、进入codis源代码下载目录并编译安装  
```
cd /usr/data/gowork/src/github.com/CodisLabs/codis
make && make install
```  

6、为方便使用，建立新的目录  
```
mkdir -p /usr/local/codis/{logs,conf,bin}
#拷贝所有课执行文件到新目录
cp -r /usr/data/gowork/src/github.com/CodisLabs/codis/bin/ /usr/local/codis/bin/
```  

部署codisServer
---

1、拷贝redis的配置文件到codis的目录中  
```
# mkdir -p /usr/local/codis/conf/redis_conf/
# cp /usr/data/gowork/src/github.com/CodisLabs/codis/extern/redis-3.2.4/redis.conf /usr/local/codis/conf/redis_conf/redis-6379.conf
```  

2、编辑redis配置文件  
```
vim /usr/local/codis/conf/redis_conf/redis-6379.conf
# bind 127.0.0.1    #注释bind
port 6379
daemonize yes
pidfile /usr/data/redis/redis-6379/run/redis_6379.pid
logfile /usr/data/redis/redis-6379/log/logs_6379.log
dir /usr/data/redis/redis-6379/db
requirepass 123456
```  

3、将redis配置文件复制为redis-6380.conf和redis-6381.conf并修改端口和文件夹路径  
```
cp /usr/local/codis/conf/redis_conf/redis-6379.conf /usr/local/codis/conf/redis_conf/redis-6380.conf
cp /usr/local/codis/conf/redis_conf/redis-6379.conf /usr/local/codis/conf/redis_conf/redis-6381.conf
```  

4、建立配置文件里的目录  
```
mkdir -p /usr/data/redis/redis-6379/{db,run,log}
mkdir -p /usr/data/redis/redis-6380/{db,run,log}
mkdir -p /usr/data/redis/redis-6381/{db,run,log}
```  

5、配置linux的环境参数，将所有的可用内存交个redis服务使用  
```
echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
sysctl -p
```  

6、使用codis-server启动redis  
```
/usr/local/codis/bin/codis-server /usr/local/codis/conf/redis_conf/redis-6379.conf
/usr/local/codis/bin/codis-server /usr/local/codis/conf/redis_conf/redis-6380.conf
/usr/local/codis/bin/codis-server /usr/local/codis/conf/redis_conf/redis-6381.conf
```  

7、使用codis的客户端工程redis-cli连接redis测试  
```
/usr/data/gowork/src/github.com/CodisLabs/codis/extern/redis-3.2.4/src/redis-cli -h 192.168.101.66 -a 123456 -p 6379
```  

8、将上边所有操作在其他节点执行，并启动redis  


部署zookeeper
---
https://github.com/mykubernetes/hadoop/blob/master/%E5%88%86%E5%B8%83%E5%BC%8F%E9%83%A8%E7%BD%B2zookeeper.md  


codis-dashboard
---
1、生成配置文件  
```
# cd /usr/local/codis/bin/
# codis-dashboard --default-config | tee /usr/local/codis/conf/dashboard.ini
# vim /usr/local/codis/conf/dashboard.ini
coordinator_name = "zookeeper"             #协调器的名字有zk和etcd两个
coordinator_addr = "192.168.101.66:2181"   #协调器的地址
product_name = "codis-1"                   #当前codis的标记名称
product_auth = "123456"                    #
admin_addr = "0.0.0.0:18080"               #后台管理路径的地址和端口
sentine_quorum =2                          #配置有几个哨兵，默认
```  

2、启动  
```
nohup /usr/local/codis/bin/codis-dashboard --ncpu=2 --config=/usr/local/codis/conf/dashboard.ini --log=/usr/local/codis/logs/dashboard.log --log-leven=WARN > /dev/null 2>&1 &
```  

codis-FE
---

1、生成配置文件  
```
/usr/local/codis/bin/codis-admin --dashboard-list --zookeeper=192.168.101.66 | tee /usr/local/codis/conf/codis.json
```  

2、启动codis-fe的程序打开前端图形管理界面  
```
nohup /usr/local/codis/bin/codis-fe --ncpu=2 --log=/usr/local/codis/logs/fe.log --log-leven=WARN --dashboard-list=/usr/local/codis/conf/codis.json --listen=192.168.101.66:18090 > /dev/null 2>&1 &
```  

3、打开浏览器，使用web进行配置  
http://192.168.101.66:18090  


codis-proxy
---
1、生成配置文件  
```
# /usr/local/codis/bin/codis-proxy --default-config | tee /usr/local/codis/conf/proxy.ini
# vim /usr/local/codis/conf/proxy.ini
product_name = "codis-1"                   #当前codis的标记名称
product_auth = "123456" 
admin_addr = "0.0.0.0:11080"
jobis_addr = "192.168.101.66:2181"         #zk地址
```  

2、启动codis-proxy  
```
nohup /usr/local/codis/bin/codis-proxy --ncpu=2 --config=/usr/local/codis/conf/proxy.ini --log=/usr/local/codis/logs/proxy.log --log-level=WARN > /dev/null 2>&1 & 
```  

codis-Admin
---

1、通过命令创建组  
```
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --create-group --gid=1
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --create-group --gid=2
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --create-group --gid=3
```  

2、为组添加服务器  
```
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=1 --addr=192.168.101.66:6379
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=1 --addr=192.168.101.66:6380
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=1 --addr=192.168.101.66:6381

/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=2 --addr=192.168.101.67:6379
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=2 --addr=192.168.101.67:6380
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=2 --addr=192.168.101.67:6381

/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=3 --addr=192.168.101.68:6379
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=3 --addr=192.168.101.68:6380
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --group-add --gid=3 --addr=192.168.101.68:6381
```  

3、设置主从同步,主要设置两台从主机的同步状态  
```
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.66:6379
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.66:6380
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.66:6381

/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.67:6379
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.67:6380
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.67:6381

/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.68:6379
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.68:6380
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --sync-action --create --addr=192.168.101.68:6381
```  

4、设置数据的可用工作插槽  
```
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --slot-action --create-ranage --beg=1 --end=300 --gid=1
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --slot-action --create-ranage --beg=301 --end=700 --gid=2
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --slot-action --create-ranage --beg=701 --end=1023 --gid=3
```  
注意：插槽1到1023之间  

5、创建一个代理codis-proxy  
```
/usr/local/codis/bin/codis-admin --dashboard=192.168.101.66:18080 --create-proxy --addr=192.168.101.66:11080
```  

