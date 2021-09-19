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










