# RBD调优参数项

- RBD缓存参数必须添加到发起I/0请求的计算机上的配置文件的[client]部分中。

| 参数信息 | 参数描述 | Defaults values |
|---------|---------|-----------------|
| rbd_cache | 开启rbd的缓存 | true |
| rbd_cache_size | 为每一个rbd设置缓存大小 | 32MB |
| rbd_cache_max dirty | 最大内存中脏数据量，超出就不准写了 | 24MB |
| rbd_cache_target_dirty | 到什么程度开始刷盘(写入磁盘) | 16MB |
| rbd_cache_max_dirty_age | 间隔多少秒自动刷盘一次 | 1 |
| rbd_cache_writethrough_until_flush | 第一次写入数据先落盘然后再写到内存 | true |
