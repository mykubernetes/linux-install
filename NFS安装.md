NFS安装
=======
1、查看系统是否已安装NFS  
```
# rpm -qa | grep nfs
# rpm -qa | grep rpcbind
```  

2、安装NFS  
``` yum -y install nfs-utils rpcbind ```  

3、创建nfs挂载目录  
```
mkdir -p /opt/data/nfs1
chmod 666 /opt/data/nfs1
```  

4、编辑export文件  
```
# vim /etc/exports 
/opt/data/nfs1 192.168.101.0/24(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)
```  
常用参数  
rw 读写  
ro 只读  
sync 数据会同步写入到内存与硬盘中  
async 数据会先暂存于内存当中，而非直接写入硬盘  
no_root_squash  登入 NFS 主机，登入 NFS 主机，他就具有 root 的权限
root_squash  客户端 root 的身份会由 root_squash 的设定压缩成 nfsnobody  
all_squash  不论登入 NFS 的使用者身份为何， 他的身份都会被压缩成为匿名用户  
anonuid  匿名用户的UID值
anongid  匿名用户的GID值,备注：其中anonuid=1000,anongid=1000,为此目录用户web的ID号,达到连接NFS用户权限一致。
anon  

5、配置生效  
``` # exportfs -r ```  

6、启动rpcbind、nfs服务  
```
systemctl start rpcbind 
systemctl start nfs
```  

7、查看 RPC 服务的注册状况  
```
# rpcinfo -p localhost
program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp  49979  mountd
    100005    1   tcp  58393  mountd
    100005    2   udp  45516  mountd
    100005    2   tcp  37792  mountd
    100005    3   udp  32997  mountd
    100005    3   tcp  39937  mountd
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    2   tcp   2049  nfs_acl
    100227    3   tcp   2049  nfs_acl
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl
    100021    1   udp  51112  nlockmgr
    100021    3   udp  51112  nlockmgr
    100021    4   udp  51112  nlockmgr
    100021    1   tcp  43271  nlockmgr
    100021    3   tcp  43271  nlockmgr
    100021    4   tcp  43271  nlockmgr
```  
选项与参数：  
-p ：针对某 IP (未写则预设为本机) 显示出所有的 port 与 porgram 的信息  
-t ：针对某主机的某支程序检查其 TCP 封包所在的软件版本  
-u ：针对某主机的某支程序检查其 UDP 封包所在的软件版本  

8、查看服务器抛出的共享目录信息  
```
# showmount -e localhost
Export list for localhost:
/opt/data/nfs1 192.168.2.0/24
```  
选项与参数：  
-a ：显示目前主机与客户端的 NFS 联机分享的状态  
-e ：显示某部主机的 /etc/exports 所分享的目录数据  

二、客户端配置  
1、安装客户端工具
``` # yum -y install nfs-utils ```  

2、创建客户端挂载目录  
``` mkdir /opt/data/mount/nfs ```  

3、查看服务器抛出的共享目录信息  
```
# showmount -e 192.168.2.203
Export list for 192.168.2.203:
/opt/data/nfs1 192.168.2.0/24
```  

4、挂载  
``` # mount -t nfs 192.168.2.203:/opt/data/nfs1 /l/opt/data/mount/nfs1 -o proto=tcp -o nolock ```  

