| 目录 | 目录描述 |
|------|--------|
| tasks | 角色需要执行的主任务文件放置在此目录中，默认的主任务文件名为main.yml，当调用角色时，默认会执行main.yml文件中的任务，你也可以将其他需要执行的任务文件通过include的方式包含在tasks/main.yml文件中。 |
| handlers | 当角色需要调用handlers时，默认会在此目录中的main.yml文件中查找对应的handler |
| defaults | 角色会使用到的变量可以写入到此目录中的main.yml文件中，通常，defaults/main.yml文件中的变量都用于设置默认值，以便在你没有设置对应变量值时，变量有默认的值可以使用，定义在defaults/main.yml文件中的变量的优先级是最低的。 |
| vars | 角色会使用到的变量可以写入到此目录中的main.yml文件中，看到这里你肯定会有疑问，vars/main.yml文件和defaults/main.yml文件的区别在哪里呢？区别就是，defaults/main.yml文件中的变量的优先级是最低的，而vars/main.yml文件中的变量的优先级非常高，如果你只是想提供一个默认的配置，那么你可以把对应的变量定义在defaults/main.yml中，如果你想要确保别人在调用角色时，使用的值就是你指定的值，则可以将变量定义在vars/main.yml中，因为定义在vars/main.yml文件中的变量的优先级非常高，所以其值比较难以覆盖。 |
| meta | 如果你想要赋予这个角色一些元数据，则可以将元数据写入到meta/main.yml文件中，这些元数据用于描述角色的相关属性，比如 作者信息、角色主要作用等等，你也可以在meta/main.yml文件中定义这个角色依赖于哪些其他角色，或者改变角色的默认调用设定，在之后会有一些实际的示例，此处不用纠结。 |
| templates目 | 角色相关的模板文件可以放置在此目录中，当使用角色相关的模板时，如果没有指定路径，会默认从此目录中查找对应名称的模板文件。 |
| files | 角色可能会用到的一些其他文件可以放置在此目录中，比如，当你定义nginx角色时，需要配置https，那么相关的证书文件即可放置在此目录中。 |

ansible的配置文件,可以设置自己的角色搜索目录
```
# vim /etc/ansible/ansible.cfg
roles_path    = /etc/ansible/roles:/opt:/testdir
```

角色入口
```
# mkdir tasks
# touch tasks/main.yml

# cat tasks/main.yml
- debug:
    msg: "hello role!"
```

在剧本中调用角色
```
- hosts: node
  roles:
  - role: testrole
```

同时定义多个角色
```
- hosts: master
  roles:
    - { role: kubespray-defaults, tags: always }
    - { role: ceph, tags: always }
    - { role: mysql, tags: always }
```


在调用角色时，也可以使用变量，以便对应的任务可以使用这个变量。
```
- hosts: node
  roles:
  - role: testrole
    vars:
      testvar: "www.zsythink.net"
```

defaults目录存放的是变量的默认值
```
# cat testrole/defaults/main.yml
testvar: "role"
```

在默认情况下，角色中的变量是全局可访问的,可以将变量的访问域变成角色所私有的，如果想要将变量变成角色私有的，则需要设置/etc/ansible/ansible.cfg文件，将private_role_vars的值设置为yes,默认情况下，”private_role_vars = yes”是被注释掉的，将前面的注释符去掉皆可
```
# vim /etc/ansible/ansible.cfg
private_role_vars = yes
```

默认情况下，ansible无法多次调用同一个角色，也就是说，如下playbook只会调用一次testrole角色
```
# cat test.yml
- hosts: test70
  roles:
  - role: testrole
  - role: testrole
```
执行上例playbook会发现，testrole的debug模块只输出了一次，如果想要多次调用同一个角色，有两种方法，如下：
- 方法一：设置角色的allow_duplicates属性 ，让其支持重复的调用。
- 方法二：调用角色时，传入的参数值不同。

方法一、需要为角色设置allow_duplicates属性，而此属性需要设置在meta/main.yml文件中，所以需要在testrole中创建meta/main.yml文件，写入如下内容
```
# cat testrole/meta/main.yml
allow_duplicates: true
```
- 将allow_duplicates属性设置为true，表示可以重复调用同一个角色。

方法二、当调用角色需要传参时，如果参数的值不同，则可以连续调用多次
```
# cat test.yml
- hosts: test70
  roles:
  - role: testrole
    vars:
      testvar: "zsythink"
  - role: testrole
    vars:
      testvar: "zsythink.net"
```

vars/main.yml中的变量优先级高于defaults/main.yml中定义的变量
```
# cat testrole/defaults/main.yml
testvar: "test"
# cat testrole/vars/main.yml
testvar: "testvar_in_vars_directory"
```

角色中需要定义一些模板，可以直接将模板文件放到templates目录中。
```
# cat testrole/templates/test.conf.j2
something in template;
{{ template_var }}
```

在角色中使用一些handlers以便进行触发，则可以直接将对应的handler任务写入到handlers/main.yml文件中
```
# cat testrole/handlers/main.yml
- name: test_handler
  debug:
    msg: "this is a test handler"
```









