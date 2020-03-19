mc admin 命令详解
===
```
service     restart and stop all MinIO servers
update      update all MinIO servers
info        display MinIO server information
user        manage users
group       manage groups
policy      manage policies defined in the MinIO server
config      manage MinIO server configuration
heal        heal disks, buckets and objects on MinIO server
profile     generate profile data for debugging purposes
top         provide top like statistics for MinIO
trace       show http trace for MinIO server
console     show console logs for MinIO server
prometheus  manages prometheus config
kms         perform KMS management operations
```

获取配置的别名的MinIO服务器信息
```
# mc admin info minio
●  192.168.101.70:9000
   Uptime: 2 hours 
   Version: 2020-03-14T02:21:58Z
   Network: 1/1 OK 
```

MinIO服务器信息
```
# mc admin --json info play
{
    "status": "success",
    "info": {
        "mode": "online",
        "deploymentID": "96fa3866-7ee6-4546-87d9-4283e3def6c3",
        "buckets": {
            "count": 950
        },
        "objects": {
            "count": 18709
        },
        "usage": {
            "size": 5590444001
        },
        "services": {
            "vault": {
                "status": "KMS configured using master key"
            },
            "ldap": {}
        },
        "backend": {
            "backendType": "Erasure",
            "onlineDisks": 4,
            "rrSCData": 2,
            "rrSCParity": 2,
            "standardSCData": 2,
            "standardSCParity": 2
        },
        "servers": [
            {
                "state": "ok",
                "endpoint": "play.min.io",
                "uptime": 126497,
                "version": "2020-03-14T11:26:28Z",
                "commitID": "d2c7ea993ed484343d37615ae1a9e5677a0cbcb9",
                "network": {
                    "play.min.io": "online"
                },
                "disks": [
                    {
                        "path": "/home/play/data1",
                        "state": "ok",
                        "uuid": "01b41712-e65d-4dba-b40f-80cb8715f2d9",
                        "totalspace": 8378122240,
                        "usedspace": 3055427584
                    },
                    {
                        "path": "/home/play/data2",
                        "state": "ok",
                        "uuid": "24720fca-5c6b-415b-a2f5-b1dd7218e68c",
                        "totalspace": 8378122240,
                        "usedspace": 3055460352
                    },
                    {
                        "path": "/home/play/data3",
                        "state": "ok",
                        "uuid": "23d4963e-b07c-4796-9c88-0342e7727528",
                        "totalspace": 8378122240,
                        "usedspace": 3055362048
                    },
                    {
                        "path": "/home/play/data4",
                        "state": "ok",
                        "uuid": "76844146-bd6c-4ded-a08e-3b991f352601",
                        "totalspace": 8378122240,
                        "usedspace": 3055394816
                    }
                ]
            }
        ]
    }
}
```



命令
| Commands                                                               |
|:-----------------------------------------------------------------------|
| [**service** - 重新启动和停止所有MinIO服务器](#service)                 |
| [**update** - 更新所有MinIO服务器](#update)                             |
| [**info** - 显示MinIO服务器信息](#info)                                 |
| [**user** - 管理用户](#user)                                           |
| [**group** - 管理组](#group)                                           |
| [**policy** - 管理固定政策](#policy)                                   |
| [**config** - 管理服务器配置文件](#config)                              |
| [**heal** - 修复MinIO服务器上的磁盘，存储桶和对象](#heal)                |
| [**profile** - 生成用于调试目的的配置文件数据](#profile)                 |
| [**top** - 为MinIO提供类似顶部的统计信息](#top)                         |
| [**trace** - 显示MinIO服务器的http跟踪](#trace)                         |
| [**console** - 显示MinIO服务器的控制台日志](#console)                   |
| [**prometheus** - 管理prometheus配置设置](#prometheus)                  |

<a name="update"> </a>
### 命令`update` - 更新所有MinIO服务器
`update`命令提供了一种更新集群中所有MinIO服务器的方法。您还可以使用带有`update`命令的私有镜像服务器来更新MinIO集群。如果MinIO在无法访问Internet的环境中运行，这很有用。

*示例：更新所有MinIO服务器。*
```
mc admin update play
Server `play` updated successfully from RELEASE.2019-08-14T20-49-49Z to RELEASE.2019-08-21T19-59-10Z
```

#### 使用私有镜像更新MinIO的步骤 
为了在私有镜像服务器上使用`update`命令，您需要在私有镜像服务器上的https://dl.minio.io/server/minio/release/linux-amd64/上镜像目录结构，然后提供：

```
mc admin update myminio https://myfavorite-mirror.com/minio-server/linux-amd64/minio.sha256sum
Server `myminio` updated successfully from RELEASE.2019-08-14T20-49-49Z to RELEASE.2019-08-21T19-59-10Z
```

> 注意：
> - 指向分布式安装程序的别名，此命令将自动更新群集中的所有MinIO服务器。
> - `update`是您的MinIO服务的破坏性操作，任何正在进行的API操作都将被强制取消。因此，仅在计划为部署进行MinIO升级时才应使用它。
> - 建议在更新成功完成后执行重新启动。

<a name="service"> </a>
### 命令`service` - 重新启动并停止所有MinIO服务器
`service`命令提供了一种重新启动和停止所有MinIO服务器的方法。

> 注意：
> - 指向分布式设置的别名，此命令将在所有服务器上自动执行相同的操作。
> - `restart`和`stop`子命令是MinIO服务的破坏性操作，任何正在进行的API操作都将被强制取消。因此，仅应在管理环境下使用。请谨慎使用。

```
NAME:
  mc admin service - restart and stop all MinIO servers

FLAGS:
  --help, -h                       show help

COMMANDS:
  restart  restart all MinIO servers
  stop     stop all MinIO servers
```

*示例：重新启动所有MinIO服务器。*
```
mc admin service restart play
Restarted `play` successfully.
```

<a name="info"> </a>
### 命令`info` - 显示MinIO服务器信息
`info`命令显示一台或多台MinIO服务器的服务器信息（在分布式集群下）

```
NAME:
  mc admin info - get MinIO server information

FLAGS:
  --help, -h                       show help
```

*示例：显示MinIO服务器信息。*

```
mc admin info play
●  play.minio.io
   Uptime: 11 hours
   Version: 2020-01-17T22:08:02Z
   Network: 1/1 OK
   Drives: 4/4 OK

2.1 GiB Used, 158 Buckets, 12,092 Objects
4 drives online, 0 drives offline
```

<a name="policy"> </a>
### 命令`policy` - 管理固定策略
使用`policy`命令在MinIO服务器上添加，删除，列出策略。

```
NAME:
  mc admin policy - manage policies

FLAGS:
  --help, -h                       show help

COMMANDS:
  add      add new policy
  remove   remove policy
  list     list all policies
  info     show info on a policy
  set      set IAM policy on a user or group
```

*示例：在MinIO上添加新策略'newpolicy'，其中的策略来自/tmp/newpolicy.json。*

```
mc admin policy add myminio/ newpolicy /tmp/newpolicy.json
```

*例如：在MinIO上删除政策“ newpolicy”。*

```
mc admin policy remove myminio/ newpolicy
```

*示例：列出MinIO上的所有策略。*

```
mc admin policy list --json myminio/
{"status":"success","policy":"newpolicy"}
```

*示例：显示政策信息*

```
mc admin policy info myminio/ writeonly
```

*示例：针对用户或组设置策略*

```
mc admin policy set myminio writeonly user=someuser
mc admin policy set myminio writeonly group=somegroup
```

<a name="user"> </a>
### 命令`user` - 管理用户
`user`命令，用于添加，删除，启用，禁用MinIO服务器上的用户。

```
NAME:
  mc admin user - manage users

FLAGS:
  --help, -h                       show help

COMMANDS:
  add      add new user
  disable  disable user
  enable   enable user
  remove   remove user
  list     list all users
  info     display info of a user
```

*例如：在MinIO上添加新用户'newuser'。*

```
mc admin user add myminio/ newuser newuser123
```

*示例：使用标准输入在MinIO上添加新用户'newuser'。*

```
mc admin user add myminio/
Enter Access Key: newuser
Enter Secret Key: newuser123
```

*例如：在MinIO上禁用用户“ newuser”。*

```
mc admin user disable myminio/ newuser
```

*例如：在MinIO上启用用户“ newuser”。*

```
mc admin user enable myminio/ newuser
```

*例如：在MinIO上删除用户'newuser'。*

```
mc admin user remove myminio/ newuser
```

*示例：列出MinIO上的所有用户。*

```
mc admin user list --json myminio/
{"status":"success","accessKey":"newuser","userStatus":"enabled"}
```

*示例：显示用户信息*

```
mc admin user info myminio someuser
```

<a name="group"> </a>
### 命令`group` - 管理组
使用`group`命令在MinIO服务器上添加，删除，信息，列出，启用，禁用组。

```
NAME:
  mc admin group - manage groups

USAGE:
  mc admin group COMMAND [COMMAND FLAGS | -h] [ARGUMENTS...]

COMMANDS:
  add      add users to a new or existing group
  remove   remove group or members from a group
  info     display group info
  list     display list of groups
  enable   Enable a group
  disable  Disable a group
```

*示例：将一对用户添加到MinIO上的“ somegroup”组中。*

如果组不存在，则会创建该组。

```
mc admin group add myminio somegroup someuser1 someuser2
```

*示例：从MinIO的“ somegroup”组中删除一对用户。*

```
mc admin group remove myminio somegroup someuser1 someuser2
```

*例如：在MinIO上删除组“ somegroup”。*

仅在给定组为空时有效。

```
mc admin group remove myminio somegroup
```

*示例：在MinIO上获取有关“ somegroup”组的信息。*

```
mc admin group info myminio somegroup
```

*示例：列出MinIO上的所有组。*

```
mc admin group list myminio
```

*示例：在MinIO上启用组“ somegroup”。*

```
mc admin group enable myminio somegroup
```

*例如：在MinIO上禁用组“ somegroup”。*

```
mc admin group disable myminio somegroup
```

<a name="config"> </a>
### 命令`config` - 管理服务器配置
`config`命令用于管理MinIO服务器配置。

```
NAME:
  mc admin config - manage configuration file

USAGE:
  mc admin config COMMAND [COMMAND FLAGS | -h] [ARGUMENTS...]

COMMANDS:
  get     get config of a MinIO server/cluster.
  set     set new config file to a MinIO server/cluster.

FLAGS:
  --help, -h                       Show help.
```

*示例：获取MinIO服务器/集群的服务器配置。*

```
mc admin config get myminio > /tmp/my-serverconfig
```

*示例：设置MinIO服务器/集群的服务器配置。*

```
mc admin config set myminio < /tmp/my-serverconfig
```

<a name="heal"> </a>
### 命令`heal` - 修复MinIO服务器上的磁盘，存储桶和对象
使用`heal`命令修复MinIO服务器上的磁盘，丢失的存储桶和对象。注意：此命令仅适用于MinIO擦除编码设置（独立和分布式）。

服务器已经有一个浅色的后台进程，可以在必要时修复磁盘，存储桶和对象。但是，它不会检测某些类型的数据损坏，尤其是很少发生的数据损坏，例如静默数据损坏。在这种情况下，您需要隔一段时间手动运行提供以下标志的heal命令：--scan deep。

要显示后台恢复过程的状态，只需键入以下命令：`mc admin heal your-alias`。

要扫描和修复所有内容，请输入：`mc admin heal -r your-alias`。

```
NAME:
  mc admin heal - heal disks, buckets and objects on MinIO server

FLAGS:
  --scan value                     select the healing scan mode (normal/deep) (default: "normal")
  --recursive, -r                  heal recursively
  --dry-run, -n                    only inspect data, but do not mutate
  --force-start, -f                force start a new heal sequence
  --force-stop, -s                 force stop a running heal sequence
  --remove                         remove dangling objects in heal sequence
  --help, -h                       show help
```

*示例：更换新磁盘后修复MinIO集群，递归修复所有存储桶和对象，其中'myminio'是MinIO服务器别名。*

```
mc admin heal -r myminio
```

*示例：递归修复特定存储桶上的MinIO集群，其中“ myminio”是MinIO服务器别名。*

```
mc admin heal -r myminio/mybucket
```

*示例：递归修复特定对象前缀上的MinIO集群，其中“ myminio”是MinIO服务器别名。*

```
mc admin heal -r myminio/mybucket/myobjectprefix
```

*示例：显示MinIO集群中自我修复过程的状态。*

```
mc admin heal myminio/
```

<a name="profile"> </a>
### 命令`profile` - 生成配置文件数据以进行调试

```
NAME:
  mc admin profile - generate profile data for debugging purposes

COMMANDS:
  start  start recording profile data
  stop   stop and download profile data
```

开始进行CPU分析
```
mc admin profile start --type cpu myminio/
```

<a name="top"> </a>
### 命令`top` - 为MinIO提供类似top的统计信息
注意：此命令仅适用于分布式MinIO设置。单节点和网关部署不支持此功能。

```
NAME:
  mc admin top - provide top like statistics for MinIO

COMMANDS:
  locks  Get a list of the 10 oldest locks on a MinIO cluster.
```

*示例：获取分布式MinIO群集上10个最旧锁的列表，其中'myminio'是MinIO群集别名。*

```
mc admin top locks myminio
```

<a name="trace"> </a>
### 命令`trace` - 显示MinIO服务器的http跟踪
`trace`命令显示一台或所有MinIO服务器（在分布式集群下）的服务器http跟踪

```
NAME:
  mc admin trace - show http trace for MinIO server

FLAGS:
  --verbose, -v                 print verbose trace
  --all, -a                     trace all traffic (including internode traffic between MinIO servers)
  --errors, -e                  trace failed requests only
  --help, -h                    show help
```

*示例：显示MinIO服务器http跟踪。*

```
mc admin trace myminio
172.16.238.1 [REQUEST (objectAPIHandlers).ListBucketsHandler-fm] [154828542.525557] [2019-01-23 23:17:05 +0000]
172.16.238.1 GET /
172.16.238.1 Host: 172.16.238.3:9000
172.16.238.1 X-Amz-Date: 20190123T231705Z
172.16.238.1 Authorization: AWS4-HMAC-SHA256 Credential=minio/20190123/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=8385097f264efaf1b71a9b56514b8166bb0a03af8552f83e2658f877776c46b3
172.16.238.1 User-Agent: MinIO (linux; amd64) minio-go/v6.0.8 mc/2019-01-23T23:15:38Z
172.16.238.1 X-Amz-Content-Sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
172.16.238.1
172.16.238.1 <BODY>
172.16.238.1 [RESPONSE] [154828542.525557] [2019-01-23 23:17:05 +0000]
172.16.238.1 200 OK
172.16.238.1 X-Amz-Request-Id: 157C9D641F42E547
172.16.238.1 X-Minio-Deployment-Id: 5f20fd91-6880-455f-a26d-07804b6821ca
172.16.238.1 X-Xss-Protection: 1; mode=block
172.16.238.1 Accept-Ranges: bytes
172.16.238.1 Content-Security-Policy: block-all-mixed-content
172.16.238.1 Content-Type: application/xml
172.16.238.1 Server: MinIO/RELEASE.2019-09-05T23-24-38Z
172.16.238.1 Vary: Origin
...
```

<a name="console"> </a>
### 命令`console` - 显示MinIO服务器的控制台日志
`console`命令显示一台或所有MinIO服务器的服务器日志（在分布式集群下）

```
NAME:
  mc admin console - show console logs for MinIO server

FLAGS:
  --limit value, -l value       show last n log entries (default: 10)
  --help, -h                    show help
```

*示例：显示MinIO服务器http跟踪。*

```
mc admin console myminio

 API: SYSTEM(bucket=images)
 Time: 22:48:06 PDT 09/05/2019
 DeploymentID: 6faeded5-5cf3-4133-8a37-07c5d500207c
 RequestID: <none>
 RemoteHost: <none>
 UserAgent: <none>
 Error: ARN 'arn:minio:sqs:us-east-1:1:webhook' not found
        4: cmd/notification.go:1189:cmd.readNotificationConfig()
        3: cmd/notification.go:780:cmd.(*NotificationSys).refresh()
        2: cmd/notification.go:815:cmd.(*NotificationSys).Init()
        1: cmd/server-main.go:375:cmd.serverMain()
```

<a name="prometheus"> </a>

### 命令`prometheus` - 管理prometheus配置设置

`generate`命令生成prometheus配置（要粘贴到prometheus.yml中）

```
NAME:
  mc admin prometheus - manages prometheus config

USAGE:
  mc admin prometheus COMMAND [COMMAND FLAGS | -h] [ARGUMENTS...]

COMMANDS:
  generate  generates prometheus config

```

示例：为<alias>生成prometheus配置。

```
mc admin prometheus generate <alias>
- job_name: minio-job
  bearer_token: <token>
  metrics_path: /minio/prometheus/metrics
  scheme: http
  static_configs:
  - targets: ['localhost:9000']
```

<a name="kms"> </a>

### 命令`kms` - 执行KMS管理操作

`kms`命令可用于执行KMS管理操作。

```
NAME:
  mc admin kms - perform KMS management operations

USAGE:
  mc admin kms COMMAND [COMMAND FLAGS | -h] [ARGUMENTS...]
```

key子命令可用于执行主密钥管理操作。

```
NAME:
  mc admin kms key - manage KMS keys

USAGE:
  mc admin kms key COMMAND [COMMAND FLAGS | -h] [ARGUMENTS...]
```


*示例：显示默认主键的状态信息*
```
mc admin kms key status play
Key: my-minio-key
 	 • Encryption ✔
 	 • Decryption ✔
```

*示例：显示一个特定主键的状态信息*
```
mc admin kms key status play test-key-1
Key: test-key-1
 	 • Encryption ✔
 	 • Decryption ✔
```
