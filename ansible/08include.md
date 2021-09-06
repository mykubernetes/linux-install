include
===

# 一、在task中通过include引入文件

1、分别用于安装LAMP环境和LNMP环境，编写playbook,发现有共同的剧本mysql和php
```
# cat lamp.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - yum:
      name: mysql
      state: present
  - yum:
      name: php-fpm
      state: present
  - yum:
      name: httpd
      state: present
 
# cat lnmp.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - yum:
      name: mysql
      state: present
  - yum:
      name: php-fpm
      state: present
  - yum:
      name: nginx
      state: present
```

2、把mysql和php部分的任务提取到install_MysqlAndPhp.yml文件中，可以重复利用
```
# cat install_MysqlAndPhp.yml
- yum:
    name: mysql
    state: present
- yum:
    name: php-fpm
    state: present
```

3、通过include模块引入需要重复利用的剧本
```
# cat lamp.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: install_MysqlAndPhp.yml
  - yum:
      name: httpd
      state: present
 
# cat lnmp.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: install_MysqlAndPhp.yml
  - yum:
      name: nginx
      state: present
```

# 二、在handlers中使用include

```
# cat test_include.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - file:
     path: /opt/ttt
     state: touch
    notify: test include handlers
 
  handlers:
  - name: test include handlers
    include: include_handler.yml
 
# cat include_handler.yml
- debug:
    msg: "task1 of handlers"
- debug:
    msg: "task2 of handlers"
- debug:
    msg: "task3 of handlers"
```


# 三、`include`不仅能够引用任务列表，还能够引用playbook

```
# cat lamp.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: install_MysqlAndPhp.yml
  - yum:
      name: httpd
      state: present
 
- include: lnmp.yml
```

# 四、在使用`函数`或者`方法`时，可能会需要传入一些`参数`，以便更加灵活的根据实际情况作出对应的处理

1）在tasks中直接写入变量
```
# cat test_include1.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: in.yml
     test_var1=hello
     test_var2=test
 
# cat in.yml
- debug:
    msg: "{{ test_var1 }}"
- debug:
    msg: "{{ test_var2 }}"
```
- 在in.yml文件中一共有两个debug任务，这两个任务分别需要两个变量，在in.yml中并未定义任何变量，而是在test_include1.yml中使用include模块引用in.yml时，传入了两个参数



2）通过vars关键字，以key: value变量的方式传入参数变量
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: in.yml
    vars:
     test_var1: hello
     test_var2: test

# cat in.yml
- debug:
    msg: "{{ test_var1 }}"
- debug:
    msg: "{{ test_var2 }}"
```

3)vars关键字也能够传入结构稍微复杂的变量数据，以便在包含的文件中使用
```
# cat test_include1.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: in.yml
    vars:
     users:
      bob:
        gender: male
      lucy:
        gender: female
         
# cat in.yml
- debug:
    msg: "{{ item.key}} is {{ item.value.gender }}"
  loop: "{{ users | dict2items }}"
```

# 五、在include中也可以使用tags进行打标签
```
# cat test_include1.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: in1.yml
    tags: t1
  - include: in2.yml
    tags: t2
 
# cat in1.yml
- debug:
    msg: "task1 in in1.yml"
- debug:
    msg: "task2 in in1.yml"
 
# cat in2.yml
- debug:
    msg: "task1 in in2.yml"
- debug:
    msg: "task2 in in2.yml"
```

# 六、对`include`添加条件判断，还可以对`include`进行循环操作

```
# cat test_include1.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: in3.yml
    when: 2 > 1
  - include: in3.yml
    loop:
    - 1
    - 2
    - 3
 
# cat in3.yml
- debug:
    msg: "task1 in in3.yml"
- debug:
    msg: "task2 in in3.yml"
```

# 七、可以对`include`进行循环操作

```
# cat A.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: B.yml
    loop:
    - 1
    - 2
    - 3
 
# cat B.yml
- debug:
    msg: "{{item}}--task1 in B.yml"
- debug:
    msg: "{{item}}--task2 in B.yml"
```

```
# ansible-playbook A.yml
 
PLAY [test70] *************************************************
 
TASK [include] *************************************************
included: /testdir/ansible/B.yml for test70
included: /testdir/ansible/B.yml for test70
included: /testdir/ansible/B.yml for test70
 
TASK [debug] *************************************************
ok: [test70] => {
    "msg": "1--task1 in B.yml"
}
 
TASK [debug] *************************************************
ok: [test70] => {
    "msg": "1--task2 in B.yml"
}
 
TASK [debug] *************************************************
ok: [test70] => {
    "msg": "2--task1 in B.yml"
}
 
TASK [debug] *************************************************
ok: [test70] => {
    "msg": "2--task2 in B.yml"
}
 
TASK [debug] *************************************************
ok: [test70] => {
    "msg": "3--task1 in B.yml"
}
 
TASK [debug] *************************************************
ok: [test70] => {
    "msg": "3--task2 in B.yml"
}
 
PLAY RECAP *************************************************
test70                     : ok=9    changed=0    unreachable=0    failed=0
```

# 八、B.yml中循环调用了debug模块，而在A.yml中，又循环的调用了B.yml，当出现这种”双层循环”的情况时，当出现上述”双层循环”的情况时，内层item的信息为B.yml中的loop列表，而不是A.yml中的loop列表
```
# cat A.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: B.yml
    loop:
    - 1
    - 2
 
# cat B.yml
- debug:
    msg: "{{item}}--task in B.yml"
  loop:
  - a
  - b
  - c
```

# 九、想要在B文件中获取到A文件中的item信息，使用loop_control选项
```
# cat A.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - include: B.yml
    loop:
    - 1
    - 2
    loop_control:
      loop_var: outer_item
 
# cat B.yml
- debug:
    msg: "{{outer_item}}--{{item}}--task in B.yml"
  loop:
  - a
  - b
  - c
```

```
# ansible-playbook A.yml
 
PLAY [test70] *************************************************
 
TASK [include] *************************************************
included: /testdir/ansible/B.yml for test70
included: /testdir/ansible/B.yml for test70
 
TASK [debug] *************************************************
ok: [test70] => (item=a) => {
    "msg": "1--a--task in B.yml"
}
ok: [test70] => (item=b) => {
    "msg": "1--b--task in B.yml"
}
ok: [test70] => (item=c) => {
    "msg": "1--c--task in B.yml"
}
 
TASK [debug] *************************************************
ok: [test70] => (item=a) => {
    "msg": "2--a--task in B.yml"
}
ok: [test70] => (item=b) => {
    "msg": "2--b--task in B.yml"
}
ok: [test70] => (item=c) => {
    "msg": "2--c--task in B.yml"
}
 
PLAY RECAP *************************************************
test70                     : ok=4    changed=0    unreachable=0    failed=0
```



