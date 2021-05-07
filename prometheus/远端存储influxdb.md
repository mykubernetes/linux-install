官网：https://docs.influxdata.com/influxdb/v1.7/supported_protocols/prometheus/

在influxdb中创建一个prometheus的库
```
curl -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE prometheus"
```

修改Prometheus容器中的prometheus.yml配置对接adapter
```
# /etc/prometheus/prometheus.yml
remote_write:
  - url: "http://influxdb:8086/api/v1/prom/write?db=prometheus"
remote_read:
  - url: "http://influxdb:8086/api/v1/prom/read?db=prometheus"
```

prometheus重新加载配置
```
kill -HUP 1	# 1是prometheus的进程id
```
