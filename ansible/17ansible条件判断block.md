# block用法

- `block`将多个任务整合成一个`块`，当做一个整体，当条件成立时，则执行这个块中的所有任务

1、如果判断条件成立，则执行的一个任务，如果想执行多个任务可以使用block模块解决
```
---
- hosts: web
  remote_user: root
  tasks:
  - debug:
      msg: "task1 not in block"
  - block:
      - debug:
          msg: "task2 in block1"
      - debug:
          msg: "task3 in block1"
    when: 2 > 1
```

# block的错误处理功能，在A任务执行失败时执行B任务，如果A任务执行成功，则无需执行B任务

1、借助failed实现上一个命令执行失败则运行
```
---
- hosts: test70
  remote_user: root
  tasks:
  - shell: 'ls /ooo'
    register: return_value
    ignore_errors: true
  - debug:
      msg: "I cought an error"
    when: return_value is failed
```

2、block中的内容执行失败后，执行rescue中的内容
```
---
- host: web
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
- hosts: web
  remote_user: root
  tasks:
  - block:
      - shell: 'ls /opt'
      - shell: 'ls /testdir'
      - shell: 'ls /c'
    rescue:
      - debug:
          msg: 'I caught an error'
      - debug:
          msg: "i cought an error2"
```
- rescue 可以写多个任务

4、无论block中的任务执行成功还是失败，always中的任务都会被执行
```
---
- host: web
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
