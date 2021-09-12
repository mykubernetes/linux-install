ansible变量
===

# ansible 内置变量

## 1、通过命令获取变量
```
# ansible node01 -m setup

# ansible 172.16.1.8 -m setup -a "filter=ansible_memtotal_mb"
172.16.1.8 | SUCCESS => {
    "ansible_facts": {
        "ansible_memtotal_mb": 1996, 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}

# ansible 172.16.1.8 -m setup -a "filter=ansible_default_ipv4"

# cat test.yml
- hosts: node01
  remote_user: root
  tasks:
   - name: copy file
     copy: content={{ ansible_env }} dest=/tmp/ansible.env
```
- `ansible_all_ipv4_addresses`表示远程主机中的所有ipv4地址
- `ansible_distribution`表示远程主机的系统发行版
- `ansible_distribution_version`表示远程主机的系统版本号
- `ansible_ens35`表示远程主机ens35网卡的相关信息
- `ansible_memory_mb`表示远程主机的内存配置信息


## 2、ansible中的内置变量

- Ansible内置了一些变量以方便主机之间相互调用各自的变量

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


# 外置变量

## 1、命令行传递变量
```
#  ansible-playbook -e pkgname=memcached  test.yaml
# cat test.yaml
- hosts: node01
  remote_user: root
  tasks:
   - name: install package {{ pkgname }}
     yum: name={{ pkgname }} state=latest
```


## 2、playbook一次性传入多个变量，变量之间用空格隔开
```
ansible-playbook test.yml --extra-vars "pass_var=cmdline pass var"
ansible-playbook test.yml --extra-vars 'pass_var="redhat" num_var="westos"'
ansible-playbook test.yml -e '{"pass_var":"test","num_var":"test1"}'
ansible-playbook test.yml -e '{"countlist":["one","two","three","four"]}'
```

命令行通过文件的方式传递变量
```
# cat /testdir/ansible/testvar
testvar: testvarinfile
countlist:
- one
- two
- three
- four


---
- hosts: test70
  remote_user: root
  tasks:
  - name: "Passing Variables On The Command Line"
    debug:
      msg: "{{testvar}} {{countlist[0]}}"

ansible-playbook test.yml -e "@/testdir/ansible/testvar"
```


## 3、在playbook文件中的play使用变量

### 定义多个变量语法
```
vars:
  testvar1: testfile
  testvar2: testfile2
  
vars:
  - testvar1: testfile
  - testvar2: testfile2

vars:
  nginx:
    conf80: /etc/nginx/conf.d/80.conf
    conf8080: /etc/nginx/conf.d/8080.conf
```

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

## 4、以类似”属性”的方式定义变量
```
---
- hosts: test70
  remote_user: root
  vars:
    nginx:
      conf80: /etc/nginx/conf.d/80.conf
      conf8080: /etc/nginx/conf.d/8080.conf
  tasks:
  - name: task1
    file:
      path: "{{nginx.conf80}}"
      state: touch
  - name: task2
    file:
      path: "{{nginx.conf8080}}"
      state: touch
```

## 5、定义一个变量文件,然后使用playbook进行调用
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

## 6、`vars_files`也可以引入多个变量文件，每个被引入的文件都需要以`- `开头
```
---
- hosts: node02
  remote_user: root
  vars_files:
  - /testdir/ansible/nginx_vars.yml
  - /testdir/ansible/other_vars.yml
  tasks:
  - name: task1
    file:
      path={{nginx.conf80}}
      state=touch
  - name: task2
    file:
      path={{nginx['conf8080']}}
      state=touch
```


## 7、`vars`关键字和`vars_files`关键字可以同时使用
```
---
- hosts: node02
  remote_user: root
  vars:
  - conf90: /etc/nginx/conf.d/90.conf
  vars_files:
  - /testdir/ansible/nginx_vars.yml
  - /testdir/ansible/other_vars.yml
  tasks:
  - name: task1
    file:
      path={{nginx.conf80}}
      state=touch
  - name: task2
    file:
      path={{nginx['conf8080']}}
      state=touch

```

## 8、ansible默认会去目标主机的/etc/ansible/facts.d目录下查找主机中的自定义信息

```
cat  /etc/ansible/facts.d/testinfo.fact
# INI格式
# cat testinfo.fact
[testmsg]
msg1=This is the first custom test message
msg2=This is the second custom test message
```

```
#json格式
{
   "testmsg":{
       "msg1":"This is the first custom test message",
       "msg2":"This is the second custom test message"
   }
}
```

```
# 以通过ansible_local关键字过滤远程主机的local facts信息
ansible test70 -m setup -a "filter=ansible_local"

test70 | SUCCESS => {
   "ansible_facts": {
       "ansible_local": {
           "testinfo": {
               "testmsg": {
                   "msg1": "This is the first custom test message",
                   "msg2": "This is the second custom test message"
               }
           }
       }
   },
   "changed": false
}
```

## 9、debug模块的获取变量信息

1)通过debug模块直接输出变量信息需要使用var参数
```
---
- hosts: test70
  remote_user: root
  vars:
    testvar: value of test variable
  tasks:
  - name: debug demo
    debug:
      var: testvar
```

2)使用debug的msg参数时可以引用变量的值
```
---
- hosts: test70
  remote_user: root
  vars:
    testvar: testv
  tasks:
  - name: debug demo
    debug:
      msg: "value of testvar is : {{testvar}}"
```

3)通过`ansible_memory_mb`关键字获取远程主机的内存信息
```
---
- hosts: test70
  remote_user: root
  tasks:
  - name: debug demo
    debug:
      msg: "Remote host memory information: {{ansible_memory_mb}}"
```

```
语法一示例：
debug:
     msg: "Remote host memory information : {{ansible_memory_mb.real}}"
语法二示例：
debug:
     msg: "Remote host memory information : {{ansible_memory_mb['real']}}"
```

## 10、注册变量（register）

| name | description | returned | type |
|------|-------------|----------|------|
| start | 命令执行开始时间 | always | string |
| end | 命令执行结束时间 | always | string |
| delta | 命令执行时间 | always | string |
| stdout | 命令的标准输出 | always | string |
| stderr | 命令的错误输出 | always | string |
| cmd | 命令内容 | always | string |
| rc | 命令返回值（0代表OK） | always | int |
| msg | changed | always | boolean |

```
ok: [192.168.101.69] => {
    "msg": {
        "changed": true, 
        "cmd": [
            "date", 
            "+%F_%T"
        ], 
        "delta": "0:00:00.002093",                           # 命令执行时间 
        "end": "2021-09-12 04:03:00.591410",                 # 命令执行结束时间
        "failed": false,                                     # 命令是否执行失败
        "rc": 0,                                             # 命令返回值（0代表OK）
        "start": "2021-09-12 04:03:00.589317",               # 命令执行开始时间
        "stderr": "",                                        # 命令的错误输出
        "stderr_lines": [], 
        "stdout": "2021-09-12_04:03:00",                     # 命令的标准输出
        "stdout_lines": [
            "2021-09-12_04:03:00"
        ]
    }
}
```

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
- 注册变量也可以在之后的play操作同一主机时被调用到

```
---
- hosts: test70
  remote_user: root
  vars:
    testvar3: tv3
  tasks:
  - shell: "echo tv4"
    register: testvar4
  - debug:
      msg: "{{testvar3}} -- {{testvar4.stdout}}"
 
- hosts: test70
  remote_user: root
  tasks:
  - name: other play get testvar4
    debug:
      msg: "{{testvar4.stdout}}"
  - name: other play get testvar3
    debug:
      msg: "{{testvar3}}"
```

## 11、set_fact是一个模块，通过set_fact模块在tasks中定义变量
```
---
- hosts: test70
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
```
- 通过set_fact模块创建的变量还有一个特殊性，通过set_fact创建的变量就像主机上的facts信息一样，可以在之后的play中被引用

```
---
- hosts: test70
  remote_user: root
  vars:
    testvar1: tv1
  tasks:
  - set_fact:
      testvar2: tv2
  - debug:
      msg: "{{testvar1}} ----- {{testvar2}}"
 
- hosts: test70
  remote_user: root
  tasks:
  - name: other play get testvar2
    debug:
      msg: "{{testvar2}}"
  - name: other play get testvar1
    debug:
      msg: "{{testvar1}}"
```
