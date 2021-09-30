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












新建一个用户
```
radosgw-admin user create --uid=admin --display-name=admin --access_key=admin --secret=123456
```

为admin用户添加读写权限
```
radosgw-admin caps add --uid=admin --caps="users=read, write"
```

删除一用户：
```
radosgw-admin user rm --uid=johnny
```

删除一个用户和与他相关的桶及内容：
```
radosgw-admin user rm --uid=johnny --purge-data
```

删除一个桶：
```
radosgw-admin bucket unlink --bucket=foo
```

显示一个桶从 2012 年 4 月 1 日起的日志：
```
$ radosgw-admin log show --bucket=foo --date=2012-04-01
```

显示某用户 2012 年 3 月 1 日（不含）到 4 月 1 日期间的使用情况：
```
$ radosgw-admin usage show --uid=johnny --start-date=2012-03-01 --end-date=2012-04-01
```

只显示所有用户的使用情况汇总：
```
$ radosgw-admin usage show --show-log-entries=false
```

裁剪掉某用户 2012 年 4 月 1 日之前的使用信息：
```
$ radosgw-admin usage trim --uid=johnny --end-date=2012-04-01
```









```
radosgw-admin user list                                       # 查看用户列表
radosgw-admin bucket stats --uid 100004603027                 # 查看某个用户下面桶的状态
radosgw-admin user info --uid 100004603175                    # 查看某个租户的配额信息，数据库里没有此信息
radosgw-admin bucket list                                     # 列出存储桶，存储网关节点上执行
radosgw-admin bucket list --uid=***                           # 列出属于某个uin的存储桶有哪些
radosgw-admin bucket stats --bucket=cbssnapbox-1255000337     # 查看桶状态
radosgw-admin bucket unindex --bucket=桶名称                   # 删除存储桶的索引
radosgw-admin bucket delete disable --bucket=桶名称            # 将存储桶置为不可删除
```
