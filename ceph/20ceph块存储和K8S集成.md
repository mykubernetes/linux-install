一、创建Ceph-RBD-Provisioner对象

Ceph-RBD-Provisioner.yaml类似于k8s与ceph的接口，为k8s的rbd提供供给。

1、编辑Ceph-RBD-Provisioner.yaml配置文件
```
cat Ceph-RBD-Provisioner.yaml
```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rbd-provisioner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
  - apiGroups: [""]
    resources: ["services"]
    resourceNames: ["kube-dns","coredns"]
    verbs: ["list", "get"]
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rbd-provisioner
subjects:
  - kind: ServiceAccount
    name: rbd-provisioner
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: rbd-provisioner
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: rbd-provisioner
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rbd-provisioner
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: rbd-provisioner
subjects:
- kind: ServiceAccount
  name: rbd-provisioner
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: rbd-provisioner
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rbd-provisioner
spec:
  selector:
    matchLabels:
      app: rbd-provisioner
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: rbd-provisioner
    spec:
      containers:
      - name: rbd-provisioner
        image: quay.io/external_storage/rbd-provisioner:latest
        env:
        - name: PROVISIONER_NAME
          value: ceph.com/rbd
      serviceAccount: rbd-provisioner
```

2、创建Ceph-RBD-Provisioner对象
```
# 创建Ceph-RBD-Provisioner对象
$ kubectl create -n kube-system -f  Ceph-RBD-Provisioner.yaml
```

3、检测是否部署成功
```
# 检测是否部署成功
$ kubectl describe deployments.apps -n kube-system rbd-provisioner
# 查看创建成功的pods信息
$ kubectl get pods -n kube-system
NAME                                 READY   STATUS    RESTARTS   AGE
...
rbd-provisioner-c968dcb4b-rtnj7      1/1     Running   3          26h				# 创建成功的pods信息
```

二、创建k8s和ceph集成需要的key

这里一共有两次秘钥的设定：

1、ceph集群与k8s的管理秘钥：
```
ceph auth get-key client.admin；
```
    
2、ceph创建的pool与k8s的管理秘钥：
```
ceph --cluster ceph auth get-or-create client.kube mon ‘allow r’ osd ‘allow rwx pool=kube’；
```

3、检测ceph集群的健康状态
```
$ ceph -s
  cluster:
    id:     ce89b98d-91a5-44b5-a546-6648492b1646
    health: HEALTH_WARN
            application not enabled on 2 pool(s)

  services:
    mon: 4 daemons, quorum ceph-master,ceph-node02,ceph-node03,ceph-node01
    mgr: ceph-node02(active), standbys: ceph-node03, ceph-node01, ceph-master
    osd: 12 osds: 12 up, 12 in

  data:
    pools:   2 pools, 256 pgs
    objects: 42  objects, 86 MiB
    usage:   13 GiB used, 575 GiB / 588 GiB avail
    pgs:     256 active+clean
```
   
4、获取管理key并在k8s中创建管理的秘钥
```
# 使用cephadm用户登录
$ ceph auth get-key client.admin
AQDaMZVeREAwBxAA2nDczMFt3E98kDqbWTio3w==

# 在k8s中创建secret, 这里仍旧是/tmp目录下(将上面获取到的秘钥替换到--from-literal=key中)
$ kubectl create secret generic ceph-secret \
     --type="kubernetes.io/rbd" \
     --from-literal=key='AQDaMZVeREAwBxAA2nDczMFt3E98kDqbWTio3w==' \
     --namespace=kube-system

# 查看创建的secret, 对应ceph-secret
$ kubectl get secret -n kube-system
NAME                                             TYPE                                  DATA   AGE
...
ceph-secret                                      kubernetes.io/rbd                     1      2m47s
```

5、生成k8s对ceph pool和客户端的认证密钥
```
# 在ceph集群中，用cephadm用户创建名称为kube的pool
$ ceph --cluster ceph osd pool create kube 4
pool 'kube' created

# 创建访问该池的客户端
$ ceph --cluster ceph auth get-or-create client.kube mon 'allow r' osd 'allow rwx pool=kube'
[client.kube]
        key = AQDbhpZetMvjMhAAURlSaND1kROu1tO9rYLS9Q==

# 获取客户端认证的token,并在k8s中创建秘钥

# 在k8s集群中创建秘钥
kubectl create secret generic ceph-secret-kube \
    --type="kubernetes.io/rbd" \
    --from-literal=key=AQDbhpZetMvjMhAAURlSaND1kROu1tO9rYLS9Q== \			
    --namespace=kube-system

# 删除旧秘钥的指令
kubectl delete secret ceph-secret-kube -n kube-system
```


三、创建ceph-rbd的存储类

1、创建Ceph-RBD-StorageClass的存储类
```
# 编辑Ceph-RBD-StroageClass的存储类.yaml文件
[root@ceph-master tmp]# cat Ceph-RBD-StorageClass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-rbd
provisioner: ceph.com/rbd
parameters:
  monitors: 192.168.47.129:6789, 192.168.47.130:6789, 192.168.47.140:6789				# 这里对应4台存储节点
  adminId: admin
  adminSecretName: ceph-secret
  adminSecretNamespace: kube-system
  pool: kube
  userId: kube
  userSecretName: ceph-secret-kube
  userSecretNamespace: kube-system
  imageFormat: "2"
  imageFeatures: layering
```

2、创建应用实例
```
$ kubectl create -f Ceph-RBD-StorageClass.yaml
storageclass.storage.k8s.io/fast-rbd created

# 查看已经创建的存储类
$ kubectl get sc
NAME       PROVISIONER    RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
fast-rbd   ceph.com/rbd   Delete          Immediate           false                  5m1s

# 如果有必要，删除存储类
kubectl delete sc fast-rbd
```

四、创建pvc

创建pvc来测试是否可以动态创建pv。

1、创建Ceph-RBD-PVC存储类
```
$ cat Ceph-RBD-PVC.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: testclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: fast-rbd
```

2、创建Ceph-RBD-PVC对象
```
# 创建Ceph-RBD-PVC对象
$ kubectl create -f Ceph-RBD-PVC.yaml

# 查看创建的pvc
$ kubectl get pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
testclaim   Bound    pvc-bc3eb914-acd6-47c1-8ffd-82f87ea0520b   1Gi        RWO            fast-rbd       37s

# 查看创建的pv
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE
pvc-bc3eb914-acd6-47c1-8ffd-82f87ea0520b   1Gi        RWO            Delete           Bound    default/testclaim   fast-rbd                107s
```

3、在ceph集群中查看创建的pv
```
$ rbd ls -p kube
kubernetes-dynamic-pvc-4e4eb4b3-7ed1-11ea-b851-5a530ae333ee
```
https://blog.csdn.net/u012720518/article/details/105489771/
