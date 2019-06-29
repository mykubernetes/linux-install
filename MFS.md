1、安装依赖  
``` yum install rpm-build gcc gcc-c++ fuse-devel zlib-devel -y ```  

2、创建mfs用户  
``` useradd -s /sbin/nologin mfs ```  

3、编译mfs  
```
wget https://github.com/moosefs/moosefs/archive/v3.0.105.tar.gz
cd moosefs
./configure --prefix=/opt/mfs --with-default-user=mfs --with-default-group=mfs
make && make install
```  

4、进入安装目录重命名配置文件  
```
cd /opt/mfs/etc/mfs
cp mfsmaster.cfg.sample mfsmaster.cfg
cp mfsexports.cfg.sample mfsexports.cfg
cp mfsmetalogger.cfg.sample mfsmetalogger.cfg
cp mfstopology.cfg.sample mfstopology.cfg
cd /opt/mfs/var/mfs
cp metadata.mfs.empty metadata.mfs
```  

5、更改属主属组  
``` chown -R mfs.mfs /opt/mfs/ ```  

6、启动  
``` sbin/sbin/mfsmaster start ```  

7、配置共享访问权限  
```
vim mfsexports.cfg
192.168.101.0/24         /       rw,alldirs,maproot=0
```  
1)客户端IP地址  
```
*                       所有 IP 地址 
x.x.x.x                 单个 IP 地址 
x.x.x.x/m.m.m.m         IP 网络地址/子网掩码 
f.f.f.f-t.t.t.t               IP 段 
```  

2)被挂载的目录  
```
/                      表示 MooseFS 的根 
.                      表示 MFSMETA 文件系
``` 

3)客户端拥有的权限  
```
ro                     只读
rw                     读写
alldirs                允许挂载任何指定的子目录 
maproot                映射为 root 用户还是指定的用户
password               指定客户端密码
```  
