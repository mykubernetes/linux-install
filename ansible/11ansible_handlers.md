# handlers

- notify：在任务结束时触发
- handlers：由特定条件触发Tasks

## 1、只有redis配置文件被修改后才重新redis服务
```
- hosts: node01
  remote_user: root
  tasks:
   - name: install redis
     yum: name=redis state=present
   - name: copy config file
     copy: src=/opt/src/redis.conf dest=/etc/redis.conf owner=redis
     notify: restart redis
     tags: conf
   - name: start redis
     service: name=redis state=started enabled=true
  handlers:
   - name: restart redis
     service: name=redis state=restarted



# ansible-playbook first.yaml                #运行playbook
# ansible-playbook -t conf first.yaml        #运行tags里的命令
```  
- 1.无论多少个task通知了相同的handlers，handlers仅会在所有tasks结束后运行一次。
- 2.只有task发生改变了才会通知handlers，没有改变则不会触发handlers。
- 3.不能使用handlers替代tasks、因为handlers是一个特殊的tasks。


## 2、一个task中调用多个handler

- listen 可以把listen理解成"组名",可以把多个handler分成"组"  

```
- hosts: testB
  remote_user: root
  tasks:
  - name: task1
    file: path=/testdir/testfile
          state=touch
    notify: handler group1

  handlers:
  - name: handler1
    listen: handler group1
    file: path=/testdir/ht1
          state=touch
  - name: handler2
    listen: handler group1
    file: path=/testdir/ht2
          state=touch
```

## 3、meta模块

- 默认情况下，所有task执行完毕后，才会执行各个handler，并不是执行完某个task后，立即执行对应的handler，如果想要在执行完某些task以后立即执行对应的handler，则需要使用meta模块

```
- hosts: testB
  remote_user: root
  tasks:
  - name: task1
    file: path=/testdir/testfile
          state=touch
    notify: handler1
  - name: task2
    file: path=/testdir/testfile2
          state=touch
    notify: handler2

  - meta: flush_handlers

  - name: task3
    file: path=/testdir/testfile3
          state=touch
    notify: handler3

  handlers:
  - name: handler1
    file: path=/testdir/ht1
          state=touch
  - name: handler2
    file: path=/testdir/ht2
          state=touch
  - name: handler3
    file: path=/testdir/ht3
          state=touch
```

## 4、force_handelers强制执行handlers  

- 通常任务失败会终止，force_handelers可以在任务失败后任然执行处理程序，要写在剧本中
```
- hosts
  force_handelers: yes
  tasks: 
    .........................
```
