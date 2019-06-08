
一、安装 Prometheus  
1、下载  
```
wget https://github.com/prometheus/prometheus/releases/download/v2.6.1/prometheus-2.6.1.linux-amd64.tar.gz
tar zxfv prometheus-2.6.1.linux-amd64.tar.gz
mv prometheus-2.6.1.linux-amd64 /data/apps/prometheus
```  

2、配置系统服务  
```
vi /usr/lib/systemd/system/prometheus.service
[Unit]
Description=prometheus
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=/data/apps/prometheus/prometheus \
--config.file=/data/apps/prometheus/prometheus.yml \
--storage.tsdb.path=/data/apps/prometheus/data \
--web.console.libraries=/data/apps/prometheus/console_libraries \
--web.console.templates=/data/apps/prometheus/consoles \
--web.enable-lifecycle
Restart=on-failure

[Install]
WantedBy=multi-user.target
```  

3、创建用户  
```
groupadd prometheus
useradd -g prometheus -m -d /data/apps/prometheus/data -s /sbin/nologin prometheus
```  

4、验证安装  
```
systemctl start prometheus
systemctl enable prometheus

/data/apps/prometheus/prometheus --version
prometheus, version 2.6.1 (branch: HEAD, revision:
b639fe140c1f71b2cbad3fc322b17efe60839e7e)
build user: root@4c0e286fe2b3
build date: 20190115-19:12:04
go version: go1.11.4

curl localhost:9090
<a href="/graph">Found</a>.
```  

二、安装 node_exporter  
1、下载  
```
wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
tar zxf node_exporter-0.17.0.linux-amd64.tar.gz
mv node_exporter-0.17.0.linux-amd64 /data/apps/node_exporter
```  

2、创建 Systemd 服务  
```
[Unit]
Description=https://prometheus.io

[Service]
Restart=on-failure
ExecStart=/data/apps/node_exporter/node_exporter \
--collector.systemd \
--collector.systemd.unit-whitelist=(docker|kubelet|kube-proxy|flanneld).service

[Install]
WantedBy=multi-user.target
```  

3、启动 Node exporter  
```
systemctl enable node_exporter
systemctl start node_exporter
```  

三、安装 grafana  
1、下载  
```
wget https://dl.grafana.com/oss/release/grafana-6.2.0-1.x86_64.rpm
yum localinstall grafana-6.2.0-1.x86_64.rpm
```  

2、启动  
```
systemctl enable grafana-server
systemctl start grafana-server
```  

四、 安装 alertmanager  
1、下载  
```
wget https://github.com/prometheus/alertmanager/releases/download/v0.16.2/alertmanager-0.16.2.linux-amd64.tar.gz
tar zxvf alertmanager-0.16.2.linux-amd64.tar.gz
mv alertmanager-0.16.2.linux-amd64 /data/apps/alertmanager
```  

2、作成服务  
```
vi /usr/lib/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
After=network.target

[Service]
Type=simple
User=alertmanager
ExecStart=/data/apps/alertmanager/alertmanager \
--config.file=/data/apps/alertmanager/alertmanager.yml \
--storage.path=/data/apps/alertmanager/data
Restart=on-failure

[Install]
WantedBy=multi-user.target
```  

3、启动服务  
```
systemctl enable alertmanager
systemctl start alertmanager
```  

五、LXCFS通过用户态文件系统，在容器中提供下列procfs的文件  
1、下载安装  
```
wget https://copr-be.cloud.fedoraproject.org/results/ganto/lxd/epel-7-x86_64/00486278-lxcfs/lxcfs-2.0.5-3.el7.centos.x86_64.rpm
yum localinstall lxcfs-2.0.5-3.el7.centos.x86_64.rpm
```  

2、启动lxcfs  
```
# systemctl enable lxcfs
# systemctl start lxcfs
# systemctl status lxcfs
```  

六、Initializer  
Kubernetes提供了Initializer扩展机制，可以用于对资源创建进行拦截和注入处理，我们可以借助它优雅地完成对lxcfs文件的自动化挂载。  
1、在集群 kube-apiserver配置文件中添加如下参数，并重启 kube-apiserver  
``` --enable-admission-plugins=Initializers --runtime-config=admissionregistration.k8s.io/v1alpha1 ```  

2、下载LXCFS  
```
# git clone https://github.com/denverdino/lxcfs-initializer
Cloning into 'lxcfs-initializer'...
remote: Enumerating objects: 1583, done.
remote: Total 1583 (delta 0), reused 0 (delta 0), pack-reused 1583
Receiving objects: 100% (1583/1583), 4.11 MiB | 1.92 MiB/s, done.
Resolving deltas: 100% (520/520), done.
```  

3、通过如下命令在所有集群节点上自动安装、部署完成lxcfs  
```
# kubectl apply -f lxcfs-initializer.yaml
# 查看 pod 运行是否正常
# kubectl get pod
NAME                               READY    STATUS     RESTARTS   AGE
ceph-pod1                          1/1      Running    5          4d1h
curl-66959f6557-8h4ll              1/1      Running    0          6d2h
lxcfs-initializer-769d7fb857-p6p45 1/1      Running    2          15m
nginx-test1-6d7fd56775-m2rzc       1/1      Running    0          111m
nginx-test2-95c548cd4-68gzc        1/1      Running    0          112m
nginx-test2-95c548cd4-ds9hf        1/1      Running    0          112m
```  

4、测试：kubectl apply -f web.yaml      #其他pod如果需要隔离资源，请确保lxcfs值为true  
```
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
  "initializer.kubernetes.io/lxcfs": "true"
  labels:
    app: web
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  teplate:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: httpd:2.4.32
          imagePullPolicy: Always
          resources:
            requests:
              memory: "256Mi"
              cpu: "500m"
            limits:
              memory: "256Mi"
              cpu: "500m"
```  
