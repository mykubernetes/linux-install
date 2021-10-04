ceph创建存储池需要pg数和pgp数的两个参数

PG (Placement Group)，pg是一个虚拟的概念，用于存放object，PGP(Placement Group for Placement purpose)，相当于是pg存放的一种osd排列组合。举个例子：假设集群有3个osd，即osd1，osd2，osd3，副本数为2，如果pgp=1，那么pg存放的osd的组合就有一种，可能是[osd1，osd2]，那么所有的pg主从副本都会存放到osd1和osd2上；如果pgp=2，那么其osd组合可能就两种，可能是[osd1,osd2]和[osd1,osd3]，pg的主从副本会落在[osd1,osd2]或者[osd1,osd3]中，和我们数学中的排列组合很像，所以pg是存放对象的归属组是一种虚拟概念，pgp就是pg对应的osd排列组合。一般情况下，存储池的pg和pgp的数量设置相等。


验证
---

1、准备是3个测试环境节点，每个节点3个osd，首先创建以个名为pool_1的存储池，包含6个pg
```
[root@node1 ~]# ceph osd pool create pool_1 6 6
pool 'pool_1' created

[root@node1 ~]# ceph osd pool set pool_1 size 2   #设置存储池副本数为2
set pool 2 size to 2
```

2、使用ceph pg dump pgs查看pg的分布：因为存储池为双副本，可以看到每个pg会分布在两个osd上，整个集群有9个osd，按照排列组合会有很多种，此时pgp=6，就会选择这些组合中的6种组合来供pg存放，可以看到最右侧的6中组合均不重复。
```
[root@node1 ~]#  ceph pg dump pgs |grep active |awk '{print $1,$2,$15}'
2.5 0 [1,2]
2.4 0 [6,0]
2.3 0 [5,2]
2.2 0 [5,6]
2.1 0 [7,8]
2.0 0 [0,6]
```

3、使用ceph自带的bench工具写入数据，来观察pg内的对象有没有移动
```
rados -p pool_1 bench 20 write --no-cleanu
```

4、再次查询结果如下：第2列为每个pg的对象数，第3列为pg所在的osd，可以看到存储创建好了pg设置固定了其osd的分布不会随着对象的增加而改变。
```
[root@node1 ~]#  ceph pg dump pgs |grep active |awk '{print $1,$2,$15}'
2.5 178 [1,2]
2.4 162 [6,0]
2.3 368 [5,2]
2.2 308 [5,6]
2.1 176 [7,8]
2.0 166 [0,6]
```

5、增加PG数，改变下pg数，将pg数扩大到12
```
[root@node1 ~]# ceph osd pool set pool_1 pg_num 12
set pool 2 pg_num to 12
```

6、再次查看存储池pg分布结果如下
```
[root@node1 ~]# ceph pg dump pgs |grep active |awk '{print $1,$2,$15}'
2.b 96 [5,2]
2.a 73 [5,6]
2.0 76 [0,6]
2.1 88 [7,8]
2.2 80 [5,6]
2.9 88 [7,8]
2.3 91 [5,2]
2.4 162 [6,0]
2.5 178 [1,2]
2.6 103 [5,6]
2.7 181 [5,2]
2.8 90 [0,6]
```
通过上面的测试可以看到，新增加的pg数还是基于pgp=6的排列组合，并没有出现新的排列组合，因为我们当前的存储池的pgp是6，那么双副本2个osd的组合就是6个，因为当前的pg是12，分布只能从6中组合里面选择，所以会有重复的组合。

结论：增加PG会引起PG内的对象进行分裂，也就是说在OSD上新建了PG目录，然后进行部分对象迁移的操作。即PG改变会引起数据迁移。

7、增加PGP，将PGP从6调整为12：
```
[root@node1 ~]# ceph osd pool set pool_1 pgp_num 12
set pool 2 pgp_num to 12
     
[root@node1 ~]# ceph pg dump pgs |grep active |awk '{print $1,$2,$15}'
2.b 96 [8,0]
2.a 73 [2,4]
2.0 76 [0,6]
2.1 88 [7,8]
2.2 80 [5,6]
2.9 88 [4,8]
2.3 91 [5,2]
2.4 162 [6,0]
2.5 178 [1,2]
2.6 155 [8,4]
2.7 181 [1,2]
2.8 90 [0,7]
```
可以看到pg内的对象数并没有发生改变，而pg所在的osd的对应关系发生了改变，可以看到最初pg=6 pgp=6的时候前6个pg的分布并没有发生变化，变化的都是后面增加的pg，也就是将重复的pg分布进行新分布，这里并不是随机打散，而是尽量做小改动的重新分布，这就是所谓的一致性哈希原理。

结论：调整PGP不会引起PG内的对象的分裂，但是会引起PG的分布变动。

总结
---
- 1. PG是指定存储池存储对象的归属组有多少个，PGP是存储池PG的OSD分布组合个数
- 2. PG的增加会引起PG内的数据进行迁移，迁移到不同的OSD上新生成的PG中
- 3. PGP的增加会引起部分PG的分布变化，但是不会引起PG内对象的变动。
