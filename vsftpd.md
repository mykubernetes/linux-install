
一、安装
```
1.安装vsftp软件包
$ yum  -y install  vsftpd*

2.启动vsftpd服务器
$ systemctl  restart  vsftpd
$ systemctl enable vsftpd

3.检查服务是否正常启动
$ ps -ef|grep vsftp   &&  netstat -tunlp|grep 21
```
匿名用户的ftp已经搭建完成

二、提前关闭selinux 和firewalld防火墙
```
systemctl stop firewall
setenfore 0
```

三、windos客户端查看
```
/var/ftp/pub/               #linux服务上的原始目录
ftp://192.168.118.172/      #windos客户端访问的目录，没有用户名和密码
```

四、windos 端上传文件则需要修改配置文件
```
$ vim   /etc/vsftpd/vsftpd.conf

anon_upload_enable=YES                    #允许匿名用户上传
anon_mkdir_write_enable=YES               #允许匿名用户创建目录

$ systemctl  restart  vsftpd
$ chown -R ftp  /var/ftp/pub/                   #赋予子目录ftp用户所属组的权限
```


五、vsftp配置虚拟用户

1.创建vsftpd使用的系统用户，主目录为/home/vsftpd，禁止ssh登录。创建之后所有虚拟用户使用这个系统用户访问文件。
```
$ useradd   vsftpd -d    /home/vsftpd -s   /bin/false
```

2.创建虚拟用户主目录，比如虚拟用户叫ftp1。后续文件都放在这个目录下
```
$ mkdir -p /home/vsftpd/ftp1
```

3.指定虚拟用户的信息
```
$ vim  /etc/vsftpd/loginusers.conf   
ftp1
123456
#这样就创建了ftp1这个虚拟用户，密码为123456
```

4.根据这个文件创建数据库文件,并启动数据库文件
```
$ db_load -T -t hash -f /etc/vsftpd/loginusers.conf /etc/vsftpd/loginusers.db

$ chmod 600 /etc/vsftpd/loginusers.db
```
```
$ vim /etc/pam.d/vsftpd

# 注释掉原来所有内容后，增加下面的内容
auth    sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/loginusers
account sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/loginusers
```

5.增加虚拟用户的数据库的配置文件
```
$ mkdir /etc/vsftpd/userconf         #创建虚拟用户配置文件目录
$ vim   /etc/vsftpd/userconf/ftp1   #这里的文件名必须与前面指定的虚拟用户名一致
local_root=/home/vsftpd/ftp1/
write_enable=YES
```

6.修改主配置文件
```
$ vim   /etc/vsftpd/vsftpd.conf    #存在的修改，不存在的增加
anonymous_enable=NO           #禁止匿名用户登录
chroot_local_user=YES            #禁止用户访问除主目录以外的目录
ascii_upload_enable=YES          #设定支持ASCII模式的上传和下载功能   
ascii_download_enable=YES     #设定支持ASCII模式的上传和下载功能   
guest_enable=YES                     #启动虚拟用户
guest_username=vsftpd             ## 虚拟用户使用的系统用户名
user_config_dir=/etc/vsftpd/userconf   #虚拟用户使用的配置文件目录
allow_writeable_chroot=YES      #最新版的vsftpd为了安全必须用户主目录（也就是/home/vsftpd/ftp1）没有写权限，才能登录
```

7.重启vsftp服务
```
$ systemctl restart vsftpd
```
