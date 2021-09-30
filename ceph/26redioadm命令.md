
```
ceph -v   查看版本
radosgw-admin user list    //查看用户列表，存储网关节点上执行
radosgw-admin bucket stats --uid 100004603027  //查看某个用户下面桶的状态，存储网关节点上执行
radosgw-admin user info --uid 100004603175   //查看某个租户的配额信息，数据库里没有此信息
radosgw-admin bucket list    //列出存储桶，存储网关节点上执行
radosgw-admin bucket list --uid=*** //列出属于某个uin的存储桶有哪些，存储网关节点上执行
radosgw-admin bucket stats --bucket=cbssnapbox-1255000337  //查看桶状态
radosgw-admin bucket unindex --bucket=桶名称    //删除存储桶的索引
radosgw-admin bucket delete disable --bucket=桶名称     //将存储桶置为不可删除


ceph osd df     //查看osd情况，容量等
ceph osd reweight <osd-id> 0.95        //调整osd的wight（权重）为0.95，默认为1
##关闭数据校验
ceph osd set noscrub
ceph osd set nodeep-scrub
##打开校验
ceph osd unset noscrub
ceph osd unset nodeep-scrub

ceph -s       //查看集群状态
ceph osd tree     //查看osd目录树，REWEIGHT
ceph df detail      //查看磁盘信息
ceph osd pool ls detail     //告警服务器上查看pool信息
ceph pg dump             //查看pg信息
```
