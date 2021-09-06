include & import 区别
===

### include*（动态）：在运行时导入

- --list-tags，--list-tasks不会显示到输出
- 不能使用notify触发来自include*内处理程序名称（handlers）

### import*（静态）：在Playbook解析时预先导入

- 不能与循环一起使用
- 将变量用于目标文件或角色名称时，不能使用inventory（主机/主机组等）中的变量

# include_tasks

1)使用”include_tasks”关键字代替”include”关键字
```
# cat intest.yml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "test task1"
  - include_tasks: in.yml
  - debug:
      msg: "test task2"
 
# cat in.yml
- debug:
    msg: "task1 in in.yml"
- debug:
    msg: "task2 in in.yml"
```

2)从2.7版本开始，”include_tasks”模块加入了file参数和apply参数
```
# cat intest.yml
---
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

```
# ansible-playbook intest.yml --tags t1
 
PLAY [test70] *******************************************
 
TASK [include_tasks] *************************************
included: /testdir/ansible/in.yml for test70
 
PLAY RECAP ********************************************
test70                     : ok=1    changed=0    unreachable=0    failed=0
```
- 当我们指定t1标签后，”include_tasks”这个任务本身被调用了，而”include_tasks”对应文件中的任务却没有被调用,在使用tags时，”include_tasks”与”include”并不相同，标签只会对”include_tasks”任务本身生效，而不会对其中包含的任务生效。












































