使用 S3 API 访问 Ceph 对象存储
============================

1、创建 radosgw 用户  
``` # radosgw-admin user create --uid=radosgw --display-name="radosgw" ```  
注意：请把 access_key 和 secret_key 保存下来 ，如果忘记可使用：radosgw-admin user info --uid … -k … --name …  
2、安装 s3cmd 客户端  
``` # yum install s3cmd -y ```  
3、将会在家目录下创建 .s3cfg 文件 , location 必须使用 US , 不使用 https  
``` # s3cmd --configure ```  
4、编辑 .s3cfg 文件，修改 host_base 和 host_bucket  
```
vi .s3cfg
……
host_base = node01:7480
host_bucket = %(bucket).node01:7480
……
```  
5、创建删除测试  

新建Bucket  
```
s3cmd mb s3://s3test1
```  

查看现有Bucket  
```
s3cmd ls
```  

删除Bucket  
```
s3cmd rb s3://s3test1
```  

上传Object  
```
s3cmd put default.conf s3://s3test1
```  

查看Object  
```
s3cmd ls s3://s3test1
```  

下载Object  
```
s3cmd get s3://s3test1/default.conf
```  




GUI图形客户端使用  
支持S3的GUI客户端比较丰富，配置也比较简单  
cyberduck:开源,支持windows、Mac,下载地址 https://cyberduck.io/  

dragondisk:支持windows、Mac,下载地址 http://www.dragondisk.com/  

Explorer for Amazon S3:分收费和免费版，只支持windows  
下载地址： http://www.cloudberrylab.com/free-amazon-s3-explorer-cloudfront-IAM.aspx  
