ELK
====
官网：https://www.elastic.co/cn/  
一、安装jdk  最低要求jdk 8版本
```
$ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
# source /etc/profile
```

二、安装elasticsearch  
1下载elasticsearch  
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.0.tar.gz
tar -xvf elasticsearch-6.6.0.tar.gz -C /opt/module/
```  
2、创建普通用户用于启动elasticsearch默认不支持root启动  
```
# useradd elasticsearch
# chown -R elasticsearch:elasticsearch /opt/module/elasticsearch-6.6.0/
```  

3、修改配置文件
```
# vim /opt/module/elasticsearch-6.6.0/config/elasticsearch.yml
cluster.name: my-elk                               #集群的名称
node.name: my-test01                               #节点的名称
node.master: true                                  #是否为master（主节点），true：是，false：不是
node.data: true                                    #是否是数据节点，false：不是，true：是
bootstrap.memory_lock: true                        #锁定物理内存，开启后只使用物理内存，不会使用swap,建议开启
http.port: 9200                                    #es端口
transport.tcp.port: 9300                           #集群选举通信端口
network.host: 192.168.101.66         #监听的ip地址，如果是0.0.0.0，则表示监听全部ip
discovery.zen.ping.unicast.hosts: ["node001","node002","node003"]   #默认使用9300，如果修改可node001:9300
```  
4、优化内核限制文件数和打开的进程数  
```
cat  /etc/security/limits.conf  |grep "^*"
    * soft    nofile    924511
    * hard    nofile    924511
    * soft    nproc     924511
    * hard    nproc     924511
    * soft    memlock   unlimited    #内存锁，不限制
    * hard    memlock   unlimited
```  

centos7系统的nproc修改位置  
```
cat /etc/security/limits.d/20-nproc.conf
     * soft   nproc     20480
```  
5、修改内核参数
```  
# vim /etc/sysctl.conf
  fs.file-max=655360         #最大打开文件数
  vm.max_map_count=262144    #最大线程数，用于限制一个进程可以拥有的VMA(虚拟内存区域)的大小
# sysctl -p
```  

6、JVM调优  
```
# vim /opt/module/elasticsearch-6.6.0/config/jvm.options
-Xms2g
-Xmx2g
```  
- 可根据服务器内存大小，修改为合适的值。一般设置为服务器物理内存的一半最佳。  

7、启动elasticsearch  
```
# su - elasticsearch
$ cd /opt/module/elasticsearch-6.6.0/bin/
./elasticsearch -d
```  
-d 参数的意思是将elasticsearch放到后台运行。  
不能使用root身份运行  

8、curl访问方法  
1)查看单记得点的工作状态  
``` curl -X GET 'http://node001:9200/?pretty' ```  
2)查看cat支持的操作  
``` curl -X GET 'http://node001:9200/_cat' ```  
3)查看集群有几个节点  
``` curl -X GET 'http://node001:9200/_cat/nodes' ```  
``` curl -X GET 'http://node001:9200/_cat/nodes?v' ```  
4)查看集群健康状态  
``` curl -X GET 'http://node001:9200/_cluster/health?pretty' ```  
5）查看集群详细信息  
``` curl 'node001:9200/_cluster/state?pretty' ```

HEAD
---
1、安装head
```
安装运行环境
yum install -y nodejs npm

安装head
yum -y install git
git clone git://github.com/mobz/elasticsearch-head.git
cd elasticsearch-head/
npm install

如果报错： node npm install Error: CERT_UNTRUSTED  ssl验证问题，使用下面的命令取消ssl验证即可解决
npm config set strict-ssl false
```

2、配置head可以通过域名或者ip进行访问
```
vi Gruntfile.js
connect: {
        server: {
                opentions: {
                          prot: 9100,
                          base: '.',
                          keepalive: true,
                          hostname: '*'            #增加hostname
                 }
         }
}
```

3、配置head连接es
```
vi _site/app.js
搜索localhost:9200
this.base_uri = this.config.base_uri || this.prefs.get("app-base_uri") || "http://192.168.101.66:9200";
```

4、Es配置,增加跨域的配置(需要重启es才能生效)
```
修改elasticsearch.yml
vi config/elasticsearch.yml
http.cors.enabled: true
http.cors.allow-origin: "*"
```

5、启动head插件
```
cd node_modules/grunt/bin/
./grunt server &
netstat -ntlp
```

6、浏览器打开  
http://192.168.101.66:9100/



ES常用命令
---

1、创建索引库
```
curl -XPUT 'http://master:9200/test/'

创建数据
PUT请求,PUT是幂等方法，所以PUT用于更新操作,PUT，DELETE操作是幂等的,幂等是指不管进行多少次操作，结果都一样。
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/1 -d '{"name" : "jack","age" : 28}'

POST请求,POST用于新增操作比较合适,POST操作不是幂等的,多次发出同样的POST请求后，其结果是创建出了若干的资源。
使用自增ID（post）
curl -H "Content-Type: application/json" -XPOST http://master:9200/test/user/ -d '{"name" : "jack","age" : 28}'

在url后面添加参数,下面两种方法都可以
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/2?op_type=create -d '{"name":"lucy","age":18}'
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/3/_create -d '{"name":"lily","age":28}'

```
创建操作可以使用POST，也可以使用PUT，区别在于POST是作用在一个集合资源之上的（/articles），而PUT操作是作用在一个具体资源之上的（/articles/123）比如说很多资源使用数据库自增主键作为标识信息，而创建的资源的标识信息到底是什么只能由服务端提供，这个时候就必须使用POST


2、查询索引
```
根据id查询
curl -XGET http://master:9200/test/user/1

检索文档中的一部分，如果只需要显示指定字段
curl -XGET 'http://master:9200/test/user/1?_source=name&pretty'

查询指定索引库指定类型所有数据
curl -XGET http://master:9200/test/user/_search?pretty

根据条件进行查询name=john的
curl -XGET 'http://master:9200/test/user/_search?q=name:john&pretty=true‘
或者
curl -XGET 'http://master:9200/test/user/_search?q=name:john&pretty'
```

3、DSL 查询  
Domain Specific Language领域特定语言
```
新添加一个文档
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/4/_create -d '{"name":"qiqi","age":17}'

DSL查询
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_search -d'{"query":{"match":{"name":"qiqi"}}}'
```


4、MGET 查询  
使用mget API获取多个文档
```
先新建一个库
curl -XPUT 'http://master:9200/test2/'
curl -H "Content-Type: application/json" -XPOST http://master:9200/test2/user/1 -d '{"name" : "marry","age" : 16}'

查询不同_index的数据
curl -H "Content-Type: application/json" -XGET http://master:9200/_mget?pretty -d '{"docs":[{"_index":"test","_type":"user","_id":2,"_source":"name"},{"_index":"test2","_type":"user","_id":1}]}'

如果需要的文档在同一个_index或者同一个_type中，可以在URL中指定一个默认的/_index或者/_index/_type。
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_mget?pretty -d '{"docs":[{"_id":1},{"_id":2}]}‘

如果所有的文档拥有相同的_index 以及_type，直接在请求中添加ids的数组即可。
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_mget?pretty -d '{"ids":["1","2"]}'
```
   
