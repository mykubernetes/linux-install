
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

