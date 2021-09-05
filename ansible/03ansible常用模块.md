# 一、ansible模块的使用

## 1）查看ansible有哪些模块
```
# ansible-doc -l
```



## 2)查看模块帮助
```
# ansible-doc -s file
- name: Sets attributes of files
  file:
      attributes:            # Attributes the file or directory should have. To get supported flags look at the man page for `chattr' on the target system. This string should contain the attributes in the
                               same order as the one displayed by `lsattr'.
      follow:                # This flag indicates that filesystem links, if they exist, should be followed. Previous to Ansible 2.5, this was `no' by default.
      force:                 # force the creation of the symlinks in two cases: the source file does not exist (but will appear later); the destination exists and is a file (so, we need to unlink the "path"
                               file and create symlink to the "src" file in place of it).
      group:                 # Name of the group that should own the file/directory, as would be fed to `chown'.
      mode:                  # Mode the file or directory should be. For those used to `/usr/bin/chmod' remember that modes are actually octal numbers. You must either specify the leading zero so that
                               Ansible's YAML parser knows it is an octal number (like `0644' or `01777') or quote it (like `'644'' or `'0644'' so Ansible receives a string and
                               can do its own conversion from string into number.  Giving Ansible a number without following one of these rules will end up with a decimal number
                               which will have unexpected results. As of version 1.8, the mode may be specified as a symbolic mode (for example, `u+rwx' or `u=rw,g=r,o=r').
      owner:                 # Name of the user that should own the file/directory, as would be fed to `chown'.
      path:                  # (required) path to the file being managed.  Aliases: `dest', `name'
      recurse:               # recursively set the specified file attributes (applies only to directories)
      selevel:               # Level part of the SELinux file context. This is the MLS/MCS attribute, sometimes known as the `range'. `_default' feature works as for `seuser'.
      serole:                # Role part of SELinux file context, `_default' feature works as for `seuser'.
      setype:                # Type part of SELinux file context, `_default' feature works as for `seuser'.
      seuser:                # User part of SELinux file context. Will default to system policy, if applicable. If set to `_default', it will use the `user' portion of the policy if available.
      src:                   # path of the file to link to (applies only to `state=link' and `state=hard'). Will accept absolute, relative and nonexisting paths. Relative paths are relative to the file being
                               created (`path') which is how the UNIX command `ln -s SRC DEST' treats relative paths.
      state:                 # If `directory', all intermediate subdirectories will be created if they do not exist. Since Ansible 1.7 they will be created with the supplied permissions. If `file', the file
                               will NOT be created if it does not exist; see the `touch' value or the [copy] or [template] module if you want that behavior.  If `link', the
                               symbolic link will be created or changed. Use `hard' for hardlinks. If `absent', directories will be recursively deleted, and files or symlinks
                               will be unlinked. Note that `absent' will not cause `file' to fail if the `path' does not exist as the state did not change. If `touch' (new in
                               1.4), an empty file will be created if the `path' does not exist, while an existing file or directory will receive updated file access and
                               modification times (similar to the way `touch` works from the command line).
      unsafe_writes:         # Normally this module uses atomic operations to prevent data corruption or inconsistent reads from the target files, sometimes systems are configured or just broken in ways that
                               prevent this. One example are docker mounted files, they cannot be updated atomically and can only be done in an unsafe manner. This boolean
                               option allows ansible to fall back to unsafe methods of updating files for those cases in which you do not have any other choice. Be aware that
                               this is subject to race conditions and can lead to data corruption.
```

## 3)ping测试
```
# ansible all -m ping

192.168.101.69 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

# 二、ansible常用模块

## 1、command 模块 默认模块

### 1）command命令常用参数说明

| 参数 | 参数说明 |
|------|--------|
| chdir | 在执行命令之前，通过cd命令进入到指定目录中 # ansible clsn -m command -a "chdir=/tmp ls" |
| create | 定义一个文件是否存在，如果不存在运行相应命令；如果存在跳过此步骤 |
| executable | 改变shell使用command进行执行，并且执行时要使用绝对路径 |
| free_form | 命令模块采用自由形式命令运行；即可以输入任意linux命令 |
| removes | 定义一个文件是否存在，如果存在运行相应命令；如果不存在跳过此步骤 |
| warn(added in 1.8) | 如果ansible配置文件中定义了命令警告，如果参数设置了no/false，将不会警告此行命令 |

-  command不支持管道技术

### 2）不指定模块的时候默认使用的模块就是command
```
# ansible all -a "date"
192.168.101.69 | SUCCESS | rc=0 >>
Thu Oct 19 17:12:15 CST 2017
```

### 3）使用ansible自带模块执行命令 如果要用 > < | & ' ' 使用shell模块
```
# ansible all -m command -a "date"
192.168.101.69 | SUCCESS | rc=0 >>
Thu Oct 19 17:12:27 CST 2017
```

### 4）chdir参数的使用：
```
# ansible clsn -m command -a "chdir=/tmp pwd"
192.168.101.69 | SUCCESS | rc=0 >>
/tmp
```

### 5）creates 文件是否存在，不存在就执行命令
```
# ansible clsn -m command -a "creates=/etc/hosts date"
192.168.101.69 | SUCCESS | rc=0 >>
skipped, since /etc/hosts exists
```

### 6）removes 文件是否存在，不存在就不执行命令，
```
# ansible clsn -m command -a "removes=/etc/hosts date"
192.168.101.69 | SUCCESS | rc=0 >>
Fri Oct 20 13:32:40 CST 2017
```

## 2、shell模块 万能模块

### 1)shell 模块在远程执行脚本时，远程主机上一定要有相应的脚本
```
# ansible clsn -m shell -a "/bin/sh /server/scripts/ssh-key.sh"
192.168.101.69 | SUCCESS | rc=0 >>
fenfa 192.168.101.69 [  OK  ]
```

## 3、script 模块 执行脚本模块

### 1)在本地执行脚本时，将脚本中的内容传输到远程节点上运行
```
ansible all -m script -a "/server/scripts/free.sh"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 192.168.101.69 closed.\r\n",
    "stdout": "             total       used       free     shared    buffers     cached\r\nMem:          474M       377M        97M       532K        54M       202M\r\n-/+ buffers/cache:       120M       354M\r\nSwap:         767M         0B       767M\r\n",
    "stdout_lines": [
        "             total       used       free     shared    buffers     cached",
        "Mem:          474M       377M        97M       532K        54M       202M",
        "-/+ buffers/cache:       120M       354M",
        "Swap:         767M         0B       767M"
    ]
}
```
- 使用scripts模块，不用将脚本传输到远程节点，脚本本身不用进行授权，即可利用script模块执行。直接执行脚本即可，不需要使用sh


## 4、copy模块 把本地文件发送到远端

### 1）copy模块 把本地文件发送到远端

| 选项参数 | 选项说明 |
|---------|---------|
| backup(重要参数） | 在覆盖远端服务器文件之前，将远端服务器源文件备份，备份文件包含时间信息。有两个选项：yes|no |
| content | 用于替代"src”,可以直接设定指定文件的值 |
| dest | 必选项。要将源文件复制到的远程主机的绝对路径，如果源文件是一个目录，那么该路径也必须是个目录 |
| directory_mode | 递归设定目录的权限，默认为系统默认权限 |
| forces | 如果目标主机包含该文件，但内容不同，如果设置为yes,则强制覆盖。如果为no,则只有当目标主机的目标位置不存在该文件时，才复制。默认为yes。别名：thirsty |
| others| 所有的file模块里的选项都可以在这里使用 |
| src| 被复制到远程主机的本地文件，可以是绝对路径，也可以是相对路径。如果路径是一个目录，它将递归复制。在这种情况下，如果路径使用"/"来结尾，则只复制目录里的内容，如果没有使用"/"来结尾，则包含目录在内的整个内容全部复制，类似于rsync。 |
| mode| 定义文件或目录的权限；注意：是4位 |
| owner| 修改属主 |
| group| 修改属组 |

- src和content不能同时使用

### 2)使用copy 模块，将/etc/hosts 文件 传输到各个服务器送，权限修改为0600 属主属组为clsn
```
# ansible clsn -m copy -a "src=/etc/hosts dest=/tmp/ mode=0600 owner=clsn group=clsn"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "checksum": "b3c1ab140a1265cd7f6de9175a962988d93c629b",
    "dest": "/tmp/hosts",
    "gid": 500,
    "group": "clsn",
    "md5sum": "8c2b120b4742a806dcfdc8cfff6b6308",
    "mode": "0600",
    "owner": "clsn",
    "size": 357,
    "src": "/root/.ansible/tmp/ansible-tmp-1508410846.63-224022812989166/source",
    "state": "file",
    "uid": 500
}

# 检查结果
# ansible all -m shell -a "ls -l /tmp/hosts"
192.168.101.69 | SUCCESS | rc=0 >>
-rw------- 1 clsn clsn 357 Oct 19 19:00 /tmp/hosts
```

### 3)将本地的httpd.conf文件推送到远端，检查远端是否存在上一次的备份文件
```
ansible clsn -m copy -a "src=./httpd.conf dest=/etc/httpd/conf/httpd.conf owner=root group=root mode=644 backup=yes"
```

### 4)移动远程主机上的文件 remote_src=true 参数
```
# ansible clsn -m copy -a " src=/server/scripts/ssh-key.sh  dest=/tmp/ remote_src=true"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "checksum": "d27bd683bd37e15992d2493b50c9410e0f667c9c",
    "dest": "/tmp/ssh-key.sh",
    "gid": 0,
    "group": "root",
    "md5sum": "dc88a3a419e3657bae7d3ef31925cbde",
    "mode": "0644",
    "owner": "root",
    "size": 397,
    "src": "/server/scripts/ssh-key.sh",
    "state": "file",
    "uid": 0
}
```

### 5)定义文件中的内容 content=clsnedu.com 默认没有换行
```
# ansible clsn -m copy -a "content=clsnedu.com dest=/tmp/clsn666.txt"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "checksum": "291694840cd9f9c464263ea9b13421d8e74b7d00",
    "dest": "/tmp/clsn666.txt",
    "gid": 0,
    "group": "root",
    "md5sum": "0a6bb40847793839366d0ac014616d69",
    "mode": "0644",
    "owner": "root",
    "size": 13,
    "src": "/root/.ansible/tmp/ansible-tmp-1508466752.1-24733562369639/source",
    "state": "file",
    "uid": 0
}
```

### 6)拷贝目录
```
ansible node02 -m copy -a "src=/etc/pam.d/ dest=/tmp/"
```

## 4、file模块 设置文件属性

### 1）file模块常用参数

| 参数 | 参数说明 |
|-----|---------|
| path | 指定要操作的文件或目录,使用dest参数或者name参数指定文件或目录也可以 |
| owner | 设置复制传输后的数据属主信息 |
| group | 设置复制传输后的数据属组信息 |
| mode | 设置文件数据权限信息 |
| dest | 要创建的文件或目录命令，以及路径信息 |
| src | 指定要创建软链接的文件信息 |
| recurse | 当要操作的文件为目录，将recurse设置为yes，可以递归的修改目录中文件的属性 |
| state | state参数信息 |

| state参数 | state参数说明 |
|-----|---------|
| directory | 创建目录 |
| file | 创建文件 |
| link | 创建软链接 |
| hard | 创建出硬链接 |
| absent | 目录将被递归删除以及文件，而链接将被取消链接 |
| touch | 创建文件；如果路径不存在将创建一个空文件

- 注意：重命名和创建多级目录不能同时实现

### 1)创建目录,并设定属主、属组、权限
```
# ansible clsn -m file -a "dest=/tmp/clsn_dir state=directory owner=apache group=apache mode=755"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "gid": 0,
    "group": "apache",
    "mode": "0755",
    "owner": "apache",
    "path": "/tmp/clsn_dir",
    "size": 4096,
    "state": "directory",
    "uid": 0
}
```

### 2)创建文件,并设定属主、属组、权限
```
# ansible clsn -m file -a "dest=/tmp/clsn_file state=touch owner=apache group=apache mode=644"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "dest": "/tmp/clsn_file",
    "gid": 0,
    "group": "apache",
    "mode": "0644",
    "owner": "apache",
    "size": 0,
    "state": "file",
    "uid": 0
} 
```

### 3)创建软连接
```
# ansible clsn -m file -a "src=/tmp/clsn_file dest=/tmp/clsn_file_link state=link"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "dest": "/tmp/clsn_file_link",
    "gid": 0,
    "group": "root",
    "mode": "0777",
    "owner": "root",
    "size": 16,
    "src": "/tmp/clsn_file",
    "state": "link",
    "uid": 0
}
```

### 4)删除目录和文件信息
```
# ansible clsn -m file -a "dest=/tmp/clsn_dir state=absent"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "path": "/tmp/clsn_dir",
    "state": "absent"

# ansible clsn -m file -a "dest=/tmp/clsn_file state=absent"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "path": "/tmp/clsn_file",
    "state": "absent"
```

### 5)创建多级目录，同时递归的将目录中的文件的属主属组都设置为apache
```
ansible clsn -m file -a "path=/var/www/html/ owner=apache group=apache mode=755"
ansible clsn -m file -a "path=/var/www/html/ owner=apache group=apache recurse=yes"
```

- 注意：重命名和创建多级目录不能同时实现

## 5、fetch 模块  拉取文件

### 1)fetch常用参数说明

|参数| 参数说明 |
|----|---------|
|dest| 将远程主机拉取过来的文件保存在本地的路径信息 |
|src| 指定从远程主机要拉取的文件信息，只能拉取文件 |
|flat| 默认设置为no，如果设置为yes，将不显示172.16.1.8/etc/信息 |

-从被控远端机器上拉取文件(和COPY模块整好相反)

### 2）从远程拉取出来文件
```
# ansible clsn -m fetch -a "dest=/tmp/backup src=/etc/hosts"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "checksum": "b3c1ab140a1265cd7f6de9175a962988d93c629b",
    "dest": "/tmp/backup/172.16.1.8/etc/hosts",
    "md5sum": "8c2b120b4742a806dcfdc8cfff6b6308",
    "remote_checksum": "b3c1ab140a1265cd7f6de9175a962988d93c629b",
    "remote_md5sum": null
}
```

### 3)flat 参数，拉去的时候不创建目录（同名文件会覆盖）
```
# ansible clsn -m fetch -a "dest=/tmp/backup/ src=/etc/hosts flat=yes"
192.168.101.69 | SUCCESS => {
    "changed": false,
    "checksum": "b3c1ab140a1265cd7f6de9175a962988d93c629b",
    "dest": "/tmp/backup/hosts",
    "file": "/etc/hosts",
    "md5sum": "8c2b120b4742a806dcfdc8cfff6b6308"
```

## 6、mount模块 配置挂载点模块

### 1）mount模块常用参数

| 参数 | 参数说明 |
|------|---------|
| fstyp| 指定挂载文件类型 -t nfs == fstype=nfs |
| opts| 设定挂载的参数选项信息 -o ro  == opts=ro |
| path| 挂载点路径          path=/mnt |
| src | 要被挂载的目录信息  src=172.16.1.31:/data |
| state | 挂载的状态 |

| state参数 | state状态说明 |
|--------|-----------|
| unmounted | 加载/etc/fstab文件 实现卸载 |
| absent | 在fstab文件中删除挂载配置 |
| present | 在fstab文件中添加挂载配置 |
| mounted | 1.将挂载信息添加到/etc/fstab文件中 2.加载配置文件挂载 |

### 2）挂载
```
# ansible 172.16.1.8 -m mount -a "fstype=nfs opts=rw path=/mnt/  src=172.16.1.31:/data/ state=mounted"
172.16.1.8 | SUCCESS => {
    "changed": true,
    "dump": "0",
    "fstab": "/etc/fstab",
    "fstype": "nfs",
    "name": "/mnt/",
    "opts": "rw",
 "passno": "0",
  "src": "172.16.1.31:/data/"
}
```

### 3)卸载
```
# ansible 172.16.1.8 -m mount -a "fstype=nfs opts=rw path=/mnt/  src=172.16.1.31:/data/ state=unmounted"
172.16.1.8 | SUCCESS => {
   "changed": true,
    "dump": "0",
    "fstab": "/etc/fstab",
    "fstype": "nfs",
    "name": "/mnt/",
    "opts": "rw",
    "passno": "0",
    "src": "172.16.1.31:/data/"
}
```

### 4)环境准备：将172.16.1.61作为nfs服务端，172.16.1.7、172.16.1.8作为nfs客户端挂载
```
# ansible localhost -m yum -a 'name=nfs-utils state=present'
# ansible localhost -m file -a 'path=/ops state=directory'
# ansible localhost -m copy -a 'content="/ops 172.16.1.0/24(rw,sync)" dest=/etc/exports'
# ansible localhost -m service -a "name=nfs state=restarted"

#1、挂载nfs存储至本地的/opt目录，并实现开机自动挂载
# ansible node02 -m mount -a "src=172.16.1.61:/ops path=/opt fstype=nfs opts=defaults state=mounted"  

#2、永久卸载nfs的挂载，会清理/etc/fstab
# ansible webservers -m mount -a "src=172.16.1.61:/ops path=/opt fstype=nfs opts=defaults state=absent"
```

## 7、cron模块 定时任务

### 1）cron模块常用参数

| 参数 | 参数说明 |
|------|---------|
| minute 分 | Minute when the job should run ( 0-59, *, */2, etc ) |
| hour 时 | Hour when the job should run ( 0-23, *, */2, etc ) |
| day 日 | Day of the month the job should run ( 1-31, *, */2, etc ) |
| month 月 | Month of the year the job should run ( 1-12, *, */2, etc ) |
| weekday 周 | Day of the week that the job should run ( 0-6 for Sunday-Saturday, *, etc ) |
| job | 工作 ;要做的事情 |
| name | 定义定时任务的描述信息 |
| disabled | 注释定时任务 |
| state | 1、absent删除定时任务 2、present创建定时任务，默认为present  |

### 2)添加定时任务
```
# ansible clsn -m cron -a "minute=0 hour=0 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null' name=clsn01"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "envs": [],
    "jobs": [
     "clsn01"
    ]
}
```

### 3）删除定时任务
```
# ansible clsn -m cron -a "minute=00 hour=00 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null' name=clsn01 state=absent"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "envs": [],
    "jobs": []
}
```

### 4）只用名字就可以删除
```
# ansible clsn -m cron -a "name=clsn01  state=absent"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "envs": [],
    "jobs": []
}
```

### 5）注释定时任务
- 注意： 注释定时任务的时候必须有job的参数
```
# ansible clsn -m cron -a "name=clsn01 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null'  disabled=yes"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "envs": [],
    "jobs": [
    "clsn01"
    ]
}
```

### 6）取消注释
```
# ansible clsn -m cron -a "name=clsn01 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null'  disabled=no"
192.168.101.69 | SUCCESS => {
    "changed": true,
    "envs": [],
   "jobs": [
       "clsn01"
    ]
}
```

## 8、yum 模块

### 1）yum 模块常用参数

| 参数 | 参数说明 |
|----—|-------|
| name=name | 指定安装的软件 |
| state | 1、安装present、installed 2、卸载absent 3、升级latest 4、排除exclude 5、指定仓库enablerepo |

### 2)安装当前最新的Apache软件，如果存在则更新
```
ansible web -m yum -a "name=httpd state=latest" -i hosts
```

### 3)安装当前最新的Apache软件，通过epel仓库安装
```
ansible web -m yum -a "name=httpd state=latest enablerepo=epel" -i hosts 
```

### 4)通过公网URL安装rpm软件
```
ansible web -m yum -a "name=https://mirrors.aliyun.com/zabbix/zabbix/4.2/rhel/7/x86_64/zabbix-agent-4.2.3-2.el7.x86_64.rpm state=latest" -i hosts 
```

### 5)更新所有的软件包，但排除和kernel相关的
```
ansible web -m yum -a "name=* state=latest exclude=kernel*,foo*" -i hosts
```

### 6）删除Apache软件
```
ansible web -m yum -a "name=httpd state=absent" -i hosts
```

## 9、service模块 服务管理

### 1)service模块常用参数说明

| 参数 | 参数说明 |
|------|--------||
| name=service name | 服务的名称 |
| state=参数 | 停止服务 服务状态信息为过去时stared/stoped/restarted/reloaded |
| enabled=yes | 设置开机自启动 |

### 2)启动Httpd服务
```
ansible web -m service -a "name=httpd state=started"
```

### 3)重载Httpd服务
```
ansible web -m service -a "name=httpd state=reloaded"
```

### 4)重启Httpd服务
```
ansible web -m service -a "name=httpd state=restarted"
```

### 5)停止Httpd服务
```
ansible web -m service -a "name=httpd state=stopped"
```

### 6)启动Httpd服务，并加入开机自启
```
ansible web -m service -a "name=httpd state=started enabled=yes"  
```

## 10、hostname 修改主机名模块
```
# ansible 172.16.1.8 -m hostname -a "name=web01"
172.16.1.8 | SUCCESS => {
    "ansible_facts": {
        "ansible_domain": "etiantian.org",
        "ansible_fqdn": "www.etiantian.org",
       "ansible_hostname": "web01",
        "ansible_nodename": "web01"
    },
    "changed": false,
    "name": "web01"
}
```

## 11、selinux 管理模块
```
# ansible 172.16.1.8 -m selinux -a "state=disabled"
172.16.1.8 | SUCCESS => {
    "changed": false,
    "configfile": "/etc/selinux/config",
    "msg": "",
    "policy": "targeted",
    "state": "disabled"
}
```

## 12、get_url 模块 == 【wget】
```
# ansible 172.16.1.8 -m get_url -a "url=http://lan.znix.top/RDPWrap-v1.6.1.zip dest=/tmp/"
172.16.1.8 | SUCCESS => {
    "changed": true,
    "checksum_dest": null,
    "checksum_src": "ad402705624d06a6ff4b5a6a98c55fc2453b3a70",
    "dest": "/tmp/RDPWrap-v1.6.1.zip",
    "gid": 0,
    "group": "root",
    "md5sum": "b04dde546293ade71287071d187ed92d",
    "mode": "0644",
    "msg": "OK (1567232 bytes)",
    "owner": "root",
    "size": 1567232,
    "src": "/tmp/tmp4X4Von",
    "state": "file",
    "status_code": 200,
    "uid": 0,
    "url": "http://lan.znix.top/RDPWrap-v1.6.1.zip"
}
```
- url= 下载文件的地址 dest 下载到哪里
- timeout 超时时间
- url_password   密码
- url_username  用户名

## 13、firewalld
```
# ansible node02 -m service -a "name=firewalld state=started"

#1、永久放行https的流量,只有重启才会生效
# ansible node02 -m firewalld -a "zone=public service=https permanent=yes state=enabled"

#2、永久放行8081端口的流量,只有重启才会生效
# ansible node02 -m firewalld -a "zone=public port=8080/tcp permanent=yes state=enabled"
	
#3、放行8080-8090的所有tcp端口流量,临时和永久都生效.
# ansible node02 -m firewalld -a "zone=public port=8080-8090/tcp permanent=yes immediate=yes state=enabled"
```

## 14、group
```
#1、创建news基本组，指定uid为9999
ansible node02 -m group -a "name=news gid=9999 state=present" -i hosts

#2、创建http系统组，指定uid为8888
ansible node02 -m group -a "name=http gid=8888 system=yes state=present" -i hosts 

#3、删除news基本组
ansible node02 -m group -a "name=news state=absent" -i hosts
```

## 15、user
```
#1、创建joh用户，uid是1040，主要的组是adm
ansible node02 -m user -a "name=joh uid=1040 group=adm state=present system=no" -i hosts

#2、创建joh用户，登录shell是/sbin/nologin，追加bin、sys两个组
ansible node02 -m user -a "name=joh shell=/sbin/nologin groups=bin,sys" -i hosts 

#3、创建jsm用户，为其添加123作为登录密码，并且创建家目录
#ansible localhost -m debug -a "msg={{ '123' | password_hash('sha512', 'salt') }}"
$6$salt$jkHSO0tOjmLW0S1NFlw5veSIDRAVsiQQMTrkOKy4xdCCLPNIsHhZkIRlzfzIvKyXeGdOfCBoW1wJZPLyQ9Qx/1

# ansible node02 -m user -a 'name=jsm password=$6$salt$jkHSO0tOjmLW0S1NFlw5veSIDRAVsiQQMTrkOKy4xdCCLPNIsHhZkIRlzfzIvKyXeGdOfCBoW1wJZPLyQ9Qx/1 create_home=yes'

#4、移除joh用户
# ansible node02  -m user -a 'name=joh state=absent remove=yes' -i hosts 

#5、创建http用户，并为该用户创建2048字节的私钥，存放在~/http/.ssh/id_rsa
# ansible node02  -m user -a 'name=http generate_ssh_key=yes ssh_key_bits=2048 ssh_key_file=.ssh/id_rsa' -i hosts
```
