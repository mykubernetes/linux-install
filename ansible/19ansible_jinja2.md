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
# 1、模板文件，在渲染后不会显示注释信息
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

6、if用来进行条件判断
```
# 1、编写jinja模板,判断testnum变量如果大于3那么执行该语句，否则删除该语句
# cat test.j2
jinja2 test
 
{% if testnum > 3 %}
greater than {{ testnum }}
{% endif %}

# 2、编写ploybook剧本
# cat temptest.yml
---
- hosts: node
  remote_user: root
  gather_facts: no
  tasks:
  - template:
      src: /testdir/ansible/test.j2
      dest: /opt/test
    vars:
      testnum: 5

# 3、查看适配后的文件
# cat /opt/test
jinja2 test
 
greater than 5
```

### jinja语法`if…else…`结构
```
{% if 条件 %}
...
{% else %}
...
{% endif %}
```

### jinja的`if…else if…`语法结构
```
{% if 条件一 %}
...
{% elif 条件二 %}
...
{% elif 条件N %}
...
{% endif %}
```

### jinja的`if..elif..else..`语法语法结构
```
{% if 条件一 %}
...
{% elif 条件N %}
...
{% else %}
...
{% endif %}
```

7、`if`表达式实现类似三元运算的效果
```
# 编写jinja模板，如果2>1条件为真，则显示a,否则显示b
# cat test.j2
jinja2 test
{{ 'a' if 2>1 else 'b' }}

# 渲染后的结果
# cat /opt/test
jinja2 test
a
```

8、在模板文件中使用{{ set ...}} 语法定义变量
```
# 1、使用set语句定义变量
# cat test.j2
jinja2 test
{% set teststr='abc' %}
{{ teststr }}

# 2、查看渲染后的结果
# cat /opt/test
jinja2 test
abc
```

### for循环的基本语法
```
{% for 迭代变量 in 可迭代对象 %}
{{ 迭代变量 }}
{% endfor %}
```

9、定义一个循环，并输出
```
# 1、编辑jinja模板
# cat test.j2
jinja2 test
{% for i in [3,1,7,8,2] %}
{{ i }}
{% endfor %}

# 2、渲染结果如下
# cat /opt/test
jinja2 test
3
1
7
8
2
```

10、从生成的内容可以看出，每次循环后都会自动换行，如果不想要换行，则可以使用如下语法
```
# 1、编写剧本文件
# cat test.j2
jinja2 test
{% for i in [3,1,7,8,2] -%}
{{ i }}
{%- endfor %}

# 2、渲染后的结果
# cat test
jinja2 test
31782
```
- 在for的结束控制符`%}`之前添加了减号`-`,在endfor的开始控制符`{%`之后添加到了减号`-`来实现输出结果不换行

11、列表中的每一项都没有换行，而是连在了一起显示，如果你觉得这样显示有些”拥挤”，则可以稍微改进一下上述模板
```
# 1、编写剧本文件
jinja2 test
{% for i in [3,1,7,8,2] -%}
{{ i }}{{ ' ' }}
{%- endfor %}

# 2、渲染后的结果
# cat test
jinja2 test
3 1 7 8 2
```

12、上一步简洁的写法
```
# cat test.j2
jinja2 test
{% for i in [3,1,7,8,2] -%}
{{ i~' ' }}
{%- endfor %}

# cat test
jinja2 test
3 1 7 8 2
```

13、`for`除了能够循环操作列表，也能够循环操作字典

- 在循环操作字典时，使用iteritems函数对字典进行处理。然后使用key和val两个变量作为迭代变量，分别用于存放字典中键值对的”键”和”值”。
```
# 1、编写剧本
# cat test.j2
jinja2 test
{% for key,val in {'name':'bob','age':18}.iteritems() %}
{{ key ~ ':' ~ val }}
{% endfor %}

#2、渲染后的结果
# cat test
jinja2 test
age:18
name:bob
```
- iteritems函数也可以替换成items函数，推荐使用iteritems函数

| 变量名称 | 描述 |
|--------|-------|
| loop.index | 当前循环操作为整个循环的第几次循环，序号从1开始 |
| loop.index0 | 当前循环操作为整个循环的第几次循环，序号从0开始 |
| loop.revindex | 当前循环操作距离整个循环结束还有几次，序号到1结束 |
| loop.revindex0 | 当前循环操作距离整个循环结束还有几次，序号到0结束 |
| loop.first | 当操作可迭代对象中的第一个元素时，此变量的值为true |
| loop.last | 当操作可迭代对象中的最后一个元素时，此变量的值为true |
| loop.length | 可迭代对象的长度 |
| loop.depth | 当使用递归的循环时，当前迭代所在的递归中的层级，层级序号从1开始 |
| loop.depth0 | 当使用递归的循环时，当前迭代所在的递归中的层级，层级序号从0开始 |
| loop.cycle() | 这是一个辅助函数，通过这个函数我们可以在指定的一些值中进行轮询取值 |

1、借助`loop.index`特殊变量,知道当前循环操作为整个循环的第几次操作
```
# 1、编写剧本文件
# cat test.j2
jinja2 test
{% for i in [3,1,7,8,2] %}
{{ i ~ '----' ~ loop.index }}
{% endfor %}

# 2、渲染后的结果
# cat test
jinja2 test
3----1
1----2
7----3
8----4
2----5
```

2、对一段内容循环的生成指定的次数，则可以使用range函数完成。
```
# 1、编写jinja文件
{% for i in range(3) %}
something
...
{% endfor %}


#2、渲染后的结果
something
...
something
...
something
...
```

3、range函数可以指定起始数字、结束数字、步长等，默认的起始数字为0。
```
# 1、编写jinja文件
{% for i in range(1,4,2) %}
  {{i}}
{% endfor %}

# 2、渲染后的结果
  1
  3
```

4、模板中的for循环不能像其他语言中的 for循环那样使用break或者continue跳出循环，但是你可以在”for”循环中添加”if”过滤条件，以便符合条件时，循环才执行真正的操作
```
# 1、编写jinja文件
{% for i in [7,1,5,3,9] if i > 3 %}
  {{ i }}
{% endfor %}

# 2、渲染后的结果
  7
  5
  9
```

5、在for循环中使用if判断控制语句进行判断
```
# 1、编写jinja文件
{% for i in [7,1,5,3,9] %}
  {% if i>3 %}
    {{ i }}
  {%endif%}
{% endfor %}

# 2、渲染后的结果
  7
  5
  9
```

6、在循环中使用到loop.index计数变量时，语法显示的索引地址不同
```
# 1、编写jinja文件
{% for i in [7,1,5,3,9] if i>3 %}
{{ i ~'----'~ loop.index }}
{% endfor %}
 
{% for i in [7,1,5,3,9] %}
{% if i>3 %}
{{ i ~'----'~ loop.index}}
{% endif %}
{% endfor %}


# 2、渲染后的结果
# cat test
7----1
5----2
9----3
 
7----1
5----3
9----5
```
- 当使用if内联表达式时，如果不满足对应条件，则不会进入当次迭代，所以loop.index也不会进行计算，而当使用if控制语句进行判断时，其实已经进入了当次迭代，loop.index也已经进行了计算。

7、使用了if内联表达式时，还可以与else控制语句结合使用
```
# 1、编写jinja文件
{% for i in [7,1,5,3,9] if i>10 %}
{{ i }}
{%else%}
no one is greater than 10
{% endfor %}

# 2、所有条件都不满足是才执行else语句
no one is greater than 10
```

8、for循环也支持递归操作
```
# 1、编写jinja文件
{% set dictionary={ 'name':'bob','son':{ 'name':'tom','son':{ 'name':'jerry' } } }  %}
 
{% for key,value in dictionary.iteritems() recursive %}
  {% if key == 'name' %}
    {% set fathername=value %}
  {% endif %}
 
  {% if key == 'son' %}
    {{ fathername ~"'s son is "~ value.name}}
    {{ loop( value.iteritems() ) }}
  {% endif %}
{% endfor %}

# 2、渲染后的结果
      bob's son is tom
           
      tom's son is jerry
```
- 从字典中可以看出，bob的儿子是tom，tom的儿子是jerry，然后我们使用for循环操作了这个字典,使用了iteritems函数，在for循环的末尾，我们添加了recursive 修饰符，当for循环中有recursive时，表示这个循环是一个递归的循环，当我们需要在for循环中进行递归时，只要在需要进行递归的地方调用loop函数即可，没错，如你所见，上例中的”loop( value.iteritems() )”即为调用递归的部分，由于value也是一个字典，所以需要使用iteritems函数进行处理。

# 转义的一些操作

1、如果想将变量中的符合或者变量保持原样，需要在`{{  }}`中使用单引号引起，当做字符串进行处理。
```
# 1、编写jinja文件
{{  '{{' }}
{{  '}}' }}
{{ '{{ test string }}' }}
{{ '{% test string %}' }}
{{ '{# test string #}' }}

# 2、渲染后的结果
{{
}}
{{ test string }}
{% test string %}
{# test string #}
```

2、如果有较多的符号都需要保持原样（不被jinja2解析），如果有较大的段落时，可以借助`{% raw %}`块进行处理。
```
# 1、编写jinja文件
{% raw %}
  {{ test }}
  {% test %}
  {# test #}
  {% if %}
  {% for %}
{% endraw %}

# 2、渲染后的结果
 
  {{ test }}
  {% test %}
  {# test #}
  {% if %}
  {% for %}
```

3、默认情况下，变量和表达式被包含在`{{  }}`中，控制语句被包含在`{%  %}`中。也可以在调用模板时，手动指定一些符号替换默认的`{{  }}`和`{%  %}`,使用`variable_start_string`参数指定一个符号替代`{{`,variable_end_string参数指定一个符号替代`}}`
```
# 1、编写jinja文件
{% set test='abc' %}
 
(( test ))
 
{{ test }}
{{ test1 }}
{{ 'test' }}
{{ 'test1' }}

# 2、在调用templdate模块时，执行如下命令，注意，如下命令表示使用”((“代替”{{“，使用”))”代替”}}”。
# ansible node -m template -a "src=test.j2 dest=/opt/test variable_start_string='((' variable_end_string='))'"

# 3、渲染后的结果
 
abc
 
{{ test }}
{{ test1 }}
{{ 'test' }}
{{ 'test1' }}
```

4、使用block_start_string参数指定一个符号替换`{%  %}`中的`{% `,使用block_end_string参数指定一个符号替换`{%  %}`中的`%}`
```
# 1、编写jinja文件
(( set test='abc' ))
{{ test }}

{% set test1='cbd' %}
{{ test1 | default(true)}}
{{ 'test1' }}

# 2、在调用templdate模块时，执行如下命令，注意，如下命令表示使用”((“代替”{%“，使用”))”代替”%}”。
# ansible node -m template -a "src=test.j2 dest=/opt/test block_start_string='((' block_end_string='))'"

# 3、渲染后的结果
abc

{% set test1='cbd' %}
True
```


# 宏相关总结

1、jinja2中也有类似函数的东西，它叫做”宏”，利用宏，我们可以方便快捷的重复的利用一段内容，并且把这段内容当做一个独立的逻辑单元，与其他语言中的函数一样，jinja2的宏也可以传入参数
```
{% macro testfunc() %}
  test string
{% endmacro %}
 
{{ testfunc() }}
```
- 定义宏时需要使用`{% macro %}`开头，使用`{% endmacro %}`结束,与大多数语言中的函数一样，宏的括号中可以传入参数

2、在定义宏时，定义两个参数，然后在调用宏时，传入了提前定义好的testvar1变量和testvar2变量，但是示例中有一个很明显的问题，就是如果宏在定义的时候有对应的参数，在调用宏时就必须传入对应的参数，否则就会报错。
```
# 1、编写jinja文件
{% set testvar1='teststr1' %}
{% set testvar2=2 %}
 
{% macro testfunc(tv1,tv2) %}
  test string
  {{tv1}}
  {{tv2}}
{% endmacro %}
 
{{ testfunc(testvar1,testvar2) }}


# 2、渲染后的结果


  test string
  teststr1
  2
```

3、在定义宏时，为对应的参数指定一个默认值，当在调用宏时没有显式的指定对应的参数时，宏就使用参数的默认值
```
# 1、编写jinja文件
{% macro testfunc(tv1=111) %}
  test string
  {{tv1}}
{% endmacro %}
 
{{ testfunc( ) }}
{{ testfunc(666) }}

# 2、渲染后的结果

 
  test string
  111
 
  test string
  666
```
- 为tv1参数定义了默认值111，然后调用了两次testfunc宏，第一次没有传入对应参数，使用了默认值，第二次调用宏时传入了对应参数，于是使用了传入的值


4、调用宏时传入的值会按照顺序与没有默认值的参数进行对应。
```
# 1、编写jinja文件
{% macro testfunc(tv1,tv2,tv3=3,tv4=4) %}
  test string
  {{tv1}}
  {{tv2}}
  {{tv3}}
  {{tv4}}
{% endmacro %}
 
{{ testfunc( 'aa','a' ) }}

# 2、渲染后的结果


  test string
  aa
  a
  3
  4
```

5、在传入参数时，也可以显式的指明参数的名称
```
# 1、编写jinja文件
{% macro testfunc(tv1,tv2=2,tv3=3) %}
  test string
  {{tv1}}
  {{tv2}}
  {{tv3}}
{% endmacro %}
 
{{ testfunc( 111,tv3='ccc' ) }}

# 2、渲染后的结果
  test string
  111
  2
  ccc
```

6、在宏的内部，有三个默认的内置特殊变量可供我们使用，它们分别是varargs、kwargs、caller

1）在调用宏时，多传入几个额外的参数，这些额外的参数会作为一个元组保存在varargs变量上，可以通过获取varargs变量的值获取到额外传入的参数
```
# 1、编写jinja文件
{% macro testfunc(testarg1=1,testarg2=2) %}
  test string
  {{testarg1}}
  {{testarg2}}
  {{varargs}}
{% endmacro %}
 
{{ testfunc('a','b','c','d','e') }}


# 2、渲染后的结果
 
  test string
  a
  b
  ('c', 'd', 'e')
```

2)既然varargs变量里面存储了多余的参数，那么如果宏压根就没有定义任何参数，我们却传入了一些参数，那么这些所有传入的参数都是“多余”出的参数，也可以使用varargs变量处理这些参数
```
# 1、编写jinja文件
{% macro testfunc() %}
  test string
  {%for i in varargs%}
  {{i}}
  {%endfor%}
  {{ '--------' }}
{% endmacro %}
 
{{ testfunc() }}
{{ testfunc(1,2,3) }}


# 2、渲染后的结果
  test string
    --------
 
  test string
    1
    2
    3
    --------
```

3)kwargs变量与varargs变量的作用很像，但是kwargs变量只是针对’关键字参数’而言的，而varargs变量是针对’非关键字参数’而言的

在定义宏时，定义了一个参数tv1，并且设置了默认值，在宏中，我们输出了varargs变量和kwargs变量，在调用宏时，我们多传入了3个参数，最后一个参数是一个带有参数名的关键字参数
```
# 1、编写jinja文件
{% macro testfunc(tv1='tv1') %}
  test string
  {{varargs}}
  {{kwargs}}
{% endmacro %}
 
{{ testfunc('a',2,'test',testkeyvar='abc') }}

# 2、渲染后的结果
 
  test string
  (2, 'test')
  {'testkeyvar': 'abc'}
```
- 多余的非关键字参数都会保存在varargs变量中，varargs变量的结构是一个元组，而多余的关键字参数都会保存在kwargs变量中，kwargs变量的结构是一个字典，kwargs变量实现的效果与Python的关键字参数效果类似。

4)与其说是caller变量，不如称其为caller函数或者caller方法，caller可以帮助我们将宏中的内容进行替换
```
# 1、编写jinja文件
{% macro testfunc() %}
  test string
  {{caller()}}
{% endmacro %}
 
{%call testfunc()%}
something~~~~~
something else~~~~~
{%endcall%}


# 2、渲染后的结果

  test string
  something~~~~~
something else~~~~~

```
- 使用了”{%call%}”语句块调用了testfunc宏，”{%call%}”和”{%endcall%}”之间的内容将会替换testfunc宏中的”{{caller()}}”部分


5)跟传参数的效果一模一样，就像传了一个参数给testfunc宏一样，当我们要传入大段内容或者复杂的内容时，可以借助caller进行传递，当然，上例只是 为了让你能够更加直观的了解caller的用法，caller其实还能够帮助我们在一个宏中调用另一个宏
```
# 1、编写jinja文件
{% macro testfunc() %}
  test string
  {{caller()}}
{% endmacro %}
 
{% macro testfunc1() %}
  {% for i in range(3) %}
    {{i}}
  {% endfor %}
{% endmacro %}
 
{%call testfunc()%}
{{testfunc1()}}
{%endcall%}


# 2、渲染后的结果

  test string
        0
      1
      2


```
- 我们定义了两个宏，testfunc和testfunc1，我们将testfunc1传递到了testfunc中。


6)`caller()`可以接收参数，只要在call块中提前定义好，在caller中传入参数即可
```
# 1、编写jinja文件
{% macro testfunc() %}
  test string
  {{caller('somethingElse~~')}}
{% endmacro %}
 
{%call(testvar) testfunc()%}
something~~~~
{{testvar}}
{%endcall%}


# 2、渲染后的结果
 
  test string
  something~~~~
somethingElse~~
```
- 当testfunc中的某些内容需要循环的进行替换时，这种方法非常有效


7)除了varargs、kwargs、caller这些内部变量，宏还有一些属性可以使用。

| 属性| 属性描述 |
|-----|---------|
| name | 宏的名称。 |
| arguments | 宏中定义的所有参数的参数名，这些参数名组成了一个元组存放在arguments中。 |
| defaults | 宏中定义的参数如果有默认值，这些默认值组成了一个元组存放在defaults中。 |
| catch_varargs | 如果宏中使用了varargs变量，此属性的值为true。 |
| catch_kwargs属 | 如果宏中使用了kwargs变量，此属性的值为true。 |
| caller | 如果宏中使用了caller变量，此属性值为true。 |

上述宏属性的使用示例如下，可以对比着渲染后的结果查看：
```
# cat test.j2
{% macro testfunc(tv1,tv2,tv3=3,tv4=4) %}
  test string
  {{tv1}}
  {{tv2}}
  {{tv3}}
  {{tv4}}
{% endmacro %}
 
  {{testfunc.name}}
  {{testfunc.arguments}}
  {{testfunc.defaults}}
  {{testfunc.catch_varargs}}
  {{testfunc.catch_kwargs}}
  {{testfunc.caller}}
 
{{'################################'}}
 
{% macro testfunc1(tv1='a',tv2='b') %}
  test string
  {{tv1}}
  {{tv2}}
  {{varargs}}
  {{kwargs}}
{% endmacro %}
 
  {{testfunc1.catch_varargs}}
  {{testfunc1.catch_kwargs}}
  {{testfunc1.caller}}
 
{{'################################'}}
 
{% macro testfunc2() %}
  test string
  {{caller()}}
{% endmacro %}
 
  {{testfunc2.caller}}
```
如你所见，我并没有调用宏，但是可以直接使用宏的属性，上例模板内容渲染后的结果如下：
```
  testfunc
  ('tv1', 'tv2', 'tv3', 'tv4')
  (3, 4)
  False
  False
  False
 
################################
 
 
  True
  True
  False
 
################################
 
 
  True
```


# 包含

1、ansible可以使用`include`在jinja模板中对其他文件进行包含。
```
# 1、定义两个jinja模板，其中一个jinja被包含在另外一个中
# cat test.j2
test...................
test...................
{% include 'test1.j2' %}
 
test...................
 
# cat test1.j2
test1.j2 start
{% for i in range(3) %}
{{i}}
{% endfor %}
test1.j2 end

# 2、剧本文件
---
- hosts: node01
  remote_user: root
  gather_facts: no
  tasks:
  - template:
      src: /root/test/test.j2
      dest: /opt/test
      
# 3、渲染后的结果
test...................
test...................
test1.j2 start
0
1
2
test1.j2 end
test...................
```

2、在test.j2中定义了一个变量，那么在被包含的test1.j2中也可以使用test.j2中的变量。
```
# 1、定义两个jinja模板，其中一个jinja被包含在另外一个中,并且test中设置变量，被包含的模板也可以使用test中的变量
# cat test.j2
{% set varintest='var in test.j2' %}
test...................
test...................
{% include 'test1.j2' %}
 
test...................
 
# cat test1.j2
test1.j2 start
{{ varintest }}
test1.j2 end

# 2、渲染后的结果
test...................
test...................
test1.j2 start
var in test.j2
test1.j2 end
test...................
```

3、如果不想让被包含文件能够使用到外部文件中定义的变量，则可以使用`without context`显式的设置`include`，当`include`中存在`without context`时，表示不导入对应的上下文。
```
# 1、使用without context显示设置定义变量不能导入上下文。
# cat test.j2
{% set varintest='var in test.j2' %}
test...................
test...................
{% include 'test1.j2' without context %}
 
test...................
 
# cat test1.j2
test1.j2 start
{{ varintest }}
test1.j2 end

# 2、在渲染test.j2文件，则会报错，这是因为设置了不导入上下文，所以无法在test1.j2中使用test.j2中定义的变量，去渲染test1.j2文件中的变量
# ansible node -m template -a "src=test.j2 dest=/opt/test"
node01 | FAILED! => {
    "changed": false, 
    "msg": "AnsibleError: Unexpected templating type error occurred on ({% set varintest='var in test.j2' %}\ntest...................\ntest...................\n{% include 'test1.j2' without context  %}\n \ntest...................\n): argument of type 'NoneType' is not iterable"
}
```

4、如果在`include`时设置了`without context`，那么在被包含的文件中使用for循环时，不能让使用range()函数，也就是说，下例中的test.j2文件无法被正常渲染
```
# 1、编辑jinja模板
# cat test.j2
test...................
test...................
{% include 'test1.j2' without context %}
 
test...................
 
# cat test1.j2
test1.j2 start
{% for i in range(3) %}
{{i}}
{% endfor %}
test1.j2 end

# 2、在ansible中渲染上例中的test.j2文件，会报错，报错信息中同样包含”argument of type ‘NoneType’ is not iterable”。
# ansible node -m template -a "src=test.j2 dest=/opt/test"
node01 | FAILED! => {
    "changed": false, 
    "msg": "AnsibleError: Unexpected templating type error occurred on ({% set varintest='var in test.j2' %}\ntest...................\ntest...................\n{% include 'test1.j2' without context  %}\n \ntest...................\n): argument of type 'NoneType' is not iterable"
}
```

5、可以通过显式的指定`with context`，表示导入上下文
```
# cat test.j2
test...................
test...................
{% include 'test1.j2' with context %}
 
test...................
```

在默认情况下，即使不使用`with context`，`include`也会导入对应的上下文，所以两种写法是等效的。
```
{% include 'test1.j2' %}
{% include 'test1.j2' with context %}
```

6、如果指定包含的文件不存在执行文件的时候会报`TemplateNotFound: 文件名`错误，可以使用`ignore missing`进行标记即可。
```
# 1、编辑2个jinja模板其中test会包含一个不存在的test2.j2模板，执行过程中会报错
test...................
test...................
{% include 'test1.j2' with context %}
 
test...................
{% include 'test2.j2' with context %}

# 2、因为没有编写所谓的test2.j2，所以渲染test.j2模板时会报错
# ansible node -m template -a "src=test.j2 dest=/opt/test"
node01 | FAILED! => {
    "changed": false, 
    "msg": "TemplateNotFound: test2.j2"
}

# 3、使用”ignore missing”标记，自动忽略不存在的文件
# cat test.j2
test...................
test...................
{% include 'test1.j2' with context %}
 
test...................
{% include 'test2.j2' ignore missing with context %}
```

# 导入import

- include的作用是在模板中包含另一个模板文件，而import的作用是在一个文件中导入其他文件中的宏，所有宏都是在当前文件中定义的也就是说，无论是定义宏，还是调用宏，都是在同一个模板文件中完成的，可以通过`import`实现在A文件中定义宏，在B文件中使用宏。

import语法：
```
方法一：
{% import 'function_lib.j2' as funclib %}
表示一次性导入'function_lib.j2' 文件中的所有宏，调用宏时使用对应的变量进行调用。
 
方法二:
{% from 'function_lib.j2' import testfunc1 as tf1  %}
表示导入'function_lib.j2' 文件中指定的宏，调用宏时使用对应的新名称进行调用。
```


```jinja
# 1、编写两个jinja模板，一个通过import调用另外一个文件的宏
# cat function_lib.j2
{% macro testfunc() %}
test function
{% for i in varargs %}
{{ i }}
{% endfor %}
{% endmacro %}
 
{% macro testfunc1(tv1=1) %}
{{tv1}}
{% endmacro %}
 
# cat test.j2
{% import 'function_lib.j2' as funclib %}
something in test.j2
{{ funclib.testfunc(1,2,3) }}
 
something in test.j2
{{ funclib.testfunc1('aaaa') }}

# 通过命令进行渲染
# ansible node -m template -a "src=test.j2 dest=/opt/test"

# 3、渲染后的结果
something in test.j2
test function
1
2
3


something in test.j2
aaaa
```
- 在function_lib.j2文件中定义了两个宏，testfunc宏和testfunc1宏，并且没有在function_lib.j2文件中调用这两个宏，而是在test.j2文件中调用这些宏，所以使用`import`将function_lib.j2文件中的宏导入到了当前文件中。由于已经将`function_lib.j2`文件中的宏导入到了”funclib”变量中，所以当需要调用`function_lib.j2`文件中的testfunc宏时可以直接使用。



```
# cat function_lib.j2
{% macro testfunc() %}
test function
{% for i in varargs %}
{{ i }}
{% endfor %}
{% endmacro %}
 
{% macro testfunc1(tv1=111) %}
test function1
{{tv1}}
{% endmacro %}
 
 
# cat test1.j2
{% from 'function_lib.j2' import testfunc as tf, testfunc1 as tf1  %}
something in test1.j2
{{ tf(1,2) }}
 
something in test1.j2
{{ tf1('a') }}
```
- 从`function_lib.j2`文件中将`testfunc`宏导入为`tf`宏
- 从`function_lib.j2`文件中将`testfunc1`宏导入为t`f1`宏
- 导入后，直接调用`tf`宏和t`f1`宏，即为调用`function_lib.j2`文件中对应的宏



import和include不同，include默认会导入上下文环境，而import默认则不会，所以，如果想要让宏被import以后能够使用到对应的上下文环境，则需要显式的配置`with context`
```
# cat function_lib.j2
{% macro testfunc1(tv1=111) %}
test function1
{{tv1}}
{{outvartest}}
{% endmacro %}
 
# cat test.j2
{% set outvartest='00000000' %}
 
{% import 'function_lib.j2' as funclib with context%}
something in test.j2
{{ funclib.testfunc1() }}
```

在使用`import`并且显式的配置`with context`时，有如下两个注意点。
- 一、在外部定义变量的位置需要在import之前，也就是说，上例中定义outvartest变量的位置在import之前。
- 二、只能使用上述方法一对宏进行导入，经测试，使用方法二导入宏后，即使显式的指定了”with context”，仍然无法找到对应的变量。

注意：宏中如果包含for循环并且for循环中使用了range()函数，那么在`import`宏时则必须显式的指定`with context`，否则在ansible中渲染对应模板时，会出现包含如下信息的报错。
```
"argument of type 'NoneType' is not iterable"
```
 

注意：宏如果以一个或多个下划线开头，则表示这个宏为私有宏，这个宏不能被导入到其他文件中使用，示例如下：
```
# cat func.j2
{% macro _test() %}
something in test macro
{% endmacro %}
 
{{_test()}}
```

# 继承

- 可以先定义一个父模板，然后在父模板中定义一些”块”，不同的内容放在不同的块中，之后再定义一个子模板，这个子模板继承自刚才定义的父模板，我们可以在子模板中写一些内容，这些内容可以覆盖父模板中对应的内容

```
# 1、编写jinja模板
# cat test.j2
something in test.j2...
something in test.j2...
{% block test %}
Some of the options that might be replaced
{% endblock %}
something in test.j2...
something in test.j2...

# 2、执行命令
# ansible node -m template -a "src=test1.j2 dest=/opt/test"

# 3、test.j2就是刚才描述的”父模板”文件，这个文件中并没有太多内容，只是有一些文本，以及一个”块”，这个块通过”{% block %}”和”{% endblock %}”定义，块的名字为”test”，test块中有一行文本，我们可以直接渲染这个文件，渲染后的结果如下
something in test.j2...
something in test.j2...
Some of the options that might be replaced
something in test.j2...
something in test.j2...

# 4、直接渲染这个父模板，父模板中的块并没有对父模板有任何影响，现在，定义一个子模板文件，并且指明这个子模板继承自这个父模板
# cat test1.j2
{% extends 'test.j2' %}
 
{% block test %}
aaaaaaaaaaaaaa
11111111111111
{% endblock %}

# 5、执行命令
# ansible node -m template -a "src=test1.j2 dest=/opt/test"

# 6、最终生成的内容中，子模板中的test块中的内容覆盖了父模板中的test块的内容
something in test.j2...
something in test.j2...
aaaaaaaaaaaaaa
11111111111111
something in test.j2...
something in test.j2...
```

可以在父模板的块中不写任何内容，而是靠子模板去填充对应的内容
```
# 在父模板的块中没有默认的内容，之前的示例中父模板的块中有默认的内容
# cat test.j2
something in test.j2...
something in test.j2...
{% block test %}
{% endblock %}
something in test.j2...
something in test.j2...
 
# cat test1.j2
{% extends 'test.j2' %}
 
{% block test %}
aaaaaaaaaaaaaa
11111111111111
{% endblock %}
```

使用继承的一些优点如下：
- 1、将公共的部分提取出来，规范统一公共部分
- 2、将稳定的部分提取出来 ，提高复用率
- 3、灵活的覆盖或者填充可能需要修改的部分，同时保留其他大部分未修改的默认配置
- 4、为别人的修改留下一定的空间，并且不会影响默认的配置

块中也可以嵌套另一个块
```
something in test.j2...
{% block test %}
 
something in block test
{% block t1 %}
something in block t1
{% endblock %}
something in block test
 
{% endblock %}
```

test块中还有一个t1块，这样也是完全可行的，不过，上例中存在一个小问题，问题就是无论test块还是t1块，都使用”{% endblock %}”作为结尾，虽然能够正常 解析，但是可读性比较差，所以，我们可以在endblock中也加入对应的块名称以提高可读性
```
something in test.j2...
{% block test %}
 
something in block test
{% block t1 %}
something in block t1
{% endblock t1 %}
something in block test
 
{% endblock test %}
something in test.j2...
```
在子模板替换对应的块时，也可以在endblock块中写入对应的块名称。

如果你需要在一个模板中多次的引用同一个块，则可以使用self特殊变量来引用模板自身的某个块，示例如下：
```
# cat test.j2
something in test.j2...
 
{% block test %}
something in block test
something else in block test
{% endblock test %}
 
{{ self.test() }}
 
something in test.j2...
```

如上例所示，模板中定义了一个test块，在这个块之后，使用了”{{ self.test() }}”，这表示调用当前模板中的test块，上例模板渲染后结果如下
```
# cat test
something in test.j2...
 
something in block test
something else in block test
 
something in block test
something else in block test
 
 
something in test.j2...
```
test块中的内容被引用了两次，如果还有其他块名，你也可以使用”self.blockname()”来调用，如果你修改了上例中test块中的内容，所有引用test块中的内容都会随之改变，同理，如果你在子模板中覆盖了test块，那么所有引用test块的部分都会被覆盖。

如果你并不想完全覆盖父模板中的块，而是想要在父模板某个块的基础之上进行扩展，那么则可以子模板中使用super块来完成，这样说可能不太容易理解，不如先来看一个小示例，如下：
```
# cat test.j2
something in test.j2...
 
{% block test %}
something in block test
something else in block test
{% endblock test %}
 
something in test.j2...
 
# cat test1.j2
{% extends 'test.j2' %}
 
{% block test%}
aaaaaaaaaaaaaa
{{ super() }}
11111111111111
{% endblock test %}
```
如上例所示，test1.j2继承自test.j2文件，同时，test1.j2中指明要修改test块，如你所见，子模板的test块中包含”{{ super() }}”，这表示父模板中test块中的内容会替换到”{{ super() }}”对应的位置，换句话说就是，我们可以通过”{{ super() }}”来获取父级块中的内容，上例test1.j2的渲染结果如下：
```
# cat test1
something in test.j2...
 
aaaaaaaaaaaaaa
something in block test
something else in block test
 
11111111111111
 
something in test.j2...
```
如你所见，父级块中的内容保留了，我们加入的两行文本也在对应的位置生成了，这样就能够在保留父级块内容的前提下，加入更多的内容，不过上例中有一个小问题，就是super块在渲染后会自动换行，细心如你一定已经发现了，之前示例中使用”self”变量时，也会出现相同的问题，解决这个问题很简单，我们之前在使用for循环时就遇到过类似的问题，没错，使用”空白控制符”即可，在super块的末尾加入空白控制符”减号”就可以将自动换行去掉，示例如下：
```
{{ super() -}}
```
 

你有可能会使用for循环去迭代一个块，但是你在块中无法获取到for的循环变量，示例如下：
```
# cat test.j2
something in test.j2...
 
{%set testvar=123%}
{% block test %}
something in block test ---- {{testvar}}
{% endblock %}
 
{% for i in range(3) -%}
 
{% block test1 %}
something in block test1 ---- {{i}}
{% endblock %}
 
{%- endfor %}
 
something in test.j2...
```
上述模板中有两个块，test块和test1块，test块未使用for循环，test1块使用for循环进行处理，渲染上述模板，会报如下错误
```
"msg": "AnsibleUndefinedVariable: 'i' is undefined"
```
提示未定义变量，这是因为当test1块被for循环处理时，无法在块中获取到for的循环变量造成的，如果想要在上述情况中获取到for的循环变量，则可以在块中使用scoped修饰符，示例如下
```
# cat test.j2
something in test.j2...
 
{%set testvar=123%}
{% block test %}
something in block test ---- {{testvar}}
{% endblock %}
 
{% for i in range(3) -%}
 
{% block test1 scoped %}
something in block test1 ---- {{i}}
{% endblock %}
 
{%- endfor %}
 
something in test.j2...
```
上例渲染后结果如下
```
something in test.j2...
 
something in block test ---- 123
 
something in block test1 ---- 0
something in block test1 ---- 1
something in block test1 ---- 2
 
something in test.j2...
```
 

在继承模板时，如果父模板在当前目录的子目录中，则可以使用如下方法继承对应的父模板
```
# tree
.
├── parent
│    └── test.j2
└── test1.j2
 
# cat test1.j2
{% extends 'parent/test.j2' %}
 
{% block test%}
{{ super() -}}
11111111111111
{% endblock test %}
```
如上例所示，test1.j2为子模板，test.j2为父模板，父模板在子模板所在目录的子目录中，此时，可以使用’parent/test.j2’引用test.j2模板。

