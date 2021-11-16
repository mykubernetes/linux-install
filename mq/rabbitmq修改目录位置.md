# rabbitmq更换数据文件和日志文件的存放位置

1、先创建数据文件和日志文件存放位置的目录并给权限
```
# mkdir -p /usr/local/rabbitmq/mnesia
# mkdir -p /usr/local/rabbitmq/log
# chmod -R 777 /usr/local/rabbitmq
```

2、创建或新增环境参数配置文件
```
vi /etc/rabbitmq/rabbitmq-env.conf
增加如下两行内容
RABBITMQ_MNESIA_BASE=/usr/local/rabbitmq/mnesia
RABBITMQ_LOG_BASE=/usr/local/rabbitmq/log
```
保存，重启rabbitmq服务
