# 条件判断与错误处理

1、ansible在执行fail模块时，fail模块默认的输出信息为`Failed as requested from task`，可以通过fail模块的msg参数自定义报错的信息
```
---
- hosts: web
  remote_user: root
  tasks:
  - debug:
      msg: "1"
  - fail:
      msg: "Interrupt running playbook"
  - debug:
      msg: "2"
```

2、对某些条件进行判断，如果条件满足，则中断剧本.
```
---
- hosts: web
  remote_user: root
  tasks:
  - shell: "echo 'This is a string for testing--error'"
    register: return_value
  - fail:
      msg: "Conditions established,Interrupt running playbook"
    when: "'error' in return_value.stdout"
  - debug:
      msg: "I never execute,Because the playbook has stopped"
```

使用in或者not in条件判断时正确写法
```
when: ' "successful" not in return_value.stdout '
when: " 'successful' not in return_value.stdout "
```

3、借助`failed_when`功能实现失败判断，`failed_when`的作用就是，当对应的条件成立时，将对应任务的执行状态设置为失败
```
---
- hosts: web
  remote_user: root
  tasks:
  - debug:
      msg: "I execute normally"
  - shell: "echo 'This is a string for testing error'"
    register: return_value
    failed_when: ' "error" in return_value.stdout'
  - debug:
      msg: "I never execute,Because the playbook has stopped"
```


4、`changed_when`作用是在条件成立时，将对应任务的执行状态设置为changed
```
---
- hosts: web
  remote_user: root
  tasks:
  - debug:
      msg: "test message"
    changed_when: 2 > 1
```

5、将任务设置成永远不为changed状态
```
---
- hosts: test70
  remote_user: root
  tasks:
  - shell: "ls /opt"
    changed_when: false
```

```
1.强制调用handlers
# cat test.yml 
- hosts: webserver
  force_handlers: yes                  #强制调用handlers
  tasks:
    - name: Touch File
      file: path=/tmp/bgx_handlers state=touch
      notify: Restart Httpd Server
    - name: Installed Packages
      yum: name=sb state=latest
  handlers:
    - name: Restart Httpd Server
      service: name=httpd state=restarted

2.关闭changed的状态(确定该tasks不会对被控端做任何的修改和变更.)
# cat test.yml 
- hosts: webserver
  tasks:
    - name: Installed Httpd Server
      yum: name=httpd state=present
    - name: Service Httpd Server
      service: name=httpd state=started
    - name: Check Httpd Server
      shell: ps aux|grep httpd
      register: check_httpd
      changed_when: false
    - name: OutPut Variables
      debug:
        msg: "{{ check_httpd.stdout_lines }}"


3、使用changed_when检查tasks任务返回的结果
# cat test.yml 
- hosts: webserver
  tasks: 
    - name: Installed Nginx Server
      yum: name=nginx state=present
    - name: Configure Nginx Server
      copy: src=./nginx.conf.j2 dest=/etc/nginx/nginx.conf
      notify: Restart Nginx Server
    - name: Check Nginx Configure Status
      command: /usr/sbin/nginx -t
      register: check_nginx
      changed_when: 
       - ( check_nginx.stdout.find('successful'))
       - false
    - name: Service Nginx Server
      service: name=nginx state=started 

  handlers:
    - name: Restart Nginx Server
      service: name=nginx state=restarted
```
