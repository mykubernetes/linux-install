# RBD介绍
> RBD即RADOS Block Device的简称，RBD块存储是最稳定且最常用的存储类型。RBD块设备类似磁盘可以被挂载。 RBD块设备具有快照、多副本、克隆和一致性等特性，数据以条带化的方式存储在Ceph集群的多个OSD中。如下是对Ceph RBD的理解。
- RBD 就是 Ceph 里的块设备，一个 4T 的块设备的功能和一个 4T 的 SATA 类似，挂载的 RBD 就可以当磁盘用；
- resizable：这个块可大可小；
- data striped：这个块在Ceph里面是被切割成若干小块来保存，不然 1PB 的块怎么存的下；
- thin-provisioned：精简置备，1TB 的集群是能创建无数 1PB 的块的。其实就是块的大小和在 Ceph 中实际占用大小是没有关系的，刚创建出来的块是不占空间，今后用多大空间，才会在 Ceph 中占用多大空间。举例：你有一个 32G 的 U盘，存了一个2G的电影，那么 RBD 大小就类似于 32G，而 2G 就相当于在 Ceph 中占用的空间  ；

>块存储本质就是将裸磁盘或类似裸磁盘(lvm)设备映射给主机使用，主机可以对其进行格式化并存储和读取数据，块设备读取速度快但是不支持共享。
>>ceph可以通过内核模块和librbd库提供块设备支持。客户端可以通过内核模块挂在rbd使用，客户端使用rbd块设备就像使用普通硬盘一样，可以对其就行格式化然后使用；客户应用也可以通过librbd使用ceph块，典型的是云平台的块存储服务（如下图），云平台可以使用rbd作为云的存储后端提供镜像存储、volume块或者客户的系统引导盘等。

使用场景：

- 云平台（OpenStack做为云的存储后端提供镜像存储）
- K8s容器
- map成块设备直接使用
- ISCIS，安装Ceph客户端
# RBD常用命令
| 命令 | 功能 |
| ------ | ------ |
| rbd create | 创建块设备映像 |
| rbd rm | 删除块设备映像 |
| rbd ls  | 列出 rbd 存储池中的块设备 |
| rbd info  | 查看块设备信息 |
| rbd diff  | 可以统计 rbd 使用量 |
| rbd map  | 映射块设备 |
| rbd showmapped  | 查看已映射块设备 |
| rbd unmap | 取消映射 |
| rbd remove  | 删除块设备 |
| rbd resize  | 更改块设备的大小 |


# RBD配置操作
## RBD挂载到操作系统
1、创建rbd使用的pool
```
# ceph osd pool create rbd  32 32
# ceph osd pool application enable rbd rbd 

```
2、创建一个块设备
```
# rbd create --size 10240 image01 
```
3、查看块设备
```
# rbd ls
# rbd info image01
```
4、将块设备映射到系统内核
```
# rbd map image01 
```
5、禁用当前系统内核不支持的feature
```
# rbd feature disable foo_image exclusive-lock, object-map, fast-diff, deep-flatten
```
6、再次映射
```
# rbd map image01 
```
7、格式化块设备镜像
```
# mkfs.xfs /dev/rbd0
```
8、mount到本地
```
# mount /dev/rbd0 /mnt
# umount /mnt
```
9、取消块设备和内核映射
```
# rbd unmap image01 
```
10、删除RBD块设备
```
# rbd rm image01
```
## 快照配置
1、创建快照
```
rbd create --size 10240 image02
rbd snap create image02@image02_snap01
```
2、列出创建的快照
```
# rbd snap list image02
或
# rbd ls -l
```
3、查看快照详细信息
```
# rbd info image02@image02_snap01
```
4、克隆快照（快照必须处于被保护状态才能被克隆）
```
# rbd snap protect image02@image02_snap01
# rbd clone rbd/image02@image02_snap01 kube/image02_clone01
```
5、查看快照的children
```
# rbd children image02
```
6、去掉快照的parent
```
# rbd flatten kube/image02_clone01
```
7、恢复快照
```
# rbd snap rollback image02@image02_snap01
```
8、删除快照
```
# rbd snap unprotect image02@image02_snap01
# rbd snap remove image02@image02_snap01
```


## 导出导入RBD镜像
1、导出RBD镜像
```
# rbd export image02 /tmp/image02
```
2、导出RBD镜像
```
# rbd import /tmp/image02 rbd/image02 --image-format 2 
```
