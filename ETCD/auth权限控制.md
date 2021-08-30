# 1. ETCD资源类型

There are three types of resources in etcd
- permission resources: users and roles in the user store
- key-value resources: key-value pairs in the key-value store
- settings resources: security settings, auth settings, and dynamic etcd cluster settings (election/heartbeat)

# 2. 权限资源

**Users**：user用来设置身份认证（user：passwd），一个用户可以拥有多个角色，每个角色被分配一定的权限（只读、只写、可读写），用户分为root用户和非root用户。

**Roles**：角色用来关联权限，角色主要三类：root角色。默认创建root用户时即创建了root角色，该角色拥有所有权限；guest角色，默认自动创建，主要用于非认证使用。普通角色，由root用户创建角色，并分配指定权限。

注意：如果没有指定任何验证方式，即没显示指定以什么用户进行访问，那么默认会设定为 guest 角色。默认情况下 guest 也是具有全局访问权限的。如果不希望未授权就获取或修改etcd的数据，则可收回guest角色的权限或删除该角色，etcdctl role revoke 。

**Permissions**:权限分为只读、只写、可读写三种权限，权限即对指定目录或key的读写权限。

# 3. ETCD访问控制

## 3.1. 访问控制相关命令
```
NAME:
   etcdctl - A simple command line client for etcd.
USAGE:
   etcdctl [global options] command [command options] [arguments...]
VERSION:
   2.2.0
COMMANDS:
   user         user add, grant and revoke subcommands
   role         role add, grant and revoke subcommands
   auth         overall auth controls  
GLOBAL OPTIONS:
   --peers, -C          a comma-delimited list of machine addresses in the cluster (default: "http://127.0.0.1:4001,http://127.0.0.1:2379")
   --endpoint           a comma-delimited list of machine addresses in the cluster (default: "http://127.0.0.1:4001,http://127.0.0.1:2379")
   --cert-file          identify HTTPS client using this SSL certificate file
   --key-file           identify HTTPS client using this SSL key file
   --ca-file            verify certificates of HTTPS-enabled servers using this CA bundle
   --username, -u       provide username[:password] and prompt if password is not supplied.
   --timeout '1s'       connection timeout per request
```

## 3.2. user相关命令
```
# etcdctl user --help
NAME:
   etcdctl user - user add, grant and revoke subcommands
USAGE:
   etcdctl user command [command options] [arguments...]
COMMANDS:
   add      add a new user for the etcd cluster                 # 添加用户
   get      get details for a user                              # 取得用户详情
   list     list all current users                              # 列出所有用户
   remove   remove a user for the etcd cluster                  # 删除用户
   grant    grant roles to an etcd user                         # 给用户分配角色
   revoke   revoke roles for an etcd user                       # 给用户移除角色
   passwd   change password for a user                          # 修改用户密码
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h   show help
```

### 3.2.1. 添加root用户并设置密码
```
etcdctl --endpoints http://172.16.22.36:2379 user add root
```

### 3.2.2. 添加非root用户并设置密码
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user add huwh
```

### 3.2.3. 查看当前所有用户
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user list
```

### 3.2.4. 将用户添加到对应角色
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user grant --roles test1 phpor
```

### 3.2.5. 查看用户拥有哪些角色
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user get phpor
```

## 3.3. role相关命令
```
# etcdctl role --help
NAME:
   etcdctl role - role add, grant and revoke subcommands
USAGE:
   etcdctl role command [command options] [arguments...]
COMMANDS:
   add      add a new role for the etcd cluster                  # 添加角色
   get      get details for a role                               # 取得角色信息
   list     list all roles                                       # 列出所有角色
   remove   remove a role from the etcd cluster                  # 删除角色
   grant    grant path matches to an etcd role                   # 为角色设置某个 key 的权限
   revoke   revoke path matches for an etcd role                 # 为角色移除某个 key 的权限
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h   show help
```

### 3.3.1. 添加角色
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:2379 role add test1
```

### 3.3.2. 查看所有角色
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 role list
```

### 3.3.3. 给角色分配权限
```
# etcdctl role grant --help
NAME:
   grant - grant path matches to an etcd role
USAGE:
   command grant [command options] [arguments...]
OPTIONS:
   --path   Path granted for the role to access
   --read   Grant read-only access
   --write  Grant write-only access
   --readwrite  Grant read-write access
```

1、只包含目录
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 role grant --readwrite --path /test1 test1
```

2、包括目录和子目录或文件
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 role grant --readwrite --path /test1/* test1
```

### 3.3.4. 查看角色所拥有的权限
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:2379 role get test1
```

## 3.4. auth相关操作
```
[root@localhost etcd]# etcdctl auth --help
NAME:
   etcdctl auth - overall auth controls
USAGE:
   etcdctl auth command [command options] [arguments...]
COMMANDS:
   enable   enable auth access controls
   disable  disable auth access controls
   help, h  Shows a list of commands or help for one command

OPTIONS:
   --help, -h   show help
```

### 3.4.1. 开启认证
```
etcdctl --endpoints http://172.16.22.36:2379 auth enable
```

# 4. 访问控制设置步骤
| 顺序 | 步骤 | 命令 |
|------|------|-----|
| 1 | 添加root用户 | etcdctl --endpoints http://: user add root |
| 2 | 开启认证 | etcdctl --endpoints http://: auth enable |
| 3 | 添加非root用户 | etcdctl --endpoints http://: –username root: user add |
| 4 | 添加角色 | etcdctl --endpoints http://: –username root: role add |
| 5 | 给角色授权（只读、只写、可读写） | etcdctl --endpoints http://: –username root: role grant --readwrite --path |
| 6 | 给用户分配角色（即分配了角色对应的权限） | etcdctl --endpoints http://: –username root: user grant --roles  |

# 5. 访问认证的API调用

更多参考
- https://coreos.com/etcd/docs/latest/v2/auth_api.html
- https://coreos.com/etcd/docs/latest/v2/authentication.html


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

$ etcdctl --user=root role grant-permission rw_key_ --readwrite key --prefix=true
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
