prometheus
---
官方参考地址：https://github.com/ceph/cephmetrics  
1、ceph集群启动prometheus模块  
``` # ceph mgr module enable prometheus ```  

2、prometheus安装  
官方下载：https://prometheus.io/download/  

prometheus 下载  
```
# wget https://github.com/prometheus/prometheus/releases/download/v2.9.2/prometheus-2.9.2.linux-amd64.tar.gz
# tar xf prometheus-2.9.2.linux-amd64.tar.gz
# cd cd prometheus-2.9.2.linux-amd64
```  

3、添加主机发现配置
```
# cat prometheus.yml
...
  - job_name: 'ceph'
    honor_labels: true
    file_sd_configs:
      - files:
        - ceph_targets.yml
```  

4、添加ceph主机
```
# cat ceph_targets.yml
[
  {
    "targets": [ "192.168.101.66:9283","192.168.101.67:9283","192.168.101.68:9283" ],
    "labels": {}
  }
]
```  

5、运行  
``` $ nohup ./prometheus --config.file prometheus.yml > /var/log/prometheus.out 2>&1 & ```  

浏览器打开  
http://192.168.101.66:9090  

grafana 安装  
---
官方下载：https://grafana.com/grafana/download  

1、软件下载  
```
# wget https://dl.grafana.com/oss/release/grafana-6.1.4-1.x86_64.rpm
# sudo yum localinstall grafana-6.1.4-1.x86_64.rpm
```  

2、启动服务  
```
# systemctl enable grafana-server
# systemctl start grafana-server
```  

3、设置数据源  
http://192.168.101.66:9090  

4、导入模板  
Ceph-Cluster： [ID: 2842]  
Ceph-OSD: [ID: 5336]  
Ceph-Pools: [ID: 5342]  
https://grafana.com/orgs/galexrt  
