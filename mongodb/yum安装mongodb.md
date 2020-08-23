1、配置yum源
```
# cd /etc/yum.repos.d
# vim mongodb-org-4.0.repo
[mngodb-org]
name=MongoDB Repository
baseurl=http://mirrors.aliyun.com/mongodb/yum/redhat/7Server/mongodb-org/4.0/x86_64/
gpgcheck=0
enabled=1
```

2、安装
```
# yum -y install mongodb-org
```

3、配置
```
# vim /etc/mongod.conf
bindIp: 172.0.0.1  改为 bindIp: 0.0.0.0
```

4、启动
```
systemctl start mongod.service
systemctl enable mongod.service
```
