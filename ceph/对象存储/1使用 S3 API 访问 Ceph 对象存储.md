使用 S3 API 访问 Ceph 对象存储
============================

1、创建 radosgw 用户  
```
$ radosgw-admin user create --uid=radosgw --display-name="radosgw" -k /var/lib/ceph/radosgw/ceph-rgw.node01/keyring --name client.rgw.c720176
...
"keys": [
{
"user": "radosgw",
"access_key": "N5UJH6WDNT2FH5WUMHIC",
"secret_key": "ja0kAxtM0kSvhl2qY4Ruww4omZPvd72ulktguOYU"
}
],
"swift_keys": [],
"caps": [],
"op_mask": "read, write, delete",
...
```  
注意：把access_key和secret_key保存下来 ，如果忘记可使用：radosgw-admin user info --uid … -k … --name …  

2、安装 s3cmd 客户端  
``` # yum install s3cmd -y ```  

3、生成配置文件  
```
# s3cmd --configure
Enter new values or accept defaults in brackets with Enter.
...
Access Key: N5UJH6WDNT2FH5WUMHIC
Secret Key: ja0kAxtM0kSvhl2qY4Ruww4omZPvd72ulktguOYU
Default Region [US]:
Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target A
mazon S3.
S3 Endpoint [s3.amazonaws.com]:
Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]:
Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program [/usr/bin/gpg]:
When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: no
On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't connect to S3 directly
HTTP Proxy server name:
New settings:
Access Key: N5UJH6WDNT2FH5WUMHIC                           #输入ak
Secret Key: ja0kAxtM0kSvhl2qY4Ruww4omZPvd72ulktguOYU       #输入sk
Default Region: US
S3 Endpoint: s3.amazonaws.com
DNS-style bucket+hostname:port template for accessing a bucket: %(bucket)s.s3.amazonaws.com
Encryption password:
Path to GPG program: /usr/bin/gpg
Use HTTPS protocol: False                                 #根据提示输入False或者no
HTTP Proxy server name:
HTTP Proxy server port: 0
Test access with supplied credentials? [Y/n] n            #输入n
Save settings? [y/N] y                                    #输入y
Configuration saved to '/root/.s3cfg'
```  

4、编辑 .s3cfg 文件，修改 host_base 和 host_bucket  
```
vi .s3cfg
……
host_base = node01:7480                   #对象网关地址
host_bucket = %(bucket).node01:7480       #bucket地址
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
