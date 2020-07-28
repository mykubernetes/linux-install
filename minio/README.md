官方网址：https://docs.minio.io/cn/

github网址： https://github.com/minio/minio/blob/master/docs/zh_CN/distributed/README.md

中文文档： https://www.bookstack.cn/read/MinioCookbookZH/17.md

kubernetes部署
```
kubectl apply -f https://raw.githubusercontent.com/minio/minio-operator/master/minio-operator.yaml
```

单机运行
===
```
#下载二进制文件
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio

#创建数据目录
mkdir /data

#启动minio
./minio server /data
Endpoint:  http://192.168.101.70:9000  http://127.0.0.1:9000    #登录地址
AccessKey: minioadmin                                           #需要记住，登录的key
SecretKey: minioadmin                                           #需要记住，加密的key

Browser Access:
   http://192.168.101.70:9000  http://127.0.0.1:9000    

Command-line Access: https://docs.min.io/docs/minio-client-quickstart-guide
   $ mc config host add myminio http://192.168.101.70:9000 minioadmin minioadmin

Object API (Amazon S3 compatible):
   Go:         https://docs.min.io/docs/golang-client-quickstart-guide
   Java:       https://docs.min.io/docs/java-client-quickstart-guide
   Python:     https://docs.min.io/docs/python-client-quickstart-guide
   JavaScript: https://docs.min.io/docs/javascript-client-quickstart-guide
   .NET:       https://docs.min.io/docs/dotnet-client-quickstart-guide
Detected default credentials 'minioadmin:minioadmin', please change the credentials immediately using 'MINIO_ACCESS_KEY' and 'MINIO_SECRET_KEY'

#二进制安装配置文件存放位置
/data/.minio.sys/config

#打开防火墙
firewall-cmd --permanent --zone=public --add-port=9000/tcp
firewall-cmd --reload
```




分布式运行命令
===
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

minio做成服务
---
1、编写集群启动脚本（所有节点配置文件相同）
```
vim /opt/minio/run.sh
#!/bin/bash
export MINIO_ACCESS_KEY=Minio
export MINIO_SECRET_KEY=Test123456

/opt/minio/minio server --config-dir /etc/minio \
http://192.168.0.101/minio/data1 http://192.168.0.101/minio/data2 \
http://192.168.0.102/minio/data1 http://192.168.0.102/minio/data2 \
```

2、编写服务脚本（所有节点）
```
vim /usr/lib/systemd/system/minio.service
[Unit]
Description=Minio service
Documentation=https://docs.minio.io/

[Service]
WorkingDirectory=/opt/minio/
ExecStart=/opt/minio/run.sh

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

3、启动测试
```
chmod +x minio
mv minio /opt/minio/
chmod +x /opt/minio/run.sh

systemctl daemon-reload
systemctl start minio
systemctl enable minio
```
