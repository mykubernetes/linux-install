命令行查看集群
===

MON 状态表
---
| 状态 | 说明 |
|-----|------|
| probing | 正在探测态。这意味着MON正在寻找其他的MON。当MON启动时， MON尝试找在monmap定义的其他剩余的MON。在多MON的集群中，直到MON找到足够多的MON构建法定选举人数之前，它一直在这个状态。这意味着如果3个MON中的2个挂掉，剩余的1个MON将一直在probing状态，直到启动其他的MON中的1个为止。 |
| electing | 正在选举态。这意味着MON正在选举中。这应该很快完成，但有时也会卡在正这，这通常是因为MON主机节点间的时钟偏移导致的. |
| synchronizing | 正在同步态。这意味着MON为了加入到法定人数中和集群中其他的MON正在同步. |
| leader或peon | 领导态或员工态。这不应该出现。然而有机会出现，一般和时钟偏移有很大关系 |

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
```
# ceph mon stat
# ceph mon dump
# ceph quorum_status -f json-pretty
```  

7、OSD查看  
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



