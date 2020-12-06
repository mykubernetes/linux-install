停用词
---
有些词在文本中出现的频率非常高，但是对文本所携带的信息基本不产生影响，这样的词我们称之为停用词。
```
中文停用词
https://www.ranks.nl/stopwords/chinese-stopwords

英文停用词
https://www.ranks.nl/stopwords
```

中文分词器
---
```
单字分词：
分词前："我们是中国人"
效果："我" "们" "是" "中" "国" "人"

二分法分词：
比如："我们是中国人"
效果："我们" "们是" "是中" "中国" "国人"

词库分词：
按某种算法构造词，然后去匹配已建好的词库集合，如果匹配到就切分出来成为词语。通常词库分词被认为是最理想的中文分词算法。
```

常见的中文分词器
---
StandardAnalyzer(单字分词)
- 能够根据空格、符号、数字、字母、E-mail地址、IP地址以及中文字符的分析处理分割原始的文本信息。但中文文字没有完成中文分词的功能，只是按照单个的汉字进行了分割。

CJKAnalyzer(二分法)
- 专门用于中文文档处理的分析器，可以实现中文的多元切分和停用词过滤。

IKAnalyzer(词库分词)
- 当前比较流行中文分词器，对中文支持较好。属于第三方插件，需要安装。

测试默认的分词对中文的支持
```
curl -H "Content-Type: application/json" -XGET 'http://master:9200/_analyze?pretty=true' -d '{"text":"我们是中国人"}'
```

集成 IK 中文分词插件
---

安装IK插件
```
下载ES的IK插件
https://github.com/medcl/elasticsearch-analysis-ik

vim pom.xml
    <properties>
        <elasticsearch.version>7.4.0</elasticsearch.version>           #如果插件版本pom文件和下载的版本不一致需要修改，一致可忽略
        <maven.compiler.target>1.8</maven.compiler.target>
        <elasticsearch.assembly.descriptor>${project.basedir}/src/main/assemblies/plugin.xml</elasticsearch.assembly.descriptor>
        <elasticsearch.plugin.name>analysis-ik</elasticsearch.plugin.name>
        <elasticsearch.plugin.classname>org.elasticsearch.plugin.analysis.ik.AnalysisIkPlugin</elasticsearch.plugin.classname>
        <elasticsearch.plugin.jvm>true</elasticsearch.plugin.jvm>
        <tests.rest.load_packaged>false</tests.rest.load_packaged>
        <skip.unit.tests>true</skip.unit.tests>
        <gpg.keyname>4E899B30</gpg.keyname>
        <gpg.useagent>true</gpg.useagent>
    </properties>



使用maven对下载的插件进行源码编译（提前安装maven）
mvn clean package -DskipTests

拷贝和解压release下的文件: 
mkdir ES_HOME/plugins/ik
cp target/releases/elasticsearch-analysis-ik-*.zip 到 elasticsearch 插件目录：ES_HOME/plugins/ik
unzip elasticsearch-analysis-ik-*.zip

重启ElasticSearch服务
bin/elasticsearch
```

测试分词效果：
```
curl -H 'Content-Type:application/json' -XGET http://master:9200/_analyze?pretty -d '{"analyzer": "ik_max_word","text": "我们是中国人"}'
curl -H 'Content-Type:application/json' -XGET http://master:9200/_analyze?pretty -d '{"analyzer": "ik_smart", "text":"我们是中国人"}'
```

自定义IK 词库
---

创建自定义词库
```
测试新词：
curl -H 'Content-Type:application/json' -XGET http://master:9200/_analyze?pretty -d '{"analyzer": "ik_max_word","text": "蓝瘦香菇"}'

首先在ik插件的config/custom目录下创建一个文件test.dic，在文件中添加词语即可，每一个词语一行。

修改ik的配置文件IKAnalyzer.cfg.xml将test.dic添加到ik的配置文件中即可
vi config/IKAnalyzer.cfg.xml
<entry key="ext_dict">custom/test.dic</entry>

重启ElasticSearch服务
bin/elasticsearch
```

测试分词效果：
```
curl -H 'Content-Type:application/json' -XGET http://master:9200/_analyze?pretty -d '{"analyzer": "ik_max_word","text": "蓝瘦香菇"}'
```

热更新IK 词库
---
部署http服务，安装tomcat
```
新建热词文件
cd /home/hadoop/app/apache-tomcat-7.0.67/webapps/ROOT
vi hot.dic
么么哒

需正常访问
bin/startup.sh
http://192.168.20.210:8080/hot.dic
```

修改ik插件的配置文件
```
vi config/IKAnalyzer.cfg.xml
添加如下内容
<entry key="remote_ext_dict">http://192.168.20.210:8080/hot.dic</entry>
分发修改后的配置到其他es节点
```

重启es，可以看到加载热词库
bin/elasticsearch

p 测试动态添加热词
对比添加热词之前和之后的变化
```
curl -H 'Content-Type:application/json' -XGET http://master:9200/_analyze?pretty -d '{"analyzer": "ik_max_word", "text": "老司机"}'
```






