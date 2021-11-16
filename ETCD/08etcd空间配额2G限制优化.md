一、简要说明
===
etcd的数据库空间配额大小默认限制为2G，当数据达到2G的时候就不允许写入。这里如果想继续写入，必须对历史数据进行压缩，或者调整etcd数据库的空间配额大小限制。

二、具体配置
===
当空间配额满载时，会提示`mvcc: database space exceeded`

# 1）查看etcd的配额使用量
```
[root@k8s001 ~]# export ETCDCTL_API=3
[root@k8s001 ~]# etcdctl endpoint status --write-out table
+----------------+------------------+---------+---------+-----------+-----------+------------+
|    ENDPOINT    |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+----------------+------------------+---------+---------+-----------+-----------+------------+
| 127.0.0.1:2379 | 8e9e05c52164694d |  3.3.10 |  2.2 GB |      true |         3 |    3085227 |
+----------------+------------------+---------+---------+-----------+-----------+------------+
```

# 2）开启磁盘碎片整理

1.查看警告信息
```
[root@k8s001 ~]# etcdctl --endpoints=http://127.0.0.1:2379 alarm list
memberID:8e9e05c52164694d alarm:NOSPACE
```

2.获取历史版本号
```
[root@k8s001 ~]# export ETCDCTL_API=3
[root@k8s001 ~]# etcdctl endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*'
8991138
```

3.压缩旧版本
```
[root@k8s001 ~]# etcdctl compact 8991138
compacted revision 8991138
```

4.etcd进行碎片整理
```
[root@k8s001 ~]# etcdctl defrag  
Finished defragmenting etcd member[127.0.0.1:2379]
```

5.查看etcd数据库大小
```
[root@k8s001 ~]# etcdctl endpoint status --write-out table
+----------------+------------------+---------+---------+-----------+-----------+------------+
|    ENDPOINT    |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+----------------+------------------+---------+---------+-----------+-----------+------------+
| 127.0.0.1:2379 | 8e9e05c52164694d |  3.3.10 |  1.2 GB |      true |         3 |    3089646 |
+----------------+------------------+---------+---------+-----------+-----------+------------+
```

6.最后清除警告
```
[root@k8s001 ~]# etcdctl --endpoints=http://127.0.0.1:2379 alarm disarm
```

# 3)修改etcd空间配额大小

1.修改systemd文件
```
[root@k8s001 ~]# cat /etc/systemd/system/etcd.service 
......
--quota-backend-bytes=10240000000 # 这里单位是字节
......
```

2.重启etcd服务
```
[root@k8s001 ~]# systemctl daemon-reload
[root@k8s001 ~]# systemctl restart etcd
```
