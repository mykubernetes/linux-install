# 从不健康的集群中删除故障的mon

```
# 1、提取mon节点中最新的monmap信息
ceph-mon-c {config_file} -i {mon-id} --mon_data {mon_datapath} --extract-monmap {mappath}

# 2、确认提取的monmap中有3个mon节点
monmaptool --print {mappath}

# 3、删除monmap中故障的mon节点
monmaptool {mappath}  -rm {mon-id}

# 4、向当前节点的mon中注入删减过的monmap
ceph-mon -c {config_file} -i {mon-id} --mon_data {mon_datapath} -inject-monmap {monpath}

# 5、启动当前节点的mon服务器
ceph-mon -c {config_file} -i {mon-id} --mon_data {mon_datapath} 
```
- -c ceph使用的配置文件
- -i mon名
- --mon_data mon存储数据目录
- --extract-monmap 将mon的map输出到指定目录
- --inject-monmap 将导出的mon_map写入到本地的monmap中


参考：
- https://blog.csdn.net/wuxianweizai/article/details/78925479
- https://blog.csdn.net/wuxianweizai/article/details/79689437?spm=1001.2014.3001.5502
