```
# 参考链接：https://www.elastic.co/guide/en/elasticsearch/client/curator/current/yum-repository.html

# 安装 curator 服务，以 centos7 为例
$ rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

$ vim /etc/yum.repos.d/elk-curator-5.repo

[curator-5]
name=CentOS/RHEL 7 repository for Elasticsearch Curator 5.x packages
baseurl=https://packages.elastic.co/curator/5/centos/7
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1

$ yum install elasticsearch-curator -y

# 创建 curator 配置文件目录与输出日志目录
$ mkdir -p /data/ELKStack/curator/logs
$ cd /data/ELKStack/curator

$ vim config.yml

---
# Remember, leave a key empty if there is no value.  None will be a string,
# # not a Python "NoneType"
client:
  hosts: ["172.20.166.25", "172.20.166.24", "172.20.166.22", "172.20.166.23", "172.20.166.26"]
  port: 9200
  url_prefix:
  use_ssl: False
  certificate:
  client_cert:
  client_key:
  ssl_no_validate: False
  http_auth: elastic:elastic123
  timeout: 150
  master_only: False

logging:
  loglevel: INFO
  logfile: /data/ELKStack/curator/logs/curator.log
  logformat: default
  blacklist: ['elasticsearch', 'urllib3']

$ vim action.yml

---
# Remember, leave a key empty if there is no value.  None will be a string,
# not a Python "NoneType"
#
# Also remember that all examples have 'disable_action' set to True.  If you
# want to use this action as a template, be sure to set this to False after
# copying it.
actions:
  1:
    action: delete_indices
    description: >-
      Delete indices older than 30 days. Ignore the error if the filter does not result in an actionable list of indices (ignore_empty_list) and exit cleanly.
    options:
      ignore_empty_list: True
      disable_action: False
    filters:
    - filtertype: pattern
      kind: regex
      value: '^((?!(kibana|json|monitoring|metadata|apm|async|transform|siem|security)).)*$'
    - filtertype: age
      source: creation_date
      direction: older
      #timestring: '%Yi-%m-%d'
      unit: days
      unit_count: 30
  2:
    action: delete_indices
    description: >-
      Delete indices older than 15 days. Ignore the error if the filter does not result in an actionable list of indices (ignore_empty_list) and exit cleanly.
    options:
      ignore_empty_list: True
      disable_action: False
    filters:
    - filtertype: pattern
      kind: regex
      value: '^(nginx-).*$'
    - filtertype: age
      source: creation_date
      direction: older
      #timestring: '%Yi-%m-%d'
      unit: days
      unit_count: 15

# 设置定时任务清理es索引
$ crontab -e

0 0 * * * /usr/bin/curator --config /data/ELKStack/curator/config.yml /data/ELKStack/curator/action.yml
```
