# 从不健康的集群中删除故障的mon

2台mon节点宕机情况下的故障解决办法，并且包含osd节点，恢复过程
```
# 1、停止当前节点的mon
pkill ceph-mon

# 2、确认mon节点进程消失
ps -ef |grep ceph-mon |grep -v grep

# 3、备份mon数据目录
tar czf {mon_datapaht}.tar.gz {mon_datapath}

# 4、提取mon节点中最新的monmap信息
ceph-mon-c {config_file} -i {mon-id} --mon_data {mon_datapath} --extract-monmap {mappath}

# 5、确认提取的monmap中有3个mon节点
monmaptool --print {mappath}

# 6、删除monmap中故障的mon节点
monmaptool {mappath}  -rm {mon-id}

# 7、确认删减后的monmap只剩下当前节点的mon
monmaptool --print {mappath}

# 8、向当前节点的mon中注入删减过的monmap
ceph-mon -c {config_file} -i {mon-id} --mon_data {mon_datapath} -inject-monmap {monpath}

# 9、启动当前节点的mon服务器
ceph-mon -c {config_file} -i {mon-id} --mon_data {mon_datapath}

# 10、查看集群是否运行正常
ceph -c {config_file} -s

# 11、阻止数据迁移
ceph -c {config_file} osd set noout

# 12、设置最小副本数
ceph -c {config_file} osd pool set {pool_name} min_size 2
```
- -c ceph使用的配置文件
- -i mon名
- --mon_data mon存储数据目录
- --extract-monmap 将mon的map输出到指定目录
- --inject-monmap 将导出的mon_map写入到本地的monmap中


参考：
- https://blog.csdn.net/wuxianweizai/article/details/78925479
- https://blog.csdn.net/wuxianweizai/article/details/79689437?spm=1001.2014.3001.5502
