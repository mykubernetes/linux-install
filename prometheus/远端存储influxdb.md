官网：https://docs.influxdata.com/influxdb/v1.7/supported_protocols/prometheus/

获取prometheus连接远端存储的一个插件  
https://github.com/prometheus/prometheus/tree/main/documentation/examples/remote_storage/remote_storage_adapter


1.部署 InfluxDB 时间序列数据库

方文档: https://docs.influxdata.com/influxdb/v1.7
```
docker run -d \
--name influxdb \
-p 8086:8086 \
-v /data/project/influxdb/data:/var/lib/influxdb \
linuxhub/influxdb:1.7.7
```

1.1.创建管理员权限用户
```
# docker exec -it influxdb influx
create user ops with password '12345678' with all privileges
show users
```

1.2. 开启身份认证
```
[http]
  auth-enabled = true
```

1.3. 创建 监控服务账号密码数据
```
# docker exec -it influxdb influx -username=ops -password=12345678
CREATE DATABASE "prometheus_db"
CREATE USER "prometheus_user" WITH PASSWORD '12345678'
GRANT ALL ON "prometheus_db" TO "prometheus_user"

# docker exec -it influxdb influx -username=prometheus_user -password=12345678
Connected to http://localhost:8086 version 1.7.7
InfluxDB shell version: 1.7.7
> show databases;
name: databases
name
----
prometheus_db
```

2. 部署 Prometheus 监控服务

官方文档: https://prometheus.io/docs/prometheus/2.11/storage

```
#!/bin/bash
# author: linuxhub

configure_file=/data/project/prometheus/conf
prometheus_data=/data/project/prometheus/data
chown -R 65534:65534 ${configure_file}
chown -R 65534:65534 ${prometheus_data}

docker run -d \
--name prometheus \
--restart=always \
-p 9090:9090 \
-v ${configure_file}:/etc/prometheus \
-v ${prometheus_data}:/prometheus/data \
linuxhub/prometheus:v2.11.2 \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/prometheus/data \
--web.enable-lifecycle
```


配置文件：conf/prometheus.yml
```
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# 远端存储 数据连接
remote_write:
  - url: "http://10.10.2.100:8086/api/v1/prom/write?db=prometheus_db&u=prometheus_user&p=12345678"
remote_read:
  - url: "http://10.10.2.100:8086/api/v1/prom/read?db=prometheus_db&u=prometheus_user&p=12345678"

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
```

访问地址：http://{IP}:9090


3.部署 chronograf 时序数据可视化

官方文档：https://docs.influxdata.com/chronograf/v1.7
```
docker run -d \
--name chronograf \
-p 8888:8888 \
-v /data/project/chronograf/data:/var/lib/chronograf \
linuxhub/chronograf:1.7.12
```

访问地址: http://{IP}:8888
