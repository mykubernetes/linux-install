# 前言

ceph版本：Jewel

由于ceph安装后，磁盘并不是开机自动挂载，每当重启后，导致osd服务无法正常运行，所以需要手动修改/etc/fstab。

而考虑到磁盘插拔导致盘符不正确的问题，所以使用磁盘的UUID进行挂载.

# 管理节点

可以免密码ssh到所有osd节点的一台服务器

准备两个脚本:manage.sh和fstab.sh,一个txt文件：host.txt, 放在同级目录

manage.sh: 用于管理节点操作使用，包括拷贝fstab.sh脚本等

fstab.sh: 放置到所有的osd节点，进行修改/etc/fstab操作

host.txt: 用于放置管理节点，列出了所有osd节点的ip,每行一个

```
host.txt:
172.*.*.*
172.*.*.*
172.*.*.*
...
```
```
manage.sh:
#!/bin/bash
while read ip
do
  echo "begin $ip";
  scp fstab.sh $ip:~/ && ssh -n $ip "./fstab.sh"
  echo "finish $ip";
done < host
fstab.sh
#!/bin/bash
cp /etc/fstab /etc/fstab.bk &&  lsblk -o UUID,MOUNTPOINT,FSTYPE|grep osd | while read line  
do  
 echo UUID=$line  defaults 0 0 >> /etc/fstab
done
```
这样会把所有节点的/etc/fstab先备份为/etc/fstab.bk,然后再修改
