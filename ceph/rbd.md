安装rbd客户端工具
===============

1、在服务器端创建 ceph 块客户端用户名和认证密钥  
``` # ceph auth get-or-create client.rbd mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd' |tee ./ceph.client.rbd.keyring ```  

2、将认证秘钥和配置文件拷贝到客户端  
```
# scp ceph.client.rbd.keyring node04:/etc/ceph/
#scp /etc/ceph/ceph.conf node04:/etc/ceph/
```  
3、客户端检查是否符合块设备环境要求
```
uname -r
modprobe rbd
echo $?
```  
4、安装ceph客户端
```
wget -O /etc/yum.repos.d/ceph.repo https://raw.githubusercontent.com/aishangwei/ceph-demo/master/ceph-deploy/ceph.repo
yum -y install ceph
cat /etc/ceph/ceph.client.rbd.keyring
ceph -s --name client.rbd
```  
