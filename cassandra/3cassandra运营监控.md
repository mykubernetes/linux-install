启动及验证
---
```
先在种子节点，然后在其它节点上执行如下命令
https://thelastpickle.com/blog/,
https://cassandra.apache.org/
https://docs.datastax.com/en/dse-trblshoot/doc/troubleshooting/trblLinuxTOC.html
 
 
 1、启动： cassandra -R
 
 2、验证：
      检查日志：
         如果启动过程中没有什么异常的话，那么现在cassandra就已经启动成功了
         如果没有报什么奇奇怪怪的ERROR，然后看到Node /x.x.x.x state jump to NORMAL,这样cassandra就算安装成功了。
      查看集群状态：
          nodetool status 
          UN：表示该节点状态，运行中的。
          DN：宕机
          UL：离线中
```

监控
---
```
a、主机指标监控：CPU、内存、磁盘空间、IO等
 
b、IO监控
iostat -x -t 10
关注： %iowait 超过1表示有IO等待；
await(平均等待毫秒数) SSD < 10ms, 磁盘 < 200ms

c、内存
free -h:可用内存
nodetool info:cassandra 内存使用情况
TOP -c:内存使用

d、磁盘
df -h
du -sh

e、cassandra专项监控
nodetool status                    # 集群基本信息 
nodetool netstats                  # 网络链接操作的统计
nodetool tablestats                # 表上的统计信息
nodetool proxyhistograms           # 网络耗时直方图
nodetool tpstats                   # 线程统计
nodetool compactionstats           # 压缩情况
nodetool tablehistograms           # 表直方图
      
f、清理数据集（先确定数据是否不再需要，不需要再清理）
清理snapshot，每个节点依次执行下面命令
./nodetool  clearsnapshot
 清理空目录：递归清理
rmdir -pv tree1/tree2/tree3
rmdir -pv mon_*/*/*

g、SSTablemetadata工具
列出所有SSTABLE详细信息
进入SSTABLE相关目录，使用如下命令
for f in *Data.db; do meta=$(sudo sstablemetadata $f); echo -e "Max:" $(date --date=@$(echo "$meta" | grep Maximum\ time | cut -d" "  -f3| cut -c 1-10) '+%m/%d/%Y') "Min:" $(date --date=@$(echo "$meta" | grep Minimum\ time | cut -d" "  -f3| cut -c 1-10) '+%m/%d/%Y') $(echo "$meta" | grep droppable) ' \t ' $(ls -lh $f | awk '{print $5" "$6" "$7" "$8" "$9}'); done | sort
        
查看数据分布在哪个节点
nodetool Getendpoints [Keyspace][Table][Primary Key]
如：nodetool Getendpoints myspace mytable  11221123121          
      
查看数据分布在哪个sstable上
nodetool GetSSTables [Keyspace] [Table] [Primary Key]

h、垃圾回收暂停
Garbage collection pauses
查看debug.log 或 system.log 如下日志，停顿超过1s或1s内停顿多次都不正常
INFO [ScheduledTasks:1]  2018-05-09 18:33:27,881 GCInspector.java (line 122) GC for ConcurrentMarkSweep:  1883 ms for 3 collections, 2123234211used; max is 120233443343
INFO [ScheduledTasks:1]  2018-05-09 17:32:17,181 GCInspector.java (line 122) GC for ParNew:  9811 ms for 8 collections, 21324234211used; max is 120237443343
```
