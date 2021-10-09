# PG与OSD映射调整

PG 是一组对象的逻辑集合，通过复制它到不同的 OSD 上来提供存储系统的可靠性。 根据 Ceph 池的复制级别，每个 PG 的数据会被复制并分发到 Ceph集群的多个 OSD上。 可以将 PG 看成一个逻辑容器，这个容器包含多个对象，同时这个逻辑容器被映射到多个 OSD上。

1、用ceph osd tree命令查看ceph集群，会发现有weight和reweight两个值
```
# ceph osd tree
ID WEIGHT   TYPE NAME                  UP/DOWN REWEIGHT PRIMARY-AFFINITY 
-3 48.59967 root oss-uat                                                 
-2 16.19989     rack rack-01                                             
-1 16.19989         host ceph001-node1                                   
 0  1.79999             osd.0               up  1.00000          1.00000 
 1  1.79999             osd.1               up  1.00000          1.00000 
 2  1.79999             osd.2               up  1.00000          1.00000 
 3  1.79999             osd.3               up  1.00000          1.00000 
 4  1.79999             osd.4               up  1.00000          1.00000 
 5  1.79999             osd.5               up  1.00000          1.00000 
 6  1.79999             osd.6               up  1.00000          1.00000 
 7  1.79999             osd.7               up  1.00000          1.00000 
 8  1.79999             osd.8               up  1.00000          1.00000 
-5 16.19989     rack rack-02                                             
-4 16.19989         host ceph001-node2                                   
10  1.79999             osd.10              up  1.00000          1.00000 
11  1.79999             osd.11              up  1.00000          1.00000 
12  1.79999             osd.12              up  1.00000          1.00000 
13  1.79999             osd.13              up  1.00000          1.00000 
14  1.79999             osd.14              up  1.00000          1.00000 
15  1.79999             osd.15              up  1.00000          1.00000 
16  1.79999             osd.16              up  1.00000          1.00000 
17  1.79999             osd.17              up  1.00000          1.00000 
 9  1.79999             osd.9               up  1.00000          1.00000 
-7 16.19989     rack rack-03                                             
-6 16.19989         host ceph001-node3                                   
18  1.79999             osd.18              up  1.00000          1.00000 
19  1.79999             osd.19              up  1.00000          1.00000 
20  1.79999             osd.20              up  1.00000          1.00000 
21  1.79999             osd.21              up  1.00000          1.00000 
22  1.79999             osd.22              up  1.00000          1.00000 
23  1.79999             osd.23              up  1.00000          1.00000 
24  1.79999             osd.24              up  1.00000          1.00000 
25  1.79999             osd.25              up  1.00000          1.00000 
26  1.79999             osd.26              up  1.00000          1.00000 
```

2、查看当前状态
```
# ceph osd df 
ID  CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA     OMAP     META     AVAIL    %USE  VAR   PGS  STATUS
 0    hdd  0.01949   1.00000   20 GiB  102 MiB   81 MiB   14 KiB   21 MiB   20 GiB  0.50  0.86   89      up
 1    hdd  0.01949   1.00000   20 GiB  130 MiB   95 MiB   27 KiB   35 MiB   20 GiB  0.63  1.10   98      up
 2    hdd  0.01949   1.00000   20 GiB  129 MiB   96 MiB    6 KiB   34 MiB   20 GiB  0.63  1.09   83      up
 3    hdd  0.01949   1.00000   20 GiB  106 MiB   71 MiB   13 KiB   35 MiB   20 GiB  0.52  0.90   87      up
 4    hdd  0.01949   1.00000   20 GiB  128 MiB   94 MiB    8 KiB   33 MiB   20 GiB  0.62  1.08   91      up
 5    hdd  0.01949   1.00000   20 GiB  123 MiB   88 MiB   23 KiB   35 MiB   20 GiB  0.60  1.04   91      up
 6    hdd  0.01949   1.00000   20 GiB  121 MiB   86 MiB    8 KiB   35 MiB   20 GiB  0.59  1.02   84      up
 7    hdd  0.01949   1.00000   20 GiB  119 MiB   91 MiB   18 KiB   28 MiB   20 GiB  0.58  1.00   95      up
 8    hdd  0.01949   1.00000   20 GiB   72 MiB   43 MiB   18 KiB   29 MiB   20 GiB  0.35  0.61   91      up
 9    hdd  0.01949   1.00000   20 GiB  129 MiB   93 MiB    6 KiB   37 MiB   20 GiB  0.63  1.09   92      up
10    hdd  0.01949   1.00000   20 GiB  141 MiB  111 MiB   11 KiB   30 MiB   20 GiB  0.69  1.19  106      up
11    hdd  0.01949   1.00000   20 GiB  120 MiB   87 MiB   17 KiB   33 MiB   20 GiB  0.59  1.01  100      up
                       TOTAL  240 GiB  1.4 GiB  1.0 GiB  175 KiB  384 MiB  239 GiB  0.58                   
MIN/MAX VAR: 0.61/1.19  STDDEV: 0.08
```

3、修改WEIGHT并验证

- 修改完会立即更新，速度取决于数据的大小，根据算法进行分配
- `crush weight`权重和磁盘的容量有关，一般1T值为1.000,500G就是0.5。其和磁盘的容量有关系，不因磁盘可用空间的减少而变化。
```
# ceph osd crush reweight osd.10 1.5

# ceph osd df 
ID  CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA     OMAP     META     AVAIL    %USE  VAR   PGS  STATUS
 0    hdd  0.01949   1.00000   20 GiB  102 MiB   81 MiB   14 KiB   21 MiB   20 GiB  0.50  0.86   87      up
 1    hdd  0.01949   1.00000   20 GiB  134 MiB   95 MiB   27 KiB   39 MiB   20 GiB  0.65  1.13   96      up
 2    hdd  0.01949   1.00000   20 GiB  133 MiB   96 MiB    6 KiB   38 MiB   20 GiB  0.65  1.12   85      up
 3    hdd  0.01949   1.00000   20 GiB  111 MiB   71 MiB   13 KiB   40 MiB   20 GiB  0.54  0.94   86      up
 4    hdd  0.01949   1.00000   20 GiB  128 MiB   94 MiB    8 KiB   33 MiB   20 GiB  0.62  1.08   92      up
 5    hdd  0.01949   1.00000   20 GiB  123 MiB   88 MiB   23 KiB   35 MiB   20 GiB  0.60  1.04   92      up
 6    hdd  0.01949   1.00000   20 GiB  121 MiB   86 MiB    8 KiB   35 MiB   20 GiB  0.59  1.02   82      up
 7    hdd  0.01949   1.00000   20 GiB  119 MiB   91 MiB   18 KiB   28 MiB   20 GiB  0.58  1.00   92      up
 8    hdd  0.01949   1.00000   20 GiB   72 MiB   43 MiB   18 KiB   29 MiB   20 GiB  0.35  0.61   92      up
 9    hdd  0.01949   1.00000   20 GiB  114 MiB   93 MiB    6 KiB   21 MiB   20 GiB  0.56  0.96   93      up
10    hdd  1.50000   1.00000   20 GiB  141 MiB  111 MiB   11 KiB   31 MiB   20 GiB  0.69  1.19  106      up
11    hdd  0.01949   1.00000   20 GiB  125 MiB   87 MiB   17 KiB   37 MiB   20 GiB  0.61  1.05   99      up
                       TOTAL  240 GiB  1.4 GiB  1.0 GiB  175 KiB  387 MiB  239 GiB  0.58 
```

4、修改REWEIGHT并验证
- REWEIGHT的值范围在0~1之间，值越小PG越小
```
# ceph osd reweight 9 0.6
reweighted osd.9 to 0.6 (9999)

# ceph osd df 
ID  CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA     OMAP     META     AVAIL    %USE  VAR   PGS  STATUS
 0    hdd  0.01949   1.00000   20 GiB  226 MiB   96 MiB   14 KiB  130 MiB   20 GiB  1.10  0.89   87      up
 1    hdd  0.01949   1.00000   20 GiB  213 MiB   98 MiB   27 KiB  115 MiB   20 GiB  1.04  0.84   97      up
 2    hdd  0.01949   1.00000   20 GiB  303 MiB  154 MiB    6 KiB  149 MiB   20 GiB  1.48  1.20   82      up
 3    hdd  0.01949   1.00000   20 GiB  304 MiB  137 MiB   13 KiB  167 MiB   20 GiB  1.48  1.20   90      up
 4    hdd  0.01949   1.00000   20 GiB  170 MiB   69 MiB    8 KiB  101 MiB   20 GiB  0.83  0.67   83      up
 5    hdd  0.01949   1.00000   20 GiB  248 MiB  123 MiB   23 KiB  125 MiB   20 GiB  1.21  0.98   86      up
 6    hdd  0.01949   1.00000   20 GiB  232 MiB   99 MiB    8 KiB  133 MiB   20 GiB  1.13  0.92   88      up
 7    hdd  0.01949   1.00000   20 GiB  301 MiB  154 MiB   18 KiB  147 MiB   20 GiB  1.47  1.19   90      up
 8    hdd  0.01949   1.00000   20 GiB  145 MiB   42 MiB   18 KiB  103 MiB   20 GiB  0.71  0.57   89      up
 9    hdd  0.01949   0.59999   20 GiB  199 MiB   91 MiB    6 KiB  108 MiB   20 GiB  0.97  0.79   54      up
10    hdd  0.01949   1.00000   20 GiB  544 MiB  303 MiB   11 KiB  240 MiB   19 GiB  2.66  2.15  144      up
11    hdd  0.01949   1.00000   20 GiB  145 MiB   70 MiB   17 KiB   75 MiB   20 GiB  0.71  0.57   96      up
                       TOTAL  240 GiB  3.0 GiB  1.4 GiB  175 KiB  1.6 GiB  237 GiB  1.23 
```

> 需要注意的是，这个参数不会持久化，当该osd out时，reweight的值为0， 当该osd重新up时，该值会恢复到1，而不会保持之前修改过的值。

> 当`reweight`改变时，weight的值并不会变化。它影响PG到OSD的映射关系。`Reweight`参数的目的，由于ceph的CRUSH算法随机分配，是概率统计意义上的数据均衡，当小规模集群pg数量相对较少时，会产生一些不均匀的情况，通过调整`reweight`参数，达到数据均衡。


