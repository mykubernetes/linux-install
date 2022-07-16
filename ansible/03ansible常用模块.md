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
-M                                                  指定要使用的模块路径
-S                                                  使用su命令
--syntax-check                                      语法检查playbook文件，不执行任何操作
-t TREE, --tree=TREE                                将日志输出到此目录
-v, --verbose                                       详细信息，-vvv更多, -vvvv debug
--version                                           查看程序版本

连接选项：控制谁连接主机和如何连接
-k, --ask-pass                                      手动输入SSH协议密码
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

| 参数 | 参数说明 |
|------|--------|
| user=root | 将密钥推送到远程主机的哪个用户下 |
| key='{{ lookup('file', '/root/.ssh/id_rsa.pub')}}' | 指定要推送的密钥文件所在的路径 |
| path='/root/.ssh/authorized_keys' [Default: (homedir)+/.ssh/authorized_keys] | 将密钥推送到远程主机的哪个目录下并重命名 |
| manage_dir=no | 指定模块是否应该管理 authorized key 文件所在的目录。如果设置为 yes，模块会创建目录，以及设置一个已存在目录的拥有者和权限。如果通过 path 选项，重新指定了一个 authorized key 文件所在目录，那么应该将该选项设置为 no |
| exclusive [default: no] | 是否移除 authorized_keys 文件中其它非指定 key |
| state (Choices: present, absent) [Default: present] | present 添加指定 key 到 authorized_keys 文件中；absent 从 authorized_keys 文件中移除指定 key |

示例一:
```
# ssh-keygen -t rsa 
# ssh-copy-id 192.168.0.1          #本机ip
# ansible all -m authorized_key -a "user=root exclusive=true manage_dir=true key='$(</root/.ssh/authorized_keys)'"

#验证
ssh 192.168.0.2            #其他机器ip
```

示例二:
```
ansible all -m authorized_key -a "user=root key='{{ lookup('file', '/root/.ssh/id_rsa.pub')}}' path='/root/.ssh/authorized_keys' manage_dir=no"
```

示例三:

如果密码不同，则需要将密码定义到/etc/ansible/hosts中
```
# cat /etc/ansible/hosts
[test]
10.10.10.1 ansible_connection=ssh ansible_ssh_user=root ansible_ssh_pass="123456"
10.10.10.2 ansible_connection=ssh ansible_ssh_user=root ansible_ssh_pass="abcdef"

# ansible test -m authorized_key -a "user=root key='{{ lookup('file', '/root/.ssh/id_rsa.pub')}}'"
```

```
---
- hosts: test
  gather_facts: false
  tasks:
  - name: deliver authorized_keys
    authorized_key:
        user: root                                                                      # 远端服务器上的用户
        key: "{{ lookup('file', '/etc/ansible/roles/authorized_keys') }}"               # 从本地authorized_keys文件读取公钥内容
        state: present               # present 添加指定key到authorized_keys文件中 # absent 从authorized_keys文件中移除指定key [Default: present]
        exclusive: no                                                                   # 是否移除authorized_keys文件中其它非指定key
```
- https://docs.ansible.com/ansible/2.3/authorized_key_module.html


# 常用模块

# 二、ansible常用模块

| 模块名称 | 模块作用 |
|----------|---------|
| [command](#command) | 直接执行用户指定的命令 |
| [shell](#shell) | 直接执行用户指定的命令（支持特殊字符） |
| [script](#script) | 收集受管节点主机上的系统及变量信息 |
| [user](#user)  | 创建、修改及删除用户 |
| [group](#group)  | 创建、修改及删除用户组 |
| [hostname](#hostname) | 修改主机名 |
| [selinux](#selinux) | 修改selinux |
| [firewalld](#firewalld) | 添加、修改及删除防火墙策略 |
| [systemd](#systemd)  |  |
| [service](#service)  | 启动、关闭及查看服务状态 |
| [yum](#yum) | 安装、更新及卸载软件包
| [yum_repository](#yum_repository) | 管理主机的软件仓库配置文件 |
| [get_url](#get_url) | 从网络中下载文件 |
| [copy](#copy) | 新建、修改及复制文件 |
| [file](#file) | 设置文件权限及创建快捷方式 |
| [fetch](#fetch) |  |
| [lineinfile](#lineinfile) | 通过正则表达式修改文件内容 |
| [replace](#replace) |  |
| [blockinfile](#blockinfile) |  |
| [mount](#mount) | 挂载硬盘设备文件 |
| [cron](#cron) | 添加、修改及删除计划任务 |
| [find](#find) |  |
| [template](#template) | 复制模板文件到受管节点主机 |
| [stat](#stat) |  |
| [synchronize](#synchronize) |  |
| [unarchive](#unarchive) |  |
| [mydql_user](#mysql_user) |  |
| [mysql_db](#mysql_db) |  |
| [pam_limits](#pam_limits) |  |


## command

1、command命令常用参数说明

| 参数 | 参数说明 |
|------|--------|
| chdir | 在执行命令之前，通过cd命令进入到指定目录中 # ansible clsn -m command -a "chdir=/tmp ls" |
| create | 定义一个文件是否存在，如果不存在运行相应命令；如果存在跳过此步骤 |
| executable | 改变shell使用command进行执行，并且执行时要使用绝对路径 |
| free_form | 命令模块采用自由形式命令运行；即可以输入任意linux命令 |
| removes | 定义一个文件是否存在，如果存在运行相应命令；如果不存在跳过此步骤 |
| warn(added in 1.8) | 如果ansible配置文件中定义了命令警告，如果参数设置了no/false，将不会警告此行命令 |

-  command不支持管道技术

2、不指定模块的时候默认使用的模块就是command
```
# ansible all -a "date"
```

3、使用ansible自带模块执行命令 如果要用 > < | & ' ' 使用shell模块
```
# ansible all -m command -a "date"
```

4、chdir参数的使用：
```
# ansible clsn -m command -a "chdir=/tmp pwd"
```

5、creates 文件是否存在，不存在就执行命令
```
# ansible clsn -m command -a "creates=/etc/hosts date"
```

6、removes 文件是否存在，不存在就不执行命令，
```
# ansible clsn -m command -a "removes=/etc/hosts date"
```

[回到模块列表](#常用模块)

## shell

1、shell命令常用参数说明
| 选项参数 | 选项说明 |
|---------|---------|
| free_form | 必须参数，指定需要执行的脚本，脚本位于ansible主机本地，并没有具体的一个参数名叫free_form |
| chdir | 此参数的作用就是指定一个远程主机中的目录，在执行对应的脚本之前，会先进入到chdir参数指定的目录中 |
| creates | 使用此参数指定一个远程主机中的文件，当指定的文件存在时，就不执行对应脚本 |
| removes | 使用此参数指定一个远程主机中的文件，当指定的文件不存在时，就不执行对应脚本 |
| executable | 默认情况下，shell模块会调用远程主机中的/bin/sh去执行对应的命令，通常情况下，远程主机中的默认shell都是bash，如果你想要使用其他类型的shell执行命令，则可以使用此参数指定某种类型的shell去执行对应的命令，指定shell文件时，需要使用绝对路径 |

2、shell 模块在远程执行脚本时，远程主机上一定要有相应的脚本
```
# ansible clsn -m shell -a "/bin/sh /server/scripts/ssh-key.sh"
192.168.101.69 | SUCCESS | rc=0 >>
fenfa 192.168.101.69 [  OK  ]
```

[回到模块列表](#常用模块)

## script

- script模块可以帮助我们在远程主机上执行ansible主机上的脚本，也就是说，脚本一直存在于ansible主机本地，不需要手动拷贝到远程主机后再执行。

1、script命令常用参数说明

| 选项参数 | 选项说明 |
|---------|---------|
| free_form | 必须参数，指定需要执行的脚本，脚本位于ansible主机本地，并没有具体的一个参数名叫free_form |
| chdir | 此参数的作用就是指定一个远程主机中的目录，在执行对应的脚本之前，会先进入到chdir参数指定的目录中 |
| creates | 使用此参数指定一个远程主机中的文件，当指定的文件存在时，就不执行对应脚本 |
| removes | 使用此参数指定一个远程主机中的文件，当指定的文件不存在时，就不执行对应脚本 |


2、在本地执行脚本时，将脚本中的内容传输到远程节点上运行
```
ansible all -m script -a "/server/scripts/free.sh"
```
- 使用scripts模块，不用将脚本传输到远程节点，脚本本身不用进行授权，即可利用script模块执行。直接执行脚本即可，不需要使用sh

3、先进入到主机中的/opt目录,然后执行脚本
```
ansible clsn -m script -a "chdir=/opt /testdir/atest.sh"
```

4、目标主机/opt/testfile文件存在，ansible主机中的/testdir/atest.sh脚本将不会在主机中执行，反之则执行。
```
ansible clsn -m script -a "creates=/opt/testfile /testdir/atest.sh"
```

5、目标主机中的/opt/testfile文件不存在，ansible主机中的/testdir/atest.sh脚本将不会在主机中执行，反之则执行。
```
ansible clsn -m script -a "removes=/opt/testfile /testdir/atest.sh"
```

[回到模块列表](#常用模块)

## user

1、user模块常用参数说明

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

2、创建joh用户，uid是1040，主要的组是adm
```
ansible node01 -m user -a "name=joh uid=1040 group=adm state=present system=no"
```

3、创建joh用户，登录shell是/sbin/nologin，追加bin、sys两个组
```
ansible node01 -m user -a "name=joh shell=/sbin/nologin groups=bin,sys"
```

4、创建jsm用户，为其添加123作为登录密码，并且创建家目录
```
#ansible localhost -m debug -a "msg={{ '123' | password_hash('sha512', 'salt') }}"
$6$salt$jkHSO0tOjmLW0S1NFlw5veSIDRAVsiQQMTrkOKy4xdCCLPNIsHhZkIRlzfzIvKyXeGdOfCBoW1wJZPLyQ9Qx/1

# ansible node01 -m user -a 'name=jsm password=$6$salt$jkHSO0tOjmLW0S1NFlw5veSIDRAVsiQQMTrkOKy4xdCCLPNIsHhZkIRlzfzIvKyXeGdOfCBoW1wJZPLyQ9Qx/1 create_home=yes'
```

5、移除joh用户
```
# ansible node01  -m user -a 'name=joh state=absent remove=yes'
```

6、创建http用户，并为该用户创建2048字节的私钥，存放在~/http/.ssh/id_rsa
```
# ansible node01  -m user -a 'name=http generate_ssh_key=yes ssh_key_bits=2048 ssh_key_file=.ssh/id_rsa'
```

[回到模块列表](#常用模块)

## group

1、group模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| name | 必须参数，用于指定要操作的组名称 |
| state | 用于指定组的状态，两个值可选，present，absent，默认为present，设置为absent表示删除组 |
| gid | 用于指定组的gid |


2、创建news基本组，指定uid为9999
```
ansible node02 -m group -a "name=news gid=9999 state=present"
```

3、创建http系统组，指定uid为8888
```
ansible node02 -m group -a "name=http gid=8888 system=yes state=present"
```

4、删除news基本组
```
ansible node02 -m group -a "name=news state=absent"
```

[回到模块列表](#常用模块)

## hostname
```
# ansible 172.16.1.8 -m hostname -a "name=web01"
```

[回到模块列表](#常用模块)

## selinux

| 参数 | 参数说明 |
|------|--------|
state | 永久开启，临时开启（默认，禁用）。enforcing、permissive、disabled |

```
# ansible 172.16.1.8 -m selinux -a "state=disabled"
```

[回到模块列表](#常用模块)

## firewalld

| 参数 | 参数说明 |
|------|--------|
| service | 指定开放或关闭的服务名称（http https） |
| port | 指定开放或关闭的端口（-） |
| permanent | 是否添加永久生效(permanent=no即为临时生效) |
| immediate | 临时生效 |
| state | 永久开启或者永久关闭enabled、disabled |
| zone | 指定配置某个区域 |
| rich_rule | 配置辅规则 |
| masquerade | 开启地址伪装 |
| source | 指定来源IP |

1、启动防火墙
```
ansible node02 -m service -a "name=firewalld state=started"
```

2、永久放行https的流量,只有重启才会生效
```
ansible node02 -m firewalld -a "zone=public service=https permanent=yes state=enabled"
```

3、永久放行8081端口的流量,只有重启才会生效
```
# ansible node02 -m firewalld -a "zone=public port=8080/tcp permanent=yes state=enabled"
```

4、放行8080-8090的所有tcp端口流量,临时和永久都生效.
```
# ansible node02 -m firewalld -a "zone=public port=8080-8090/tcp permanent=yes immediate=yes state=enabled"
```

[回到模块列表](#常用模块)

## systemd

1、systemd模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| state | 服务状态started、stopped、restarted、reloaded |
| name | 指定服务名称 |
| enabled | 设置开机自启yes、no |
| daemon_reload | 读取配置文件，每次修改了文件，最好都运行一次，确保应用了（systemd） |
| masked | 是否将服务设置为masked状态，被mask的服务是无法启动的(systemd),（yes or no）默认为no |


2、远程停止服务
```
# ansible 'web_group' -m systemd -a 'name=nginx state=stopped '
```

3、远程启动服务（并设置开机自启动）
```
# ansible 'web_group' -m systemd -a 'name=nginx state=started enabled=yes '
```

4、设置masked
```
# 先将服务停止
# ansible web -m systemd -a "name=httpd state=stopped"

#设置masked
# ansible web -m systemd -a "name=httpd masked=yes"

# 服务已无法启动
# ansible web -m systemd -a "name=httpd state=started"

# 撤销mask
# ansible web -m systemd -a "name=httpd masked=no"

# 可以启动成功
# ansible web -m systemd -a "name=httpd state=started"
```

[回到模块列表](#常用模块)

## service

1、service模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| name | 服务的名称 |
| state | 服务状态信息为过去时stared/stoped/restarted/reloaded |
| enabled | 设置开机自启动yes、no |
| sleep | 如果执行了restarted，在则stop和start之间沉睡几秒钟 |
| runlevel | 运行级别 |
| arguments | 给命令行提供一些选项 |
| pattern | 定义一个模式，如果通过status指令来查看服务的状态时，没有响应，就会通过ps指令在进程中根据该模式进行查找，如果匹配到，则认为该服务依然在运行 |

2、启动Httpd服务
```
ansible web -m service -a "name=httpd state=started"
```

3、重载Httpd服务
```
ansible web -m service -a "name=httpd state=reloaded"
```

4、重启Httpd服务
```
ansible web -m service -a "name=httpd state=restarted"
```

5、停止Httpd服务
```
ansible web -m service -a "name=httpd state=stopped"
```

6、启动Httpd服务，并加入开机自启
```
ansible web -m service -a "name=httpd state=started enabled=yes"  
```

[回到模块列表](#常用模块)

## yum

1、yum 模块常用参数

| 参数 | 参数说明 |
|-----|-------|
| name=name | 指定安装的软件 |
| state | 1、安装present、installed 2、卸载absent 3、升级latest 4、排除exclude 5、指定仓库enablerepo |
| disable_gpg_check | 用于禁用对rpm包的公钥gpg验证，默认值为no，表示不禁用验证，设置为yes表示禁用验证，即不验证包，直接安装，在对应的yum源没有开启gpg验证的情况下，需要将此参数的值设置为yes，否则会报错而无法进行安装 |
| enablerepo | 用于指定安装软件包时临时启用的yum源，假如你想要从A源中安装软件，但是你不确定A源是否启用了，你可以在安装软件包时将此参数的值设置为yes，即使A源的设置是未启用，也可以在安装软件包时临时启用A源 |
| disablerepo | 用于指定安装软件包时临时禁用的yum源，某些场景下需要此参数，比如，当多个yum源中同时存在要安装的软件包时，你可以使用此参数临时禁用某个源，这样设置后，在安装软件包时则不会从对应的源中选择安装包 |


2、安装当前最新的Apache软件，如果存在则更新
```
ansible web -m yum -a "name=httpd state=latest"
```

3、安装当前最新的Apache软件，通过epel仓库安装
```
ansible web -m yum -a "name=httpd state=latest enablerepo=epel"
```

4、通过公网URL安装rpm软件
```
ansible web -m yum -a "name=https://mirrors.aliyun.com/zabbix/zabbix/4.2/rhel/7/x86_64/zabbix-agent-4.2.3-2.el7.x86_64.rpm state=latest"
```

5、更新所有的软件包，但排除和kernel相关的
```
ansible web -m yum -a "name=* state=latest exclude=kernel*,foo*"
```

6、删除Apache软件
```
ansible web -m yum -a "name=httpd state=absent"
```

[回到模块列表](#常用模块)

## yum_repository

1、yum_repository模块常用参数说明
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

2、设置ID为aliEpel 的yum源，仓库配置文件路径为/etc/yum.repos.d/aliEpel.repo
```
ansible web -m yum_repository -a 'name=aliEpel description="alibaba EPEL" baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/'
```

3、设置ID为aliEpel 的yum源，仓库配置文件路径为/etc/yum.repos.d/alibaba.repo
```
ansible web -m yum_repository -a 'name=aliEpel description="alibaba EPEL" baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/ file=alibaba'
```

4、设置ID为local 的yum源，但是不启用它（local源使用系统光盘镜像作为本地yum源，以便测试举例，所以baseurl中的值以file:///开头）
```
ansible web -m yum_repository -a 'name=local baseurl=file:///media description="local cd yum" enabled=no'
```

5、设置ID为local的yum源，开启包验证功能，并指定验证包所需的公钥位置为/media/RPM-GPG-KEY-CentOS-7
```
ansible web -m yum_repository -a 'name=local baseurl=file:///media description="local cd yum" gpgcheck=yes gpgcakey=file:///media/RPM-GPG-KEY-CentOS-7'
```

6、删除/etc/yum.repos.d/alibaba.repo配置文件中的aliEpel源
```
ansible web -m yum_repository -a 'file=alibaba name=aliEpel state=absent'
```

[回到模块列表](#常用模块)

## get_url

| 选项参数 | 选项说明 |
|---------|---------|
| url | 自定下载文件的URL |
| dest | 指定下载的目录 |
| mode | 指定下载后的权限如'0440' |
| owner | 属主 |
| group | 属组 |
| force_basic_auth | 文件名相同直接覆盖（默认）yes、no |
| checksum | #默认关闭,#md5校验,sha校验 （md5、sha256） |

1、远程连接并下载（串行，速度慢）
```
# ansible 'web_group' -m get_url -a 'url=http://test.driverzeng.com/Nginx_Code/wordpress-4.9.4-zh_CN.tar.gz dest=/root mode=000'
```

2、校验MD5并下载（小心等于号，阿里云不使用md5sum校验，）
```
# ansible 'web_group' -m get_url -a 'url=http://test.driverzeng.com/Nginx_Code/wordpress-4.9.4-zh_CN.tar.gz dest=/root mode=000 checksum= md5:b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c'
```

[回到模块列表](#常用模块)

## copy

1、copy模块 把本地文件发送到远端

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

2、使用copy 模块，将/etc/hosts 文件 传输到各个服务器送，权限修改为0600 属主属组为clsn
```
# ansible clsn -m copy -a "src=/etc/hosts dest=/tmp/ mode=0600 owner=clsn group=clsn"
```

3、将本地的httpd.conf文件推送到远端，检查远端是否存在上一次的备份文件
```
ansible clsn -m copy -a "src=./httpd.conf dest=/etc/httpd/conf/httpd.conf owner=root group=root mode=644 backup=yes"
```

4、移动远程主机上的文件 remote_src=true 参数
```
# ansible clsn -m copy -a " src=/server/scripts/ssh-key.sh  dest=/tmp/ remote_src=true"
```

5、定义文件中的内容 content=clsnedu.com 默认没有换行
```
# ansible clsn -m copy -a "content=clsnedu.com dest=/tmp/clsn666.txt"
```

6、拷贝目录
```
ansible node02 -m copy -a "src=/etc/pam.d/ dest=/tmp/"
```

[回到模块列表](#常用模块)

## file

1、file模块常用参数

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

2、创建目录,并设定属主、属组、权限
```
# ansible clsn -m file -a "dest=/tmp/clsn_dir state=directory owner=apache group=apache mode=755"
```

3、创建文件,并设定属主、属组、权限
```
# ansible clsn -m file -a "dest=/tmp/clsn_file state=touch owner=apache group=apache mode=644"
```

4、创建软连接
```
# ansible clsn -m file -a "src=/tmp/clsn_file dest=/tmp/clsn_file_link state=link"
```

5、删除目录和文件信息
```
# ansible clsn -m file -a "dest=/tmp/clsn_dir state=absent"
# ansible clsn -m file -a "dest=/tmp/clsn_file state=absent"
```

6、创建多级目录，同时递归的将目录中的文件的属主属组都设置为apache
```
ansible clsn -m file -a "path=/var/www/html/ owner=apache group=apache mode=755"
ansible clsn -m file -a "path=/var/www/html/ owner=apache group=apache recurse=yes"
```
- 注意：重命名和创建多级目录不能同时实现

[回到模块列表](#常用模块)

## fetch

1、fetch常用参数说明

| 参数 | 参数说明 |
|----|---------|
| dest | 将远程主机拉取过来的文件保存在本地的路径信息 |
| src | 指定从远程主机要拉取的文件信息，只能拉取文件 |
| flat | 默认设置为no，如果设置为yes，将不显示172.16.1.8/etc/信息 |

-从被控远端机器上拉取文件(和COPY模块整好相反)

2、从远程拉取出来文件
```
# ansible clsn -m fetch -a "dest=/tmp/backup src=/etc/hosts"
```

3、flat 参数，拉去的时候不创建目录（同名文件会覆盖）
```
# ansible clsn -m fetch -a "dest=/tmp/backup/ src=/etc/hosts flat=yes"
```

[回到模块列表](#常用模块)

## lineinfile

- 确保`某一行文本`存在于指定的文件中，或者确保从文件中删除指定的`文本`（即确保指定的文本不存在于文件中），还可以根据正则表达式，替换`某一行文本`

1、lineinfile模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| path | 必须参数，指定要操作的文件。 |
| line | 使用此参数指定文本内容。 |
| regexp | 使用正则表达式匹配对应的行，当替换文本时，如果有多行文本都能被匹配，则只有最后面被匹配到的那行文本才会被替换，当删除文本时，如果有多行文本都能被匹配，这么这些行都会被删除。 |
| state | 当想要删除对应的文本时，需要将state参数的值设置为absent，absent为缺席之意，表示删除，state的默认值为present |
| backrefs | 默认情况下，当根据正则替换文本时，即使regexp参数中的正则存在分组，在line参数中也不能对正则中的分组进行引用，除非将backrefs参数的值设置为yes，backrefs=yes表示开启后向引用，这样，line参数中就能对regexp参数中的分组进行后向引用了，这样说不太容易明白，参考下面的示例命令比较直观一点，backrefs=yes除了能够开启后向引用功能，还有另一个作用，默认情况下，当使用正则表达式替换对应行时，如果正则没有匹配到任何的行，那么line对应的内容会被插入到文本的末尾，不过，如果使用了backrefs=yes，情况就不一样了，当使用正则表达式替换对应行时，同时设置了backrefs=yes，那么当正则没有匹配到任何的行时，则不会对文件进行任何操作，相当于保持原文件不变，如果没有理解，就按照下面的示例命令，动手操作一下吧，那样更加直观。 |
| insertafter | 借助insertafter参数可以将文本插入到“指定的行”之后，insertafter参数的值可以设置为EOF或者正则表达式，EOF为End Of File之意，表示插入到文档的末尾，默认情况下insertafter的值为EOF，如果将insertafter的值设置为正则表达式，表示将文本插入到匹配到正则的行之后，如果正则没有匹配到任何行，则插入到文件末尾，当使用backrefs参数时，此参数会被忽略。 |
| insertbefore | 借助insertbefore参数可以将文本插入到“指定的行”之前，insertbefore参数的值可以设置为BOF或者正则表达式，BOF为Begin Of File之意，表示插入到文档的开头，如果将insertbefore的值设置为正则表达式，表示将文本插入到匹配到正则的行之前，如果正则没有匹配到任何行，则插入到文件末尾，当使用backrefs参数时，此参数会被忽略。 |
| backup | 是否在修改文件之前对文件进行备份。 |
| create | 当要操作的文件并不存在时，是否创建对应的文件 |


2、指定的文本中的内容如果存在则不做任何操作，如果不存在，默认在文件的末尾插入这行文本。
```
ansible node01 -m lineinfile -a 'path=/testdir/test line="test text"'
```

3、正则表达式替换`某一行`，如果不止一行能够匹配正则，那么只有最后一个匹配正则的行才会被替换，被匹配行会被替换成line参数指定的内容，但是如果指定的表达式没有匹配到任何一行，那么line中的内容会被添加到文件的最后一行。
```
ansible node01 -m lineinfile -a 'path=/testdir/test regexp="^line" line="test text"'
```

4、根据正则表达式替换`某一行`，如果不止一行能够匹配正则，那么只有最后一个匹配正则的行才会被替换，被匹配行会被替换成line参数指定的内容，但是如果指定的表达式没有匹配到任何一行，那么则不对文件进行任何操作。
```
ansible node01 -m lineinfile -a 'path=/testdir/test regexp="^line" line="test text" backrefs=yes'
```

5、根据line参数的内容删除行，如果文件中有多行都与line参数的内容相同，那么这些相同的行都会被删除。
```
ansible node01 -m lineinfile -a 'path=/testdir/test line="lineinfile -" state=absent'
```

6、根据正则表达式删除对应行，如果有多行都满足正则表达式，那么所有匹配的行都会被删除。
```
ansible node01 -m lineinfile -a 'path=/testdir/test regexp="^lineinfile" state=absent'
```

7、如果将backrefs设置为yes，表示开启支持后向引用，使用如下命令，可以将test示例文件中的”Hello ansible,Hiiii”替换成”Hiiii”，如果不设置backrefs=yes，则不支持后向引用，那么”Hello ansible,Hiiii”将被替换成”\2″
```
ansible node01 -m lineinfile -a 'path=/testdir/test regexp="(H.{4}).*(H.{4})" line="\2" backrefs=yes'
```

[回到模块列表](#常用模块)

## replace

- replace模块可以根据我们指定的正则表达式替换文件中的字符串，文件中所有被正则匹配到的字符串都会被替换。

1、replace模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| path | 必须参数，指定要操作的文件，2.3版本之前，只能使用dest, destfile, name指定要操作的文件，2.4版本中，仍然可以使用这些参数名，这些参数名作为path参数的别名使用 |
| regexp |  必须参数，指定一个python正则表达式，文件中与正则匹配的字符串将会被替换 |
| replace | 指定最终要替换成的字符串 |
| backup | 是否在修改文件之前对文件进行备份，最好设置为yes |

2、把文件中的所有ASM替换成asm
```
ansible node02 -m replace -a 'path=/testdir/test regexp="ASM" replace=asm'
```

3、把文件中的所有ASM替换成asm，但是在操作文件之前进行备份。
```
ansible node02 -m replace -a 'path=/testdir/test regexp="ASM" replace=asm backup=yes'
```

4、关闭selinux
```
ansible node01 -m replace -a 'path=/etc/sysconfig/selinux regexp="^SELINUX=.*" replace="SELINUX=disabled"'
```

[回到模块列表](#常用模块)

## blockinfile

- blockinfile 在指定的文件中插入`一段文本`，这段文本是被标记过的，以便在以后的操作中可以通过`标记`找到这段文本，然后修改或者删除它

1、blockinfile模块常用参数说明

| 参数 | 参数说明 |
|------|--------|
| path | 必须参数，指定要操作的文件。 |
| block | 此参数用于指定我们想要操作的那”一段文本”，此参数有一个别名叫”content”，使用content或block的作用是相同的。 |
| marker | 假如我们想要在指定文件中插入一段文本，ansible会自动为这段文本添加两个标记，一个开始标记，一个结束标记，默认情况下，开始标记为# BEGIN ANSIBLE MANAGED BLOCK，结束标记为# END ANSIBLE MANAGED BLOCK，我们可以使用marker参数自定义”标记”，比如，marker=#{mark}test ，这样设置以后，开始标记变成了# BEGIN test，结束标记变成了# END test，没错，{mark}会自动被替换成开始标记和结束标记中的BEGIN和END，我们也可以插入很多段文本，为不同的段落添加不同的标记，下次通过对应的标记即可找到对应的段落。 |
| state | state参数有两个可选值，present与absent，默认情况下，我们会将指定的一段文本”插入”到文件中，如果对应的文件中已经存在对应标记的文本，默认会更新对应段落，在执行插入操作或更新操作时，state的值为present，默认值就是present，如果对应的文件中已经存在对应标记的文本并且将state的值设置为absent，则表示从文件中删除对应标记的段落。 |
| insertafter | 在插入一段文本时，默认会在文件的末尾插入文本，如果想要将文本插入在某一行的后面，可以使用此参数指定对应的行，也可以使用正则表达式(python正则)，表示将文本插入在符合正则表达式的行的后面，如果有多行文本都能够匹配对应的正则表达式，则以最后一个满足正则的行为准，此参数的值还可以设置为EOF，表示将文本插入到文档末尾。 |
| insertbefore | 在插入一段文本时，默认会在文件的末尾插入文本，如果想要将文本插入在某一行的前面，可以使用此参数指定对应的行，也可以使用正则表达式(python正则)，表示将文本插入在符合正则表达式的行的前面，如果有多行文本都能够匹配对应的正则表达式，则以最后一个满足正则的行为准，此参数的值还可以设置为BOF，表示将文本插入到文档开头。 |
| backup | 是否在修改文件之前对文件进行备份 |
| create | 当要操作的文件并不存在时，是否创建对应的文件 |


2、在主机中的/etc/rc.local文件尾部插入如下两行`systemctl start mariadb`,`systemctl start httpd`
```
ansible node01 -m blockinfile -a 'path=/etc/rc.local block="systemctl start mariadb\nsystemctl start httpd"'
```

插入后效果
```
# BEGIN ANSIBLE MANAGED BLOCK
systemctl start mariadb
systemctl start httpd
# END ANSIBLE MANAGED BLOCK
```

3、自定义的标记但是标记也会`成对出现`，需要有开始标记和结束标记
```
ansible node01 -m blockinfile -a 'path=/etc/rc.local block="systemctl start mariadb\nsystemctl start httpd" marker="#{mark} serivce to start"'
```

插入后效果
```
#BEGIN serivce to start
systemctl start mariadb
systemctl start httpd
#END serivce to start
```

4、在执行此命令时`标记`对应的文本块已经存在时，block参数对应的内容又与之前文本块的内容不同，对应文本块中的内容会被更新，而不会再一次插入新的文本块，这种用法相当于更新原来文本块中的内容。
```
ansible node01 -m blockinfile -a 'path=/etc/rc.local block="systemctl start mariadb" marker="#{mark} serivce to start"'
```

插入后效果
```
#BEGIN serivce to start
systemctl start mariadb
#END serivce to start
```

5、在执行此命令时`标记`对应的文本块已经存在时，block参数对应的内容为空，blockinfile模块会删除对应标记的文本块，可以使用如下命令删除对应的文本块。
```
ansible host node001 -m blockinfile -a 'path=/etc/rc.local block="" marker="#{mark} serivce to start"'
```

6、将文本块插入到文档的开头，可以使用insertbefore参数，将其值设置为BOF，BOF表示Begin Of File。
```
ansible node01 -m blockinfile -a 'path=/etc/rc.local block="####blockinfile test####"  marker="#{mark} test" insertbefore=BOF'
```

7、将文本块插入到文档的结尾，与默认操作相同，将insertafter参数设置为EOF表示End Of File。
```
ansible node01 -m blockinfile -a 'path=/etc/rc.local block="####blockinfile test####"  marker="#{mark} test" insertafter=EOF'
```

8、使用正则表达式匹配行，将文本块插入到`以#!/bin/bash开头的行`之后。
```
ansible node01 -m blockinfile -a 'path=/etc/rc.local block="####blockinfile test####"  marker="#{mark} test reg" insertafter="^#!/bin/bash"'
```

9、使用backup参数，可以在操作修改文件之前，对文件进行备份，备份的文件会在原文件名的基础上添加时间戳
```
ansible node01 -m blockinfile -a 'path=/etc/rc.local marker="#{mark} test" state=absent backup=yes'
```

10、使用create参数，如果指定的文件不存在，则创建它
```
ansible node01 -m blockinfile -a 'path=/etc/test block="test" marker="#{mark} test" create=yes'
```

[回到模块列表](#常用模块)

## mount

1、mount模块常用参数

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

2、挂载
```
# ansible 172.16.1.8 -m mount -a "fstype=nfs opts=rw path=/mnt/  src=172.16.1.31:/data/ state=mounted"
```

3、卸载
```
# ansible 172.16.1.8 -m mount -a "fstype=nfs opts=rw path=/mnt/  src=172.16.1.31:/data/ state=unmounted"
```

4、环境准备：将172.16.1.61作为nfs服务端，172.16.1.7、172.16.1.8作为nfs客户端挂载
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

[回到模块列表](#常用模块)

## cron

1、cron模块常用参数

| 参数 | 参数说明 |
|------|---------|
| minute 分 | Minute when the job should run `( 0-59, *, */2, etc )` |
| hour 时 | Hour when the job should run `( 0-23, *, */2, etc )` |
| day 日 | Day of the month the job should run `( 1-31, *, */2, etc )` |
| month 月 | Month of the year the job should run `( 1-12, *, */2, etc )` |
| weekday 周 | Day of the week that the job should run `( 0-6 for Sunday-Saturday, *, etc )` |
| user | 用于设置当前计划任务属于哪个用户,当不使用此参数时,默认为管理员用户 |
| job | 指定计划的任务中需要实际执行的命令或者脚本 |
| name | 用于设置计划任务的名称,计划任务的名称会在注释中显示 |
| disabled | 当计划任务有名称时,我们可以根据名称使对应的任务失效,注释定时任务 |
| backup | 此参数的值设置为yes,那么当修改或者删除对应的计划任务时,会对计划任务备份 |
| state | 1、absent删除定时任务 2、present创建定时任务，默认为present  |

2、添加定时任务
```
# ansible clsn -m cron -a "minute=0 hour=0 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null' name=clsn01"
```

3、删除定时任务
```
# ansible clsn -m cron -a "minute=00 hour=00 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null' name=clsn01 state=absent"
```

4、只用名字就可以删除
```
# ansible clsn -m cron -a "name=clsn01  state=absent"
```

5、注释定时任务
- 注意： 注释定时任务的时候必须有job的参数
```
# ansible clsn -m cron -a "name=clsn01 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null'  disabled=yes"
```

6、取消注释
```
# ansible clsn -m cron -a "name=clsn01 job='/bin/sh  /server/scripts/hostname.sh &>/dev/null'  disabled=no"
```

[回到模块列表](#常用模块)

## find

- find模块可以帮助我们在远程主机中查找符合条件的文件，就像find命令一样。

1、template模块常用参数说明

| 参数 | 描述 |
|------|------|
| paths | 必须参数，指定在哪个目录中查找文件，可以指定多个路径，路径间用逗号隔开，此参数有别名，使用别名path或者别名name可以代替paths。 |
| recurse | 默认情况下，只会在指定的目录中查找文件，如果目录中还包含目录，不会递归查找，如果想递归的查找文件，当需要将recurse参数设置为yes |
| hidden | 默认情况下，隐藏文件会被忽略，当hidden参数的值设置为yes时，才会查找隐藏文件。 |
| file_type | 默认情况下，ansible只会根据条件查找”文件”，并不会查找”目录”或”软链接”等文件类型，想要指定查找的文件类型，通过file_type指定文件类型，可指定文件类型有any、directory、file、link 四种。 |
| patterns | 使用此参数指定需要查找的文件名称，支持使用shell（比如通配符）或者正则表达式去匹配文件名称，默认情况下，使用shell匹配对应的文件名，如果想要使用python的正则去匹配文件名，需要将use_regex参数的值设置为yes。 |
| use_regex | 默认情况下，find模块不会使用正则表达式去解析patterns参数中对应的内容，当use_regex设置为yes时，表示使用python正则解析patterns参数中的表达式，否则，使用glob通配符解析patterns参数中的表达式。 |
| contains | 用此参数可以根据文章内容查找文件，此参数的值为一个正则表达式，find模块会根据对应的正则表达式匹配文件内容。 |
| age | 使用此参数可以根据时间范围查找文件，默认以文件的mtime为准与指定的时间进行对比，比如，如果想要查找mtime在3天之前的文件，那么可以设置age=3d,如果想要查找mtime在3天以内的文件，可以设置age=-3d，这里所说的3天是按照当前时间往前推3天，可以使用的单位有秒(s)、分(m)、时(h)、天(d)、星期(w)。 |
| age_stamp | 文件的时间属性中有三个时间种类，atime、ctime、mtime，当我们根据时间范围查找文件时，可以指定以哪个时间种类为准，当根据时间查找文件时，默认以mtime为准。 |
| size | 使用此参数可以根据文件大小查找文件，比如，如果想要查找大于3M的文件，那么可以设置size=3m,如果想要查找小于50k的文件，可以设置size=-50k，可以使用的单位有t、g、m、k、b。 |
| get_checksum | 当有符合查找条件的文件被找到时，会同时返回对应文件的sha1校验码，如果要查找的文件比较大，那么生成校验码的时间会比较长。 |

2、在主机的/testdir目录中查找文件内容中包含abc字符串的文件，隐藏文件会被忽略，不会进行递归查找。
```
ansible test70 -m find -a 'paths=/testdir contains=".*abc.*" '
```
 

3、在主机的/testdir目录以及其子目录中查找文件内容中包含abc字符串的文件，隐藏文件会被忽略。
```
ansible test70 -m find -a 'paths=/testdir contains=".*abc.*" recurse=yes '
```
 

4、在主机的/testdir目录中查找以.sh结尾的文件，包括隐藏文件，但是不包括目录或其他文件类型，不会进行递归查找。
```
ansible test70 -m find -a 'paths=/testdir patterns="*.sh" hidden=yes'
```
 

5、在主机的/testdir目录中查找以.sh结尾的文件，包括隐藏文件，包括所有文件类型，比如文件、目录、或者软链接，但是不会进行递归查找。
```
ansible test70 -m find -a 'paths=/testdir patterns="*.sh" file_type=any hidden=yes'
```
 

6、在主机的/testdir目录中查找以.sh结尾的文件，包括隐藏文件，包括所有文件类型，比如文件、目录、或者软链接，但是不会进行递归查找。
```
ansible test70 -m find -a 'paths=/testdir patterns="*.sh" file_type=any hidden=yes'
```
 

7、在主机的/testdir目录中查找以.sh结尾的文件，只不过patterns对应的表达式为正则表达式，查找范围包括隐藏文件，包括所有文件类型，但是不会进行递归查找，不会对/testdir目录的子目录进行查找。
```
ansible test70 -m find -a 'paths=/testdir patterns=".*\.sh" use_regex=yes file_type=any hidden=yes'
```
 

8、在主机的/testdir目录中以及其子目录中查找mtime在4天以内的文件，不包含隐藏文件，不包含目录或软链接文件等文件类型。
```
ansible test70 -m find -a "path=/testdir age=-4d recurse=yes"
```
 

9、在主机的/testdir目录中以及其子目录中查找atime在2星期以内的文件，不包含隐藏文件，不包含目录或软链接文件等文件类型。
```
ansible test70 -m find -a "path=/testdir age=-2w age_stamp=atime recurse=yes"
```
 

10、在主机的/testdir目录中以及其子目录中查找大于2G的文件，不包含隐藏文件，不包含目录或软链接文件等文件类型。
```
ansible test70 -m find -a "paths=/testdir size=2g recurse=yes"
```
 

11、在主机的/testdir目录中以及其子目录中查找以.sh结尾的文件，并且返回符合条件文件的sha1校验码，包括隐藏文件
```
ansible test70 -m find -a "paths=/testdir patterns=*.sh get_checksum=yes  hidden=yes recurse=yes"
```

[回到模块列表](#常用模块)

## template

1、template模块常用参数说明

| 参数 | 描述 |
|------|------|
| src | 本地Jinjia2模版的template文件位置。 |
| dest | 远程节点上的绝对路径，用于放置template文件。 |
| owner | 指定最终生成的文件拷贝到远程主机后的属主。 |
| group | 指定最终生成的文件拷贝到远程主机后的属组。 |
| mode | 指定最终生成的文件拷贝到远程主机后的权限，如果你想将权限设置为"rw-r–r--"，则可以使用mode=0644表示，如果你想要在user对应的权限位上添加执行权限，则可以使用mode=u+x表示。 |
| force | 当远程主机的目标路径中已经存在同名文件，并且与最终生成的文件内容不同时，是否强制覆盖，可选值有yes和no，默认值为yes，表示覆盖，如果设置为no，则不会执行覆盖拷贝操作，远程主机中的文件保持不变。 | 
| backup | 当远程主机的目标路径中已经存在同名文件，并且与最终生成的文件内容不同时，是否对远程主机的文件进行备份，可选值有yes和no，当设置为yes时，会先备份远程主机中的文件，然后再将最终生成的文件拷贝到远程主机 |


```
# 1、编写template文件并修改配置对应到变量
# cat /opt/src/redis.conf |grep ^bind
bind {{ ansible_enp0s3.ipv4.address }}

# 2、编写playbook文件
# cat first.yaml
- hosts: node01
  remote_user: root
  tasks:
   - name: install redis
     yum: name=redis state=present
   - name: copy config file
     template: src=/opt/src/redis.conf dest=/etc/redis.conf owner=redis
     notify: restart redis
     tags: conf
   - name: start redis
     service: name=redis state=started enabled=true
  handlers:
   - name: restart redis
     service: name=redis state=restarted

# 3、运行后查看配置文件是否更换
# cat /etc/redis.conf |grep ^bind
bind 192.168.1.70
```

[回到模块列表](#常用模块)

## stat
- stat模块获取远程文件状态信息，包括atime、ctime、mtime、md5、uid、gid等，和linux的stat命令类似。

1、显示文件的所有信息
```
# ansible web -m stat -a "path=/etc/sysctl.conf"
```

2、显示MD5值
```
# ansible web -m stat -a "path=/etc/sysctl.conf get_md5=yes"
```

[回到模块列表](#常用模块)

## synchronize

功能：基于rsync命令工具同步目录和文件

由于synchronize模块会调用rsync命令，因此首先要记得提前安装好rsync软件包

| 参数 | 描述 |
|------|------|
| archive | 归档，相当于同时开启recursive(递归)、links、perms、times、owner、group、-D选项都为yes ，默认该项为开启（#保证源文件和目标文件属性一致） |
| checksum: | 是否检测sum值，默认关闭 |
| compress | 是否开启压缩（默认开启） |
| copy_links | 同步的时候是否复制链接，默认为no ，注意后面还有一个links参数 |
| links | 同步链接文件 |
| delete | 删除不存在的文件，delete=yes 使两边的内容一样（即以推送方为主），默认no |
| dest | 目录路径（绝对路径或者相对路径） |
| dest_port | 目标主机上的端口 ，默认是22，走的ssh协议 |
| dirs | 传送目录不进行递归，默认为no，即进行目录递归（#一般不用指定）rsync_opts：通过传递数组来指定其他rsync选项。	`#--exclude=*.txt`#排除 |
| set_remote_user | 主要用于ansible默认使用的用户与rsync使用的'用户不同的情况 |
| mode | push(默认)或pull 模块，push模的话，'一般用于从本机向远程主机上传文件，pull 模式用于从远程主机上取文件' |
| src | 要同步到目的地的源主机上的路径; 路径可以是绝对的或相对的。如果路径使用”/”来结尾，则只复制目录里的内容，如果没有使用”/”来结尾，则包含目录在内的整个内容全部复制  |

1、同步目录（前提是远程服务器上有rsync这个命令）
```
ansible 172.25.70.2 -m synchronize -a 'src=some/relative/path dest=/some/absolute/path rsync_path="sudo rsync"'
```

2、排除(#由于这个是rsync命令的参数，所以必须和rsync_opts一起使用)
```
ansible 172.25.70.2 -m synchronize -a 'src=/tmp/helloworld dest=/var/www/helloword rsync_opts=--exclude=.log'
```

[回到模块列表](#常用模块)

## unarchive
- 解压缩

| 参数 | 描述 |
|------|------|
| copy | 在解压文件之前,是否先将文件复制到远程主机,默认为yes |
| creates | 指定一个文件名,当该文件存在时,则解压指令不执行 |
| src | 如果copy为yes,则需要指定压缩文件的源路径 |
| dest | 远程主机上的一个路径,即文件解压的路径 |
| list_files | 列出压缩包里的文件,默认两个参数yes/no |
| mode | 解压后文件的权限设置 |
| group | 解压后的目录或文件的属组 |
| owner | 解压后文件或目录的属主 |

1、解压ansible管理机上的压缩文件到远程主机
```
ansible all -m unarchive -a "src=/tmp/install/zabbix-3.0.4.tar.gz dest=/tmp/ mode=0755 copy=yes"
```

2、解压远程主机上的文件到目录
```
ansible all -m unarchive -a "src=/tmp/install/zabbix-3.0.4.tar.gz dest=/tmp/ mode=0755 copy=no"
```

[回到模块列表](#常用模块)

## mysql_user

- 主控端对被控端mysql服务器 添加删除用户，授权远程用户登录，访问

| 参数 | 描述 |
|------|------|
| login_host=“localhost” | 指定本地root用户登录本机mysql |
| login_password=“123.com” | root用户的登录密码 |
| login_user=“root” | 为root用户或者mysql用户 |
| login_port=“3306” | 数据库端口号 |
| name="" | 指定grant授权用户,建立使用者的名字或是已存在的使用者 |
| password="" | grant授权用户密码,给新用户设置密码，或者修改密码 |
| priv="" | 库名.SQL语句权限,GRANT,资料库.资料表:权限1,权限2（要用"） |
| host="" | 授权远程登录的IP地址，一般为 网段.% 或者直接 % |
| state=“present” | 创建授权用户 |
| state=“absent” | 删除授权用户 |

1、ahdoc模式写法创建授权用户，验证模块正确时使用
```
# ansible mysql -m mysql_user -a "login_host=% login_password=123.com login_user=root login_port=3306 name=ty_user password=1 priv=".:ALL,GRANT" host='%' state=present"
```

2、playbook剧本写法创建授权用户，执行自动化部署时使用
```
- hosts: mysql_group
  remote_user: root
  tasks:
    - name: grant mysql user
      mysql_user:
      	login_host: "localhost"
      	login_user: "root"
     	login_password: "123.com"
     	login_port: "3306"
      	name: "ty"
      	password: "123.com"
      	host: "%"
      	priv: "*.*:ALL,GRANT"
      	state: "present"
```

[回到模块列表](#常用模块)

## mysql_db

- 用于建立、删除、导入和导出数据库

```
#建立数据库
  hosts: mysql_group
  tasks:
  - name: create a database
    mysql_db:
      login_host: "127.0.0.1"
      login_user: "root"
      login_password: "mysql@123"
      login_port: "3306"
      name: "mezz"
      encoding: "utf8"
      state: "present"
      
#删除数据库
  hosts: mysql_group
  tasks:
  - name: delete a database
    mysql_db:
      login_host: "127.0.0.1"
      login_user: "root"
      login_password: "mysql@123"
      login_port: "3306"
      name: "mezz"
      state: "absent"
      
#导出数据库
  hosts: mysql_group
  tasks:
  - name: dump a database
    mysql_db:
      login_host: "127.0.0.1"
      login_user: "root"
      login_password: "mysql@123"
      login_port: "3306"
      name: "mezz"
      target: "/tmp/mezz.gz"
      state: "dump"
      
#导入数据库
  hosts: mysql_group
  tasks:
  - name: import a database
    mysql_db:
      login_host: "127.0.0.1"
      login_user: "root"
      login_password: "mysql@123"
      login_port: "3306"
      name: "mezz"
      target: "/tmp/mezz.gz"
      state: "import"
```

[回到模块列表](#常用模块)

## pam_limits

- 修改文件描述符

```
#为用户joe添加或修改nofile软限制
- pam_limits:
    domain: joe
    limit_type: soft
    limit_item: nofile
    value: 64000

# 为用户smith添加或修改硬限制。保持或设置最大值。
- pam_limits:
    domain: smith
    limit_type: hard
    limit_item: fsize
    value: 1000000
    use_max: yes

#为用户james添加或修改memlock，包括软硬限制和注释。
- pam_limits:
    domain: james
    limit_type: '-'
    limit_item: memlock
    value: unlimited
    comment: unlimited memory lock for james
```

[回到模块列表](#常用模块)
