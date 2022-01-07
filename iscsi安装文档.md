LIO iscsi 安装测试文档
Target端配置

一、检查操作系统是否加载iscsi模块。内核版本要求linux 2.6.38以上。  
```
uname -r
lsmod |grep iscsi
```

二、安装targetcli  
```
yum install targetcli –y
```  

三、配置ramdisk（3种，选择一个支持的）  
1)	直接使用系统生成的ramdisk（/dev/ram0-15）  
a)	使用fdisk查看ramdisk大小  
b)	修改grub.cfg 在kernel字段添加 ramdisk_size=5120000 ，重启服务器，确认ramdisk大小为设定大小。  
2)	使用ramfs生成内存文件  
a)	使用mount命令创建挂载点：mount -t ramfs none /testRAM -o maxsize=5120000  
b)	使用dd命令生成一个内存文件充当裸设备：dd if=/dev/zero of=/testRAM/ramfs.img bs=1M oflag=dsync  
3)	使用tmpfs生成内存文件  
a)	使用mount命令创建挂载点：mount tmpfs /tmpfs -t tmpfs -o size=5G  
b)	使用dd命令生成一个内存文件充当裸设备：dd if=/dev/zero of=/tmpfs/tmpfs.img bs=1M oflag=dsync  

四、配置LIO target  

1)启动iscsi  
```
systemctl start target.service
```  

2)检查服务启动情况  
```
systemctl status target.service
```  

3)进入targetcli  
```
# targetcli
targetcli shell version 2.1.fb34
Copyright 2011-2013 by Datera, Inc and others.
For help on commands, type 'help'.

/> ls     
o- / ............................................................................ [...]
  o- backstores ............................................................... [...]
   | o- block ..................... ............................ [Storage Objects: 0]
   | o- fileio .................................................. [Storage Objects: 0]
   | o- pscsi .................................................. [Storage Objects: 0]
   | o- ramdisk .............................................. [Storage Objects: 0]
  o- iscsi ............................................................ [Targets: 0]
  o- loopback ...................................................... [Targets: 0]
/> 

/> cd iscsi   	 #切换到iscsi目录

/iscsi> create    #创建一个默认iqn，当然也可以手动指定，在这里我们使用create命令自动生成iqn。

/iscsi> ls  查看创建情况
 
前边的操作创建了target 门户，后边需要开始关联到后端存储。

/iscsi> cd /backstores/    #切换到backstores，查看支持的后端存储类型

/backstores> ls
o- backstores ..................................................................... [...]
  o- block ............................................. [Storage Objects: 0]
  o- fileio .............................................. [Storage Objects: 0]
  o- pscsi .............................................. [Storage Objects: 0]
  o- ramdisk .......................................... [Storage Objects: 0]
/backstores> 

如果使用/dev/ram0-15 切换到 ramdisk分组，适应ramfs、tmpfs的切换到fileio分组。

/backstores/fileio> create lun1 /tmpfs/tmpfs.img  5G sparse=true   #创建一个5G稀疏的lun。

创建的lun需要关联映射后才可以使用。
切换到前边创建的的target门户。
/>cd iscsi/iqn.2003-01.org.linux-iscsi.server1.x8664:sn.c8ec20f691ae/tpg1/luns
/iscsi/iqn.20...1ae/tpg1/luns>create storage_object=/backstores/fileio/lun1 lun=1
Created LUN 1.

/iscsi/iqn.20...1ae/tpg1/luns> 
 
配置监听，默认监听3260
 
配置授权
/>cd iscsi/iqn.2003-01.org.linux-iscsi.server1.x8664:sn.c8ec20f691ae/tpg1
set attribute authentication=0
 set attribute generate_node_acls=1
 set attribute demo_mode_write_protect=0

/> saveconfig   #保存设置

重启服务  systemctl restart target.service
```  


initiator配置  
一、安装客户端  
```
yum install –y iscsi-initiator-utils-devel
```  

二、发现iscsi target  
```
iscsiadm --mode discoverydb --type sendtargets --portal target_IP –discover
```
记下获取targetname  
```
iscsiadm --mode node  --targetname iqn.20180214.com:test.target2  --portal target_IP:3260（默认的3260，可在target配置其他端口）  --login  ##登录连接 target
```  
查看/dev/ 下是不是有新的盘，现在就可以对这个新盘操作测试了。  
使用fdisk 命令查看新出现的磁盘是否跟LIO配置的磁盘大小一致。  

 
http://www.idcat.cn/centos7%E7%B3%BB%E7%BB%9Flio%E7%AE%80%E5%8D%95%E4%BD%BF%E7%94%A8.html
