# ceph-硬件配置

- 为了使ceph集群运行的更稳定，综合性价比，做出如下的硬件配置:

| 名称 | 数量 | 说明 |
|-----|------|------|
| OS Disk | `2*600G SAS (SEAGATE 600GB SAS 6Gbps 15K 2.5英寸)` | 根据预算选择SSD、SAS、SATA。RAID 1 ，防止系统盘故障，引发ceph集群问题 |
| OSD Disk | `8*4T SAS (SEAGATE 4T SAS 7200)` | 根据预算选择SAS或者SATA盘，每台物理机配置8块4T磁盘，用于存放数据。NoRAID |
| Monitor Disk | `1*480G SSD (Intel SSD 730 series)` | 用于monitor 进程的磁盘，选择ssd，速度更快 |
| Journal Disk | `2*480G SSD (Intel SSD 730 series)` | ssd磁盘，每块分4个区，对应4个osd，一台节点总计8个journal分区，对应8个osd。NoRAID |
| CPU | `E5-2630v4 * 2` | 综合预算，选择cpu,越高越好 |
| Memory | `64G` | 综合预算，不差钱上128G内存 |
| NIC | `10GB * 2 光口` | 10GB网卡可以保证数据同步速度 |

## CPU

每一个osd守护进程至少有一个cpu核

计算公式如下：
```
((cpu sockets * cpu cores per socket * cpu clock speed in GHZ)/No. of OSD) >= 1
 
Intel Xeon Processor E5-2630 V4(2.2GHz,10 core)计算：
  1 * 10 * 2.2 / 8 = 2.75  #大于1, 理论上能跑20多个osd进程，我们考虑到单节点的osd过多，引发数据迁移量的问题，所以限定了8个osd进程
```

## 内存

1个osd进程至少需要1G的内存，不过考虑到数据迁移内存占用，建议1个osd进程预配2G内存。

在作数据恢复时1TB数据大概需要1G的内存，所以内存越多越好

# 磁盘

## 系统盘

- 根据预算选择ssd、sas、sata磁盘，必须做raid，以防因为磁盘引发的宕机

## OSD 磁盘

- 综合性价比，选择sas或者sata磁盘，每块大小4T。如果有io密集型的业务，也可单独配备性能更高的ssd作为osd磁盘，然后单独划分一个region

## Journal 磁盘

- 用于日志写入，选择ssd磁盘，速度快

## Monitor 磁盘

- 用于运行监控进程的磁盘，建议选择ssd磁盘。如果ceph的monitor单独运行在物理机上，则需要2块ssd磁盘做raid1，如果monitor与osd运行在同一个节点上，则单独准备一块ssd作为monitor的磁盘

## NIC

- 一个osd节点是配置2块10GB网卡，一个作为public网络用于管理，一个作为cluster网络用于osd之间的通信
