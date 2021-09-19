| 用法 | 描述 |
|-----|------|
| {{      }} | 用来装载表达式，比如变量、运算表达式、比较表达式等 |
| {%   %} | 用来装载控制语句，比如 if 控制结构，for循环控制结构 |
| {#    #} | 用来装载注释，模板文件被渲染后，注释不会包含在最终生成的文件中 |


1、template的简单实用
```
# cat /testdir/ansible/redis.conf
bind {{ ansible_host }}


# cat temptest.yml
---
- hosts: redis
 remote_user: root
 gather_facts: no
 tasks:
 - yum:
     name: redis
     state: present
 - template:
     src: /testdir/ansible/redis.conf                 # ansible主机中的模板文件
     dest: /etc/redis.conf                            # 最终生成的配置文件拷贝到目标主机的所在路径


# ansible-playbook temptest.yml
```


2、通过命令调用jinja2
```
# cat test.j2
test jinja2 variable
test {{ testvar1 }} test


# ansible node01 -m template -e "testvar1=teststr" -a "src=test.j2 dest=/opt/test"
```


# 比较表达式

| 表达式 | 描述 | 使用方法 | 执行结果 |
|-------|------|--------|---------|
| == | 等于 | {{ 1 == 1 }} | True |
| != | 不等于 | {{ 2 != 2 }} | False |
| > | 大于 | {{ 2 > 1 }} | True |
| >= | 大于等于 | {{ 2 >= 1 }} | True |
| < | 小于 | {{ 2 < 1 }} | False |
| <= | 小于等于 | {{ 2 <= 1 }} | False |

# 逻辑运算

| 表达式 | 描述 | 使用方法 | 执行结果 |
|-------|------|--------|---------|
| or | 或 | {{ (2 > 1) or (1 > 2) }} | True |
| and | 与 | {{ (2 > 1) and (1 > 2) }} | False |
| not | 非 | {{ not true }} | False |
| not | 非 | {{ not True }} | False |
| not | 非 | {{ not false }} | True |
| not | 非 | {{ not False }} | True |

# 算数运算

| 表达式 | 描述 | 使用方法 | 执行结果 |
|-------|------|--------|---------|
| + | 加法 | {{ 3 + 2 }} | 5 |
| - | 减法 | {{ 3 - 4 }} | -1 |
| * | 乘法 | {{ 3 * 5 }} | 15 |
| ** | 幂 | {{ 2 ** 3 }} | 8 |
| / | 除法 | {{ 7 / 5 }} | 1.4 |
| // |  除法，取整  | {{ 7 // 5 }} | 1 |
| % | 取余 | {{ 17 % 5 }} | 2 |

# 成员运算

| 表达式 | 描述 | 使用方法 | 执行结果 |
|-------|------|--------|---------|
| in | 在列表中 | {{ 1 in [1,2,3,4] }} | True |
| not in | 不在列表中 | {{ 1 not in [1,2,3,4] }} | False |

# jinja2本身就是基于python的模板引擎，所以python的基础数据类型都可以包含在`{{  }}`中

| 数据类型 | 描述 | 使用方法 | 执行结果 |
|-------|------|--------|---------|
| str | 字符串 | `{{ 'testString' }}`,`{{ "testString" }}` | `testString`,`testString` |
| num | 数值 | `{{ 15 }}`,`{{ 18.8 }}` | `15`,`18.5` |
| list | 列表 | `{{ ['Aa','Bb','Cc','Dd'] }}`,`{{ ['Aa','Bb','Cc','Dd'].1 }}`,`{{ ['Aa','Bb','Cc','Dd'][1] }}` | `['Aa', 'Bb', 'Cc', 'Dd']`,`Bb`,`Bb` |
| tuple | 元组 | `{{ ('Aa','Bb','Cc','Dd') }}`,`{{ ('Aa','Bb','Cc','Dd').0 }}`,`{{ ('Aa','Bb','Cc','Dd')[0] }}` | `('Aa', 'Bb', 'Cc', 'Dd')`,`Aa`,`Aa` |
| dic | 字典 | `{{ {'name':'bob','age':18} }}`,`{{ {'name':'bob','age':18}.name }}`,`{{ {'name':'bob','age':18}['name'] }}` | `{'age': 18, 'name': 'bob'}`,`bob`,`bob` |
| Boolean | 布尔 | `{{ True }}`,`{{ true }}`,`{{ False }}`,`{{ false }}` | `True`,`True`,`False`,`False` |


1、使用ad-hoc执行命令时，会把列表、数字、字典等数据类型当做参数传入，这些参数会被默认当做字符串，所以需要playbook的方式渲染模板。
```
# 1、配置jinja模板
# /testdir/ansible/test.j2
jinja2 test
{{ teststr }}
{{ testnum }}
{{ testlist[1] }}
{{ testlist1[1] }}
{{ testdic['name'] }}

# 2、编写剧本
# cat temptest.yml
---
- hosts: web
 remote_user: root
 gather_facts: no
 vars:
   teststr: 'tstr'
   testnum: 18
   testlist: ['aA','bB','cC']
   testlist1:
   - AA
   - BB
   - CC
   testdic:
     name: bob
     age: 18
 tasks:
 - template:
     src: /testdir/ansible/test.j2
     dest: /opt/test

# 3、通过ansible-playbook方式运行
# ansible-playbook temptest.yml

# 4、查看渲染结果
# cat /opt/test
jinja2 test
tstr
18
bB
BB
bob
```

2、除了变量和各种常用的运算符，过滤器也可以直接在`{{  }}`中使用。
```
模板文件内容
# cat test.j2
jinja2 test
{{ 'abc' | upper }}
 
 
生成文件内容
# cat test
jinja2 test
ABC
```

3、jinja2的tests也能在`{{  }}`中使用。
```
# 1、模板文件内容
# cat test.j2
jinja2 test
{{ testvar1 is defined }}
{{ testvar1 is undefined }}
{{ '/opt' is exists }}
{{ '/opt' is file }}
{{ '/opt' is directory }}
 
# 2、执行命令时传入变量
# ansible test70 -m template -e "testvar1=1 testvar2=2" -a "src=test.j2 dest=/opt/test"
 
# 3、生成文件内容
# cat test
jinja2 test
True
False
True
False
True
```

4、lookup也可以直接在`{{  }}`中使用。
```
# 1、模板文件内容如下
# cat /testdir/ansible/test.j2
jinja2 test
 
{{ lookup('file','/testdir/testfile') }}
 
{{ lookup('env','PATH') }}
 
test jinja2

 
# 2、ansible主机中的testfile内容如下
# cat /testdir/testfile
testfile in ansible
These are for testing purposes only
 
 
# 3、生成文件内容如下
# cat test
jinja2 test
 
testfile in ansible
These are for testing purposes only
 
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
 
test jinja2
```

5、在模板文件中对某些配置进行注释，则可以将注释信息写入到`{#   #}`
```
# 1、模板文件内容如下：
# cat test.j2
jinja2 test
{#这是一行注释信息#}
jinja2 test
{#
这是多行注释信息，
模板被渲染以后，
最终的文件中不会包含这些信息
#}
jinja2 test
 
 
# 2、生成文件内容如下：
# cat test
jinja2 test
jinja2 test
jinja2 test
```
