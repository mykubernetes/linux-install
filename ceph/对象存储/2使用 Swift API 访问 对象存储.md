# 一、 Swift简介
openstack swift是openstack开源云计算项目开源的对象存储，提供了强大的扩展性、冗余和持久性

## 1.1 swift特性
极高的数据持久性

完全对称的系统架构

无限的可扩展性

无单点故障

## 1.2 对象存储在容器中
Openstack Swift API的用户模型与Amazon S3 API稍有不同。若要使用swift api通过rados网关的身份验证，需要rados网关用户帐户配置子用户

Amazon S3 API授权和身份验证模型具有单层设计。一个用户可以有多个access key和secret key，用于在同一帐户中提供不同类型的访问

而swift有租户概念，rados网关用户对应swift的租户，而子帐号则对应swift的api用户

RADOS网关支持Swift v1.0以及OpenStack keystone v2.0身份验证

# 二、swift 用户管理

## 2.1 创建Swift的子用户
```
#  radosgw-admin user info --uid joy
{
    "user_id": "joy",
    "display_name": "Joy Ning",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": 1024,
        "max_size_kb": 1,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": true,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}
```

## 2.2 创建一个子账号
```
# radosgw-admin subuser create --uid joy --subuser joy:swift --access=full
{
    "user_id": "joy",
    "display_name": "Joy Ning",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [
        {
            "id": "joy:swift",
            "permissions": "full-control"
        }
    ],
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        }
    ],
    "swift_keys": [
        {
            "user": "joy:swift",
            "secret_key": "6Ea8Cu94ea37ESj7mJWFV1TmoL9ffMjVHJ5D0vKK"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": 1024,
        "max_size_kb": 1,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": true,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
} 
```

## 创建另一个子账号
```
# radosgw-admin subuser create --uid joy --subuser joy:swift2 --access=full
{
    "user_id": "joy",
    "display_name": "Joy Ning",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [
        {
            "id": "joy:swift",
            "permissions": "full-control"
        },
        {
            "id": "joy:swift2",
            "permissions": "full-control"
        }
    ],
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        }
    ],
    "swift_keys": [
        {
            "user": "joy:swift",
            "secret_key": "6Ea8Cu94ea37ESj7mJWFV1TmoL9ffMjVHJ5D0vKK"
        },
        {
            "user": "joy:swift2",
            "secret_key": "kJl6k4dVfqbOlZxdIX1Apmu5VFkL0KmSb5B8MkXz"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": 1024,
        "max_size_kb": 1,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": true,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}
```

## 2.3 删除一个子账号
```
# radosgw-admin subuser rm  --uid joy --subuser joy:swift2
{
    "user_id": "joy",
    "display_name": "Joy Ning",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [
        {
            "id": "joy:swift",
            "permissions": "full-control"
        }
    ],
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        }
    ],
    "swift_keys": [
        {
            "user": "joy:swift",
            "secret_key": "6Ea8Cu94ea37ESj7mJWFV1TmoL9ffMjVHJ5D0vKK"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": 1024,
        "max_size_kb": 1,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": true,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
} 
```

## 2.4 修改子用户秘钥
```
#  radosgw-admin key create --subuser joy:swift --gen-secret
{
    "user_id": "joy",
    "display_name": "Joy Ning",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [
        {
            "id": "joy:swift",
            "permissions": "full-control"
        }
    ],
    "keys": [
        {
            "user": "joy",
            "access_key": "5XCV68WUQJFFJPVM3UHK",
            "secret_key": "xhaA2YB1CA3xH54xLbmwPcglqjDyuFez36F8XGuG"
        }
    ],
    "swift_keys": [
        {
            "user": "joy:swift",
            "secret_key": "RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": 1024,
        "max_size_kb": 1,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": true,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}
```

# 三、使用swift客户端

## 3.1、安装软件  
```
# yum install -y python-pip
# pip install --upgrade python-swiftclient
或者
#  yum -y install python-swiftclient 
```

## 3.2 创建一个容器
```
# swift -A http://ceph5.lab.example.com/auth/v1.0 -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq post swiftbk
```

## 3.3 向容器上传一个文件
```
# swift -A http://ceph5.lab.example.com/auth/v1.0 -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq upload swiftbk /etc/ceph/ceph.conf
```

## 3.4 服务器端查看
```
#  rados -p  default.rgw.buckets.data ls  --cluster backup
```

## 3.5 列出容器中的文件
```
# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq list  swiftbk 
```

## 3.6 从容器中下载文件
```
# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq download swiftbk ceph.conf
```

## 3.7 查看容器状态
```
# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq stat swiftbk 
Account: v1
                    Container: swiftbk
                      Objects: 1
                        Bytes: 589
                     Read ACL:
                    Write ACL:
                      Sync To:
                     Sync Key:
                Accept-Ranges: bytes
             X-Storage-Policy: default-placement
X-Container-Bytes-Used-Actual: 4096
                  X-Timestamp: 1553059437.79870
                   X-Trans-Id: tx000000000000000000017-005c91cf25-1095-default
                 Content-Type: text/plain; charset=utf-8
       X-Openstack-Request-Id: tx000000000000000000017-005c91cf25-1095-default

 


# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq stat
Account: v1
                                 Containers: 2
                                    Objects: 3
                                      Bytes: 1184
Objects in policy "default-placement-bytes": 0
  Bytes in policy "default-placement-bytes": 0
   Containers in policy "default-placement": 2
      Objects in policy "default-placement": 3
        Bytes in policy "default-placement": 1184
                              Accept-Ranges: bytes
                                X-Timestamp: 1553059632.46208
                X-Account-Bytes-Used-Actual: 12288
                                 X-Trans-Id: tx000000000000000000019-005c91cf30-1095-default
                               Content-Type: text/plain; charset=utf-8
                     X-Openstack-Request-Id: tx000000000000000000019-005c91cf30-1095-default
```

## 重复操作
```
# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq upload test /etc/ceph/rbdmap 
etc/ceph/rbdmap

# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq list
swiftbk
test

# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq list test
ceph
demoobject
etc/ceph/rbdmap

# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq post swifttest

# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq post  list

# swift -A http://ceph5.lab.example.com/auth/v1.0  -U joy:swift -K RB5SfO54XqgPl7TkfEjobfz9GP63dLIG1tZ9MQiq list
list
swiftbk
swifttest
test
```
