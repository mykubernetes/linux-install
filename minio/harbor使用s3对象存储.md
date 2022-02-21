默认情况下，harbor使用本地存储进行注册，但您可以可选地配置设置，以便harbor使用外部存储。有关如何为不同的存储提供商配置注册表的存储后端的信息，请参阅 Docker 文档中的配置参考https://docs.docker.com/registry/configuration/#storage。

**我这里使用s3对象存储作为harbor镜像仓库存放镜像的位置。使用的s3对象存储为minio，当然也可以使用其他s3对象存储。**

docker官方的配置示例如下
```
s3:
    accesskey: awsaccesskey   #s3对象存储认证信息
    secretkey: awssecretkey   
    region: us-west-1    #区域，正常自己搭建的对象存储服务默认为us-west-1，但是如果使用第三方厂商的s3对象存储需要根据实际情况配置
    regionendpoint: http://myobjects.local #对象存储访问url
    bucket: bucketname  #存储桶名称
    encrypt: true  #您是否希望在服务器端加密您的数据 (如果未指定，则默认为 false).
    keyid: mykeyid #您是否希望使用此 KMS 密钥 ID 加密您的数据，如果encrypt不为真，则忽略。
    secure: true #您是否希望通过ssl将数据传输到存储桶。
    v4auth: true #您是否希望在请求中使用 aws 签名版本4
    chunksize: 5242880  #分段上传（由 WriteStream 执行）到 S3 的默认分段大小。
    multipartcopychunksize: 33554432
    multipartcopymaxconcurrency: 100
    multipartcopythresholdsize: 33554432 #这个值需要调大，最大5G
    rootdirectory: /s3/object/name/prefix #这是一个应用于所有 S3 键的前缀，允许您在必要时对存储桶中的数据进行分段。
```

**实现过程**

harbor.yml配置文件
```
#添加配置
storage_service:
  s3:
    accesskey: minio
    secretkey: minio123
    region: us-west-1
    regionendpoint: http://192.168.10.71:9000
    bucket: harbor
    multipartcopythresholdsize: "5368709120"
```

重新启动harbor服务，上传镜像验证minio中是否有数据
```
[16:54:06 root@centos7 ~]#docker push harbor.zhangzhuo.org/bash/mysql:latest
[16:54:31 root@centos7 ~]#mc ls minio/harbor/
[2021-09-16 16:54:35 CST]     0B docker/
```

在minio的web控制台验证
