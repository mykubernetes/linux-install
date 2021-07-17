PG介绍
---
PG, Placement Groups。CRUSH先将数据分解成一组对象，然后根据对象名称、复制级别和系统中的PG数等信息执行散列操作，再将结果生成PG ID。可以将PG看做一个逻辑容器，这个容器包含多个对象，同时这个逻辑对象映射之多个OSD上。
如果没有PG，在成千上万个OSD上管理和跟踪数百万计的对象的复制和传播是相当困难的。没有PG这一层，管理海量的对象所消耗的计算资源也是不可想象的。建议每个OSD上配置50~100个PG。
计算PG数

官方推荐如下：
- Less than 5 OSDs set pg_num to 128
- Between 5 and 10 OSDs set pg_num to 512
- Between 10 and 50 OSDs set pg_num to 1024
- If you have more than 50 OSDs, you need to understand the tradeoffs and how to calculate the pu_num value by yourself
- For calculation pg_num value by yourseif please take help of pgcalc tool

Ceph集群中的PG总数：
```
PG总数 = (OSD总数 * 100) / 最大副本数
结果必须舍入到最接近的2的N次方幂的值。

Ceph集群中每个pool中的PG总数：
存储池PG总数 = (OSD总数 * 100 / 最大副本数) / 池数
```
平衡每个存储池中的PG数和每个OSD中的PG数对于降低OSD的方差、避免速度缓慢的恢复再平衡进程是相当重要的。

修改PG和PGP
---
PGP是为了实现定位而设置的PG，它的值应该和PG的总数(即pg_num)保持一致。对于Ceph的一个pool而言，如果增加pg_num，还应该调整pgp_num为同样的值，这样集群才可以开始再平衡。
参数pg_num定义了PG的数量，PG映射至OSD。当任意pool的PG数增加时，PG依然保持和源OSD的映射。直至目前，Ceph还未开始再平衡。此时，增加pgp_num的值，PG才开始从源OSD迁移至其他的OSD，正式开始再平衡。PGP，Placement Groups of Placement。

获取现有的PG数和PGP数值：
```
ceph osd pool get data pg_num

ceph osd pool get data pgp_num
```

检查存储池的副本数
```
ceph osd dump|grep -i size
```

计算pg_num和pgp_num
```
# pg_num calculation
pg_num = (num_osds * 100) / num_copies
num_up = pow(2, int(log(pg_num,2) + 0.5))
num_down = pow(2, int(log(pg_num,2)))
if abs(pg_num - num_up) <= abs(pg_num - num_down):
    pg_num = num_up
else:
    pg_num = num_down
pgp_num = pg_num
```

修改存储池的PG和PGP
```
ceph osd pool set data pg_num 

ceph osd pool set data pgp_num
```
例子：
```
ceph osd pool ls
ceph osd pool set .rgw.root pg_num 16
ceph osd pool set .rgw.root pgp_num 16
```
