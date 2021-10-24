一、安装java 8
```
1、解压缩
# cd /usr/local/java
# tar -zxvf  jdk-8u73-linux-x64.tar.gz

2、配置环境变量
# vim /etc/profile
文件末尾追加如下配置
export JAVA_HOME=/usr/local/java/jdk1.8.0_73
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib:$CLASSPATH
export JAVA_PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin
export PATH=${JAVA_PATH}:$PATH

3、加载环境变量
source /etc/profile

4、验证
java -version 
java version "1.8.0_73"
java(TM) SE Runtime Environment (build 1.8.0_73-b02)
java HotSpot(TM) 64-Bit Server VM (build 25.73-b02,mixed mode)
```

二、安装python 2
```
# python -V
Python 2.7.5
```

三、在/etc/hosts里面添加集群服务器信息
```
192.168.1.74 node01
192.168.1.75 node02
192.168.1.76 node03
```

四、进行linux 系统内核 文件连接数的修改
```
vi /etc/sysctl.conf

vm.zone_reclaim_mode=0
vm.max_map_count = 262144
vm.swappiness = 1

sysctl -p

vi /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
```

五、创建cassandra用户名和数据存放目录
```
useradd cassandra
mkdir /opt/data1
mkdir /opt/data2
chmod 777 -R /opt/data1
chmod 777 -R /opt/data2
```

六、下载客户端
```
cd /opt
wget http://mirrors.hust.edu.cn/apache/cassandra/3.11.3/apache-cassandra-3.11.3-bin.tar.gz
tar xvf apache-cassandra-3.11.3-bin.tar.gz -C /opt
mv /opt/apache-cassandra-3.11.3    /opt/cassandra
chown -R cassandra.cassandra /opt/cassandra
```

| 目录 | 描述 |
|-----|------|
| bin | 这个目录下包含了启动 Cassandra 以及客户端相关操作的可执行文件，包括 query language shell（cqlsh）以及命令行界面（CLI）等客户端。同时还包含运行 nodetool 的相关脚本，操作 SSTables 的工具等等。 |
| conf | 这个目录下面包含了 Cassandra 的配置文件。必须包含的配置文件包括：assandra.yaml 以及 logback.xml，这两个文件分别是运行 Cassandra 必须包含的配置文件以及日志相关配置文件。同时还包含 Cassandra 网络拓扑配置文件等。 |
| doc | 这个目录包含 CQL 相关的 html 文档。 |
| interface | 这个文件夹下面只包含一个名为 cassandra.thrift 的文件。这个文件定义了基于 Thrift 语法的 RPC API，这个 Thrift 主要用于在 Java, C++, PHP, Ruby, Python, Perl, 以及 C# 等语言中创建相关客户端，但是在 CQL 出现之后，Thrift API 在 Cassandra 3.2 版本开始标记为 deprecated，并且会在 Cassandra 4.0 版本删除。 |
| javadoc | 这个文件夹包含使用 JavaDoc 工具生成的 html 文档。 |
| lib | 这个目录包含 Cassandra 运行时需要的所有外部库。 |
| pylib | 这个目录包含 cqlsh 运行时需要使用的 Python 库。 |
| tools | 这个目录包含用于维护 Cassandra 节点的相关工具。 |
| NEWS.txt | 这个文件包含当前及之前版本的 release notes 相关信息。 |
| CHANGES.txt | 这个文件主要包含一些 bug fixes 信息。 |

```
# ll
total 528
drwxr-xr-x 2 iteblog iteblog   4096 Apr  2 21:12 bin
-rw-r--r-- 1 iteblog iteblog   4832 Feb  3 06:09 CASSANDRA-14092.txt
-rw-r--r-- 1 iteblog iteblog 366951 Feb  3 06:09 CHANGES.txt
drwxr-xr-x 3 iteblog iteblog   4096 Apr  2 21:12 conf
drwxr-xr-x 4 iteblog iteblog   4096 Apr  2 21:12 doc
drwxr-xr-x 2 iteblog iteblog   4096 Apr  2 21:12 interface
drwxr-xr-x 3 iteblog iteblog   4096 Apr  2 21:12 javadoc
drwxr-xr-x 4 iteblog iteblog   4096 Apr  2 21:12 lib
-rw-r--r-- 1 iteblog iteblog  11609 Feb  3 06:09 LICENSE.txt
-rw-r--r-- 1 iteblog iteblog 112586 Feb  3 06:09 NEWS.txt
-rw-r--r-- 1 iteblog iteblog   2811 Feb  3 06:09 NOTICE.txt
drwxr-xr-x 3 iteblog iteblog   4096 Apr  2 21:12 pylib
drwxr-xr-x 4 iteblog iteblog   4096 Apr  2 21:12 tools
```

七、却换到cassandra用户下
```
su - cassandra
mkdir /opt/data1/commitlog
mkdir /opt/data1/data1file
mkdir /opt/data2/data2file
mkdir /opt/data2/saved_caches

cd /opt/cassandra/conf/
修改 cassandra.yaml 配置文件，配置第一台为seeds。
第一台配置：
cluster_name: 'prod Cluster'                       #集群的名字，同一个集群的名字要相同
data_file_directories:                             #数据文件存放路径
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog          #操作日志文件存放路径
saved_caches_directory: /opt/data2/saved_caches    #缓存文件存放路径
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "192.168.1.74"                  #集群种子节点ip,新加入集群的节点从种子节点中同步数据。可配置多个，中间用逗号隔开。
listen_address: 192.168.1.74                       #需要监听的IP或主机名
start_rpc: true
storage_port: 7000                                 #集群中服务器与服务器之间相互通信的端口号
native_transport_port: 9042                        #客户端通信端口
rpc_address: 192.168.1.74                          #用于监听客户端连接的地址


第二台配置：
cluster_name: 'prod Cluster'
data_file_directories:
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog
saved_caches_directory: /opt/data2/saved_caches
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "192.168.1.74"
listen_address: 192.168.1.75
start_rpc: true
storage_port: 7000
native_transport_port: 9042
rpc_address: 192.168.1.75


第三台配置：
cluster_name: 'prod Cluster'
data_file_directories:
     -  /opt/data1/data1file
     -  /opt/data2/data2file
commitlog_directory: /opt/data1/commitlog
saved_caches_directory: /opt/data2/saved_caches
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "192.168.1.74"
listen_address: 192.168.1.76
start_rpc: true
storage_port: 7000
native_transport_port: 9042
rpc_address: 192.168.1.76
```

配置环境变量
```
vim  ~/.bash_profile
export CASSANDRA_HOME=/opt/cassandra
export PATH=PATH:$CASSANDRA_HOME/bin:$CASSANDRA_HOME/bin
 
使配置生效
source ~/.bash_profile
```

八、启动
```
然后启动，先启动seed
/opt/cassandra/bin/cassandra

使用root用户启动需要-R参数
/opt/cassandra/bin/cassandra -R

/opt/cassandra/bin/cassandra -f              #将日志输出到前台

启动完成后，可使用
/opt/cassandra/bin/nodetool status
查看集群状态
# /opt/cassandra/bin/nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address       Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.1.74  189.2 KiB  256          68.9%             98436d32-5d5d-4e5e-afe2-84550e56daa9  rack1
UN  192.168.1.75  161.43 KiB  256          64.7%             2f52f14c-acbb-4241-9eff-6ed13b2827e5  rack1
UN  192.168.1.76  120.67 KiB  256          66.4%             450b02db-90a1-4b76-831a-9b0b9aa42c27  rack1
```
Cassandra的端口
| 端口号 | 描述 |
|--------|------|
| 7199 | JMX |
| 7000 | 节点间通信（如果启用了TLS，则不使用） |
| 7001 | TLS节点间通信（使用TLS时使用） |
| 9160 | Thrift客户端API |
| 9042 | CQL本地传输端口 |


启动、重启、关闭的脚本
```
vim /opt/cassandra/startme.sh

#!/bin/sh
CASSANDRA_DIR="/opt/cassandra"
 echo "************cassandra***************"
case "$1" in
        start)
                
                echo "*                                  *"
                echo "*            starting              *"
                nohup $CASSANDRA_DIR/bin/cassandra -R >> $CASSANDRA_DIR/logs/system.log 2>&1 &
                echo "*            started               *"
                echo "*                                  *"
                echo "************************************"
                ;;
        stop)
                
                echo "*                                  *"
                echo "*           stopping               *"
                PID_COUNT=`ps aux |grep CassandraDaemon |grep -v grep | wc -l`
                PID=`ps aux |grep CassandraDaemon |grep -v grep | awk {'print $2'}`
                if [ $PID_COUNT -gt 0 ];then
                		echo "*           try stop               *"
                        kill -9 $PID
                		echo "*          kill  SUCCESS!          *"
                else
                		echo "*          there is no !           *"
                echo "*                                  *"
                echo "************************************"
                fi
                ;;
        restart)
        		
        		echo "*                                  *"
                echo "*********     restarting      ******"
                $0 stop
                $0 start
                echo "*                                  *"
                echo "************************************"
                ;;
        status)
                $CASSANDRA_DIR/bin/nodetool status
                ;;
        
        *)
        echo "Usage:$0 {start|stop|restart|status}"
        
        exit 1
esac
```

```
./startme.sh start
./startme.sh restart
./startme.sh stop
```


九、开启用户名密码认证

1、编辑配置文件添加认证
```
# vim cassandra.yaml
authenticator: PasswordAuthenticator
```

2、重新启动cassandra并且根据默认用户登录cqlsh，用户名密码都是cassandra
```
# ./cassandra
# ./cqlsh -ucassandra -pcassandra
```

3、修改默认用户，进入cqlsh后
```
1 超级用户可以更改用户的密码或超级用户身份。为了防止禁用所有超级,超级用户不能改变自己的超级用户身份。普通用户只能改变自己的密码。附上用户名在单引号如果它包含非字母数字字符。附上密码在单引号。
2 CREATE USER test WITH PASSWORD '123456' SUPERUSER;  #创建一个超级用户
3 CREATE USER test1 WITH PASSWORD '123456' NOSUPERUSER;  #创建一个普通用户
4 ALTER USER test WITH PASSWORD '654321' ( NOSUPERUSER | SUPERUSER ) #修改用户
5 DROP USER cassandra #删除默认用户
```

4、无密码登录Cqlsh
```
vi ~/.cassandra/cqlshrc  #添加下面内容
[authentication]
username = test
password = 654321
```

