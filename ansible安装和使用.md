ansible安装和使用
===========

最佳实践：https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html  
示例参考：https://github.com/ansible/ansible-examples  
http://www.zsythink.net/archives/category/%e8%bf%90%e7%bb%b4%e7%9b%b8%e5%85%b3/ansible/

http://www.luyixian.cn/news_show_361949.aspx

1、安装ansible
--
```
# yum install -y ansible

# vim /etc/ansible/ansible.cfg 
[defaults]
inventory = /etc/ansible/hosts                             #ansible inventory文件路径
remote_tmp = /tmp/.ansible/tmp                             #远程主机脚本临时存放目录
local_tmp = ~/.ansible/tmp                                 #本机的临时执行目录
forks = 5                                                  #并发数
become = root
sudo_user = root                                           #默认sudo用户
remote_port  = 22
host_key_checking = False                                  #避免ssh的时候输入yes
roles_path = /etc/ansible/roles:/usr/share/ansible/roles   #role路径
ask_sudo_pass = True                                       #每次执行是否询问sudo的ssh密码
ask_pass = True                                            #每次执行是否询问ssh密码
host_key_checking = False                                  #跳过检查主机指纹
timeout = 10
log_path = /var/log/ansible.log
private_key_file = /root/.ssh/id_rsa

[privilege_escalation]                                     #如果是普通用户则需要配置提权
become=True
become_method=sudo
become_user=root
become_ask_pass=False
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
- present	将挂载信息写入/etc/fstab
- unmounted	卸载临时,不会清理/etc/fstab
- mounted	先挂载,在将挂载信息/etc/fstab		
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

```


基本语法  

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
    register: shellreturn
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

invertory自带变量和自定义变量
---
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


判断循环
---
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
	
	
2、为所有的web主机名添加nginx仓库，其余的都跳过添加
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

3、主机名称是web*或主机名称是lb*的则添加这个nginx源
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
      when: ( ansible_fqdn is match ("web*")) or 
	    ( ansible_fqdn is match ("lb*"))
可以用or 或者and 做判断

4、根据命令执行的结果进行判断
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
```  
- is match 匹配到的
- is not match 没有匹配到的


2、with_items、with_list、loop迭代,ansible2.5版本之后将with_items、with_list迁移至loop
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
  
2、定义变量方式循环安装软件包
# cat vars.yml
- hosts: web
  tasks:
    - name: Installed Httpd Mariadb Package
      yum: name={{ pack }} state=latest
      vars:
       pack:
         - httpd
         - mariadb-server	

3、使用变量字典循环方式批量创建用户
- name: with_items
  user: name={{itme.name}} groups={{item.groups}} state=present
  with_items:
    - {name: 'zhangsan', groups: nginx}
    - {name: 'lisi', groups: nginx}


4、使用变量字典循环方式批量拷贝文件
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

错误忽略ignore_errors
---
```
# cat test.yml 
- hosts: webserver
  tasks:
     - name: Command 
       command: /bin/false
       ignore_errors: yes

     - name: Create File 
       file: path=/tmp/tttt state=touch
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
