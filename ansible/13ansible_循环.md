
# 循环语句

| 循环语句关键字 | 描述 |
|--------------|-------|
| with_items  | 简单的列表循环 |
| with_nested | 嵌套循环 |
| with_dict | 循环字典 |
| with_fileglob | 循环指定目录中的所有文件 |
| with_lines | 循环一个文件中的所有行 |
| with_sequence | 生成一个自增的整数序列，可以指定起始值和结束值以及步长。参数以key=value的形式指定，format指定输出的格式。数字可以是十进制、十六进制、八进制 |
| with_subelement | 遍历子元素 |
| with_together | 遍历数据并行集合 |

- 旧循环语句（版本在2.5之前仅有的),这些语句使用with_作为前缀,些语法目前仍然兼容，但在未来的某个时间点，会逐步废弃。
- with_items、with_list、loop迭代,ansible2.5版本之后将with_items、with_list迁移至loop

## 1、with_items循环

### 1）假设有一个清单配置
```
10.1.1.60
test70.zsythink.net ansible_host=10.1.1.70
test71 anisble_host=10.1.1.71
 
[testA]
test60 ansible_host=10.1.1.60
test61 ansible_host=10.1.1.61
 
[testB]
test70 ansible_host=10.1.1.70
 
[test:children]
testA
testB
```

### 2）想要获取到清单中所有未分组的主机的主机名,返回信息可以看出，一共有3个未分组主机
```
# ansible test70 -m debug -a "msg={{groups.ungrouped}}"
test70 | SUCCESS => {
    "changed": false,
    "msg": [
        "10.1.1.60",
        "test70.zsythink.net",
        "test71"
    ]
}
```

### 4)获取到上述返回信息中的第二条信息
```
# ansible test70 -m debug -a "msg={{groups.ungrouped[1]}}"
test70 | SUCCESS => {
    "changed": false,
    "msg": "test70.zsythink.net"
}
```

### 5)但是通常不能确定返回信息有几条，可能需要循环的处理返回信息中的每一条信息
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_items: "{{groups.ungrouped}}"
```

```
TASK [debug] *********************************************
ok: [test70] => (item=10.1.1.60) => {
    "changed": false,
    "item": "10.1.1.60",
    "msg": "10.1.1.60"
}
ok: [test70] => (item=test70.zsythink.net) => {
    "changed": false,
    "item": "test70.zsythink.net",
    "msg": "test70.zsythink.net"
}
ok: [test70] => (item=test71) => {
    "changed": false,
    "item": "test71",
    "msg": "test71"
}
```

### 6)循环使用列表中的值

方法一
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_items:
    - 1
    - 2
    - 3
```

方法二
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_items: [ 1, 2, 3 ]
```

### 7)稍微复杂一点的循环

第一个条目的test1键对应的值是a，第二个条目的test1键对应的值是c，所以执行上例playbook以后，”a”和”c”会被输出
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item.test1}}"
    with_items:
    - { test1: a, test2: b }
    - { test1: c, test2: d }
```

### 8）使用循环创建文件

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    dirs:
    - "/opt/a"
    - "/opt/b"
    - "/opt/c"
    - "/opt/d"
  tasks:
  - file:
      path: "{{item}}"
      state: touch
    with_items: "{{dirs}}"
```

### 9)每次shell模块执行后的返回值都会放入一个名为`results`的序列中,`results`也是一个返回值，当模块中使用了循环时，模块每次执行的返回值都会追加存放到`results`这个返回值中
```
---
- hosts: test70
  gather_facts: no
  tasks:
  - shell: "{{item}}"
    with_items:
    - "ls /opt"
    - "ls /home"
    register: returnvalue
  - debug:
      msg: "{{item.stdout}}"
    with_items: "{{returnvalue.results}}"
```

```
---
- hosts: test70
  gather_facts: no
  tasks:
  - shell: "{{item}}"
    with_items:
    - "ls /opt"
    - "ls /home"
    register: returnvalue
  - debug:
      msg:
       "{% for i in returnvalue.results %}
          {{ i.stdout }}
        {% endfor %}"
```























