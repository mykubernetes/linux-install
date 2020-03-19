官方网址：https://docs.minio.io/cn/

github网址： https://github.com/minio/minio/blob/master/docs/zh_CN/distributed/README.md


分布式运行命令
---
```
export MINIO_ACCESS_KEY=<ACCESS_KEY>
export MINIO_SECRET_KEY=<SECRET_KEY>
minio server http://192.168.1.11/export1 http://192.168.1.12/export2 \
               http://192.168.1.13/export3 http://192.168.1.14/export4 \
               http://192.168.1.15/export5 http://192.168.1.16/export6 \
               http://192.168.1.17/export7 http://192.168.1.18/export8
```

![分布式Minio,8节点，每个节点一块盘](https://github.com/minio/minio/blob/master/docs/screenshots/Architecture-diagram_distributed_8.jpg?raw=true)

```
export MINIO_ACCESS_KEY=<ACCESS_KEY>
export MINIO_SECRET_KEY=<SECRET_KEY>
minio server http://192.168.1.11/export1 http://192.168.1.11/export2 \
               http://192.168.1.11/export3 http://192.168.1.11/export4 \
               http://192.168.1.12/export1 http://192.168.1.12/export2 \
               http://192.168.1.12/export3 http://192.168.1.12/export4 \
               http://192.168.1.13/export1 http://192.168.1.13/export2 \
               http://192.168.1.13/export3 http://192.168.1.13/export4 \
               http://192.168.1.14/export1 http://192.168.1.14/export2 \
               http://192.168.1.14/export3 http://192.168.1.14/export4
```

![分布式Minio,4节点，每节点4块盘](https://github.com/minio/minio/blob/master/docs/screenshots/Architecture-diagram_distributed_16.jpg?raw=true)

扩展现有的分布式集群
```
export MINIO_ACCESS_KEY=<ACCESS_KEY>
export MINIO_SECRET_KEY=<SECRET_KEY>
minio server http://host{1...32}/export{1...32} http://host{33...64}/export{1...32}
```

mc命令介绍
---
```
ls       列出文件和文件夹。
mb       创建一个存储桶或一个文件夹。
cat      显示文件和对象内容。
pipe     将一个STDIN重定向到一个对象或者文件或者STDOUT。
share    生成用于共享的URL。
cp       拷贝文件和对象。
mirror   给存储桶和文件夹做镜像。
find     基于参数查找文件。
diff     对两个文件夹或者存储桶比较差异。
rm       删除文件和对象。
events   管理对象通知。
watch    监听文件和对象的事件。
policy   管理访问策略。
session  为cp命令管理保存的会话。
config   管理mc配置文件。
update   检查软件更新。
version  输出版本信息。
```
