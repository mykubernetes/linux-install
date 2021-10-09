一、认证
---
1、关闭认证
```
# vim /etc/ceph/ceph.conf
auth cluster required = none
auth service required = none
auth client required = none
```  

2、开启认证
```
# vim /etc/ceph/ceph.conf
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
```  

二、授权  
---

用户通过身份验证后，即可获得不同类型的访问权限，活动或角色的授权  
语法：{daemon-type} 'allow {capability}' [{daemon-type} 'allow {capability}']  

1、mon
包括r，w，x，参数，并允许 profiles（配置） {cap}。例如：  
```
mon 'allow rwx' or mon 'allow profile osd'
```  

2、osd  
包括r，w，x，class-read，class-write，和 profile OSD。例如：  
```
osd 'allow rwx' or osd 'allow class-read, allow rwx pool=rbd'
```  

3、MDS  
仅支持allow 例如  
```
mds 'allow'
```  

Ceph常用权限说明

| 参数 | 描述 |
|-----|------|
| allow | 仅适合 MDS |
| r | 读取访问权限，这是监视器读取CRUSH映射所必需的。 |
| w | 对对象的写访问权限。 |
| x | 这使用户能够调用类方法，包括读取和写入，以及auth在监视器上执行操作的权限。 |
| class-read | 这是x的一个子集，允许用户调用类读取方法。 |
| class-write | 这是x允许用户调用类写方法的子集。 |
| * | 这为用户提供特定池的完全权限（r，w和x）以及执行管理命令。 |
| profile rbd | 授权管理rbd权限 |
| profile osd | 这允许用户以OSD的形式连接到其他OSD或监视器。用于OSD心跳流量和状态报告。 |
| profile mds | 这允许用户作为MDS连接到其他MDS。 |
| profile bootstrap-osd | 这允许用户引导OSD。例如，ceph-deploy和ceph-disk工具使用的客户端。bootstrap-osduser，有权添加密钥和引导OSD。 |
| profile bootstrap-mds | 这允许用户引导元数据服务器。例如，该ceph-deploy工具使用 |
| client.bootstrap-mds | 用户添加密钥并引导元数据服务器。 |


1、列出集群中的用户 
```
# ceph auth ls
```

2、 # 列出指定用户信息
```
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

3、结合使用-o 文件名选项和 ceph auth list 将输出保存到某个文件。
```
# ceph auth list -o 123.key
```

4、添加用户

- 添加用户的规范方法：它会创建用户、生成密钥，并添加所有指定的能力
```
#添加认证 key
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

5、ceph auth get-or-create

- ceph auth get-or-create 此命令是创建用户较为常见的方式之一，它会返回包含用户名和密钥的密钥文，如果该用户已存在，此命令只以密钥文件格式返回用户名和密钥，还可以使用 -o 指定文件名选项将输出保存到某个文件
```
# 创建用户
# ceph auth get-or-create client.test mon 'allow r' osd 'allow rwx pool=mypool'
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==

# 验证用户
# ceph auth get client.test
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
    caps mon = "allow r"
    caps osd = "allow rwx pool=mypool"
exported keyring for client.test

# 再次创建用户
# ceph auth get-or-create client.test mon 'allow r' osd 'allow rwx pool=mypool'
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==

# 保存文件
# ceph auth get-or-create client.rbd | tee /etc/ceph/ceph.client.rbd.keyring      #ceph集群名.client.rbd用户名.keyring格式保存
```

6、ceph auth get-or-create-key
- 此命令是创建用户并仅返回用户密钥，对于只需要密钥的客户端（例如 libvirt），此命令非常有用。如果该用户已存在，此命令只返回密钥。您可以使用 -o 文件名选项将输出保存到某个文件。
- 创建客户端用户时，可以创建不具有能力的用户。不具有能力的用户可以进行身份验证，但不能执行其他操作，此类客户端无法从监视器检索集群地图，但是，如果希望稍后再添加能力，可以使用 ceph auth caps 命令创建一个不具有能力的用户。

典型的用户至少对 Ceph monitor 具有读取功能，并对 Ceph OSD 具有读取和写入功能。此外，用户的 OSD 权限通常限制为只能访问特定的存储池
```
# 用户有 key 就显示没有就创建
# ceph auth get-or-create-key client.test mon 'allow r' osd 'allow rwx pool=mypool'
AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
```

7、ceph auth print-key
```
# 获取单个指定用户的key
# ceph auth print-key client.test
AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==test
```

8、修改用户能力

- 使用 ceph auth caps 命令可以指定用户以及更改该用户的能力，设置新能力会完全覆盖当前的能力，因此要加上之前的用户已经拥有的能和新的能力，如果看当前能力，可以运行 cephauth get USERTYPE.USERID
```
# 查看用户当前权限
# ceph auth get client.test
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
    caps mon = "allow r"
    caps osd = "allow rwx pool=mypool"
exported keyring for client.test

# 修改权限
# ceph auth caps client.test mon 'allow r' osd 'allow rw pool=mypool'
updated caps for client.test

# 验证权限
# ceph auth get client.test
[client.test]
    key = AQAYVyphyzZdGxAAYZlScsmbAf3mK9zyuaod6g==
    caps mon = "allow r"
    caps osd = "allow rw pool=mypool"
exported keyring for client.test

# 写入到文件
# ceph auth caps client.rbd mon 'allow r' osd 'allow rwx pool=rbd' | tee /etc/ceph/ceph.client.rbd.keyring
```

9、删除用户
```
# ceph auth del client.rbd
```


## 秘钥环管理

- ceph 的秘钥环是一个保存了 secrets、keys、certificates 并且能够让客户端通认证访问 ceph的 keyring file(集合文件)，一个 keyring file 可以保存一个或者多个认证信息，每一个 key 都有一个实体名称加权限，类型为：
```
{client、mon、mds、osd}.name
```

1、通过秘钥环文件备份与恢复用户
使用 ceph auth add 等命令添加的用户还需要额外使用 ceph-authtool 命令为其创建用户秘钥环文件
```
创建 keyring 文件命令格式：
ceph-authtool --create-keyring FILE
```

2、导出用户认证信息至 keyring 文件
- 将用户信息导出至 keyring 文件，对用户信息进行备份。
```
#deploy节点
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

3、从 keyring 文件恢复用户认证信息
- 可以使用 ceph auth import -i 指定 keyring 文件并导入到 ceph，起到用户备份和恢复的作用
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
# ceph auth get client.user1
[client.user1]
    key = AQB6WiphsylPERAALnVZ0wMPapQ0lb3ehDdrVA==
    caps mon = "allow r"
    caps osd = "allow * pool=mypool"
exported keyring for client.user1
```


4、秘钥环文件多用户
- 一个 keyring 文件中可以包含多个不同用户的认证文件

将多用户导出至秘钥环
```
#创建空的keyring 文件
# ceph-authtool --create-keyring ceph.client.user.keyring
creating ceph.client.user.keyring

#把指定的 admin 用户的 keyring 文件内容导入到 user 用户的 keyring 文件
# ceph-authtool ./ceph.client.user.keyring --import-keyring ./ceph.client.admin.keyring
importing contents of ./ceph.client.admin.keyring into ./ceph.client.user.keyring

#验证 keyring 文件
# ceph-authtool -l ./ceph.client.user.keyring
[client.admin]
    key = AQD55h9h5ICUJBAAfk/2gBzkwU+G8bfqY023Yg==
    caps mds = "allow *"
    caps mgr = "allow *"
    caps mon = "allow *"
    caps osd = "allow *"

#再导入一个其他用户的 keyring
# ceph-authtool ./ceph.client.user.keyring --import-keyring ./ceph.client.user1.keyring
importing contents of ./ceph.client.user1.keyring into ./ceph.client.user.keyring

#验证 keyring 文件是否包含多个用户的认证信息
# ceph-authtool -l ./ceph.client.user.keyring
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
