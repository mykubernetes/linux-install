将Ceph FS 导出为NFS服务器
========================
下载地址：http://download.ceph.com/nfs-ganesha/rpm-V2.7-stable/luminous/x86_64/  
```
#下载官网包安装方法
# wget http://download.ceph.com/nfs-ganesha/rpm-V2.7-stable/luminous/x86_64/libntirpc-1.7.1-0.1.el7.x86_64.rpm
# wget http://download.ceph.com/nfs-ganesha/rpm-V2.7-stable/luminous/x86_64/nfs-ganesha-2.7.1-0.1.el7.x86_64.rpm
# wget http://download.ceph.com/nfs-ganesha/rpm-V2.7-stable/luminous/x86_64/nfs-ganesha-ceph-2.7.1-0.1.el7.x86_64.rpm
# yum -y install libntirpc-1.7.1-0.1.el7.x86_64.rpm nfs-ganesha-2.7.1-0.1.el7.x86_64.rpm nfs-ganesha-ceph-2.7.1-0.1.el7.x86_64.rpm


# systemctl start rpcbind; systemctl enable rpcbind
# systemctl start rpc-statd.service
```  

1、使用yum源安装软件  
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
或者  
```
# grep -v ".*#" /etc/ganesha/ganesha.conf|grep -v "^$"
EXPORT
{
    Export_Id = 12345;
    Path = /;
    Pseudo = /cephfs;
    Protocols = 4;
    Access_Type = RW;
    Squash = no_root_squash;
    Sectype = sys;
    FSAL {
        Name = CEPH;
            User_Id = cephfs;
            Secret_Access_Key = "AQAj8s9cJ/u/ERAAMh+Ey9mNLaBEk1/yff7AOw==";
    }
}
```  
如果放在ceph集群节点，可以直接使用ceph.client.admin ,就不需要设置User_Id和Secret_Access_Key  

4、通过提供Ganesha.conf 启动NFS Ganesha守护进程，并输出日志到/var/log/ganesha.log下，为deubg模式 
```
# ganesha.nfsd -f /etc/ganesha/ganesha.conf -L /var/log/ganesha.log -N NIV_DEBUG   # 不需要执行，改成守护进程模式启动
启动
# systemctl start nfs-ganesha
# systemctl enable nfs-ganesha

# showmount -e
Export list for node02:

```  
5、客户端挂载  
```
# yum install -y nfs-utils
# mkdir /mnt/cephnfs
# mount -t nfs -o nfsvers=4.1,noauto,soft,sync,proto=tcp node02:/ /mnt/cephnfs
验证
# df -h /mnt/cephnfs
Filesystem      Size  Used Avail Use% Mounted on
node02:/           0     0     0    - /mnt/cephnfs

```  
