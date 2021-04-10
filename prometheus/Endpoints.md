#### 1. Endpoints

在Prometheus中，有`/-/healthy`和`/-ready`端点。


可以在测试环境中运行以下命令并检查它们的输出以及它们的HTTP状态码。

```
$ curl -w "%{http_code}\n" http://localhost:9090/-/healthy
Prometheus is Healthy.
200

$ curl -w "%{http_code}\n" http://localhost:9090/-/ready
Prometheus is Ready.
200
```

Prometheus公开了一个/debug/pprof/endpoint, promtool debug pprof命令使用了这个端点


#### 2. Logs
通过`--log.level`选项来设置日志级别。

查看配置的日志级别：
```
$ sudo systemctl cat prometheus.service
ExecStart=/usr/bin/prometheus \
    --log.level=debug \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/data \
    --web.console.templates=/usr/share/prometheus/consoles \
    --web.console.libraries=/usr/share/prometheus/console_libraries
```

```
$ sudo service node-exporter stop
$ sudo journalctl -fu prometheus | grep debug
Feb 23 15:28:14 prometheus prometheus[1438]: level=debug ts=2019-02-23T15:28:14.44856006Z caller=scrape.go:825 component="scrape manager" scrape_pool=node target=http://prometheus:9100/metrics msg="Scrape failed" err="Get http://prometheus:9100/metrics: dial tcp 192.168.42.10:9100: connect: connection refused"
Feb 23 15:28:29 prometheus prometheus[1438]: level=debug ts=2019-02-23T15:28:29.448826505Z caller=scrape.go:825 component="scrape manager" scrape_pool=node target=http://prometheus:9100/metrics msg="Scrape failed" err="Get http://prometheus:9100/metrics: dial tcp 192.168.42.10:9100: connect: connection refused"
```
