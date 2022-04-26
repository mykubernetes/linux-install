1. OSD概念

OSD：Object Storage Device，主要负责响应客户端请求返回具体数据的守护进程，一般一个集群会有多个OSD，每一块盘都会对应一个OSD。

2. OSD 状态
```
[root@data1 ~]# ceph osd stat
4 osds: 3 up (since 23m), 3 in (since 13m); epoch: e345
```
OSD状态说明：
- a. 集群内（in）
- b. 集群外（out）
- c. 活着且在运行（up）
- d. 挂了且不再运行（down）

正常情况下OSD的状态是up in状态，如果down掉OSD，它的状态会变为down in，等待数据均衡完成后osd变为down out状态，Ceph 会把其归置组迁移到其他OSD， CRUSH 就不会再分配归置组给它。

3. 查看OSD的状态
```
# 查看集群的osd状态
# 查看指定osd的状态：ceph osd dump 3
 
[root@node1 ~]# ceph osd dump
epoch 242
fsid a1001d7b-e11e-48b5-9d18-759aeb238b21
created 2020-05-25 15:25:44.802972
modified 2020-05-26 13:22:00.626733
flags sortbitwise,recovery_deletes,purged_snapdirs,pglog_hardlimit
crush_version 23
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.85
require_min_compat_client luminous
min_compat_client luminous
require_osd_release nautilus
pool 8 'pool' replicated size 2 min_size 1 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 autoscale_mode warn last_change 60 flags hashpspool,selfmanaged_snaps max_bytes 214748364800 stripe_width 0 application rbd
	removed_snaps [1~3]
max_osd 4
osd.0 up   in  weight 1 up_from 231 up_thru 235 down_at 230 last_clean_interval [13,228) [v2:192.168.102.21:6800/1518,v1:192.168.102.21:6801/1518] [v2:192.168.102.21:6802/1518,v1:192.168.102.21:6803/1518] exists,up 23438b52-b147-456e-8368-7fcb71daf267
osd.1 up   in  weight 1 up_from 229 up_thru 235 down_at 227 last_clean_interval [13,226) [v2:192.168.102.19:6800/1517,v1:192.168.102.19:6801/1517] [v2:192.168.102.19:6802/1517,v1:192.168.102.19:6803/1517] exists,up f66ea32b-bc4a-4806-92bd-958b6f291676
osd.2 up   in  weight 1 up_from 235 up_thru 235 down_at 228 last_clean_interval [13,227) [v2:192.168.102.20:6800/1501,v1:192.168.102.20:6801/1501] [v2:192.168.102.20:6802/1501,v1:192.168.102.20:6803/1501] exists,up 76ca3ce8-5f01-4272-835b-796881f27f8a
osd.3 down out weight 0 up_from 0 up_thru 0 down_at 0 last_clean_interval [0,0)   exists,new
```

4. 查看OSD目录树
```
[root@node1 ~]# ceph osd tree
ID  CLASS WEIGHT  TYPE NAME             STATUS REWEIGHT PRI-AFF 
 -1       0.78119 root default                                  
 -2       0.78119     rack rack                                 
-11       0.19530         host node1                         
  3   ssd 0.19530             osd.3       down        0 1.00000 
 -3       0.19530         host node2                         
  1   ssd 0.19530             osd.1         up  1.00000 1.00000 
 -4       0.19530         host node3                         
  2   ssd 0.19530             osd.2         up  1.00000 1.00000 
 -5       0.19530         host node4                         
  0   ssd 0.19530             osd.0         up  1.00000 1.00000 
```

5. 下线OSD （down in）
```
#让ID为3的osd down 掉,此时该 osd 不接受读写请求,但 osd 还是存活的，即对应down in状态
 
[root@node1 ~]# ceph osd down 0
 
[root@node1 ~]# ceph osd tree
ID  CLASS WEIGHT  TYPE NAME             STATUS REWEIGHT PRI-AFF 
 -1       0.78119 root default                                  
 -2       0.78119     rack rack                                 
-11       0.19530         host node1                         
  3   ssd 0.19530             osd.3       down  1.00000 1.00000 
 -3       0.19530         host node2                         
  1   ssd 0.19530             osd.1         up  1.00000 1.00000 
 -4       0.19530         host node3                         
  2   ssd 0.19530             osd.2         up  1.00000 1.00000 
 -5       0.19530         host node4                         
  0   ssd 0.19530             osd.0         up  1.00000 1.00000 
```

5. 上线OSD (up in)
```
#让ID为3的osd up起来,此时该 osd 接受读写请求，对应up in状态
 
[root@node1 ~]# ceph osd up 3
 
[root@node1 ~]# ceph osd tree
ID  CLASS WEIGHT  TYPE NAME             STATUS REWEIGHT PRI-AFF 
 -1       0.78119 root default                                  
 -2       0.78119     rack rack                                 
-11       0.19530         host node1                         
  3   ssd 0.19530             osd.3       up  1.00000 1.00000 
 -3       0.19530         host node2                         
  1   ssd 0.19530             osd.1         up  1.00000 1.00000 
 -4       0.19530         host node3                         
  2   ssd 0.19530             osd.2         up  1.00000 1.00000 
 -5       0.19530         host node4                         
  0   ssd 0.19530             osd.0         up  1.00000 1.00000 
```

6. OSD踢出集群 (down out)
```
#让ID为3的osd踢出集群，对应down out状态
 
[root@node1 ~]# ceph osd out 3
```

7. OSD加入集群 (up in)
```
#让ID为3的osd加入集群，对应up in状态，即上线一个OSD
 
[root@node1 ~]# ceph osd in  3
```

8. 删除OSD (stop osd)
```
#在集群中删除一个OSD，需要先停止OSD，即stop osd
 
[root@node1 ~]# ceph osd rm osd.3
```

9. 从crush map中删除OSD
```
#在crush map中删除一个OSD
 
[root@node1 ~]# ceph osd crush rm osd.3
```

10. 删除host节点
```
#从集群中删除一个host节点
 
[root@node1 ~]# ceph osd crush rm node1
```

11. 查看最大OSD个数
```
#查看最大osd个数，默认最大是4osd节点
 
[root@node1 ~]# ceph osd getmaxosd
```

12. 设置最大OSD个数
```
#设置最大osd个数，默认最大是4osd节点
 
[root@node1 ~]# ceph osd setmaxosd 60
```

13. 设置OSD的crush权重
```
[root@node1 ~]# ceph osd crush reweight osd.3 3.0
```

14. 暂停OSD
```
#暂停后整个集群不再接受数据
 
[root@node1 ~]# ceph osd pause
```

15. 开启OSD
```
#开启后再次接收数据
 
[root@node1 ~]# ceph osd unpause
```

16. 查看OSD参数
```
[root@node1 ~]# ceph --admin-daemon /var/run/ceph/ceph-osd.1.asok config show
```

17. 查看延迟
```
# 主要解决单块磁盘问题，如果有问题及时剔除OSD。统计的是平均值
# commit_latency 表示从接收请求到设置commit状态的时间间隔
# apply_latency 表示从接收请求到设置apply状态的时间间隔
 
[root@node1 ~]# ceph osd perf
osd commit_latency(ms) apply_latency(ms) 
  3                  0                 0 
  2                  3                 3 
  1                  4                 4 
  0                  3                 3 
```

18. 主亲和性
```
# Ceph 客户端读写数据时，总是连接 acting set 里的主 OSD （如 [2, 3, 4] 中， osd.2 是主的）。
# 有时候某个 OSD 与其它的相比并不适合做主 OSD （比如其硬盘慢、或控制器慢），最大化硬件利用率时为防止性能瓶颈（特别是读操作），
# 你可以调整 OSD 的主亲和性，这样 CRUSH 就尽量不把它用作 acting set 里的主 OSD 了。
 
#ceph osd primary-affinity <osd-id> <weight>   
 
[root@node1 ~]#  ceph osd primary-affinity 2 1.0
 
#主亲和性默认为 1 （就是说此 OSD 可作为主 OSD ）。此值合法范围为 0-1 ，其中 0 意为此 OSD 不能用作主的，#1 意为 OSD 可用作主的；此权重小于 1 时， CRUSH 选择主 OSD 时选中它的可能性低
```

19. 查看osd对应盘的利用率
```
[root@node1 ~]# ceph osd df
ID CLASS WEIGHT  REWEIGHT SIZE    RAW USE DATA    OMAP    META     AVAIL   %USE  VAR  PGS STATUS 
 3   ssd 0.19530        0     0 B     0 B     0 B     0 B      0 B     0 B     0    0   0   down 
 1   ssd 0.19530  1.00000 198 GiB  43 GiB  39 GiB  39 KiB 1024 MiB 155 GiB 21.88 1.01 189     up 
 2   ssd 0.19530  1.00000 198 GiB  43 GiB  39 GiB  48 KiB 1024 MiB 155 GiB 21.60 1.00 191     up 
 0   ssd 0.19530  1.00000 198 GiB  42 GiB  38 GiB  41 KiB 1024 MiB 156 GiB 21.20 0.98 188     up 
                    TOTAL 594 GiB 128 GiB 116 GiB 130 KiB  3.0 GiB 466 GiB 21.56                 
MIN/MAX VAR: 0.98/1.01  STDDEV: 0.28
```

20. 提取crush图
```
# 提取最新crush图
# ceph osd getcrushmap -o {compiled-crushmap-filename}
 
[root@node1 ~]# ceph osd getcrushmap -o /tmp/crush
 
# 反编译crush图
# crushtool -d {compiled-crushmap-filename} -o {decompiled-crushmap-filename}
[root@node1 ~]# crushtool -d /tmp/crush -o /tmp/decompiled_crush
```

21. 注入crush图
```
#例如修改故障域host为osd，需要提取crush图，修改故障域，然后注入crush图
 
# 编译crush图
# crushtool -c {decompiled-crush-map-filename} -o {compiled-crush-map-filename}
 
[root@node1 ~]# crushtool -c /tmp/decompiled_crush -o /tmp/crush_new
 
#注入crush图
# ceph osd setcrushmap -i {compiled-crushmap-filename}
[root@node1 ~]# ceph osd setcrushmap -i /tmp/crush_new
```

22. 停止自动均衡
```
# 在集群维护过程中，如果某一个机架或者主机故障，而此时不想在停机维护osd过程中让crush自动均衡，提前设置为noout
 
[root@node1 ~]# ceph osd set noout
```

23. 取消停止自动均衡
```
# 取消停止自动均衡
 
[root@node1 ~]# ceph osd set noout
```

24. 删除OSD的痕迹
```
# 删除OSD的所有痕迹，包括其cephx加密秘钥，OSD ID 和crush map entry
 
 
ceph osd purge <osdname (id|osd.id)> {--yes-i-really-mean-it}
 
[root@node1 ~]# ceph osd purge 1 --yes-i-really-mean-it
 
此时osd已经不在集群中
 
[root@node1 ~]# ceph osd tree
 -1 0.04799 root default
 -2 0.00999     host luminous0
  5 0.00999         osd.5               up  1.00000          1.00000
 -3 0.01900     host luminous2
  0 0.00999         osd.0               up  1.00000          1.00000
  4 0.00999         osd.4               up  1.00000          1.00000
 -4 0.01900     host luminous1
  2 0.00999         osd.2               up  1.00000          1.00000
  3 0.00999         osd.3               up  1.00000          1.00000
  ```
