比较运算符

| 用法 | 描述 |
|-----|-----|
| == | 比较两个对象是否相等，相等为真 |
| != | 比较两个对象是否不等，不等为真 |
| > | 比较两个值的大小，如果左边的值大于右边的值，则为真 |
| < | 比较两个值的大小，如果左边的值小于右边的值，则为真 |
| >= | 比较两个值的大小，如果左边的值大于右边的值或左右相等，则为真 |
| <= | 比较两个值的大小，如果左边的值小于右边的值或左右相等，则为真 |


逻辑运算符
| 用法 | 描述 |
|-----|-----|
| and | 逻辑与，当左边与右边同时为真，则返回真 |
| or | 逻辑或，当左边与右边有任意一个为真，则返回真 |
| not | 取反，对一个操作体取反 |
| ( ) | 组合，将一组操作体包装在一起，形成一个较大的操作体 |

when条件判断

1、简单条件判断，判断系统是否为centos。
```
---
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "System release is centos"
    when: ansible_distribution == "CentOS"
```

2、根据不同操作系统，安装相同的软件包
```
- hosts: webserver
  tasks:

    - name: Installed {{ ansible_distribution }} Httpd Server
      yum: name=httpd state=present
      when: ( ansible_distribution == "CentOS" )

    - name: Installed {{ ansible_distribution }} Httpd2 Server
      yum: name=httpd2 state=present
      when: ( ansible_distribution == "Ubuntu" )
```


3、获取facts中的key的值，通过引用变量的方式进行判断。
```
---
- hosts: node01
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_items:
    - 1
    - 2
    - 3
    when: item > 1
```

4、判断目标主机是否为centos系统并且为centos7的系统
```
---
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "System release is centos7"
    when: ansible_distribution == "CentOS" and ansible_distribution_major_version == "7"
```

5、以列表的方式，判断目标主机是否为centos系统并且为centos7的系统
```
---
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "System release is centos7"
    when:
    - ansible_distribution == "CentOS"                   # 两个条件同时满足才执行
    - ansible_distribution_major_version == "7"
```

6、判断目标主机是否为centos系统，并且是centos6或者是centos7系统。
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

7、取反，判断目标主机不为centos系统。
```
---
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "System release is not centos"
    when: not ansible_distribution == "CentOS"
```

8、判断上一个命令执行成功才操作，失败不操作
```
---
- hosts: node01
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

11、布尔型判断

| 用法 | 描述 |
|-----|-----|
| true | 变量为真则执行 |
| false | 变量为假则跳过 |
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
