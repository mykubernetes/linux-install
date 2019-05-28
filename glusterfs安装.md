glusterfs安装
===
1、每个节点分别安装并设置自启动  
``` 
# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# yum -y install centos-release-gluster
# yum -y install glusterfs-server
# systemctl enable glusterd
# systemctl start glusterd
```  

2、配置hosts文件  
```
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.101.69 node01
192.168.101.70 node02
192.168.101.71 node03
```  

3、在任一节点上适用glusterfs peer probe命令"发现"其他节点，组件集群
```
# gluster peer probe node02
# gluster peer probe node03
```  

4、通过节点状态命令gluster peer status 确认各节点已经加入统一可信池中  
```
# gluster peer status
Number of Peers: 2

Hostname: node02
Uuid: c5e929e5-3b42-4d07-b1d1-510f10a62b03
State: Peer in Cluster (Connected)

Hostname: node03
Uuid: 948018c8-988b-4f77-9d12-629d0f630110
State: Peer in Cluster (Connected)
```  

