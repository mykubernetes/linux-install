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

6、检查prometheus服务器中是否添加成功
```
# 浏览器-》 http://x.x.x.x:9090 -》status -》Targets
```

grafana 安装  
---
官方下载：https://grafana.com/grafana/download  

1、安装
```
1、配置yum源文件
# vim /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt

2.通过yum命令安装grafana
# yum -y install grafana

3.启动grafana并设为开机自启
# systemctl start grafana-server.service 
# systemctl enable grafana-server.service
```

2、打开浏览器  
```
192.168.101.66:3000  
```

3、设置数据源  
```
1、浏览器登录 grafana 管理界面 http://192.168.101.66:9090  
2、添加data sources，点击configuration--》data sources
3、添加dashboard，点击HOME--》find dashboard on grafana.com
4、搜索ceph的dashboard
5、点击HOME--》Import dashboard, 选择合适的dashboard，记录编号
```

4、导入模板  
```
Ceph-Cluster：[ID: 2842]  
Ceph-OSD: [ID: 5336]  
Ceph-Pools: [ID: 5342]  
https://grafana.com/orgs/galexrt  
```



https://github.com/krakendash/krakendash

calamari  
https://www.cnblogs.com/gaohong/p/4669524.html


使用 Prometheus 监控 Ceph  
https://www.jianshu.com/p/f0fae97d9349

https://www.jianshu.com/p/0dcdbc1135bd
