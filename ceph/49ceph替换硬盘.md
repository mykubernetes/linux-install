# 替换osd数据磁盘

- 当集群规模比较大，磁盘出硬件故障是一个常态。为了维持集群规模稳定，必须及时的修复因硬盘故障停止的OSD。 因为Ceph采用了多个副本的策略，一般情况下，不需要恢复坏掉硬盘的数据。用一个新硬盘初始化一个OSD即可。操作步骤如下：
```
两种情况：
a. 如果磁盘坏掉osd会标记为down，默认300秒osd会被标记为out，数据会开始迁移。所以我们替换osd数据磁盘，确保数据迁移完成，集群状态是ok。
b. 如果磁盘将要损坏，但还没有坏，仍然是up&in的，则需要先把该osd 设置为out: ceph osd out osd.0,这样集群会把osd.0的数据 rebalancing and copying到其他机器上去。直到整个集群编程active+clean，再进行后续操作
1. 关闭 osd.0的进程
systemctl stop ceph-osd@0
2. 删除旧osd信息(osd.0为例)：
ceph osd crush remove osd.0
ceph auth del osd.0
ceph osd rm 0
3. 创建新osd
a. ceph osd create #会自动生成uuid和osd-number
b. ssh {new_osd_host}
c. sudo mkdir /var/lib/ceph/osd/ceph-{osd-number}  #上一步生成的osd-number
d. 分区 通过parted把osd的磁盘分区为一个分区
e. sudo mkfs -t xfs /dev/{drive} # 上一步分区
f. sudo mount /dev/{sdx} /var/lib/ceph/osd/ceph-{osd-number}
g. ceph-osd -i {osd-number} --mkfs --mkkey   # 初始化osd数据目录
目录必须为空
h. ceph auth add osd.{osd-number} osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-{osd-number}/keyring #注册认证key
i. ceph osd crush add osd.{osd-number}# 添加osd到crush map，则该osd可以接受数据了，这个时候osd的状态为 down & in。ceph osd crush add osd.0 1.0 host=bj-yh-ceph-node2
j. systemctl start ceph-osd@{osd-number} # 启动osd进程，数据会rebalancing and migrating 到新的osd上
```

# 替换ssd日志磁盘

- 由于我们使用过程中，一块ssd分4个区，给4个osd使用，所以如果ssd日志磁盘坏掉，需要给对应的osd都要操作
```
1. 设置OSD状态为noout，防止数据重新平衡
ceph osd set noout
2. 停止osd进程
ssh {ssd所在节点}
systemctl stop ceph-osd@x  #ssd所对应的osds
3. 日志数据落盘到数据盘
ceph-osd -i {osd-number} --flush-journal #该ssd日志分区所对应的所有osd-number
4. 删除日志链接
rm -rf /var/lib/ceph/osd/{osd-number}/journal # #该ssd日志分区所对应的所有osd-number
5. 创建日志链接
ln -s /dev/disk/by-partuuid/{uuid} /var/lib/ceph/osd/ceph-{osd-number}/journal # 注意别把使用中的分区给绑定错了
chown ceph:ceph /var/lib/ceph/osd/ceph-{osd-number}/journal
echo {uuid} > /var/lib/ceph/osd/ceph-{osd-number}/journal_uuid  #前面/dev/disk/by-partuuid/{uuid} uuid
6. 创建日志
ceph-osd -i {osd-number} --mkjournal
7. 启动osd进程
systemctl start ceph-osd@{osd-number}
如果所有osd进程都起来了
8. 去除noout的标记
ceph osd set noout
```
