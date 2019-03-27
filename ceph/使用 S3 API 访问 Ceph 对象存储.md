使用 S3 API 访问 Ceph 对象存储
============================

1、创建 radosgw 用户  
``` # radosgw-admin user create --uid=radosgw --display-name="radosgw" ```  
注意：请把 access_key 和 secret_key 保存下来 ，如果忘记可使用：radosgw-admin user info --uid … -k … --name …
2、安装 s3cmd 客户端  
``` # yum install s3cmd -y  
3、将会在家目录下创建 .s3cfg 文件 , location 必须使用 US , 不使用 https  
``` # s3cmd --configure ```  
4、编辑 .s3cfg 文件，修改 host_base 和 host_bucket  
```
vi .s3cfg
……
host_base = c720183.xiodi.cn:7480
host_bucket = %(bucket).c720183.xiodi.cn:7480
……
```  
5、创建桶并放入文件  
```
s3cmd mb s3://first-bucket
s3cmd ls
s3cmd put /etc/hosts s3://first-bucket
s3cmd ls s3://first-bucket
```  
