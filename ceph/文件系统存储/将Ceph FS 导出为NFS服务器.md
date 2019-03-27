将Ceph FS 导出为NFS服务器
========================
1、安装软件  
``` # yum install -y nfs-utils nfs-ganesha ```  

2、启动 NFS所需的rpc服务  
```
# systemctl start rpcbind;
# systemctl enable rpcbind
# systemctl status rpcbind.service
```  

3、修改配置文件  
``` # vim /etc/ganesha/ganesha.conf ```  

4、通过提供Ganesha.conf 启动NFS Ganesha守护进程  
```
ganesha.nfsd -f /etc/ganesha.conf -L /var/log/ganesha.log -N NIV_DEBUG
showmount -e
```  
5、客户端挂载  
```
yum install -y nfs-utils
mkdir /mnt/cephnfs
mount -o rw,noatime node02:/ /mnt/cephnfs
```  
