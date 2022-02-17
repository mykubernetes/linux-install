# RadosGW对象存储简介

RadosGW是对象存储（OSS,Object Storage Service)的一种实现方式，RADOS网关也成为Ceph对象网关、RadosGW、RGW，是一种服务，使客户端能够利用标准对象存储API来访问Ceph集群，它支持AWS S3和Swift API,在ceph 0.8 版本之后使用 Civetweb (https://github.com/civetweb/civetweb) 的web服务器来响应api请求，客户端使用http/https协议通过RESTful API与RGW通信，而RGW则通过librados与ceph集群通信，RGW客户端通过s3或者swift api使用RGW用户进行身份验证，然后RGW网关代表用户利用cephx与ceph存储进行身份验证。

S3由Amazon 于2006年推出，全称为Simple Storage Service,S3定义了对象存储，是对象存储事实上的标准，从某种意义上说，S3就是对象存储，对象存储就是S3,它是对象存储市场的霸主，后续的对象存储都是对S3的模仿

# 对象存储特点

通过对象存储将数据存储为对象，每个对象处理包含数据，还可以包含自身的元数据。

对象通过Object ID来检索，无法通过普通文件系统的方式通过文件路径及文件名称操作来直接访问对象，只能通过API来访问，或者第三方客户端（实际上也是对API的封装)。

对象存储在的对象不整理到目录树中，而是存储在扁平的命名空间中，Amazon S3将这个扁平命名空间称为bucket，而swift则将其成为容器。

无论是bucket 还是容器，都不能嵌套。

bucket需要被授权才能访问到，一个账户可以对多个bucket授权，而权限可以不同。

方便横向扩展，快速检索数据。

不支持客户端挂载，而需要客户端在访问的时候指定文件名称。

不是很适用于文件过频繁修改及删除的场景。

ceph使用bucket作为存储桶（存储空间），实现对象数据的存储和多用户隔离，数据存储在bucket中，用户的权限也是针对bucket进行授权，可以设置用户对不同bucket用户不同的权限，以实现权限管理



参考：
- https://www.jianshu.com/p/53071a40afef
- https://www.jianshu.com/p/bf883548c6f7
- http://www.idcat.cn/hadoop2-7-3%E9%80%9A%E8%BF%87s3%E5%AF%B9%E6%8E%A5ceph10-2-radosgw%E6%B5%8B%E8%AF%95.html
- https://blog.csdn.net/zhouzixin053/article/details/106420562
