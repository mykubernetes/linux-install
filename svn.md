
1、安装
```
# yum install -y subversion
```  

2、首先创建一个仓库。
```
# mkdir -pv /opt/svn
# svnadmin create /opt/svn/repos
```  

3、需要修改server的配置文件：
```
vim /tmp/svn/repos/conf/svnserve.conf
anon-access = none           #禁止匿名访问
auth-access = write          #认证后可写
password-db = passwd         #密码的数据库文件
authz-db = authz             #认证的数据库文件
```  

4、添加认证的用户passwd  
```
# vim /opt/svn/repos/conf/passwd
tomcat = 123        #用户密码
```

5、为仓库添加用户权限  
```
[repos:/]
tomcat = rw
```

6、启动svn服务器  
```
# svnserve -d -r /opt/svn/
# ps -ef |grep svn
root      12546      1  0 09:58 ?        00:00:00 svnserve -d -r /opt/svn/
root      12548  12421  0 09:58 pts/0    00:00:00 grep --color=auto svn
```  

7、导入文件夹到版本库：
```
svn import new_dir file:///opt/svn/repos/
svn import /tmp/shell file:///opt/svn/repos/new_dir -m "my first project"
```  


7、查看网络服务器信息及版本信息：
```
# svn list svn://192.168.101.70/repos
# svn list svn://192.168.101.70/repos/new_dir
# svn info svn://192.168.101.70/repos 
```  

8、下载工作目录到本地：  
```
# svn checkout svn://192.168.101.70/repos/new_dir
# cd new_dir/
# vim test_file
# svn add test_file
# svn co --username tomcat --password 123 svn://192.168.101.70/repos/shell
```  


9、更新版本：  
```
更新到最新版本
# svn update
更新至历史版本2
# svn update -r 2
```  

10、查看状态：  
```
svn status /tmp/shell/   ----------- 正常状态命令返回为空，M代表修改过的文件，A代表add的文件但是还没有commit
M       /tmp/shell/if/c.sh

svn commit -m "add while.sh and modify c.sh"  /tmp/shell/
```  

11、删除库中文件：  
```
svn delete svn://192.168.101.70/repos/shell/if/c.sh -m "delete c.sh"
```  

12、查看版本日志：  
```
# svn log svn://192.168.101.70/repos/shell
与版本系统中最新的文件进行对比。
# svn diff c.sh
比较历史版本。
# svn diff -r 3:5 c.sh
```  

钩子hook实现自动同步
```
cd /tmp/svn/repos/hooks
cat post-commit
#!/bin/bash

/usr/bin/ssh root@10.1.1.4 "export LANG=en_US.UTF-8; /usr/bin/svn update --username tomcat --password 123 /var/www/html/project/shell"
```  


