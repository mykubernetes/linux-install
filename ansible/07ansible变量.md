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
ansible-playbook test.yml  --extra-vars 'pass_var="redhat" num_var="westos"'
ansible-playbook test.yml -e '{"pass_var":"test","num_var":"test1"}'
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






































































