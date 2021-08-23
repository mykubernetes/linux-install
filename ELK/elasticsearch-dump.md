# 1.elasticsearch备份工具介绍

elasticsearch备份工具由elasticsearch-dump实现

官网：https://github.com/elasticsearch-dump/elasticsearch-dump

# 2.安装elasticsearch-dump
```
1.下载elasticsearch-dump
# git clone https://github.com/taskrabbit/elasticsearch-dump

2.安装elasticsearch-dump
# mv elasticsearch-dump/ /data/
# cd /data/elasticsearch-dump
# npm install elasticdump

3.查看版本
# elasticdump --version
6.62.1
```

# 3.elasticsearch-dump备份

## 3.1.使用elasticsearch-dump备份xinwen索引库

命令语法：elasticdump --input es地址/索引 --output 备份到某个路径
```
# mkdir /data/es-backer

# elasticdump --input http://192.168.81.210:9200/xinwen --output /data/es-backer/xinwen.json
Thu, 14 Jan 2021 02:57:08 GMT | starting dump
Thu, 14 Jan 2021 02:57:09 GMT | got 4 objects from source elasticsearch (offset: 0)
Thu, 14 Jan 2021 02:57:09 GMT | sent 4 objects to destination file, wrote 4
Thu, 14 Jan 2021 02:57:09 GMT | got 0 objects from source elasticsearch (offset: 4)
Thu, 14 Jan 2021 02:57:09 GMT | Total Writes: 4
Thu, 14 Jan 2021 02:57:09 GMT | dump complete

# ls /data/es-backer/xinwen.json
/data/es-backer/xinwen.json

# cat /data/es-backer/xinwen.json
{"_index":"xinwen","_type":"create","_id":"2","_score":1,"_source":{"centent":美国"}}
{"_index":"xinwen","_type":"create","_id":"4","_score":1,"_source":{"centent":中国"}}
{"_index":"xinwen","_type":"create","_id":"1","_score":1,"_source":{"centent":英国"}}
{"_index":"xinwen","_type":"create","_id":"3","_score":1,"_source":{"centent":韩国"}}
```

## 3.2.删除xinwen索引库

```
curl -XDELETE localhost:9200/xinwen
```

## 3.3.使用elasticsearch-dump还原xinwen索引库
命令语法：elasticdump --input 备份文件路径 --output es地址/索引
```
# elasticdump --input /data/es-backer/xinwen.json --output http://192.168.81.210:9200/xinwen
Thu, 14 Jan 2021 03:04:45 GMT | starting dump
Thu, 14 Jan 2021 03:04:45 GMT | got 4 objects from source file (offset: 0)
Thu, 14 Jan 2021 03:04:50 GMT | sent 4 objects to destination elasticsearch, wrote 4
Thu, 14 Jan 2021 03:04:50 GMT | got 0 objects from source file (offset: 4)
Thu, 14 Jan 2021 03:04:50 GMT | Total Writes: 4
Thu, 14 Jan 2021 03:04:50 GMT | dump complete
```

# 4…两个es之间进行数据迁移

elasticdump --input 要迁移es1地址/索引 --output 迁移到es2地址/索引
```
# elasticdump --input http://192.168.81.210:9200/xinwen --output http://192.168.81.220:9200/xinwen
Thu, 14 Jan 2021 03:08:24 GMT | starting dump
Thu, 14 Jan 2021 03:08:24 GMT | got 4 objects from source elasticsearch (offset: 0)
Thu, 14 Jan 2021 03:08:32 GMT | sent 4 objects to destination elasticsearch, wrote 4
Thu, 14 Jan 2021 03:08:32 GMT | got 0 objects from source elasticsearch (offset: 4)
Thu, 14 Jan 2021 03:08:32 GMT | Total Writes: 4
Thu, 14 Jan 2021 03:08:32 GMT | dump complete
```

# 5.安装elasticsearch-dump报错问题排查

## 报错内容如下
```
# npm install elasticdump
npm ERR! code ENOSELF
npm ERR! Refusing to install package with name "elasticdump" under a package
npm ERR! also called "elasticdump". Did you name your project the same
npm ERR! as the dependency you're installing?
npm ERR! 
npm ERR! For more information, see:
npm ERR!     <https://docs.npmjs.com/cli/install#limitations-of-npms-install-algorithm>

npm ERR! A complete log of this run can be found in:
npm ERR!     /root/.npm/_logs/2021-01-13T06_36_56_956Z-debug.log

报错内容翻译如下
错误的ERR！ 代码ENOSELF
错误的ERR！ 拒绝在包下安装名为“webpack”的包
错误的ERR！ 也被称为“webpack”。 你的项目名称是否相同？
错误的ERR！ 作为您正在安装的依赖项？
错误的ERR！
错误的ERR！ 有关更多信息，请参阅：
错误的ERR！<https://docs.npmjs.com/cli/install#limitations-of-npms-install-algorithm>

错误的ERR！ 可以在以下位置找到此运行的完整日志：
```

##错误解决

根据翻译的内容提示说我们包安装名相同，elasticsearch-dump目录下有个package.json的文件，打开文件，将里面的name字段值换成和npm安装插件的名称不一致就行
```
# vim package.json 
{
  "author": "Evan Tahler <evantahler@gmail.com>",
  "name": "elasticdump1",				#随便改就行
	······
	
再次致谢npm install
# npm install elasticdump
npm WARN deprecated request@2.88.2: request has been deprecated, see https://github.com/request/request/issues/3142
npm WARN deprecated har-validator@5.1.5: this library is no longer supported
npm WARN deprecated s3signed@0.1.0: This module is no longer maintained. It is provided as is.
npm notice created a lockfile as package-lock.json. You should commit this file.
+ elasticdump@6.62.1
added 114 packages from 201 contributors in 37.994s
```
