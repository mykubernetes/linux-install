# absible-playbook常用执行语法

## 一、运行ansible-playbook语法

### 1、检查语法是否正确
```
ansible-playbook --syntax-checak first.yaml
```

### 2、不实际运行测试
```
ansible-playbook -C first.yaml
```

### 3、检查运行的主机
```
ansible-playbook --list-hosts first.yaml
```

### 4、运行加密playbook文件时提示输入密码
```
ansible-playbook --ask-vault-pass example.yaml
```

### 5、指定要读取的Inventory清单文件
```
ansible-playbook example.yaml -i inventory
ansible-playbook example.yaml --inventory-file=inventory
```

### 6、列出所有tags
```
ansible-playbook example.yaml --list-tags
```

### 7、列出所有即将被执行的任务
```
ansible-playbook example.yaml --list-tasks  
```

### 8、指定tags
```
ansible-playbook example.yaml --tags "configuration,install"
```

### 9、跳过tags
```
ansible-playbook example.yaml --skip-tags "install"
```

### 10、并行任务数。FORKS被指定为一个整数,默认是5
```
ansible-playbook example.yaml -f 5
ansible-playbook example.yaml --forks=5
```

### 11、指定运行的主机
```
ansible-playbook example.yaml --limit node01
```

### 12、查看主机变量
```
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

## 二、tags的用法

### 1、配置多个tags语法
```
语法一：
tags:
 - testtag
 - t1
 
语法二：
tags: tag1,t1
 
语法三：
tags: ['tagtest','t2']
```

### 2、编写一个剧本设置标签测试

1）编写剧本
```
---
- hosts: all
  remote_user: root
  tasks:
  - name: task1
    file:
      path: /testdir/t1
      state: touch
    tags: t1
  - name: task2
    file: path=/testdir/t2
          state=touch
    tags: t2
  - name: task3
    file: path=/testdir/t3
          state=touch
    tags: t3
```

2）执行t2标签
```
# ansible-playbook test2.yml --tags=t2

PLAY [all] *********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [192.168.101.69]

TASK [task2] *******************************************************************************************************************************************
changed: [192.168.101.69]

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=2    changed=1    unreachable=0    failed=0 
```

3）跳过t2标签
```
# ansible-playbook test2.yml --skip-tags=t2

PLAY [all] *********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [192.168.101.69]

TASK [task1] *******************************************************************************************************************************************
changed: [192.168.101.69]

TASK [task3] *******************************************************************************************************************************************
changed: [192.168.101.69]

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=3    changed=2    unreachable=0    failed=0   
```

### 3、不同任务可以使用相同的标签

1）每个任务都配置相同标签
```
---
- hosts: all
  remote_user: root
  tasks:
  - name: install httpd package
    tags: httpd,package
    yum:
      name=httpd
      state=latest
 
  - name: start up httpd service
    tags: httpd,service
    service:
      name: httpd
      state: started
```

2）同上有共同的标签httpd,可以吧标签写到play中为共同标签
```
---
- hosts: all
  remote_user: root
  tags: httpd                         # 设置共同的标签
  tasks:
  - name: install httpd package
    tags: ['package']
    yum:
      name=httpd
      state=latest
 
  - name: start up httpd service
    tags:
      - service
    service:
      name: httpd
      state: started
```

3）执行多个标签
```
# ansible-playbook --tags package,service   test2.yml 

PLAY [all] *********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [192.168.101.69]

TASK [install httpd package] ***************************************************************************************************************************
changed: [192.168.101.69]

TASK [start up httpd service] **************************************************************************************************************************
changed: [192.168.101.69]

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=3    changed=2    unreachable=0    failed=0   
```

4）查看标签
```
# ansible-playbook --list-tags test2.yml

playbook: test2.yml

  play #1 (all): all	TAGS: [httpd]
      TASK TAGS: [httpd, package, service]

playbook: test2.yml

  play #1 (all): all	TAGS: [httpd]
      TASK TAGS: [httpd, package, service]
```

### 4、ansible预置了5个特殊tag
- always
- never(2.5版本中新加入的特殊tag)
- tagged
- untagged
- all

1)编写一个剧本，把任务的tags的值指定为always时，那么这个任务就总是会被执行。除非你使用`--skip-tags`选项明确指定不执行对应的任务
```
---
- hosts: all
  remote_user: root
  tasks:
  - name: task1
    file:
      path: /testdir/t1
      state: touch
    tags:
      - t1
  - name: task2
    file: path=/testdir/t2
          state=touch
    tags: ['t2']
  - name: task3
    file: path=/testdir/t3
          state=touch
    tags: t3,always
```

2)每次运行都会执行always标签
```
# ansible-playbook --tags t1   test2.yml 

PLAY [all] *********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [192.168.101.69]

TASK [task1] *******************************************************************************************************************************************
changed: [192.168.101.69]

TASK [task3] *******************************************************************************************************************************************
changed: [192.168.101.69]

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=3    changed=2    unreachable=0    failed=0   
```

3)使用`--skip-tags`选项明确指定跳过always标签
```
# ansible-playbook --skip-tags always  test2.yml      # 范围太广
# ansible-playbook --skip-tags t3  test2.yml          # 推荐 

PLAY [all] *********************************************************************************************************************************************

TASK [task1] *******************************************************************************************************************************************
changed: [192.168.101.69]

TASK [task2] *******************************************************************************************************************************************
changed: [192.168.101.69]

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=2    changed=2    unreachable=0    failed=0 
```

4)never的作用应该与always正好相反
```
ansible-playbook --tags never test2.yml
```

5）只执行有标签的任务，没有任何标签的任务不会被执行
```
ansible-playbook --tags tagged test2.yml
```

6)跳过包含标签的任务，即使对应的任务包含always标签，也会被跳过
```
ansible-playbook --skip-tags tagged test2.yml
```

7)只执行没有标签的任务，但是如果某些任务包含always标签，那么这些任务也会被执行
```
ansible-playbook --tags untagged test2.yml
```

7)跳过没有标签的任务
```
ansible-playbook --skip-tags untagged test2.yml
```

8)特殊标签all表示所有任务会被执行，不用指定，默认情况下就是使用这个标签

## 三、在playbook中实现交互

### 1、交互是输入变量
```
- hosts: all
  remote_user: root
  vars_prompt:
    - name: "you_name"              #定义的变量名
      prompt: "what is you name?"   #提示用户输入的不回显
    - name: "you_age"               #定义的变量名
      prompt: "how old are you?"
  tasks:
    - name: output vars
      debug:
        msg: "your name is {{ you_name }},you are {{ you_age }} years old"

# 执行命令结果
# ansible-playbook test.yml 
what is you name?: 
how old are you?: 

PLAY [hello debug] *************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [192.168.101.69]

TASK [hello debug] *************************************************************************************************************************************
ok: [192.168.101.69] => {
    "msg": "your name is huy,you are 18 years old"
}

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=2    changed=0    unreachable=0    failed=0  
```

### 2、设置输入时的默认值
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


# 执行命令结果
# ansible-playbook test.yml 
please choose 
 A: solA
 B: solB
 C: solC
 [A]: b    

PLAY [all] *********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [192.168.101.69]

TASK [out vars] ****************************************************************************************************************************************
ok: [192.168.101.69] => {
    "msg": "the so is b"
}

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=2    changed=0    unreachable=0    failed=0
```

### 3、confirm（输入密码时，再确认一次）
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
        name: "{{you_name}}"
        password: "{{you_pass}}"   # 输入的密码必须是经过加密的



# ansible-playbook -i ../host test.yml 
what is you name?: 
what is your password?: 
confirm what is your password?: 

PLAY [all] *********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [192.168.101.69]

TASK [create user] *************************************************************************************************************************************
changed: [192.168.101.69]

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=2    changed=1    unreachable=0    failed=0   
```
