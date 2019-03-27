1、安装ceph-radosgw  
``` # yum -y install ceph-radosgw ```  
2、部署  
``` # ceph-deploy rgw create node01 node02 node03 ```  
3、检查服务是否开启  
``` netstat -tnlupn |grep 7480 ```  

4、可配置80端口（不用修改）  
```
vi /etc/ceph/ceph.conf
…….
[client.rgw.node01]
rgw_frontends = "civetweb port=80"
sudo systemctl restart ceph-radosgw@rgw.node01.service
```
5、创建池  
```
wget https://raw.githubusercontent.com/aishangwei/ceph-demo/master/ceph-deploy/rgw/pool
wget https://raw.githubusercontent.com/aishangwei/ceph-demo/master/ceph-deploy/rgw/create_pool.sh
chmod +x create_pool.sh
./create_pool.sh
```  
6、测试是否能够访问ceph 集群  
```
sudo cp
ceph -s -k /var/lib/ceph/radosgw/ceph-rgw.node03/keyring --name client.rgw.node03
```
