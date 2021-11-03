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

```
#根据索引名称排序
- filtertype: space
  disk_space: 0.001
  reverse: True
#根据索引创建的时间排序
- filtertype: space
  disk_space: 0.001
  use_age: True
  source: creation_date
#根据索引名称获取时间排序
- filtertype: space
  disk_space: 0.001
  use_age: True
  source: name
  timestring: '%Y-%m-%d'
#根据索引时间字段的最小值排序
- filtertype: space
  disk_space: 0.001
  use_age: True
  source: field_stats
  field: logtime
  stats_result: min_value
```
```
- filtertype: space
  disk_space: 100
  reverse: True
  use_age: False
  source: creation_date
  timestring:
  field:
  stats_result:
  exclude: False
```
- disk_space: 设置一个临界值，单位为gb，当匹配的索引数据总和与这个临界值进行比较
- reverse: 默认为True,可以这样理解，True时索引按名称倒序，删除时从后往前删。False时索引按名称顺序，删除时也是从后往前删。如果配置了use_age为True时这个配置就被忽略了。
- user_age: 这个就与action.yml样例类似，根据日期来确定哪些数据为老数据
- source: 从哪里来获取索引时间。当user_age为True时，该配置为必填项。可以为name、creation_date、field_stats
  - name: 来源为索引名称，此时必须指定timestring来匹配索引名称中的日期
  - creation_date: 来源为索引的创建时间，ES内部会保存每个索引创建的具体时间，可通过 http://127.0.0.1:9200/zou_data*?pretty 查看。
  - filed_stats: 来源为索引数据中某个日期字段，这个字段必须时ES能识别的日期字段，Curator会通过ES API获取每个索引中这个字段的最大值跟最小值。
- timestring: 当source为name时必须配置，用于匹配索引名称中的日期，如 '%Y-%m-%d'
- field: 当source为field_stats时必须配置，用于指定索引中的日期字段，默认@timestamp字段
- stats_result: 只有当source为field时才需配置，用于指定永min_value 还是max_value ,默认为min_value 
- exclude： 是否需要排除，为True表示该filter匹配到的内容不执行action操作



delete_indices标识执行的动作为删除索引，action参考：  
https://www.elastic.co/guide/en/elasticsearch/client/curator/current/actions.html

ignore_empty_list：是否忽略错误空列表，option参考：  
https://www.elastic.co/guide/en/elasticsearch/client/curator/current/option_ignore_empty.html

```
actions:
  1:
    action: delete_indices
    description: >-
      Delete metric indices older than 3 days (based on index name), for
      .monitoring-es-6-
      .monitoring-kibana-6-
      .monitoring-logstash-6-
      .watcher-history-3-
      prefixed indices. Ignore the error if the filter does not result in an
      actionable list of indices (ignore_empty_list) and exit cleanly.
    options:
      ignore_empty_list: True
 #     disable_action: True
    filters:
    - filtertype: pattern
      kind: regex
      value: '^(\.monitoring-(es|kibana|logstash)-6-|\.watcher-history-3-).*$'
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 3

  2:
    action: close
    description: >-
      Close indices older than 30 days (based on index name), for syslog-
      prefixed indices.
    options:
      ignore_empty_list: True
      delete_aliases: False
#      disable_action: True
    filters:
    - filtertype: pattern
      kind: prefix
      value: syslog-
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 30

  3:
    action: forcemerge
    description: >-
      forceMerge syslog- prefixed indices older than 2 days (based on indexcreation_date) to 2 segments per shard.  Delay 120 seconds between each forceMerge operation to allow the cluster to quiesce. Skip indices that have already been forcemerged to the minimum number of segments to avoid reprocessing.
    options:
      ignore_empty_list: True
      max_num_segments: 2
      delay: 120
      timeout_override:
      continue_if_exception: False
    filters:
    - filtertype: pattern
      kind: prefix
      value: syslog-
      exclude:
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 2
    - filtertype: forcemerged
      max_num_segments: 2
      exclude:
```
