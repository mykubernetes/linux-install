# 设置Cassandra登录密码

1.修改配置文件 cassandra.yaml
```
authenticator: AllowAllAuthenticator改为authenticator: PasswordAuthenticator
```

2.重启cassandra
```
systemctl restart cassandra
```

3.使用默认用户名cassandra和默认密码cassandra登录
```
cqlsh -ucassandra -pcassandra
```

3.创建用户
```
CREATE USER myusername WITH PASSWORD 'mypassword' SUPERUSER ;               #（NOSUPERUSER | SUPERUSER）
```

4.删除默认帐号
```
DROP USER cassandra;                        # 为了安全
```

# 设置无密码登录

1、编辑~/.cassandra/cqlshrc文件，加入下面代码，可以无密码登录CQLSH
```
vim ~/.cassandra/cqlshrc
[authentication]
username = root
password = 123456
```

2、登录
```
cqlsh 192.168.101.69 -u root
```
