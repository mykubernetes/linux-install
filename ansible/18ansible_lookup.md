# 使用lookup生成变量

## 1、简单说明

在通常情况下，所有的配置信息都会被作为ansible的变量保存了，而且可以保存在ansible允许定义变量的各种地方，诸如vars区段，vars_files加载的文件中，以及host_vars和group_vars目录中。

但在有些时候，我们希望从诸如文本文件或者.csv文件中收集数据作为ansible的变量，或者直接获取某些命令的输出作为ansible的变量，甚至从redis或者etcd这样的键值存储中取得相应的值作为ansible的变量。这个时候，我们就需要通过ansible的lookup插件来从这些数据源中读取配置数据，传递给ansbile变量，并在playbook或者模板中使用这些数据。

ansible支持一套从不同数据源获取数据的lookup，包括file, password, pipe, env, template, csvfile, dnstxt, redis_kv, etcd等

## 2、file

1、使用file lookup可以从文本文件中获取数据，并在这些数据传递给ansible变量，在task或者jinja2模板中进行引用。下面是一个从文本文件中获取ssh公钥并复制到远程主机的示例
```
# vim lookup_files_ex.yml

- hosts: node01
  tasks:
  - debug:
      msg: "{{ lookup('file','./hosts') }}"
```


```
# ansible-playbook lookup_files_ex.yml


TASK [debug] **********************************************************************************************************************************
ok: [demo2.example.com] => {
    "msg": "srv1.example.com\nsrv2.example.com\ns1.lab.example.com\ns2.lab.example.com\n\n[web]\njupiter.lab.example.com\nsaturn.example.com\n\n[db]\ndb1.example.com\ndb2.example.com\ndb3.example.com\n\n[lb]\nlb1.lab.example.com\nlb2.lab.example.com\n\n[boston]\ndb1.example.com\njupiter.lab.example.com\nlb2.lab.example.com\n\n[london]\ndb2.example.com\ndb3.example.com\nfile1.lab.example.com\nlb1.lab.example.com\n\n[dev]\nweb1.lab.example.com\ndb3.example.com\n\n[stage]\nfile2.example.com\ndb2.example.com\n\n[prod]\nlb2.lab.example.com\ndb1.example.com\njupiter.lab.example.com\n\n[function:children]\nweb\ndb\nlb\ncity\n\n[city:children]\nboston\nlondon\nenvironments\n\n[environments:children]\ndev\nstage\nprod\nnew\n\n[new]\n172.25.252.23\n172.25.252.44"
}
```

2、可以把这个获取的值，使用set_fact变量
```
- hosts: node01
  tasks:
  - set_fact: aaa={{ lookup('file','./hosts') }}
  - debug:
      msg: "{{ aaa }}"
```

```
- hosts: node01
  tasks:
  - set_fact:
      aaa: "{{ lookup('file','./hosts') }}"
  - debug:
      msg: "{{ aaa }}"
```

3、如果想要获取多个文件中的内容，则可以传入多个文件路径。
```
- hosts: all
  remote_user: root
  tasks:
  - set_fact: aaa={{ lookup('file','./hosts','./hosts1',wantlist=true) }}
  - debug:
      msg: "{{ aaa }}"
```
- 将每个文件的内容当做列表中的一个独立的字符串进行显示，使用`wantlist=true`参数


4、通过query函数调用lookup插件时默认行为是返回一个列表
```
- hosts: all
  remote_user: root
  tasks:
  - set_fact: aaa={{ lookup('file','./hosts','./hosts1',wantlist=true) }}
  - debug:
      msg: "{{ query('file','./hosts') }}"
```

query函数可以简写的`q`
```
- hosts: all
  remote_user: root
  tasks:
  - set_fact: aaa={{ lookup('file','./hosts','./hosts1',wantlist=true) }}
  - debug:
      msg: "{{ q('file','./hosts') }}"
```

5、使用errors关键字控制lookup插件出错时的处理机制，如果我想要在lookup插件执行出错时忽略错误，则可以将errors的值设置为ignore
```
- hosts: all
  remote_user: root
  tasks:
  - set_fact:
      aaa: "{{ lookup('file','./hosts','./hosts1',errors='ignore') }}"
  - debug:
      msg: "{{ q('file','./hosts') }}"
```

## 3、pipe

使用pipe lookup可以直接调用外部命令，并将命令执行的结果打印到标准输出，作为ansible变量。下面的例子通过pipe调用date指令拿到一个以时间数字组成的字串，获取的是服务端命令
```
# vim lookup_pipe_ex.yml

- hosts: node01
  tasks:
  - debug:
    msg: "{{ lookup('pipe','ip addr') }}"
```

```
# ansible-playbook lookup_pipe_ex.yml
TASK [debug] **********************************************************************************************************************************
ok: [demo2.example.com] => {
    "msg": "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000\n    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00\n    inet 127.0.0.1/8 scope host lo\n       valid_lft forever preferred_lft forever\n    inet6 ::1/128 scope host \n       valid_lft forever preferred_lft forever\n2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000\n    link/ether 00:0c:29:91:dd:19 brd ff:ff:ff:ff:ff:ff\n    inet 192.168.132.131/24 brd 192.168.132.255 scope global noprefixroute ens33\n       valid_lft forever preferred_lft forever\n    inet6 fe80::bcf9:af19:a325:e2c7/64 scope link noprefixroute \n       valid_lft forever preferred_lft forever\n3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default \n    link/ether 02:42:00:5f:59:93 brd ff:ff:ff:ff:ff:ff\n    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0\n       valid_lft forever preferred_lft forever\n    inet6 fe80::42:ff:fe5f:5993/64 scope link \n       valid_lft forever preferred_lft forever"
}
```

## 4、env

env lookup实际就是获取在控制主机上的某个环境变量的值。下面是一个读取控制机上$JAVA_HOME变量值的示例：
```
- name: get JAVA_HOME
  debug: msg="{{ lookup('env', 'JAVA_HOME')}}"
```

## 5、csvfile

csvfile可以从.csv文件中读取一个条目。假设我们有如下示例的名为users.csv的文件：
```
# vim test.csv
username,email,gender
lorin,lorin@test.com,female
john,john@example.com,female
sue,sue@exmaple.com,male


# vim lookup_csvf_ex.yml
- name: get sue's email
  hosts: demo2.example.com  
  tasks:
  - debug: 
      msg: "{{ lookup('csvfile','sue file=test.csv delimiter=, col=1')}}"
```
可以看到，一共向插件传递了四个参数：sue, file=test.csv, delimiter=,以及col=1。说明如下：
- 第一个参数指定一个名字，该名字必须出现在其所在行的第0列，需要说明的是，如果指定的第一个参数名字在文件中出现多次，则匹配第一次出现的结果
- 第二个参数指定csv文件的文件名
- 第三个参数指定csv文件的中条目的分隔符，
- 第四个参数指定要取得哪一列的值，这一列正是第一个参数所在行的那一列的值

```
[root@node1 ansible]# ansible-playbook lookup_csvf_ex.yml

TASK [debug] **********************************************************************************************************************************
ok: [demo2.example.com] => {
    "msg": "sue@exmaple.com"
}
```

## 使用pipe，执行awk
```
# cat lookup_csvf_ex.yml
- name: get sue's email
  hosts: demo2.example.com  
  tasks:
  - debug: 
      msg: "{{ lookup('csvfile','sue file=test.csv delimiter=, col=1')}}"
  - debug: 
      msg: lookup('pipe',"awk -F , '$1 ~/sue/ {print $2}' test.csv" )
```

执行
```
# ansible-playbook lookup_csvf_ex.yml

TASK [debug] **********************************************************************************************************************************
ok: [demo2.example.com] => {
    "msg": "sue@exmaple.com"
}
TASK [debug] **********************************************************************************************************************************
ok: [demo2.example.com] => {
    "msg": "lookup('pipe',\"awk -F , '$1 ~/sue/ {print $2}' test.csv\" )"
}
```

## 6、redis_kv

redis_kv lookup可以直接从redis存储中来获取一个key的value，key必须是一个字符串，如同Redis GET指令一样。需要注意的是，要使用redis_kv lookup，需要在主控端安装python的redis客户端，在centos上，软件包为python-redis。

下面是一个在playbook中调用redis lookup的task，从本地的redis中取中一个key为weather的值
```
- name: lookup value in redis
  debug: msg="{{ lookup('redis_kv', 'redis://localhost:6379,weather')}}"
```
 
其中URL部分如果不指定，该模块会默认连接到redis://localhost:6379，所以实际上在上面的实例中，调用可以直接写成如下
```
{{ lookup('redis_kv', 'weather')}}
```

## 7、etcd

etcd是一个分布式的key-value存储，通常被用于保存配置信息或者被用于实现服务发现。可以使用etcd lookup来从etcd中获取指定key的value。

我们通过如下方法往一个etcd中写入一个key：
```
curl -L http://127.0.0.1:2379/v2/keys/weather -XPUT -d value=sunny
```
定义一个调用etcd插件的task
```
- name: look up value in etcd
  debug: msg="{{ lookup('etcd','weather')}}"
```
默认情况下，etcd lookup会在http://127.0.0.1:4001上查找etcd服务器。但我们在执行playbook之前可以通过设置ANSIBLE_ETCD_URL环境变量来修改这个设置。

## 8、password

password lookup会随机生成一个密码，并将这个密码写入到参数指定的文件中。如下示例，创建一个名为bob的mysql用户，并随机生成该用户的密码，并将密码写入到主控端的bob-password.txt中
```
- name: create deploy mysql user
  mysql_user: name=bob password={{ lookup('password', 'bob-password,txt')}} priv=*.*:ALL state=present
```

## 9、dnstxt

dnstxt lookup用于获取指定域名的TXT记录。需要在主控端安装python-dns。

```
- name: lookup TXT record
  debug: msg="{{ lookup('dnstxt', "aliyun.com") }}"
```

## 10、first_found插件可以获取列表中第一个找到的文件

按照列表顺序在ansible主机中查找
```
- hosts: all
  remote_user: root
  tasks:
  - debug:
      msg: "{{ lookup('first_found',looklist) }}"
  vars:
    looklist:
      - /opt/lookup/test
      - /tmp
```

当使用with_first_found时，可以在列表的最后添加- skip: true

表示如果列表中的所有文件都没有找到，则跳过当前任务,不会报错

当不确定有文件能够被匹配到时，推荐这种方式
```
- hosts: all
  remote_user: root
  tasks:
  - debug:
      msg: "{{item}}"
    with_first_found:
      - /testdir1
      - /tmp/staging
      - skip: true
```

## 11、dig插件可以获取指定域名的IP地址
- 此插件依赖dnspython库,可使用pip安装pip install dnspython
- 如果域名使用了CDN，可能返回多个地址
```
- hosts: all
  remote_user: root
  tasks:
  - debug:
      msg: "{{ lookup('dig','www.baidu.com',wantlist=true) }}"
```

##  12、ini插件可以在ansible主机中的ini文件中查找对应key的值

1、如下示例表示从test.ini文件中的testA段落中查找testa1对应的值
```
# vim /testdir/test.ini
[testA]
testa1=Andy
testa2=Armand

[testB]
testb1=Ben
```

```
  - debug:
      msg: "{{ lookup('ini','testa1 section=testA file=/testdir/test.ini') }}"
```
2、当未找到对应key时，默认返回空字符串，如果想要指定返回值，可以使用default选项,如下
```
msg: "{{ lookup('ini','test666 section=testA file=/testdir/test.ini default=notfound') }}"
```

3、可以使用正则表达式匹配对应的键名，需要设置re=true，表示开启正则支持,如下
```
#msg: "{{ lookup('ini','testa[12] section=testA file=/testdir/test.ini re=true') }}"
```

4、ini插件除了可以从ini类型的文件中查找对应key，也可以从properties类型的文件中查找key

#默认在操作的文件类型为ini，可以使用type指定properties类型，如下例所示
```
# vim /testdir/pplication.properties
http.port=8080
redis.no=0
imageCode = 1,2,3
```

```
  - debug:
      msg: "{{ lookup('ini','http.port type=properties file=/testdir/application.properties') }}"
```
