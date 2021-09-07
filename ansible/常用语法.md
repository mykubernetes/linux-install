# 1、执行一个shell模块将返回的值进行测试，如果符合预期跳过，不符合预期结束

| 参数 | 描述 |
|------|-----|
| until | 条件终止表达式 |
| retries | 最大循环次数 |
| delay | 每次循环时间间隔（秒） |

- 循环终止有两个条件，任意满足其一就可以：
  - 1. 循环次数超过最大次数；
  - 2. 满足until条件，直接跳出循环；


## 1、配置shell模块输出的值为12，预期的值为1测试效果
```
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - name: "Kafka | Wait for kafka nodes ready"
    vars:
      - replicas: "1"
    shell: "echo 12"
    register: result
    until: "{{ result.stdout|int }} == {{ replicas|int}}"
    retries: 10
    delay: 5
```
- register：保存命令的结果(shell或command模块)

```
# ansible-playbook -i host test.yml 

PLAY [all] ******************************************************************************************************************************************************************************************************

TASK [Kafka | Wait for kafka nodes ready] ***********************************************************************************************************************************************************************
 [WARNING]: when statements should not include jinja2 templating delimiters such as {{ }} or {% %}. Found: {{ result.stdout|int }} == {{ replicas|int}}

FAILED - RETRYING: Kafka | Wait for kafka nodes ready (10 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (9 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (8 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (7 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (6 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (5 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (4 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (3 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (2 retries left).
FAILED - RETRYING: Kafka | Wait for kafka nodes ready (1 retries left).
fatal: [192.168.101.69]: FAILED! => {"attempts": 10, "changed": true, "cmd": "echo 12", "delta": "0:00:00.002368", "end": "2021-09-07 09:13:21.948380", "rc": 0, "start": "2021-09-07 09:13:21.946012", "stderr": "", "stderr_lines": [], "stdout": "12", "stdout_lines": ["12"]}
	to retry, use: --limit @/tmp/test.retry

PLAY RECAP ******************************************************************************************************************************************************************************************************
192.168.101.69             : ok=0    changed=0    unreachable=0    failed=1
```

## 2、配置shell模块输出的值为1，预期的值为1测试效果
```
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - name: "Kafka | Wait for kafka nodes ready"
    vars:
      - replicas: "1"
    shell: "echo 1"
    register: result
    until: "{{ result.stdout|int }} == {{ replicas|int}}"
    retries: 10
    delay: 5
```

```
# ansible-playbook -i host test.yml 

PLAY [all] ******************************************************************************************************************************************************************************************************

TASK [Kafka | Wait for kafka nodes ready] ***********************************************************************************************************************************************************************
 [WARNING]: when statements should not include jinja2 templating delimiters such as {{ }} or {% %}. Found: {{ result.stdout|int }} == {{ replicas|int}}

changed: [192.168.101.69]

PLAY RECAP ******************************************************************************************************************************************************************************************************
192.168.101.69             : ok=1    changed=1    unreachable=0    failed=0
```

```
- command: grep "url.httpport=8081" "/{{ base_dir }}/conf/server.conf"
  ignore_errors: yes
  register: output

- get_url:
    url: http://localhost:8000/version.txt
    dest: /tmp
  register: result
  until: result is succeeded
  retries: 10
  delay: 30
  when: output.rc == 1

- get_url:
    url: http://localhost:8081/version.txt
    dest: /tmp
  register: result
  until: result is succeeded
  retries: 10
  delay: 30
  when: output.rc == 0
```



# 1、控制每次同时更新的主机数量
```
---
- hosts: all
  serial: 2                          #每次只同时处理2个主机
  max_fail_percentage : 50           #当两台机器中有一台执行失败，既终止task
  gather_facts: False
 
  tasks:
    - name: task one
      comand: hostname
    - name: task two
      command: hostname

#也可以使用百分比进行控制
name: test serail
  hosts: all
  serial: "20%"                      #每次只同时处理20%的主机
```

# 2、Until条件循环

```
---
- hosts: "ansible-server"
  tasks:
  - name: test for sync job
    shell: |
      sleep 15
    async: 999
    poll: 0
    register: sleeper
 
  - name: Monitor and feedback
    async_status:
      jid: "{{ sleeper.ansible_job_id }}"
    register: backer
    until: backer.finished
    retries: 20
    delay: 1
```



# 3、获取变量的值
```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    kafka:
      name: kafka
      port: 9092
      ip: "192.168.101.69"
  tasks:
  - debug:
      msg: "{{ kafka.get('ip') }}"
```







