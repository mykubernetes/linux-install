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



