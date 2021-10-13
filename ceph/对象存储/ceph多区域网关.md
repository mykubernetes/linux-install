# 一、基本概念

## 1.1 多区域概念

Multi-Size功能是从J版本开始的。一个single zone配置通常由一个zone group组成，该zone group包含一个zone和多个用于负载均衡的RGW实例。从K版本开始，ceph为RGW提供了Multi-Size的配置选项

## 1.2 多区域相关术语

区域（zone）: 一个ceph集群可以包含多个区域，一个区域只属于一个集群，一个区域可以有多个RGW

区域组（zonegroup）：由一个或多个区域组成，包含一个主区域（master zone），其他区域称为Secondary Zone，区域组内的所有区域之间同步数据

域（realm）: 同一个或多个区域组组成，包含一个主区域组，其他都次区域组。域中的所有rados网关都从位于主区域组和主区域中的rados网关拉取配置

注意： master zone group中的master zone处理所元数据更新，因此创建用户、bucket等操作都必须经由master zone

## 1.3 多区域网关配置架构

single-zone：一个realm中只有一个zonegroup和一个zone，可以有多个RGW

multi-zone：一个relam中只有一个zonegroup，但是有多个zone。一个realm中存储的数据复制到该zonegroup中的所有zone中

multi-zonegroup：一个realm中有多个zonegroup，每个zonegroup中又有一个或多个zone

multi-realms：多个realm



 

两个集群配置两个zone，实现两个zone之间的数据同步：

periods和Epochs：

每个zone有关联的period，每个period有关联的epoch。

period用于跟踪zone、zone group和realm的配置状态

epoch用于跟踪zone period的配置变更的版本号

每个period具有唯一ID，含有zone配置，并且知道其先前period的id

在更改zone的配置时，需要更新zone的当前period

## 1.4 多区域同步流程
RGW在所有zone group集合之间同步元数据和数据操作。元数据操作与bucket相关：创建、删除、启用和禁用版本控制、管理用户。meta master位于master zone group中的master zone，负责管理元数据更新

多区域配置后处于活跃状态时，RGW会在master和secondary区域之间执行一次初始的完整同步。随后的更新是增量更新

当RGW将数据写入zone group的任意zone时，它会在该zone group的所有其他zone之间同步这一数据

当RGW同步数据时，所有活跃的网关会更新数据日志并通知其他网关

当RGW网关因用户操作而同步元数据时，主网关会更新元数据日志并通知其他RGW网关

两个集群配置两个zone，实现两个zone之间的数据同步：periods和Epochs：每个zone有关联的period，每个period有关联的epoch。period用于跟踪zone、zone group和realm的配置状态epoch用于跟踪zone period的配置变更的版本号每个period具有唯一ID，含有zone配置，并且知道其先前period的id在更改zone的配置时，需要更新zone的

当前period多区域同步流程：RGW在所有zone group集合之间同步元数据和数据操作。元数据操作与bucket相关：创建、删除、启用和禁用版本控制、管理用户。meta master位于master zone group中的master zone，负责管理元数据更新多区域配置后处于活跃状态时，RGW会在master和secondary区域之间执行一次初始的完整同步。随后

的更新是增量更新当RGW将数据写入zone group的任意zone时，它会在该zone group的所有其他zone之间同步这一数据当RGW同步数据时，所有活跃的网关会更新数据日志并通知其他网关当RGW网关因用户操作而同步元数据时，主网关会更新元数据日志并通知其他RGW网关

# 二、配置

## 2.1 查看
```
# radosgw-admin realm list
{
    "default_info": "",
    "realms": []
}


# radosgw-admin zonegroup list
{
    "default_info": "",
    "zonegroups": [
        "default"
    ]
}

# radosgw-admin zone list
{
    "default_info": "",
    "zones": [
        "default"
    ]
}

# radosgw-admin zone list --rgw-zonegroup default
{
    "default_info": "",
    "zones": [
        "default"
    ]
}
```

## 2.2 创建realm
```
# radosgw-admin realm create --rgw-realm hubei  --default
{
    "id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "name": "hebei",
    "current_period": "55fafff6-9c4c-4d54-8801-ad48861221a1",
    "epoch": 1
}
```

## 2.3 创建zonegroup
```
# radosgw-admin zonegroup create --rgw-realm hubei --rgw-zonegroup  fancheng --default  --master
{
    "id": "c3e67678-07df-45cc-a6d7-f714d63fad9b",
    "name": "fancheng",
    "api_name": "fancheng",
    "is_master": "true",
    "endpoints": [],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": [],
    "zones": [],
    "placement_tragets": [],
    "default_placement": "",
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}
```


## 2.4 修改名
```
# radosgw-admin zonegroup rename  --rgw-realm hubei --rgw-zonegroup fancheng --zonegroup-new-name xiangyang

# radosgw-admin zonegroup  get --rgw-zonegroup xiangyang
{
    "id": "c3e67678-07df-45cc-a6d7-f714d63fad9b",
    "name": "xiangyang",
    "api_name": "fancheng",
    "is_master": "true",
    "endpoints": [],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": [],
    "zones": [],
    "placement_tragets": [],
    "default_placement": "",
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}
```

## 2.5 删除一个zonegroup
```
# radosgw-admin realm remove --rgw-realm hubei --rgw-zonegroup xiangyang

# radosgw-admin zonegroup list
{
    "default_info": "c3e67678-07df-45cc-a6d7-f714d63fad9b",
    "zonegroups": [
        "xiangyang",
        "default"
    ]
}

# radosgw-admin zonegroup delete --rgw-zonegroup xiangyang

# radosgw-admin zonegroup list
{
    "default_info": "",
    "zonegroups": [
        "default"
    ]
}
```


## 2.6 重建一个zonegroup
```
# radosgw-admin zonegroup  create --rgw-realm hubei  --rgw-zonegroup xiangyang  --default --master
{
    "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "name": "xiangyang",
    "api_name": "xiangyang",
    "is_master": "true",
    "endpoints": [],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": "",
    "zones": [],
    "placement_targets": [],
    "default_placement": "",
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}
```

## 2.7 创建一个zone
```
# radosgw-admin zone create --rgw-zonegroup xiangyang --rgw-zone  fancheng --default --endpoints http://ceph5.lab.example.com
{
    "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "name": "fancheng",
    "domain_root": "fancheng.rgw.meta:root",
    "control_pool": "fancheng.rgw.control",
    "gc_pool": "fancheng.rgw.log:gc",
    "lc_pool": "fancheng.rgw.log:lc",
    "log_pool": "fancheng.rgw.log",
    "intent_log_pool": "fancheng.rgw.log:intent",
    "usage_log_pool": "fancheng.rgw.log:usage",
    "reshard_pool": "fancheng.rgw.log:reshard",
    "user_keys_pool": "fancheng.rgw.meta:users.keys",
    "user_email_pool": "fancheng.rgw.meta:users.email",
    "user_swift_pool": "fancheng.rgw.meta:users.swift",
    "user_uid_pool": "fancheng.rgw.meta:users.uid",
    "system_key": {
        "access_key": "",
        "secret_key": ""
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "fancheng.rgw.buckets.index",
                "data_pool": "fancheng.rgw.buckets.data",
                "data_extra_pool": "fancheng.rgw.buckets.non-ec",
                "index_type": 0,
                "compression": ""
            }
        }
    ],
    "metadata_heap": "",
    "tier_config": [],
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}
```

## 2.8 为zone创建一个系统账号
```
# radosgw-admin  user  create --uid syncuser  --display-name  "sync user" --system
{
    "user_id": "syncuser",
    "display_name": "sync user",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "syncuser",
            "access_key": "42Y4FBWY5VDCRLG9GDM8",
            "secret_key": "BiGRHcqL03RFoFWAbymFZj6xDQAXYFVb60cIzvav"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "system": "true",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}
```

## 2.9 修改zone绑定这个用户
```
# radosgw-admin zone modify --rgw-zonegroup  xiangyang --rgw-zone  fancheng --access 42Y4FBWY5VDCRLG9GDM8 --secret BiGRHcqL03RFoFWAbymFZj6xDQAXYFVb60cIzvav
{
    "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "name": "fancheng",
    "domain_root": "fancheng.rgw.meta:root",
    "control_pool": "fancheng.rgw.control",
    "gc_pool": "fancheng.rgw.log:gc",
    "lc_pool": "fancheng.rgw.log:lc",
    "log_pool": "fancheng.rgw.log",
    "intent_log_pool": "fancheng.rgw.log:intent",
    "usage_log_pool": "fancheng.rgw.log:usage",
    "reshard_pool": "fancheng.rgw.log:reshard",
    "user_keys_pool": "fancheng.rgw.meta:users.keys",
    "user_email_pool": "fancheng.rgw.meta:users.email",
    "user_swift_pool": "fancheng.rgw.meta:users.swift",
    "user_uid_pool": "fancheng.rgw.meta:users.uid",
    "system_key": {
        "access_key": "",
        "secret_key": "BiGRHcqL03RFoFWAbymFZj6xDQAXYFVb60cIzvav"
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "fancheng.rgw.buckets.index",
                "data_pool": "fancheng.rgw.buckets.data",
                "data_extra_pool": "fancheng.rgw.buckets.non-ec",
                "index_type": 0,
                "compression": ""
            }
        }
    ],
    "metadata_heap": "",
    "tier_config": [],
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}


# radosgw-admin zonegroup  get --rgw-zonegroup  xiangyang
{
    "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "name": "xiangyang",
    "api_name": "xiangyang",
    "is_master": "true",
    "endpoints": [],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "zones": [
        {
            "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
            "name": "fancheng",
            "endpoints": [
                "http://ceph5.lab.example.com"
            ],
            "log_meta": "false",
            "log_data": "false",
            "bucket_index_max_shards": 0,
            "read_only": "false",
            "tier_type": "",
            "sync_from_all": "true",
            "sync_from": []
        }
    ],
    "placement_targets": [
        {
            "name": "default-placement",
            "tags": []
        }
    ],
    "default_placement": "default-placement",
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}
```

## 2.10 查看用户
```
# radosgw-admin user list
[
    "syncuser"
]

# radosgw-admin user list --rgw-zonegroup default --rgw-zone default
[
    "joy"
]
```


## 2.11 实施刷盘操作,更新period
```
#  radosgw-admin period update --commit
{
    "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
    "epoch": 1,
    "predecessor_uuid": "55fafff6-9c4c-4d54-8801-ad48861221a1",
    "sync_status": [],
    "period_map": {
        "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
        "zonegroups": [
            {
                "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
                "name": "xiangyang",
                "api_name": "xiangyang",
                "is_master": "true",
                "endpoints": [],
                "hostnames": [],
                "hostnames_s3website": [],
                "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "zones": [
                    {
                        "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
                        "name": "fancheng",
                        "endpoints": [
                            "http://ceph5.lab.example.com"
                        ],
                        "log_meta": "false",
                        "log_data": "false",
                        "bucket_index_max_shards": 0,
                        "read_only": "false",
                        "tier_type": "",
                        "sync_from_all": "true",
                        "sync_from": []
                    }
                ],
                "placement_targets": [
                    {
                        "name": "default-placement",
                        "tags": []
                    }
                ],
                "default_placement": "default-placement",
                "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
            }
        ],
        "short_zone_ids": [
            {
                "key": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "val": 557238113
            }
        ]
    },
    "master_zonegroup": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "period_config": {
        "bucket_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        },
        "user_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        }
    },
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "realm_name": "hubei",
    "realm_epoch": 2
}


# ceph osd pool ls
rbd
rbdmirror
.rgw.root
defautl.rgw.control
defautl.rgw.meta
defautl.rgw.log
defautl.rgw.buckets.index
defautl.rgw.buckets.data
fancheng.rgw.control
fancheng.rgw.meta
fancheng.rgw.log
```

## 2.12 更新配置文件并重启
```
# vim /etc/ceph/backup.conf 
[client.rgw.chph5]
host = ceph5
keyring = /etc/ceph/backup.client.rgw.ceph5.keyring
rgw_frontends = civetweb port=80 num_threads=100
log = /var/log/ceph/$cluster.$name.log
rgw_dns_name = ceph5.lab.example.com
rgw_zone = fancheng


# systemctl restart ceph-radosgw@rgw.ceph5


# 为当前zone创建用户
# radosgw-admin user create --uid joy --display-name "Joy Ning" --subuser joy:swift
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
            "permissions": "<none>"
        }
    ],
    "keys": [
        {
            "user": "joy",
            "access_key": "4YGLC3480T3Z5ZRY3UHG",
            "secret_key": "UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB"
        }
    ],
    "swift_keys": [
        {
            "user": "joy:swift",
            "secret_key": "ofbO1nZ1vqUHQwdNuyUd6zLLYhlbiDxMCILfbJoL"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}

# radosgw-admin user create --uid joy --display-name "Joy Ning"
# radosgw-admin subuser create --uid joy --display-name "Joy Ning" --subuser joy:swift
```

# 三、测试

## 3.1 修改为full
```
# radosgw-admin subuser modify --uid joy --display-name "Joy Ning" --subuser joy:swift --access full
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
            "access_key": "4YGLC3480T3Z5ZRY3UHG",
            "secret_key": "UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB"
        }
    ],
    "swift_keys": [
        {
            "user": "joy:swift",
            "secret_key": "ofbO1nZ1vqUHQwdNuyUd6zLLYhlbiDxMCILfbJoL"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}
```

## 3.2 客户端测试
```
# swift -A http://ceph5.lab.example.com/auth/v1.0 -U joy:swift -K ofbO1nZ1vqUHQwdNuyUd6zLLYhlbiDxMCILfbJoL list
# swift -A http://ceph5.lab.example.com/auth/v1.0 -U joy:swift -K ofbO1nZ1vqUHQwdNuyUd6zLLYhlbiDxMCILfbJoL post testswift
# swift -A http://ceph5.lab.example.com/auth/v1.0 -U joy:swift -K ofbO1nZ1vqUHQwdNuyUd6zLLYhlbiDxMCILfbJoL upload  testswift /etc/ceph/ceph.client.rbd.keyring 
etc/ceph/ceph.client.rbd.keyring
```

## 3.3 服务端

出现元数据和数据的池
```
# ceph osd pool ls
rbd
rbdmirror
.rgw.root
defautl.rgw.control
defautl.rgw.meta
defautl.rgw.log
defautl.rgw.buckets.index
defautl.rgw.buckets.data
fancheng.rgw.control
fancheng.rgw.meta
fancheng.rgw.log
fancheng.rgw.buckets.index
fancheng.rgw.buckets.data

# rados -p fancheng.rgw.buckets.data ls --cluster backup
b337a562-5921-46fc-aad2-e70e99454e5f.4282.1_etc/ceph/ceph.client.rbd.keyring
```


# 四 、ceph2配置secondary域

## 4.1 拉取realm
```
# radosgw-admin realm pull --url http://ceph5.lab.example.com  --access-key 4YGLC3480T3Z5ZRY3UHG --secret UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB


2019-03-26 11:37:03.055756 7f1974483c40  1 error read_lastest_epoch .rgw.root:periods.1c6ccdef-ca02-44b5-b212-ba68acbd6aad.latest_epoch
2019-03-26 11:37:03.075671 7f1974483c40  1 Set the period's master zonegroup 5acbb712-0f7f-4108-8d93-ea75a19e33b3 as the default
{
    "id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "name": "hubei",
    "current_period": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
    "epoch": 2
}

# radosgw-admin realm list
{
    "default-info": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "realms": [
        "hebei",
    ]
}

# radosgw-admin zonegroup get --rgw-realm hubei
{
    "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "name": "xiangyang",
    "api_name": "xiangyang",
    "is_master": "true",
    "endpoints": [],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "zones": [
        {
            "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
            "name": "fancheng",
            "endpoints": [
                "http://ceph5.lab.example.com"
            ],
            "log_meta": "false",
            "log_data": "false",
            "bucket_index_max_shards": 0,
            "read_only": "false",
            "tier_type": "",
            "sync_from_all": "true",
            "sync_from": []
        }
    ],
    "placement_targets": [
        {
            "name": "default-placement",
            "tags": []
        }
    ],
    "default_placement": "default-placement",
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}
```

## 4.2 拉取period
```
# radosgw-admin period pull --url  http://ceph5.lab.example.com --access-key 4YGLC3480T3Z5ZRY3UHG  --secret UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB
2019-03-26 11:47:05.406374 7f3dc85c7c40  1 found existing latest_epoch 1 >= given epoch 1, returning r=-17
{
    "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
    "epoch": 1,
    "predecessor_uuid": "55fafff6-9c4c-4d54-8801-ad48861221a1",
    "sync_status": [],
    "period_map": {
        "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
        "zonegroups": [
            {
                "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
                "name": "xiangyang",
                "api_name": "xiangyang",
                "is_master": "true",
                "endpoints": [],
                "hostnames": [],
                "hostnames_s3website": [],
                "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "zones": [
                    {
                        "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
                        "name": "fancheng",
                        "endpoints": [
                            "http://ceph5.lab.example.com"
                        ],
                        "log_meta": "false",
                        "log_data": "false",
                        "bucket_index_max_shards": 0,
                        "read_only": "false",
                        "tier_type": "",
                        "sync_from_all": "true",
                        "sync_from": []
                    }
                ],
                "placement_targets": [
                    {
                        "name": "default-placement",
                        "tags": []
                    }
                ],
                "default_placement": "default-placement",
                "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
            }
        ],
        "short_zone_ids": [
            {
                "key": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "val": 557238113
            }
        ]
    },
    "master_zonegroup": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "period_config": {
        "bucket_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        },
        "user_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        }
    },
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "realm_name": "hubei",
    "realm_epoch": 2
}
```

## 4.3 创建Secondary Zone
```
# radosgw-admin zone create --rgw-zonegroup  xiangyang --rgw-zone  xiantao  --endpoints http://ceph2.lab.example.com  --default --access-key 4YGLC3480T3Z5ZRY3UHG  --secret UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB
2019-03-26 11:49:47.924379 7f7d2758cc40  0 failed reading obj info from .rgw.root:zone_info.b337a562-5921-46fc-aad2-e70e99454e5f: (2) No such file or directory
2019-03-26 11:49:47.924419 7f7d2758cc40  0 WARNING: could not read zone params for zone id=b337a562-5921-46fc-aad2-e70e99454e5f name=fancheng
{
    "id": "b012d15d-a83c-4553-9ec3-09bf45d4a67b",
    "name": "xiantao",
    "domain_root": "xiantao.rgw.meta:root",
    "control_pool": "xiantao.rgw.control",
    "gc_pool": "xiantao.rgw.log:gc",
    "lc_pool": "xiantao.rgw.log:lc",
    "log_pool": "xiantao.rgw.log",
    "intent_log_pool": "xiantao.rgw.log:intent",
    "usage_log_pool": "xiantao.rgw.log:usage",
    "reshard_pool": "xiantao.rgw.log:reshard",
    "user_keys_pool": "xiantao.rgw.meta:users.keys",
    "user_email_pool": "xiantao.rgw.meta:users.email",
    "user_swift_pool": "xiantao.rgw.meta:users.swift",
    "user_uid_pool": "xiantao.rgw.meta:users.uid",
    "system_key": {
        "access_key": "4YGLC3480T3Z5ZRY3UHG",
        "secret_key": "UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB"
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "xiantao.rgw.buckets.index",
                "data_pool": "xiantao.rgw.buckets.data",
                "data_extra_pool": "xiantao.rgw.buckets.non-ec",
                "index_type": 0,
                "compression": ""
            }
        }
    ],
    "metadata_heap": "",
    "tier_config": [],
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}

# radosgw-admin zonegroup get --rgw-realm  hubei --rgw-zonegroup
parse error setting 'rgw_zonegroup' to '' (Option --rgw-zonegroup requires an argument.)
{
    "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "name": "xiangyang",
    "api_name": "xiangyang",
    "is_master": "true",
    "endpoints": [],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "zones": [
        {
            "id": "b012d15d-a83c-4553-9ec3-09bf45d4a67b",
            "name": "xiantao",
            "endpoints": [
                "http://ceph2.lab.example.com"
            ],
            "log_meta": "false",
            "log_data": "true",
            "bucket_index_max_shards": 0,
            "read_only": "false",
            "tier_type": "",
            "sync_from_all": "true",
            "sync_from": []
        },
        {
            "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
            "name": "fancheng",
            "endpoints": [
                "http://ceph5.lab.example.com"
            ],
            "log_meta": "false",
            "log_data": "true",
            "bucket_index_max_shards": 0,
            "read_only": "false",
            "tier_type": "",
            "sync_from_all": "true",
            "sync_from": []
        }
    ],
    "placement_targets": [
        {
            "name": "default-placement",
            "tags": []
        }
    ],
    "default_placement": "default-placement",
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}


# radosgw-admin zone modify  --rgw-zonegroup  xiangyang --rgw-zone  fancheng --endpoints http://ceph5.lab.example.com
{
    "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "name": "fancheng",
    "domain_root": "fancheng.rgw.meta:root",
    "control_pool": "fancheng.rgw.control",
    "gc_pool": "fancheng.rgw.log:gc",
    "lc_pool": "fancheng.rgw.log:lc",
    "log_pool": "fancheng.rgw.log",
    "intent_log_pool": "fancheng.rgw.log:intent",
    "usage_log_pool": "fancheng.rgw.log:usage",
    "reshard_pool": "fancheng.rgw.log:reshard",
    "user_keys_pool": "fancheng.rgw.meta:users.keys",
    "user_email_pool": "fancheng.rgw.meta:users.email",
    "user_swift_pool": "fancheng.rgw.meta:users.swift",
    "user_uid_pool": "fancheng.rgw.meta:users.uid",
    "system_key": {
        "access_key": "",
        "secret_key": "BiGRHcqL03RFoFWAbymFZj6xDQAXYFVb60cIzvav"
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "fancheng.rgw.buckets.index",
                "data_pool": "fancheng.rgw.buckets.data",
                "data_extra_pool": "fancheng.rgw.buckets.non-ec",
                "index_type": 0,
                "compression": ""
            }
        }
    ],
    "metadata_heap": "",
    "tier_config": [],
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}
```

## 4.4 更新period
```
#  radosgw-admin period update --commit
{
    "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
    "epoch": 2,
    "predecessor_uuid": "55fafff6-9c4c-4d54-8801-ad48861221a1",
    "sync_status": [],
    "period_map": {
        "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
        "zonegroups": [
            {
                "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
                "name": "xiangyang",
                "api_name": "xiangyang",
                "is_master": "true",
                "endpoints": [],
                "hostnames": [],
                "hostnames_s3website": [],
                "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "zones": [
                    {
                        "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
                        "name": "fancheng",
                        "endpoints": [
                            "http://ceph5.lab.example.com"
                        ],
                        "log_meta": "false",
                        "log_data": "false",
                        "bucket_index_max_shards": 0,
                        "read_only": "false",
                        "tier_type": "",
                        "sync_from_all": "true",
                        "sync_from": []
                    }
                ],
                "placement_targets": [
                    {
                        "name": "default-placement",
                        "tags": []
                    }
                ],
                "default_placement": "default-placement",
                "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
            }
        ],
        "short_zone_ids": [
            {
                "key": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "val": 557238113
            }
        ]
    },
    "master_zonegroup": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "period_config": {
        "bucket_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        },
        "user_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        }
    },
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "realm_name": "hubei",
    "realm_epoch": 2
}

# ceph auth get-or-create client.rgw.ceph2  mon 'allow rwx' osd 'allow rwx' -o /etc/ceph/ceph.client.radosgw.keyring --cluster ceph

# ceph osd pool ls
testpool
rbd
rbdmirror
.rgw.root
default.rgw.control
default.rgw.meta
default.rgw.log
```
发现没有成功，重新拉取一遍

## 4.5 删除relam
```
# radosgw-admin zonegroup delete --rgw-zonegroup xiangyang
# radosgw-admin realm delete --rgw-realm hubei

# radosgw-admin zone delete --rgw-zone xiantao

# radosgw-admin realm list
{
    "default_info": "",
    "realms": []
}
```


## 4.6 重新拉取
```
# radosgw-admin realm pull --url http://ceph5.lab.example.com --access-key  4YGLC3480T3Z5ZRY3UHG --secret UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB
2019-03-26 13:28:24.324288 7f00bbc65c40  1 Set the period's master zonegroup 5acbb712-0f7f-4108-8d93-ea75a19e33b3 as the default
{
    "id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "name": "hubei",
    "current_period": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
    "epoch": 2
}

# radosgw-admin period pull --url http://ceph5.lab.example.com --access-key  4YGLC3480T3Z5ZRY3UHG --secret UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB
{
    "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
    "epoch": 5,
    "predecessor_uuid": "55fafff6-9c4c-4d54-8801-ad48861221a1",
    "sync_status": [],
    "period_map": {
        "id": "1c6ccdef-ca02-44b5-b212-ba68acbd6aad",
        "zonegroups": [
            {
                "id": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
                "name": "xiangyang",
                "api_name": "xiangyang",
                "is_master": "true",
                "endpoints": [],
                "hostnames": [],
                "hostnames_s3website": [],
                "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "zones": [
                    {
                        "id": "b337a562-5921-46fc-aad2-e70e99454e5f",
                        "name": "fancheng",
                        "endpoints": [
                            "http://ceph5.lab.example.com"
                        ],
                        "log_meta": "false",
                        "log_data": "false",
                        "bucket_index_max_shards": 0,
                        "read_only": "false",
                        "tier_type": "",
                        "sync_from_all": "true",
                        "sync_from": []
                    }
                ],
                "placement_targets": [
                    {
                        "name": "default-placement",
                        "tags": []
                    }
                ],
                "default_placement": "default-placement",
                "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
            }
        ],
        "short_zone_ids": [
            {
                "key": "b337a562-5921-46fc-aad2-e70e99454e5f",
                "val": 557238113
            }
        ]
    },
    "master_zonegroup": "5acbb712-0f7f-4108-8d93-ea75a19e33b3",
    "master_zone": "b337a562-5921-46fc-aad2-e70e99454e5f",
    "period_config": {
        "bucket_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        },
        "user_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        }
    },
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba",
    "realm_name": "hubei",
    "realm_epoch": 2
}

2019-03-26 13:28:54.816633 7efd7ebf8c40  1 found existing latest_epoch 5 >= given epoch 5, returning r=-17

#  radosgw-admin zone create --rgw-zonegroup xiangyang --rgw-zone xiantao --endpoints http://ceph2.lab.example.com --default --access-key 4YGLC3480T3Z5ZRY3UHG --secret UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB
2019-03-26 13:30:01.076567 7fb699f77c40  0 failed reading obj info from .rgw.root:zone_info.b337a562-5921-46fc-aad2-e70e99454e5f: (2) No such file or directory
2019-03-26 13:30:01.076625 7fb699f77c40  0 WARNING: could not read zone params for zone id=b337a562-5921-46fc-aad2-e70e99454e5f name=fancheng
{
    "id": "09ece789-b2fc-4379-8c60-d37811074216",
    "name": "xiantao",
    "domain_root": "xiantao.rgw.meta:root",
    "control_pool": "xiantao.rgw.control",
    "gc_pool": "xiantao.rgw.log:gc",
    "lc_pool": "xiantao.rgw.log:lc",
    "log_pool": "xiantao.rgw.log",
    "intent_log_pool": "xiantao.rgw.log:intent",
    "usage_log_pool": "xiantao.rgw.log:usage",
    "reshard_pool": "xiantao.rgw.log:reshard",
    "user_keys_pool": "xiantao.rgw.meta:users.keys",
    "user_email_pool": "xiantao.rgw.meta:users.email",
    "user_swift_pool": "xiantao.rgw.meta:users.swift",
    "user_uid_pool": "xiantao.rgw.meta:users.uid",
    "system_key": {
        "access_key": "4YGLC3480T3Z5ZRY3UHG",
        "secret_key": "UuHLN9nlTofwez8Nz0RVJ60Vl6v6zGVJtjLP04pB"
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "xiantao.rgw.buckets.index",
                "data_pool": "xiantao.rgw.buckets.data",
                "data_extra_pool": "xiantao.rgw.buckets.non-ec",
                "index_type": 0,
                "compression": ""
            }
        }
    ],
    "metadata_heap": "",
    "tier_config": [],
    "realm_id": "d4668fc2-ceed-4eb2-a5e7-a70c2aa7deba"
}

# cd /etc/ceph/
# rm -rf ceph.client.radosgw.keyring 
# ceph auth get-or-create client.rgw.ceph2 mon 'allow rwx' osd 'allow rwx' -o /etc/ceph/ceph.client.radosgw.keyring --cluster ceph

# ceph osd  pool ls
testpool
rbd
rbdmirror
.rgw.root
default.rgw.control
default.rgw.meta
default.rgw.log
xiantao.rgw.control
xiantao.rgw.meta
xiantao.rgw.log
```

# 五、迁移Single-Zone至Multi-Zone

## 5.1 查看
```
# swift -A http://ceph5.lab.example.com/auth/v1.0 -U joy:swift -K ofbO1nZ1vqUHQwdNuyUd6zLLYhlbiDxMCILfbJoL list 

 
# swift -A http://ceph5.lab.example.com/auth/v1.0 -U joy:swift -K ofbO1nZ1vqUHQwdNuyUd6zLLYhlbiDxMCILfbJoL list testswift

```

## 5.2 ceph5把default的zone添加到一个realm
```
#  radosgw-admin realm list

 

# radosgw-admin zonegroup list

```

## 5.3 为default创建一个新的zonegroup
```
# radosgw-admin realm create --rgw-realm realmnew

```

## 5.4 修改default的realm，设置为master
```
# radosgw-admin zonegroup modify --rgw-realm realmnew --rgw-zonegroup default --master
{
    "id": "e80133e1-a513-44f5-ba90-e25b6c987b26",
    "name": "default",
    "api_name": "",
    "is_master": "true",
    "endpoints": [],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
    "zones": [
        {
            "id": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
            "name": "default",
            "endpoints": [],
            "log_meta": "false",
            "log_data": "false",
            "bucket_index_max_shards": 0,
            "read_only": "false",
            "tier_type": "",
            "sync_from_all": "true",
            "sync_from": []
        }
    ],
    "placement_targets": [
        {
            "name": "default-placement",
            "tags": []
        }
    ],
    "default_placement": "default-placement",
    "realm_id": "de918d45-d763-416d-af0a-0350b1339ca1"
}



# radosgw-admin zone modify --rgw-zonegroup default --rgw-zone default --master --endpoints http://ceph5.lab.example.com
{
    "id": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
    "name": "default",
    "domain_root": "default.rgw.meta:root",
    "control_pool": "default.rgw.control",
    "gc_pool": "default.rgw.log:gc",
    "lc_pool": "default.rgw.log:lc",
    "log_pool": "default.rgw.log",
    "intent_log_pool": "default.rgw.log:intent",
    "usage_log_pool": "default.rgw.log:usage",
    "reshard_pool": "default.rgw.log:reshard",
    "user_keys_pool": "default.rgw.meta:users.keys",
    "user_email_pool": "default.rgw.meta:users.email",
    "user_swift_pool": "default.rgw.meta:users.swift",
    "user_uid_pool": "default.rgw.meta:users.uid",
    "system_key": {
        "access_key": "",
        "secret_key": ""
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "default.rgw.buckets.index",
                "data_pool": "default.rgw.buckets.data",
                "data_extra_pool": "default.rgw.buckets.non-ec",
                "index_type": 0,
                "compression": ""
            }
        }
    ],
    "metadata_heap": "",
    "tier_config": [],
    "realm_id": ""
}
```

## 5.5 创建一个系统用户
```
# radosgw-admin user create --uid syncuser1 --display-name "sync user" --rgw-zonegroup default --rgw-zone default
{
    "user_id": "syncuser1",
    "display_name": "sync user",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "syncuser1",
            "access_key": "MIVNCAI762F49VPRAFDF",
            "secret_key": "kHJSrkBxpVQJsCOy2sV4P9ElmzTkjcPX81R6hycR"
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
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}
```

## 5.6 将master-zone与系统用户关联
```
#  radosgw-admin zone modify --rgw-zonegroup default --rgw-zone default --master --endpoints http://ceph5.lab.example.com --access-key MIVNCAI762F49VPRAFDF --secret kHJSrkBxpVQJsCOy2sV4P9ElmzTkjcPX81R6hycR
{
    "id": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
    "name": "default",
    "domain_root": "default.rgw.meta:root",
    "control_pool": "default.rgw.control",
    "gc_pool": "default.rgw.log:gc",
    "lc_pool": "default.rgw.log:lc",
    "log_pool": "default.rgw.log",
    "intent_log_pool": "default.rgw.log:intent",
    "usage_log_pool": "default.rgw.log:usage",
    "reshard_pool": "default.rgw.log:reshard",
    "user_keys_pool": "default.rgw.meta:users.keys",
    "user_email_pool": "default.rgw.meta:users.email",
    "user_swift_pool": "default.rgw.meta:users.swift",
    "user_uid_pool": "default.rgw.meta:users.uid",
    "system_key": {
        "access_key": "MIVNCAI762F49VPRAFDF",
        "secret_key": "kHJSrkBxpVQJsCOy2sV4P9ElmzTkjcPX81R6hycR"
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "default.rgw.buckets.index",
                "data_pool": "default.rgw.buckets.data",
                "data_extra_pool": "default.rgw.buckets.non-ec",
                "index_type": 0,
                "compression": ""
            }
        }
    ],
    "metadata_heap": "",
    "tier_config": [],
    "realm_id": ""
}
```

## 5.7 提交新的配置 
```
#  radosgw-admin period update --commit --rgw-zonegroup default --rgw-zone default --rgw-realm realmnew
2019-03-26 13:50:39.137059 7fd1dd9cec40  1 Set the period's master zonegroup e80133e1-a513-44f5-ba90-e25b6c987b26 as the default
{
    "id": "152a15c4-d0f7-4bd1-93db-fc1f8655b741",
    "epoch": 1,
    "predecessor_uuid": "0daf85ed-732b-4f0f-8f58-a3f8ef1e996e",
    "sync_status": [],
    "period_map": {
        "id": "152a15c4-d0f7-4bd1-93db-fc1f8655b741",
        "zonegroups": [
            {
                "id": "e80133e1-a513-44f5-ba90-e25b6c987b26",
                "name": "default",
                "api_name": "",
                "is_master": "true",
                "endpoints": [],
                "hostnames": [],
                "hostnames_s3website": [],
                "master_zone": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
                "zones": [
                    {
                        "id": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
                        "name": "default",
                        "endpoints": [
                            "http://ceph5.lab.example.com"
                        ],
                        "log_meta": "false",
                        "log_data": "false",
                        "bucket_index_max_shards": 0,
                        "read_only": "false",
                        "tier_type": "",
                        "sync_from_all": "true",
                        "sync_from": []
                    }
                ],
                "placement_targets": [
                    {
                        "name": "default-placement",
                        "tags": []
                    }
                ],
                "default_placement": "default-placement",
                "realm_id": "de918d45-d763-416d-af0a-0350b1339ca1"
            }
        ],
        "short_zone_ids": [
            {
                "key": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
                "val": 422091396
            }
        ]
    },
    "master_zonegroup": "e80133e1-a513-44f5-ba90-e25b6c987b26",
    "master_zone": "1b85c5b1-19d2-48a1-bb45-3ac75895aeed",
    "period_config": {
        "bucket_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        },
        "user_quota": {
            "enabled": false,
            "check_on_raw": false,
            "max_size": -1,
            "max_size_kb": 0,
            "max_objects": -1
        }
    },
    "realm_id": "de918d45-d763-416d-af0a-0350b1339ca1",
    "realm_name": "realmnew",
    "realm_epoch": 2
}
```

## 5.8 修改配置文件使生效
```
# vim /etc/ceph/backup.conf
fsid = 51dda18c-7545-4edb-8ba9-27330ead81a7
mon_initial_members = ceph5
mon_host = 172.25.250.14
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
public_network = 172.25.250.0/24
cluster_network = 172.25.250.0/24
[mgr]
mgr modules = dashboard
[client.rgw.ceph5]
host = ceph5
keyring = /etc/ceph/backup.client.rgw.ceph5.keyring
rgw_frontends = civetweb port=80 num_threads=100
log = /var/log/ceph/$cluster.$name.log
rgw_dns_name = ceph5.lab.example.com
rgw_zone = default
rgw_region = realmnew
rgw_zonegroup = default

# systemctl restart ceph-radosgw@rgw.ceph5

# ps -ef|grep rados
```
