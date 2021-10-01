# 命令

| 命令 | 命令描述 |
|------|--------|
| user create | 创建一个新用户。 |
| user modify | 修改一个用户。 |
| user info | 显示用户信息，以及可能存在的子用户和密钥。 |
| user rm | 删除一个用户。
| user suspend | 暂停某用户。 |
| user enable | 重新允许暂停的用户。 |
| user check | 检查用户信息。 |
| user stats | 显示配额子系统统计的用户状态。 |
| caps add | 给用户分配能力。 |
| caps rm | 删除用户能力。 |
| subuser create | 新建一个子用户（适合使用 Swift API 的客户端）。 |
| subuser modify | 修改子用户。 |
| subuser rm | 删除子用户 |
| key create | 新建访问密钥。 |
| key rm | 删除访问密钥。 |
| bucket list | 罗列所有桶。 |
| bucket link | 把桶关联到指定用户。 |
| bucket unlink | 取消指定用户和桶的关联。 |
| bucket stats | 返回桶的统计信息。 |
| bucket rm | 删除一个桶。 |
| bucket check | 检查桶的索引信息。 |
| object rm | 删除一个对象。 |
| object unlink | 从桶索引里去掉对象。 |
| quota set | 设置配额参数。 |
| quota enable | 启用配额。 |
| quota disable | 禁用配额。 |
| region get | 显示 region 信息。 |
| regions list | 列出本集群配置的所有 region 。 |
| region set | 设置 region 信息（需要输入文件）。 |
| region default | 设置默认 region 。 |
| region-map get | 显示 region-map 。 |
| region-map set | 设置 region-map （需要输入文件）。 |
| zone get | 显示区域集群参数。 |
| zone set | 设置区域集群参数（需要输入文件）。 |
| zone list | 列出本集群内配置的所有区域。 |
| pool add | 增加一个已有存储池用于数据归置。 |
| pool rm | 从数据归置集删除一个已有存储池。 |
| pools list | 罗列归置活跃集。 |
| policy | 显示桶或对象相关的策略。 |
| log list | 罗列日志对象。 |
| log show | 显示指定对象内（或指定桶、日期、桶标识符）的日志。 |
| log rm | 删除日志对象。 |
| usage show | 查看使用率信息（可选选项有用户和数据范围）。 |
| usage trim | 修剪使用率信息（可选选项有用户和数据范围）。 |
| temp remove | 删除指定日期（时间可选）之前创建的临时对象。 |
| gc list | 显示过期的垃圾回收对象（加 –include-all 选项罗列所有条目，包括未过期的）。 |
| gc process | 手动处理垃圾。 |
| metadata get | 读取元数据信息。 |
| metadata put | 设置元数据信息。 |
| metadata rm | 删除元数据信息。 |
| metadata list | 罗列元数据信息。 |
| mdlog list | 罗列元数据日志。 |
| mdlog trim | 裁截元数据日志。 |
| bilog list | 罗列桶索引日志。 |
| bilog trim | 裁截桶索引日志（需要起始标记、结束标记）。 |
| datalog list | 罗列数据日志。 |
| datalog trim | 裁截数据日志。 |
| opstate list | 罗列含状态操作（需要 client_id 、 op_id 、对象）。 |
| opstate set | 设置条目状态（需指定 client_id 、 op_id 、对象、状态）。 |
| opstate renew | 更新某一条目的状态（需指定 client_id 、 op_id 、对象）。 |
| opstate rm | 删除条目（需指定 client_id 、 op_id 、对象）。 |
| replicalog get | 读取复制元数据日志条目。 |
| replicalog delete | 删除复制元数据日志条目。 |

# 选项

| 选项 | 选项描述 |
|-----|---------|
| -c ceph.conf, --conf=ceph.conf | 用指定的 ceph.conf 配置文件而非默认的 /etc/ceph/ceph.conf 来确定启动时所需的监视器地址。 |
| -m monaddress[:port] | 连接到指定监视器，而非通过 ceph.conf 查询。 |
| --uid=uid | radosgw 用户的 ID 。 |
| --subuser=<name> | 子用户名字。 |
| --email=email | 用户的电子邮件地址。 |
| --display-name=name | 配置用户的显示名称（昵称） |
| --access-key=<key> | S3 访问密钥。 |
| --gen-access-key | 生成随机访问密钥（给 S3 ）。 |
| --secret=secret | 指定密钥的密文。 |
| --gen-secret | 生成随机密钥。 |
| --key-type=<type> | 密钥类型，可用的有： swift 、 S3 。 |
| --temp-url-key[-2]=<key> | 临时 URL 密钥。 |
| --system | 给用户设置系统标识。 |
| --bucket=bucket | 指定桶名 |
| --object=object | 指定对象名 |
| --date=yyyy-mm-dd | 某些命令所需的日期 |
| --start-date=yyyy-mm-dd | 某些命令所需的起始日期 |
| --end-date=yyyy-mm-dd | 某些命令所需的终结日期 |
| --shard-id=<shard-id> | 执行 mdlog list 时为可选项。对 mdlog trim 、 replica mdlog get/delete 、 replica datalog get/delete 来说是必须的。 |
| --auth-uid=auid | librados 认证所需的 auid 。 |
| --purge-data | 删除用户前先删除用户数据。 |
| --purge-keys | 若加了此选项，删除子用户时将一起删除其所有密钥。 |
| --purge-objects | 删除桶前先删除其内所有对象。 |
| --metadata-key=<key> | 用 metadata get 检索元数据时用的密钥。 |
| --rgw-region=<region> | radosgw 所在的 region 。 |
| --rgw-zone=<zone> | radosgw 所在的区域。 |
| --fix | 除了检查桶索引，还修复它。 |
| --check-objects | 检查桶：根据对象的实际状态重建桶索引。 |
| --format=<format> | 为某些操作指定输出格式： xml 、 json 。 |
| --sync-stats | user stats 的选项，收集用户的桶索引状态、并同步到用户状态。 |
| --show-log-entries=<flag> | 执行 log show 时，显示或不显示日志条目。 |
| --show-log-sum=<flag> | 执行 log show 时，显示或不显示日志汇总。 |
| --skip-zero-entries | 让 log show 只显示数字字段非零的日志。 |
| --infile | 设置时指定要读取的文件。 |
| --state=<state string> | 给 opstate set 命令指定状态。 |
| --replica-log-type | 复制日志类型（ metadata 、 data 、 bucket ），操作复制日志时需要。 |
| --categories=<list> | 逗号分隔的一系列类目，显示使用情况时需要。 |
| --caps=<caps> | 能力列表，如 “usage=read, write; user=read” 。 |
| --yes-i-really-mean-it | 某些特定操作需要。 |


# 磁盘配额选项

| 配额选项 | 选项描述 |
|--------|----------|
| --bucket | 为配额命令指定桶。 |
| --max-objects | 指定最大对象数（负数为禁用）。 |
| --max-size | 指定最大尺寸（单位为字节，负数为禁用）。 |
| --quota-scope | 配额有效范围（桶、用户）。 |

## 用户管理

1、新建一个用户
> 执行下面的命令新建一个用户 (S3 接口)
```
语法
radosgw-admin user create --uid={username} --display-name="{display-name}" [--email={email}]
演示
radosgw-admin user create --uid=johndoe --display-name="John Doe" --email=john@example.com
```

2、新建一个子用户
> 为了给用户新建一个子用户 (Swift 接口) ,必须为该子用户指定用户的 ID(--uid={username})，子用户的ID以及访问级别
```
语法
radosgw-admin subuser create --uid={uid} --subuser={uid} --access=[ read | write | readwrite | full ]
演示
radosgw-admin subuser create --uid=johndoe --subuser=johndoe:swift --access=full
```
- full并不表示readwrite, 因为它还包括访问权限策略.

3、获取用户信息
```
radosgw-admin user info --uid=johndoe
```

4、修改用户信息,主要的修改项是access和secret密钥，邮件地址，显示名称和访问级别。
```
radosgw-admin user modify --uid=johndoe --display-name="John E. Doe"
```

5、修改子用户的信息
```
radosgw-admin subuser modify --uid=johndoe:swift --access=full
```

6、用户的启用/停用

> 当创建一个用户默认情况下是处于启用状态。
```
radosgw-admin user suspend --uid=johndoe
```

> 重新启用已经被停用的用户。
```
radosgw-admin user enable --uid=johndoe
```
- 停用一个用户后,它的子用户也会一起被停用.

7、删除用户

> 删除用户时这个用户以及他的子用户都会被删除，当然也可以只删除子用户。
```
radosgw-admin user rm --uid=johndoe
```

> 只删除子用户
```
radosgw-admin subuser rm --subuser=johndoe:swift
```

> 删除一个用户和与他相关的桶及内容
```
radosgw-admin user rm --uid=johnny --purge-data
```
- `--purge-data` 清除与此UID相关的所有数据。
- `--purge-keys` 清除与此UID相关的所有密钥。

8、新建一个密钥
> 为用户新建一个密钥，需要使用 key create 子命令。对于用户来说，需要指明用户的 ID 以及新建的密钥类型为s3。要为子用户新建一个密钥，则需要指明子用户的ID以及密钥类型为swift。
```
radosgw-admin key create --subuser=johndoe:swift --key-type=swift --gen-secret
```

9、新建/删除 ACCESS 密钥

用户和子用户要能使用S3和Swift接口，必须有access密钥。在你新建用户或者子用户的时候，如果没有指明 access 和 secret 密钥，这两个密钥会自动生成。你可能需要新建 access 和/或 secret 密钥，不管是 手动指定还是自动生成的方式。你也可能需要删除一个 access 和 secret 。
- `--secret=<key>` 指明一个 secret 密钥 (e.即手动生成).
- `--gen-access-key` 生成一个随机的 access 密钥 (新建 S3 用户的默认选项).
- `--gen-secret` 生成一个随机的 secret 密钥.
- `--key-type=<type>` 指定密钥类型. 这个选项的值可以是: swift, s3
  
> 要新建密钥。
```
radosgw-admin key create --uid=johndoe --key-type=s3 --gen-access-key --gen-secret
```

> 手动使用指定access和secret密钥的方式。
```
radosgw-admin key create --uid=johndoe --key-type=s3 --access=123456   secret=123456
```

> 删除一个access密钥。
```
radosgw-admin key rm --uid=johndoe
```
  
10、添加/删除 管理权限

- Ceph 存储集群提供了一个管理API，它允许用户通过 REST API 执行管理功能。默认情况下，用户没有访问 这个 API 的权限。要启用用户的管理功能，需要为用 户提供管理权限。

```

> 语法：给一个用户添加对用户、bucket、元数据和用量(存储使用信息)等数据的 读、写或者所有权限。
```
radosgw-admin caps add --uid={uid} --caps={caps}      # --caps="[users|buckets|metadata|usage|zone]=[*|read|write|read, write]"
```

> 为用户添加管理权限
```
radosgw-admin caps add --uid=johndoe --caps="users=*"
```

> 要删除某用户的管理权限
```
radosgw-admin caps rm --uid=johndoe --caps={caps}
```

11、查看用户列表
```
radosgw-admin user list
```
  
12、检查用户信息
```
radosgw-admin user check --uid=johndoe
```

13、获取用户用量统计信息
```
radosgw-admin user stats --uid=uid
```

## 配额管理

1、设置用户配额
```
在启用用户的配额前，需要先设置配额参数。 
radosgw-admin quota set --quota-scope=user --uid=<uid> [--max-objects=<num objects>] [--max-size=<max size>]

示例
radosgw-admin quota set --quota-scope=user --uid=johndoe --max-objects=1024 --max-size=1024
```
- 最大对象数和最大存储用量的值是负数则表示不启用指定的配额参数。

2、启用/禁用用户配额
```
在设置了用户配额之后，可以启用这个配额。
radosgw-admin quota enable --quota-scope=user --uid=<uid>

也可以禁用已经启用了配额的用户的配额。
radosgw-admin quota-disable --quota-scope=user --uid=<uid>
```

3、设置BUCKET配额
```
Bucket配额作用于用户的某一个bucket，通过uid指定用户。这些配额设置是独立于用户之外的。
radosgw-admin quota set --uid=<uid> --quota-scope=bucket [--max-objects=<num objects>] [--max-size=<max size>]
```
- 最大对象数和最大存储用量的值是负数则表示不启用指定的配额参数。

4、启用/禁用 BUCKET 配额
```
在设置了bucket配额之后，可以启用这个配额。
radosgw-admin quota enable --quota-scope=bucket --uid=<uid>

也可以禁用已经启用了配额的bucket的配额。
radosgw-admin quota-disable --quota-scope=bucket --uid=<uid>
```

5、获取配额信息
```
通过用户信息API来获取每一个用户的配额设置。通过CLI接口读取用户的配额设置信息
radosgw-admin user info --uid=<uid>
```

6、更新配额统计信息
```
配额的统计数据的同步是异步的。可以通过手动获取最新的配额统计数据为所有用户和所有bucket更新配额统计数据
radosgw-admin user stats --uid=<uid> --sync-stats
```

7、获取用户用量统计信息
```
获取当前用户已经消耗了配额的多少
radosgw-admin user stats --uid=<uid>
```
- Note:你应该在执行 radosgw-admin user stats 的时候带上 --sync-stats 参数来获取最新的数据

8、读取/设置全局配额
```
在region map中读取和设置配额。
radosgw-admin regionmap get > regionmap.json

为整个region设置配额，只需要简单的修改region map中的配额设置。然后使用 region set 来更新 region map即可
radosgw-admin region set < regionmap.json
```
- 在更新region map后，必须重启网关

## 用量管理

Ceph对象网关会为每一个用户记录用量数据。可以通过指定日期范围来跟踪用户的用量数据。
- `--start-date` 指定一个起始日期来过滤用量数据`(format: yyyy-mm-dd[HH:MM:SS])`
- `--end-date` 指定一个截止日期来过滤用量数据 `(format: yyyy-mm-dd[HH:MM:SS])`
- `--show-log-entries` 指明显示用量数据的时候是否要包含日志条目。`(选项值: true | false)`

- Note：你可以指定时间为分钟和秒，但是数据存储是以一个小时的间隔存储的.


1、展示用量信息
```
显示用量统计数据。显示某一个特定用户的用量数据，你必须指定该用户的ID。你也可以指定开始日期、结束日期以及是否显示日志条目。
radosgw-admin usage show --uid=johndoe --start-date=2012-03-01 --end-date=2012-04-01

通过去掉用户的 ID，你也可以获取所有用户的汇总的用量信息
radosgw-admin usage show --show-log-entries=false
```
                                         
2、删除用量信息

对于大量使用的集群而言，用量日志可能会占用大量存储空间。你可以为所有用户或者一个特定的用户删除部分用量日志。你也可以为删除操作指定日期范围。
```
radosgw-admin usage trim --start-date=2010-01-01 --end-date=2010-12-31
radosgw-admin usage trim --uid=johndoe
radosgw-admin usage trim --uid=johndoe --end-date=2013-12-31
```

3、显示一个桶从2012年4月1日起的日志
```
radosgw-admin log show --bucket=foo --date=2012-04-01
```

4、显示某用户2012年3月1日（不含）到4月1日期间的使用情况
```
radosgw-admin usage show --uid=johnny --start-date=2012-03-01 --end-date=2012-04-01
```

5、只显示所有用户的使用情况汇总
```
radosgw-admin usage show --show-log-entries=false
```

6、裁剪掉某用户 2012 年 4 月 1 日之前的使用信息
```
radosgw-admin usage trim --uid=johnny --end-date=2012-04-01
```

## 存储桶

1、列出所有桶
```
列出所有桶
radosgw-admin bucket list

查看某一个用户，存储桶有哪些
radosgw-admin bucket list --uid=johndoe
```

2、把桶关联到指定用户
```
radosgw-admin metadata get bucket:s3test1&lt;/span&gt;&lt;span class="s1"&gt;
radosgw-admin bucket link --uid=johndoe --bucket=s3test1 --bucket-id=xxx
```
- note：一个桶只能连接给一个用户。连接给一个用户了，上个用户会自动取消链接    

3、取消连接
```
radosgw-admin bucket unlink --uid=johndoe --bucket=s3test1
```

4、返回桶的统计
```
信息输出bucket详细信息
radosgw-admin bucket stats

查看某个bucket具体信息
radosgw-admin bucket stats --bucket=s3test1

查看某个用户下面桶的状态
radosgw-admin bucket stats --uid 100004603027
```
- 输出信息中，有bucket的objects个数和占用空间。

5、删除一个桶
```
radosgw-admin bucket rm --bucket=s3test1
```

6、默认只能删空的bucket，强制删除非空的bucket需要加上"—purge-objects"
```
radosgw-admin bucket rm --bucket=s3test1 --purge-objects
```

7、查看桶的索引信息
```
radosgw-admin bucket check --bucket=s3test1
```

8、删除一个对象
```
radosgw-admin object rm --object=1.jpg --bucket=s3test3
```

9、从桶索引里去除对象
```
radosgw-admin object unlink --bucket=s3test3 --object=1.jpg
```

10、删除存储桶的索引
```
radosgw-admin bucket unindex --bucket=桶名称
```

11、将存储桶置为不可删除
```
radosgw-admin bucket delete disable --bucket=桶名称
```
