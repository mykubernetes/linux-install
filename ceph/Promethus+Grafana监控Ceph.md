[toc]
# 一、安装grafana
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
# 二、安装promethus
```
1、下载安装包，下载地址
https://prometheus.io/download/
2、解压压缩包
# tar fvxz prometheus-2.14.0.linux-amd64.tar.gz
3、将解压后的目录改名
# mv prometheus-2.13.1.linux-amd64 /opt/prometheus
4、查看promethus版本
# ./prometheus --version
5、配置系统服务启动
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
6、加载系统服务
# systemctl daemon-reload
7、启动服务和添加开机自启动
# systemctl start prometheus
# systemctl enable prometheus
```

# 三、ceph mgr prometheus插件配置
```
# ceph mgr module enable prometheus
# netstat -nltp | grep mgr 检查端口
# curl 127.0.0.1:9283/metrics  测试返回值
```

# 四、配置promethus 
1、在 scrape_configs: 配置项下添加
```
vim prometheus.yml
- job_name: 'ceph_cluster'
    honor_labels: true
    scrape_interval: 5s
    static_configs:
      - targets: ['10.151.30.125:9283']
        labels:
          instance: ceph
          

```
2、重启promethus服务
```
# systemctl restart prometheus
```
3、检查prometheus服务器中是否添加成功
```
# 浏览器-》 http://x.x.x.x:9090 -》status -》Targets
```
# 五、配置grafana
1、浏览器登录 grafana 管理界面  
2、添加data sources，点击configuration--》data sources  
3、添加dashboard，点击HOME--》find dashboard on grafana.com  
4、搜索ceph的dashboard    
5、点击HOME--》Import dashboard, 选择合适的dashboard，记录编号
