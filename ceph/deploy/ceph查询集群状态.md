命令行查看集群
===
1、检查集群的健康状况  
```
# ceph health
# ceph health detail
```  

2、查看集群事件  
```
# ceph -w                    # 集群的动态更改信息
# ceph --watch-debug         # debug
```  
- --watch-info: to watch info events  
- --watch-sec: to watch security events  
- --watch-warn: to watch warning events  
- --watch-error: to watch error events  

3、集群利用率统计  
```
# ceph df
GLOBAL:
    SIZE        AVAIL       RAW USED     %RAW USED 
    5.99GiB     3.93GiB      2.06GiB         34.46 
POOLS:
    NAME     ID     USED        %USED     MAX AVAIL     OBJECTS 
    rbd      1      4.45MiB      0.12       3.61GiB          13 


# ceph df detail
GLOBAL:
    SIZE        AVAIL       RAW USED     %RAW USED     OBJECTS 
    5.99GiB     3.93GiB      2.07GiB         34.47          13 
POOLS:
    NAME     ID     QUOTA OBJECTS     QUOTA BYTES     USED        %USED     MAX AVAIL     OBJECTS     DIRTY     READ     WRITE     RAW USED 
    rbd      1      N/A               N/A             4.45MiB      0.12       3.61GiB          13        13     362B       93B      13.4MiB 
```  

4、检查集群的状态  
```
# ceph status
# ceph -s
```  

5、集群身份验证  
```
# ceph auth list
```

6、检查Mon状态  

MON 状态表
---
| 状态 | 说明 |
|-----|------|
| probing | 正在探测态。这意味着MON正在寻找其他的MON。当MON启动时， MON尝试找在monmap定义的其他剩余的MON。在多MON的集群中，直到MON找到足够多的MON构建法定选举人数之前，它一直在这个状态。这意味着如果3个MON中的2个挂掉，剩余的1个MON将一直在probing状态，直到启动其他的MON中的1个为止。 |
| electing | 正在选举态。这意味着MON正在选举中。这应该很快完成，但有时也会卡在正这，这通常是因为MON主机节点间的时钟偏移导致的. |
| synchronizing | 正在同步态。这意味着MON为了加入到法定人数中和集群中其他的MON正在同步. |
| leader或peon | 领导态或员工态。这不应该出现。然而有机会出现，一般和时钟偏移有很大关系 |

client 无法链接mon的可能原因
- 连通性和防火墙规则。在MON主机上修改允许TCP 端口6789的访问。
- 磁盘空间。每个MON主机上必须有超过5%的空闲磁盘空间使MON和levelDB数据库正常工作。
- MON没有工作或者离开选举，检查如上命令输出结果中的quorum_status和mon_status或者ceph -s 的输出来确定失败的MON进程，尝试重启或者部署一个新的来替代它。

```
# ceph mon stat
# ceph mon dump
# ceph quorum_status -f json-pretty
```  

7、OSD查看  

OSD状态表
---
| 状态 | 说明 |
|-----|------|
| up | osd启动 |
| down | osd停止 |
| in | osd在集群中 |
| out | osd不在集群中，默认OSD down 超过300s,Ceph会标记为out，会触发重新平衡操作 |
| up & in | 说明该OSD正常运行，且已经承载至少一个PG的数据。这是一个OSD的标准工作状态 |
| up & out | 说明该OSD正常运行，但并未承载任何PG，其中也没有数据。一个新的OSD刚刚被加入Ceph集群后，便会处于这一状态。而一个出现故障的OSD被修复后，重新加入Ceph集群时，也是处于这一状态 |
| down & in | 说明该OSD发生异常，但仍然承载着至少一个PG，其中仍然存储着数据。这种状态下的OSD刚刚被发现存在异常，可能仍能恢复正常，也可能会彻底无法工作 |
| down & out | 说明该OSD已经彻底发生故障，且已经不再承载任何PG |

常见问题
- 硬盘失败。可以通过系统日志或SMART活动确认。有些有缺陷的硬盘因为密集的有时限的错误修复活动变的很慢。
- 网络连接问题。可以使用ping、iperf等普通网络工具进行调试。
- OSD文件存储的磁盘空间不足。 磁盘到85%将会触发HEALTH_WARN告警。磁盘到95%会触发HEALTH_ERR告警，OSD为了避免填满磁盘会停止。
- 超过系统资源限制。系统内存应该足够主机上所有的OSD进程，打开文件句柄数和最大线程数也应该是足够的。OSD进程处理心跳的限制导致进程自杀。默认的处理和通信超时不足以执行IO饥饿型的操作，尤其是失败后的恢复。这经常会导致OSD闪断的现象出现。

```
# ceph osd tree
# ceph osd dump
```  

8、Crush map的查看  
```
# ceph osd crush dump
# ceph osd crush rule list
# ceph osd crush rule dump <crush_rule_name>
# ceph osd find <Numeric_OSD_ID>
```  

9、PGs的查看  

PG 状态表
---
正常是active+clean
| 状态 | 描述 |
|-----|------|
| active | 活跃状态。ceph将处理到达这个PG的读写请求 |
| unactive | 非活跃状态。该PG不能处理读写请求 |
| clean | 干净状态。Ceph复制PG内所有对象到设定正确的数目 |
| unclean | 非干净状态。PG不能从上一个失败中恢复 |
| down | 离线状态。有必需数据的副本挂掉，比如对象所在的3个副本的OSD挂掉，所以PG离线 |
| degraded | 降级状态。ceph有些对象的副本数目没有达到系统设置，一般是因为有OSD挂掉 |
| inconsistent | 不一致态。Ceph 清理和深度清理后检测到PG中的对象在副本存在不一致，例如对象的文件大小不一致或recovery结束后一个对象的副本丢失 |
| peering | 正在同步状态。PG正在执行同步处理 |
| recovering | 正在恢复状态。Ceph正在执行迁移或同步对象和他们的副本 |
| incomplete | 未完成状态。实际的副本数少于min_size。Ceph检测到PG正在丢失关于已经写操作的信息，或者没有任何健康的副本。如果遇到这种状态，尝试启动失败的OSD，这些OSD中可能包含需要的信息或者临时调整副本min_size的值到允许恢复。 |
| stale | 未刷新状态。PG状态没有被任何OSD更新，这说明所有存储这个PG的OSD可能down |
| backfilling | 正在后台填充状态。 当一个新的OSD加入集群后，Ceph通过移动一些其他OSD上的PG到新的OSD来达到新的平衡；这个过程完成后，这个OSD可以处理客户端的IO请求。 |
| remapped | 重新映射状态。PG活动集任何的一个改变，数据发生从老活动集到新活动集的迁移。在迁移期间还是用老的活动集中的主OSD处理客户端请求，一旦迁移完成新活动集中的主OSD开始处理。 |

PG 长时间卡在一些状态

遇到失败后PG进入如 “degraded” 或 “peering”的状态是正常的。通常这些状态指示失败恢复处理过程中的正常继续。然而，一个PG长时间保持在其中一些状态可能是一个更大问题的提示。因此，MON当PG卡在一个非正常态时会警告。 我们特别地检查：
- inactive : PG太长时间不在active态，例如PG长时间不能处理读写请求，通常是peering的问题。
- unclean : PG太长时间不在clean态，例如PG不能完成从上一个失败的恢复，通常是unfound objects导致。
- stale : PG状态未被OSD更新，表示所有存储PG的OSD可能挂掉，一般启动相应的OSD进程即可。


```
# ceph pg stat
# ceph pg dump -f json-pretty
# ceph pg <pg_id> query            # 查询特定pg的详细信息
```  




10、Ceph MDS的查看  
```
# ceph fs ls
# ceph mds stat
# ceph mds dump
```  



