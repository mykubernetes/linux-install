将Ceph FS 导出为NFS服务器
========================
1、安装软件  
``` # yum install -y nfs-utils nfs-ganesha ```  

2、启动 NFS所需的rpc服务  
```
systemctl start rpcbind
systemctl enable rpcbind
systemctl status rpcbind.service
```  

3、修改配置文件  
``` # vim /etc/ganesha/ganesha.conf ```  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/ceph.png)  
```
EXPORT
{
	# Export Id (mandatory, each EXPORT must have a unique Export_Id)
	Export_Id = 77;

	# Exported path (mandatory)
	Path = "/";

	# Pseudo Path (required for NFS v4)
	Pseudo = "/";

	# Required for access (default is None)
	# Could use CLIENT blocks instead
	Access_Type = RW;
        SecType = "none";
        NFS_Protocols = "3";
        Squash = No_ROOT_Squash;

	# Exporting FSAL
	FSAL {
		Name = CEPH;
	}
}
```  

4、通过提供Ganesha.conf 启动NFS Ganesha守护进程，并输出日志到/var/log/ganesha.log下，为deubg模式 
```
# ganesha.nfsd -f /etc/ganesha/ganesha.conf -L /var/log/ganesha.log -N NIV_DEBUG

# showmount -e
Export list for node02:

```  
5、客户端挂载  
```
# yum install -y nfs-utils
# mkdir /mnt/cephnfs
# mount -o rw,noatime node02:/ /mnt/cephnfs
验证
# df -h /mnt/cephnfs
Filesystem      Size  Used Avail Use% Mounted on
node02:/           0     0     0    - /mnt/cephnfs

```  
