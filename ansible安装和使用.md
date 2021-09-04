ansible安装和使用
===========

最佳实践：https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html  
示例参考：https://github.com/ansible/ansible-examples  
http://www.zsythink.net/archives/category/%e8%bf%90%e7%bb%b4%e7%9b%b8%e5%85%b3/ansible/

https://www.cnblogs.com/clsn/p/7743792.html#auto-id-66

ssh免密
```
ssh-keygen -t rsa 
ssh-copy-id 192.168.0.1    #本机ip
ansible all -m authorized_key -a "user=root exclusive=true manage_dir=true key='$(</root/.ssh/authorized_keys)'"
#验证
ssh 192.168.0.2            #其他机器ip
```


1、安装ansible
--
```
# yum install -y ansible

# vim /etc/ansible/ansible.cfg 
[defaults]
inventory = /etc/ansible/hosts                             #ansible inventory文件路径
library=/usr/share/my_modules/                             #库文件存放目录
remote_tmp = /tmp/.ansible/tmp                             #远程主机脚本临时存放目录
local_tmp = ~/.ansible/tmp                                 #本机的临时执行目录
forks = 5                                                  #并发数
poll_interval=15                                           #默认轮询时间间隔(单位秒)
become = root
sudo_user = root                                           #默认sudo用户
remote_port  = 22                                          #默认远程主机的端口号
host_key_checking = False                                  #避免ssh的时候输入yes
roles_path = /etc/ansible/roles:/usr/share/ansible/roles   #role路径
ask_sudo_pass = True                                       #每次执行是否询问sudo的ssh密码
ask_pass = True                                            #每次执行是否询问ssh密码
transport=smart                                            #传输方式
host_key_checking = False                                  #跳过检查主机指纹
timeout = 10
log_path = /var/log/ansible.log                            #开启ansible日志
private_key_file = /root/.ssh/id_rsa
#module_name = command                                     #默认执行模块，可以换成shell模块

[privilege_escalation]                                     #如果是普通用户则需要配置提权
become=True                                                #是否sudo
become_method=sudo                                         #sudo方式
become_user=root                                           #sudo 后变为root用户
become_ask_pass=False                                      #sudo 后是否验证密码
```
注意：控制端和被控制端第一次通讯，需要确认指纹信息, host_key_checking = False 参数注释打开即可

2、ansible读取配置文件优先级，自上而下
---
```
ANSIBLE_CONFIG
ansible.cfg                # 项目目录
.ansible.cfg               # 当前用户的家目录
/etc/ansible/ansible.cfg   # 优先级最低
```

3、配置ansible可以获取的主机
---
```
vim /etc/ansible/hosts
[webserver]
node01
node02
[dbserver]
192.168.1.[1:3]

[server:children]    #定义server组包含两个子组[dbserver,webserver]
webserver
dbserver

———————————————————————————
#定义组变量
[atlanta]
host1
host2
 
[atlanta:vars]       #表示要为这个组定义变量
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com
——————————————————————————
```  

4、常用命令  
---

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

0)查看模块帮助
```
ansible-doc -s file
```

1)ping测试  
```
ansible all -m ping
```

2)group  
```
#1、创建news基本组，指定uid为9999
ansible node02 -m group -a "name=news gid=9999 state=present" -i hosts

#2、创建http系统组，指定uid为8888
ansible node02 -m group -a "name=http gid=8888 system=yes state=present" -i hosts 

#3、删除news基本组
ansible node02 -m group -a "name=news state=absent" -i hosts
```

3)user  
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

#示5、创建http用户，并为该用户创建2048字节的私钥，存放在~/http/.ssh/id_rsa
# ansible node02  -m user -a 'name=http generate_ssh_key=yes ssh_key_bits=2048 ssh_key_file=.ssh/id_rsa' -i hosts
```  


4)copy  
```
#1、将本地的httpd.conf文件推送到远端服务。
ansible node02 -m copy -a "src=./httpd.conf dest=/etc/httpd/conf/httpd.conf owner=root group=root mode=644" -i hosts

#2、将本地的httpd.conf文件推送到远端，检查远端是否存在上一次的备份文件
ansible node02 -m copy -a "src=./httpd.conf dest=/etc/httpd/conf/httpd.conf owner=root group=root mode=644 backup=yes" -i hosts

#3、往远程的主机文件中写入内容
ansible node02 -m copy -a "content=HttpServer... dest=/var/www/html/index.html" -i hosts 

#4、拷贝目录
ansible node02 -m copy -a "src=/etc/pam.d/ dest=/tmp/ "
```  

5)command  shell  本质上执行都是基础命令  (command不支持管道技术)
```
command 模块
ansible all -m command -a "chdir=/opt/ touch new.ansible"

shell 模块
ansible node02 -m shell -a "ps aux|grep nginx"  -i hosts
```

7)file  
```
#1、创建文件，并设定属主、属组、权限。
ansible node02 -m file -a "path=/var/www/html/tt.html state=touch owner=apache group=apache mode=644" -i hosts 

#2、创建目录，并设定属主、属组、权限。
ansible node02 -m file -a "path=/var/www/html/dd state=directory owner=apache group=apache mode=755" -i hosts

#3、递归授权目录的方式。
ansible node02 -m file -a "path=/var/www/html/ owner=apache group=apache mode=755" -i hosts 
ansible node02 -m file -a "path=/var/www/html/ owner=apache group=apache recurse=yes" -i hosts

#4、创建连接文件
ansible all -m file -a "src=/etc/fstab path=/tmp/fstab.ansible state=link"
```

8)cron  
```
#0、每3分钟同步一次时间
ansible all -m cron -a "minute=*/3 job='/usr/bin/update 192.168.1.1 &> /dev/null' state=present name=update"

#1、添加定时任务。每分钟执行一次ls  * * * * * ls >/dev/null
ansible node02 -m cron -a "name=job1 job='ls >/dev/null'" -i hosts 

#2、添加定时任务，每天的凌晨2点和凌晨5点执行一次ls。"0 5,2 * * ls >/dev/null
ansible node02 -m cron -a "name=job2 minute=0 hour=5,2 job='ls >/dev/null'" -i hosts 

#3、关闭定时任务，使定时任务失效
ansible node02 -m cron -a "name=job2 minute=0 hour=5,2 job='ls >/dev/null' disabled=yes" -i hosts 
```  

9)yum模块	(安装present 卸载absent 升级latest  排除exclude 指定仓库enablerepo)
```
#1、安装当前最新的Apache软件，如果存在则更新
ansible web -m yum -a "name=httpd state=latest" -i hosts

#2、安装当前最新的Apache软件，通过epel仓库安装
ansible web -m yum -a "name=httpd state=latest enablerepo=epel" -i hosts 

#3、通过公网URL安装rpm软件
ansible web -m yum -a "name=https://mirrors.aliyun.com/zabbix/zabbix/4.2/rhel/7/x86_64/zabbix-agent-4.2.3-2.el7.x86_64.rpm state=latest" -i hosts 

#4、更新所有的软件包，但排除和kernel相关的
ansible web -m yum -a "name=* state=latest exclude=kernel*,foo*" -i hosts

#5、删除Apache软件
ansible web -m yum -a "name=httpd state=absent" -i hosts
```  

10)service  
```
#1、启动Httpd服务
ansible web -m service -a "name=httpd state=started"

#2、重载Httpd服务
ansible web -m service -a "name=httpd state=reloaded"

#3、重启Httpd服务
ansible web -m service -a "name=httpd state=restarted"

#4、停止Httpd服务
ansible web -m service -a "name=httpd state=stopped"

#5、启动Httpd服务，并加入开机自启
ansible web -m service -a "name=httpd state=started enabled=yes"  
```  

11)script 本地脚本拷贝到目标主机执行  
```
ansible all -m script -a "/opt/script_file.sh"
ansible all -m script -a 'chdir=/opt ./keme.sh'
```

12)get_url
```
#1、下载互联网的软件至本地
url  ==> http  https  ftp 
ansible node01 -m get_url -a "url=https://mirrors.aliyun.com/zabbix/zabbix/4.2/rhel/7/x86_64/zabbix-agent-4.2.3-2.el7.x86_64.rpm dest=/var/www/html/" -i hosts

#2、下载互联网文件并进行md5校验(了解)
ansible node01 -m get_url -a "url=https://mirrors.aliyun.com/zabbix/zabbix/4.2/rhel/7/x86_64/zabbix-agent-4.2.3-2.el7.x86_64.rpm dest=/var/www/html/ checksum=md5:7b86f423757551574a7499f0aae" -i hosts
```

13)mount
- present 将挂载信息写入/etc/fstab
- unmounted 卸载临时,不会清理/etc/fstab
- mounted 先挂载,在将挂载信息/etc/fstab		
- absent 卸载临时,也会清理/etc/fstab
```
#环境准备：将172.16.1.61作为nfs服务端，172.16.1.7、172.16.1.8作为nfs客户端挂载
# ansible localhost -m yum -a 'name=nfs-utils state=present'
# ansible localhost -m file -a 'path=/ops state=directory'
# ansible localhost -m copy -a 'content="/ops 172.16.1.0/24(rw,sync)" dest=/etc/exports'
# ansible localhost -m service -a "name=nfs state=restarted"

#1、挂载nfs存储至本地的/opt目录，并实现开机自动挂载
# ansible node02 -m mount -a "src=172.16.1.61:/ops path=/opt fstype=nfs opts=defaults state=mounted"  

#2、永久卸载nfs的挂载，会清理/etc/fstab
# ansible webservers -m mount -a "src=172.16.1.61:/ops path=/opt fstype=nfs opts=defaults state=absent"
```

14)selinux
```
# ansible node02 -m selinux -a "state=disabled"  -i hosts
```

15)firewalld
```
# ansible node02 -m service -a "name=firewalld state=started" -i hosts

#1、永久放行https的流量,只有重启才会生效
# ansible node02 -m firewalld -a "zone=public service=https permanent=yes state=enabled" -i hosts 

#2、永久放行8081端口的流量,只有重启才会生效
# ansible node02 -m firewalld -a "zone=public port=8080/tcp permanent=yes state=enabled" -i hosts 
	
#3、放行8080-8090的所有tcp端口流量,临时和永久都生效.
# ansible node02 -m firewalld -a "zone=public port=8080-8090/tcp permanent=yes immediate=yes state=enabled" -i hosts 
```

16）fetch  
从被控远端机器上拉取文件(和COPY模块整好相反) 
```
#拉取node02的文件 到 /home/ansible/目录下
# ansible node02 -m fetch -a 'src=/etc/hostname dest=/home/ansible/'
```

17)hostname
```
# ansible node02 -m hostname -a 'name=node05'
```


ansible playbook
===

常用执行语法

```
#检查语法是否正确
ansible-playbook --syntax-checak first.yaml

#不实际运行测试
ansible-playbook -C first.yaml

#检查运行的主机
ansible-playbook --list-host first.yaml

#加密playbook文件时提示输入密码
ansible-playbook --ask-vault-pass example.yaml

#指定要读取的Inventory清单文件
ansible-playbook example.yaml -i inventory
ansible-playbook example.yaml --inventory-file=inventory

#列出执行匹配到的主机，但并不会执行任何动作。
ansible-playbook example.yaml --list-hosts

#列出所有tags
ansible-playbook example.yaml --list-tags

#列出所有即将被执行的任务
ansible-playbook example.yaml --list-tasks  

#指定tags
ansible-playbook example.yaml --tags "configuration,install"

#跳过tags
ansible-playbook example.yaml --skip-tags "install"

#并行任务数。FORKS被指定为一个整数,默认是5
ansible-playbook example.yaml -f 5
ansible-playbook example.yaml --forks=5

指定运行的主机
ansible-playbook example.yaml --limit node01

查看主机变量
ansible node01 -m setup

ansible 172.16.1.8 -m setup -a "filter=ansible_memtotal_mb" -i hosts
172.16.1.8 | SUCCESS => {
    "ansible_facts": {
        "ansible_memtotal_mb": 1996, 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}

ansible 172.16.1.8 -m setup -a "filter=ansible_default_ipv4"
```

ansible-vault加密及解密
--
```
ansible-vault create test.yml 加密创建新文件
ansible-vault create --vault-password-file=file test.yml 指定密码加密创建新文件（file要先写好）

ansible-vault view test.yml 查看加密的文件
ansible-vault edit test.yml 编辑加密的文件

ansible-vault encrypt test.yml 加密已经有的文件
ansible-vault decrypt test.yml 解密

ansible-vault rekey test.yml 更改密码
ansible-vault rekey --new-vault password-file=file test.yml 指定密码文件更改密码

ansible-playbook --vault-password-file=file test.yml 执行加密的playbook（方式一）
ansible-playbook --vault-id @prompt test.yml 执行加密的playbook（方式二）
ansible-playbook --ask-vault-pass test.yml
```


基本语法  
---

ansible变量相关
---

ansible定义变量的方式{{ 变量名称 }}
- 1.通过playbook文件中的play进行定义
  - 通过vars来进行定义变量
  - 通过vars_files来进行定义变量
- 2.通过inventory主机清单进行变量定义
  - 通过host_vars对主机进行定义
  - 通过group_vars对主机组进行定义
- 3.通过执行playbook时使用-e参数指定变量

ansible变量的优先级  
1）在plabook中定义vars变量  
2）在playbook中定义vars_files变量  
3）在host_vars中定义变量  
4）在group_vars中定义变量  
5）通过执行命令传递变量  

变量的优先级(从左到右，外置参数最高，all.yaml最低）
外置传参--->playbook(vars_files--->vars)--->inventory(host_vars-->group_vars/group_name--->group_vars-all)

task控制:
- 1.判断语句  when
  - 根据主机名称来安装不同的yum仓库
  - 根据主机的系统安装不同的软件包
- 2.循环语句 with_items:  列表 item
  - 基本循环
  - 字典循环 facts
- 3.handlers触发
  - notify   通知
  - handlers 执行
- 4.include
  - include  #tasks
  - include_tasks #tasks
  - import_playbook #playbook
- 5.tags标签
  - -t 指定tag
  - --skip-tags: 跳过
- 6.忽略错误ignore_errors: yes
- 7.错误处理
  - fource_handlers: yes  强制调用handlers(少)
  - change_when: false    抑制changed状态
  - change_when: (check_nginx.stdout.find('ok')
		
```
# ansible node01 -m setup

- hosts: node01
  remote_user: root
  tasks:
   - name: copy file
     copy: content={{ ansible_env }} dest=/tmp/ansible.env
```

ansible中的内置变量
- Ansible内置了一些变量以方便主机之间相互调用各自的变量。
```
# 查看ansible的版本信息
ansible testA -m debug -a "msg={{ansible_version}}"

# 获取当前操作的目的主机的名称
ansible testA -m debug -a "msg={{inventory_hostname}}"

# 获取短名称
ansible testA -m debug -a "msg={{inventory_hostname_short}}"

# 获取清单中的组和信息
ansible testA -m debug -a "msg={{groups}}"

# 查看某个小分组的信息
ansible testA -m debug -a "msg={{groups.testA}}"

# 查看某个主机属于哪些组
ansible testA -m debug -a "msg={{group_names}}"

# 获取ansible主机清单的存放路径
ansible testA -m debug -a "msg={{inventory_dir}}"
```
- hostvars允许你访问另一个主机的变量，当然前提是ansible已经收集到这个主机的变量了：
- group_names：是当前主机所在的group列表
- groups：是所有inventory的group列表
- inventory_hostname：是在inventory里定义的主机名（ip或主机名称）
- play_hosts是当前的playbook范围内的主机列表
- inventory_dir和inventory_file是定义inventory的目录和文件

命令行传递变量  
```  
#  ansible-playbook -e pkgname=memcached  test.yaml
# cat test.yaml
- hosts: node01
  remote_user: root
  tasks:
   - name: install package {{ pkgname }}
     yum: name={{ pkgname }} state=latest
```

一次性传入多个变量，变量之间用空格隔开
```
ansible-playbook bl_test6.yml  --extra-vars 'pass_var="redhat" num_var="westos"'
ansible-playbook bl_test6.yml -e '{"pass_var":"test","num_var":"test1"}'

ansible命令传递变量
ansible testB -e "testvar=test" -m shell -a "echo {{testvar}}"
```



在playbook文件中的play使用变量
```
# cat vars.yml 
- hosts: node02
  vars:
    - web_packages: httpd-2.4.6
    - ftp_packages: vsftpd-3.0.2

  tasks:
    - name: Installed {{ web_packages }} {{ ftp_packages }}
      yum: 
        name:
          - "{{ web_packages }}"
          - "{{ ftp_packages }}"
        state: present
```

```
# cat vars.yml 
- hosts: node02
  vars:
    httpd:
      conf80: /etc/httpd/conf.d/80.conf
      conf8080: /etc/httpd/conf.d/8080.conf
  tasks:
    - name: task1
      file:
        path: "{{ httpd.conf80 }}"
	state: touch
    - name: task2
      file:
          path: "{{ httpd.conf8080 }}"
        state: touch
```

定义一个变量文件,然后使用playbook进行调用
```
定义一个变量文件
# cat vars_public.yml 
web_packages: httpd-2.4.6
ftp_packages: vsftpd-3.0.2

编写playbook调用变量文件
# cat test.yml
- hosts: node02
  vars_files: ./vars_public.yml

  tasks:
    - name: Installed {{ web_packages }} {{ ftp_packages }}
      yum: 
        name:
          - "{{ web_packages }}"
          - "{{ ftp_packages }}"
        state: present
```

```
# 定义一个变量文件
# cat testfile
testvar: testfile
numlist:
- one
- two
- three

# 编写playbook调用变量文件
# cat test.yml
- hosts: testA
  remote_user: root
  tasks:
    - name: "pass the var from the file"
      debug:
        msg: "{{testvar}} {{numlist[0]}}"

剧本传递变量文件
# ansible-playbook test.yml -e "@/root/testfile"
```



注册变量（register）
```
- hosts: webservers 
    gather_facts: no
    tasks:
      - name: Get date 
        command: date +"%F_%T"
        register: date_output
      - name: Echo date_output
        command: touch /tmp/{{date_output.stdout}}
```

```
# cat test.yml 
- hosts: node02
  tasks:
    - name: Installed Httpd Server
      yum: name=httpd state=present

    - name: Service Httpd Server
      service: name=httpd state=started

    - name: Check Httpd Server
      shell: ps aux|grep httpd
      register: check_httpd

    - name: OutPut Variables
      debug:
        msg: "{{ check_httpd.stdout_lines }}"
```

set_fact变量在tasks中定义
```
---
- hosts: test
  remote_user: root
  vars:
    testvar1: test1_string
  tasks:
  - shell: "echo test2_string"
    register: shellreturn       #注册变量接受shell模块返回的值
  - set_fact:
      testsf1: "{{testvar1}}"
      testsf2: "{{shellreturn.stdout}}"
  - debug:
      msg: "{{testsf1}} {{testsf2}}"
      #var: shellreturn
```

ansible facts变量
- 用来采集被控端的状态指标,比如: IP地址  主机名称  cpu信息  内存  等等
- 默认情况的facts变量名都已经预先定义好了, 只需要采集被控端的信息,然后传递至facts变量即可.
```
#手动获取被控端变量，拿到变量名
# ansible node02 -m setup

#编写playbook打印被控端变量值
# cat test.yml 
- hosts: node02
  gather_facts: yes     #获取被控端主机变量，模式为yes,关闭no
  tasks:
    - name: OutPut Variables ansible facets
      debug:
        msg: this default IPv4 address "{{ ansible_fqdn }}" is "{{ ansible_default_ipv4.address }}"

#查看输出结果
# ansible-playbook test.yml
```

在playbook中实现交互
---

```
- hosts: testA
  remote_user: root
  vars_prompt:
    - name: "you_name"              #定义的变量名
      prompt: "what is you name?"   #提示用户输入的不回显
    - name: "you_age"               #定义的变量名
      prompt: "how old are you?"
  tasks:
    - name: output vars
      debug:
        msg: your name is {{your_name}},you are {{your_age}} years old
```

设置输入时的默认值
```
- hosts: testA
  remote_user: root
  vars_prompt:
    - name: "solu" 
      prompt: "please choose \n
      A: solA\n
      B: solB\n
      C: solC\n"
      private: no
      default: A
  tasks:
    - name: out vars
      debug:
        msg: the so is {{solu}}
```

confirm（输入密码时，再确认一次）
```
- hosts: testA
  remote_user: root
  vars_prompt:
    - name: "you_name"              # 定义的变量名
      prompt: "what is you name?"
      private: no                   # 提示用户，输入的回显
    - name: "you_pass"               # 定义的变量名
      prompt: "what is your password?"
      encrypt: "sha512_crypt"       # 对用户输入进行hash,依赖python的passlib库
      confirm: yes                  # 输入密码后进行确认
  tasks:
    - name: create user
      user:
        name: "{{your_name}}"
        password: "{{user_pass}}"   # 输入的密码必须是经过加密的
```

invertory自带变量和自定义变量
---
```
ansible_ssh_host                  将要连接的远程主机名
ansible_ssh_port                  ssh端口号
ansible_ssh_user                  默认的ssh用户名
ansible_ssh_pass                  ssh 密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥)
ansible_sudo_pass                 sudo 密码(这种方式并不安全,我们强烈建议使用 --ask-sudo-pass)
ansible_connection                与主机的连接类型.比如:local, ssh 或者 paramiko. Ansible 1.2 以前默认使用 paramiko.1.2 以后默认使用 'smart','smart' 方式会根据是否支持 ControlPersist, 来判断'ssh' 方式是否可行.
ansible_ssh_private_key_file      ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况.
ansible_shell_type                目标系统的shell类型.默认情况下,命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'.
ansible_python_interpreter        目标主机的 python 路径.适用于的情况: 系统中有多个 Python, 或者命令路径不是"/usr/bin/python",比如  \*BSD, 或者 /usr/bin/python不是 2.X 版本的 Python.我们不使用 "/usr/bin/env" 机制,因为这要求远程用户的路径设置正确,且要求 "python" 可执行程序名不可为 python以外的名字(实际有可能名为python27).与 ansible_python_interpreter 的工作方式相同,可设定如 ruby 或 perl 的路径....
```
- ansible_ssh_host
- ansible_ssh_port
- ansible_ssh_user
- ansible_ssh_pass
- ansible_ssh_sudo_pass
```
# cat /etc/ansible/hosts
node01 ansible_host=192.169.101.66 ansible_user=root ansible_ssh_pass='123456'
node02 ansible_host=192.169.101.67 ansible_user=root ansible_ssh_pass='123456'

[test]
node01 ansible_ssh_port=5678 ansible_ssh_user=hadoop ansible_ssh_pass=123456

[web]
node01 http_port=80              #分别为每个主机定义变量
node02 http_port=8080

[web:vars]                      #组变量,为web下的主机全部添加变量
   http_port=9090


# vim test.yaml
- hosts: web
  remote_user: root
  tasks:
   - name: http_port
     copy: content={{ http_port }} dest=/opt/test_http_port
```  

通过inventory主机清单进行变量定义,在项目目录下创建两个变量的目录,host_vars group_vars

一、group_vars
```
1）在当前的项目目录中创建两个变量的目录
# mkdir host_vars
# mkdir group_vars

2）在group_vars目录中创建一个文件，文件名与inventory清单中的组名称要保持完全一致。
# vim group_vars/webserver
web_packages: wget
ftp_packages: tree
        
3）编写playbook，只需在playbook文件中使用变量即可。
# vim install.yml 
- hosts: webserver
  tasks:
    - name: Install Rpm Packages "{{ web_packages }}" "{{ ftp_packages }}"
      yum: 
        name: 
          - "{{ web_packages }}"
          - "{{ ftp_packages }}"
        state: present
```
注意: 默认情况下,group_vars目录中文件名与hosts清单中的组名保持一致.比如在group_vars目录中创建了webserver组的变量,其他组是无法使用webserver组的变量系统提供了一个特殊组,all,只需要在group_vars目录下建立一个all文件,编写好变量,所有组都可使用.

二、host_vars
```
1）在host_vars目录中创建一个文件，文件名与inventory清单中的主机名称要保持完全一致
# cat hosts 
[test]
172.16.1.7
172.16.1.8

2）在host_vars目录中创建文件，给172.16.1.7主机定义变量
# cat host_vars/172.16.1.7 
web_packages: zlib-static
ftp_packages: zmap

#3）准备一个playbook文件调用host主机变量
# cat test.yml 
- hosts: 172.16.1.7
  tasks:
    - name: Install Rpm Packages "{{ web_packages }}" "{{ ftp_packages }}"
      yum: 
        name: 
          - "{{ web_packages }}"
          - "{{ ftp_packages }}"
        state: present

- hosts: 172.16.1.8
  tasks:
    - name: Install Rpm Packages "{{ web_packages }}" "{{ ftp_packages }}"
      yum: 
        name: 
          - "{{ web_packages }}"
          - "{{ ftp_packages }}"
        state: present
```
- host_vars 特殊的变量目录,针对单个主机进行变量.
- group_vars 特殊的变量目录,针对inventory主机清单中的组进行变量定义. 对A组定义的变量 B组无法调用
- group_vars/all 特殊的变量文件,可以针对所有的主机组定义变量.

all.yml中定义变量
```
# vim group_vars/all.yml
ansible_user: 'vagrant'
ansible_ssh_private_key_file: '/home/haibin/.vagrant.d/insecure_private_key'

elk_version: '6.7.0'
timezone: 'Asia/Shanghai'
apt_mirror: 'mirrors.aliyun.com'
```

template文件
---
```
1、编写template文件并修改配置对应到变量
# cat /opt/src/redis.conf |grep ^bind
bind {{ ansible_enp0s3.ipv4.address }}

2、编写playbook文件
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

3、运行后查看配置文件是否更换
# cat /etc/redis.conf |grep ^bind
bind 192.168.1.70
```  

handlers
---
- notify：在任务结束时触发  
- handlers：由特定条件触发Tasks  
```
- hosts: node01
  remote_user: root
  tasks:
   - name: install redis
     yum: name=redis state=present
   - name: copy config file
     copy: src=/opt/src/redis.conf dest=/etc/redis.conf owner=redis
     notify: restart redis
     tags: conf
   - name: start redis
     service: name=redis state=started enabled=true
  handlers:
   - name: restart redis
     service: name=redis state=restarted



# ansible-playbook first.yaml                #运行playbook
# ansible-playbook -t conf first.yaml        #运行tags里的命令
```  
- 1.无论多少个task通知了相同的handlers，handlers仅会在所有tasks结束后运行一次。
- 2.只有task发生改变了才会通知handlers，没有改变则不会触发handlers。
- 3.不能使用handlers替代tasks、因为handlers是一个特殊的tasks。


listen 可以把listen理解成"组名",可以把多个handler分成"组"  
一个task中调用多个handler
```
- hosts: testB
  remote_user: root
  tasks:
  - name: task1
    file: path=/testdir/testfile
          state=touch
    notify: handler group1

  handlers:
  - name: handler1
    listen: handler group1
    file: path=/testdir/ht1
          state=touch
  - name: handler2
    listen: handler group1
    file: path=/testdir/ht2
          state=touch
```

meta模块

默认情况下，所有task执行完毕后，才会执行各个handler，并不是执行完某个task后，立即执行对应的handler，如果想要在执行完某些task以后立即执行对应的handler，则需要使用meta模块
```
- hosts: testB
  remote_user: root
  tasks:
  - name: task1
    file: path=/testdir/testfile
          state=touch
    notify: handler1
  - name: task2
    file: path=/testdir/testfile2
          state=touch
    notify: handler2

  - meta: flush_handlers

  - name: task3
    file: path=/testdir/testfile3
          state=touch
    notify: handler3

  handlers:
  - name: handler1
    file: path=/testdir/ht1
          state=touch
  - name: handler2
    file: path=/testdir/ht2
          state=touch
  - name: handler3
    file: path=/testdir/ht3
          state=touch
```

force_handelers强制执行handlers  
通常任务失败会终止，force_handelers可以在任务失败后任然执行处理程序，要写在剧本中
```
- hosts
  force_handelers: yes
  tasks: 
    .........................
```


判断循环
---

条件
| 用法 | 描述 |
|-------|-------|
| A== "B" | 等于（字符串）|
| A==100 | 等于（数字）|
| < | 小于 |
| > | 大于 |
| <= | 小于等于 |
| >= | 大于等于 |
| != | 不等于 |
| 1、true、yes | 布尔值true |
| 0、false、no | 布尔值false |
| A in B | 第一个变量的值存在，且在第二个变量的列表中 |

多条件
| 用法 | 描述 |
|-----|------|
| or | 逻辑或，当做边与右边有任意一个为真，则返回真 |
| and | 逻辑与，当左边与右边同时为真，则返回真 |
| not | 取反，对一个操作体取反 |
| () | 组合，将一组操作体包装在一起，形成一个较大的操作体 |

存在判断
| 用法 | 描述 |
|-----|------|
| is exists | 存在则返回真 |
| is not exists | 不存在则返回真 |

变量是否定义判断
| 用法 | 描述 |
|-----|------|
| defined | 判断变量是否已经定义，已经定义则返回真 |
| undefind | 判断变量是否已经定义，未定义则返回真 |
| none | 判断变量值是否为空，如果变量已经定义，但是变量值为空，则返回真 |


任务执行结果判断
| 用法 | 描述 |
|-----|------|
| success 或 succeeded | 通过任务的返回值信息判断任务的执行状态，任务执行成功则返回真 |
| failure 或 failed | 通过任务的返回值信息判断任务的执行状态，任务执行失败则返回真 |
| change 或 changed | 通过任务的返回值信息判断任务的执行状态，任务执行chage则返回真 |
| skip 或 skipped | 通过任务的返回值信息判断任务的执行状态，当任务没满足条件，而跳过执行时，则返回真 |

路径的判断
| 用法 | 描述 |
|-----|------|
| file | 判断路径是否是一个文件，如果路径是一个文件则返回真 |
| directory | 判断路径是否是一个目录，如果是一个目录则返回真 |
| link | 判断路径是否是一个软连接，如果是一个软连接则返回真 |
| mount | 判断路径是否是一个挂载点，如果是一个挂载点则返回真 |
| exists | 判断路径是否存在，如果存在则返回真 |
- 上述判断为2.6版本中的名称，如果是2.5之前的版本需要加上`is_`前缀

字符串判断
| 用法 | 描述 |
|-----|------|
| lower | 判断包含字母的字符串中的字母是否为纯小写，字符串中的字母全部为小写则返回为真 |
| upper | 判断包含字母的字符串中的字母是否为纯大写，字符串中的字母全部为大写则返回为真 |

整数的判断
| 用法 | 描述 |
|-----|------|
| even | 判断数值是否是偶数，是偶数则返回真 |
| odd | 判断数值是否是奇数，是奇数则返回真 |
| divisibleby(num) | 判断是否可以正吃指定的数值，如果除以指定的数值以后余数为0，则返回真 |

版本判断
| 用法 | 描述 |
|-----|------|
| version | 可以用于对比两个版本号的大小，或者指定的版本号进行对比使用语法为version('版本号'，'比较操作符') |
- 注：2.5版本中`version_compare`更名为`version`

当版本比较时支持多种比较操作符
- 大于： >,gt
- 大于等于： >=,ge
- 小于： <,lt
- 小于等于： <=,le
- 等于： ==,=,eq
- 不等于： !=,<>,ne

子集父集判断
| 用法 | 描述 |
|-----|------|
| subset | 判断一个list是不是另一个list的子集，是另一个list的子集则返回真 |
| superset | 判断一个list是不是另一个list的父集，是另一个list的父集则返回真 |
- 2.5版本中issubset和issuperset更名为subset和superset

字符串和数值判断
| 用法 | 描述 |
|-----|------|
| string | 判断对象是否是一个字符串，是字符串则返回真 |
| number | 判断对象是否是一个数字，是数字则返回真 |

| 用法 | 描述 |
|-----|------|
| is match | 开头匹配的，则为真 |
| is not match | 开头没匹配到，则为真 |

- search：子串匹配
- regex：正则匹配


测验列表真假
| 用法 | 描述 |
|-----|------|
| all | 一假则假 |
| any | 一真则真 |
- 用于检查列表里元素的真假，列表中所有为真或者任何一个为真


1、when判断
```
1、根据不同操作系统，安装相同的软件包
# cat tasks.yml 
- hosts: webserver
  tasks:

    - name: Installed {{ ansible_distribution }} Httpd Server
      yum: name=httpd state=present
      when: ( ansible_distribution == "CentOS" )

    - name: Installed {{ ansible_distribution }} Httpd2 Server
      yum: name=httpd2 state=present
      when: ( ansible_distribution == "Ubuntu" )
	
---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "redhat7"
    when: ansible_distribution == "Redhat" and ansible_distribution_major_version == "7"

---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "redhat7"
    when:
    - ansible_distribution == "Redhat"           #两个条件同时满足才执行
    - ansible_distribution_major_version == "7"

---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "redhat7 or 6"
    when: ansible_distribution == "Redhat" and (ansible_distribution_major_version == "7" or ansible_distribution_major_version == "6"

取反，如果系统不是windows，则输出"not windows"
---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "not windows"
    when: not ansible_distribution == "windows"


2、当shell模块运行命令后的返回值，进行判断
- host: testA
  remote_user: root
  tasks:
  - name: task1
    shell: "ls /testabc"
    register: returnmsg
    ignore_errors: true          #即使当前语句报错，也会忽略,继续执行playbook
  - name: task2
    debug:         # var: returnmsg 当执行成功时，相当于$？的值是0，命令执行成功
      msg: " command exection successful "
    when: returnmsg.rc == 0
  -name: task3
    debug:
      msg: " command failed "
    when: returnmsg.rc != 0


3、为所有的web主机名添加nginx仓库，其余的都跳过添加
# cat tasks.yml 
- hosts: all
  tasks:
    - name: Create YUM Repo
      yum_repository:
        name: ansible_nginx
        description: ansible_test
        baseurl: https://mirrors.aliyun.com/repo/Centos-7.repo
        gpgcheck: no
        enabled: no
      when: ( ansible_fqdn is match ("web*"))

4、主机名称是web*或主机名称是lb*的则添加这个nginx源
# cat tasks.yml 
- hosts: all
  tasks:
    - name: Create YUM Repo
      yum_repository:
        name: ansible_nginx
        description: ansible_test
        baseurl: https://mirrors.aliyun.com/repo/Centos-7.repo
        gpgcheck: no
        enabled: no
      when: ( ansible_fqdn is match ("web*")) or ( ansible_fqdn is match ("lb*"))
可以用or 或者and 做判断

5、根据命令执行的结果进行判断
# cat tasks.yml 
- hosts: all
  tasks:
    #检查httpd服务是否是活动的
    - name: Check Httpd Server
      command: systemctl is-active httpd
      ignore_errors: yes
      register: check_httpd

    #如果check_httpd变量中的rc结果等于0，则执行重启httpd，否则跳过
    - name: Httpd Restart 
      service: name=httpd state=restarted
      when: check_httpd.rc == 0
      
6、布尔型判断
- name: Boolean test
    hosts: all
    vars:
      run_my_task: true             # 只有当变量为true时，才会执行
    tasks:
      - name: httpd is install
        yum: name=httpd
	when: run_my_task

7、变量是否存在的或定义
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    testvar: "test"
    testvar1: 
  tasks:
  - debug:
      msg: "var is defined"
    when: testvar is defined             # 变量是否定义
  - debug:
      msg: "var is not defined"
    when: testvar2 is not defined        # 变量是否未定义
  - debug:
      msg: "var is defined,but no value"
    when: testpath is none               # 变量值是否为空

8、判断文件是否存在 is exists,is not exists
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    testpath: /test
  tasks:
  - debug:
      msg: "file exist"
    when: testpath is exists

---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    testpath: /testrrr
  tasks:
  - debug:
      msg: "file not exist"
    when: not testpath is exists
    
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    testpath: /test
  tasks:
  - debug:
      msg: "file exist"
    when: testpath is not exists

9、命令的执行结果判断success、failure
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    doshell: "yes"
  tasks:
  - shell: "cat /test/abc"
    when: doshell == "yes"
    register: returnmsg
    ignore_errors: true
  - debug:
      msg: "success"
    when: returnmsg is success
  - debug:
      msg: "changed"
    when: returnmsg is change
  - debug:
      msg: "failed"
    when: returnmsg is failure
  - debug:
      msg: "skip"
    when: returnmsg is skip

10、路径判断
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    testpath1: "/testdir/test"
    testpath2: "/testdir/"
    testpath3: "/testdir/testsoftlink"
    testpath4: "/testdir/testhardlink"
    testpath5: "/boot"
  tasks:
  - debug:
      msg: "file"
    when: testpath1 is file
  - debug:
      msg: "directory"
    when: testpath2 is directory
  - debug:
      msg: "link"
    when: testpath3 is link
  - debug:
      msg: "link"
    when: testpath4 is link
  - debug:
      msg: "mount"
    when: testpath5 is mount
  - debug:
      msg: "exists"
    when: testpath1 is exists

11、字符串判断
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    str1: "abc"
    str2: "ABC"
  tasks:
  - debug:
      msg: "this string is all lower"
    when: str1 is lower             # 判断字符串是否为全小写
  - debug:
      msg: "this string is all lower"
    when: str2 is upper             # 判断字符串是否为全大写


12、整除的判断
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    str1: 4
    str2: 7
    str3: 64
  tasks:
  - debug:
      msg: "an even number"
    when: str1 is even
  - debug:
      msg: "an odd number"
    when: str2 is odd
  - debug:
      msg: "can be diviede exactly by"
    when: str3 is divisibleby(8)

13、版本判断
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    ver1: 7.4.1708
    ver2: 7.4.1707
  tasks:
  - debug:
      msg: "greater"
    when: ver1 is version(ver2,">")  # ver1的版本大于ver2
  - debug:
      msg: "greater1"
    when: ansible_distribution_version is version("7.3","gt")   # ansible的版本大于7.3

14、子集父集
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    a: 
    - 2
    - 5
    b: [1,2,3,4,5]
  tasks:
  - debug:
      msg: "a is a subset of b"
    when: a is subset(b)
  - debug:
      msg: "b is the parent set of a"
    when: b is suberset(a)

15、字符串判断
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    testvar1: 1
    testvar2: "1"
    tesrvar3: a
  tasks:
  - debug:
      msg: "string"
    when: testvar1 is string
  - debug:
      msg: "string"
    when: testvar2 is string
  - debug:
      msg: "string"
    when: testvar3 is string

16、数值判断
---
- host: testA
  remote_user: root
  gather_facts: no
  vars:
    testvar1: 1
    testvar2: "1"
    tesrvar3: 0.2
  tasks:
  - debug:
      msg: "number"
    when: testvar1 is number
  - debug:
      msg: "number"
    when: testvar2 is number
  - debug:
      msg: "number"
    when: testvar3 is number

17、交互式变量
1）var_prompt提示用户输入信息并写入变量
- hosts: testB
  remote_user: root
  vars_prompt:
    - name: "your_name"
      prompt: "What is your name"
    - name: "your_age"
      prompt: "How old are you"
  tasks:
   - name: output vars
     debug:
      msg: Your name is {{your_name}},You are {{your_age}} years old.

2）交互式远程创建用户
- hosts: testB
  remote_user: root
  vars_prompt:
    - name: "user_name"
      prompt: "Enter user name"
      private: no
    - name: "user_password"
      prompt: "Enter user password"
  tasks:
   - name: create user
     user:
      name: "{{user_name}}"
      password: "{{user_password}}"
```  

字符串匹配
```
---
- hosts: manageservers
  vars:
    url: "http://example.com/users/foo/resources/bar"

  tasks:
    - debug:
        msg: "matched pattern 1-1"
      when: url is match("http://example.com/users/.*/resources/.*") # True

    - debug:
        msg: "matched pattern 1-2"
      when: url is match("http://example.com") # True

    - debug:
        msg: "matched pattern 1-3"
      when: url is match(".*://example.com") # True

    - debug:
        msg: "matched pattern 1-4"
      when: url is match("example.com/users/.*/resources/.*") # False

    - debug:
        msg: "matched pattern 2-1"
      when: url is search("/users/.*/resources/.*") # True

    - debug:
        msg: "matched pattern 2-2"
      when: url is search("/users/") # True

    - debug:
        msg: "matched pattern 2-3"
      when: url is search("/user/") # False

    - debug:
        msg: "matched pattern 3"
      when: url is regex("example.com/\w+/foo") # True
```

测验列表真假
```
---
#  tests 测验 all any
- hosts: manageservers

  vars:
    mylist:
      - 1
      - "{{ 3 == 3 }}"
      - True
    myotherlist:
      - False
      - True

  tasks:
    - debug:
        msg: "all are true!"
      when: mylist is all

    - debug:
        msg: "at least one is true"
      when: myotherlist is any
```

条件判断与block
---
1、如果判断条件成立，则执行的一个任务，如果想执行多个任务可以使用block模块解决
```
---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "task1 not in block"
  - block:                       #将多个任务写在一个block中，当判断语句成立则执行block语句
      - debug:
          msg: "task1 in block"
      - debug:
          msg: "task1 in block"
    when: 2 > 1
```

2、block中的内容执行失败后，执行rescue中的内容
```
---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - block:
      - shell: 'ls /oo'
    rescue:                      # 当block中的内容执行失败后，执行rescue中的内容
      - debug:
          msg: "i cought an error"

```

3、block任意语句执行错误都会按照顺序执行rescue内容
```
---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - block:                       #将多个任务写在一个block中，当判断语句成立则执行block语句
      - shell: 'ls /mnt'         # 任意一个错误，都会执行rescue中的内容
      - shell: 'ls /mnt1'
      - shell: 'ls /mnt2'
    rescue:                      # 写多个任务
      - debug:
        msg: "i cought an error1"
      - debug:
        msg: "i cought an error1"
```

block结合always关键字
---
1、无论block中的任务执行成功还是失败，always中的任务都会被执行
```
---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - block:
      - debug:
          msg: "i execute no rmally"
      - command: /bin/false
      - debug:
          msg: 'i never execute'
    rescue:
      - debug:
          msg: "i execute no error1"
      - command: /bin/false
      - debug:
          msg: 'i never execute'
    always:
      - debug:
          msg: "this is always execute"
```

错误忽略ignore_errors
---
```
# cat test.yml 
- hosts: webserver
  tasks:
     - name: task1
       shell: "ls /testabc"
       register: returnmsg
       ignore_errors: true          #即使当前语句报错，也会忽略,继续执行playbook
     - name: task2
       debug: 
         msg: "command exection successful"
       when: returnmsg.rc == 0
     - name: task3
       debug:
         msg: "command failed"
```

条件判断与错误处理
---
```
---
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - block:
      - debug:
          msg: "1"
      - debug:
          msg: '2'
      - fail:                  # 手动让后面的都失败
          msg: "my test"       # 可以通过fail模块的msg自定义报错信息
      - debug:
          msg: "3"
      - debug:
          msg: '4'
```

```
--- 
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
  - block:
      - shell: "echo '---error'"
        register: return_value
      - fail:
          msg: "running fail"
	when: " 'error' in return_value.stout"
      - debug:        # 当中断时，不会执行这里的内容
          msg: " i never exectue"

```

使用in或者not in条件判断时正确写法
```
when: ' "successful" not in return_value.stdout '
when: " 'successful' not in return_value.stdout "
```

failed_when关键字
---
```
--- 
- host: testA
  remote_user: root
  gather_facts: no
  tasks:
    - shell: "echo '---error'"
      register: return_valuefailed_when: '"error" in return_value.stout'  # 针对shell模块的关键字，当error在shell模块的输出时，条件成立，shell模块的执行状态将会被设置失败，playbook终止运行但不代表shell模块没有正常执行
    - debug:
        msg: "i never exectue"
```


changed_when 关键字
---
```
--- 
- host: testA
  remote_user: root
  tasks:
    - bedug:
        msg: "test message"
      changed_when: 2 > 1
```

```
--- 
- host: testA
  remote_user: root
  tasks:
    - shell: "ls /opt"
      changed_when: false    #此时任务的执行状态不是changed了,是ok
```

交互是变量进行hash加密
---
```
利用encrypt关键字可以解决之前遇到的创建用户时指定密码字符串的问题，但是需要注意，

- hosts: testB
  remote_user: root
  vars_prompt:
    - name: "hash_string"                      # 哈希计算后的字符串会存入到"hash_string"变量中
      prompt: "Enter something"
      private: no
      encrypt: "sha512_crypt"                  # encrypt表示对用户输入的信息进行哈希，"sha512_crypt"表示使用sha512算法对用户输入的信息进行哈希
  tasks:
   - name: Output the string after hash
     debug:
      msg: "{{hash_string}}"
      
--------------------------------------------------
当使用"encrypt"关键字对字符串进行哈希时，ansible需要依赖passlib库完成哈希操作，如果未安装passlib库（一个用于哈希明文密码的python库），执行playbook时会报错
为了能够正常执行上述playbook，需要先安装passlib库。

此处通过pip安装passlib库，由于当前主机也没有安装pip，所以先下载安装pip
# yum install wget -y
# wget https://pypi.python.org/packages/source/s/setuptools/setuptools-0.6c11.tar.gz
# tar zxf setuptools-0.6c11.tar.gz 
# tar zxf pip-20.0.2.tar.gz 
# cd pip-20.0.2
# python setup.py install

pip安装完成后，通过pip安装passlib库
# pip install passlib

```

循环语句
---

| 循环语句关键字 | 描述 |
|--------------|-------|
| with_items  | 简单的列表循环 |
| with_nested | 嵌套循环 |
| with_dict | 循环字典 |
| with_fileglob | 循环指定目录中的所有文件 |
| with_lines | 循环一个文件中的所有行 |
| with_sequence | 生成一个自增的整数序列，可以指定起始值和结束值以及步长。参数以key=value的形式指定，format指定输出的格式。数字可以是十进制、十六进制、八进制 |
| with_subelement | 遍历子元素 |
| with_together | 遍历数据并行集合 |
- 旧循环语句（版本在2.5之前仅有的),这些语句使用with_作为前缀,些语法目前仍然兼容，但在未来的某个时间点，会逐步废弃。

with_items、with_list、loop迭代,ansible2.5版本之后将with_items、with_list迁移至loop

```
1、使用循环启动多个服务
- hosts: web
  remote_user: root
  tasks:
   - name: install {{ item }} package
     yum: name={{ item }}  state=latest
     with_items:
      - tomcat
      - tomcat-webapps
      - tomcat-admin-webapps
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_items: [1,2,3,4]


- name: with_list
  debug:
    msg: "{{ item }}"
  with_list:
    - one
    - two

- name: with_list -> loop
  debug:
    msg: "{{ item }}"
  loop:
    - 1
    - 2


#通过变量传递的方式
- name: with_items -> loop
  debug:
    msg: "{{ item }}"
  loop: "{{ items|flatten(levels=1) }}"
```

```
- hosts: testA
  remote_user: root
  vars:
    dirs:                        # 相当于定义了一个列表
    - "/opt/a"
    - "/opt/b"
    - "/opt/c"
    - "/opt/d"
  tasks:
    - name: "create file"
      file:
        path: "{{item}}"         # 输出了每一次循环的值
	state: touch
      with_items: "{{dirs}}"     # 循环了列表
```

借助注册函数，多次执行循环中的不同命令
```
---
- hosts: testA
  remote_user: root
  tasks:
  - shell: "{{item}}"
    register: returnvalue
    with_items:
    - "ls /opt"
    - "ls /mnt"
  - debug:
      var: returnvalue
```

results,shell模块执行后的返回值放入results的序列中，results也是一个返回值
```
---
- hosts: testA
  remote_user: root
  tasks:
  - shell: "{{item}}"
    register: returnvalue
    with_items:
    - "ls /opt"
    - "ls /mnt"
  - debug:
      msg: "{{returnvalue.results}}"
      
---
- hosts: testA
  remote_user: root
  tasks:
  - shell: "{{item}}"
    register: returnvalue
    with_items:
    - "ls /opt"
    - "ls /mnt"
  - debug:
      msg: "{{item.stdout}}"
    with_items: "{{returnvalue.results}}"
```

for循环实现遍历
```
---
- hosts: testA
  gather_facts: no
  tasks:
  - shell: "{{item}}"
    with_items:
    - "ls /opt"
    - "ls /home"
    register: returnvalue
  - debug:
      msg:
       "{% for i in returnvalue.results %}
          {{ i.stdout }}
        {% endfor %}"
```

嵌套列表的定义
```
---
- hosts: testA
- remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_item:
    - [ 1,2,3 ]
    - [ a,b ]
```

```
---
- hosts: testA
- remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_list:
    - [ 1,2,3 ]
    - [ a,b ]
```

```
---
- hosts: testA
- remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_flattened:
    - [ 1,2,3 ]
    - [ a,b ]
```
- with_list、with_items、with_flattened之前的区别，在处理简单的单层列表时没区别，但是在处理嵌套的多层列表时，with_items、with_flattened会将列表"拉平展开"循环的处理每一个元素，而with_list只会处理最外层的列表，将最外层的列表中的项循环处理

 with_together关键字
 -  with_together可以将两个列表中的元素"对齐合并"
```
---
- hosts: testA
- remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_together:
    - [ 1,2,3 ]
    - [ a,b ]
```

with_cartesian关键字
- 将每个小列表中的元素按照"迪卡尔的方式"组合后，循环的处理每个组合
```
---
- hosts: testA
- remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_together:
    - [ 1,2,3 ]
    - [ a,b,c ]
```

with_indexed_items关键字
- 循环处理列表时为列表中的每一项添加"数字索引"，"索引"从0开始

1)单层列表
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is : {{ item.0 }} , value is {{ item.1 }}"
    with_indexed_items:
    - test1
    - test2
    - test3
```

2) 两层列表嵌套
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is : {{ item.0 }} , value is {{ item.1 }}"
    with_indexed_items:
    - [ test1, test2 ]
    - [ test3, test4, test5 ]
    - [ test6, test7 ]
```

with_sequence关键字
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is : {{ item }}"
    with_sequence: start=1 end=5 stride=1           # 步长为1
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is : {{ item }}"
    with_sequence:
      start=6
      end=2
      stride=-2           # 输出的是递减序列
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is : {{ item }}"
    with_sequence: count=5           #输出 1，2，3，4，5
```

```
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - file: 
      path: "/westos{{item}}"
      state: directory
    with_sequence:
      start=2
      end=10
      stride=2
```

with_sequence格式化输出
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_sequence: start=2 end=6 stride=2 format="number is %0.2f"
```

with_random_choice关键字
- 从列表中随机取一个值
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_random_choice:
      - 1
      - 2
      - 3
```

with_dict关键字
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      lily: female
      bob: male
  tasks:
  - debug:
      msg: "{{item}}"       # 每一个item就是一组键值对    
    with_dict: "{{users}}"  # 字典形式输出users
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      lily: female
      bob: male
  tasks:
  - debug:
      msg: "user name:{{item.key}},user gender:{{item.value}}"   
    with_dict: "{{users}}"  # 字典形式输出users
```

字典的嵌套
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      lily:
        name: lilybb
	sex: female
	tele: 1234567
      bob:
        name: bobbb
	sex: male
	tele: 8899078
  tasks:
  - debug:
      msg: "{{item}}"   
    with_dict: "{{users}}"  # 字典形式输出users
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      lily:
        name: lilybb
	sex: female
	tele: 1234567
      bob:
        name: bobbb
	sex: male
	tele: 8899078
  tasks:
  - debug:
      msg: "user {{item.key}} is {{item.value.name}} sex is {{item.value.sex}}"        # 多层字典的引用   
    with_dict: "{{users}}"  # 字典形式输出users
```

with_subelements关键字
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      lily:
        name: lilybb
	sex: female
	tele: 1234567
	hobby:
	  - skate
	  - video
      bob:
        name: bobbb
	sex: male
	tele: 8899078
	hobby:
	  - music
  tasks:
  - debug:
      msg: "{{item}}"       # 多层字典的引用   
    with_subelements: "{{users}}" 
#    - "{{users}}"
#    - hobby
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      lily:
        name: lilybb
	sex: female
	tele: 1234567
	hobby:
	  - skate
	  - video
      bob:
        name: bobbb
	sex: male
	tele: 8899078
	hobby:
	  - music
  tasks:
  - debug:
      msg: "{{ item.0.name }} is {{item.1}}"
    with_subelements:
    - "{{users}}"
    - hobby
```

with_file关键字
- 查看文件的内容，针对ansible主机进行操作，而不是目标主机
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_file:
    - /test/pp
    - /opt/ansible
```

with_fileglob关键字
- 匹配文件名称，在指定目录中匹配符合模式的文件名，针对ansible主机进行操作，而不是目标主机
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_fileglob:     #只匹配文件，输出文件名，而不是内容
    - /test/*
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_fileglob:     #只匹配文件，输出文件名，而不是内容
    - /test/*
    - /opt/test*.???   #匹配/opt/test开头的以三个符号结尾的
```




2、定义变量方式循环安装软件包
```
# cat vars.yml
- hosts: web
  tasks:
    - name: Installed Httpd Mariadb Package
      yum: name={{ pack }} state=latest
      vars:
       pack:
         - httpd
         - mariadb-server	
```

3、使用变量字典循环方式批量创建用户
```
- name: with_items
  user: name={{itme.name}} groups={{item.groups}} state=present
  with_items:
    - {name: 'zhangsan', groups: nginx}
    - {name: 'lisi', groups: nginx}
```

4、使用变量字典循环方式批量拷贝文件
```
- hosts: webserver
  tasks:
    - name: Configure Rsyncd Server
      copy: src={{ item.src }} dest={{ item.dest }} mode={{ item.mode }}
      with_items:
        - { src: './rsyncd.conf.j2', dest: '/tmp/rsyncd.conf', mode: '0644' }
        - { src: './rsync.pass.j2', dest: '/tmp/rsync.pass', mode: '0600' }

    - name: Configure PHP-FPM {{ php_fpm_conf }}
      template: src={{ item.src }} dest={{ item.dest }}
      with_items:
        - { src: './docs1/php_www.conf.j2', dest: '{{ php_fpm_conf }}' }
        - { src: './docs1/php.ini.j2', dest: '{{ php_ini_conf }}' }
```

# lookup插件

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
    - debug:
        msg: " index is {{item.0}},value is {{item.1}}"
      with_indexed_items: ['a','b','c']
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
    - debug:
        msg: " index is {{item.0}},value is {{item.1}}"
      loop: "{{ lookup(' indexed_items',['a','b','c'])}}"   #lookup是插件 loop是循环
```
- 第一个使用with_indexed_items关键字处理列表
- 第二个使用loop关键字配合lookup产处理列表
- indexed_items是一个lookup插件


```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      yyx: male
      ll: female
  tasks:
    - debug:
        msg: "{{item.key}} is {{item.value}}"
      with_dict: "{{users}}"   #获取字典中的每一个键值对
```


```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    users:
      yyx: male
      ll: female
  tasks:
    - debug:
        msg: "{{item.key}} is {{item.value}}"
      loop: "{{lookup('dict'users)}}"
```

## 插件用法
`lookup('插件名',被处理数据或参数)`


```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
    - debug:
        msg: "{{lookup('file','/test/yxx')}}"   # 查看本机文件的内容


---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
    - debug:
        msg: "{{lookup('file','/test/yxx','/test/yxx1')}}"   # 查看本机多个文件的内容

---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
    - debug:
        msg: "{{lookup('file','/test/yxx','/test/yxx1',wantlist=true)}}"   # 查看本机多个文件的内容,以逗号分隔字符串。

# 2.5版本中引入了jinja2函数，这函数叫query，通过query也可以调用lookup插件，但是通过query函数调用lookup插件时，query函数的默认行为是返回一个列表
- debug:
      msg: "{{ lookup('file','/testdir/testfile',wantlist=true) }}"
  - debug:
      msg: "{{ query('file','/testdir/testfile') }}"
```

```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  tasks:
  #file插件可以获取ansible主机中指定文件的内容
  - debug:
      msg: "{{ lookup('file','/testdir/testfile') }}"
  #env插件可以获取ansible主机中指定变量的值
  - debug:
      msg: "{{ lookup('env','PATH') }}"
  #first_found插件可以获取列表中第一个找到的文件
  #按照列表顺序在ansible主机中查找
  - debug:
      msg: "{{ lookup('first_found',looklist) }}"
    vars:
      looklist:
        - /testdir
        - /tmp/staging
  #当使用with_first_found时，可以在列表的最后添加- skip: true
  #表示如果列表中的所有文件都没有找到，则跳过当前任务,不会报错
  #当不确定有文件能够被匹配到时，推荐这种方式
  - debug:
      msg: "{{item}}"
    with_first_found:
      - /testdir1
      - /tmp/staging
      - skip: true
  #ini插件可以在ansible主机中的ini文件中查找对应key的值
  #如下示例表示从test.ini文件中的testA段落中查找testa1对应的值
  #测试文件/testdir/test.ini的内容如下(不包含注释符#号)
  #[testA]
  #testa1=Andy
  #testa2=Armand
  #
  #[testB]
  #testb1=Ben
  - debug:
      msg: "{{ lookup('ini','testa1 section=testA file=/testdir/test.ini') }}"
  #当未找到对应key时，默认返回空字符串，如果想要指定返回值，可以使用default选项,如下
  #msg: "{{ lookup('ini','test666 section=testA file=/testdir/test.ini default=notfound') }}"
  #可以使用正则表达式匹配对应的键名，需要设置re=true，表示开启正则支持,如下
  #msg: "{{ lookup('ini','testa[12] section=testA file=/testdir/test.ini re=true') }}"
  #ini插件除了可以从ini类型的文件中查找对应key，也可以从properties类型的文件中查找key
  #默认在操作的文件类型为ini，可以使用type指定properties类型，如下例所示
  #如下示例中，application.properties文件内容如下(不包含注释符#号)
  #http.port=8080
  #redis.no=0
  #imageCode = 1,2,3
  - debug:
      msg: "{{ lookup('ini','http.port type=properties file=/testdir/application.properties') }}"
  #dig插件可以获取指定域名的IP地址
  #此插件依赖dnspython库,可使用pip安装pip install dnspython
  #如果域名使用了CDN，可能返回多个地址
  - debug:
      msg: "{{ lookup('dig','www.baidu.com',wantlist=true) }}"
  #password插件可以生成随机的密码并保存在指定文件中
  - debug:
      msg: "{{ lookup('password','/tmp/testpasswdfile') }}"
```

# 过滤器

## 与字符串操作有关的过滤器
```
---
- hosts: testA
  remote_user: root
  vars:
    testvar: "abc123ABC 666"
    testvar1: "  abc  "
    testvar2: '123456789'
    testvar3: "1a2b,@#$%^&"
  tasks:
  - debug:
      #将字符串转换成纯大写
      msg: "{{ testvar | upper }}"
  - debug:
      #将字符串转换成纯小写
      msg: "{{ testvar | lower }}"
  - debug:
      #将字符串变成首字母大写,之后所有字母纯小写
      msg: "{{ testvar | capitalize }}"
  - debug:
      #将字符串反转
      msg: "{{ testvar | reverse }}"
  - debug:
      #返回字符串的第一个字符
      msg: "{{ testvar | first }}"
  - debug:
      #返回字符串的最后一个字符
      msg: "{{ testvar | last }}"
  - debug:
      #将字符串开头和结尾的空格去除
      msg: "{{ testvar1 | trim }}"
  - debug:
      #将字符串放在中间，并且设置字符串的长度为30，字符串两边用空格补齐30位长
      msg: "{{ testvar1 | center(width=30) }}"
  - debug:
      #返回字符串长度,length与count等效,可以写为count
      msg: "{{ testvar2 | length }}"
  - debug:
      #将字符串转换成列表，每个字符作为一个元素
      msg: "{{ testvar3 | list }}"
  - debug:
      #将字符串转换成列表，每个字符作为一个元素，并且随机打乱顺序
      #shuffle的字面意思为洗牌
      msg: "{{ testvar3 | shuffle }}"
  - debug:
      #将字符串转换成列表，每个字符作为一个元素，并且随机打乱顺序
      #在随机打乱顺序时，将ansible_date_time.epoch的值设置为随机种子
      #也可以使用其他值作为随机种子，ansible_date_time.epoch是facts信息
      msg: "{{ testvar3 | shuffle(seed=(ansible_date_time.epoch)) }}"
```

## 跟数字有关的过滤器
```
---
- hosts: testA
  remote_user: root
  vars:
    testvar4: -1
  tasks:
  - debug:
      #将对应的值转换成int类型
      #ansible中，字符串和整形不能直接计算，比如{{ 8+'8' }}会报错
      #所以，我们可以把一个值为数字的字符串转换成整形后再做计算
      msg: "{{ 8+('8' | int) }}"
  - debug:
      #将对应的值转换成int类型,如果无法转换,默认返回0
      #使用int(default=6)或者int(6)时，如果无法转换则返回指定值6
      msg: "{{ 'a' | int(default=6) }}"
  - debug:
      #将对应的值转换成浮点型，如果无法转换，默认返回'0.0'
      msg: "{{ '8' | float }}"
  - debug:
      #当对应的值无法被转换成浮点型时，则返回指定值’8.8‘
      msg: "{{ 'a' | float(8.88) }}"
  - debug:
      #获取对应数值的绝对值
      msg: "{{ testvar4 | abs }}"
  - debug:
      #四舍五入
      msg: "{{ 12.5 | round }}"
  - debug:
      #取小数点后五位
      msg: "{{ 3.1415926 | round(5) }}"
  - debug:
      #从0到100中随机返回一个随机数
      msg: "{{ 100 | random }}"
  - debug:
      #从5到10中随机返回一个随机数
      msg: "{{ 10 | random(start=5) }}"
  - debug:
      #从5到15中随机返回一个随机数,步长为3
      #步长为3的意思是返回的随机数只有可能是5、8、11、14中的一个
      msg: "{{ 15 | random(start=5,step=3) }}"
  - debug:
      #从0到15中随机返回一个随机数,这个随机数是5的倍数
      msg: "{{ 15 | random(step=5) }}"
  - debug:
      #从0到15中随机返回一个随机数，并将ansible_date_time.epoch的值设置为随机种子
      #也可以使用其他值作为随机种子，ansible_date_time.epoch是facts信息
      #seed参数从ansible2.3版本开始可用
      msg: "{{ 15 | random(seed=(ansible_date_time.epoch)) }}"
```

##  列表操作有关的过滤器
```
---
- hosts: testA
  remote_user: root
  vars:
    testvar7: [22,18,5,33,27,30]
    testvar8: [1,[7,2,[15,9]],3,5]
    testvar9: [1,'b',5]
    testvar10: [1,'A','b',['QQ','wechat'],'CdEf']
    testvar11: ['abc',1,3,'a',3,'1','abc']
    testvar12: ['abc',2,'a','b','a']
  tasks:
  - debug:
      #返回列表长度,length与count等效,可以写为count
      msg: "{{ testvar7 | length }}"
  - debug:
      #返回列表中的第一个值
      msg: "{{ testvar7 | first }}"
  - debug:
      #返回列表中的最后一个值
      msg: "{{ testvar7 | last }}"
  - debug:
      #返回列表中最小的值
      msg: "{{ testvar7 | min }}"
  - debug:
      #返回列表中最大的值
      msg: "{{ testvar7 | max }}"
  - debug:
      #将列表升序排序输出
      msg: "{{ testvar7 | sort }}"
  - debug:
      #将列表降序排序输出
      msg: "{{ testvar7 | sort(reverse=true) }}"
  - debug:
      #返回纯数字非嵌套列表中所有数字的和
      msg: "{{ testvar7 | sum }}"
  - debug:
      #如果列表中包含列表，那么使用flatten可以'拉平'嵌套的列表
      #2.5版本中可用,执行如下示例后查看效果
      msg: "{{ testvar8 | flatten }}"
  - debug:
      #如果列表中嵌套了列表，那么将第1层的嵌套列表‘拉平’
      #2.5版本中可用,执行如下示例后查看效果
      msg: "{{ testvar8 | flatten(levels=1) }}"
  - debug:
      #过滤器都是可以自由结合使用的，就好像linux命令中的管道符一样
      #如下，取出嵌套列表中的最大值
      msg: "{{ testvar8 | flatten | max }}"
  - debug:
      #将列表中的元素合并成一个字符串
      msg: "{{ testvar9 | join }}"
  - debug:
      #将列表中的元素合并成一个字符串,每个元素之间用指定的字符隔开
      msg: "{{ testvar9 | join(' , ') }}"
  - debug:
      #从列表中随机返回一个元素
      #对列表使用random过滤器时，不能使用start和step参数
      msg: "{{ testvar9 | random }}"
  - debug:
      #从列表中随机返回一个元素,并将ansible_date_time.epoch的值设置为随机种子
      #seed参数从ansible2.3版本开始可用
      msg: "{{ testvar9 | random(seed=(ansible_date_time.epoch)) }}"
  - debug:
      #随机打乱顺序列表中元素的顺序
      #shuffle的字面意思为洗牌
      msg: "{{ testvar9 | shuffle }}"
  - debug:
      #随机打乱顺序列表中元素的顺序
      #在随机打乱顺序时，将ansible_date_time.epoch的值设置为随机种子
      #seed参数从ansible2.3版本开始可用
      msg: "{{ testvar9 | shuffle(seed=(ansible_date_time.epoch)) }}"
  - debug:
      #将列表中的每个元素变成纯大写
      msg: "{{ testvar10 | upper }}"
  - debug:
      #将列表中的每个元素变成纯小写
      msg: "{{ testvar10 | lower }}"
  - debug:
      #去掉列表中重复的元素，重复的元素只留下一个
      msg: "{{ testvar11 | unique }}"
  - debug:
      #将两个列表合并，重复的元素只留下一个
      #也就是求两个列表的并集
      msg: "{{ testvar11 | union(testvar12) }}"
  - debug:
      #取出两个列表的交集，重复的元素只留下一个
      msg: "{{ testvar11 | intersect(testvar12) }}"
  - debug:
      #取出存在于testvar11列表中,但是不存在于testvar12列表中的元素
      #去重后重复的元素只留下一个
      #换句话说就是:两个列表的交集在列表1中的补集
      msg: "{{ testvar11 | difference(testvar12) }}"
  - debug:
      #取出两个列表中各自独有的元素,重复的元素只留下一个
      #即去除两个列表的交集，剩余的元素
      msg: "{{ testvar11 | symmetric_difference(testvar12) }}"
```

## 变量未操作时相关操作的过滤器
```
---
- hosts: testA
  remote_user: root
  gather_facts: no
  vars:
    testvar6: ''
  tasks:
  - debug:
      #如果变量没有定义，则临时返回一个指定的默认值
      #注：如果定义了变量，变量值为空字符串，则会输出空字符
      #default过滤器的别名是d
      msg: "{{ testvar5 | default('zsythink') }}"
  - debug:
      #如果变量的值是一个空字符串或者变量没有定义，则临时返回一个指定的默认值
      msg: "{{ testvar6 | default('zsythink',boolean=true) }}"
  - debug:
      #如果对应的变量未定义,则报出“Mandatory variable not defined.”错误，而不是报出默认错误
      msg: "{{ testvar5 | mandatory }}"
```

在目标主机上创建几个文件，这些文件大多数都不需要指定特定权限，只有个别的文件需要指定特定的权限
```
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    paths:
      - path: /tmp/test
        mode: '0444'
      - path: /tmp/foo
      - path: /tmp/bar
  tasks:
  - file: dest={{item.path}} state=touch mode={{item.mode}}
    with_items: "{{ paths }}"
    when: item.mode is defined
  - file: dest={{item.path}} state=touch
    with_items: "{{ paths }}"
    when: item.mode is undefined
```

上边一共循环了两遍，下边是精简写法
```
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    paths:
      - path: /tmp/test
        mode: '0444'
      - path: /tmp/foo
      - path: /tmp/bar
  tasks:
  - file: dest={{item.path}} state=touch mode={{item.mode | default(omit)}}     # 更加精简的写法，omit表示省略有就用，没有就用默认的
    with_items: "{{ paths }}"
```



Playbook模板（jinja2）
---
条件和循环
- {% for i in EXPR %}...{% endfor%}

判断
- {% if EXPR %}...{% elif EXPR %}...{% endif%} 作为条件判断
```
# cat test.yml 
---
- hosts: webservers
  vars:
   hello: Ansible
 
  tasks:
    - template: src=f.j2 dest=/tmp/f.j2


# cat f.j2 
{% set list=['one', 'two', 'three'] %}          #定义一个列表
 
{% for i in list %}
   {% if i == 'two' %}
       -> two
   {% elif loop.index == 3 %}
       -> 3
   {% else %}
       {{i}}                                    #打印所有变量
   {% endif %}
{% endfor %} 
 
{{ hello }}

#便利一个字典
{% set dict={'zhangsan': '26', 'lisi': '25'} %}
{% for key, value in dict.iteritems() %}
    {{key}} -> {{value}}
{% endfor %}
```

```
# 判断
{% if ansible_fqdn == "web01" %}
	echo "123"
{% elif ansible_fqdn == "web02" %}
	echo "456"
{% else %}
	echo "789"
{% endif %}

#循环
{% for i in range(1,10) %}
     server 172.16.1.{{i}};
{% endfor %}

{# COMMENT #} 表示注释
```
管理Nginx配置文件
```
# cat main.yml 
---
- hosts: webservers
  gather_facts: no
  vars:
    http_port: 80
    server_name: www.ctnrs.com
 
  tasks:
    - name: Copy nginx configuration file 
      template: src=site.conf.j2 dest=/etc/nginx/conf.d/www.ctnrs.com.conf
      notify: reload nginx
 
  handlers:
    - name: reload nginx
      service: name=nginx state=reloaded
 
# cat site.conf.j2 
{% set list=[10, 12, 13, 25, 31] %}
upstream {{server_name}} {
    {% for i in list %}
       server 192.168.1.{{i}}:80;
    {% endfor %}
}
server {
    listen       {{ http_port }};
    server_name  {{ server_name }};
 
    location / {
        proxy_pass http://{{server_name}};
    } 
}
```

循环inventory主机清单中的webserver组,将提取到的IP赋值给i变量.
```
upstream {{ server_name }} {
{% for i in groups['webserver'] %}
    server {{i}}:{{http_port}} weight=2;
{% endfor %}
```

roles
---
Roles目录结构
```
site.yml 
webservers.yml   
fooservers.yml   
roles/ 
   common/ 
     tasks/ 
     handlers/ 
     files/ 
     templates/ 
     vars/ 
     defaults/ 
     meta/ 
   webservers/ 
     tasks/ 
     defaults/ 
     meta/
```
- tasks - 包含角色要执行的主要任务列表
- handlers - 包含角色使用的处理程序
- defaults - 角色默认的变量
- vars - 角色其他的变量
- files - 角色部署时用到的文件
- templates - 角色部署时用到的模板
- meta - 角色定义的一些元数据


role中定定义变量变量
```
- hosts: webservers
  roles:
     - common
     - nginx
     - php
---
- hosts: webservers
  roles:
    - common
    - role: nginx              #指定角色
      vars:                    #定义变量
         dir: '/opt/a'
         app_port: 5000
    - role: php
      vars:
         dir: '/opt/b'
         app_port: 5001
---
- hosts: webservers
  roles:
    - role: common
      tags: ["common"]
    - role: nginx
      tags: ["nginx"]
    - role: php
      tags: ["php"]
```

```
mkdir /etc/ansible/roles/nginx/{tasks,vars,templates,files,handlers,meta,default} -pv
# cat /opt/playbook/httpd.yaml
- hosts: web
  remote_user: root
  roles:
   - nginx

# tree /etc/ansible/roles/nginx/
/etc/ansible/roles/nginx/
├── files
│    └── index.html
├── handlers
│    └── main.yaml
├── tasks
│    └── main.yml
├── templates
│    └── vhost1.conf.j2
└── vars
    └── main.yaml

# cat nginx/files/index.html
<h1>Vhost1</h1>

# cat nginx/handlers/main.yaml
- name: restart nginx
  service: name=nginx state=restarted

# cat nginx/tasks/main.yml
- name: install httpd
  yum: name=nginx state=latest
- name: install conf
  template: src=vhost1.conf.j2 dest=/etc/nginx/conf.d/vhost1.conf
  tags: conf
  notify: restart nginx
- name: install site home directory
  file: path={{ ngxroot }} state=directory
- name: install index page
  copy: src=index.html dest={{ ngxroot }}/
- name: start nginx
  service: name=nginx state=started

# cat nginx/templates/vhost1.conf.j2
server {
        listen 8080;
        server_name {{ ansible_fqdn }};
        location / {
                root "/ngxdata/vhost1";
        }
}

# cat nginx/vars/main.yaml
ngxroot: /ngxdata/vhost1
```  

include & import 区别
---
include*（动态）：在运行时导入
-	--list-tags，--list-tasks不会显示到输出
-	不能使用notify触发来自include*内处理程序名称（handlers）

import*（静态）：在Playbook解析时预先导入
-	不能与循环一起使用
-	将变量用于目标文件或角色名称时，不能使用inventory（主机/主机组等）中的变量

1.import_playbook
```
# cat main.yml
---
- import_playbook: webservers.yml
- import_playbook: databases.yml

# cat webservers.yml
---
- hosts: webservers
  tasks:
    - debug: msg="test webserver"


# cat database.yml
---
- hosts: webservers
  tasks:
    - debug: msg="test database"
```

2.include_tasks和import_tasks
```
# cat main.yml
---
- hosts: webservers
  gather_facts: no
  tasks:
  - include_tasks: task1.yml
    vars:
      user: zhangsan
  - import_tasks: task2.yml
    vars:
      user: lisi

# cat task1.yml
---
- name: task1
  debug: msg="hello {{user}}"

# cat task2.yml
---
- name: task2
  debug: msg="hello {{user}}"
```

3、include
```
# cat a_project.yml 
- hosts: webserver
  tasks:
    - name: A Project command
      command: echo "A"

    - name: Restart httpd
      include: restart_httpd.yml
```

错误处理changed_when
---
```
1.强制调用handlers
# cat test.yml 
- hosts: webserver
  force_handlers: yes #强制调用handlers

  tasks:
    - name: Touch File
      file: path=/tmp/bgx_handlers state=touch
      notify: Restart Httpd Server

    - name: Installed Packages
      yum: name=sb state=latest

  handlers:
    - name: Restart Httpd Server
      service: name=httpd state=restarted

2.关闭changed的状态(确定该tasks不会对被控端做任何的修改和变更.)
# cat test.yml 
- hosts: webserver
  tasks:
    - name: Installed Httpd Server
      yum: name=httpd state=present

    - name: Service Httpd Server
      service: name=httpd state=started

    - name: Check Httpd Server
      shell: ps aux|grep httpd
      register: check_httpd
      changed_when: false

    - name: OutPut Variables
      debug:
        msg: "{{ check_httpd.stdout_lines }}"


3、使用changed_when检查tasks任务返回的结果
# cat test.yml 
- hosts: webserver
  tasks: 

    - name: Installed Nginx Server
      yum: name=nginx state=present

    - name: Configure Nginx Server
      copy: src=./nginx.conf.j2 dest=/etc/nginx/nginx.conf
      notify: Restart Nginx Server

    - name: Check Nginx Configure Status
      command: /usr/sbin/nginx -t
      register: check_nginx
      changed_when: 
       - ( check_nginx.stdout.find('successful'))
       - false
	   
    - name: Service Nginx Server
      service: name=nginx state=started 


  handlers:
    - name: Restart Nginx Server
      service: name=nginx state=restarted
```

自动部署Nginx
```
- hosts: webservers
  vars:
    hello: Ansible
 
  tasks:
  - name: Add repo 
    yum_repository:
      name: nginx
      description: nginx repo
      baseurl: http://nginx.org/packages/centos/7/$basearch/
      gpgcheck: no
      enabled: 1
  - name: Install nginx
    yum:
      name: nginx
      state: latest
  - name: Copy nginx configuration file
    copy:
      src: ./site.conf
      dest: /etc/nginx/conf.d/site.conf
  - name: Start nginx
    service:
      name: nginx
      state: started
  - name: Create wwwroot directory
    file:
      dest: /var/www/html
      state: directory
  - name: Create test page index.html
    shell: echo "hello {{hello}}" > /var/www/html/index.html


# site.conf
server {
    listen 80;
    server_name www.ctnrs.com;
    location / {
        root   /var/www/html;
        index  index.html;
    }
}
```

galaxy
---
ansible-playbook代码托管网址  
https://galaxy.ansible.com/home

```
下载代码到默认目录/root/.ansible/roles
ansible-galaxy install geerlingguy.nginx
```

自动部署Tomcat
```
---
hosts: webservers 
  gather_facts: no
  vars:
    tomcat_version: 8.5.34
    tomcat_install_dir: /usr/local
  
  tasks:
    - name: Install jdk1.8
      yum: name=java-1.8.0-openjdk state=present
 
    - name: Download tomcat
      get_url: url=http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v{{ tomcat_version }}/bin/apache-tomcat-{{ tomcat_version }}.tar.gz dest=/tmp
 
    - name: Unarchive tomcat-{{ tomcat_version }}.tar.gz
      unarchive:
        src: /tmp/apache-tomcat-{{ tomcat_version }}.tar.gz 
        dest: "{{ tomcat_install_dir }}"
        copy: no 
 
    - name: Start tomcat 
      shell: cd {{ tomcat_install_dir }} &&
             mv apache-tomcat-{{ tomcat_version }} tomcat8 &&
             cd tomcat8/bin && nohup ./startup.sh &
```


自动化运维之磁盘的分区及挂载
---

```
$ cat part.yml 
---
- hosts: web
  tasks:
    - shell: test -b /dev/sda               #shell模块判断磁盘设备是否存在
      register: result
      ignore_errors: True

    - debug:
        msg: "/dev/sda not exists"          #不存在报错
      when: result.rc != 0

    - name: create partations
      block:  
        - name: Create a new primary partition with a size of 1GiB
          parted:                           #磁盘分区（parted模块）
            device: /dev/sda
            number: 1
            state: present
            part_end: 1GiB

        - name: Create a ext4 filesystem on /dev/sda1 
          filesystem:                       #磁盘格式化（filesystem模块）
            fstype: ext4
            dev: /dev/sda1

        - name: Mount up device
          mount:                            #文件系统的挂载（mount模块）
            path: /media
            src: /dev/sda1
            fstype: ext4
            opts: noatime
            state: mounted

      when: result.rc == 0  ##存在创建

```
