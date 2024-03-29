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

## 1、使用file模块在目标主机中创建文件,需要对文件是否有mode属性进行判断,然后根据判断结果调整file模块的参数设定。
```
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    paths:
      - path: /tmp/test
        mode: '0444'
      - path: /tmp/foo
      - path: /tmp/bar
  tasks:
  - file: dest={{item.path}} state=touch mode={{item.mode}}
    with_items: "{{ paths }}"
    when: item.mode is defined
  - file: dest={{item.path}} state=touch
    with_items: "{{ paths }}"
    when: item.mode is undefined
```

## 2、没有对文件是否有mode属性进行判断，而是直接调用了file模块的mode参数，如果item有mode属性，就把file模块的mode参数的值设置为item的mode属性的值，如果item没有mode属性，file模块就直接省略mode参数，’omit’的字面意思就是”省略”
```
- hosts: test70
  remote_user: root
  gather_facts: no
  vars:
    paths:
      - path: /tmp/test
        mode: '0444'
      - path: /tmp/foo
      - path: /tmp/bar
  tasks:
  - file: dest={{item.path}} state=touch mode={{item.mode | default(omit)}}
    with_items: "{{ paths }}"
```
- omit 是`省略`,有就用，没有就不用，可以有，也可以没有


# 五、常用过滤器

```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  ######################################################################
  #在调用shell模块时，如果引用某些变量时需要添加引号，则可以使用quote过滤器代替引号
  #示例如下，先看示例，后面会有注解
  - shell: "echo {{teststr | quote}} > /testdir/testfile"
    vars:
      teststr: "a\nb\nc"
  #上例中shell模块的写法与如下写法完全等效
  #shell: "echo '{{teststr}}' > /testdir/testfile"
  #没错，如你所见，quote过滤器能够代替引号
  #上例中，如果不对{{teststr}}添加引号，则会报错，因为teststr变量中包含"\n"转义符
  ######################################################################
  #ternary过滤器可以实现三元运算的效果 示例如下
  #如下示例表示如果name变量的值是John，那么对应的值则为Mr,否则则为Ms
  #简便的实现类似if else对变量赋值的效果
  - debug: 
      msg: "{{ (name == 'John') | ternary('Mr','Ms') }}"
    vars:
      name: "John"
  ######################################################################
  #basename过滤器可以获取到一个路径字符串中的文件名
  - debug:
      msg: "{{teststr | basename}}"
    vars:
      teststr: "/testdir/ansible/testfile"
  ######################################################################
  #获取到一个windows路径字符串中的文件名,2.0版本以后的ansible可用
  - debug:
      msg: "{{teststr | win_basename}}"
    vars:
      teststr: 'D:\study\zsythink'
  ######################################################################
  #dirname过滤器可以获取到一个路径字符串中的路径名
  - debug:
      msg: "{{teststr | dirname}}"
    vars:
      teststr: "/testdir/ansible/testfile"
  ######################################################################
  #获取到一个windows路径字符串中的文件名,2.0版本以后的ansible可用
  - debug:
      msg: "{{teststr | win_dirname}}"
    vars:
      teststr: 'D:\study\zsythink'
  ######################################################################
  #将一个windows路径字符串中的盘符和路径分开,2.0版本以后的ansible可用
  - debug:
      msg: "{{teststr | win_splitdrive}}"
    vars:
      teststr: 'D:\study\zsythink'
  #可以配合之前总结的过滤器一起使用，比如只获取到盘符，示例如下
  #msg: "{{teststr | win_splitdrive | first}}"
  #可以配合之前总结的过滤器一起使用，比如只获取到路径，示例如下
  #msg: "{{teststr | win_splitdrive | last}}"
  ######################################################################
  #realpath过滤器可以获取软链接文件所指向的真正文件
  - debug:
      msg: "{{ path | realpath }}"
    vars:
      path: "/testdir/ansible/testsoft"
  ######################################################################
  #relpath过滤器可以获取到path对于“指定路径”来说的“相对路径”
  - debug:
      msg: "{{ path | relpath('/testdir/testdir') }}"
    vars:
      path: "/testdir/ansible"
  ######################################################################
  #splitext过滤器可以将带有文件名后缀的路径从“.后缀”部分分开
  - debug:
      msg: "{{ path | splitext }}"
    vars:
      path: "/etc/nginx/conf.d/test.conf"
  #可以配置之前总结的过滤器，获取到文件后缀
  #msg: "{{ path | splitext | last}}"
  #可以配置之前总结的过滤器，获取到文件前缀名
  #msg: "{{ path | splitext | first | basename}}"
  ######################################################################
  #to_uuid过滤器能够为对应的字符串生成uuid
  - debug:
      msg: "{{ teststr | to_uuid }}"
    vars:
      teststr: "This is a test statement" 
  ######################################################################
  #bool过滤器可以根据字符串的内容返回bool值true或者false
  #字符串的内容为yes、1、True、true则返回布尔值true，字符串内容为其他内容则返回false
  - debug:
      msg: "{{ teststr | bool }}"
    vars:
      teststr: "1"
  #当和用户交互时，有可能需要用户从两个选项中选择一个，比如是否继续，
  #这时，将用户输入的字符串通过bool过滤器处理后得出布尔值，从而进行判断，比如如下用法
  #- debug:
  #    msg: "output when bool is true"
  #  when: some_string_user_input | bool
  ######################################################################
  #map过滤器可以从列表中获取到每个元素所共有的某个属性的值，并将这些值组成一个列表
  #当列表中嵌套了列表，不能越级获取属性的值，也就是说只能获取直接子元素的共有属性值。
  - vars:
      users:
      - name: tom
        age: 18
        hobby:
        - Skateboard
        - VideoGame
      - name: jerry
        age: 20
        hobby:
        - Music
    debug:
      msg: "{{ users | map(attribute='name') | list }}"
  #也可以组成一个字符串，用指定的字符隔开，比如分号
  #msg: "{{ users | map(attribute='name') | join(';') }}"
  ######################################################################
  #与python中的用法相同，两个日期类型相减能够算出两个日期间的时间差
  #下例中，我们使用to_datatime过滤器将字符串类型转换成了日期了类型，并且算出了时间差
  - debug:
      msg: '{{ ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 19:00:00" | to_datetime) }}'
  #默认情况下，to_datatime转换的字符串的格式必须是“%Y-%m-%d %H:%M:%S”
  #如果对应的字符串不是这种格式，则需要在to_datetime中指定与字符串相同的时间格式，才能正确的转换为时间类型
  - debug:
      msg: '{{ ("20160814"| to_datetime("%Y%m%d")) - ("2012-12-25 19:00:00" | to_datetime) }}'
  #如下方法可以获取到两个日期之间一共相差多少秒
  - debug:
      msg: '{{ ( ("20160814"| to_datetime("%Y%m%d")) - ("20121225" | to_datetime("%Y%m%d")) ).total_seconds() }}'
  #如下方法可以获取到两个日期“时间位”相差多少秒，注意：日期位不会纳入对比计算范围
  #也就是说，下例中的2016-08-14和2012-12-25不会纳入计算范围
  #只是计算20:00:12与08:30:00相差多少秒
  #如果想要算出连带日期的秒数差则使用total_seconds()
  - debug:
      msg: '{{ ( ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 08:30:00" | to_datetime) ).seconds }}'
  #如下方法可以获取到两个日期“日期位”相差多少天，注意：时间位不会纳入对比计算范围
  - debug:
      msg: '{{ ( ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 08:30:00" | to_datetime) ).days }}'
  ######################################################################
  #使用base64编码方式对字符串进行编码
  - debug:
      msg: "{{ 'hello' | b64encode }}"
  #使用base64编码方式对字符串进行解码
  - debug:
      msg: "{{ 'aGVsbG8=' | b64decode }}"
  #######################################################################
  #使用sha1算法对字符串进行哈希
  - debug:
      msg: "{{ '123456' | hash('sha1') }}"
  #使用md5算法对字符串进行哈希
  - debug:
      msg: "{{ '123456' | hash('md5') }}"
  #获取到字符串的校验和,与md5哈希值一致
  - debug:
      msg: "{{ '123456' | checksum }}"
  #使用blowfish算法对字符串进行哈希，注:部分系统支持
  - debug:
      msg: "{{ '123456' | hash('blowfish') }}"
  #使用sha256算法对字符串进行哈希,哈希过程中会生成随机"盐",以便无法直接对比出原值
  - debug:
      msg: "{{ '123456' | password_hash('sha256') }}"
  #使用sha256算法对字符串进行哈希,并使用指定的字符串作为"盐"
  - debug:
      msg: "{{ '123456' | password_hash('sha256','mysalt') }}"
  #使用sha512算法对字符串进行哈希,哈希过程中会生成随机"盐",以便无法直接对比出原值
  - debug:
      msg: "{{ '123123' | password_hash('sha512') }}"
  #使用sha512算法对字符串进行哈希,并使用指定的字符串作为"盐"
  - debug:
      msg: "{{ '123123' | password_hash('sha512','ebzL.U5cjaHe55KK') }}"
  #一些hash类型也允许提供「rounds」参数
  - debug:
      msg: "{{ '123123' | password_hash('sha256', 'mysecretsalt', rounds=10000) }}"
  #如下方法可以幂等的为每个主机的密码生成对应哈希串
  #有了之前总结的过滤器用法作为基础，你一定已经看懂了
  - debug:
      msg: "{{ '123123' | password_hash('sha512', 65534|random(seed=inventory_hostname)|string) }}"
```


# 六、Json数据查询过滤器

```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    domain_definition:
        domain:
            cluster:
                - name: "cluster1"
                - name: "cluster2"
            server:
                - name: "server11"
                  cluster: "cluster1"
                  port: "8080"
                - name: "server12"
                  cluster: "cluster1"
                  port: "8090"
                - name: "server21"
                  cluster: "cluster2"
                  port: "9080"
                - name: "server22"
                  cluster: "cluster2"
                  port: "9090"
            library:
                - name: "lib1"
                  target: "cluster1"
                - name: "lib2"
  tasks:
  - name: "Display all cluster names"
    debug:
      var: item
    loop: "{{ domain_definition | json_query('domain.library[*].name') }}"
```

```
# ansible-playbook test.yml 

PLAY [all] **********************************************************************************************************

TASK [Display all cluster names] ************************************************************************************
Saturday 11 September 2021  09:47:10 -0400 (0:00:00.062)       0:00:00.062 **** 
ok: [192.168.101.69] => (item=lib1) => {
    "item": "lib1"
}
ok: [192.168.101.69] => (item=lib2) => {
    "item": "lib2"
}

PLAY RECAP **********************************************************************************************************
192.168.101.69             : ok=1    changed=0    unreachable=0    failed=0   

Saturday 11 September 2021  09:47:10 -0400 (0:00:00.058)       0:00:00.120 **** 
=============================================================================== 
Display all cluster names ------------------------------------------------------------------------------------- 0.06s
```


# 七、数据格式化过滤器

1）过滤器`to_json``to_yaml`，将变量转换为json和yaml格式
```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    domain_definition:
        domain:
            cluster:
                - name: "cluster1"
                - name: "cluster2"
            server:
                - name: "server11"
                  cluster: "cluster1"
                  port: "8080"
                - name: "server12"
                  cluster: "cluster1"
                  port: "8090"
                - name: "server21"
                  cluster: "cluster2"
                  port: "9080"
                - name: "server22"
                  cluster: "cluster2"
                  port: "9090"
            library:
                - name: "lib1"
                  target: "cluster1"
                - name: "lib2"
  tasks:
  - name: "Display json"
    debug:
      msg: "{{ domain_definition | to_json }}"            # 将变量转换为json格式
  - name: "Display nice json"
    debug:
      msg: "{{ domain_definition | to_nice_json }}"       # 将变量转换为更加友好的json格式
  - name: "Display yaml"
    debug:
      msg: "{{ domain_definition | to_yaml }}"            # 将变量转换为yaml格式
  - name: "Display nice yaml"
    debug:
      msg: "{{ domain_definition | to_nice_yaml }}"       # 将变量转换为更加友好的yaml格式
  - name: "Display indent json"
    debug:
      msg: "{{ domain_definition | to_nice_json(indent=2) }}"   # 自定义json缩进的大小
  - name: "Display indent yaml"
    debug:
      msg: "{{ domain_definition | to_nice_yaml(indent=8) }}"   # 自定义yaml缩进的大小
```

```
# ansible-playbook test.yml 

PLAY [all] *********************************************************************************************************************************************

TASK [Display json] ************************************************************************************************************************************
Saturday 11 September 2021  10:15:16 -0400 (0:00:00.063)       0:00:00.063 **** 
ok: [192.168.101.69] => {
    "msg": "{\"domain\": {\"cluster\": [{\"name\": \"cluster1\"}, {\"name\": \"cluster2\"}], \"library\": [{\"name\": \"lib1\", \"target\": \"cluster1\"}, {\"name\": \"lib2\"}], \"server\": [{\"cluster\": \"cluster1\", \"name\": \"server11\", \"port\": \"8080\"}, {\"cluster\": \"cluster1\", \"name\": \"server12\", \"port\": \"8090\"}, {\"cluster\": \"cluster2\", \"name\": \"server21\", \"port\": \"9080\"}, {\"cluster\": \"cluster2\", \"name\": \"server22\", \"port\": \"9090\"}]}}"
}

TASK [Display nice json] *******************************************************************************************************************************
Saturday 11 September 2021  10:15:16 -0400 (0:00:00.045)       0:00:00.109 **** 
ok: [192.168.101.69] => {
    "msg": "{\n    \"domain\": {\n        \"cluster\": [\n            {\n                \"name\": \"cluster1\"\n            }, \n            {\n                \"name\": \"cluster2\"\n            }\n        ], \n        \"library\": [\n            {\n                \"name\": \"lib1\", \n                \"target\": \"cluster1\"\n            }, \n            {\n                \"name\": \"lib2\"\n            }\n        ], \n        \"server\": [\n            {\n                \"cluster\": \"cluster1\", \n                \"name\": \"server11\", \n                \"port\": \"8080\"\n            }, \n            {\n                \"cluster\": \"cluster1\", \n                \"name\": \"server12\", \n                \"port\": \"8090\"\n            }, \n            {\n                \"cluster\": \"cluster2\", \n                \"name\": \"server21\", \n                \"port\": \"9080\"\n            }, \n            {\n                \"cluster\": \"cluster2\", \n                \"name\": \"server22\", \n                \"port\": \"9090\"\n            }\n        ]\n    }\n}"
}

TASK [Display yaml] ************************************************************************************************************************************
Saturday 11 September 2021  10:15:16 -0400 (0:00:00.043)       0:00:00.153 **** 
ok: [192.168.101.69] => {
    "msg": "domain:\n  cluster:\n  - {name: cluster1}\n  - {name: cluster2}\n  library:\n  - {name: lib1, target: cluster1}\n  - {name: lib2}\n  server:\n  - {cluster: cluster1, name: server11, port: '8080'}\n  - {cluster: cluster1, name: server12, port: '8090'}\n  - {cluster: cluster2, name: server21, port: '9080'}\n  - {cluster: cluster2, name: server22, port: '9090'}\n"
}

TASK [Display nice yaml] *******************************************************************************************************************************
Saturday 11 September 2021  10:15:16 -0400 (0:00:00.046)       0:00:00.199 **** 
ok: [192.168.101.69] => {
    "msg": "domain:\n    cluster:\n    -   name: cluster1\n    -   name: cluster2\n    library:\n    -   name: lib1\n        target: cluster1\n    -   name: lib2\n    server:\n    -   cluster: cluster1\n        name: server11\n        port: '8080'\n    -   cluster: cluster1\n        name: server12\n        port: '8090'\n    -   cluster: cluster2\n        name: server21\n        port: '9080'\n    -   cluster: cluster2\n        name: server22\n        port: '9090'\n"
}

TASK [Display indent json] *****************************************************************************************************************************
Saturday 11 September 2021  10:15:16 -0400 (0:00:00.045)       0:00:00.244 **** 
ok: [192.168.101.69] => {
    "msg": "{\n  \"domain\": {\n    \"cluster\": [\n      {\n        \"name\": \"cluster1\"\n      }, \n      {\n        \"name\": \"cluster2\"\n      }\n    ], \n    \"library\": [\n      {\n        \"name\": \"lib1\", \n        \"target\": \"cluster1\"\n      }, \n      {\n        \"name\": \"lib2\"\n      }\n    ], \n    \"server\": [\n      {\n        \"cluster\": \"cluster1\", \n        \"name\": \"server11\", \n        \"port\": \"8080\"\n      }, \n      {\n        \"cluster\": \"cluster1\", \n        \"name\": \"server12\", \n        \"port\": \"8090\"\n      }, \n      {\n        \"cluster\": \"cluster2\", \n        \"name\": \"server21\", \n        \"port\": \"9080\"\n      }, \n      {\n        \"cluster\": \"cluster2\", \n        \"name\": \"server22\", \n        \"port\": \"9090\"\n      }\n    ]\n  }\n}"
}

TASK [Display indent yaml] *****************************************************************************************************************************
Saturday 11 September 2021  10:15:16 -0400 (0:00:00.045)       0:00:00.290 **** 
ok: [192.168.101.69] => {
    "msg": "domain:\n        cluster:\n        -       name: cluster1\n        -       name: cluster2\n        library:\n        -       name: lib1\n                target: cluster1\n        -       name: lib2\n        server:\n        -       cluster: cluster1\n                name: server11\n                port: '8080'\n        -       cluster: cluster1\n                name: server12\n                port: '8090'\n        -       cluster: cluster2\n                name: server21\n                port: '9080'\n        -       cluster: cluster2\n                name: server22\n                port: '9090'\n"
}

PLAY RECAP *********************************************************************************************************************************************
192.168.101.69             : ok=6    changed=0    unreachable=0    failed=0   

Saturday 11 September 2021  10:15:16 -0400 (0:00:00.046)       0:00:00.336 **** 
=============================================================================== 
Display indent yaml ----------------------------------------------------------------------------------------------------------------------------- 0.05s
Display yaml ------------------------------------------------------------------------------------------------------------------------------------ 0.05s
Display json ------------------------------------------------------------------------------------------------------------------------------------ 0.05s
Display nice yaml ------------------------------------------------------------------------------------------------------------------------------- 0.05s
Display indent json ----------------------------------------------------------------------------------------------------------------------------- 0.05s
Display nice json ------------------------------------------------------------------------------------------------------------------------------- 0.04s
```


2)过滤器`from_json``from_yaml`，从已经格式化好了的变量读取数据
```
# json文件
# cat file.json 
{"domain": {"cluster": [{"name": "cluster1"}, {"name": "cluster2"}], "library": [{"name": "lib1", "target": "cluster1"}, {"name": "lib2"}], "server": [{"cluster": "cluster1", "name": "server11", "port": "8080"}, {"cluster": "cluster1", "name": "server12", "port": "8090"}, {"cluster": "cluster2", "name": "server21", "port": "9080"}, {"cluster": "cluster2", "name": "server22", "port": "9090"}]}}


# ansible-playbook文件
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - shell: cat /tmp/file.json
    register: result
  - set_fact:
      myvar: "{{ result.stdout | from_json }}"           # 读取文件中的json数据
  - debug:
      msg: "{{ myvar }}"
```

```
# ansible-playbook test.yaml 

PLAY [all] ********************************************************************************************************************

TASK [shell] ******************************************************************************************************************
Saturday 11 September 2021  10:32:31 -0400 (0:00:00.062)       0:00:00.062 **** 
changed: [192.168.101.69]

TASK [set_fact] ***************************************************************************************************************
Saturday 11 September 2021  10:32:32 -0400 (0:00:00.438)       0:00:00.501 **** 
ok: [192.168.101.69]

TASK [debug] ******************************************************************************************************************
Saturday 11 September 2021  10:32:32 -0400 (0:00:00.046)       0:00:00.547 **** 
ok: [192.168.101.69] => {
    "msg": {
        "domain": {
            "cluster": [
                {
                    "name": "cluster1"
                }, 
                {
                    "name": "cluster2"
                }
            ], 
            "library": [
                {
                    "name": "lib1", 
                    "target": "cluster1"
                }, 
                {
                    "name": "lib2"
                }
            ], 
            "server": [
                {
                    "cluster": "cluster1", 
                    "name": "server11", 
                    "port": "8080"
                }, 
                {
                    "cluster": "cluster1", 
                    "name": "server12", 
                    "port": "8090"
                }, 
                {
                    "cluster": "cluster2", 
                    "name": "server21", 
                    "port": "9080"
                }, 
                {
                    "cluster": "cluster2", 
                    "name": "server22", 
                    "port": "9090"
                }
            ]
        }
    }
}

PLAY RECAP ********************************************************************************************************************
192.168.101.69             : ok=3    changed=1    unreachable=0    failed=0   

Saturday 11 September 2021  10:32:32 -0400 (0:00:00.043)       0:00:00.590 **** 
=============================================================================== 
shell ------------------------------------------------------------------------------------------------------------------ 0.44s
set_fact --------------------------------------------------------------------------------------------------------------- 0.05s
debug ------------------------------------------------------------------------------------------------------------------ 0.04s
```

```
# 过滤器from_yaml_all，用来解析YAML多文档文件
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - shell: cat /tmp/test.yml
    register: result
  - debug:
      msg: '{{ item }}'
    loop: '{{ result.stdout | from_yaml_all | list }}'

```

# 八、ip 过滤器
```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    ip: 192.0.2.1/24
    maca: "52:54:00"
  tasks:
  - name: "Display ip"
    debug:
      msg: '{{ ip | ipaddr("address") }}'         # ip地址过滤
  - name: "Display ipv4"
    debug:
      msg: '{{ ip | ipv4 }}'                      # ipv4地址过滤
  - name: "Display ipv6"
    debug:
      msg: '{{ ip | ipv6 }}'                      # ipv6地址过滤
  - name: "Display mac"
    debug:
      msg: "{{ maca | random_mac }}"              # MAC地址前缀的基础上，随机生成mac地址
```

# 九、注释过滤器
```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    ansible_managed: "date: %Y-%m-%d %H:%M:%S"
  tasks:
  - name: "Display comment"
    debug:
      msg: '{{ "Plain style (default)" | comment }}'                # 添加属性信息为#
  - name: "Display comment //...//"
    debug:
      msg: "{{ 'c style' | comment('c') }}"                         # 添加注释信息为//
  - name: "Display comment /*...*/"
    debug:
      msg: "{{ 'c block style' | comment('cblock') }}"              # 添加注释信息为/*
  - name: "Display comment %...%"
    debug:
      msg: "{{ 'Erlang style' | comment('erlang') }}"               # 添加注释信息为%
  - name: "Display comment <!--...-->"
    debug:
      msg: "{{ 'XML style' | comment('xml') }}"                     # 添加注释信息为<!
  - name: "Display comment decoration"
    debug:
      msg: "{{ 'my spcial case' | comment(decoration='! ') }}"      # 自定义注释符号
  - name: "Display Cistom  comment"
    debug:
      msg: "{{ 'custom style' | comment('plain', prefix='#######\n#', postfix='#\n#######\n   ###\n    #') }}"       #美观输出，可以定制格式
  - name: "Display Cistom  comment"
    debug:
      msg: "{{ ansible_managed | comment }}"                        # 通过变量注释
```

# 十、解析url过滤器

```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    url: "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment"
  tasks:
  - name: "Display hostname"
    debug:
      msg: "{{ url | urlsplit('hostname') }}"
  - name: "Display netloc"
    debug:
      msg: "{{ url | urlsplit('netloc') }}"
  - name: "Display username"
    debug:
      msg: "{{ url | urlsplit('username') }}"
  - name: "Display password"
    debug:
      msg: "{{ url | urlsplit('password') }}"
  - name: "Display path"
    debug:
      msg: "{{ url | urlsplit('path') }}"
  - name: "Display port"
    debug:
      msg: "{{ url | urlsplit('port') }}"
  - name: "Display scheme"
    debug:
      msg: "{{ url | urlsplit('scheme') }}"
  - name: "Display query"
    debug:
      msg: "{{ url | urlsplit('query') }}"
  - name: "Display fragment"
    debug:
      msg: "{{ url | urlsplit('fragment') }}"
  - name: "Display urlsplit"
    debug:
      msg: "{{ url | urlsplit }}"
```

```
# ansible-playbook test.yml 

PLAY [all] ********************************************************************************************************

TASK [Display hostname] *******************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.153)       0:00:00.153 **** 
ok: [192.168.101.69] => {
    "msg": "www.acme.com"
}

TASK [Display netloc] *********************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.060)       0:00:00.213 **** 
ok: [192.168.101.69] => {
    "msg": "user:password@www.acme.com:9000"
}

TASK [Display username] *******************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.049)       0:00:00.262 **** 
ok: [192.168.101.69] => {
    "msg": "user"
}

TASK [Display password] *******************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.043)       0:00:00.306 **** 
ok: [192.168.101.69] => {
    "msg": "password"
}

TASK [Display path] ***********************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.051)       0:00:00.357 **** 
ok: [192.168.101.69] => {
    "msg": "/dir/index.html"
}

TASK [Display port] ***********************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.046)       0:00:00.404 **** 
ok: [192.168.101.69] => {
    "msg": "9000"
}

TASK [Display scheme] *********************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.057)       0:00:00.462 **** 
ok: [192.168.101.69] => {
    "msg": "http"
}

TASK [Display query] **********************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.046)       0:00:00.508 **** 
ok: [192.168.101.69] => {
    "msg": "query=term"
}

TASK [Display fragment] *******************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.047)       0:00:00.556 **** 
ok: [192.168.101.69] => {
    "msg": "fragment"
}

TASK [Display urlsplit] ******************************************************************************************
Saturday 11 September 2021  22:24:06 -0400 (0:00:00.052)       0:00:00.609 **** 
ok: [192.168.101.69] => {
    "msg": {
        "fragment": "fragment", 
        "hostname": "www.acme.com", 
        "netloc": "user:password@www.acme.com:9000", 
        "password": "password", 
        "path": "/dir/index.html", 
        "port": 9000, 
        "query": "query=term", 
        "scheme": "http", 
        "username": "user"
    }
}

PLAY RECAP ********************************************************************************************************
192.168.101.69             : ok=10   changed=0    unreachable=0    failed=0   

Saturday 11 September 2021  22:24:06 -0400 (0:00:00.044)       0:00:00.653 **** 
=============================================================================== 
Display hostname -------------------------------------------------------------------------------------------- 0.06s
Display port ------------------------------------------------------------------------------------------------ 0.06s
Display fragment -------------------------------------------------------------------------------------------- 0.05s
Display password -------------------------------------------------------------------------------------------- 0.05s
Display netloc ---------------------------------------------------------------------------------------------- 0.05s
Display query ----------------------------------------------------------------------------------------------- 0.05s
Display path ------------------------------------------------------------------------------------------------ 0.05s
Display scheme ---------------------------------------------------------------------------------------------- 0.05s
Display urlsplit -------------------------------------------------------------------------------------------- 0.04s
Display username -------------------------------------------------------------------------------------------- 0.04s
```

# 十一、正则过滤器

```
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - name: "search for 'foo' in 'foobar'"
    debug:
      msg: "{{ 'foobar' | regex_search('(foo)') }}"                                # 匹配到则显示匹配到的值
  - name: "will return empty if it cannot find a match"
    debug:
      msg: "{{ 'ansible' | regex_search('(foobar)') }}"                            # 没匹配到则显示为空
  - name: "case insensitive search in multiline mode"
    debug:
      msg: "{{ 'foo\nBAR' | regex_search('^bar', multiline=True, ignorecase=True) }}"      # 不区分大小写匹配     
  - name: "Return a list of all IPv4 addresses in the string"
    debug:
      msg: "{{ 'Some DNS servers are 8.8.8.8 and 8.8.4.4' | regex_findall('\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b') }}"   # 对所有事件进行查找
  - name: 'convert "ansible" to "able"'
    debug:
      msg: "{{ 'ansible' | regex_replace('^a.*i(.*)$', 'a\\1') }}"                 # 将“ansible”转换为“able”
  - neme: 'onvert "foobar" to "bar"'
    debug:
      msg: "{{ 'foobar' | regex_replace('^f.*o(.*)$', '\\1') }}"                   # 将“foobar”反转为“bar” 
  - name: 'convert "localhost:80" to "localhost, 80" using named groups'
    debug:
      msg: "{{ 'localhost:80' | regex_replace('^(?P<host>.+):(?P<port>\\d+)$', '\\g<host>, \\g<port>') }}"    # 使用命名组将“localhost:80”转换为“localhost，80”
  - name: 'convert "localhost:80" to "localhost"'
    debug:
      msg: "{{ 'localhost:80' | regex_replace(':80') }}"                            # 将“localhost:80”转换为“localhost”
  - name: 'add "https://" prefix to each item in a list'
    debug:
      msg: "{{ 'hosts' | map('regex_replace', '^(.*)$', 'https://\\1') | list }}"   # 为列表中的每个项目添加“https://”前缀 
  - name: 'convert "^f.*o(.*)$" to "\^f\.\*o\(\.\*\)\$" '
    debug:
      msg: "{{ '^f.*o(.*)$' | regex_escape() }}"                                    # 将“^f.*o（.*）”转换为“^f.\*o”（\.\*\）\$” 
```

```
ansible-playbook test.yml 
 [WARNING]: Ignoring invalid attribute: neme


PLAY [all] ****************************************************************************************************************
TASK [search for 'foo' in 'foobar'] ***************************************************************************************
Saturday 11 September 2021  23:08:07 -0400 (0:00:00.073)       0:00:00.073 **** 
ok: [192.168.101.69] => {
    "msg": "foo"
}

TASK [will return empty if it cannot find a match] ************************************************************************
Saturday 11 September 2021  23:08:07 -0400 (0:00:00.060)       0:00:00.134 **** 
ok: [192.168.101.69] => {
    "msg": ""
}

TASK [case insensitive search in multiline mode] **************************************************************************
Saturday 11 September 2021  23:08:07 -0400 (0:00:00.056)       0:00:00.190 **** 
ok: [192.168.101.69] => {
    "msg": "BAR"
}

TASK [Return a list of all IPv4 addresses in the string] ******************************************************************
Saturday 11 September 2021  23:08:07 -0400 (0:00:00.059)       0:00:00.249 **** 
ok: [192.168.101.69] => {
    "msg": [
        "8.8.8.8", 
        "8.8.4.4"
    ]
}

TASK [convert "ansible" to "able"] ****************************************************************************************
Saturday 11 September 2021  23:08:07 -0400 (0:00:00.045)       0:00:00.295 **** 
ok: [192.168.101.69] => {
    "msg": "able"
}

TASK [debug] **************************************************************************************************************
Saturday 11 September 2021  23:08:08 -0400 (0:00:00.043)       0:00:00.339 **** 
ok: [192.168.101.69] => {
    "msg": "bar"
}

TASK [convert "localhost:80" to "localhost, 80" using named groups] *******************************************************
Saturday 11 September 2021  23:08:08 -0400 (0:00:00.042)       0:00:00.382 **** 
ok: [192.168.101.69] => {
    "msg": "localhost, 80"
}

TASK [convert "localhost:80" to "localhost"] ******************************************************************************
Saturday 11 September 2021  23:08:08 -0400 (0:00:00.044)       0:00:00.427 **** 
ok: [192.168.101.69] =
TASK [add "https://" prefix to each item in a list] ***********************************************************************
Saturday 11 September 2021  23:08:08 -0400 (0:00:00.042)       0:00:00.469 **** 
ok: [192.168.101.69] => {
    "msg": [
        "https://h", 
        "https://o", 
        "https://s", 
        "https://t", 
        "https://s"
    ]
}

TASK [convert "^f.*o(.*)$" to "\^f\.\*o\(\.\*\)\$"] ***********************************************************************
Saturday 11 September 2021  23:08:08 -0400 (0:00:00.047)       0:00:00.516 **** 
ok: [192.168.101.69] => {
    "msg": "\\^f\\.\\*o\\(\\.\\*\\)\\$"
}

PLAY RECAP ****************************************************************************************************************
192.168.101.69             : ok=10   changed=0    unreachable=0    failed=0   

Saturday 11 September 2021  23:08:08 -0400 (0:00:00.042)       0:00:00.559 **** 
=============================================================================== 
search for 'foo' in 'foobar' --------------------------------------------------------------------------------------- 0.06s
case insensitive search in multiline mode -------------------------------------------------------------------------- 0.06s
will return empty if it cannot find a match ------------------------------------------------------------------------ 0.06s
add "https://" prefix to each item in a list ----------------------------------------------------------------------- 0.05s
Return a list of all IPv4 addresses in the string ------------------------------------------------------------------ 0.05s
convert "localhost:80" to "localhost, 80" using named groups ------------------------------------------------------- 0.04s
convert "ansible" to "able" ---------------------------------------------------------------------------------------- 0.04s
debug -------------------------------------------------------------------------------------------------------------- 0.04s
convert "localhost:80" to "localhost" ------------------------------------------------------------------------------ 0.04s
convert "^f.*o(.*)$" to "\^f\.\*o\(\.\*\)\$"  ---------------------------------------------------------------------- 0.04s
```

# 十二、格式化时间数据
```
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - name: " Display year-month-day"
    debug:
      msg: "{{ '%Y-%m-%d' | strftime }}"
  - name: "Display hour:min:sec"
    debug:
      msg: "{{ '%H:%M:%S' | strftime }}"
  - name: "Use ansible_date_time.epoch fact"
    debug:
      msg: "{{ '%Y-%m-%d %H:%M:%S' | strftime }}"
  - name: "Use arbitrary epoch value"
    debug:
      msg: "{{ '%Y-%m-%d' | strftime(0) }}"
  - name: "Use arbitrary epoch value"
    debug:
      msg: "{{ '%Y-%m-%d' | strftime(1441357287) }}"
  - name: "Use ansible_date_time.epoch fact"
    debug:
      msg: "{{ '%Y-%m-%d' | strftime(ansible_date_time.epoch) }}"
```

```
# ansible-playbook test.yml 

PLAY [all] **********************************************************************************************************************

TASK [Display year-month-day] ***************************************************************************************************
Sunday 12 September 2021  00:06:46 -0400 (0:00:00.056)       0:00:00.056 ****** 
ok: [192.168.101.69] => {
    "msg": "2021-09-12"
}

TASK [Display hour:min:sec] *****************************************************************************************************
Sunday 12 September 2021  00:06:46 -0400 (0:00:00.044)       0:00:00.101 ****** 
ok: [192.168.101.69] => {
    "msg": "00:06:46"
}

TASK [Use ansible_date_time.epoch fact] *****************************************************************************************
Sunday 12 September 2021  00:06:46 -0400 (0:00:00.040)       0:00:00.141 ****** 
ok: [192.168.101.69] => {
    "msg": "2021-09-12 00:06:46"
}

TASK [Use arbitrary epoch value] ************************************************************************************************
Sunday 12 September 2021  00:06:46 -0400 (0:00:00.041)       0:00:00.183 ****** 
ok: [192.168.101.69] => {
    "msg": "1969-12-31"
}

TASK [Use arbitrary epoch value] ************************************************************************************************
Sunday 12 September 2021  00:06:46 -0400 (0:00:00.040)       0:00:00.223 ****** 
ok: [192.168.101.69] => {
    "msg": "2015-09-04"
}

PLAY RECAP **********************************************************************************************************************
192.168.101.69             : ok=5    changed=0    unreachable=0    failed=0   

Sunday 12 September 2021  00:06:46 -0400 (0:00:00.037)       0:00:00.261 ****** 
=============================================================================== 
 Display year-month-day -------------------------------------------------------------------------------------------------- 0.04s
Use ansible_date_time.epoch fact ----------------------------------------------------------------------------------------- 0.04s
Use arbitrary epoch value ------------------------------------------------------------------------------------------------ 0.04s
Display hour:min:sec ----------------------------------------------------------------------------------------------------- 0.04s
Use arbitrary epoch value ------------------------------------------------------------------------------------------------ 0.04s
```


# 十三、过滤器`type_debug`，用于debug输出数据类型
```
  - name: "Use arbitrary epoch value"
    debug:
      msg: "{{ 'myvar' | type_debug }}"
```

```
# ansible-playbook test.yml 

PLAY [all] ************************************************************************************************************************

TASK [Use arbitrary epoch value] **************************************************************************************************
Sunday 12 September 2021  00:07:39 -0400 (0:00:00.065)       0:00:00.065 ****** 
ok: [192.168.101.69] => {
    "msg": "str"
}

PLAY RECAP ************************************************************************************************************************
192.168.101.69             : ok=1    changed=0    unreachable=0    failed=0   

Sunday 12 September 2021  00:07:39 -0400 (0:00:00.050) 
=============================================================================== 
Use arbitrary epoch value -------------------------------------------------------------------------------------------------- 0.05s
```

# 十四、操作字典元素过滤器

```
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - name: "combine"
    debug:
      msg: "{{ {'a':1, 'b':2} | combine({'b':3, 'c':4}) }}"          # 默认情况下，不仅两个字典会被合并，字典数据也会被后面字典数据覆盖
  - name: "combine"
    debug:
      msg: "{{ {'a':{'foo':1, 'bar':2}, 'b':2} | combine({'a':{'bar':3, 'baz':4}}, recursive=True) }}"          # 如果字典类型是多层全套字典，我们可以添加「resursive=True」参数进行内层字典融合
  - name: "combine"
    debug:
      msg: "{{ 'a' | combine('b, c, d') }}"                 # 多个字典递归融合
```

```
# ansible-playbook t test.yml 
PLAY [all] *****************************************************************************************************************

TASK [combine] *************************************************************************************************************
Sunday 12 September 2021  00:21:15 -0400 (0:00:00.069)       0:00:00.069 ****** 
ok: [192.168.101.69] => {
    "msg": {
        "a": 1, 
        "b": 3, 
        "c": 4
    }
}

TASK [combine] *************************************************************************************************************
Sunday 12 September 2021  00:21:15 -0400 (0:00:00.045)       0:00:00.115 ****** 
ok: [192.168.101.69] => {
    "msg": {
        "a": {
            "bar": 3, 
            "baz": 4, 
            "foo": 1
        }, 
        "b": 2
    }
}

PLAY RECAP *****************************************************************************************************************
192.168.101.69             : ok=2    changed=0    unreachable=0    failed=0   

Sunday 12 September 2021  00:21:15 -0400 (0:00:00.060)       0:00:00.176 ****** 
=============================================================================== 
combine ------------------------------------------------------------------------------------------------------------- 0.06s
combine ------------------------------------------------------------------------------------------------------------- 0.05s
```

# 十五、操作列表过滤器zip和zip_longest

- 过滤器「zip」，使两个列表元素递归的融合，生成一个「itertools.izip」生成器对象。

-通常后面加上「list」过滤器来使用，表示list1[0]元素与list2[0]元素组合，作为新列表的第一个元素；list1[1]元素与list2[1]元素组合，作为新列表的第二个元素 ，以此类推…… 新列表元素个数以list1和list2中元素个数较少者为准。

```
- hosts: all
  remote_user: root
  gather_facts: no
  tasks:
  - name: "zip"
    debug:
      msg: "{{ [1,2,3,4,5] | zip(['a','b','c','d','e','f']) | list }}"
  - name: "zip_longset"
    debug:
      msg: "{{ [1,2,3] | zip_longest(['a','b','c','d','e','f'], [21, 22, 23], [100,200,300],fillvalue='X') | list }}"
```

```
# ansible-playbook test.yml 

PLAY [all] ***************************************************************************************************************

TASK [zip] ***************************************************************************************************************
Sunday 12 September 2021  00:57:42 -0400 (0:00:00.060)       0:00:00.060 ****** 
ok: [192.168.101.69] => {
    "msg": [
        [
            1, 
            "a"
        ], 
        [
            2, 
            "b"
        ], 
        [
            3, 
            "c"
        ], 
        [
            4, 
            "d"
        ], 
        [
            5, 
            "e"
        ]
    ]
}

TASK [zip_longset] *******************************************************************************************************
Sunday 12 September 2021  00:57:42 -0400 (0:00:00.049)       0:00:00.110 ****** 
ok: [192.168.101.69] => {
    "msg": [
        [
            1, 
            "a", 
            21, 
            100
        ], 
        [
            2, 
            "b", 
            22, 
            200
        ], 
        [
            3, 
            "c", 
            23, 
            300
        ], 
        [
            "X", 
            "d", 
            "X", 
            "X"
        ], 
        [
            "X", 
            "e", 
            "X", 
            "X"
        ], 
        [
            "X", 
            "f", 
            "X", 
            "X"
        ]
    ]
}

PLAY RECAP ***************************************************************************************************************
192.168.101.69             : ok=2    changed=0    unreachable=0    failed=0   

Sunday 12 September 2021  00:57:42 -0400 (0:00:00.043)       0:00:00.153 ****** 
==================================================
zip --------------------------------------------------------------------------------------------------------------- 0.05s
zip_longset ------------------------------------------------------------------------------------------------------- 0.04s
```


# 十六、操作列表过滤器subelements

- 过滤器「subelements」，操作对象为列表，摘取列表中的一个元素（通常为一个字典），将这个字典元素作为原始列表的新元素，其他元素保持不变。


```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    users:
      - name: alice
        authorized:
          - /tmp/alice/onekey.pub
          - /tmp/alice/twokey.pub
        groups:
          - wheel
          - docker
      - name: bob
        authorized:
          - /tmp/bob/id_rsa.pub
        groups:
          - docker
  tasks:
  - name: "zip"
    debug:
      msg: "{{ users | subelements('groups', skip_missing=True) }}"
```

```
# ansible-playbook test.yml 

PLAY [all] *************************************************************************************************************************

TASK [zip] *************************************************************************************************************************
Sunday 12 September 2021  01:02:14 -0400 (0:00:00.056)       0:00:00.056 ****** 
ok: [192.168.101.69] => {
    "msg": [
        [
            {
                "authorized": [
                    "/tmp/alice/onekey.pub", 
                    "/tmp/alice/twokey.pub"
                ], 
                "groups": [
                    "wheel", 
                    "docker"
                ], 
                "name": "alice"
            }, 
            "wheel"
        ], 
        [
            {
                "authorized": [
                    "/tmp/alice/onekey.pub", 
                    "/tmp/alice/twokey.pub"
                ], 
                "groups": [
                    "wheel", 
                    "docker"
                ], 
                "name": "alice"
            }, 
            "docker"
        ], 
        [
            {
                "authorized": [
                    "/tmp/bob/id_rsa.pub"
                ], 
                "groups": [
                    "docker"
                ], 
                "name": "bob"
            }, 
            "docker"
        ]
    ]
}

PLAY RECAP *************************************************************************************************************************
192.168.101.69             : ok=1    changed=0    unreachable=0    failed=0   

Sunday 12 September 2021  01:02:14 -0400 (0:00:00.048)       0:00:00.104 ****** 
=============================================================================== 
zip ------------------------------------------------------------------------------------------------------------------------- 0.05s
```

# 十七、列表与字典互相转换过滤器

- 过滤器`dict2items`，将字典变量转换为列表变量
- 过滤器`items2dict`，将列表变量转换为字典变量，默认情况下，列表元素必须有`key`和`value`
```
- hosts: all
  remote_user: root
  gather_facts: no
  vars:
    tags:
      Application: payment
      Environment: dev
    tagss:
      - key: Application
        value: payment
      - key: Environment
        value: dev
  tasks:
  - name: "dict2items"
    debug:
      msg: "{{ tags | dict2items }}"
  - name: "items2dict"
    debug:
      msg: "{{ tagss | items2dict }}"
  - name: "items2dict"
    debug:
      msg: "{{ tagss | items2dict(key_name='key_spec', value_name='value_spec') }}"
```

```
# ansible-playbook -i host test1.yml 
 [WARNING]: Found variable using reserved name: tags


PLAY [all] ********************************************************************************************************************

TASK [dict2items] *************************************************************************************************************
Sunday 12 September 2021  01:11:50 -0400 (0:00:00.061)       0:00:00.061 ****** 
ok: [192.168.101.69] => {
    "msg": [
        {
            "key": "Environment", 
            "value": "dev"
        }, 
        {
            "key": "Application", 
            "value": "payment"
        }
    ]
}

PLAY RECAP ********************************************************************************************************************
192.168.101.69             : ok=1    changed=0    unreachable=0    failed=0   

Sunday 12 September 2021  01:11:50 -0400 (0:00:00.041)       0:00:00.102 ****** 
=============================================================================== 
dict2items ------------------------------------------------------------------------------------------------------------- 0.04s
```

# 十八、map参数提取过滤器

```
- hosts: all
  remote_user: root
  tasks:
  - name: "msg"
    debug:
      msg: "{{ [0,2] | map('extract', ['x','y','z']) | list }}"
  - name: "msg"
    debug:
      msg: "{{ ['x','y'] | map('extract', {'x': 42, 'y': 31}) | list }}"
  - name: "x86"
    debug:
      msg: "{{ groups['all'] | map ('extract',hostvars,['ansible_architecture']) | list }}"     # 提取出主机组「all」主下「ansible_architecture」fact变量值
  - name: "ip"
    debug:
      msg: "{{ groups['all'] | map ('extract',hostvars,['ansible_default_ipv4','address']) | list }}"   # 查询节点的ip地址放到一个列表内
```

```
# ansible-playbook test.yml 

PLAY [all] ******************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************
Sunday 12 September 2021  01:37:23 -0400 (0:00:00.055)       0:00:00.055 ****** 
ok: [192.168.101.69]

TASK [msg] ******************************************************************************************************************
Sunday 12 September 2021  01:37:23 -0400 (0:00:00.871)       0:00:00.927 ****** 
ok: [192.168.101.69] => {
    "msg": [
        "x", 
        "z"
    ]
}

TASK [msg] ******************************************************************************************************************
Sunday 12 September 2021  01:37:24 -0400 (0:00:00.063)       0:00:00.990 ****** 
ok: [192.168.101.69] => {
    "msg": [
        42, 
        31
    ]
}

TASK [x86] ******************************************************************************************************************
Sunday 12 September 2021  01:37:24 -0400 (0:00:00.065)       0:00:01.056 ****** 
ok: [192.168.101.69] => {
    "msg": [
        "x86_64"
    ]
}

TASK [ip] *******************************************************************************************************************
Sunday 12 September 2021  01:37:24 -0400 (0:00:00.079)       0:00:01.135 ****** 
ok: [192.168.101.69] => {
    "msg": [
        "192.168.101.69"
    ]
}

PLAY RECAP ******************************************************************************************************************
192.168.101.69             : ok=5    changed=0    unreachable=0    failed=0   

Sunday 12 September 2021  01:37:24 -0400 (0:00:00.059)       0:00:01.194 ****** 
=============================================================================== 
Gathering Facts ------------------------------------------------------------------------------------------------------ 0.87s
x86 ------------------------------------------------------------------------------------------------------------------ 0.08s
msg ------------------------------------------------------------------------------------------------------------------ 0.07s
msg ------------------------------------------------------------------------------------------------------------------ 0.06s
ip ------------------------------------------------------------------------------------------------------------------- 0.06s

```
