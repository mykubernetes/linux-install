ElastAlert是一个开源的工具,用于从Elastisearch中检索数据,并根据匹配模式发出告警。  
github项目地址如下:https://github.com/Yelp/elastalert  
官方文档如下:https://elastalert.readthedocs.io/en/latest/elastalert.html  https://elastalert2.readthedocs.io/en/latest/index.html

它支持多种监控模式和告警方式,具体可以查阅Github项目介绍.但是自带的ElastAlert并不支持钉钉告警,在github上有第三方的钉钉python项目。地址如下:https://github.com/xuyaoqiang/elastalert-dingtalk-plugin

ElastAlert 有以下特点：
- 支持多种匹配规则（频率、阈值、数据变化、黑白名单、变化率等）。
- 支持多种告警类型（邮件、HTTP POST、自定义脚本等）。
- 支持用户自定义规则和告警类型。
- 匹配项汇总报警，重复告警抑制，告警失败重试和过期。
- 可用性强，状态信息保存到 Elasticsearch 的索引中。
- 支持调试和审计。


# 使用elastalert2对elk中的日志进行监控及报警

## 环境说明

| 软件 | 版本 |
|------|------|
| elasticsearch | 8.5 |
| python | 3.6.8 |
| elastalert2 | 2.9.0 |

## 软件部署

elastalert2安装

[官网地址](https://elastalert2.readthedocs.io/en/latest/)

安装操作记录
```
# 配置虚拟环境
mkdir -p /data 
cd /data/
git clone https://github.com/jertel/elastalert2.git
cd elastalert2
python3 -m venv elastalert2
source elastalert2/bin/active

# 安装
pip install elastalert2
pip install "setuptools>=11.3"
python setup.py install
```

## config.yaml 配置
```shell
cd examples
cp config.yaml.example config.yaml
vim config.yaml
```

```yaml
# 最简配置，其余配置按需添加
rules_folder: rules  #监控规则存放路径
run_every: #探测间隔
  seconds: 15
buffer_time: #查询时间段
  minutes: 1
es_host: 1.1.1.1 #es配置信息
es_port: 9200
es_username: elastic 
es_password: elastic 
writeback_index: elastalert_status #alert日志
alert_time_limit: #设定时间内，如果告警发送失败，会重新发送 
  days: 2

```shell
mv config.yaml ..
```

## frequency.yaml 配置

```shell
cd rules
cp example_frequency.yaml frequency.yaml
vim frequency.yaml
```

```yaml
# 使用的配置如下。实际使用时可以根据官方文档调整
es_host: 1.1.1.1  #es配置
es_port: 9200 
use_ssl: False
es_username: elastic 
es_password: elastic 
name: 短信发送失败 #监控名称
type: frequency #监控类型
index: index-* #监控索引
num_events: 1 #设定时间内，异常数达到这个值就会报警
timeframe: #累加的时间段。和上一条结合起来表示，在1分钟内有1条数据，就报警
 minutes: 1
filter: #数据匹配规则。使用es的dsl语句。这里的语句是判断日志的message一定要有code和desc关键字，并且message 不等于“code 0 desc 成功”这四个关键字。因为使用了match_phrase查询方式，表示这四个关键字必须相邻而且顺序不变。
#{"query":{"bool":{"must_not":{"match_phrase":{"message":"code 0 message 成功"}}}}}
- bool:
   must_not:
     - match_phrase:
         message: "code 0 desc 成功"
   must:
     - match:
         message: "code desc"
         #message: "code 0 desc 成功"
realert: #设定时间内不重复报警
 minutes: 3
alert: #报警方式，多种选择。这里选择邮件
 - email
#  - command
#command: ["/bin/bash","/bin/sendQywx"]
email: # 接受人
 - "a@e.com"
 - "b@e.com"
 - "c@e.com"
smtp_host: "mail.e.com" #邮件配置
smtp_port: 465
smtp_ssl: true
email_reply_to: "a@e.com"
from_addr: "a@e.com"
smtp_auth_file: "/data/email.yaml"  #这里配置了邮件发送者的账户密码
```

## 启动监控
```shell
# 通过指定脚本启动监控
cd /data/elastalert2/
python -m elastalert.elastalert --verbose --rule frequency.yaml
# 也可以将rule文件全部放在rules路径下，通过以下命令启动
python -m elastalert.elastalert --verbose --rule frequency.yaml

# 在实际使用中，为了方便管理，也可以通过nohup 或者 supervisor 进行后台运行。
# 因为我这里测试机器是centos 7，就直接使用systemctl来进行管理了
vim /usr/lib/systemd/system/elastalert2.service

[Unit]
Description=elastalert
After=syslog.target network.target
Wants=network.target

[Service]
WorkingDirectory=/data/elastalert2/
ExecStart=/data/elastalert2/elastalert/bin/python -m elastalert.elastalert --verbose
Restart=on-failure

[Install]
WantedBy=multi-user.target

systemctl start elastalert2
systemctl status elastalert2
```
