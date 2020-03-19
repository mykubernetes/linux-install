官方网址：https://docs.minio.io/cn/

github网址： https://github.com/minio/minio/blob/master/docs/zh_CN/distributed/README.md

中文文档： https://www.bookstack.cn/read/MinioCookbookZH/17.md

单机运行
===
```
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
./minio server /data
Endpoint:  http://192.168.101.70:9000  http://127.0.0.1:9000    #登录地址
AccessKey: minioadmin                                           #登录的key
SecretKey: minioadmin                                           #加密的key

Browser Access:
   http://192.168.101.70:9000  http://127.0.0.1:9000    

Command-line Access: https://docs.min.io/docs/minio-client-quickstart-guide
   $ mc config host add myminio http://192.168.101.70:9000 minioadmin minioadmin

Object API (Amazon S3 compatible):
   Go:         https://docs.min.io/docs/golang-client-quickstart-guide
   Java:       https://docs.min.io/docs/java-client-quickstart-guide
   Python:     https://docs.min.io/docs/python-client-quickstart-guide
   JavaScript: https://docs.min.io/docs/javascript-client-quickstart-guide
   .NET:       https://docs.min.io/docs/dotnet-client-quickstart-guide
Detected default credentials 'minioadmin:minioadmin', please change the credentials immediately using 'MINIO_ACCESS_KEY' and 'MINIO_SECRET_KEY'

二进制安装配置文件地址
/data/.minio.sys/config

```




分布式运行命令
===
```
export MINIO_ACCESS_KEY=<ACCESS_KEY>
export MINIO_SECRET_KEY=<SECRET_KEY>
minio server http://192.168.1.11/export1 http://192.168.1.12/export2 \
               http://192.168.1.13/export3 http://192.168.1.14/export4 \
               http://192.168.1.15/export5 http://192.168.1.16/export6 \
               http://192.168.1.17/export7 http://192.168.1.18/export8
```

![分布式Minio,8节点，每个节点一块盘](https://github.com/minio/minio/blob/master/docs/screenshots/Architecture-diagram_distributed_8.jpg?raw=true)

```
export MINIO_ACCESS_KEY=<ACCESS_KEY>
export MINIO_SECRET_KEY=<SECRET_KEY>
minio server http://192.168.1.11/export1 http://192.168.1.11/export2 \
               http://192.168.1.11/export3 http://192.168.1.11/export4 \
               http://192.168.1.12/export1 http://192.168.1.12/export2 \
               http://192.168.1.12/export3 http://192.168.1.12/export4 \
               http://192.168.1.13/export1 http://192.168.1.13/export2 \
               http://192.168.1.13/export3 http://192.168.1.13/export4 \
               http://192.168.1.14/export1 http://192.168.1.14/export2 \
               http://192.168.1.14/export3 http://192.168.1.14/export4
```

![分布式Minio,4节点，每节点4块盘](https://github.com/minio/minio/blob/master/docs/screenshots/Architecture-diagram_distributed_16.jpg?raw=true)

扩展现有的分布式集群
```
export MINIO_ACCESS_KEY=<ACCESS_KEY>
export MINIO_SECRET_KEY=<SECRET_KEY>
minio server http://host{1...32}/export{1...32} http://host{33...64}/export{1...32}
```

mc命令介绍
===

mc命令下载安装
---
```
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
./mc --help

shell自动补全
下载autocomplete/bash_autocomplete到/etc/bash_completion.d/，将其重命名为mc。运行source命令让其生效
wget https://raw.githubusercontent.com/minio/mc/master/autocomplete/bash_autocomplete -O /etc/bash_completion.d/mc
source /etc/bash_completion.d/mc
```

添加一个云存储服务
---
MinIO云存储  
从MinIO服务获得URL、access key和secret key  
```
./mc config host add minio http://192.168.101.70:9000 minioadmin minioadmin S3v4
Added `minio` successfully.
```

Amazon S3云存储
```
mc config host add s3 https://s3.amazonaws.com BKIKJAA5BMMU2RHO6IBB V7f1CwQqAcwo80UEIJEjc5gVQUSSx5ohQ9GSrr12 S3v4
```

Google云存储
```
mc config host add gcs  https://storage.googleapis.com BKIKJAA5BMMU2RHO6IBB V8f1CwQqAcwo80UEIJEjc5gVQUSSx5ohQ9GSrr12 S3v2
```
注意：Google云存储只支持旧版签名版本V2，所以你需要选择S3v2

mc配置文件路径，在家目录下的一个隐藏文件夹
---
```
tree ~/.mc
/home/supernova/.mc
├── config.json
├── session
└── share

# ll
total 8
drwx------. 3 root root  17 Mar 18 22:16 certs
-rw-------. 1 root root 856 Mar 18 22:18 config.json
-rw-------. 1 root root 700 Mar 18 22:18 config.json.old
drwx------. 2 root root   6 Mar 18 22:16 session
drwx------. 2 root root  48 Mar 18 22:16 share

通过mc config host添加的所有凭证，endpoint信息都存储在这里
# cat config.json
{
	"version": "9",
	"hosts": {
		"gcs": {
			"url": "https://storage.googleapis.com",
			"accessKey": "YOUR-ACCESS-KEY-HERE",
			"secretKey": "YOUR-SECRET-KEY-HERE",
			"api": "S3v2",
			"lookup": "dns"
		},
		"local": {
			"url": "http://localhost:9000",
			"accessKey": "",
			"secretKey": "",
			"api": "S3v4",
			"lookup": "auto"
		},
		"minio": {
			"url": "http://192.168.101.70:9000",
			"accessKey": "minioadmin",
			"secretKey": "minioadmin",
			"api": "s3v4",
			"lookup": "auto"
		},
		"play": {
			"url": "https://play.min.io",
			"accessKey": "Q3AM3UQ867SPQQA43P2F",
			"secretKey": "zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG",
			"api": "S3v4",
			"lookup": "auto"
		},
		"s3": {
			"url": "https://s3.amazonaws.com",
			"accessKey": "YOUR-ACCESS-KEY-HERE",
			"secretKey": "YOUR-SECRET-KEY-HERE",
			"api": "S3v4",
			"lookup": "dns"
		}
	}
}
```

全局参数

### 参数 [--debug]
Debug参数开启控制台输出debug信息。

*示例：输出`ls`命令的详细debug信息。*

```
mc --debug ls play
mc: <DEBUG> GET / HTTP/1.1
Host: play.min.io
User-Agent: MinIO (darwin; amd64) minio-go/1.0.1 mc/2016-04-01T00:22:11Z
Authorization: AWS4-HMAC-SHA256 Credential=**REDACTED**/20160408/us-east-1/s3/aws4_request, SignedHeaders=expect;host;x-amz-content-sha256;x-amz-date, Signature=**REDACTED**
Expect: 100-continue
X-Amz-Content-Sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
X-Amz-Date: 20160408T145236Z
Accept-Encoding: gzip

mc: <DEBUG> HTTP/1.1 200 OK
Transfer-Encoding: chunked
Accept-Ranges: bytes
Content-Type: text/xml; charset=utf-8
Date: Fri, 08 Apr 2016 14:54:55 GMT
Server: MinIO/DEVELOPMENT.2016-04-07T18-53-27Z (linux; amd64)
Vary: Origin
X-Amz-Request-Id: HP30I0W2U49BDBIO

mc: <DEBUG> Response Time:  1.220112837s

[...]

[2016-04-08 03:56:14 IST]     0B albums/
[2016-04-04 16:11:45 IST]     0B backup/
[2016-04-01 20:10:53 IST]     0B deebucket/
[2016-03-28 21:53:49 IST]     0B guestbucket/
```

### 参数 [--json]
JSON参数启用JSON格式的输出。

*示例：列出MinIO play服务的所有存储桶。*

```
mc --json ls play
{"status":"success","type":"folder","lastModified":"2016-04-08T03:56:14.577+05:30","size":0,"key":"albums/"}
{"status":"success","type":"folder","lastModified":"2016-04-04T16:11:45.349+05:30","size":0,"key":"backup/"}
{"status":"success","type":"folder","lastModified":"2016-04-01T20:10:53.941+05:30","size":0,"key":"deebucket/"}
{"status":"success","type":"folder","lastModified":"2016-03-28T21:53:49.217+05:30","size":0,"key":"guestbucket/"}
```

### 参数 [--no-color]
这个参数禁用颜色主题。对于一些比较老的终端有用。

### 参数 [--quiet]
这个参数关闭控制台日志输出。

### 参数 [--config-dir]
这个参数参数自定义的配置文件路径。

### 参数 [ --insecure]
跳过SSL证书验证。


mc命令使用
---
```
ls       列出文件和文件夹。
mb       创建一个存储桶或一个文件夹。
cat      显示文件和对象内容。
pipe     将一个STDIN重定向到一个对象或者文件或者STDOUT。
share    生成用于共享的URL。
cp       拷贝文件和对象。
mirror   给存储桶和文件夹做镜像。
find     基于参数查找文件。
diff     对两个文件夹或者存储桶比较差异。
rm       删除文件和对象。
events   管理对象通知。
watch    监听文件和对象的事件。
policy   管理访问策略。
session  为cp命令管理保存的会话。
config   管理mc配置文件。
update   检查软件更新。
version  输出版本信息。
```

```
#列出文件和文件夹
mc ls minio

#创建一个bucket
mc mb minio/test

#将本地文件拷贝到object
mc cp /etc/fstab minio/test/
/etc/fstab:         465 B / 465 B ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 73.92 KiB/s 0s

#精确查找文件
mc find minio/test --name fstab
minio/test/fstab

#查看bucket大小
# mc du   minio/test/
10MiB	test


```

命令

|                                      |                                                    |                                        |
|:-------------------------------------|:---------------------------------------------------|:---------------------------------------|
| [**ls** - 列出存储桶和对象](#ls)     | [**mb** - 创建存储桶](#mb)                         | [**cat** - 合并对象](#cat)             |
| [**cp** - 拷贝对象](#cp)             | [**rm** - 删除对象](#rm)                           | [**pipe** - Pipe到一个对象](#pipe)     |
| [**share** - 共享](#share)           | [**mirror** - 存储桶镜像](#mirror)                 | [**find** - 查找文件和对象](#find)     |
| [**diff** - 比较存储桶差异](#diff)   | [**policy** - 给存储桶或前缀设置访问策略](#policy) |                                        |
| [**config** - 管理配置文件](#config) | [**watch** - 事件监听](#watch)                     | [**events** - 管理存储桶事件](#events) |
| [**update** - 管理软件更新](#update) | [**version** - 显示版本信息](#version)             |                                        |


###  `ls`命令 - 列出对象
`ls`命令列出文件、对象和存储桶。使用`--incomplete` flag可列出未完整拷贝的内容。

```
用法：
   mc ls [FLAGS] TARGET [TARGET ...]

FLAGS:
  --help, -h                       显示帮助。
  --recursive, -r		   递归。
  --incomplete, -I		   列出未完整上传的对象。
```

*示例： 列出所有https://play.min.io上的存储桶。*

```
mc ls play
[2016-04-08 03:56:14 IST]     0B albums/
[2016-04-04 16:11:45 IST]     0B backup/
[2016-04-01 20:10:53 IST]     0B deebucket/
[2016-03-28 21:53:49 IST]     0B guestbucket/
[2016-04-08 20:58:18 IST]     0B mybucket/
```
<a name="mb"></a>
### `mb`命令 - 创建存储桶
`mb`命令在对象存储上创建一个新的存储桶。在文件系统，它就和`mkdir -p`命令是一样的。存储桶相当于文件系统中的磁盘或挂载点，不应视为文件夹。MinIO对每个​​用户创建的存储桶数量没有限制。
在Amazon S3上，每个帐户被限制为100个存储桶。有关更多信息，请参阅[S3上的存储桶限制和限制](http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html) 。

```
用法：
   mc mb [FLAGS] TARGET [TARGET...]

FLAGS:
  --help, -h                       显示帮助。
  --region "us-east-1"		   指定存储桶的region，默认是‘us-east-1’.

```

*示例：在https://play.min.io上创建一个名叫"mybucket"的存储桶。*


```
mc mb play/mybucket
Bucket created successfully ‘play/mybucket’.
```

<a name="cat"></a>

### `cat`命令 - 合并对象
`cat`命令将一个文件或者对象的内容合并到另一个上。你也可以用它将对象的内容输出到stdout。

```
用法：
   mc cat [FLAGS] SOURCE [SOURCE...]

FLAGS:
  --help, -h                       显示帮助。
```

*示例： 显示`myobject.txt`文件的内容*

```
mc cat play/mybucket/myobject.txt
Hello MinIO!!
```
<a name="pipe"></a>
### `pipe`命令 - Pipe到对象
`pipe`命令拷贝stdin里的内容到目标输出，如果没有指定目标输出，则输出到stdout。

```
用法：
   mc pipe [FLAGS] [TARGET]

FLAGS:
  --help, -h					显示帮助。
```

*示例： 将MySQL数据库dump文件输出到Amazon S3。*

```
mysqldump -u root -p ******* accountsdb | mc pipe s3/sql-backups/backups/accountsdb-oct-9-2015.sql
```

<a name="cp"></a>
### `cp`命令 - 拷贝对象
`cp`命令拷贝一个或多个源文件目标输出。所有到对象存储的拷贝操作都进行了MD4SUM checkSUM校验。可以从故障点恢复中断或失败的复制操作。

```
用法：
   mc cp [FLAGS] SOURCE [SOURCE...] TARGET

FLAGS:
  --help, -h                       显示帮助。
  --recursive, -r		   递归拷贝。
```

*示例： 拷贝一个文本文件到对象存储。*

```
mc cp myobject.txt play/mybucket
myobject.txt:    14 B / 14 B  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  100.00 % 41 B/s 0
```
<a name="rm"></a>
### `rm`命令 - 删除存储桶和对象。
使用`rm`命令删除文件对象或者存储桶。

```
用法：
   mc rm [FLAGS] TARGET [TARGET ...]

FLAGS:
  --help, -h                       显示帮助。
  --recursive, -r	       	   递归删除。
  --force			   强制执行删除操作。
  --prefix			   删除批配这个前缀的对象。
  --incomplete, -I		删除未完整上传的对象。
  --fake			   模拟一个假的删除操作。
  --stdin			   从STDIN中读对象列表。
  --older-than value               删除N天前的对象（默认是0天）。
```

*示例： 删除一个对象。*

```
mc rm play/mybucket/myobject.txt
Removed ‘play/mybucket/myobject.txt’.
```

*示例：删除一个存储桶并递归删除里面所有的内容。由于这个操作太危险了，你必须传`--force`参数指定强制删除。*

```
mc rm --recursive --force play/myobject
Removed ‘play/myobject/newfile.txt’.
Removed 'play/myobject/otherobject.txt’.
```

*示例： 从`mybucket`里删除所有未完整上传的对象。*

```
mc rm  --incomplete --recursive --force play/mybucket
Removed ‘play/mybucket/mydvd.iso’.
Removed 'play/mybucket/backup.tgz’.
```
*示例： 删除一天前的对象。*

```
mc rm --force --older-than=1 play/mybucket/oldsongs
```

<a name="share"></a>
### `share`命令 - 共享
`share`命令安全地授予上传或下载的权限。此访问只是临时的，与远程用户和应用程序共享也是安全的。如果你想授予永久访问权限，你可以看看`mc policy`命令。

生成的网址中含有编码后的访问认证信息，任何企图篡改URL的行为都会使访问无效。想了解这种机制是如何工作的，请参考[Pre-Signed URL](http://docs.aws.amazon.com/AmazonS3/latest/dev/ShareObjectPreSignedURL.html)技术。

```
用法：
   mc share [FLAGS] COMMAND

FLAGS:
  --help, -h                       显示帮助。

COMMANDS:
   download	  生成有下载权限的URL。
   upload	  生成有上传权限的URL。
   list		  列出先前共享的对象和文件夹。
```

### 子命令`share download` - 共享下载
`share download`命令生成不需要access key和secret key即可下载的URL，过期参数设置成最大有效期（不大于7天），过期之后权限自动回收。

```
用法：
   mc share download [FLAGS] TARGET [TARGET...]

FLAGS:
  --help, -h                       显示帮助。
  --recursive, -r		   递归共享所有对象。
  --expire, -E "168h"		   设置过期时限，NN[h|m|s]。
```

*示例： 生成一个对一个对象有4小时访问权限的URL。*

```

mc share download --expire 4h play/mybucket/myobject.txt
URL: https://play.min.io/mybucket/myobject.txt
Expire: 0 days 4 hours 0 minutes 0 seconds
Share: https://play.min.io/mybucket/myobject.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=Q3AM3UQ867SPQQA43P2F%2F20160408%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20160408T182008Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=1527fc8f21a3a7e39ce3c456907a10b389125047adc552bcd86630b9d459b634

```

#### 子命令`share upload` - 共享上传
`share upload`命令生成不需要access key和secret key即可上传的URL。过期参数设置成最大有效期（不大于7天），过期之后权限自动回收。
Content-type参数限制只允许上传指定类型的文件。

```
用法：
   mc share upload [FLAGS] TARGET [TARGET...]

FLAGS:
  --help, -h                       显示帮助。
  --recursive, -r   		   递归共享所有对象。
  --expire, -E "168h"		   设置过期时限，NN[h|m|s].
```

*示例： 生成一个`curl`命令，赋予上传到`play/mybucket/myotherobject.txt`的权限。*

```
mc share upload play/mybucket/myotherobject.txt
URL: https://play.min.io/mybucket/myotherobject.txt
Expire: 7 days 0 hours 0 minutes 0 seconds
Share: curl https://play.min.io/mybucket -F x-amz-date=20160408T182356Z -F x-amz-signature=de343934bd0ba38bda0903813b5738f23dde67b4065ea2ec2e4e52f6389e51e1 -F bucket=mybucket -F policy=eyJleHBpcmF0aW9uIjoiMjAxNi0wNC0xNVQxODoyMzo1NS4wMDdaIiwiY29uZGl0aW9ucyI6W1siZXEiLCIkYnVja2V0IiwibXlidWNrZXQiXSxbImVxIiwiJGtleSIsIm15b3RoZXJvYmplY3QudHh0Il0sWyJlcSIsIiR4LWFtei1kYXRlIiwiMjAxNjA0MDhUMTgyMzU2WiJdLFsiZXEiLCIkeC1hbXotYWxnb3JpdGhtIiwiQVdTNC1ITUFDLVNIQTI1NiJdLFsiZXEiLCIkeC1hbXotY3JlZGVudGlhbCIsIlEzQU0zVVE4NjdTUFFRQTQzUDJGLzIwMTYwNDA4L3VzLWVhc3QtMS9zMy9hd3M0X3JlcXVlc3QiXV19 -F x-amz-algorithm=AWS4-HMAC-SHA256 -F x-amz-credential=Q3AM3UQ867SPQQA43P2F/20160408/us-east-1/s3/aws4_request -F key=myotherobject.txt -F file=@<FILE>
```

#### 子命令`share list` - 列出之前的共享
`share list`列出没未过期的共享URL。

```
用法：
   mc share list COMMAND

COMMAND:
   upload:   列出先前共享的有上传权限的URL。
   download: 列出先前共享的有下载权限的URL。
```

<a name="mirror"></a>
### `mirror`命令 - 存储桶镜像
`mirror`命令和`rsync`类似，只不过它是在文件系统和对象存储之间做同步。

```
用法：
   mc mirror [FLAGS] SOURCE TARGET

FLAGS:
  --help, -h                       显示帮助。
  --force			   强制覆盖已经存在的目标。
  --fake			   模拟一个假的操作。
  --watch, -w                      监听改变并执行镜像操作。
  --remove			   删除目标上的外部的文件。
```

*示例： 将一个本地文件夹镜像到https://play.min.io上的'mybucket'存储桶。*

```
mc mirror localdir/ play/mybucket
localdir/b.txt:  40 B / 40 B  ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃  100.00 % 73 B/s 0
```

*示例： 持续监听本地文件夹修改并镜像到https://play.min.io上的'mybucket'存储桶。*

```
mc mirror -w localdir play/mybucket
localdir/new.txt:  10 MB / 10 MB  ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃  100.00 % 1 MB/s 15s
```

<a name="find"></a>
### `find`命令 - 查找文件和对象
``find``命令通过指定参数查找文件，它只列出满足条件的数据。

```
用法：
  mc find PATH [FLAGS]

FLAGS:
  --help, -h                       显示帮助。
  --exec value                     为每个匹配对象生成一个外部进程（请参阅FORMAT）
  --name value                     查找匹配通配符模式的对象。
  ...
  ...
```

*示例： 持续从s3存储桶中查找所有jpeg图像，并复制到minio "play/bucket"存储桶*
```
mc find s3/bucket --name "*.jpg" --watch --exec "mc cp {} play/bucket"
```

<a name="diff"></a>
### `diff`命令 - 显示差异
``diff``命令计算两个目录之间的差异。它只列出缺少的或者大小不同的内容。

它*不*比较内容，所以可能的是，名称相同，大小相同但内容不同的对象没有被检测到。这样，它可以在不同站点或者大量数据的情况下快速比较。

```
用法：
  mc diff [FLAGS] FIRST SECOND

FLAGS:
  --help, -h                       显示帮助。
```

*示例： 比较一个本地文件夹和一个远程对象存储服务*

```
 mc diff localdir play/mybucket
‘localdir/notes.txt’ and ‘https://play.min.io/mybucket/notes.txt’ - only in first.
```

<a name="watch"></a>
### `watch`命令 - 监听文件和对象存储事件。
``watch``命令提供了一种方便监听对象存储和文件系统上不同类型事件的方式。

```
用法：
  mc watch [FLAGS] PATH

FLAGS:
  --events value                   过滤不同类型的事件，默认是所有类型的事件 (默认： "put,delete,get")
  --prefix value                   基于前缀过滤事件。
  --suffix value                   基于后缀过滤事件。
  --recursive                      递归方式监听事件。
  --help, -h                       显示帮助。
```

*示例： 监听对象存储的所有事件*

```
mc watch play/testbucket
[2016-08-18T00:51:29.735Z] 2.7KiB ObjectCreated https://play.min.io/testbucket/CONTRIBUTING.md
[2016-08-18T00:51:29.780Z]  1009B ObjectCreated https://play.min.io/testbucket/MAINTAINERS.md
[2016-08-18T00:51:29.839Z] 6.9KiB ObjectCreated https://play.min.io/testbucket/README.md
```

*示例： 监听本地文件夹的所有事件*

```
mc watch ~/Photos
[2016-08-17T17:54:19.565Z] 3.7MiB ObjectCreated /home/minio/Downloads/tmp/5467026530_a8611b53f9_o.jpg
[2016-08-17T17:54:19.565Z] 3.7MiB ObjectCreated /home/minio/Downloads/tmp/5467026530_a8611b53f9_o.jpg
...
[2016-08-17T17:54:19.565Z] 7.5MiB ObjectCreated /home/minio/Downloads/tmp/8771468997_89b762d104_o.jpg
```

<a name="events"></a>
### `events`命令 - 管理存储桶事件通知。
``events``提供了一种方便的配置存储桶的各种类型事件通知的方式。MinIO事件通知可以配置成使用 AMQP，Redis，ElasticSearch，NATS和PostgreSQL服务。MinIO configuration提供了如何配置的更多细节。

```
用法：
  mc events COMMAND [COMMAND FLAGS | -h] [ARGUMENTS...]

COMMANDS:
  add     添加一个新的存储桶通知。
  remove  删除一个存储桶通知。使用'--force'可以删除所有存储桶通知。
  list    列出存储桶通知。

FLAGS:
  --help, -h                       显示帮助。
```

*示例： 列出所有存储桶通知。*

```
mc events list play/andoria
MyTopic        arn:minio:sns:us-east-1:1:TestTopic    s3:ObjectCreated:*,s3:ObjectRemoved:*   suffix:.jpg
```

*示例： 添加一个新的'sqs'通知，仅接收ObjectCreated事件。*

```
mc events add play/andoria arn:minio:sqs:us-east-1:1:your-queue --events put
```

*示例： 添加一个带有过滤器的'sqs'通知。*

给`sqs`通知添加`prefix`和`suffix`过滤规则。

```
mc events add play/andoria arn:minio:sqs:us-east-1:1:your-queue --prefix photos/ --suffix .jpg
```

*示例： 删除一个'sqs'通知*

```
mc events remove play/andoria arn:minio:sqs:us-east-1:1:your-queue
```

<a name="policy"></a>
### `policy`命令 - 管理存储桶策略
管理匿名访问存储桶和其内部内容的策略。

```
用法：
  mc policy [FLAGS] PERMISSION TARGET
  mc policy [FLAGS] TARGET
  mc policy list [FLAGS] TARGET

PERMISSION:
  Allowed policies are: [none, download, upload, public].

FLAGS:
  --help, -h                       显示帮助。
```

*示例： 显示当前匿名存储桶策略*

显示当前``mybucket/myphotos/2020/``子文件夹的匿名策略。

```
mc policy play/mybucket/myphotos/2020/
Access permission for ‘play/mybucket/myphotos/2020/’ is ‘none’
```

*示例：设置可下载的匿名存储桶策略。*

设置``mybucket/myphotos/2020/``子文件夹可匿名下载的策略。现在，这个文件夹下的对象可被公开访问。比如：``mybucket/myphotos/2020/yourobjectname``可通过这个URL [https://play.min.io/mybucket/myphotos/2020/yourobjectname](https://play.min.io/mybucket/myphotos/2020/yourobjectname)访问。

```
mc policy set download play/mybucket/myphotos/2020/
Access permission for ‘play/mybucket/myphotos/2020/’ is set to 'download'
```

*示例：删除当前的匿名存储桶策略*

删除所有*mybucket/myphotos/2020/*这个子文件夹下的匿名存储桶策略。

```
mc policy set none play/mybucket/myphotos/2020/
Access permission for ‘play/mybucket/myphotos/2020/’ is set to 'none'
```

<a name="config"></a>
### `config`命令 - 管理配置文件
`config host`命令提供了一个方便地管理`~/.mc/config.json`配置文件中的主机信息的方式，你也可以用文本编辑器手动修改这个配置文件。

```
用法：
  mc config host COMMAND [COMMAND FLAGS | -h] [ARGUMENTS...]

COMMANDS:
  add, a      添加一个新的主机到配置文件。
  remove, rm  从配置文件中删除一个主机。
  list, ls    列出配置文件中的主机。

FLAGS:
  --help, -h                       显示帮助。
```

*示例： 管理配置文件*

添加MinIO服务的access和secret key到配置文件，注意，shell的history特性可能会记录这些信息，从而带来安全隐患。在`bash` shell,使用`set -o`和`set +o`来关闭和开启history特性。

```
set +o history
mc config host add myminio http://localhost:9000 OMQAGGOL63D7UNVQFY8X GcY5RHNmnEWvD/1QxD3spEIGj+Vt9L7eHaAaBTkJ
set -o history
```

<a name="update"></a>
### `update`命令 - 软件更新
从[https://dl.min.io](https://dl.min.io)检查软件更新。Experimental标志会检查unstable实验性的版本，通常用作测试用途。

```
用法：
  mc update [FLAGS]

FLAGS:
  --quiet, -q  关闭控制台输出。
  --json       使用JSON格式输出。
  --help, -h   显示帮助。
```

*示例： 检查更新*

```
mc update
You are already running the most recent version of ‘mc’.
```

<a name="version"></a>
### `version`命令 - 显示版本信息
显示当前安装的`mc`版本。

```
用法：
  mc version [FLAGS]

FLAGS:
  --quiet, -q  关闭控制台输出。
  --json       使用JSON格式输出。
  --help, -h   显示帮助。
```

 *示例： 输出mc版本。*

```
mc version
Version: 2016-04-01T00:22:11Z
Release-tag: RELEASE.2016-04-01T00-22-11Z
Commit-id: 12adf3be326f5b6610cdd1438f72dfd861597fce
```

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
### 命令`update`-更新所有MinIO服务器
update命令提供了一种更新集群中所有MinIO服务器的方法。您还可以使用带有`update`命令的私有镜像服务器来更新MinIO集群。如果MinIO在无法访问Internet的环境中运行，这很有用。

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
### 命令`service`-重新启动并停止所有MinIO服务器
服务命令提供了一种重新启动和停止所有MinIO服务器的方法。

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
### 命令`info`-显示MinIO服务器信息
“ info”命令显示一台或多台MinIO服务器的服务器信息（在分布式集群下）

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
### 命令`policy`-管理固定策略
使用policy命令在MinIO服务器上添加，删除，列出策略。

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
### 命令`user`-管理用户
用户命令，用于添加，删除，启用，禁用MinIO服务器上的用户。

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
### 命令`group`-管理组
使用group命令在MinIO服务器上添加，删除，信息，列出，启用，禁用组。

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
### 命令`config`-管理服务器配置
config命令用于管理MinIO服务器配置。

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
### 命令`heal`-修复MinIO服务器上的磁盘，存储桶和对象
使用heal命令修复MinIO服务器上的磁盘，丢失的存储桶和对象。注意：此命令仅适用于MinIO擦除编码设置（独立和分布式）。

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
### 命令`profile`-生成配置文件数据以进行调试

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
### 命令`top`-为MinIO提供类似top的统计信息
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
### 命令`trace`-显示MinIO服务器的http跟踪
trace命令显示一台或所有MinIO服务器（在分布式集群下）的服务器http跟踪

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
### 命令`console`-显示MinIO服务器的控制台日志
“ console”命令显示一台或所有MinIO服务器的服务器日志（在分布式集群下）

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

### 命令`prometheus`-管理prometheus配置设置

generate”命令生成prometheus配置（要粘贴到prometheus.yml中）

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

### 命令`kms`-执行KMS管理操作

kms命令可用于执行KMS管理操作。

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
