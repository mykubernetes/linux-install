ELK
====
官网：https://www.elastic.co/cn/  

| ES | 关系型数据库（比如Mysql） |
| :------: | :--------: |
| Index | Database |
| Type(在7.0之后type为固定值_doc) | Table |
| Document | Row |
| Field | Column |
| Mapping | Schema |
| DSL(Descriptor Structure Language) | SQL |

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
discovery.zen.ping.multicast.enabled: false        #如果是不同网段的节点如何组成es集群禁用自动发现机制

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
```
curl -X GET 'http://node001:9200/?pretty'
```

2)查看cat支持的操作  
``` 
curl -X GET 'http://node001:9200/_cat'
```

3)查看节点信息  
```
curl -X GET 'http://node001:9200/_cat/nodes?v' 
curl -X GET 'http://node001:9200/_nodes/process?pretty'
```

4)查看集群健康状态  
```
curl 'node001:9200/_cat/health?v'
curl -X GET 'http://node001:9200/_cluster/health?pretty'
```  

5）查看集群详细信息  
```
curl 'node001:9200/_cluster/state?pretty'
```

6)查看所有索引信息  
```
curl 'node001:9200/_cat/indices?v'
```

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

REST API可以作用
- 1.检查集群,节点,索引的健康,状态,统计
- 2.管理集群,节点,索引的数据和元数据
- 3.执行CRUD和搜索操作
- 4.执行高级搜索操作,比如分页,排序,过滤,脚本,聚合等


1、添加和删除索引
```
1、创建索引库
curl -XPUT 'master:9200/test?pretty' -H 'Content-Type: application/json' -d '
{
    "settings": {
        "number_of_shards": 3,
        "number_of_replicas": 2
    }
}
'

2、查看索引设置
curl -XGET http://master:9200/test/_settings?pretty

3、修改索引策略
curl -H "Content-Type: application/json" -XPUT 'http://master:9200/test5/_settings' -d'{"index":{"number_of_replicas":1}}'

4、删除索引
curl -XDELETE http://master:9200/test

5、删除索引中的一行数据
curl -XDELETE http://master:9200/test/user/1

6、获取删除后的索引状态
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
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/1 -d '{"name" : "jack","age" : 28}'     #指定id

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


4、查询索引
```
1、检查一个文档是否存在  
curl -i -XHEAD http://master:9200/test/user/1

2、查看索引文档数量
curl -XGET '101.201.34.96:9200/test/_count?pretty'

3、获取一个文档
curl -XGET 'http://master:9200/test/user/1?pretty'

4、检索文档中的一部分，如果只需要显示指定字段
curl -XGET 'http://master:9200/test/user/1?_source=name&pretty'

5、查询后结果进行排序，q=* ES批量索引中的所有文档
curl -X GET "master:9200/test/user/_search?q=*&sort=account_number:asc&pretty"

6、搜索所有文档
curl -XGET '101.201.34.96:9200/test/_doc/_search?pretty'

7、检索文档中的一部分，如果只需要显示指定字段
curl -XGET 'http://master:9200/test/user/1?_source=name&pretty'

8、查询指定索引库指定类型所有数据
curl -XGET http://master:9200/test/user/_search?pretty

9、查询所有的属性中只要包含2012的所有的数据，泛查询
curl -XGET 'http://master:9200/test/_search?q=2012 

10、查询title中包含2012的所有的数据，df(default field)
curl -XGET 'http://master:9200/test/_search?q=2012&df=title 
curl -XGET 'http://master:9200/test/_search?q=title:2012

11、查询title中包含2012，从第10条开始，查询8条 数据
curl -XGET 'http://master:9200/test/_search?q=title:2012&from=10&size=8

12、查询title中包含Beautiful或者Mind的所有的数据+号可以省略
curl -XGET 'http://master:9200/test/_search?q=title:Beautiful Mind
curl -XGET 'http://master:9200/test/_search?q=title:(Beautiful Mind)
curl -XGET 'http://master:9200/test/_search?q=title:(+Beautiful +Mind)

13、查询title中包含 "Beautiful Mind"这个短语的所 有的数据
curl -XGET 'http://master:9200/test/_search?q=title:"Beautiful Mind" 

14、查询title中既包含Mind又包含Beautiful的所有 的数据，与顺序没有关系
curl -XGET 'http://master:9200/test/_search?q=title:(Mind AND Beautiful) 

15、查询title中包含Beautiful但是不包含mind的所有的数据，两种方法
curl -XGET 'http://master:9200/test/_search?q=title:(Beautiful NOT Mind)
curl -XGET 'http://master:9200/test/_search?q=title:(Beautiful -Mind)

16、查询title中包含Beautiful且时间在2012年之后的所有的数据
curl -XGET 'http://master:9200/test/_search?q=title:Beautiful AND year:>=2012

17、查询2018年之的数据
curl -XGET 'http://master:9200/test/_search?q=year:>=2018

18、查询在2012到2017年的数据
curl -XGET 'http://master:9200/test/_search?q=year:(>=2012 AND <2018)

19、查询2016到2017的数据，必须以 ] 结尾
curl -XGET 'http://master:9200/test/_search?q=year:{2015 TO 2017]

20、通配符？代表一个字母
curl -XGET 'http://master:9200/test/_search?q=title:Min?x'

21、通配符*查询title中包含以 Min开头的字母
curl -XGET 'http://master:9200/test/_search?q=title:Min*'

```

5、DSL 查询 搜索

term、terms表达式
```
Term查询不会对输入进行分词处理，将输入作为一个整体，在倒排索引中查找准确的词项。

1、查询名字中包含有 beautiful 这个单词的所有的数据，用于查询的单词不会进行分词的处理
curl -XGET '101.201.34.96:9200/test/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
  "query": {
    "term": {
      "title": {
        "value": "beautiful"
      }
    }
  }
}'

2、查询电影名字中包含有 beautiful 或者 mind 这两个单词的所有的电影，用于查询的单词不会进行分词的处理
curl -XGET '101.201.34.96:9200/test/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
  "query": {
    "terms": {
      "title": [
        "beautiful",
        "mind"
      ]
    }
  }
}'
```

range 查询在2016到2018年的的数据，再根据时间的倒序进行排序
```
curl -XGET '101.201.34.96:9200/test/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
  "query": {
    "range": {
      "year": {
        "gte": 2016,
        "lte": 2018
      }
   }
},
  "sort": [
    {
      "year": {
        "order": "desc"
      }
    }
  ]
}
```

Constant Score 查询title中包含有beautiful的所有的数据，不进行相关性算分，查询的数据进行缓存，提高效率
```
curl -XGET 'localhost:9200/test/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "title": "beautiful"
        }
      }
    }
  }
}'
```

match
```
1、查询名字中包含有beautiful的所有数据，每页十条，取第二页的数据
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "title": "beautiful"
    }
  },
  "from": 10,
  "size": 10
}'


2、查询名字中包含有 beautiful 或者 mind 的所有的数据，但是只查询title和id两个属性
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "_source": ["title", "id"],
    "query": {
      "match": {
        "title": "beautiful mind"
    }
  }
}'
```

match_phrase 查询名字中包含有 "beautiful mind" 这个短语的所有的数据
```
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase": {
      "title": "beautiful mind"
    }
  }
}'
```

multi_match 查询title或genre中包含有beautiful或者Adventure的所有的数据
```
{
  "query": {
    "multi_match": {
      "query": "beautiful Adventure",
      "fields": ["title", "genre"]
    }
  }
}
```

match_all 
```
1、查看所有文档
curl -X GET "master:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": { 
    "match_all": {}
  }
}'

2、查询所有文档，返回10-19页，
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "from": 10,
  "size": 10
}'
```

query_string 查询title中包含有beautiful和mind的所有的数据
```
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "query_string": {
      "default_field": "title",
      "query": "mind AND beautiful"
    }
  }
}'


curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "query_string": {
      "default_field": "title",
      "query": "mind beautiful",
      "default_operator": "AND"
    }
  }
}'
```

simple_query_string 覆盖了很多其他查询的用法
```
1、查询 title 中包含有 beautiful 和 mind 的所有的电影
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "simple_query_string": {
      "query": "beautiful + mind",
      "fields": ["title"]
    }
  }
}'

curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "simple_query_string": {
      "query": "beautiful mind",
      "fields": ["title"],
      "default_operator": "AND"
    }
  }
}'


2、查询title中包含 "beautiful mind" 这个短语的所有的数 (用法和match_phrase类似)
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "simple_query_string": {
      "query": "\"beautiful mind\"",
      "fields": ["title"]
    }
  }
}'

3、查询title或genre中包含有 beautiful mind romance 这个三个单词的所有的数据 （与multi_match类似）
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "simple_query_string": {
      "query": "beautiful mind Romance",
      "fields": ["title", "genre"]
    }
  }
}'

4、查询title中包含 “beautiful mind” 或者 "Modern Romance" 这两个短语的所有的数据
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "simple_query_string": {
      "query": "\"beautiful mind\" | \"Modern Romance\"",
      "fields": ["title"]
    }
  }
}'

5、查询title或者genre中包含有 beautiful + mind 这个两个词，或者Comedy + Romance + Musical + Drama + Children 这个五个词的所有的数据
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "simple_query_string": {
      "query": "(beautiful + mind) | (Comedy + Romance + Musical + Drama + Children)",
      "fields": ["title","genre"]
    }
  }
}'

6、查询 title 中包含 beautiful 和 people 但是不包含 Animals 的所有的数据
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "simple_query_string": {
      "query": "beautiful + people + -Animals",
      "fields": ["title"]
    }
  }
}'
```

模糊搜索 
```
查询title中从第6个字母开始只要最多纠正一次，就与 neverendign 匹配的所有的数据
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "fuzzy": {
      "title": {
        "value": "neverendign",
        "fuzziness": 1,
        "prefix_length": 5
      }
    }
  }
}'
```

多条件查询
```
1、与的关系，同时匹配
curl -X GET "localhost:9200/test/_search" -H 'Content-Type: application/json' -d'
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

2、或的关系，匹配任意一个
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

3、既不包含A也不包含B
curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
'

4、match不区分大小写且匹配的结果可以不在一起，match_phrase区分大小写且匹配的结果和检索一致
curl -XGET '101.201.34.96:9200/mtestindex3/_doc/_search?pretty' -H 'Content-Type: application/json' -d '
{
    "query": {
        "match_phrase": {
            "address": "北京 昌平"
        }
    }
}
'

```

组合查询
```
1、查询男性，年龄大于30
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

2、查询余额大于或等于20000且小于等于30000的账户
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
}'

3、多条件组合
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


6、高亮显示
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

7、聚合搜索
```
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_search -d '
{
   "aggs": {
      "all_interests": {
         "terns": {
             "field": "age"
          }
       }
    }
 }

# 匹配地址包含mill，且年龄在20~30之间的
curl -H "Content-Type: application/json" -XGET '192.168.149.129:9200/bank/_search?pretty' -d '
{"query":
      {"bool":
          { "must":{"match":{"address":"mill"}},
           "filter":{"range":{"age":{"gte":20,"lte":30}}}
          }
      }, 
 "_source":["address","age"] }'


# 按照state分组，count递减排序
curl -H "Content-Type: application/json" -XGET '192.168.149.129:9200/bank/_search?pretty' -d '
 { "size":0,
   "aggs":
        {"group_by_state":
            {"terms":{"field":"state.keyword"}}
        } 
  }'  #默认递减

# 按state计算平均账户余额
curl -H "Content-Type: application/json" -XGET '192.168.149.129:9200/bank/_search?pretty' -d ' 
{
 "size":0, 
 "aggs":{ 
      "group_by_state": 
             { "terms": {"field":"state.keyword"}, 
               "aggs":{"average_balance":{"avg":{"field":"balance"}}}
             }
        }
}'
```

8、MGET 查询  
使用mget API获取多个文档
```
1、查询不同_index的数据
curl -H "Content-Type: application/json" -XGET http://master:9200/_mget?pretty -d '
{
  "docs":[{"_index":"test","_type":"user","_id":2,"_source":"name"},
  {"_index":"test2","_type":"user","_id":1}]
}'

2、如果需要的文档在同一个_index或者同一个_type中，可以在URL中指定一个默认的/_index或者/_index/_type。
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_mget?pretty -d '
{
  "docs":[{"_id":1},
    {"_id":2}]
}'

3、如果所有的文档拥有相同的_index 以及_type，直接在请求中添加ids的数组即可。
curl -H "Content-Type: application/json" -XGET http://master:9200/test/user/_mget?pretty -d '
{
  "ids":["1","2"]
}'
```

9、ES 更新  
ES可以使用PUT或者POST对文档进行更新(全部更新)，如果指定ID的文档已经存在，则执行更新操作  
```
局部更新，可以添加新字段或者更新已有字段（必须使用POST）
curl -H "Content-Type: application/json" -XPOST http://master:9200/test/user/1/_update -d '
{
  "doc":{
    "name":"baby",
    "age":27
  }
}'
```

10、ES 批量操作-bulk  
bulk API可以帮助我们同时执行多个请求
```
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
1、使用文件的方式新建一个requests文件
vim requests
{"index":{"_index":"test","_type":"user","_id":"6"}}
{"name":"mayun","age":51}
{"update":{"_index":"test","_type":"user","_id":"6"}}
{"doc":{"age":52}}

2、执行批量操作
curl -H "Content-Type: application/json" -XPOST http://master:9200/_bulk --data-binary @requests;
```
bulk一次最大处理多少数据量
- bulk会把将要处理的数据载入内存中，所以数据量是有限制.
- 最佳的数据量取决于硬件，文档大小以及复杂性，索引以及搜索的负载.
- 一般建议是1000-5000个文档，如果文档很大，可以适当减少队列，大小建议是5-15MB，默认不能超过100M，可以在es的配置文件中修改这个值http.max_content_length: 100mb.
- https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-http.html


11、ES 版本控制  
```
1、首先得到需要修改的文档，获取版本(_version)号
curl -XGET http://master:9200/test/user/2

2、在执行更新操作的时候把版本号传过去，如果传递的版本号和待更新的文档的版本号不一致，则会更新失败
curl -H "Content-Type: application/json" -XPUT http://master:9200/test/user/2?version=1 -d '{"name":"john","age":29}'
curl -H "Content-Type: application/json" -XPOST http://master:9200/test/user/2/_update?version=2 -d'{"doc":{"age":30}}'
```

12、Mapping

https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html

```
# 查询索引库的mapping信息：
curl -XGET http://master:9200/test/user/_mapping?pretty

# 操作不存在的索引（创建）：
curl -H "Content-Type: application/json" -XPUT 'http://master:9200/test6' -d '
{
  "mappings":{
    "user":{
      "properties":{
        "name":{
          "type":"text",
          "analyzer": "ik_max_word"
        }
      }
    }
  }
}'

# 操作已存在的索引（修改）：
curl -H "Content-Type: application/json" -XPOST http://master:9200/test6/user/_mapping -d '
{
"properties":{
  "name":{
    "type":"text",
    "analyzer":"ik_max_word"
    }
  }
}'
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
