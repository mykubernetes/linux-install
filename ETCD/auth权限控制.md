权限命令#
---
可以为 etcd 创建多个用户并设置密码，子命令有：

- add 添加用户
- delete 删除用户
- get 取得用户详情
- list 列出所有用户
- passwd 修改用户密码
- grant-role 给用户分配角色
- revoke-role 给用户移除角色

role
---
可以为 etcd 创建多个角色并设置权限，子命令有：

- add 添加角色
- delete 删除角色
- get 取得角色信息
- list 列出所有角色
- grant-permission 为角色设置某个 key 的权限
- revoke-permission 为角色移除某个 key 的权限

auth
---
开启 / 关闭权限控制

示例
---
```
root用户存在时才能开启权限控制
$ etcdctl auth enable
Error:  etcdserver: root user does not exist

$ etcdctl user add root
Password of root: 
Type password of root again for confirmation: 
User root created

$ etcdctl auth enable
Authentication Enabled

开启权限控制后需要用--user指定用户
$ etcdctl user list
Error:  etcdserver: user name not found

$ etcdctl user list --user=root
Password: 
root

$ etcdctl user get root --user=root
Password: 
User: root
Roles: root

添加用户，前两个密码是新用户的，后一个密码是root的
$ etcdctl user add mengyuan --user=root
Password of mengyuan: 
Type password of mengyuan again for confirmation: 
Password: 
User mengyuan created

使用新用户执行put命令，提示没有权限
$ etcdctl put key1 v1 --user=mengyuan
Password: 
Error:  etcdserver: permission denied

创建名为rw_key_的role，添加对字符串"key"做为前缀的key的读写权限，为mengyuan添加角色
$ etcdctl role add rw_key_ --user=root
Password: 
Role rw_key_ created

$ etcdctl --user=root role grant-permission rw_key_ readwrite key --prefix=true
Password: 
Role rw_key_ updated

$ etcdctl --user=root user grant-role mengyuan rw_key_
Password: 
Role rw_key_ is granted to user mengyuan

添加权限成功后执行put key1成功，执行put k1失败（因为上面只给前缀为"key"的key添加了权限）
$ etcdctl put key1 v1 --user=mengyuan
Password: 
OK

$ etcdctl put k1 v1 --user=mengyuan
Password: 
Error:  etcdserver: permission denied

执行user list命令失败，没有权限
$ etcdctl user list --user=mengyuan
Password: 
Error:  etcdserver: permission denied

为新用户添加root的角色后就能执行user list命令了，注意命令中第一个root是角色，第二个root是用户

$ etcdctl user grant-role mengyuan root --user=root
Password: 
Role root is granted to user mengyuan

$ etcdctl user list --user=mengyuan
Password: 
mengyuan
root
```
