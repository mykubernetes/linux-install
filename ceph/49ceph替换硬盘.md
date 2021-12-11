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

# ceph 更换日志盘详解

现在，通常的部署情况是ssd作为日志分区，sas或者hdd磁盘作为osd；为了节省成本，一块ssd划分多个区给多个osd服务使用,所以这里假设ssd故障，如何更换ssd磁盘

大家都知道，ceph的日志是基于事务的，为了确保数据完整，所以在更新ssd的时候，需要先把日志里的数据下刷存储到osd服务。

而且日志在下刷的时候，osd是停止的，拒绝从外部新的写入

1、首先，停止该ssd对应的所有osd服务
```
ceph osd set noout
systemctl stop ceph-osd@1 ceph-osd@2 ceph-osd@3 ceph-osd@4
```

2、然后，下刷日志到osd
```
ceph-osd -i id --flush-journal  ##-i:后面跟osd的id 1、2、3、4
```
3、删除每个osd(1、2、3、4)的日志目录
```
rm -rf /var/lib/ceph/osd/ceph-id/journal   ##id为1、2、3、4
```

4、拔掉老的ssd，插上新的ssd，然后同样分为4个分区(根据实际需求),把各分区分别软连到个osd/var/lib/ceph/osd/ceph-id/journal
```
ln -s /dev/disk/by-partuuid/0a9b2162-3f95-42b8-b041-6dfdd54354a7 /var/lib/cpeh/osd/ceph-1/journal
echo a9b2162-3f95-42b8-b041-6dfdd54354a7 > /var/lib/cpeh/osd/ceph-1/journal_uuid

ln -s /dev/disk/by-partuuid/370e4aa8-3406-46de-9c89-6e0e46021e72 /var/lib/cpeh/osd/ceph-2/journal
echo 370e4aa8-3406-46de-9c89-6e0e46021e72 > /var/lib/cpeh/osd/ceph-2/journal_uuid

ln -s /dev/disk/by-partuuid/2e2c88fd-15cc-44a0-9eb7-57d4c2ffc9b3 /var/lib/cpeh/osd/ceph-3/journal
echo e2c88fd-15cc-44a0-9eb7-57d4c2ffc9b3 > /var/lib/cpeh/osd/ceph-3/journal_uuid

ln -s /dev/disk/by-partuuid/2d9c471f-4e0f-469b-add5-b599f2441a9a /var/lib/cpeh/osd/ceph-4/journal
echo 2d9c471f-4e0f-469b-add5-b599f2441a9a > /var/lib/cpeh/osd/ceph-4/journal_uuid
```

5、修改每个目录的组
```
chown ceph:ceph /var/lib/cpeh/osd/ceph-1/journal
chown ceph:ceph /var/lib/cpeh/osd/ceph-2/journal
chown ceph:ceph /var/lib/cpeh/osd/ceph-3/journal
chown ceph:ceph /var/lib/cpeh/osd/ceph-4/journal
```

6、为各个osd创建日志
```
ceph-osd -i 1 --mkjournal
ceph-osd -i 2 --mkjournal
ceph-osd -i 3 --mkjournal
ceph-osd -i 4 --mkjournal
```

7、启动osd服务
```
systemctl start ceph-osd@1 ceph-osd@2 ceph-osd@3 ceph-osd@4 
```

8、删除 noout 标记
```
ceph osd unset noout
```

9、最后查看集群状态是否ok
