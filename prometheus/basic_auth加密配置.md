# 一、basic_auth加密的引入

平常使用prom都是没有加密的安全措施的，有一些节点直接暴漏在公网上了，不安全。现在使用basic_auth加密，可以加个密码，安全一些。

# 二、使用步骤

## 1.生成basic_auth密钥

> 安装工具包并生成加密后密码
```
#安装工具包
yum install -y httpd-tools
#生成加密密码
htpasswd -nBC 12 '' | tr -d ':\n'
New password:               # 这里设置密码为123456，实际使用请按照自己的集群需求定义密码
Re-type new password:
#生成的密码信息
$2y$12$mMnPuKlOQ97ff4NjDsQTMukAtRS/ILpjxjEQrCN0vefs0CBLe/hi6
```

## 2.将密钥文件写入config.yml文件内

> 准备配置文件
```
cat > ./config.yml<<eof
basic_auth_users:
  # 当前设置的用户名为admin， 可以设置多个
  admin: $2y$12$mMnPuKlOQ97ff4NjDsQTMukAtRS/ILpjxjEQrCN0vefs0CBLe/hi6
```

## 3.查看prometheus相关参数

> 查看prometheus配置项
```
prometheus --help
	--web.config.file=""       [EXPERIMENTAL] Path to configuration file that can enable TLS or authentication.
```

在运行时增加- -web.config.file配置即可启用加密

## 4.修改prometheus配置
修改配置，增加basic_auth配置
```
scrape_configs:
  - job_name: 'prometheus'
    basic_auth:
      username: admin
      password: 123456
    static_configs:
    - targets: ['prometheus:9090']
```

## 5.启动服务

### 5.1 service模式

> 修改/usr/lib/systemd/system/prometheus.service文件，在ExecStart后面追加–web.config.file=/xx/xx/xx/config.yml

例：
```
cat /usr/lib/systemd/system/prometheus.service 

[Unit]
  Description=https://prometheus.io

  [Service]
  Restart=on-failure
  ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml --web.config.file=/usr/local/prometheus/config.yml

  [Install]
  WantedBy=multi-user.target
```

## 5.2 docker模式

> 修改镜像，在服务启动脚本命令内增加–web.config.file配置，

例：
```
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles", \
             "--web.config.file=/etc/prometheus/config.yml" ]
```

镜像制作完毕之后，在启动容器时，将config.yml传递到/etc/prometheus/config.yml位置即可
```
  prometheus:
    image: prometheus:1
    volumes:
      - type: bind
        source: ./xxx/xxx/config.yml
        target: /etc/prometheus/config.yml
        read_only: true
```

