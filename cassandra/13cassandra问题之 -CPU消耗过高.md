现象

集群中有一台主机CPU消耗相比其它节点高一倍以上，检查了每个节点的数据流量也基本相同。
```
高CPU： xx.xx.139.48       50%
低CPU： xx.xx.137.249     20%
```


原因分析

集群经过4个小时的饱和压力测试，压测结束后，主机48的CPU一直维持在50%以上，其它节点都能回到正常的20%左右，因为CPU消耗高，首先要找出消耗CPU的任务，方法如下：
```
1、找出消耗CPU的进程
ps -ef | grep java
		
2、找出进程中CPU消耗最高的线程，假设进程ID为  2589
top -Hp 2589(PID)
	
3、找出CPU占比前面的线程ID，用如下命令转换成16进制
printf "%x\n" 2899(线程ID)
   	
4、查看线程堆栈信息
jstack 2589(进程ID) | grep b32(16进制线程ID) -A 30 
	
5、堆栈信息显示，大量的工作在
CompactionController.getPurgeEvaluator
查看源码，主要是对SSTABLE评估到期时间，看是否可以删除，因此怀疑compact出了问题
	
6、nodetool compactionstats -H
发现有很多的压缩任务积压，对一张大表moni_trace的压缩一直没有停止过
	
7、nodetool tablestats  myspace.moni_trace
发现sstable count : 12322个，明显不正常。问题定位出来了，是因为SSTABLE太多，系统花费太多的资源在扫描磁盘及压缩任务上。
```


解决方案

1、cassandra性能调优
```
a、加大压缩速度
nodetool setcompactionthroughput 640(默认16)

或修改cassandra.yaml配置项
compaction_throughput_mb_per_sec:640(0：无限制)
		
b、增加压缩线程
官网说一般不需要调整，除非使用SSD，但我们实际使用情况看，若CPU有富余且磁盘性能很好的情况下是可以适当调大的。
		
c、临时关闭gossip
nodetool disablegossip
```

2、linux性能调优
```
a、时钟同步，公司主机都自带此功能，不需要做
	
b、TCP参数配置
# vim /etc/sysctl.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=16777216
net.core.wmem_default=16777216
net.core.optmem_max=40960
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
		     
c、禁用zone_reclaim_mode
查看：cat /proc/sys/vm/zone_reclaim_mode  0：关闭，   1：开启
设置：vim /etc/sysctl.conf  添加vm.zone_reclaim_mode=0 并执行sysctl -p
     	
d、资源限制放开
#	vim /etc/security/limits.conf,不同操作系统可能不同
root - memlock unlimited
root - nofile 100000
root - nproc 32768
root - as unlimited
     	
f、禁用swap
# vim /etc/sysctl.conf 设置 vm.swappiness=0 并执行sysctl -p
# swapoff -a
# vim /etc/fstab   去掉swap挂载
```
