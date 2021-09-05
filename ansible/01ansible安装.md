# ansible安装配置

## 1、配置yum源
```
# pwd
/etc/yum.repos.d
 
# cat aliBase.repo
[aliBase]
name=aliBase
baseurl=https://mirrors.aliyun.com/centos/$releasever/os/$basearch/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/$releasever/os/$basearch/RPM-GPG-KEY-CentOS-$releasever
 
# cat aliEpel.repo
[aliEpel]
name=aliEpel
baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/
enabled=1
gpgcheck=0
```

## 2、安装ansible
```
# yum install -y ansible
```

## 3、配置
```
# vim /etc/ansible/ansible.cfg 
[defaults]
inventory = /etc/ansible/hosts                             #ansible inventory文件路径
library=/usr/share/my_modules/                             #库文件存放目录
remote_tmp = /tmp/.ansible/tmp                             #远程主机脚本临时存放目录
local_tmp = ~/.ansible/tmp                                 #本机的临时执行目录
forks = 5                                                  #并发数
poll_interval=15                                           #默认轮询时间间隔(单位秒)
become = root
sudo_user = root                                           #默认sudo用户
remote_port  = 22                                          #默认远程主机的端口号
host_key_checking = False                                  #避免ssh的时候输入yes
roles_path = /etc/ansible/roles:/usr/share/ansible/roles   #role路径
ask_sudo_pass = True                                       #每次执行是否询问sudo的ssh密码
ask_pass = True                                            #每次执行是否询问ssh密码
transport=smart                                            #传输方式
host_key_checking = False                                  #跳过检查主机指纹
timeout = 10
log_path = /var/log/ansible.log                            #开启ansible日志
private_key_file = /root/.ssh/id_rsa
#module_name = command                                     #默认执行模块，可以换成shell模块

[privilege_escalation]                                     #如果是普通用户则需要配置提权
become=True                                                #是否sudo
become_method=sudo                                         #sudo方式
become_user=root                                           #sudo 后变为root用户
become_ask_pass=False                                      #sudo 后是否验证密码
```
注意：控制端和被控制端第一次通讯，需要确认指纹信息, host_key_checking = False 参数注释打开即可

## 4、ansible读取配置文件优先级，自上而下
---
```
ANSIBLE_CONFIG
ansible.cfg                  # 项目目录
.ansible.cfg                 # 当前用户的家目录
/etc/ansible/ansible.cfg     # 优先级最低
```

## 5、配置ansible可以获取的主机
```
vim /etc/ansible/hosts

[all:vars]                           #定义所有主机变量
ansible_ssh_port=36000
ansible_user=root
ansible_ssh_pass='123456'

[webserver]
192.168.101.69
192.168.101.70

[dbserver]
192.168.101.[1:3]

[server:children]                    #定义server组包含两个子组[dbserver,webserver]
webserver
dbserver

——————————————————————————
#定义组变量
[atlanta]
host1
host2
 
[atlanta:vars]                       #表示要为这个组定义变量
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com
```

## 6、配置ssh互信
```
# 1、生成默认格式的密钥对，私钥与公钥。
# ssh-keygen

# 2、将生成的公钥加入到node01的认证列表
# ssh-copy-id -i /root/.ssh/id_rsa.pub root@node01
```

## 7、使用ping模块测试连
```
ansible  all  -m ping
192.168.101.69 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```
