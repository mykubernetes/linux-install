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
ansible-playbook --list-host first.yaml
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

### 6、列出执行匹配到的主机，但并不会执行任何动作。
```
ansible-playbook example.yaml --list-hosts
```

### 7、列出所有tags
```
ansible-playbook example.yaml --list-tags
```

### 8、列出所有即将被执行的任务
```
ansible-playbook example.yaml --list-tasks  
```

### 9、指定tags
```
ansible-playbook example.yaml --tags "configuration,install"
```

### 10、跳过tags
```
ansible-playbook example.yaml --skip-tags "install"
```

### 11、并行任务数。FORKS被指定为一个整数,默认是5
```
ansible-playbook example.yaml -f 5
ansible-playbook example.yaml --forks=5
```

### 12、指定运行的主机
```
ansible-playbook example.yaml --limit node01
```

### 13、查看主机变量
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
