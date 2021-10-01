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

# 管理对象存储

1. List objects or buckets
```
# s3cmd ls
2018-05-09 07:30  s3://123
2018-05-09 07:30  s3://BUCKET
2018-05-09 07:30  s3://ddd

# s3cmd ls s3://BUCKET
2018-05-09 07:4769   s3://BUCKET/a.txt
2018-05-09 07:4869   s3://BUCKET/ccc

# s3cmd ls s3://bucket
ERROR: Bucket 'bucket' does not exist
ERROR: S3 error: 404 (NoSuchBucket)
```

2. Make bucket
```
# s3cmd mb s3://BUCKET
Bucket 's3://BUCKET/' created

# s3cmd mb s3://ddd
Bucket 's3://ddd/' created

# s3cmd mb s3://123
Bucket 's3://123/' created
```

3. Delete bucket
```
# s3cmd rb s3://bucketceq
Bucket 's3://bucketceq/' removed
```

4. List all object in all buckets
```
# s3cmd la
2018-05-09 07:48        69   s3://BUCKET/ccc
2018-05-09 07:42         0   s3://ddd/b.txt
```

5. Put file into bucket
```
# s3cmd put ccc s3://BUCKET
upload: 'ccc' -> 's3://BUCKET/ccc'  [1 of 1]
 69 of 69   100% in    0s     4.04 kB/s  done
```

6. Get file from bucket
```
# s3cmd get s3://BUCKET/a.txt aa.txt
download: 's3://BUCKET/a.txt' -> 'aa.txt'  [1 of 1]
 69 of 69   100% in    0s     5.46 kB/s  done

# ll aa.txt
-rw-r--r-- 1 root root 69 May  9 07:47 aa.txt
```

7. Delete file from bucket
```
# s3cmd del s3://BUCKET/a.txt
delete: 's3://BUCKET/a.txt'

# s3cmd ls s3://BUCKET
2018-05-09 07:48        69   s3://BUCKET/ccc
```

8. Synchronize a directory tree to/from S3
```
# s3cmd sync LOCAL_DIR s3://BUCKET/
upload: 'LOCAL_DIR/ccc' -> 's3://BUCKET/LOCAL_DIR/ccc'  [1 of 1]
 27 of 27   100% in    0s   532.19 B/s  done
Done. Uploaded 27 bytes in 1.0 seconds, 27.00 B/s.
```

9. Disk usage by buckets
```
# s3cmd du
0        0 objects s3://123/
142      4 objects s3://BUCKET/
0        1 objects s3://ddd/
--------
142      Total

# s3cmd du s3://BUCKET/ccc
69       1 objects s3://BUCKET/ccc
```

10. Get various information about Buckets or Files

10.2.10 版本对 bucket 执行 info 的时候返回 python 错误
```
# s3cmd info s3://BUCKET/ccc
s3://BUCKET/ccc (object):
   File size: 69
   Last mod:  Wed, 09 May 2018 07:48:06 GMT
   MIME type: text/plain
   Storage:   STANDARD
   MD5 sum:   bc1ed6398b9e9e67b8ffea7807ef5598
   SSE:       none
   Policy:    none
   CORS:      none
   ACL:       test chenerqi: FULL_CONTROL
   x-amz-meta-s3cmd-attrs: atime:1525852073/ctime:1525852073/gid:0/gname:root/md5:bc1ed6398b9e9e67b8ffea7807ef5598/mode:33188/mtime:1525852073/uid:0/uname:root
```

11. Copy object
```
# s3cmd cp s3://BUCKET/ccc s3://BUCKET/cpd
remote copy: 's3://BUCKET/ccc' -> 's3://BUCKET/cpd'
```


12. Modify object metadata
```
# s3cmd modify s3://BUCKET/cpd  --acl-public
modify: 's3://BUCKET/cpd'
```

13. Move object
```
# s3cmd ls s3://BUCKET
                       DIR   s3://BUCKET/LOCAL_DIR/
2018-05-09 07:48        69   s3://BUCKET/ccc

# s3cmd mv s3://BUCKET/ccc s3://BUCKET/aaa
move: 's3://BUCKET/ccc' -> 's3://BUCKET/aaa'

# s3cmd ls s3://BUCKET
                       DIR   s3://BUCKET/LOCAL_DIR/
2018-05-09 09:01        69   s3://BUCKET/aaa
```


14. Modify access control list for bucket or files
```
# s3cmd ls s3://BUCKET/
ERROR: Access to bucket 'BUCKET' was denied
ERROR: S3 error: 403 (AccessDenied)

# s3cmd setacl s3://BUCKET --acl-public
s3://BUCKET/: ACL set to Public

# s3cmd info s3://BUCKET
s3://BUCKET/ (bucket):
   Location:  us-east-1
   Payer:     BucketOwner
   Expiration Rule: none
   Policy:    none
   CORS:      none
   ACL:       anon: READ
   ACL:       test chenerqi: FULL_CONTROL
   URL:       http://10.168.89.187:8060/BUCKET/

# s3cmd ls s3://BUCKET/
2018-05-09 09:21        69   s3://BUCKET/a.txt
2018-05-09 09:21        69   s3://BUCKET/aa.txt
2018-05-09 09:21         7   s3://BUCKET/ccc

s3cmd setacl s3://BUCKET --acl-grant=read:test-c111
s3cmd setacl s3://BUCKET --acl-grant=write:test-c111
s3cmd setacl s3://BUCKET --acl-grant=full_control:test-c111
s3cmd setacl s3://BUCKET --acl-revoke=full_control:test-c111
```

15.
```
Modify Bucket Policy
Delete Bucket Policy
Modify Bucket CORS
Delete Bucket CORS
```



16. Set Bucket Quota:
```
s3cmd没有相关命令，radosgw-adm命令：
radosgw-admin quota set --bucket BUCKET --max-objects 1500
radosgw-admin quota set --bucket BUCKET --max-size 1G
radosgw-admin bucket stats --bucket BUCKET
radosgw-admin quota set --quota-scope=user --uid=johndoe --max-objects=1024 --max-size=1024B
radosgw-admin quota enable --quota-scope=user --uid=<uid>
radosgw-admin quota disable --quota-scope=user --uid=<uid>

max-objects和max-size设置为-1（或者任意其他负数）表示无限量
```


17. Set Life Cycle（10.2.10 测试不支持）
```
s3cmd setlifecycle lf.xml s3://BUCKET
lf.xml
<LifecycleConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Rule>
    <ID>111</ID>
    <Prefix/>
    <Status>enable</Status>
    <Expiration>
      <Days>1</Days>
      <StartAt>0 1 * * *</StartAt>
      <StopAt>0 7 * * *</StopAt>
    </Expiration>
  </Rule>
</LifecycleConfiguration>

radosgw-admin lc get --bucket=BUCKET
{
    "LifecycleConfiguration http://s3.amazonaws.com/doc/2006-03-01/": {
        "Rule": {
            "ID": "111",
            "Prefix": "",
            "Status": "enable",
            "Expiration": {
                "Days": "1",
                "StartAt": "0 1 * * *",
                "StopAt": "0 7 * * *"
            }
        }
    }
}

10.2.10:
# s3cmd setlifecycle lf.xml s3://ddd
ERROR: S3 error: 403 (SignatureDoesNotMatch)
```

18. Del Life Cycle（10.2.10 测试不支持）
```
# s3cmd dellifecycle s3://BUCKET
s3://BUCKET/: Lifecycle Policy deleted
```

19. Write Protect(10.2.10 不支持)
```
# s3cmd ls s3://BUCKET
2018-05-10 12:56         0   s3://BUCKET/5

# s3cmd del s3://BUCKET/5
ERROR: S3 error: 403 (AccessDenied)

# s3cmd del s3://BUCKET/5
delete: 's3://BUCKET/5'
```






GUI图形客户端使用  
支持S3的GUI客户端比较丰富，配置也比较简单  
cyberduck:开源,支持windows、Mac,下载地址 https://cyberduck.io/  

dragondisk:支持windows、Mac,下载地址 http://www.dragondisk.com/  

Explorer for Amazon S3:分收费和免费版，只支持windows  
下载地址： http://www.cloudberrylab.com/free-amazon-s3-explorer-cloudfront-IAM.aspx  
