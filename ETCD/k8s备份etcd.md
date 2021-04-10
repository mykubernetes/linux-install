一、问题描述
===
二进制部署的单Master节点的v1.13.10版本的集群，etcd部署的是3.3.10版本，部署在master节点上。在异常断电后，kubernetes集群无法正常启动。这里通过查看kubernetes和etcd的服务日志信息，发现etcd服务异常，无法重新启动，具体日志信息如下：
```
Jun 29 09:39:37 k8s001 etcd[3348]: recovered store from snapshot at index 2600026
Jun 29 09:39:37 k8s001 etcd[3348]: recovering backend from snapshot error: database snapshot file path error: snap: snapshoJun 29 09:39:37 k8s001.wf etcd[3348]: panic: r
ecovering backend from snapshot error: database snapshot file path error: snap: Jun 29 09:39:37 k8s001 etcd[3348]: panic: runtime error: invalid memory address or nil pointer dereferenceJun 29 09:39:37 k8s001 etcd[3348]: [signal SIGSEGV: segmentation violation code=0x1 addr=0x20 pc=0xb8cb90]
Jun 29 09:39:37 k8s001 etcd[3348]: goroutine 1 [running]:
Jun 29 09:39:37 k8s001 etcd[3348]: github.com/coreos/etcd/cmd/vendor/github.com/coreos/etcd/etcdserver.NewServer.func1(0xc4Jun 29 09:39:37 k8s001 etcd[3348]: /tmp/etc
d-release-3.3.10/etcd/release/etcd/gopath/src/github.com/coreos/etcd/cmd/vendor/Jun 29 09:39:37 k8s001.wf etcd[3348]: panic(0xde0ce0, 0xc4200b10a0)Jun 29 09:39:37 k8s001 etcd[3348]: /usr/local/go/src/runtime/panic.go:502 +0x229
Jun 29 09:39:37 k8s001 etcd[3348]: github.com/coreos/etcd/cmd/vendor/github.com/coreos/pkg/capnslog.(*PackageLogger).PanicfJun 29 09:39:37 k8s001 etcd[3348]: /tmp/etc
d-release-3.3.10/etcd/release/etcd/gopath/src/github.com/coreos/etcd/cmd/vendor/Jun 29 09:39:37 k8s001.wf etcd[3348]: github.com/coreos/etcd/cmd/vendor/github.com/coreos/etcd/etcdserver.NewServer(0x7ffe787eJun 29 09:39:37 k8s001.wf etcd[3348]: /tmp/etcd-release-3.3.10/etcd/release/etcd/gopath/src/github.com/coreos/etcd/cmd/vendor/Jun 29 09:39:37 k8s001 etcd[3348]: github.com/coreos/etcd/cmd/vendor/github.com/coreos/etcd/embed.StartEtcd(0xc42019d680, 0Jun 29 09:39:37 k8s001 etcd[3348]: /tmp/etcd-release-3.3.10/etcd/release/etcd/gopath/src/github.com/coreos/etcd/cmd/vendor/
```
通过查看异常日志来看，etcd执行了恢复操作，但是无法从现有的快照数据进行数据恢复。这里查看了资料，发现社区也有类似的问题，此问题暂未修复：

https://github.com/etcd-io/etcd/issues/11949

https://github.com/kubernetes/kubernetes/issues/88574

二、问题解决方案
===
对于单master节点的集群，master作为整个集群的核心，如果etcd服务挂掉，将影响我们整个集群的使用。因此这里对etcd做一个备份方案，以备不时之需。

这个我们采用kubernetes的CronJob来实现etcd数据的定时备份。也就是kubernetes集群正常时，CronJob执行定时备份任务，如果kubernetes集群异常，则CrobJob也将不会执行。

备份etcd数据的yaml文件
```
[root@k8s001 home]# cat etcd_cronjob.yaml
---
apiVersion: batch/v2alpha1
kind: CronJob
metadata:
  name: etcd-backup
spec:
 # 30分钟执行一次备份
 schedule: "*/30 * * * *"
 jobTemplate:
  spec:
    template:
      metadata:
       labels:
        app: etcd-disaster-recovery
      spec:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                  - matchExpressions:
                    - key: kubernetes.io/role
                      operator: In
                      values:
                      - master
        containers:
        - name: etcd
          image: etcd:backup
          command:
          - sh
          - -c
          - "export ETCDCTL_API=3; \
             # 备份前执行下清理的操作，最多保留6个快照
             sh -x /usr/bin/delete_image_reserver_5.sh; \
             etcdctl --endpoints $ENDPOINT snapshot save /snapshot/$(date +%Y%m%d_%H%M%S)_snapshot.db; \
             echo etcd backup sucess"
          env:
          - name: ENDPOINT
            value: "127.0.0.1:2379"
          volumeMounts:
            - mountPath: "/snapshot"
              name: snapshot
              subPath: etcd-snapshot
            - mountPath: /etc/localtime
              name: lt-config
            - mountPath: /etc/timezone
              name: tz-config
        restartPolicy: OnFailure
        volumes:
          - name: snapshot
            hostPath:
              path: /var
          - name: lt-config
            hostPath:
              path: /etc/localtime
          - name: tz-config
            hostPath:
              path: /etc/timezone
        hostNetwork: true

# 设置master节点可调度
[root@k8s001 ~]# kubectl uncordon ${masterip}

# 创建定时备份任务
# 创建etcd定时备份的job
[root@k8s001 home]# kubectl apply -f etcd_cronjob.yaml

# 查看备份的快照
[root@k8s001 ~]# ls /var/etcd-snapshot/ -alh
total 45M
drwxr-xr-x   2 root root  216 Jun 30 16:05 .
drwxr-xr-x. 20 root root  288 Jun 28 16:10 ..
-rw-r--r--   1 root root 7.5M Jun 30 15:45 20200630_154509_snapshot.db
-rw-r--r--   1 root root 7.5M Jun 30 15:50 20200630_155009_snapshot.db
-rw-r--r--   1 root root 7.5M Jun 30 15:55 20200630_155510_snapshot.db
-rw-r--r--   1 root root 7.5M Jun 30 16:00 20200630_160010_snapshot.db
-rw-r--r--   1 root root 7.5M Jun 30 16:03 20200630_160357_snapshot.db
-rw-r--r--   1 root root 7.5M Jun 30 16:05 20200630_160510_snapshot.db

# 监控任务执行情况
[root@k8s001 ~]# kubectl get job --watch
NAME                                   COMPLETIONS   DURATION   AGE
etcd-backup-1593504000   1/1           1s         9m20s
```

三、验证
===
验证下创建的快照是否可以进行数据的恢复：

1、停止集群的etcd服务和删除etcd数据
```
# 停止etcd服务
[root@k8s001 ~]# systemctl stop etcd

# 删除etcd数据
[root@k8s001 ~]# rm -rf /var/lib/etcd

# 查看集群服务是否还正常
[root@k8s001 ~]# kubectl get pod
The connection to the server 172.16.33.5:6443 was refused - did you specify the right host or port?
```

2、基于etcd快照恢复数据目录
```
[root@k8s001 ~]# cd /var/etcd_backup/

# 这里选用最新的一个快照进行数据目录恢复
[root@k8s001 ~]# export ETCDCTL_API=3
[root@k8s001 ~]# etcdctl snapshot restore 20200630_161001_snapshot.db --data-dir /var/lib/etcd
2020-06-30 16:19:29.789757 I | mvcc: restore compact to 6142751
2020-06-30 16:19:29.807133 I | etcdserver/membership: added member 8e9e05c52164694d [http://localhost:2380] to cluster cdf818194e3a8c32

# 查看执行快照恢复后的数据目录
[root@k8s001 etcd-snapshot]# tree /var/lib/etcd/
/var/lib/etcd/
└── member
    ├── snap
    │   ├── 0000000000000001-0000000000000001.snap
    │   └── db
    └── wal
        └── 0000000000000000-0000000000000000.wal

# 启动etcd服务
[root@k8s001 etcd-snapshot]# systemctl restart etcd
[root@k8s001 etcd-snapshot]# systemctl status etcd
● etcd.service - Etcd Server
   Loaded: loaded (/etc/systemd/system/etcd.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-06-30 16:20:27 CST; 6s ago
     Docs: https://github.com/coreos
 Main PID: 3069327 (etcd)
    Tasks: 15
   Memory: 17.5M
   CGroup: /system.slice/etcd.service
           └─3069327 /usr/bin/etcd --name=k8s001 --cert-file=/etc/etcd/ssl/etcd.pem --key-file=/etc/etcd/ssl/etcd-key.pem --peer-cert-file=/etc/etcd/ssl/etcd.pem --pe...
 
Jun 30 16:20:27 k8s001 etcd[3069327]: raft.node: 8e9e05c52164694d elected leader 8e9e05c52164694d at term 2
Jun 30 16:20:27 k8s001 etcd[3069327]: setting up the initial cluster version to 3.3
Jun 30 16:20:27 k8s001 etcd[3069327]: set the initial cluster version to 3.3
Jun 30 16:20:27 k8s001 etcd[3069327]: published {Name:k8s001 ClientURLs:[https://172.16.33.5:2379]} to cluster cdf818194e3a8c32
Jun 30 16:20:27 k8s001 etcd[3069327]: enabled capabilities for version 3.3
Jun 30 16:20:27 k8s001 etcd[3069327]: ready to serve client requests
Jun 30 16:20:27 k8s001 etcd[3069327]: ready to serve client requests
Jun 30 16:20:27 k8s001 systemd[1]: Started Etcd Server.
Jun 30 16:20:27 k8s001 etcd[3069327]: serving insecure client requests on 127.0.0.1:2379, this is strongly discouraged!
Jun 30 16:20:27 k8s001 etcd[3069327]: serving client requests on 172.16.33.5:2379

# 查看业务的服务是否丢失，从下面可知业务服务恢复正常
[root@k8s001 etcd-snapshot]# kubectl get pod -n business -o wide
NAME                          READY   STATUS      RESTARTS   AGE   IP             NODE            NOMINATED NODE   READINESS GATES
redis-4ghyausyd-9hejh         1/1     Running     1          28d   172.20.0.30    172.16.33.5   <none>           <none>
mysql-c6994b67c-jx9rb         1/1     Running     0          28d   172.20.0.233   172.16.33.5   <none>           <none>
```
