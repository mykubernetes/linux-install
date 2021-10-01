
# 列出所有存储池
```
# rados lspools
.rgw.root
default.rgw.control
default.rgw.data.root
default.rgw.gc
default.rgw.log
default.rgw.users.uid
default.rgw.users.keys
default.rgw.buckets.index
default.rgw.usage
default.rgw.buckets.data
default.rgw.buckets.non-ec
default.rgw.users.swift
default.rgw.users.email
```

# 各个pool的作用

1).rgw.root
- 本pool中包含realm、zonegroup和zone

```
# rados -p .rgw.root ls
zone_info.78b9bcbb-b328-4e4a-8417-4ed933be88bb
zonegroup_info.8a40abe8-c081-4065-8aea-bd0a3745cd2c
zone_names.default
zonegroups_names.default
```

2)default.rgw.control
- 在RGW上电时， 在control pool创建若干个对象用于watch-notify，主要作用为当一个zone对应多个RGW且cache使能时，保证数据的一致性。其基本原理为利用librados提供的对象watch-notify功能，当有数据更新时，通知其他RGW刷新cache，后面会有文档专门描述RGW cache。

```
# rados -p default.rgw.control ls
notify.1
notify.7
notify.5
notify.6
notify.2
notify.4
notify.3
notify.0
```

3)default.rgw.data.root
- 包含bucket和bucket元数据，bucket创建了两个对象， 一个是`<bucket_name>`，另一个是`.bucket.meta.<bucket_name>.<marker>`。这个marker是创建bucket时生成的。同时用户创建的bucket在`default.rgw.buckets.index`中都对应一个object对象，其命名格式为`.dir.<marker>.`

```
# rados -p default.rgw.data.root ls 
.bucket.meta.app_wangpan_uat_liuzy28_bucket:78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11
app_wangpan_uat_liuzy28_bucket

# rados -p default.rgw.buckets.index ls 
.dir.78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11
```

  
4）default.rgw.gc
- RGW中大文件数据一般在后台删除，该pool用于记录那些待删除的文件对象。

```
# rados -p default.rgw.gc ls | more
gc.132
gc.597
gc.250
gc.197
gc.949
gc.650
gc.446
gc.218
gc.333
gc.1000
gc.299
gc.423
...
```

5） default.rgw.log
- 各种log信息。

```
# rados -p default.rgw.log ls | more
obj_delete_at_hint.0000000078
obj_delete_at_hint.0000000070
obj_delete_at_hint.0000000104
obj_delete_at_hint.0000000026
obj_delete_at_hint.0000000028
obj_delete_at_hint.0000000040
obj_delete_at_hint.0000000015
obj_delete_at_hint.0000000069
obj_delete_at_hint.0000000095
obj_delete_at_hint.0000000003
obj_delete_at_hint.0000000047
```

6) default.rgw.users.uid
- 保存用户信息和用户下的bucket信息。

```
# rados -p default.rgw.users.uid ls 
app_wangpan_uat_liuzy28.buckets
app_wangpan_uat_liuzy28

# rados -p default.rgw.users.uid listomapkeys app_wangpan_uat_liuzy28.buckets
app_wangpan_uat_liuzy28_bucket
```
上面可以看到，用户liuzy28创建了一个bucket。

7) **default.rgw.users.keys**
- 包含注册用户的`access_key`。

```
# rados -p default.rgw.users.keys ls
7ACMGKB778ADFXHN4UB5
3FD061FOB9MBI3792OK6
8OGTPS5BP8D91K2WB16X
412ON3GMI1F9H6868EDU
4JGRS8LFTJA5B9JZZDCN
BO2OKHSNRFX39C8FTUXI
PVBNC7HS7UE4RA7I76GI
3GCOA1BH97LVAFCVZIBL
8L9FXBWCZXPS3I8ZJ8ZU
NH4N19Y9IICLAGPZ7EG1
...
```

8）default.rgw.users.swift
- 包含注册的子用户(用于swift)。
```
# rados -p default.rgw.users.swift ls
```

9)default.rgw.buckets.index
- 包含bucket信息，和default.rgw.data.root对应。
```
# rados -p default.rgw.buckets.index ls 
.dir.78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11
```

10)default.rgw.buckets.data
- 包含每个bucket目录下的object。

```
# rados -p  default.rgw.buckets.data ls | grep "78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11"
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_f90bc5b01ee550a61ca3d7a6993e863c_1.2~gii8SrB-7mFepWvb_flR_vZ-rwcyL_n.3
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_931ed2b0edcea755675d67d1bf5edef1_19.2~3wDME9d_ntrl-l_MF5dpi70ycL-35lm.3
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_2e58afcfaee9fef3b2be9963e45c986a_1.2~pcoCTx8dG4JwRtxxYwh2e5Dgaqm9Jnq.1
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_ad5496efb007cd3726b331490987fd03_1.2~BvnuoIfhpzgskVzH7yNdGJKXbE89P5f.1
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_701d70d3033f0a885f4c0ba792bc4597_1.2~X-omYr0C4kGS6l5XqUn0VxNbUrjUzZG.4
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_701d70d3033f0a885f4c0ba792bc4597_1.2~X-omYr0C4kGS6l5XqUn0VxNbUrjUzZG.7
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_931ed2b0edcea755675d67d1bf5edef1_19.2~3wDME9d_ntrl-l_MF5dpi70ycL-35lm.19
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_80a61aa9359429c0c103a204ddcea5f2_1.2~MUAMe80jwm9K-kyYzXA6Arw5iVl2YXP.1
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11_f90bc5b01ee550a61ca3d7a6993e863c_1
....

# rados -p default.rgw.buckets.index listomapkeys .dir.78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11
28fb479ea32e0037590e32ca48ff189d_1
2e58afcfaee9fef3b2be9963e45c986a_1
701d70d3033f0a885f4c0ba792bc4597_1
80a61aa9359429c0c103a204ddcea5f2_1
931ed2b0edcea755675d67d1bf5edef1_19
ad5496efb007cd3726b331490987fd03_1
b464a8dfbe27c555ea84843557f70926_1
d2a6727a280b020c7f7edc0182cd89b0_1
f90bc5b01ee550a61ca3d7a6993e863c_1

# radosgw-admin bucket list --bucket=app_wangpan_uat_liuzy28_bucket | grep -w name
        "name": "28fb479ea32e0037590e32ca48ff189d_1",
        "name": "2e58afcfaee9fef3b2be9963e45c986a_1",
        "name": "701d70d3033f0a885f4c0ba792bc4597_1",
        "name": "80a61aa9359429c0c103a204ddcea5f2_1",
        "name": "931ed2b0edcea755675d67d1bf5edef1_19",
        "name": "ad5496efb007cd3726b331490987fd03_1",
        "name": "b464a8dfbe27c555ea84843557f70926_1",
        "name": "d2a6727a280b020c7f7edc0182cd89b0_1",
        "name": "f90bc5b01ee550a61ca3d7a6993e863c_1",
```
上面可以看到bucket下有9个文件。
```
# rados -p default.rgw.buckets.data listxattr \
78b9bcbb-b328-4e4a-8417-4ed933be88bb.113396.11__multipart_f90bc5b01ee550a61ca3d7a6993e863c_1.2~gii8SrB-7mFepWvb_flR_vZ-rwcyL_n.3
user.rgw.acl
user.rgw.content_type
user.rgw.etag
user.rgw.pg_ver
user.rgw.source_zone
user.rgw.x-amz-date
user.rgw.x-amz-user-agent
```
对于每个object都包含相应的属性。
