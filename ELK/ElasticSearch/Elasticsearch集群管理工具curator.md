# 介绍

- Curator 是一个elasticsearch集群管理工具，在日常集群管理方面的一个利器，掌握此神器，es集群日常管理将轻松+愉快。

# 功能介绍
```
创建索引
删除索引
关闭索引
删除快照
从快照还原
添加或移除索引
打开已经关闭的索引
更改分片路由配置
强制合并索引
更改索引每个分片的副本数量
为索引创建快照
reindices 、remote reindices
rollover indices(当某个别名指向的实际索引过大的时候，自动将别名指向下一个实际索引)
等等。。。。。
```


# 安装配置（centos7）

1、install the public signing key:
```
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch   
```


2、添加repo 文件
```
cat >/etc/yum.repos.d/es-curator.repo <<-EOF
[curator-5]
name=CentOS/RHEL 7 repository for Elasticsearch Curator 5.x packages
baseurl=https://packages.elastic.co/curator/5/centos/7
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF
```

3、安装
```
yum install elasticsearch-curator -y   
```

# curator的接口 介绍

- curator提供了两种接口。一个是curator_cli 命令行模式 ，一个是curator API 模式。  

## 一、curator_cli 命令行模式介绍

1、查看帮助
```
$ curator_cli --help
Usage: curator_cli [OPTIONS] COMMAND [ARGS]...

Options:
  --config PATH       Path to configuration file. Default:
                      ~/.curator/curator.yml
  --host TEXT         Elasticsearch host.
  --url_prefix TEXT   Elasticsearch http url prefix.
  --port TEXT         Elasticsearch port.
  --use_ssl           Connect to Elasticsearch through SSL.
  --certificate TEXT  Path to certificate to use for SSL validation.
  --client-cert TEXT  Path to file containing SSL certificate for client auth.
  --client-key TEXT   Path to file containing SSL key for client auth.
  --ssl-no-validate   Do not validate SSL certificate
  --http_auth TEXT    Use Basic Authentication ex: user:pass
  --timeout INTEGER   Connection timeout in seconds.
  --master-only       Only operate on elected master node.
  --dry-run           Do not perform any changes.
  --loglevel TEXT     Log level
  --logfile TEXT      log file
  --logformat TEXT    Log output format [default|logstash|json].
  --version           Show the version and exit.
  --help              Show this message and exit.

Commands:
  allocation        Shard Routing Allocation
  close             Close indices
  delete_indices    Delete indices
  delete_snapshots  Delete snapshots
  forcemerge        forceMerge index/shard segments
  open              Open indices
  replicas          Change replica count
  show_indices      Show indices
  show_snapshots    Show snapshots
  snapshot          Snapshot indices
```

2、查看 index
```
# curator_cli --host 10.33.4.160 --port 9200 show_indices --verbos
ptlog-prod-userservice-2018.11.20         open    58.4MB     185964   5   1 2018-11-20T00:00:09Z
ptlog-prod-userservice-2018.11.21         open    58.3MB     185658   5   1 2018-11-21T00:00:12Z
ptlog-prod-userservice-2018.11.22         open    57.5MB     182808   5   1 2018-11-22T00:00:18Z
ptlog-prod-userservice-2018.11.23         open    56.7MB     180296   5   1 2018-11-23T00:00:18Z
```


3、查看 snapshots
```
curator_cli --host 10.33.4.160 --port 9200 show_snapshots --verbose
```

### 过滤特性 （filter）

- 可以根据指定条件匹配，然后指定相应的动作。

1、将30天以前创建的以ptlog开头的index状态为 close
```
curator_cli --host 172.20.11.32 --port 9200 close --filter_list '[{"filtertype":"age","source":"creation_date","direction":"older","unit":"days","unit_count":30},{"filtertype":"pattern","kind":"prefix","value":"ptlog-"}]'
```

验证结果，查看索引信息
```
GET _cat/indices
      green open  15_hot_v1                                    P1FnKd6FRsG7NmnoWZ5hZA 20 1   1780400    59939    1.9gb  981.1mb
      close ptlog-pte-prod-userservice-2018.11.12              LaAHL-KKToqQ30f0dX6pqw                                          
      green open  ptlog-pte-prod-userservice-2018.11.27        bXIzgcrVR1eki8NpehUWcA  5 1     91756        0   57.6mb   28.8mb
      close ptlog-ddv-syslog-2018.10.26                        x4lnrJbbQ_uD4UXR8iXGWw                                          
      green open  ptlog-ddv-trace-2018.12.03                   BrGrgpsYQFOQM0TVHgR-QA  5 1       110        0  896.2kb  438.6kb
      close ptlog-pte-prod-ptservice-2018.11.09                A4Fil2BkRUC70jjcW9iczQ                                          
      close ptlog-pte-prod-userservice-2018.10.24              0eNY0RzYSNuxH5Fm5bpM9A                                          
```
> 发现符合条件的索引状态都调整为 close !   

2、将30天以前创建的以ptlog开头的index状态为删除
```
curator_cli --host 172.20.11.32 --port 9200 delete_indices --filter_list '[{"filtertype":"age","source":"creation_date","direction":"older","unit":"days","unit_count":30},{"filtertype":"pattern","kind":"prefix","value":"ptlog-"}]'
```

输入结果如下：
```
2018-12-12 14:33:57,064 INFO      ---deleting index ptlog-ddv-syslog-2018.10.23
...........
2018-12-12 14:33:57,066 INFO      ---deleting index ptlog-ddv-syslog-2018.11.02
2018-12-12 14:33:57,066 INFO      ---deleting index ptlog-ddv-syslog-2018.10.31
2018-12-12 14:33:57,066 INFO      ---deleting index ptlog-pte-prod-userservice-2018.10.25
```

再次查看索引信息

发现所有 close 状态的索引都被删除了，生产环境推荐这样操作，先关闭一段时间观察，然后再删除数据，毕竟恢复数据比较麻烦。
```
GET _cat/indices
      green open 15_hot_v1                                    P1FnKd6FRsG7NmnoWZ5hZA 20 1   1780726    59943    1.9gb  987.4mb
      green open 6c_hot_v1                                    TIiPrWmaTRCPUShBfVdVIw 20 1  34826911   369431     37gb   18.4gb
      green open ptlog-event-pte-prod-ecology-2018.12.10      FSgH1MFkRbKkR7Y27ugNXA  2 1         0        0      1kb     522b
```


## 二、curator 接口模式使用介绍

1、curator的命令行语法如下：
```
curator [–config CONFIG.YML] [–dry-run] ACTION_FILE.YML
--config: 之后跟上配置文件
--dry-run： 调试参数，测试脚本运行是否正常；
ACTION_FILE.YML: action文件中可以包含一连串的action，curator接口集中式的config和action管理，可以方便我们重用变量，更利于维护和阅读。

环境初始化也可以至通过 curator [--config CONFIG.YML] 直接指定

#### linux 默认查找路径：
~/.curator/curator.yml
```

2、环境初始化也可以至通过 curator [–config CONFIG.YML] 直接指定
```
#### 初始化系统环境，配置 [–config CONFIG.YML]

mkdir -p  ~/.curator/
vim ~/.curator/curator.yml
---
# Remember, leave a key empty if there is no value.  None will be a string,
# not a Python "NoneType"
client:
  hosts:
    - 172.20.11.32                        # 集群节点IP地址，可以写多个
  port: 9200                              # ES端口
  url_prefix:                             # 保持默认
  use_ssl: False                          # 默认即可
  certificate:
  client_cert:
  client_key:
  ssl_no_validate: False
  http_auth:
  timeout: 30
  master_only: False

logging:
  loglevel: INFO                          # 日志级别
  logfile:                                # 输出日志到文件
  logformat: default
  blacklist: ['elasticsearch', 'urllib3']
```

## 重要选项介绍
- **loglevel** 支持：
  - **CRITICAL** will only display critical messages.
  - **ERROR** will only display error and critical messages.
  - **WARNING** will display error, warning, and critical messages.
  - **INFO** will display informational, error, warning, and critical messages.
  - **DEBUG** will display debug messages, in addition to all of the above.

- **logfile** 支持：
  - **default**
  - **json**
  - **logstash**
  - **留空**

- **blacklist** 支持：
  - 那些关键字开头索引日志不输出，默认即可。


## ACTION_FILE.YML 介绍

每个action由三部分组成： 
- action，具体执行什么操作 
- option, 配置哪些可选项 
- filter, 过滤条件，哪些index需要执行action



## 支持的动作
- Alias
- Allocation
- Close
- Cluster Routing
- Create Index
- Delete Indices
- Delete Snapshots
- forceMerge
- Index Settings
- Open
- Reindex
- Replicas
- Restore
- Rollover
- Shrink
- Snapshot


## option: 选项 ,filter:过滤条件，哪些index需要执行action,详细参考官网；
- allocation_type
- continue_if_exception
- count
- delay
- delete_after
- delete_aliases
- disable_action
- extra_settings
- ignore_empty_list
- ignore_unavailable
- include_aliases
- include_global_state
- indices
- key
- max_age
- max_docs
- max_num_segments
- max_wait
- migration_prefix
- migration_suffix
- name
- node_filters
- number_of_replicas
- number_of_shards
- partial
- post_allocation
- preserve_existing-
- refresh
- remote_aws_key
- remote_aws_region
- remote_aws_secret_key
- remote_certificate
- remote_client_cert
- remote_client_key
- remote_filters
- remote_ssl_no_validate
- remote_url_prefix
- rename_pattern
- rename_replacement
- repository
- requests_per_second
- request_body
- retry_count
- retry_interval
- routing_type
- setting
- shrink_node
- shrink_prefix
- shrink_suffix
- slices
- skip_repo_fs_check
- timeout
- timeout_override
- value
- wait_for_active_shards
- wait_for_completion
- wait_interval
- warn_if_no_indices

参考官网: https://www.elastic.co/guide/en/elasticsearch/client/curator/current/actions.html

## filters

### 最常用的filtertype是pattern和age:
- age
- alias
- allocated
- closed
- count
- forcemerged
- kibana
- none
- opened
- pattern
- period
- space
- state


1、定期删除旧index
```
more delete_indices-eslog-ptlog.yml
actions:
  1:
    action: delete_indices
    description: >-
      删除超过20天的索引（基于索引名称），monitoring-*
      前缀索引。如果过滤器没有导致错误，请忽略错误
      可操作的索引列表（ignore_empty_list）并彻底退出.
    options:
      ignore_empty_list: True
      disable_action: False
    filters:
    - filtertype: pattern
      kind: regex
      value: '^(\.monitoring-(es|kibana|logstash)-).*$'
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 20
  2:
    action: delete_indices
    description: >-
      删除超过10天的索引（基于索引名称ptlog）
    options:
      ignore_empty_list: True
      disable_action: False
    filters:
    - filtertype: pattern
      kind: prefix
      value: ptlog
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 10
```
   
2、reindex每天生成的index文件到月index文件

将所有每天生成的ptlog-dd-trace-prod-app-gateway-2018.11.文件汇总到 ptlog-dd-trace-prod-app-gateway-2018.11 月日志文件，然后删除 ptlog-dd-trace-prod-app-gateway-2018.11. 的日志文件。

用于合并琐碎index文件，减少集群分片数；
```
awsesbak-reindex.yml 
---
actions:
  1:
    description: >-
       Reindex 11月份每天生成的index数据到 ptlog-$name-2018.11
    action: reindex
    options:
      disable_action: False
      wait_interval: 9
      max_wait: -1
      request_body:
        source:
          index: REINDEX_SELECTION
        dest:
          index: ptlog-dd-trace-prod-app-gateway-2018.11
    filters:
    - filtertype: pattern
      kind: prefix
      value: ptlog-dd-trace-prod-app-gateway-2018.11.
  2:
    action: delete_indices
    description: >-
       删除已经完成合并的索引
    options:
      ignore_empty_list: True
      disable_action: False
    filters:
    - filtertype: pattern
      kind: prefix
      value: ptlog-dd-trace-prod-app-gateway-2018.11.
```

## 使用crontab定期执行curator

- curator是一个命令行工具，而我们的需要是需要自动化的定期维护，因此需要crontab等工具。一般的linux操作系统都自带crontab。修改/etc/crontab文件
```
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

0 0 * * * root curator --config /opt/curator/config.yml /opt/curator/action.yml
```
