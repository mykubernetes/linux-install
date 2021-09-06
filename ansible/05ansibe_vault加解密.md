ansible-vault加密及解密
===

- 编写playbook时，可能会涉及敏感的数据，比如密码，这些敏感数据以明文的方式存储在playbook中时，使用`ansible-vault`命令，对敏感数据进行加密，可以对整个文件加密，也可以对某个字符串加密（也就是变量加密）。

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

7、将密码写到文件中，通过文件对playbook进行加密
```
# echo "123123" > pwdfile
# ansible-vault encrypt --vault-password-file pwdfile test.yml
```

8、执行playbook时使用密码文件进行操作
```
# ansible-playbook --vault-password-file pwdfile test.yml
```

9、通过密码文件对playbook进行解密
```
# ansible-vault decrypt --vault-password-file pwdfile test.yml
```

10、从ansible2.4版本开始，官方不再推荐使用`--vault-password-file`选项，官方开始推荐使用`--vault-id`选项代替`--vault-password-file`选项指定密码文件，也就是说，如下两条命令的效果是一样的。
```
# ansible-vault encrypt --vault-id pwdfile test.yml
# ansible-vault decrypt --vault-password-file pwdfile test.yml
```

11、运行加密过的脚本和解密时，也可以使用`--vault-id`选项指定密码文件
```
# ansible-playbook --vault-id pwdfile test.yml
# ansible-vault decrypt --vault-id pwdfile test.yml
```

12、`--vault-id`选项不仅能够代替`--vault-password-file`选项，还能够代替`--ask-vault-pass`选项，交互式的输入密码
```
# ansible-playbook --vault-id prompt test.yml
```

13、两条同样会交互式的提示用户输入密码，输入正确的密码后，即可正常的运行加密过的剧本，也就是说，如下两条命令的效果是完全相同的。
```
# ansible-playbook --vault-id prompt test.yml
# ansible-playbook --ask-vault-pass test.yml
```

14、2.4版本以后的ansible中，`--vault-id`选项支持同时使用多个密码文件进行解密
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

```
# echo "123123" > pwdfile
# echo "123456" > pwdfile1
```

```
# ansible-vault encrypt --vault-id pwdfile test.yml
# ansible-vault encrypt --vault-id pwdfile1 test1.yml
```

```
# ansible-playbook --vault-id pwdfile1 --vault-id pwdfile test.yml
```

```
# ansible-vault decrypt --vault-id pwdfile1 --vault-id pwdfile test.yml test1.yml
```

```
# ansible-vault view --vault-id prompt --vault-id prompt test.yml test1.yml
```
