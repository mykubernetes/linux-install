# when基本条件

- **when在单个任务的后面添加when条件判断语句。when语句中的变量不需要使用{{}}表达式。when条件语句的处理逻辑是：当playbook或task执行时，ansible会在所有主机上进行测试，只在测试通过的主机上执行该任务。**
- **when条件语句中能够使用的判断条件有很多，有变量、facts等，when条件语句可以应用于task，roles或者import等。**

## 比较运算符

| 用法 | 描述 |
|-----|-----|
| == | 比较两个对象是否相等，相等为真 |
| != | 比较两个对象是否不等，不等为真 |
| > | 比较两个值的大小，如果左边的值大于右边的值，则为真 |
| < | 比较两个值的大小，如果左边的值小于右边的值，则为真 |
| >= | 比较两个值的大小，如果左边的值大于右边的值或左右相等，则为真 |
| <= | 比较两个值的大小，如果左边的值小于右边的值或左右相等，则为真 |


## 逻辑运算符

| 用法 | 描述 |
|-----|-----|
| and | 逻辑与，当左边与右边同时为真，则返回真 |
| or | 逻辑或，当左边与右边有任意一个为真，则返回真 |
| not | 取反，对一个操作体取反 |
| ( ) | 组合，将一组操作体包装在一起，形成一个较大的操作体 |

## 布尔型判断

| 用法 | 描述 |
|-----|-----|
| true | 变量为真则执行 |
| false | 变量为假则跳过 |

## 一、when基本条件

1、只在启动了SELinux的主机上配置SELinux以允许mysql运行
```
- hosts: node
  remote_user: root
  tasks:
  - name: Configure SELinux to start mysql on any port
    seboolean:
       name: mysql_connect_any
       state: true
       persistent: yes
    when: ansible_selinux.status == "enabled"
```

## 二、基于ansible_facts的条件

- ansible_facts是单个主机的属性，比如IP地址，操作系统，网络信息。当处理不同主机的差异时可以根据ansible_facts的值进行判断。

1)通过debug打印出ansible_facts都有哪些值。
```
- hosts: node
  remote_user: root
  tasks:
  - name: show ansible facts
    debug:
      var: ansible_facts
```

2）当distribution是CentOS时重启主机
```
- hosts: node
  remote_user: root
  tasks:
  - name: Shut down CentOS systems
    command: /sbin/shutdown -t now
    when: ansible_facts['distribution'] == "CentOS"
```

3)简单条件判断，判断系统是否为centos。
```
---
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "System release is centos"
    when: ansible_distribution == "CentOS"
```

4）如果有多个条件，使用括号进行分组
```
- hosts: node
  remote_user: root
  tasks:
  - name: Shut down CentOS 6 and Debian 7 systems
    command: /sbin/shutdown -t now
    when: (ansible_facts['distribution'] == "CentOS" and ansible_facts['distribution_major_version'] == "6") or
        (ansible_facts['distribution'] == "Debian" and ansible_facts['distribution_major_version'] == "7")
```

5）判断目标主机是否为centos系统，并且是centos6或者是centos7系统。
```
---
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "System release is centos6 or centos7"
    when: ansible_distribution == "CentOS" and
          (ansible_distribution_major_version == "6" or ansible_distribution_major_version == "7")
```

6）取反判断目标主机不为centos系统。
```
---
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "System release is not centos"
    when: not ansible_distribution == "CentOS"
```

7)如果有多个条件都为真时(即and)，可以使用列表形式。并且关系
```
- hosts: node
  remote_user: root
  tasks:
  - name: System release is centos7
    debug:
      msg: "System release is centos7"
    when:
      - ansible_facts['distribution'] == "CentOS"
      - ansible_facts['distribution_major_version'] == "7"
```

8）如果需要类型转换，可以使用过滤器，比如将字符串转变为数字。
```
- hosts: node
  remote_user: root
  tasks:
  - shell: echo "only on Red Hat 6, derivatives, and later"
    when: ansible_facts['os_family'] == "RedHat" and ansible_facts['lsb']['major_release'] | int >= 6
```


## 三、基于注册变量的条件

- **通常在playbook中，会根据前面任务执行的结果来判断后面任务的执行与否。比如：只有当依赖包安装成功后，才能安装该软件。这时就可以将安装依赖包的任务的执行结果注册（register）为变量，再根据注册变量的值决定后续是否安装该软件。**

1)判断上一个命令执行成功则执行此命令，执行失败则跳过。
```
- hosts: node
  remote_user: root
  tasks:
  - command: /bin/false
    register: result
    ignore_errors: True

  - command: echo "is work"
    when: result is succeeded
```

2）判断上一个命令执行成功才操作，失败则跳过
```
---
- hosts: node
  remote_user: root
  tasks:
  - name: task1
    shell: "ls /testabc"
    register: returnmsg
    ignore_errors: true
  - name: task2
    debug:
      msg: "Command execution successful"
    when: returnmsg.rc == 0
  - name: task3
    debug:
      msg: "Command execution failed"
    when: returnmsg.rc != 0
```

3）注册变量也是一个对象，包含了任务执行的结果和输出。可以通过debug将注册变量输出，以下是打印出注册变量ls_result的内容
```
- hosts: node
  remote_user: root
  tasks:
  - name: register variable
    command: ls /mnt
    register: ls_result

  - name: print register variable
    debug:
      var: ls_result
```

执行过程
```
# ansible-playbook when.yml 

PLAY [node] ********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Monday 27 September 2021  10:02:48 -0400 (0:00:00.060)       0:00:00.060 ****** 
ok: [node01]

TASK [register variable] *******************************************************************************************************************************
Monday 27 September 2021  10:02:49 -0400 (0:00:00.880)       0:00:00.941 ****** 
changed: [node01]

TASK [print register variable] *************************************************************************************************************************
Monday 27 September 2021  10:02:49 -0400 (0:00:00.381)       0:00:01.322 ****** 
ok: [node01] => {
    "ls_result": {
        "changed": true, 
        "cmd": [
            "ls", 
            "/mnt"
        ], 
        "delta": "0:00:00.002489", 
        "end": "2021-09-27 10:02:49.365923", 
        "failed": false, 
        "rc": 0, 
        "start": "2021-09-27 10:02:49.363434", 
        "stderr": "", 
        "stderr_lines": [], 
        "stdout": "", 
        "stdout_lines": []
    }
}

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=3    changed=1    unreachable=0    failed=0   

Monday 27 September 2021  10:02:49 -0400 (0:00:00.044)       0:00:01.366 ****** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.88s
register variable ------------------------------------------------------------------------------------------------------------------------------- 0.38s
print register variable ------------------------------------------------------------------------------------------------------------------------- 0.04s
```

4)当结果不为空时，打印出该目录下有几个条目。
```
- hosts: node
  remote_user: root
  tasks:
  - name: register variable
    command: ls /mnt
    register: ls_result

  - name: print register variable
    debug:
      msg: "this directory includes {{ls_result.stdout_lines|length}} items"
    when: ls_result.stdout != ""
```

```
# ansible-playbook when.yml

PLAY [node] ********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Monday 27 September 2021  10:09:51 -0400 (0:00:00.059)       0:00:00.059 ****** 
ok: [node01]

TASK [register variable] *******************************************************************************************************************************
Monday 27 September 2021  10:09:52 -0400 (0:00:00.761)       0:00:00.820 ****** 
changed: [node01]

TASK [print register variable] *************************************************************************************************************************
Monday 27 September 2021  10:09:52 -0400 (0:00:00.383)       0:00:01.204 ****** 
ok: [node01] => {
    "msg": "this directory includes 6 items"
}

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=3    changed=1    unreachable=0    failed=0   

Monday 27 September 2021  10:09:52 -0400 (0:00:00.044)       0:00:01.248 ****** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.76s
register variable ------------------------------------------------------------------------------------------------------------------------------- 0.38s
print register variable ------------------------------------------------------------------------------------------------------------------------- 0.04s
```

## 四、基于变量的条件

可以基于playboo或inventory中定义的变量进行条件判断。因为when条件判断的结果是布尔值（True|False）。因此基于条件判断的变量值有两类
- 可以转换成布尔的值，比如yes、on、1、true等。该类型的值需要进行bool过滤器转换。
- 其他类型的值，通过表达式计算出布尔值。比如：master == ‘master’

1)根据变量值判断
```
- hosts: node
  remote_user: root
  debugger: on_failed
  vars:
    output: yes
  tasks:
  - name: print debug msg
    debug:
      msg: "this is debug msg"
    when: output | bool
```

执行过程
```
# ansible-playbook when.yml

PLAY [node] ********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Monday 27 September 2021  10:19:09 -0400 (0:00:00.056)       0:00:00.056 ****** 
ok: [node01]

TASK [print debug msg] *********************************************************************************************************************************
Monday 27 September 2021  10:19:10 -0400 (0:00:00.771)       0:00:00.828 ****** 
ok: [node01] => {
    "msg": "this is debug msg"
}

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=2    changed=0    unreachable=0    failed=0   

Monday 27 September 2021  10:19:10 -0400 (0:00:00.045)       0:00:00.874 ****** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.77s
print debug msg --------------------------------------------------------------------------------------------------------------------------------- 0.05s
```

2)判断变量为true则执行，判断变量为false则跳过执行，在判断语句中变量不用使用`{{  }}`符合
```
---
- hosts: node
  remote_user: root
  gather_facts: no
  vars:
    mode1: true
    mode2: false
  tasks:
  - name: "when var is false not exec"
    shell: echo false
    ignore_errors: true
    when: mode2

  - name: "when var is true exec"
    shell: echo true
    ignore_errors: true
    when: mode1
```

执行结果
```
# ansible-playbook test.yml

PLAY [node] ********************************************************************************************************************************************

TASK [when var is false not exec] **********************************************************************************************************************
Saturday 25 September 2021  04:35:23 -0400 (0:00:00.072)       0:00:00.072 **** 
skipping: [node01]

TASK [when var is true exec] ***************************************************************************************************************************
Saturday 25 September 2021  04:35:23 -0400 (0:00:00.025)       0:00:00.097 **** 
changed: [node01]

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=1    changed=1    unreachable=0    failed=0   

Saturday 25 September 2021  04:35:24 -0400 (0:00:00.334)       0:00:00.432 **** 
=============================================================================== 
when var is true exec --------------------------------------------------------------------------------------------------------------------------- 0.33s
when var is false not exec ---------------------------------------------------------------------------------------------------------------------- 0.03s
```

3）根据变量是否定义判断
```
- hosts: node
  remote_user: root
  debugger: on_failed
  vars:
    output: yes
  tasks:
  - name: variable is defined
    debug:
      msg: "variable output is {{output}}"
    when: output is defined

  - name: variable is not defined
    debug:
      msg: "variable output is not defined"
    when: output is undefined
```

执行过程
```
# ansible-playbook when.yml

PLAY [node] ********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Monday 27 September 2021  10:22:09 -0400 (0:00:00.059)       0:00:00.059 ****** 
ok: [node01]

TASK [variable is defined] *****************************************************************************************************************************
Monday 27 September 2021  10:22:10 -0400 (0:00:00.862)       0:00:00.921 ****** 
ok: [node01] => {
    "msg": "variable output is True"
}

TASK [variable is not defined] *************************************************************************************************************************
Monday 27 September 2021  10:22:10 -0400 (0:00:00.064)       0:00:00.986 ****** 
skipping: [node01]

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=2    changed=0    unreachable=0    failed=0   

Monday 27 September 2021  10:22:10 -0400 (0:00:00.026)       0:00:01.012 ****** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.86s
variable is defined ----------------------------------------------------------------------------------------------------------------------------- 0.06s
variable is not defined ------------------------------------------------------------------------------------------------------------------------- 0.03s
```

## 五、与循环一起使用

- **如果将when与循环一起使用时，ansible会为每个循环项都执行单独的条件判断，不满足条件的项就会跳过。**

1）打印大于5的数字
```
- hosts: node
  remote_user: root
  debugger: on_failed
  tasks:
  - name: print items greater than 5
    debug:
      msg: "item is {{item}}"
    loop: [0,1,3,5,6,7,8,10]
    when: item > 5
```

执行过程
```
# ansible-playbook when.yml

PLAY [node] ********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Monday 27 September 2021  10:31:13 -0400 (0:00:00.059)       0:00:00.059 ****** 
ok: [node01]

TASK [print items greater than 5] **********************************************************************************************************************
Monday 27 September 2021  10:31:14 -0400 (0:00:00.868)       0:00:00.928 ****** 
skipping: [node01] => (item=0) 
skipping: [node01] => (item=1) 
skipping: [node01] => (item=3) 
skipping: [node01] => (item=5) 
ok: [node01] => (item=6) => {
    "msg": "item is 6"
}
ok: [node01] => (item=7) => {
    "msg": "item is 7"
}
ok: [node01] => (item=8) => {
    "msg": "item is 8"
}
ok: [node01] => (item=10) => {
    "msg": "item is 10"
}

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=2    changed=0    unreachable=0    failed=0   

Monday 27 September 2021  10:31:14 -0400 (0:00:00.128)       0:00:01.056 ****** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.87s
print items greater than 5 ---------------------------------------------------------------------------------------------------------------------- 0.13s
```

2）指定默认值default，当该集合未定义时，可以跳过。
```
- hosts: node
  remote_user: root
  debugger: on_failed
  tasks:
  - name: print items greater than 5
    debug:
      msg: "item is {{item}}"
    loop: "{{ mylist|default([]) }}"
    when: item > 5
```

执行过程
```
# ansible-playbook when.yml

PLAY [node] ********************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Monday 27 September 2021  10:33:19 -0400 (0:00:00.060)       0:00:00.060 ****** 
ok: [node01]

TASK [print items greater than 5] **********************************************************************************************************************
Monday 27 September 2021  10:33:20 -0400 (0:00:00.858)       0:00:00.919 ****** 

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=1    changed=0    unreachable=0    failed=0   

Monday 27 September 2021  10:33:20 -0400 (0:00:00.020)       0:00:00.939 ****** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.86s
print items greater than 5 ---------------------------------------------------------------------------------------------------------------------- 0.02s
```

3)循环dict字典
```

```













9、为所有的web主机名添加nginx仓库，其余的都跳过添加
```
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
```

10、主机名称是web*或主机名称是lb*的则添加这个nginx源
```
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
```


