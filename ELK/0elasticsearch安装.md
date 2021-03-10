ELK
====
官网：https://www.elastic.co/cn/  

| ES | 关系型数据库（比如Mysql） |
| :------: | :--------: |
| Index | Database |
| Type | Table |
| Document | Row |
| Field | Column |

- Node：运行单个ES实例的服务器
- Cluster：一个或多个节点构成集群
- Index：索引是多个文档的集合
- Document：Index里每条记录称为Document，若干文档构建一个Index
- Type：一个Index可以定义一种或多种类型，将Document逻辑分组
- Field：ES存储的最小单元
- Shards：ES将Index分为若干份，每一份就是一个分片
- Replicas：Index的一份或多份副本


一、安装jdk  最低要求jdk 8版本
```
$ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
# source /etc/profile
```

时钟同步
```
设置本地时间
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

集群时间日期同步NTP
yum install ntp
ntpdate pool.ntp.org
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
path.data: /opt/module/elasticsearch-6.6.0/data    #数据路径
path.logs: /opt/module/elasticsearch-6.6.0/datalog #日志路径
node.master: true                                  #是否为master（主节点），true：是，false：不是
node.data: true                                    #是否是数据节点，false：不是，true：是
bootstrap.memory_lock: true                        #锁定物理内存，开启后只使用物理内存，不会使用swap,建议开启
http.port: 9200                                    #es端口
transport.tcp.port: 9300                           #集群选举通信端口
network.host: 192.168.101.66         #监听的ip地址，如果是0.0.0.0，则表示监听全部ip
discovery.zen.ping.unicast.hosts: ["node001","node002","node003"]   #默认使用9300，如果修改可node001:9300
discovery.zen.ping_timeout: 10s
discovery.zen.minimum_master_nodes: 3

# 允许跨域请求
http.cors.enabled: true
http.cors.allow-origin: "*"
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

7、锁定物理内存，默认为开启不用配置  
设置memory_lock来锁定进程的物理内存地址,避免内存交换（swapped）来提高性能
```
vi config/elasticsearch.yml
bootstrap.memory_lock: true
```

8、启动elasticsearch  
```
# su - elasticsearch
$ cd /opt/module/elasticsearch-6.6.0/bin/
./elasticsearch -d
```  
-d 参数的意思是将elasticsearch放到后台运行。  
不能使用root身份运行  

9、curl访问方法  
1)查看单记得点的工作状态  
``` curl -X GET 'http://node001:9200/?pretty' ```  

2)查看cat支持的操作  
``` 
curl -X GET 'http://node001:9200/_cat'
```

3)查看节点信息  
```
curl -X GET 'http://node001:9200/_cat/nodes?v' 
curl -X GET 'http://node001:9200/_nodes/process?pretty'
、
```

4)查看集群健康状态  
```
curl 'nofr001:9200/_cat/health?v'
curl -X GET 'http://node001:9200/_cluster/health?pretty'
```  

5）查看集群详细信息  
``` curl 'node001:9200/_cluster/state?pretty' ```  

6)查看所有索引信息  
``` curl 'node001:9200/_cat/indices?v' ```  

7)计算集群中文档的数量
```
curl  -H "Content-Type: application/json"  -XGET 'http://localhost:9200/_count?pretty' -d '
{
  "query": {
    "match_all": {}
  }
} '
```
- green：所有的主分片和副本分片都已分配。你的集群是 100% 可用的。
- yellow：所有的主分片已经分片了，但至少还有一个副本是缺失的。不会有数据丢失，所以搜索结果依然是完整的。不过，你的高可用性在某种程度上被弱化。如果 更多的 分片消失，你就会丢数据了。把 yellow 想象成一个需要及时调查的警告。
- red：至少一个主分片（以及它的全部副本）都在缺失中。这意味着你在缺少数据：搜索只能返回部分数据，而分配到这个分片上的写入请求会返回一个异常。

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

1、添加和删除索引
```
1、创建索引库
curl -XPUT 'master:9200/test?pretty' -H 'Content-Type: application/json' -d '
{
    "settings": {
        "number_of_shards": 3,
        "number_of_replicas": 1
    }
}
'


2、删除索引
curl -XDELETE http://master:9200/test/user/1


3、删除索引中的一行数据
curl -XDELETE http://master:9200/test/user/1

4、获取删除后的索引状态
curl -XGET http://master:9200/test/user/1

如果文档存在，result属性值为deleted，_version属性的值+1

如果文档不存在，result属性值为not_found，但是_version属性的值依然会+1，这个就是内部管理的一部分，它保证了我们在多个节点间的不同操作的顺序都被正确标记了

注意：删除一个文档也不会立即生效，它只是被标记成已删除。Elasticsearch将会在你之后添加更多索引的时候才会在后台进行删除内容的清理。
```

2、查看所有分片
```
curl -XGET '101.201.34.96:9200/_cat/shards?pretty'

```


3、导入数据
```
1、PUT请求,PUT是幂等方法，所以PUT用于更新操作,PUT，DELETE操作是幂等的,幂等是指不管进行多少次操作，结果都一样。
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/1 -d '{"name" : "jack","age" : 28}'
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/_doc/1 -d '{"name" : "jack","age" : 28}'     #指定id

2、POST请求,POST用于新增操作比较合适,POST操作不是幂等的,多次发出同样的POST请求后，其结果是创建出了若干的资源。使用自增ID（post）
curl -H "Content-Type: application/json" -XPOST http://master:9200/test/user/ -d '{"name" : "jack","age" : 28}'     #自动生成id

3、通过文件导入
wget https://raw.githubusercontent.com/elastic/elasticsearch/master/docs/src/test/resources/accounts.json
curl -H "Content-Type: application/json" -XPOST "localhost:9200/bank/_doc/_bulk?pretty&refresh" --data-binary "@accounts.json"

4、在url后面添加参数,下面两种方法都可以
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/2?op_type=create -d '{"name":"lucy","age":18}'
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/3/_create -d '{"name":"lily","age":28}'
```
- _create创建数据也可以用?op_type=create替代,也可以不加_create，不存在则创建存在则覆盖
- put请求必须带id,如果id不存在则为创建，如果id存在则为更新
- post请求不用带id,如果id不存在则为创建，如果id存在则为更新


4、查看索引文档数量
```
curl -XGET '101.201.34.96:9200/test/_count?pretty'
```


5、查询索引
```
1、根据id查询
curl -XGET http://master:9200/test/user/1

1、查询索引并排序
curl -X GET "localhost:9200/bank/_search?q=*&sort=account_number:asc&pretty"

curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}
'

检索文档中的一部分，如果只需要显示指定字段
curl -XGET 'http://master:9200/test/user/1?_source=name&pretty'

查询指定索引库指定类型所有数据
curl -XGET http://master:9200/test/user/_search?pretty

根据条件进行查询name=john的
curl -XGET 'http://master:9200/test/user/_search?q=name:john&pretty=true‘
或者
curl -XGET 'http://master:9200/test/user/_search?q=name:john&pretty'
```
- _search 查询
- q=* ES批量索引中的所有文档
- sort=account_number:asc 表示根据account_number按升序对结果排序
- match_all：匹配所有文档。默认查询



6、DSL 查询 搜索
Domain Specific Language领域特定语言
```
1、查找name是qiqi的
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_search -d'{"query":{"match":{"name":"qiqi"}}}'


2、查询男性，年龄大于30
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_search -d '
{
   "query": {
      "bool": {
         "filter": {
             "ranage": {
                "age": {
                   "gt": 30
                }
              }
          },
          "must": {
             "match": {
                "sex": "男"
              }
           }
       }
   }
}'

3、查询余额大于或等于20000且小于等于30000的账户
curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": { "match_all": {} },
      "filter": {
        "range": {
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}
'

4、查询所有文档，返回10-19页：
curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "from": 10,
  "size": 19
}
'

5、全文搜索 "张三" "李四"
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_search -d'{"query":{"match":{"name":"张三 李四"}}}'


6、返回_source字段中的几个字段：
curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "_source": ["account_number", "balance"]
}
'
```
- 通过 from 和 size 进行分页，默认最多10000条数据
- from未指定，默认为0
- size未指定，默认为10


```
# 查询包含mill和lane的所有账户，该bool must指定了所有必须为真才匹配。
curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
'


# 查询包含mill或lane的所有账户
curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "should": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
'

match_phrase
curl -XGET '101.201.34.96:9200/mtestindex3/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
    "query": {
        "match_phrase": {
            "address": "北京 昌平"
        }
    }
}
'

term
curl -XGET '101.201.34.96:9200/mtestindex3/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
    "query": {
        "term": {
            "age": 22
        }
    }
}
'



curl -XGET '101.201.34.96:9200/test/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
    "query": {
        "bool": {
            "must": {
                "match": {
                    "address": "北京 昌平"
                }
            },
            "must_not": {
                "term": {
                    "age": 40
                }
            },
            "should": {
                "term": {
                    "age": 20
                }
            },
            "filter": {
                "range": {
                    "age": {
                        "gt": 12
                    }
                }
            }
        }
    }
}
'
```
- must 条件必须都满足，会进行打分
- must_not 条件必须都不满足
- should 如果满足任意条件，将增加 _score ，否则无任何影响。主要用于修正每个文档的相关性得分
- filter 条件必须都满足，不进行打分，效率高，还会进行缓存


高亮显示
```
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_search -d'
{
  "query": {
    "match": {
      "name": "张三 李四"
    }
  },
  "highlight": {
     "fields": {
        "name": {}
      }
   }
  
}'
```

聚合搜索
```
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_search -d'
{
   "aggs": {
      "all_interests": {
         "terns": {
             "field": "age"
          }
       }
    }
 }
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

5、HEAD 的使用  
如果只想检查一下文档是否存在，可以使用HEAD来替代GET方法，这样就只会返回HTTP头文件
```
curl -i -XHEAD http://master:9200/test/user/1
```

6、ES 更新  
ES可以使用PUT或者POST对文档进行更新(全部更新)，如果指定ID的文档已经存在，则执行更新操作  
注意:执行更新操作的时候  
- ES首先将旧的文档标记为删除状态
- 然后添加新的文档
- 旧的文档不会立即消失，但是你也无法访问
- ES会在你继续添加更多数据的时候在后台清
- 理已经标记为删除状态的文档

局部更新，可以添加新字段或者更新已有字段（必须使用POST）
```
curl -H "Content-Type: application/json" -XPOST http://master:9200/test/user/1/_update -d '{"doc":{"name":"baby","age":27}}‘

curl -XGET http://master:9200/test/user/1?pretty
```


8、ES 批量操作-bulk  
bulk API可以帮助我们同时执行多个请求
```
格式：
action：index/create/update/delete
metadata：_index,_type,_id
request body：_source(删除操作不需要)
{ action: { metadata }}
{ request body }
{ action: { metadata }}
{ request body }

create 和index的区别,如果数据存在，使用create操作失败，会提示文档已经存在，使用index则可以成功执行。
```

```
使用文件的方式新建一个requests文件
vi requests
{"index":{"_index":"test","_type":"user","_id":"6"}}
{"name":"mayun","age":51}
{"update":{"_index":"test","_type":"user","_id":"6"}}
{"doc":{"age":52}}

执行批量操作
curl -H "Content-Type: application/json" -XPOST http://master:9200/_bulk --data-binary @requests;

curl -XGET http://master:9200/test/user/6?pretty
```

bulk请求可以在URL中声明/_index 或者/_index/_type.  
bulk一次最大处理多少数据量
- bulk会把将要处理的数据载入内存中，所以数据量是有限制的.
- 最佳的数据量不是一个确定的数值，它取决于你的硬件，你的文档大小以及复杂性，你的索引以及搜索的负载.
- 一般建议是1000-5000个文档，如果你的文档很大，可以适当减少队列，大小建议是5-15MB，默认不能超过100M，可以在es的配置文件中修改这个值http.max_content_length: 100mb.
- https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-http.html


9、ES 版本控制  
普通关系型数据库使用的是（悲观并发控制（PCC））当我们在修改一个数据前先锁定这一行，然后确保只有读取到数据的这个线程可以修改这一行数据.

ES使用的是（乐观并发控制（OCC））ES不会阻止某一数据的访问，然而，如果基础数据在我们读取和写入的间隔中发生了变化，更新就会失败，这时候就由程序来决定如何处理这个冲突。它可以重新读取新数据来进行更新，又或者将这一情况直接反馈给用户。

ES如何实现版本控制(使用es内部版本号)
```
首先得到需要修改的文档，获取版本(_version)号
curl -XGET http://master:9200/test/user/2

在执行更新操作的时候把版本号传过去
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/2?version=1 -d '{"name":"john","age":29}'
curl -H "Content-Type: application/json" -XPOST http://master:9200/test/user/2/_update?version=2 -d'{"doc":{"age":30}}'
如果传递的版本号和待更新的文档的版本号不一致，则会更新失败
```

cluster
---
- 集群中有多个节点，其中有一个为主节点，这个主节点是可以通过选举产生的。es是去中心化的，与任何一个节点的通信和与整个es集群通信是等价的。
- 主节点的职责是负责管理集群状态，包括管理分片的状态和副本的状态，以及节点的发现和删除。
- 注意：主节点不负责对数据的增删改查请求进行处理，只负责维护集群的相关状态信息。
集群状态查看
```
http://192.168.20.210:9200/_cluster/health?pretty
```


Shards
---
- 代表索引分片，es可以把一个完整的索引分成多个分片，这样的好处是可以。把一个大的索引水平拆分成多个，分布到不同的节点上。构成分布式搜索，提高性能和吞吐量。
- 分片的数量只能在创建索引库时指定，索引库创建后不能更改。
```
curl -H "Content-Type: application/json" -XPUT 'master:9200/test3/' -d'{"settings":{"number_of_shards":3}}'
```
默认是一个索引库有5个分片，每个分片中最多存储2,147,483,519条数据

https://www.elastic.co/guide/en/elasticsearch/reference/6.6/getting-started-concepts.html


Replicas
---
es可以给索引分片设置副本，副本的作用：
- 一是提高系统的容错性，当某个节点某个分片损坏或丢失时可以从副本中恢复。
- 二是提高es的查询效率，es会自动对搜索请求进行负载均衡。
- 副本的数量可以随时修改
```
可以在创建索引库的时候指定
curl -H "Content-Type: application/json" -XPUT 'master:9200/test4/' -d'{"settings":{"number_of_replicas":3}}'
```
默认是一个分片有1个副本
```
index.number_of_replicas: 1
```
注意：主分片和副本不会存在一个节点中

recovery
---
- 数据恢复或叫数据重新分布，es在有节点加入或退出时会根据机器的负载对索引分片进行重新分配，挂掉的节点重新启动时也会进行数据恢复。

Gateway
---
- es索引的持久化存储方式，es默认是先把索引存放到内存中，当内存满了时再持久化到硬盘。当es集群关闭再重新启动时就会从gateway中读取索引数据。es支持多种类型的gateway，有本地文件系统（默认），分布式文件系统，Hadoop的HDFS和Amazon的s3云存储服务。

Discovery.zen
---
代表es的自动发现节点机制，es是一个基于p2p的系统，它先通过广播寻找存在的节点，再通过多播协议来进行节点之间的通信，同时也支持点对点的交互。
```
如果是不同网段的节点如何组成es集群禁用自动发现机制
discovery.zen.ping.multicast.enabled: false
```

```
设置新节点被启动时能够发现的主节点列表
discovery.zen.ping.unicast.hosts: ["192.168.20.210","192.168.20.211", "192.168.20.212"]
```

Transport
---
- es内部节点或集群与客户端的交互方式，默认内部是使用tcp协议进行交互，同时它支持http协议（json格式）、thrift、servlet、memcached、zeroMQ等的传输协议（通过插件方式集成）。

settings
---
https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html  
例如：分片数量，副本数量
```
查看
curl -XGET http://master:9200/test/_settings?pretty

# 操作不存在索引(创建)：
curl -H "Content-Type: application/json" -XPUT 'http://master:9200/test5/' -d'{"settings":{"number_of_shards":3,"number_of_replicas":2}}'

# 操作已存在索引（修改）：
curl -H "Content-Type: application/json" -XPUT 'http://master:9200/test5/_settings' -d'{"index":{"number_of_replicas":1}}'
```

Mapping
---
https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html

```
# 查询索引库的mapping信息：
curl -XGET http://master:9200/test/user/_mapping?pretty

# 操作不存在的索引（创建）：
curl -H "Content-Type: application/json" -XPUT 'http://master:9200/test6' -d'{"mappings":{"user":{"properties":{"name":{"type":"text","analyzer": "ik_max_word"}}}}}'

# 操作已存在的索引（修改）：
curl -H "Content-Type: application/json" -XPOST http://master:9200/test6/user/_mapping -d '{"properties":{"name":{"type":"text","analyzer":"ik_max_word"}}}'
```

索引数据快照备份和恢复
===

一.搭建NFS共享存储服务器

1.安装 nfs服务
```
yum install -y nfs-utils
```

2.开机启动
```
systemctl enable rpcbind.service
systemctl enable nfs-server.service
```

3.分别启动rpcbind和nfs服务：
```
systemctl start rpcbind.service
systemctl start nfs-server.service
```

4.firewalld 防火墙针对es节点内网ip开放NFS服务监听端口：
```
111 udp端口    20048 tcp端口    2049 tcp 和 udp全开
```

5.创建本地数据共享目录 并设置权限  
```
mkdir /data/db/elasticsearch/backup
chmod 777 /data/db/elasticsearch/backup
chown -R elasticsearch:elasticsearch /data/db/elasticsearch/backup
```

6.配置NFS目录访问权限
```
vim etc/exports
/data/db/elasticsearch/backup 192.168.85.39(rw,sync,all_squash)     192.168.85.33(rw,sync,all_squash) 192.168.85.36(rw,sync,all_squash)
exports -r //生效
exports -s //查看
```

7.es节点上安装客户端
```
yum -y install showmount
开启服务：
systemctl enable rpcbind.service
systemctl start rpcbind.service
```

8.创建挂载目录
```
mkdir /mnt/elasticsearch
chmod 777 elasticsearch

挂载共享目录到本地
mount -t nfs 192.168.5.63:/data/db/elasticsearch/backup  /mnt/elasticsearch

df -h //查看确认是否成功挂载
```

二、创建快照仓库

| 参数 | 含义 |
|------|------|
| location | 快照存储位置 |
| compress | 是否压缩源文件，默认为true |
| chunk_size | 如果有需要，可以将大文件分解为多个小文件，默认不开启 |
| max_restore_bytes_per_sec | 指定数据恢复速度，默认为 40m/s |
| max_snapshot_bytes_per_sec | 指定创建快照时的速度，默认为 40m/s |
| readonly | 设置为只读仓库，默认为false |

```
curl -XPUT http://192.168.85.39:9002/_snapshot/backup -d'
{
"type": "fs",
"settings": {
"location": "/mnt/elasticsearch/backup",
"compress": true,
"max_snapshot_bytes_per_sec" : "50mb",
"max_restore_bytes_per_sec" : "50mb"
}
}'

1.可在es任一节点操作
2.backup: 指定仓库名称为backup  ,生成的备份文件存放路径为/mnt/elasticsearch/backup
3.max_snapshot_bytes_per_sec,max_restore_bytes_per_sec 限定备份和恢复的数据字节内容大小为50mb,
为了防止磁盘IO过高。数值越大,备份恢复速度越快。50mb为推荐值，IO性能高的机器可不限制

在创建一个仓库时，会即刻在集群所有节点验证确保其功能在所有节点可用,verify 参数可以用来取消该验证
curl -XPUT http://192.168.85.39:9002/_snapshot/backup/_verify -d '
{
    "type": "fs",
    "settings": {
        "location": "/mnt/elasticsearch/backup",
        "compress": true
    }
}'
```

三、创建快照备份

1.针对全索引快照备份
```
curl -XPUT 192.168.85.39:9002/_snapshot/backup/snapshot_all?pretty
```
- 指定备份到仓库backup
- 快照名称为 snapshot_all

2.针对指定某个单独索引快照备份（为了区分不同索引备份目录,建议仓库用索引名称命名）
```
单独快照备份user_event_201810这个索引

1.先针对索引创建仓库
curl -XPUT http://192.168.85.39:9002/_snapshot/user_event_201810 -d'
{
"type": "fs",
"settings": {
"location": "/mnt/elasticsearch/user_event_201810",
"compress": true,
"max_snapshot_bytes_per_sec" : "50mb",
"max_restore_bytes_per_sec" : "50mb"
}
}'


2.快照备份索引user_event_201810操作
curl -XPUT http://192.168.85.39:9002/_snapshot/user_event_201810/user_event_201810?wait_for_completion=true -d '
{
"indices":"user_event_201810",
"ignore_unavailable": "true",
"include_global_state": false
}'

3.对多个索引创建快照
curl -XPUT http://192.168.85.39:9002/_snapshot/user_event_201810/user_event_201810?wait_for_completion=true -d '
{
"indices":"user_event_201810","user_event_201811","user_event_201811"
"ignore_unavailable": "true",
"include_global_state": false
}'
```
- 创建的仓库名为user_event_201810
- 存放的文件目录为/mnt/elasticsearch/user_event_201810
- ?wait_for_completion=true 执行完成返回结果状态
- indices:指定索引源为user_event_201810
- ignore_unavailable: 在创建快照时会忽略不存在的索引
- include_global_state: 阻止集群全局状态信息被保存为快照的一部分,默认情况下，如果一个快照中的一个或者多个索引没有所有主分片可用，整个快照创建会失败

3.查看快照信息

| 状态 | 含义 |
|-----|-------|
| IN_PROGRESS | 正在创建快照 |
| SUCCESS | 快照创建成功 |
| FAILED | 快照创建完成，但是有错误，数据不会保存 |
| PARTIAL | 整个集群备份完成，但是至少有一个shard数据存贮失败，会有更具体报错信息 |
| INCOMPATIBLE | 创建快照的es版本和当前集群es版本不一致 |

```
curl -XGET http://192.168.85.39:9002/_snapshot/user_event_201810
```

4.查看已存在仓库
```
curl 192.168.85.39:9002/_cat/repositories?v
```

5.查看快照
```
1、查看全部快照
curl -XGET http://192.168.85.39:9002/_snapshot？
curl -XGET http://192.168.85.39:9002/_snapshot/_all

2、查看仓库信息
curl -XGET http://192.168.85.39:9002/_snapshot/user_event_201810

3、查看指定索引的快照
curl -XGET http://192.168.85.39:9002/_snapshot/user_event_201810/user_event_201810

4、查看当前正在运行的快照
curl -XGET http://192.168.85.39:9002/_snapshot/user_event_201810/_current

5、删除快照user_event_201810
curl -XDELETE http://192.168.85.39:9002/_snapshot/user_event_201810/user_event_201810

6、删除仓库user_event_201810
curl -XDELETE http://192.168.85.39:9002/_snapshot/user_event_201810

7、删除所有仓库
curl -XDELETE http://192.168.85.39:9002/_snapshot
curl -XDELETE http://192.168.85.39:9002/_snapshot/_all
```

四.恢复快照备份数据到es集群

1.恢复前准备
```
0、挂载之前部署的NFS或者将之前备份的镜像打包执行1、2、两步
mount -t nfs 192.168.5.63:/data/db/elasticsearch/backup /mnt/elasticsearch

1、在需要恢复的机器上执行
mkdir /mnt/elasticsearch/user_event_201810

2、修改目录权限
chown -R es:es /mnt/elasticsearch/user_event_201810
chmod -R 777 /mnt/elasticsearch/user_event_201810

3、修改配置文件
vim elasticsearch.yml
path.repo: "/mnt/elasticsearch/user_event_201810"             #仓库路径

4、创建索引仓库
curl -XPUT http://192.168.85.40:9002/_snapshot/user_event_201810 -d'
{
"type": "fs",
"settings": {
"location": "/mnt/elasticsearch/user_event_201810",
"compress": true,
"max_snapshot_bytes_per_sec" : "50mb",
"max_restore_bytes_per_sec" : "50mb"
}
}'
```

2.针对全索引快照备份的恢复操作
```
curl -XPOST http://192.168.85.39:9200/_snapshot/backup/snapshot_all/_restore
```
- 指定仓库名称backup
- 指定快照备份名称snapshot_all

3.针对某个指定索引的快照备份恢复操作
```
针对索引user_event_201810快照恢复
curl -XPOST http://192.168.85.39:9002/_snapshot/user_event_201810/user_event_201810/_restore
```
- 指定仓库名称user_event_201810
- 指定快照备份名称user_event_201810

4、针对多个指定索引的快照备份恢复操作
```
curl -XPOST http://192.168.85.39:9002/_snapshot/user_event_201810/user_event_201810/_restore -d {
  "indices": "index_1,index_2",
  "ignore_unavailable": true,
  "include_global_state": true,
  "rename_pattern": "index_(.+)",
  "rename_replacement": "restored_index_$1"
}
```
- include_global_state 指定要恢复的索引和允许恢复集群全局状态
- 索引列表支持多索引语法。rename_pattern 和 rename_replacement 选项在恢复时通过正则表达式来重命名索引
- include_aliases 为 false 可以防止与索引关联的别名被一起恢复


5.查看快照状态
```
curl -XGET http://192.168.85.39:9002/_snapshot/user_event_201810/user_event_201810/_status
```

五、elasticsearch其中一节点配置文件
```
cluster.name: my-application1
node.name: node-3
path.data: /data/db/elasticsearch
path.logs: /data/log/elasticsearch/logs
path.repo: ["/mnt/elasticsearch"]           #快照路径
network.host: 192.168.85.33
http.port: 9002
transport.tcp.port: 9102
node.master: true
node.data: true
discovery.zen.ping.unicast.hosts: ["192.168.85.39:9102","192.168.85.36:9102","192.168.85.33:9102"]
discovery.zen.minimum_master_nodes: 2
indices.query.bool.max_clause_count: 10240
http.cors.enabled: true
http.cors.allow-origin: "*"
```

NFS
```
mount -t nfs 192.168.5.63:/data/db/elasticsearch/backup /mnt/elasticsearch
```
