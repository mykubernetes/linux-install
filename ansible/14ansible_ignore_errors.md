错误忽略ignore_errors
---
```
# cat test.yml 
- hosts: webserver
  tasks:
     - name: task1
       shell: "ls /testabc"
       register: returnmsg
       ignore_errors: true          #即使当前语句报错，也会忽略,继续执行playbook
     - name: task2
       debug: 
         msg: "command exection successful"
       when: returnmsg.rc == 0
     - name: task3
       debug:
         msg: "command failed"
```
