prometheus
---
官方参考地址：https://github.com/ceph/cephmetrics  
1、ceph集群启动prometheus模块  
```
# ceph mgr module enable prometheus
# netstat -nltp | grep mgr 检查端口
# curl 127.0.0.1:9283/metrics  测试返回值
```  

2、prometheus安装  
官方下载：https://prometheus.io/download/  

1)prometheus 下载
```
# wget https://github.com/prometheus/prometheus/releases/download/v2.9.2/prometheus-2.9.2.linux-amd64.tar.gz
# tar xf prometheus-2.9.2.linux-amd64.tar.gz
# cd prometheus-2.9.2.linux-amd64

# 查看promethus版本
# ./prometheus --version
```

2)配置系统服务启动
```
# vim /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring System
Documentation=Prometheus Monitoring System

[Service]
ExecStart=/opt/prometheus/prometheus \
  --config.file /opt/prometheus/prometheus.yml \
  --web.listen-address=:9090

[Install]
WantedBy=multi-user.target
```

3)加载系统服务
```
# systemctl daemon-reload
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
```
# 启动服务和添加开机自启动
# systemctl start prometheus
# systemctl enable prometheus
```

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

3、打开浏览器  
192.168.101.66:3000  

4、设置数据源  
http://192.168.101.66:9090  

5、导入模板  
Ceph-Cluster：[ID: 2842]  
Ceph-OSD: [ID: 5336]  
Ceph-Pools: [ID: 5342]  
https://grafana.com/orgs/galexrt  




https://github.com/krakendash/krakendash

calamari  
https://www.cnblogs.com/gaohong/p/4669524.html


使用 Prometheus 监控 Ceph  
https://www.jianshu.com/p/f0fae97d9349

https://www.jianshu.com/p/0dcdbc1135bd
