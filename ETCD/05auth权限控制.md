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
Password of root: 
Type password of root again for confirmation: 
User root created
```

### 3.2.2. 添加非root用户并设置密码
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user add huwh
Password of huwh: 
Type password of huwh again for confirmation: 
User huwh created
```

### 3.2.3. 查看当前所有用户
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user list
root
huwh
```

### 3.2.4.授予用户对应的 Role 和撤销用户所拥有的 Role（允许部分撤销）
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user grant --roles test1 phpor
```

### 3.2.5. 查看用户拥有哪些角色
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user get phpor
```

### 3.2.6. 修改密码
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user passwd huwh
```

### 3.2.7. 删除用户
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 user delete huwu
****
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

### 3.3.3. 移除某个角色
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 role delete test1
Role test1 deleted
```

### 3.3.4. 给角色分配权限
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

### 3.3.5. 查看角色所拥有的权限
```
etcdctl --endpoints http://172.16.22.36:2379 --username root:123 role get test1
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

# etcd 访问控制实践

## User 相关命令
- 可使用 etcdctl user 子命令来处理与用户相关的操作，比如：

1. 获取所有的 User
```
[root@kano ~]# etcdctl user list
[root@kano ~]# 
```
当前没有任何的User。


2. 创建一个 User
```
# 创建成功
[root@kano ~]# etcdctl user add mea
Password of mea: 
Type password of mea again for confirmation: 
User mea created
[root@kano ~]# 
[root@kano ~]# etcdctl user list
mea
[root@kano ~]#
```

3. 授予用户对应的 Role 和撤销用户所拥有的 Role（允许部分撤销）
```
# 给 mea 添加角色, 但是 super 显然不存在, 这里只是演示命令
[root@kano ~]# etcdctl user grant-role mea super
Error: etcdserver: role name not found
[root@kano ~]#
# 显然是失败的, 因为 super 不是一个角色, 也没有授予用户 mea
[root@kano ~]# etcdctl user revoke-role mea super
Error: etcdserver: role is not granted to the user
[root@kano ~]# 
```

4. 一个用户的详细信息可以通过下面的命令进行获取
```
# 角色为空
[root@kano ~]# etcdctl user get mea
User: mea
Roles:
[root@kano ~]# 
```

5. 修改密码
```
[root@kano ~]# etcdctl user passwd mea
Password of mea: 
Type password of mea again for confirmation: 
Password updated
[root@kano ~]# 
```

6. 删除用户
```
[root@kano ~]# etcdctl user delete mea
User mea deleted
[root@kano ~]#
```

## Role 相关命令
- 与 User 子命令类似，Role 子命令可用来处理与角色相关的操作。可使用 etcdctl 子命令 etcdctl role 来为对应的 Role 角色指定相应的权限，然后将 Role 角色授予相应的 User，从而使 User 具有相应的权限。

1. 列出所有的 Role
```
[root@kano ~]# etcdctl role list
[root@kano ~]#
```

2. 创建一个 Role
```
[root@kano ~]# etcdctl role add common
Role common created
[root@kano ~]#
```

一个角色没有密码，它定义了一组访问权限，etcd 里的角色被授予访问一个或一个范围内的key。这个范围可以由一个区间 `[start-key, end-key]`，其中起始值 start-key 的字典序要小于结束值 end-key。

访问权限可以是读、写或者可读可写，Role 角色能够指定键空间下不同部分的访问权限，不过一次只能设置一个 path 或 一组path（使用前缀 + * 来表示，相当于以某个字符串为开头）的访问权限。

3. 授予对某个 key 只读权限
```
# 授予 name的只读权限
[root@kano ~]# etcdctl role grant-permission common read name
Role common updated
[root@kano ~]# 
```

4. 授予对一个范围的 key 只写权限
```
# 授予 a 开头的key的只写权限
[root@kano ~]# etcdctl role grant-permission common write a b
Role common updated
[root@kano ~]# 
```

5. 授予对一组 key 只写权限
```
# 授予 c 开头的key的可读可写权限, 需要加上--prefix
[root@kano ~]# etcdctl role grant-permission common readwrite c --prefix
Role common updated
[root@kano ~]# 
```

6. 查看一个角色具有的权限
```
[root@kano ~]# etcdctl role get common
Role common
KV Read:
	c*
	name
KV Write:
	[a, b) (prefix a)
	c*
[root@kano ~]# 
```

7. 收回一个角色的某个权限
```
# 收回对 c* 进行操作的权限, 这里不需要指定读或写, 显然是读写都收回
[root@kano ~]# etcdctl role revoke-permission common c*
Permission of key c* is revoked from role common
# 对 c* 进行操作的权限已经没了
[root@kano ~]# etcdctl role get common
Role common
KV Read:
	name
KV Write:
	[a, b) (prefix a)
[root@kano ~]# 
# 收回一个本来就没有权限操作的key会报错
[root@kano ~]# etcdctl role revoke-permission common d*
Error: etcdserver: permission is not granted to the role
[root@kano ~]# 
# 只有读或写一种权限也可以, 只要有权限, 在收回的时候就不会报错
[root@kano ~]# etcdctl role revoke-permission common name
Permission of key name is revoked from role common
[root@kano ~]# 
# 可以看到只剩下对 [a, b) 的写权限了
[root@kano ~]# etcdctl role get common
Role common
KV Read:
KV Write:
	[a, b) (prefix a)
[root@kano ~]# 
```

8. 移除某个角色
```
# 此时整个角色就被删除了
[root@kano ~]# etcdctl role delete common
Role common deleted
[root@kano ~]# etcdctl role get common
Error: etcdserver: role name not found
[root@kano ~]# 
```

## 启用用户权限功能

- 虽然我们介绍了权限相关，但是我们之前貌似并不需要权限就可以操作，这是因为没有开启权限。而开始权限可以通过 etcdctl auth 子命令开启。

1. 确认 root 用户已经创建
```
[root@kano ~]# etcdctl user list
[root@kano ~]# etcdctl user add root
Password of root: 
Type password of root again for confirmation: 
User root created
[root@kano ~]# 
```

2. 启用权限认证功能
```
# 此时认证就开启了
[root@kano ~]# etcdctl auth enable
Authentication Enabled
[root@kano ~]# 
# 也就不能随随便便地写了
[root@kano ~]# etcdctl put name nana
Error: etcdserver: user name is empty
[root@kano ~]# etcdctl get name
Error: etcdserver: user name is empty
# 如果想写的话, 需要指定用户, 然后会提示输入密码
[root@kano ~]# etcdctl put name nana --user="root"
Password: 
OK
# 也可以直接指定, 通过 user:password 方式
[root@kano ~]# etcdctl put age 16 --user="root:123456"
OK
# 读也是同理
[root@kano ~]# etcdctl get name --user="root"
Password: 
name
nana
# 直接指定密码
[root@kano ~]# etcdctl get age --user="root:123456"
age
16
[root@kano ~]# 
```

3. 关闭权限认证功能
```
[root@kano ~]# etcdctl auth disable
Error: etcdserver: user name not found
# 即便是关闭权限, 也依旧需要指定一个用户
[root@kano ~]# etcdctl auth disable --user="root:123456"
Authentication Disabled
[root@kano ~]# 
```

这个时候可能有人好奇了，要是没有用户怎么办？答案是如果没有用户，etcd是不会允许你开启认证的，我们举个栗子。
```
[root@kano ~]# etcdctl user delete root
User root deleted
[root@kano ~]# etcdctl auth enable
Error: etcdserver: root user does not exist
```

注意：我们说角色会被授予用户，而当我们开启认证的时候，会自动创建 root 角色并授予 root 用户。
```
# 此时 用户 和 角色 都没有
[root@kano ~]# etcdctl user list
[root@kano ~]# etcdctl role list
# 创建一个root, 否则无法开启认证
[root@kano ~]# etcdctl user add root
Password of root: 
Type password of root again for confirmation: 
User root created
[root@kano ~]# etcdctl user list
root
# 用户多了 root, 但是角色还不存在
[root@kano ~]# etcdctl role list
# 开启认证
[root@kano ~]# etcdctl auth enable
Authentication Enabled
# 发现root角色自动被创建了
[root@kano ~]# etcdctl role list --user="root:123456"
root
```

而我们说 root 用户 和 root 角色都是可以被删除的，但那是在没有开启认证的情况下，如果开启了认证呢？
```
# 此时再创建一个用户 mea
[root@kano ~]# etcdctl role add mea --user="root:123456"
Role mea created
# 用户 mea 是可以被删除的, 当然权限也可以
[root@kano ~]# etcdctl role delete mea --user="root:123456"
Role mea deleted
# 但是: root用户和root权限, 是无法被删除的
[root@kano ~]# etcdctl role delete root --user="root:123456"
Error: etcdserver: invalid auth management
[root@kano ~]# etcdctl user delete root --user="root:123456"
Error: etcdserver: invalid auth management
# 如果想删除, 那么需要先把认证给关掉
[root@kano ~]# etcdctl auth disable --user="root:123456"
Authentication Disabled
# 此时 root 就可以删除了
[root@kano ~]# etcdctl user delete root
User root deleted
# 但是这里还有一个容易忽略的地方, 如果我们想再次启动认证呢? 显然再创建一个 root 启动不就行了吗? 我们来试试
# 创建root
[root@kano ~]# etcdctl user add root
Password of root: 
Type password of root again for confirmation: 
User root created
# 开启认证, 但是报错了: 告诉我们角色已存在, 相信你肯定想到了
# 因为我们刚才只把 root用户 删掉了, 但是没有删 root角色, 而我们说开启认证的时候会自动创建 root 角色
# 但是 root角色已经存在了, 所以就报错了
[root@kano ~]# etcdctl auth enable
Error: etcdserver: role name already exists
# 此时认证是没有开启的
[root@kano ~]# etcdctl put name hanser
OK
[root@kano ~]# etcdctl get name
name
hanser
# 而解决办法也很简单, 直接把 root角色给删掉就可以了
[root@kano ~]# etcdctl role delete root
Role root deleted
# 此时成功开启认证
[root@kano ~]# etcdctl auth enable
Authentication Enabled
[root@kano ~]# 
```

4. 综合以上例子
```
# 创建一个普通用户, 由于开启了认证, 所以下面每一步都需要指定用户
[root@kano ~]# etcdctl role add common --user="root:123456"
Role common created
# 就是我们刚才演示的, 赋予对name的只读权限
[root@kano ~]# etcdctl role grant-permission common read name --user="root:123456"
Role common updated
# 赋予对[a, b)的只写权限
[root@kano ~]# etcdctl role grant-permission common write a b --user="root:123456"
Role common updated
# 赋予对c*的可读可写权限
[root@kano ~]# etcdctl role grant-permission common readwrite c --prefix --user="root:123456"
Role common updated
# 然后创建一个用户 mea
[root@kano ~]# etcdctl user add mea --user="root:123456"
Password of mea: 
Type password of mea again for confirmation: 
User mea created
# 以后让别人不使用root, 只能使用mea这个用户, 但是默认它是没有任何权限的
# 所以我们将角色common授予用户mea
[root@kano ~]# etcdctl user grant-role mea common --user="root:123456"
Role common is granted to user mea
# 那么以后通过 --user="mea:123456" 便可以操作指定的key了; 这里的密码是123456, 只是为了方便
# 如果 用户mea 还希望操作其它key, 则需要root再次赋予新的角色, 一个用户可以有多个角色, 或者更新common所具有的权限也是可以的
[root@kano ~]# 
# 我们看到写name这个key的时候, 被告知权限不够
[root@kano ~]# etcdctl put name nana --user="mea:123456"
Error: etcdserver: permission denied
# 我们用 root 写一下
[root@kano ~]# etcdctl put name nana --user="root:123456"
OK
# 虽然写不行, 但是读可以
[root@kano ~]# etcdctl get name --user="mea:123456"
name
nana
# [a, b)具有写权限
[root@kano ~]# etcdctl put aaaa bbbb --user="mea:123456"
OK
# 但是没有读权限
[root@kano ~]# etcdctl get aaaa --user="mea:123456"
Error: etcdserver: permission denied
[root@kano ~]# etcdctl get aaaa --user="root:123456"
aaaa
bbbb
[root@kano ~]#
# c开头的key是可读可写
[root@kano ~]# etcdctl put crystal krystal --user="mea:123456"
OK
[root@kano ~]# etcdctl get crystal --user="mea:123456"
crystal
krystal
[root@kano ~]#
```
