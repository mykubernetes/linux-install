prometheus安装
=============
prometheus官网  
https://prometheus.io/  
https://prometheus.io/docs/instrumenting/exporters/#software-exposing-prometheus-metrics  
软件下载地址  
https://prometheus.io/download/  
https://github.com/prometheus  

一、安装后台运行程序  
1、daemonize安装
```
yum install gcc* git wget -y
git clone https://github.com/mykubernetes/daemonize.git
cd daemonize/
sh configure && make && make install
```  
2、prometheus安装  
```
wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz
tar xvf prometheus-2.7.1.linux-amd64.tar.gz -C /opt/prometheus/
cd /opt/prometheus/prometheus-2.7.1.linux-amd64
```
3、修改配置文件
```
# cat prometheus.yml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']

  - job_name: 'pushgatewa'
    static_configs:
    - targets: ['localhost:9091','localhost:9092']

  - job_name: 'node'
    static_configs:
    - targets: ['node01:9100','node02:9100','node03:9100']
```  

4、promehteus配置后台启动  
```
检查配置文件是否正确
# promtool check config /opt/prometheus/prometheus-2.7.1.linux-amd64/prometheus.yml
启动
# cat up.sh
/opt/prometheus/prometheus-2.7.1.linux-amd64/prometheus --web.listen-address="0.0.0.0:9090" --web.read-timeout=5m --web.max-connections=10 --storage.tsdb.retention=15d --storage.tsdb.path="/opt/prometheus/prometheus-2.7.1.linux-amd64/data" --query.max-concurrency=20 --query.timeout=2m

# daemonize -c /opt/prometheus/node_exporter-0.17.0.linux-amd64/ /opt/prometheus/node_exporter-0.17.0.linux-amd64/up.sh

# ps aux |grep prometheus
   root      3479  0.1  3.7 148388 37892 ?        Sl   08:49   0:04 /opt/prometheus/prometheus-2.7.1.linux-amd64/prometheus --web.listen-address=0.0.0.0:9090 --   web.read-timeout=5m --web.max-connections=10 --storage.tsdb.retention=15d --storage.tsdb.path=/opt/prometheus/prometheus-2.7.1.linux-amd64/data --   query.max-concurrency=20 --query.timeout=2m
```  
- --web.listen-address="0.0.0.0:9090"                    #监听地址  
- --web.read-timeout=5m                                      #请求链接的最?等待时间   
- --web.max-connections=10                                #最大链接数  
- --storage.tsdb.retention=15d                             #数据保存期限  
- --storage.tsdb.path="/opt/prometheus/prometheus-2.7.1.linux-amd64/data"     #数据保存目录  
- --query.max-concurrency=20                             #客户端并发执行的查询的最大数量   后边两条属于优化设置  
- --query.timeout=2m                                           #客户端查询语句超时时间  
- --config.file "/etc/prometheus/prometheus.yml"         #手动指定配置文件，默认使用当前路径的，此处为设置
- --web.enable-lifecycle #通过curl -X POST http://localdns:9090/-/reload 方式加载配置，2.0以后默认关闭

5、web展示  
http://192.168.1.70:9090  

二、node_exporter安装配置  
1、node_exporter安装  
```
wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
tar xvf node_exporter-0.17.0.linux-amd64.tar.gz -C /opt/prometheus/
cd /opt/prometheus/node_exporter-0.17.0.linux-amd64
```  
2、配置node_exporter后台启动  
```
# cat up.sh
/opt/prometheus/node_exporter-0.17.0.linux-amd64/node_exporter --collector.systemd --collector.systemd.unit-whitelist=(docker|sshd|nginx).service

# daemonize -c /opt/prometheus/node_exporter-0.17.0.linux-amd64/ /opt/prometheus/node_exporter-0.17.0.linux-amd64/up.sh

# ps aux |grep exporter
   root      3279  0.0  0.1 113180  1212 ?        Ss   09:06   0:00 /bin/sh /opt/prometheus/node_exporter-0.17.0.linux-amd64/up.sh
   root      3280  0.1  1.5 113808 16056 ?        Sl   09:06   0:02 /opt/prometheus/node_exporter-0.17.0.linux-amd64/node_exporter
```  

- --collector.textfile.directory=/var/lib/node_exporter/textfile_collector  #指定文本文件收集器  
- --collector.systemd                                                       #开启系统收集器  
- --collector.systemd.unit-whitelist="(docker|sshd|rsyslog).service"        #白名单，收集的服务  
- --web.listen-address="0.0.0.0:9100"                                       #监听地址  
- --web.telemetry-path="/node_metrics"                                      #网页地址路径  

3、配置文本文件收集器  
```
# mkdir -p /var/lib/node_exporter/textfile_collector
# echo 'metadata{role="docker_server",datacenter="BJ"} 1' | sudo tee /var/lib/node_exporter/textfile_collector/metadata.prom
注：文本文件收集器，默认事加载的，我们只需要指定目录 --collector.textfile.directory=""
```  

4、配置过滤规则,因为node_export收集的数据非常多，可以通过过滤规则匹配出想收集的数据  
https://raw.githubusercontent.com/aishangwei/prometheus-demo/master/prometheus/prometheus.yml  
```
global:
  scrape_interval:     15s 
  evaluation_interval: 15s 

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
  - job_name: 'node'
    static_configs:
    - targets: ['192.168.20.172:9100', '192.168.20.173:9100', '192.168.20.174:9100']
    params:            #过滤参数
      collect[]:
        - cpu
        - meminfo
        - diskstats
        - netdev
        - netstat
        - filefd
        - filesystem
        - xfs
        - systemd
```  
5、web展示  
http://192.168.1.70:9100  

三、pushgageway安装部署  
1、pushgageway安装部署  
```
wget  https://github.com/prometheus/pushgateway/releases/download/v0.7.0/pushgateway-0.7.0.linux-amd64.tar.gz
tar xvf  pushgateway-0.7.0.linux-amd64.tar.gz -C /opt/prometheus/
cd /opt/prometheus/pushgateway-0.7.0.linux-amd64/
```  
2、pushgageway后台启动
```
# cat up.sh
/opt/prometheus/pushgateway-0.7.0.linux-amd64/pushgateway  --web.listen-address="0.0.0.0:9091" --persistence.file="/tmp/pushgateway.data"

# daemonize -c /opt/prometheus/pushgateway-0.7.0.linux-amd64 /opt/prometheus/pushgateway-0.7.0.linux-amd64/up.sh

# ps aux |grep pushgateway
root      4080  0.0  0.1 113180  1212 ?        Ss   10:10   0:00 /bin/sh /opt/prometheus/pushgateway-0.7.0.linux-amd64/up.sh
root      4081  0.0  0.7 111312  7976 ?        Sl   10:10   0:00 /opt/prometheus/pushgateway-0.7.0.linux-amd64/pushgateway --web.listen-address=0.0.0.0:9092
```  
--persistence.file="/tmp/pushgateway.data"    #数据持久保存文件内，不指定则保存在内存中，重启丢失  

3、prometheus添加pushgageway主机，使用文件发现方式
```
# cat /etc/prometheus.yml
……
- job_name: pushgateway
  honor_labels: true
  file_sd_configs:
    - files:
      - targets/pushgateway/*.json
    refresh_interval: 5m

发现主机
# cat targets/pushgateway/push.json
[{
 "targets": ["192.168.101.67:9091"]
}]
```

4、脚本编写  
```
# cat node_exporter_shell.sh
#/bin/bash
instance_name=`hostname -f |cut -d'.' -f1`
if [ $instance_name == "localhost" ]; then
echo "Must FQDN hostname"
exit 1
fi

#For waitting connections

label="count_netstat_wait_connections"
count_netstat_wait_connections=`netstat -an |grep -i wait|wc -l`
echo "$label : $count_netstat_wait_connections"

echo "$label  $count_netstat_wait_connections" | curl --data-binary @- http://192.168.1.70:9091/metrics/job/pushgateway/instance/$instance_name
```  
5、配置脚本每15秒检查一次  由于计划任务是每分钟执行一次所以定义多个  
```
#chmod +x node_exporter_shell.sh
# crontab -l
* * * * * /usr/bin/sleep 15 ; /opt/node_exporter_shell.sh
* * * * * /usr/bin/sleep 30 ; /opt/node_exporter_shell.sh
* * * * * /usr/bin/sleep 45 ; /opt/node_exporter_shell.sh
* * * * * /usr/bin/sleep 60 ; /opt/node_exporter_shell.sh
```  

6、删除数据大写字母为监控数据值  
删除某个组下的某实例的所有数据：  
``` curl -X DELETE http://192.168.1.70:9091/metrics/job/JOB_NAME/instance/HOME_NAME ```  

删除某个组下的所有数据：  
``` curl -X DELETE http://pushgateway.example.org:9091/metrics/job/JOB_NAME ```  

``` 格式如下： /metrics/job/<jobname>{/<label>/<label>} ```  

四、grafana安装  
官网  
https://grafana.com/grafana/download  
1、grafana下载  
```
# wget https://dl.grafana.com/oss/release/grafana-5.4.3-1.x86_64.rpm 
# yum install grafana-5.4.3-1.x86_64.rpm 
# systemctl start grafana-server
```  

2、web展示  
192.168.1.70:3000  
admin/admin  


五、安装配置 blackbox exporter  
Prometheus探测工作是通过运行一个blackbox exporter——来探测远程目标，并公开在本地端点上收集的任何时间序列。  

1、安装blackbox exporter  
``` 
# wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.12.0/blackbox_exporter-0.12.0.linux-amd64.tar.gz
# tar xf blackbox_exporter-0.12.0.linux-amd64.tar.gz
# cp blackbox_exporter-0.12.0.linux-amd64/blackbox_exporter /usr/local/bin/
# blackbox_exporter --version
```  

2、配置blackbox exporter  
```
# mkdir -pv /etc/prober
# cat /etc/prober/prober.yml
modules:
  http_2xx_check:
    prober: http
    timeout: 5s
    http:
      valid_status_codes: []
      method: GET
  icmp_check:
    prober: icmp
    timeout: 5s
    icmp:
      preferred_ip_protocol: "ip4"
  dns_examplecom_check:
    prober: dns
    dns:
      preferred_ip_protocol: "ip4"
      query_name: "www.huy.cn"
```  

3、启动  
``` # blackbox_exporter --config.file="/etc/prober/prober.yml" ```  

4、prometheus添加配置文件  
```
# cat /etc/prometheus/prometheus.yml
……
scrape_configs:
  - job_name: 'http_probe'
    metrics_path: /probe
    params:
      module: [http_2xx_check]
    file_sd_configs:
      - files:
        - 'targets/probes/http_probes.json'
        refresh_interval: 5m
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
         replacement: 192.168.101.67:9115

自动发现主机（远端探测地址）
# cat /etc/prometheus/targets/probes/http_probes.json
[{
  "targets": [
    "http://node02"
  ]
}]
```  

注：  
• 我们的第一个relabel通过将__address__标签(当前目标地址)写入__param_target标签来创建一个参数。  
• 第二个relabel将__param_target标签写为实例标签。  
• 最后，我们使用我们的出口商的主机名(和端口)重新标记__address__标签，在我们的例子中是node02  



六、安装配置Alertmanager  
1、安装Alertmanager  
```
# wget https://github.com/prometheus/alertmanager/releases/download/v0.15.2/alertmanager-0.15.2.linux-amd64.tar.gz
# tar xf alertmanager-0.15.2.linux-amd64.tar.gz
# cp alertmanager-0.15.2.linux-amd64/{alertmanager,amtool} /usr/local/bin/
# alertmanager --version
```  

2、配置Alertmanager  
```
# mkdir -pv /etc/alertmanager
# cat /etc/alertmanager/alertmanager.yml
global:
  smtp_smarthost: 'smtp.126.com:25'
  smtp_from: 'xxxxxx@126.com'
  smtp_auth_username: 'xxxxxx@126.com'
  smtp_auth_password: ‘xxxxxx'
  smtp_require_tls: false

route:
  group_by: ['instance']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: email
  routes:
  - match:
      severity: critical
    receiver: email
  - match_re:
      severity: ^(warning|critical)$
    receiver: support_team

receivers:
- name: 'email'
  email_configs:
  - to: '756686600@qq.com'
- name: 'support_team'
  email_configs:
  - to: '995595198@qq.com'
- name: 'pager'
  email_configs:
  - to: 'alert-pager@example.com'
```  
- group_by: 根据 labael(标签)进行匹配，如果是多个，就要多个都匹配
- group_wait: 30s 等待该组的报警，看有没有一起合伙搭车的
- group_interval: 5m 下一次报警开车时间
- repeat_interval: 3h 重复报警时间


3、启动alertmanager  
```
# alertmanager --config.file alertmanager.yml
```  
打开浏览器 http://192.168.101.69:9093

4、配置prometheus配置文件添加告警  
```
alerting:
alertmanagers:
- static_configs:
- targets:
- 192.168.101.69:9093
```  

5、在prometheus上添加对alertmanager的监控  
```
  - job_name: 'alertmanager'
    static_configs:
    - targets: ['192.168.101.69:9093']
```  

6、在prometheus添加告警规则  
```
# vim /etc/prometheus/rules/node_alerts.yml
groups:
- name: node_alerts
  rules:
  - alert: HighNodeCPU
    expr: instance:node_cpu:avg_rate5m > 4
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: High Node CPU for 1 hour       console: Thank you Test
  - alert: DiskWillFillIn4Hours
    expr: predict_linear(node_filesystem_free_bytes{mountpoint="/"}[1h], 4*3600) < 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: Disk on {{ $labels.instance }} will fill in approximately 4 hours.
  - alert: InstanceDown
    expr: up{job="node"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: Host {{ $labels.instance }} of {{ $labels.job }} is Down!

#prometheus重载配置告警，和altertmanagers服务宕机告警
- name: prometheus_alerts
  rules:
  - alert: PrometheusConfigReloadFailed
    expr: prometheus_config_last_reload_successful == 0
    for: 1m
    labels:
      severity: warning
    annotations:
      description: Reloading Prometheus configuration has failed on {{ $labels.instance }}.
  - alert: PrometheusNotConnectedToAlertmanagers
    expr: prometheus_notifications_alertmanagers_discovered < 2
    for: 1m
    labels:
      severity: warning
    annotations:
      description: Prometheus {{ $labels.instance }} is not connected to any Alertmanagers

#添加systemd服务告警
- name: service_alerts
  rules:
  - alert: NodeServiceDown
    expr: node_systemd_unit_state{state="active"} != 1
    for: 10s
    labels:
      severity: critical
    annotations:
      summary: Service {{ $labels.name }} on {{ $labels.instance }} is no longer active!
      description: 监控中心向您报告：- " 挨踢的，您的服务挂了？"
```  
- {{ $labels.instance }} 获取告警信息的标签instance的标签
- {{ $labels.job }} 获取告警信息的标签job的标签

7、把告警规则加入prometheus配置文件  
```
# cd /etc/prometheus/rules
# vim node_alertes.yml
……
rule_files:
  - "rules/*_rules.yml"
  - "rules/*_alerts.yml"
……
```  
webhook告警参考官方文档  
https://prometheus.io/docs/alerting/configuration/#webhook_config  
