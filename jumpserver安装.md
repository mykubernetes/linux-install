部署Jumpserver运行环境
=====================
实验环境：  
node001 jumpserver服务端  
node002  资源，被管理的服务器  
安装包下载  
链接：https://pan.baidu.com/s/1gVu4SotVOv2LnScgJ7RlPg 提取码：v4kb  

 一、准备工作
关闭 selinux 和防火墙  
```
# setenforce 0  # 可以设置配置文件永久关闭
# systemctl stop firewalld.service ; systemctl disable firewalld.service

# 修改字符集，否则可能报 input/output error的问题，因为日志里打印了中文
# localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8
# export LC_ALL=zh_CN.UTF-8
# echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf
# exit
再重新连接， 这样语言环境就改变了。  
```  
二、准备 Python3 和 Python 虚拟环境  
1、安装依赖包  
注：安装前，可以开启yum缓存功能，把软件包下载下来，方便后期使用。  
```
# vim /etc/yum.conf
改：keepcache=0
为：keepcache=1
# yum -y install wget sqlite-devel xz gcc automake zlib-devel openssl-devel epel-release git
```  
2、编译安装python3.6.1  
```
# cd /opt 
# tar xvf Python-3.6.1.tar.xz  && cd Python-3.6.1
# ./configure  &&  make  -j 4 && make install 
# 这里必须执行编译安装，否则在安装 Python 库依赖时会有麻烦...
注：在线下载 wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz
```  

3、建立 Python 虚拟环境  
因为 CentOS 6/7 自带的是 Python2，而 Yum 等工具依赖原来的 Python，为了不扰乱原来的环境我们来使用 Python 虚拟环境  
```
# cd /opt
# python3 -m venv py3
# source /opt/py3/bin/activate
(py3) [root@node001 ~]#        #切换成功的，前面有一个py3 标识  
```
看到下面的提示符代表成功，以后运行 Jumpserver 都要先运行以上 source 命令，以下所有命令均在该虚拟环境中运行  

三、安装 Jumpserver 1.0.0  
1、下载或 Clone 项目  
注：在线下载方法：  
```
git clone --depth=1 https://github.com/jumpserver/jumpserver.git && cd jumpserver && git checkout master
```  

2、 安装依赖 RPM 包  
```
# cd /opt/jumpserver/requirements
# yum -y install $(cat rpm_requirements.txt) 
```  
3、 安装 Python 库依赖  
```
# cd /opt/jumpserver/requirements
# source /opt/py3/bin/activate
(py3) [root@node001 ~]# pip -V
pip 9.0.1 from /opt/py3/lib/python3.6/site-packages (python 3.6) 
方法1：离线安装：
(py3) [root@node001 python-package]# cd /opt/python-package 
(py3) [root@node001 ~]# pip install  ./* 

方法2:在线安装：(py3) [root@node001 ~]#  pip install -r requirements.txt  
pip 是一个安装和管理 Python 包的工具，相当于yum命令
```  
4、安装 Redis, Jumpserver 使用 Redis 做 cache 和 celery broke  
```
# yum  -y install redis 
# systemctl enable redis  ;  systemctl start redis
```  
5、安装 MySQL  
本教程使用 Mysql 作为数据库，如果不使用 Mysql 可以跳过相关 Mysql 安装和配置  
```
# yum  install mariadb mariadb-devel mariadb-server   -y 
# systemctl enable mariadb  ;  systemctl start mariadb
```  
6、建数据库 Jumpserver 并授权  
```
# mysql
MariaDB [(none)]> create database jumpserver default charset 'utf8';
MariaDB [(none)]> grant all on jumpserver.* to 'jumpserver'@'127.0.0.1' identified by '123456';
MariaDB [(none)]> exit;
```  
7、改 Jumpserver 配置文件  
```
# cd /opt/jumpserver
# cp config_example.py config.py
# vim config.py
```  
我们计划修改 DevelopmentConfig 中的配置，因为默认 Jumpserver 使用该配置，它继承自 Config  
注意: 配置文件是 Python 格式，不要用 TAB，而要用空格  
```
class DevelopmentConfig(Config):
    DEBUG = True
    DB_ENGINE = 'mysql'
    DB_HOST = '127.0.0.1'
    DB_PORT = 3306
    DB_USER = 'jumpserver'
    DB_PASSWORD = '123456'
    DB_NAME = 'jumpserver'
如下：一定要注意前面空格的对齐。
``` 

8、成数据库表结构和初始化数据  
```
(py3) [root@node001 jumpserver]# cd /opt/jumpserver/utils
(py3) [root@node001 jumpserver]# bash make_migrations.sh  #注，在执行这一条命令之前，必续保障之前的pip install ./* 命令已经执行完了，不然后导入不了Django等软件包。
```
9、运行 Jumpserver
```
(py3) [root@node001 jumpserver]# cd /opt/jumpserver
(py3) [root@node001 jumpserver]# chmod +x jms
(py3) [root@node001 jumpserver]# ./jms start all -d # 后台运行使用 -d 参数 
注： ./jms start all #前台运行
如果运行失败了，重新启动一下。 
#启动服务的脚本，使用方式./jms start|stop|status|restart all  后台运行请添加 -d 参数  
```  
测试：  
访问 http://192.168.1.1:8080/   用户 ： admin 密码： admin  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver1.png)   
这里需要使用8080端口来访问页面。后期搭建 nginx 代理，就可以直接使用80端口正常访问了  
附上重启的方法  
``` (py3) [root@node001 jumpserver]# ./jms restart -d ```  

四、安装 Coco组件  
1、默认点击web终端，弹出：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver2.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver3.png)
所以接下来，我们安装luna和coco：  
coco概述：coco实现了 SSH Server 和 Web Terminal Server 的组件，提供 SSH 和 WebSocket 接口, 使用 Paramiko 和 Flask 开发。  
```
(py3) [root@node001 jumpserver]# cd /opt/coco  #直接使用离线代码
(py3) [root@node001 jumpserver]# source /opt/py3/bin/activate
```
附：在线下载代码：#``` git clone https://github.com/jumpserver/coco.git && cd coco && git checkout master ```  
2、 安装coco的依赖包，主要有rpm和python包  
```
(py3) [root@node001 jumpserver]# cd /opt/coco/requirements
(py3) [root@node001 jumpserver]# yum -y  install $(cat rpm_requirements.txt)  
(py3) [root@node001 jumpserver]# pip install -r requirements.txt 
注：扩展： pip download -r requirements.txt  #使用download可以下载python包到本地
```  
3、查看配置文件并运行  
```
(py3) [root@node001 jumpserver]# cd /opt/coco
(py3) [root@node001 jumpserver]# cp conf_example.py conf.py  # 如果 coco 与 jumpserver 分开部署，请手动修改 conf.py
(py3) [root@node001 coco]# chmod +x cocod 
(py3) [root@node001 jumpserver]# ./cocod start -d   #后台运行使用 -d 参数
新版本更新了运行脚本，使用方式./cocod start|stop|status|restart  后台运行请添加 -d 参数
```  
五、安装Web-Terminal前端-Luna组件-配置Nginx整合各组件  
1、安装luna组件  
Luna概述：Luna现在是 Web Terminal 前端，计划前端页面都由该项目提供，Jumpserver 只提供 API，不再负责后台渲染html等。  
访问（https://github.com/jumpserver/luna/releases）下载对应版本的 release 包，直接解压，不需要编译  
 解压 Luna  
 ```
(py3) [root@node001 jumpserver]# cd /opt
(py3) [root@node001 jumpserver]# tar xvf luna.tar.gz
(py3) [root@node001 jumpserver]# ls /opt/luna
注：在线下载
#wget https://github.com/jumpserver/luna/releases/download/v1.0.0/luna.tar.gz
```  
2、配置 Nginx 整合各组件  
安装 Nginx 根据喜好选择安装方式和版本  
``` (py3) [root@node001 jumpserver]# yum -y install nginx ```  
3、准备配置文件 修改 /etc/nginx/conf.d/jumpserver.conf  
内容如下：  
```
(py3) [root@node001 opt]#  vim /etc/nginx/nginx.conf
删除第38行到 57行中server {。。。}相关的内容，在vim命令模式，输入38gg，快速跳到38行，然后输入20dd，就可以删除。
删除后，在38行插入以一下内容:
```  
```
server {
    listen 80;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    location /luna/ {
        try_files $uri / /index.html;
        alias /opt/luna/;
    }

    location /media/ {
        add_header Content-Encoding gzip;
        root /opt/jumpserver/data/;
    }

    location /static/ {
        root /opt/jumpserver/data/;
    }

    location /socket.io/ {
        proxy_pass       http://localhost:5000/socket.io/;  # 如果coco安装在别的服务器，请填写它的ip
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location / {
        proxy_pass http://localhost:8080;  # 如果jumpserver安装在别的服务器，请填写它的ip
    }
}
```  
 运行 Nginx  
 ```
(py3) [root@node001 opt]# nginx -t   # 检测配置文件
(py3) [root@node001 jumpserver]# systemctl start nginx  ;  systemctl enable nginx
```

七、接受coco注册  
到会话管理-终端管理 接受 Coco的注册。点接受。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver4.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver5.png)  
再刷新页面：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver6.png)  
** 测试连接**  
(py3) [root@node001 jumpserver]# ssh -p2222 admin@192.168.1.63   #密码: admin
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver7.png)  
到此安装成功。  


八、jumpserver平台系统初始化  
1、系统基本设置  
这里要写成自己真实的URL地址，不然后期用户访问不了。http://192.168.1.63  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver8.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver9.png)  
2、配置邮件发送服务器  
点击页面上边的"邮件设置" TAB ，进入邮件设置页面： 
SMTP服务器：smtp.163.com
 ![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver10.png)  
注：自己邮箱要开启smtp和pop3服务。  
开启POP3/SMTP/IMAP服务方法：  
请登录163邮箱，点击页面右上角的“设置”—在“高级”下，点“POP3/SMTP/IMAP”，勾选图中两个选项，点击确定。即可开启成功。开通后即可用闪电邮、Outlook等软件收发邮件了。  
 ![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver11.png)  
服务器地址：POP3服务器：pop.163.com   |  SMTP服务器：smtp.163.com   | IMAP服务器：imap.163.com  
注：配置完后，需要重启一下服务。不然后期创建用户，收不到邮件。  
```
(py3) [root@node001 jumpserver]# /opt/jumpserver/jms stop all -d  
(py3) [root@node001 jumpserver]# /opt/jumpserver/jms start all -d  
```  
配置邮件服务后，点击页面的"测试连接"按钮，如果配置正确，Jumpserver 会发送一条测试邮件到您的 SMTP 账号邮箱里面：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver12.png)  
查看邮箱：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver13.png)  
收到邮件后，点提交：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver14.png)  
注意： 在使用jumpserver过程中，有一步是系统用户推送，要推送成功，client（后端服务器）要满足以下条件：   
1）后端服务器需要有python、sudo环境才能使用推送用户，批量命令等功能   
2）后端服务器如果开启了selinux，请安装libselinux-python。一般情况服务器上都关闭了selinux  

九、使用jumpserver 管理王者荣耀数万台游戏服务器  
1 ）用户管理  
1、添加用户组。  
用户名即 Jumpserver 登录账号。用户组是用于资产授权，当某个资产对一个用户组授权后，这个用户组下面的所有用户就都可以使用这个资产了。角色用于区分一个用户是管理员还是普通用户。  
点击用户管理 —> 查看用户组 —> 添加用户组  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver15.png)  
________________________________________  
添加新的小组 —> 王者荣耀-华北区运维部门  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver16.png)  
________________________________________  
查看刚才添加的组  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver17.png)  

2、添加用户  
点击用户管理 —> 用户列表 —> 创建用户  
其中，名称是真实姓名，用户名即 Jumpserver 登录账号。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver18.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver19.png)  
然后点提交。   

3、查看添加的用户  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver20.png)  

成功提交用户信息后，Jumpserver 会发送一条设置"用户密码"的邮件到您填写的用户邮箱。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver21.png)   
点击链接，开始修改密码：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver22.png)  
用户首次登录 Jumpserver，会被要求完善用户信息。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver23.png)  
这个需要用户自己生成SSH 密钥，方便后期登录：我在自己的另一台linux上，使用mk用户生成自己的ssh密钥。  
```
(py3) [root@node001 luna]# useradd mk123
(py3) [root@node001 luna]# echo 123456 | passwd --stdin mk123
[root@node001 opt]# su - mk123
[mk@node001 ~]$ ssh-keygen   #一路回车
[mk@node001 ~]$ cat ~/.ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE/7Yt3MKTvavCZSV2F9GCRX0snRDyAu2GzvmGaMj1Y1Evv0+bdNYuEVbax/CyakBcaYyBuD427trkQytfbfovc97As4fFV3yhKKKis6D66TR28zH5gGkhuToFhmil9BGFzJqy1M7fne+A18bKvezlFpZn4clwgg3kIqPCbOtQQnA9h1TH5j8lnvMwwcRxenKRMla987TfJ3482aTAoScxNmv2FNNSQmZEKHGPT5MmUIzrm3dwvCotAEmDegxJ0dB5u29tZaHgxMWFf1GRoj3pW8CzMOhug42F9FDF+K9wve5aph0mmc5pe7OKJthWrbv8CEV3T2mRYK4+M5q5sRed mk123@xuegod63.cn
```  
把上面生成的公钥粘到这里：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver24.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver25.png)  

4、编辑资产树添加节点  
节点不能重名，右击节点可以添加、删除和重命名节点，以及进行资产相关的操作。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver26.png)  
 改成节点名字为：王者荣耀-华北区-服务器  


5、创建管理用户  
Jumpserver里各个用户的说明：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver27.png)   
管理用户是服务器的 root，或拥有 NOPASSWD: ALL sudo 权限的用户，Jumpserver 使用该用户来推送系统用户、获取资产硬件信息等。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver28.png)  
王者荣耀-华北区-服务器管理用户-root     密码是： 123456   
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver29.png)  
前提，你的王者荣耀-华北区-服务器节点中所有的服务器root用户密码都是：123456  
这样就可以使用此root用户管理服务器。  

6、创建系统用户  
系统用户是 Jumpserver 跳转登录资产时使用的用户，可以理解为登录资产用户， Jumpserver使用系统用户登录资产。  
系统用户的 Sudo 栏填写允许当前系统用户免sudo密码执行的程序路径，如默认的/sbin/ifconfig，意思是当前系统用户可以直接执行 ifconfig 命令或 sudo ifconfig 而不需要输入当前系统用户的密码，执行其他的命令任然需要密码，以此来达到权限控制的目的。  
此处的权限应该根据使用用户的需求汇总后定制，原则上给予最小权限即可。  
系统用户创建时，如果选择了自动推送 Jumpserver 会使用 Ansible 自动推送系统用户到资产中，如果资产(交换机、Windows )不支持 Ansible, 请手动填写账号密码。  
Linux 系统协议项务必选择 ssh 。如果用户在系统中已存在，请去掉自动生成密钥、自动推送勾选。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver30.png)  
增加一个：检查服务器运行状态的用户： user 权限： /sbin/ifconfig,/usr/bin/top,/usr/bin/free  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver31.png)  

再加一个： 系统管理员用户：manager   
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver32.png)  

7、创建资产  
点击页面左侧的“资产管理”菜单下的“资产列表”按钮，查看当前所有的资产列表。  
点击页面左上角的“创建资产”按钮，进入资产创建页面，填写资产信息。  
IP 地址和管理用户要确保正确，确保所选的管理用户的用户名和密码能"牢靠"地登录指定的 IP 主机上。资产的系统平台也务必正确填写。公网 IP 信息只用于展示，可不填，Jumpserver 连接资产使用的是 IP 信息。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver33.png)  
开启虚拟机xuegod64.cn。 一会把这台机器当成资源添加平台中。  
node02-王者荣耀-华北区  192.168.1.2  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver34.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver35.png)  
资产创建信息填写好保存之后，可以看到已经可以连接资产，说明正常：
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver36.png)  
如果资产不能正常连接，请检查管理用户的用户名和密钥是否正确以及该管理用户是否能使用 SSH 从 Jumpserver 主机正确登录到资产主机上。  

8、网域列表  
网域功能是为了解决部分环境无法直接连接而新增的功能，原理是通过网关服务器进行跳转登录。  
这个功能，一般情况不用到。  

9、创建授权规则  
节点，对应的是资产，代表该节点下的所有资产。  
用户组，对应的是用户，代表该用户组下所有的用户。  
系统用户，及所选的用户组下的用户能通过该系统用户使用所选节点下的资产。  
节点，用户组，系统用户是一对一的关系，所以当拥有 Linux、Windows 不同类型资产时，应该分别给 Linux 资产和 Windows 资产创建授权规则。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver37.png)  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver38.png)  

 

授权成功后，你自己手动到node02上查看：  
```
[root@node001 ~]# tail /etc/passwd -n 5
postfix:x:89:89::/var/spool/postfix:/sbin/nologin
ntp:x:38:38::/etc/ntp:/sbin/nologin
tcpdump:x:72:72::/:/sbin/nologin
mk:x:1000:1000:mk:/home/mk:/bin/bash
manager:x:1001:1001::/home/manager:/bin/bash  #自动推送一个帐号，自动在资产服务器上创建系统用户
```  
[root@node002 ~]# visudo  #sudo相关的规则也会被自动推送过来  
``` manager ALL=(ALL) NOPASSWD: /sbin/,/bin/ ```  

9、用户使用资产  
登录 Jumpserver  
创建授权规则的时候，选择了用户组，所以这里需要登录所选用户组下面的用户才能看见相应的资产。  
使用无痕浏览器，再打开一个窗口，进行登录：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver39.png)  
用户正确登录后的页面：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver40.png)  
连接资产，点击页面左边的 Web 终端：  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver41.png)  
打开资产所在的节点：  
双击资产名字，就连上资产了：  
如果显示连接超时，请检查为资产分配的系统用户用户名和密钥是否正确，是否正确选择 Linux 操作系统，协议 ssh，端口22，以及资产的防火墙策略是否正确配置等信息。  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver42.png)  
接下来，就可以对资产进行操作了。  

10、在xshell字符终端下连接jumpserver管理服务器  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver43.png)  
输入jumpserver用户mk123 和密码123456  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver44.png)  
点击确定开始连接  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver45.png)  
Opt> 2   #输入一个2，就可以直接登录：192.168.1.2  
Connecting to manager@game64.xuegod.cn-王者荣耀-华北区 0.3  
Last login: Thu Jun  7 23:15:13 2018 from xuegod63.cn  
[manager@node002 ~]$ whoami  #发现登录使用的是系统用户manager  
manager  
[manager@node002 ~]$ exit  
登出  
Opt> p  #显示你有权限的主机  
 ID  Hostname                          IP              LoginAs       Comment  
  1  node02 -王者荣耀-华北区 192.168.1.2    [系统管理员用户]  

Opt> g  #显示你有权限的主机组  
  ID Name            Assets     Comment  
  1   王者荣耀-华北区-服务器                         1  

11、查看历史命令记录  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver46.png)  
12、查看历史会话并回放视频  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/jumpserver47.png)  
更多内容，可以参数官方手册：http://docs.jumpserver.org/zh/docs/step_by_step.html  

总结：  
Jumpserver堡垒机概述-部署Jumpserver运行环境  
安装Coco组件  
安装Web-Terminal前端-Luna组件-配置Nginx整合各组件  
jumpserver平台系统初始化  
使用jumpserver 管理王者荣耀数万台游戏服务器  
