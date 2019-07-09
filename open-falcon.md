1、配置yum源  
```
# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# yum install epel-release -y
```  

2、安装配置redis  
```
# yum install redis -y
# vim  /etc/redis.conf
bind 0.0.0.0
# redis-server &
# netstat -tnlaup |grep 6379
tcp        0      0 0.0.0.0:6379            0.0.0.0:*               LISTEN      16652/redis-server  
tcp6       0      0 :::6379                 :::*                    LISTEN      16652/redis-server
```  

3、安装mysql  
```
yum -y install mysql mysql-server mysql-devel
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld.service
```  

4、初始化mysql数据库表  
```
# git clone https://github.com/open-falcon/falcon-plus.git
# cd falcon-plus/scripts/mysql/db_schema/
mysql -h 127.0.0.1 -u root -p < 1_uic-db-schema.sql
mysql -h 127.0.0.1 -u root -p < 2_portal-db-schema.sql
mysql -h 127.0.0.1 -u root -p < 3_dashboard-db-schema.sql
mysql -h 127.0.0.1 -u root -p < 4_graph-db-schema.sql
mysql -h 127.0.0.1 -u root -p < 5_alarms-db-schema.sql

查看是否导入
# mysql –u root -p
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| alarms             |
| dashboard          |
| falcon_portal      |
| graph              |
| mysql              |
| performance_schema |
| uic                |
+--------------------+
10 rows in set (0.01 sec)
```  

5、下载编译后的二进制包  
```
# wget https://github.com/open-falcon/falcon-plus/releases/download/v0.2.1/open-falcon-v0.2.1.tar.gz
# mkdir open-falcon
# tar xvf open-falcon-v0.2.1.tar.gz -C open-falcon
# cd open-falcon
# ls
agent  aggregator  alarm  api  gateway  graph  hbs  judge  nodata  open-falcon  plugins  public  transfer
```  

6、配置  
```
此配置会修改目录下所有配置
# grep -Ilr 3306  ./ | xargs -n1 -- sed -i 's/root:/root:123456/g'

随便挑一个配置查看是否配置成功
# vim graph/config/cfg.json
{
    "debug": false,
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:6071"
    },
    "rpc": {
        "enabled": true,
        "listen": "0.0.0.0:6070"
    },
    "rrd": {
        "storage": "./data/6070"
    },
    "db": {
        "dsn": "root:123456@tcp(127.0.0.1:3306)/graph?loc=Local&parseTime=true",        #账号:密码@tcp(数据库地址:端口)/库
        "maxIdle": 4
    },
    "callTimeout": 5000,
    "migrate": {
            "enabled": false,
            "concurrency": 2,
            "replicas": 500,
            "cluster": {
                    "graph-00" : "127.0.0.1:6070"
            }
    }
}
```  

7、启动  
```
# ./open-falcon start
[falcon-graph] 16736
[falcon-hbs] 16746
[falcon-judge] 16752
[falcon-transfer] 16760
[falcon-nodata] 16767
[falcon-aggregator] 16773
[falcon-agent] 16782
[falcon-gateway] 16789
[falcon-api] 16797
[falcon-alarm] 16810


# ./open-falcon check
        falcon-graph       DOWN               - 
          falcon-hbs         UP           16746 
        falcon-judge         UP           16752 
     falcon-transfer         UP           16760 
       falcon-nodata         UP           16767 
   falcon-aggregator         UP           16773 
        falcon-agent         UP           16782 
      falcon-gateway         UP           16789 
          falcon-api         UP           16797 
        falcon-alarm         UP           16810 
```  
