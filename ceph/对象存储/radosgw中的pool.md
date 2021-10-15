```
rbd
.rgw.root 包含realm，zonegroup和zone
default.rgw.control 在RGW上电时，在control pool创建若干个对象用于watch-notify，主要作用为当一个zone对应多个RGW，且cache使能时， 保证数据的一致性，其基本原理为利用librados提供的对象watch-notify功能，当有数据更新时，通知其他RGW刷新cache， 后面会有文档专门描述RGW cache。
default.rgw.data.root
包含bucekt和bucket元数据，bucket创建了两个对象一个：一个是< bucket_name > 另一个是.bucket.meta.< bucket_name >.< marker > 这个marker是创建bucket中生成的。 同时用户创建的buckets在.rgw.buckets.index都对应一个object对象，其命名是格式：.dir.< marker >
default.rgw.gc RGW中大文件数据一般在后台删除，该pool用于记录那些待删除的文件对象
default.rgw.log 各种log信息
default.rgw.users.uid 保存用户信息，和用户下的bucket信息
default.rgw.users.keys 包含注册用户的access_key
default.rgw.users.swift 包含注册的子用户(用于swift)
default.rgw.buckets.index 包含bucket信息，和default.rgw.data.root对应
default.rgw.buckets.data 包含每个bucket目录下的object
```
