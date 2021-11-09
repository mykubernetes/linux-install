1、编写policy.json文件
```
[root@node1 ~]# vim policy.xml
{
  "Version": "2012-10-17",
  "Statement":[
      {"Sid":"0",
       "Effect":"Allow",
       "Principal":"*",
       "Action":"s3:*",
       "Resource":"arn:aws:s3:::test/*",
       "Condition":{
           "StringLike":
           {"aws:Referer":["http://10.168.106.22*"]}
        }
      }
  ]
}
```

2、 使用s3cmd 命令设置存储桶的policy。
```
[root@compute0 ~]# s3cmd setpolicy policy.xml s3://test/
```

3、使用s3cmd 命令设置存储桶的policy
```
[root@compute0 ~]# s3cmd  info  s3://test/
s3://test-yl/ (bucket):
   Location:  cn
   Payer:     BucketOwner
   Expiration Rule: none
   Policy:    {
  "Version": "2012-10-17",
  "Statement":[
      {"Sid":"2",
       "Effect":"Allow",
       "Principal":"*",
       "Action":"s3:*",
       "Resource":"arn:aws:s3:::test/*",
       "Condition":{
           "StringLike":
           {"aws:Referer":["http://10.168.106.22*"]}
        }
      }
  ]
}

   CORS:      none
   ACL:       admin: FULL_CONTROL
```

注意事项

1、 存储桶的acl规则，应该是private，默认bucket规则是私有的，如果不是需要手动设置，设置方式：
```
s3cmd setacl s3://test/  --acl-private
```

参数解释
```
1、Version
有两个值可选：默认是 2008-10-17；对于本环境使用的ceph对象存储，只能使用另外的一个值 2012-10-17。

2、 Statement
是policy 的主体，该参数为必需参数。里面放的是列表。

"Statement": [{...},{...},{...}]
3、Sid
是一个可选的标识，当由多条statement 的时候，我们需要为每个statement 分配 一个Sid作为标识

4、Effect
是必需元素，它来指定这条statement 的作用是允许还是拒绝，它只有两个值（ Allow 和 Deny ）

5、Principal
使用Principal策略中的元素来指定允许或拒绝访问资源的用户。

6、Action
用来描述指定动作（例如：s3:GetObject）

对于ceph使用的是S3协议，所以该值的写法如下：
"Action": "s3:*"
"Action": "s3:GetObject"
7、Resource
指定特定的资源集合

写法格式：
arn:partition:service:region:account-id:resource-id
arn:partition:service:region:account-id:resource-type/resource-id
arn:partition:service:region:account-id:resource-type:resource-id
partition ：对于标准的aws 这个值为aws

service ：这个值标识是aws什么产品可以是S3, IAM,RDS

region ：资源所在的区域。某些资源的ARN不需要区域，因此可以省略

account-id ：拥有资源的AWS账户的ID，不带连字符。例如123456789012。某些资源的ARN不需要帐号，因此可以省略此组件。

resource：资源标识符，可以这样定义（ 子资源类型/父资源/子资源 ）
resource-type：资源路径 resource-id：资源名称

s3 对象存储写法示意图：
arn:aws:s3:::my_corporate_bucket/*
```
