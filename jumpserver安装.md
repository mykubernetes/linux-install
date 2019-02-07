部署Jumpserver运行环境
=====================
实验环境：  
node001 jumpserver服务端  
node002  资源，被管理的服务器  
 
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
在线安装：(py3) [root@node001 ~]#  pip install -r requirements.txt  
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
# cp config_example.yml config.py
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
9、行 Jumpserver
(py3) [root@node001 jumpserver]# cd /opt/jumpserver
(py3) [root@node001 jumpserver]# chmod +x jms
(py3) [root@node001 jumpserver]# ./jms start all -d # 后台运行使用 -d 参数 
注： ./jms start all #前台运行
如果运行失败了，重新启动一下。 
#启动服务的脚本，使用方式./jms start|stop|status|restart all  后台运行请添加 -d 参数  
```  
测试：  
访问 http://192.168.1.1:8080/   用户 ： admin 密码： admin  
 
这里需要使用8080端口来访问页面。后期搭建 nginx 代理，就可以直接使用80端口正常访问了  
附上重启的方法  

(py3) [root@node001 jumpserver]# ./jms restart -d  
34.2  安装 Coco组件  
34.2.1  安装coco组件  
1、默认点击web终端，弹出：  
 
 
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
(py3) [root@node001 jumpserver]# pip install -r requirements.txt   #前面已经离线安装过python的包，这里就很快安装成功了，或提示已经安装成功。
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
34.3 安装Web-Terminal前端-Luna组件-配置Nginx整合各组件  
34.3.1  安装luna组件  
Luna概述：Luna现在是 Web Terminal 前端，计划前端页面都由该项目提供，Jumpserver 只提供 API，不再负责后台渲染html等。  
访问（https://github.com/jumpserver/luna/releases）下载对应版本的 release 包，直接解压，不需要编译  
 解压 Luna  
 ```
(py3) [root@xuegod63 jumpserver]# cd /opt
(py3) [root@xuegod63 jumpserver]# tar xvf luna.tar.gz
(py3) [root@xuegod63 jumpserver]# ls /opt/luna
注：在线下载
#wget https://github.com/jumpserver/luna/releases/download/v1.0.0/luna.tar.gz
```  
34.3.2  配置 Nginx 整合各组件  
安装 Nginx 根据喜好选择安装方式和版本  
``` (py3) [root@node001 jumpserver]# yum -y install nginx ```  
5.2 准备配置文件 修改 /etc/nginx/conf.d/jumpserver.conf  
内容如下：  
```
(py3) [root@xuegod63 opt]#  vim /etc/nginx/nginx.conf
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
(py3) [root@xuegod63 opt]# nginx -t   # 检测配置文件
(py3) [root@xuegod63 jumpserver]# systemctl start nginx  ;  systemctl enable nginx
```
