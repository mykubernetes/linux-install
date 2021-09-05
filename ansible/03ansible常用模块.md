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
192.168.101.69| SUCCESS => {
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
