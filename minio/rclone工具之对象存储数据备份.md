**安装rclone工具：**

下载地址：https://hub.fastgit.org/rclone/rclone/releases/tag/v1.56.0

安装工具：
`yum install ./rclone-v1.56.0-linux-amd64.rpm`

**配置工具：**

使用命令`rclone config`随便生成一个配置文件

之后修改生成的配置文件，配置文件默认路径`~/.config/rclone/rclone.conf`根据环境修改配置文件
```
[13:05:05 root@centos7 ~]#cat .config/rclone/rclone.conf
# Encrypted rclone configuration File
[minio]
type= s3
evn_auth= false
access_key_id =  ********    #密钥
secret_access_key = ********  #密钥
region = us-east-1
endpoint = http://****:***    #对象存储访问地址
location_constraint =
server_side_encryption =
```

**查看对象存储的存储桶**
```
[13:07:38 root@centos7 ~]#rclone lsd minio:
          -1 2021-02-20 15:11:20        -1 cpc-oss
          -1 2021-02-25 18:20:59        -1 oss-ga
          -1 2021-02-18 15:24:30        -1 test
```

**查看存储桶中的文件**
```
[13:07:41 root@centos7 ~]#rclone lsd minio:oss-ga
           0 2021-08-04 13:08:29        -1 common
```

**拷贝存储桶中的文件到本地**
```
[13:09:29 root@centos7 ~]#mkdir /backup -p
[13:08:29 root@centos7 ~]#rclone copy minio:oss-ga /backup/
```

**拷贝完成后使用命令对比桶文件与本地文件是否一致**
```
[13:13:42 root@centos7 ~]#rclone check minio:oss-ga /backup/
```

**拷贝完成后打包**
