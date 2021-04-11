etcdctl 命令
===
```
ETCDCTL_API=3 ./etcdctl --endpoints=https://0:2379,https://1:2379,https://2:2379 --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem endpoint status --write-out=table
```

etcd 版本为 3.4，可以ETCDCTL_API=3，或ETCDCTL_API=2，默认情况下用的就是v3了，可以不用声明ETCDCTL_API

- version: 查看版本
- member list: 查看节点状态，learner 情况
- endpoint status: 节点状态，leader 情况
- endpoint health: 健康状态与耗时
- alarm list: 查看警告，如存储满时会切换为只读，产生 alarm
- alarm disarm：清除所有警告
- set app demo: 写入
- get app: 获取
- update app demo1:更新
- rm app: 删除
- mkdir demo 创建文件夹
- rmdir dir 删除文件夹
- backup 备份
- compaction： 压缩
- defrag：整理碎片
- watch key : 监测 key 变化
- get / –prefix –keys-only: 查看所有 key
- –write-out=table : 可以用表格形式输出更清晰，注意有些输出并不支持tables
