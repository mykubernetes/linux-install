
# 循环语句

| 循环语句关键字 | 描述 |
|--------------|-------|
| [with_items](#with_items) | 简单的列表循环 |
| [with_flattened](#with_flattened) | 与with_items类似 |
| [with_list](#with_list) | 每个嵌套在大列表中的小列表都被当做一个整体存放在item变量中 |
| [with_together](#with_together) | 可以将两个列表中的元素`对齐合并`,遍历数据并行集合 | 
| [with_cartesian](#with_cartesian) | 关键字的作用就是将每个小列表中的元素按照`笛卡尔的方式`组合后，循环的处理每个组合 |
| [with_indexed_items](#with_indexed_items) | 在循环处理列表时为列表中的每一项添加`数字索引`，`索引`从0开始 |
| [with_sequence](#with_sequence) | 按照顺序生成数字序列，`start=1 end=5 stride=1`，其中start=1表示从1开始，end=5表示到5结束， stride=1表示步长为1 |
| [with_random_choice](#with_random_choice) | 可以从列表的多个值中随机返回一个值 |
| [with_file](#with_file) | 循环获取文件的内容 | 
| [with_nested](#with_nested) | 嵌套循环,`ith_nested`与`with_cartesian`的效果一致，可以无差别使用他们 |
| [with_dict](#with_dict) | 循环字典 |
| [with_fileglob](#with_fileglob) | 循环指定目录中的所有文件 |
| [with_lines](#with_lines) | 指令后跟一个命令，ansible会遍历命令的输出 |
| [with_subelement](#with_subelements) | 遍历子元素 |

- 旧循环语句（版本在2.5之前仅有的),这些语句使用with_作为前缀,些语法目前仍然兼容，但在未来的某个时间点，会逐步废弃。
- with_items、with_list、loop迭代,ansible2.5版本之后将with_items、with_list迁移至loop

with_list与 with_items一样，也是用于循环列表。区别是，如果列表的值也是列表，with_iems会将第一层嵌套的列表拉平，而with_list会将值作为一个整体返回。with_flatten会将所有列表全部拉平

[[1,2,[3,4]],[5,6],7,8]   
- with_item------->[1,2,[3,4],5,6,7,8]    拉平第一层
- with_list--------->[[1,2,[3,4]],[5,6],7,8]   整体返回
- with_flatten----->[1,2,3,4,5,6,7,8]     全部拉平


# with_items

## 一、with_items 循环

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

```
ok: [node01] => (item={u'test1': u'a', u'test2': u'b'}) => {
    "msg": "a"
}
ok: [node01] => (item={u'test1': u'c', u'test2': u'd'}) => {
    "msg": "c"
}
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

# with_list

# 二、with_list 循环

## 1）with_list和with_items的区别

### with_items 会将第一层嵌套的列表拉平
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_items:
    - [1,2,[3,4]]
    - [5,6]
    - 7
    - 8
```

```
ok: [node01] => (item=1) => {
    "msg": 1
}
ok: [node01] => (item=2) => {
    "msg": 2
}
ok: [node01] => (item=[3, 4]) => {
    "msg": [
        3, 
        4
    ]
}
ok: [node01] => (item=5) => {
    "msg": 5
}
ok: [node01] => (item=6) => {
    "msg": 6
}
ok: [node01] => (item=7) => {
    "msg": 7
}
ok: [node01] => (item=8) => {
    "msg": 8
}
```

### with_list 会将值作为一个整体返回
```
- hosts: node01
  remote_user: root
  tasks:
  - debug:
      msg: "{{item}}"
    with_list:
    - [1,2,[3,4]]
    - [5,6]
    - 7
    - 8
```

```
ok: [node01] => (item=[1, 2, [3, 4]]) => {
    "msg": [
        1, 
        2, 
        [
            3, 
            4
        ]
    ]
}
ok: [node01] => (item=[5, 6]) => {
    "msg": [
        5, 
        6
    ]
}
ok: [node01] => (item=7) => {
    "msg": 7
}
ok: [node01] => (item=8) => {
    "msg": 8
}
```
- 当处理单层的简单列表时，with_list与with_items没有任何区别

### 通过缩进对齐的方式，定义一个嵌套的列表
```
    with_list:
    -
      - 1
      - 2
      - 3
    -
      - a
      - b

或者
    with_list:
    - [ 1, 2, 3 ]
    - [ a, b ]
```


# with_flattened

## 三、with_flattened 循环

- 将列表中的元素全部拉平

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_flattened:
    - [1,2,[3,4]]
    - [5,6]
    - 7
    - 8
```

```
ok: [node01] => (item=1) => {
    "msg": 1
}
ok: [node01] => (item=2) => {
    "msg": 2
}
ok: [node01] => (item=3) => {
    "msg": 3
}
ok: [node01] => (item=4) => {
    "msg": 4
}
ok: [node01] => (item=5) => {
    "msg": 5
}
ok: [node01] => (item=6) => {
    "msg": 6
}
ok: [node01] => (item=7) => {
    "msg": 7
}
ok: [node01] => (item=8) => {
    "msg": 8
}
```

# with_together

## 四、with_together 循环可以将两个列表中的元素`对齐合并`

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_together:
    - [ 1, 2, 3 ]
    - [ a, b, c ]
```

```
TASK [debug] ******************************
ok: [test70] => (item=[1, u'a']) => {
    "changed": false,
    "item": [
        1,
        "a"
    ],
    "msg": [
        1,
        "a"
    ]
}
ok: [test70] => (item=[2, u'b']) => {
    "changed": false,
    "item": [
        2,
        "b"
    ],
    "msg": [
        2,
        "b"
    ]
}
ok: [test70] => (item=[3, u'c']) => {
    "changed": false,
    "item": [
        3,
        "c"
    ],
    "msg": [
        3,
        "c"
    ]
}
```
- 第一个小列表中的第1个值与第二个小列表中的第1个值合并在一起输出
- 第一个小列表中的第2个值与第二个小列表中的第2个值合并在一起输出
- 第一个小列表中的第3个值与第二个小列表中的第3个值合并在一起输出

# with_cartesian

## 五、with_cartesian 循环

### 1）第一个小列表中的每个元素与第二个小列表中的每个元素都”两两组合在了一起”
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_cartesian:
    - [ a, b, c ]
    - [ test1, test2 ]
```

```
TASK [debug] ***********************************
ok: [test70] => (item=[u'a', u'test1']) => {
    "changed": false,
    "item": [
        "a",
        "test1"
    ],
    "msg": [
        "a",
        "test1"
    ]
}
ok: [test70] => (item=[u'a', u'test2']) => {
    "changed": false,
    "item": [
        "a",
        "test2"
    ],
    "msg": [
        "a",
        "test2"
    ]
}
ok: [test70] => (item=[u'b', u'test1']) => {
    "changed": false,
    "item": [
        "b",
        "test1"
    ],
    "msg": [
        "b",
        "test1"
    ]
}
ok: [test70] => (item=[u'b', u'test2']) => {
    "changed": false,
    "item": [
        "b",
        "test2"
    ],
    "msg": [
        "b",
        "test2"
    ]
}
ok: [test70] => (item=[u'c', u'test1']) => {
    "changed": false,
    "item": [
        "c",
        "test1"
    ],
    "msg": [
        "c",
        "test1"
    ]
}
ok: [test70] => (item=[u'c', u'test2']) => {
    "changed": false,
    "item": [
        "c",
        "test2"
    ],
    "msg": [
        "c",
        "test2"
    ]
}
```


### 2）在目标主机的测试目录中创建a、b、c三个目录，这三个目录都有相同的子目录，它们都有test1和test2两个子目录
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - file:
      state: directory
      path: "/testdir/testdir/{{ item.0 }}/{{ item.1 }}"
    with_cartesian:
    - [ a, b, c ]
    - [ test1, test2 ]
```

# with_indexed_items

## 六、with_indexed_items循环

### 1)with_indexed_items 在循环的时候会添加索引索引
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_indexed_items:
    - test1
    - test2
    - test3
```

```
TASK [debug] **********************************
ok: [test70] => (item=(0, u'test1')) => {
    "changed": false,
    "item": [
        0,
        "test1"
    ],
    "msg": [
        0,
        "test1"
    ]
}
ok: [test70] => (item=(1, u'test2')) => {
    "changed": false,
    "item": [
        1,
        "test2"
    ],
    "msg": [
        1,
        "test2"
    ]
}
ok: [test70] => (item=(2, u'test3')) => {
    "changed": false,
    "item": [
        2,
        "test3"
    ],
    "msg": [
        2,
        "test3"
    ]
}
```

### 2)处理每一项的时候同时获取到对应的编号

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is : {{ item.0 }} , value is {{ item.1 }}"
    with_indexed_items:
    - test1
    - test2
    - test3
```

### 3)多层嵌套列表显示索引编号

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is : {{ item.0 }} , value is {{ item.1 }}"
    with_indexed_items:
    - [ test1, test2 ]
    - [ test3, test4, test5 ]
    - [ test6, test7 ]
```

```
TASK [debug] *****************************
ok: [test70] => (item=(0, u'test1')) => {
    "changed": false,
    "item": [
        0,
        "test1"
    ],
    "msg": "index is : 0 , value is test1"
}
ok: [test70] => (item=(1, u'test2')) => {
    "changed": false,
    "item": [
        1,
        "test2"
    ],
    "msg": "index is : 1 , value is test2"
}
ok: [test70] => (item=(2, u'test3')) => {
    "changed": false,
    "item": [
        2,
        "test3"
    ],
    "msg": "index is : 2 , value is test3"
}
ok: [test70] => (item=(3, u'test4')) => {
    "changed": false,
    "item": [
        3,
        "test4"
    ],
    "msg": "index is : 3 , value is test4"
}
ok: [test70] => (item=(4, u'test5')) => {
    "changed": false,
    "item": [
        4,
        "test5"
    ],
    "msg": "index is : 4 , value is test5"
}
ok: [test70] => (item=(5, u'test6')) => {
    "changed": false,
    "item": [
        5,
        "test6"
    ],
    "msg": "index is : 5 , value is test6"
}
ok: [test70] => (item=(6, u'test7')) => {
    "changed": false,
    "item": [
        6,
        "test7"
    ],
    "msg": "index is : 6 , value is test7"
}
```

### 4)`with_indexed_items`会将嵌套的两层列表`拉平`，`拉平`后按照顺序为每一项编号,`拉平`效果跟`with_flattened`效果类似.但是，当处理这种嵌套的多层列表时，`with_indexed_items`的拉平效果与`with_flattened`的不完全一致

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_indexed_items:
    - [ test1, test2 ]
    - [ test3, [ test4, test5 ] ]
    - [ test6 ]
```


```
TASK [debug] ********************************
ok: [test70] => (item=(0, u'test1')) => {
    "changed": false,
    "item": [
        0,
        "test1"
    ],
    "msg": [
        0,
        "test1"
    ]
}
ok: [test70] => (item=(1, u'test2')) => {
    "changed": false,
    "item": [
        1,
        "test2"
    ],
    "msg": [
        1,
        "test2"
    ]
}
ok: [test70] => (item=(2, u'test3')) => {
    "changed": false,
    "item": [
        2,
        "test3"
    ],
    "msg": [
        2,
        "test3"
    ]
}
ok: [test70] => (item=(3, [u'test4', u'test5'])) => {
    "changed": false,
    "item": [
        3,
        [
            "test4",
            "test5"
        ]
    ],
    "msg": [
        3,
        [
            "test4",
            "test5"
        ]
    ]
}
ok: [test70] => (item=(4, u'test6')) => {
    "changed": false,
    "item": [
        4,
        "test6"
    ],
    "msg": [
        4,
        "test6"
    ]
}
```
- 当多加了一层嵌套以后，`with_indexed_items`并不像`with_flattened`一样将嵌套的列表`完全拉平`，第二层列表中的项如果仍然是一个列表，`with_indexed_items`则不会拉平这个列表，而是将其当做一个整体进行编号。


# with_sequence

## 七、with_sequence

### 1)设置起始值为1，最大五，步长为1

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_sequence: start=1 end=5 stride=1
    
#    with_sequence:
#      start=1
#      end=5
#      stride=1
```

```
TASK [debug] ***************************
ok: [test70] => (item=1) => {
    "changed": false,
    "item": "1",
    "msg": "1"
}
ok: [test70] => (item=2) => {
    "changed": false,
    "item": "2",
    "msg": "2"
}
ok: [test70] => (item=3) => {
    "changed": false,
    "item": "3",
    "msg": "3"
}
ok: [test70] => (item=4) => {
    "changed": false,
    "item": "4",
    "msg": "4"
}
ok: [test70] => (item=5) => {
    "changed": false,
    "item": "5",
    "msg": "5"
}
```

### 2)count=5表示数字序列默认从1开始，到5结束，默认步长为1
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_sequence: count=5
```

### 3)不指定stride的值时，stride的值默认为1，但是当end的值小于start的值时，则必须指定stride的值，而且stride的值必须是负数

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_sequence: start=6 end=2 stride=-2
```

```
TASK [debug] ***************************
ok: [test70] => (item=6) => {
    "changed": false,
    "item": "6",
    "msg": "6"
}
ok: [test70] => (item=4) => {
    "changed": false,
    "item": "4",
    "msg": "4"
}
ok: [test70] => (item=2) => {
    "changed": false,
    "item": "2",
    "msg": "2"
}
```

### 4)使用with_sequence循环创建目录

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - file:
      path: "/testdir/testdir/test{{ item }}"
      state: directory
    with_sequence:
      start=2
      end=10
      stride=2
```

### 5）with_sequence `格式化`输出数据

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_sequence: start=2 end=6 stride=2 format="number is %0.2f"
```

```
TASK [debug] ***************************
ok: [test70] => (item=number is 2.00) => {
    "changed": false,
    "item": "number is 2.00",
    "msg": "number is 2.00"
}
ok: [test70] => (item=number is 4.00) => {
    "changed": false,
    "item": "number is 4.00",
    "msg": "number is 4.00"
}
ok: [test70] => (item=number is 6.00) => {
    "changed": false,
    "item": "number is 6.00",
    "msg": "number is 6.00"
}
```

# with_random_choice

## 八、with_random_choice循环
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{item}}"
    with_random_choice:
    - 1
    - 2
    - 3
    - 4
    - 5
```

# with_dict

## 九、with_dict字典循环

### 1)使用字典的方式定义了users变量，users中一共有两个用户，alice和bob，从变量的键值对可以看出，alice是女性，bob是男性
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    users:
      alice: female
      bob: male
  tasks:
  - debug:
      msg: "{{item}}"
    with_dict: "{{users}}"
```

```
TASK [debug] *************************************
ok: [test70] => (item={'value': u'male', 'key': u'bob'}) => {
    "changed": false,
    "item": {
        "key": "bob",
        "value": "male"
    },
    "msg": {
        "key": "bob",
        "value": "male"
    }
}
ok: [test70] => (item={'value': u'female', 'key': u'alice'}) => {
    "changed": false,
    "item": {
        "key": "alice",
        "value": "female"
    },
    "msg": {
        "key": "alice",
        "value": "female"
    }
}
```

### 2)字典中的每个键值对被放到了item变量中，而且，键值对中的”键”被放入了”key”关键字中，键值对中的”值”被放入了”value”关键字中
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    users:
      alice: female
      bob: male
  tasks:
  - debug:
      msg: "User name: {{item.key}} , User's gender: {{item.value}} "
    with_dict: "{{users}}"
```

```
TASK [debug] ************************************************
ok: [test70] => (item={'value': u'male', 'key': u'bob'}) => {
    "changed": false,
    "item": {
        "key": "bob",
        "value": "male"
    },
    "msg": "User name: bob , User's gender: male "
}
ok: [test70] => (item={'value': u'female', 'key': u'alice'}) => {
    "changed": false,
    "item": {
        "key": "alice",
        "value": "female"
    },
    "msg": "User name: alice , User's gender: female "
}
```

### 3)将alice和bob的信息完善了，每个人都有自己姓名，性别，电话等信息

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    users:
      alice:
        name: Alice Appleworth
        gender: female
        telephone: 123-456-7890
      bob:
        name: Bob Bananarama
        gender: male
        telephone: 987-654-3210
  tasks:
  - debug:
      msg: "{{item}}"
    with_dict: "{{users}}"
```

```
TASK [debug] *****************************************
ok: [test70] => (item={'value': {u'gender': u'male', u'name': u'Bob Bananarama', u'telephone': u'987-654-3210'}, 'key': u'bob'}) => {
    "changed": false,
    "item": {
        "key": "bob",
        "value": {
            "gender": "male",
            "name": "Bob Bananarama",
            "telephone": "987-654-3210"
        }
    },
    "msg": {
        "key": "bob",
        "value": {
            "gender": "male",
            "name": "Bob Bananarama",
            "telephone": "987-654-3210"
        }
    }
}
ok: [test70] => (item={'value': {u'gender': u'female', u'name': u'Alice Appleworth', u'telephone': u'123-456-7890'}, 'key': u'alice'}) => {
    "changed": false,
    "item": {
        "key": "alice",
        "value": {
            "gender": "female",
            "name": "Alice Appleworth",
            "telephone": "123-456-7890"
        }
    },
    "msg": {
        "key": "alice",
        "value": {
            "gender": "female",
            "name": "Alice Appleworth",
            "telephone": "123-456-7890"
        }
    }
}
```

### 4)将字典遍历到变量中使用
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    users:
      alice:
        name: Alice Appleworth
        gender: female
        telephone: 123-456-7890
      bob:
        name: Bob Bananarama
        gender: male
        telephone: 987-654-3210
  tasks:
  - debug:
      msg: "User {{ item.key }} is {{ item.value.name }}, Gender: {{ item.value.gender }}, Tel: {{ item.value.telephone }}"
    with_dict: "{{users}}"
```


# with_subelements

## 十、with_subelements循环

### 1)复合结构的字典变量，`users`变量，`users`变量列表中有两个块序列，这两个块序列分别代表两个用户，bob和alice，alice是个妹子，bob是个汉子，bob的爱好是滑板和打游戏，alice的爱好是听音乐,在处理`users`变量的同时，还指定了一个属性，`hobby`属性是`users`变量中每个用户的`子属性`
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    users:
    - name: bob
      gender: male
      hobby:
        - Skateboard
        - VideoGame
    - name: alice
      gender: female
      hobby:
        - Music
  tasks:
  - debug:
      msg: "{{ item }}"
    with_subelements:
    - "{{users}}"
    - hobby
```

```
TASK [debug] ***********************************************************
ok: [test70] => (item=({u'gender': u'male', u'name': u'bob'}, u'Skateboard')) => {
    "changed": false,
    "item": [
        {
            "gender": "male",
            "name": "bob"
        },
        "Skateboard"
    ],
    "msg": [
        {
            "gender": "male",
            "name": "bob"
        },
        "Skateboard"
    ]
}
ok: [test70] => (item=({u'gender': u'male', u'name': u'bob'}, u'VideoGame')) => {
    "changed": false,
    "item": [
        {
            "gender": "male",
            "name": "bob"
        },
        "VideoGame"
    ],
    "msg": [
        {
            "gender": "male",
            "name": "bob"
        },
        "VideoGame"
    ]
}
ok: [test70] => (item=({u'gender': u'female', u'name': u'alice'}, u'Music')) => {
    "changed": false,
    "item": [
        {
            "gender": "female",
            "name": "alice"
        },
        "Music"
    ],
    "msg": [
        {
            "gender": "female",
            "name": "alice"
        },
        "Music"
    ]
}
```

###  2)通过item.0获取到第一个小整体，即gender和name属性，然后通过item.1获取到第二个小整体，即hobby列表中的每一项
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    users:
    - name: bob
      gender: male
      hobby:
        - Skateboard
        - VideoGame
    - name: alice
      gender: female
      hobby:
        - Music
  tasks:
  - debug:
      msg: "{{ item.0.name }} 's hobby is {{ item.1 }}"
    with_subelements:
    - "{{users}}"
    - hobby
```

```
"msg": "bob 's hobby is Skateboard"
"msg": "bob 's hobby is VideoGame"
"msg": "alice 's hobby is Music"
```

# with_file

## 十一、with_file循环获取文件内容

### 1)列表中有两个文件路径，分别是”/testdir/testdir/a.log”和”/opt/testfile”，这两个文件都是ansible主机中的文件，通过`with_file`关键字处理了这个列表
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_file:
    - /testdir/testdir/a.log
    - /opt/testfile
```

```
TASK [debug] *******************
ok: [test70] => (item=aaa) => {
    "changed": false,
    "item": "aaa",
    "msg": "aaa"
}
ok: [test70] => (item=test) => {
    "changed": false,
    "item": "test",
    "msg": "test"
}
```
- 无论目标主机是谁，都可以通过`with_file`关键字获取到ansible主机中的文件内容

# with_fileglob

## 十二、with_fileglob匹配文件名称

- 通过`with_fileglob`关键字，在指定的目录中匹配符合模式的文件名，`with_file`与`with_fileglob`也有相同的地方，它们都是针对ansible主机的文件进行操作的，而不是目标主机

### 1)定义了一个列表，这个列表中只有一个值，这个值是一个路径，路径中包含一个通配符,按照我们通常的理解，`/testdir/*`应该代表了`/testdir`目录中的所有文件
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_fileglob:
    - /testdir/*
```

```
TASK [debug] *************************
ok: [test70] => (item=/testdir/testfile) => {
    "changed": false,
    "item": "/testdir/testfile",
    "msg": "/testdir/testfile"
}
ok: [test70] => (item=/testdir/test.sh) => {
    "changed": false,
    "item": "/testdir/test.sh",
    "msg": "/testdir/test.sh"
}
```

可以看出`/testdir`目录有四项，两项是目录，两项是文件，剧本中只匹配到文件，不包含目录，所以`with_fileglob`只会匹配指定目录中的文件，而不会匹配指定目录中的目录
```
# ll /testdir
total 16
drwxr-xr-x 2 root root 4096 Jul 27 17:26 ansible
drwxr-xr-x 2 root root 4096 Jul 19 16:05 testdir
-rw-r--r-- 1 root root   99 May 25 14:06 testfile
-rwxr--r-- 1 root root   81 Mar 17 13:28 test.sh
```

### 2)指定多个路径
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ item }}"
    with_fileglob:
    - /testdir/*
    - /opt/test*.???
```
- 第一项表示匹配”/testdir”目录下的文件，第二项表示匹配”/opt”目录下，以”test”开头，以”. 任意3个字符”结尾的文件，比如”testa.123″或者”testfile.yml


# with_lines

## 十三、with_lines
```
- hosts: node001
  remote_user: root
  tasks:
  - name: "command line"
    debug: 
      msg: "{{ item }} is a line from /etc/hosts"
    with_lines:
      - cat /etc/hosts
```

```
# ansible-playbook -i host test1.yml 

ok: [192.168.101.69] => (item=127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4) => {
    "msg": "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 is a line from /etc/hosts"
}
ok: [192.168.101.69] => (item=::1         localhost localhost.localdomain localhost6 localhost6.localdomain6) => {
    "msg": "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6 is a line from /etc/hosts"
}
ok: [192.168.101.69] => (item=192.168.101.69 node01) => {
    "msg": "192.168.101.69 node01 is a line from /etc/hosts"
}
ok: [192.168.101.69] => (item=192.168.101.70 node02) => {
    "msg": "192.168.101.70 node02 is a line from /etc/hosts"
}
ok: [192.168.101.69] => (item=192.168.101.71 node03) => {
    "msg": "192.168.101.71 node03 is a line from /etc/hosts"
}
ok: [192.168.101.69] => (item=192.168.101.69 192.168.101.69 node01 node01) => {
    "msg": "192.168.101.69 192.168.101.69 node01 node01 is a line from /etc/hosts"
}
ok: [192.168.101.69] => (item=192.168.101.80 192.168.101.80) => {
    "msg": "192.168.101.80 192.168.101.80 is a line from /etc/hosts"
}
```

# with_nested

## 十四、with_nested

- 嵌套循环，相当于像个for

```
# vim with_items.yml

- hosts: demo2.example.com
  gather_facts: no 
  tasks:
    - debug: msg="name is {{ item[0] }}  vaule is {{ item[1] }} num is {{ item[2] }}"
      with_nested:
        - ['alice','bob']
        - ['a','b','c']
        - ['1','2','3']

```
- item[0]是循环的第一个列表的值["alice","bob"] item[1]是第二个列表的值;以上的执行输出如下:

```
# ansible-playbook with_items.yml

ok: [demo2.example.com] => (item=[u'alice', u'a', u'1']) => {
    "msg": "name is alice  vaule is a num is 1"
}
ok: [demo2.example.com] => (item=[u'alice', u'a', u'2']) => {
    "msg": "name is alice  vaule is a num is 2"
}
ok: [demo2.example.com] => (item=[u'alice', u'a', u'3']) => {
    "msg": "name is alice  vaule is a num is 3"
}
ok: [demo2.example.com] => (item=[u'alice', u'b', u'1']) => {
    "msg": "name is alice  vaule is b num is 1"
}
ok: [demo2.example.com] => (item=[u'alice', u'b', u'2']) => {
    "msg": "name is alice  vaule is b num is 2"
}
ok: [demo2.example.com] => (item=[u'alice', u'b', u'3']) => {
    "msg": "name is alice  vaule is b num is 3"
}
ok: [demo2.example.com] => (item=[u'alice', u'c', u'1']) => {
    "msg": "name is alice  vaule is c num is 1"
}
ok: [demo2.example.com] => (item=[u'alice', u'c', u'2']) => {
    "msg": "name is alice  vaule is c num is 2"
}
ok: [demo2.example.com] => (item=[u'alice', u'c', u'3']) => {
    "msg": "name is alice  vaule is c num is 3"
}
ok: [demo2.example.com] => (item=[u'bob', u'a', u'1']) => {
    "msg": "name is bob  vaule is a num is 1"
}
ok: [demo2.example.com] => (item=[u'bob', u'a', u'2']) => {
    "msg": "name is bob  vaule is a num is 2"
}
ok: [demo2.example.com] => (item=[u'bob', u'a', u'3']) => {
    "msg": "name is bob  vaule is a num is 3"
}
ok: [demo2.example.com] => (item=[u'bob', u'b', u'1']) => {
    "msg": "name is bob  vaule is b num is 1"
}
ok: [demo2.example.com] => (item=[u'bob', u'b', u'2']) => {
    "msg": "name is bob  vaule is b num is 2"
}
ok: [demo2.example.com] => (item=[u'bob', u'b', u'3']) => {
    "msg": "name is bob  vaule is b num is 3"
}
ok: [demo2.example.com] => (item=[u'bob', u'c', u'1']) => {
    "msg": "name is bob  vaule is c num is 1"
}
ok: [demo2.example.com] => (item=[u'bob', u'c', u'2']) => {
    "msg": "name is bob  vaule is c num is 2"
}
ok: [demo2.example.com] => (item=[u'bob', u'c', u'3']) => {
    "msg": "name is bob  vaule is c num is 3"
}
```
- with_cartesian功能完全一样









[回到顶部](#循环语句)
