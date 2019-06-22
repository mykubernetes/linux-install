官网  
https://www.rabbitmq.com/  

准备环境  
```
yum install -y build-essential openssl openssl-devel unixODBC unixODBC-devel make gcc gcc-c++ kernel-devel m4 ncurses-devel tk tc xz
```  
erlang与rabbix版本对应关系，必选对应上，否则无法使用  
https://www.rabbitmq.com/which-erlang.html  

安装下载：  
```
wget www.rabbitmq.com/releases/erlang/erlang-18.3-1.el7.centos.x86_64.rpm
wget http://repo.iotti.biz/CentOS/7/x86_64/socat-1.7.3.2-5.el7.lux.x86_64.rpm
wget www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/rabbitmq-server-3.6.5-1.noarch.rpm

rpm -ivh erlang-18.3-1.el7.centos.x86_64.rpm
rpm -ivh socat-1.7.3.2-5.el7.lux.x86_64.rpm
rpm -ivh rabbitmq-server-3.6.5-1.noarch.rpm
```  

修改配置文件  
```
vim /usr/lib/rabbitmq/lib/rabbitmq_server-3.6.5/ebin/rabbit.app

```  

启动 rabbitmq-server start &  
停止 rabbitmqctl app_stop  

管理插件：rabbitmq-plugins enable rabbitmq_management  
访问地址：http://192.168.11.76:15672/  
