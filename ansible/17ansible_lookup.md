
使用`with_indexed_items`关键字处理列表时，会自动的为列表中的每个元素添加序号，示例如下：
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is {{item.0}} , value is {{item.1}}"
    with_indexed_items: ['a','b','c']
```


```
TASK [debug] ***************************************
ok: [test70] => (item=[0, u'a']) => {
    "msg": "index is 0 , value is a"
}
ok: [test70] => (item=[1, u'b']) => {
    "msg": "index is 1 , value is b"
}
ok: [test70] => (item=[2, u'c']) => {
    "msg": "index is 2 , value is c"
}
```

其实，我们完全能够换一种写法，我们可以使用lookup插件，也可以做到与上述示例完全相同的效果，示例如下：
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "index is {{item.0}} , value is {{item.1}}"
    loop: "{{ lookup('indexed_items',['a','b','c']) }}"
```
如你所见，两个示例的不同之处在于

第一个示例使用”with_indexed_items关键字”处理列表

第二个示例使用”loop关键字”配合”lookup插件”处理列表

上例中，”lookup(‘indexed_items’,[‘a’,’b’,’c’])” 这段代码就是在使用lookup插件，它的含义是，使用名为’indexed_items’的lookup插件处理[‘a’,’b’,’c’]这个列表，没错，’indexed_items’就是一个lookup插件。

如果你执行上例的playbook，会发现，执行结果与之前的结果完全相同。

 

虽然说上述示例能够对lookup插件有一个初步的认识，但是仅仅依靠上述一个示例，还是不能够很明显的看出”循环”和”lookup”的关系，别急，我们再来看一个示例，之前总结过，我们可以使用”with_dict”关键字循环的获取到”字典”中的每个键值对，示例如下
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
      msg: "{{item.key}} is {{item.value}}"
    with_dict: "{{ users }}"
```
执行上例playbook以后，debug模块的输出信息如下
```
TASK [debug] ***************************************
ok: [test70] => (item={'value': u'male', 'key': u'bob'}) => {
    "msg": "bob is male"
}
ok: [test70] => (item={'value': u'female', 'key': u'alice'}) => {
    "msg": "alice is female"
}
```
其实，我们也可以换一种写法，没错，仍然是使用lookup插件，示例如下：
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
      msg: "{{item.key}} is {{item.value}}"
    loop: "{{ lookup('dict',users) }}"
```
如你所见，两个示例的区别在于

第一个示例使用”with_dict关键字”处理users字典变量

第二个示例使用”loop关键字”配合”lookup插件”处理users字典变量

上例中，”lookup(‘dict’,users)”表示使用名为’dict’的lookup插件处理users字典变量，没错，’dict’也是一个lookup插件

 

看完上述两个示例，你一定已经学会了怎样使用lookup插件，没错，lookup插件的用法如下

lookup(‘插件名’,被处理数据或参数)

 

那么话说回来，之前总结的”循环”和lookup插件有什么关系呢？聪明如你，一定已经从之前的示例中总结出了一些规律，没错，规律如下：

当我们需要使用循环时，可以使用”with_”开头的关键字处理数据，也可以使用”loop”关键字，使用loop关键字时，可以根据情况配合对应的lookup插件处理数据，具体的lookup插件名称与”with_”之后的名称相同，其实，在2.4版本的官网手册中有如下一句话：

在2.6版本的官网手册中，这句话稍微有些变动，如下：

这两句话的大概意思是，以”with_”开头的循环实际上就是”with_”和”lookup()”的组合，lookup插件可以作为循环的数据源，通过以上描述，你应该已经明白了我们之前总结的循环与各种lookup插件之间的关系了吧。

 

说到循环，我们顺势再聊一些关于循环的使用习惯的问题，在2.5版本之前的ansible中，大多数人都会使用以”with_”开头的关键字进行循环操作，从2.5版本开始，官方开始推荐使用”loop”关键字代替”with_xxx”风格的关键字，在推荐使用”loop”关键字的同时，官方认为，loop关键字结合lookup插件的使用方法不够简洁明了，所以官方同时推荐，在使用loop关键字进行循环操作时，最好配合过滤器来处理数据，官方认为这样做会使语法变得更加简洁明了，如果想要详细的描述官方推荐的使用方法，可能还需要更多的篇幅，所以，我会在之后的文章中单独的进行总结，以便大家可以更好的过渡到新的使用习惯，但在这篇文章中，我们先来聊聊lookup插件。

 

这篇文章一直在聊循环和lookup插件之间的关系，但是需要注意，不要错误的以为lookup插件只能实现循环操作，lookup插件有很多，有的lookup插件与”循环操作”完全没有关系，lookup类型的插件的主要作用是访问外部的数据源，比如，获取到外部数据并赋值给某个变量，以便之后使用这些数据，lookup插件的操作都是在ansible主机中进行的，与目标主机没有关系。

 

如果你想要查看有哪些lookup插件可以使用，可以使用如下命令进行查看
```
ansible-doc -t lookup -l
```
上述命令中，”-t”选项用于指定插件类型，”-l”选项表示列出列表

如果你想要单独查看某个插件的使用方法，比如dict插件的使用方法，则可以使用如下命令
```
ansible-doc -t lookup dict
```
 

先来认识一个很常用的lookup插件，file插件

 

file插件可以获取到指定文件的文件内容（注：文件位于ansible主机中），示例如下
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  - debug:
      msg: "{{ lookup('file','/testdir/testfile') }}"

上例表示获得/testdir/testfile文件中的内容，此文件中的内容为”testfile in test71″，执行上例playbook后debug模块输出如下：

TASK [debug] *******************************
ok: [test70] => {
    "msg": "testfile in test71"
}
```
 

如果想要获取多个文件中的内容，则可以传入多个文件路径，示例如下
```
  tasks:
  - debug:
      msg: "{{ lookup('file','/testdir/testfile','/testdir/testfile1') }}"
执行上例playbook以后，debug模块的输出信息如下：
TASK [debug] *******************************
ok: [test70] => {
    "msg": "testfile in test71,testfile1 in test71"
}
```
你一定已经看出来了，file插件获得多个文件中的内容时，会将多个文件中的内容放置在一个字符串中，并用”逗号”隔开每个文件中的内容，当我们想要得到一个完整的字符串时，这样非常方便，但是在某些时候，我可能并不想将所有文件的内容变成一整个字符串，而是想要获得一个字符串列表，将每个文件的内容当做列表中的一个独立的字符串，如果我想要实现这样的需求，该怎样做呢？我们可以使用”wantlist”参数，表示我们想要获取到的值是一个列表，而非字符串，示例如下
```
  tasks:
  - debug:
      msg: "{{ lookup('file','/testdir/testfile','/testdir/testfile1',wantlist=true) }}"
```
执行上例playbook，会发现各个文件的内容已经分开作为单独的字符串存放在了一个列表中。

 

从上述示例可以引出一个注意点：大多数lookup插件的默认行为会返回一个用逗号隔开的字符串，如果想要返回一个列表，则需要使用”wantlist=True”，在2.5版本的ansible中，引入了一个新的jinja2函数，这个函数叫做”query”，通过query函数也可以调用lookup插件，但是通过query函数调用lookup插件时，query函数的默认行为是返回一个列表，也就是说，如下两种写法是等价的
```
  - debug:
      msg: "{{ lookup('file','/testdir/testfile',wantlist=true) }}"
  - debug:
      msg: "{{ query('file','/testdir/testfile') }}"
```
而”query”函数又有一个简写的格式”q”，所以，如下写法与上述两种写法也是等价的
```
  - debug:
      msg: "{{ q('file','/testdir/testfile') }}"
```
 

在2.6版本的ansible中，我们可以使用errors关键字控制lookup插件出错时的处理机制，如果我想要在lookup插件执行出错时忽略错误，则可以将errors的值设置为ignore，示例如下：

  - debug:
      msg: "{{ lookup('file','/testdir/testfil',errors='ignore') }}"

如上例所示，errors的值需要使用引号引起，errors的值可以设置为ignore、warn或者strict，缺省值为strict

 

你肯定早就看出来了，当使用file插件对多个文件进行操作时，与之前总结的with_file在本质上没有什么区别。

 

我们通过file插件，了解到了lookup插件的特性，那么现在，我们来总结一些其他的lookup插件的用法。
```
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  #file插件可以获取ansible主机中指定文件的内容
  - debug:
      msg: "{{ lookup('file','/testdir/testfile') }}"
  #env插件可以获取ansible主机中指定变量的值
  - debug:
      msg: "{{ lookup('env','PATH') }}"
  #first_found插件可以获取列表中第一个找到的文件
  #按照列表顺序在ansible主机中查找
  - debug:
      msg: "{{ lookup('first_found',looklist) }}"
    vars:
      looklist:
        - /testdir
        - /tmp/staging
  #当使用with_first_found时，可以在列表的最后添加- skip: true
  #表示如果列表中的所有文件都没有找到，则跳过当前任务,不会报错
  #当不确定有文件能够被匹配到时，推荐这种方式
  - debug:
      msg: "{{item}}"
    with_first_found:
      - /testdir1
      - /tmp/staging
      - skip: true
  #ini插件可以在ansible主机中的ini文件中查找对应key的值
  #如下示例表示从test.ini文件中的testA段落中查找testa1对应的值
  #测试文件/testdir/test.ini的内容如下(不包含注释符#号)
  #[testA]
  #testa1=Andy
  #testa2=Armand
  #
  #[testB]
  #testb1=Ben
  - debug:
      msg: "{{ lookup('ini','testa1 section=testA file=/testdir/test.ini') }}"
  #当未找到对应key时，默认返回空字符串，如果想要指定返回值，可以使用default选项,如下
  #msg: "{{ lookup('ini','test666 section=testA file=/testdir/test.ini default=notfound') }}"
  #可以使用正则表达式匹配对应的键名，需要设置re=true，表示开启正则支持,如下
  #msg: "{{ lookup('ini','testa[12] section=testA file=/testdir/test.ini re=true') }}"
  #ini插件除了可以从ini类型的文件中查找对应key，也可以从properties类型的文件中查找key
  #默认在操作的文件类型为ini，可以使用type指定properties类型，如下例所示
  #如下示例中，application.properties文件内容如下(不包含注释符#号)
  #http.port=8080
  #redis.no=0
  #imageCode = 1,2,3
  - debug:
      msg: "{{ lookup('ini','http.port type=properties file=/testdir/application.properties') }}"
  #dig插件可以获取指定域名的IP地址
  #此插件依赖dnspython库,可使用pip安装pip install dnspython
  #如果域名使用了CDN，可能返回多个地址
  - debug:
      msg: "{{ lookup('dig','www.baidu.com',wantlist=true) }}"
  #password插件可以生成随机的密码并保存在指定文件中
  - debug:
      msg: "{{ lookup('password','/tmp/testpasswdfile') }}"
  #以上插件还有一些参数我们没有涉及到，而且也还有很多插件没有总结，等到用到对应的插件时，再行介绍吧
  #你也可以访问官网的lookup插件列表页面，查看各个插件的用法
  #https://docs.ansible.com/ansible/latest/plugins/lookup.html
  ```
