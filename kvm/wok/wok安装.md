代码扩管地址  
https://github.com/kimchi-project  

配置yum源  
```
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum install epel-release -y
```  

临时关闭selinux  
``` setenforce 0 ```  
	
永久关闭selinux  
``` sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config ```  

关闭防火墙（或自行开放相应端口）  
``` systemctl stop firewalld.service ```  

安装  
```
#安装wok
wget https://github.com/kimchi-project/wok/releases/download/2.5.0/wok-2.5.0-0.el7.centos.noarch.rpm
yum install wok-2.5.0-0.el7.centos.noarch.rpm

#安装kimchi
wget https://github.com/kimchi-project/kimchi/releases/download/2.5.0/kimchi-2.5.0-0.el7.centos.noarch.rpm
yum install kimchi-2.5.0-0.el7.centos.noarch.rpm

#启动
systemctl start wokd
```  

通过浏览器访问wok  
https://192.168.101.71:8001  
