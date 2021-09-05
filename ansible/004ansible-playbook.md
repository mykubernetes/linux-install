# absible-playbook常用执行语法

## 1、检查语法是否正确
```
ansible-playbook --syntax-checak first.yaml
```

## 2、不实际运行测试
```
ansible-playbook -C first.yaml
```

## 3、检查运行的主机
```
ansible-playbook --list-host first.yaml
```

## 4、运行加密playbook文件时提示输入密码
```
ansible-playbook --ask-vault-pass example.yaml
```

## 5、指定要读取的Inventory清单文件
```
ansible-playbook example.yaml -i inventory
ansible-playbook example.yaml --inventory-file=inventory
```

## 6、列出执行匹配到的主机，但并不会执行任何动作。
```
ansible-playbook example.yaml --list-hosts
```

## 7、列出所有tags
```
ansible-playbook example.yaml --list-tags
```

## 8、列出所有即将被执行的任务
```
ansible-playbook example.yaml --list-tasks  
```

## 9、指定tags
```
ansible-playbook example.yaml --tags "configuration,install"
```

## 10、跳过tags
```
ansible-playbook example.yaml --skip-tags "install"
```

## 11、并行任务数。FORKS被指定为一个整数,默认是5
```
ansible-playbook example.yaml -f 5
ansible-playbook example.yaml --forks=5
```

## 12、指定运行的主机
```
ansible-playbook example.yaml --limit node01
```

## 13、查看主机变量
```
ansible node01 -m setup

ansible 172.16.1.8 -m setup -a "filter=ansible_memtotal_mb" -i hosts
172.16.1.8 | SUCCESS => {
    "ansible_facts": {
        "ansible_memtotal_mb": 1996, 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}

ansible 172.16.1.8 -m setup -a "filter=ansible_default_ipv4"
```
