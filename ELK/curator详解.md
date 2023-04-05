
# 添加配置`curator.yml`

- [configfile配置参考官方](https://www.elastic.co/guide/en/elasticsearch/client/curator/8.0/configfile.html)
```
$ mkdir ~/.curator
$ vim curator.yml 
---
client:
  hosts:                     # 需要处理的主机如下，必须是一个集群，不能同时处理多个集群
    - 127.0.0.1
    - x.x.x.x
    - 127.0.0.1:9200         # 如果集群中ES端口号不一样,可以指定端口号
    - x.x.x.x:9201
  port:                      # ES 集群的端口号，如果上方指定后，这里空出就好
  url_prefix:                # 如访问ES需要通过域名加路径来访问，这里就写域名加路径
  use_ssl: False             # 如果使用了https来访问则设置为True，否则为False
# 如果use_ssl的值为True，则需要设置以下三项
  certificate:               # ca证书路径
  client_cert:               # 客户端证书路径，pem格式
  client_key:                # 客户端密钥，pem格式
  
  ssl_no_validate: False     # 如果ES集群使用了ssl证书，但不需要去验证，则改为True来禁用ssl，否则为False
  username:                  # 访问ES使用到的用户名
  password:                  # 访问ES使用到的密码
  timeout: 30                # 连接超时的值
  master_only: False         # 当执行curator命令时，该值为True则不允许执行该配置文件中指向的节点

logging:
# 设置要显示的最低可接受日志严重性
# CRITICAL 将只显示关键消息。
# ERROR 将只显示错误和关键消息。
# WARNING 将显示错误、警告和关键消息。
# INFO 将显示信息、错误、警告和关键消息。
# DEBUG 除了上述所有信息外，还将显示调试消息。
  loglevel: INFO
  logfile: /var/log/es-curator/curator.log    # 日志文件的路径，默认为空
  logformat: default                          # 日志格式：json/logstash/ecs/default
  blacklist: ['elasticsearch', 'urllib3']     # 黑名单，不输出elasticsearch和urllib3，这两个python模块的日志，没有必要或者不了解，默认值即可。
```

# 创建日志目录
```
mkdir /var/log/es-curator
```

# action.yml

- 该文件用作如何操作 ES 集群，会根据 ES 的索引来做删除的动作，使用以下命令查看 ES 中的索引。
```
curator_cli show-indices
# 默认读取~/.curator/curator.yml中的ES服务器
# 也可以通过--host和--port指定es服务器
# 也可以通过--config重新指定其他位置的配置
```

action.yml配置包含四个部分:
- action 操作
- description 描述
- options 参数
- filters 匹配方式

# 定义删除动作


```
$ vim ~/.curator/action.yml
action: delete_indices                # delete_indices为删除索引的关键字
description: "只保留ES两天的数据"       # description可选
options:
  continue_if_exception: True         # 发现错误后，继续执行下一个索引操作
  ignore_empty_list: True             # 为true表示filters为空列表时，继续下一个action，而不是退出
  timeout_override: 300               # 必须是整秒数，用来防止轮询超时
  disable_action: False               # action开关，为True表示不执行这个action，默认False

# 以下即是根据过滤索引来选择操作哪些数据
# 如：我的索引为feiyi-2021.09.01
filters:
- filtertype: kibana                  # 是否排除隐藏索引，如.kibana
      exclude: True
- filtertype: opened                  # 是否排除open状态的索引
      exclude: True
# 索引前缀匹配feiyi-
- filtertype: pattern
  kind: prefix                        # 指定kind为prefix来匹配前缀
  value: feiyi-                       # 前缀值为"feiyi-"
  # exclude为true是删除，false为保留
  # exclude: False
# 处理2天前的索引(匹配后缀索引日期)
- filtertype: age                   # 匹配时间
  source: name                      # 匹配索引的名字中的日期格式
  direction: older                  # 此设置必须为older或者younger，没有默认值
  timestring: '%Y.%m.%d'            # 匹配索引名字中的时间戳的格式
  unit: days                        # 指定计算日期的单位,这里定义的是days，还有weeks，months等，总时间为unit * unit_count
  unit_count: 2                     # 作为unit的乘数
```

# 多个action的格式如下

```
actions:
    1:
      action:
      ...
    2: 
      action:
      ...
    3:
      action:
      ...
```

# 以下是我实际使用的配置

```
actions:
    1:
      action: delete_indices
      description: "Delete exchange-app-api"
      options:
        continue_if_exception: False
        ignore_empty_list: True
        timeout_override: 300
      filters:
      - filtertype: pattern
        kind: prefix
        value: sbox-exchange-app-api-
      #  exclude: False
      - filtertype: age
        source: name
        direction: older
        timestring: '%Y.%m.%d'
        unit: days
        unit_count: 2
      #  exclude: False
    2:  
      action: delete_indices
      description: "Delete sbox-operate-web-"
      options:
        continue_if_exception: False
        ignore_empty_list: True
        timeout_override: 300
      filters:
      - filtertype: pattern
        kind: prefix
        value: sbox-operate-web-
      #  exclude: False
      - filtertype: age
        source: name
        direction: older
        timestring: '%Y.%m.%d'
        unit: days
        unit_count: 2
      #  exclude: False

    3:  
      action: delete_indices
      description: "Delete sbox-operate-web-"
      options:
        continue_if_exception: False
        ignore_empty_list: True
        timeout_override: 300
      filters:
      - filtertype: pattern
        kind: prefix
        value: sbox-operate-web-
      #  exclude: False
      - filtertype: age
        source: name
        direction: older
        timestring: '%Y.%m.%d'
        unit: days
        unit_count: 2
      #  exclude: False
```

# 执行删除操作
```
curator --config ~/.curator/curator.yml ~/.curator/action.yml 
```

# 定时任务
```
crontab -e
# 每天中午12执行任务
0 12 * * * /usr/local/bin/curator --config ~/.curator/curator.yml ~/.curator/action.yml
```

[参考](https://www.feiyiblog.com/2021/09/01/elasticsearch%E5%8F%AA%E4%BF%9D%E7%95%99%E5%BD%93%E5%A4%A9%E7%9A%84%E6%95%B0%E6%8D%AE/)
