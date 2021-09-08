过滤器（filters）
===

http://jinja.pocoo.org/docs/2.10/templates/#builtin-filters

# 一、字符串相关过滤器

```
---
- hosts: all
  remote_user: root
  vars:
    testvar: "abc123ABC 666"
    testvar1: "  abc  "
    testvar2: '123456789'
    testvar3: "1a2b,@#$%^&"
  tasks:
  - debug:
      #将字符串转换成纯大写
      msg: "{{ testvar | upper }}"
  - debug:
      #将字符串转换成纯小写
      msg: "{{ testvar | lower }}"
  - debug:
      #将字符串变成首字母大写,之后所有字母纯小写
      msg: "{{ testvar | capitalize }}"
  - debug:
      #将字符串反转
      msg: "{{ testvar | reverse }}"
  - debug:
      #返回字符串的第一个字符
      msg: "{{ testvar | first }}"
  - debug:
      #返回字符串的最后一个字符
      msg: "{{ testvar | last }}"
  - debug:
      #将字符串开头和结尾的空格去除
      msg: "{{ testvar1 | trim }}"
  - debug:
      #将字符串放在中间，并且设置字符串的长度为30，字符串两边用空格补齐30位长
      msg: "{{ testvar1 | center(width=30) }}"
  - debug:
      #返回字符串长度,length与count等效,可以写为count
      msg: "{{ testvar2 | length }}"
  - debug:
      #将字符串转换成列表，每个字符作为一个元素
      msg: "{{ testvar3 | list }}"
  - debug:
      #将字符串转换成列表，每个字符作为一个元素，并且随机打乱顺序
      #shuffle的字面意思为洗牌
      msg: "{{ testvar3 | shuffle }}"
  - debug:
      #将字符串转换成列表，每个字符作为一个元素，并且随机打乱顺序
      #在随机打乱顺序时，将ansible_date_time.epoch的值设置为随机种子
      #也可以使用其他值作为随机种子，ansible_date_time.epoch是facts信息
      msg: "{{ testvar3 | shuffle(seed=(ansible_date_time.epoch)) }}"
```


# 二、数字相关过滤器

```
---
- hosts: all
  remote_user: root
  vars:
    testvar4: -1
  tasks:
  - debug:
      #将对应的值转换成int类型
      #ansible中，字符串和整形不能直接计算，比如{{ 8+'8' }}会报错
      #所以，我们可以把一个值为数字的字符串转换成整形后再做计算
      msg: "{{ 8+('8' | int) }}"
  - debug:
      #将对应的值转换成int类型,如果无法转换,默认返回0
      #使用int(default=6)或者int(6)时，如果无法转换则返回指定值6
      msg: "{{ 'a' | int(default=6) }}"
  - debug:
      #将对应的值转换成浮点型，如果无法转换，默认返回'0.0'
      msg: "{{ '8' | float }}"
  - debug:
      #当对应的值无法被转换成浮点型时，则返回指定值’8.8‘
      msg: "{{ 'a' | float(8.88) }}"
  - debug:
      #获取对应数值的绝对值
      msg: "{{ testvar4 | abs }}"
  - debug:
      #四舍五入
      msg: "{{ 12.5 | round }}"
  - debug:
      #取小数点后五位
      msg: "{{ 3.1415926 | round(5) }}"
  - debug:
      #从0到100中随机返回一个随机数
      msg: "{{ 100 | random }}"
  - debug:
      #从5到10中随机返回一个随机数
      msg: "{{ 10 | random(start=5) }}"
  - debug:
      #从5到15中随机返回一个随机数,步长为3
      #步长为3的意思是返回的随机数只有可能是5、8、11、14中的一个
      msg: "{{ 15 | random(start=5,step=3) }}"
  - debug:
      #从0到15中随机返回一个随机数,这个随机数是5的倍数
      msg: "{{ 15 | random(step=5) }}"
  - debug:
      #从0到15中随机返回一个随机数，并将ansible_date_time.epoch的值设置为随机种子
      #也可以使用其他值作为随机种子，ansible_date_time.epoch是facts信息
      #seed参数从ansible2.3版本开始可用
      msg: "{{ 15 | random(seed=(ansible_date_time.epoch)) }}"
```

# 三、列表相关过滤器

```
---
- hosts: all
  remote_user: root
  vars:
    testvar7: [22,18,5,33,27,30]
    testvar8: [1,[7,2,[15,9]],3,5]
    testvar9: [1,'b',5]
    testvar10: [1,'A','b',['QQ','wechat'],'CdEf']
    testvar11: ['abc',1,3,'a',3,'1','abc']
    testvar12: ['abc',2,'a','b','a']
  tasks:
  - debug:
      #返回列表长度,length与count等效,可以写为count
      msg: "{{ testvar7 | length }}"
  - debug:
      #返回列表中的第一个值
      msg: "{{ testvar7 | first }}"
  - debug:
      #返回列表中的最后一个值
      msg: "{{ testvar7 | last }}"
  - debug:
      #返回列表中最小的值
      msg: "{{ testvar7 | min }}"
  - debug:
      #返回列表中最大的值
      msg: "{{ testvar7 | max }}"
  - debug:
      #将列表升序排序输出
      msg: "{{ testvar7 | sort }}"
  - debug:
      #将列表降序排序输出
      msg: "{{ testvar7 | sort(reverse=true) }}"
  - debug:
      #返回纯数字非嵌套列表中所有数字的和
      msg: "{{ testvar7 | sum }}"
  - debug:
      #如果列表中包含列表，那么使用flatten可以'拉平'嵌套的列表
      #2.5版本中可用,执行如下示例后查看效果
      msg: "{{ testvar8 | flatten }}"
  - debug:
      #如果列表中嵌套了列表，那么将第1层的嵌套列表‘拉平’
      #2.5版本中可用,执行如下示例后查看效果
      msg: "{{ testvar8 | flatten(levels=1) }}"
  - debug:
      #过滤器都是可以自由结合使用的，就好像linux命令中的管道符一样
      #如下，取出嵌套列表中的最大值
      msg: "{{ testvar8 | flatten | max }}"
  - debug:
      #将列表中的元素合并成一个字符串
      msg: "{{ testvar9 | join }}"
  - debug:
      #将列表中的元素合并成一个字符串,每个元素之间用指定的字符隔开
      msg: "{{ testvar9 | join(' , ') }}"
  - debug:
      #从列表中随机返回一个元素
      #对列表使用random过滤器时，不能使用start和step参数
      msg: "{{ testvar9 | random }}"
  - debug:
      #从列表中随机返回一个元素,并将ansible_date_time.epoch的值设置为随机种子
      #seed参数从ansible2.3版本开始可用
      msg: "{{ testvar9 | random(seed=(ansible_date_time.epoch)) }}"
  - debug:
      #随机打乱顺序列表中元素的顺序
      #shuffle的字面意思为洗牌
      msg: "{{ testvar9 | shuffle }}"
  - debug:
      #随机打乱顺序列表中元素的顺序
      #在随机打乱顺序时，将ansible_date_time.epoch的值设置为随机种子
      #seed参数从ansible2.3版本开始可用
      msg: "{{ testvar9 | shuffle(seed=(ansible_date_time.epoch)) }}"
  - debug:
      #将列表中的每个元素变成纯大写
      msg: "{{ testvar10 | upper }}"
  - debug:
      #将列表中的每个元素变成纯小写
      msg: "{{ testvar10 | lower }}"
  - debug:
      #去掉列表中重复的元素，重复的元素只留下一个
      msg: "{{ testvar11 | unique }}"
  - debug:
      #将两个列表合并，重复的元素只留下一个
      #也就是求两个列表的并集
      msg: "{{ testvar11 | union(testvar12) }}"
  - debug:
      #取出两个列表的交集，重复的元素只留下一个
      msg: "{{ testvar11 | intersect(testvar12) }}"
  - debug:
      #取出存在于testvar11列表中,但是不存在于testvar12列表中的元素
      #去重后重复的元素只留下一个
      #换句话说就是:两个列表的交集在列表1中的补集
      msg: "{{ testvar11 | difference(testvar12) }}"
  - debug:
      #取出两个列表中各自独有的元素,重复的元素只留下一个
      #即去除两个列表的交集，剩余的元素
      msg: "{{ testvar11 | symmetric_difference(testvar12) }}"
```

# 四、变量未定义相关操作过滤器

```
---
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    testvar6: ''
  tasks:
  - debug:
      #如果变量没有定义，则临时返回一个指定的默认值
      #注：如果定义了变量，变量值为空字符串，则会输出空字符
      #default过滤器的别名是d
      msg: "{{ testvar5 | default('zsythink') }}"
  - debug:
      #如果变量的值是一个空字符串或者变量没有定义，则临时返回一个指定的默认值
      msg: "{{ testvar6 | default('zsythink',boolean=true) }}"
  - debug:
      #如果对应的变量未定义,则报出“Mandatory variable not defined.”错误，而不是报出默认错误
      msg: "{{ testvar5 | mandatory }}"
```
