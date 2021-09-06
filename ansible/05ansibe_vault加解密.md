ansible-vault加密及解密
===

- 编写playbook时，可能会涉及敏感的数据，比如密码，这些敏感数据以明文的方式存储在playbook中时，使用`ansible-vault`命令，对敏感数据进行加密，可以对整个文件加密，也可以对某个字符串加密（也就是变量加密）。

# 一、常用命令
```
ansible-vault create test.yml                                         # 加密创建新文件
ansible-vault create --vault-password-file=file test.yml              # 指定密码加密创建新文件（file要先写好）

ansible-vault view test.yml                                           # 查看加密的文件
ansible-vault edit test.yml                                           # 编辑加密的文件

ansible-vault encrypt test.yml                                        # 加密已经有的文件
ansible-vault decrypt test.yml                                        # 解密

ansible-vault rekey test.yml                                          # 更改密码
ansible-vault rekey --new-vault password-file=file test.yml           # 指定密码文件更改密码

ansible-playbook --vault-password-file=file test.yml                  # 执行加密的playbook（方式一）
ansible-playbook --vault-id @prompt test.yml                          # 执行加密的playbook（方式二）
ansible-playbook --ask-vault-pass test.yml                            # 手动输入密码执行playbook
```

# 二、通过命令对playbook进行手动加解密

1、编写playbook文件
```
# cat test.yml
- hosts: all
  tasks:
  - debug:
      msg: "Test ansible-vault"
```

2、对playbook文件进行加密
```
ansible-vault encrypt test.yml
```

3、查看文件内容发现已经加密
```
# cat test.yml
$ANSIBLE_VAULT;1.1;AES256
64323634303535336563333064663033393037316462363334656334396562643736663839386464
3062373266626165306238613264633230623837633436660a356638633436313332643735613335
31333935336437633064323761613632396631643334363730663131656661613063333265363838
3139306532613739660a386130346232656132366330383131323637613533323733646437366331
63663939396234376362336164663665326162323262313139383364373038636562306163636362
33396434663731356239303162656466343031316161346166373037666130353831393261313530
31646366353836303439323738323032306164623338346433323433623538353863633563633266
34313334623637336535
```

4、对加密的playbook执行会报错
```
# ansible-playbook test.yml
ERROR! Attempting to decrypt but no vault secrets found
```

5、运行加密的剧本时输入对应的密码才能执行
```
# ansible-playbook --ask-vault-pass test.yml
```

6、对加密过的文件进行解密操作
```
# ansible-vault decrypt test.yml
```

# 三、通过密码文件对playbook进行加解密

1、将密码写到文件中，通过文件对playbook进行加密
```
# echo "123123" > pwdfile
# ansible-vault encrypt --vault-password-file pwdfile test.yml
```

2、执行playbook时使用密码文件进行操作
```
# ansible-playbook --vault-password-file pwdfile test.yml
```

3、通过密码文件对playbook进行解密
```
# ansible-vault decrypt --vault-password-file pwdfile test.yml
```


# 四、ansible2.4版本以后引入`--vault-id`代替`--vault-password-file`

- 从ansible2.4版本开始，官方不再推荐使用`--vault-password-file`选项，官方开始推荐使用`--vault-id`选项代替`--vault-password-file`选项指定密码文件，也就是说，如下两条命令的效果是一样的。

1、使用`vault-id`对playbook进行加密
```
# ansible-vault encrypt --vault-id pwdfile test.yml
```

2、执行加密的polybook时也可以使用`--vault-id`选项指定密码文件
```
# ansible-playbook --vault-id pwdfile test.yml
```

3、使用`--vault-id`对文件加密过的playbook进行解密
```
# ansible-vault decrypt --vault-id pwdfile test.yml
```

4、`--vault-id`选项不仅能够代替`--vault-password-file`选项，还能够代替`--ask-vault-pass`选项，交互式的输入密码
```
# ansible-playbook --vault-id prompt test.yml
```

5、两条交互式命令效果是完全相同的。
```
# ansible-playbook --vault-id prompt test.yml
# ansible-playbook --ask-vault-pass test.yml
```


# 五、2.4版本以后的ansible中，`--vault-id`选项支持同时使用多个密码文件进行解密

1、创建两条playbook文件
```
# cat test.yml
- hosts: test70
  tasks:
  - debug:
      msg: "message from test"
  - include_tasks: test1.yml
 
# cat test1.yml
- debug:
    msg: "message from test1"
```

2、配置两条密码文件，分别存放不同的密码
```
# echo "123123" > pwdfile
# echo "123456" > pwdfile1
```

3、分别用两个密码文件对playbbook进行加密操作
```
# ansible-vault encrypt --vault-id pwdfile test.yml
# ansible-vault encrypt --vault-id pwdfile1 test1.yml
```

4、因为test.yml包含test1.yml，当调用test.yml时，也会调用test1.yml，但是使用了不同的密码加密了这两个yml文件，所以，必须同时提供两个密码文件
```
# ansible-playbook --vault-id pwdfile1 --vault-id pwdfile test.yml
```

5、可以一次性使用不同的密码文件解密不同的文件
```
# ansible-vault decrypt --vault-id pwdfile1 --vault-id pwdfile test.yml test1.yml
```
- 不用纠结密码文件与加密文件的对应关系，ansible会自动尝试这些密码文件

6、可以使用如下交互式命令，一次性的输入多个文件的解密密码，但是需要注意对应顺序
```
# ansible-vault view --vault-id prompt --vault-id prompt test.yml test1.yml
```

# 六、`--vault-id`选项还有一个小功能，就是在加密文件时，给被加密的文件`做记号`

1、对文件进行加密，使用pwdfile文件中的内容作为密码，并且在加密文件中加入了`zsy`记号
```
# ansible-vault encrypt --vault-id zsy@pwdfile test.yml
```

2、查看加密后文件内容
```
# cat test.yml
$ANSIBLE_VAULT;1.2;AES256;zsy
65633737626662646664343335303732383437626634306261326636336261303935316431626437
3362653939303733646533356665643737333830323833370a363530623865353831623936376463
31343961313638393865373061623439376632383038386464386662643935656261656130636135
6133366539386433370a366136646162626532303363636466366663373034383932643035313761
32346538656532323434613435393137633731383561653163373233626366623662356636643565
61666537316137323936613237663639333461333534653336313731653331323434666434663831
63323239373463626534393063383365666438363737653535333430636232336634663064393462
61623266373735373066316663303533633638353762653630323833376535666134316136356639
61386437656562383965656162376434666439633134643665393637663639363133
```
- 这些记号并不会对加密和解密的过程产生影响，只是为了方便管理，如果你是管理员，可能通过一些记号，能够更方便的对这些加密过的内容进行标识

3、在交互输入密码时添加记号，比如添加一个`记号`zsythink
```
# ansible-vault encrypt --vault-id zsythink@prompt test.yml
```

# 七、ansible-vault子命令

## 1、create

### 1)创建一个被加密的文件
```
# ansible-vault create test
```
- 命令后会提示你输入密码，确认密码，然后默认调用vi编辑器，输入的内容将会被保存到test文件中，并且在退出编辑器时自动将test文件加密。

## 2、view

### 1)查看已经被加密过的文件的原内容，不会对文件本身进行还原操作，只是查看原内容。
```
# ansible-vault view test.yml
# ansible-vault view --vault-id pwdfile test.yml
```

## 3、edit

### 1）直接修改被加密过的文件的原内容，相当于：先解密、修改原内容，再加密
```
# ansible-vault edit test.yml
# ansible-vault edit --vault-id pwdfile test.yml
```

## 4、rekey

### 1)修改被加密文件的密码
```
# ansible-vault rekey test.yml
```
- 一共会提示输入3次密码，第一次输入老密码，之后两次输入新密码。

### 2)如果之前使用密码文件进行的加密，可以使用`--new-vault-id`或者`--new-vault-password-file`选项，通过这两个选项的任何一个，都可以指定新的密码文件。
```
# ansible-vault rekey --vault-id pwdfile --new-vault-id pwdfile1 test.yml
```


## 5、encrypt_string

- 从2.3版本开始，使用encrypt_string子命令，可以加密`字符串`，通过加密字符串的功能，能够有效的隐藏敏感变量的值，比如，隐藏变量列表中密码变量的值

### 1）创建包含密码的playbook
```
# cat test.yml
- hosts: test71
  vars:
    test_user: "testuser"
    test_passwd: "123456"
  tasks:
  - debug:
      msg: "{{test_user}}"
  - debug:
      msg: "{{test_passwd}}"
```

### 2）使用`ansible-vault encrypt_string`命令对`123456`这个字符串进行加密，加密时会提示你输入密码，命令会将加密后的字符串输入到前台
```
# ansible-vault encrypt_string 123456
New Vault password:
Confirm New Vault password:
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          30316633646364663764333666383437373439353538353336623532323131623739353663653637
          3430626637386231366236643034643365323738336231330a326534623039363030393739663237
          65623635616666656233333337636439366535383334393138623231613035373133323832383335
          3737386234363761350a343839326663626664396436336465393862613237393864316533663533
          6335
```

### 3）复制这串文本，用这串文本替换playbook中的`123456`
```
# cat test.yml
- hosts: test71
  vars:
    test_user: "testuser"
    test_passwd: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          30316633646364663764333666383437373439353538353336623532323131623739353663653637
          3430626637386231366236643034643365323738336231330a326534623039363030393739663237
          65623635616666656233333337636439366535383334393138623231613035373133323832383335
          3737386234363761350a343839326663626664396436336465393862613237393864316533663533
          6335
  tasks:
  - debug:
      msg: "{{test_user}}"
  - debug:
      msg: "{{test_passwd}}"
```

### 4)运行带密码字符串的playbook和运行加密的文件一样，两条命令都可以。
```
# ansible-playbook --ask-vault-pass test.yml


# ansible-playbook --vault-id prompt test.yml
Vault password (default):
 
PLAY [test71] *************************************
 
TASK [Gathering Facts] *****************************
ok: [test71]
 
TASK [debug] *************************************
ok: [test71] => {
    "msg": "testuser"
}
 
TASK [debug] **************************************
ok: [test71] => {
    "msg": "123456"
}
 
PLAY RECAP **************************************
test71                     : ok=3    changed=0    unreachable=0    failed=0
```

### 5）加密字符串或者解密字符串时，可以使用`--vault-id`或者`--vault-password-file`选项指定`密码文件`，以免手动的输入加密时的密码
```
# echo aaaa > pwdfile
# ansible-vault encrypt_string --vault-id pwdfile 123456

# 将密码写入剧本后可以通过密码文件执行playbook
# ansible-playbook --vault-id pwdfile test.yml
```
- 使用密码文件的方式是最常见的，因为我们不可能在自动化的过程中手动的输入密码进行解密，所以密码文件的权限一定要控制好，无论是放在git上或者放在jenkins上，都应该做好权限控制。


### 6)`encrypt_string`子命令还有一个选项，能够设置加密后的字符串的变量名，它就是`--name`选项
```
# ansible-vault encrypt_string --vault-id pwdfile --name test_passwd 123456
test_passwd: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36396366336238376662353664383836316366383937623830626635613063343764333962376466
          3835646161363364303563373438643732626231303564320a393233333461663562383733643166
          62313362623838336433303032376565343264356665323832623565653631386536383762633764
          3961613265366336300a376564633034376238363664653565316163313739343639643565306665
          6264
Encryption successful
```
- 指定了变量名`test_passwd`，生成结果的格式就是`变量名：加密后的字符串`，其实与不使用`--name`选项时没有太大的区别，不过这样比较方便复制，你可以直接将生成的结果复制到playbook中

### 7)字符串加密也可以做标记
```
# ansible-vault encrypt_string --vault-id zsy@pwdfile --name test_passwd 123456
```
