```
ceph df   #查看集群使用状态
ceph health detail  #显示集群健康状态
rados -p [pool_name] ls #缓存对象
rbd -p [pool_name] map [img_name]  #挂载镜像
rbd -p [pool_name] unmap [img_name] #卸载RBD镜像
rbd ls -p  [pool_name] -l   #查看存储池内RBD镜像
rbd ls [pool_name]  #查看RBD镜像
rbd rm --pool [pool_name]--image [img_name] # 删除RBD镜像
rbd create [img_name] --size nM|G|T --pool [pool_name] --image-format 2 --image-feature layering # 创建RBD镜像
rbd status --pool [pool_name] --image [img_name] # 查看缓存状态
rbd status {pool-name}/{image-name} #缓存状态
rbd info [pool-name/]image-name #检索 RBD 镜像详情
rbd du [pool-name/]image-name #检索 RBD 镜像的调配磁盘使用量和实际磁盘使用量。
rbd resize [pool-name/]image-name --size nM|G|T #调整 RBD 镜像大小
rbd rm [pool-name/]image-name #删除 RBD 镜像
rbd cp [pool-name/]src-image-name [pool-name/] tgt-image-name #复制 RBD 镜像
rbd mv [pool-name/]src-image-name [pool-name/] new-image-name #重命名 RBD 镜像
rbd trash mv [pool-name/]image-name #将 RBD 镜像移到回收站中
rbd trash rm [pool-name/]image-name #从回收站中删除 RBD 镜像
rbd trash restore [pool-name/]image-name #从回收站中恢复 RBD 镜像
rbd trash ls [pool-name] #列出回收站中的所有 RBD 镜像
rbd fs fail  <fs_name> #允许快速删除文件系统（以进行测试）或快速关闭文件系统和MDS守护程序
ceph fs set <fs_name> joinable false #允许快速删除文件系统（以进行测试）或快速关闭文件系统和MDS守护程序
ceph fs set <fs_name> joinable true #恢复cephfs集群


ceph osd pool create <poolname> pg_num pgp_num {replicated|erasure} #创建存储池

ceph osd pool ls [detail] #列出存储池

ceph osd pool lspools #列出存储池

ceph osd pool stats [pool name] #获取存储池的时间信息

ceph osd pool old-name new-name #重命名存储池

ceph osd pool get [pool name] size #获取存储池对象副本数默认为一主两倍3副本

ceph osd pool get [pool name] min_size #存储池最下副本数

ceph osd pool get [pool name] pg_num #查看当前pg数量

ceph osd pool get [pool name] crush_rule #设置crush算法规则，默认为副本池(replicated_rule)

ceph osd pool get [pool name] nodelete  #控制是否可以删除。默认可以

ceph osd pool get [pool name] nopgchange  #控制是否可更新存储池的pg num 和pgp num

ceph osd pool set [pool name] pg_num 64 #修改制定pool的pg数量

ceph osd pool get [pool name] nosizechange #控制是否可以更改存储池的大小，默认允许修改

ceph osd pool set-quota [pool name] #获取存储池配额信息

ceph osd pool set-quota [pool name] max_bytes   21474836480 #设置存储池最大空间，单位字节

ceph osd pool set-quota [pool name] max_objects 1000 #设置存储池最大对象数量

ceph osd pool get [pool name] noscrub #查看当前是否关闭轻量扫描数据，默认值为false，不关闭，开启

ceph osd pool set [pool name] noscrub true #修改制定的pool轻量扫描为true，不执行轻量扫描

ceph osd pool set [pool name] nodeep-scrub #查看当前是否关闭深度扫描数据，默认值为false，不关闭，开启

ceph osd pool set [pool name] nodeep-scrub true #修改制定pool的深度扫描测量为true,即不执行深度扫描

ceph osd pool get [pool name] scrub_min_interval #查看存储池的最小整理时间间隔，默认值没有设置，可以通过配置文件中的osd_scrub_min_interval参数指定间隔时间。

ceph osd pool get [pool name] scrub_max_interval #查看存储池的最大整理时间间隔，默认值没有设置，可以通过配置文件中的osd_scrub_max_interval参数指定。

ceph osd pool get [pool name] deep_scrub_interval #查看存储池的深层整理时间间隔，默认值没有设置，可以通过配置文件中的osd_deep_scrub_interval参数指定。

rados df #显示存储池的用量信息


ceph osd pool mksnap [pool name] [snap name] #创建存储池快照

rados -p [pool name] mksnap [snap name]  #创建存储池快照

rados -p [pool name] lssnap # 列出存储池快照

radps rollback  -p [pool name] [object name] [snap name] #通过快照还原某个文件

ceph osd pool rnsnap [pool name] [snap name] # 删除存储池快照

rados -p [pool name ] rmsnap [snap name] # 删除存储池快照
```
