# 一、debug模块

- debug模块是Ansible Playbook中最常用的调试模块，可以在Playbook执行过程打印调试信息，特别是跟when条件语句一起使用时，可以调试特定条件下的执行过程。比如：当变量a定义时，将a的值打印出来，当任务成功后，打印执行结果等等

## 1、debug参数说明
| 参数 | 参数说明 |
|-----|------|
| msg | 指定要打印的信息，如果没有指定，打印默认值`hello world`。 |
| var | 指定要打印的变量名，与msg参数互斥，二者只能有一个。注意：var参数中的变量不需要使用{{}}表达式，而msg中需要。 |
| verbosity | 控制哪种调试级别下输出，值为Integer。如果设为3，则只有在-vvv或更高调试级别下才会输出。 |

## 2、debug调试示例
```
---
- hosts: devops
  tasks:
  - name: show debug msg
    debug:
      msg: System {{inventory_hostname}} has uuid {{ansible_product_uuid}}
  - name: print gateway when it is defined
    debug:
      msg: System {{inventory_hostname}} has gateway {{ansible_default_ipv4.gateway}}
    when: ansible_default_ipv4.gateway is defined
  - name: show uptime
    shell: /usr/bin/uptime
    register: result
  - name: show uptime result
    debug:
      var: result
      verbosity: 2
  - name: display all vars of a host
    debug:
      var: hostvars[inventory_hostname]
      verbosity: 3
  - name: print two lines of messages
    debug:
      msg:
        - "first line msg"
        - "second line msg"
```

## 3、debug执行过程
```
# ansible-playbook debug.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node01] ******************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Thursday 23 September 2021  09:21:45 -0400 (0:00:00.061)       0:00:00.061 **** 
ok: [192.168.101.69]

TASK [show debug msg] **********************************************************************************************************************************
Thursday 23 September 2021  09:21:46 -0400 (0:00:00.883)       0:00:00.944 **** 
ok: [192.168.101.69] => {
    "msg": "System 192.168.101.69 has uuid 1CA64D56-F48A-A64E-B82D-B31749084A76"
}

TASK [print gateway when it is defined] ****************************************************************************************************************
Thursday 23 September 2021  09:21:46 -0400 (0:00:00.071)       0:00:01.015 **** 
ok: [192.168.101.69] => {
    "msg": "System 192.168.101.69 has gateway 192.168.101.1"
}

TASK [show uptime] *************************************************************************************************************************************
Thursday 23 September 2021  09:21:46 -0400 (0:00:00.078)       0:00:01.094 **** 
changed: [192.168.101.69] => {"changed": true, "cmd": "/usr/bin/uptime", "delta": "0:00:00.004278", "end": "2021-09-23 09:21:46.788891", "rc": 0, "start": "2021-09-23 09:21:46.784613", "stderr": "", "stderr_lines": [], "stdout": " 09:21:46 up 1 day, 17:05,  3 users,  load average: 0.21, 0.13, 0.07", "stdout_lines": [" 09:21:46 up 1 day, 17:05,  3 users,  load average: 0.21, 0.13, 0.07"]}

TASK [show uptime result] ******************************************************************************************************************************
Thursday 23 September 2021  09:21:46 -0400 (0:00:00.386)       0:00:01.481 **** 
skipping: [192.168.101.69] => {"skipped_reason": "Verbosity threshold not met."}

TASK [display all vars of a host] **********************************************************************************************************************
Thursday 23 September 2021  09:21:46 -0400 (0:00:00.066)       0:00:01.548 **** 
skipping: [192.168.101.69] => {"skipped_reason": "Verbosity threshold not met."}

TASK [print two lines of messages] *********************************************************************************************************************
Thursday 23 September 2021  09:21:46 -0400 (0:00:00.064)       0:00:01.613 **** 
ok: [192.168.101.69] => {
    "msg": [
        "first line msg", 
        "second line msg"
    ]
}

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=5    changed=1    unreachable=0    failed=0   

Thursday 23 September 2021  09:21:47 -0400 (0:00:00.044)       0:00:01.657 **** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.88s
show uptime ------------------------------------------------------------------------------------------------------------------------------------- 0.39s
print gateway when it is defined ---------------------------------------------------------------------------------------------------------------- 0.08s
show debug msg ---------------------------------------------------------------------------------------------------------------------------------- 0.07s
show uptime result ------------------------------------------------------------------------------------------------------------------------------ 0.07s
display all vars of a host ---------------------------------------------------------------------------------------------------------------------- 0.06s
print two lines of messages --------------------------------------------------------------------------------------------------------------------- 0.04s
```

# 二、assert模块

- assert模块是用来断言playbook中给定的表达式。当表达式成功或失败时输出一些信息，帮助进行调试。assert模块可用作单元测试，每次修改playbook后，都通过assert断言判断有没有改变执行结果。

## 1、assert参数说明
| 参数 | 参数说明 |
|-----|------|
| fail_msg | 当断言失败时输出的消息。 |
| success_msg | 当断言成功时输出的消息。 |
| quite | 当为yes时，如果成功就不输出任何消息，为no时，断言成功会输出消息。 |
| that | 需要判断的表达式列表。 |

## 2、assert调试示例
```
---
- hosts: devops
  vars:
    command_result: 'the result is success'
    number_of_the_count: 5
    param: 90
  tasks:
  - name: assert param scope
    assert:
      that:
        - param <= 100
        - param >= 0
      fail_msg: "'param' must be between 0 and 100"
      success_msg: "'param' is between 0 and 100"
  - name: use quiet to avoid verbose output
    assert:
      that:
        - param <= 100
        - param >= 0
      quiet: yes
  - name: print origin fail msg
    assert:
      that:
        - "'success' in command_result"
        - number_of_the_count == 4
```

## 3、assert执行过程
```
# ansible-playbook assert.yml

PLAY [node01] ******************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Thursday 23 September 2021  09:32:01 -0400 (0:00:00.060)       0:00:00.060 **** 
ok: [192.168.101.69]

TASK [assert param scope] ******************************************************************************************************************************
Thursday 23 September 2021  09:32:02 -0400 (0:00:00.779)       0:00:00.839 **** 
ok: [192.168.101.69] => {
    "changed": false, 
    "msg": "All assertions passed"
}

TASK [use quiet to avoid verbose output] ***************************************************************************************************************
Thursday 23 September 2021  09:32:02 -0400 (0:00:00.072)       0:00:00.911 **** 
ok: [192.168.101.69] => {
    "changed": false, 
    "msg": "All assertions passed"
}

TASK [print origin fail msg] ***************************************************************************************************************************
Thursday 23 September 2021  09:32:02 -0400 (0:00:00.070)       0:00:00.982 **** 
fatal: [192.168.101.69]: FAILED! => {
    "assertion": "number_of_the_count == 4", 
    "changed": false, 
    "evaluated_to": false
}
	to retry, use: --limit @/root/assert.retry

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=3    changed=0    unreachable=0    failed=1   

Thursday 23 September 2021  09:32:02 -0400 (0:00:00.047)       0:00:01.029 **** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.78s
assert param scope ------------------------------------------------------------------------------------------------------------------------------ 0.07s
use quiet to avoid verbose output --------------------------------------------------------------------------------------------------------------- 0.07s
print origin fail msg --------------------------------------------------------------------------------------------------------------------------- 0.05s
```


# 三、fail模块

- fail模块是让当前所执行的任务失败，并输出信息。等与when一起使用时，可以在特定条件下让任务失败，以调试程序。比如：当status与期望值不符时，任务失败并输出变量的值。


## 1、fail参数说明
| 参数 | 参数说明 |
|-----|------|
| msg | 当任务失败时，输出特定的消息。如果没有指定，输出默认消息“Failed as requested from task”。 |

## 2、fail调试示例
```
---
- hosts: devops
  vars:
  number_of_the_count: 5
  tasks:
  - name: use fail module with when
    fail:
    when: number_of_the_count == 5

  - name: use fail module
    fail:
      msg: 'this is a debug msg'
```

## 3、assert执行过程
```
# ansible-playbook fail.yml

PLAY [node01] ******************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Thursday 23 September 2021  09:35:59 -0400 (0:00:00.057)       0:00:00.057 **** 
ok: [192.168.101.69]

TASK [use fail module with when] ***********************************************************************************************************************
Thursday 23 September 2021  09:36:00 -0400 (0:00:00.883)       0:00:00.941 **** 
fatal: [192.168.101.69]: FAILED! => {"changed": false, "msg": "Failed as requested from task"}
	to retry, use: --limit @/root/fail.retry

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=1    changed=0    unreachable=0    failed=1   

Thursday 23 September 2021  09:36:00 -0400 (0:00:00.048)       0:00:00.989 **** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.88s
use fail module with when ----------------------------------------------------------------------------------------------------------------------- 0.05s
```

# 四、--start-at-task参数

- 有时候在开发阶段调试新增的palybook或task，其中有个任务经常失败，需要不停的重试。如果在这个任务之前还有很多其他成功的任务，如果每次都从头执行，那么每次都需要执行那些已经成功的任务，效率就很低，这时可以通过`--start-at-task`参数指定这个特定的任务。

## 1、`--start-at-task`参数示例
```
# ansible-playbook assert.yml --start-at-task="print origin fail msg"

PLAY [node01] ******************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Thursday 23 September 2021  09:38:42 -0400 (0:00:00.057)       0:00:00.057 **** 
ok: [192.168.101.69]

TASK [print origin fail msg] ***************************************************************************************************************************
Thursday 23 September 2021  09:38:43 -0400 (0:00:00.767)       0:00:00.824 **** 
fatal: [192.168.101.69]: FAILED! => {
    "assertion": "number_of_the_count == 4", 
    "changed": false, 
    "evaluated_to": false
}
	to retry, use: --limit @/root/assert.retry

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=1    changed=0    unreachable=0    failed=1   

Thursday 23 September 2021  09:38:43 -0400 (0:00:00.050)       0:00:00.875 **** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 0.77s
print origin fail msg --------------------------------------------------------------------------------------------------------------------------- 0.05s
```

# 五、--step参数

- --step参数与--start-at-task参数不同，--start-at-task参数是从某个特定的任务开始，而--step是以交互的模式一步一步的执行。

每步任务的执行都需要输入三个选项中的一个
- N（跳过）
- Y（执行）
- C（继续执行后面所有步骤）

## 1、`--start-at-task`参数示例
```
# ansible-playbook debug.yml --step

PLAY [node01] ******************************************************************************************************************************************
Perform task: TASK: Gathering Facts (N)o/(y)es/(c)ontinue: y

Perform task: TASK: Gathering Facts (N)o/(y)es/(c)ontinue: *********************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
Thursday 23 September 2021  09:42:45 -0400 (0:00:01.246)       0:00:01.246 **** 
ok: [192.168.101.69]
Perform task: TASK: show debug msg (N)o/(y)es/(c)ontinue: n

Perform task: TASK: show debug msg (N)o/(y)es/(c)ontinue: **********************************************************************************************
Perform task: TASK: print gateway when it is defined (N)o/(y)es/(c)ontinue: n

Perform task: TASK: print gateway when it is defined (N)o/(y)es/(c)ontinue: ****************************************************************************
Perform task: TASK: show uptime (N)o/(y)es/(c)ontinue: c

Perform task: TASK: show uptime (N)o/(y)es/(c)ontinue: *************************************************************************************************

TASK [show uptime] *************************************************************************************************************************************
Thursday 23 September 2021  09:42:50 -0400 (0:00:04.391)       0:00:05.637 **** 
changed: [192.168.101.69]

TASK [show uptime result] ******************************************************************************************************************************
Thursday 23 September 2021  09:42:50 -0400 (0:00:00.380)       0:00:06.018 **** 
skipping: [192.168.101.69]

TASK [display all vars of a host] **********************************************************************************************************************
Thursday 23 September 2021  09:42:50 -0400 (0:00:00.060)       0:00:06.078 **** 
skipping: [192.168.101.69]

TASK [print two lines of messages] *********************************************************************************************************************
Thursday 23 September 2021  09:42:50 -0400 (0:00:00.066)       0:00:06.144 **** 
ok: [192.168.101.69] => {
    "msg": [
        "first line msg", 
        "second line msg"
    ]
}

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=3    changed=1    unreachable=0    failed=0   

Thursday 23 September 2021  09:42:50 -0400 (0:00:00.047)       0:00:06.192 **** 
=============================================================================== 
Gathering Facts --------------------------------------------------------------------------------------------------------------------------------- 4.39s
show uptime ------------------------------------------------------------------------------------------------------------------------------------- 0.38s
display all vars of a host ---------------------------------------------------------------------------------------------------------------------- 0.07s
show uptime result ------------------------------------------------------------------------------------------------------------------------------ 0.06s
print two lines of messages --------------------------------------------------------------------------------------------------------------------- 0.05s
```

# 六、debugger

- 可以使用debugger关键字为play、role、block或task开启或关闭调试器。一般情况下，在新增或修改task时开启调试器，这样当失败时可以进行调试，快速修复错误。

| debugger参数的值| debugger参数描述|
|----------------|----------------|
| always | 无论如何都会调用debugger。 |
| never | 无论如何都不会调用debugger。 |
| on_failed | 只有当任务失败的时候再调用debugger。 |
| on_unreachable | 只有当主机不可达时再调用debugger。 |
| on_skipped | 只有当任务skipped再调用debugger。 |

## 1、在全局开启debugger，可以在ansible.cfg文件中设置，默认是task级别。
```
[defaults]
enable_task_debugger = True
```

## 2、在环境变量中进行设置，默认是task级别
```
ANSIBLE_ENABLE_TASK_DEBUGGER = True
```


## 3、在play级别设置debugger
```
---
- hosts: node01
  debugger: on_skipped
  tasks:
  - name: Execute a command
    debug:
      msg: test
    when: False
```

## 4、在task级别设置debugger
```
---
- hosts: node01
  tasks:
  - name: Execute a command
    debug:
      var: "{{ absible }}"
    debugger: on_failed
```


## 5、在多个级别设置debugger
```
---
- hosts: node01
  debugger: never
  tasks:
  - name: Execute a command
    debug:
      var: "{{ absible }}"
    debugger: on_failed
```


## Debugger中可用的命令

- 在使用debugger进行调试时，是进入到一个交互模式窗口下，使用debugger提供的命令进行调试

| 命令使用方法 | 命令描述 |
|-------------|--------|
| p task | 打印出任务的名称 |
| p task_vars | 打印任务的变量 |
| p task_args | 打印任务的参数 |
| p host | 打印当前主机 |
| p result | 打印任务执行结果 |
| task.args[key]=value | 修改模块参数的值 |
| task.vars[key]=value | 修改模块变量的值 |
| u（update_task） | 根据更新后的变量或参数值从新创建该task |
| r（redo） | 重新执行该task |
| c（continue） | 继续执行后续的tasks |
| q（quit） | 从debugger会话中退出 |
| help | 查看帮助信息 |

## 6、使用debugger调试
```
---
- hosts: node
  debugger: on_failed
  gather_facts: no
  vars:
    info: debug this playbook
  tasks:
  - name: print the wrong variable
    ping: data={{wrong_info}}
```
- 设置了play级别的debugger值为on_failed，也就是当task失败时调用debugger进行调试。在task中使用了一个错误的变量，执行时肯定会失败。在debugger中修改变量名，然后再次成功执行该任务。

```
# ansible-playbook debugger_test.yml 

PLAY [node] ********************************************************************************************************************************************

TASK [print the wrong variable] ************************************************************************************************************************
Sunday 26 September 2021  09:41:09 -0400 (0:00:00.073)       0:00:00.073 ****** 
fatal: [node01]: FAILED! => {"msg": "The task includes an option with an undefined variable. The error was: 'wrong_info' is undefined\n\nThe error appears to have been in '/root/test/te.yml': line 8, column 5, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n  tasks:\n  - name: print the wrong variable\n    ^ here\n"}
[node01] TASK: print the wrong variable (debug)> p task
TASK: print the wrong variable
[node01] TASK: print the wrong variable (debug)> p task.args
{u'data': u'{{wrong_info}}'}
[node01] TASK: print the wrong variable (debug)> task.args['data']='{{info}}'
[node01] TASK: print the wrong variable (debug)> p task.args
{u'data': '{{info}}'}
[node01] TASK: print the wrong variable (debug)> r
ok: [node01]

PLAY RECAP *********************************************************************************************************************************************
node01                     : ok=1    changed=0    unreachable=0    failed=0   

Sunday 26 September 2021  09:42:21 -0400 (0:01:12.164)       0:01:12.237 ****** 
=============================================================================== 
print the wrong variable ----------------------------------------------------------------------------------------------------------------------- 72.16s
```
- 通过p task_args命令查看当前的参数列表，通过task.args['data'] = '{{info}}'设置参数名，然后通过r命令重新执行该任务，再次执行时执行成功。
