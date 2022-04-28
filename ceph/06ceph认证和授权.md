# 一： CephX 认证机制

Ceph 使用 cephx 协议对客户端进行身份认证，cephx 用于对 ceph 保存的数据进行认证访问和授权，用于对访问 ceph 的请求进行认证和授权检测，与 mon 通信的请求都要经过 ceph 认证通过，但是也可以在 mon 节点关闭 cephx认证，但是关闭认证之后任何访问都将被允许，因此无法保证数据的安全性。

## 1.1 授权流程
每个 mon 节点都可以对客户端进行身份认证并分发秘钥，因此多个 mon 节点就不存在单点故障和认证性能瓶颈。
m
on 节点会返回用于身份认证的数据结构，其中包含获取 ceph 服务时用到的 session key,session key 通 过 客 户 端 秘 钥 进 行 加 密 ， 秘 钥 是 在 客 户 端 提 前 配 置 好的，/etc/ceph/ceph.client.admin.keyring

## 1.2 访问流程

无论 ceph 客户端是哪种类型，例如块设备、对象存储、文件系统，ceph 都会在存储池中将所有数据存储为对象:

ceph 用户需要拥有存储池访问权限，才能读取和写入数据

ceph 用户必须拥有执行权限才能使用 ceph 的管理命令

## 1.3 开启关闭Cephx认证

1）、关闭认证
```
# vim /etc/ceph/ceph.conf
auth cluster required = none
auth service required = none
auth client required = none
```  

2）、开启认证
```
# vim /etc/ceph/ceph.conf
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
```  

## 1.4 ceph 用户

用户是指个人(ceph 管理者)或系统参与者(MON/OSD/MDS)。

通过创建用户，可以控制用户或哪个参与者能够访问 ceph 存储集群、以及可访问的存储池及存储池中的数据。

ceph 支持多种类型的用户，但可管理的用户都属于 client 类型

区分用户类型的原因在于，MON/OSD/MDS 等系统组件特使用 cephx 协议，但是它们为非客户端。
```
#node节点
test@ceph-node1:~$ cat /etc/ceph/ceph.client.admin.keyring
[client.admin]
    key = AQD55h9h5ICUJBAAfk/2gBzkwU+G8bfqY023Yg==
    caps mds = "allow *"
    caps mgr = "allow *"
    caps mon = "allow *"
    caps osd = "allow *"
```

## 1.5 ceph 授权和使能

ceph 基于使能/能力(Capabilities，简称 caps )来描述用户可针对 MON/OSD 或 MDS 使用的授权范围或级别。

用户通过身份验证后，即可获得不同类型的访问权限，活动或角色的授权

语法：`{daemon-type} 'allow {capability}' [{daemon-type} 'allow {capability}']`

能力一览表：
- allow
  - 需先于守护进程的访问设置指定
  - 仅对MDS表示rw之意，其它的表示字面意义
- r：向用户授予读取权限。访问监视器(mon)以检索 CRUSH 运行图时需具有此能力。 
- w：向用户授予针对对象的写入权限。 
- x：授予用户调用类方法（包括读取和写入）的能力，以及在mon中执行auth 操作的能力。
- *：授予用户对特定守护进程/存储池的读取、写入和执行权限，以及执行管理命令的能力 
- class-read：x能力的子集，授予用户调用类读取方法的能力 
- class-write：x能力的子集，授予用户调用类写入方法的能力
- profile osd: 
  - 授予用户以某个 OSD 身份连接到其他 OSD 或监视器的权限。
  - 授予 OSD 权限，使 OSD 能够处理复制检测信号流量和状态报告(获取 OSD 的状态信息)
- profile mds: 
  - 授予用户以某个 MDS 身份连接到其他 MDS 或监视器的权限
- profile bootstrap-osd: 
  - 授予用户引导 OSD 的权限(初始化OSD并将OSD加入ceph集群)。
  - 授权给部署工具，使其在引导 OSD 时有权添加密钥
- profile bootstrap-mds: 
  - 授予用户引导元数据服务器的权限。
  - 授权部署工具权限，使其在引导元数据服务器时有权添加密钥。

### MON 能力：

> 包括 r/w/x 和 allow profile cap (ceph 的运行图)

```
例如：
mon 'allow rwx' 
mon 'allow profile osd
```

### OSD 能力:

> `包括 r、w、x、class-read(类读取)、class-write(类写入)和 profile osd(剖析osd的工作特性或统计数据)，另外 OSD 能力还允许进行存储池和名称空间设置。`
```
osd 'allow rwx' or osd 'allow class-read, allow rwx pool=rbd'
``` 

### MDS 能力：

> 仅支持allow ,只需要 allow 或空都表示允许。 mds 'allow'
```
mds 'allow'
```  

### 1.6 列出指定用户

```
# ceph auth ls                         #列出所以用户
# ceph auth get osd.10                 #获取用户信息
[osd.10]
    key = AQDNBilhkPDRKRAABW8mMaGrYMwYHVVVjtOU0g==
    caps mgr = "allow profile osd"
    caps mon = "allow profile osd"
    caps osd = "allow *"
exported keyring for osd.10

# ceph auth get osd                     #write keyring file with requested key                                       
# ceph auth get osd.10
[osd.10]
    key = AQDNBilhkPDRKRAABW8mMaGrYMwYHVVVjtOU0g==
    caps mgr = "allow profile osd"
    caps mon = "allow profile osd"
    caps osd = "allow *"
exported keyring for osd.10

# ceph auth get client.admin
[client.admin]
    key = AQD55h9h5ICUJBAAfk/2gBzkwU+G8bfqY023Yg==
    caps mds = "allow *"
    caps mgr = "allow *"
    caps mon = "allow *"
    caps osd = "allow *"
exported keyring for client.admin
```
注：TYPE.ID 表示法 针对用户采用 TYPE.ID 表示法，例如 osd.0 指定是 osd 类并且 ID 为 0 的用户(节点)，client.admin 是 client 类型的用户，其 ID 为 admin

另请注意，每个项包含一个 key=xxxx 项，以及一个或多个 caps 项。 可以结合使用-o 文件名选项和 ceph auth list 将输出保存到某个文件。
```
# ceph auth list -o 123.key
```

将osd.1的用户秘钥导出到aaa中
```
ceph auth export osd.1 -o aaa.key
```

## 1.6 ceph用户管理
用户管理功能可让 Ceph 集群管理员能够直接在 Ceph 集群中创建、更新和删除用户。在 Ceph 集群中创建或删除用户时，可能需要将密钥分发到客户端，以便将密钥添加到密钥环文件中/etc/ceph/ceph.client.admin.keyring，此文件中可以包含一个或者多个用户认证信息，凡是拥有此文件的节点，将具备访问 ceph 的权限，而且可以使用其中任何一个账户的权限

### 1.6.1 列出用户
```
test@ceph-deploy:~/ceph-cluster$ ceph auth ls
mds.ceph-mgr1
    key: AQA5UyhhXsY/MBAAgv/L+/cKMPx4fy+V2Cm+vg==
    caps: [mds] allow
    caps: [mon] allow profile mds
    caps: [osd] allow rwx
osd.0
    key: AQAswSBh2jDUERAA+jfMZKocn+OjdFYZf7lrbg==
    caps: [mgr] allow profile osd
    caps: [mon] allow profile osd
    caps: [osd] allow *
osd.1
    key: AQBjwSBhhYroNRAAO5+aqRxoaYGiMnI8FZegZw==
    caps: [mgr] allow profile osd
    caps: [mon] allow profile osd
    caps: [osd] allow *
osd.10
    key: AQDNBilhkPDRKRAABW8mMaGrYMwYHVVVjtOU0g==
    caps: [mgr] allow profile osd
    caps: [mon] allow profile osd
    caps: [osd] allow *
osd.11
    key: AQDfBilhKPzvGBAAVx7+GDBZlXkdRdLQM/qypw==
    caps: [mgr] allow profile osd
    caps: [mon] allow profile osd
    caps: [osd] allow *
```

### 1.6.2 用户管理

添加一个用户会创建用户名、密钥，以及包含在命令中用于创建该用户的所有能力,用户可使用其密钥向Ceph存储集群进行身份验证。用户的能力授予该用户在 Cephmonitor (mon)、Ceph OSD (osd) 或Ceph 元数据服务器 (mds) 上进行读取、写入或执行的能力

#### 1.6.2.1添加用户

添加用户的规范方法：它会创建用户、生成密钥，并添加所有指定的能力

```
# ceph auth -h
auth add <entity> [<caps>...]

#添加认证 key
#当用户不存在，则创建用户并授权；当用户存在，当权限不变，则不进行任何输出；当用户存在，不支持修改权限
# ceph auth add client.tom mon 'allow r' osd 'allow rwx pool=mypool'
0added key for client.tom

#验证key
# ceph auth get client.tom
[client.tom]
    key = AQBvVipheB/5DhAAaABVJGZbBlneBJUNoWfowg==
    caps mon = "allow r"
    caps osd = "allow rwx pool=mypool"
exported keyring for client.tom
```

#### 1.6.2.2 ceph auth get-or-create

ceph auth get-or-create 此命令是创建用户较为常见的方式之一，它会返回包含用户名和密钥的密钥文，如果该用户已存在，此命令只以密钥文件格式返回用户名和密钥，还可以使用 -o 指定文件名选项将输出保存到某个文件

```
# 创建用户,当用户不存在，则创建用户并授权；当用户存在，当权限不变，则不进行任何输出；当用户存在，不支持修改权限
# ceph auth get-or-create client.test mon 'allow r' osd 'allow rwx pool=mypool'
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==

#验证用户
#  ceph auth get client.test
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
    caps mon = "allow r"
    caps osd = "allow rwx pool=mypool"
exported keyring for client.test

#再次创建用户
#当用户不存在，则创建用户并授权并返回用户和key，当用户存在，权限不变，返回用户和key，当用户存在，权限修改，则返回报错
# ceph auth get-or-create client.test mon 'allow r' osd 'allow rwx pool=mypool'
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==

#保存文件
# ceph auth get-or-create client.rbd -o /etc/ceph/ceph.client.rbd.keyring        # ceph集群名.client.rbd用户名.keyring格式保存
```

#### 1.6.2.3 ceph auth get-or-create-key

此命令是创建用户并仅返回用户密钥，对于只需要密钥的客户端（例如 libvirt），此命令非常有用。如果该用户已存在，此命令只返回密钥。您可以使用 -o 文件名选项将输出保存到某个文件。

创建客户端用户时，可以创建不具有能力的用户。不具有能力的用户可以进行身份验证，但不能执行其他操作，此类客户端无法从监视器检索集群地图，但是，如果希望稍后再添加能力，可以使用 ceph auth caps 命令创建一个不具有能力的用户。

典型的用户至少对 Ceph monitor 具有读取功能，并对 Ceph OSD 具有读取和写入功能。此外，用户的 OSD 权限通常限制为只能访问特定的存储池

```
#用户有 key 就显示没有就创建
# ceph auth get-or-create-key client.test mon 'allow r' osd 'allow rwx pool=mypool'
AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
```

#### 1.6.2.4 ceph auth print-key

```
#获取单个指定用户的key
test@ceph-deploy:~/ceph-cluster$ ceph auth print-key client.test
AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==test
```

#### 1.6.2.5 修改用户能力

使用 ceph auth caps 命令可以指定用户以及更改该用户的能力，设置新能力会完全覆盖当前的能力，因此要加上之前的用户已经拥有的能和新的能力，如果看当前能力，可以运行 cephauth get USERTYPE.USERID

```
#查看用户当前权限
# ceph auth get client.test
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
    caps mon = "allow r"
    caps osd = "allow rwx pool=mypool"
exported keyring for client.test

#修改权限
# ceph auth caps client.test mon 'allow r' osd 'allow rw pool=mypool'
updated caps for client.test

#验证权限
# ceph auth get client.test
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
    caps mon = "allow r"
    caps osd = "allow rw pool=mypool"
exported keyring for client.test

# 写入到文件
# ceph auth caps client.rbd mon 'allow r' osd 'allow rwx pool=rbd' -o /etc/ceph/ceph.client.rbd.keyring
```

#### 1.6.2.6 删除用户

要删除用户使用 ceph auth del TYPE.ID，其中 TYPE 是 client、osd、mon 或 mds 之一，ID 是用户名或守护进程的 ID

```
# ceph auth del client.rbd
```

## 1.7 秘钥环管理

ceph 的秘钥环是一个保存了 secrets、keys、certificates 并且能够让客户端通认证访问 ceph的 keyring file(集合文件)，一个 keyring file 可以保存一个或者多个认证信息，每一个 key 都有一个实体名称加权限，类型为：
```
{client、mon、mds、osd}.name
```

### 1.7.1 通过秘钥环文件备份与恢复用户

使用 ceph auth add 等命令添加的用户还需要额外使用 ceph-authtool 命令为其创建用户秘钥环文件
```
创建 keyring 文件命令格式：
ceph-authtool --create-keyring FILE
```

#### 1.7.1.1 导出用户认证信息至 keyring 文件

将用户信息导出至 keyring 文件，对用户信息进行备份。
```
#创建用户
# ceph auth get-or-create client.user1 mon 'allow r' osd 'allow * pool=mypool'
[client.user1]
    key = AQB6WiphsylPERAALnVZ0wMPapQ0lb3ehDdrVA==

#验证用户
# ceph auth get client.user1
[client.user1]
    key = AQB6WiphsylPERAALnVZ0wMPapQ0lb3ehDdrVA==
    caps mon = "allow r"
    caps osd = "allow * pool=mypool"
exported keyring for client.user1

#创建keyring 文件
# ceph-authtool --create-keyring ceph.client.user1.keyring
creating ceph.client.user1.keyring

#验证 keyring 文件
# cat ceph.client.user1.keyring
# file ceph.client.user1.keyring
ceph.client.user1.keyring: empty #空文件

#导出 keyring 至指定文件
# ceph auth get client.user1 -o ceph.client.user1.keyring
exported keyring for client.user1

#验证指定用户的 keyring 文件
# cat ceph.client.user1.keyring
[client.user1]
    key = AQB6WiphsylPERAALnVZ0wMPapQ0lb3ehDdrVA==
    caps mon = "allow r"
    caps osd = "allow * pool=mypool"
```

#### 1.7.1.2 从 keyring 文件恢复用户认证信息

可以使用 ceph auth import -i 指定 keyring 文件并导入到 ceph，起到用户备份和恢复的作用
```
#验证用户
# cat ceph.client.user1.keyring
[client.user1]
    key = AQB6WiphsylPERAALnVZ0wMPapQ0lb3ehDdrVA==
    caps mon = "allow r"
    caps osd = "allow * pool=mypool"

#模拟误删用户
# ceph auth del client.user1
updated

#验证用户
# ceph auth get client.user1
Error ENOENT: failed to find client.user1 in keyring

#导入用户 keyring
# ceph auth import -i ceph.client.user1.keyring
imported keyring

#验证用户
#ceph auth get client.user1
[client.user1]
    key = AQB6WiphsylPERAALnVZ0wMPapQ0lb3ehDdrVA==
    caps mon = "allow r"
    caps osd = "allow * pool=mypool"
exported keyring for client.user1
```

### 1.7.2 秘钥环文件多用户

一个 keyring 文件中可以包含多个不同用户的认证文件

#### 1.7.2.1 将多用户导出至秘钥环
```
#创建空的keyring 文件
test@ceph-deploy:~/ceph-cluster$ ceph-authtool --create-keyring ceph.client.user.keyring
creating ceph.client.user.keyring

#把指定的 admin 用户的 keyring 文件内容导入到 user 用户的 keyring 文件
test@ceph-deploy:~/ceph-cluster$ ceph-authtool ./ceph.client.user.keyring --import-keyring ./ceph.client.admin.keyring
importing contents of ./ceph.client.admin.keyring into ./ceph.client.user.keyring

#验证 keyring 文件
test@ceph-deploy:~/ceph-cluster$ ceph-authtool -l ./ceph.client.user.keyring
[client.admin]
    key = AQD55h9h5ICUJBAAfk/2gBzkwU+G8bfqY023Yg==
    caps mds = "allow *"
    caps mgr = "allow *"
    caps mon = "allow *"
    caps osd = "allow *"

#再导入一个其他用户的 keyring
test@ceph-deploy:~/ceph-cluster$ ceph-authtool ./ceph.client.user.keyring --import-keyring ./ceph.client.user1.keyring
importing contents of ./ceph.client.user1.keyring into ./ceph.client.user.keyring

#验证 keyring 文件是否包含多个用户的认证信息
test@ceph-deploy:~/ceph-cluster$ ceph-authtool -l ./ceph.client.user.keyring
[client.admin]
    key = AQD55h9h5ICUJBAAfk/2gBzkwU+G8bfqY023Yg==
    caps mds = "allow *"
    caps mgr = "allow *"
    caps mon = "allow *"
    caps osd = "allow *"
[client.user1]
    key = AQB6WiphsylPERAALnVZ0wMPapQ0lb3ehDdrVA==
    caps mon = "allow r"
    caps osd = "allow * pool=mypool"
```
