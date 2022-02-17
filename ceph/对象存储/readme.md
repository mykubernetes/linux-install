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

# bucket 特性

存储空间是用于存储对象（Object)的容器，所有的对象都必须隶属于某个存储空间，可以设置和修改存储空间属性用来控制地域，访问权限，生命周期等，这些属性设置直接作用于该存储空间内所有对象，因此可以通过灵活创建不同的存储空间来完成不同的管理功能。

同一个存储空间的内部是扁平的，没有文件系统的目录等概念，所有的对象都直接隶属于其对应的存储空间。

每个用户可以拥有多个存储空间。

存储空间的名称在OSS范围内必须是全局唯一的，一旦创建之后无法修改名称。

存储空间内部的对象数目没有限制。

# bucket 命名规范

https://docs.amazonaws.cn/AmazonS3/latest/userguide/bucketnamingrules.html

- 只能包括小写字母，数字和短横线（-）
- 必须以小写字母或者数字开头和结尾
- 长度必须在3-63字节之间
- 存储桶名称不能使用IP地址格式
- Bucket名称必须全局唯一

# 对象存储访问对比

**Amazon S3**: 提供了user、bucket和object分别标识用户、存储桶和对象，其中bucket隶属于user,可以针对user设置不同bucket的名称空间的访问权限，而且不同用户允许访问相同的bucket

**OpenStack Swift**: 提供了user、container和acount用于表示一个项目或租户（OpenStack用户），因此一个account中可以包含一到多个User,它们可共享使用同一组container，并为container提供名称空间

**RadosGW**: 提供了user、subuser、bucket和object,其中user对应于S3的user,而subuser则对应于Swift的user,不过user和subuser都不支持为bucket提供名称空间，因此，不同用户的存储桶也不允许同名，不过自Jewel版本起，RadosGW引入了tenant(租户）用于为user和bucket提供名称空间，但它是个可选组件，RadosGW基于ACL为不同的用户设置不同的权限控制，如：
- Read: 读权限
- Write: 写权限
- Readwrite: 读写权限
- full-control: 全部控制权限









参考：
- https://www.jianshu.com/p/53071a40afef
- https://www.jianshu.com/p/bf883548c6f7
- http://www.idcat.cn/hadoop2-7-3%E9%80%9A%E8%BF%87s3%E5%AF%B9%E6%8E%A5ceph10-2-radosgw%E6%B5%8B%E8%AF%95.html
- https://blog.csdn.net/zhouzixin053/article/details/106420562
