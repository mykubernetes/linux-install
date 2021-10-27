1.创建用户

```sh
create user wdnmd@'localhost';
8.0之后,不再支持grant一次性创建用户授权了.必须先建用户后授权.
```

2.创建用户并制定密码

```sh
create user wdnmd@'localhost' identified by '123';
```

3.创建用户制定密码并制定加密方式

```sh
create user wdnmd@'localhost' identified with mysql_native_password by '123';
```

4.白名单

```sh
用户名@后面的东西
%            所有
10.0.0.%     该网段
localhost    本地登录
```

5.查询用户

```sh
select user,host,pluginauthentication_string from mysql.user;
查询 用户名，登录方式，加密方式，加密密码
```

6.修改密码

```sh
alter user wdnmd@'localhost' identified by '123456';
```

7.修改加密方式并修改密码

```sh
alter user wdnmd@'localhost' identified with mysql_native_password by '123456';
```

8.用户加锁与解锁

```sh
alter user wdnmd@'localhost' account lock     #加锁
alter user wdnmd@'localhost' account unlock   #解锁
```

9.删除用户

```sh
drop user wdnmd@'localhost';
```
