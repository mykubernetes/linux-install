小乌龟svn下载地址  
https://tortoisesvn.net/downloads.html  
使用说明  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/Tortoisesvn.png)

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



6、导入文件夹到版本库(此步可忽略)  
```
# svn import /opt/new_dir file:///opt/svn/repos/new_dir -m "my first project"
```  

7、启动svn服务器  
```
# svnserve -d -r /opt/svn/
# ps -ef |grep svn
root      12546      1  0 09:58 ?        00:00:00 svnserve -d -r /opt/svn/
root      12548  12421  0 09:58 pts/0    00:00:00 grep --color=auto svn
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
# svn status /opt/new_dir/
M       /opt/new_dir/1     正常状态命令返回为空，M代表修改过的文件，A代表add的文件但是还没有commit
                 
# svn commit -m "add 1"  /opt/new_dir/
```  

11、删除库中文件：  
```
# svn delete svn://192.168.101.70/repos/new_dir/2 -m "delete 2"
```  

12、查看版本日志：  
```
# svn log svn://192.168.101.70/repos/new_dir
与版本系统中最新的文件进行对比。
# svn diff 1
比较历史版本。
# svn diff -r 3:5 1   
```  
- 3:5 第三个和第五比较
- 1 文件名


钩子hook实现自动同步
```
cd /tmp/svn/repos/hooks
cat post-commit
#!/bin/bash

/usr/bin/ssh root@10.1.1.4 "export LANG=en_US.UTF-8; /usr/bin/svn update --username tomcat --password 123 /var/www/html/project/shell"
```  

SVN 备份的三种方式
===
svnadmin dump是官方推荐的备份方式，优点是比较灵活，可以全量备份也可以增量备份，并提供了版本恢复机制
- 缺点是：如果版本比较大，如版本数增长到数万、数十万，那么dump的过程将非常慢；备份耗时，恢复更耗时；不利于快速进行灾难恢复。个人建议在版本数比较小的情况下使用这种备份方式。 

```
#!/bin/sh
##Subversion decritory and file
SVN_HOME=/usr/local/subversion/bin/  
SVN_ADMIN=$SVN_HOME/svnadmin  
SVN_LOOK=$SVN_HOME/svnlook

SVN_REPOROOT=/data/svnroot/repository                    

#backup file path
date=$(date '+%Y-%m-%d')  
RAR_STORE=/data/svnbackup/full/$date  
if [ ! -d "$RAR_STORE" ];then  
mkdir -p $RAR_STORE  
fi

cd $SVN_REPOROOT  
#Projectname 指库名
for name in $(ls|grep Projectname)  
do  
$SVN_ADMIN dump $SVN_REPOROOT/$name > $RAR_STORE/full.$name.bak
done  
```

svnadmin hotcopy原设计目的估计不是用来备份的，只能进行全量拷贝，不能进行增量备份
- 优点是：备份过程较快，灾难恢复也很快；如果备份机上已经搭建了svn服务，甚至不需要恢复，只需要进行简单配置即可切换到备份库上工作。
- 缺点是：比较耗费硬盘，需要有较大的硬盘支持

```
#!/bin/sh
##Subversion decritory and file
SVN_HOME=/usr/local/subversion/bin/  
SVN_ADMIN=$SVN_HOME/svnadmin  
SVN_LOOK=$SVN_HOME/svnlook

SVN_REPOROOT=/data/svnroot/repository

#backup file path
date=$(date '+%Y-%m-%d')  
RAR_STORE=/data/svnbackup/hotcopy/$date  
if [ ! -d "$RAR_STORE" ];then  
mkdir -p $RAR_STORE  
fi

cd $SVN_REPOROOT  
#Projectname 指库名
for name in $(ls|grep Projectname)  
do  
$SVN_ADMIN hotcopy $SVN_REPOROOT/$name $RAR_STORE/$name
done  
```


svnsync实际上是制作2个镜像库，当一个坏了的时候，可以迅速切换到另一个。不过，必须svn1.4版本以上才支持这个功能。
- 优点是：当制作成2个镜像库的时候起到双机实时备份的作用；
- 缺点是：当作为2个镜像库使用时，没办法做到“想完全抛弃今天的修改恢复到昨晚的样子”；而当作为普通备份机制每日备份时，操作又较前2种方法麻烦。
- 由于版本数比较大 采用第二种做全量备份

```
#!/bin/sh
##Subversion decritory and file
SVN_HOME=/usr/local/subversion/bin/  
SVN_ADMIN=$SVN_HOME/svnadmin  
SVN_LOOK=$SVN_HOME/svnlook

SVN_REPOROOT=/data/svnroot/repository

#backup file path
date=$(date '+%Y-%m-%d')  
RAR_STORE=/data/svnbackup/incremental/$date  
if [ ! -d "$RAR_STORE" ];then  
mkdir -p $RAR_STORE  
fi

#log file path
Log_PATH=/data/svnbackup/log  
if [ ! -d "$Log_PATH" ];then  
mkdir -p $Log_PATH  
fi

#read repo list
cd $SVN_REPOROOT  
#Projectname 指库名
for name in $(ls|grep Projectname)  
do  
if [ ! -d "$RAR_STORE/$name" ];then  
mkdir $RAR_STORE/$name  
fi

cd $RAR_STORE/$name  
if [ ! -d "$Log_PATH/$name" ];then  
mkdir $Log_PATH/$name  
fi

echo ******Starting backup from $date****** >> $Log_PATH/$name/$name.log  
echo ******svn repository $name startting to backup****** >> $Log_PATH/$name/$name.log  
$SVN_LOOK youngest $SVN_REPOROOT/$name > $Log_PATH/A.TMP
UPPER=`head -1 $Log_PATH/A.TMP`

NUM_LOWER=`head -1 $Log_PATH/$name/last_revision.txt`  
let LOWER="$NUM_LOWER+1"

$SVN_ADMIN dump $SVN_REPOROOT/$name -r $LOWER:$UPPER --incremental > $RAR_STORE/$name/$LOWER-$UPPER.dump
rm -f $Log_PATH/A.TMP  
echo $UPPER > $Log_PATH/$name/last_revision.txt  
echo ******This time we bakcup from $LOWER to $UPPER****** >> $Log_PATH/$name/$name.log  
echo ******Back up ended****** >> $Log_PATH/$name/$name.log  
done
```
