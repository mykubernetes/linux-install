include & import 区别
===

### include*（动态）：在运行时导入

- --list-tags，--list-tasks不会显示到输出
- 不能使用notify触发来自include*内处理程序名称（handlers）

### import*（静态）：在Playbook解析时预先导入

- 不能与循环一起使用
- 将变量用于目标文件或角色名称时，不能使用inventory（主机/主机组等）中的变量

# include_tasks

1)使用`include_tasks`关键字代替`include`关键字
```
# cat main.yml
- hosts: demo2.example.com
  tasks:
    - debug:
        msg: "start tasks"
    - include_tasks: tasks/host.yml
    - include_tasks: tasks/dns.yml
    - include_tasks: tasks/nginx.yml
    - debug:
        msg: "执行结束"
  handlers:
    - include_tasks: tasks/handlers.yml


# cat tasks/host.yml
- debug:
    msg: "task1 in in.yml"
- debug:
    msg: "task2 in in.yml"

 # cat tasks/dns.yml
- debug:
    msg: "task1 in in.yml"
- debug:
    msg: "task2 in in.yml"

# cat tasks/nginx.yml
- debug:
    msg: "task1 in in.yml"
- debug:
    msg: "task2 in in.yml"
    
# cat tasks/handlers.yml
- debug:
    msg: "task1 in in.yml"
- debug:
    msg: "task2 in in.yml"
```

2)从2.7版本开始，`include_tasks`模块加入了file参数和apply参数
```
# cat main.yml
- hosts: demo2.example.com
  tasks:
    - debug:
        msg: "start tasks"
    - include_tasks:
        file: tasks/host.yml
    - include_tasks:
        file: tasks/dns.yml
    - include_tasks:
        file: tasks/nginx.yml
    - debug:
        msg: "执行结束"
  handlers:
    - include_tasks:
        file: tasks/handlers.yml


# cat intest.yml

- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "test task1"
  - include_tasks:
      file: in.yml
    tags: t1
  - debug:
      msg: "test task2"
```

# include_tasks 使用 tags

如果为include添加tags，那么tags是对include中的所有任务生效的，所以当调用include的tag时，include中的所有任务都会执行

但是对include_tasks添加tag，只会对include_tasks本身生效，include_tasks中的所有任务都不生效

```
- hosts: demo2.example.com
  tasks:
    - debug:
        msg: "start tasks"
    - include_tasks: 
        file:  tasks/host.yml
      tags: host

    - include_tasks: 
        file: tasks/dns.yml
      tags: dns

    - include_tasks:
        file: tasks/nginx.yml
      tags: nginx

    - debug:
        msg: "执行结束"
  handlers:
    - include_tasks: tasks/handlers.yml
```

```
# ansible-playbook main.yml --tags="host"

PLAY [demo2.example.com] **************************************************************************************************************************

TASK [include_tasks] ******************************************************************************************************************************
included: /etc/ansible/tasks/host.yml for demo2.example.com

PLAY RECAP ****************************************************************************************************************************************
demo2.example.com          : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
- 只执行自己本身，里面的任务并没有执行

若要执行include_tasks里面的任务，就需要为执行文件打tags
```
- hosts: demo2.example.com
  tasks:
    - debug:
        msg: "start tasks" 
    - include_tasks:
        file:  tasks/host.yml
        apply:
          tags: H1
      tags: always        #这里必须指定always，因为host.yml执行前提是，include_tasks执行

    - include_tasks: 
        file: tasks/dns.yml
      tags: dns

    - include_tasks: 
        file: tasks/nginx.yml
      tags: nginx 
 
    - debug:
        msg: "执行结束"
  handlers:
    - include_tasks: tasks/handlers.yml
```

执行
```
# ansible-playbook main.yml --tags="H1"

PLAY [demo2.example.com] **************************************************************************************************************************

TASK [include_tasks] ******************************************************************************************************************************
included: /etc/ansible/tasks/host.yml for demo2.example.com

TASK [modify hostname] ****************************************************************************************************************************
changed: [demo2.example.com]

PLAY RECAP ****************************************************************************************************************************************
demo2.example.com          : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```


# import_tasks

- import_tasks include_task用法类似，都是包含一个任务列表

```
# vim main.yml 

- hosts: demo2.example.com
  tasks:
    - debug:
        msg: "start tasks" 
    - include_tasks:
        file:  tasks/host.yml
        apply:
          tags: H1
      tags: always

    - import_tasks: tasks/dns.yml
      tags: dns

    - include_tasks: 
        file: tasks/nginx.yml
      tags: nginx 
 
    - debug:
        msg: "执行结束"
  handlers:
    - include_tasks: tasks/handlers.yml

```

## include_tasks和import_task区别一

当执行import_task的tags的时候，对应的文件的任务也会执行，但是自己本身是透明的，和include一样
```
# ansible-playbook main.yml --tags="dns"

PLAY [demo2.example.com] **************************************************************************************************************************

TASK [include_tasks] ******************************************************************************************************************************
included: /etc/ansible/tasks/host.yml for demo2.example.com

TASK [modify resolv.conf] *************************************************************************************************************************
ok: [demo2.example.com]

TASK [/etc/resolvconf/base] ***********************************************************************************************************************
skipping: [demo2.example.com]

PLAY RECAP ****************************************************************************************************************************************
demo2.example.com          : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0  
```

import_tasks是静态的，被import的文件，在被playbook加载时就预处理了，include_tasks是动态的，被include的文件在playbook运行后，才开始处理
```
# cat import_ex.yml
- hosts: demo2.example.com
  gather_facts: no
  vars:
    file_name: tasks/host.yml
  tasks:
    - include_tasks: "{{ file_name }}"
    - import_tasks: "{{ file_name }}"
```

执行
```
PLAY [demo2.example.com] **************************************************************************************************************************

TASK [include_tasks] ******************************************************************************************************************************
included: /etc/ansible/tasks/host.yml for demo2.example.com

TASK [modify hostname] ****************************************************************************************************************************
changed: [demo2.example.com]

TASK [modify hostname] ****************************************************************************************************************************
changed: [demo2.example.com]

PLAY RECAP ****************************************************************************************************************************************
demo2.example.com          : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

修改配置
```
# cat import_ex.yml
- hosts: demo2.example.com
  gather_facts: no
  #vars:
  #  file_name: tasks/host.yml
  tasks:
    - set_facts:
        file_name: tasks/host.yml
    - include_tasks: "{{ file_name }}"
    #- import_tasks: "{{ file_name }}"
```

```
# ansible-playbook  import_ex.yml 

PLAY [demo2.example.com] **************************************************************************************************************************

TASK [set_fact] ***********************************************************************************************************************************
ok: [demo2.example.com]

TASK [include_tasks] ******************************************************************************************************************************
included: /etc/ansible/tasks/host.yml for demo2.example.com

TASK [modify hostname] ****************************************************************************************************************************
changed: [demo2.example.com]

PLAY RECAP ****************************************************************************************************************************************
demo2.example.com          : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

但是使用import就会报错，原因是include在运行之后加载，但是import在运行之前加载，运行playbook之前，是没有file_name的参数选项，报错  
```
# cat import_ex.yml
- hosts: demo2.example.com
  gather_facts: no
  #vars:
  #  file_name: tasks/host.yml
  tasks:
    - set_facts:
        file_name: tasks/host.yml
    #- include_tasks: "{{ file_name }}"
    - import_tasks: "{{ file_name }}"
```

```
# ansible-playbook import_ex.yml

ERROR! Error when evaluating variable in import path: {{ file_name }}.

When using static imports, ensure that any variables used in their names are defined in vars/vars_files
or extra-vars passed in from the command line. Static imports cannot use variables from facts or inventory
sources like group or host vars.
```

## include_tasks和import_task区别二

如果想对包含的列表进行循环操作，只能使用include_tasks。import_task不支持循环操作，即loop对include内容进行循环操作时，只能使用include_tasks，不能使用import_task
```
# cat import_ex.yml
- hosts: demo2.example.com
  gather_facts: no
  vars:
    file_name: tasks/host.yml
  tasks:
    #- set_fact:
    #    file_name: tasks/host.yml
    - include_tasks: "{{ file_name }}"
    - import_tasks: "{{ file_name }}"
      loop:
        - 1
        - 2
```

执行

```
# ansible-playbook  import_ex.yml 

ERROR! You cannot use loops on 'import_tasks' statements. You should use 'include_tasks' instead.

The error appears to be in '/etc/ansible/import_ex.yml': line 9, column 7, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

    - include_tasks: "{{ file_name }}"
    - import_tasks: "{{ file_name }}"
      ^ here
We could be wrong, but this one looks like it might be an issue with
missing quotes. Always quote template expression brackets when they
start a value. For instance:

    with_items:
      - {{ foo }}

Should be written as:

    with_items:
      - "{{ foo }}"
```

使用include_tasks
```
# cat import_ex.yml
- hosts: demo2.example.com
  gather_facts: no
  vars:
    file_name: tasks/host.yml
  tasks:
    #- set_fact:
    #    file_name: tasks/host.yml
    - include_tasks: "{{ file_name }}"
      loop:
        - 1
        - 2
    - import_tasks: "{{ file_name }}"
```

执行
```
PLAY [demo2.example.com] **************************************************************************************************************************

TASK [include_tasks] ******************************************************************************************************************************
included: /etc/ansible/tasks/host.yml for demo2.example.com
included: /etc/ansible/tasks/host.yml for demo2.example.com

TASK [modify hostname] ****************************************************************************************************************************
changed: [demo2.example.com]

TASK [modify hostname] ****************************************************************************************************************************
changed: [demo2.example.com]

TASK [modify hostname] ****************************************************************************************************************************
changed: [demo2.example.com]

PLAY RECAP ****************************************************************************************************************************************
demo2.example.com          : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## include_tasks和import_task区别三

在使用when的条件判断时，有着本质的区别

当include_tasks使用when时候，when只针对include_tasks任务本身，当执行被包含的认识时，不会对包含的任务进行条件判断

当import_tasks使用when时，when对应的条件会被用于import的每一个任务，当执行import的任务时，会对每一个包含的任务进行条件判断

```
# vim import_ex.yml 
- hosts: demo2.example.com
  gather_facts: no
  vars:
    file_name: tasks/host.yml
    num: 1
  tasks:
    - include_tasks: "{{ file_name }}"
      when: num == 1

    - set_fact:
        num: 1

    - import_tasks: "{{ file_name }}"
      when: num == 1
```

执行

```
# vim tasks/host.yml

- name: modify num to 0
  set_fact:
    num: 0
- name: modify hostname
  hostname:
    name: test.example.com
```

```
# ansible-playbook import_ex.yml

PLAY [demo2.example.com] **************************************************************************************************************************
TASK [include_tasks] ******************************************************************************************************************************
included: /etc/ansible/tasks/host.yml for demo2.example.com    # include满足条件，自己本身任务执行
TASK [modify num to 0] ****************************************************************************************************************************
ok: [demo2.example.com]                                        # 包含的第一个任务执行
TASK [modify hostname] ****************************************************************************************************************************
ok: [demo2.example.com]                                        # 包含的第二个任务执行

TASK [set_fact] ***********************************************************************************************************************************
ok: [demo2.example.com]
TASK [modify num to 0] ****************************************************************************************************************************
ok: [demo2.example.com]           #import第一个满足条件执行，这是num设为0
TASK [modify hostname] ****************************************************************************************************************************
skipping: [demo2.example.com]     #第二个任务在进行比较，不满足，直接跳过
PLAY RECAP ****************************************************************************************************************************************
demo2.example.com          : ok=5    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```
在include只要条件满足，就会全部执行包含的内容，import_tasks会对每一个任务做判断，在确定是否执行



# import_playbook

1、在2.8版本以后，使用”include”关键字引用整个playbook的特性将会被弃用
```
# cat intest6.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "test task in intest6.yml"
 
- import_playbook: intest7.yml
 
# cat intest7.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "test task in intest7.yml"
```





