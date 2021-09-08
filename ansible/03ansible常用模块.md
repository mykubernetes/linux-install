# 一、ansible模块的使用

## 1、ansible常用参数
```
-a MODULE_ARGS, --args=MODULE_ARGS                  模块参数
-C, --check                                         运行检查，不执行任何操作
-e EXTRA_VARS, --extra-vars=EXTRA_VARS              设置附加变量 key=value
-f FORKS, --forks=FORKS                             指定并行进程数量，默认5
-i INVENTORY, --inventory=INVENTORY                 指定主机清单文件路径
--list-hosts                                        输出匹配的主机列表，不执行任何操作
-m MODULE_NAME, --module-name=MODULE_NAME           执行的模块名，默认command
--syntax-check                                      语法检查playbook文件，不执行任何操作
-t TREE, --tree=TREE                                将日志输出到此目录
-v, --verbose                                       详细信息，-vvv更多, -vvvv debug
--version                                           查看程序版本

连接选项：控制谁连接主机和如何连接
-k, --ask-pass                                      请求连接密码
--private-key=PRIVATE_KEY_FILE, --key-file=PRIVATE_KEY_FILE      私钥文件
-u REMOTE_USER, --user=REMOTE_USER                  连接用户，默认None
-T TIMEOUT, --timeout=TIMEOUT                       覆盖连接超时时间，默认10秒

提权选项：控制在目标主机以什么用户身份运行
-b, --become                                        以另一个用户身份操作
--become-method=BECOME_METHOD                       提权方法，默认sudo
--become-user=BECOME_USER                           提权后的用户身份，默认root
-K, --ask-become-pass                               提权密码
```

## 2）查看ansible有哪些模块
```
# ansible-doc -l
```

## 3)查看模块帮助
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

## 4)ping测试
```
# ansible all -m ping

192.168.101.69 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

## 5)ansible批量设置免密登录
```
# ssh-keygen -t rsa 
# ssh-copy-id 192.168.0.1          #本机ip
# ansible all -m authorized_key -a "user=root exclusive=true manage_dir=true key='$(</root/.ssh/authorized_keys)'"

#验证
ssh 192.168.0.2            #其他机器ip
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

### 1）shell命令常用参数说明
| 选项参数 | 选项说明 |
|---------|---------|
| free_form | 必须参数，指定需要执行的脚本，脚本位于ansible主机本地，并没有具体的一个参数名叫free_form |
| chdir | 此参数的作用就是指定一个远程主机中的目录，在执行对应的脚本之前，会先进入到chdir参数指定的目录中 |
| creates | 使用此参数指定一个远程主机中的文件，当指定的文件存在时，就不执行对应脚本 |
| removes | 使用此参数指定一个远程主机中的文件，当指定的文件不存在时，就不执行对应脚本 |
| executable | 默认情况下，shell模块会调用远程主机中的/bin/sh去执行对应的命令，通常情况下，远程主机中的默认shell都是bash，如果你想要使用其他类型的shell执行命令，则可以使用此参数指定某种类型的shell去执行对应的命令，指定shell文件时，需要使用绝对路径 |

### 2)shell 模块在远程执行脚本时，远程主机上一定要有相应的脚本
```
# ansible clsn -m shell -a "/bin/sh /server/scripts/ssh-key.sh"
192.168.101.69 | SUCCESS | rc=0 >>
fenfa 192.168.101.69 [  OK  ]
```

## 3、script 模块 执行脚本模块

- script模块可以帮助我们在远程主机上执行ansible主机上的脚本，也就是说，脚本一直存在于ansible主机本地，不需要手动拷贝到远程主机后再执行。

### 1）script命令常用参数说明
| 选项参数 | 选项说明 |
|---------|---------|
| free_form | 必须参数，指定需要执行的脚本，脚本位于ansible主机本地，并没有具体的一个参数名叫free_form |
| chdir | 此参数的作用就是指定一个远程主机中的目录，在执行对应的脚本之前，会先进入到chdir参数指定的目录中 |
| creates | 使用此参数指定一个远程主机中的文件，当指定的文件存在时，就不执行对应脚本 |
| removes | 使用此参数指定一个远程主机中的文件，当指定的文件不存在时，就不执行对应脚本 |


### 2)在本地执行脚本时，将脚本中的内容传输到远程节点上运行
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

先进入到主机中的/opt目录,然后执行脚本
```
ansible clsn -m script -a "chdir=/opt /testdir/atest.sh"
```

目标主机/opt/testfile文件存在，ansible主机中的/testdir/atest.sh脚本将不会在主机中执行，反之则执行。
```
ansible clsn -m script -a "creates=/opt/testfile /testdir/atest.sh"
```

目标主机中的/opt/testfile文件不存在，ansible主机中的/testdir/atest.sh脚本将不会在主机中执行，反之则执行。
```
ansible clsn -m script -a "removes=/opt/testfile /testdir/atest.sh"
```

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

| 参数 | 参数说明 |
|----|---------|
| dest | 将远程主机拉取过来的文件保存在本地的路径信息 |
| src | 指定从远程主机要拉取的文件信息，只能拉取文件 |
| flat | 默认设置为no，如果设置为yes，将不显示172.16.1.8/etc/信息 |

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
|-----|-------|
| name=name | 指定安装的软件 |
| state | 1、安装present、installed 2、卸载absent 3、升级latest 4、排除exclude 5、指定仓库enablerepo |
| disable_gpg_check | 用于禁用对rpm包的公钥gpg验证，默认值为no，表示不禁用验证，设置为yes表示禁用验证，即不验证包，直接安装，在对应的yum源没有开启gpg验证的情况下，需要将此参数的值设置为yes，否则会报错而无法进行安装 |
| enablerepo | 用于指定安装软件包时临时启用的yum源，假如你想要从A源中安装软件，但是你不确定A源是否启用了，你可以在安装软件包时将此参数的值设置为yes，即使A源的设置是未启用，也可以在安装软件包时临时启用A源 |
| disablerepo | 用于指定安装软件包时临时禁用的yum源，某些场景下需要此参数，比如，当多个yum源中同时存在要安装的软件包时，你可以使用此参数临时禁用某个源，这样设置后，在安装软件包时则不会从对应的源中选择安装包 |


### 2)安装当前最新的Apache软件，如果存在则更新
```
ansible web -m yum -a "name=httpd state=latest"
```

### 3)安装当前最新的Apache软件，通过epel仓库安装
```
ansible web -m yum -a "name=httpd state=latest enablerepo=epel"
```

### 4)通过公网URL安装rpm软件
```
ansible web -m yum -a "name=https://mirrors.aliyun.com/zabbix/zabbix/4.2/rhel/7/x86_64/zabbix-agent-4.2.3-2.el7.x86_64.rpm state=latest"
```

### 5)更新所有的软件包，但排除和kernel相关的
```
ansible web -m yum -a "name=* state=latest exclude=kernel*,foo*"
```

### 6）删除Apache软件
```
ansible web -m yum -a "name=httpd state=absent"
```

## 9、yum_repository模块

### 1)yum_repository模块常用参数说明
| 参数 | 参数说明 |
|-----|-------|
| name | 必须参数，用于指定要操作的唯一的仓库ID，也就是”.repo”配置文件中每个仓库对应的”中括号”内的仓库ID |
| baseurl | 设置yum仓库的baseurl |
| description | 设置仓库的注释信息，也就是”.repo”配置文件中每个仓库对应的”name字段”对应的内容。 |
| file | 设置仓库的配置文件名称，即设置”.repo”配置文件的文件名前缀，不使用此参数情况下，默认以name参数的仓库ID作为”.repo”配置文件的文件名前缀，同一个’.repo’配置文件中可以存在多个yum源 |
| enabled | 是否激活对应的yum源，此参数默认值为yes，表示启用对应的yum源，设置为no表示不启用对应的yum源。 |
| gpgcheck | 是否开启rpm包验证功能，默认值为no，表示不启用包验证，设置为yes表示开启包验证功能。 |
| gpgcakey | 当gpgcheck参数设置为yes时，需要使用此参数指定验证包所需的公钥 |
| state | 默认值为present，当值设置为absent时，表示删除对应的yum源 |

### 2)设置ID为aliEpel 的yum源，仓库配置文件路径为/etc/yum.repos.d/aliEpel.repo
```
ansible web -m yum_repository -a 'name=aliEpel description="alibaba EPEL" baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/'
```

### 3)设置ID为aliEpel 的yum源，仓库配置文件路径为/etc/yum.repos.d/alibaba.repo
```
ansible web -m yum_repository -a 'name=aliEpel description="alibaba EPEL" baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/ file=alibaba'
```

### 4)设置ID为local 的yum源，但是不启用它（local源使用系统光盘镜像作为本地yum源，以便测试举例，所以baseurl中的值以file:///开头）
```
ansible web -m yum_repository -a 'name=local baseurl=file:///media description="local cd yum" enabled=no'
```

### 5)设置ID为local的yum源，开启包验证功能，并指定验证包所需的公钥位置为/media/RPM-GPG-KEY-CentOS-7
```
ansible web -m yum_repository -a 'name=local baseurl=file:///media description="local cd yum" gpgcheck=yes gpgcakey=file:///media/RPM-GPG-KEY-CentOS-7'
```

### 6)删除/etc/yum.repos.d/alibaba.repo配置文件中的aliEpel源
```
ansible web -m yum_repository -a 'file=alibaba name=aliEpel state=absent'
```

## 10、service模块 服务管理

### 1)service模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
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

## 11、hostname 修改主机名模块
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

## 12、selinux 管理模块
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

## 13、get_url 模块 == 【wget】
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

## 14、firewalld
```
# ansible node02 -m service -a "name=firewalld state=started"

#1、永久放行https的流量,只有重启才会生效
# ansible node02 -m firewalld -a "zone=public service=https permanent=yes state=enabled"

#2、永久放行8081端口的流量,只有重启才会生效
# ansible node02 -m firewalld -a "zone=public port=8080/tcp permanent=yes state=enabled"
	
#3、放行8080-8090的所有tcp端口流量,临时和永久都生效.
# ansible node02 -m firewalld -a "zone=public port=8080-8090/tcp permanent=yes immediate=yes state=enabled"
```

## 15、group

### 1)group模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| name | 必须参数，用于指定要操作的组名称 |
| state | 用于指定组的状态，两个值可选，present，absent，默认为present，设置为absent表示删除组 |
| gid | 用于指定组的gid |


### 2)创建news基本组，指定uid为9999
```
ansible node02 -m group -a "name=news gid=9999 state=present" -i hosts
```

### 3)创建http系统组，指定uid为8888
```
ansible node02 -m group -a "name=http gid=8888 system=yes state=present" -i hosts 
```

### 4)删除news基本组
```
ansible node02 -m group -a "name=news state=absent" -i hosts
```

## 16、user

### 1)user模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| name | 必须参数，指定要操作的用户名称，可以使用别名user |
| group | 指定用户所在的基本组
| gourps | 指定用户所在的附加组，如果用户已经存在并且已经拥有多个附加组，那么想要继续添加新的附加组，需要结合append参数使用，否则再次使用groups参数设置附加组时，用户原来的附加组会被覆盖。
| append | 如果用户原本就存在多个附加组，那么当使用groups参数时，当前设置会覆盖原来的附加组设置，如果不想覆盖原来的附加组设置，需要结合append参数，将append设置为yes，表示追加附加组到现有的附加组设置，append默认值为no。
| shell | 指定用户的默认shell |
| uid | 指定用户的uid号 | 
| expires | 指定用户的过期时间 |
| comment | 指定用户的注释信息 |
| state | present创建用户，absent删除用户，默认值为present |
| remove | state设置为absent时，在删除用户时，不会删除用户的家目录等信息，这是因为remoove参数的默认值为no，如果设置为yes，在删除用户的同时，会删除用户的家目录，当state=absent并且remove=yes时，相当于执行”userdel -remove”命令 |
| password | 指定用户的密码，但是这个密码不能是明文的密码，而是一个对明文密码”加密后”的字符串，相当于/etc/shadow文件中的密码字段，是一个对明文密码进行哈希后的字符串 |
| update_password | 1、always当前的加密过的密码字符串不一致，则直接更新用户的密码 2、on_create当前的加密过的密码字符串不一致，则不会更新用户的密码字符串，保持之前的密码设定，如果新创建的用户为on_create，会将密码设置为password的值。默认值即为always |
| generate_ssh_key | 此参数默认值为no，如果设置为yes，表示为对应的用户生成ssh密钥对，默认在用户家目录的./ssh目录中生成名为id_rsa的私钥和名为id_rsa.pub的公钥，如果同名的密钥已经存在与对应的目录中，原同名密钥并不会被覆盖(不做任何操作)  |


### 2)创建joh用户，uid是1040，主要的组是adm
```
ansible node02 -m user -a "name=joh uid=1040 group=adm state=present system=no" -i hosts
```

### 3)创建joh用户，登录shell是/sbin/nologin，追加bin、sys两个组
```
ansible node02 -m user -a "name=joh shell=/sbin/nologin groups=bin,sys" -i hosts 
```

### 4)创建jsm用户，为其添加123作为登录密码，并且创建家目录
```
#ansible localhost -m debug -a "msg={{ '123' | password_hash('sha512', 'salt') }}"
$6$salt$jkHSO0tOjmLW0S1NFlw5veSIDRAVsiQQMTrkOKy4xdCCLPNIsHhZkIRlzfzIvKyXeGdOfCBoW1wJZPLyQ9Qx/1

# ansible node02 -m user -a 'name=jsm password=$6$salt$jkHSO0tOjmLW0S1NFlw5veSIDRAVsiQQMTrkOKy4xdCCLPNIsHhZkIRlzfzIvKyXeGdOfCBoW1wJZPLyQ9Qx/1 create_home=yes'
```

### 5)移除joh用户
```
# ansible node02  -m user -a 'name=joh state=absent remove=yes' -i hosts 
```

### 6)创建http用户，并为该用户创建2048字节的私钥，存放在~/http/.ssh/id_rsa
```
# ansible node02  -m user -a 'name=http generate_ssh_key=yes ssh_key_bits=2048 ssh_key_file=.ssh/id_rsa' -i hosts
```

## 17、replace模块

- replace模块可以根据我们指定的正则表达式替换文件中的字符串，文件中所有被正则匹配到的字符串都会被替换。

### 1)user模块常用参数说明
| 参数 | 参数说明 |
|------|--------|
| path | 必须参数，指定要操作的文件，2.3版本之前，只能使用dest, destfile, name指定要操作的文件，2.4版本中，仍然可以使用这些参数名，这些参数名作为path参数的别名使用 |
| regexp |  必须参数，指定一个python正则表达式，文件中与正则匹配的字符串将会被替换 |
| replace | 指定最终要替换成的字符串 |
| backup | 是否在修改文件之前对文件进行备份，最好设置为yes |


### 2)把文件中的所有ASM替换成asm
```
ansible test70 -m replace -a 'path=/testdir/test regexp="ASM" replace=asm'
```

### 3)把文件中的所有ASM替换成asm，但是在操作文件之前进行备份。
```
ansible test70 -m replace -a 'path=/testdir/test regexp="ASM" replace=asm backup=yes'
```
